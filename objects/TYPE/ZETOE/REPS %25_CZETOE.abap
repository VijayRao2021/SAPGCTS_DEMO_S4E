TYPE-POOL zetoe.

TYPES:
  zetoe_comment TYPE string,
  zetoe_interface_id TYPE zinterface_id,
  zetoe_unique_id TYPE zunique_id,
  zetoe_property_name TYPE string,
  zetoe_property_value TYPE string,
  zetoe_status_id TYPE n,
  zetoe_step_id(3) TYPE n,
  zetoe_system_id(4) TYPE n,
  zetoe_status(1) TYPE n,
  zetoe_error(2) TYPE n,

  BEGIN OF zetoe_sop_audit_header,
    record_type(6) TYPE c,
    unique_id TYPE zetoe_unique_id,
    interface_id TYPE zetoe_interface_id,
    timestamp(17) TYPE c,
    country_id(2) TYPE c,
    identifier(40) TYPE c,
    sequence_number(15) TYPE c,
  END OF zetoe_sop_audit_header,

  BEGIN OF zetoe_sop_audit_trailer,
    record_type(6) TYPE c,
    documents_counter(15) TYPE c,
    total_debit(17) TYPE c,
    total_credit(17) TYPE c,
    quantity(15) TYPE c,
  END OF zetoe_sop_audit_trailer,

  zetoe_tr_interface_id_range TYPE RANGE OF zinterface_id,
  zetoe_ts_interface_id_line TYPE line of zetoe_tr_interface_id_range.

CONSTANTS:
*--- Constants for the web service
  zetoe_audit_class TYPE srt_lp_proxyclass VALUE 'ZE2E_CO_E2EAUDIT_WS',
  zetoe_validation_class TYPE srt_lp_proxyclass VALUE 'ZE2E_CO_VALIDATION_CHECK_WS',
  zetoe_system_id TYPE zetoe_system_id VALUE '3000',
  zetoe_eai_system_id TYPE zetoe_system_id VALUE '2000',

*Step ID for Inbound interfaces
  zetoe_stepid_get_validation TYPE zetoe_step_id VALUE '300',
  zetoe_stepid_chk_idocs_nb TYPE zetoe_step_id VALUE '310',
  zetoe_stepid_start_analysis TYPE zetoe_step_id VALUE '320',
  zetoe_stepid_registration TYPE zetoe_step_id VALUE '330',
  zetoe_stepid_chk_idocs_status TYPE zetoe_step_id VALUE '340',
  zetoe_stepid_chk_audit_values TYPE zetoe_step_id VALUE '350',
  zetoe_stepid_analysis_finish TYPE zetoe_step_id VALUE '399',

  zetoe_stepid_get_validation_c TYPE zetoe_comment VALUE 'Get EAI validation for Unique ID',
  zetoe_stepid_chk_idocs_ex_c TYPE zetoe_comment VALUE 'Number of Idocs expected',
  zetoe_stepid_chk_idocs_rv_c TYPE zetoe_comment VALUE 'Number of Idocs received',
  zetoe_stepid_start_analysis_c TYPE zetoe_comment VALUE 'Start Analysis Unique ID',
  zetoe_stepid_registration_c TYPE zetoe_comment VALUE 'Registration of received audit information',
  zetoe_stepid_chk_idocs_statu_c TYPE zetoe_comment VALUE 'Check if Idocs are well processed',
  zetoe_stepid_chk_audit_value_c TYPE zetoe_comment VALUE 'Audit data reconciliation',
  zetoe_stepid_analysis_finish_c TYPE zetoe_comment VALUE 'Analysis finished',
  zetoe_stepid_check_value TYPE zetoe_comment VALUE 'Check Value',
  zetoe_stepid_park_idoc_c TYPE zetoe_comment VALUE 'EAI return -1, so park the idocs and stop the processing',
  zetoe_stepid_stop_wait_c TYPE zetoe_comment VALUE  '1 hour since the last idoc, SAP stop waiting the EAI confirmation and the idocs are parked',
  zetoe_stepid_validation_ok TYPE zetoe_comment VALUE 'EAI return 1',

*Step ID for the Outbound interfaces
  zetoe_stepid_start TYPE zetoe_step_id VALUE '100',
  zetoe_stepid_head_register TYPE zetoe_step_id VALUE '110',
  zetoe_stepid_data_gen TYPE zetoe_step_id VALUE '120',
  zetoe_stepid_audit_values TYPE zetoe_step_id VALUE '130',
  zetoe_stepid_completed TYPE zetoe_step_id VALUE '199',

  zetoe_stepid_start_c TYPE zetoe_comment VALUE 'Start Outbound interface',
  zetoe_stepid_head_register_c TYPE zetoe_comment VALUE 'Register Header properties',
  zetoe_stepid_data_gen_c TYPE zetoe_comment VALUE 'Extract data',
  zetoe_stepid_audit_values_c TYPE zetoe_comment VALUE 'Audit data for reconciliation',
  zetoe_stepid_completed_c TYPE zetoe_comment VALUE 'Outbound interface extraction completed',

*Properties values
  zetoe_property_output_counter TYPE zetoe_property_name VALUE 'OUTPUT_COUNTER',
  zetoe_property_idoc_counter TYPE zetoe_property_name VALUE 'DOCUMENTS_COUNTER',
  zetoe_property_idoc_processed TYPE zetoe_property_name VALUE 'IDOCS_PROCESSED',
  zetoe_property_idoc_not_proc TYPE zetoe_property_name VALUE 'IDOCS_NOT_PROCESSED',
  zetoe_property_idoc_failed TYPE zetoe_property_name VALUE 'IDOCS_FAILED',
  zetoe_property_total_credit TYPE zetoe_property_name VALUE 'TOTAL_CREDIT',
  zetoe_property_total_debit TYPE zetoe_property_name VALUE 'TOTAL_DEBIT',
  zetoe_property_quantity TYPE zetoe_property_name VALUE 'QUANTITY',

  zetoe_status_success TYPE zetoe_status VALUE '1',
  zetoe_status_failed TYPE zetoe_status VALUE '2',

  zetoe_idoc_status_parked TYPE edi_status VALUE '68',
  zetoe_idoc_status_wait TYPE edi_status VALUE '68',
  zetoe_idoc_status_ready TYPE edi_status VALUE '64',
  zetoe_idoc_status_processed TYPE edi_status VALUE '53',
  zetoe_idoc_status_error TYPE edi_status VALUE '51',

  zetoe_error_eai_running TYPE zetoe_error VALUE '01',
  zetoe_error_wsconnfail_p TYPE zetoe_error VALUE '02',
  zetoe_error_last_preproc TYPE zetoe_error VALUE '49',

  zetoe_error_ready_4_analysis TYPE zetoe_error VALUE '50',
  zetoe_error_custo_missing TYPE zetoe_error VALUE '51',
  zetoe_error_wsconnfail_a TYPE zetoe_error VALUE '52',

  zetoe_error_idoc_failed TYPE zetoe_error VALUE '70',
  zetoe_error_idoc_not_processed TYPE zetoe_error VALUE '71',
  zetoe_error_missing_idocs TYPE zetoe_error VALUE '72',

  zetoe_error_multi_error TYPE zetoe_error VALUE '99'.