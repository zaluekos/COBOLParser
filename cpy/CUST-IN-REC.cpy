*================================================================*
      * CUST-IN-REC.cpy - Fixed Width Input Layout (80 Bytes total)
      *================================================================*
       01  IN-CUSTOMER-RECORD.
           05  IN-CUST-ID              PIC X(8).
           05  IN-CUST-NAME.
               10  IN-FIRST-NAME       PIC X(15).
               10  IN-LAST-NAME        PIC X(20).
           05  IN-JOIN-DATE.
               10  IN-JOIN-YYYY        PIC 9(4).
               10  IN-JOIN-MM          PIC 9(2).
               10  IN-JOIN-DD          PIC 9(2).
           05  IN-ACCOUNT-STATUS       PIC X(1).
               88  STATUS-ACTIVE       VALUE 'A'.
               88  STATUS-INACTIVE     VALUE 'I'.
               88  STATUS-PENDING      VALUE 'P'.
           05  IN-BALANCE              PIC S9(7)V99 COMP-3.
           05  FILLER                  PIC X(23).
