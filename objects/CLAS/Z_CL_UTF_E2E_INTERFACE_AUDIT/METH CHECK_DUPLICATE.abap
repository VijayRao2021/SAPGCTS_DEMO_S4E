************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD CHECK_DUPLICATE.
  DATA:
    lv_flg_idocs_ok TYPE flag,
    lr_interface    TYPE REF TO ts_interface,
    ls_finger_print TYPE ze2e_finger_prt,
    ls_idoc         TYPE zbc_audit_idoc_line,
    ls_idoc_status  TYPE bdidocstat, " INS for INC0577180
    lv_msg_cls      TYPE bdidocstat-msgid VALUE 'ZGLOBAL_MSG_CLS',  " INS for INC0577180
    lv_counter      TYPE i. " INS MAK-001 01.08.2018 INC0518279 FCDK955336


  LOOP AT mt_interfaces REFERENCE INTO lr_interface WHERE duplicate_control IS NOT INITIAL.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'Duplicate control on interface ID &2, msg Code/fct: &3/&4'(h04) iv_msg2 = lr_interface->interface_id iv_msg3 = lr_interface->mescod
                                   iv_msg4 = lr_interface->mesfct.
    "E2E duplicate control.
    IF lr_interface->unique_id IS NOT INITIAL.
      "it is an E2E interface so check if this interface has been already received
      SELECT SINGLE docnum INTO CORRESPONDING FIELDS OF ls_finger_print                          "$sst: #712
        FROM ze2e_finger_prt
        WHERE interface_id = lr_interface->interface_id AND
              mescod = lr_interface->mescod AND
              mesfct = lr_interface->mesfct AND
              finger_print = lr_interface->unique_id.
      IF sy-subrc = 0.
        READ TABLE lr_interface->idocs INTO ls_idoc WITH KEY docnum = ls_finger_print-docnum.
        IF sy-subrc <> 0.
          "this unique has been already received.
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = '=>Unique ID &2 has been already received for interface ID &3.'(e35) iv_msg2 = lr_interface->unique_id iv_msg3 = lr_interface->interface_id.

          "Park the idocs
          update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked ).

          "Remove the interface from the list.
          REFRESH lr_interface->idocs.
          DELETE mt_interfaces.
          CONTINUE.
        ELSE.
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'S' iv_msg1 = '=>Unique ID &2 is not yet received'(m34) iv_msg2 = lr_interface->unique_id.
        ENDIF.
      ELSE.
        "Unique Id not yet received so create the entry in the finger print table
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'S' iv_msg1 = '=>Unique ID &2 is not yet received'(m34) iv_msg2 = lr_interface->unique_id.
        CLEAR ls_finger_print.
        ls_finger_print-interface_id = lr_interface->interface_id.
        ls_finger_print-mescod = lr_interface->mescod.
        ls_finger_print-mesfct = lr_interface->mesfct.
        ls_finger_print-finger_print = lr_interface->unique_id.
        ls_finger_print-finger_print_type = 'U'.
        READ TABLE lr_interface->idocs INTO ls_idoc INDEX 1.
        ls_finger_print-docnum = ls_idoc-docnum.
        ls_finger_print-receiving_date = sy-datum.
        INSERT ze2e_finger_prt FROM ls_finger_print.
      ENDIF.
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Duplicate Idoc check...'(m36).
    "Check each idocs.
    lv_flg_idocs_ok = abap_true.
    LOOP AT lr_interface->idocs INTO ls_idoc.
      IF ( ls_idoc-idoc->is_already_received( ) = 8 ).
        "idoc already received => park it.
*          ls_idoc-idoc->set_status( zetoe_idoc_status_parked ). " DEL for INC0577180
** -> Start of changes for INC0577180
** Change IDOC status to 51 and populate error message according to INC0577180 requirement.
*        CLEAR: ls_idoc_status.
*        ls_idoc_status-msgty = 'E'.
*        ls_idoc_status-msgid = lv_msg_cls.
*        ls_idoc_status-msgno = '002'.
*        ls_idoc_status-msgv1 = ls_idoc-docnum.
*        ls_idoc_status-msgv2 = ls_finger_print-docnum.
*        ls_idoc_status-msgv3 = ls_finger_print-receiving_date.
*        ls_idoc-idoc->set_status( iv_new_status = zetoe_idoc_status_error is_idoc_status = ls_idoc_status ).
** -> End of changes for INC0577180
        lv_flg_idocs_ok = abap_false.
***    BOI MAK-001 01.08.2018 INC0518279 FCDK955336
      ADD 1 TO lv_counter.
        IF lv_counter = 1000.
          CALL FUNCTION 'DEQUEUE_ALL'.
          CLEAR lv_counter.
        ENDIF.
***    EOI MAK-001 01.08.2018 INC0518279 FCDK955336
      ENDIF.
    ENDLOOP.
    IF lv_flg_idocs_ok = abap_true.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 2 iv_type = 'S' iv_msg1 = '=>All idocs are ok...'(m33).
    ENDIF.
  ENDLOOP.

  "Remove the non E2E entries for the rest of processing.
  LOOP AT mt_interfaces REFERENCE INTO lr_interface WHERE unique_id IS INITIAL.
    REFRESH lr_interface->idocs.
    DELETE mt_interfaces.
  ENDLOOP.

ENDMETHOD.