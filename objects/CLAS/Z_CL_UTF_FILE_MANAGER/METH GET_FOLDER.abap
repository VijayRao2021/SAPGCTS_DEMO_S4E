  METHOD get_folder.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* G. KANUGOLU! 14/11/2018 ! GAP-2974: add error folder management.                                 *
* GK-001     !            !                                                                        *
****************************************************************************************************
    CASE iv_folder.
      WHEN 'PROGRESS'.
        rv_folder_name = ms_file_manager-progress_folder.
      WHEN 'ARCHIVE'.
        rv_folder_name = ms_file_manager-archive_folder.
      WHEN 'ROOT'.
        rv_folder_name = ms_file_manager-root_folder.
        " SOI by GK-001 GAP(2974) 10.08.2018
      WHEN 'ERROR'.
        rv_folder_name = ms_file_manager-error_folder.
        " EOI by GK-001 GAP(2974) 10.08.2018
      WHEN OTHERS.
        rv_folder_name = ms_file_manager-root_folder.
    ENDCASE.
  ENDMETHOD.