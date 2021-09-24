*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.09.2021 at 10:20:41
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_FILE_SERVER..................................*
TABLES: ZV_FILE_SERVER, *ZV_FILE_SERVER. "view work areas
CONTROLS: TCTRL_ZV_FILE_SERVER
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_FILE_SERVER. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_FILE_SERVER.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_FILE_SERVER_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_FILE_SERVER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_FILE_SERVER_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_FILE_SERVER_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_FILE_SERVER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_FILE_SERVER_TOTAL.

*.........table declarations:.................................*
TABLES: ZFILE_SERVER                   .