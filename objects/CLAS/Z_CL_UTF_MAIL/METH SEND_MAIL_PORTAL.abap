METHOD send_mail_portal.
  DATA:
        lv_fl_first TYPE c,
        lv_subject_tmp(1024) TYPE c,
        lv_sub1_tmp(1024) TYPE c,
        lv_sub2_tmp(1024) TYPE c,
        lv_lenght1 TYPE i,
        lv_lenght2 TYPE i,

        ls_mail_program TYPE zbc_mail_program,
        lt_mail_program TYPE STANDARD TABLE OF zbc_mail_program,
        ls_mail_header TYPE zbc_mail_header,
        lt_mail_header TYPE STANDARD TABLE OF zbc_mail_header,
        ls_mail_recipient TYPE zbc_mail_recip,
        lt_mail_recipient TYPE STANDARD TABLE OF zbc_mail_recip,
        ls_mail_block TYPE zbc_mail_block,
        lt_mail_blocks TYPE STANDARD TABLE OF zbc_mail_block,
        ls_t000 TYPE t000,
        ls_block TYPE soli,
        lt_block TYPE soli_tab,
        ls_sender TYPE zbc_mail_email_address_line,
        lt_recipients TYPE zbc_mail_email_address_table,
        ls_content TYPE ts_build_content,
        ls_content_ref TYPE REF TO ts_build_content,
        lt_content TYPE STANDARD TABLE OF ts_build_content.

*Read the program configurations
  SELECT * INTO TABLE lt_mail_program
    FROM zbc_mail_program
    WHERE program_name = iv_program AND
          variant_name = iv_variant.
  IF sy-subrc <> 0.
* Read with the generic variant
    SELECT * INTO TABLE lt_mail_program
      FROM zbc_mail_program
      WHERE program_name = iv_program AND
            variant_name = space.
    IF sy-subrc <> 0.
*Read with the default program
      SELECT * INTO TABLE lt_mail_program
        FROM zbc_mail_program
        WHERE program_name = 'DEFAULT_PROGRAM' AND
              variant_name = 'NOT_CONFIGURED'.
    ENDIF.
  ENDIF.

  LOOP AT lt_mail_program INTO ls_mail_program.
*Read the configuration header
    SELECT SINGLE * INTO ls_mail_header
      FROM zbc_mail_header
      WHERE program_name = ls_mail_program-program_name AND
            configuration = ls_mail_program-configuration.
    IF sy-subrc <> 0.
      SELECT SINGLE * INTO ls_mail_header
        FROM zbc_mail_header
        WHERE program_name = 'DEFAULT_PROGRAM' AND
              configuration = 'NO_CONF'.
    ENDIF.

    CHECK ls_mail_header-disable_sending IS INITIAL.
    CLEAR ls_sender.
    ls_sender-addrtype = ls_mail_header-addrtype.
    ls_sender-recipient = ls_mail_header-sender.
    ls_sender-display_name = ls_mail_header-display_name.
    search_mail_address( EXPORTING is_recipient = ls_sender
                         IMPORTING et_recipients = lt_recipients ).
    READ TABLE lt_recipients INTO ls_sender INDEX 1.
    IF sy-subrc = 0.
      ls_mail_header-sender = ls_sender-recipient.
      IF NOT ls_sender-display_name IS INITIAL.
        ls_mail_header-display_name = ls_sender-display_name.
      ENDIF.
    ELSE.
      SELECT SINGLE * INTO ls_mail_header
        FROM zbc_mail_header
        WHERE program_name = 'DEFAULT_PROGRAM' AND
              configuration = 'NO_RECIP'.
      IF sy-subrc = 0.
        CLEAR ls_sender.
        ls_sender-addrtype = ls_mail_header-addrtype.
        ls_sender-recipient = ls_mail_header-sender.
        ls_sender-display_name = ls_mail_header-display_name.
        search_mail_address( EXPORTING is_recipient = ls_sender
                             IMPORTING et_recipients = lt_recipients ).
        READ TABLE lt_recipients INTO ls_sender INDEX 1.
        IF sy-subrc = 0.
          ls_mail_header-sender = ls_sender-recipient.
          IF NOT ls_sender-display_name IS INITIAL.
            ls_mail_header-display_name = ls_sender-display_name.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    REFRESH lt_recipients.

*Gets the configuration's blocks
    SELECT * INTO TABLE lt_mail_blocks
      FROM zbc_mail_block
      WHERE program_name = ls_mail_program-program_name AND
            configuration = ls_mail_program-configuration.
    IF sy-subrc <> 0.
*No block found, set a default one
      CLEAR ls_mail_block.
      ls_mail_block-program_name = ls_mail_program-program_name.
      ls_mail_block-configuration = ls_mail_program-configuration.
      ls_mail_block-block_name = 'REPORT'.
      ls_mail_block-block_format = 'TXT'.
      APPEND ls_mail_block TO lt_mail_blocks.

      "Check if this default block exists.
      io_block->get_block( EXPORTING  iv_block_name = ls_mail_block-block_name
                                      iv_format = ls_mail_block-block_format
                           IMPORTING  et_list = lt_block
                           EXCEPTIONS block_doesnt_exist = 1 ).
      IF sy-subrc <> 0.
        "No, then create a default one
        CLEAR ls_block.
        CONCATENATE text-b01 iv_program ' / ' iv_variant INTO ls_block-line.
        APPEND ls_block TO lt_block.
        io_block->add_block( iv_block_name = ls_mail_block-block_name it_datas_block = lt_block ).
      ENDIF.
    ENDIF.

    REFRESH lt_content.
*Create the finals contents using the blocks configuration
    SORT lt_mail_blocks BY attachment.
    LOOP AT lt_mail_blocks INTO ls_mail_block.
* send email in HTM format in case of PDF and not in batch

      IF sy-batch IS INITIAL AND ls_mail_block-block_format = 'PDF'.
        ls_mail_block-block_format = 'HTM'.
      ENDIF.

      io_block->get_block( EXPORTING  iv_block_name = ls_mail_block-block_name
                                      iv_format = ls_mail_block-block_format
                           IMPORTING  et_list = lt_block
                           EXCEPTIONS block_doesnt_exist = 1 ).
      CHECK sy-subrc EQ 0.

      READ TABLE lt_content REFERENCE INTO ls_content_ref WITH KEY object = ls_mail_block-attach_subject.
      IF sy-subrc = 0.
        APPEND LINES OF lt_block TO ls_content_ref->content.
      ELSE.
        CLEAR ls_content.
        ls_content-object = ls_mail_block-attach_subject.
        ls_content-format = ls_mail_block-block_format.
        ls_content-content[] = lt_block[].
        APPEND ls_content TO lt_content.
      ENDIF.
    ENDLOOP.

    REFRESH lt_block.
    CLEAR lv_fl_first.
*Finally create the mail and his attachments and then send it
    LOOP AT lt_content INTO ls_content.
      IF lv_fl_first IS INITIAL.
        lv_fl_first = 'X'.
        lv_subject_tmp = ls_mail_header-subject.

        WRITE: iv_subject_variable1 TO lv_sub1_tmp, iv_subject_variable2 TO lv_sub2_tmp.
        CONDENSE: lv_sub1_tmp, lv_sub2_tmp.
        IF lv_subject_tmp CS '&1'.
          REPLACE '&1'  IN lv_subject_tmp WITH lv_sub1_tmp.
        ENDIF.
        IF lv_subject_tmp CS '&2'.
          REPLACE '&2' IN lv_subject_tmp WITH lv_sub2_tmp.
        ENDIF.
        ls_mail_header-subject = lv_subject_tmp.
        SELECT SINGLE * INTO ls_t000
          FROM t000
          WHERE mandt = sy-mandt.
        IF sy-subrc = 0 AND ls_t000-cccategory <> 'P'.
          lv_lenght1 = strlen( text-val ).
          lv_lenght2 = strlen( ls_mail_header-subject ) + lv_lenght1.
          IF lv_lenght2 > 50.
            lv_lenght1 = 50 - lv_lenght1.
            ls_mail_header-subject+lv_lenght1 = text-val.
          ELSE.
            CONCATENATE ls_mail_header-subject text-val INTO ls_mail_header-subject.
          ENDIF.
        ENDIF.

        IF ls_content-object IS INITIAL.
          create( iv_type = ls_content-format it_body = ls_content-content iv_subject = ls_mail_header-subject ).
          CONTINUE.
        ELSE.
          CLEAR ls_block.
          CONCATENATE text-b01 ls_mail_program-program_name INTO ls_block-line.
          APPEND ls_block TO lt_block.
          create( iv_type = 'TXT' it_body = lt_block iv_subject = ls_mail_header-subject ).
        ENDIF.
      ENDIF.
      add_attachment( iv_format = ls_content-format iv_subject = ls_content-object it_content = ls_content-content ).
    ENDLOOP.

    get_recipients( EXPORTING is_mail_header = ls_mail_header
                    IMPORTING et_recipients = lt_recipients ).

    send( EXPORTING iv_sender = ls_mail_header-sender iv_display_name = ls_mail_header-display_name it_recipients = lt_recipients iv_immediately = ls_mail_header-immediately ).
  ENDLOOP.
ENDMETHOD.