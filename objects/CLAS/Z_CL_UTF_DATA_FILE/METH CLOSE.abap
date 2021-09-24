  METHOD close.
    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 1 iv_type = 'I' iv_msg1 = 'Close the file &2.'(i01) iv_msg2 = mv_filename.

    rv_rc = 0.
    IF is_open( ) = 0.
      CLOSE DATASET mv_filename_full.
      IF sy-subrc <> 0.
        rv_rc = sy-subrc.
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot close the file &2, RC = &3.'(e01) iv_msg2 = mv_filename iv_msg3 = sy-subrc.
      ELSE.
        mv_is_open = abap_false.
      ENDIF.
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 1 iv_type = 'W' iv_msg1 = 'File &2 is not open.'(w01) iv_msg2 = mv_filename.
      rv_rc = 8.
    ENDIF.
  ENDMETHOD.