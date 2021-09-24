method GET_AND_PARSE_REPORT.
  DATA:

        lt_spool      TYPE STANDARD TABLE OF soli,
        lt_list       TYPE STANDARD TABLE OF abaplist,
        lt_block      TYPE STANDARD TABLE OF soli,
        lv_spool      TYPE soli,
        lv_block_name TYPE z_bc_mail_block.

  IF sy-batch EQ 'X' .
* we need a new page... this is something to change in the future!
    NEW-PAGE.

*If the program runs in background, then save the spool and then get it
    COMMIT WORK AND WAIT.

    v_rqident = sy-spono.
     SUBMIT rspolist EXPORTING LIST TO MEMORY AND RETURN
                     WITH rqident = v_rqident.

    CALL FUNCTION 'LIST_FROM_MEMORY'
      TABLES
        listobject = lt_list
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING cant_get_report.
    ENDIF.

    CALL FUNCTION 'LIST_FREE_MEMORY'
      TABLES
        listobject = lt_list
      EXCEPTIONS
        OTHERS     = 1.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING cant_get_report.
    ENDIF.

  ELSE.
    CALL FUNCTION 'SAVE_LIST'
      TABLES
        listobject         = lt_list
      EXCEPTIONS
        list_index_invalid = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING cant_get_report.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'LIST_TO_ASCI'
    TABLES
      listasci           = lt_spool
      listobject         = lt_list
    EXCEPTIONS
      empty_list         = 1
      list_index_invalid = 2
      OTHERS             = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 RAISING cant_get_report.
  ENDIF.

* update the global "image" in ABAPLIST format
  t_list[] = lt_list[].

*Finaly create a new block
*Parse the markup to cut the report in blocks
  IF iv_ind_multi_block EQ 'X'.
    LOOP AT lt_spool INTO lv_spool.
      IF lv_spool-line(6) EQ 'BEGIN>'.
        REFRESH lt_block.
        lv_block_name = lv_spool-line+6(10).
        CONTINUE.
      ENDIF.

      IF lv_spool-line(4) EQ 'END>'.
        IF lv_block_name NE lv_spool-line+4(10).
*error!!
        ENDIF.
        IF NOT lt_block[] IS INITIAL.
          me->add_block( iv_block_name = lv_block_name it_datas_block = lt_block ).
        ENDIF.
        CLEAR lv_block_name.
        CONTINUE.
      ENDIF.

      INSERT lv_spool INTO TABLE lt_block.
    ENDLOOP.

    IF lv_block_name NE space.
* error!!!
    ENDIF.
  ELSE.
    me->add_block( iv_block_name = iv_block_name it_datas_block = lt_spool ).
  ENDIF.
endmethod.