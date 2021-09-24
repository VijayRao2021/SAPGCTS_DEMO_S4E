****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 19.02.2016 ! GAP-2270: Get duplicate control indicator for E2E and non E2E interfaces*
* GAP-2270   !            !                                                                        *
****************************************************************************************************

METHOD LOAD_NEW_IDOCS.
  DATA:
    lv_cnt_idocs         TYPE i,
    lv_cnt_auditable     TYPE i,
    lv_cnt_unique_id     TYPE i,

    ls_idoc              TYPE edidc,
    ls_interface         TYPE ts_interface,
    ls_audit_segment     TYPE z1zaudit,
    lr_interface         TYPE REF TO ts_interface,
    ls_control_record    TYPE edidc, "MC-001
    ls_duplicate_control TYPE ze2e_dup_control,             "GAP-2270+

    ls_idoc_line         TYPE zbc_audit_idoc_line,
    lt_idocs             TYPE edidc_tt.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'Loading new Idocs...'(m01).
  lt_idocs[] = it_idocs[].
  SORT lt_idocs BY docnum DESCENDING.

*  LOOP AT it_idocs INTO ls_idoc. "INC0829526-08/6/19++Commented
  LOOP AT lt_idocs INTO ls_idoc. "INC0829526-08/6/19++Line Added
    ADD 1 TO lv_cnt_idocs.
    "Group Idocs by interface ID
    CREATE OBJECT ls_idoc_line-idoc
      EXPORTING
        is_edidc = ls_idoc.
    IF ( ls_idoc_line-idoc->is_auditable( ) = 0 ).
      "if the Idoc has an audit segment...
      ADD 1 TO lv_cnt_auditable.
      "get the corresponding unique ID
      ls_audit_segment = ls_idoc_line-idoc->get_interface_audit_control( ).
      ls_idoc_line-docnum = ls_idoc-docnum.
      "Find the idocs group with this unique id if it exists...
      IF lr_interface IS INITIAL OR lr_interface->unique_id <> ls_audit_segment-unique_id.
        READ TABLE mt_interfaces REFERENCE INTO lr_interface WITH KEY unique_id = ls_audit_segment-unique_id.
        IF sy-subrc <> 0.
          "...else creates it.
          ADD 1 TO lv_cnt_unique_id.
          ls_control_record = ls_idoc_line-idoc->get_control_record( ). "MC-001
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Find E2E interface &2, Msg Code/fct: &3/&4, UUID &5'(m32) iv_msg2 = ls_audit_segment-interface_id iv_msg3 = ls_control_record-mescod
                                         iv_msg4 = ls_control_record-mesfct iv_msg5 = ls_audit_segment-unique_id. "GAP-2270+
          CLEAR ls_interface.
          ls_interface-unique_id = ls_audit_segment-unique_id.
          ls_interface-interface_id = ls_audit_segment-interface_id.
          ls_interface-audit_data_received = ls_audit_segment.
          ls_interface-audit_data_calculated-interface_id = ls_interface-audit_data_received-interface_id.
          ls_interface-audit_data_calculated-unique_id = ls_interface-audit_data_received-unique_id.
          ls_interface-mescod = ls_control_record-mescod.  "MC-001
          ls_interface-mesfct = ls_control_record-mesfct.  "MC-001
*-Begin of GAP-2270+
          CLEAR ls_duplicate_control.
          READ TABLE mt_duplicate_control_int INTO ls_duplicate_control WITH KEY interface_id = ls_interface-interface_id mescod = ls_interface-mescod mesfct = ls_interface-mesfct.
          IF sy-subrc <> 0.
            READ TABLE mt_duplicate_control_int INTO ls_duplicate_control WITH KEY interface_id = ls_interface-interface_id mescod = space mesfct = space.
          ENDIF.
          IF ls_duplicate_control-duplicate_control IS NOT INITIAL.
            RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Duplicate control is activated.'(m31).
          ENDIF.
          ls_interface-duplicate_control = ls_duplicate_control-duplicate_control.
*-End of GAP-2270+
          APPEND ls_interface TO mt_interfaces.
          READ TABLE mt_interfaces REFERENCE INTO lr_interface WITH KEY unique_id = ls_audit_segment-unique_id.
          IF mv_mode = c_mode_analysis.
            IF ( ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_start_analysis iv_comment = zetoe_stepid_start_analysis_c ) = 0 ).
              IF ( ws_send_audit_data( iv_step_id = zetoe_stepid_registration iv_comment = zetoe_stepid_registration_c is_audit_data = lr_interface->audit_data_received ) <> 0 ).
                lr_interface->error_code = mv_error_ws_conn_failed.
              ENDIF.
            ELSE.
              lr_interface->error_code = mv_error_ws_conn_failed.
            ENDIF.
          ENDIF.
        ELSEIF lr_interface->audit_data_received-status = 0 AND ls_audit_segment-status <> 0.
          lr_interface->audit_data_received = ls_audit_segment.
        ENDIF.
      ELSEIF      lr_interface->audit_data_received-status = 0 AND ls_audit_segment-status <> 0.
        lr_interface->audit_data_received = ls_audit_segment.
      ENDIF.
      "Assign the idoc to the idocs group.
      APPEND ls_idoc_line TO lr_interface->idocs.
*-Begin of GAP-2270+
    ELSE.
      "Dedicated control for non E2E interfaces.
      ls_control_record = ls_idoc_line-idoc->get_control_record( ).
      "Check if this non E2E interface is already registered
      READ TABLE mt_interfaces REFERENCE INTO lr_interface WITH KEY unique_id = space mescod = ls_control_record-mescod mesfct = ls_control_record-mesfct.
      IF sy-subrc <> 0.
        "...else creates it.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Find Non E2E interface Msg Code/fct: &2/&3, Mestyp: &4'(m37) iv_msg2 = ls_control_record-mescod iv_msg3 = ls_control_record-mesfct
                                       iv_msg4 = ls_control_record-mestyp..
        CLEAR ls_interface.
        ls_interface-mescod = ls_control_record-mescod.
        ls_interface-mesfct = ls_control_record-mesfct.
        CLEAR ls_duplicate_control.
        IF ls_control_record-mescod IS NOT INITIAL AND ls_control_record-mesfct IS NOT INITIAL.
          READ TABLE mt_duplicate_control_int INTO ls_duplicate_control WITH KEY interface_id = space mescod = ls_interface-mescod mesfct = ls_interface-mesfct.
          IF sy-subrc <> 0.
            READ TABLE mt_duplicate_control_int INTO ls_duplicate_control WITH KEY interface_id = space mestyp = ls_control_record-mestyp.
            IF sy-subrc = 0.
              ls_interface-interface_id = ls_control_record-mestyp.
            ENDIF.
          ENDIF.
        ELSE.
          READ TABLE mt_duplicate_control_int INTO ls_duplicate_control WITH KEY interface_id = space mestyp = ls_control_record-mestyp.
          IF sy-subrc = 0.
            ls_interface-interface_id = ls_control_record-mestyp.
          ENDIF.
        ENDIF.
        IF ls_duplicate_control-duplicate_control IS NOT INITIAL.
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Duplicate control is activated.'(m31).
        ENDIF.
        ls_interface-duplicate_control = ls_duplicate_control-duplicate_control.
        APPEND ls_interface TO mt_interfaces.
        READ TABLE mt_interfaces REFERENCE INTO lr_interface WITH KEY unique_id = space mescod = ls_interface-mescod mesfct = ls_interface-mesfct.
      ENDIF.

      "Keep the idoc only if we want to do the duplicate control on this interface
      IF lr_interface->duplicate_control IS NOT INITIAL.
        APPEND ls_idoc_line TO lr_interface->idocs.
      ENDIF.
*-End of GAP-2270+
    ENDIF.
  ENDLOOP.
  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'I' iv_msg1 = 'Idocs: &2, Auditables: &3, Unique ID: &4'(m02) iv_msg2 = lv_cnt_idocs iv_msg3 = lv_cnt_auditable iv_msg4 = lv_cnt_unique_id.
ENDMETHOD.