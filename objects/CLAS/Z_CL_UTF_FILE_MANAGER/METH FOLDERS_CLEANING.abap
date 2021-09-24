  METHOD folders_cleaning.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* GK-001     !  09.12.2018! folders clearing GAP(2192)                                             *
****************************************************************************************************
    CONSTANTS:lc_root     TYPE string VALUE 'ROOT',
              lc_progress TYPE string VALUE 'PROGRESS',
              lc_archive  TYPE string VALUE 'ARCHIVE',
              lc_error    TYPE string VALUE 'ERROR'.

    IF ms_file_manager-retention IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FOLDERS_CLEANING' iv_level = 1 iv_type = 'I' iv_msg1 = 'No Retention time defined for Process ID &2.'(i10)
                                     iv_msg2 = mv_process_id.
      EXIT.
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FOLDERS_CLEANING' iv_level = 1 iv_type = 'I' iv_msg1 = 'Process ID &2 has a &3 days retention defined.'(i04)
                                     iv_msg2 = mv_process_id iv_msg3 = ms_file_manager-retention.
    ENDIF.

    IF NOT ms_file_manager-root_folder IS INITIAL.
      folder_cleaning( lc_root ).
    ENDIF.

    IF NOT ms_file_manager-progress_folder IS INITIAL.
      folder_cleaning( lc_progress ).
    ENDIF.

    IF NOT ms_file_manager-archive_folder IS INITIAL.
      folder_cleaning( lc_archive ).
    ENDIF.

    IF NOT ms_file_manager-error_folder IS INITIAL.
      folder_cleaning( lc_error ).
    ENDIF.
  ENDMETHOD.