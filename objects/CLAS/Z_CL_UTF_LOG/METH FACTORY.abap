  METHOD FACTORY.

    TYPES:BEGIN OF lts_log_instance,
            process_id TYPE zproc_process_id,
            log        TYPE REF TO z_cl_utf_log,
          END OF lts_log_instance,

          ltt_log_instances TYPE STANDARD TABLE OF lts_log_instance.

    STATICS:ss_log_instance  TYPE lts_log_instance,
            st_log_instances TYPE ltt_log_instances.

    IF ss_log_instance-process_id <> iv_process_id.
      READ TABLE st_log_instances INTO ss_log_instance WITH KEY process_id = iv_process_id.
      IF sy-subrc <> 0.
        CLEAR ss_log_instance.
        ss_log_instance-log = NEW #( ).
        IF ss_log_instance-log IS BOUND.
          ss_log_instance-log->set_log_level( 5 ).
          SET HANDLER ss_log_instance-log->add_log.
          ss_log_instance-process_id = iv_process_id.
          APPEND ss_log_instance TO st_log_instances.
        ENDIF.
      ENDIF.
    ENDIF.

    ro_log = ss_log_instance-log.

  ENDMETHOD.