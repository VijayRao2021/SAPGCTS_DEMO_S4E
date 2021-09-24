METHOD CHECK_IDOCS.
  rv_returncode = 0.
  rv_returncode = check_idocs_status( ir_interface ).
  IF rv_returncode <> 0.
    IF rv_returncode = 8.
      ir_interface->error_code = zetoe_error_multi_error.
    ENDIF.
    rv_returncode = 8.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Some idocs are not well processed: cannot reconcile the audit data; stop here.'(e20).
  ELSE.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'O' iv_msg1 = 'All the idocs are well processed!'(m09).
  ENDIF.
ENDMETHOD.