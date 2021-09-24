************************************************************************
* 5/3/17   smartShift project

************************************************************************

****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 19.02.2016 ! GAP-2270: Fill the new attribute mt_duplicate_control_interfaces      *
* GAP-2270   !            !                                                                        *
****************************************************************************************************
METHOD CONSTRUCTOR.
  TYPES: BEGIN OF type_s_logical_port_sel,                                                         "$sst: #712
        LP_NAME TYPE SRT_CFG_CLI_ASGN-LP_NAME,                                                     "$sst: #712
         END OF type_s_logical_port_sel.                                                           "$sst: #712
  DATA:
        lt_logical_port TYPE STANDARD TABLE OF type_s_logical_port_sel,                            "$sst: #712
        ls_logical_port TYPE type_s_logical_port_sel,                                              "$sst: #712
        lv_flg_last TYPE c,
        lv_message TYPE string,
        lo_sys_exception TYPE REF TO cx_ai_system_fault.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'H' iv_msg1 = 'SAP E2E framework initialization...'(h02).
  REFRESH mt_interfaces.
  IF iv_disable_ws = 'X'.
    ws_enable_disable_ws( '' ).
  ELSE.
    ws_enable_disable_ws( 'X' ).
  ENDIF.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Activating processing mode &2.'(m23) iv_msg2 = iv_mode.
  mv_mode = iv_mode.
  IF iv_mode = c_mode_analysis.
    mv_error_ws_conn_failed = zetoe_error_wsconnfail_a.
  ELSE.
    mv_error_ws_conn_failed = zetoe_error_wsconnfail_p.
  ENDIF.
  "Load the customzing. -MC-001 begin GAP-1790
  IF mt_audit_cust[] IS INITIAL.
    SELECT * INTO TABLE mt_audit_cust
      FROM zbc_audit_cust.                              "#EC CI_NOWHERE
  ENDIF.
  IF mt_postprocessing[] IS INITIAL.
    SELECT * INTO TABLE mt_postprocessing
      FROM ze2e_postproc.                               "#EC CI_NOWHERE
  ENDIF.
*MC-001
*-Begin of GAP-2270+
  IF mt_duplicate_control_int[] IS INITIAL.
    SELECT * INTO TABLE mt_duplicate_control_int
      FROM ze2e_dup_control.                            "#EC CI_NOWHERE
  ENDIF.
*-End of GAP-2270+
  CHECK NOT mv_ws_call IS INITIAL.

  "Load the logical port available for this proxy and the current environment
  SELECT lp_name INTO TABLE lt_logical_port                                                        "$sst: #712
    FROM srt_cfg_cli_asgn
    WHERE proxy_class = zetoe_audit_class ORDER BY PRIMARY KEY.              "#EC CI_GENBUFF       "$sst: #601
  IF sy-dbcnt = 0.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'No working logical port found => EXIT'(e11).
    RAISE cant_create_ws_proxy.
  ENDIF.
  CLEAR lv_flg_last.
  "Look for an active logical port.
  LOOP AT lt_logical_port INTO ls_logical_port.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Try connecting to logical port &2.'(m16) iv_msg2 = ls_logical_port-lp_name.
    AT LAST.
      lv_flg_last = 'X'.
    ENDAT.
*--- Create the Proxy
    TRY.
        CREATE OBJECT mo_e2e_ws_proxy
          EXPORTING
            logical_port_name = ls_logical_port-lp_name.
      CATCH cx_ai_system_fault INTO lo_sys_exception.
        IF NOT lo_sys_exception IS INITIAL.
          CLEAR mo_e2e_ws_proxy.
          lv_message = lo_sys_exception->get_text( ).
          RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Error when connecting to WS proxy: &2.'(e10) iv_msg2 = lv_message.
          IF lv_flg_last = 'X'.
            "no more logical port to test so exit with error.
            RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'No working logical port found => EXIT'(e11).
            RAISE cant_create_ws_proxy.
          ENDIF.
        ENDIF.
    ENDTRY.
    "Event the proxy instance could be created, we have to check if it works
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test the selected port &2 by trying to retrieve a UUID.'(M24) iv_msg2 = ls_logical_port-lp_name.
    IF ( ws_get_unique_id( ) CO ' 8' ).
      IF lv_flg_last = 'X'.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'No working logical port found => EXIT'(e11).
        RAISE cant_create_ws_proxy.
      ENDIF.
    ELSE.
      "This logical port works so we keep it.
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'The port &2 works correctly then keep it.'(M25) iv_msg2 = ls_logical_port-lp_name.
      EXIT.
    ENDIF.
  ENDLOOP.

  TRY.
      "Use the same logical port
      CREATE OBJECT mo_e2e_validation_ws_proxy
        EXPORTING
          logical_port_name = ls_logical_port-lp_name.
    CATCH cx_ai_system_fault INTO lo_sys_exception.
      IF NOT lo_sys_exception IS INITIAL.
        CLEAR mo_e2e_validation_ws_proxy.
        lv_message = lo_sys_exception->get_text( ).
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Error when connecting to WS proxy: &2.'(e10) iv_msg2 = lv_message.
        "no more logical port to test so exit with error.
        RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'No working logical port found => EXIT'(e11).
        RAISE cant_create_ws_proxy.
      ENDIF.
  ENDTRY.

  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'S' iv_msg1 = 'SAP E2E Framework initialization successfully done.'(s01).
ENDMETHOD.