  METHOD save.
    DATA:
          lv_rc TYPE sysubrc.

    CLEAR lv_rc.
    IF mv_flg_changed = abap_true.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Update the DB...'(i07).
      CLEAR mv_flg_changed.
      "Save header data.
      MODIFY zrun_header FROM ms_runtime.
      lv_rc = sy-subrc.
    ENDIF.
    rv_subrc = lv_rc.
  ENDMETHOD.