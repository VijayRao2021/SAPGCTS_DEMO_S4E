  METHOD folder_check.
    CONSTANTS:lc_tstfldr TYPE sxpgcolist-name VALUE 'ZFILE_TEST_FOLDER',
              lc_crtfldr TYPE sxpgcolist-name VALUE 'ZFILE_CREAT_FOLDER'.

    STATICS st_checked_folders TYPE STANDARD TABLE OF string.

    DATA:
      lv_path       TYPE string,
      lv_subfolder  TYPE string,
      lt_subfolders TYPE STANDARD TABLE OF string.

    lv_path = '/'.

    "split the full path into subfolders.
    SPLIT iv_subfolder AT '/' INTO TABLE lt_subfolders.

    "Check if each subfolder exist.
    LOOP AT lt_subfolders INTO lv_subfolder WHERE table_line IS NOT INITIAL.
      CONCATENATE lv_path lv_subfolder '/' INTO lv_path.

      READ TABLE st_checked_folders TRANSPORTING NO FIELDS WITH KEY table_line = lv_path.
      IF sy-subrc <> 0.
        APPEND lv_path TO st_checked_folders.

        RAISE EVENT send_log EXPORTING iv_group = 'FOLDER_CHECK' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if folder &2 exists.'(i06) iv_msg2 = lv_path.
        IF ( z_cl_core_tool_system=>call_system_command( iv_command_name = lc_tstfldr
                                                         iv_parameter1   = lv_path ) <> 0 ).


          RAISE EVENT send_log EXPORTING iv_group = 'FOLDER_CREAT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Creation of folder &2.'(i07)
                                         iv_msg2 = lv_path.

          z_cl_core_tool_system=>call_system_command( iv_command_name = lc_crtfldr
                                                      iv_parameter1   = lv_path ).
        ENDIF.

      ENDIF.

    ENDLOOP.
  ENDMETHOD.