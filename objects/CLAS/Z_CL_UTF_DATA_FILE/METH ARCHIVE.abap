  METHOD archive.
    DATA:
      lv_archive_folder TYPE string,
      lv_archive_name   TYPE string.

    rv_rc = 0.
    IF mo_file_manager IS BOUND.
      lv_archive_folder = mo_file_manager->get_folder( 'ARCHIVE' ).
      IF lv_archive_folder IS NOT INITIAL.
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_ARCHIVE' iv_level = 0 iv_type = 'I' iv_msg1 = 'Start file archiving'(i13).
        lv_archive_name = mo_file_manager->get_new_filename( iv_current_filename = mv_filename iv_folder = 'ARCHIVE' ).
        rv_rc = move( iv_target_filename = lv_archive_name iv_target_folder = lv_archive_folder ).
        IF rv_rc <> 0.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_ARCHIVE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Archiving failed.'(e11).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.