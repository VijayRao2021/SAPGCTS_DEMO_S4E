METHOD IS_FAILED.
  IF '51' CS ms_control_record-status.
    rv_returncode = 0.
  ELSE.
    rv_returncode = 8.
  ENDIF.
ENDMETHOD.