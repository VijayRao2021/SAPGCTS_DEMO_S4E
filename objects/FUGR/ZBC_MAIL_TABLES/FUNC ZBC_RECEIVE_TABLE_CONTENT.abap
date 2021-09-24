FUNCTION zbc_receive_table_content .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(INPUT_METHOD) LIKE  BDWFAP_PAR-INPUTMETHD
*"     VALUE(MASS_PROCESSING) LIKE  BDWFAP_PAR-MASS_PROC
*"     VALUE(PI_XK99_USED) TYPE  CHAR1 DEFAULT SPACE
*"  EXPORTING
*"     VALUE(WORKFLOW_RESULT) LIKE  BDWFAP_PAR-RESULT
*"     VALUE(APPLICATION_VARIABLE) LIKE  BDWFAP_PAR-APPL_VAR
*"     VALUE(IN_UPDATE_TASK) LIKE  BDWFAP_PAR-UPDATETASK
*"     VALUE(CALL_TRANSACTION_DONE) LIKE  BDWFAP_PAR-CALLTRANS
*"  TABLES
*"      IDOC_CONTRL STRUCTURE  EDIDC
*"      IDOC_DATA STRUCTURE  EDIDD
*"      IDOC_STATUS STRUCTURE  BDIDOCSTAT
*"      RETURN_VARIABLES STRUCTURE  BDWFRETVAR
*"      SERIALIZATION_INFO STRUCTURE  BDI_SER
*"  EXCEPTIONS
*"      WRONG_FUNCTION_CALLED
*"----------------------------------------------------------------------
* Modification Protocol                                                *
* No.    Date        Author                      	      Transp.Requ.   *
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
DATA:ls_z1bctable       TYPE z1bctable,
     ls_z1bctableline   TYPE z1bctableline,
     ls_z1bctablefield2 TYPE z1bctablefield2,
     ls_idoc_status     TYPE bdidocstat.

DATA:lo_tabref_modi     TYPE REF TO data,
     lo_tabref_del      TYPE REF TO data,
     lo_line            TYPE REF TO data.

FIELD-SYMBOLS:<ls_idoc_data>   TYPE edidd,
              <lt_table_modi>  TYPE STANDARD TABLE,
              <lt_table_del>   TYPE STANDARD TABLE,
              <ls_line>        TYPE any,
              <lv_field>       TYPE any,
              <ls_idoc_contrl> TYPE edidc.

CONSTANTS:lc_z1bctable       TYPE edilsegtyp VALUE 'Z1BCTABLE',
          lc_z1bctableline   TYPE edilsegtyp VALUE 'Z1BCTABLELINE',
          lc_z1bctablefield2 TYPE edilsegtyp VALUE 'Z1BCTABLEFIELD2',
          lc_ins_009         TYPE char03     VALUE '009',
          lc_upd_004         TYPE char03     VALUE '004',
          lc_del_003         TYPE char03     VALUE '003',
          lc_a               TYPE as4local   VALUE 'A',
          lc_status_51       TYPE edi_status VALUE '51',
          lc_status_53       TYPE edi_status VALUE '53',
          lc_msgid           TYPE sy-msgid   VALUE 'ZFI_INTERFACES',
          lc_msgty_e         TYPE sy-msgty   VALUE 'E',
          lc_msgty_s         TYPE sy-msgty   VALUE 'S',
          lc_msgno_zero      TYPE sy-msgno   VALUE '000'.

*  Read control record
READ TABLE idoc_contrl ASSIGNING <ls_idoc_contrl> INDEX 1.

*------------ read Z1BCTABLE table name segment from IDoc data  ----------------*
  CLEAR:ls_z1bctable,ls_idoc_status.
    ls_idoc_status-docnum = <ls_idoc_contrl>-docnum.
    ls_idoc_status-status = lc_status_53.
    ls_idoc_status-msgid  = lc_msgid.
    ls_idoc_status-msgty  = lc_msgty_s.
    ls_idoc_status-msgno  = lc_msgno_zero.

  READ TABLE idoc_data ASSIGNING <ls_idoc_data> WITH KEY segnam = lc_z1bctable.       " Z1BCTABLE.
  IF sy-subrc = 0 AND <ls_idoc_data> IS ASSIGNED.
    MOVE <ls_idoc_data>-sdata TO ls_z1bctable.
  ENDIF.

  SELECT *
    FROM dd02l UP TO 1 ROWS
    INTO @DATA(ls_dd02l)
    WHERE tabname     = @ls_z1bctable-tablename
    AND   as4local    = @lc_a
    ORDER BY PRIMARY KEY.
   EXIT.
  ENDSELECT.

  IF sy-subrc NE 0.
    ls_idoc_status-status = lc_status_51.
    ls_idoc_status-msgty  = lc_msgty_e.
    ls_idoc_status-msgv1  = TEXT-001.
    ls_idoc_status-msgv2  = ls_z1bctable-tablename.
   APPEND ls_idoc_status TO idoc_status.
   EXIT.
  ENDIF.

  CREATE DATA lo_tabref_modi TYPE TABLE OF (ls_z1bctable-tablename).
  ASSIGN lo_tabref_modi->* TO <lt_table_modi>.

  CREATE DATA lo_tabref_del TYPE TABLE OF (ls_z1bctable-tablename).
  ASSIGN lo_tabref_del->* TO <lt_table_del>.

  CREATE DATA lo_line LIKE LINE OF <lt_table_modi>.
  ASSIGN lo_line->* TO <ls_line>.

*------------ Process Z1BCTABLELINE table line segment from IDoc data  ----------------*
  LOOP AT idoc_data ASSIGNING <ls_idoc_data> WHERE segnam = lc_z1bctableline.
    CLEAR ls_z1bctableline.
    MOVE <ls_idoc_data>-sdata TO ls_z1bctableline.
*------------ Process Z1BCTABLEFIELD2 table fieldnames and values segment from IDoc data  ----------------*
    LOOP AT idoc_data ASSIGNING FIELD-SYMBOL(<ls_idoc_data1>) WHERE segnam = lc_z1bctablefield2       " Z1BCTABLEFIELD2
                                               AND   psgnum = <ls_idoc_data>-segnum.
       MOVE <ls_idoc_data1>-sdata TO ls_z1bctablefield2.
       ASSIGN COMPONENT ls_z1bctablefield2-fieldname OF STRUCTURE <ls_line> TO <lv_field>.
       MOVE ls_z1bctablefield2-fieldvalue TO <lv_field>.
       UNASSIGN <lv_field>.
    ENDLOOP.

   IF ls_z1bctableline-msgfn = lc_del_003.
     APPEND <ls_line> TO <lt_table_del>.
   ELSE.
     APPEND <ls_line> TO <lt_table_modi>.
   ENDIF.
 ENDLOOP.

 DATA(lv_del_flag) = abap_false.
 IF NOT <lt_table_del> IS INITIAL.
   DELETE (ls_z1bctable-tablename) FROM TABLE <lt_table_del>.
   IF sy-subrc NE 0.
     lv_del_flag = abap_true.
   ENDIF.
 ENDIF.

 DATA(lv_modi_flag) = abap_false.
 IF NOT <lt_table_modi> IS INITIAL.
   MODIFY (ls_z1bctable-tablename) FROM TABLE <lt_table_modi>.
   IF sy-subrc NE 0.
     lv_modi_flag = abap_true.
   ENDIF.
 ENDIF.

 IF lv_del_flag = abap_true.
   ls_idoc_status-status = lc_status_51.
   ls_idoc_status-msgty  = lc_msgty_e.
   ls_idoc_status-msgv1  = TEXT-003.
   APPEND ls_idoc_status TO idoc_status.
 ENDIF.

 IF lv_modi_flag = abap_true.
   ls_idoc_status-status = lc_status_51.
   ls_idoc_status-msgty  = lc_msgty_e.
   ls_idoc_status-msgv1  = TEXT-002.
   APPEND ls_idoc_status TO idoc_status.
 ENDIF.

 IF lv_del_flag = abap_false AND lv_modi_flag = abap_false.
   ls_idoc_status-msgv1  = TEXT-004.
   APPEND ls_idoc_status TO idoc_status.
 ENDIF.
ENDFUNCTION.