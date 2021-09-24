  METHOD LOAD.
    TYPES:
      BEGIN OF lts_handle_update,
        old_handle TYPE balloghndl,
        new_handle TYPE balloghndl,
      END OF lts_handle_update.

    DATA:
          lr_group TYPE REF TO zlog_ts_group_line,
*          ls_log_header TYPE balhdr,
          ls_log_filter TYPE bal_s_lfil,
          ls_extn TYPE bal_s_extn,
          ls_object TYPE bal_s_obj,
          ls_subobj TYPE bal_s_sub,
          lt_log_headers TYPE balhdr_t,
          lt_log_handles TYPE bal_t_logh,
          lv_handle TYPE balloghndl,
          lt_handle_updates TYPE STANDARD TABLE OF lts_handle_update,
          ls_handle_update TYPE lts_handle_update.

    LOOP AT mt_groups_table REFERENCE INTO lr_group.
      "check if the current handle has been already loaded.
      READ TABLE lt_handle_updates INTO ls_handle_update WITH KEY old_handle = lr_group->al_loghandler.
      IF sy-subrc = 0.
        lr_group->al_loghandler = ls_handle_update-new_handle.
      ELSE.
        "Load the configured group and update the handler.
        IF lr_group->al_object IS NOT INITIAL AND lr_group->al_subobject IS NOT INITIAL AND lr_group->al_extnumber IS NOT INITIAL.
          REFRESH lt_log_headers.
          REFRESH: ls_log_filter-object, ls_log_filter-subobject, ls_log_filter-extnumber.
          ls_object-sign = 'I'. ls_object-option = 'EQ'. ls_object-low = lr_group->al_object.
          APPEND ls_object TO ls_log_filter-object.
          ls_subobj-sign = 'I'. ls_subobj-option = 'EQ'. ls_subobj-low = lr_group->al_subobject.
          APPEND ls_subobj TO ls_log_filter-subobject.
          ls_extn-sign = 'I'. ls_extn-option = 'EQ'. ls_extn-low = lr_group->al_extnumber.
          APPEND ls_extn TO ls_log_filter-extnumber.

          CALL FUNCTION 'BAL_DB_SEARCH'
            EXPORTING
              i_client           = sy-mandt
              i_s_log_filter     = ls_log_filter
*             I_T_SEL_FIELD      =
            IMPORTING
              e_t_log_header     = lt_log_headers
            EXCEPTIONS
              log_not_found      = 1
              no_filter_criteria = 2
              OTHERS             = 3.
          IF sy-subrc <> 0.
            add_log( iv_group = 'LOG' iv_level = 0 iv_type = sy-msgty iv_msgid = sy-msgid iv_msgno = sy-msgno iv_msg1 = sy-msgv1 iv_msg2 = sy-msgv2 iv_msg3 = sy-msgv3 iv_msg4 = sy-msgv4 ).
          ENDIF.
          IF lt_log_headers[] IS NOT INITIAL.
            "Load the log from application log DB
            CALL FUNCTION 'BAL_DB_LOAD'
              EXPORTING
                i_t_log_header     = lt_log_headers
*               I_T_LOG_HANDLE     =
*               I_T_LOGNUMBER      =
                i_client           = sy-mandt
*               I_DO_NOT_LOAD_MESSAGES              = ' '
*               I_EXCEPTION_IF_ALREADY_LOADED       =
              IMPORTING
                e_t_log_handle     = lt_log_handles
*               E_T_MSG_HANDLE     =
              EXCEPTIONS
                no_logs_specified  = 1
                log_not_found      = 2
                log_already_loaded = 3
                OTHERS             = 4.
            IF sy-subrc <> 0.
              "Cannot load it then inform the main program.
              add_log( iv_group = 'LOG' iv_level = 0 iv_type = 'E' iv_msg1 = 'Cannot Load the log &2 in DB RC: &3.'(e03) iv_msg2 = lr_group->al_extnumber  iv_msg3 = sy-subrc ).
              add_log( iv_group = 'LOG' iv_level = 0 iv_type = sy-msgty iv_msgid = sy-msgid iv_msgno = sy-msgno iv_msg1 = sy-msgv1 iv_msg2 = sy-msgv2 iv_msg3 = sy-msgv3 iv_msg4 = sy-msgv4 ).
            ELSE.
              "Log loaded then update the handler with the new one.
              IF lt_log_handles[] IS NOT INITIAL.
                READ TABLE lt_log_handles INTO lv_handle INDEX 1.
                IF sy-subrc = 0.
                  CLEAR ls_handle_update.
                  ls_handle_update-old_handle = lr_group->al_loghandler.
                  ls_handle_update-new_handle =  lv_handle.
                  lr_group->al_loghandler = lv_handle.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.