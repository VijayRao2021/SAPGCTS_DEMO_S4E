  METHOD folder_cleaning.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* GK-001     !  09.12.2018! folder clearing GAP(2192)                                             *
****************************************************************************************************
    DATA:lo_file_container TYPE REF TO z_cl_utf_data_container,
         lo_file           TYPE REF TO z_cl_utf_data_file,
         lo_object         TYPE REF TO z_cl_utf_data_dataset.

    FREE:lo_file_container.
    lo_file_container = get_file_list( iv_subfolder = iv_folder iv_filter_method = 'FILTER_RETENTION' ).
    IF lo_file_container IS NOT BOUND.
      RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FOLDER_CLEANING' iv_level = 1 iv_type = 'I' iv_msg1 = 'No files to clean the folder &2.'(i09) iv_msg2 = iv_folder.
      EXIT.
    ENDIF.

    RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FOLDER_CLEANING' iv_level = 1 iv_type = 'I' iv_msg1 = 'Folder cleaning initialized for folder &2.'(i05) iv_msg2 = iv_folder.
    DO.
      FREE:lo_object,lo_file.
      lo_object = lo_file_container->loop( ).
      IF lo_object IS NOT BOUND.
        EXIT.
      ENDIF.
      lo_file ?= lo_object.
      lo_file->delete( ).
    ENDDO.
    RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FOLDER_CLEANING' iv_level = 1 iv_type = 'S' iv_msg1 = 'Folder &2 cleaning completed successfully '(s01) iv_msg2 = iv_folder.
  ENDMETHOD.