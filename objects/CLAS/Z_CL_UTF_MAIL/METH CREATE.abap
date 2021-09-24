METHOD create.
  DATA:
        lv_datalength TYPE i,
        lv_datalengths TYPE so_obj_len,
        lv_tmp_string TYPE string,
        lv_bcs_message TYPE string,
        ls_body TYPE LINE OF soli_tab,
        lo_bcs_exception TYPE REF TO cx_bcs.

  TRY.
      CLEAR o_send_request.
      o_send_request = cl_bcs=>create_persistent( ).

*Calculate the size body size
      DESCRIBE TABLE it_body LINES lv_datalength.
      lv_datalength = lv_datalength * 255.
      lv_datalengths = lv_datalength.

*Create the mail document
      CLEAR o_mail_document.
      o_mail_document = cl_document_bcs=>create_document( i_type = iv_type i_text = it_body i_subject = iv_subject i_length = lv_datalengths ).

    CATCH cx_bcs INTO lo_bcs_exception.
      lv_bcs_message = lo_bcs_exception->get_text( ).
      APPEND lv_bcs_message TO et_log.
      EXIT.
  ENDTRY.
ENDMETHOD.