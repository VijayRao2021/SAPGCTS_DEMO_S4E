************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD CALCULATE_AUDIT_DATA_PIPS014.
*  DATA:
*        lv_amount_external TYPE bapicurr-bapicurr.
*  TYPES: BEGIN OF type_s_pipsbal_hdr_sel,                                                          "$sst: #712
*        Z_PIPS_FILE_ID TYPE ZFI_PIPSBAL_HDR-Z_PIPS_FILE_ID,                                        "$sst: #712
*         END OF type_s_pipsbal_hdr_sel.                                                            "$sst: #712
*  DATA: ls_pipsbal_hdr TYPE type_s_pipsbal_hdr_sel,                                                "$sst: #712
*        ls_pipsbal_item TYPE zfi_pipsbal_item,
*        lt_pipsbal_items TYPE STANDARD TABLE OF zfi_pipsbal_item.
*
*  SELECT z_pips_file_id INTO ls_pipsbal_hdr                                                   "$sst: #601 #712
*    FROM zfi_pipsbal_hdr UP TO 1 ROWS                                                              "$sst: #601
*    WHERE z_idoc_no = ms_control_record-docnum ORDER BY PRIMARY KEY.                               "$sst: #601
*  ENDSELECT.                                                                                       "$sst: #601
*  IF sy-subrc <> 0.
*    cs_audit_data-documents_counter = 0.
*    cs_audit_data-total_debit = 0.
*    cs_audit_data-total_credit = 0.
*    EXIT.
*  ENDIF.
*
*  SELECT * INTO TABLE lt_pipsbal_items
*    FROM zfi_pipsbal_item
*    WHERE z_pips_file_id = ls_pipsbal_hdr-z_pips_file_id.
*  IF sy-subrc <> 0.
*    cs_audit_data-documents_counter = 0.
*    cs_audit_data-total_debit = 0.
*    cs_audit_data-total_credit = 0.
*    EXIT.
*  ENDIF.
*
*  LOOP AT lt_pipsbal_items INTO ls_pipsbal_item.
*    ADD 1 TO cs_audit_data-documents_counter.
*    IF ls_pipsbal_item-z_post_key1 = 'H'.
*      ADD ls_pipsbal_item-z_dmbtr TO cs_audit_data-total_credit.
*    ELSE.
*      ADD ls_pipsbal_item-z_dmbtr TO cs_audit_data-total_debit.
*    ENDIF.
*    IF ls_pipsbal_item-z_post_key2 = 'H'.
*      ADD ls_pipsbal_item-z_dom_amnt TO cs_audit_data-total_credit.
*    ELSE.
*      ADD ls_pipsbal_item-z_dom_amnt TO cs_audit_data-total_debit.
*    ENDIF.
*    IF ls_pipsbal_item-z_post_key3 = 'H'.
*      ADD ls_pipsbal_item-z_intl_amnt TO cs_audit_data-total_credit.
*    ELSE.
*      ADD ls_pipsbal_item-z_intl_amnt TO cs_audit_data-total_debit.
*    ENDIF.
*  ENDLOOP.
*  lv_amount_external = cs_audit_data-total_credit.
*  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*    EXPORTING
*      currency        = ls_pipsbal_item-z_waers
*      amount_internal = lv_amount_external
*    IMPORTING
*      amount_external = lv_amount_external.
*
*  cs_audit_data-total_credit = lv_amount_external * 100.
*  lv_amount_external = cs_audit_data-total_debit.
*  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
*    EXPORTING
*      currency        = ls_pipsbal_item-z_waers
*      amount_internal = lv_amount_external
*    IMPORTING
*      amount_external = lv_amount_external.
*  cs_audit_data-total_debit = lv_amount_external * 100.
**  CONDENSE cs_audit_data-documents_counter NO-GAPS.
ENDMETHOD.