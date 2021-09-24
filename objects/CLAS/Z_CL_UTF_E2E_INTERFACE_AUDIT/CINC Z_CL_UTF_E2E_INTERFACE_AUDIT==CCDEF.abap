****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 19.02.2016 ! GAP-2270: define the new types                                         *
* GAP-2270   !            !                                                                        *
****************************************************************************************************

*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

TYPE-POOLS:
 abap,
 zetoe.

TYPES:
     BEGIN OF ts_interface,
       unique_id TYPE zunique_id,
       interface_id TYPE zinterface_id,
       audit_data_received TYPE z1zaudit,   "Audit data sent by Idocs
       audit_data_calculated TYPE z1zaudit, "Audit data calculated with the SAP documents
       data_reconciliation_failed(1) TYPE c,   "Audit data received and calculated don't match
       recycling(1) TYPE c,                    "The unique Id was already in error and it is recycled
       recycling_erdat TYPE erdat,"Date when the unique id has been put in the recycling table
       recycling_erzeit TYPE erzeit,"Time when the unique id has been put in the recycling table
       error_code TYPE zbc_audit_error_code,   "The unique ID has a least one idoc with a problem
       idocs TYPE zbc_audit_idoc_table,     "IDOCs received for the unique ID
       mescod TYPE edi_mescod,  "MC-001
       mesfct TYPE edi_mesfct,  "MC-001
       duplicate_control TYPE ze2e_duplicate_control,       "GAP-2270+
     END OF ts_interface,

     tt_interfaces TYPE STANDARD TABLE OF ts_interface,
*MC-001 GAP-1790 begin
     ts_audit_cust TYPE zbc_audit_cust,
     tt_audit_cust TYPE STANDARD TABLE OF ts_audit_cust,

     ts_postprocessing TYPE ze2e_postproc,
     tt_postprocessing TYPE STANDARD TABLE OF ts_postprocessing,

     ts_postproc_event TYPE ze2e_pstpc_evt,
     tt_postproc_event TYPE STANDARD TABLE OF ts_postproc_event,
*MC-001 GAP-1790 end
*-Begin of GAP-2270+
     ts_duplicate_control_int TYPE ze2e_dup_control,
     tt_duplicate_control_int TYPE STANDARD TABLE OF ts_duplicate_control_int.
*-End of GAP-2270+