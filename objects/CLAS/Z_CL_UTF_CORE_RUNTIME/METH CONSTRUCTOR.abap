  METHOD constructor.
    RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 0 iv_type = 'H' iv_msg1 = 'Initializing the Runtime Module...'(h01).

    super->constructor( zcore_c_modid_runtime ).


    IF iv_manage_log = abap_true.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Log management is requested.'(i01).
      "Initialize the log
      CREATE OBJECT mo_log
        EXPORTING
          iv_level = 5.
      "Connect the log connect to the log event
      SET HANDLER mo_log->add_log.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Log is activated'(i02).
    ENDIF.

    create( iv_process_id = iv_process_id iv_country = iv_country ).

    RAISE EVENT is_used EXPORTING iv_module_id = mv_module_id iv_object_id = mv_object_id.
  ENDMETHOD.