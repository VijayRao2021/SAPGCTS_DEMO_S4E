class Z_CL_UTF_MAIL definition
  public
  create public .

*"* public components of class ZCL_BC_MAIL
*"* do not include other source files here!!!
public section.

  methods ADD_ATTACHMENT
    importing
      !IV_FORMAT type SO_OBJ_TP
      !IV_SUBJECT type SO_OBJ_DES
      !IT_CONTENT type SOLI_TAB .
  methods CREATE
    importing
      !IV_TYPE type SO_OBJ_TP
      !IV_SUBJECT type SO_OBJ_DES
      !IT_BODY type SOLI_TAB
    exporting
      !ET_LOG type TABLE_OF_STRINGS .
  methods SEARCH_MAIL_ADDRESS
    importing
      !IS_RECIPIENT type ZBC_MAIL_EMAIL_ADDRESS_LINE
    exporting
      !ET_RECIPIENTS type ZBC_MAIL_EMAIL_ADDRESS_TABLE .
  methods SEND
    importing
      !IV_SENDER type AD_SMTPADR
      !IV_DISPLAY_NAME type AD_SMTPADR
      !IT_RECIPIENTS type ZBC_MAIL_EMAIL_ADDRESS_TABLE
      !IV_EXPRESS type OS_BOOLEAN default SPACE
      !IV_IMMEDIATELY type OS_BOOLEAN default SPACE
    exporting
      !ET_LOG type TABLE_OF_STRINGS .
  methods SEND_MAIL_PORTAL
    importing
      !IV_PROGRAM type PROGRAMM
      !IV_VARIANT type RALDB_VARI
      !IO_BLOCK type ref to ZCL_BC_REPORT_MANAGEMENT
      !IV_SUBJECT_VARIABLE1 type ANY default SPACE
      !IV_SUBJECT_VARIABLE2 type ANY default SPACE .
  methods GET_RECIPIENTS
    importing
      !IS_MAIL_HEADER type ZBC_MAIL_HEADER
    exporting
      !ET_RECIPIENTS type ZBC_MAIL_EMAIL_ADDRESS_TABLE .