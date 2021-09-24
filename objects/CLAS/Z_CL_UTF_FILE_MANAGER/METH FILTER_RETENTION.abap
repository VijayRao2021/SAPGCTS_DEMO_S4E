  METHOD filter_retention.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* GK-001     !  09.12.2018! Retention filtering (2192)                                             *
****************************************************************************************************
    DATA:
      lv_retension_dt TYPE sydatum,
      ls_folder_files TYPE zfile_s_file_attributes,
      lv_tabix        TYPE sytabix.

    IF ct_folder_files IS INITIAL.
      "Nothing to filter so leave the method
      EXIT.
    ENDIF.

* Calculate retention date
    lv_retension_dt = sy-datum - ms_file_manager-retention.

* Process all the files list
    LOOP AT ct_folder_files INTO ls_folder_files.
      lv_tabix = sy-tabix.

* If retention date is greater than today date - number of days in retention field in ZFILE_MANAGER
      IF ls_folder_files-date GT lv_retension_dt.
        DELETE ct_folder_files INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.