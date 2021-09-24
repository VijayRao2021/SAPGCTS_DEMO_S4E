************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD IS_ALREADY_RECEIVED.
  TYPES:
    BEGIN OF lts_edid4_line,
      segnum TYPE idocdsgnum,
      segnam TYPE edi_segnam,
      psgnum TYPE edi_psgnum,
      hlevel TYPE edi_hlevel,
      dtint2 TYPE	edi_dtint2,
      sdata	 TYPE edi_sdata,
    END OF lts_edid4_line,

    BEGIN OF lts_edid4_line2,
      segnum TYPE idocdsgnum,
      segnam TYPE edi_segnam,
      psgnum TYPE edi_psgnum,
      hlevel TYPE edi_hlevel,
      sdata	 TYPE edi_sdata,
    END OF lts_edid4_line2.
  DATA:
    lt_datas        TYPE STANDARD TABLE OF lts_edid4_line,
    lt_datas2       TYPE STANDARD TABLE OF lts_edid4_line2,
    ls_datas        TYPE lts_edid4_line,
    ls_datas2       TYPE lts_edid4_line2,
    lv_hash         TYPE md5_fields-hash,
    ls_finger_print TYPE ze2e_finger_prt.
  DATA:ls_idoc_status TYPE bdidocstat, " INS for INC0577180
       lv_msg_cls     TYPE bdidocstat-msgid VALUE 'ZGLOBAL_MSG_CLS'.  " INS for INC0577180

  rv_rc          = 0.

  SELECT segnum segnam psgnum hlevel dtint2 sdata INTO TABLE lt_datas
    FROM edid4
    WHERE docnum = ms_control_record-docnum AND
          ( segnam <> 'Z1AUDIT' AND segnam <> 'Z1ZAUDIT' ) ORDER BY PRIMARY KEY.                 "$sst: #600
  "we don't need audit segment here                                                    "$sst: #600
  LOOP AT lt_datas INTO ls_datas.
    MOVE-CORRESPONDING ls_datas TO ls_datas2.
    APPEND ls_datas2 TO lt_datas2.
  ENDLOOP.
  REFRESH lt_datas.

  CALL FUNCTION 'MD5_CALCULATE_HASH_FOR_CHAR'
*     EXPORTING
*       DATA                 =
*       LENGTH               = 0
*       VERSION              = 1
    IMPORTING
      hash           = lv_hash
    TABLES
      data_tab       = lt_datas2
    EXCEPTIONS
      no_data        = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    "Cannot calculate the hash so consider the idoc as already received by security
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT_IDOC/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = 'Error when calculating MD5 checksum on idoc &2 => idoc is parked'(e02) iv_msg2 = ms_control_record-docnum.
    mv_already_received = abap_true.
    rv_rc = 8.
    EXIT.
  ENDIF.
  REFRESH lt_datas.

  SELECT SINGLE * INTO ls_finger_print
    FROM ze2e_finger_prt
    WHERE interface_id = ms_audit_record-interface_id AND
          mescod = ms_control_record-mescod AND
          mesfct = ms_control_record-mesfct AND
          finger_print = lv_hash.
  IF sy-subrc <> 0.
    "Not yet received so create entry in the table
    CLEAR ls_finger_print.
    ls_finger_print-interface_id = ms_audit_record-interface_id.
    ls_finger_print-mescod = ms_control_record-mescod.
    ls_finger_print-mesfct = ms_control_record-mesfct.
    ls_finger_print-finger_print = lv_hash.
    ls_finger_print-finger_print_type = 'I'.
    ls_finger_print-docnum = ms_control_record-docnum.
    ls_finger_print-unique_id = ms_audit_record-unique_id.
    ls_finger_print-receiving_date = ms_control_record-credat.
    INSERT ze2e_finger_prt FROM ls_finger_print.
  ELSE.
    IF ls_finger_print-docnum <> ms_control_record-docnum.
      "Already received
      RAISE EVENT send_log EXPORTING iv_group = 'AUDIT_IDOC/ERROR_MAIL' iv_level = 1 iv_type = 'E' iv_msg1 = 'Idoc &2 has been already received under idoc &3 the &4'(e03) iv_msg2 = ms_control_record-docnum iv_msg3 = ls_finger_print-docnum
                                     iv_msg4 = ls_finger_print-receiving_date.
      mv_already_received = abap_true.
      rv_rc = 8.
* -> Start of changes for INC0577180
* Change IDOC status to 51 and populate error message according to INC0577180 requirement.
      CLEAR: ls_idoc_status.
      ls_idoc_status-msgty = 'E'.
      ls_idoc_status-msgid = lv_msg_cls.
      ls_idoc_status-msgno = '002'.
      ls_idoc_status-msgv1 = ms_control_record-docnum.
      ls_idoc_status-msgv2 = ls_finger_print-docnum.
      ls_idoc_status-msgv3 = ls_finger_print-receiving_date.
      me->set_status( iv_new_status = zetoe_idoc_status_error is_idoc_status = ls_idoc_status ).
* -> End of changes for INC0577180
    ENDIF.
  ENDIF.
ENDMETHOD.