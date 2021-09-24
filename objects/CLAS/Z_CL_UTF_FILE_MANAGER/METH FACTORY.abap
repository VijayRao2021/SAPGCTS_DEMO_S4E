  METHOD factory.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: fix a bug in the static storage and update naming convention *
* GAP-2974   !            !                                                                        *
****************************************************************************************************
    TYPES:
      BEGIN OF lts_file_manager_instance,
        process_id   TYPE zproc_process_id,
        file_manager TYPE REF TO z_cl_utf_file_manager,
      END OF lts_file_manager_instance,

      ltt_file_manager_instances TYPE STANDARD TABLE OF lts_file_manager_instance.

    STATICS: ss_file_manager  TYPE lts_file_manager_instance,
             st_file_managers TYPE ltt_file_manager_instances.

    IF ss_file_manager-process_id <> iv_process_id.
      READ TABLE st_file_managers INTO ss_file_manager WITH KEY process_id = iv_process_id.
      IF sy-subrc <> 0.
        CLEAR ss_file_manager.
        ss_file_manager-file_manager = NEW #( iv_process_id = iv_process_id ).
        IF ss_file_manager-file_manager IS BOUND.
          ss_file_manager-process_id = iv_process_id.       "GAP-2974+
          APPEND ss_file_manager TO st_file_managers.
        ENDIF.
      ENDIF.
    ENDIF.
    ro_file_manager = ss_file_manager-file_manager.
  ENDMETHOD.