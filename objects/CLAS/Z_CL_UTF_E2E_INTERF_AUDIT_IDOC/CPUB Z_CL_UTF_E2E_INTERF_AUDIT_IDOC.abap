class Z_CL_UTF_E2E_INTERF_AUDIT_IDOC definition
  public
  final
  create public .

*"* public components of class Z_CL_UTF_E2E_INTERF_AUDIT_IDOC
*"* do not include other source files here!!!
public section.

  interfaces Z_IN_UTF_LOG .

  methods IS_ALREADY_RECEIVED
    returning
      value(RV_RC) type SYSUBRC .
  methods GET_CONTROL_RECORD
    returning
      value(RS_CONTROL_RECORD) type EDIDC .
  methods GET_TIMESTAMP
    exporting
      !EV_TIME type ERZEIT
      !EV_DATE type ERDAT .
  methods SET_STATUS
    importing
      !IV_NEW_STATUS type EDI_STATUS
      !IS_IDOC_STATUS type BDIDOCSTAT optional .
  methods CALCULATE_AUDIT_DATA
    changing
      !CS_AUDIT_DATA type Z1ZAUDIT
    exceptions
      METHOD_NOT_CONFIGURED .
  methods CONSTRUCTOR
    importing
      !IV_DOCNUM type EDI_DOCNUM optional
      !IS_EDIDC type EDIDC optional .
  methods GET_INTERFACE_AUDIT_CONTROL
    returning
      value(RS_AUDIT_CONTROL) type Z1ZAUDIT
    exceptions
      IDOC_NOT_AUDITABLE .
  methods GET_INTERFACE_UNIQUE_ID
    returning
      value(RV_UNIQUE_ID) type ZUNIQUE_ID
    exceptions
      IDOC_NOT_AUDITABLE .
  methods GET_DOCNUM
    returning
      value(RV_DOCNUM) type EDI_DOCNUM .
  methods IS_AUDITABLE
    returning
      value(RV_RETURNCODE) type I .
  methods GET_STATUS
    returning
      value(RV_STATUS) type EDI_STATUS .
  methods IS_FAILED
    returning
      value(RV_RETURNCODE) type SYSUBRC .
  methods IS_PROCESSED
    returning
      value(RV_RETURNCODE) type SYSUBRC .