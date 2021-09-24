  METHOD constructor.
    super->constructor( iv_dataset_type = iv_dataset_type iv_filename = iv_filename iv_subfolder = iv_subfolder iv_process_id = iv_process_id ).

    CLEAR: ms_received_audit_data, ms_calculated_audit_data.

  ENDMETHOD.