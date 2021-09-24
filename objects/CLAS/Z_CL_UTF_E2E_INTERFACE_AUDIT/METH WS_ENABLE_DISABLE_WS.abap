METHOD WS_ENABLE_DISABLE_WS.
  IF iv_flag = mv_ws_call.
    "Value is already correct, then ignore the request
    EXIT.
  ENDIF.
  IF iv_flag IS INITIAL.
    CLEAR mv_ws_call.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Calls to Web Services are &2.'(m20) iv_msg2 = 'Disable'(m21).
  ELSE.
    mv_ws_call = 'X'.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Calls to Web Services are &2.'(m20) iv_msg2 = 'Enable'(m22).
  ENDIF.
ENDMETHOD.