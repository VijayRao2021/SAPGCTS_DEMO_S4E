*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBC_MAIL_TABLES
*   generation date: 17.09.2021 at 09:26:54
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBC_MAIL_TABLES    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.