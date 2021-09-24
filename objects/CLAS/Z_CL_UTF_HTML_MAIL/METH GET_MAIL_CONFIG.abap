  METHOD GET_MAIL_CONFIG.

    DATA:
      ls_mail_program      TYPE zbc_mail_program,
      lt_mail_program      TYPE STANDARD TABLE OF zbc_mail_program,
      ls_mail_header       TYPE zbc_mail_header,
      lt_mail_header       TYPE STANDARD TABLE OF zbc_mail_header,
      ls_mail_recipient    TYPE zbc_mail_recip,
      lt_mail_recipient    TYPE STANDARD TABLE OF zbc_mail_recip,
      ls_sender            TYPE zbc_mail_email_address_line,
      lt_recipients        TYPE zbc_mail_email_address_table.

    " Read the program configurations
    SELECT * INTO TABLE lt_mail_program
      FROM zbc_mail_program
      WHERE program_name = iv_program AND
            variant_name = iv_variant.
    IF sy-subrc <> 0.
      " Read with the generic variant
      SELECT * INTO TABLE lt_mail_program
        FROM zbc_mail_program
        WHERE program_name = iv_program AND
              variant_name = space.
      IF sy-subrc <> 0.
        " Read with the default program
        SELECT * INTO TABLE lt_mail_program
          FROM zbc_mail_program
          WHERE program_name = 'DEFAULT_PROGRAM' AND
                variant_name = 'NOT_CONFIGURED'.
      ENDIF.
    ENDIF.

    IF lt_mail_program IS INITIAL.
      RAISE EXCEPTION TYPE cx_abap_docu_not_found.
    ENDIF.

    LOOP AT lt_mail_program INTO ls_mail_program.
      " Read the configuration header
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

      get_recipients( EXPORTING is_mail_header = ls_mail_header
                             IMPORTING et_recipients = lt_recipients ).


      APPEND VALUE ty_sender_recipient( head = ls_mail_header
                                        recipients = lt_recipients ) TO rt_sender_recipients.
    ENDLOOP.
  ENDMETHOD.