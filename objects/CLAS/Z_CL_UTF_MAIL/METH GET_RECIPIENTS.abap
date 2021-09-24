METHOD get_recipients.
  DATA:
        ls_mail_header TYPE zbc_mail_header,
        ls_mail_recipient TYPE zbc_mail_recip,
        lt_mail_recipients TYPE STANDARD TABLE OF zbc_mail_recip,
        ls_recipient TYPE zbc_mail_email_address_line,
        lt_recipients TYPE zbc_mail_email_address_table.

*Gets the recipients for the given programm/configuration
  SELECT * INTO TABLE lt_mail_recipients
    FROM zbc_mail_recip
    WHERE program_name = is_mail_header-program_name AND
          configuration = is_mail_header-configuration.
  IF sy-subrc <> 0.
* If not found get default recipients
    CLEAR ls_mail_header.
    ls_mail_header-program_name = 'DEFAULT_PROGRAM'.
    ls_mail_header-configuration = 'NO_RECIP'.
    get_recipients( EXPORTING is_mail_header = ls_mail_header
                    IMPORTING et_recipients = et_recipients ).
  ELSE.
* Loop on the configuration recipient and convert them into smtp address
    LOOP AT lt_mail_recipients INTO ls_mail_recipient.
      CLEAR ls_recipient.
      MOVE-CORRESPONDING ls_mail_recipient TO ls_recipient.
      search_mail_address( EXPORTING is_recipient = ls_recipient
                           IMPORTING et_recipients = lt_recipients ).
      LOOP AT lt_recipients INTO ls_recipient.
*Check if the mail can be send to the user addresses
        IF NOT ( is_mail_header-disable_user = 'X' AND ls_recipient-user_flag = 'X' ).
          APPEND ls_recipient TO et_recipients.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

*Finally if the recipients list is empty then get the recipients from a default ML
    IF et_recipients[] IS INITIAL.
      CLEAR ls_recipient.
      ls_recipient-addrtype = 'L'.
      ls_recipient-recipient = 'DEFAULT_ML'.
      search_mail_address( EXPORTING is_recipient = ls_recipient
                           IMPORTING et_recipients = lt_recipients ).
      APPEND LINES OF lt_recipients TO et_recipients.
    ENDIF.
  ENDIF.
ENDMETHOD.