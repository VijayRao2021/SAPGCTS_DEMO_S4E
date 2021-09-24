METHOD search_mail_address.
************************************************************************
* 5/3/17   smartShift project

************************************************************************

  DATA:
        lv_username TYPE bapibname-bapibname,
        ls_mailing_list TYPE zbc_mail_list,
        lt_mailing_list TYPE STANDARD TABLE OF zbc_mail_list,
        ls_recipient TYPE zbc_mail_email_address_line,
        ls_recipient_ref TYPE REF TO zbc_mail_email_address_line,
        lt_recipients TYPE STANDARD TABLE OF zbc_mail_email_address_line,
        lt_return TYPE STANDARD TABLE OF bapiret2,
        ls_user_addr TYPE bapiadsmtp,
        lt_user_addr TYPE STANDARD TABLE OF bapiadsmtp.

  REFRESH et_recipients.
  CASE is_recipient-addrtype.
    WHEN 'M' OR ' '. "Email Address
      APPEND is_recipient TO et_recipients.

    WHEN 'L'."Mailing List
*Get the mailing list definition...
      SELECT * INTO TABLE lt_mailing_list
        FROM zbc_mail_list
        WHERE mailing_list = is_recipient-recipient ORDER BY PRIMARY KEY.                          "$sst: #601
*...and convert the recipients to email addresses
      LOOP AT lt_mailing_list INTO ls_mailing_list.
        CLEAR ls_recipient.
        MOVE-CORRESPONDING ls_mailing_list to ls_recipient.
        search_mail_address( EXPORTING is_recipient = ls_recipient
                             IMPORTING et_recipients = lt_recipients ).
        APPEND LINES OF lt_recipients TO et_recipients.
      ENDLOOP.
*If the mailing list set to user mailing list then set all the recipients to user recipient
      IF is_recipient-user_flag = 'X'.
        LOOP AT et_recipients REFERENCE INTO ls_recipient_ref.
          IF ls_recipient_ref->user_flag <> is_recipient-user_flag.
            ls_recipient_ref->user_flag = is_recipient-user_flag.
          ENDIF.
        ENDLOOP.
      ENDIF.

    WHEN 'T'.

    WHEN 'U' OR 'C'."SAP User
*Read the E-Mail address for the user
      IF is_recipient-addrtype = 'C'.
        lv_username = sy-uname.
      ELSE.
        lv_username = is_recipient-recipient.
      ENDIF.
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = lv_username
        TABLES
          return   = lt_return
          addsmtp  = lt_user_addr.
      LOOP AT lt_user_addr INTO ls_user_addr WHERE std_no = 'X'.
        CLEAR ls_recipient.
        MOVE-CORRESPONDING is_recipient TO ls_recipient.
        ls_recipient-recipient = ls_user_addr-e_mail.
        APPEND ls_recipient TO et_recipients.
      ENDLOOP.
  ENDCASE.
ENDMETHOD.