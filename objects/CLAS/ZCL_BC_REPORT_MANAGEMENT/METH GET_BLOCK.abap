************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD get_block.
  CONSTANTS:
    lc_crlf    TYPE abap_cr_lf VALUE cl_abap_char_utilities=>cr_lf,
    lc_newline TYPE abap_char1 VALUE cl_abap_char_utilities=>newline.

  TYPES:
   lts_char10000(10000) TYPE c.

  DATA:
    lv_oneline_string          TYPE string,
    lv_newlinechar             TYPE abap_cr_lf,
    lv_bytecount               TYPE rstsbytno,
    lv_buffer                  TYPE string,
    " Job Runtime Parameters
    lv_eventid                 TYPE tbtcm-eventid,
    lv_eventparm               TYPE  tbtcm-eventparm,
    lv_external_program_active TYPE tbtcm-xpgactive,
    lv_jobcount                TYPE tbtcm-jobcount,
    lv_jobname                 TYPE tbtcm-jobname,
    lv_stepcount               TYPE tbtcm-stepcount.
  TYPES: BEGIN OF type_s_tbtcp_sel,                                                                "$sst: #712
           listident TYPE tbtcp-listident,                                                            "$sst: #712
         END OF type_s_tbtcp_sel.                                                                  "$sst: #712
  DATA: lv_tbtcp      TYPE type_s_tbtcp_sel,                                                            "$sst: #712

        ls_block      TYPE ts_block_def,
        ls_list       TYPE abaplist,
        ls_pdf_output TYPE  tline,
        ls_mess_att   TYPE solisti1,
        ls_datas      TYPE lts_char10000,

        lt_list       TYPE STANDARD TABLE OF abaplist,
        lt_w3html     TYPE STANDARD TABLE OF w3html,
        lt_mess_att   TYPE TABLE OF solisti1,
        lt_pdf_output TYPE TABLE OF tline,
        lt_tbtcp      TYPE STANDARD TABLE OF type_s_tbtcp_sel.                                          "$sst: #712

*Checks if the block exists and get his defintion
  READ TABLE t_block INTO ls_block WITH KEY name = iv_block_name.
  IF sy-subrc <> 0.
    RAISE block_doesnt_exist.
  ENDIF.

  CASE ls_block-typeofblock.
    WHEN c_datas_block.
      CASE iv_format.
        WHEN 'HTM'.
          CALL FUNCTION 'WWW_HTML_FROM_LISTOBJECT'
            TABLES
              html       = lt_w3html
              listobject = t_list.

          et_list[] = lt_w3html[].

        WHEN 'PDF'.

* Get current job details
            CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
              IMPORTING
                eventid                 = lv_eventid
                eventparm               = lv_eventparm
                external_program_active = lv_external_program_active
                jobcount                = lv_jobcount
                jobname                 = lv_jobname
                stepcount               = lv_stepcount
              EXCEPTIONS
                no_runtime_info         = 1
                OTHERS                  = 2.

*--obtain spool id
            CHECK NOT ( lv_jobname IS INITIAL ).
            CHECK NOT ( lv_jobcount IS INITIAL ).

            SELECT listident FROM  tbtcp                                                             "$sst: #712
                           INTO TABLE lt_tbtcp
                           WHERE      jobname     = lv_jobname
                           AND        jobcount    = lv_jobcount
                           AND        stepcount   = lv_stepcount
                           AND        listident   <> '0000000000'
                           ORDER BY   jobname
                                      jobcount
                                      stepcount.

            READ TABLE lt_tbtcp INTO lv_tbtcp INDEX 1.
            IF sy-subrc = 0.
              v_rqident = lv_tbtcp-listident.
            ENDIF.


            CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
              EXPORTING
                srlc_spoolid             = v_rqident
                no_dialog                = ' '
              IMPORTING
                pdf_bytecount            = lv_bytecount
              TABLES
                pdf                      = lt_pdf_output
              EXCEPTIONS
                err_no_abap_spooljob     = 1
                err_no_spooljob          = 2
                err_no_permission        = 3
                err_conv_not_possible    = 4
                err_bad_destdevice       = 5
                user_cancelled           = 6
                err_spoolerror           = 7
                err_temseerror           = 8
                err_btcjob_open_failed   = 9
                err_btcjob_submlt_failed = 10
                err_btcjob_close_failed  = 11
                OTHERS                   = 12.

            CHECK sy-subrc = 0.

*--convert the table lt_pdf_ouput into proper format
            DATA : lt_soli_tab TYPE soli_tab.
            CALL FUNCTION 'SX_TABLE_LINE_WIDTH_CHANGE'
              TABLES
                content_in  = lt_pdf_output
                content_out = lt_soli_tab.

            et_list[] = lt_soli_tab.

        WHEN OTHERS.
*Lines selection and add a CRLF char
          CLEAR lv_oneline_string.
          IF ls_block-endlinetype = 'W'.
            lv_newlinechar = lc_crlf.
          ELSE.
            lv_newlinechar = lc_newline.
          ENDIF.

          LOOP AT t_block_datas INTO ls_datas FROM ls_block-begin_idx TO ls_block-end_idx.
            CONCATENATE lv_oneline_string ls_datas lv_newlinechar INTO lv_oneline_string.
          ENDLOOP.

*Finaly convert the string into the final forma
          CALL FUNCTION 'SWA_STRING_TO_TABLE'
            EXPORTING
              character_string = lv_oneline_string
              line_size        = 255
            IMPORTING
              character_table  = et_list.

      ENDCASE.
    WHEN c_list_block.

  ENDCASE.
ENDMETHOD.