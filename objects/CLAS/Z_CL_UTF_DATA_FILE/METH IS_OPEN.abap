  METHOD is_open.
    rv_rc = 0.
    IF mv_is_open = abap_false.
      "this class has not open the file
      rv_rc = 8.
    ENDIF.
  ENDMETHOD.