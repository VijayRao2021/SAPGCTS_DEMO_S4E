REPORT zutf_e2e_outbound_example NO STANDARD PAGE HEADING LINE-SIZE 255.
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
*                                              TYPES                                               *
****************************************************************************************************
TYPE-POOLS:
 abap,
 zetoe.

****************************************************************************************************
*                                            CONSTANTS                                             *
****************************************************************************************************
CONSTANTS:
 gc_interface_id TYPE zetoe_interface_id VALUE 'TEST001'.

****************************************************************************************************
*                                            SAP TABLES                                            *
****************************************************************************************************
*TABLES:


****************************************************************************************************
*                                   STRUCTURES AND INTERN TABLES                                   *
****************************************************************************************************
DATA:
      gs_audit TYPE z1zaudit.


****************************************************************************************************
*                                             VARIABLES                                            *
****************************************************************************************************
DATA:
  gv_unique_id TYPE zunique_id,

  go_interface_audit TYPE REF TO zcl_bc_interface_audit,
  go_log TYPE REF TO z_cl_utf_log.

****************************************************************************************************
*                                         SELECTION SCREEN                                         *
****************************************************************************************************
*Selection criterion block
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-b01.
PARAMETERS: p_datefr TYPE sy-datum,
            p_dateto TYPE sy-datum.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE text-b02.
PARAMETERS: p_disws AS CHECKBOX DEFAULT space,
            p_loglvl TYPE i DEFAULT 5.
SELECTION-SCREEN END OF BLOCK b02.
****************************************************************************************************
START-OF-SELECTION.
****************************************************************************************************
  "Configure log system
  CREATE OBJECT go_log.
  go_log->set_log_level( p_loglvl ).
  SET HANDLER go_log->add_log.

  "Create the Interface Audit object
  CREATE OBJECT go_interface_audit
    EXPORTING
      iv_disable_ws        = p_disws
    EXCEPTIONS
      cant_create_ws_proxy = 1
      OTHERS               = 99.
  IF sy-subrc = 0.
* Error can't go further with the framework web service
    EXIT." we can stop the program
  ENDIF.

* get the unique ID for the interface run
  gv_unique_id = go_interface_audit->ws_get_unique_id( ).
  IF gv_unique_id = '8'.
* Error can't go further with the framework web service
    EXIT." we can stop the program
    go_interface_audit->ws_enable_disable_ws( '' )."Or disable the web services call
  ENDIF.


  "create the first step
  IF ( go_interface_audit->ws_create( iv_interface_id = gc_interface_id iv_unique_id = gv_unique_id  iv_step_id = zetoe_stepid_start iv_comment = zetoe_stepid_start_c ) <> 0 ).
*handle error
  ENDIF.

  "Send some program information
  "Exemple send the datefrom and dateto used for the extraction
  go_interface_audit->ws_create( iv_interface_id = gc_interface_id iv_unique_id = gv_unique_id  iv_step_id = zetoe_stepid_head_register iv_comment = zetoe_stepid_head_register_c iv_property_name = 'DATEFROM' iv_property_value = p_datefr ).
  go_interface_audit->ws_create( iv_interface_id = gc_interface_id iv_unique_id = gv_unique_id  iv_step_id = zetoe_stepid_head_register iv_comment = zetoe_stepid_head_register_c iv_property_name = 'DATETO' iv_property_value = p_dateto ).

**Start filling the audit segment.
  gs_audit-interface_id = gc_interface_id.
  gs_audit-unique_id = gv_unique_id.

**Generate the idocs and complete the audit segment.
  go_interface_audit->ws_create( iv_interface_id = gc_interface_id iv_unique_id = gv_unique_id  iv_step_id = zetoe_stepid_data_gen iv_comment = zetoe_stepid_data_gen_c ).
  gs_audit-documents_counter = 12.
*.
*.
*.
*Idocs creation...
*.
*.
*.

  "Send the audit data put in the audit segment
  IF ( go_interface_audit->ws_send_audit_data( iv_step_id = zetoe_stepid_audit_values iv_comment = zetoe_stepid_audit_values_c is_audit_data = gs_audit ) <> 0 ).
    "Error.
  ENDIF.

  "It is finished
  go_interface_audit->ws_create( iv_interface_id = gc_interface_id iv_unique_id = gv_unique_id  iv_step_id = zetoe_stepid_completed iv_comment = zetoe_stepid_completed_c ).
****************************************************************************************************
END-OF-SELECTION.
****************************************************************************************************

*--------------------------------------------- REPORT ---------------------------------------------*
  "Write the log in the spool
  go_log->write_log( ).

*****************************************     INCLUDES     *****************************************


****************************************************************************************************
*                                               FORMS                                              *
****************************************************************************************************