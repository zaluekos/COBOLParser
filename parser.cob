       IDENTIFICATION DIVISION.
       PROGRAM-ID. CUST-FLAT-PARSER.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT INPUT-FILE  ASSIGN TO "data/customers_input.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-IN-FILE-STATUS.
           SELECT OUTPUT-FILE ASSIGN TO "data/customers_output.csv"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-OUT-FILE-STATUS.

       DATA DIVISION.
       FILE SECTION.

       FD  INPUT-FILE.
       01  INPUT-RAW-RECORD                   PIC X(80).

       FD  OUTPUT-FILE.
       01  OUTPUT-LINE                        PIC X(512).

       WORKING-STORAGE SECTION.

       77  WS-IN-FILE-STATUS                  PIC XX VALUE SPACES.
       77  WS-OUT-FILE-STATUS                 PIC XX VALUE SPACES.
       77  WS-EOF                             PIC X VALUE "N".
       77  WS-REC-COUNT                       PIC 9(9) VALUE 0.
       77  WS-GOOD-COUNT                      PIC 9(9) VALUE 0.
       77  WS-BAD-COUNT                       PIC 9(9) VALUE 0.
       77  WS-OUT-LEN                         PIC 9(4) VALUE 0.

       01  WS-RAW-RECORD.
           05 WS-RAW-CUST-ID                  PIC X(8).
           05 WS-RAW-FIRST-NAME               PIC X(15).
           05 WS-RAW-LAST-NAME                PIC X(20).
           05 WS-RAW-YEAR                     PIC 9(4).
           05 WS-RAW-MONTH                    PIC 9(2).
           05 WS-RAW-DAY                      PIC 9(2).
           05 WS-RAW-STATUS                   PIC X(1).
           05 WS-RAW-BALANCE                  PIC S9(7)V99 COMP-3.
           05 WS-RAW-FILLER                   PIC X(23).

       01  WS-RAW-RECORD-REDEFINES REDEFINES WS-RAW-RECORD.
           05 WS-REDEF-FULL-RECORD            PIC X(80).

       01  WS-NORMALIZED-REC.
           05 WS-NORM-CUST-ID                 PIC X(8).
           05 WS-NORM-FIRST-NAME              PIC X(15).
           05 WS-NORM-LAST-NAME               PIC X(20).
           05 WS-NORM-YEAR                    PIC 9(4).
           05 WS-NORM-MONTH                   PIC 99.
           05 WS-NORM-DAY                     PIC 99.
           05 WS-NORM-STATUS                  PIC X(1).
           05 WS-NORM-BALANCE-TXT             PIC X(16).
           05 WS-NORM-VALID-FLAG              PIC X VALUE "Y".
           05 WS-NORM-ERR-MSG                 PIC X(120).

       01  WS-CSV-BUFFER                      PIC X(512).

       01  WS-CSV-PARTS.
           05 WS-CSV-CUST-ID                  PIC X(20).
           05 WS-CSV-FIRST-NAME               PIC X(30).
           05 WS-CSV-LAST-NAME                PIC X(40).
           05 WS-CSV-DATE                     PIC X(10).
           05 WS-CSV-STATUS                   PIC X(2).
           05 WS-CSV-BALANCE                  PIC X(20).

       01  WS-STATUS-TABLE.
           05 FILLER OCCURS 3 TIMES.
              10 WS-STATUS-CODE               PIC X(1).
              10 WS-STATUS-TEXT               PIC X(10).

       01  WS-STATUS-TABLE-VALUES REDEFINES WS-STATUS-TABLE.
           05 FILLER                         PIC X(33).

       01  WS-DATE-PARTS.
           05 WS-YYYY                         PIC 9(4).
           05 WS-MM                           PIC 99.
           05 WS-DD                           PIC 99.

       01  WS-CONSTS.
           05 WS-CSV-HEADER.
              10 FILLER PIC X(8)  VALUE "CUST-ID,".
              10 FILLER PIC X(11) VALUE "FIRST-NAME,".
              10 FILLER PIC X(10) VALUE "LAST-NAME,".
              10 FILLER PIC X(5)  VALUE "DATE,".
              10 FILLER PIC X(8)  VALUE "STATUS,".
              10 FILLER PIC X(8)  VALUE "BALANCE".

       PROCEDURE DIVISION.

       MAIN-LOGIC.
           DISPLAY "PROGRAM STARTED"
           DISPLAY "INPUT FILE: data/customers_input.dat"
           DISPLAY "OUTPUT FILE: data/customers_output.csv"
           PERFORM INIT-STATUS-TABLE
           OPEN INPUT INPUT-FILE
           DISPLAY "OUT STATUS: " WS-OUT-FILE-STATUS
           IF WS-IN-FILE-STATUS NOT = "00"
               DISPLAY "ERROR OPENING INPUT FILE: " WS-IN-FILE-STATUS
               STOP RUN
           END-IF

           OPEN OUTPUT OUTPUT-FILE
           DISPLAY "OUT STATUS: " WS-OUT-FILE-STATUS
           IF WS-OUT-FILE-STATUS NOT = "00"
               DISPLAY "ERROR OPENING OUTPUT FILE: " WS-OUT-FILE-STATUS
               CLOSE INPUT-FILE
               STOP RUN
           END-IF

           MOVE WS-CSV-HEADER TO OUTPUT-LINE
           WRITE OUTPUT-LINE
           DISPLAY "WRITE STATUS: " WS-OUT-FILE-STATUS
           CONTINUE AFTER 5 SECONDS

           PERFORM UNTIL WS-EOF = "Y"
               READ INPUT-FILE
                   AT END
                       MOVE "Y" TO WS-EOF
                   NOT AT END
                       ADD 1 TO WS-REC-COUNT
                       PERFORM PROCESS-RECORD
               END-READ
           END-PERFORM

           DISPLAY "RECORDS READ:  " WS-REC-COUNT
           DISPLAY "RECORDS GOOD:  " WS-GOOD-COUNT
           DISPLAY "RECORDS BAD:   " WS-BAD-COUNT

           CLOSE INPUT-FILE OUTPUT-FILE
           STOP RUN.

       INIT-STATUS-TABLE.
           MOVE "A" TO WS-STATUS-CODE (1)
           MOVE "ACTIVE    " TO WS-STATUS-TEXT (1)
           MOVE "P" TO WS-STATUS-CODE (2)
           MOVE "PENDING   " TO WS-STATUS-TEXT (2)
           MOVE "I" TO WS-STATUS-CODE (3)
           MOVE "INACTIVE  " TO WS-STATUS-TEXT (3)
           .

       PROCESS-RECORD.
           MOVE INPUT-RAW-RECORD TO WS-RAW-RECORD

           PERFORM MOVE-TO-NORMALIZED

           PERFORM VALIDATE-RECORD

           IF WS-NORM-VALID-FLAG = "Y"
               PERFORM BUILD-CSV-LINE
               WRITE OUTPUT-LINE
               ADD 1 TO WS-GOOD-COUNT
           ELSE
               ADD 1 TO WS-BAD-COUNT
               DISPLAY "INVALID RECORD " WS-REC-COUNT ": "
                       WS-NORM-ERR-MSG
           END-IF
           .

       MOVE-TO-NORMALIZED.
           MOVE WS-RAW-CUST-ID   TO WS-NORM-CUST-ID
           MOVE WS-RAW-FIRST-NAME TO WS-NORM-FIRST-NAME
           MOVE WS-RAW-LAST-NAME  TO WS-NORM-LAST-NAME
           MOVE WS-RAW-YEAR       TO WS-NORM-YEAR
           MOVE WS-RAW-MONTH      TO WS-NORM-MONTH
           MOVE WS-RAW-DAY        TO WS-NORM-DAY
           MOVE WS-RAW-STATUS     TO WS-NORM-STATUS
           MOVE FUNCTION NUMVAL-C(WS-RAW-BALANCE) TO WS-NORM-BALANCE-TXT
           MOVE "Y" TO WS-NORM-VALID-FLAG
           MOVE SPACES TO WS-NORM-ERR-MSG
           .

       VALIDATE-RECORD.
           IF FUNCTION TRIM(WS-NORM-CUST-ID) = SPACES
               MOVE "N" TO WS-NORM-VALID-FLAG
               MOVE "ERR-NO-ID" TO WS-NORM-ERR-MSG
           END-IF

           IF WS-NORM-VALID-FLAG = "Y"
               IF WS-NORM-STATUS NOT = "A"
                  AND WS-NORM-STATUS NOT = "P"
                  AND WS-NORM-STATUS NOT = "I"
                   MOVE "N" TO WS-NORM-VALID-FLAG
                   MOVE "ERR-BAD-STAT" TO WS-NORM-ERR-MSG
               END-IF
           END-IF

           IF WS-NORM-VALID-FLAG = "Y"
               IF WS-NORM-MONTH < 1 OR WS-NORM-MONTH > 12
                   MOVE "N" TO WS-NORM-VALID-FLAG
                   MOVE "ERR-BAD-DATE" TO WS-NORM-ERR-MSG
               END-IF
           END-IF

           IF WS-NORM-VALID-FLAG = "Y"
               IF WS-NORM-DAY < 1 OR WS-NORM-DAY > 31
                   MOVE "N" TO WS-NORM-VALID-FLAG
                   MOVE "ERR-BAD-DATE" TO WS-NORM-ERR-MSG
               END-IF
           END-IF
           .

       BUILD-CSV-LINE.
           MOVE SPACES TO WS-CSV-BUFFER
           MOVE SPACES TO WS-CSV-PARTS

           MOVE FUNCTION TRIM(WS-NORM-CUST-ID)   TO WS-CSV-CUST-ID
           MOVE FUNCTION TRIM(WS-NORM-FIRST-NAME) TO WS-CSV-FIRST-NAME
           MOVE FUNCTION TRIM(WS-NORM-LAST-NAME)  TO WS-CSV-LAST-NAME

           MOVE WS-NORM-YEAR TO WS-YYYY
           MOVE WS-NORM-MONTH TO WS-MM
           MOVE WS-NORM-DAY   TO WS-DD

           STRING
               '"' DELIMITED BY SIZE
               FUNCTION TRIM(WS-CSV-CUST-ID) DELIMITED BY SIZE
               '",' DELIMITED BY SIZE
               '"' DELIMITED BY SIZE
               FUNCTION TRIM(WS-CSV-FIRST-NAME) DELIMITED BY SIZE
               '",' DELIMITED BY SIZE
               '"' DELIMITED BY SIZE
               FUNCTION TRIM(WS-CSV-LAST-NAME) DELIMITED BY SIZE
               '",' DELIMITED BY SIZE
               '"' DELIMITED BY SIZE
               WS-YYYY DELIMITED BY SIZE
               '-' DELIMITED BY SIZE
               WS-MM DELIMITED BY SIZE
               '-' DELIMITED BY SIZE
               WS-DD DELIMITED BY SIZE
               '",' DELIMITED BY SIZE
               '"' DELIMITED BY SIZE
               WS-NORM-STATUS DELIMITED BY SIZE
               '",' DELIMITED BY SIZE
               FUNCTION TRIM(WS-NORM-BALANCE-TXT) DELIMITED BY SIZE
               INTO WS-CSV-BUFFER
           END-STRING
           .
