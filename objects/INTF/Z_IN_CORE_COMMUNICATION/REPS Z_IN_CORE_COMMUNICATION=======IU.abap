interface Z_IN_CORE_COMMUNICATION
  public .


  class-events PROCESSING_STATUS_UPDATED
    exporting
      value(IV_OBJECT_ID) type ZCORE_OBJECT_ID
      value(IV_STATUS) type ZRUN_STATUS .
  class-events HAS_SAVED .
  class-events IS_USED
    exporting
      value(IV_MODULE_ID) type ZCORE_MODULE_ID
      value(IV_OBJECT_ID) type ZCORE_OBJECT_ID .
  class-events GET_DATA .
  class-events SEND_DATA
    exporting
      value(IV_MESSAGE_TYPE) type STRING optional
      value(IR_MESSAGE_DATA) type ref to DATA optional .
endinterface.