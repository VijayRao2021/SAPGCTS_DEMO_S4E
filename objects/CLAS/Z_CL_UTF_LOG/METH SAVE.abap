  METHOD SAVE.
    DATA:
          ls_group TYPE zlog_ts_group_line,
          lt_log_handles TYPE bal_t_logh.

    LOOP AT mt_groups_table INTO ls_group.
      IF ls_group-al_object IS NOT INITIAL AND ls_group-al_subobject IS NOT INITIAL.
        APPEND ls_group-al_loghandler TO lt_log_handles.
      ENDIF.
    ENDLOOP.

    IF lt_log_handles[] IS NOT INITIAL.
      CALL FUNCTION 'BAL_DB_SAVE'
        EXPORTING
          i_client         = sy-mandt
          i_t_log_handle   = lt_log_handles
        EXCEPTIONS
          log_not_found    = 1
          save_not_allowed = 2
          numbering_error  = 3
          OTHERS           = 4.
      IF sy-subrc <> 0.
        add_log( iv_group = 'LOG' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot save the log in DB RC: &2.'(e04) iv_msg2 = sy-subrc ).
      ENDIF.
    ENDIF.

  ENDMETHOD.