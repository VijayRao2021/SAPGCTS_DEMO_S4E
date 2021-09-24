  METHOD LOAD_FEATURE.
**************************************************************
*HP-001  20.11.2015 PAITHAH
*        GAP : 2161
*        Check for fetaure log activation.
*        if tick is marked then log is updated.
**************************************************************
    DATA:
      ls_feature          TYPE zfam_feature,
      ls_feature_buffer   TYPE zfamm_ts_feature_buffer,
      ls_parameter        TYPE zfam_parameters,
      lt_parameters       TYPE STANDARD TABLE OF zfam_parameters,
      ls_parameter_buffer TYPE zfamm_ts_parameter_buffer.

    IF iv_data_to_load = 'A'.
      "Load Feature configuration
      SELECT SINGLE * INTO ls_feature
        FROM zfam_feature
        WHERE feature_id = iv_feature_id.
      IF sy-subrc = 0.
        CLEAR ls_feature_buffer.
        MOVE-CORRESPONDING ls_feature TO ls_feature_buffer.
*SOI by HP-001
        IF ls_feature-dislog_fg = 'X'.
          ls_feature_buffer-logged = 'X'.
        ENDIF.
*EOI by HP-001
        APPEND ls_feature_buffer TO ct_feature.
        SORT ct_feature.
      ENDIF.
    ELSE.
      "Load Parameters
      SELECT * INTO TABLE lt_parameters
        FROM zfam_parameters
        WHERE feature_id = iv_feature_id
        ORDER BY PRIMARY KEY.
      IF sy-subrc = 0.
        LOOP AT lt_parameters INTO ls_parameter.
          CLEAR ls_parameter_buffer.
          ls_parameter_buffer-feature_id = ls_parameter-feature_id.
          ls_parameter_buffer-name = ls_parameter-parameter_name.
          ls_parameter_buffer-rule_level = ls_parameter-rule_level.
          ls_parameter_buffer-value = ls_parameter-parameter_value.
          ls_parameter_buffer-group_id = ls_parameter-group_id.
          APPEND ls_parameter_buffer TO ct_parameters.
        ENDLOOP.
        SORT ct_parameters ASCENDING BY feature_id name rule_level DESCENDING.
      ENDIF.
    ENDIF.
  ENDMETHOD.