  METHOD loop_links.
    DATA:
          ls_link TYPE zdatm_ts_link.

    IF mv_loop_links_index > mv_cnt_links.
      mv_loop_links_index = 1.
      CLEAR ro_dataset.
    ELSE.
      READ TABLE mt_links INTO ls_link INDEX mv_loop_links_index.
      IF sy-subrc = 0.
        ro_dataset = ls_link-child_ref.
        ADD 1 TO mv_loop_links_index.
      ELSE.
        mv_loop_links_index = 1.
        CLEAR ro_dataset.
      ENDIF.
    ENDIF.
  ENDMETHOD.