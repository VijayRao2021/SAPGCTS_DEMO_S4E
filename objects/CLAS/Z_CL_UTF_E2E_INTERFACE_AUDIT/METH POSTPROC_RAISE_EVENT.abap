************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD POSTPROC_RAISE_EVENT.
*GAP-1790 MC-001. This method allows to raise a SAP event when the idocs of the interfaces are processed.
*It reads the table ZBC_EVT_POSTPROC first with the interface ID, message variant and message function key,
*and if not found with the interface ID only.
*If no entry is found, then a non critical error is raised because it means a part of the customizing is missing.
    DATA: ls_postproc_event TYPE ts_postproc_event.


    RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC_EVT' iv_level = 2 iv_type = 'I' iv_msg1 = 'Raising Event Postprocessing is configured, look for event to raise.'(M30).

    IF mt_postproc_event[] IS INITIAL.
      SELECT * INTO TABLE mt_postproc_event
        FROM ze2e_pstpc_evt ORDER BY PRIMARY KEY.                            "#EC CI_NOWHERE       "$sst: #601
    ENDIF.
    LOOP AT mt_postproc_event INTO ls_postproc_event WHERE interface_id = is_postproc_param-interface_id AND
                                                           mescod = is_postproc_param-mescod AND
                                                           mesfct = is_postproc_param-mesfct AND
                                                           postproc_condition = is_postproc_param-postproc_condition.
      CALL METHOD cl_batch_event=>raise
        EXPORTING
*         i_eventparm           = gv_eventparm
*         i_server              = gv_server
          i_eventid             = ls_postproc_event-event_id
        EXCEPTIONS
          excpt_raise_failed    = 1
          excpt_raise_forbidden = 3
          excpt_unknown_event   = 4
          excpt_no_authority    = 5
          OTHERS                = 6.
      CASE sy-subrc.
        WHEN 0.
          RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC_EVT' iv_level = 3 iv_type = 'S' iv_msg1 = 'Event &2 Raised for interface &3'(M19) iv_msg2 = ls_postproc_event-event_id iv_msg3 = is_postproc_param-interface_id.
          EXIT.
        WHEN 4.
          RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC_EVT/ERROR_MAIL' iv_level = 3 iv_type = 'E' iv_msg1 = 'Event &2 does not exist'(E21) iv_msg2 = ls_postproc_event-event_id.
        WHEN OTHERS.
          RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC_EVT/ERROR_MAIL' iv_level = 3 iv_type = 'E' iv_msg1 = 'Postprocess Event &2 not yet configure'(E22) iv_msg2 = ls_postproc_event-event_id.

      ENDCASE.
    ENDLOOP.
    IF sy-subrc <> 0.
      RAISE EVENT send_log EXPORTING iv_group = 'E2E_POSTPROC_EVT/ERROR_MAIL' iv_level = 3 iv_type = 'E' iv_msg1 = 'No Event configure for interface ID &2, mescod &3, mesfct &4 and condition &5.'(e23) iv_msg2 = is_postproc_param-interface_id
                                      iv_msg3 = is_postproc_param-mescod iv_msg4 = is_postproc_param-mesfct iv_msg5 = is_postproc_param-postproc_condition.
    ENDIF.
  ENDMETHOD.