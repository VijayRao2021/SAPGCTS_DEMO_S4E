  METHOD get_email_template.

    DATA: cds_data_key TYPE if_smtg_email_template=>ty_gt_data_key.

    " Get Instance of the Email Template
    DATA(email_api) = cl_smtg_email_api=>get_instance( iv_template_id = iv_template ).

    " Get the subject & HTML body from the Email Template
    email_api->render( EXPORTING iv_language  = iv_language    " Template Language
                                 it_data_key  = cds_data_key   " Empty CDS Key
                       IMPORTING ev_subject   = DATA(subject)    " HTML Template Subject
                                 ev_body_html = DATA(email_body) ).   " HTML Template Body

    " Build Date & Time in Readable Format
    DATA(datetime)  = |{ sy-datum DATE = ENVIRONMENT  }, { sy-uzeit TIME = ENVIRONMENT }|.
    REPLACE ALL OCCURRENCES OF: '{{body}}'      IN email_body WITH iv_body_config              IN CHARACTER MODE,
                                '{{banner}}'    IN email_body WITH |cid:{ umg_banner }|        IN CHARACTER MODE,
                                '{{header}}'    IN email_body WITH |cid:{ umg_header_black }|  IN CHARACTER MODE,
                                '{{dot}}'       IN email_body WITH |cid:{ umg_formatter_dot }| IN CHARACTER MODE,
                                '{{sysid}}'     IN email_body WITH sy-sysid                    IN CHARACTER MODE,
                                '{{datetime}}'  IN email_body WITH datetime                    IN CHARACTER MODE,
                                '{{title}}'     IN email_body WITH iv_subject_config           IN CHARACTER MODE,
                                '{{subject}}'   IN subject    WITH iv_subject_config           IN CHARACTER MODE.

    et_body_html = cl_bcs_convert=>string_to_soli( email_body ).    " Convert HTML String to SOLI_TAB(255 chars)
    ev_subject = subject.

  ENDMETHOD.