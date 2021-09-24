  METHOD folders_check.

****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* GK-001     !  09.12.2018! folders clearing GAP(2192)                                             *
****************************************************************************************************

    RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FOLDERS_CHECK' iv_level = 1 iv_type = 'I' iv_msg1 = 'Folders checking initialized.'(i08).
    IF NOT ms_file_manager-root_folder IS INITIAL.
      folder_check( iv_subfolder = ms_file_manager-root_folder ).
    ENDIF.

    IF NOT ms_file_manager-progress_folder IS INITIAL.
      folder_check( iv_subfolder = ms_file_manager-progress_folder ).
    ENDIF.

    IF NOT ms_file_manager-archive_folder IS INITIAL.
      folder_check( iv_subfolder = ms_file_manager-archive_folder ).
    ENDIF.

    IF NOT ms_file_manager-error_folder IS INITIAL.
      folder_check( iv_subfolder = ms_file_manager-error_folder ).
    ENDIF.
  ENDMETHOD.