METHOD send.
  DATA:
        lv_sent_to_all TYPE os_boolean,
        lv_bcs_message TYPE string,
        ls_recipient TYPE zbc_mail_email_address_line,

        lo_sender_id TYPE REF TO if_sender_bcs,
        lo_recipient TYPE REF TO if_recipient_bcs,
        lo_bcs_exception TYPE REF TO cx_bcs.

  TRY.
* add document to send request
      CALL METHOD o_send_request->set_document( o_mail_document ).

      CLEAR lo_sender_id.
      lo_sender_id = cl_cam_address_bcs=>create_internet_address( i_address_string = iv_sender i_address_name = iv_display_name ).
      CALL METHOD o_send_request->set_sender( lo_sender_id ).

      LOOP AT it_recipients INTO ls_recipient.
        CLEAR lo_recipient.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = ls_recipient-recipient i_address_name = ls_recipient-display_name ).

* add recipient with its respective attributes to send request
        CALL METHOD o_send_request->add_recipient( i_recipient = lo_recipient i_express = iv_express ).
      ENDLOOP.

      CALL METHOD o_send_request->set_status_attributes( i_requested_status = 'E' i_status_mail = 'E' ).
      CALL METHOD o_send_request->set_send_immediately( iv_immediately ).

* Send the mail
      CALL METHOD o_send_request->send(
         EXPORTING
                  i_with_error_screen = ' '
         RECEIVING
                  result = lv_sent_to_all ).
      IF lv_sent_to_all = 'X'.
      ENDIF.
      COMMIT WORK.

*Catch the exception and store the message
    CATCH cx_bcs INTO lo_bcs_exception.
      lv_bcs_message = lo_bcs_exception->get_text( ).
      APPEND lv_bcs_message TO et_log.
      EXIT.
  ENDTRY.
ENDMETHOD.