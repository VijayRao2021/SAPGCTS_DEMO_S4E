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
      BEGIN OF lts_transfer_manager_instance,
        process_id       TYPE zproc_process_id,
        transfer_manager TYPE REF TO z_cl_utf_file_transfer_manager,
      END OF lts_transfer_manager_instance,

      ltt_transfer_manager_instances TYPE STANDARD TABLE OF lts_transfer_manager_instance.

    STATICS: ss_transfer_manager  TYPE lts_transfer_manager_instance,
             st_transfer_managers TYPE ltt_transfer_manager_instances.

    IF ss_transfer_manager-process_id <> iv_process_id.
      READ TABLE st_transfer_managers INTO ss_transfer_manager WITH KEY process_id = iv_process_id.
      IF sy-subrc <> 0.
        CLEAR ss_transfer_manager.
        ss_transfer_manager-transfer_manager = NEW #( iv_process_id = iv_process_id ).
        IF ss_transfer_manager-transfer_manager IS BOUND.
          ss_transfer_manager-process_id = iv_process_id.   "GAP-2974+
          APPEND ss_transfer_manager TO st_transfer_managers.
        ENDIF.
      ENDIF.
    ENDIF.
    ro_transfer_manager = ss_transfer_manager-transfer_manager.

  ENDMETHOD.