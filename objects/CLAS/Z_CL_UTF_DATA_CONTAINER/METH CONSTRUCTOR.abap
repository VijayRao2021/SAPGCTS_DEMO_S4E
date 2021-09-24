METHOD constructor.
  RAISE EVENT send_log EXPORTING iv_group = 'DATASET_CONTAINER_CONSTRUCTOR' iv_level = 0 iv_type = 'H' iv_msg1 = 'Initializing a Container object...'(h01).

  super->constructor( iv_dataset_type = iv_dataset_type iv_process_id = iv_process_id ).

  CLEAR( ).

  ENDMETHOD.