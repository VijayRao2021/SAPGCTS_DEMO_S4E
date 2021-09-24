  METHOD get_file_list.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* G. KANUGOLU! 14/11/2018 ! GAP-2974: add error folder management. Add call to additional filter   *
*            !            ! method if it is configued.Add preproc comment to remove warnings in the*
* GK-001     !            ! syntax check                                                           *
* GK-002     ! 09/12/2018 ! Adding Retention filtering method GAP(2192)
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 20/07/2020 ! GAP-3397: Use new get_folder_content method, add delta filter          *
* GAP-3397   !            !                                                                        *
*--------------------------------------------------------------------------------------------------*
* PANNERS    ! 06/01/2021 ! GAP-3397_W: Warranty fix - This method should return the latest file   *
* GAP-3397_W !            ! from the folder when the import parameter IV_LAST_ONE is 'X'. This     *
*            !            ! was not working after GAP-3397, and this functionality had been enabled*
*            !            ! again through GAP_3397_W                                               *
****************************************************************************************************
*-Begin of GAP3397-
*    TYPES:
*      BEGIN OF lts_file,
*        dirname(75) TYPE c, " name of directory. (possibly truncated.)
*        name        TYPE eps2filnam, " name of entry. (possibly truncated.)
*        type(10)    TYPE c, " type of entry.
*        len(8)      TYPE p DECIMALS 0, " length in bytes.
*        owner(8)    TYPE c, " owner of the entry.
*        mtime(6)    TYPE p DECIMALS 0, " last modification date, seconds since 1970
*        mode(9)     TYPE c, " like "rwx-r-x--x": protection mode.
*        errno(3)    TYPE c,
*        errmsg(40)  TYPE c,
*      END OF lts_file.
*-End of GAP3397-
    DATA:
      lv_folder_to_read TYPE eps2filnam,
      lv_folder_2_read  TYPE string,
      lv_filename       TYPE string,

      lv_file_counter   TYPE epsf-epsfilsiz,
      lv_error_counter  TYPE epsf-epsfilsiz,
      lv_flg_error      TYPE flag,
      lv_pattern        TYPE string,

      lo_file           TYPE REF TO z_cl_utf_data_file,
      lo_file_container TYPE REF TO z_cl_utf_data_container,
*      ls_folder_file    TYPE eps2fili,"GAP3397-
      ls_folder_file    TYPE zfile_s_file_attributes,       "GAP3397+
      lr_file           TYPE REF TO zfile_s_file_attributes, "GAP3397+
*      ls_file           TYPE lts_file,"GAP3397-
*      lt_folder_files   TYPE STANDARD TABLE OF eps2fili."GAP3397-
      lt_folder_files   TYPE zfile_t_files_list.            "GAP3397+

    CLEAR lo_file_container.

    "Define which folder need to be read.
    IF iv_subfolder IS NOT INITIAL.
      CASE iv_subfolder.
        WHEN 'ROOT'.
          lv_folder_2_read = ms_file_manager-root_folder.
        WHEN 'PROGRESS'.
          lv_folder_2_read = ms_file_manager-progress_folder.
        WHEN 'ARCHIVE'.
          lv_folder_2_read = ms_file_manager-archive_folder.
***SOI by GK-001 GAP(2974) 10.08.2018
        WHEN 'ERROR'.
          lv_folder_2_read = ms_file_manager-error_folder.
***EOI by GK-001 GAP(2974) 10.08.2018
        WHEN OTHERS.
          CONCATENATE ms_file_manager-root_folder '/' iv_subfolder INTO lv_folder_2_read.
      ENDCASE.
    ELSE.
      lv_folder_2_read = ms_file_manager-root_folder.
    ENDIF.

    "check if a pattern need to be applied
    IF iv_pattern IS SUPPLIED AND iv_pattern IS NOT INITIAL.
      lv_pattern = iv_pattern.
    ELSEIF ms_file_manager-file_pattern IS NOT INITIAL.
      lv_pattern = ms_file_manager-file_pattern.
    ELSE.
      CLEAR lv_pattern.
    ENDIF.

    "Look for the available files in the folder.
    lv_folder_to_read = lv_folder_2_read.
    CLEAR lv_flg_error.
*-Begin of GAP3397-
** get directory listing
*    CALL 'C_DIR_READ_FINISH'                  " just to be sure
*          ID 'ERRNO'  FIELD ls_file-errno
*          ID 'ERRMSG' FIELD ls_file-errmsg.               "#EC CI_CCALL
*
*    CALL 'C_DIR_READ_START'
*          ID 'DIR'    FIELD lv_folder_to_read
*          ID 'FILE'   FIELD ''
*          ID 'ERRNO'  FIELD ls_file-errno
*          ID 'ERRMSG' FIELD ls_file-errmsg.               "#EC CI_CCALL
*    IF sy-subrc <> 0.
*      lv_flg_error = abap_true.
*    ELSE.
*      CLEAR lt_folder_files.
*      CLEAR: lv_file_counter, lv_error_counter.
*      DO.
*        CLEAR: ls_file, ls_folder_file.
*        CALL 'C_DIR_READ_NEXT'
*              ID 'TYPE'   FIELD ls_file-type
*              ID 'NAME'   FIELD ls_file-name
*              ID 'LEN'    FIELD ls_file-len
*              ID 'OWNER'  FIELD ls_file-owner
*              ID 'MTIME'  FIELD ls_file-mtime
*              ID 'MODE'   FIELD ls_file-mode
*              ID 'ERRNO'  FIELD ls_file-errno
*              ID 'ERRMSG' FIELD ls_file-errmsg.           "#EC CI_CCALL
*        IF sy-subrc = 0.
*          "No error when retrieving file attribute then check if current file is a regular file and if its name matches with file pattern if required.
*          IF ( ls_file-type(1) = 'f' OR ls_file-type(1) = 'F' ) AND
*             ( lv_pattern IS INITIAL OR ls_file-name CP lv_pattern ) AND
*             ls_file-name(1) <> '.'."GAP2192 Exclude metadata files starting with a '.'
*            ls_folder_file-size = ls_file-len.
*            ls_folder_file-name = ls_file-name.
*            IF NOT ls_file-name IS INITIAL.
*              "Converting file time stamp to human readable date and time.
*              DATA: lv_tstmp TYPE timestamp.
*              CONVERT DATE '19700101' TIME '000000'  INTO TIME STAMP lv_tstmp TIME ZONE 'UTC   '.
*              TRY.
*                  CALL METHOD cl_abap_tstmp=>add
*                    EXPORTING
*                      tstmp   = lv_tstmp
*                      secs    = ls_file-mtime
*                    RECEIVING
*                      r_tstmp = lv_tstmp.
*                CATCH cx_parameter_invalid_range.
*                  CLEAR lv_tstmp.
*                CATCH cx_root.
*                  CLEAR lv_tstmp.
*              ENDTRY.
*              WRITE lv_tstmp TIME ZONE sy-zonlo TO ls_folder_file-mtim.
*            ELSE.
*              CLEAR ls_folder_file-mtim.
*            ENDIF.
*            ls_folder_file-owner = ls_file-owner.
*
*            ADD 1 TO lv_file_counter.
*            ls_folder_file-rc   = 0.
*            APPEND ls_folder_file TO lt_folder_files.
*          ENDIF.
*        ELSEIF sy-subrc = 1.
*          EXIT.
*        ELSE.
*          IF lv_error_counter > 1000.
*            CALL 'C_DIR_READ_FINISH'
*                  ID 'ERRNO'  FIELD ls_file-errno
*                  ID 'ERRMSG' FIELD ls_file-errmsg.       "#EC CI_CCALL
*            lv_flg_error = abap_true.
*            EXIT.
*          ENDIF.
*          ADD 1 TO lv_error_counter.
*        ENDIF.
*      ENDDO.
*
*      CALL 'C_DIR_READ_FINISH'
*            ID 'ERRNO'  FIELD ls_file-errno
*            ID 'ERRMSG' FIELD ls_file-errmsg.             "#EC CI_CCALL
*
*      IF lv_file_counter > 0.
*        IF iv_last_one = abap_true.
*          SORT lt_folder_files BY mtim DESCENDING.
*          "Read the last file
*          READ TABLE lt_folder_files INTO ls_folder_file INDEX 1.
*          IF sy-subrc = 0.
*            CLEAR lt_folder_files[].
*            APPEND ls_folder_file TO lt_folder_files.
*            lv_file_counter = 1.
*          ENDIF.
*        ELSE.
*          SORT lt_folder_files BY name ASCENDING.
*        ENDIF.
*      ENDIF.
*    ENDIF.
*-End of GAP3397-

*-Begin of GAP3397+ Use the new get_folder_content method
    lt_folder_files = get_folder_content( iv_folder = lv_folder_2_read ).
    "Delete folder and apply pattern.
    LOOP AT lt_folder_files REFERENCE INTO  lr_file.
      IF lr_file->file_type(1) = 'D' OR lr_file->file_type(1) = 'd'.
        DELETE lt_folder_files INDEX sy-tabix.
        CONTINUE.
      ENDIF.
      IF NOT ( ( lv_pattern IS INITIAL OR lr_file->name CP lv_pattern ) AND lr_file->name(1) <> '.' ).
        DELETE lt_folder_files INDEX sy-tabix.
        CONTINUE.
      ENDIF.
    ENDLOOP.
*-End of GAP3397+

*-Begin of GAP3397+
    IF ms_file_manager-delta_mode = abap_true.
      filter_method_delta( EXPORTING iv_subfolder = iv_subfolder CHANGING ct_folder_files = lt_folder_files ).
    ENDIF.
*-End of GAP3397+

***SOI by GK-001 GAP(2974) 08.08.2018
*    IF ms_file_manager-filter_method IS NOT INITIAL.        "GAP2192-
    IF ms_file_manager-filter_method IS NOT INITIAL AND ( iv_subfolder = 'ROOT' OR iv_subfolder = 'PROGRESS' ). "GAP2192+
      CALL METHOD (ms_file_manager-filter_method)
        EXPORTING
          iv_subfolder    = iv_subfolder
        CHANGING
          ct_folder_files = lt_folder_files.
    ENDIF.
***EOI by GK-001 GAP(2974) 08.08.2018

***SOI by GK-001 GAP(2192) 06.12.2018
    IF iv_filter_method IS NOT INITIAL.
      CALL METHOD (iv_filter_method)
        EXPORTING
          iv_subfolder    = iv_subfolder
        CHANGING
          ct_folder_files = lt_folder_files.
    ENDIF.
***EOI by GK-001 GAP(2192) 06.12.2018

*** Begin of insert - GAP-3397 - Warranty fix
    IF iv_last_one = abap_true AND lt_folder_files[] IS NOT INITIAL.
      SORT lt_folder_files BY mtime DESCENDING.
      READ TABLE lt_folder_files INTO DATA(ls_file) INDEX 1.
      IF sy-subrc = 0.
        FREE lt_folder_files.
        APPEND ls_file to lt_folder_files.
      ENDIF.
    ENDIF.
*** End of insert - GAP-3397 - Warranty fix

    IF lv_flg_error = abap_true.
      RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_GET_LIST' iv_level = 1 iv_type = 'W' iv_msg1 = 'Cannot read the files list for folder &2: RC=&3.'(w04) iv_msg2 = lv_folder_to_read iv_msg3 = sy-subrc.
      EXIT.
    ENDIF.
    IF lt_folder_files[] IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_GET_LIST' iv_level = 1 iv_type = 'W' iv_msg1 = 'No file found in folder &2'(w03) iv_msg2 = lv_folder_to_read.
      CLEAR ro_file_container.
      EXIT.
    ENDIF.
    CREATE OBJECT lo_file_container
      EXPORTING
        iv_dataset_type = zdatm_c_datasettype_toquery
        iv_process_id   = mv_process_id.

    LOOP AT lt_folder_files INTO ls_folder_file.
      "Check if there is a file pattern to use
      lv_filename = ls_folder_file-name.
      CREATE OBJECT lo_file
        EXPORTING
          iv_dataset_type = zdatm_c_datasettype_toquery
          iv_filename     = lv_filename
          iv_subfolder    = iv_subfolder
          iv_process_id   = mv_process_id.
      lo_file_container->add( lo_file ).
    ENDLOOP.
    ro_file_container = lo_file_container.
  ENDMETHOD.