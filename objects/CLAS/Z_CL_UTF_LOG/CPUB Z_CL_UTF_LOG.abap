class Z_CL_UTF_LOG definition
  public
  final
  create public .

*"* public components of class Z_CL_UTF_LOG
*"* do not include other source files here!!!
*"* protected components of class Z_CL_UTF_LOG
*"* do not include other source files here!!!
public section.

  interfaces Z_IN_UTF_LOG .

  aliases RAISE_LOG
    for Z_IN_UTF_LOG~SEND_LOG .

  methods CONFIGURE
    importing
      !IV_PROGNAM type PROGRAMM default SY-REPID
      !IV_VARIANT type RALDB_VARI default SPACE
      !IV_AL_EXTNUMBER type ANY default SPACE .
  methods DISPATCH_LOG .
  methods REFRESH .
  class-methods RAISE_LOG_MESSAGE
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
  methods LOAD .
  methods SAVE .
  methods SEND_MAIL
    importing
      !IV_PRINT_DATE type C default SPACE
      !IV_PRINT_HOUR type C default SPACE
      !IV_PRINT_GROUP type C default SPACE
      !IV_PRINT_MSGTYPE type C default SPACE
      !IV_PRINT_LEVEL type C default SPACE
      !IV_SEPARATOR type C default SPACE
      !IV_GROUP type STRING default SPACE
      !IV_ONLY_ERROR type C default SPACE
      !IV_PROGRAM type PROGRAMM optional
      !IV_VARIANT type RALDB_VARI default SPACE
      !IV_BLOCK type Z_BC_MAIL_BLOCK default 'BODY'
      !IO_BLOCKS type ref to ZCL_BC_REPORT_MANAGEMENT optional
      !IV_SUBJECT_VARIABLE1 type ANY default SPACE
      !IV_SUBJECT_VARIABLE2 type ANY default SPACE .
  methods ADD_LOG
    for event SEND_LOG of Z_IN_UTF_LOG
    importing
      !IV_GROUP
      !IV_LEVEL
      !IV_TYPE
      !IV_MSGID
      !IV_MSGNO
      !IV_MSG1
      !IV_MSG2
      !IV_MSG3
      !IV_MSG4
      !IV_MSG5
      !IV_PUT_AT_END .
  methods CONFIGURE_GROUP
    importing
      !IV_GROUP type STRING
      !IV_LEVEL type I
      !IV_DISPLAY type C default 'X'
      !IV_AL_OBJECT type BALOBJ_D default SPACE
      !IV_AL_SUBOBJECT type BALSUBOBJ default SPACE
      !IV_MODE type C default 'U'
      !IV_AL_EXTNUMBER type ANY default SPACE
      !IV_LOAD_LOG type C default SPACE .
  methods CONSTRUCTOR
    importing
      !IV_LEVEL type I default 0
      !IV_AL_OBJECT type BALOBJ_D default SPACE
      !IV_AL_SUBOBJECT type BALSUBOBJ default SPACE
      !IV_AL_EXTNUMBER type BALNREXT default SPACE .
  methods GET_LOG
    importing
      !IV_GROUP type STRING optional
    exporting
      !ET_LOG type ZLOG_LOG_TABLE .
  methods SET_LOG_LEVEL
    importing
      !IV_LEVEL type I
      !IV_GROUP type STRING default SPACE .
  methods WRITE_LOG
    importing
      !IV_GRID type BALUSEGRID default 'X'
      !IV_FULLSCREEN type C default 'X' .
  class-methods FACTORY
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
    returning
      value(RO_LOG) type ref to Z_CL_UTF_LOG .