class Z_CL_BC_OUTBOUND_INTERFACE definition
  public
  final
  create public .

public section.

  interfaces Z_IN_UTF_LOG .

  methods UPDATE
    exceptions
      CANNOT_UPDATE .
  methods GET_DETAIL
    exporting
      value(ES_INTERFACE_DETAIL) type ZFI_INTER_OUT
    exceptions
      CANT_FOUND_INTERFACE .
  methods CONSTRUCTOR
    importing
      !IV_INTERFACE_ID type ZINTERFACE_ID
      !IV_VARIANT_NAME type RALDB_VARI default SPACE
      !IV_MESTYP type EDI_MESTYP default SPACE
      !IV_MESCOD type EDI_MESCOD default SPACE
      !IV_MESFCT type EDI_MESFCT default SPACE
      !IV_CATCHUP_MODE type FLAG default SPACE
      !IV_TEST_MODE type FLAG default SPACE
      !IV_MODE type CHAR1 default 'T'
      !IV_DATE_FROM type SYDATUM optional
      !IV_TIME_FROM type SYUZEIT optional
      !IV_DATE_TO type SYDATUM optional
      !IV_TIME_TO type SYUZEIT optional
      !IV_SHIFT_TIME type NUMERIC optional .
  class-methods FACTORY
    importing
      !IV_INTERFACE_ID type ZINTERFACE_ID
      !IV_VARIANT_NAME type RALDB_VARI default SPACE
      !IV_MESTYP type EDI_MESTYP default SPACE
      !IV_MESCOD type EDI_MESCOD default SPACE
      !IV_MESFCT type EDI_MESFCT default SPACE
      !IV_CATCHUP_MODE type FLAG default SPACE
      !IV_TEST_MODE type FLAG default SPACE
      !IV_MODE type CHAR1 default 'T'
      !IV_DATE_FROM type SYDATUM optional
      !IV_TIME_FROM type SYUZEIT optional
      !IV_DATE_TO type SYDATUM optional
      !IV_TIME_TO type SYUZEIT optional
    returning
      value(RO_DELTA_MANAGER) type ref to Z_CL_BC_OUTBOUND_INTERFACE .