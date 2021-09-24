  METHOD get_detail.
    RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 0 iv_type = 'H' iv_msg1 = 'Retrieve interface information'(h02).
    es_interface_detail = ms_interface_detail.
    IF es_interface_detail IS INITIAL.
      RAISE EVENT send_log EXPORTING iv_group = 'OUTINTMNG' iv_level = 1 iv_type = 'E' iv_msg1 = '=>Interface information are empty'(e01).
      RAISE cant_found_interface.
    ENDIF.
  ENDMETHOD.