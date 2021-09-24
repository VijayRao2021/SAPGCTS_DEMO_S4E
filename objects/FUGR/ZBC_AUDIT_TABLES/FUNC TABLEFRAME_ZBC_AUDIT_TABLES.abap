*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBC_AUDIT_TABLES
*   generation date: 04.07.2013 at 15:41:16 by user CRESSOD
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBC_AUDIT_TABLES   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.