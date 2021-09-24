  METHOD POSTPROC_START.
*GAP-1790. ChengM- The method postproc_start is used to define if a processing need to be started after the inbound interface,
*if the conditions are reached to start it, and finally, if all the lights are green call the method corresponding
*to the post processing configured in the table ZBC_E2E_POSTPROC_CUST.

*Follow as below, create the attritube
    DATA:
          ls_postprocessing TYPE ts_postprocessing,
          ls_parameter TYPE zbc_audit_postproc_parameter.

    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 0 iv_type = 'H' iv_msg1 = 'Postprocessing check...'(h03) iv_msg3 = ir_interface->interface_id.
    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if interface has postprocessing configuration for interface ID &5 MESCOD/MESFCT &2/&3 and callpoint &4'(M26) iv_msg2 = ir_interface->mescod
                                   iv_msg3 = ir_interface->mesfct iv_msg4 = iv_callpoint iv_msg5 = ir_interface->interface_id.
    CLEAR ls_parameter.
    ls_parameter-interface_id = ir_interface->interface_id.
    ls_parameter-mescod = ir_interface->mescod.
    ls_parameter-mesfct = ir_interface->mesfct.
    ls_parameter-postproc_condition = iv_callpoint.
    LOOP AT mt_postprocessing INTO ls_postprocessing WHERE interface_id = ir_interface->interface_id AND
                                                       mescod = ir_interface->mescod AND
                                                       mesfct = ir_interface->mesfct AND
                                                       postproc_condition = iv_callpoint.
      IF ls_postprocessing-postproc_method IS NOT INITIAL.
        "Run the method.
        CALL METHOD (ls_postprocessing-postproc_method)
          EXPORTING
            is_postproc_param = ls_parameter.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'No configuration found for these parameters'(M27).
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if interface has postprocessing configuration for interface ID &5 MESCOD/MESFCT &2/&3 and callpoint &4'(M26) iv_msg2 = ir_interface->mescod
                                   iv_msg3 = ir_interface->mesfct iv_msg4 = c_postproc_cond_always iv_msg5 = ir_interface->interface_id.
    CLEAR ls_parameter.
    ls_parameter-interface_id = ir_interface->interface_id.
    ls_parameter-mescod = ir_interface->mescod.
    ls_parameter-mesfct = ir_interface->mesfct.
    ls_parameter-postproc_condition = c_postproc_cond_always.
    LOOP AT mt_postprocessing INTO ls_postprocessing WHERE interface_id = ir_interface->interface_id AND
                                                       mescod = ir_interface->mescod AND
                                                       mesfct = ir_interface->mesfct AND
                                                       postproc_condition = c_postproc_cond_always.
      IF ls_postprocessing-postproc_method IS NOT INITIAL.
        "Run the method.
        CALL METHOD (ls_postprocessing-postproc_method)
          EXPORTING
            is_postproc_param = ls_parameter.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'No configuration found for these parameters'(M27).
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if interface has postprocessing configuration for interface ID &2 and callpoint &3'(M28) iv_msg2 = ir_interface->interface_id iv_msg3 = iv_callpoint.
    CLEAR ls_parameter.
    ls_parameter-interface_id = ir_interface->interface_id.
    ls_parameter-postproc_condition = iv_callpoint.
    LOOP AT mt_postprocessing INTO ls_postprocessing WHERE interface_id = ir_interface->interface_id AND
                                                       mescod = space AND
                                                       mesfct = space AND
                                                       postproc_condition = iv_callpoint.
      IF ls_postprocessing-postproc_method IS NOT INITIAL.
        "Run the method.
        CALL METHOD (ls_postprocessing-postproc_method)
          EXPORTING
            is_postproc_param = ls_parameter.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'No configuration found for these parameters'(M27).
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if interface has postprocessing configuration for interface ID &2 and callpoint &3'(M28) iv_msg2 = ir_interface->interface_id
                                   iv_msg3 = c_postproc_cond_always.
    CLEAR ls_parameter.
    ls_parameter-interface_id = ir_interface->interface_id.
    ls_parameter-postproc_condition = c_postproc_cond_always.
    LOOP AT mt_postprocessing INTO ls_postprocessing WHERE interface_id = ir_interface->interface_id AND
                                                       mescod = space AND
                                                       mesfct = space AND
                                                       postproc_condition = c_postproc_cond_always.
      IF ls_postprocessing-postproc_method IS NOT INITIAL.
        "Run the method.
        CALL METHOD (ls_postprocessing-postproc_method)
          EXPORTING
            is_postproc_param = ls_parameter.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'No configuration found for these parameters'(M27).
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if interface has postprocessing configuration for ALL interfaces and callpoint &2'(M29) iv_msg2 = iv_callpoint.
    CLEAR ls_parameter.
    ls_parameter-postproc_condition = iv_callpoint.
    LOOP AT mt_postprocessing INTO ls_postprocessing WHERE interface_id = space AND
                                                       mescod = space AND
                                                       mesfct = space AND
                                                       postproc_condition = iv_callpoint.
      IF ls_postprocessing-postproc_method IS NOT INITIAL.
        "Run the method.
        CALL METHOD (ls_postprocessing-postproc_method)
          EXPORTING
            is_postproc_param = ls_parameter.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'No configuration found for these parameters'(M27).
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'Check if interface has postprocessing configuration for ALL interfaces and callpoint &2'(M29) iv_msg2 = c_postproc_cond_always.
    CLEAR ls_parameter.
    ls_parameter-postproc_condition = c_postproc_cond_always.
    LOOP AT mt_postprocessing INTO ls_postprocessing WHERE interface_id = space AND
                                                       mescod = space AND
                                                       mesfct = space AND
                                                       postproc_condition = c_postproc_cond_always.
      IF ls_postprocessing-postproc_method IS NOT INITIAL.
        "Run the method.
        CALL METHOD (ls_postprocessing-postproc_method)
          EXPORTING
            is_postproc_param = ls_parameter.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC' iv_level = 1 iv_type = 'I' iv_msg1 = 'No configuration found for these parameters'(M27).
    ENDIF.
  ENDMETHOD.