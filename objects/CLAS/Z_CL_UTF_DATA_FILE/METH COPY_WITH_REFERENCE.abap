  METHOD copy_with_reference.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 27/01/2020 ! GAP-3397: create the method                                            *
* GAP-3397   !            !                                                                        *
****************************************************************************************************
    IF ( copy( iv_target_folder = iv_target_folder iv_target_filename = iv_target_filename ) = 0 ).
      "copy is successful then create the file object
      ro_file = NEW #( iv_dataset_type = mv_dataset_type iv_filename = iv_target_filename iv_subfolder = iv_target_folder iv_process_id = mv_process_id ).
    ELSE.
      "Problem during the copy then clear the reference.
      CLEAR ro_file.
    ENDIF.
  ENDMETHOD.