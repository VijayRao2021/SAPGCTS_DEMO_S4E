  METHOD open.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: add the file type (ASC/BIN) management provided by file      *
* GAP-2974   !            ! management framework                                                   *
* D. CRESSON ! 06/09/2019 ! GAP-3303: Introduce a temp solution to be able to force the file type  *
* GAP-3303   !            ! over the file manager config to manage process ID with BIN/ASC files   *
****************************************************************************************************
    DATA:
          lv_filetype TYPE string.

    rv_rc = 0.
    IF is_open( ) = 8.
*-Begin of GAP-2974+
      IF iv_filetype = 'FASC'.                              "GAP3303+
        lv_filetype = 'ASC'.                                "GAP3303+
      ELSE.                                                 "GAP3303+
        IF mv_file_type IS NOT INITIAL.
          lv_filetype = mv_file_type.
        ELSE.
          lv_filetype = iv_filetype.
        ENDIF.
      ENDIF.                                                "GAP3303+
*-End of GAP-2974+
*      IF iv_opentype = 'INPUT' OR ( (  iv_opentype IS INITIAL ) AND ( mv_dataset_type = zdatm_c_datasettype_inbound OR mv_dataset_type = zdatm_c_datasettype_toquery ) ).
      IF mv_dataset_type = zdatm_c_datasettype_inbound OR mv_dataset_type = zdatm_c_datasettype_toquery.
        IF lv_filetype = 'ASC'.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Open text file &2 in read mode.'(i05) iv_msg2 = mv_filename.
          OPEN DATASET mv_filename_full FOR INPUT IN TEXT MODE ENCODING DEFAULT.
          IF sy-subrc <> 0.
            rv_rc = sy-subrc.
            RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot open the file, RC = &2.'(e04) iv_msg2 = sy-subrc.
          ELSE.
            mv_is_open = abap_true.
          ENDIF.
        ELSE.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Open binary file &2 in read mode.'(i16) iv_msg2 = mv_filename.
          OPEN DATASET mv_filename_full FOR INPUT IN BINARY MODE.
          IF sy-subrc <> 0.
            rv_rc = sy-subrc.
            RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot open the file, RC = &2.'(e04) iv_msg2 = sy-subrc.
          ELSE.
            mv_is_open = abap_true.
          ENDIF.
        ENDIF.
      ELSE.
        IF lv_filetype = 'ASC'.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Open text file &2 in write mode.'(i06) iv_msg2 = mv_filename.
          OPEN DATASET mv_filename_full FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
          IF sy-subrc <> 0.
            rv_rc = sy-subrc.
            RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot open the file, RC = &2.'(e04) iv_msg2 = sy-subrc.
          ELSE.
            mv_is_open = abap_true.
          ENDIF.
        ELSE.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Open binary file &2 in write mode.'(i17) iv_msg2 = mv_filename.
          OPEN DATASET mv_filename_full FOR OUTPUT IN BINARY MODE.
          IF sy-subrc <> 0.
            rv_rc = sy-subrc.
            RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot open the file, RC = &2.'(e04) iv_msg2 = sy-subrc.
          ELSE.
            mv_is_open = abap_true.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_OPEN' iv_level = 1 iv_type = 'W' iv_msg1 = 'File &2 is already open'(w02) iv_msg2 = mv_filename.
      rv_rc = 8.
    ENDIF.
  ENDMETHOD.