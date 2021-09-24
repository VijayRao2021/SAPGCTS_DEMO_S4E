private section.

  aliases SEND_LOG
    for Z_IN_UTF_LOG~SEND_LOG .

  class-methods EVALUATE_RULES_GROUP
    importing
      !IV_GROUP_ID type ZFAM_CRITERIAS_GROUP_ID
      !IV_CRITERIA1_NAME type ZFAM_CRITERIA optional
      !IV_CRITERIA1_VALUE type ANY optional
      !IV_CRITERIA2_NAME type ZFAM_CRITERIA optional
      !IV_CRITERIA2_VALUE type ANY optional
      !IV_CRITERIA3_NAME type ZFAM_CRITERIA optional
      !IV_CRITERIA3_VALUE type ANY optional
      !IV_CRITERIA4_NAME type ZFAM_CRITERIA optional
      !IV_CRITERIA4_VALUE type ANY optional
      !IV_CRITERIA5_NAME type ZFAM_CRITERIA optional
      !IV_CRITERIA5_VALUE type ANY optional
    returning
      value(RV_EVALUATION_RESULT) type SYSUBRC .
  class-methods LOAD_RULES_GROUP
    importing
      !IV_GROUP_ID type ZFAM_RULES_GROUP_ID
    changing
      !CT_RULES_GROUPS type ZFAMM_TT_RULES_GROUPS_BUFFER .
  class-methods UPDATE_LOG
    importing
      !IV_FEATURE_ID type ZFAM_FEATURE_ID .
  class-methods CHECK_CRITERIA
    importing
      !IV_GROUP_ID type ZFAM_RULES_GROUP_ID
      !IV_CRITERIA_NAME type ZFAM_CRITERIA
      !IV_CRITERIA_VALUE type ANY
      !IT_RULES_GROUPS_BUFFER type ZFAMM_TT_RULES_GROUPS_BUFFER
    changing
      !CT_GROUPS_RESULT type ZFAMM_TT_GROUPS_RESULT .
  class-methods LOAD_FEATURE
    importing
      !IV_FEATURE_ID type ZFAM_FEATURE_ID
      !IV_DATA_TO_LOAD type C
    changing
      !CT_FEATURE type ZFAMM_TT_FEATURE_BUFFER optional
      !CT_PARAMETERS type ZFAMM_TT_PARAMETERS_BUFFER optional .