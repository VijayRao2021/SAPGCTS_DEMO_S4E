*******************************************************************
*   THIS FILE IS GENERATED BY THE FUNCTION LIBRARY.               *
*   NEVER CHANGE IT MANUALLY, PLEASE!                             *
*******************************************************************
FUNCTION $$UNIT$$ VIEWFRAME_ZV_MAIL_PROGRAM

    IMPORTING
       VALUE(VIEW_ACTION) DEFAULT 'S'
       VALUE(VIEW_NAME) LIKE !DD02V-TABNAME
       VALUE(CORR_NUMBER) LIKE !E070-TRKORR DEFAULT ' '
    TABLES
       !DBA_SELLIST STRUCTURE !VIMSELLIST
       !DPL_SELLIST STRUCTURE !VIMSELLIST
       !EXCL_CUA_FUNCT STRUCTURE !VIMEXCLFUN
       !X_HEADER STRUCTURE !VIMDESC
       !X_NAMTAB STRUCTURE !VIMNAMTAB
    EXCEPTIONS
       !NO_VALUE_FOR_SUBSET_IDENT
       !MISSING_CORR_NUMBER.