  METHOD transfer_file.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* G. KANUGOLU! 14/11/2018 ! GAP-2974: add duplicate check manage and archiving/parking features    *
* GK-001     !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 09/01/2019 ! GAP-3345: Add the SFTP protocol management                             *
* GAP-3345   !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 11/12/2020 ! GAP-3905: Add REST protocol on HTTP and HTTPS                          *
* GAP-3905   !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* R. TALARI  ! 23/03/2021 ! GAP-3910: Clear Archive folder flag if file successfully sent          *
* RT-001     !            !                                                                        *
****************************************************************************************************

***SOI by GK-001 GAP(2974) 10.08.2018
    DATA(lv_flag) = abap_false.
    rv_rc = 0.
    CASE iv_disable_duplicate_check.
      WHEN abap_true.
        lv_flag = abap_true.
      WHEN abap_false.
        IF ( io_file_object->is_already_sent( ms_file_transfer-duplicate_check ) = 0 ).
          lv_flag = abap_true.
        ELSE.
          rv_rc = 8.
        ENDIF.
      WHEN OTHERS.
        rv_rc = 8.
    ENDCASE.
***EOI by GK-001 GAP(2974) 10.08.2018

    IF lv_flag = abap_true.                      " added by GK-001 GAP(2974) 10.08.2018
      CASE ms_file_server-protocol.
        WHEN 'FTP'.
          rv_rc = transfer_file_ftp( io_file_object ).             " MOD MK-001
        WHEN 'SFTP'.                                        "GAP-3345+
          rv_rc = transfer_file_sftp( io_file_object ).     "GAP-3345+
        WHEN 'REST_HTTP' OR 'REST_HTTPS'.                   "GAP-3905+
          rv_rc = transfer_file_rest( EXPORTING io_file_object = io_file_object iv_parameters = iv_parameters "GAP-3905+
                                      CHANGING cv_response_code = cv_response_code cv_response_text = cv_response_text "SCR-1283
                                               cv_response_time = cv_response_time cv_filesent_time = cv_filesent_time "SCR-1283
                                               cv_retry_attempts = cv_retry_attempts ). "SCR-1283
*** SOI by RT-001 GAP-3910 23.03.2021
          IF rv_rc = 0 AND iv_parameters IS NOT INITIAL.
            CLEAR:ms_file_transfer-archive_file,
                  ms_file_transfer-physical_transfer.
          ENDIF.
** EOI by RT-001 GAP-3910 23.03.2021
        WHEN OTHERS.
          rv_rc = 8.
      ENDCASE.
    ENDIF.                                      " added by GK-001 GAP(2974) 10.08.2018
***SOI by GK-001 GAP(2974) 10.08.2018
    IF rv_rc = 0 AND ms_file_transfer-archive_file = abap_true.
      io_file_object->archive( ).
    ELSEIF rv_rc <> 0 AND ms_file_transfer-park_file = abap_true.
      io_file_object->park( ).
    ENDIF.
***EOI by GK-001 GAP(2974) 10.08.2018
  ENDMETHOD.