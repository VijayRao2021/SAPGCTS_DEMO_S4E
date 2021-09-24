  METHOD transfer_data.
    DATA:
          lv_line TYPE zdatm_file_ts_file_content.

    IF iv_in_memory = abap_false.
      IF is_open( ) = 0.
        TRANSFER iv_data TO mv_filename_full.
        rv_rc = sy-subrc.
      ELSE.
        rv_rc = 8.
      ENDIF.
    ELSE.
      lv_line = iv_data.
      APPEND lv_line TO mt_file_data.
      rv_rc = sy-subrc.
    ENDIF.
  ENDMETHOD.