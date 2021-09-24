  METHOD constructor.
    DATA:
*          lv_init TYPE flag,   " Commented by KANUGOG GAP(2134)
          lv_string TYPE string."DC-001+

    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 0 iv_type = 'H' iv_msg1 = 'Loading interface detail...'(h01).
    mv_catchup_mode = iv_catchup_mode.
    IF mv_catchup_mode IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Cathup mode disable'(i01).
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Cathup mode enable'(i02).
    ENDIF.

    mv_test_mode = iv_test_mode.
    IF mv_test_mode IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Test mode disable'(i03).
    ELSE.
      RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Test mode enable'(i04).
    ENDIF.

    CONCATENATE iv_mescod iv_mesfct INTO lv_string SEPARATED BY ','."DC-001+
*    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Getting detail for &2, &3, &4, &5'(i05) iv_msg2 = iv_interface_id iv_msg3 = iv_mestyp iv_msg4 = iv_mescod iv_msg5 = iv_mesfct."DC-001-
    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'I' iv_msg1 = '=>Getting detail for &2, &3, &4, &5'(i05) iv_msg2 = iv_interface_id iv_msg3 = iv_variant_name iv_msg4 = iv_mestyp iv_msg5 = lv_string."DC-001+

***SOC by KANUGOG GAP(2134) extract document(sundry invoice, supplier invoice, royalties invoice) created in hyparchive since previous run
    IF iv_mode = 'T'.
*** class calculate a time range between two date and time.
      CALL METHOD me->define_time_mode_range
        EXPORTING
          iv_interface_id = iv_interface_id
          iv_variant_name = iv_variant_name
          iv_mestyp       = iv_mestyp
          iv_mescod       = iv_mescod
          iv_mesfct       = iv_mesfct
          iv_catchup_mode = iv_catchup_mode
          iv_date_from    = iv_date_from
          iv_time_from    = iv_time_from
          iv_date_to      = iv_date_to
          iv_time_to      = iv_time_to
          iv_shift_time   = iv_shift_time.

    ELSE.
*** class calculate a day range between two dates.
      CALL METHOD me->define_day_mode_range
        EXPORTING
          iv_interface_id = iv_interface_id
          iv_variant_name = iv_variant_name
          iv_mestyp       = iv_mestyp
          iv_mescod       = iv_mescod
          iv_mesfct       = iv_mesfct
          iv_catchup_mode = iv_catchup_mode
          iv_date_from    = iv_date_from
          iv_date_to      = iv_date_to.
    ENDIF.


  ENDMETHOD.