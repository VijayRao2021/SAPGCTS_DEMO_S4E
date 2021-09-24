  METHOD unlock_generic_entry.
    DATA:
          lv_objname TYPE rsdeo-objname.

    CLEAR: lv_objname.
    CONCATENATE iv_part1 iv_part2 iv_part3 iv_part4 iv_part5 INTO lv_objname.
    RAISE EVENT send_log EXPORTING iv_group = 'LOCK_UTILITY' iv_level = 0 iv_type = 'I' iv_msg1 = 'Unlock entry &2.'(i02) iv_msg2 = lv_objname.

    CALL FUNCTION 'RS_DD_DEQUEUE'
      EXPORTING
        objtype = 'ENQU'
        objname = lv_objname.
  ENDMETHOD.