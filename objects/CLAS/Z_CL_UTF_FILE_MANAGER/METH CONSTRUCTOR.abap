  METHOD constructor.
    RAISE EVENT send_log EXPORTING iv_group = 'FILE_MANAGER_CONSTRUCTOR' iv_level = 0 iv_type = 'H' iv_msg1 = 'Initializing the File Manager Module...'(h01).

    super->constructor( zcore_c_modid_filemanager ).

*  IFs iv_process_id IS SUPPLIED
    IF iv_process_id IS NOT INITIAL.
      mv_process_id = iv_process_id.
*    ELSE.
      "get the default process ID.
    ENDIF.

    "Load the file manager configuration
    SELECT SINGLE * INTO ms_file_manager
    FROM zfile_manager
    WHERE process_id = iv_process_id.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'FILE_MANAGER_CONSTRUCTOR' iv_level = 1 iv_type = 'E' iv_msg1 = 'No configuration found in ZFILE_MANAGER for Process ID &2.'(e01) iv_msg2 = iv_process_id.
      RAISE no_configuration.
    ENDIF.

    "Check for logical path and do conversion if required.
    IF ms_file_manager-root_logical IS NOT INITIAL.
      convert_logical_2_physical( EXPORTING iv_logical_folder = ms_file_manager-root_folder IMPORTING ev_physical_folder = ms_file_manager-root_folder ).
      CLEAR ms_file_manager-root_logical.
    ENDIF.
    IF ms_file_manager-progress_logical IS NOT INITIAL.
      convert_logical_2_physical( EXPORTING iv_logical_folder = ms_file_manager-progress_folder IMPORTING ev_physical_folder = ms_file_manager-progress_folder ).
      CLEAR ms_file_manager-progress_logical.
    ENDIF.
    IF ms_file_manager-archive_logical IS NOT INITIAL.
      convert_logical_2_physical( EXPORTING iv_logical_folder = ms_file_manager-archive_folder IMPORTING ev_physical_folder = ms_file_manager-archive_folder ).
      CLEAR ms_file_manager-archive_logical.
    ENDIF.
    IF ms_file_manager-error_logical IS NOT INITIAL.
      convert_logical_2_physical( EXPORTING iv_logical_folder = ms_file_manager-error_folder IMPORTING ev_physical_folder = ms_file_manager-error_folder ).
      CLEAR ms_file_manager-error_logical.
    ENDIF.

    RAISE EVENT is_used EXPORTING iv_module_id = mv_module_id iv_object_id = mv_object_id.
  ENDMETHOD.