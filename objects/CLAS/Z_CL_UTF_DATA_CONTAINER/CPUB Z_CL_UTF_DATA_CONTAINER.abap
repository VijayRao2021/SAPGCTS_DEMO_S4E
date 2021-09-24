class Z_CL_UTF_DATA_CONTAINER definition
  public
  inheriting from Z_CL_UTF_DATA_DATASET
  create public .

public section.

  methods ADD
    importing
      !IO_DATA_OBJECT type ref to Z_CL_utf_DATA_DATASET .
  methods CLEAR .
  methods CONSTRUCTOR
    importing
      !IV_DATASET_TYPE type ZDATM_TV_DATASET_TYPE
      !IV_PROCESS_ID type ZPROC_PROCESS_ID default SPACE .
  methods LOOP
    returning
      value(RO_DATA_OBJECT) type ref to Z_CL_utf_DATA_DATASET .
  methods REMOVE
    importing
      !IO_DATA_OBJECT type ref to Z_CL_utf_DATA_DATASET .