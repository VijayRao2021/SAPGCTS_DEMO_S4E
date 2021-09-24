*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 25.02.2016 at 11:34:32 by user CRESSOD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_AUDIT_CUST..................................*
DATA:  BEGIN OF STATUS_ZBC_AUDIT_CUST                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_AUDIT_CUST                .
CONTROLS: TCTRL_ZBC_AUDIT_CUST
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZE2E_DUP_CONTROL................................*
DATA:  BEGIN OF STATUS_ZE2E_DUP_CONTROL              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZE2E_DUP_CONTROL              .
CONTROLS: TCTRL_ZE2E_DUP_CONTROL
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZE2E_POSTPROC...................................*
DATA:  BEGIN OF STATUS_ZE2E_POSTPROC                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZE2E_POSTPROC                 .
CONTROLS: TCTRL_ZE2E_POSTPROC
            TYPE TABLEVIEW USING SCREEN '0003'.
*...processing: ZE2E_PSTPC_EVT..................................*
DATA:  BEGIN OF STATUS_ZE2E_PSTPC_EVT                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZE2E_PSTPC_EVT                .
CONTROLS: TCTRL_ZE2E_PSTPC_EVT
            TYPE TABLEVIEW USING SCREEN '0004'.
*.........table declarations:.................................*
TABLES: *ZBC_AUDIT_CUST                .
TABLES: *ZE2E_DUP_CONTROL              .
TABLES: *ZE2E_POSTPROC                 .
TABLES: *ZE2E_PSTPC_EVT                .
TABLES: ZBC_AUDIT_CUST                 .
TABLES: ZE2E_DUP_CONTROL               .
TABLES: ZE2E_POSTPROC                  .
TABLES: ZE2E_PSTPC_EVT                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .