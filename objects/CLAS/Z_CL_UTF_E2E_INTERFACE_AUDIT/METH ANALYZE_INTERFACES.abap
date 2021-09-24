METHOD ANALYZE_INTERFACES.
  DATA:
        lr_interface TYPE REF TO ts_interface.


  LOOP AT mt_interfaces REFERENCE INTO lr_interface.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'Start the interface &3/&2 analysis...'(m04) iv_msg2 = lr_interface->unique_id iv_msg3 = lr_interface->audit_data_received-interface_id.
    IF ( check_idocs( lr_interface ) = 0 ).
      reconcile_data( lr_interface ).
     ELSE. "START_POSTPROC IDOCS_IN_ERROR condition - MC-001 GAP-1790
       postproc_start( ir_interface = lr_interface iv_callpoint = 'IDOC_IN_ERROR' ).
    ENDIF.
  ENDLOOP.
  idocs_recycling_management( ).

  LOOP AT mt_interfaces REFERENCE INTO lr_interface.
    "Send end step to the framework.
    ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_analysis_finish iv_comment = zetoe_stepid_analysis_finish_c ).
  ENDLOOP.

  "Finally clean and flus the framework web service
  ws_clean_and_flush( ).
ENDMETHOD.