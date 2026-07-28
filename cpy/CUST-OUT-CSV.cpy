*================================================================*
      * CUST-OUT-CSV.cpy - Unpacked / Formatted CSV Buffer
      *================================================================*
       01  WS-CSV-FORMATTED-FIELDS.
           05  WS-CSV-ID               PIC X(8).
           05  WS-CSV-NAME             PIC X(36).
           05  WS-CSV-DATE             PIC X(10).
           05  WS-CSV-STATUS           PIC X(10).
           05  WS-CSV-BALANCE          PIC -ZZZ,ZZ9.99.

       01  WS-CSV-LINE                 PIC X(150).