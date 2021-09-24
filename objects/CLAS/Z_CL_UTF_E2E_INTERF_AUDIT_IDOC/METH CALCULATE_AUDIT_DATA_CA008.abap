************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD CALCULATE_AUDIT_DATA_CA008.
  TYPES:
    BEGIN OF lts_bseg,
      belnr TYPE belnr_d,
      buzei TYPE buzei,
      buzid TYPE buzid,
      koart TYPE koart,
      shkzg TYPE shkzg,
      wrbtr TYPE wrbtr,
      menge TYPE menge_d,
    END OF lts_bseg.

  DATA:
        lv_debit TYPE vtcur_h,
        lv_credit TYPE vtcur_h,
        ls_edids TYPE edids,
        ls_bkpf TYPE bkpf,
        ls_bseg TYPE lts_bseg,
        lt_bseg TYPE STANDARD TABLE OF lts_bseg.

  "Get SAP document
  ls_edids = get_idoc_status_detail( ).

  "Load the items.
  ls_bkpf-belnr = ls_edids-stapa2(10).
  ls_bkpf-bukrs = ls_edids-stapa2+10(4).
  ls_bkpf-gjahr = ls_edids-stapa2+14(4).

  SELECT belnr buzei buzid koart shkzg wrbtr menge INTO TABLE lt_bseg
    FROM bseg
    WHERE bukrs = ls_bkpf-bukrs AND
          belnr = ls_bkpf-belnr AND
          gjahr = ls_bkpf-gjahr ORDER BY PRIMARY KEY.                                              "$sst: #600
  IF sy-subrc <> 0.
    SELECT belnr buzei buzid koart shkzg wrbtr menge INTO TABLE lt_bseg
      FROM vbsegs
      WHERE ausbk = ls_bkpf-bukrs AND
            belnr = ls_bkpf-belnr AND
            gjahr = ls_bkpf-gjahr.
  ENDIF.

  "Do the calculation
  CLEAR: lv_debit, lv_credit.
  LOOP AT lt_bseg INTO ls_bseg WHERE buzid <> 'T'. "Exclude tax items
    CASE ls_bseg-shkzg.
      WHEN 'S'."Debit
        ADD ls_bseg-wrbtr TO lv_debit.
      WHEN 'H'."Credit
        IF ls_bseg-koart = 'S'.
          ADD ls_bseg-wrbtr TO lv_credit.
        ENDIF.
    ENDCASE.
  ENDLOOP.

  IF lv_debit IS NOT INITIAL.
    cs_audit_data-total_debit = cs_audit_data-total_debit + lv_debit.
  ENDIF.
  IF lv_credit IS NOT INITIAL.
    cs_audit_data-total_credit = cs_audit_data-total_credit + lv_credit.
  ENDIF.

ENDMETHOD.