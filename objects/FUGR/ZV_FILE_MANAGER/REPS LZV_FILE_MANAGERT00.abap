*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 01.09.2021 at 10:14:30
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_FILE_MANAGER.................................*
TABLES: ZV_FILE_MANAGER, *ZV_FILE_MANAGER. "view work areas
CONTROLS: TCTRL_ZV_FILE_MANAGER
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_FILE_MANAGER. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_FILE_MANAGER.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_FILE_MANAGER_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_FILE_MANAGER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_FILE_MANAGER_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_FILE_MANAGER_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_FILE_MANAGER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_FILE_MANAGER_TOTAL.

*.........table declarations:.................................*
TABLES: ZFILE_MANAGER                  .