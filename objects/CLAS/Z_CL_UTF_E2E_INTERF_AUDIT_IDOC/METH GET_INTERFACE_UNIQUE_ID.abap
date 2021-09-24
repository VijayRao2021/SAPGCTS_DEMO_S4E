METHOD GET_INTERFACE_UNIQUE_ID.
  IF ( is_auditable( ) = 0 ).
    rv_unique_id = ms_audit_record-unique_id.
  ELSE.
    RAISE idoc_not_auditable.
  ENDIF.
ENDMETHOD.