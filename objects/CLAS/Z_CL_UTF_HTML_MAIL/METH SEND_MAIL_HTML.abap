  METHOD send_mail_html.

    " Determine Banner for Mail type
    IF iv_mail_type = 'A'.
      umg_banner = 'umg_banner_alert.jpg'.
    ELSE.
      umg_banner = 'umg_banner_update.jpg'.
    ENDIF.

    TRY.
        DATA(mail_configs) = get_mail_config( iv_program = iv_program
                                              iv_variant = iv_variant ).



        LOOP AT mail_configs REFERENCE INTO DATA(mail_config).

          TRY.
              get_email_template( EXPORTING iv_template       = iv_template
                                            iv_language       = iv_language
                                            iv_body_config    = iv_body
                                            iv_subject_config = mail_config->head-subject
                                  IMPORTING et_body_html      = DATA(body_html_soli_tab)
                                            ev_subject        = DATA(mail_subject) ).


              DATA(doc_bcs) =  create_html_document( iv_html_body    = body_html_soli_tab
                                                     iv_mail_subject = mail_subject
                                                     iv_mail_type    = iv_mail_type ).


              IF iv_attachment_data_ref IS BOUND.
                add_xlsx_attachment( EXPORTING iv_mail_subject        = mail_subject
                                               iv_attachment_data_ref = iv_attachment_data_ref
                                     CHANGING  co_doc_bcs             = doc_bcs ).
              ENDIF.


              DATA(lo_bcs) = cl_bcs=>create_persistent( ).
              lo_bcs->set_document( i_document = doc_bcs ).

              lo_bcs->set_sender( cl_cam_address_bcs=>create_internet_address( i_address_string = to_lower( mail_config->head-sender )
                                                                               i_address_name   = mail_config->head-display_name ) ).    "Set sender

              LOOP AT mail_config->recipients REFERENCE INTO DATA(recipient).
                lo_bcs->add_recipient( i_recipient = cl_cam_address_bcs=>create_internet_address( i_address_string = recipient->recipient
                                                                                                  i_address_name   = recipient->display_name )
                                       i_express = mail_config->head-express ).
              ENDLOOP.

              lo_bcs->set_send_immediately( mail_config->head-immediately ).
              IF lo_bcs->send( ) IS NOT INITIAL.
                COMMIT WORK.
              ENDIF.

            CATCH cx_static_check INTO DATA(error_handler).
              APPEND VALUE ty_exception_result( program       = mail_config->head-program_name
                                                configuration = mail_config->head-configuration
                                                msgty         = 'E'
                                                error_handler = error_handler ) TO rt_errorlogs.
          ENDTRY.

        ENDLOOP.

      CATCH cx_abap_docu_not_found INTO DATA(not_found_handler).
        APPEND VALUE ty_exception_result( program       = iv_program
                                          configuration = iv_variant
                                          msgty         = 'E'
                                          error_handler = not_found_handler ) TO rt_errorlogs.
    ENDTRY.
  ENDMETHOD.