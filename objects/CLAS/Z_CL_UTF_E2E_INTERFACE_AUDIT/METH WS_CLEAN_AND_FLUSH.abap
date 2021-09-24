METHOD WS_CLEAN_AND_FLUSH.
  DATA:
        lv_message TYPE string,
* Reference variables for exception class
      lo_sys_exception TYPE REF TO cx_ai_system_fault,
      lo_app_exception TYPE REF TO cx_ai_application_fault,
      lo_cx_throwable TYPE REF TO ze2e_cx_throwable,
* Structures to set and get message content
      ls_request TYPE ze2e_clean_and_flush1.

  rv_returncode = 0.
  CHECK NOT mv_ws_call IS INITIAL.
  IF NOT mo_e2e_ws_proxy IS INITIAL AND ( iv_proxy_to_flush = space OR iv_proxy_to_flush = 'A' ).
    CLEAR lv_message.
*--- Call the service
    TRY.
        CALL METHOD mo_e2e_ws_proxy->clean_and_flush
          EXPORTING
            input = ls_request.

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
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Can''t call clean and flush web service: &2'(e07) iv_msg2 = lv_message.
    ELSE.
      rv_returncode = 0.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Clean and Flush web service call successfull.'(m13).
    ENDIF.
  ENDIF.

  IF NOT mo_e2e_validation_ws_proxy IS INITIAL AND ( iv_proxy_to_flush = space OR iv_proxy_to_flush = 'V' ).
    TRY.
        CALL METHOD mo_e2e_validation_ws_proxy->clean_and_flush
          EXPORTING
            input = ls_request.

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
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Can''t call clean and flush validation web service: &2'(e09) iv_msg2 = lv_message.
    ELSE.
      rv_returncode = 0.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Clean and Flush validation web service call successfull.'(m15).
    ENDIF.
  ENDIF.
ENDMETHOD.