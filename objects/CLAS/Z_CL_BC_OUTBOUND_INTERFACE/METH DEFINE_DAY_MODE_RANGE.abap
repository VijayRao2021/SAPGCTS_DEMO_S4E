  METHOD define_day_mode_range.
    DATA lv_init TYPE flag.
* Get Interface details for existing interfaces
    SELECT SINGLE * FROM zfi_inter_out INTO ms_interface_detail
      WHERE interface_id = iv_interface_id
      AND   variant_name =  iv_variant_name "DC-001+
      AND   mestyp       =  iv_mestyp
      AND   mescod       =  iv_mescod
      AND   mesfct       =  iv_mesfct.
    IF sy-subrc <> 0 AND mv_catchup_mode IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'W' iv_msg1 = '=>Record doesn''t exist in ZFI_INTER_OUT: create it.'(w01).
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
        ms_interface_detail-fromdate = sy-datum - 1.
      ENDIF.

      ms_interface_detail-fromtime = space.
      ms_interface_detail-daterun = sy-datum.
      ms_interface_detail-timerun = space.
      ms_interface_detail-todate  = sy-datum - 1.
      ms_interface_detail-totime  = space.

      INSERT zfi_inter_out FROM ms_interface_detail.
      lv_init = abap_true.
    ENDIF.

    "Data preparation for the next run
    IF mv_catchup_mode IS INITIAL.
      IF lv_init IS INITIAL.  " at least 2nd Run
        ms_interface_detail-fromdate = ms_interface_detail-todate.
        ms_interface_detail-fromtime = ms_interface_detail-totime.
      ENDIF.
      ms_interface_detail-daterun = sy-datum.
      ms_interface_detail-timerun = space.
      ms_interface_detail-todate  = sy-datum - 1.
      ms_interface_detail-totime  = space.
    ELSE.                    "RE-Run
      ms_interface_detail-fromdate = iv_date_from.
      ms_interface_detail-fromtime = space.
      ms_interface_detail-todate   = iv_date_to.
      ms_interface_detail-totime   = space.
    ENDIF.
    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Date/time from &2 Date/time to &3'(i08) iv_msg2 = ms_interface_detail-fromdate iv_msg3 = ms_interface_detail-todate.
  ENDMETHOD.