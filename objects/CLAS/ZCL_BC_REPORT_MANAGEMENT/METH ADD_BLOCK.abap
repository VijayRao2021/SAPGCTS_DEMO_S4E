METHOD add_block.
  DATA:
    lv_size  TYPE i,
    ls_block TYPE ts_block_def.


  READ TABLE t_block INTO ls_block WITH KEY name = iv_block_name.
  IF sy-subrc = 0.
    IF iv_replace = 'X'.
      DELETE t_block_datas FROM ls_block-begin_idx TO ls_block-end_idx.
      DELETE t_block WHERE name = iv_block_name.
    ELSE.
      RAISE already_exists.
    ENDIF.
  ENDIF.

*Create the block line
  CLEAR ls_block.
  ls_block-name = iv_block_name.
  ls_block-endlinetype = iv_endlinetype.
  ls_block-typeofblock = c_datas_block.
  DESCRIBE TABLE t_block_datas LINES lv_size.
  IF it_datas_block[] IS INITIAL.
    ls_block-begin_idx = 0.
    ls_block-end_idx = 0.
  ELSE.
    ls_block-begin_idx = lv_size + 1.
    DESCRIBE TABLE it_datas_block LINES lv_size.
    ls_block-end_idx = ls_block-begin_idx + lv_size - 1.
  ENDIF.

  APPEND ls_block TO t_block.

*    *Add the datas to the global datas table
  APPEND LINES OF it_datas_block TO t_block_datas.

ENDMETHOD.