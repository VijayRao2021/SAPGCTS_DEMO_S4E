*----------------------------------------------------------------------*
* PROGRAM ID        : ZUTF_HTML_MAIL_DEMO                              *
* TITLE             : UTF HTML Email - Demo                            *
* PROGRAM TYPE      : Demo                                             *
* SUBMITTING        : None                                             *
* DEPENDENCY        : Class Z_CL_UTF_CUSTOM_PROGRAM,Z_CL_UTF_HTML_MAIL *
* TABLE UPDATES     : None                                             *
* PROGRAM EXECUTION : N/A                                              *
* SPECIAL LOGIC     : None                                             *
* INCLUDES          : N/A                                              *
* JIRA  Call NO     : Symphony Project                                 *
* CREATION DATE     : 17-SEP-2021                                      *
* PROGRAMMER        : PRASHANTH NAGARAJ(NAGARAP)                       *
* DESIGNER          : PRASHANTH NAGARAJ(NAGARAP)                       *
* TCODE             : N/A                                              *
* RELEASE           : Developed on S4HANA 2020                         *
* OWNERSHIP         : This ABAP code must not be reproduced in whole or*
*                     in part. It must not be used except with the     *
*                     prior written consent of UMG. UMG retains all    *
*                     Intellectual Property Rights                     *
*----------------------------------------------------------------------*
* DESCRIPTION       :                                                  *
*     PURPOSE                                                          *
*      1. To explain the features & use of HTML Mail UTF class         *
*         Z_CL_UTF_HTML_MAIL                                           *
*                                                                      *
*      SELECTION                                                       *
*        1. N/A                                                        *
*        2.                                                            *
*        3.                                                            *
*      OUTPUT                                                          *
*        1. Mail                                                       *
*        2. Logs                                                           *
*----------------------------------------------------------------------*
*                       AUTHORIZATION CHECKS                           *
*----------------------------------------------------------------------*
* OBJECT              | AUTHORITY FIELDS       |  ABAP FIELDS          *
*--------------------- ------------------------ -----------------------*
*                     |                        |                       *
*----------------------------------------------------------------------*
*                         PREREQUISITES/ ASSUMPTIONS                   *
* 1. Email variant and configuration is set in cluster                 *
*    Z_MAIL_CONFIGURATION                                              *
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
*                 CHANGE HISTORY (M O D I F I C A T I O N  L O G)      *
*----------------------------------------------------------------------*
*   DATE     | NAME     | DESCRIPTION                     | Transport #*
*----------------------------------------------------------------------*
* 17-SEP-21  | NAGARAP  | Original Design                 | SD1K900098 *
*            |          |                                 |            *
*            |          |                                 |            *
*            |          |                                 |            *
************************************************************************
REPORT zutf_custom_program_template MESSAGE-ID 00.

*----------------------------------------------------------------------*
*     LOCAL CLASS DEFINITION                                           *
*----------------------------------------------------------------------*
CLASS lcl_main DEFINITION INHERITING FROM z_cl_utf_custom_program CREATE PUBLIC.

  PUBLIC SECTION.

    METHODS :
      start       REDEFINITION,
      report      REDEFINITION,
      constructor,
      get_attachment_data RETURNING VALUE(ro_attachment_data_ref) TYPE REF TO data,
      get_body_html       RETURNING VALUE(rv_body_html) TYPE string.

  PROTECTED SECTION.


  PRIVATE SECTION.
    DATA: attachment_table TYPE ty_scarr.

ENDCLASS.

*----------------------------------------------------------------------*
*    LOCAL CLASS IMPLEMENTATION                                        *
*----------------------------------------------------------------------*
CLASS lcl_main IMPLEMENTATION.

  METHOD get_attachment_data.

" The internal table which needs to be attached as XLSX needs to be constructed here and pointed to a Data reference object

    " Get table type
    DATA(lo_table_type) = cl_abap_tabledescr=>create(
                               p_line_type = CAST #( cl_abap_structdescr=>describe_by_name( 'TY_SCARR' ) ) ).
    " Create Data Object
    CREATE DATA ro_attachment_data_ref TYPE HANDLE lo_table_type.
    " Point the local itab to the reference object
    GET REFERENCE OF attachment_table INTO ro_attachment_data_ref.


    " Fill the itab which needs to be attached
    SELECT * FROM scarr UP TO 10 ROWS
      INTO TABLE attachment_table.
    IF sy-subrc <> 0.
    " Information message?
    ENDIF.

  ENDMETHOD.

  METHOD get_body_html.
    " Imagine that this is written inside <body></body> tags. You can use any HTML tags to design your body
    rv_body_html = |Dear User,| &&
                   |<br><br>This is a <u>test mail</u> for the purpose of <b>DEMO</b>.| &&
                   |<br> Imagine you are writing HTML inside the body tags.| &&
                   |<br><br>Regards,<br>Support Team|.
  ENDMETHOD.
  METHOD constructor.
    " Enable framework instantiation using the constructor. Here we are instantiating Log and Email object
    super->constructor( i_enable_log_fw        = VALUE logger_parameter( enable       = abap_true
                                                                         al_object    = 'ZMIG'
                                                                         al_subobject = 'ARUN'
                                                                         al_extnumber = '0123456789' )
                        i_enable_html_email_fw = abap_true ).

    " Setting log level to 5. (Possible levels 0 to 5)
    logger->set_log_level( 5 ).
    SET HANDLER logger->add_log.
  ENDMETHOD.

  METHOD start.

    " Trigger mail using the Email Configuration Object (Table ZBC_MAIl_PROGRAM).
    " Also, pass the body and attachment constructed in the program
    DATA(results) = html_email->send_mail_html( iv_program             = sy-repid
                                                iv_variant             = 'DEFAULT'
                                                iv_body                = get_body_html( )
                                                iv_attachment_data_ref = get_attachment_data( )
                                                iv_mail_type           = 'A' ).


    " If the results are empty, it means all the configured mails are sent successfully.
    " Results are filled only in case of errors.
    LOOP AT results REFERENCE INTO DATA(result).

      " Error handler object from the respective exception class is given as a result.
      " 1. Get the source line and program namefrom the Error handler object.
      " 2.The result table will also have other information like mail configuration, message type for information.
      result->error_handler->get_source_position( IMPORTING program_name = DATA(program_name)
                                                            source_line  = DATA(source_line) ).

      MESSAGE result->error_handler TYPE 'S' DISPLAY LIKE 'E' .
      logger->raise_log_message( iv_group = ''
                                 iv_level = 0
                                 iv_type = result->msgty
                                 iv_msg1 = 'Exception Raised at'(i01)
                                 iv_msg2 = |{ program_name }/{ source_line }|
                                 iv_msg3 = |for mail config { result->program }|
                                 iv_msg4 = |/{ result->configuration }| ).
      CLEAR: program_name, source_line.
    ENDLOOP.

    IF results IS INITIAL.
      MESSAGE s398 WITH 'Mail sent successfully'(i02).
      logger->raise_log_message( iv_group = ''
                                 iv_level = 0
                                 iv_type = 'S'
                                 iv_msg1 = 'Mail sent successfully'(i02) ).
    ENDIF.

  ENDMETHOD.

  METHOD report.

    " Save and display logs
    logger->dispatch_log( ).

  ENDMETHOD.

ENDCLASS.




*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*
  " Local object instantiation
  DATA(go_main) = NEW lcl_main( ).

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  go_main->start( ).

*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*
  go_main->report( ).