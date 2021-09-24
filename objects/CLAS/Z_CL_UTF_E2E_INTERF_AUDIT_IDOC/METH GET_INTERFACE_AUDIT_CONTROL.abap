METHOD GET_INTERFACE_AUDIT_CONTROL.
  IF ( is_auditable( ) = 0 ).
    rs_audit_control = ms_audit_record.
  ELSE.
    RAISE idoc_not_auditable.
  ENDIF.
ENDMETHOD.