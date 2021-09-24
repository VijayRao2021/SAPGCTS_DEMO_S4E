METHOD RECONCILE_DATA.
  DATA:
        lr_idoc TYPE REF TO zbc_audit_idoc_line.

  CLEAR: ir_interface->audit_data_calculated-documents_counter,ir_interface->audit_data_calculated-total_debit,ir_interface->audit_data_calculated-total_credit,ir_interface->audit_data_calculated-quantity.
  LOOP AT ir_interface->idocs REFERENCE INTO lr_idoc.
    CALL METHOD lr_idoc->idoc->calculate_audit_data
      CHANGING
        cs_audit_data         = ir_interface->audit_data_calculated
      EXCEPTIONS
        method_not_configured = 1
        OTHERS                = 2.
    IF sy-subrc <> 0.
      ir_interface->error_code = zetoe_error_custo_missing.
      EXIT.
    ENDIF.
  ENDLOOP.
  IF ir_interface->error_code <> zetoe_error_custo_missing.
    " Send audit data to Framewwork.
    IF ( ws_send_audit_data( iv_step_id = zetoe_stepid_chk_audit_values iv_comment = zetoe_stepid_chk_audit_value_c is_audit_data = ir_interface->audit_data_calculated ) <> 0 ).
      ir_interface->error_code = mv_error_ws_conn_failed.
    ENDIF.
    ws_send_status_audit_data( is_audit_data_received = ir_interface->audit_data_received is_audit_data_calculated = ir_interface->audit_data_calculated ).
    IF ( ir_interface->audit_data_calculated-documents_counter IS NOT INITIAL AND ir_interface->audit_data_calculated-documents_counter <> ir_interface->audit_data_received-documents_counter ) OR
       ( ir_interface->audit_data_calculated-total_debit IS NOT INITIAL AND ir_interface->audit_data_calculated-total_debit <> ir_interface->audit_data_received-total_debit ) OR
       ( ir_interface->audit_data_calculated-total_credit IS NOT INITIAL AND ir_interface->audit_data_calculated-total_credit <> ir_interface->audit_data_received-total_credit ) OR
       ( ir_interface->audit_data_calculated-quantity IS NOT INITIAL AND ir_interface->audit_data_calculated-quantity <> ir_interface->audit_data_received-quantity ).
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 0 iv_type = 'E' iv_msg1 = 'Can''t reconcile the audit data on &2/&3'(e04) iv_msg2 = ir_interface->interface_id iv_msg3 = ir_interface->unique_id.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = '&2: &3/&4'(e13) iv_msg2 = 'DOCUMENTS_COUNTER' iv_msg3 = ir_interface->audit_data_received-documents_counter
                                     iv_msg4 = ir_interface->audit_data_calculated-documents_counter.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = '&2: &3/&4'(e13) iv_msg2 = 'TOTAL DEBIT' iv_msg3 = ir_interface->audit_data_received-total_debit
                                     iv_msg4 = ir_interface->audit_data_calculated-total_debit.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = '&2: &3/&4'(e13) iv_msg2 = 'TOTAL CREDIT' iv_msg3 = ir_interface->audit_data_received-total_credit
                                     iv_msg4 = ir_interface->audit_data_calculated-total_credit.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = '&2: &3/&4'(e13) iv_msg2 = 'QUANTITY' iv_msg3 = ir_interface->audit_data_received-quantity iv_msg4 = ir_interface->audit_data_calculated-quantity.
      "START_POSTPROC AUDIT_FAILED condition - MC-001
      postproc_start( ir_interface = ir_interface iv_callpoint = 'AUDIT_FAILED' ).
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'O' iv_msg1 = 'Interface is well integrated to SAP!'(m10).
      "START_POSTPROC SUCCESS condition -MC-001
      postproc_start( ir_interface = ir_interface iv_callpoint = 'SUCCESS' ).
    ENDIF.
  ELSE.
    CLEAR ir_interface->error_code.
    RAISE EVENT send_log EXPORTING iv_group = 'ERROR_MAIL' iv_level = 0 iv_type = 'E' iv_msg1 = 'Calculation method is not configured in table ZBC_AUDIT_CUST for the interface &2'(e14) iv_msg2 = ir_interface->interface_id.
  ENDIF.
ENDMETHOD.