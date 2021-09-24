  METHOD load.
    "get content from the file if available
    IF mo_file IS BOUND.
      mo_file->get_content( EXPORTING iv_start_offset = mv_start_offset iv_end_offset = mv_end_offset IMPORTING et_content = mt_document_data ).
    ENDIF.
  ENDMETHOD.