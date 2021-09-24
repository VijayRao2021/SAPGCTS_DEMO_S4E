class ZE2E_CO_VALIDATION_CHECK_WS definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

*"* public components of class ZE2E_CO_VALIDATION_CHECK_WS
*"* do not include other source files here!!!
public section.

  methods CLEAN_AND_FLUSH
    importing
      !INPUT type ZE2E_CLEAN_AND_FLUSH1
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods GET_OUTPUT_COUNT_FROM_EAI
    importing
      !INPUT type ZE2E_GET_OUTPUT_COUNT_FROM_EA2
    exporting
      !OUTPUT type ZE2E_GET_OUTPUT_COUNT_FROM_EA1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods GET_VALIDATION_STATUS
    importing
      !INPUT type ZE2E_GET_VALIDATION_STATUS1
    exporting
      !OUTPUT type ZE2E_GET_VALIDATION_STATUS_RE1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods GET_VALIDATION_STATUS_BY_PROPE
    importing
      !INPUT type ZE2E_GET_VALIDATION_STATUS_BY5
    exporting
      !OUTPUT type ZE2E_GET_VALIDATION_STATUS_BY4
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods GET_VALIDATION_STATUS_BY_STEP
    importing
      !INPUT type ZE2E_GET_VALIDATION_STATUS_BY6
    exporting
      !OUTPUT type ZE2E_GET_VALIDATION_STATUS_BY3
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods OPR_VALIDATION_CHECK
    importing
      !INPUT type ZE2E_OPR_VALIDATION_CHECK1
    exporting
      !OUTPUT type ZE2E_OPR_VALIDATION_CHECK_RES1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods OPR_VALIDATION_CHECK_LIST
    importing
      !INPUT type ZE2E_OPR_VALIDATION_CHECK_LIS2
    exporting
      !OUTPUT type ZE2E_OPR_VALIDATION_CHECK_LIS1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .