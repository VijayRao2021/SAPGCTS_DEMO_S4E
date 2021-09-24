  METHOD LOAD_RULES_GROUP.
    DATA:
          ls_range TYPE zfamm_ts_generic_range,
          ls_rules_group_buffer TYPE zfamm_ts_rules_group_buffer,
          ls_rules_group TYPE zfam_rules_group,
          lt_rules_groups TYPE STANDARD TABLE OF zfam_rules_group.

    "Load detailled configuration
    SELECT * INTO TABLE lt_rules_groups
      FROM zfam_rules_group
      WHERE group_id = iv_group_id.
    IF sy-subrc = 0.
      SORT lt_rules_groups.
      "Transform the DDIC table format to internal format with a real abap range
      LOOP AT lt_rules_groups INTO ls_rules_group.
        AT NEW criteria.
          CLEAR ls_rules_group_buffer.
          ls_rules_group_buffer-group_id = ls_rules_group-group_id.
          ls_rules_group_buffer-criterias_group = ls_rules_group-criterias_group.
          ls_rules_group_buffer-criteria = ls_rules_group-criteria.
          REFRESH ls_rules_group_buffer-values.
        ENDAT.

        "Prepare the range
        CLEAR ls_range.
        ls_range-sign = ls_rules_group-sign.
        ls_range-option = ls_rules_group-opti.
        ls_range-low = ls_rules_group-low.
        ls_range-high = ls_rules_group-high.
        APPEND ls_range TO ls_rules_group_buffer-values.

        AT END OF criteria.
          "add the rule line
          APPEND ls_rules_group_buffer TO ct_rules_groups.
        ENDAT.
      ENDLOOP.
      SORT ct_rules_groups.
    ENDIF.
  ENDMETHOD.