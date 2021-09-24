*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZFAM_TABLE_MAINT
*   generation date: 18.09.2021 at 16:52:14
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZFAM_TABLE_MAINT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.