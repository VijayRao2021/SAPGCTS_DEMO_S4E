*&---------------------------------------------------------------------*
*& Report  ZES046_FILE_TRANSFER
*-----------------------------------------------------------------------
* Program       : ZES046_FILE_TRANSFER
* Title         : Create FTP transfer program for ES046
* Author        : Gopala Krishna Kanugolu / KANUGOG
* Date          : 03.01.2018
* Consultant    : Cresson, David
* GAP number    : 2974
* Sap Original  : n.r.
*-----------------------------------------------------------------------
* Description
* Create FTP file transfer program for interface ES046
*-----------------------------------------------------------------------
* Update functionality
*   none
*-----------------------------------------------------------------------
* Modification Protocol
* No.    Date        Author                      	      Transp.Requ.
*-----------------------------------------------------------------------
* GAP-3397 11/09/2020 D.CRESSON
* Implementation of a resending feature based on delta logic for the process ID
* which is using it like ES048* processes ID
************************************************************************
REPORT zutf_file_transfer MESSAGE-ID zfi_enhancements.

TABLES:
  zfile_transfer.

*** Global variables declaration
DATA:gv_file_extern TYPE filename-fileextern ##NEEDED,  " Files to be processed
     gv_process_id  TYPE zproc_process_id    ##NEEDED.  " Runtime process id

DATA:
      go_log TYPE REF TO z_cl_utf_log           ##NEEDED.  " Log class reference
*-Begin of GAP-3397+
##NEEDED DATA:gv_date_range TYPE zoutmngt_date_range,
              gv_time_range TYPE zoutmngt_time_range.
*-End of GAP-3397+

***Constants declaration
CONSTANTS:"gc_m1     TYPE char3 VALUE 'M1',                                 " Screen group M1
  gc_email  TYPE char3 VALUE 'EMA',                                 " Screen group for email option
  gc_resend TYPE char3 VALUE 'RES',                                 " Screen group for resend option
  gc_delta  TYPE char3 VALUE 'DEL'. "Resend mode with delta "GAP-3397+
*** selection screen Design
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_proces FOR zfile_transfer-process_id OBLIGATORY NO INTERVALS DEFAULT 'ES046'. " Process Id
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_resind TYPE rfpdo1-umsvtrud USER-COMMAND uc1.            " checkbox to resend files
PARAMETERS: p_folder TYPE string DEFAULT 'ARCHIVE' MODIF ID res.
SELECT-OPTIONS: s_file FOR gv_file_extern NO INTERVALS MODIF ID res.                 " File(s) name to be send to FTP
PARAMETERS:p_dpchk TYPE rfpdo1-umsvtrud MODIF ID res.
*-Begin of GAP-3397+
PARAMETERS: p_resend TYPE zoutmngt_resend_mode AS CHECKBOX DEFAULT space USER-COMMAND uc1.
SELECT-OPTIONS: s_udate FOR gv_date_range NO-EXTENSION MODIF ID del,
                s_utime FOR gv_time_range NO-EXTENSION MODIF ID del.
*-End of GAP-3397+
PARAMETERS: p_email  AS CHECKBOX USER-COMMAND uc1,
            p_varian TYPE raldb_vari DEFAULT 'DEFAULT' MODIF ID ema.
SELECTION-SCREEN END OF BLOCK b02.

*-Begin of GAP-3397+
INITIALIZATION.
  CLEAR s_udate.
  s_udate-sign = 'I'.
  s_udate-option = 'BT'.
  s_udate-low = sy-datum.
  s_udate-high = sy-datum.
  APPEND s_udate.
  CLEAR s_utime.
  s_utime-sign = 'I'.
  s_utime-option = 'BT'.
  s_utime-high = sy-uzeit.
  APPEND s_utime.
*-End of GAP-3397+

AT SELECTION-SCREEN OUTPUT.
* Selections hide;/unhide
  PERFORM screen_output.

*Starting point of program execution
START-OF-SELECTION.
*-Initialize application log
  CREATE OBJECT go_log.
* Set max level to 5.
  go_log->set_log_level( 5 ).
* Set handler for add log event
  SET HANDLER go_log->add_log.

*  IF p_resend NE abap_true."GAP-3397-
*-Begin of GAP-3397+
  IF p_resind NE abap_true.
    IF p_resend = abap_true.
      PERFORM init_delta.
    ENDIF.
*-End of GAP-3397+
* Subroutine to send all the files from application server to legacy system ES.
    PERFORM send_files.
  ELSE.
    IF s_file[] IS INITIAL.
      MESSAGE i000 WITH 'Please provide at least one file to process'(e01).
      RETURN.
    ENDIF.
    PERFORM send_individual_files.
  ENDIF.

END-OF-SELECTION.
  "Send log by email if option is activated and if there is error
  IF p_email = abap_true.
    go_log->send_mail( iv_print_date = 'X' iv_print_hour = 'X' iv_print_group = 'X' iv_print_msgtype = 'X' iv_print_level = 'X' iv_only_error = abap_true iv_program = sy-repid iv_variant = p_varian ).
  ENDIF.

* save log
  go_log->dispatch_log( ).


*&---------------------------------------------------------------------*
*&      Form  SCREEN_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM screen_output.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN gc_email.
        IF p_email EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
      WHEN gc_resend.
        IF p_resind EQ abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
*-Begin of GAP-3397+
      WHEN gc_delta.
        IF p_resend = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
        MODIFY SCREEN.
*-End of GAP-3397+
    ENDCASE.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SEND_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_files.
  DATA:
    lv_process_id TYPE zproc_process_id,                    "GAP-3397+
    lt_process_id TYPE STANDARD TABLE OF zproc_process_id,  "GAP-3397+
*    ls_process  LIKE LINE OF s_proces,"GAP-3397-
    lo_transfer   TYPE REF TO z_cl_utf_file_transfer_manager.

*-Begin of GAP-3397+
  "Select the process ID to process based on selection
  SELECT process_id INTO TABLE lt_process_id
    FROM zfile_transfer
    WHERE process_id IN s_proces.
  LOOP AT lt_process_id INTO lv_process_id.
*-End of GAP-3397+
*  LOOP AT s_proces INTO ls_process."GAP-3397-
    CLEAR gv_process_id.
*    gv_process_id = ls_process-low.                         "GAP-3397-
    gv_process_id = lv_process_id.                          "GAP-3397+
    z_cl_utf_log=>raise_log_message( iv_group = 'FILE_TRANSFER' iv_level = 0 iv_type = 'H' iv_msg1 = 'Start file transfer for Process ID &2'(h01) iv_msg2 = gv_process_id ).

    lo_transfer = z_cl_utf_file_transfer_manager=>factory( gv_process_id ).

    IF ( lo_transfer->transfer_folder( ) = 0 ).
      z_cl_utf_log=>raise_log_message( iv_group = 'FILE_TRANSFER' iv_level = 1 iv_type = 'S' iv_msg1 = 'Transfer files request successfully sent'(s01) iv_msg2 = gv_process_id ).
    ELSE.
      z_cl_utf_log=>raise_log_message( iv_group = 'FILE_TRANSFER' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error during transfer files req. sending'(e04) iv_msg2 = gv_process_id ).
    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SEND_INDIVIDUAL_FILES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_individual_files .
  DATA:
    lo_transfer      TYPE REF TO z_cl_utf_file_transfer_manager,
    lo_file_transfer TYPE REF TO z_cl_utf_data_file,
    lv_filename      TYPE string,

    ls_process       LIKE LINE OF s_proces.

  LOOP AT s_proces INTO ls_process.
    CLEAR:gv_process_id.
    gv_process_id = ls_process-low.
    z_cl_utf_log=>raise_log_message( iv_group = 'FILE_TRANSFER' iv_level = 0 iv_type = 'H' iv_msg1 = 'Start file transfer for Process ID &2'(h01) iv_msg2 = gv_process_id ).
    lo_transfer = z_cl_utf_file_transfer_manager=>factory( gv_process_id ).

    LOOP AT s_file INTO DATA(ls_file).
      CLEAR lv_filename.
      lv_filename = ls_file-low.

      CREATE OBJECT lo_file_transfer
        EXPORTING
          iv_dataset_type    = zdatm_c_datasettype_outbound
          iv_filename        = lv_filename
          iv_subfolder       = p_folder
          iv_process_id      = gv_process_id
        EXCEPTIONS
          cannot_define_file = 1 ##SUBRC_OK
          OTHERS             = 2.

      IF ( lo_transfer->transfer_file( io_file_object             = lo_file_transfer
                                       iv_disable_duplicate_check = p_dpchk )
                                     = 0 ).
        z_cl_utf_log=>raise_log_message( iv_group = 'FILE_TRANSFER' iv_level = 1 iv_type = 'S' iv_msg1 = 'Transfer request successfully sent for file &2'(s02) iv_msg2 = lo_file_transfer->get_file_name( ) ).
      ELSE.
        z_cl_utf_log=>raise_log_message( iv_group = 'FILE_TRANSFER' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error during transfer req. sending for file &2'(e02) iv_msg2 = lo_file_transfer->get_file_name( ) ).
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.
*-Begin of GAP-3397+
FORM init_delta.
  DATA:
    lv_interface_id TYPE zinterface_id,
    lv_variant      TYPE raldb_vari,

    lv_process_id   TYPE zproc_process_id,
    lt_process_id   TYPE STANDARD TABLE OF zproc_process_id.

  "Get process ID list based on selection which are manager in delta mode
  SELECT process_id INTO TABLE lt_process_id
    FROM zfile_manager
    WHERE process_id IN s_proces AND
          delta_mode = abap_true.
  IF sy-subrc = 0 AND lt_process_id IS NOT INITIAL.
    LOOP AT lt_process_id INTO lv_process_id.
      "Initialize delta with the range pass on selection screen
      lv_interface_id = lv_process_id(10).
      lv_variant = lv_process_id+10.
      z_cl_bc_outbound_interface=>factory( EXPORTING iv_interface_id = lv_interface_id iv_variant_name = lv_variant iv_catchup_mode = p_resend
                                                     iv_date_from = s_udate-low iv_time_from = s_utime-low iv_date_to = s_udate-high iv_time_to = s_utime-high ).
    ENDLOOP.
  ENDIF.
ENDFORM.
*-End of GAP-3397+