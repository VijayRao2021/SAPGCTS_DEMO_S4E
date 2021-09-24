protected section.

  aliases IS_USED
    for Z_IN_CORE_COMMUNICATION~IS_USED .
  aliases PROCESSING_STATUS_UPDATED
    for Z_IN_CORE_COMMUNICATION~PROCESSING_STATUS_UPDATED .
  aliases SEND_LOG
    for Z_IN_UTF_LOG~SEND_LOG .

  data MV_OBJECT_ID type ZCORE_OBJECT_ID .
  data MV_MODULE_ID type ZCORE_MODULE_ID .
  data MV_FLG_CHANGED type FLAG .

    "! <p class="shorttext synchronized" lang="en">Return the ID of current object</p>
    "!
  methods GET_OBJECT_ID
    returning
      value(RV_OBJECT_ID) type ZCORE_OBJECT_ID .
  methods COMPLETE_PROCESSING
    importing
      !IV_OBJECT_ID type ZCORE_OBJECT_ID .
  methods PROCESS_PROCESSING_STATUS_UPD
    for event PROCESSING_STATUS_UPDATED of Z_IN_CORE_COMMUNICATION
    importing
      !IV_OBJECT_ID
      !IV_STATUS .
  methods RAISE_LOG
    importing
      !IV_GROUP type STRING
      !IV_LEVEL type I
      !IV_TYPE type C default 'I'
      !IV_MSGID type SYMSGID default SPACE
      !IV_MSGNO type SYMSGNO default 0
      !IV_MSG1 type ANY default SPACE
      !IV_MSG2 type ANY default SPACE
      !IV_MSG3 type ANY default SPACE
      !IV_MSG4 type ANY default SPACE
      !IV_MSG5 type ANY default SPACE
      !IV_PUT_AT_END type C default 'X' .
  methods PROCESS_IS_USED
    for event IS_USED of Z_IN_CORE_COMMUNICATION
    importing
      !IV_MODULE_ID
      !IV_OBJECT_ID .
  methods SAVE
    returning
      value(RV_SUBRC) type SYSUBRC .