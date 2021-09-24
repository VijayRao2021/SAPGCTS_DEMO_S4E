  METHOD get_full_filename.
    IF iv_folder IS INITIAL.
      CONCATENATE mv_current_folder '/' mv_filename INTO rv_full_filename.
    ELSE.
      CONCATENATE iv_folder '/' mv_filename INTO rv_full_filename.
    ENDIF.
  ENDMETHOD.