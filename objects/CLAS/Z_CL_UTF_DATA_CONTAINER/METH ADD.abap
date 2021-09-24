METHOD ADD.
  DATA:
        ls_content_line TYPE zdatm_container_ts_content.

  mv_loop_index = 1.
  CLEAR ls_content_line.
  ls_content_line-object = io_data_object.
  APPEND ls_content_line TO mt_content.
  add 1 to mv_size.
  ENDMETHOD.