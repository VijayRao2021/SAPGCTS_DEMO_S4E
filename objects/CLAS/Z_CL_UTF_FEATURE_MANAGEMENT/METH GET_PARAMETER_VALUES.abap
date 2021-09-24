  METHOD GET_PARAMETER_VALUES.
    STATICS:
     st_parameters_buffer TYPE zfamm_tt_parameters_buffer,
     ss_results_buffer TYPE zfamm_ts_param_results_buffer,
     st_results_buffer TYPE zfamm_tt_param_results_buffer.

    DATA:
          lv_subrc TYPE sysubrc,
          lv_rule_level TYPE zfam_level,
          lv_flg_rule_level TYPE flag,
          lv_parameter_name_old TYPE zfam_parameter,
          ls_parameter_buffer TYPE zfamm_ts_parameter_buffer,
          ls_parameter_result TYPE zfam_s_parameter_result,
          lr_parameter_result TYPE REF TO zfam_s_parameter_result.

    REFRESH et_results.
    ev_subrc = 8.

    "check if the request is the same than the previous one
    IF  ss_results_buffer-feature_id = iv_feature_id AND
        ss_results_buffer-parameter_name = iv_parameter_name AND
        ss_results_buffer-criteria1_name = iv_criteria1_name AND
        ss_results_buffer-criteria1_value = iv_criteria1_value AND
        ss_results_buffer-criteria2_name = iv_criteria2_name AND
        ss_results_buffer-criteria2_value = iv_criteria2_value AND
        ss_results_buffer-criteria3_name = iv_criteria3_name AND
        ss_results_buffer-criteria3_value = iv_criteria3_value AND
        ss_results_buffer-criteria4_name = iv_criteria4_name AND
        ss_results_buffer-criteria4_value = iv_criteria4_value AND
        ss_results_buffer-criteria5_name = iv_criteria5_name AND
        ss_results_buffer-criteria5_value = iv_criteria5_value.
      "it is the case so return the same result :)
      et_results = ss_results_buffer-parameters_values.
      ev_subrc = ss_results_buffer-rc.
      EXIT.
    ELSE.
      "check if the combination has been already resolved.
      READ TABLE st_results_buffer INTO ss_results_buffer WITH TABLE KEY feature_id = iv_feature_id
                                                                       parameter_name = iv_parameter_name
                                                                       criteria1_name = iv_criteria1_name
                                                                       criteria1_value = iv_criteria1_value
                                                                       criteria2_name = iv_criteria2_name
                                                                       criteria2_value = iv_criteria2_value
                                                                       criteria3_name = iv_criteria3_name
                                                                       criteria3_value = iv_criteria3_value
                                                                       criteria4_name = iv_criteria4_name
                                                                       criteria4_value = iv_criteria4_value
                                                                       criteria5_name = iv_criteria5_name
                                                                       criteria5_value = iv_criteria5_value.
      IF sy-subrc = 0.
        "Found then return the result
        et_results = ss_results_buffer-parameters_values.
        ev_subrc = ss_results_buffer-rc.
        EXIT.
      ENDIF.
    ENDIF.
    "If we are here it means the result is not yet buffered, so it need to be calculated.
    CLEAR ss_results_buffer.
    ss_results_buffer-feature_id = iv_feature_id.
    ss_results_buffer-parameter_name = iv_parameter_name.
    ss_results_buffer-criteria1_name = iv_criteria1_name.
    ss_results_buffer-criteria1_value = iv_criteria1_value.
    ss_results_buffer-criteria2_name = iv_criteria2_name.
    ss_results_buffer-criteria2_value = iv_criteria2_value.
    ss_results_buffer-criteria3_name = iv_criteria3_name.
    ss_results_buffer-criteria3_value = iv_criteria3_value.
    ss_results_buffer-criteria4_name = iv_criteria4_name.
    ss_results_buffer-criteria4_value = iv_criteria4_value.
    ss_results_buffer-criteria5_name = iv_criteria5_name.
    ss_results_buffer-criteria5_value = iv_criteria5_value.

    "Check if parameter exist and is configuration is loaded in memory
    IF iv_parameter_name IS NOT INITIAL.
      "Parameter is specified so check it.
      CLEAR ls_parameter_buffer.
      READ TABLE st_parameters_buffer INTO ls_parameter_buffer WITH KEY feature_id = iv_feature_id
                                                                        name = iv_parameter_name.
      IF sy-subrc <> 0.
        "Data are not yet loaded in memory so do it now.
        z_cl_utf_feature_management=>load_feature( EXPORTING iv_feature_id = iv_feature_id iv_data_to_load = 'P' CHANGING ct_parameters = st_parameters_buffer ).
        READ TABLE st_parameters_buffer INTO ls_parameter_buffer WITH KEY feature_id = iv_feature_id
                                                                          name = iv_parameter_name.
        IF sy-subrc <> 0.
          "Could not find it again, then it means we have really a problem, stop here
          REFRESH ss_results_buffer-parameters_values.
          ss_results_buffer-rc = 99.
          RAISE EVENT send_log EXPORTING iv_group = 'FAMM/MAIL_ERROR' iv_level = 0 iv_type = 'E' iv_msg1 = 'Parameter &2 is not defined for feature &3'(e04) iv_msg2 = iv_parameter_name iv_msg3 = iv_feature_id.
        ENDIF.
      ENDIF.
    ELSE.
      "no parameter specified, it means all the parameters have to be extracted, so check if there is at least one parameter
      CLEAR ls_parameter_buffer.
      READ TABLE st_parameters_buffer INTO ls_parameter_buffer WITH KEY feature_id = iv_feature_id.
      IF sy-subrc <> 0.
        "Data are not yet loaded in memory so do it now.
        z_cl_utf_feature_management=>load_feature( EXPORTING iv_feature_id = iv_feature_id iv_data_to_load = 'P' CHANGING ct_parameters = st_parameters_buffer ).
        READ TABLE st_parameters_buffer INTO ls_parameter_buffer WITH KEY feature_id = iv_feature_id.
        IF sy-subrc <> 0.
          "Could not find it again, then it means we have really a problem, stop here
          REFRESH ss_results_buffer-parameters_values.
          ss_results_buffer-rc = 99.
          RAISE EVENT send_log EXPORTING iv_group = 'FAMM/MAIL_ERROR' iv_level = 0 iv_type = 'E' iv_msg1 = 'No parameter defined for feature &3'(e05) iv_msg3 = iv_feature_id.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ls_parameter_buffer IS NOT INITIAL.
      "Something has been found in the table for the feature ID
      CLEAR lv_parameter_name_old.
      LOOP AT st_parameters_buffer INTO ls_parameter_buffer WHERE feature_id = iv_feature_id.
        IF ls_parameter_buffer-name <> iv_parameter_name AND iv_parameter_name IS NOT INITIAL.
          "If parameter name is specified and the current record is not for this parameter then skip the record.
          CONTINUE.
        ENDIF.

        IF ls_parameter_buffer-name <> lv_parameter_name_old.
          "parameter change.
          CLEAR: lv_rule_level, lv_flg_rule_level, lr_parameter_result.
          lv_parameter_name_old = ls_parameter_buffer-name.
        ENDIF.

        IF lv_flg_rule_level IS NOT INITIAL AND lv_rule_level <> ls_parameter_buffer-rule_level.
          "it is not the same rule level than the first value found then skip this record
          CONTINUE.
        ENDIF.

        "loop is done from deeper rule_level to higher so first rule which matches is kept.
        lv_subrc = z_cl_utf_feature_management=>evaluate_rules_group( iv_group_id = ls_parameter_buffer-group_id
                                                                   iv_criteria1_name = iv_criteria1_name
                                                                   iv_criteria1_value = iv_criteria1_value
                                                                   iv_criteria2_name = iv_criteria2_name
                                                                   iv_criteria2_value = iv_criteria2_value
                                                                   iv_criteria3_name = iv_criteria3_name
                                                                   iv_criteria3_value = iv_criteria3_value
                                                                   iv_criteria4_name = iv_criteria4_name
                                                                   iv_criteria4_value = iv_criteria4_value
                                                                   iv_criteria5_name = iv_criteria5_name
                                                                   iv_criteria5_value = iv_criteria5_value ).
        ss_results_buffer-rc = lv_subrc.
        IF lv_subrc = 0.
          IF lr_parameter_result IS NOT BOUND.
            ls_parameter_result-parameter_name = ls_parameter_buffer-name.
            INSERT ls_parameter_result INTO ss_results_buffer-parameters_values INDEX 1.
            lr_parameter_result = REF #( ss_results_buffer-parameters_values[ 1 ] ).
          ENDIF.

          APPEND ls_parameter_buffer-value TO lr_parameter_result->parameter_values.

          lv_rule_level = ls_parameter_buffer-rule_level.
          lv_flg_rule_level = abap_true.
        ENDIF.
      ENDLOOP.
    ENDIF.
    "Save the buffer and return the new combination result
    APPEND ss_results_buffer TO st_results_buffer.
    SORT st_results_buffer.
    et_results = ss_results_buffer-parameters_values.
    ev_subrc = ss_results_buffer-rc.
  ENDMETHOD.