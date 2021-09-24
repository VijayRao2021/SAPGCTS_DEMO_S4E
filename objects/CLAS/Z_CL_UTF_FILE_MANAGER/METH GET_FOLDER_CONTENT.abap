  METHOD get_folder_content.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON !  29.03.2019! GAP2192: Extract content of a folder                                   *
****************************************************************************************************
    DATA:
      lv_folder_to_read   TYPE eps2filnam,
      lv_errno(3)         TYPE c,
      lv_errmsg(40)       TYPE c,

      lv_cnt_folder_entry TYPE epsf-epsfilsiz,
      lv_error_counter    TYPE epsf-epsfilsiz,
      lv_flg_error        TYPE flag,

      ls_file             TYPE zfile_s_file_attributes.

    "Look for the available files in the folder.
    lv_folder_to_read = iv_folder.
    CLEAR lv_flg_error.

* get directory listing
    CALL 'C_DIR_READ_FINISH'                  " just to be sure
          ID 'ERRNO'  FIELD lv_errno
          ID 'ERRMSG' FIELD lv_errmsg.                    "#EC CI_CCALL

    CALL 'C_DIR_READ_START'
          ID 'DIR'    FIELD lv_folder_to_read
          ID 'FILE'   FIELD ''
          ID 'ERRNO'  FIELD lv_errno
          ID 'ERRMSG' FIELD lv_errmsg.                    "#EC CI_CCALL
    IF sy-subrc <> 0.
      lv_flg_error = abap_true.
    ELSE.
      CLEAR rt_folder_content.
      CLEAR: lv_cnt_folder_entry, lv_error_counter.
      DO.
        CLEAR: ls_file.
        CALL 'C_DIR_READ_NEXT'
              ID 'TYPE'    FIELD ls_file-file_type
              ID 'NAME'    FIELD ls_file-name
              ID 'LEN'     FIELD ls_file-file_size
              ID 'OWNER'   FIELD ls_file-owner
              ID 'MTIME'   FIELD ls_file-mtime
              ID 'MODE'    FIELD ls_file-file_mode
              ID 'ERRNO'   FIELD lv_errno
              ID 'ERRMSG'  FIELD lv_errmsg.               "#EC CI_CCALL
        IF sy-subrc = 0.
          "No error when retrieving file attribute then check if current file is a regular file and if its name matches with file pattern if required.
          ADD 1 TO lv_cnt_folder_entry.
          DATA: lv_tstmp      TYPE timestamp,
                lv_tstmp_file TYPE timestamp.
          CONVERT DATE '19700101' TIME '000000'  INTO TIME STAMP lv_tstmp TIME ZONE 'UTC   '.
          lv_tstmp_file = ls_file-mtime.
          TRY.
              CALL METHOD cl_abap_tstmp=>add
                EXPORTING
                  tstmp   = lv_tstmp
                  secs    = lv_tstmp_file
                RECEIVING
                  r_tstmp = lv_tstmp_file.
            CATCH cx_parameter_invalid_range.
              CLEAR lv_tstmp_file.
            CATCH cx_root.
              CLEAR lv_tstmp_file.
          ENDTRY.
          CONVERT TIME STAMP lv_tstmp_file TIME ZONE sy-zonlo INTO DATE ls_file-date TIME ls_file-time.
          CONCATENATE ls_file-date ls_file-time INTO ls_file-mtime.
*          ls_file-mtime = lv_tstmp_file.
          CONDENSE ls_file-mtime NO-GAPS.
          APPEND ls_file TO rt_folder_content.
        ELSEIF sy-subrc = 1.
          EXIT.
        ELSE.
          IF lv_error_counter > 1000.
            CALL 'C_DIR_READ_FINISH'
                  ID 'ERRNO'  FIELD lv_errno
                  ID 'ERRMSG' FIELD lv_errmsg.            "#EC CI_CCALL
            lv_flg_error = abap_true.
            EXIT.
          ENDIF.
          ADD 1 TO lv_error_counter.
        ENDIF.
      ENDDO.

      CALL 'C_DIR_READ_FINISH'
            ID 'ERRNO'  FIELD lv_errno
            ID 'ERRMSG' FIELD lv_errmsg.                  "#EC CI_CCALL

      IF lv_flg_error = abap_true.
        RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_GET_CONTENT' iv_level = 1 iv_type = 'W' iv_msg1 = 'Cannot read the files list for folder &2: RC=&3.'(w04) iv_msg2 = iv_folder iv_msg3 = sy-subrc.
        CLEAR rt_folder_content.
        EXIT.
      ENDIF.

      IF lv_cnt_folder_entry > 0.
        SORT rt_folder_content BY file_type name ASCENDING.
      ENDIF.
    ENDIF.
  ENDMETHOD.