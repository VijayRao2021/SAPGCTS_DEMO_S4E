class Z_CL_UTF_E2E_INTERFACE_AUDIT definition
  public
  final
  create public .

*"* public components of class Z_CL_UTF_E2E_INTERFACE_AUDIT
*"* do not include other source files here!!!
public section.

  interfaces Z_IN_UTF_LOG .

  methods CHECK_DUPLICATE .
  methods GET_EAI_VALIDATION .
*  methods GET_EAI_VALIDATION
*    importing
*      !IT_INTERFACE_ID type ZETOE_TR_INTERFACE_ID_RANGE .
  methods WS_GET_EAI_VALIDATION_STATUS
    importing
      !IV_INTERFACE_ID type ZETOE_INTERFACE_ID
      !IV_UNIQUE_ID type ZETOE_UNIQUE_ID
    exporting
      value(EV_SUBRC) type I
      !EV_OUTPUT_COUNTER type I .
  methods WS_CLEAN_AND_FLUSH
    importing
      !IV_PROXY_TO_FLUSH type C default SPACE
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods WS_CREATE
    importing
      !IV_INTERFACE_ID type ZETOE_INTERFACE_ID
      !IV_UNIQUE_ID type ZETOE_UNIQUE_ID
      !IV_STEP_ID type ZETOE_STEP_ID
      !IV_COMMENT type ZETOE_COMMENT
      !IV_PROPERTY_NAME type ZETOE_PROPERTY_NAME default SPACE
      !IV_PROPERTY_VALUE type ANY default SPACE
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods WS_ENABLE_DISABLE_WS
    importing
      !IV_FLAG type C .
  methods WS_GET_UNIQUE_ID
    returning
      value(RV_UNIQUE_ID) type ZUNIQUE_ID .
  methods WS_SEND_AUDIT_DATA
    importing
      !IV_STEP_ID type ZETOE_STEP_ID
      !IV_COMMENT type ZETOE_COMMENT
      !IS_AUDIT_DATA type Z1ZAUDIT
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods WS_SEND_STATUS_AUDIT_DATA
    importing
      !IS_AUDIT_DATA_RECEIVED type Z1ZAUDIT
      !IS_AUDIT_DATA_CALCULATED type Z1ZAUDIT .
  methods WS_VALIDATION_CHECK
    importing
      !IV_INTERFACE_ID type ZETOE_INTERFACE_ID
      !IV_UNIQUE_ID type ZETOE_UNIQUE_ID
      !IV_COMMENT type ZETOE_COMMENT
      !IV_PROPERTY_NAME type ZETOE_PROPERTY_NAME
      !IV_STATUS type ZETOE_STATUS
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods ANALYZE_INTERFACES .
  methods CONSTRUCTOR
    importing
      !IV_DISABLE_WS type C default SPACE
      !IV_MODE type C default SPACE
    preferred parameter IV_DISABLE_WS
    exceptions
      CANT_CREATE_WS_PROXY .
  methods LOAD_NEW_IDOCS
    importing
      !IT_IDOCS type EDIDC_TT .
  methods LOAD_RECYCLED_IDOCS .
  methods SET_INTERFACE_ID_TO_CHECK
    importing
      !IT_INTERFACE_ID type ZETOE_TR_INTERFACE_ID_RANGE .