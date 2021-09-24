************************************************************************
* 5/3/17   smartShift project
* Rule ids applied: #712
************************************************************************

REPORT zutf_e2e_audit_idocs_preproces NO STANDARD PAGE HEADING LINE-SIZE 255.
****************************************************************************************************
* FLOW         :                                                                                   *
*--------------------------------------------------------------------------------------------------*
* AIM          :                                                                                   *
*                                                                                                  *
*--------------------------------------------------------------------------------------------------*
* Author       :                                                                                   *
* Creation Date:                                                                                   *
****************************************************************************************************

****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 28/07/2015 ! GAP-1790: add a new TVARVC variable for non E2E postprocessing range   *
* GAP-1790   !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 25/02/2016 ! GAP-2270: call the new method to do the duplicate control              *
* GAP-2270   !            !                                                                        *
*------------+------------+------------------------------------------------------------------------*
* R. NARALA  ! 20/04/2018 !INC0577305: Add selection parameters for TVARVC Variants.               *
* INC0577305 !            !                                                                        *
* GUPTEY     ! 18/5/2019  !INC0829526-Call method set_interface_id_to_check before Interface_Delta *
*                          check method                                                            *
*                          Remove parameter GT_INTERFACE_ID from method call of get_eai_validation *
****************************************************************************************************
* SHAHASJ    ! 08/09/2020 !INC1122130 - Enhancement to IDOC Pre-processing program                 *
* INC1122130               Adding a new message to Audit Pre-processing Program to print the last  *
*                          audited IDOC of that bunch. Added Text Symbol (S02) for the Text        *
****************************************************************************************************


****************************************************************************************************
*                                            CONSTANTS                                             *
****************************************************************************************************
*-> Start of changes for INC0577305
*CONSTANTS:
*  gcv_tvarvc_preproc  TYPE tvarvc-name VALUE 'AUDIT_E2E_PREPROC_LAST_IDOC',
*  gcv_tvarvc_rbdapp01 TYPE tvarvc-name VALUE 'AUDIT_E2E_PROC_IDOC_MAX',
*  gcv_tvarvc_analyze  TYPE tvarvc-name VALUE 'AUDIT_E2E_ANALYZE_IDOC_RANGE',
*  gcv_tvarvc_postproc TYPE tvarvc-name VALUE 'AUDIT_NE2E_POSTPROC_IDOC_RANGE'. "GAP1790+
*-> End of changes for INC0577305
****************************************************************************************************
*                                            SAP TABLES                                            *
****************************************************************************************************
TABLES:
  zbc_audit_cust,
  edidc.

****************************************************************************************************
*                                              TYPES                                               *
****************************************************************************************************
TYPE-POOLS:
 abap,zetoe.

****************************************************************************************************
*                                   STRUCTURES AND INTERN TABLES                                   *
****************************************************************************************************
DATA:
  gt_idocs                      TYPE edidc_tt,
  gs_idoc                       TYPE edidc,

  gs_date_range                 TYPE zoutmngt_date_range, "GAP-DCR+
  gs_time_range                 TYPE zoutmngt_time_range, "GAP-DCR+
  gs_interface_delta_management TYPE zfi_inter_out, "GAP-DCR+

  gt_interface_id               TYPE zetoe_tr_interface_id_range.

****************************************************************************************************
*                                             VARIABLES                                            *
****************************************************************************************************
DATA:
  gv_idoc_first      TYPE edi_docnum,                       "GAP1790+
  gv_idoc_last       TYPE edi_docnum,                       "GAP-1790+

  go_interface_audit TYPE REF TO zcl_bc_interface_audit,
  go_interface_delta TYPE REF TO z_cl_bc_outbound_interface, "GAP-DCR+
  go_log             TYPE REF TO z_cl_utf_log.

****************************************************************************************************
*                                         SELECTION SCREEN                                         *
****************************************************************************************************
*Selection criterion block
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
SELECT-OPTIONS: s_docnum FOR edidc-docnum,
                s_rcvpor FOR edidc-rcvpor,
                s_rcvprt FOR edidc-rcvprt,
                s_rcvprn FOR edidc-rcvprn,
                s_mestyp FOR edidc-mestyp,
                s_idoctp FOR edidc-idoctp,
*                s_credat FOR edidc-credat,
                s_direct FOR edidc-direct,
                s_status FOR edidc-status,
                s_int_id FOR zbc_audit_cust-interface_id.
SELECTION-SCREEN END OF BLOCK b01.
*-Start of GAP-DCR+
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
PARAMETERS: p_proces TYPE zinterface_id,
            p_resend TYPE zoutmngt_resend_mode AS CHECKBOX DEFAULT space USER-COMMAND resend_uc.
SELECT-OPTIONS: s_udate   FOR gs_date_range DEFAULT sy-datum NO-EXTENSION,
                s_utime   FOR gs_time_range DEFAULT sy-uzeit NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK b02.
*-End of GAP-DCR+

*-> Start of changes for INC0577305
SELECTION-SCREEN BEGIN OF BLOCK b04 WITH FRAME TITLE TEXT-b04.
PARAMETERS: p_prepro TYPE tvarvc-name DEFAULT 'AUDIT_E2E_PREPROC_LAST_IDOC',
            p_rbdapp TYPE tvarvc-name DEFAULT 'AUDIT_E2E_PROC_IDOC_MAX',
            p_analyz TYPE tvarvc-name DEFAULT 'AUDIT_E2E_ANALYZE_IDOC_RANGE',
            p_postpr TYPE tvarvc-name DEFAULT 'AUDIT_NE2E_POSTPROC_IDOC_RANGE'.
SELECTION-SCREEN END OF BLOCK b04.
*-> End of changes for INC0577305

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
PARAMETERS: p_disws  AS CHECKBOX DEFAULT space,
            p_recycl AS CHECKBOX DEFAULT 'X',
            p_tvarvc AS CHECKBOX DEFAULT 'X',
            p_loglvl TYPE i DEFAULT 5.
SELECTION-SCREEN END OF BLOCK b03.

*-Start of GAP-DCR+
AT SELECTION-SCREEN.
* Selections validation
  PERFORM screen_output.

AT SELECTION-SCREEN OUTPUT.
  PERFORM screen_output.

*-End of GAP-DCR+
****************************************************************************************************
START-OF-SELECTION.
****************************************************************************************************
  "Configure log system
  CREATE OBJECT go_log.
  go_log->set_log_level( p_loglvl ).
  go_log->configure_group( iv_group = 'ERROR_MAIL' iv_level = p_loglvl iv_display = '' ).
  SET HANDLER go_log->add_log.

  "Create the Interface Audit object
  CREATE OBJECT go_interface_audit
    EXPORTING
      iv_disable_ws        = p_disws
      iv_mode              = 'P'
    EXCEPTIONS
      cant_create_ws_proxy = 1
      OTHERS               = 99.
  IF sy-subrc = 0.
     gt_interface_id[] = s_int_id[].  "YG-001-INC0829526-18/5/19++
     go_interface_audit->set_interface_id_to_check( gt_interface_id ).  "YG-001-INC0829526-18/5/19++
*-Start of GAP-DCR+
    CREATE OBJECT go_interface_delta
      EXPORTING
        iv_interface_id = p_proces
        iv_variant_name = sy-slset
        iv_catchup_mode = p_resend
*       iv_test_mode    = p_test
        iv_date_from    = s_udate-low
        iv_time_from    = s_utime-low
        iv_date_to      = s_udate-high
        iv_time_to      = s_utime-high.

* Get Interace last run details
    CALL METHOD go_interface_delta->get_detail
      IMPORTING
        es_interface_detail  = gs_interface_delta_management
      EXCEPTIONS
        cant_found_interface = 1
        OTHERS               = 2.
    IF sy-subrc <> 0.
      "This error cannot happen as the entry is now automatically created
    ENDIF.
*-End of GAP-DCR+
    SELECT * INTO TABLE gt_idocs
      FROM edidc
      WHERE docnum IN s_docnum AND
            rcvpor IN s_rcvpor AND
            rcvprt IN s_rcvprt AND
            rcvprn IN s_rcvprn AND
            mestyp IN s_mestyp AND
            idoctp IN s_idoctp AND
*            credat IN s_credat AND"GAP-DCR-
            upddat BETWEEN gs_interface_delta_management-fromdate AND gs_interface_delta_management-todate AND "GAP-DCR+
            direct IN s_direct AND
            status IN s_status.
    IF sy-subrc = 0.                                        "GAP1790+
*-Start of GAP-DCR+
      LOOP AT gt_idocs INTO gs_idoc.
        IF ( gs_idoc-credat = gs_interface_delta_management-fromdate AND gs_idoc-cretim < gs_interface_delta_management-fromtime ) OR
           ( gs_idoc-credat = gs_interface_delta_management-todate AND gs_idoc-cretim >= gs_interface_delta_management-totime ) OR
             gs_idoc-credat < gs_interface_delta_management-fromdate OR gs_idoc-credat > gs_interface_delta_management-todate.
          DELETE gt_idocs.
        ENDIF.
      ENDLOOP.
*-End of GAP-DCR+
      SORT gt_idocs BY docnum ASCENDING.                    "GAP1790+
      READ TABLE gt_idocs INTO gs_idoc INDEX 1.             "GAP1790+
      gv_idoc_first = gs_idoc-docnum.                       "GAP1790+
      SORT gt_idocs BY docnum DESCENDING.
      READ TABLE gt_idocs INTO gs_idoc INDEX 1.
      gv_idoc_last = gs_idoc-docnum.                        "GAP1790+
    ELSE.                                                   "GAP1790+
      CLEAR: gv_idoc_last, gv_idoc_first.                   "GAP1790+
    ENDIF.                                                  "GAP1790+

    "Update the TVARVC table for the next run.
*    IF NOT p_tvarvc IS INITIAL AND NOT gs_idoc-docnum IS INITIAL."GAP1790-
*      PERFORM update_tvarvc USING gs_idoc-docnum."GAP1790-
    PERFORM update_tvarvc USING gv_idoc_first gv_idoc_last. "GAP1790+
*  ENDIF.                                                    "GAP1790-
    "Load the Idocs
    go_interface_audit->load_new_idocs( gt_idocs ).
    IF p_recycl = abap_true.
      go_interface_audit->load_recycled_idocs( ).
    ENDIF.

    go_interface_audit->check_duplicate( ).                 "GAP-2270+
*    gt_interface_id[] = s_int_id[].          "YG-001-INC0829526-18/5/19++
     go_interface_audit->get_eai_validation( ).  "YG-001-INC0829526-18/5/19++
*    go_interface_audit->get_eai_validation( gt_interface_id ). "YG-001-INC0829526-18/5/19-Commented
  ENDIF.
  IF go_interface_delta IS NOT INITIAL.
* Update the interface run details
    CALL METHOD go_interface_delta->update
      EXCEPTIONS
        cannot_update = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
****************************************************************************************************
END-OF-SELECTION.
****************************************************************************************************

*--------------------------------------------- REPORT ---------------------------------------------*
  "Write the log in the spool
  go_log->write_log( ).
  go_log->send_mail( iv_group = 'ERROR_MAIL' iv_program = 'E2E_PROCESS' iv_variant = 'E2E_PROC' iv_subject_variable1 = 'Error during preprocessing check'(m01) ).

*****************************************     INCLUDES     *****************************************


****************************************************************************************************
*                                               FORMS                                              *
****************************************************************************************************

*FORM update_tvarvc USING pv_docnum."GAP1790-
FORM update_tvarvc USING pv_docnum_first TYPE edi_docnum    "GAP1790+
                         pv_docnum_last TYPE edi_docnum.    "GAP1790+
  DATA:
        ls_tvarvc TYPE tvarvc.
  IF pv_docnum_last IS NOT INITIAL.                         "GAP1790+
    "NEw idocs have been selected so update the variables
    CLEAR ls_tvarvc.
*    ls_tvarvc-name = gcv_tvarvc_preproc. " DEL for INC0577305
    ls_tvarvc-name = p_prepro.  " INS for INC0577305
    ls_tvarvc-type = 'S'.
    ls_tvarvc-numb = '0000'.
    ls_tvarvc-sign = 'I'.
    ls_tvarvc-opti = 'GT'.
*  ls_tvarvc-low = pv_docnum."GAP1790-
    ls_tvarvc-low = pv_docnum_last.                         "GAP1790+
    MODIFY tvarvc FROM ls_tvarvc.

    CLEAR ls_tvarvc.
*    ls_tvarvc-name = gcv_tvarvc_rbdapp01. " DEL for INC0577305
    ls_tvarvc-name = p_rbdapp. " INS for INC0577305
    ls_tvarvc-type = 'S'.
    ls_tvarvc-numb = '0000'.
    ls_tvarvc-sign = 'I'.
    ls_tvarvc-opti = 'BT'.
*  ls_tvarvc-high = pv_docnum."GAP1790-
    ls_tvarvc-high = pv_docnum_last.                        "GAP1790+
    MODIFY tvarvc FROM ls_tvarvc.

    SELECT SINGLE * INTO ls_tvarvc
      FROM tvarvc
*      WHERE name = gcv_tvarvc_analyze AND  " DEL for INC0577305
      WHERE name = p_analyz AND " INS for INC0577305
            type = 'S' AND
            numb = '0000'. "#EC CI_ALL_FIELDS_NEEDED (confirmed full access)                       "$sst: #712
    IF sy-subrc <> 0.
      CLEAR ls_tvarvc.
*      ls_tvarvc-name = gcv_tvarvc_analyze. " DEL for INC0577305
      ls_tvarvc-name = p_analyz.  " INS for INC0577305
      ls_tvarvc-type = 'S'.
      ls_tvarvc-numb = '0000'.
      ls_tvarvc-sign = 'I'.
      ls_tvarvc-opti = 'BT'.
    ENDIF.
*  ls_tvarvc-high = pv_docnum."GAP1790-
    ls_tvarvc-high = pv_docnum_last.                        "GAP1790+
    MODIFY tvarvc FROM ls_tvarvc.

*-Begin of GAP1790+
    CLEAR ls_tvarvc.
*    ls_tvarvc-name = gcv_tvarvc_postproc.  " DEL for INC0577305
    ls_tvarvc-name = p_postpr. " INS for INC0577305
    ls_tvarvc-type = 'S'.
    ls_tvarvc-numb = '0000'.
    ls_tvarvc-sign = 'I'.
    ls_tvarvc-opti = 'BT'.
    ls_tvarvc-low = pv_docnum_first.
    ls_tvarvc-high = pv_docnum_last.
    MODIFY tvarvc FROM ls_tvarvc.
  ELSE.
    "update the NON E2E postproc to avoid selecting always the same range
    SELECT SINGLE * INTO ls_tvarvc
  FROM tvarvc
*  WHERE name = gcv_tvarvc_preproc AND  " DEL for INC0577305
      WHERE name = p_prepro AND " INS for INC0577305
        type = 'S' AND
        numb = '0000'. "#EC CI_ALL_FIELDS_NEEDED (confirmed full access)                           "$sst: #712
    IF sy-subrc = 0.
*      ls_tvarvc-name = gcv_tvarvc_postproc.  " DEL for INC0577305
      ls_tvarvc-name = p_postpr. " INS for INC0577305
      ls_tvarvc-type = 'S'.
      ls_tvarvc-numb = '0000'.
      ls_tvarvc-sign = 'I'.
      ls_tvarvc-opti = 'EQ'.
      MODIFY tvarvc FROM ls_tvarvc.
    ENDIF.
  ENDIF.
*-End of GAP1790+


  go_log->add_log( iv_group = 'PREPROC' iv_level = 0 iv_type = 'S' iv_msg1 = 'TVARVC table successfully updated'(s01) ).

***SOC-SHAHASJ-001-08.09.2020-INC1122130-FCDK971020
  go_log->add_log( iv_group = 'PREPROC' iv_level = 0 iv_type = 'S' iv_msg1 = 'IDOC considered / audited till: &2'(s02) iv_msg2 = pv_docnum_last ).
***EOC-SHAHASJ-001-08.09.2020-INC1122130-FCDK971020
ENDFORM.                    "update_tvarvc

*-Start GAP-DCR+
FORM screen_output.
  DATA:
    ls_udate LIKE LINE OF s_udate,
    ls_utime LIKE LINE OF s_utime.

  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'S_UDATE-LOW'  OR '%_S_UDATE_%_APP_%-TEXT'
        OR 'S_UDATE-HIGH' OR '%_S_UTIME_%_APP_%-TEXT'
        OR 'S_UTIME-LOW'  OR 'S_UTIME-HIGH'
        OR 'P_RESEND' OR '%_P_RESEND_%_APP_%-TEXT'.
        IF screen-name = 'S_UDATE-LOW' OR screen-name = 'S_UDATE-HIGH'
        OR screen-name = 'S_UTIME-LOW' OR screen-name = 'S_UTIME-HIGH'
        OR screen-name = '%_S_UDATE_%_APP_%-TEXT' OR screen-name = '%_S_UTIME_%_APP_%-TEXT'.
          IF p_resend IS NOT INITIAL.
            IF s_udate IS INITIAL.
              CLEAR ls_udate.
              ls_udate-sign    = 'I'.
              ls_udate-option  = 'BT'.
              ls_udate-low    = sy-datum.
              ls_udate-high    = sy-datum.
              APPEND ls_udate TO s_udate.
            ENDIF.
            IF s_utime IS INITIAL.
              CLEAR ls_utime.
              ls_utime-sign    = 'I'.
              ls_utime-option  = 'BT'.
              ls_utime-low = '000000'.
              ls_utime-high    = '235959'.
              APPEND ls_utime TO s_utime.
            ENDIF.
          ELSE.
            CLEAR: s_udate, s_utime.
            REFRESH: s_udate, s_utime.
            screen-invisible  = 1.
            screen-input      = 0.
            screen-required   = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.
*-End of GAP-DCR+