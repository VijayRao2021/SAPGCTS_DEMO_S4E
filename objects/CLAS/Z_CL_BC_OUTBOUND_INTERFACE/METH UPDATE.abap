  METHOD update.
    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 0 iv_type = 'H' iv_msg1 = 'Update interface data in ZFI_INTER_OUT.'(h03).
    IF mv_test_mode IS INITIAL AND mv_catchup_mode IS INITIAL.
      MODIFY zfi_inter_out FROM ms_interface_detail.
      IF sy-subrc <> 0.
        RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'E' iv_msg1 = '=>Cannot update interface data in ZFI_INTER_OUT.'(e02).
        RAISE cannot_update.
      ENDIF.
    ENDIF.
  ENDMETHOD.