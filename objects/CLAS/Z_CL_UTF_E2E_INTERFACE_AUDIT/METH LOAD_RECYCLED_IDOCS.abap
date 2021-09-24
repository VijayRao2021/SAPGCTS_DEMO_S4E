****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 19.02.2016 ! GAP-2270: Get duplicate control indicator for E2E and non E2E interfaces*
* GAP-2270   !            !                                                                        *
* GUPTEY     ! 18/5/2019  ! INC0829526-Changes for adding global parameter MT_INTERFACE_ID_TO_CHECK*
****************************************************************************************************
METHOD LOAD_RECYCLED_IDOCS.
  DATA:
        lv_cnt_idocs TYPE i,
        lv_cnt_unique_id TYPE i,

*        ls_idoc TYPE edidc,
        ls_interface TYPE ts_interface,
        lr_interface TYPE REF TO ts_interface,
        ls_control_record  type edidc, "MC-001
        ls_duplicate_control TYPE ze2e_dup_control,         "GAP-2270+

        ls_idoc_line TYPE zbc_audit_idoc_line,
        ls_audit_segment TYPE z1zaudit,

        ls_recycle TYPE zbc_audit_idocs,
        lt_recycle TYPE STANDARD TABLE OF zbc_audit_idocs.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'Loading Idocs from the table ZBC_AUDIT_IDOCS...'(m03).
  IF mv_mode = c_mode_analysis.
    SELECT * INTO TABLE lt_recycle
      FROM zbc_audit_idocs
      WHERE error_code > zetoe_error_last_preproc "#EC CI_NOFIELD
      AND interface_id in mt_interface_id_to_check.  "INC0829526-18/5/19++
  ELSE.
    SELECT * INTO TABLE lt_recycle
      FROM zbc_audit_idocs
      WHERE error_code <= zetoe_error_last_preproc "#EC CI_NOFIELD
      AND interface_id in mt_interface_id_to_check. "INC0829526-18/5/19++
  ENDIF.
  "Group Idocs by interface ID
  SORT lt_recycle BY unique_id docnum DESCENDING.
  LOOP AT lt_recycle INTO ls_recycle.
    ADD 1 TO lv_cnt_idocs.
    "Create the IDOC object
    CREATE OBJECT ls_idoc_line-idoc
      EXPORTING
        iv_docnum = ls_recycle-docnum.
    IF ( ls_idoc_line-idoc->is_auditable( ) = 0 ).
      ls_idoc_line-docnum = ls_recycle-docnum.
      ls_audit_segment = ls_idoc_line-idoc->get_interface_audit_control( ).
      IF lr_interface IS INITIAL OR lr_interface->unique_id <> ls_recycle-unique_id.
        "Assign the IDOC to the Unique ID
        READ TABLE mt_interfaces REFERENCE INTO lr_interface WITH KEY unique_id = ls_recycle-unique_id.
        IF sy-subrc <> 0.
          ADD 1 TO lv_cnt_unique_id.
          ls_control_record = ls_idoc_line-idoc->get_control_record( ). "MC-001
                    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Reload E2E interface &2, Msg Code/fct: &3/&4, UUID &5'(m35) iv_msg2 = ls_audit_segment-interface_id iv_msg3 = ls_control_record-mescod
                                         iv_msg4 = ls_control_record-mesfct iv_msg5 = ls_audit_segment-unique_id."GAP-2270+
          CLEAR ls_interface.
          ls_interface-unique_id = ls_recycle-unique_id.
          ls_interface-interface_id = ls_recycle-interface_id.
          ls_interface-audit_data_received = ls_audit_segment.
          ls_interface-audit_data_calculated-interface_id = ls_interface-audit_data_received-interface_id.
          ls_interface-audit_data_calculated-unique_id = ls_interface-audit_data_received-unique_id.
          ls_interface-recycling = abap_true.
          ls_interface-recycling_erdat = ls_recycle-erdat.
          ls_interface-recycling_erzeit = ls_recycle-erzeit.
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
          READ TABLE mt_interfaces REFERENCE INTO lr_interface WITH KEY unique_id = ls_recycle-unique_id.
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
      ELSEIF lr_interface->audit_data_received-status = 0 AND ls_audit_segment-status <> 0.
        lr_interface->audit_data_received = ls_audit_segment.
      ENDIF.
      APPEND ls_idoc_line TO lr_interface->idocs.
    ENDIF.
  ENDLOOP.
  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'I' iv_msg1 = 'Idocs: &2, Auditables: &3, Unique ID: &4'(m02) iv_msg2 = lv_cnt_idocs iv_msg3 = lv_cnt_idocs iv_msg4 = lv_cnt_unique_id.
ENDMETHOD.