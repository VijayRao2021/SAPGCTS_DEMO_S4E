  METHOD IS_ACTIVE.
    STATICS:
     st_feature_buffer TYPE zfamm_tt_feature_buffer,
     st_result_buffer TYPE zfamm_tt_result_buffer,
     ss_result_buffer TYPE zfamm_ts_result_buffer.

    DATA:
         lr_feature_buffer TYPE REF TO zfamm_ts_feature_buffer.

    rv_subrc = 8. "Set non active by default.
    "check if the request is the same than the previous one
    IF  ss_result_buffer-feature_id = iv_feature_id AND
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
      rv_subrc = ss_result_buffer-criterias_result.
      EXIT.
    ELSE.
      "check if the combination has been already resolved.
      READ TABLE st_result_buffer INTO ss_result_buffer WITH TABLE KEY feature_id = iv_feature_id
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
        rv_subrc = ss_result_buffer-criterias_result.
        EXIT.
      ENDIF.
    ENDIF.

    "If we are here, it means current combination has never been request so try to resolve it
    CLEAR ss_result_buffer.
    ss_result_buffer-feature_id = iv_feature_id.
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

    "Check if the feature is globally active.
    READ TABLE st_feature_buffer REFERENCE INTO lr_feature_buffer WITH TABLE KEY feature_id = iv_feature_id.
    IF sy-subrc <> 0.
      "Feature not found, it means it is not yet loaded, so load information.
      z_cl_utf_feature_management=>load_feature( EXPORTING iv_feature_id = iv_feature_id iv_data_to_load = 'A' CHANGING ct_feature = st_feature_buffer  ).
      "Now try again
      READ TABLE st_feature_buffer REFERENCE INTO lr_feature_buffer WITH TABLE KEY feature_id = iv_feature_id.
      IF sy-subrc <> 0.
        "Could not find it again, then it means we have really a problem, stop here
        ss_result_buffer-criterias_result = 99.
        RAISE EVENT send_log EXPORTING iv_group = 'FAMM/MAIL_ERROR' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot find feature ID &2 in ZFAM_FEATURE table'(e01) iv_msg2 = iv_feature_id.
      ELSE.
        IF lr_feature_buffer->activated <> abap_true.
          ss_result_buffer-criterias_result = 8.
        ENDIF.
      ENDIF.
    ELSE.
      IF lr_feature_buffer->activated <> abap_true.
        ss_result_buffer-criterias_result = 8.
      ENDIF.
    ENDIF.

    IF ss_result_buffer-criterias_result = 0.
      "If we are here it means the feature is globally active, so have a look to the others criterias
      ss_result_buffer-criterias_result = z_cl_utf_feature_management=>evaluate_rules_group( iv_group_id = lr_feature_buffer->group_id
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
      IF ss_result_buffer-criterias_result = 0 AND lr_feature_buffer->logged IS INITIAL.
        lr_feature_buffer->logged = 'X'.
        z_cl_utf_feature_management=>update_log( iv_feature_id = lr_feature_buffer->feature_id ).
      ENDIF.
    ENDIF.

    "Save the buffer and return the new combination result
    APPEND ss_result_buffer TO st_result_buffer.
    SORT st_result_buffer.
    rv_subrc = ss_result_buffer-criterias_result.
  ENDMETHOD.