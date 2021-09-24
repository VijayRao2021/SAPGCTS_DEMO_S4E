  METHOD COMPLETE_PROCESSING.
    DATA:
          lv_group TYPE string.

    lv_group = mv_module_id.

    RAISE EVENT send_log EXPORTING iv_group = lv_group iv_level = 1 iv_type = 'I' iv_msg1 = 'Complete processing for &2/&3'(i01) iv_msg2 = mv_module_id iv_msg3 = mv_object_id.
    save( ).

  ENDMETHOD.