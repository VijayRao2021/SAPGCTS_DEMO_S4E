  METHOD create_from_memory.
    DATA:lv_data TYPE string.

    IF mt_file_data IS NOT INITIAL.
*      IF open( iv_filetype = 'BIN' ) = 0.    " DEL GK-001 GAP-3419 06.11.2020 to get file type from file manager table
      IF open( ) = 0.                         " INS GK-001 GAP-3419 06.11.2020 to get file type from file manager table
        LOOP AT mt_file_data INTO lv_data.
          rv_rc = transfer_data( iv_data = lv_data iv_in_memory = abap_false ).
        ENDLOOP.
      ENDIF.
    ENDIF.

    IF rv_rc = 0.
      rv_rc = close( ).
    ENDIF.


  ENDMETHOD.