METHOD GET_LOG.
  DATA:
        lv_group TYPE string,
        lt_groups TYPE STANDARD TABLE OF string,

        ls_msg_handle TYPE balmsghndl,
        ls_group TYPE zlog_ts_group_line,
        lt_log_handles TYPE bal_t_logh,
        lt_msg_handles TYPE bal_t_msgh,
        lt_msg_context_filter TYPE bal_t_cfil,
        ls_msg_context_filter TYPE bal_s_cfil,
        ls_filter_range TYPE bal_rfield,
        ls_context TYPE zbcs_log_context,
        ls_msg TYPE bal_s_msg,
        ls_log TYPE zlog_log_tableline.

  REFRESH et_log.
  "Take the full log handler
  READ TABLE mt_groups_table INTO ls_group WITH KEY group = space.
  IF sy-subrc = 0.
    APPEND ls_group-al_loghandler TO lt_log_handles.
  ELSE."there is a problem, then exit.
    RETURN.
  ENDIF.

  "If group is specified then create a filter with this/these group(s)
  IF iv_group IS NOT INITIAL.
    IF iv_group CS '/'.
      SPLIT iv_group AT '/' INTO TABLE lt_groups.
    ELSE.
      APPEND iv_group TO lt_groups.
    ENDIF.
    LOOP AT lt_groups INTO lv_group.
      CLEAR ls_msg_context_filter.
      ls_msg_context_filter-tabname = zlog_context_structure.
      ls_msg_context_filter-fieldname = 'LOG_GROUP'.
      ls_filter_range-sign = 'I'.
      ls_filter_range-option = 'EQ'.
      ls_filter_range-low = lv_group.
      APPEND ls_filter_range TO ls_msg_context_filter-t_range.
    ENDLOOP.
    APPEND ls_msg_context_filter TO lt_msg_context_filter.
  ENDIF.

  CALL FUNCTION 'BAL_GLB_SEARCH_MSG'
    EXPORTING
*     I_S_LOG_FILTER         =
*     I_T_LOG_CONTEXT_FILTER =
      i_t_log_handle         = lt_log_handles
*     I_S_MSG_FILTER         =
      i_t_msg_context_filter = lt_msg_context_filter
*     I_T_MSG_HANDLE         =
    IMPORTING
*     E_T_LOG_HANDLE         =
      e_t_msg_handle         = lt_msg_handles
    EXCEPTIONS
      msg_not_found          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    add_log( iv_group = 'LOG' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot get the messages handlers RC: &2.'(E01) iv_msg2 = sy-subrc ).
  ENDIF.

  LOOP AT lt_msg_handles INTO ls_msg_handle.
    CALL FUNCTION 'BAL_LOG_MSG_READ'
      EXPORTING
        i_s_msg_handle = ls_msg_handle
*       I_LANGU        = SY-LANGU
      IMPORTING
        e_s_msg        = ls_msg
*       E_EXISTS_ON_DB =
*       E_TXT_MSGTY    =
*       E_TXT_MSGID    =
*       E_TXT_DETLEVEL =
*       E_TXT_PROBCLASS                =
*       E_TXT_MSG      =
*       E_WARNING_TEXT_NOT_FOUND       =
      EXCEPTIONS
        log_not_found  = 1
        msg_not_found  = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      add_log( iv_group = 'LOG' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot read the message with handler &2 RC: &3.'(e02) iv_msg2 = ls_msg_handle iv_msg3 = sy-subrc ).
    ELSE.
      CLEAR ls_log.
      ls_log-message_number = ls_msg-msg_count.
      CONVERT TIME STAMP ls_msg-time_stmp TIME ZONE sy-zonlo INTO DATE ls_log-date TIME ls_log-hour.
      ls_context = ls_msg-context-value.
      ls_log-group = ls_context-log_group.
      ls_log-msgtype = ls_msg-msgty.
      ls_log-level = ls_msg-detlevel.
      ls_log-probclass = ls_msg-probclass.
      IF ls_msg-msgid <> 'BL' OR ls_msg-msgno <> 1.
        IF ls_msg-msgty IS INITIAL.
          ls_msg-msgty = 'I'.
        ENDIF.
        MESSAGE ID ls_msg-msgid TYPE ls_msg-msgty NUMBER ls_msg-msgno WITH ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4 INTO ls_log-message.
      ELSE.
        CONCATENATE ls_msg-msgv1 ls_msg-msgv2 ls_msg-msgv3 ls_msg-msgv4 INTO ls_log-message.
      ENDIF.
      APPEND ls_log TO et_log.
    ENDIF.
  ENDLOOP.
ENDMETHOD.