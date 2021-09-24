*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 23.05.2016 at 14:02:53 by user CRESSOD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZDSET_OBJECT_DAT................................*
DATA:  BEGIN OF STATUS_ZDSET_OBJECT_DAT              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZDSET_OBJECT_DAT              .
CONTROLS: TCTRL_ZDSET_OBJECT_DAT
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZDSET_OBJECT_DAT              .
TABLES: ZDSET_OBJECT_DAT               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .