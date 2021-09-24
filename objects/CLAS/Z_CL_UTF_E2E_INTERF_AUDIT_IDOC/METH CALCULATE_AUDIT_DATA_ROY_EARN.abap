************************************************************************
* 5/3/17   smartShift project

************************************************************************

*-----------------------------------------------------------------------
* BR-001 24.09.2013  B.Richards/RICHARBR
*                    Ensure multi FI documents are detected
* BR-002 22.11.2013  B.Richards/RICHARBR
*                    Changed to cater for different field format for PB002
*-----------------------------------------------------------------------
METHOD CALCULATE_AUDIT_DATA_ROY_EARN.
  TYPES:
   BEGIN OF lts_parameters,
       total_debit(1) TYPE c,
       total_credit(1) TYPE c,
       amount_factor(6) TYPE c,
   END OF lts_parameters,

   BEGIN OF lts_bseg,
     belnr TYPE belnr_d,                                    "BR-001
     buzei TYPE buzei,                                      "BR-001
     shkzg TYPE shkzg,
     dmbtr TYPE dmbtr,
     menge TYPE menge_d,
   END OF lts_bseg,

*-Begin of BR-001+
   BEGIN OF lts_bkpf,                                       "BR-001
     belnr TYPE belnr_d,                                    "BR-001
     bukrs TYPE bukrs,                                      "BR-001
     gjahr TYPE gjahr,                                      "BR-001
   END   OF lts_bkpf.                                       "BR-001
*-End   of BR-001+

  DATA:
        lv_debit TYPE vtcur_h,
        lv_credit TYPE vtcur_h,
        lv_quantity TYPE menge_d,
        ls_edids TYPE edids,
        lt_edids TYPE STANDARD TABLE OF edids,              "BR-001
        ls_bkpf TYPE bkpf,
        ls_fidc TYPE lts_bkpf,                              "BR-001
        lt_bkpf TYPE STANDARD TABLE OF lts_bkpf,            "BR-001
        ls_bseg TYPE lts_bseg,
        lt_bseg TYPE STANDARD TABLE OF lts_bseg,
        ls_parameters TYPE lts_parameters,
        lv_tabix TYPE p,                                    "BR-001
        ls_results TYPE match_result,                       "BR-002
        lv_doc   TYPE char18.                               "BR-002

  CONSTANTS: lc_customer TYPE char01 VALUE 'D'.

  SPLIT is_configuration-parameters AT ';' INTO ls_parameters-total_debit
                                                ls_parameters-total_credit
                                                ls_parameters-amount_factor.
  "Get SAP document
  ls_edids = get_idoc_status_detail( ).

*-Begin of BR-001+
  lt_edids = mt_status_records.
  DESCRIBE TABLE lt_edids LINES lv_tabix.

* Where an idocs has been split due it's size and multiple FI docs generated,
* then ensure all the documents are retrieved.
  IF lv_tabix GT 1.
    LOOP AT lt_edids INTO ls_edids.
      IF ls_edids-stapa2 IS NOT INITIAL.
        ls_bkpf-belnr = ls_edids-stapa2(10).
        ls_bkpf-bukrs = ls_edids-stapa2+10(4).
        ls_bkpf-gjahr = ls_edids-stapa2+14(4).
      ENDIF.
      MOVE-CORRESPONDING ls_bkpf TO ls_fidc.
      APPEND ls_fidc TO lt_bkpf.
    ENDLOOP.
    SORT lt_bkpf.
    SELECT belnr buzei shkzg dmbtr menge INTO TABLE lt_bseg
      FROM bseg FOR ALL ENTRIES IN lt_bkpf
      WHERE bukrs = lt_bkpf-bukrs AND
            belnr = lt_bkpf-belnr AND
            gjahr = lt_bkpf-gjahr AND
            koart = lc_customer.                          "ASL Line                                "$sst: #600
 "#EC CI_NOORDER                                                                                   "$sst: #600
    SORT lt_bseg BY belnr buzei.                                                                   "$sst: #600
    IF sy-subrc <> 0.
      SELECT belnr buzei shkzg dmbtr menge INTO TABLE lt_bseg
        FROM vbsegs
        FOR ALL ENTRIES IN lt_bkpf
        WHERE ausbk = lt_bkpf-bukrs AND
              belnr = lt_bkpf-belnr AND
              gjahr = lt_bkpf-gjahr AND
              koart = lc_customer.                          "ASL Line
    ENDIF.
  ELSE.                                                     "BR-001
*-End   of BR-001+
    "Load the items.
    IF ls_edids-stapa2 IS NOT INITIAL.
      ls_bkpf-belnr = ls_edids-stapa2(10).
      ls_bkpf-bukrs = ls_edids-stapa2+10(4).
      ls_bkpf-gjahr = ls_edids-stapa2+14(4).
    ENDIF.
*   SELECT shkzg dmbtr menge INTO TABLE lt_bseg                  "BR-001
    SELECT belnr buzei shkzg dmbtr menge INTO TABLE lt_bseg "BR-001
      FROM bseg
      WHERE bukrs = ls_bkpf-bukrs AND
            belnr = ls_bkpf-belnr AND
            gjahr = ls_bkpf-gjahr AND
            koart = lc_customer ORDER BY PRIMARY KEY.                            "ASL Line         "$sst: #600
    IF sy-subrc <> 0.
*      SELECT shkzg dmbtr menge INTO TABLE lt_bseg               "BR-001
      SELECT belnr buzei shkzg dmbtr menge INTO TABLE lt_bseg "BR-001
        FROM vbsegs
        WHERE ausbk = ls_bkpf-bukrs AND
              belnr = ls_bkpf-belnr AND
              gjahr = ls_bkpf-gjahr AND
              koart = lc_customer.                           "ASL Line
    ENDIF.
  ENDIF.                                                    "BR-001

  "Do the calculation
  CLEAR: lv_debit, lv_credit.
  LOOP AT lt_bseg INTO ls_bseg.
    CASE ls_bseg-shkzg.
      WHEN 'S'."Debit
        SUBTRACT ls_bseg-dmbtr FROM lv_credit.
      WHEN 'H'."Credit
        ADD ls_bseg-dmbtr TO lv_credit.
    ENDCASE.
  ENDLOOP.

  IF ls_parameters-total_debit = abap_true.
    cs_audit_data-total_debit = cs_audit_data-total_debit + ( lv_credit * ls_parameters-amount_factor ).
  ENDIF.
  IF ls_parameters-total_credit = abap_true.
    cs_audit_data-total_credit = cs_audit_data-total_credit + ( lv_credit * ls_parameters-amount_factor ).
  ENDIF.
ENDMETHOD.