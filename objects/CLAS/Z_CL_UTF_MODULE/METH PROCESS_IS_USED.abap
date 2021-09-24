  METHOD PROCESS_IS_USED.
    DATA:
      lv_group TYPE string.
    lv_group = mv_module_id.

    RAISE EVENT send_log EXPORTING iv_group = lv_group iv_level = 5 iv_type = 'I' iv_msg1 = '&2 is caught by &3 &4.'(i03) iv_msg2 = 'IS_USED' iv_msg3 = mv_module_id iv_msg4 = mv_object_id.
  ENDMETHOD.