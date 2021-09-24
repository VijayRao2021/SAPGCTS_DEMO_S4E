  METHOD sign.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 27/01/2020 ! GAP-3397: create the method                                            *
* GAP-3397   !            !                                                                        *
****************************************************************************************************
    DATA: lv_toolkit   TYPE ssfparms-ssftoolkit,
          lv_ssfformat TYPE ssfparms-ssfformat,
          lv_profileid TYPE ssfargs-profileid,
          lv_profile   TYPE ssfargs-profile,
          lv_profilepw TYPE ssfargs-profilepw,
          lv_hashalg   TYPE ssfargs-hashalg,
          lv_inccerts  TYPE ssfargs-inccerts,
          lv_detached  TYPE ssfargs-detached,
          lt_signer    TYPE TABLE OF ssfinfo,
          ls_signer    TYPE ssfinfo,
          lv_undefined TYPE ssfinfo-result VALUE 28,
          lv_sig_ns    TYPE ssfinfo-namespace,
          lv_in_enc    TYPE ssfparms-binenc VALUE 'X',
          lv_io_spec   TYPE ssfparms-iospec VALUE 'T',
          lv_in_length TYPE ssflen,
          lv_line      TYPE string.
    DATA: lt_input_data  TYPE rmps_ssfbin,
          lt_output_data TYPE rmps_ssfbin,
          ls_input_data  TYPE ssfbin.
    DATA:
      lv_string  TYPE string,
      lv_xstring TYPE xstring,
      lt_xtab    TYPE enh_version_management_hex_tb,
      ls_data    TYPE ssfbin.

    CLEAR:lv_toolkit     ,        lv_ssfformat   ,
          lv_profileid   ,        lv_profile     ,        lv_profilepw   ,
          lv_hashalg     ,        lv_inccerts    ,        lv_detached    ,
          lt_signer      ,        ls_signer      ,        lv_undefined   ,
          lv_sig_ns      ,        lv_in_enc      ,        lv_io_spec     ,
          lv_in_length   ,        lt_input_data  ,        lt_output_data ,
          ls_input_data  ,        lv_string      ,
          lv_xstring     ,        lt_xtab        ,        ls_data        .

    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 0 iv_type = 'H' iv_msg1 = 'Sign file &2.'(h04) iv_msg2 = mv_filename.
    rv_rc = 0.

    lv_undefined   = 28.
    lv_in_enc      = 'X'.
    lv_io_spec     = 'T'.

    "Load the file
    open( iv_filetype = 'FASC' ).
    load_in_memory( ).
    close( ).

    IF mt_file_data IS NOT INITIAL.

      "Convert file into a string.
      CLEAR lv_string.
      LOOP AT mt_file_data INTO lv_line.
        CONCATENATE lv_string lv_line INTO lv_string.
      ENDLOOP.

      "Convert the string into a xstring.
      CALL FUNCTION 'ECATT_CONV_STRING_TO_XSTRING'
        EXPORTING
          im_string  = lv_string
*         IM_ENCODING       = 'UTF-8'
        IMPORTING
          ex_xstring = lv_xstring
          ex_len     = lv_in_length.

      IF NOT lv_in_length IS INITIAL.
        "Convert xstring into table
        CALL FUNCTION 'ENH_XSTRING_TO_TAB'
          EXPORTING
            im_xstring = lv_xstring
          IMPORTING
            ex_data    = lt_xtab
            ex_leng    = lv_in_length.

        "Move table into another format
        LOOP AT lt_xtab INTO ls_data-bindata.
          APPEND ls_data TO lt_input_data.
        ENDLOOP.

        "Read certificate config
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Get certifcate parameter for application &2.'(i18) iv_msg2 = iv_application.
        CALL FUNCTION 'SSF_GET_PARAMETER'
          EXPORTING
            mandt                   = sy-mandt
            application             = iv_application
          IMPORTING
*           appfound                = lv_appfound
            ssftoolkit              = lv_toolkit
            str_format              = lv_ssfformat
*           str_pab                 = lv_pab
*           str_pab_password        = lv_pabpw
            str_profileid           = lv_profileid
            str_profile             = lv_profile
            str_profilepw           = lv_profilepw
            str_hashalg             = lv_hashalg
*           str_encralg             = lv_encralg
            b_inccerts              = lv_inccerts
            b_detached              = lv_detached
*           b_distrib               = lv_distrib
          EXCEPTIONS
            ssf_parameter_not_found = 1
            OTHERS                  = 2.
        IF sy-subrc <> 0.
          rv_rc = 8.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = sy-msgty iv_msgid = sy-msgid iv_msgno = sy-msgno iv_msg1 = sy-msgv1
                                         iv_msg2 = sy-msgv2 iv_msg3 = sy-msgv3 iv_msg4 = sy-msgv4.
          EXIT.
        ELSE.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Certifcate parameter loaded.'(i19).
        ENDIF.
        ls_signer-id        = lv_profileid.
        ls_signer-namespace = lv_sig_ns.
        ls_signer-profile   = lv_profile.
        ls_signer-password  = lv_profilepw.
        ls_signer-result    = lv_undefined.
        APPEND ls_signer TO lt_signer.

        "Sign the file
        RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Sign the file data.'(i20).
        CALL FUNCTION 'SSF_KRN_SIGN'
          EXPORTING
            ssftoolkit                   = lv_toolkit
            str_format                   = lv_ssfformat
            b_inc_certs                  = lv_inccerts
            b_detached                   = lv_detached
            b_inenc                      = lv_in_enc
            io_spec                      = lv_io_spec
            ostr_input_data_l            = lv_in_length
            str_hashalg                  = lv_hashalg
          TABLES
            ostr_input_data              = lt_input_data
            signer                       = lt_signer
            ostr_signed_data             = lt_output_data
          EXCEPTIONS
            ssf_krn_error                = 399
            ssf_krn_noop                 = 201
            ssf_krn_nomemory             = 202
            ssf_krn_opinv                = 203
            ssf_krn_signer_list_error    = 205
            ssf_krn_input_data_error     = 208
            ssf_krn_invalid_par          = 209
            ssf_krn_invalid_parlen       = 210
            ssf_fb_input_parameter_error = 211
            OTHERS                       = 212.
        IF sy-subrc <> 0.
          rv_rc = 8.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = sy-msgty iv_msgid = sy-msgid iv_msgno = sy-msgno iv_msg1 = sy-msgv1
                                         iv_msg2 = sy-msgv2 iv_msg3 = sy-msgv3 iv_msg4 = sy-msgv4.
          EXIT.
        ELSE.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'I' iv_msg1 = 'File data signed.'(i21).
        ENDIF.
        IF NOT lt_output_data IS INITIAL.
          RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'I' iv_msg1 = 'Overwrite file with signed data.'(i22).
          OPEN DATASET mv_filename_full FOR OUTPUT IN BINARY MODE.
          IF sy-subrc IS INITIAL.
            LOOP AT lt_output_data INTO ls_input_data.
              TRANSFER ls_input_data-bindata TO mv_filename_full.
            ENDLOOP.
            CLOSE DATASET mv_filename_full.
          ELSE.
            rv_rc = 8.
            RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error while writing file.'(e14).
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE.
      rv_rc = 8.
      RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'E' iv_msg1 = 'File is empty: nothing to sign.'(e15).
      EXIT.
    ENDIF.
    RAISE EVENT send_log EXPORTING iv_group = 'DATASET_FILE_SIGN' iv_level = 1 iv_type = 'S' iv_msg1 = 'File successfully signed.'(s01).
  ENDMETHOD.