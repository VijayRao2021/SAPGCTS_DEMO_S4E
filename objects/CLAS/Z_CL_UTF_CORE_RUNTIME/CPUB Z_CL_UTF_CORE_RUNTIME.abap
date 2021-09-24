class Z_CL_UTF_CORE_RUNTIME definition
  public
  inheriting from Z_CL_UTF_MODULE
  create public .

public section.
  type-pools ABAP .

  methods CONSTRUCTOR
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
      !IV_COUNTRY type LAND1 default SPACE
      !IV_MANAGE_LOG type FLAG default ABAP_FALSE .
  methods CREATE
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
      !IV_COUNTRY type LAND1 default SPACE
    returning
      value(RV_SUBRC) type SYSUBRC .
  class-methods GET_RUNTIME .
  methods LOAD .
  methods UPDATE_STATUS
    importing
      !IV_STATUS type ZRUN_STATUS .