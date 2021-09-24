  METHOD transfer_file_sftp.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 09/01/2019 ! GAP-3345 add the SFTP protocol to the framework: creation of the method*
* GAP-3345   !            !                                                                        *
****************************************************************************************************
    DATA:
      lv_full_file_name TYPE string,
      lv_file_name      TYPE string.

    rv_rc = 0.
    lv_file_name = io_file_object->get_file_name( iv_full_filename = abap_false ).
    RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 1 iv_type = 'I' iv_msg1 = 'Transfer file &2 by SFTP.'(i01) iv_msg2 = lv_file_name.
    RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'I' iv_msg1 = 'Server: &2.'(i02) iv_msg2 = ms_file_server-hostname.
    RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'I' iv_msg1 = 'User: &2.'(i03) iv_msg2 = ms_file_server-username.
    RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'I' iv_msg1 = 'Target folder: &2.'(i04) iv_msg2 = ms_file_transfer-target_folder.
    IF ms_file_transfer-physical_transfer IS INITIAL.
      "If file is in memory only then, write it into a temporary folder.
      io_file_object->create_from_memory( ).
    ENDIF.

    "At this stage of the code, the file is always on SAP application server.
    lv_full_file_name = io_file_object->get_file_name( iv_full_filename = abap_true ).

*    "Check if the Server Fingerprint is already initialized. "GAP-3397: no more required as the script is able to self initialize
*    IF ms_file_server-fingerprint_initialized = abap_false.
*      "It seems not, then call the initialization OS command
*      rv_rc = z_cl_core_tool_system=>call_system_command( iv_command_name = 'ZFILE_TRANS_FINGER' iv_parameter1 = ms_file_server-hostname ).
*      IF rv_rc = 0.
*        "Initialization is done, raise a message...
*        RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'S' iv_msg1 = 'Server &2 Finger Print successfully initialized!'(s02) iv_msg2 = ms_file_server-hostname.
*        "... and update the table for next time.
*        ms_file_server-fingerprint_initialized = abap_true.
*        UPDATE zfile_server FROM ms_file_server.
*      ELSE.
*        "Cannot initialize...
*        RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'E' iv_msg1 = 'Error during Server &2 Finger Print initialization!'(e02) iv_msg2 = ms_file_server-hostname.
*      ENDIF.
*
*    ENDIF.
    "Call the OS script to do the transfer thanks to OS program
    rv_rc = z_cl_core_tool_system=>call_system_command( iv_command_name = 'ZFILE_TRANS_SFTP' iv_parameter1 = ms_file_server-hostname iv_parameter2 = ms_file_server-username
                                                        iv_parameter3 = ms_file_server-password iv_parameter4 = lv_full_file_name iv_parameter5 = ms_file_transfer-target_folder ).

    IF rv_rc = 0.
      RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'S' iv_msg1 = 'Transfer of file &2 successfully done.'(s01) iv_msg2 = lv_file_name.
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_SFTP' iv_level = 2 iv_type = 'E' iv_msg1 = 'Error during the transfer of file &2.'(e01) iv_msg2 = lv_file_name.
    ENDIF.

    IF ms_file_transfer-physical_transfer IS INITIAL.
      "Delete the temporary file created above.
      io_file_object->delete(  ).
    ENDIF.

  ENDMETHOD.