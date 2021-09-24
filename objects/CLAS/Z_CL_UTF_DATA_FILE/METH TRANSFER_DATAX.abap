  METHOD transfer_datax.
*    IF iv_in_memory = abap_false.
    IF is_open( ) = 0.
      TRANSFER iv_datax TO mv_filename_full.
      rv_rc = sy-subrc.
    ELSE.
      rv_rc = 8.
    ENDIF.
*    ELSE.
*      ls_line = iv_data.
*      APPEND ls_line TO mt_file_data.
*      rv_rc = sy-subrc.
*    ENDIF.
  ENDMETHOD.