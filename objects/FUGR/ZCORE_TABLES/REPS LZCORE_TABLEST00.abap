*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 05.02.2019 at 16:47:40
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_PROC_HEADER..................................*
TABLES: ZV_PROC_HEADER, *ZV_PROC_HEADER. "view work areas
CONTROLS: TCTRL_ZV_PROC_HEADER
TYPE TABLEVIEW USING SCREEN '0001'.
DATA: BEGIN OF STATUS_ZV_PROC_HEADER. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_PROC_HEADER.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_PROC_HEADER_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_PROC_HEADER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_PROC_HEADER_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_PROC_HEADER_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_PROC_HEADER.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_PROC_HEADER_TOTAL.

*...processing: ZV_PROC_TEXT....................................*
TABLES: ZV_PROC_TEXT, *ZV_PROC_TEXT. "view work areas
CONTROLS: TCTRL_ZV_PROC_TEXT
TYPE TABLEVIEW USING SCREEN '0002'.
DATA: BEGIN OF STATUS_ZV_PROC_TEXT. "state vector
          INCLUDE STRUCTURE VIMSTATUS.
DATA: END OF STATUS_ZV_PROC_TEXT.
* Table for entries selected to show on screen
DATA: BEGIN OF ZV_PROC_TEXT_EXTRACT OCCURS 0010.
INCLUDE STRUCTURE ZV_PROC_TEXT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_PROC_TEXT_EXTRACT.
* Table for all entries loaded from database
DATA: BEGIN OF ZV_PROC_TEXT_TOTAL OCCURS 0010.
INCLUDE STRUCTURE ZV_PROC_TEXT.
          INCLUDE STRUCTURE VIMFLAGTAB.
DATA: END OF ZV_PROC_TEXT_TOTAL.

*.........table declarations:.................................*
TABLES: ZPROC_HEADER                   .
TABLES: ZPROC_TEXT                     .