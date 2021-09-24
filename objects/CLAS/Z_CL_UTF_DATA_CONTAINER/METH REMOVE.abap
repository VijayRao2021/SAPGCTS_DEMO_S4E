METHOD remove.
  DATA:
        ls_content_line TYPE zdatm_container_ts_content.

  mv_loop_index = 1.
  READ TABLE mt_content INTO ls_content_line WITH KEY object = io_data_object.
  IF sy-subrc = 0.
  DELETE mt_content INDEX sy-tabix.
  ENDIF.
  SUBTRACT 1 FROM mv_size.
  ENDMETHOD.