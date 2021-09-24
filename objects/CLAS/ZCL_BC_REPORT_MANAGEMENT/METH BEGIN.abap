method BEGIN.
  DATA:
        lv_size TYPE i,
        ls_block TYPE ts_block_def.

  READ TABLE t_block INTO ls_block WITH KEY name = iv_block_name.
  IF sy-subrc = 0.
    RAISE already_exists.
  ENDIF.

  CLEAR ls_block.
  ls_block-name = iv_block_name.
  ls_block-typeofblock = c_list_block.
  lv_size = update_list( ).
  ls_block-begin_idx = lv_size + 1.
  APPEND ls_block TO t_block.
endmethod.