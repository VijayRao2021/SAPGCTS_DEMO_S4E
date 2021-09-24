METHOD constructor.
************************************************************************
* 5/3/17   smartShift project

************************************************************************

    DATA:
          lv_flg_text_defined TYPE flag.

    RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 0 iv_type = 'H' iv_msg1 = 'Initializing Process module for Process ID &2...'(h01) iv_msg2 = iv_process_id.

    super->constructor( zcore_c_modid_process ).

    CLEAR ms_process.
    CLEAR lv_flg_text_defined.

    RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 1 iv_type = 'I' iv_msg1 = 'Load the process &2 header information.'(i01) iv_msg2 = iv_process_id.
    "Load the process data
    SELECT SINGLE * INTO ms_process
      FROM zproc_header
      WHERE process_id = iv_process_id. "#EC CI_ALL_FIELDS_NEEDED (confirmed full access)          "$sst: #712
    IF sy-subrc <> 0.
      "Process still doesn't exist then initialize the data.
      RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 1 iv_type = 'W' iv_msg1 = 'Process ID &2 is not yet created, set it with default value.'(w01) iv_msg2 = iv_process_id.
      ms_process-process_id = iv_process_id.
      ms_process-program_name = sy-cprog.

      "Save the new entry
      MODIFY zproc_header FROM ms_process.

    ELSE.
      SELECT SINGLE * INTO ms_process_text
        FROM zproc_text
        WHERE process_id = iv_process_id AND
              language = sy-langu.
      IF sy-subrc <> 0.
        IF sy-langu <> 'E'.
          SELECT SINGLE * INTO ms_process_text
            FROM zproc_text
            WHERE process_id = iv_process_id AND
                  language = 'E'.
          IF sy-subrc = 0.
            lv_flg_text_defined = abap_true.
          ENDIF.
        ENDIF.
      ELSE.
        lv_flg_text_defined = abap_true.
      ENDIF.
    ENDIF.

    "Check if the description was found.
    IF lv_flg_text_defined = abap_false.
      "No then create a default one
      "Define the default description
      CLEAR ms_process_text.
      ms_process_text-process_id = ms_process-process_id.
      ms_process_text-language = sy-langu.
      ms_process_text-process_description = 'Process description to be defined'(l01).
      MODIFY zproc_text FROM ms_process_text.
    ENDIF.

    "Load the attributes
    SELECT * INTO TABLE mt_attributes
      FROM zproc_attr
      WHERE process_id = ms_process-process_id.
    RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 1 iv_type = 'I' iv_msg1 = '&2 attributes loaded.'(i05) iv_msg2 = sy-dbcnt.

    "Connect the event receivers
    SET HANDLER me->process_is_used.
    SET HANDLER me->process_processing_status_upd.

    RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 1 iv_type = 'S' iv_msg1 = 'Process module initialization done.'(s01).
  ENDMETHOD.