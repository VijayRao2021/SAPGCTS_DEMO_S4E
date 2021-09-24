METHOD IS_AUDITABLE.
  IF mv_auditable = abap_true.
    rv_returncode = 0.
  ELSE.
    rv_returncode = 8.
  ENDIF.
ENDMETHOD.