*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.09.2021 at 10:17:38
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_FILE_TRANSFER................................*
TABLES: ZV_FILE_TRANSFER, *ZV_FILE_TRANSFER. "view work areas
CONTROLS: TCTRL_ZV_FILE_TRANSFER
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_FILE_TRANSFER. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_FILE_TRANSFER.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_FILE_TRANSFER_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_FILE_TRANSFER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_FILE_TRANSFER_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_FILE_TRANSFER_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_FILE_TRANSFER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_FILE_TRANSFER_TOTAL.

*.........table declarations:.................................*
TABLES: ZFILE_TRANSFER                 .