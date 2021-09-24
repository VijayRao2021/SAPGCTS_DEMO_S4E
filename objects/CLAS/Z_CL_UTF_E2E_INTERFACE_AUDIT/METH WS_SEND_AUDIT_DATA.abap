METHOD WS_SEND_AUDIT_DATA.
  DATA:
        lv_flg_conn_failed TYPE c.

  rv_returncode = 0.
  CHECK NOT mv_ws_call IS INITIAL.

  CLEAR lv_flg_conn_failed.
  IF  NOT is_audit_data-documents_counter IS INITIAL.
    IF ( ws_create( iv_interface_id = is_audit_data-interface_id iv_unique_id = is_audit_data-unique_id  iv_step_id = iv_step_id iv_comment = iv_comment
                    iv_property_name = zetoe_property_idoc_counter iv_property_value = is_audit_data-documents_counter ) <> 0 ).
      lv_flg_conn_failed = 'X'.
    ENDIF.
  ENDIF.
  IF  NOT is_audit_data-total_credit IS INITIAL.
    IF ( ws_create( iv_interface_id = is_audit_data-interface_id iv_unique_id = is_audit_data-unique_id  iv_step_id = iv_step_id iv_comment = iv_comment
                    iv_property_name = zetoe_property_total_credit iv_property_value = is_audit_data-total_credit ) <> 0 ).
      lv_flg_conn_failed = 'X'.
    ENDIF.
  ENDIF.
  IF  NOT is_audit_data-total_debit IS INITIAL.
    IF ( ws_create( iv_interface_id = is_audit_data-interface_id iv_unique_id = is_audit_data-unique_id  iv_step_id = iv_step_id iv_comment = iv_comment
                    iv_property_name = zetoe_property_total_debit iv_property_value = is_audit_data-total_debit ) <> 0 ).
      lv_flg_conn_failed = 'X'.
    ENDIF.
  ENDIF.
  IF  NOT is_audit_data-quantity IS INITIAL.
    IF ( ws_create( iv_interface_id = is_audit_data-interface_id iv_unique_id = is_audit_data-unique_id  iv_step_id = iv_step_id iv_comment = iv_comment
                    iv_property_name = zetoe_property_quantity iv_property_value = is_audit_data-quantity ) <> 0 ).
      lv_flg_conn_failed = 'X'.
    ENDIF.
  ENDIF.
  IF lv_flg_conn_failed = 'X'.
    rv_returncode = 8.
  ELSE.
    rv_returncode = 0.
  ENDIF.
ENDMETHOD.