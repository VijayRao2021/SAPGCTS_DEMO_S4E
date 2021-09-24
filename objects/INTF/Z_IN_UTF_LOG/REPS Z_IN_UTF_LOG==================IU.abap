interface Z_IN_UTF_LOG
  public .


  class-events SEND_LOG
    exporting
      value(IV_GROUP) type STRING
      value(IV_LEVEL) type I
      value(IV_TYPE) type C default 'I'
      value(IV_MSGID) type SYMSGID default SPACE
      value(IV_MSGNO) type SYMSGNO default 0
      value(IV_MSG1) type ANY default SPACE
      value(IV_MSG2) type ANY default SPACE
      value(IV_MSG3) type ANY default SPACE
      value(IV_MSG4) type ANY default SPACE
      value(IV_MSG5) type ANY default SPACE
      value(IV_PUT_AT_END) type C default 'X' .
endinterface.