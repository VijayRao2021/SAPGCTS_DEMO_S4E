  METHOD link.
    DATA:
            ls_link TYPE zdatm_ts_link.

    ls_link-child_id = iv_dataset->get_object_id( ).
    ls_link-child_ref = iv_dataset.
    ls_link-parent_id = get_object_id( ).
    APPEND ls_link TO mt_links.
    ADD 1 TO mv_cnt_links.
    mv_loop_links_index = 1.
  ENDMETHOD.