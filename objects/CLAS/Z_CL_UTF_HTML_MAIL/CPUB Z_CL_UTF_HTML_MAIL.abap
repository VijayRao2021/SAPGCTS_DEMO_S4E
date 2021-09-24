class Z_CL_UTF_HTML_MAIL definition
  public
  inheriting from Z_CL_UTF_MAIL
  final
  create public .

public section.

  types:
    BEGIN OF  ty_exception_result,
        program       TYPE programm,
        configuration TYPE z_bc_mail_conf,
        msgty         TYPE sy-msgty,
        error_handler TYPE REF TO cx_static_check,
      END OF ty_exception_result .
  types:
    tt_exception_results TYPE STANDARD TABLE OF ty_exception_result WITH NON-UNIQUE KEY program configuration .

  methods SEND_MAIL_HTML
    importing
      !IV_PROGRAM type PROGRAMM
      !IV_VARIANT type RALDB_VARI
      !IV_TEMPLATE type IF_SMTG_EMAIL_TEMPLATE=>TY_GS_TMPL_CONT-ID default 'Z_ET_UTF_GENERIC'
      !IV_LANGUAGE type IF_SMTG_EMAIL_TEMPLATE=>TY_GS_TMPL_CONT-LANGU default 'E'
      !IV_BODY type STRING
      !IV_ATTACHMENT_DATA_REF type ref to DATA optional
      !IV_MAIL_TYPE type CHAR01 default 'U'
    returning
      value(RT_ERRORLOGS) type TT_EXCEPTION_RESULTS .