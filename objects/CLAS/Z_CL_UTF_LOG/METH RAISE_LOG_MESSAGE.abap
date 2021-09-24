  METHOD RAISE_LOG_MESSAGE.
    RAISE EVENT raise_log EXPORTING iv_group = iv_group iv_level = iv_level iv_type = iv_type iv_msgid = iv_msgid iv_msgno = iv_msgno iv_msg1 = iv_msg1 iv_msg2 = iv_msg2 iv_msg3 = iv_msg3 iv_msg4 = iv_msg4 iv_msg5 = iv_msg5 iv_put_at_end = iv_put_at_end.
  ENDMETHOD.