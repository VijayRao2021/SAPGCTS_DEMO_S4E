  METHOD lock_generic_entry.
    DATA:
          lv_objname TYPE rsdeo-objname.

    CLEAR: lv_objname.
    rv_subrc = 0.
    CONCATENATE iv_part1 iv_part2 iv_part3 iv_part4 iv_part5 INTO lv_objname.
    RAISE EVENT send_log EXPORTING iv_group = 'LOCK_UTILITY' iv_level = 0 iv_type = 'I' iv_msg1 = 'Try to lock entry &2.'(i01) iv_msg2 = lv_objname.

    DO.
      CALL FUNCTION 'RS_DD_ENQUEUE'
        EXPORTING
          objtype        = 'ENQU'
          objname        = lv_objname
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
      rv_subrc = sy-subrc.
      IF rv_subrc <> 0 AND iv_wait = 'X'.
        IF sy-batch <> 'X'.
          CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
            EXPORTING
              text = text-w01.
        ENDIF.
        RAISE EVENT send_log EXPORTING iv_group = 'LOCK_UTILITY' iv_level = 1 iv_type = 'W' iv_msg1 = 'Lock entry already exists. Wait until it is released...'(w01).
        WAIT UP TO 1 SECONDS.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
  ENDMETHOD.