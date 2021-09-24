  METHOD transfer_folder.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* G. KANUGOLU! 14/11/2018 ! GAP-2974: add the direct transfer management. Update transfer calls    *
* GK-001     !            ! to add the duplicate checks management                                 *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/03/2019 ! GAP-3345: Manage the possibility to store the trigger file on sap server
* GAP-3345   !            ! else use the internal process ID to generate it. It will be used for   *
*            !            ! SFTP transfer as trigger must be on disk to be transferred             *
*            !            ! Add the Move to progress folder feature                                *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 05/09/2020 ! GAP-3397: Add the file signature management and enhance the V1 of the  *
* GAP3397    !            ! trigger file                                                           *
****************************************************************************************************
    DATA:
      lv_filename                   TYPE string,
      lv_source_folder              TYPE string,
      lv_target_folder              TYPE string,
      lv_archive_folder             TYPE string,
      lv_trigger_line               TYPE string,
      lv_count(2)                   TYPE n,       " INS GK-001 GAP(2807) 19.07.2018
      lv_trigger_file_process_id    TYPE zproc_process_id,  "GAP-3345+
      lv_flg_trigger_file_in_memory TYPE flag,              "GAP-3345+
      lv_signed_file_name           TYPE string,            "GAP-3397+

      lo_file_manager               TYPE REF TO z_cl_utf_file_manager,
      lo_file_container             TYPE REF TO z_cl_utf_data_container,
      lo_object                     TYPE REF TO z_cl_utf_data_dataset,
      lo_file                       TYPE REF TO z_cl_utf_data_file,
      lo_file_signed                TYPE REF TO z_cl_utf_data_file,
      lo_trigger_file               TYPE REF TO z_cl_utf_data_file.

    lo_file_manager = z_cl_utf_file_manager=>factory( mv_process_id ).
    lo_file_container = lo_file_manager->get_file_list( ).

    IF lo_file_container IS NOT BOUND.
      "There is nothing to transfer.
      EXIT.
    ENDIF.

    IF ms_file_transfer-trigger_file = abap_true.
*-Begin of GAP-3345+
      IF ms_file_transfer-physical_transfer IS INITIAL.
        "Trigger doesn't need to be in the current process ID folder so use the internal process ID of the framework.
        lv_trigger_file_process_id = cv_transfer_framework_id.
        lv_flg_trigger_file_in_memory = abap_true.
      ELSE.
        "Trigger will be created physically on the
        lv_trigger_file_process_id = mv_process_id.
        lv_flg_trigger_file_in_memory = abap_false.
      ENDIF.
*-End of GAP-3345+

      IF ms_file_transfer-trigger_file_version = 3.     " INS GK-001 GAP(2958) 10.07.2018
        "Get trigger file name
        CALL FUNCTION 'FILE_GET_NAME'
          EXPORTING
            logical_filename = ms_file_transfer-trigger_file_name
          IMPORTING
            file_name        = lv_filename
          EXCEPTIONS
            file_not_found   = 1
            OTHERS           = 2.
        IF sy-subrc <> 0.
          rv_rc = 8.
          EXIT.
        ENDIF.

        "Create trigger file
        CREATE OBJECT lo_trigger_file
          EXPORTING
            iv_dataset_type = zdatm_c_datasettype_outbound
            iv_filename     = lv_filename
*           iv_process_id   = mv_process_id."GAP-3345-
            iv_process_id   = lv_trigger_file_process_id. "GAP-3345+

        IF ms_file_transfer-move_to_progress IS INITIAL.    "GAP-3345+
          lv_source_folder = lo_file_manager->get_folder( 'ROOT' ).
*-Begin of GAP-3345+
        ELSE.
          lv_source_folder = lo_file_manager->get_folder( 'PROGRESS' ).
        ENDIF.
*-End of GAP-3345+
        lv_target_folder = ms_file_transfer-end_target_folder.
        lv_archive_folder = lo_file_manager->get_folder( 'ARCHIVE' ).

        "Fill  the trigger file with the file list
        DO.
          lo_object = lo_file_container->loop( ).
          IF lo_object IS NOT BOUND.
            EXIT.
          ENDIF.
          lo_file ?= lo_object.
*-Begin of GAP-3345+
          IF ms_file_transfer-move_to_progress IS NOT INITIAL.
            "move file to 'progress' folder if required
            lo_file->move( 'PROGRESS ').
          ENDIF.
*-End of GAP-3345+
          lv_filename = lo_file->get_file_name( ).
          CONCATENATE lv_source_folder lv_filename lv_target_folder lv_filename lv_archive_folder lv_filename INTO lv_trigger_line SEPARATED BY ';'.
*          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = abap_true )."GAP-3345-
          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = lv_flg_trigger_file_in_memory ). "GAP-3345+
        ENDDO.
***SOI by GK-001 GAP(2974) 10.08.2018
*       rv_rc = transfer_file( lo_trigger_file ).
        rv_rc = transfer_file( io_file_object = lo_trigger_file iv_disable_duplicate_check = abap_true ).
***EOI by GK-001 GAP(2974) 10.08.2018

***SOI by GK-001 GAP(2958) 10.07.2018
      ELSE.

        IF ms_file_transfer-move_to_progress IS INITIAL.    "GAP-3345+
          lv_source_folder = lo_file_manager->get_folder( 'ROOT' ).
*-Begin of GAP-3345+
        ELSE.
          lv_source_folder = lo_file_manager->get_folder( 'PROGRESS' ).
        ENDIF.
*-End of GAP-3345+
        lv_target_folder = ms_file_transfer-end_target_folder.
        lv_archive_folder = lo_file_manager->get_folder( 'ARCHIVE' ).

        "Fill  the trigger file with the file list
        CLEAR:lv_count.
        DO.
          FREE:lv_filename,lo_trigger_file,lo_object.
          lv_count = lv_count + 1.
*-Begin of GAP-3397-
*          "Get trigger file name
*          CALL FUNCTION 'FILE_GET_NAME'
*            EXPORTING
*              logical_filename = ms_file_transfer-trigger_file_name
*              parameter_1      = lv_count
*              parameter_2      =
*            IMPORTING
*              file_name        = lv_filename
*            EXCEPTIONS
*              file_not_found   = 1
*              OTHERS           = 2.
*          IF sy-subrc <> 0.
*            rv_rc = 8.
*            EXIT.
*          ENDIF.
*
*          "Create trigger file
*          CREATE OBJECT lo_trigger_file
*            EXPORTING
*              iv_dataset_type = zdatm_c_datasettype_outbound
*              iv_filename     = lv_filename
**             iv_process_id   = mv_process_id."GAP-3345-
*              iv_process_id   = lv_trigger_file_process_id. "GAP-3345+
*-End of GAP-3397-
          lo_object = lo_file_container->loop( ).
          IF lo_object IS NOT BOUND.
            EXIT.
          ENDIF.
          lo_file ?= lo_object.
*-Begin of GAP-3345+
          IF ms_file_transfer-move_to_progress IS NOT INITIAL.
            "move file to 'progress' folder if required
            lo_file->move( 'PROGRESS ').
          ENDIF.
*-End of GAP-3345+

*-Begin of GAP-3397+
          " Check if file must be signed before sending or Signature is disable but do we need to create a dummy signed file?.
          IF ms_file_server-sign_file = abap_true OR ms_file_server-signed_file_name IS NOT INITIAL.
            "Define the signed file name
            lv_signed_file_name = lo_file_manager->get_new_filename( iv_folder = 'CUSTOM' iv_current_filename = lo_file->get_file_name( ) iv_custom_filename = ms_file_server-signed_file_name ).
            "copy the original filename and use it as file to be transfered.
            lo_file_signed = lo_file->copy_with_reference( iv_target_folder = lo_file->get_current_folder(  ) iv_target_filename = lv_signed_file_name ).
            IF ms_file_server-sign_file = abap_true."need to do real signature
              IF ( lo_file_signed->sign( ms_file_server-sign_application ) <> 0 ).
                rv_rc = 8.
                EXIT.
              ELSE.
                lv_filename = lo_file_signed->get_file_name( ).
              ENDIF.
            ELSE.
              lv_filename = lo_file_signed->get_file_name( ).
            ENDIF.
          ENDIF.

          "Create the trigger file
          "Get trigger file name
          CALL FUNCTION 'FILE_GET_NAME'
            EXPORTING
              logical_filename = ms_file_transfer-trigger_file_name
              parameter_1      = lv_count
              parameter_2      = lv_filename
            IMPORTING
              file_name        = lv_filename
            EXCEPTIONS
              file_not_found   = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
            rv_rc = 8.
            EXIT.
          ELSE.                                             "GAP-3397+
*-Begin of GAP3397+
            IF lv_filename(1) = '#'.
              "logical filename cannot start with a parameter so put a # if it is required
              SHIFT lv_filename LEFT.
            ENDIF.
*-End of GAP3397+
          ENDIF.

          "Create trigger file
          CREATE OBJECT lo_trigger_file
            EXPORTING
              iv_dataset_type = zdatm_c_datasettype_outbound
              iv_filename     = lv_filename
*             iv_process_id   = mv_process_id."GAP-3345-
              iv_process_id   = lv_trigger_file_process_id. "GAP-3345+

          IF lo_file_signed IS BOUND.
            lv_filename = lo_file_signed->get_file_name( ).
          ELSE.
            lv_filename = lo_file->get_file_name( ).
          ENDIF.
*-End of GAP-3397+

*            lv_filename = lo_file->get_file_name( )."GAP-3397-
          CONCATENATE lv_source_folder lv_filename INTO lv_trigger_line SEPARATED BY ';'.
*          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = abap_true )."GAP-3345-
          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = lv_flg_trigger_file_in_memory ). "GAP-3345+

          CONCATENATE lv_target_folder lv_filename INTO lv_trigger_line SEPARATED BY ';'.
*          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = abap_true )."GAP-3345-
          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = lv_flg_trigger_file_in_memory ). "GAP-3345+
*-Begin of GAP-3397+
          IF ms_file_transfer-trigger_file_version = 1.
            lv_filename = lo_file->get_file_name( ).
          ENDIF.
*-End of GAP-3397+
          CONCATENATE lv_archive_folder lv_filename INTO lv_trigger_line SEPARATED BY ';'.
*          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = abap_true )."GAP-3345-
          lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = lv_flg_trigger_file_in_memory ). "GAP-3345+

***SOI by GK-001 GAP(2974) 10.08.2018
*          rv_rc = transfer_file( lo_trigger_file ).
          rv_rc = transfer_file( io_file_object = lo_trigger_file iv_disable_duplicate_check = abap_true ).
***EOI by GK-001 GAP(2974) 10.08.2018
        ENDDO.
      ENDIF.
***EOI by GK-001 GAP(2958) 10.07.2018
    ELSE.        "GK-001 GAP2974+
*   trigger directly

***SOI by GK-001 GAP(2974) 10.08.2018
      DO.
        lo_object = lo_file_container->loop( ).
        IF lo_object IS NOT BOUND.
          EXIT.
        ENDIF.
        lo_file ?= lo_object.
*        lv_filename = lo_file->get_file_name( ).    "-SBA01
*        CONCATENATE lv_source_folder lv_filename lv_target_folder lv_filename lv_archive_folder lv_filename INTO lv_trigger_line SEPARATED BY ';'. "-SBA01
*        lo_trigger_file->transfer_data( iv_data = lv_trigger_line iv_in_memory = abap_true ).        "-SBA01
*          rv_rc = transfer_file( io_file_object = lo_trigger_file iv_disable_duplicate_check = abap_false ). "-SBA01
        rv_rc = transfer_file( io_file_object = lo_file iv_disable_duplicate_check = abap_false )."+SBA01
      ENDDO.
***EOI by GK-001 GAP(2974) 10.08.2018
      "SBA_GAP2974+
    ENDIF.
  ENDMETHOD.