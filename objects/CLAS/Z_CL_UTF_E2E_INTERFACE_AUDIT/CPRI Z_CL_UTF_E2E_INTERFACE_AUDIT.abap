private section.

  aliases SEND_LOG
    for Z_IN_UTF_LOG~SEND_LOG .

  constants C_POSTPROC_COND_ALWAYS type STRING value 'ALWAYS' ##NO_TEXT.
  data MT_AUDIT_CUST type TT_AUDIT_CUST .
  data MT_POSTPROCESSING type TT_POSTPROCESSING .
  data MT_POSTPROC_EVENT type TT_POSTPROC_EVENT .
  data MT_DUPLICATE_CONTROL_INT type TT_DUPLICATE_CONTROL_INT .
  data MV_ERROR_WS_CONN_FAILED type ZETOE_ERROR .
  constants C_MODE_ANALYSIS type C value 'A' ##NO_TEXT.
  constants C_MODE_PREPROCESSING type C value 'P' ##NO_TEXT.
  data MO_E2E_VALIDATION_WS_PROXY type ref to ZE2E_CO_VALIDATION_CHECK_WS .
  data MV_MODE type C .
  data MV_WS_CALL type C .
  data MO_E2E_WS_PROXY type ref to ZE2E_CO_E2EAUDIT_WS .
  data MT_INTERFACES type TT_INTERFACES .
  data MT_INTERFACE_ID_TO_CHECK type ZETOE_TR_INTERFACE_ID_RANGE .

  methods IS_WAIT_TIME_EXPIRED
    importing
      !IR_INTERFACE type ref to TS_INTERFACE
    returning
      value(RV_ANSWER) type SYSUBRC .
  methods POSTPROC_RAISE_EVENT
    importing
      !IS_POSTPROC_PARAM type ZBC_AUDIT_POSTPROC_PARAMETER .
  methods POSTPROC_START
    importing
      !IR_INTERFACE type ref to TS_INTERFACE
      !IV_CALLPOINT type STRING .
  methods UPDATE_IDOCS_STATUS
    importing
      !IR_INTERFACE type ref to TS_INTERFACE
      !IV_NEW_STATUS type EDI_STATUS
      !IS_IDOC_STATUS type BDIDOCSTAT optional .
  methods CHECK_IDOCS
    importing
      !IR_INTERFACE type ref to TS_INTERFACE
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods IDOCS_RECYCLING_MANAGEMENT .
  methods CHECK_IDOCS_STATUS
    importing
      !IR_INTERFACE type ref to TS_INTERFACE
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods CHECK_NUMBER_DOCUMENTS
    importing
      !IR_INTERFACE type ref to TS_INTERFACE
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods RECONCILE_DATA
    importing
      !IR_INTERFACE type ref to TS_INTERFACE .