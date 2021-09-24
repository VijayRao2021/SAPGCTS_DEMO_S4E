*---------------------------------------------------------------------*
*    view related data declarations
*   generation date: 17.09.2021 at 09:26:55
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZBC_MAIL_BLOCK..................................*
DATA:  BEGIN OF STATUS_ZBC_MAIL_BLOCK                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_MAIL_BLOCK                .
CONTROLS: TCTRL_ZBC_MAIL_BLOCK
            TYPE TABLEVIEW USING SCREEN '0004'.
*...processing: ZBC_MAIL_HEADER.................................*
DATA:  BEGIN OF STATUS_ZBC_MAIL_HEADER               .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_MAIL_HEADER               .
CONTROLS: TCTRL_ZBC_MAIL_HEADER
            TYPE TABLEVIEW USING SCREEN '0002'.
*...processing: ZBC_MAIL_LIST...................................*
DATA:  BEGIN OF STATUS_ZBC_MAIL_LIST                 .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_MAIL_LIST                 .
CONTROLS: TCTRL_ZBC_MAIL_LIST
            TYPE TABLEVIEW USING SCREEN '0005'.
*...processing: ZBC_MAIL_PROGRAM................................*
DATA:  BEGIN OF STATUS_ZBC_MAIL_PROGRAM              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_MAIL_PROGRAM              .
CONTROLS: TCTRL_ZBC_MAIL_PROGRAM
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZBC_MAIL_RECIP..................................*
DATA:  BEGIN OF STATUS_ZBC_MAIL_RECIP                .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZBC_MAIL_RECIP                .
CONTROLS: TCTRL_ZBC_MAIL_RECIP
            TYPE TABLEVIEW USING SCREEN '0003'.
*.........table declarations:.................................*
TABLES: *ZBC_MAIL_BLOCK                .
TABLES: *ZBC_MAIL_HEADER               .
TABLES: *ZBC_MAIL_LIST                 .
TABLES: *ZBC_MAIL_PROGRAM              .
TABLES: *ZBC_MAIL_RECIP                .
TABLES: ZBC_MAIL_BLOCK                 .
TABLES: ZBC_MAIL_HEADER                .
TABLES: ZBC_MAIL_LIST                  .
TABLES: ZBC_MAIL_PROGRAM               .
TABLES: ZBC_MAIL_RECIP                 .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .