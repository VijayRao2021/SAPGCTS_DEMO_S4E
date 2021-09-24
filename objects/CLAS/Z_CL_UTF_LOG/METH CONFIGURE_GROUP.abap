METHOD CONFIGURE_GROUP.
  DATA:
        lv_flg_create_al TYPE c,

        ls_group_line TYPE zlog_ts_group_line,
        lr_group_line TYPE REF TO zlog_ts_group_line,
        ls_header_log TYPE bal_s_log.

  CLEAR lv_flg_create_al.

*Keep the higher level
  IF mv_level_max < iv_level.
    mv_level_max = iv_level.
  ENDIF.

  IF iv_mode = 'D'.
    "Update mode = deletion
    READ TABLE mt_groups_table INTO ls_group_line WITH KEY group = iv_group al_object = iv_al_object al_subobject = iv_al_subobject.
    IF sy-subrc = 0.
      DELETE mt_groups_table WHERE group = iv_group AND al_object = iv_al_object AND al_subobject = iv_al_subobject.
    ENDIF.
    RETURN.
  ENDIF.

*Update or create the data's group
  CLEAR lr_group_line.
  READ TABLE mt_groups_table REFERENCE INTO lr_group_line WITH KEY group = iv_group al_object = iv_al_object al_subobject = iv_al_subobject al_extnumber = iv_al_extnumber.
  IF sy-subrc = 0.
    "if a line exists for the 3 parameters, then update it
    lr_group_line->level = iv_level.
    lr_group_line->display = iv_display.
  ELSE.
    IF iv_mode = 'U'.
      "If we are in update mode then check for the group line
      READ TABLE mt_groups_table REFERENCE INTO lr_group_line WITH KEY group = iv_group.
      IF sy-subrc = 0.
        "if found, update it
        lr_group_line->level = iv_level.
        lr_group_line->display = iv_display.
        "and update the AL handler
        lr_group_line->al_object = iv_al_object.
        lr_group_line->al_subobject = iv_al_subobject.
        lr_group_line->al_extnumber = iv_al_extnumber.
        CLEAR ls_header_log.
        ls_header_log-object = iv_al_object.
        ls_header_log-subobject = iv_al_subobject.
        ls_header_log-extnumber = iv_al_extnumber.
        ls_header_log-altcode = sy-tcode.
        ls_header_log-alprog = sy-cprog.
        CALL FUNCTION 'BAL_LOG_HDR_CHANGE'
          EXPORTING
            i_log_handle            = lr_group_line->al_loghandler
            i_s_log                 = ls_header_log
          EXCEPTIONS
            log_not_found           = 1
            log_header_inconsistent = 2
            OTHERS                  = 3.
        IF sy-subrc <> 0 ##NEEDED.
* Implement suitable error handling here
        ENDIF.
      ELSE.
        "Group not found then create it
        lv_flg_create_al = 'X'.
      ENDIF.
    ELSE.
      "Create the AL
      lv_flg_create_al = 'X'.
    ENDIF.
    IF lv_flg_create_al IS NOT INITIAL.
      "if the flag is initial, it means line with blank AL object has not been searched/found, so new line must be created.
      CLEAR ls_group_line.
      ls_group_line-group = iv_group.
      ls_group_line-al_object = iv_al_object.
      ls_group_line-al_subobject = iv_al_subobject.
      ls_group_line-al_extnumber = iv_al_extnumber.
      ls_group_line-level = iv_level.
      ls_group_line-display = iv_display.
      INSERT ls_group_line INTO TABLE mt_groups_table.
      "load the line to create AL handler
      READ TABLE mt_groups_table REFERENCE INTO lr_group_line WITH KEY group = iv_group al_object = iv_al_object al_subobject = iv_al_subobject.

      "A new AL handler is requested, first check if there is an existing handler for the AL object.
      CLEAR ls_group_line.
      LOOP AT mt_groups_table INTO ls_group_line WHERE al_object = iv_al_object AND al_subobject = iv_al_subobject AND al_extnumber = iv_al_extnumber AND al_loghandler IS NOT INITIAL.
        EXIT.
      ENDLOOP.
      IF ls_group_line-al_loghandler IS NOT INITIAL.
        "If handler found then use it
        lr_group_line->al_loghandler = ls_group_line-al_loghandler.
      ELSE.
        CLEAR ls_header_log.
        ls_header_log-object = iv_al_object.
        ls_header_log-subobject = iv_al_subobject.
        ls_header_log-extnumber = iv_al_extnumber.
        ls_header_log-altcode = sy-tcode.
        ls_header_log-alprog = sy-cprog.
        CALL FUNCTION 'BAL_LOG_CREATE'
          EXPORTING
            i_s_log                 = ls_header_log
          IMPORTING
            e_log_handle            = lr_group_line->al_loghandler
          EXCEPTIONS
            log_header_inconsistent = 1
            OTHERS                  = 2.
        IF sy-subrc <> 0  ##NEEDED.
* Implement suitable error handling here
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  SORT mt_groups_table BY group al_object al_subobject.

  "Update the Higher level
  mv_level_max = 0.
  LOOP AT mt_groups_table INTO ls_group_line.
    IF ls_group_line-level > mv_level_max.
      mv_level_max = ls_group_line-level.
    ENDIF.
  ENDLOOP.
ENDMETHOD.