****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 25.02.2016 ! GAP-2270:  Don't update to status 64 if idoc is duplicated             *
* GAP-2270   !            !                                                                        *
****************************************************************************************************
METHOD SET_STATUS.
  DATA:
    ls_idoc_status  TYPE bdidocstat,
    lt_idoc_status  TYPE STANDARD TABLE OF bdidocstat,
    ls_idoc_control TYPE edidc.
  CHECK ms_control_record-status <> iv_new_status AND
        ms_control_record-status <> zetoe_idoc_status_processed AND
        ms_control_record-status <> zetoe_idoc_status_error.
*-Begin of GAP-2270+
*  IF mv_already_received IS NOT INITIAL AND iv_new_status <> zetoe_idoc_status_parked. " DEL for INC0577180
  IF mv_already_received IS NOT INITIAL AND iv_new_status <> zetoe_idoc_status_error.  " INS for INC0577180
    EXIT.
  ENDIF.
  ms_control_record-status = iv_new_status.
*-End of GAP-2270+

  CLEAR ls_idoc_status.
  REFRESH lt_idoc_status.

* -> Start of changes for INC0577180
  IF is_idoc_status IS NOT INITIAL.
    MOVE-CORRESPONDING is_idoc_status TO ls_idoc_status.
  ENDIF.
* -> End of changes for INC0577180
  ls_idoc_status-docnum = ms_control_record-docnum.
  ls_idoc_status-status = iv_new_status.
  APPEND ls_idoc_status TO lt_idoc_status.

  CALL FUNCTION 'IDOC_STATUS_WRITE_TO_DATABASE'
    EXPORTING
      idoc_number               = ms_control_record-docnum
    IMPORTING
      idoc_control              = ls_idoc_control
    TABLES
      idoc_status               = lt_idoc_status
    EXCEPTIONS
      idoc_foreign_lock         = 1
      idoc_not_found            = 2
      idoc_status_records_empty = 3
      idoc_status_invalid       = 4
      db_error                  = 5
      OTHERS                    = 6.
ENDMETHOD.