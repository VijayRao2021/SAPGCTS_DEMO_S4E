************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD CONSTRUCTOR.
  DATA:
        lv_amount TYPE vtcur_h,
        lv_quantity TYPE menge_d,
        ls_data TYPE edid4.

  "Refresh the atttributes
*  CLEAR: mv_auditable, ms_audit_record, ms_control_record."GAP-2270-
  CLEAR: mv_auditable, ms_audit_record, ms_control_record, mv_already_received. "GAP-2270+
  REFRESH mt_datas.

  "Load the customzing.
  IF gt_calculation_customizing[] IS INITIAL.
    SELECT * INTO TABLE gt_calculation_customizing
      FROM zbc_audit_cust.
  ENDIF.

  "Initialize the control record
  IF NOT iv_docnum IS INITIAL.
    SELECT SINGLE * INTO ms_control_record
      FROM edidc
      WHERE docnum = iv_docnum.
  ELSE.
    ms_control_record = is_edidc.
  ENDIF.

  "Get the idoc segment
  SELECT * INTO TABLE mt_datas
    FROM edid4
    WHERE docnum = ms_control_record-docnum AND
          ( segnam = 'Z1AUDIT' OR segnam = 'Z1ZAUDIT' ) ORDER BY PRIMARY KEY.                      "$sst: #600
            "we need only audit segment                                                            "$sst: #600

  "get the Audit segment in the mt_datas table
  READ TABLE mt_datas INTO ls_data WITH KEY segnam = 'Z1ZAUDIT'.
  IF sy-subrc = 0.
    mv_auditable = abap_true.
    ms_audit_record = ls_data-sdata.
  ELSE.
    READ TABLE mt_datas INTO ls_data WITH KEY segnam = 'Z1AUDIT'.
    IF sy-subrc = 0.
      mv_auditable = abap_true.
      ms_audit_record = ls_data-sdata.
    ELSE.
      mv_auditable = abap_false.
    ENDIF.
  ENDIF.
  "Change the audit data format.
  IF mv_auditable = abap_true.
    IF ms_audit_record-total_debit CN '0123456789.,- '.
      CLEAR ms_audit_record-total_debit.
    ENDIF.
    IF ms_audit_record-total_credit CN '0123456789.,- '.
      CLEAR ms_audit_record-total_credit.
    ENDIF.
    IF ms_audit_record-documents_counter CN '0123456789 '.
      CLEAR ms_audit_record-documents_counter.
    ENDIF.
    IF ms_audit_record-output_counter CN '0123456789 '.
      CLEAR ms_audit_record-output_counter.
    ENDIF.
    IF ms_audit_record-total_debit IS NOT INITIAL.
      lv_amount = ms_audit_record-total_debit.
      CLEAR ms_audit_record-total_debit.
      ADD lv_amount TO ms_audit_record-total_debit.
    ENDIF.
    IF ms_audit_record-total_credit IS NOT INITIAL.
      lv_amount = ms_audit_record-total_credit.
      CLEAR ms_audit_record-total_credit.
      ADD lv_amount TO ms_audit_record-total_credit.
    ENDIF.
    IF ms_audit_record-quantity IS NOT INITIAL.
      lv_quantity = ms_audit_record-quantity.
      CLEAR ms_audit_record-quantity.
      ADD lv_quantity TO ms_audit_record-quantity.
    ENDIF.
  ENDIF.
ENDMETHOD.