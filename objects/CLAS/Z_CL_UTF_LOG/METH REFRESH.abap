  METHOD REFRESH.
    DATA:
          ls_group TYPE zlog_ts_group_line.

    LOOP AT mt_groups_table INTO ls_group.
      CALL FUNCTION 'BAL_LOG_REFRESH'
        EXPORTING
          i_log_handle  = ls_group-al_loghandler
        EXCEPTIONS
          log_not_found = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        add_log( iv_group = 'LOG' iv_level = 0 iv_type = sy-msgty iv_msgid = sy-msgid iv_msgno = sy-msgno iv_msg1 = sy-msgv1 iv_msg2 = sy-msgv2 iv_msg3 = sy-msgv3 iv_msg4 = sy-msgv4 ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.