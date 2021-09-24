  METHOD transfer_file_ftp.

    TYPES:
      BEGIN OF lts_transfer_line,
        line(1024) TYPE c,
      END OF lts_transfer_line.

    TYPES: BEGIN OF lts_result ,                        " INS MK-001
             line(100) TYPE c,                          " INS MK-001
           END OF lts_result.                           " INS MK-001

    DATA: lv_ftp_handle      TYPE i,
          lv_key             TYPE i VALUE 26101957,
          lv_password_length TYPE i,
          lv_password        TYPE zfile_password,
          lv_target_filename TYPE char1024,
          lv_source_filename TYPE char1024,              " INS MK-001
          lv_command_cd      TYPE char200,
          lv_command_put     TYPE char200,

          lv_content         TYPE zdatm_file_ts_file_content,
          lt_content         TYPE zdatm_file_tt_file_content,

          ls_transfer_line   TYPE lts_transfer_line,
          lt_transfer        TYPE STANDARD TABLE OF lts_transfer_line,
          lt_result          TYPE STANDARD TABLE OF lts_result.

    CONSTANTS: lc_n TYPE char1 VALUE 'N'.

    lv_password_length = strlen( ms_file_server-password ).

    CALL FUNCTION 'HTTP_SCRAMBLE'
      EXPORTING
        source      = ms_file_server-password
        sourcelen   = lv_password_length
        key         = lv_key
      IMPORTING
        destination = lv_password.

    CALL FUNCTION 'FTP_CONNECT'
      EXPORTING
        user            = ms_file_server-username
        password        = lv_password
        host            = ms_file_server-hostname
        rfc_destination = ms_file_server-rfc_destination
      IMPORTING
        handle          = lv_ftp_handle.


    IF ms_file_transfer-physical_transfer IS INITIAL.                                                     " INS MK-001
      io_file_object->get_content( IMPORTING et_content = lt_content ).
      LOOP AT lt_content INTO lv_content.
        ls_transfer_line-line = lv_content.
        APPEND ls_transfer_line TO lt_transfer.
      ENDLOOP.

      lv_target_filename = io_file_object->get_file_name( ).
      CONCATENATE ms_file_transfer-target_folder lv_target_filename INTO lv_target_filename SEPARATED BY '/'.

      CALL FUNCTION 'FTP_R3_TO_SERVER'
        EXPORTING
          handle         = lv_ftp_handle
          fname          = lv_target_filename
          character_mode = 'X'
        TABLES
          text           = lt_transfer
        EXCEPTIONS
          tcpip_error    = 1
          command_error  = 2
          data_error     = 3
          OTHERS         = 4.
      IF sy-subrc <> 0.
        rv_rc = 8.
*      ELSE.
*        "Message ok;
      ENDIF.
    ELSE.
* BOC by MK-001
      lv_target_filename = io_file_object->get_file_name( ).
      lv_source_filename = io_file_object->get_file_name( iv_full_filename = abap_true ).

      CONCATENATE 'cd' ms_file_transfer-target_folder INTO lv_command_cd SEPARATED BY space.
      CONCATENATE 'put' lv_source_filename lv_target_filename INTO lv_command_put SEPARATED BY space.

      " Call CD command
      IF rv_rc = 0.
        CALL FUNCTION 'FTP_COMMAND'
          EXPORTING
            handle        = lv_ftp_handle
            command       = lv_command_cd
            compress      = lc_n
          TABLES
            data          = lt_result
          EXCEPTIONS
            command_error = 1
            tcpip_error   = 2.
        IF sy-subrc <> 0.
          rv_rc = 8.
*        ELSE.
*          " Message ok
        ENDIF.
      ENDIF.
      " Call ASCII command
      IF rv_rc = 0.
        CLEAR lt_result.
        CALL FUNCTION 'FTP_COMMAND'
          EXPORTING
            handle        = lv_ftp_handle
            command       = 'ascii'
            compress      = lc_n
          TABLES
            data          = lt_result
          EXCEPTIONS
            command_error = 1
            tcpip_error   = 2.
        IF sy-subrc <> 0.
          rv_rc = 8.
*        ELSE.
*          " Message ok
        ENDIF.
      ENDIF.
      " Call PUT command
      IF rv_rc = 0.
        CLEAR lt_result.
        CALL FUNCTION 'FTP_COMMAND'
          EXPORTING
            handle        = lv_ftp_handle
            command       = lv_command_put
            compress      = lc_n
          TABLES
            data          = lt_result
          EXCEPTIONS
            command_error = 1
            tcpip_error   = 2.
        IF sy-subrc <> 0.
          rv_rc = 8.
        ELSE.
          " Message ok
        ENDIF.
      ENDIF.
    ENDIF.
* EOC by MK-001
* Disconnect FTP connection
    CALL FUNCTION 'FTP_DISCONNECT'
      EXPORTING
        handle = lv_ftp_handle.

* Close RFC connection
    CALL FUNCTION 'RFC_CONNECTION_CLOSE'
      EXPORTING
        destination          = ms_file_server-rfc_destination
      EXCEPTIONS
        destination_not_open = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      rv_rc = 8.
    ENDIF.

  ENDMETHOD.