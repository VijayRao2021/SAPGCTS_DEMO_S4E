  METHOD check_and_complete_object_data.
    DATA:
      lv_fl_error    TYPE c,

      ls_object_data TYPE zdatm_ts_object_data,
      ls_field1(40)  TYPE c,
      ls_field2(40)  TYPE c.

    FIELD-SYMBOLS: <fs_field1> TYPE any,
                   <fs_field2> TYPE any.

    READ TABLE mt_object_data TRANSPORTING NO FIELDS WITH KEY process_id = mv_process_id.
    IF sy-subrc <> 0.
      SELECT * APPENDING TABLE  mt_object_data
        FROM zdset_object_dat
        WHERE process_id = mv_process_id.
    ENDIF.

    ev_rc = 0.
    CASE iv_function.
        "Retrieve the constants value for one or many field
      WHEN zdatm_c_ccfunction_retrieve.
        IF NOT iv_fieldname IS INITIAL.
          "Retrieve only one field
          READ TABLE mt_object_data INTO ls_object_data WITH KEY record_type = 'F'
                                                                 tabname = iv_tabname
                                                                 fieldname = iv_fieldname
                                                                 apply_condition = iv_condition
                                                                 data_source = 'C'.
          IF sy-subrc <> 0.
            ev_rc = 8.
            RAISE EVENT send_log EXPORTING iv_group = 'CHECK&COMPLETE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot find ZDSET_OBJECT_DATA entry for &2 &3 &4 &5.'(e04) iv_msg2 = 'F' iv_msg3 = iv_tabname iv_msg4 = iv_fieldname iv_msg5 = iv_condition.
          ELSE.
            ev_value = ls_object_data-value.
          ENDIF.
        ELSE.
          "Transfert all the constants without condition
          LOOP AT mt_object_data INTO ls_object_data WHERE record_type = 'F' AND
                                                           tabname = iv_tabname AND
                                                           apply_condition = iv_condition AND
                                                           data_source = 'C'.
            CONCATENATE 'ES_STRUCTOUT-' ls_object_data-fieldname INTO ls_field1.
            ASSIGN (ls_field1) TO <fs_field1>.
            <fs_field1> = ls_object_data-value.
          ENDLOOP.
        ENDIF.

        "Check mode: check the mandatory field are well there
      WHEN zdatm_c_ccfunction_check.
        LOOP AT mt_object_data INTO ls_object_data WHERE record_type = 'F' AND
                                                         tabname = iv_tabname AND
                                                         data_source = 'R'.
          IF ( iv_mode = zdatm_c_whattodo_create AND ls_object_data-creation_mandatory IS INITIAL ) OR
             ( iv_mode = zdatm_c_whattodo_update AND ls_object_data-change_mandatory IS INITIAL ).
            CONTINUE.
          ENDIF.
          CONCATENATE 'IS_STRUCTIN-' ls_object_data-fieldname INTO ls_field1.
          ASSIGN (ls_field1) TO <fs_field1>.
          IF <fs_field1> IS INITIAL AND ls_object_data-null_allowed IS INITIAL.
            ev_rc = '8'.
            RAISE EVENT send_log EXPORTING iv_group = 'CHECK&COMPLETE' iv_level = 1 iv_type = 'E' iv_msg1 = 'The field &2-&3 is required.'(e05) iv_msg2 = ls_object_data-tabname iv_msg3 = ls_object_data-fieldname.
          ENDIF.
        ENDLOOP.

        "Copy mode: copy the fields of change request from a structure to another
      WHEN zdatm_c_ccfunction_copy.
        LOOP AT mt_object_data INTO ls_object_data WHERE record_type = 'F' AND
                                                         tabname = iv_tabname AND
                                                         data_source = 'R' AND
                                                         apply_condition = iv_condition.
          "Source field setup
          CONCATENATE 'IS_STRUCTIN-' ls_object_data-fieldname INTO ls_field1.
          ASSIGN (ls_field1) TO <fs_field1>.

          "Target field setup
          CONCATENATE 'ES_STRUCTOUT-' ls_object_data-fieldname INTO ls_field2.
          ASSIGN (ls_field2) TO <fs_field2>.

          "Field update
          IF <fs_field1> IS INITIAL AND NOT ls_object_data-null_allowed IS INITIAL.
            CLEAR <fs_field2>.
            ev_rc = 99."Says at least an update has been done
            CONTINUE.
          ENDIF.
          IF NOT <fs_field1> IS INITIAL AND <fs_field1> <> <fs_field2>.
            <fs_field2> = <fs_field1>.
            ev_rc = 99."Says at least an update has been done
          ENDIF.
        ENDLOOP.

        "Group mode: retrieve the values of a group of values
      WHEN zdatm_c_ccfunction_group.
        READ TABLE mt_object_data INTO ls_object_data WITH KEY record_type = 'G'
                                                               tabname = iv_tabname
                                                               fieldname = iv_fieldname
                                                               data_source = 'C'.
        IF sy-subrc <> 0.
          IF iv_not_found_allowed = abap_false.
            ev_rc = 8.
            RAISE EVENT send_log EXPORTING iv_group = 'CHECK&COMPLETE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot find ZDSET_OBJECT_DATA entry for &2 &3 &4 &5.'(e04) iv_msg2 = 'G' iv_msg3 = iv_tabname iv_msg4 = iv_fieldname iv_msg5 = iv_condition.
          ELSE.
            ev_rc = 4.
            RAISE EVENT send_log EXPORTING iv_group = 'CHECK&COMPLETE' iv_level = 1 iv_type = 'W' iv_msg1 = 'Cannot find ZDSET_OBJECT_DATA entry for &2 &3 &4 &5.'(e04) iv_msg2 = 'G' iv_msg3 = iv_tabname iv_msg4 = iv_fieldname iv_msg5 = iv_condition.
          ENDIF.
        ELSE.
          ev_value = ls_object_data-value.
        ENDIF.
    ENDCASE.
  ENDMETHOD.