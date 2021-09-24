  METHOD constructor.
    super->constructor( iv_dataset_type = iv_dataset_type iv_process_id = iv_process_id io_file = io_file ).

    mv_start_offset = iv_start_offset.
    mv_end_offset = iv_end_offset.
    mt_document_data[] = it_document_data[].
  ENDMETHOD.