  METHOD transfer_file_rest.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 11/12/2020 ! GAP-3905 add the REST protocol to the framework: creation of the method*
* GAP-3905   !            !                                                                        *
****************************************************************************************************

*** Constant declarations:
    CONSTANTS:lc_dfault  TYPE ssfapplssl VALUE 'DFAULT',
              lc_accept  TYPE string     VALUE 'Accept',
              lc_xml     TYPE string     VALUE 'text/xml',
              lc_method  TYPE string     VALUE '~request_method',
              lc_post    TYPE string     VALUE 'POST',
              lc_version TYPE string     VALUE '&version='.

*** Reference declarations:
    DATA:lo_http  TYPE REF TO if_http_client,
         lo_error TYPE REF TO cx_uuid_error,
         lo_exc   TYPE REF TO cx_rest_client_exception.

*** Internal table declarations;
    DATA:lt_content TYPE zdatm_file_tt_file_content.

**** Variable declarations:
    DATA:lv_url         TYPE string,
         lv_status_code TYPE i,
         lv_status_text TYPE string,
         lv_result      TYPE string,
         lv_data        TYPE string,
         lv_xml_datax   TYPE xstring,
         lv_parameters  TYPE string,
         lv_date        TYPE sydatum,
         lv_time        TYPE syuzeit,
         lv_version     TYPE char17,
         lv_uniqueid    TYPE sysuuid_c32,
##NEEDED lv_error_txt   TYPE string.

*Build the rest service URL
    "Define the protocol
    CASE ms_file_server-protocol.
      WHEN 'REST_HTTP'.
        lv_url = 'http://'.
      WHEN 'REST_HTTPS'.
        lv_url = 'https://'.
      WHEN OTHERS.
        rv_rc = 8.
    ENDCASE.

    "Add the hostname
    CONCATENATE lv_url ms_file_server-hostname INTO lv_url.

    "if port is defined then add it.
    IF ms_file_server-port IS NOT INITIAL.
      CONCATENATE lv_url ':' ms_file_server-port INTO lv_url.
    ENDIF.

    "if url path is defined then add it.
    IF ms_file_server-url IS NOT INITIAL.
      CONCATENATE lv_url '/' ms_file_server-url INTO lv_url.
    ENDIF.

    "Finaly if parameters is provided then add at the end
    IF iv_parameters IS NOT INITIAL.
      CONCATENATE lv_url iv_parameters INTO lv_url.
    ELSE.
      lv_parameters = '?sap-client=' && sy-mandt.
      GET TIME STAMP FIELD DATA(lv_tstmp).
      CONVERT TIME STAMP lv_tstmp TIME ZONE 'UTC' INTO DATE lv_date TIME lv_time.
      lv_version = lv_date && lv_time && '000'.

*** Get the Unique ID for file name
      CLEAR lv_uniqueid.
      TRY.
          lv_uniqueid  = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
        CATCH cx_uuid_error INTO lo_error.
          lv_error_txt = lo_error->get_text( ).
      ENDTRY.

*** fill url:
      lv_url = lv_url && lv_uniqueid && lc_version && lv_version.
    ENDIF.

    "Get the XML data
    IF io_file_object IS BOUND.

      "Get the XML file content
      io_file_object->get_content( IMPORTING et_content = lt_content ).

      "Read the XML file from Memory
      IF lt_content[] IS INITIAL.

        "Open the file.
        IF ( io_file_object->open( ) <> 0 ).
          RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'E'
                                         iv_msg1  = 'Can not open the XML file for the URL &2'(e05)
                                         iv_msg2  = lv_url.
        ENDIF.

        "Load the XML file from Memory.
        IF ( io_file_object->load_in_memory( ) <> 0 ).
          RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'E'
                                         iv_msg1  = 'Can not load the XML file into memory for the URL &2'(e06)
                                         iv_msg2  = lv_url.
        ENDIF.

        "Close the file.
        io_file_object->close( ).

        "Get the XML file content
        io_file_object->get_content( IMPORTING et_content = lt_content ).
      ENDIF.

      READ TABLE lt_content INTO lv_data INDEX 1.
      IF sy-subrc IS INITIAL.
*** Convert XML data to Hexadecimal data
        CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
          EXPORTING
            text   = lv_data
          IMPORTING
            buffer = lv_xml_datax
          EXCEPTIONS
            failed = 1
            OTHERS = 2.
        IF sy-subrc IS NOT INITIAL.
          CLEAR lv_xml_datax.
        ENDIF.
      ENDIF.
    ENDIF.

*** Transfer the data by 3 attempts, if failed to transfer
    DO 3 TIMES. "22.07.2021 - Do loop is moved here to create new instance for every Re-attempt

      TRY.

*** Create HTTP client
          IF lo_http IS NOT BOUND.
            CALL METHOD cl_http_client=>create_by_url
              EXPORTING
                url                = lv_url
                ssl_id             = lc_dfault
              IMPORTING
                client             = lo_http
              EXCEPTIONS
                argument_not_found = 1
                plugin_not_active  = 2
                internal_error     = 3
                OTHERS             = 4.
            IF sy-subrc <> 0.
              RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'E'
                                             iv_msg1  = 'Error in creating HTTP client by the URL &2'(e04)
                                             iv_msg2  = lv_url.
              rv_rc = 8.
              RETURN.
            ENDIF.
          ENDIF.

          IF lo_http IS BOUND.

*** Authenticate HTTP client
            CALL METHOD lo_http->authenticate
              EXPORTING
                username = CONV #( ms_file_server-username )
                password = CONV #( ms_file_server-password ).

***Set HTTP version
            lo_http->request->set_version( if_http_request=>co_protocol_version_1_1 ).   "(+) 29.07.2021

*** Set HTTP header field
            CALL METHOD lo_http->request->set_header_field
              EXPORTING
                name  = lc_accept
                value = lc_xml.

*** Set HTTP header field
            CALL METHOD lo_http->request->set_header_field
              EXPORTING
                name  = lc_method
                value = lc_post.

*** Set HTTP content type
            CALL METHOD lo_http->request->set_content_type
              EXPORTING
                content_type = lc_xml.

*** Send data to POST Method
            CALL METHOD lo_http->request->set_data
              EXPORTING
                data = lv_xml_datax.

            GET RUN TIME FIELD DATA(lv_rtime_1).

*** Send HTTP Request
            CALL METHOD lo_http->send
              EXCEPTIONS
                http_communication_failure = 1
                http_invalid_state         = 2.
            IF sy-subrc <> 0.
              CLEAR:lv_status_code,lv_status_text.
            ENDIF.

*** Get HTTP Response
            CALL METHOD lo_http->receive
              EXCEPTIONS
                http_communication_failure = 1
                http_invalid_state         = 2
                http_processing_failed     = 3.
            IF sy-subrc <> 0.
              CLEAR:lv_status_code,lv_status_text.
            ENDIF.

*** Read HTTP Return code
            CALL METHOD lo_http->response->get_status
              IMPORTING
                code   = lv_status_code
                reason = lv_status_text.

*** Read Response Data
            CALL METHOD lo_http->response->get_cdata
              RECEIVING
                data = lv_result.

*** Close Connection
            CALL METHOD lo_http->close
              EXCEPTIONS
                http_invalid_state = 1
                OTHERS             = 2.
            IF sy-subrc <> 0.
              CLEAR lv_result.
            ENDIF.

            "Filling Response code and text
            cv_response_code = lv_status_code.
            cv_response_text = lv_status_text.

            RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'I'
                                           iv_msg1  = 'Attempt &2'(i06) iv_msg2 = sy-index.

*** Fill log message
            IF lv_status_code EQ cl_rest_status_code=>gc_success_accepted.  "202.
              GET RUN TIME FIELD DATA(lv_rtime_2).
              cv_response_time = CONV decfloat34( ( lv_rtime_2 - lv_rtime_1 ) / 1000000 ) .
              GET TIME STAMP FIELD cv_filesent_time.  "UTC Timestamp
              RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'S'
                                             iv_msg1  = 'File transfered successfully.'(s03).
              rv_rc = 0.
              EXIT.
            ELSE.
              RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'E'
                                             iv_msg1  = 'Error during transfer the file: &2 &3 &4.'(e03)
                                             iv_msg2  = lv_status_code iv_msg3 = '-' iv_msg4 = lv_status_text.

*** Wait only for first two iterations
              IF sy-index LT 3.
                WAIT UP TO 10 SECONDS.
                RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'I'
                                               iv_msg1  = 'Retried to transfer the file'(i05).
              ENDIF.

              IF sy-index GT 1.
                ADD 1 TO cv_retry_attempts.
              ENDIF.

              rv_rc = 8.

            ENDIF.

            CLEAR:lv_status_code,lv_status_text,lv_result,lv_rtime_1.

          ENDIF.

        CATCH cx_rest_client_exception INTO lo_exc.
          CLEAR lv_error_txt.
          lv_error_txt = lo_exc->get_text( ).
          RAISE EVENT send_log EXPORTING iv_group = 'TRANSFER_FILE_REST' iv_level = 2 iv_type = 'E' iv_msg1 = lv_error_txt.
          EXIT.
      ENDTRY.

    ENDDO.

  ENDMETHOD.