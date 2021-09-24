  METHOD CHECK_CRITERIA.
    DATA:
          lv_criteria_result TYPE sysubrc,

          ls_rules_group_buffer TYPE zfamm_ts_rules_group_buffer,
          lr_group_result TYPE REF TO zfamm_ts_group_result,
          ls_group_result TYPE zfamm_ts_group_result.

    "Check the criteria in the different criterias groups
    LOOP AT it_rules_groups_buffer INTO ls_rules_group_buffer WHERE group_id = iv_group_id AND
                                                                    criteria = iv_criteria_name.
      IF iv_criteria_value IN ls_rules_group_buffer-values.
        lv_criteria_result = 0.
      ELSE.
        lv_criteria_result = 8.
      ENDIF.
      "Update groups result table
      READ TABLE ct_groups_result REFERENCE INTO lr_group_result WITH TABLE KEY criterias_group = ls_rules_group_buffer-criterias_group.
      IF sy-subrc = 0.
        "At group level, we do an OR operator, so overwrite only if it is true.
        IF lv_criteria_result = 0.
          lr_group_result->group_result = 0.
        ENDIF.
      ELSE.
        "Group result entry doesn't entry, so create it.
        CLEAR ls_group_result.
        ls_group_result-criterias_group = ls_rules_group_buffer-criterias_group.
        ls_group_result-group_result = lv_criteria_result.
        APPEND ls_group_result TO ct_groups_result.
      ENDIF.
    ENDLOOP.
    IF sy-subrc <> 0.
      "it is not normal then notify it.
      RAISE EVENT send_log EXPORTING iv_group = 'FAMM/MAIL_ERROR' iv_level = 0 iv_type = 'E' iv_msg1 = 'Criteria &2 is not defined in the Group ID &3'(e03) iv_msg2 = iv_criteria_name iv_msg3 = iv_group_id.
      "Create the 00 criterias group
      READ TABLE ct_groups_result REFERENCE INTO lr_group_result WITH TABLE KEY criterias_group = '00'.
      IF sy-subrc <> 0.
        "Group result entry doesn't entry, so create it.
        CLEAR ls_group_result.
        ls_group_result-criterias_group = '00'.
        ls_group_result-group_result = 8.
        APPEND ls_group_result TO ct_groups_result.
      ENDIF.
    ENDIF.
  ENDMETHOD.