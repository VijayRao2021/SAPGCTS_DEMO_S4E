  METHOD get_new_filename.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 21/01/2020 ! GAP3397: Add logical name passed by parameter for custom scenario      *
****************************************************************************************************
    CASE iv_folder.
      WHEN 'ARCHIVE'.
        IF ms_file_manager-archived_file_name IS INITIAL.
          rv_new_filename = iv_current_filename.
        ELSE.
          CALL FUNCTION 'FILE_GET_NAME'
            EXPORTING
              logical_filename = ms_file_manager-archived_file_name
              parameter_1      = iv_current_filename
            IMPORTING
              file_name        = rv_new_filename
            EXCEPTIONS
              file_not_found   = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
            rv_new_filename = iv_current_filename.
*-Begin of GAP3397+
          ELSEIF rv_new_filename(1) = '#'.
            "logical filename cannot start with a parameter so put a # if it is required
            SHIFT rv_new_filename LEFT.
*-End of GAP3397+
          ENDIF.
        ENDIF.

      WHEN 'ERROR'.
        IF ms_file_manager-error_file_name IS INITIAL.
          rv_new_filename = iv_current_filename.
        ELSE.
          CALL FUNCTION 'FILE_GET_NAME'
            EXPORTING
              logical_filename = ms_file_manager-error_file_name
              parameter_1      = iv_current_filename
            IMPORTING
              file_name        = rv_new_filename
            EXCEPTIONS
              file_not_found   = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
            rv_new_filename = iv_current_filename.
*-Begin of GAP3397+
          ELSEIF rv_new_filename(1) = '#'.
            "logical filename cannot start with a parameter so put a # if it is required
            SHIFT rv_new_filename LEFT.
*-End of GAP3397+
          ENDIF.
        ENDIF.

*-Begin of GAP3397+
      WHEN 'CUSTOM'.
        IF iv_custom_filename IS INITIAL.
          rv_new_filename = iv_current_filename.
        ELSE.
          CALL FUNCTION 'FILE_GET_NAME'
            EXPORTING
              logical_filename = iv_custom_filename
              parameter_1      = iv_current_filename
            IMPORTING
              file_name        = rv_new_filename
            EXCEPTIONS
              file_not_found   = 1
              OTHERS           = 2.
          IF sy-subrc <> 0.
            rv_new_filename = iv_current_filename.
          ELSEIF rv_new_filename(1) = '#'.
            "logical filename cannot start with a parameter so put a # if it is required
            SHIFT rv_new_filename LEFT.
          ENDIF.
        ENDIF.
*-End of GAP3397+
    ENDCASE.
  ENDMETHOD.