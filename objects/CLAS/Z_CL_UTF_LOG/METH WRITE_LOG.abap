* Modfications
* ----------------------------------------------------------------------*
* Developer:  ATHERTS
* Date:       11.11.2020
* Mark:       SBA01
* Descr:      An extra check is required so that the log is not displayed
*             if there are no messages therein
* ----------------------------------------------------------------------*

METHOD WRITE_LOG.
  DATA:
    ls_group              TYPE zlog_ts_group_line,
    ls_display_profile    TYPE bal_s_prof,
    ls_fields_cat         TYPE bal_s_fcat,
    ls_filter_range       TYPE bal_rfield,
    ls_msg_context_filter TYPE bal_s_cfil,
    lt_msg_context_filter TYPE bal_t_cfil,
    lt_log_handles        TYPE bal_t_logh.
  DATA:
    lt_msg                TYPE bal_t_msgr.                        "+SBA01

  "Get the main BAL handler
  READ TABLE mt_groups_table INTO ls_group WITH KEY group = ''.
  IF sy-subrc = 0.
    APPEND ls_group-al_loghandler TO lt_log_handles.
  ENDIF.

* BOI ---------------------------------------------------------- +SBA01
  CALL FUNCTION 'BAL_LOG_READ'
    EXPORTING
      i_log_handle  = ls_group-al_loghandler
    IMPORTING
      et_msg        = lt_msg
    EXCEPTIONS
      log_not_found = 1
      OTHERS        = 2.

  IF sy-subrc <> 0.
    EXIT.                 "no log found
  ELSE.
*   Check there are messages
    IF lt_msg IS INITIAL.
      EXIT.
    ENDIF.
  ENDIF.
* EOI ---------------------------------------------------------- +SBA01

  CALL FUNCTION 'BAL_DSP_PROFILE_NO_TREE_GET'
    IMPORTING
      e_s_display_profile = ls_display_profile.

  "Set title
  ls_display_profile-title = sy-title.

  "Set column optimization
  ls_display_profile-cwidth_opt = abap_true.      " INS GK-001 GAP-3440 07.02.2020 to do column optimization.

  "Set color for the probclasses.
  ls_display_profile-colors-probclass1 = 1.
  ls_display_profile-colors-probclass2 = 5.
  ls_display_profile-colors-probclass3 = 3.
  ls_display_profile-colors-probclass4 = 6.

  "Set fields to display and the order
  REFRESH ls_display_profile-mess_fcat.
  CLEAR ls_fields_cat.
  ls_fields_cat-ref_table = 'BAL_S_SHOW'.
  ls_fields_cat-ref_field = 'MSG_STMP'.
  ls_fields_cat-col_pos = 2.
  APPEND ls_fields_cat TO ls_display_profile-mess_fcat.
  ls_fields_cat-ref_field = 'DETLEVEL'.
  ls_fields_cat-col_pos = 4.
  APPEND ls_fields_cat TO ls_display_profile-mess_fcat.
  ls_fields_cat-ref_field = 'T_MSG'.
  ls_fields_cat-col_pos = 5.
  APPEND ls_fields_cat TO ls_display_profile-mess_fcat.
  ls_fields_cat-ref_table = zlog_context_structure.
  ls_fields_cat-ref_field = 'LOG_GROUP'.
  ls_fields_cat-col_pos = 3.
  APPEND ls_fields_cat TO ls_display_profile-mess_fcat.

  "Filter groups which should not be displayed
  LOOP AT mt_groups_table INTO ls_group WHERE display = ''.
    CLEAR ls_msg_context_filter.
    ls_msg_context_filter-tabname = zlog_context_structure.
    ls_msg_context_filter-fieldname = 'LOG_GROUP'.
    ls_filter_range-sign = 'E'.
    ls_filter_range-option = 'EQ'.
    ls_filter_range-low = ls_group-group.
    APPEND ls_filter_range TO ls_msg_context_filter-t_range.
  ENDLOOP.
  IF ls_msg_context_filter-t_range[] IS NOT INITIAL.
    APPEND ls_msg_context_filter TO lt_msg_context_filter.
  ENDIF.

  ls_display_profile-use_grid = iv_grid.
  IF iv_fullscreen IS INITIAL.
    ls_display_profile-start_row = 10.
    ls_display_profile-start_col = 10.
    ls_display_profile-pop_adjst = 'X'.
  ENDIF.

  CALL FUNCTION 'BAL_DSP_LOG_DISPLAY'
    EXPORTING
      i_s_display_profile    = ls_display_profile
      i_t_log_handle         = lt_log_handles
*     I_T_MSG_HANDLE         =
*     I_S_LOG_FILTER         =
*     I_S_MSG_FILTER         =
*     I_T_LOG_CONTEXT_FILTER =
      i_t_msg_context_filter = lt_msg_context_filter
*     I_AMODAL               = ' '
*     I_SRT_BY_TIMSTMP       = ' '
* IMPORTING
*     E_S_EXIT_COMMAND       =
    EXCEPTIONS
      profile_inconsistent   = 1
      internal_error         = 2
      no_data_available      = 3
      no_authority           = 4
      OTHERS                 = 5.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 3.
        WRITE: / 'No log data to display'(i01).
      WHEN 4.
        WRITE: / 'No authorization to display the log'(i02).
      WHEN OTHERS.
        WRITE: / 'Cannot display the log'(i03).
    ENDCASE.
  ENDIF.
ENDMETHOD.