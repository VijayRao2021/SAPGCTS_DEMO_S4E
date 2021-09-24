*---------------------------------------------------------------------*
*    view related FORM routines
*   generation date: 18.08.2020 at 12:11:03
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
*...processing: ZV_MAIL_BLOCK...................................*
FORM GET_DATA_ZV_MAIL_BLOCK.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZBC_MAIL_BLOCK WHERE
(VIM_WHERETAB) .
    CLEAR ZV_MAIL_BLOCK .
ZV_MAIL_BLOCK-MANDT =
ZBC_MAIL_BLOCK-MANDT .
ZV_MAIL_BLOCK-PROGRAM_NAME =
ZBC_MAIL_BLOCK-PROGRAM_NAME .
ZV_MAIL_BLOCK-CONFIGURATION =
ZBC_MAIL_BLOCK-CONFIGURATION .
ZV_MAIL_BLOCK-BLOCK_NAME =
ZBC_MAIL_BLOCK-BLOCK_NAME .
ZV_MAIL_BLOCK-BLOCK_FORMAT =
ZBC_MAIL_BLOCK-BLOCK_FORMAT .
ZV_MAIL_BLOCK-ATTACHMENT =
ZBC_MAIL_BLOCK-ATTACHMENT .
ZV_MAIL_BLOCK-ATTACH_SUBJECT =
ZBC_MAIL_BLOCK-ATTACH_SUBJECT .
<VIM_TOTAL_STRUC> = ZV_MAIL_BLOCK.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZV_MAIL_BLOCK .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZV_MAIL_BLOCK.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZV_MAIL_BLOCK-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_BLOCK WHERE
  PROGRAM_NAME = ZV_MAIL_BLOCK-PROGRAM_NAME AND
  CONFIGURATION = ZV_MAIL_BLOCK-CONFIGURATION AND
  BLOCK_NAME = ZV_MAIL_BLOCK-BLOCK_NAME .
    IF SY-SUBRC = 0.
    DELETE ZBC_MAIL_BLOCK .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_BLOCK WHERE
  PROGRAM_NAME = ZV_MAIL_BLOCK-PROGRAM_NAME AND
  CONFIGURATION = ZV_MAIL_BLOCK-CONFIGURATION AND
  BLOCK_NAME = ZV_MAIL_BLOCK-BLOCK_NAME .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZBC_MAIL_BLOCK.
    ENDIF.
ZBC_MAIL_BLOCK-MANDT =
ZV_MAIL_BLOCK-MANDT .
ZBC_MAIL_BLOCK-PROGRAM_NAME =
ZV_MAIL_BLOCK-PROGRAM_NAME .
ZBC_MAIL_BLOCK-CONFIGURATION =
ZV_MAIL_BLOCK-CONFIGURATION .
ZBC_MAIL_BLOCK-BLOCK_NAME =
ZV_MAIL_BLOCK-BLOCK_NAME .
ZBC_MAIL_BLOCK-BLOCK_FORMAT =
ZV_MAIL_BLOCK-BLOCK_FORMAT .
ZBC_MAIL_BLOCK-ATTACHMENT =
ZV_MAIL_BLOCK-ATTACHMENT .
ZBC_MAIL_BLOCK-ATTACH_SUBJECT =
ZV_MAIL_BLOCK-ATTACH_SUBJECT .
    IF SY-SUBRC = 0.
    UPDATE ZBC_MAIL_BLOCK ##WARN_OK.
    ELSE.
    INSERT ZBC_MAIL_BLOCK .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZV_MAIL_BLOCK-UPD_FLAG,
STATUS_ZV_MAIL_BLOCK-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZV_MAIL_BLOCK.
  SELECT SINGLE * FROM ZBC_MAIL_BLOCK WHERE
PROGRAM_NAME = ZV_MAIL_BLOCK-PROGRAM_NAME AND
CONFIGURATION = ZV_MAIL_BLOCK-CONFIGURATION AND
BLOCK_NAME = ZV_MAIL_BLOCK-BLOCK_NAME .
ZV_MAIL_BLOCK-MANDT =
ZBC_MAIL_BLOCK-MANDT .
ZV_MAIL_BLOCK-PROGRAM_NAME =
ZBC_MAIL_BLOCK-PROGRAM_NAME .
ZV_MAIL_BLOCK-CONFIGURATION =
ZBC_MAIL_BLOCK-CONFIGURATION .
ZV_MAIL_BLOCK-BLOCK_NAME =
ZBC_MAIL_BLOCK-BLOCK_NAME .
ZV_MAIL_BLOCK-BLOCK_FORMAT =
ZBC_MAIL_BLOCK-BLOCK_FORMAT .
ZV_MAIL_BLOCK-ATTACHMENT =
ZBC_MAIL_BLOCK-ATTACHMENT .
ZV_MAIL_BLOCK-ATTACH_SUBJECT =
ZBC_MAIL_BLOCK-ATTACH_SUBJECT .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZV_MAIL_BLOCK USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZV_MAIL_BLOCK-PROGRAM_NAME TO
ZBC_MAIL_BLOCK-PROGRAM_NAME .
MOVE ZV_MAIL_BLOCK-CONFIGURATION TO
ZBC_MAIL_BLOCK-CONFIGURATION .
MOVE ZV_MAIL_BLOCK-BLOCK_NAME TO
ZBC_MAIL_BLOCK-BLOCK_NAME .
MOVE ZV_MAIL_BLOCK-MANDT TO
ZBC_MAIL_BLOCK-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZBC_MAIL_BLOCK'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZBC_MAIL_BLOCK TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZBC_MAIL_BLOCK'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_MAIL_HEADER..................................*
FORM GET_DATA_ZV_MAIL_HEADER.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZBC_MAIL_HEADER WHERE
(VIM_WHERETAB) .
    CLEAR ZV_MAIL_HEADER .
ZV_MAIL_HEADER-MANDT =
ZBC_MAIL_HEADER-MANDT .
ZV_MAIL_HEADER-PROGRAM_NAME =
ZBC_MAIL_HEADER-PROGRAM_NAME .
ZV_MAIL_HEADER-CONFIGURATION =
ZBC_MAIL_HEADER-CONFIGURATION .
ZV_MAIL_HEADER-ADDRTYPE =
ZBC_MAIL_HEADER-ADDRTYPE .
ZV_MAIL_HEADER-SENDER =
ZBC_MAIL_HEADER-SENDER .
ZV_MAIL_HEADER-DISPLAY_NAME =
ZBC_MAIL_HEADER-DISPLAY_NAME .
ZV_MAIL_HEADER-SUBJECT =
ZBC_MAIL_HEADER-SUBJECT .
ZV_MAIL_HEADER-EXPRESS =
ZBC_MAIL_HEADER-EXPRESS .
ZV_MAIL_HEADER-IMMEDIATELY =
ZBC_MAIL_HEADER-IMMEDIATELY .
ZV_MAIL_HEADER-DISABLE_USER =
ZBC_MAIL_HEADER-DISABLE_USER .
ZV_MAIL_HEADER-DISABLE_SENDING =
ZBC_MAIL_HEADER-DISABLE_SENDING .
<VIM_TOTAL_STRUC> = ZV_MAIL_HEADER.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZV_MAIL_HEADER .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZV_MAIL_HEADER.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZV_MAIL_HEADER-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_HEADER WHERE
  PROGRAM_NAME = ZV_MAIL_HEADER-PROGRAM_NAME AND
  CONFIGURATION = ZV_MAIL_HEADER-CONFIGURATION .
    IF SY-SUBRC = 0.
    DELETE ZBC_MAIL_HEADER .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_HEADER WHERE
  PROGRAM_NAME = ZV_MAIL_HEADER-PROGRAM_NAME AND
  CONFIGURATION = ZV_MAIL_HEADER-CONFIGURATION .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZBC_MAIL_HEADER.
    ENDIF.
ZBC_MAIL_HEADER-MANDT =
ZV_MAIL_HEADER-MANDT .
ZBC_MAIL_HEADER-PROGRAM_NAME =
ZV_MAIL_HEADER-PROGRAM_NAME .
ZBC_MAIL_HEADER-CONFIGURATION =
ZV_MAIL_HEADER-CONFIGURATION .
ZBC_MAIL_HEADER-ADDRTYPE =
ZV_MAIL_HEADER-ADDRTYPE .
ZBC_MAIL_HEADER-SENDER =
ZV_MAIL_HEADER-SENDER .
ZBC_MAIL_HEADER-DISPLAY_NAME =
ZV_MAIL_HEADER-DISPLAY_NAME .
ZBC_MAIL_HEADER-SUBJECT =
ZV_MAIL_HEADER-SUBJECT .
ZBC_MAIL_HEADER-EXPRESS =
ZV_MAIL_HEADER-EXPRESS .
ZBC_MAIL_HEADER-IMMEDIATELY =
ZV_MAIL_HEADER-IMMEDIATELY .
ZBC_MAIL_HEADER-DISABLE_USER =
ZV_MAIL_HEADER-DISABLE_USER .
ZBC_MAIL_HEADER-DISABLE_SENDING =
ZV_MAIL_HEADER-DISABLE_SENDING .
    IF SY-SUBRC = 0.
    UPDATE ZBC_MAIL_HEADER ##WARN_OK.
    ELSE.
    INSERT ZBC_MAIL_HEADER .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZV_MAIL_HEADER-UPD_FLAG,
STATUS_ZV_MAIL_HEADER-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZV_MAIL_HEADER.
  SELECT SINGLE * FROM ZBC_MAIL_HEADER WHERE
PROGRAM_NAME = ZV_MAIL_HEADER-PROGRAM_NAME AND
CONFIGURATION = ZV_MAIL_HEADER-CONFIGURATION .
ZV_MAIL_HEADER-MANDT =
ZBC_MAIL_HEADER-MANDT .
ZV_MAIL_HEADER-PROGRAM_NAME =
ZBC_MAIL_HEADER-PROGRAM_NAME .
ZV_MAIL_HEADER-CONFIGURATION =
ZBC_MAIL_HEADER-CONFIGURATION .
ZV_MAIL_HEADER-ADDRTYPE =
ZBC_MAIL_HEADER-ADDRTYPE .
ZV_MAIL_HEADER-SENDER =
ZBC_MAIL_HEADER-SENDER .
ZV_MAIL_HEADER-DISPLAY_NAME =
ZBC_MAIL_HEADER-DISPLAY_NAME .
ZV_MAIL_HEADER-SUBJECT =
ZBC_MAIL_HEADER-SUBJECT .
ZV_MAIL_HEADER-EXPRESS =
ZBC_MAIL_HEADER-EXPRESS .
ZV_MAIL_HEADER-IMMEDIATELY =
ZBC_MAIL_HEADER-IMMEDIATELY .
ZV_MAIL_HEADER-DISABLE_USER =
ZBC_MAIL_HEADER-DISABLE_USER .
ZV_MAIL_HEADER-DISABLE_SENDING =
ZBC_MAIL_HEADER-DISABLE_SENDING .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZV_MAIL_HEADER USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZV_MAIL_HEADER-PROGRAM_NAME TO
ZBC_MAIL_HEADER-PROGRAM_NAME .
MOVE ZV_MAIL_HEADER-CONFIGURATION TO
ZBC_MAIL_HEADER-CONFIGURATION .
MOVE ZV_MAIL_HEADER-MANDT TO
ZBC_MAIL_HEADER-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZBC_MAIL_HEADER'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZBC_MAIL_HEADER TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZBC_MAIL_HEADER'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_MAIL_LIST....................................*
FORM GET_DATA_ZV_MAIL_LIST.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZBC_MAIL_LIST WHERE
(VIM_WHERETAB) .
    CLEAR ZV_MAIL_LIST .
ZV_MAIL_LIST-MANDT =
ZBC_MAIL_LIST-MANDT .
ZV_MAIL_LIST-MAILING_LIST =
ZBC_MAIL_LIST-MAILING_LIST .
ZV_MAIL_LIST-ITEM =
ZBC_MAIL_LIST-ITEM .
ZV_MAIL_LIST-ADDRTYPE =
ZBC_MAIL_LIST-ADDRTYPE .
ZV_MAIL_LIST-RECIPIENT =
ZBC_MAIL_LIST-RECIPIENT .
ZV_MAIL_LIST-DISPLAY_NAME =
ZBC_MAIL_LIST-DISPLAY_NAME .
ZV_MAIL_LIST-USER_FLAG =
ZBC_MAIL_LIST-USER_FLAG .
<VIM_TOTAL_STRUC> = ZV_MAIL_LIST.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZV_MAIL_LIST .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZV_MAIL_LIST.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZV_MAIL_LIST-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_LIST WHERE
  MAILING_LIST = ZV_MAIL_LIST-MAILING_LIST AND
  ITEM = ZV_MAIL_LIST-ITEM .
    IF SY-SUBRC = 0.
    DELETE ZBC_MAIL_LIST .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_LIST WHERE
  MAILING_LIST = ZV_MAIL_LIST-MAILING_LIST AND
  ITEM = ZV_MAIL_LIST-ITEM .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZBC_MAIL_LIST.
    ENDIF.
ZBC_MAIL_LIST-MANDT =
ZV_MAIL_LIST-MANDT .
ZBC_MAIL_LIST-MAILING_LIST =
ZV_MAIL_LIST-MAILING_LIST .
ZBC_MAIL_LIST-ITEM =
ZV_MAIL_LIST-ITEM .
ZBC_MAIL_LIST-ADDRTYPE =
ZV_MAIL_LIST-ADDRTYPE .
ZBC_MAIL_LIST-RECIPIENT =
ZV_MAIL_LIST-RECIPIENT .
ZBC_MAIL_LIST-DISPLAY_NAME =
ZV_MAIL_LIST-DISPLAY_NAME .
ZBC_MAIL_LIST-USER_FLAG =
ZV_MAIL_LIST-USER_FLAG .
    IF SY-SUBRC = 0.
    UPDATE ZBC_MAIL_LIST ##WARN_OK.
    ELSE.
    INSERT ZBC_MAIL_LIST .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZV_MAIL_LIST-UPD_FLAG,
STATUS_ZV_MAIL_LIST-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZV_MAIL_LIST.
  SELECT SINGLE * FROM ZBC_MAIL_LIST WHERE
MAILING_LIST = ZV_MAIL_LIST-MAILING_LIST AND
ITEM = ZV_MAIL_LIST-ITEM .
ZV_MAIL_LIST-MANDT =
ZBC_MAIL_LIST-MANDT .
ZV_MAIL_LIST-MAILING_LIST =
ZBC_MAIL_LIST-MAILING_LIST .
ZV_MAIL_LIST-ITEM =
ZBC_MAIL_LIST-ITEM .
ZV_MAIL_LIST-ADDRTYPE =
ZBC_MAIL_LIST-ADDRTYPE .
ZV_MAIL_LIST-RECIPIENT =
ZBC_MAIL_LIST-RECIPIENT .
ZV_MAIL_LIST-DISPLAY_NAME =
ZBC_MAIL_LIST-DISPLAY_NAME .
ZV_MAIL_LIST-USER_FLAG =
ZBC_MAIL_LIST-USER_FLAG .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZV_MAIL_LIST USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZV_MAIL_LIST-MAILING_LIST TO
ZBC_MAIL_LIST-MAILING_LIST .
MOVE ZV_MAIL_LIST-ITEM TO
ZBC_MAIL_LIST-ITEM .
MOVE ZV_MAIL_LIST-MANDT TO
ZBC_MAIL_LIST-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZBC_MAIL_LIST'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZBC_MAIL_LIST TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZBC_MAIL_LIST'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_MAIL_PROGRAM.................................*
FORM GET_DATA_ZV_MAIL_PROGRAM.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZBC_MAIL_PROGRAM WHERE
(VIM_WHERETAB) .
    CLEAR ZV_MAIL_PROGRAM .
ZV_MAIL_PROGRAM-MANDT =
ZBC_MAIL_PROGRAM-MANDT .
ZV_MAIL_PROGRAM-PROGRAM_NAME =
ZBC_MAIL_PROGRAM-PROGRAM_NAME .
ZV_MAIL_PROGRAM-VARIANT_NAME =
ZBC_MAIL_PROGRAM-VARIANT_NAME .
ZV_MAIL_PROGRAM-ITEM =
ZBC_MAIL_PROGRAM-ITEM .
ZV_MAIL_PROGRAM-CONFIGURATION =
ZBC_MAIL_PROGRAM-CONFIGURATION .
<VIM_TOTAL_STRUC> = ZV_MAIL_PROGRAM.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZV_MAIL_PROGRAM .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZV_MAIL_PROGRAM.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZV_MAIL_PROGRAM-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_PROGRAM WHERE
  PROGRAM_NAME = ZV_MAIL_PROGRAM-PROGRAM_NAME AND
  VARIANT_NAME = ZV_MAIL_PROGRAM-VARIANT_NAME AND
  ITEM = ZV_MAIL_PROGRAM-ITEM .
    IF SY-SUBRC = 0.
    DELETE ZBC_MAIL_PROGRAM .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_PROGRAM WHERE
  PROGRAM_NAME = ZV_MAIL_PROGRAM-PROGRAM_NAME AND
  VARIANT_NAME = ZV_MAIL_PROGRAM-VARIANT_NAME AND
  ITEM = ZV_MAIL_PROGRAM-ITEM .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZBC_MAIL_PROGRAM.
    ENDIF.
ZBC_MAIL_PROGRAM-MANDT =
ZV_MAIL_PROGRAM-MANDT .
ZBC_MAIL_PROGRAM-PROGRAM_NAME =
ZV_MAIL_PROGRAM-PROGRAM_NAME .
ZBC_MAIL_PROGRAM-VARIANT_NAME =
ZV_MAIL_PROGRAM-VARIANT_NAME .
ZBC_MAIL_PROGRAM-ITEM =
ZV_MAIL_PROGRAM-ITEM .
ZBC_MAIL_PROGRAM-CONFIGURATION =
ZV_MAIL_PROGRAM-CONFIGURATION .
    IF SY-SUBRC = 0.
    UPDATE ZBC_MAIL_PROGRAM ##WARN_OK.
    ELSE.
    INSERT ZBC_MAIL_PROGRAM .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZV_MAIL_PROGRAM-UPD_FLAG,
STATUS_ZV_MAIL_PROGRAM-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZV_MAIL_PROGRAM.
  SELECT SINGLE * FROM ZBC_MAIL_PROGRAM WHERE
PROGRAM_NAME = ZV_MAIL_PROGRAM-PROGRAM_NAME AND
VARIANT_NAME = ZV_MAIL_PROGRAM-VARIANT_NAME AND
ITEM = ZV_MAIL_PROGRAM-ITEM .
ZV_MAIL_PROGRAM-MANDT =
ZBC_MAIL_PROGRAM-MANDT .
ZV_MAIL_PROGRAM-PROGRAM_NAME =
ZBC_MAIL_PROGRAM-PROGRAM_NAME .
ZV_MAIL_PROGRAM-VARIANT_NAME =
ZBC_MAIL_PROGRAM-VARIANT_NAME .
ZV_MAIL_PROGRAM-ITEM =
ZBC_MAIL_PROGRAM-ITEM .
ZV_MAIL_PROGRAM-CONFIGURATION =
ZBC_MAIL_PROGRAM-CONFIGURATION .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZV_MAIL_PROGRAM USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZV_MAIL_PROGRAM-PROGRAM_NAME TO
ZBC_MAIL_PROGRAM-PROGRAM_NAME .
MOVE ZV_MAIL_PROGRAM-VARIANT_NAME TO
ZBC_MAIL_PROGRAM-VARIANT_NAME .
MOVE ZV_MAIL_PROGRAM-ITEM TO
ZBC_MAIL_PROGRAM-ITEM .
MOVE ZV_MAIL_PROGRAM-MANDT TO
ZBC_MAIL_PROGRAM-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZBC_MAIL_PROGRAM'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZBC_MAIL_PROGRAM TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZBC_MAIL_PROGRAM'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*
*...processing: ZV_MAIL_RECIP...................................*
FORM GET_DATA_ZV_MAIL_RECIP.
  PERFORM VIM_FILL_WHERETAB.
*.read data from database.............................................*
  REFRESH TOTAL.
  CLEAR   TOTAL.
  SELECT * FROM ZBC_MAIL_RECIP WHERE
(VIM_WHERETAB) .
    CLEAR ZV_MAIL_RECIP .
ZV_MAIL_RECIP-MANDT =
ZBC_MAIL_RECIP-MANDT .
ZV_MAIL_RECIP-PROGRAM_NAME =
ZBC_MAIL_RECIP-PROGRAM_NAME .
ZV_MAIL_RECIP-CONFIGURATION =
ZBC_MAIL_RECIP-CONFIGURATION .
ZV_MAIL_RECIP-ITEM =
ZBC_MAIL_RECIP-ITEM .
ZV_MAIL_RECIP-ADDRTYPE =
ZBC_MAIL_RECIP-ADDRTYPE .
ZV_MAIL_RECIP-RECIPIENT =
ZBC_MAIL_RECIP-RECIPIENT .
ZV_MAIL_RECIP-DISPLAY_NAME =
ZBC_MAIL_RECIP-DISPLAY_NAME .
ZV_MAIL_RECIP-USER_FLAG =
ZBC_MAIL_RECIP-USER_FLAG .
<VIM_TOTAL_STRUC> = ZV_MAIL_RECIP.
    APPEND TOTAL.
  ENDSELECT.
  SORT TOTAL BY <VIM_XTOTAL_KEY>.
  <STATUS>-ALR_SORTED = 'R'.
*.check dynamic selectoptions (not in DDIC)...........................*
  IF X_HEADER-SELECTION NE SPACE.
    PERFORM CHECK_DYNAMIC_SELECT_OPTIONS.
  ELSEIF X_HEADER-DELMDTFLAG NE SPACE.
    PERFORM BUILD_MAINKEY_TAB.
  ENDIF.
  REFRESH EXTRACT.
ENDFORM.
*---------------------------------------------------------------------*
FORM DB_UPD_ZV_MAIL_RECIP .
*.process data base updates/inserts/deletes.........................*
LOOP AT TOTAL.
  CHECK <ACTION> NE ORIGINAL.
MOVE <VIM_TOTAL_STRUC> TO ZV_MAIL_RECIP.
  IF <ACTION> = UPDATE_GELOESCHT.
    <ACTION> = GELOESCHT.
  ENDIF.
  CASE <ACTION>.
   WHEN NEUER_GELOESCHT.
IF STATUS_ZV_MAIL_RECIP-ST_DELETE EQ GELOESCHT.
     READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
     IF SY-SUBRC EQ 0.
       DELETE EXTRACT INDEX SY-TABIX.
     ENDIF.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN GELOESCHT.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_RECIP WHERE
  PROGRAM_NAME = ZV_MAIL_RECIP-PROGRAM_NAME AND
  CONFIGURATION = ZV_MAIL_RECIP-CONFIGURATION AND
  ITEM = ZV_MAIL_RECIP-ITEM .
    IF SY-SUBRC = 0.
    DELETE ZBC_MAIL_RECIP .
    ENDIF.
    IF STATUS-DELETE EQ GELOESCHT.
      READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY> BINARY SEARCH.
      DELETE EXTRACT INDEX SY-TABIX.
    ENDIF.
    DELETE TOTAL.
    IF X_HEADER-DELMDTFLAG NE SPACE.
      PERFORM DELETE_FROM_MAINKEY_TAB.
    ENDIF.
   WHEN OTHERS.
  SELECT SINGLE FOR UPDATE * FROM ZBC_MAIL_RECIP WHERE
  PROGRAM_NAME = ZV_MAIL_RECIP-PROGRAM_NAME AND
  CONFIGURATION = ZV_MAIL_RECIP-CONFIGURATION AND
  ITEM = ZV_MAIL_RECIP-ITEM .
    IF SY-SUBRC <> 0.   "insert preprocessing: init WA
      CLEAR ZBC_MAIL_RECIP.
    ENDIF.
ZBC_MAIL_RECIP-MANDT =
ZV_MAIL_RECIP-MANDT .
ZBC_MAIL_RECIP-PROGRAM_NAME =
ZV_MAIL_RECIP-PROGRAM_NAME .
ZBC_MAIL_RECIP-CONFIGURATION =
ZV_MAIL_RECIP-CONFIGURATION .
ZBC_MAIL_RECIP-ITEM =
ZV_MAIL_RECIP-ITEM .
ZBC_MAIL_RECIP-ADDRTYPE =
ZV_MAIL_RECIP-ADDRTYPE .
ZBC_MAIL_RECIP-RECIPIENT =
ZV_MAIL_RECIP-RECIPIENT .
ZBC_MAIL_RECIP-DISPLAY_NAME =
ZV_MAIL_RECIP-DISPLAY_NAME .
ZBC_MAIL_RECIP-USER_FLAG =
ZV_MAIL_RECIP-USER_FLAG .
    IF SY-SUBRC = 0.
    UPDATE ZBC_MAIL_RECIP ##WARN_OK.
    ELSE.
    INSERT ZBC_MAIL_RECIP .
    ENDIF.
    READ TABLE EXTRACT WITH KEY <VIM_XTOTAL_KEY>.
    IF SY-SUBRC EQ 0.
      <XACT> = ORIGINAL.
      MODIFY EXTRACT INDEX SY-TABIX.
    ENDIF.
    <ACTION> = ORIGINAL.
    MODIFY TOTAL.
  ENDCASE.
ENDLOOP.
CLEAR: STATUS_ZV_MAIL_RECIP-UPD_FLAG,
STATUS_ZV_MAIL_RECIP-UPD_CHECKD.
MESSAGE S018(SV).
ENDFORM.
*---------------------------------------------------------------------*
FORM READ_SINGLE_ZV_MAIL_RECIP.
  SELECT SINGLE * FROM ZBC_MAIL_RECIP WHERE
PROGRAM_NAME = ZV_MAIL_RECIP-PROGRAM_NAME AND
CONFIGURATION = ZV_MAIL_RECIP-CONFIGURATION AND
ITEM = ZV_MAIL_RECIP-ITEM .
ZV_MAIL_RECIP-MANDT =
ZBC_MAIL_RECIP-MANDT .
ZV_MAIL_RECIP-PROGRAM_NAME =
ZBC_MAIL_RECIP-PROGRAM_NAME .
ZV_MAIL_RECIP-CONFIGURATION =
ZBC_MAIL_RECIP-CONFIGURATION .
ZV_MAIL_RECIP-ITEM =
ZBC_MAIL_RECIP-ITEM .
ZV_MAIL_RECIP-ADDRTYPE =
ZBC_MAIL_RECIP-ADDRTYPE .
ZV_MAIL_RECIP-RECIPIENT =
ZBC_MAIL_RECIP-RECIPIENT .
ZV_MAIL_RECIP-DISPLAY_NAME =
ZBC_MAIL_RECIP-DISPLAY_NAME .
ZV_MAIL_RECIP-USER_FLAG =
ZBC_MAIL_RECIP-USER_FLAG .
ENDFORM.
*---------------------------------------------------------------------*
FORM CORR_MAINT_ZV_MAIL_RECIP USING VALUE(CM_ACTION) RC.
  DATA: RETCODE LIKE SY-SUBRC, COUNT TYPE I, TRSP_KEYLEN TYPE SYFLENG.
  FIELD-SYMBOLS: <TAB_KEY_X> TYPE X.
  CLEAR RC.
MOVE ZV_MAIL_RECIP-PROGRAM_NAME TO
ZBC_MAIL_RECIP-PROGRAM_NAME .
MOVE ZV_MAIL_RECIP-CONFIGURATION TO
ZBC_MAIL_RECIP-CONFIGURATION .
MOVE ZV_MAIL_RECIP-ITEM TO
ZBC_MAIL_RECIP-ITEM .
MOVE ZV_MAIL_RECIP-MANDT TO
ZBC_MAIL_RECIP-MANDT .
  CORR_KEYTAB             =  E071K.
  CORR_KEYTAB-OBJNAME     = 'ZBC_MAIL_RECIP'.
  IF NOT <vim_corr_keyx> IS ASSIGNED.
    ASSIGN CORR_KEYTAB-TABKEY TO <vim_corr_keyx> CASTING.
  ENDIF.
  ASSIGN ZBC_MAIL_RECIP TO <TAB_KEY_X> CASTING.
  PERFORM VIM_GET_TRSPKEYLEN
    USING 'ZBC_MAIL_RECIP'
    CHANGING TRSP_KEYLEN.
  <VIM_CORR_KEYX>(TRSP_KEYLEN) = <TAB_KEY_X>(TRSP_KEYLEN).
  PERFORM UPDATE_CORR_KEYTAB USING CM_ACTION RETCODE.
  ADD: RETCODE TO RC, 1 TO COUNT.
  IF RC LT COUNT AND CM_ACTION NE PRUEFEN.
    CLEAR RC.
  ENDIF.

ENDFORM.
*---------------------------------------------------------------------*