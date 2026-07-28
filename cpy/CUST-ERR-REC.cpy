*================================================================*
      * CUST-ERR-REC.cpy - Exception/Audit Log Layout
      *================================================================*
       01  WS-ERR-LINE.
           05  WS-ERR-TIMESTAMP        PIC X(19).
           05  FILLER                  PIC X(3)  VALUE " | ".
           05  WS-ERR-CUST-ID          PIC X(8).
           05  FILLER                  PIC X(3)  VALUE " | ".
           05  WS-ERR-CODE             PIC X(12).
           05  FILLER                  PIC X(3)  VALUE " | ".
           05  WS-ERR-MSG              PIC X(45).
