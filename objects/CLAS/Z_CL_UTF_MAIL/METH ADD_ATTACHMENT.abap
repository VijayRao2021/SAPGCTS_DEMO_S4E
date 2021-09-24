method ADD_ATTACHMENT.
    DATA : lv_cnt TYPE i,
           lv_bytes TYPE i,
           lv_xref TYPE REF TO data,

           lt_xstring TYPE xstring,
           lt_solix  TYPE solix_tab.

    FIELD-SYMBOLS : <any> TYPE any.

*--The PDF data hqs to be formatted properly before adding it as attachment so that it can be
* opened without any issues
  IF iv_format = 'PDF'.
    CREATE DATA lv_xref LIKE LINE OF it_content.
    ASSIGN lv_xref->* to <any>.

    DESCRIBE FIELD <any> LENGTH lv_cnt in BYTE MODE.
    lv_bytes = lines( it_content ) * lv_cnt.

    CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
      EXPORTING
        input_length = lv_bytes
      IMPORTING
        buffer       = lt_xstring
      TABLES
        binary_tab   = it_content.

    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer     = lt_xstring
      TABLES
        binary_tab = lt_solix.

    o_mail_document->add_attachment( EXPORTING i_attachment_type    = iv_format
                                               i_attachment_subject = iv_subject
                                               i_att_content_hex    = lt_solix ).
  ELSE.
    o_mail_document->add_attachment( EXPORTING i_attachment_type    = iv_format
                                               i_attachment_subject = iv_subject
                                               i_att_content_text   = it_content ).
  ENDIF.
endmethod.