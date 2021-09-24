  METHOD check_audit_data.
    "#TODO implement the E2E webservices calls
    rv_rc = 0.
    "Compare the values from received to read
    IF ms_received_audit_data-unique_id IS NOT INITIAL.

**      IF ( go_interface_audit_data->ws_send_audit_data_data(
**         iv_step_id = zetoe_stepid_chk_audit_data_values
**         iv_comment = zetoe_stepid_chk_audit_data_value_c
**         is_audit_data_data = ms_calculated_audit_data ) <> 0 ).
**
**        go_interface_audit_data->ws_enable_disable_ws( '' ).
**      ENDIF.
**      go_interface_audit_data->ws_send_status_audit_data_data(
**               is_audit_data_data_received = ms_received_audit_data
**                is_audit_data_data_calculated = ms_calculated_audit_data ).
*
      IF    ( ms_calculated_audit_data-documents_counter IS NOT INITIAL
          AND ms_calculated_audit_data-documents_counter <> ms_received_audit_data-documents_counter ) OR
            ( ms_calculated_audit_data-total_debit IS NOT INITIAL AND
              ms_calculated_audit_data-total_debit <> ms_received_audit_data-total_debit ) OR
           ( ms_calculated_audit_data-total_credit IS NOT INITIAL
            AND ms_calculated_audit_data-total_credit <> ms_received_audit_data-total_credit ) OR
            ( ms_calculated_audit_data-quantity IS NOT INITIAL
            AND ms_calculated_audit_data-quantity <> ms_received_audit_data-quantity ).
        rv_rc = 8.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot reconcile the audit data.'(e01).
      ELSE.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'O' iv_msg1 = 'Audit data for inbound file are correct'(o01).
      ENDIF.
**      go_interface_audit_data->ws_create( iv_interface_id = ms_received_audit_data-interface_id iv_unique_id = ms_received_audit_data-unique_id  iv_step_id = zetoe_stepid_analysis_finish iv_comment = zetoe_stepid_analysis_finish_c ).
    ENDIF.
  ENDMETHOD.