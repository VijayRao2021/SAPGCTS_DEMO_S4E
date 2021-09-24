  METHOD delete.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: add a return code to the method and add log message          *
* GAP-2974   !            !                                                                        *
****************************************************************************************************
    IF is_open( ) = 0.
      close( ).
    ENDIF.
    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_DELETE' iv_level = 0 iv_type = 'I' iv_msg1 = 'Delete file &2.'(i12) iv_msg2 = mv_filename_full. "GAP-2974+
    DELETE DATASET mv_filename_full.
*-Begin of "GAP-2974+
    rv_rc = sy-subrc.
    IF rv_rc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_DELETE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Deletion failed.'(e09).
    ENDIF.
*-End of "GAP-2974+
  ENDMETHOD.