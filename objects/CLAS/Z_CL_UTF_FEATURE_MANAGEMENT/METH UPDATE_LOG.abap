METHOD UPDATE_LOG.
  DATA:
        ls_log TYPE zfam_log.

** SOI SBA-01 19.10.2020
** This code is to ensure that when we have a background job with multiple
** attempts on the same lock, we do not get a SGL error 131 (timeout)
  STATICS: slv_update_done TYPE flag.
  IF slv_update_done IS INITIAL.
    slv_update_done = abap_true.
  ELSE.
    EXIT.
  ENDIF.
** EOI SBA-01 19.10.2020

  CLEAR ls_log.
  ls_log-feature_id = iv_feature_id.
  ls_log-progname = sy-cprog.
  ls_log-uname = sy-uname.
  ls_log-udate = sy-datum.
  ls_log-uzeit = sy-uzeit.


***SOI by GK-001 GAP-4024 14.09.2020 to delete updating ZFAM_LOG table directly
***Apply locking mechanism to lock, update and unlock table entries.

*    MODIFY zfam_log FROM ls_log.

  DO 10 TIMES.

    CALL FUNCTION 'ENQUEUE_EZFAM_LOG'
      EXPORTING
        mode_zfam_log  = 'E'
        mandt          = sy-mandt
        feature_id     = ls_log-feature_id
        progname       = ls_log-progname
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc EQ 0.
      MODIFY zfam_log FROM ls_log.

      CALL FUNCTION 'DEQUEUE_EZFAM_LOG'
        EXPORTING
          mode_zfam_log = 'E'
          mandt         = sy-mandt
          feature_id    = ls_log-feature_id
          progname      = ls_log-progname.

      EXIT.
    ENDIF.

  ENDDO.
***EOI by GK-001 GAP-4024 14.09.2020
ENDMETHOD.