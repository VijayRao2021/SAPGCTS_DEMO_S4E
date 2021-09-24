class Z_CL_UTF_FEATURE_MANAGEMENT definition
  public
  final
  create public .

public section.

  interfaces Z_IN_UTF_LOG .

  class-methods GET_PARAMETER_VALUE
    importing
      !IV_FEATURE_ID type ZFAM_FEATURE_ID
      !IV_PARAMETER_NAME type ZFAM_PARAMETER
      !IV_CRITERIA1_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA1_VALUE type ANY default SPACE
      !IV_CRITERIA2_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA2_VALUE type ANY default SPACE
      !IV_CRITERIA3_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA3_VALUE type ANY default SPACE
      !IV_CRITERIA4_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA4_VALUE type ANY default SPACE
      !IV_CRITERIA5_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA5_VALUE type ANY default SPACE
    exporting
      !EV_VALUE type ZFAM_PARAMETER_VALUE
      !EV_SUBRC type SYSUBRC .
  class-methods GET_PARAMETER_VALUES
    importing
      !IV_FEATURE_ID type ZFAM_FEATURE_ID
      !IV_PARAMETER_NAME type ZFAM_PARAMETER optional
      !IV_CRITERIA1_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA1_VALUE type ANY default SPACE
      !IV_CRITERIA2_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA2_VALUE type ANY default SPACE
      !IV_CRITERIA3_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA3_VALUE type ANY default SPACE
      !IV_CRITERIA4_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA4_VALUE type ANY default SPACE
      !IV_CRITERIA5_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA5_VALUE type ANY default SPACE
    exporting
      !ET_RESULTS type ZFAM_T_PARAMETER_RESULTS
      !EV_SUBRC type SYSUBRC .
  class-methods IS_ACTIVE
    importing
      !IV_FEATURE_ID type ZFAM_FEATURE_ID
      !IV_CRITERIA1_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA1_VALUE type ANY default SPACE
      !IV_CRITERIA2_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA2_VALUE type ANY default SPACE
      !IV_CRITERIA3_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA3_VALUE type ANY default SPACE
      !IV_CRITERIA4_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA4_VALUE type ANY default SPACE
      !IV_CRITERIA5_NAME type ZFAM_CRITERIA default SPACE
      !IV_CRITERIA5_VALUE type ANY default SPACE
    returning
      value(RV_SUBRC) type SYSUBRC .