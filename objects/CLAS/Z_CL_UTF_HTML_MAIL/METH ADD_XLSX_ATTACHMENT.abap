  METHOD add_xlsx_attachment.

    DATA: description       TYPE so_obj_des,
          attachment_header TYPE soli_tab.

    " Local Constants
    CONSTANTS: attachment_filetype_xlsx  TYPE string VALUE '.XLSX',
               attachment_parameter_name TYPE string VALUE '&SO_FILENAME=',
               attachment_type_bin       TYPE soodk-objtp VALUE 'BIN'.


    IF binary_tab IS INITIAL.
      DATA(xls_xstring) = convert_table_to_xstring( iv_attachment_data_ref ).

      IF xls_xstring IS NOT INITIAL.

        "  Converting the table contents from xstring to binary
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer        = xls_xstring
          IMPORTING
            output_length = xls_length
          TABLES
            binary_tab    = binary_tab.
      ENDIF.
    ENDIF.

    " XLSX Name
    description = |{ iv_mail_subject(46) }{ attachment_filetype_xlsx }|.
    CLEAR attachment_header.
    APPEND VALUE #( line = |{ attachment_parameter_name }{ description }| ) TO attachment_header.


    " add the spread sheet as attachment to document object
    co_doc_bcs->add_attachment(
      i_attachment_type    = attachment_type_bin
      i_attachment_subject = description
      i_attachment_size    = CONV #( xls_length )
      i_att_content_hex    = binary_tab
      i_attachment_header  = attachment_header    ).
  ENDMETHOD.