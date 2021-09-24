************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD CALCULATE_AUDIT_DATA_INVOIC.
  TYPES:
   BEGIN OF lts_parameters,
       total_debit(1) TYPE c,
       total_credit(1) TYPE c,
       quantity(1) TYPE c,
       amount_factor(6) TYPE c,
       quantity_factor(6) TYPE c,
   END OF lts_parameters.

  DATA:
        lv_belnr TYPE belnr_d,
        lv_gjahr TYPE gjahr,
        lv_debit TYPE vtcur_h,
        lv_credit TYPE vtcur_h,
        lv_quantity TYPE menge_d,

        ls_edids TYPE edids,
        ls_parameters TYPE lts_parameters.
  TYPES: BEGIN OF type_s_rseg_sel,                                                                 "$sst: #712
        WRBTR TYPE RSEG-WRBTR,                                                                     "$sst: #712
        MENGE TYPE RSEG-MENGE,                                                                     "$sst: #712
         END OF type_s_rseg_sel.                                                                   "$sst: #712
  DATA: ls_rseg TYPE type_s_rseg_sel,                                                              "$sst: #712
        lt_rseg TYPE STANDARD TABLE OF type_s_rseg_sel.                                            "$sst: #712

  SPLIT is_configuration-parameters AT ';' INTO ls_parameters-total_debit
                                                ls_parameters-total_credit
                                                ls_parameters-quantity
                                                ls_parameters-amount_factor
                                                ls_parameters-quantity_factor.

  "Get SAP document
  ls_edids = get_idoc_status_detail( ).

  "get the MM invoice number
  IF NOT ( ls_edids-stamid = 'M8' AND ls_edids-stamno = '060' ).
    LOOP AT mt_status_records INTO ls_edids WHERE stamid = 'M8' AND stamno = '060'.
      EXIT.
    ENDLOOP.
  ENDIF.

  lv_belnr = ls_edids-stapa1.
  lv_gjahr = ls_edids-credat(4).

  "Retrieve invoice item.
  SELECT wrbtr menge INTO TABLE lt_rseg                                                            "$sst: #712
    FROM rseg
    WHERE belnr = lv_belnr AND
          gjahr = lv_gjahr.

  "Calculate audit data.
  CLEAR: lv_debit, lv_credit, lv_quantity.
  LOOP AT lt_rseg INTO ls_rseg.
    IF ls_parameters-total_debit = abap_true.
      ADD ls_rseg-wrbtr TO lv_debit.
    ENDIF.
    IF ls_parameters-total_credit = abap_true.
      ADD ls_rseg-wrbtr TO lv_credit.
    ENDIF.
    IF ls_parameters-quantity = abap_true.
      ADD ls_rseg-menge TO lv_quantity.
    ENDIF.
  ENDLOOP.

  "Finally forward the requested data.
  IF ls_parameters-total_debit = abap_true.
    cs_audit_data-total_debit = cs_audit_data-total_debit + ( lv_debit * ls_parameters-amount_factor ).
  ENDIF.
  IF ls_parameters-total_credit = abap_true.
    cs_audit_data-total_credit = cs_audit_data-total_credit + ( lv_credit * ls_parameters-amount_factor ).
  ENDIF.
  IF ls_parameters-quantity = abap_true.
    cs_audit_data-quantity = cs_audit_data-quantity + ( lv_quantity * ls_parameters-quantity_factor ).
  ENDIF.
ENDMETHOD.