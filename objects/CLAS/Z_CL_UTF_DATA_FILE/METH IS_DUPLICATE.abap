  METHOD is_duplicate.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* G. KANUGOLU! 14/11/2018 ! GAP-2974: manage the different duplicate check (by name or content)    *
* GK-001     !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSOD ! 20/07/2020 ! GAP-3397: Fix display bug                                              *
* GAP3397    !            !                                                                        *
****************************************************************************************************
    DATA:
      lv_hash         TYPE md5_fields-hash,
      ls_finger_print TYPE ze2e_finger_prt,
      lt_data         TYPE TABLE OF char255,
      lv_data         TYPE char255,
      lv_file_data    TYPE string.

    rv_rc = 0.

***SOI by GK-001 GAP(2974) 10.08.2018
    IF iv_duplicate_check = '0' OR iv_duplicate_check = ' '.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_DATASET_FILE_DUPLICATE' iv_level = 1 iv_type = 'I' iv_msg1 = 'No duplicate check performed on file &2.'(i15) iv_msg2 = mv_filename.
      rv_rc = 0.
      EXIT.
    ENDIF.
***EOI by GK-001 GAP(2974) 10.08.2018

    IF mt_file_data[] IS NOT INITIAL OR iv_duplicate_check = '2' .
      " Convert string format data to character type table, since MD5 FM will not accept string type tables.
      IF iv_duplicate_check = '1'.   " INS GK-001 GAP(2974) 06.08.2018
        LOOP AT mt_file_data INTO lv_file_data.
          lv_data = lv_file_data.
          CONDENSE lv_data NO-GAPS.
          APPEND lv_data TO lt_data.
          CLEAR:lv_data.
        ENDLOOP.
        " SOI GK-001 GAP(2974) 06.08.2018
      ELSEIF iv_duplicate_check = '2'.
        CLEAR lv_data.
        DATA(lv_filename) = get_file_name( ).
        MOVE lv_filename TO lv_data.
        CONDENSE lv_data NO-GAPS.
        APPEND lv_data TO lt_data.
      ENDIF.
      " EOI GK-001 GAP(2974) 06.08.2018

      CALL FUNCTION 'MD5_CALCULATE_HASH_FOR_CHAR'
*     EXPORTING
*       DATA                 =
*       LENGTH               = 0
*       VERSION              = 1
        IMPORTING
          hash           = lv_hash
        TABLES
          data_tab       = lt_data
        EXCEPTIONS
          no_data        = 1
          internal_error = 2
          OTHERS         = 3.
      IF sy-subrc <> 0.
        "Cannot calculate the hash so consider the idoc as already received by security
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_DATASET_FILE_DUPLICATE' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error when calculating MD5 checksum on file &2.'(e02) iv_msg2 = mv_filename.
        rv_rc = 8.
        EXIT.
      ENDIF.

*-Begin of GAP-3397-
*      SELECT interface_id INTO ls_finger_print
*        FROM ze2e_finger_prt UP TO 1 ROWS
*        WHERE interface_id = mv_process_id AND
*              finger_print = lv_hash
*        ORDER BY PRIMARY KEY.
*      ENDSELECT.
*End of GAP3397-

*-Begin of GAP-3397+
      SELECT interface_id, receiving_date INTO CORRESPONDING FIELDS OF @ls_finger_print
        FROM ze2e_finger_prt UP TO 1 ROWS
        WHERE interface_id = @mv_process_id AND
              finger_print = @lv_hash
        ORDER BY PRIMARY KEY.
      ENDSELECT.
*End of GAP3397+
      IF sy-subrc <> 0.
        "Not yet received so create entry in the table
        CLEAR ls_finger_print.
        ls_finger_print-interface_id = mv_process_id .
        ls_finger_print-finger_print = lv_hash.
        ls_finger_print-finger_print_type = 'F'.
        ls_finger_print-receiving_date = sy-datum.
        INSERT ze2e_finger_prt FROM ls_finger_print.
      ELSE.
        "Already received
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_DATASET_FILE_DUPLICATE' iv_level = 1 iv_type = 'E' iv_msg1 = 'File &2 has been already processed the &3.'(e03) iv_msg2 = mv_filename iv_msg3 = ls_finger_print-receiving_date.
        rv_rc = 8.
      ENDIF.
    ENDIF.
  ENDMETHOD.