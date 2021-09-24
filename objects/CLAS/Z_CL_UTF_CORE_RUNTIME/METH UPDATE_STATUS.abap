  METHOD update_status.
    RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Update the runtime status to &2'(i06) iv_msg2 = iv_status.
    ms_runtime-status = iv_status.
    mv_flg_changed = abap_true.

    save( ).

    RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Send notification to others modules...'(i08).

    "Raise a notification for the other modules.
    RAISE EVENT processing_status_updated EXPORTING iv_object_id = mv_object_id iv_status = iv_status.
  ENDMETHOD.