  METHOD constructor.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: add the file type (ASC/BIN) management                       *
* GAP-2974   !            !                                                                        *
****************************************************************************************************
    DATA:
      lv_folder  TYPE zfolder.

    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_CONSTRUCTOR' iv_level = 0 iv_type = 'H' iv_msg1 = 'Initialize a File data object...'(h01).
    super->constructor( iv_dataset_type = iv_dataset_type iv_process_id = iv_process_id ).

    CLEAR: mv_filename, mv_current_folder, mv_filename_full, mv_is_open.
    CLEAR: mt_file_data[], mt_file_docs[].

    "get link to the new file manager for the current process ID
    mo_file_manager = z_cl_utf_file_manager=>factory( mv_process_id ).
    IF mo_file_manager IS BOUND.
      "Retrieve the root folder of the process ID
      mv_root_folder = mo_file_manager->get_folder( 'ROOT' ).
      IF iv_subfolder IS SUPPLIED AND iv_subfolder IS NOT INITIAL.
        "If file is in a subfolder then retrieve this folder name.
        mv_current_folder = mo_file_manager->get_folder( iv_subfolder ).
      ELSE.
        mv_current_folder = mv_root_folder.
      ENDIF.
      mv_file_type = mo_file_manager->get_file_type( ).     "GAP-2974+
    ELSE.
      "there is no config in old and new file manager table then we have a problem, stop here.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_CONSTRUCTOR' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot define default path for process ID &2.'(e13) iv_msg2 = mv_process_id.
      RAISE cannot_define_file.
    ENDIF.

    mv_filename = iv_filename.

    mv_filename_full = get_full_filename( ).

    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_CONSTRUCTOR' iv_level = 1 iv_type = 'I' iv_msg1 = 'Full path defined: &2.'(i02) iv_msg2 = mv_filename_full.
  ENDMETHOD.