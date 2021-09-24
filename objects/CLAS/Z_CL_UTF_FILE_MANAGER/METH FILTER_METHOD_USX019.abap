  METHOD filter_method_usx019.

    IF ct_folder_files IS INITIAL.
      EXIT.
    ENDIF.

***Check TXT files must be there with same filename for interface USX019
***If not delete the corresponding PDF/CSV file from the further processing

    DATA(lt_folder_files) = ct_folder_files.
    SORT lt_folder_files BY name.

    IF NOT lt_folder_files IS INITIAL.
      LOOP AT lt_folder_files INTO DATA(ls_folder_files).
        DATA(lv_index) = sy-tabix.

        IF ls_folder_files-name(4) NE 'WFAR'.
          DELETE lt_folder_files INDEX lv_index.
          RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_FILTER_USX019' iv_level = 1 iv_type = 'W' iv_msg1 = 'The file &2 is not a txt file.'(w08) iv_msg2 = ls_folder_files-name.
        ENDIF.

      ENDLOOP.
    ENDIF.

    ct_folder_files[] = lt_folder_files[].

  ENDMETHOD.