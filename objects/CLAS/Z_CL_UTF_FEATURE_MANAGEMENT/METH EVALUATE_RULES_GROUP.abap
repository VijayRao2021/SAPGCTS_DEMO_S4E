  METHOD EVALUATE_RULES_GROUP.
    STATICS: st_rules_groups_buffer TYPE zfamm_tt_rules_groups_buffer.

    DATA:
          ls_rules_group_buffer TYPE zfamm_ts_rules_group_buffer,
          lt_groups_result TYPE zfamm_tt_groups_result,
          ls_group_result TYPE zfamm_ts_group_result.

    IF iv_group_id IS INITIAL.
      "if group id is empty, then it is a global parameter so always true
      rv_evaluation_result = 0.
      EXIT.
    ENDIF.

    rv_evaluation_result = 0.
    "Check if the rule is in memory
    READ TABLE st_rules_groups_buffer INTO ls_rules_group_buffer WITH KEY group_id = iv_group_id.
    IF sy-subrc <> 0.
      "Rules group is not yet loaded in memory so do it now.
      z_cl_utf_feature_management=>load_rules_group( EXPORTING iv_group_id = iv_group_id CHANGING ct_rules_groups = st_rules_groups_buffer ).
      READ TABLE st_rules_groups_buffer INTO ls_rules_group_buffer WITH KEY group_id = iv_group_id.
      IF sy-subrc <> 0.
        "Rules group is still not yet loaded then it mean we have a problem, stop here
        rv_evaluation_result = 99.
        RAISE EVENT send_log EXPORTING iv_group = 'FAMM/MAIL_ERROR' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot find group ID &2 in ZFAM_RULES_GROUP table'(e02) iv_msg2 = iv_group_id.
      ENDIF.
    ENDIF.

    IF rv_evaluation_result = 0.
      "No problem until now so continue.
      "check if there is at least one second level criteria entry.
      IF iv_criteria1_name IS SUPPLIED AND iv_criteria1_name IS NOT INITIAL.
        z_cl_utf_feature_management=>check_criteria( EXPORTING iv_group_id = ls_rules_group_buffer-group_id
                                                              iv_criteria_name = iv_criteria1_name
                                                              iv_criteria_value = iv_criteria1_value
                                                              it_rules_groups_buffer = st_rules_groups_buffer
                                                    CHANGING
                                                              ct_groups_result = lt_groups_result ).
      ENDIF.
      IF iv_criteria2_name IS SUPPLIED AND iv_criteria2_name IS NOT INITIAL.
        z_cl_utf_feature_management=>check_criteria( EXPORTING iv_group_id = ls_rules_group_buffer-group_id
                                                    iv_criteria_name = iv_criteria2_name
                                                    iv_criteria_value = iv_criteria2_value
                                                    it_rules_groups_buffer = st_rules_groups_buffer
                                          CHANGING
                                                    ct_groups_result = lt_groups_result ).

      ENDIF.
      IF iv_criteria3_name IS SUPPLIED AND iv_criteria3_name IS NOT INITIAL.
        z_cl_utf_feature_management=>check_criteria( EXPORTING iv_group_id = ls_rules_group_buffer-group_id
                                                    iv_criteria_name = iv_criteria3_name
                                                    iv_criteria_value = iv_criteria3_value
                                                    it_rules_groups_buffer = st_rules_groups_buffer
                                          CHANGING
                                                     ct_groups_result = lt_groups_result ).

      ENDIF.
      IF iv_criteria4_name IS SUPPLIED AND iv_criteria4_name IS NOT INITIAL.
        z_cl_utf_feature_management=>check_criteria( EXPORTING iv_group_id = ls_rules_group_buffer-group_id
                                                    iv_criteria_name = iv_criteria4_name
                                                    iv_criteria_value = iv_criteria4_value
                                                    it_rules_groups_buffer = st_rules_groups_buffer
                                          CHANGING
                                                     ct_groups_result = lt_groups_result ).

      ENDIF.
      IF iv_criteria5_name IS SUPPLIED AND iv_criteria5_name IS NOT INITIAL.
        z_cl_utf_feature_management=>check_criteria( EXPORTING iv_group_id = ls_rules_group_buffer-group_id
                                                    iv_criteria_name = iv_criteria5_name
                                                    iv_criteria_value = iv_criteria5_value
                                                    it_rules_groups_buffer = st_rules_groups_buffer
                                          CHANGING
                                                     ct_groups_result = lt_groups_result ).

      ENDIF.
      "Now check the groups result: they must be all ok, else it means it is not activated for the given criterias
      rv_evaluation_result = 0.
      LOOP AT lt_groups_result INTO ls_group_result.
        IF ls_group_result-group_result <> 0.
          rv_evaluation_result = ls_group_result-group_result.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.