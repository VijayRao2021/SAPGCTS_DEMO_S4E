METHOD UPDATE_IDOCS_STATUS.
  DATA:
    lv_counter TYPE i,
    lr_idoc    TYPE REF TO zbc_audit_idoc_line.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = '&2: Update idocs status to &3.'(m17) iv_msg2 = ir_interface->unique_id iv_msg3 = iv_new_status.
  LOOP AT ir_interface->idocs REFERENCE INTO lr_idoc.
*    lr_idoc->idoc->set_status( iv_new_status ).  " DEL for INC0577180
    lr_idoc->idoc->set_status( iv_new_status = iv_new_status is_idoc_status = is_idoc_status  ). " INS for INC0577180
    ADD 1 TO lv_counter.
    IF lv_counter = 1000.
      CALL FUNCTION 'DEQUEUE_ALL'.
      CLEAR lv_counter.
    ENDIF.
  ENDLOOP.
ENDMETHOD.