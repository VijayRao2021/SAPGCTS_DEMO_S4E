  METHOD IS_WAIT_TIME_EXPIRED.
    DATA:
          lv_time_diff TYPE fahztd.

    rv_answer = 8. "Mean not expired

    IF ir_interface->recycling_erdat IS INITIAL OR ir_interface->recycling_erzeit IS INITIAL.
      rv_answer = 8. "Not expired.
    ELSE.
      CALL FUNCTION 'SD_CALC_DURATION_FROM_DATETIME'
        EXPORTING
          i_date1          = ir_interface->recycling_erdat
          i_time1          = ir_interface->recycling_erzeit
          i_date2          = sy-datum
          i_time2          = sy-uzeit
        IMPORTING
          e_tdiff          = lv_time_diff
        EXCEPTIONS
          invalid_datetime = 1
          OTHERS           = 2.
      IF ( sy-subrc = 0 AND lv_time_diff >= 10000 ).
        rv_answer = 0. "Has expired.
      ENDIF.
    ENDIF.
  ENDMETHOD.