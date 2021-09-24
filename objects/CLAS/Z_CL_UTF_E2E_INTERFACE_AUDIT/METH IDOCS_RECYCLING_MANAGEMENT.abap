METHOD IDOCS_RECYCLING_MANAGEMENT.
  DATA:
        lv_time_diff TYPE fahztd,
        lr_interface TYPE REF TO ts_interface,
        ls_idoc TYPE zbc_audit_idoc_line,
        ls_recycle TYPE zbc_audit_idocs,
        lt_recycle TYPE STANDARD TABLE OF zbc_audit_idocs.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'Update the recycling table...'(m08).
  LOOP AT mt_interfaces REFERENCE INTO lr_interface.
    IF NOT lr_interface->error_code IS INITIAL AND lr_interface->error_code <> mv_error_ws_conn_failed.
      IF NOT lr_interface->recycling IS INITIAL AND lr_interface->error_code <> zetoe_error_ready_4_analysis.
        "Autocleaning mecanism
        CALL FUNCTION 'SD_CALC_DURATION_FROM_DATETIME'
          EXPORTING
            i_date1          = lr_interface->recycling_erdat
            i_time1          = lr_interface->recycling_erzeit
            i_date2          = sy-datum
            i_time2          = sy-uzeit
          IMPORTING
            e_tdiff          = lv_time_diff
          EXCEPTIONS
            invalid_datetime = 1
            OTHERS           = 2.
        IF ( sy-subrc = 0 AND lv_time_diff >= 10000 ) OR ( lr_interface->recycling_erdat IS INITIAL AND lr_interface->recycling_erzeit IS INITIAL ).
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT/ERROR_MAIL' iv_level = 0 iv_type = 'E' iv_msg1 = '&2/&3: 1 hour without any changes, SAP stop trying to check this interface and the idocs are parked if not processed.'(e19)
                                         iv_msg2 = lr_interface->interface_id iv_msg3 = lr_interface->unique_id.
          ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_get_validation_c ).
          ws_create( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_get_validation iv_comment = zetoe_stepid_stop_wait_c ).
          ws_validation_check( iv_interface_id = lr_interface->audit_data_received-interface_id iv_unique_id = lr_interface->unique_id iv_comment = zetoe_stepid_stop_wait_c iv_property_name = zetoe_property_idoc_counter
                               iv_status = zetoe_status_failed ).
          ws_create( iv_interface_id = lr_interface->interface_id iv_unique_id = lr_interface->unique_id  iv_step_id = zetoe_stepid_analysis_finish iv_comment = zetoe_stepid_analysis_finish_c ).
          "it is more than 1 hour this unique id has been recycled so stop recycling
          DELETE FROM zbc_audit_idocs WHERE unique_id = lr_interface->unique_id.
          CONTINUE.
        ENDIF.
      ENDIF.
      "there is a least one error so the idocs will be recycled next time.
      CLEAR ls_recycle.
      ls_recycle-unique_id = lr_interface->unique_id.
      ls_recycle-interface_id = lr_interface->audit_data_received-interface_id.
      ls_recycle-error_code = lr_interface->error_code.

      "Loop on idocs to get idoc info
      LOOP AT lr_interface->idocs INTO ls_idoc.
        IF sy-tabix = 1.
          ls_idoc-idoc->get_timestamp( IMPORTING ev_date = ls_recycle-erdat ev_time = ls_recycle-erzeit ).
        ENDIF.

        ls_recycle-docnum = ls_idoc-idoc->get_docnum( ).
        ls_recycle-status = ls_idoc-idoc->get_status( ).
        IF ls_idoc-error_code IS NOT INITIAL.
          ls_recycle-error_code = ls_idoc-error_code.
        ENDIF.
        IF mv_mode = c_mode_preprocessing.
          IF ls_recycle-status = zetoe_idoc_status_ready OR
             ls_recycle-status = zetoe_idoc_status_parked OR
             ls_recycle-status = zetoe_idoc_status_wait.
            APPEND ls_recycle TO lt_recycle.
          ELSE.
            DELETE FROM zbc_audit_idocs WHERE unique_id = lr_interface->unique_id AND docnum = ls_recycle-docnum.
          ENDIF.
        ELSE.
          APPEND ls_recycle TO lt_recycle.
        ENDIF.
      ENDLOOP.
    ELSEIF NOT lr_interface->recycling IS INITIAL.
      "The unique ID was in error on previous run but now, it's ok so delete it from the recycle table
      DELETE FROM zbc_audit_idocs WHERE unique_id = lr_interface->unique_id.
    ENDIF.
  ENDLOOP.
  IF NOT lt_recycle[] IS INITIAL.
    MODIFY zbc_audit_idocs FROM TABLE lt_recycle.
  ENDIF.
  COMMIT WORK.
ENDMETHOD.