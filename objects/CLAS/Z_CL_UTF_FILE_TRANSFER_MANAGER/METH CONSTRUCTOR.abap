  METHOD constructor.
    RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_MANAGER_CONSTRUCTOR' iv_level = 0 iv_type = 'H' iv_msg1 = 'Initializing the File Transfer Manager Module...'(h01).

    super->constructor( zcore_c_modid_filetransfer ).

*  IF iv_process_id IS SUPPLIED.
    IF iv_process_id IS NOT INITIAL.
      mv_process_id = iv_process_id.
*    ELSE.
*      "get the default process ID.
*
    ENDIF.

    "Load the file manager configuration
    SELECT SINGLE * INTO ms_file_transfer
    FROM zfile_transfer
    WHERE process_id = iv_process_id.

    SELECT SINGLE * INTO ms_file_server
    FROM zfile_server
    WHERE server_id = ms_file_transfer-server_id.

    RAISE EVENT is_used EXPORTING iv_module_id = mv_module_id iv_object_id = mv_object_id.
  ENDMETHOD.