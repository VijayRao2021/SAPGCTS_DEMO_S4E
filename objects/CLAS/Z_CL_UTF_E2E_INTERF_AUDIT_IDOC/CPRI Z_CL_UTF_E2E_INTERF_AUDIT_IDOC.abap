*"* private components of class Z_CL_UTF_E2E_INTERF_AUDIT_IDOC
*"* do not include other source files here!!!
private section.

  aliases SEND_LOG
    for Z_IN_UTF_LOG~SEND_LOG .

  data MV_ALREADY_RECEIVED type BOOL .
  data MV_AUDITABLE type BOOL .
  data MS_AUDIT_RECORD type Z1ZAUDIT .
  data MT_DATAS type TAB_EDIDD .
  class-data GT_CALCULATION_CUSTOMIZING type TT_CALCULATION_CUSTOMIZING .
  data MS_CONTROL_RECORD type EDIDC .
  data MT_STATUS_RECORDS type TT_EDIDS .

  methods CALCULATE_AUDIT_DATA_CNT_DOC
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_GOODSMVT
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_INVOIC
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_PIPS012
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_PIPS014
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_CRED_LIM
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_FI_DOC
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_ROY_EARN
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods CALCULATE_AUDIT_DATA_CA008
    importing
      !IS_CONFIGURATION type TS_CALCULATION_CUSTOMIZING
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT .
  methods GET_IDOC_STATUS_DETAIL
    returning
      value(RS_EDIDS) type EDIDS .