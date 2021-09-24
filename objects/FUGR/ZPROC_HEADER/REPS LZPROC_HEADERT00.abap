*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.09.2021 at 07:04:36
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZPROC_HEADER....................................*
DATA:  BEGIN OF STATUS_ZPROC_HEADER                  .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZPROC_HEADER                  .
CONTROLS: TCTRL_ZPROC_HEADER
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *ZPROC_HEADER                  .
TABLES: ZPROC_HEADER                   .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .