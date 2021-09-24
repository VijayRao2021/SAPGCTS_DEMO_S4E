  METHOD filter_method_es046.
***SOI by GK-001 GAP(2974) 10.08.2018
    TYPES:
      BEGIN OF lts_email_variant,
        variant TYPE raldb_vari,
        file    TYPE eps2filnam,
      END OF lts_email_variant.

    DATA:
      lv_filename       TYPE string,
      lv_full_filename  TYPE string,
      lv_file_extension TYPE string,
      lv_variant        TYPE raldb_vari,
      lv_doc_type(3)    TYPE c,
      lv_cc             TYPE bukrs,
      lv_cnt            TYPE i,
      lv_program        TYPE programm,

      lo_file           TYPE REF TO z_cl_utf_data_file,
      lo_blocks         TYPE REF TO zcl_bc_report_management,
      lo_mail           TYPE REF TO z_cl_utf_mail,

      lt_email_conf     TYPE STANDARD TABLE OF zbc_mail_program,

      ls_email_variant  TYPE lts_email_variant,
      lt_email_variants TYPE STANDARD TABLE OF lts_email_variant,

      lt_body           TYPE STANDARD TABLE OF string.

    CONSTANTS:lc_pdf TYPE string VALUE 'pdf',
              lc_csv TYPE string VALUE 'csv',
              lc_dot TYPE char1  VALUE '.'.

    IF ct_folder_files IS INITIAL.
      EXIT.
    ENDIF.

*lock the file
    z_cl_bc_lock_utilities=>lock_generic_entry( EXPORTING iv_part1 = 'ZFI_ROY_AST_REGEN_TO_GRP' iv_wait = abap_true ). " Added by GK-001 GAP(3303) 18.09.2019

    "calculate date and time 30min ago.
    DATA(lv_time) = sy-uzeit.
    DATA(lv_date) = sy-datum.
    IF lv_time < '003000'.
      lv_date = lv_date - 1.
    ENDIF.
    lv_time = lv_time - 1800."Remove 1800s

    SORT ct_folder_files BY name.

***Check both CSV and PDF files must be there with same filename for interface ES054
***If not delete the corresponding PDF/CSV file from the further processing
    DATA(lt_folder_files) = ct_folder_files.
    IF NOT lt_folder_files IS INITIAL.
      LOOP AT lt_folder_files INTO DATA(ls_folder_files).
        CLEAR:lv_filename,lv_file_extension,lv_full_filename.
        DATA(lv_index) = sy-tabix.
        IF ls_folder_files-name(3) = 'REA' OR ls_folder_files-name(3) = 'REC'
           OR ls_folder_files-name(3) = 'ROY' OR ls_folder_files-name(3) = 'TRI'.  " Added by GK-002 GAP(3303) for Royalty AST files generation
          "REA and REC files have only csv file, no pdf, so don't do the control on them
          CONTINUE.
        ENDIF.
        SPLIT ls_folder_files-name AT lc_dot INTO lv_filename lv_file_extension.

        CASE lv_file_extension.
          WHEN lc_csv.
            lv_full_filename = lv_filename && lc_dot && lc_pdf.
          WHEN lc_pdf.
            lv_full_filename = lv_filename && lc_dot && lc_csv.
          WHEN OTHERS.
            DELETE lt_folder_files INDEX lv_index.
            RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_FILTER_ES046' iv_level = 1 iv_type = 'W' iv_msg1 = 'The file &2 is not a pdf/csv file.'(w06) iv_msg2 = ls_folder_files-name.
        ENDCASE.

        IF NOT line_exists( lt_folder_files[ name = lv_full_filename ] ).
          DELETE lt_folder_files INDEX lv_index.
          RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_FILTER_ES046' iv_level = 1 iv_type = 'W' iv_msg1 = 'The corresponding pdf/csv file does not exist for &2.'(w05) iv_msg2 = ls_folder_files-name.

          "Check for how much time the file is there.
*          CONCATENATE ls_folder_files-mtime+11(2) ls_folder_files-mtime+14(2) ls_folder_files-mtime+17(2) INTO DATA(lv_file_time).
*          CONCATENATE ls_folder_files-mtime+6(4) ls_folder_files-mtime+3(2) ls_folder_files-mtime(2) INTO DATA(lv_file_date).
          IF ( ls_folder_files-date < lv_date ) OR ( ls_folder_files-date = lv_date AND ls_folder_files-time < lv_time ).
            RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_FILTER_ES046' iv_level = 1 iv_type = 'E' iv_msg1 = 'File is now alone for more than 30min, park it.'(e02).

            "check if email config is loaded, if not load it.
            IF lt_email_conf[] IS INITIAL.
              SELECT * INTO TABLE @lt_email_conf
               FROM zbc_mail_program
               WHERE program_name = @mv_process_id
               ORDER BY PRIMARY KEY.
            ENDIF.

            "get document type and company code from file name
            lv_doc_type = ls_folder_files-name(3).
            lv_cc = ls_folder_files-name+20(4).

            lv_cnt = 1.
            DO.
              CASE lv_cnt.
                WHEN 1.
                  "check doc type + CC
                  lv_variant = |{ lv_doc_type }{ lv_cc }|.
                WHEN 2.
                  "check * + CC
                  lv_variant = |*{ lv_cc }|.
                WHEN 3.
                  "check doc type + CC(2)*
                  lv_variant = |{ lv_doc_type }{ lv_cc(2) }*|.
                WHEN 4.
                  "check * + CC(2)*
                  lv_variant = |*{ lv_cc(2) }*|.
                WHEN 5.
                  "check doc type + *
                  lv_variant = |{ lv_doc_type }*|.
                WHEN 6.
                  "check * *
                  lv_variant = |**|.
                WHEN OTHERS.
                  RAISE EVENT send_log EXPORTING iv_group = 'MANAGER_FILE_FILTER_ES046' iv_level = 1 iv_type = 'W' iv_msg1 = 'No Email config found for doc type &2 and CC &3.'(w07) iv_msg2 = lv_doc_type iv_msg3 = lv_cc.
                  "we check everything so we exit.
                  EXIT.
              ENDCASE.
              ADD 1 TO lv_cnt.
              "Identify the email variant to use for current file.
              IF line_exists( lt_email_conf[ variant_name = lv_variant ] ).
                "Email config found.
                CLEAR ls_email_variant.
                ls_email_variant-variant = lv_variant.
                ls_email_variant-file = ls_folder_files-name.
                APPEND ls_email_variant TO lt_email_variants.
                EXIT.
              ENDIF.
            ENDDO.

            "Create file object to park it.
            lv_filename = ls_folder_files-name.
            lo_file = NEW #( iv_dataset_type = zdatm_c_datasettype_inbound iv_filename = lv_filename iv_process_id = mv_process_id ).
            lo_file->park( ).
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    "Check if some files have been parked and if yes then generate an email.
    IF lt_email_variants[] IS NOT INITIAL.
      SORT lt_email_variants BY variant.
      " add a blank line at the end to simplify management of last line
      CLEAR ls_email_variant.
      APPEND ls_email_variant TO lt_email_variants.

      CLEAR lv_variant.
      LOOP AT lt_email_variants INTO ls_email_variant.
        IF lv_variant <> ls_email_variant-variant AND lt_body[] IS NOT INITIAL.

          "Finalize the email body
          APPEND 'Kind Regards,'(b03) TO lt_body.
          APPEND 'SAP Team'(b04) TO lt_body.

          " Create blocks management object
          lo_blocks = NEW #( ).

          "Add the body block
          lo_blocks->add_block( iv_block_name = 'BODY' it_datas_block = lt_body ).

          "Send the email
          IF lo_mail IS NOT BOUND.
            lo_mail = NEW #( ).
          ENDIF.

          lv_program = mv_process_id.
          lo_mail->send_mail_portal( iv_program = lv_program io_block = lo_blocks iv_variant = lv_variant ).

          FREE lo_blocks.
          CLEAR lt_body.
        ENDIF.
        IF lt_body[] IS INITIAL.
          "Initialize the body text
          APPEND 'Hello,'(b01) TO lt_body.
          APPEND 'The file(s) below could not be sent to GRP because the corresponding CSV/PDF file is missing:'(b02) TO lt_body.
        ENDIF.
        "add the file to the file list
        APPEND |- { ls_email_variant-file }| TO lt_body.

        lv_variant = ls_email_variant-variant.
      ENDLOOP.
    ENDIF.

** UnLock the file
    z_cl_bc_lock_utilities=>unlock_generic_entry( iv_part1 = 'ZFI_ROY_AST_REGEN_TO_GRP' ).  " Added by GK-001 GAP(3303) 18.09.2019

    ct_folder_files[] = lt_folder_files[].
***EOI by GK-001 GAP(2974) 10.08.2018
  ENDMETHOD.