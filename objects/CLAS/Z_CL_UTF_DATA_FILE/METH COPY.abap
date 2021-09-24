  METHOD copy.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: improve the copy process (control, log...)                   *
* GAP-2974   !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 07/09/2020 ! GAP-3397: Fix a bug in the binary copy                                 *
* GAP-3397   !            !                                                                        *
****************************************************************************************************
    DATA:
      lv_target_path   TYPE string,
      lv_full_filename TYPE string,
      lv_file_line     TYPE zdatm_file_ts_file_content,
      lv_file_linex    TYPE xstring,                        "GAP-3397+
      lv_dataset_type  TYPE zdatm_tv_dataset_type.          "GAP-2974+


    "Define the target folder where to copy the file
*-Begin of GAP-2974-
*    IF 'ROOT/ARCHIVE/PROGRESS' CS iv_target_folder AND mo_file_manager IS BOUND.
*      lv_target_path = mo_file_manager->get_folder( iv_target_folder ).
*    ELSE.
*-End of GAP-2974-
    lv_target_path = get_full_path( iv_target_folder ).
*  ENDIF."GAP-2974-

    "Define the target file name is required
    IF iv_target_filename IS SUPPLIED AND iv_target_filename IS NOT INITIAL.
      CONCATENATE lv_target_path '/' iv_target_filename INTO lv_full_filename.
    ELSE.
      "else use the current name.
      lv_full_filename = get_full_filename( lv_target_path ).
    ENDIF.
    IF lv_full_filename <> mv_filename_full."Cannot copy the file on same place and name "GAP-2974+
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_COPY' iv_level = 1 iv_type = 'I' iv_msg1 = 'Copy file to &2.'(i07) iv_msg2 = lv_full_filename.

      CLEAR rv_rc.
      IF mt_file_data[] IS INITIAL.
        " the file is not in memory,
        IF is_open( ) <> 0.
          "Change the dataset type in case of the current type is Outbound (in this file will be opened in write mode not in read mode).
          lv_dataset_type = mv_dataset_type.                "GAP-2974+
          mv_dataset_type = zdatm_c_datasettype_toquery.    "GAP-2974+
          "File is not open so open it.
          IF ( open( ) <> 0 ).
            rv_rc = sy-subrc.
            EXIT.
          ENDIF.
          mv_dataset_type = lv_dataset_type.                "GAP-2974+
        ENDIF.
      ENDIF.

      "Open the target file
      IF mv_file_type IS INITIAL OR mv_file_type = 'ASC'.   "GAP-2974+
        OPEN DATASET lv_full_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
      ELSE.                                                 "GAP-2974+
        OPEN DATASET lv_full_filename FOR OUTPUT IN BINARY MODE. "GAP-2974+
      ENDIF.                                                "GAP-2974+
      IF sy-subrc = 0.
        IF mt_file_data[] IS NOT INITIAL.
          "Data are in memory so do a transfer memory to file
          LOOP AT mt_file_data INTO lv_file_line.
            TRANSFER lv_file_line TO lv_full_filename.
          ENDLOOP.
        ELSE.
          "Data not in memory so do a file to file transfer
          IF mv_file_type IS INITIAL OR mv_file_type = 'ASC'. "GAP-3397+
            DO.
              READ DATASET mv_filename_full INTO lv_file_line.
              IF sy-subrc <> 0.
                EXIT.
              ENDIF.
              TRANSFER lv_file_line TO lv_full_filename.
            ENDDO.
*-Begin of GAP-3397+
          ELSE.
            DO.
              READ DATASET mv_filename_full INTO lv_file_linex.
              IF sy-subrc <> 0.
                EXIT.
              ENDIF.
              TRANSFER lv_file_linex TO lv_full_filename.
            ENDDO.
          ENDIF.
*-End of GAP-3397+
        ENDIF.
        CLOSE DATASET lv_full_filename.
      ELSE.
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_COPY' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot open in write mode &2.'(e07) iv_msg2 = lv_full_filename.
        rv_rc = 8.
      ENDIF.
    ENDIF.                                                  "GAP-2974+
  ENDMETHOD.