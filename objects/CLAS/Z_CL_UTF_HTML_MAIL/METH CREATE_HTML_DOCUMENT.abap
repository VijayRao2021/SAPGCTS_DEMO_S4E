  METHOD create_html_document.


    " Create the main object of the mail.
    DATA(mime_helper) = NEW cl_gbt_multirelated_service( ).

    " Add Header MIME Object
    add_mime_object( EXPORTING iv_filename    = umg_header_black
                     CHANGING  co_mime_helper = mime_helper ).

    " Add Formatter MIME Object
    add_mime_object( EXPORTING iv_filename    = umg_formatter_dot
                     CHANGING  co_mime_helper = mime_helper ).

    " Add Banner MIME Object
    add_mime_object( EXPORTING iv_filename    = umg_banner
                     CHANGING  co_mime_helper = mime_helper ).


    " Prepare HTML Document
    mime_helper->set_main_html( content     = iv_html_body
                                description = iv_mail_subject ).


    "Create HTML using BCS class and attach html and image part to it.
    rv_doc_bcs = cl_document_bcs=>create_from_multirelated( i_subject          = iv_mail_subject
                                                            i_multirel_service = mime_helper ).


  ENDMETHOD.