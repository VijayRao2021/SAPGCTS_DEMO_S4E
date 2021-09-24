METHOD WS_CREATE.
  DATA:
        lv_message TYPE string,
* Reference variables for exception class
        lo_sys_exception   TYPE REF TO cx_ai_system_fault,
        lo_app_exception   TYPE REF TO cx_ai_application_fault,
        lo_cx_throwable   TYPE REF TO ze2e_cx_throwable,
* Structures to set and get message content
        ls_request         TYPE ze2e_create1,
        ls_response        TYPE ze2e_create_response1.

  rv_returncode = 0.
  CHECK NOT mv_ws_call IS INITIAL.

  ls_request-parameters-e2e_audit-system_id = zetoe_system_id.
  ls_request-parameters-e2e_audit-interface_id = iv_interface_id.
  ls_request-parameters-e2e_audit-job_id = iv_unique_id.
  ls_request-parameters-e2e_audit-step_id = iv_step_id.

  ls_request-parameters-e2e_audit-comment = iv_comment.

  ls_request-parameters-e2e_audit-property_name = iv_property_name.
  ls_request-parameters-e2e_audit-property_value = iv_property_value.

*--- Call the service
  TRY.
      CALL METHOD mo_e2e_ws_proxy->create
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
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Error calling create WS for &2, &3 &4: &5'(e06) iv_msg2 = iv_step_id iv_msg3 = iv_interface_id iv_msg4 = iv_unique_id iv_msg5 = lv_message.
    EXIT.
  ENDIF.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Call to create WS successful: &2, &3 &4'(m12) iv_msg2 = iv_step_id iv_msg3 = iv_interface_id iv_msg4 = iv_unique_id.
ENDMETHOD.