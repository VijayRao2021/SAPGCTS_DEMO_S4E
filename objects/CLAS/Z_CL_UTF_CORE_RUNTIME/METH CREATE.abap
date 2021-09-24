  METHOD create.
    DATA:
          lv_uuid TYPE sysuuid_c32.

    "TODO add a check to control if an open runtime doesn't still exist.

    RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 0 iv_type = 'H' iv_msg1 = 'Create a new runtime environment...'(h02).
    "Create the header structure
    CLEAR ms_runtime.
    lv_uuid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).
    ms_runtime-mandt = sy-mandt.
    ms_runtime-runtime_id = lv_uuid.
    RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'UUID &2 is defined for this run.'(i03) iv_msg2 = lv_uuid.

    "Lock the table entry
    CALL FUNCTION 'ENQUEUE_EZRUN_HEADER'
      EXPORTING
        mode_zrun_header = 'E'
        mandt            = sy-mandt
        runtime_id       = ms_runtime-runtime_id
      EXCEPTIONS
        foreign_lock     = 1
        system_failure   = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      "Already locked?
    ENDIF.

    ms_runtime-status = zrunt_c_status_in_progress.
    ms_runtime-process_id = iv_process_id.

    "Load the process data
    CREATE OBJECT mo_process
      exporting iv_process_id = iv_process_id.

    ms_runtime-country = iv_country.
    ms_runtime-create_user = ms_runtime-update_user = sy-uname.
    ms_runtime-create_date = ms_runtime-update_date = sy-datum.
    ms_runtime-create_time = ms_runtime-update_time = sy-uzeit.

    IF sy-batch = 'X'.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Processing is running in &2 mode'(i04) iv_msg2 = 'background'(M01).
      ms_runtime-run_mode = 'B'.
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Processing is running in &2 mode'(i04) iv_msg2 = 'dialog'(M02).
      ms_runtime-run_mode = 'D'.
    ENDIF.

    IF sy-tcode IS NOT INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'I' iv_msg1 = 'Processing started from tcode &2'(i05) iv_msg2 = sy-tcode.
      ms_runtime-tcode = sy-tcode.
    ENDIF.
    mv_flg_changed = abap_true.

    "Update the header table
    IF ( save( ) = 0 ).
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'S' iv_msg1 = 'Runtime environment successfully created and saved.'(s01).
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'RUNTIME' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error occured during runtime environment creation.'(e01).
    ENDIF.

    "Raise current status to inform the other objects
  ENDMETHOD.