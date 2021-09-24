METHOD WS_GET_EAI_VALIDATION_STATUS.
  DATA:
      lv_message TYPE string,
* Reference variables for exception class
      lo_sys_exception   TYPE REF TO cx_ai_system_fault,
      lo_app_exception   TYPE REF TO cx_ai_application_fault,
      lo_cx_throwable   TYPE REF TO ze2e_cx_throwable,
* Structures to set and get message content
      ls_request         TYPE ze2e_get_validation_status1,
      ls_response        TYPE ze2e_get_validation_status_re1,
      ls_request2 TYPE ze2e_get_output_count_from_ea2,
      ls_response2 TYPE ze2e_get_output_count_from_ea1.

  CHECK NOT mv_ws_call IS INITIAL.
  CLEAR ls_request.
  ls_request-parameters-system_id = zetoe_eai_system_id.
  ls_request-parameters-interface_id = iv_interface_id.
  ls_request-parameters-job_id = iv_unique_id.
*--- Call the service
  TRY.
      CLEAR lv_message.

      CALL METHOD mo_e2e_validation_ws_proxy->get_validation_status
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
*  Error handling
  IF NOT lo_sys_exception IS INITIAL
  OR NOT lo_app_exception IS INITIAL
  OR NOT lo_cx_throwable IS INITIAL.
    "Return an error code
    ev_subrc = 8.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Can''t reach audit framework to get the EAI status: park the idocs.'(e16).
    EXIT.
  ELSEIF ls_response-parameters-return-valid = 'X'.
    "If EAI says OK, then get the number of expected idocs
    ev_subrc = 0.
    CLEAR ls_request2.
    ls_request2-parameters-interface_id = iv_interface_id.
    ls_request2-parameters-job_id = iv_unique_id.
    TRY.
        CLEAR lv_message.

        CALL METHOD mo_e2e_validation_ws_proxy->get_output_count_from_eai
          EXPORTING
            input  = ls_request2
          IMPORTING
            output = ls_response2.

      CATCH cx_ai_system_fault      INTO lo_sys_exception.
        lv_message = lo_sys_exception->get_text( ).
      CATCH ze2e_cx_throwable INTO lo_cx_throwable.
        lv_message = lo_cx_throwable->get_text( ).
      CATCH cx_ai_application_fault INTO lo_app_exception.
        lv_message = lo_app_exception->get_text( ).

    ENDTRY.
*  Error handling
    IF NOT lo_sys_exception IS INITIAL
    OR NOT lo_app_exception IS INITIAL
    OR NOT lo_cx_throwable IS INITIAL.
      "Return an error code
      ev_subrc = 0.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Can''t reach audit framework to get the EAI status: park the idocs.'(e16).
      EXIT.
    ENDIF.
  ELSE.
    ev_subrc = 8.
  ENDIF.
  ev_output_counter = ls_response2-parameters-return.
  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Got EAI status: &2.'(m18) iv_msg2 = ev_subrc.
ENDMETHOD.