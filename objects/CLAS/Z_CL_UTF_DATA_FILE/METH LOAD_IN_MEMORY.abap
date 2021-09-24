  METHOD load_in_memory.
    DATA:
      lv_line      TYPE string,
      lv_cnt_lines TYPE i.

    rv_rc = 0.
    IF mt_file_data[] IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 1 iv_type = 'I' iv_msg1 = 'Load file data in memory.'(i03).
      IF is_open( ) = 0.
        DO.
          READ DATASET mv_filename_full INTO lv_line.
          IF sy-subrc <> 0.
            EXIT.
          ENDIF.
          ADD 1 TO lv_cnt_lines.
          APPEND lv_line TO mt_file_data.
        ENDDO.
      ELSE.
        rv_rc = 8.
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 2 iv_type = 'E' iv_msg1 = 'Cannot load file in memory, because is not open.'(e06) iv_msg2 = lv_cnt_lines.
      ENDIF.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 2 iv_type = 'I' iv_msg1 = '&2 lines loaded.'(i04) iv_msg2 = lv_cnt_lines.
    ELSE.
      "Already in memory so return a warning.
      rv_rc = 4.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE' iv_level = 2 iv_type = 'W' iv_msg1 = 'Data are alredy loaded.'(w05).
    ENDIF.
  ENDMETHOD.