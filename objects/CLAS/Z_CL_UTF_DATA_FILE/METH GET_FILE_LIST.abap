  METHOD get_file_list.
    DATA:
      lv_process        TYPE zprocess,
      lv_folder_to_read TYPE eps2filnam,
      lv_root_folder    TYPE string,
      lv_folder_2_read  TYPE string,

*      ls_folder         TYPE zfmm_folder,

*      lt_folder         TYPE STANDARD TABLE OF zfmm_folder,
      lt_folder_files   TYPE STANDARD TABLE OF eps2fili.

    CLEAR rt_file_list.
*{ UTF Implementation: Commented the code below
*    "Define the work folder.
*    lv_process = iv_process_id."for compatibility between old and new process ID
*    CALL FUNCTION 'Z_FMM_READ_FOLDER_TABLE'
*      EXPORTING
*        iv_process       = lv_process
*      TABLES
*        tt_folder        = lt_folder
*      EXCEPTIONS
*        no_authorisation = 1
*        no_data_found    = 2
*        OTHERS           = 3.
*    IF sy-subrc EQ 0.
*      READ TABLE lt_folder INTO ls_folder INDEX 1.
*      lv_root_folder = ls_folder-folder.
*    ELSE.
*      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_GET_LIST' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot define default path for process ID &2.'(e13) iv_msg2 = iv_process_id.
*      EXIT.
*    ENDIF.
*} UTF Implementation: End of comments

    IF iv_subfolder IS NOT INITIAL.
      CONCATENATE lv_root_folder '/' iv_subfolder INTO lv_folder_2_read.
    ELSE.
      lv_folder_2_read = lv_root_folder.
    ENDIF.

    "Look for the available files in the folder.
    lv_folder_to_read = lv_folder_2_read.
    CALL FUNCTION 'EPS2_GET_DIRECTORY_LISTING'
      EXPORTING
        iv_dir_name            = lv_folder_to_read
*       FILE_MASK              = ' '
*       IMPORTING
*       DIR_NAME               =
*       FILE_COUNTER           =
*       ERROR_COUNTER          =
      TABLES
        dir_list               = lt_folder_files
      EXCEPTIONS
        invalid_eps_subdir     = 1
        sapgparam_failed       = 2
        build_directory_failed = 3
        no_authorization       = 4
        read_directory_failed  = 5
        too_many_read_errors   = 6
        empty_directory_list   = 7
        OTHERS                 = 8.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_GET_LIST' iv_level = 1 iv_type = 'W' iv_msg1 = 'Cannot read the files list for folder &2: RC=&3.'(w04) iv_msg2 = lv_folder_to_read iv_msg3 = sy-subrc.
      EXIT.
    ENDIF.
    SORT lt_folder_files BY mtim.
    IF lt_folder_files[] IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_GET_LIST' iv_level = 1 iv_type = 'W' iv_msg1 = 'No file to process in folder &2'(w03) iv_msg2 = lv_folder_to_read.
      EXIT.
    ENDIF.
    rt_file_list[] = lt_folder_files[].
  ENDMETHOD.