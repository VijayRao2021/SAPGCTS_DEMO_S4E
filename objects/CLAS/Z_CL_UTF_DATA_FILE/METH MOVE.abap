  METHOD move.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: rewrite move method to improve it (control, log...)          *
* GAP-2974   !            !                                                                        *
****************************************************************************************************
*-Begin of GAP-2974+
    DATA:
      lv_target_path   TYPE string,
      lv_full_filename TYPE string.

    rv_rc = 0.
    lv_target_path = get_full_path( iv_target_folder ).

    "Define the target file name
    IF iv_target_filename IS SUPPLIED AND iv_target_filename IS NOT INITIAL.
      CONCATENATE lv_target_path '/' iv_target_filename INTO lv_full_filename.
    ELSE.
      "else use the current name.
      lv_full_filename = get_full_filename( lv_target_path ).
    ENDIF.
    IF lv_full_filename <> mv_filename_full."Cannot move the file on same place and name.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_MOVE' iv_level = 0 iv_type = 'I' iv_msg1 = 'Move file to &2.'(i08) iv_msg2 = lv_full_filename.

      rv_rc = copy( iv_target_folder = iv_target_folder iv_target_filename = iv_target_filename ).
      IF rv_rc = 0.
        rv_rc = delete( ).
        IF rv_rc = 0.
          IF iv_target_filename IS NOT INITIAL.
            mv_filename = iv_target_filename.
          ENDIF.
          mv_current_folder = lv_target_path.
          mv_filename_full = get_full_filename( ).
        ENDIF.
      ENDIF.
      IF rv_rc <> 0.
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_MOVE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Move failed.'(e10).
      ENDIF.
    ENDIF.
*-End of GAP-2974+
  ENDMETHOD.