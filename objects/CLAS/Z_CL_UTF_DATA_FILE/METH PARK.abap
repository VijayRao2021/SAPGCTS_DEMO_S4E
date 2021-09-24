  METHOD park.
    DATA:
      lv_error_folder TYPE string,
      lv_error_name   TYPE string.

    rv_rc = 0.
    IF mo_file_manager IS BOUND.
      lv_error_folder = mo_file_manager->get_folder( 'ERROR' ).
      IF lv_error_folder IS NOT INITIAL.
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_PARK' iv_level = 0 iv_type = 'I' iv_msg1 = 'Start file parking.'(i14).
        lv_error_name = mo_file_manager->get_new_filename( iv_current_filename = mv_filename iv_folder = 'ERROR' ).
        rv_rc = move( iv_target_filename = lv_error_name iv_target_folder = lv_error_folder ).
        IF rv_rc <> 0.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_PARK' iv_level = 1 iv_type = 'E' iv_msg1 = 'Parking failed.'(e12).
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.