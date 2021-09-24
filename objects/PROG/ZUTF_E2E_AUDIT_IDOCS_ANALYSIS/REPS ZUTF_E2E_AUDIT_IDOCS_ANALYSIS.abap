************************************************************************
* 5/3/17   smartShift project
* Rule ids applied: #601 #712
************************************************************************

REPORT zutf_e2e_audit_idocs_analysis NO STANDARD PAGE HEADING LINE-SIZE 255.
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
*            !            !                                                                        *
*            !            !                                                                        *
****************************************************************************************************

****************************************************************************************************
*                                            CONSTANTS                                             *
****************************************************************************************************
CONSTANTS:
 gcv_tvarvc_analyze TYPE tvarvc-name VALUE 'AUDIT_E2E_ANALYZE_IDOC_RANGE'.

****************************************************************************************************
*                                            SAP TABLES                                            *
****************************************************************************************************
TABLES:
  edidc.

****************************************************************************************************
*                                              TYPES                                               *
****************************************************************************************************
TYPE-POOLS:
 abap.

****************************************************************************************************
*                                   STRUCTURES AND INTERN TABLES                                   *
****************************************************************************************************
DATA:
  gt_idocs TYPE edidc_tt,
  gs_idoc TYPE edidc.

****************************************************************************************************
*                                             VARIABLES                                            *
****************************************************************************************************
DATA:
  go_interface_audit TYPE REF TO zcl_bc_interface_audit,
  go_log TYPE REF TO z_cl_utf_log.

****************************************************************************************************
*                                         SELECTION SCREEN                                         *
****************************************************************************************************
*Selection criterion block
SELECTION-SCREEN BEGIN OF BLOCK ba1 WITH FRAME TITLE text-ba1.
PARAMETERS: p_table RADIOBUTTON GROUP sel,
            p_select RADIOBUTTON GROUP sel.
SELECTION-SCREEN BEGIN OF BLOCK ba2 WITH FRAME TITLE text-ba2.
SELECT-OPTIONS: s_docnum FOR edidc-docnum,
                s_rcvpor FOR edidc-rcvpor,
                s_rcvprt FOR edidc-rcvprt,
                s_rcvprn FOR edidc-rcvprn,
                s_mestyp FOR edidc-mestyp,
                s_idoctp FOR edidc-idoctp,
                s_credat FOR edidc-credat,
                s_direct FOR edidc-direct,
                s_status FOR edidc-status.
SELECTION-SCREEN END OF BLOCK ba2.
SELECTION-SCREEN END OF BLOCK ba1.
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-b02.
PARAMETERS: p_disws AS CHECKBOX DEFAULT space,
            p_tvarvc AS CHECKBOX DEFAULT ' ',
            p_loglvl TYPE i DEFAULT 5.
SELECTION-SCREEN END OF BLOCK b02.
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
      iv_mode              = 'A'
    EXCEPTIONS
      cant_create_ws_proxy = 1
      OTHERS               = 99.
  IF sy-subrc = 0.
    CASE 'X'.
      WHEN p_select.
        SELECT * INTO TABLE gt_idocs
          FROM edidc
          WHERE docnum IN s_docnum AND
                rcvpor IN s_rcvpor AND
                rcvprt IN s_rcvprt AND
                rcvprn IN s_rcvprn AND
                mestyp IN s_mestyp AND
                idoctp IN s_idoctp AND
                credat IN s_credat AND
                direct IN s_direct AND
                status IN s_status.
        SORT gt_idocs BY docnum DESCENDING.
        READ TABLE gt_idocs INTO gs_idoc INDEX 1.

        "Update the TVARVC table for the next run
        IF NOT p_tvarvc IS INITIAL AND NOT gs_idoc-docnum IS INITIAL.
          PERFORM update_tvarvc USING gs_idoc-docnum.
        ENDIF.
        "Load the Idocs
        go_interface_audit->load_new_idocs( gt_idocs ).

      WHEN p_table.
        "Load the Idocs
        go_interface_audit->load_recycled_idocs( ).
    ENDCASE.

    go_interface_audit->analyze_interfaces( ).
  ENDIF.
****************************************************************************************************
END-OF-SELECTION.
****************************************************************************************************

*--------------------------------------------- REPORT ---------------------------------------------*
  "Write the log in the spool
  go_log->write_log( ).
  go_log->send_mail( iv_group = 'ERROR_MAIL' iv_program = 'E2E_PROCESS' iv_variant = 'E2E_PROC' iv_subject_variable1 = 'Error during analysis check'(m01) ).

*****************************************     INCLUDES     *****************************************


****************************************************************************************************
*                                               FORMS                                              *
****************************************************************************************************

FORM update_tvarvc USING pv_docnum.
  DATA:
        ls_tvarvc TYPE tvarvc.

  SELECT * INTO ls_tvarvc                                                                          "$sst: #601
    FROM tvarvc UP TO 1 ROWS                                                                       "$sst: #601
    WHERE name = gcv_tvarvc_analyze AND
          type = 'S' ORDER BY PRIMARY KEY. "#EC CI_ALL_FIELDS_NEEDED (confirmed full access)  "$sst: #601 #712
ENDSELECT.                                                                                         "$sst: #601
  IF sy-subrc <> 0.
    CLEAR ls_tvarvc.
    ls_tvarvc-name = gcv_tvarvc_analyze.
    ls_tvarvc-type = 'S'.
    ls_tvarvc-numb = '0000'.
    ls_tvarvc-sign = 'I'.
    ls_tvarvc-opti = 'BT'.
  ENDIF.
  ls_tvarvc-low = pv_docnum.
  MODIFY tvarvc FROM ls_tvarvc.

  SELECT SINGLE * INTO ls_tvarvc
  FROM tvarvc
  WHERE name = gcv_tvarvc_analyze AND
        type = 'S' AND
        numb = '0001'. "#EC CI_ALL_FIELDS_NEEDED (confirmed full access)                           "$sst: #712
  IF sy-subrc <> 0.
    CLEAR ls_tvarvc.
    ls_tvarvc-name = gcv_tvarvc_analyze.
    ls_tvarvc-type = 'S'.
    ls_tvarvc-numb = '0001'.
    ls_tvarvc-sign = 'E'.
    ls_tvarvc-opti = 'EQ'.
  ENDIF.
  ls_tvarvc-low = pv_docnum.
  MODIFY tvarvc FROM ls_tvarvc.

  go_log->add_log( iv_group = 'PREPROC' iv_level = 0 iv_type = 'S' iv_msg1 = 'TVARVC table successfully updated'(s01) ).
ENDFORM.                    "update_tvarvc