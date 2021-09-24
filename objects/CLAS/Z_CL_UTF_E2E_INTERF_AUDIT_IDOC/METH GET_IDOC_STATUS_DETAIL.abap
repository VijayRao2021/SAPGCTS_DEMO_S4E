************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD GET_IDOC_STATUS_DETAIL.
  SELECT * INTO rs_edids
*    UP TO 1 ROWS
    FROM edids
    WHERE docnum = ms_control_record-docnum AND
          status = ms_control_record-status
    ORDER BY logdat logtim. "#EC CI_ALL_FIELDS_NEEDED (METHOD formal parameter)                    "$sst: #712
    APPEND rs_edids TO mt_status_records.
  ENDSELECT.
ENDMETHOD.