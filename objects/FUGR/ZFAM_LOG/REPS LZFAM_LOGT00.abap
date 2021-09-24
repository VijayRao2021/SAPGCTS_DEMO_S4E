*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 17.09.2021 at 09:20:40
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZFAM_LOG........................................*
DATA:  BEGIN OF STATUS_ZFAM_LOG                      .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZFAM_LOG                      .
CONTROLS: TCTRL_ZFAM_LOG
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZFAM_LOG                      .
TABLES: ZFAM_LOG                       .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .