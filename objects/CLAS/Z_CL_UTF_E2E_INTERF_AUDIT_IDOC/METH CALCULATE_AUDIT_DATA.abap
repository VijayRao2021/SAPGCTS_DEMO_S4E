METHOD CALCULATE_AUDIT_DATA.
  DATA:
        ls_calculation_customizing TYPE ts_calculation_customizing.


  "Check if the data can be calculated
  CHECK ( is_auditable( ) = 0 ) AND ( is_processed( ) = 0 ).

  "Read the customizing to know how to calculate the audit data depending on the interface.
  READ TABLE gt_calculation_customizing INTO ls_calculation_customizing WITH KEY interface_id = cs_audit_data-interface_id.
  IF sy-subrc <> 0.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT_IDOC' iv_level = 0 iv_type = 'E' iv_msg1 = 'Calculation method is not configured in table ZBC_AUDIT_CUST for the interface &2'(e01) iv_msg2 = cs_audit_data-interface_id.
    RAISE method_not_configured.
  ENDIF.

  "Run the method.
  CALL METHOD (ls_calculation_customizing-method)
    EXPORTING
      is_configuration = ls_calculation_customizing
    CHANGING
      cs_audit_data    = cs_audit_data.
ENDMETHOD.