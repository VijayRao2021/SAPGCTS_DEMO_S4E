METHOD CHECK_IDOCS_STATUS.
  DATA:
      lv_cnt_idocs_failed TYPE i,
      lv_cnt_idocs_not_processed TYPE i,
      lv_cnt_idocs_processed TYPE i,
      lr_idoc TYPE REF TO zbc_audit_idoc_line.

  rv_returncode = 0.

  LOOP AT ir_interface->idocs REFERENCE INTO lr_idoc.
    IF ( lr_idoc->idoc->is_processed( ) <> 0 ).
      IF ( lr_idoc->idoc->is_failed( ) = 0 ).
*        lr_idoc->error_code = zetoe_error_idoc_failed.
        ADD 1 TO lv_cnt_idocs_failed.
        IF rv_returncode <> 8.
          rv_returncode = 4.
        ENDIF.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'IDOC &2 is in error status'(e02) iv_msg2 = lr_idoc->docnum.
      ELSE.
        lr_idoc->error_code = zetoe_error_idoc_not_processed.
        ADD 1 TO lv_cnt_idocs_not_processed.
        rv_returncode = 8.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'IDOC &2 is not processed'(e03) iv_msg2 = lr_idoc->docnum.
      ENDIF.
    ELSE.
      ADD 1 TO lv_cnt_idocs_processed.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'O' iv_msg1 = 'IDOC &3 is well processed'(m07) iv_msg2 = lr_idoc->docnum.
    ENDIF.
  ENDLOOP.

* Update the Audit Framework
  IF ( ws_create( iv_interface_id = ir_interface->audit_data_received-interface_id iv_unique_id = ir_interface->unique_id  iv_step_id = zetoe_stepid_chk_idocs_status iv_comment = zetoe_stepid_chk_idocs_statu_c
                  iv_property_name = zetoe_property_idoc_processed iv_property_value = lv_cnt_idocs_processed ) <> 0 ).
    ir_interface->error_code = mv_error_ws_conn_failed.
  ENDIF.
  IF ( ws_create( iv_interface_id = ir_interface->audit_data_received-interface_id iv_unique_id = ir_interface->unique_id  iv_step_id = zetoe_stepid_chk_idocs_status iv_comment = zetoe_stepid_chk_idocs_statu_c
                  iv_property_name = zetoe_property_idoc_not_proc iv_property_value = lv_cnt_idocs_not_processed ) <> 0 ).
    ir_interface->error_code = mv_error_ws_conn_failed.
  ENDIF.
  IF ( ws_create( iv_interface_id = ir_interface->audit_data_received-interface_id iv_unique_id = ir_interface->unique_id  iv_step_id = zetoe_stepid_chk_idocs_status iv_comment = zetoe_stepid_chk_idocs_statu_c
                iv_property_name = zetoe_property_idoc_failed iv_property_value = lv_cnt_idocs_failed ) <> 0 ).
    ir_interface->error_code = mv_error_ws_conn_failed.
  ENDIF.
ENDMETHOD.