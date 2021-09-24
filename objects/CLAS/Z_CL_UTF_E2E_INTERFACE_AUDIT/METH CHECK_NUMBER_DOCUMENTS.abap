METHOD CHECK_NUMBER_DOCUMENTS.

  DESCRIBE TABLE Ir_INTERFACE->idocs LINES Ir_INTERFACE->audit_data_calculated-documents_counter.
  CONDENSE Ir_INTERFACE->audit_data_calculated-documents_counter NO-GAPS.
  IF ( ws_create( iv_interface_id = Ir_INTERFACE->audit_data_received-interface_id iv_unique_id = Ir_INTERFACE->unique_id iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_chk_idocs_ex_c
                iv_property_name = zetoe_property_output_counter iv_property_value = Ir_INTERFACE->audit_data_received-output_counter ) <> 0 ).
    Ir_INTERFACE->error_code = mv_error_ws_conn_failed.
  ENDIF.
  IF ( ws_create( iv_interface_id = Ir_INTERFACE->audit_data_received-interface_id iv_unique_id = Ir_INTERFACE->unique_id iv_step_id = zetoe_stepid_chk_idocs_nb iv_comment = zetoe_stepid_chk_idocs_rv_c
                  iv_property_name = zetoe_property_output_counter iv_property_value = Ir_INTERFACE->audit_data_calculated-documents_counter ) <> 0 ).
    Ir_INTERFACE->error_code = mv_error_ws_conn_failed.
  ENDIF.

  IF Ir_INTERFACE->audit_data_calculated-documents_counter <> Ir_INTERFACE->audit_data_received-documents_counter.
    rv_returncode = 8.
    ws_validation_check( iv_interface_id = Ir_INTERFACE->audit_data_received-interface_id iv_unique_id = Ir_INTERFACE->unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_idoc_counter iv_status = zetoe_status_success ).
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 0 iv_type = 'E' iv_msg1 = '&2/&3: &4 received idocs <> &5 expected idocs'(e01) iv_msg2 = Ir_INTERFACE->interface_id iv_msg3 = Ir_INTERFACE->unique_id
                                   iv_msg4 = Ir_INTERFACE->audit_data_calculated-documents_counter iv_msg5 = Ir_INTERFACE->audit_data_received-documents_counter.
  ELSE.
    rv_returncode = 0.
    ws_validation_check( iv_interface_id = Ir_INTERFACE->audit_data_received-interface_id iv_unique_id = Ir_INTERFACE->unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_idoc_counter iv_status = zetoe_status_failed ).
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'O' iv_msg1 = 'All idocs are arrived for this interface'(m06).
  ENDIF.
ENDMETHOD.