  METHOD PROCESS_PROCESSING_STATUS_UPD.
    DATA:
          lv_group TYPE string.
    lv_group = mv_module_id.

    RAISE EVENT send_log EXPORTING iv_group = lv_group iv_level = 5 iv_type = 'I' iv_msg1 = '&2 is caught by &3 &4.'(i03) iv_msg2 = 'PROCESSING_STATUS_UPDATED' iv_msg3 = mv_module_id iv_msg4 = mv_object_id.

    CASE iv_status.
      WHEN zrunt_c_status_in_progress.
      WHEN zrunt_c_status_completed.
        complete_processing( iv_object_id ).
    ENDCASE.
  ENDMETHOD.