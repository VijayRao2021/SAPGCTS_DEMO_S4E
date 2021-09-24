METHOD SEND_MAIL.

  DATA:
        lv_level TYPE c,

        ls_log TYPE zlog_log_tableline,
        ls_log_old TYPE zlog_log_tableline,
        lt_log TYPE zlog_log_table,

        lv_block TYPE string,
        lt_block TYPE STANDARD TABLE OF string,

        lo_blocks TYPE REF TO zcl_bc_report_management,
        lo_mail TYPE REF TO z_cl_utf_mail,
        lt_log_messages TYPE zlog_log_table.

  get_log( EXPORTING iv_group = iv_group IMPORTING et_log = lt_log_messages ).

  IF iv_only_error = 'X'.
    "On continue que s'il y a au moins une erreur dans la log
    IF iv_group IS INITIAL.
      READ TABLE lt_log_messages INTO ls_log WITH KEY msgtype = 'E'.
    ELSE.
      READ TABLE lt_log_messages INTO ls_log WITH KEY group = iv_group
                                                   msgtype = 'E'.
    ENDIF.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
  ENDIF.

  IF iv_program IS INITIAL.
    "Envoie des messages qui sont paramétrés
    lt_log[] = lt_log_messages[].
    SORT lt_log BY program variant block message_number group.

    LOOP AT lt_log INTO ls_log WHERE program <> space.
      IF ( ls_log-program <> ls_log_old-program OR
           ls_log-variant <> ls_log_old-variant OR
           ls_log-block <> ls_log_old-block ) AND NOT lt_block[] IS INITIAL.
        lo_blocks->add_block( iv_block_name = ls_log_old-block it_datas_block = lt_block iv_replace = 'X' ).
        REFRESH lt_block.
      ENDIF.

      IF ls_log-program <> ls_log_old-program OR
         ls_log-variant <> ls_log_old-variant.
        IF NOT ls_log_old-program IS INITIAL.
          CREATE OBJECT lo_mail.
          lo_mail->send_mail_portal( iv_program = ls_log_old-program iv_variant = ls_log_old-variant io_block = lo_blocks iv_subject_variable1 = iv_subject_variable1 iv_subject_variable2 = iv_subject_variable2 ).
        ENDIF.
        IF io_blocks IS INITIAL.
          CREATE OBJECT lo_blocks.
        ELSE.
          lo_blocks = io_blocks.
        ENDIF.
      ENDIF.

      CLEAR lv_block.
      lv_block = ls_log-message.
      IF NOT iv_print_level IS INITIAL.
        lv_level = ls_log-level.
        CONCATENATE lv_level lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_msgtype IS INITIAL.
        CONCATENATE ls_log-msgtype lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_group IS INITIAL.
        CONCATENATE ls_log-group lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_hour IS INITIAL.
        CONCATENATE ls_log-hour lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_date IS INITIAL.
        CONCATENATE ls_log-date lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.

      APPEND lv_block TO lt_block.

      ls_log_old = ls_log.

    ENDLOOP.
    IF sy-subrc = 0.
      lo_blocks->add_block( iv_block_name = ls_log_old-block it_datas_block = lt_block iv_replace = 'X' ).
      CREATE OBJECT lo_mail.
      lo_mail->send_mail_portal( iv_program = ls_log_old-program iv_variant = ls_log_old-variant io_block = lo_blocks iv_subject_variable1 = iv_subject_variable1 iv_subject_variable2 = iv_subject_variable2 ).
    ENDIF.
  ELSE.
    LOOP AT lt_log_messages INTO ls_log.
      IF NOT iv_group IS INITIAL.
        CHECK ls_log-group = iv_group.
      ENDIF.
      CLEAR lv_block.
      lv_block = ls_log-message.
      IF NOT iv_print_level IS INITIAL.
        lv_level = ls_log-level.
        CONCATENATE lv_level lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_msgtype IS INITIAL.
        CONCATENATE ls_log-msgtype lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_group IS INITIAL.
        CONCATENATE ls_log-group lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_hour IS INITIAL.
        CONCATENATE ls_log-hour lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.
      IF NOT iv_print_date IS INITIAL.
        CONCATENATE ls_log-date lv_block INTO lv_block SEPARATED BY iv_separator.
      ENDIF.

      APPEND lv_block TO lt_block.
    ENDLOOP.
    IF sy-subrc = 0 AND NOT lt_block[] IS INITIAL.
      IF io_blocks IS INITIAL.
        CREATE OBJECT lo_blocks.
      ELSE.
        lo_blocks = io_blocks.
      ENDIF.
      lo_blocks->add_block( iv_block_name = iv_block it_datas_block = lt_block ).
      CREATE OBJECT lo_mail.
      lo_mail->send_mail_portal( iv_program = iv_program iv_variant = iv_variant io_block = lo_blocks iv_subject_variable1 = iv_subject_variable1  iv_subject_variable2 = iv_subject_variable2 ).
    ENDIF.
  ENDIF.
ENDMETHOD.