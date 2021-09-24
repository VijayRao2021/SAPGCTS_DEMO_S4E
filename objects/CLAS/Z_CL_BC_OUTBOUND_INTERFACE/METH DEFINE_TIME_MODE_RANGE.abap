  METHOD define_time_mode_range.

    DATA:lv_init      TYPE flag,
         lv_new_tstmp TYPE tzntstmpl.

    DATA:lo_inv_range TYPE REF TO cx_parameter_invalid_range,
         lo_inv_type  TYPE REF TO cx_parameter_invalid_type.

* Get Interface details for existing interfaces
    SELECT SINGLE * FROM zfi_inter_out INTO ms_interface_detail
      WHERE interface_id = iv_interface_id
      AND   variant_name =  iv_variant_name "DC-001+
      AND   mestyp       =  iv_mestyp
      AND   mescod       =  iv_mescod
      AND   mesfct       =  iv_mesfct.
    IF sy-subrc <> 0 AND mv_catchup_mode IS INITIAL.

      IF mv_test_mode IS INITIAL. "TALARIR
        RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'W' iv_msg1 = '=>Record doesn''t exist in ZFI_INTER_OUT: create it.'(w01).
      ENDIF.

      "Record doesn't exist so create it
      CLEAR ms_interface_detail.
      ms_interface_detail-interface_id = iv_interface_id.
      ms_interface_detail-variant_name = iv_variant_name."DC-001+
      ms_interface_detail-mestyp       = iv_mestyp.
      ms_interface_detail-mescod       = iv_mescod.
      ms_interface_detail-mesfct       = iv_mesfct.
      IF iv_date_from IS NOT INITIAL.
        ms_interface_detail-fromdate = iv_date_from.
      ELSE.
        ms_interface_detail-fromdate = sy-datum.
      ENDIF.
      IF iv_time_from IS NOT INITIAL.
        ms_interface_detail-fromtime = iv_time_from.
      ELSE.
        ms_interface_detail-fromtime = sy-uzeit.
      ENDIF.

      ms_interface_detail-daterun = sy-datum.
      ms_interface_detail-timerun = sy-uzeit.
      ms_interface_detail-todate  = sy-datum.
      ms_interface_detail-totime  = sy-uzeit.

      IF mv_test_mode IS INITIAL. "TALARIR
        INSERT zfi_inter_out FROM ms_interface_detail.
      ENDIF.
      lv_init = abap_true.
    ENDIF.

    "Data preparation for the next run
    IF mv_catchup_mode IS INITIAL.
      IF lv_init IS INITIAL.  " at least 2nd Run
        ms_interface_detail-fromdate = ms_interface_detail-todate.
        ms_interface_detail-fromtime = ms_interface_detail-totime.
      ENDIF.
      ms_interface_detail-daterun = sy-datum.
      ms_interface_detail-timerun = sy-uzeit.
      ms_interface_detail-todate  = sy-datum.
      ms_interface_detail-totime  = sy-uzeit.

*** SOI by TALARIR #GAP-3910
      IF lv_init IS INITIAL AND iv_shift_time IS NOT INITIAL.  "For Delta Run

*** Convert into Timestamp
        CONVERT DATE sy-datum TIME sy-uzeit INTO TIME STAMP DATA(lv_timestamp) TIME ZONE 'UTC'.

*** Subtract Seconds from the Timestamp
        TRY.
            CALL METHOD cl_abap_tstmp=>subtractsecs
              EXPORTING
                tstmp   = lv_timestamp
                secs    = iv_shift_time
              RECEIVING
                r_tstmp = lv_new_tstmp.
          CATCH cx_parameter_invalid_range INTO lo_inv_range.
            RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'E'
                                           iv_msg1 = '=>Error while subtract &2 seonds from Date &3 and Time &4'(e03)
                                           iv_msg2 = iv_shift_time
                                           iv_msg3 = ms_interface_detail-todate
                                           iv_msg4 = ms_interface_detail-totime.
          CATCH cx_parameter_invalid_type INTO lo_inv_type.
            RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'E'
                                           iv_msg1 = '=>Error while subtract &2 seonds from Date &3 and Time &4'(e03)
                                           iv_msg2 = iv_shift_time
                                           iv_msg3 = ms_interface_detail-todate
                                           iv_msg4 = ms_interface_detail-totime.
        ENDTRY.

        IF lv_new_tstmp IS NOT INITIAL.
*** Conver the Timestamp into Date and Time format
          CONVERT TIME STAMP lv_new_tstmp TIME ZONE 'UTC'
          INTO DATE ms_interface_detail-todate TIME ms_interface_detail-totime.
        ENDIF.

      ENDIF.
*** EOI by TALARIR #GAP-3910

    ELSE.                    "RE-Run
      ms_interface_detail-fromdate = iv_date_from.
      ms_interface_detail-fromtime = iv_time_from.
      ms_interface_detail-todate   = iv_date_to.
      ms_interface_detail-totime   = iv_time_to.
    ENDIF.
    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Date/time from &2/&3 Date/time to &4/&5'(i07) iv_msg2 = ms_interface_detail-fromdate iv_msg3 = ms_interface_detail-fromtime
                                   iv_msg4 = ms_interface_detail-todate iv_msg5 = ms_interface_detail-totime.
  ENDMETHOD.