  METHOD get_file_name.
    IF iv_full_filename IS NOT INITIAL.
      rv_file_name = get_full_filename( ).
    ELSE.
      rv_file_name = mv_filename.
    ENDIF.
  ENDMETHOD.