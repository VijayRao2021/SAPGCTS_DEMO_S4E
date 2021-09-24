PRIVATE SECTION.

  TYPES:
    BEGIN OF ty_sender_recipient,
      head       TYPE zbc_mail_header,
      recipients TYPE zbc_mail_email_address_table,
    END OF ty_sender_recipient .
  TYPES:
    tt_sender_recipients TYPE STANDARD TABLE OF ty_sender_recipient WITH NON-UNIQUE KEY head .

  DATA binary_tab TYPE solix_tab .
  DATA xls_length TYPE i .
  DATA umg_banner TYPE string .
  DATA umg_formatter_dot TYPE string VALUE 'umg_mail_arrange_dot.png' ##NO_TEXT.
  DATA umg_header_black TYPE string VALUE 'umg_header_black.png' ##NO_TEXT.

  METHODS add_xlsx_attachment
    IMPORTING
      !iv_attachment_data_ref TYPE REF TO data
      !iv_mail_subject        TYPE so_obj_des
    CHANGING
      !co_doc_bcs             TYPE REF TO cl_document_bcs
    RAISING
      cx_document_bcs .
  METHODS create_html_document
    IMPORTING
      !iv_html_body     TYPE soli_tab
      !iv_mail_subject  TYPE so_obj_des
      !iv_mail_type     TYPE char01
    RETURNING
      VALUE(rv_doc_bcs) TYPE REF TO cl_document_bcs
    RAISING
      cx_document_bcs
      cx_bcom_mime
      cx_gbt_mime .
  METHODS get_email_template
    IMPORTING
      !iv_template       TYPE if_smtg_email_template=>ty_gs_tmpl_cont-id DEFAULT 'Z_UTF_GENERIC_MAIL'
      !iv_language       TYPE if_smtg_email_template=>ty_gs_tmpl_cont-langu DEFAULT 'E'
      !iv_body_config    TYPE string DEFAULT ''
      !iv_subject_config TYPE so_obj_des DEFAULT ''
    EXPORTING
      !et_body_html      TYPE soli_tab
      !ev_subject        TYPE so_obj_des
    RAISING
      cx_smtg_email_common .
  METHODS add_mime_object
    IMPORTING
      !iv_filename    TYPE csequence
    CHANGING
      !co_mime_helper TYPE REF TO cl_gbt_multirelated_service .
  METHODS convert_table_to_xstring
    IMPORTING
      !iv_attachment_data_ref TYPE REF TO data
    RETURNING
      VALUE(rv_xstring)       TYPE xstring .
  METHODS get_mail_config
    IMPORTING
      !iv_program                 TYPE programm
      !iv_variant                 TYPE raldb_vari
    RETURNING
      VALUE(rt_sender_recipients) TYPE tt_sender_recipients
    RAISING
      cx_abap_docu_not_found .