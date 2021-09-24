private section.

  aliases SEND_LOG
    for Z_IN_UTF_LOG~SEND_LOG .

  data MS_INTERFACE_DETAIL type ZFI_INTER_OUT .
  data MV_CATCHUP_MODE type FLAG .
  data MV_TEST_MODE type FLAG .

  methods DEFINE_TIME_MODE_RANGE
    importing
      !IV_INTERFACE_ID type ZINTERFACE_ID
      !IV_VARIANT_NAME type RALDB_VARI default SPACE
      !IV_MESTYP type EDI_MESTYP default SPACE
      !IV_MESCOD type EDI_MESCOD default SPACE
      !IV_MESFCT type EDI_MESFCT default SPACE
      !IV_CATCHUP_MODE type FLAG default SPACE
      !IV_DATE_FROM type SYDATUM optional
      !IV_TIME_FROM type SYUZEIT optional
      !IV_DATE_TO type SYDATUM optional
      !IV_TIME_TO type SYUZEIT optional
      !IV_SHIFT_TIME type NUMERIC optional .
  methods DEFINE_DAY_MODE_RANGE
    importing
      !IV_INTERFACE_ID type ZINTERFACE_ID
      !IV_VARIANT_NAME type RALDB_VARI default SPACE
      !IV_MESTYP type EDI_MESTYP default SPACE
      !IV_MESCOD type EDI_MESCOD default SPACE
      !IV_MESFCT type EDI_MESFCT default SPACE
      !IV_CATCHUP_MODE type FLAG default SPACE
      !IV_DATE_FROM type SYDATUM optional
      !IV_DATE_TO type SYDATUM optional .