  METHOD call_system_command.

    DATA:
      lv_additional_parameters TYPE btcxpgpar,
      lv_status                TYPE extcmdexex-status,
      lv_exitcode              TYPE extcmdexex-exitcode,
      ls_execprtcl             TYPE btcxpm,
      lt_execprtcl             TYPE STANDARD TABLE OF btcxpm.

    IF iv_command_name IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'CALL_SYSTEM_COMMAND' iv_level = 1 iv_type = 'E' iv_msg1 = 'No command name specified.'(e01).
      rv_rc = 8.
      EXIT.
    ENDIF.

    CLEAR: lv_status,lv_exitcode,lt_execprtcl, lv_additional_parameters.
    rv_rc = 0.
    CONCATENATE iv_parameter1 iv_parameter2 iv_parameter3 iv_parameter4 iv_parameter5 INTO lv_additional_parameters SEPARATED BY space.

    CALL FUNCTION 'SXPG_COMMAND_CHECK'
      EXPORTING
        commandname                = iv_command_name
        operatingsystem            = sy-opsys
*       targetsystem               =
        additional_parameters      = lv_additional_parameters
*       DESTINATION                =
*       long_params                =
*       ext_user                   = SY-uname
* IMPORTING
*       programname                =
*       defined_parameters         =
*       all_parameters             =
      EXCEPTIONS
        no_permission              = 1
        command_not_found          = 2
        parameters_too_long        = 3
        security_risk              = 4
        wrong_check_call_interface = 5
        x_error                    = 6
        too_many_parameters        = 7
        parameter_expected         = 8
        illegal_command            = 9
        communication_failure      = 10
        system_failure             = 11
        OTHERS                     = 12.

    CASE sy-subrc.
      WHEN 0.
        CALL FUNCTION 'SXPG_COMMAND_EXECUTE'
          EXPORTING
            commandname                   = iv_command_name
            additional_parameters         = lv_additional_parameters
            operatingsystem               = sy-opsys
*           targetsystem                  = sy-host
*           DESTINATION                   =
            stdout                        = 'X'
            stderr                        = 'X'
            terminationwait               = 'X'
*           TRACE                         =
*           DIALOG                        =
          IMPORTING
            status                        = lv_status
            exitcode                      = lv_exitcode
          TABLES
            exec_protocol                 = lt_execprtcl
          EXCEPTIONS
            no_permission                 = 1
            command_not_found             = 2
            parameters_too_long           = 3
            security_risk                 = 4
            wrong_check_call_interface    = 5
            program_start_error           = 6
            program_termination_error     = 7
            x_error                       = 8
            parameter_expected            = 9
            too_many_parameters           = 10
            illegal_command               = 11
            wrong_asynchronous_parameters = 12
            cant_enq_tbtco_entry          = 13
            jobcount_generation_error     = 14
            OTHERS                        = 15.
        CASE sy-subrc.
          WHEN 0.
            IF lv_status = 'E' OR lv_exitcode > 0.
              RAISE EVENT send_log EXPORTING iv_group = 'CALL_SYSTEM_COMMAND' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error executing command &2 with parameters &3.'(e02)
                                             iv_msg2 = iv_command_name iv_msg3 = lv_additional_parameters.
              LOOP AT lt_execprtcl INTO ls_execprtcl.
                RAISE EVENT send_log EXPORTING iv_group = 'CALL_SYSTEM_COMMAND' iv_level = 1 iv_type = 'E' iv_msg1 = ls_execprtcl-message.
              ENDLOOP.
              rv_rc = 8.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.

      WHEN OTHERS.
        RAISE EVENT send_log EXPORTING iv_group = 'CALL_SYSTEM_COMMAND' iv_level = 1 iv_type = 'W' iv_msg1 = 'No authorization to call &2 with &3.'(w01)
                                       iv_msg2 = iv_command_name iv_msg3 = lv_additional_parameters.
        rv_rc = 1.
    ENDCASE.

  ENDMETHOD.