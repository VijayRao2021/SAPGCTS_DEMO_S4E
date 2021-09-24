METHOD ADD_LOG.
  DATA:
        lv_msg1_tmp(1024) TYPE c,
        lv_msg2_tmp(1024) TYPE c,
        lv_msg3_tmp(1024) TYPE c,
        lv_msg4_tmp(1024) TYPE c,
        lv_msg5_tmp(1024) TYPE c,
        ls_group TYPE zlog_ts_group_line,
        ls_log_message TYPE bal_s_msg,
        ls_log_context TYPE zbcs_log_context,
        lv_group TYPE string,
        lt_groups TYPE STANDARD TABLE OF string,
        lt_handlers_to_log TYPE STANDARD TABLE OF balloghndl,
        lv_handler_to_log TYPE balloghndl,

     BEGIN OF ls_message,
        part1   TYPE symsgv,
        part2   TYPE symsgv,
        part3   TYPE symsgv,
        part4   TYPE symsgv,
     END OF ls_message.

  IF iv_level > mv_level_max.
    RETURN.
  ENDIF.

  CLEAR ls_group.
  "If the message contains mulitple groups, then split them
  IF iv_group CS '/'.
    SPLIT iv_group AT '/' INTO TABLE lt_groups.
    LOOP AT lt_groups INTO lv_group.
      add_log( iv_group = lv_group iv_level = iv_level iv_type = iv_type iv_msg1 = iv_msg1 iv_msg2 = iv_msg2
               iv_msg3 = iv_msg3 iv_msg4 = iv_msg4 iv_msg5 = iv_msg5 ).
    ENDLOOP.
    RETURN.
  ENDIF.

*Define the handlers where to send the message for the given group.
  READ TABLE mt_groups_table INTO ls_group WITH KEY group = iv_group.
  IF sy-subrc = 0.
    IF ls_group-level >= iv_level.
      APPEND ls_group-al_loghandler TO lt_handlers_to_log.
    ELSE.
      "Based on the group configuration, this message should not be logged
      RETURN.
    ENDIF.
  ENDIF.

*Check the general handlers
  READ TABLE mt_groups_table INTO ls_group WITH KEY group = space.
  IF sy-subrc = 0.
    IF lt_handlers_to_log[] IS INITIAL.
      "No group configuration found before so we check the global log level
      IF ls_group-level >= iv_level.
        "Message can be logged
        APPEND ls_group-al_loghandler TO lt_handlers_to_log.
      ENDIF.
    ELSE.
      "There is already something so check if global log and group log have the same handler
      READ TABLE lt_handlers_to_log TRANSPORTING NO FIELDS WITH KEY table_line = ls_group-al_loghandler.
      IF sy-subrc <> 0.
        APPEND ls_group-al_loghandler TO lt_handlers_to_log.
      ENDIF.
    ENDIF.
  ENDIF.

*If we can log the message, then log it!
  IF lt_handlers_to_log[] IS NOT INITIAL.
    CLEAR ls_log_message.
    IF iv_msgid IS INITIAL.
      WRITE: iv_msg1 TO lv_msg1_tmp ##WRITE_MOVE,
             iv_msg2 TO lv_msg2_tmp ##WRITE_MOVE,
             iv_msg3 TO lv_msg3_tmp ##WRITE_MOVE,
             iv_msg4 TO lv_msg4_tmp ##WRITE_MOVE,
             iv_msg5 TO lv_msg5_tmp ##WRITE_MOVE.
      CONDENSE: lv_msg1_tmp, lv_msg2_tmp, lv_msg3_tmp, lv_msg4_tmp, lv_msg5_tmp.
      IF lv_msg1_tmp CS '&2'.
        REPLACE '&2'  IN lv_msg1_tmp WITH lv_msg2_tmp.
      ELSEIF NOT iv_put_at_end IS INITIAL.
        CONCATENATE lv_msg1_tmp lv_msg2_tmp INTO lv_msg1_tmp SEPARATED BY space.
      ENDIF.
      IF lv_msg1_tmp CS '&3'.
        REPLACE '&3' IN lv_msg1_tmp WITH lv_msg3_tmp.
      ELSEIF NOT iv_put_at_end IS INITIAL.
        CONCATENATE lv_msg1_tmp lv_msg3_tmp INTO lv_msg1_tmp SEPARATED BY space.
      ENDIF.
      IF lv_msg1_tmp CS '&4'.
        REPLACE '&4' IN lv_msg1_tmp WITH lv_msg4_tmp.
      ELSEIF NOT iv_put_at_end IS INITIAL.
        CONCATENATE lv_msg1_tmp lv_msg4_tmp INTO lv_msg1_tmp SEPARATED BY space.
      ENDIF.
      IF lv_msg1_tmp CS '&5'.
        REPLACE '&5' IN lv_msg1_tmp WITH lv_msg5_tmp.
      ELSEIF NOT iv_put_at_end IS INITIAL.
        CONCATENATE lv_msg1_tmp lv_msg5_tmp INTO lv_msg1_tmp SEPARATED BY space.
      ENDIF.

    ls_log_message-msgty = iv_type.

      CASE iv_type.
        WHEN 'H'.
          ls_log_message-msgty = ''.
          ls_log_message-probclass = 1.
        WHEN 'O' OR 'S'.
          ls_log_message-msgty = 'S'.
          ls_log_message-probclass = 2.
        WHEN 'W'.
          ls_log_message-probclass = 3.
        WHEN 'E' OR 'A'.
          ls_log_message-probclass = 4.
        WHEN OTHERS.
          ls_log_message-probclass = 0.
      ENDCASE.

      ls_message = lv_msg1_tmp.
      ls_log_message-msgid = 'BL'.
      ls_log_message-msgno = 1.
      ls_log_message-msgv1 = ls_message-part1.
      ls_log_message-msgv2 = ls_message-part2.
      ls_log_message-msgv3 = ls_message-part3.
      ls_log_message-msgv4 = ls_message-part4.
    ELSE.
      "use of the class message
      ls_log_message-msgty = iv_type.
      ls_log_message-msgid = iv_msgid.
      ls_log_message-msgno = iv_msgno.
      ls_log_message-msgv1 = iv_msg1.
      ls_log_message-msgv2 = iv_msg2.
      ls_log_message-msgv3 = iv_msg3.
      ls_log_message-msgv4 = iv_msg4.
    ENDIF.

    ls_log_message-detlevel = iv_level.

    ls_log_context-log_group = iv_group.
    "Custom fields
    ls_log_message-context-tabname = zlog_context_structure.
    ls_log_message-context-value = ls_log_context.

    "Send the message to each selected handler
    LOOP AT lt_handlers_to_log INTO lv_handler_to_log.
      CALL FUNCTION 'BAL_LOG_MSG_ADD'
        EXPORTING
          i_log_handle     = lv_handler_to_log
          i_s_msg          = ls_log_message
        EXCEPTIONS
          log_not_found    = 1
          msg_inconsistent = 2
          log_is_full      = 3
          OTHERS           = 4.
      IF sy-subrc <> 0 ##NEEDED.
* Implement suitable error handling here
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMETHOD.