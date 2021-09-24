CLASS z_cl_utf_data_docfile DEFINITION
  PUBLIC
  INHERITING FROM z_cl_utf_data_dataset
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPE-POOLS zdatm .
    METHODS constructor
      IMPORTING
        !iv_dataset_type TYPE zdatm_tv_dataset_type
        !iv_process_id   TYPE zproc_process_id OPTIONAL
        !io_file         TYPE REF TO z_cl_utf_data_file OPTIONAL .
    METHODS process
      CHANGING
        !cv_fs_error TYPE flag OPTIONAL .