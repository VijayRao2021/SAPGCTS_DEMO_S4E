class ZE2E_CO_E2EAUDIT_WS definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

*"* public components of class ZE2E_CO_E2EAUDIT_WS
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
  methods CREATE
    importing
      !INPUT type ZE2E_CREATE1
    exporting
      !OUTPUT type ZE2E_CREATE_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT
      ZE2E_CX_THROWABLE
      CX_AI_APPLICATION_FAULT .
  methods GET_UNIQUE_ID
    importing
      !INPUT type ZE2E_GET_UNIQUE_ID1
    exporting
      !OUTPUT type ZE2E_GET_UNIQUE_ID_RESPONSE1
    raising
      CX_AI_SYSTEM_FAULT
      ZE2E_CX_THROWABLE
      CX_AI_APPLICATION_FAULT .
  methods MERGE_PROPERTY_VALUE
    importing
      !INPUT type ZE2E_MERGE_PROPERTY_VALUE1
    exporting
      !OUTPUT type ZE2E_MERGE_PROPERTY_VALUE_RES1
    raising
      CX_AI_SYSTEM_FAULT
      ZE2E_CX_THROWABLE
      CX_AI_APPLICATION_FAULT .