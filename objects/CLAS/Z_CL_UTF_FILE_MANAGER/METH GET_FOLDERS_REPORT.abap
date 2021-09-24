  METHOD get_folders_report.
    TYPES:
      BEGIN OF lts_folder_manager,
        folder     TYPE zfile_folder_name,
        process_id TYPE zproc_process_id,
        retention  TYPE zfile_retention,
      END OF lts_folder_manager.

    STATICS:
      st_folders_manager     TYPE STANDARD TABLE OF lts_folder_manager.

    DATA:
      lv_folder              TYPE string,
      lt_folder_content      TYPE zfile_t_files_list,
      lr_folder_content      TYPE REF TO zfile_s_file_attributes,
      ls_folder_report       TYPE zfile_s_folder_report,
      lr_child_folder_report TYPE REF TO zfile_s_folder_report,
      lt_folders_report      TYPE zfile_t_folder_report,

      ls_file_manager        TYPE zfile_manager,
      lt_file_manager        TYPE STANDARD TABLE OF zfile_manager,

      ls_folder_manager      TYPE lts_folder_manager,

      lo_file_manager        TYPE REF TO z_cl_utf_file_manager.

    IF st_folders_manager IS INITIAL.
      "Read all the processes managed by the file manager framework.
      SELECT process_id retention FROM zfile_manager
       INTO CORRESPONDING FIELDS OF TABLE lt_file_manager. "#EC CI_NOWHERE.

      LOOP AT lt_file_manager INTO ls_file_manager.
        CLEAR ls_folder_manager.
        ls_folder_manager-process_id = ls_file_manager-process_id.
        ls_folder_manager-retention = ls_file_manager-retention.
        lo_file_manager = NEW #( iv_process_id = ls_file_manager-process_id ).
        ls_folder_manager-folder = lo_file_manager->get_folder( 'ROOT' ).
        IF ls_folder_manager-folder IS NOT INITIAL.
          APPEND ls_folder_manager TO st_folders_manager.
        ENDIF.
        ls_folder_manager-folder = lo_file_manager->get_folder( 'PROGRESS' ).
        IF ls_folder_manager-folder IS NOT INITIAL.
          APPEND ls_folder_manager TO st_folders_manager.
        ENDIF.
        ls_folder_manager-folder = lo_file_manager->get_folder( 'ARCHIVE' ).
        IF ls_folder_manager-folder IS NOT INITIAL.
          APPEND ls_folder_manager TO st_folders_manager.
        ENDIF.
        ls_folder_manager-folder = lo_file_manager->get_folder( 'ERROR' ).
        IF ls_folder_manager-folder IS NOT INITIAL.
          APPEND ls_folder_manager TO st_folders_manager.
        ENDIF.
      ENDLOOP.
      SORT st_folders_manager BY process_id.
    ENDIF.

    "Get the folder content informations.
    lt_folder_content = get_folder_content( iv_root_folder ).

    CLEAR ls_folder_report.
    ls_folder_report-folder_name = iv_root_folder.
    READ TABLE st_folders_manager INTO ls_folder_manager WITH KEY folder = iv_root_folder.
    IF sy-subrc = 0.
      ls_folder_report-process_id = ls_folder_manager-process_id.
      ls_folder_report-retention = ls_folder_manager-retention.
    ELSE.
      CONCATENATE ls_folder_report-folder_name '/' INTO ls_folder_report-folder_name.
      READ TABLE st_folders_manager INTO ls_folder_manager WITH KEY folder = ls_folder_report-folder_name.
      IF sy-subrc = 0.
        ls_folder_report-process_id = ls_folder_manager-process_id.
        ls_folder_report-retention = ls_folder_manager-retention.
      ELSE.
        ls_folder_report-process_id = 'Not Managed by file manager'(l01).
      ENDIF.
    ENDIF.

    LOOP AT lt_folder_content REFERENCE INTO lr_folder_content.
      IF lr_folder_content->file_type = 'directory'.
        IF NOT lr_folder_content->name CS '.'.
          CONCATENATE iv_root_folder '/' lr_folder_content->name INTO lv_folder.
          REPLACE '//' WITH '/' INTO lv_folder.

          "For each subfolder request to have the content info
          lt_folders_report = get_folders_report( lv_folder ).

          "Merge the subfolders info with the root folder.
          LOOP AT lt_folders_report REFERENCE INTO lr_child_folder_report.
            ADD lr_child_folder_report->folder_size TO ls_folder_report-folder_full_size.
            APPEND lr_child_folder_report->* TO rt_folders_report.
          ENDLOOP.
        ENDIF.
      ELSE.
        ADD lr_folder_content->file_size TO ls_folder_report-folder_size.
        ADD 1 TO ls_folder_report-files_counter.
        IF lr_folder_content->file_size > ls_folder_report-biggest_file.
          ls_folder_report-biggest_file = lr_folder_content->file_size.
        ENDIF.
        IF lr_folder_content->mtime < ls_folder_report-oldest_file OR ls_folder_report-oldest_file IS INITIAL.
          ls_folder_report-oldest_file = lr_folder_content->mtime.
        ENDIF.
        IF lr_folder_content->mtime > ls_folder_report-recent_file OR ls_folder_report-recent_file IS INITIAL.
          ls_folder_report-recent_file = lr_folder_content->mtime.
        ENDIF.
      ENDIF.

    ENDLOOP.
    ADD ls_folder_report-folder_size TO ls_folder_report-folder_full_size.
    INSERT ls_folder_report INTO rt_folders_report INDEX 1.
  ENDMETHOD.