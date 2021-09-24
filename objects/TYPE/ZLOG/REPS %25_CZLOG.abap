TYPE-POOL zlog.

CONSTANTS:
  zlog_context_structure TYPE baltabname VALUE 'ZBCS_LOG_CONTEXT'.

TYPES:
  BEGIN OF zlog_ts_group_line,
    group TYPE string,
    level TYPE i,
    display(1) TYPE c,
    al_object TYPE  balobj_d,
    al_subobject TYPE  balsubobj,
    al_extnumber TYPE balnrext,
    al_loghandler TYPE balloghndl,
  END OF zlog_ts_group_line,

  zlog_tt_group_table TYPE STANDARD TABLE OF zlog_ts_group_line,
*  tt_group_table TYPE SORTED TABLE OF ts_group_tableline WITH UNIQUE KEY group,

  BEGIN OF zlog_log_tableline,
    message_number TYPE i,
    date TYPE sydatum,
    hour TYPE syuzeit,
    group TYPE string,
    msgtype(1) TYPE c,
    probclass TYPE balprobcl,
    level TYPE i,
    message TYPE string,
    program TYPE programm,
    variant TYPE raldb_vari,
    block TYPE z_bc_mail_block,
  END OF zlog_log_tableline,

  zlog_log_table TYPE STANDARD TABLE OF zlog_log_tableline,

  BEGIN OF zlog_ts_log_conf,
    level TYPE i,
    send_log(1) TYPE c,
    send_only_error(1) TYPE c,
  END OF zlog_ts_log_conf.