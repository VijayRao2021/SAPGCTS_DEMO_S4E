  METHOD filter_method_delta.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 09/10/2019 ! GAP-3397: Add filter method for the delta mode                         *
****************************************************************************************************
    DATA:
      lv_interface_id TYPE zinterface_id,
      lv_variant      TYPE raldb_vari,

      lr_file         TYPE REF TO zfile_s_file_attributes,
      ls_delta        TYPE zfi_inter_out,

      lo_delta        TYPE REF TO z_cl_bc_outbound_interface.

    lv_interface_id = mv_process_id(10).
    lv_variant = mv_process_id+10.
    lo_delta = z_cl_bc_outbound_interface=>factory( EXPORTING iv_interface_id = lv_interface_id iv_variant_name = lv_variant ).

    CALL METHOD lo_delta->get_detail
      IMPORTING
        es_interface_detail  = ls_delta
      EXCEPTIONS
        cant_found_interface = 1
        OTHERS               = 2.
    IF sy-subrc = 0."Continue only if no problem.
      LOOP AT ct_folder_files REFERENCE INTO lr_file.
        IF lr_file->date < ls_delta-fromdate OR lr_file->date > ls_delta-todate OR
           ( lr_file->date = ls_delta-fromdate AND lr_file->time < ls_delta-fromtime ) OR
           ( lr_file->date = ls_delta-todate AND lr_file->time >= ls_delta-totime ).
          "file is outside of the delta time frame so delete it.
          DELETE ct_folder_files.
        ENDIF.
      ENDLOOP.
      lo_delta->update( ).
    ENDIF.
  ENDMETHOD.