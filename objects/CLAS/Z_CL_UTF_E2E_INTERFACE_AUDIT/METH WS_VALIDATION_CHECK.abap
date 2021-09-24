METHOD WS_VALIDATION_CHECK.
  DATA:
        lv_message type string,

* Reference variables for exception class
        lo_sys_exception   TYPE REF TO cx_ai_system_fault,
        lo_app_exception   TYPE REF TO cx_ai_application_fault,
        lo_cx_throwable   TYPE REF TO ze2e_cx_throwable,
* Structures to set and get message content
        ls_request         TYPE ze2e_opr_validation_check1,
        ls_response        TYPE ze2e_opr_validation_check_res1.

  ls_request-parameters-validation_input-system_id = zetoe_system_id.
  ls_request-parameters-validation_input-interface_id = iv_interface_id.
  ls_request-parameters-validation_input-job_id = iv_unique_id.

  ls_request-parameters-validation_input-comment = iv_comment.

  ls_request-parameters-validation_input-property_name = iv_property_name.
  ls_request-parameters-validation_input-rule_id = 1.
  ls_request-parameters-validation_input-status_id = iv_status.

  rv_returncode = 0.
  CHECK NOT mv_ws_call IS INITIAL.

*--- Call the service
  TRY.
    clear lv_message.

      CALL METHOD mo_e2e_validation_ws_proxy->opr_validation_check
        EXPORTING
          input  = ls_request
        IMPORTING
          output = ls_response.

      CATCH cx_ai_system_fault      INTO lo_sys_exception.
        lv_message = lo_sys_exception->get_text( ).
      CATCH ze2e_cx_throwable INTO lo_cx_throwable.
        lv_message = lo_cx_throwable->get_text( ).
      CATCH cx_ai_application_fault INTO lo_app_exception.
        lv_message = lo_app_exception->get_text( ).
  ENDTRY.
*   Error handling
      IF NOT lo_sys_exception IS INITIAL
      OR NOT lo_app_exception IS INITIAL
      OR NOT lo_cx_throwable IS INITIAL.
        "Return an error code
        rv_returncode = 8.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Erreur calling Validation WS for &2, &3 &4: &5'(e08) iv_msg2 = iv_property_name iv_msg3 = iv_interface_id iv_msg4 = iv_unique_id iv_msg5 = lv_message.
        EXIT.
      ENDIF.
  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Call to Validation WS successful: &2, &3 &4'(m14) iv_msg2 = iv_property_name iv_msg3 = iv_interface_id iv_msg4 = iv_unique_id.
ENDMETHOD.