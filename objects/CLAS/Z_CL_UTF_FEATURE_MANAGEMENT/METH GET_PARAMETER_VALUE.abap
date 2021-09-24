  METHOD get_parameter_value.
    STATICS:
      st_parameters_buffer TYPE zfamm_tt_parameters_buffer,
      ss_result_buffer     TYPE zfamm_ts_param_result_buffer,
      st_result_buffer     TYPE zfamm_tt_param_result_buffer.

    DATA:
      lv_subrc            TYPE sysubrc,
      ls_parameter_buffer TYPE zfamm_ts_parameter_buffer.

    CLEAR ev_value.
    ev_subrc = 8.
    "Before looking for the parameter value, check if the feature is active for the given combination
*    IF ( z_cl_utf_feature_management=>is_active( iv_feature_id = iv_feature_id iv_criteria1_name = iv_criteria1_name iv_criteria1_value = iv_criteria1_value iv_criteria2_name = iv_criteria2_name   iv_criteria2_value = iv_criteria2_value
*                                                iv_criteria3_name = iv_criteria3_name iv_criteria3_value = iv_criteria3_value iv_criteria4_name = iv_criteria4_name  iv_criteria4_value = iv_criteria4_value
*                                                iv_criteria5_name = iv_criteria5_name iv_criteria5_value = iv_criteria5_value ) = 0 ).
    "check if the request is the same than the previous one
    IF  ss_result_buffer-feature_id = iv_feature_id AND
        ss_result_buffer-parameter_name = iv_parameter_name AND
        ss_result_buffer-criteria1_name = iv_criteria1_name AND
        ss_result_buffer-criteria1_value = iv_criteria1_value AND
        ss_result_buffer-criteria2_name = iv_criteria2_name AND
        ss_result_buffer-criteria2_value = iv_criteria2_value AND
        ss_result_buffer-criteria3_name = iv_criteria3_name AND
        ss_result_buffer-criteria3_value = iv_criteria3_value AND
        ss_result_buffer-criteria4_name = iv_criteria4_name AND
        ss_result_buffer-criteria4_value = iv_criteria4_value AND
        ss_result_buffer-criteria5_name = iv_criteria5_name AND
        ss_result_buffer-criteria5_value = iv_criteria5_value.
      "it is the case so return the same result :)
      ev_value = ss_result_buffer-parameter_value.
      ev_subrc = ss_result_buffer-rc.
      EXIT.
    ELSE.
      "check if the combination has been already resolved.
      READ TABLE st_result_buffer INTO ss_result_buffer WITH TABLE KEY feature_id = iv_feature_id
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
        ev_value = ss_result_buffer-parameter_value.
        ev_subrc = ss_result_buffer-rc.
        EXIT.
      ENDIF.
    ENDIF.
    "If we are here it means the result is not yet buffered, so it need to be calculated.
    CLEAR ss_result_buffer.
    ss_result_buffer-feature_id = iv_feature_id.
    ss_result_buffer-parameter_name = iv_parameter_name.
    ss_result_buffer-criteria1_name = iv_criteria1_name.
    ss_result_buffer-criteria1_value = iv_criteria1_value.
    ss_result_buffer-criteria2_name = iv_criteria2_name.
    ss_result_buffer-criteria2_value = iv_criteria2_value.
    ss_result_buffer-criteria3_name = iv_criteria3_name.
    ss_result_buffer-criteria3_value = iv_criteria3_value.
    ss_result_buffer-criteria4_name = iv_criteria4_name.
    ss_result_buffer-criteria4_value = iv_criteria4_value.
    ss_result_buffer-criteria5_name = iv_criteria5_name.
    ss_result_buffer-criteria5_value = iv_criteria5_value.

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
        CLEAR ss_result_buffer-parameter_value.
        ss_result_buffer-rc = 99.
        RAISE EVENT send_log EXPORTING iv_group = 'FAMM/MAIL_ERROR' iv_level = 0 iv_type = 'E' iv_msg1 = 'Parameter &2 is not defined for feature &3'(e04) iv_msg2 = iv_parameter_name iv_msg3 = iv_feature_id.
      ENDIF.
    ENDIF.

    IF ls_parameter_buffer IS NOT INITIAL.
      "Something has been found in the table for the feature ID
      LOOP AT st_parameters_buffer INTO ls_parameter_buffer WHERE feature_id = iv_feature_id AND
                                                                  name = iv_parameter_name.
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
        ss_result_buffer-rc = lv_subrc.
        IF lv_subrc = 0.
          ss_result_buffer-parameter_value = ls_parameter_buffer-value.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    "Save the buffer and return the new combination result
    APPEND ss_result_buffer TO st_result_buffer.
    SORT st_result_buffer.
    ev_value = ss_result_buffer-parameter_value.
    ev_subrc = ss_result_buffer-rc.
*    ELSE.
*      "Should we consider it as an error? no the feature is not active so method return 8 and calling program will manage this RC
*      CLEAR ev_value.
*      ev_subrc = 8.
*    ENDIF.
  ENDMETHOD.