*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDATA_TABLES
*   generation date: 20.05.2016 at 15:41:06 by user CRESSOD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDATA_TABLES       .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.