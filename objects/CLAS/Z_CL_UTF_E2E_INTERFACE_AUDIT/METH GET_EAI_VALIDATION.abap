****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D.CRESSON  !            ! GAP-2019: add wait time for -1 and 1 status if all idocs are not there *
* GAP2019    !            ! when last idoc is received                                             *
* GUPTEY     ! 18/5/2019  ! INC0829526-Changes for adding global parameter MT_INTERFACE_ID_TO_CHECK*
****************************************************************************************************
METHOD GET_EAI_VALIDATION.
*-Begin of GAP2019+
  CONSTANTS:
    lc_close TYPE string VALUE 'Close',                     "#EC NOTEXT
    lc_wait  TYPE string VALUE 'Wait'.                      "#EC NOTEXT
*-End of GAP2019+

  DATA:
    lv_subrc          TYPE i,
    lv_output_counter TYPE i,
    lr_interface      TYPE REF TO ts_interface,
    lv_mode           TYPE string,
    ls_idoc_status    TYPE bdidocstat, " INS for INC0577180
    lv_msg_cls        TYPE bdidocstat-msgid VALUE 'ZGLOBAL_MSG_CLS'.  " INS for INC0577180

*  DATA : l_idocs_equal TYPE abap_bool. "INC0829526-Commented-12/7/2019
  LOOP AT mt_interfaces REFERENCE INTO lr_interface.
*    CHECK lr_interface->interface_id IN it_interface_id.  "INC0829526-18/5/19++Commented
    CHECK lr_interface->interface_id IN mt_interface_id_to_check. "it_interface_id. "INC0829526-18/5/19++
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'Get the interface &3/&2 validation...'(h01) iv_msg2 = lr_interface->unique_id iv_msg3 = lr_interface->audit_data_received-interface_id.
*-> Start of changes for INC0577180
    DESCRIBE TABLE lr_interface->idocs LINES lr_interface->audit_data_calculated-documents_counter.
    CONDENSE lr_interface->audit_data_calculated-documents_counter NO-GAPS.
*SOC-INC0829526-Commented-12/7/2019
*    IF lr_interface->audit_data_received-documents_counter = lr_interface->audit_data_calculated-documents_counter.
*      l_idocs_equal = abap_true.
*    ELSE.
*      l_idocs_equal = abap_false.
*    ENDIF.
*EOC-INC0829526-Commented-12/7/2019
*-> End of changes for INC0577180
    CASE lr_interface->audit_data_received-status.
      WHEN -1.
        "EAI failed, so park the idocs.
*-Begin of GAP2019+
        "But first check if all expected idocs are there to park them together
        lr_interface->audit_data_received-documents_counter = lr_interface->audit_data_received-output_counter."
        IF ( check_number_documents( lr_interface ) = 0 ).
          "They are all there then we can close
          lv_mode = lc_close.
        ELSE.
* if expected and received idoc counters don't match it may be because the last idoc arrived before the others
          "Check if wait time has expired.
          IF ( is_wait_time_expired( lr_interface ) <> 0 ).
            "Park temporarly the idocs
            lv_mode = lc_wait.
          ELSE.
            "stop waiting and close
            lv_mode = lc_close.
          ENDIF.
        ENDIF.
*-End of GAP2019+
        IF lv_mode = lc_close.                              "GAP2019+
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 0 iv_type = 'W' iv_msg1 = '&2/&3: EAI reports failure: park the idocs.'(e12) iv_msg2 = lr_interface->interface_id iv_msg3 = lr_interface->unique_id.
          ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_get_validation_c ).
          ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_park_idoc_c ).
* -> Start of changes for INC0577180
*           update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked ). " DEL forINC0577180
* Change IDOC status to 51 and populate error message according to INC0577180 requirement.
          CLEAR: ls_idoc_status.
          ls_idoc_status-msgty = 'E'.
          ls_idoc_status-msgid = lv_msg_cls.
          ls_idoc_status-msgno = '003'.
          ls_idoc_status-msgv1 = lr_interface->audit_data_received-interface_id.
          ls_idoc_status-msgv2 = lr_interface->unique_id.
          update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked is_idoc_status = ls_idoc_status ).
* -> End of changes for INC0577180
          CLEAR lr_interface->error_code.
          ws_create( iv_interface_id = lr_interface->interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_analysis_finish iv_comment = zetoe_stepid_analysis_finish_c ).
*-Begin of GAP2019+
        ELSE.
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'W' iv_msg1 = 'EAI is still running: move idocs in wait status.'(w01).
          update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_wait ).
          lr_interface->error_code = zetoe_error_eai_running.
        ENDIF.
*-End of GAP2019+
      WHEN 0.
        "EAI is still running
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'W' iv_msg1 = 'EAI is still running: move idocs in wait status.'(w01).
        "Check how much SAP is waiting for the next idoc
*-Begin of GAP2019-
*        CALL FUNCTION 'SD_CALC_DURATION_FROM_DATETIME'
*          EXPORTING
*            i_date1          = lr_interface->recycling_erdat
*            i_time1          = lr_interface->recycling_erzeit
*            i_date2          = sy-datum
*            i_time2          = sy-uzeit
*          IMPORTING
*            e_tdiff          = lv_time_diff
*          EXCEPTIONS
*            invalid_datetime = 1
*            OTHERS           = 2.
*        IF ( sy-subrc = 0 AND lv_time_diff >= 10000 ).
*-End of GAP2019-
        IF ( is_wait_time_expired( lr_interface ) = 0 ).    "GAP2019+
          "Check with the audit framework is the EAI process is fine.
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'W' iv_msg1 = '&2/&3: 1 hour since the last idoc, check with the audit framework.'(e17) iv_msg2 = lr_interface->interface_id iv_msg3 = lr_interface->unique_id.
          ws_get_eai_validation_status( EXPORTING iv_interface_id = lr_interface->interface_id iv_unique_id = lr_interface->unique_id IMPORTING ev_subrc = lv_subrc ev_output_counter = lv_output_counter ).
          lr_interface->audit_data_received-output_counter = lv_output_counter.
          CONDENSE lr_interface->audit_data_received-output_counter NO-GAPS.
          IF lv_subrc = 0.
            RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'I' iv_msg1 = 'Audit framework said ok.'(e18).
            "Audit framework says EAI is fine so continue the check
            CLEAR lr_interface->error_code.
            ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_get_validation_c ).
**            IF lr_interface->interface_id = g_interface_id. "INC0829526-Commented-12/7/2019
            lr_interface->audit_data_received-documents_counter = lr_interface->audit_data_received-output_counter.
*              l_idocs_equal = abap_true. "INC0829526-Commented-12/7/2019
*            ENDIF.                       "INC0829526-Commented-12/7/2019
            IF ( check_number_documents( lr_interface ) = 0 ). " AND l_idocs_equal IS NOT INITIAL ). "INC0829526-Commented-12/7/2019
              "Release the idocs
              update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_ready ).
              lr_interface->error_code = zetoe_error_ready_4_analysis.
            ELSE.
              "Park the idocs and finish the process
              update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked ).
              ws_create( iv_interface_id = lr_interface->interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_analysis_finish iv_comment = zetoe_stepid_analysis_finish_c ).
            ENDIF.
          ELSE.
            "Audit Framwork confirm there is a problem on EAI side. Park the idocs and close the process
            update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked ).
            CLEAR lr_interface->error_code.
            RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 0 iv_type = 'E' iv_msg1 = '&2/&3: 1 hour since the last idoc, SAP stop waiting the EAI confirmation and the idocs are parked.'(e15) iv_msg2 = lr_interface->interface_id
                                           iv_msg3 = lr_interface->unique_id.
            ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_get_validation_c ).
            ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_stop_wait_c ).
            ws_validation_check( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id iv_comment = zetoe_stepid_stop_wait_c iv_property_name = zetoe_property_idoc_counter
                                 iv_status = zetoe_status_failed ).
            ws_create( iv_interface_id = lr_interface->interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_analysis_finish iv_comment = zetoe_stepid_analysis_finish_c ).
          ENDIF.
        ELSE.
          update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_wait ).
          lr_interface->error_code = zetoe_error_eai_running.
        ENDIF.
      WHEN OTHERS.
        "it is ok for EAI, so check the number of IDOCS
        CLEAR lr_interface->error_code.
        ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_get_validation_c ).
*        IF lr_interface->interface_id = g_interface_id. "INC0829526-Commented-12/7/2019
        lr_interface->audit_data_received-documents_counter = lr_interface->audit_data_received-output_counter.
*          l_idocs_equal = abap_true. "INC0829526-Commented-12/7/2019
*        ENDIF.                       "INC0829526-Commented-12/7/2019

        IF ( check_number_documents( lr_interface ) = 0 ). " AND l_idocs_equal IS NOT INITIAL ). "INC0829526-Commented-12/7/2019
          "Release the idocs
          update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_ready ).
          lr_interface->error_code = zetoe_error_ready_4_analysis.
        ELSE.
          "Park the idocs
*          update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked )."GAP2019-
*-Begin of GAP2019+
* if expected and received idoc counters don't match it may be because the last idoc arrived before the other one
          "Check if wait time has expired.
          IF ( is_wait_time_expired( lr_interface ) <> 0 ).
            "PArk temporarly the idocs
            RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'W' iv_msg1 = 'EAI is still running: move idocs in wait status.'(w01).
            update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_wait ).
            lr_interface->error_code = zetoe_error_eai_running.
          ELSE.
            "Park definitively the idocs.
* -> Start of changes for INC0577180
*            update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_parked ). " DEL for INC0577180
* Change IDOC status to 51 and populate error message according to INC0577180 requirement.
            CLEAR: ls_idoc_status.
            ls_idoc_status-msgty = 'E'.
            ls_idoc_status-msgid = lv_msg_cls.
            ls_idoc_status-msgno = '001'.
            ls_idoc_status-msgv1 = lr_interface->audit_data_received-interface_id.
            ls_idoc_status-msgv2 = lr_interface->unique_id.
            ls_idoc_status-msgv3 = lr_interface->audit_data_calculated-documents_counter.
            ls_idoc_status-msgv4 = lr_interface->audit_data_received-documents_counter.
            update_idocs_status( ir_interface = lr_interface iv_new_status = zetoe_idoc_status_error is_idoc_status = ls_idoc_status ).
* -> End of changes for INC0577180
          ENDIF.
*-End of GAP2019+
        ENDIF.
    ENDCASE.
  ENDLOOP.
  idocs_recycling_management( ).
  "Finally clean and flus the framework web service
  ws_clean_and_flush( ).
ENDMETHOD.