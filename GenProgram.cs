// Record generator with deliberate corrupted records for the COBOL CSV Parser
using System;
using System.IO;
using System.Text;

class GenProgram
{
    static void Main(string[] args)
    {
        string dataDir = Path.Combine(AppContext.BaseDirectory, "data");
        Directory.CreateDirectory(dataDir);

        string outputPath = Path.Combine("data", "customers_input.dat");
        Directory.CreateDirectory("data");

        Console.WriteLine($"Writing to {outputPath}");

        using (var fs = new FileStream(outputPath, FileMode.Create, FileAccess.Write))
        using (var writer = new BinaryWriter(fs))
        {
            // Record 1: Valid - Active Status, Positive Balance ($1,250.50)
            WriteRecord(writer, "CUST0001", "John", "Doe", 2024, 05, 15, 'A', 1250.50m);

            // Record 2: Valid - Pending Status, Zero Balance ($0.00)
            WriteRecord(writer, "CUST0002", "Jane", "Smith", 2023, 11, 01, 'P', 0.00m);

            // Record 3: INVALID - Bad Status Code 'X' (Should trigger ERR-BAD-STAT)
            WriteRecord(writer, "CUST0003", "Alice", "Brown", 2022, 08, 20, 'X', 450.75m);

            // Record 4: Valid - Inactive Status, Large Balance ($99,999.99)
            WriteRecord(writer, "CUST0004", "Bob", "Johnson", 2021, 01, 10, 'I', 99999.99m);

            // Record 5: INVALID - Bad Month 15 (Should trigger ERR-BAD-DATE)
            WriteRecord(writer, "CUST0005", "Charlie", "Davis", 2025, 15, 05, 'A', 300.00m);

            // Record 6: INVALID - Blank Customer ID (Should trigger ERR-NO-ID)
            WriteRecord(writer, "        ", "No", "IDUser", 2024, 03, 12, 'A', 100.00m);
        }

        Console.WriteLine($"Successfully generated test binary file at: {outputPath}");
        Console.WriteLine($"CWD: {Directory.GetCurrentDirectory()}");
        Console.WriteLine($"Base: {AppContext.BaseDirectory}");
        Console.WriteLine($"Output: {Path.GetFullPath(outputPath)}");
        Console.WriteLine($"Exists: {File.Exists(outputPath)}");
    }

    /// <summary>
    /// Writes an 80-byte fixed-width COBOL record matching CUST-IN-REC.cpy
    /// </summary>
    static void WriteRecord(
        BinaryWriter writer,
        string custId,
        string firstName,
        string lastName,
        int year,
        int month,
        int day,
        char status,
        decimal balance)
    {
        // 1. IN-CUST-ID: PIC X(8)
        writer.Write(Encoding.ASCII.GetBytes(PadRight(custId, 8)));

        // 2. IN-FIRST-NAME: PIC X(15)
        writer.Write(Encoding.ASCII.GetBytes(PadRight(firstName, 15)));

        // 3. IN-LAST-NAME: PIC X(20)
        writer.Write(Encoding.ASCII.GetBytes(PadRight(lastName, 20)));

        // 4. IN-JOIN-DATE: YYYY (4 bytes), MM (2 bytes), DD (2 bytes)
        writer.Write(Encoding.ASCII.GetBytes(year.ToString("D4")));
        writer.Write(Encoding.ASCII.GetBytes(month.ToString("D2")));
        writer.Write(Encoding.ASCII.GetBytes(day.ToString("D2")));

        // 5. IN-ACCOUNT-STATUS: PIC X(1)
        writer.Write((byte)status);

        // 6. IN-BALANCE: PIC S9(7)V99 COMP-3 (5 Bytes)
        byte[] packedBalance = EncodeComp3(balance, 7, 2);
        writer.Write(packedBalance);

        // 7. FILLER: PIC X(23) - Pad remaining bytes to make total record length = 80
        writer.Write(Encoding.ASCII.GetBytes(new string(' ', 23)));
    }

    /// <summary>
    /// Encodes a decimal into COBOL COMP-3 (Packed Decimal) format.
    /// </summary>
    static byte[] EncodeComp3(decimal value, int integerDigits, int decimalDigits)
    {
        // Total digits = 9 (7 integer + 2 decimal). Total nibbles = 10 (9 digits + 1 sign).
        int totalDigits = integerDigits + decimalDigits;
        int totalNibbles = totalDigits + 1;
        int byteLength = (totalNibbles + 1) / 2; // 5 bytes

        // Convert value to absolute integer string (e.g. 1250.50 -> "0000125050")
        decimal absValue = Math.Abs(value);
        long scaledValue = (long)Math.Round(absValue * (decimal)Math.Pow(10, decimalDigits));
        string digitString = scaledValue.ToString().PadLeft(totalDigits, '0');

        byte[] comp3Bytes = new byte[byteLength];

        // Populate digit nibbles
        for (int i = 0; i < totalDigits; i++)
        {
            int digit = digitString[i] - '0';
            if (i % 2 == 0)
            {
                comp3Bytes[i / 2] |= (byte)(digit << 4);
            }
            else
            {
                comp3Bytes[i / 2] |= (byte)(digit & 0x0F);
            }
        }

        // Determine Sign Nibble: 0xC for Positive (+), 0xD for Negative (-)
        byte signNibble = (value < 0) ? (byte)0x0D : (byte)0xC;

        // Place sign nibble in the lower 4 bits of the last byte
        comp3Bytes[byteLength - 1] |= (byte)(signNibble & 0x0F);

        return comp3Bytes;
    }

    static string PadRight(string input, int length)
    {
        if (input.Length > length)
            return input.Substring(0, length);
        return input.PadRight(length, ' ');
    }
}
