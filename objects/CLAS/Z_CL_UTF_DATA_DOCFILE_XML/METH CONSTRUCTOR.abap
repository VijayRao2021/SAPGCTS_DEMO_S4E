  METHOD CONSTRUCTOR.
    super->constructor( iv_dataset_type = iv_dataset_type iv_process_id = iv_process_id ).

    mv_document_number = iv_document_number.
    mo_document_data = io_document_data.
  ENDMETHOD.