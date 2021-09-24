METHOD end.
  DATA:
        lv_size TYPE i,
        ls_block TYPE ts_block_def.

  READ TABLE t_block INTO ls_block WITH KEY name = iv_block_name.
  IF sy-subrc = 0 AND ls_block-end_idx IS INITIAL.
    lv_size = update_list( ).
    ls_block-end_idx = lv_size.
    MODIFY t_block FROM ls_block TRANSPORTING end_idx WHERE name = iv_block_name.
  ENDIF.
ENDMETHOD.