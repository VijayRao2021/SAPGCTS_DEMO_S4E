METHOD WS_SEND_STATUS_AUDIT_DATA.

  CHECK NOT mv_ws_call IS INITIAL.

  IF NOT is_audit_data_calculated-documents_counter IS INITIAL.
    IF is_audit_data_received-documents_counter = is_audit_data_calculated-documents_counter.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_idoc_counter iv_status = zetoe_status_success ).
    ELSE.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_idoc_counter iv_status = zetoe_status_failed ).
    ENDIF.
  ENDIF.

  IF NOT is_audit_data_calculated-total_credit IS INITIAL.
    IF  is_audit_data_received-total_credit = is_audit_data_calculated-total_credit.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_total_credit iv_status = zetoe_status_success ).
    ELSE.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_total_credit iv_status = zetoe_status_failed ).
    ENDIF.
  ENDIF.

  IF NOT is_audit_data_calculated-total_debit IS INITIAL.
    IF  is_audit_data_received-total_debit = is_audit_data_calculated-total_debit.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_total_debit iv_status = zetoe_status_success ).
    ELSE.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_total_debit iv_status = zetoe_status_failed ).
    ENDIF.
  ENDIF.

  IF NOT is_audit_data_calculated-quantity IS INITIAL.
    IF  is_audit_data_received-quantity = is_audit_data_calculated-quantity.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_quantity iv_status = zetoe_status_success ).
    ELSE.
      ws_validation_check( iv_interface_id = is_audit_data_received-interface_id iv_unique_id = is_audit_data_received-unique_id iv_comment = zetoe_stepid_check_value  iv_property_name = zetoe_property_quantity iv_status = zetoe_status_failed ).
    ENDIF.
  ENDIF.
ENDMETHOD.