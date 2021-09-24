  METHOD LOOP.
    DATA:
          ls_content_line TYPE zdatm_container_ts_content.

    IF mv_loop_index > mv_size.
    mv_loop_index = 1.
    CLEAR ro_data_object.
    ELSE.
    READ TABLE mt_content INTO ls_content_line INDEX mv_loop_index.
    IF sy-subrc = 0.
    ro_data_object = ls_content_line-object.
    ADD 1 TO mv_loop_index.
    ELSE.
    mv_loop_index = 1.
    CLEAR ro_data_object.
    ENDIF.
    ENDIF.

    ENDMETHOD.