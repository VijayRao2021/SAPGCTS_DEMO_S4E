  METHOD process_documents.
    DATA:
          ls_file_document TYPE zdatm_file_ts_file_doc.

    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_PROCESS' iv_level = 0 iv_type = 'H' iv_msg1 = 'Process the file documents...'(h03).
    LOOP AT mt_file_docs INTO ls_file_document.
      ls_file_document-document->process( ).
    ENDLOOP.
  ENDMETHOD.