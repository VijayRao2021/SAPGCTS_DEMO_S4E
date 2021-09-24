class ZCL_BC_REPORT_MANAGEMENT definition
  public
  final
  create public .

*"* public components of class ZCL_BC_REPORT_MANAGEMENT
*"* do not include other source files here!!!
public section.

  methods ADD_BLOCK
    importing
      !IV_BLOCK_NAME type C
      !IT_DATAS_BLOCK type STANDARD TABLE
      !IV_REPLACE type C default ''
      !IV_ENDLINETYPE type C default 'W'
    exceptions
      ALREADY_EXISTS .
  methods BEGIN
    importing
      !IV_BLOCK_NAME type C default 'REPORT'
    exceptions
      ALREADY_EXISTS .
  methods END
    importing
      !IV_BLOCK_NAME type C default 'REPORT' .
  methods GET_AND_PARSE_REPORT
    importing
      !IV_BLOCK_NAME type C default 'REPORT'
      !IV_IND_MULTI_BLOCK type C default SPACE
    exceptions
      CANT_GET_REPORT .
  methods GET_BLOCK
    importing
      !IV_BLOCK_NAME type C default 'REPORT'
      !IV_FORMAT type SO_OBJ_TP default SPACE
    exporting
      !ET_LIST type STANDARD TABLE
    exceptions
      BLOCK_DOESNT_EXIST .