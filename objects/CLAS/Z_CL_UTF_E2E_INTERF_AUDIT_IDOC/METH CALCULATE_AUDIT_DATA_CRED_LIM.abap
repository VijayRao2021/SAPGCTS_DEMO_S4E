************************************************************************
* 5/3/17   smartShift project

************************************************************************

METHOD CALCULATE_AUDIT_DATA_CRED_LIM.

  TYPES:
   BEGIN OF LTS_PARAMETERS,
       TOTAL_DEBIT(1) TYPE C,
       TOTAL_CREDIT(1) TYPE C,
       QUANTITY(1) TYPE C,
       AMOUNT_FACTOR(6) TYPE C,
       QUANTITY_FACTOR(6) TYPE C,
   END OF LTS_PARAMETERS.

  DATA:
        LV_DEBIT TYPE VTCUR_H,
        LV_CREDIT TYPE VTCUR_H,
        LV_QUANTITY TYPE MENGE_D,
        LS_EDIDS TYPE EDIDS,
        LV_KLIMK TYPE KLIMK,
        LS_KNKK TYPE KNKK,
        LS_PARAMETERS TYPE LTS_PARAMETERS,
        LV_COUNTER TYPE NUMC07.


  SPLIT IS_CONFIGURATION-PARAMETERS AT ';' INTO LS_PARAMETERS-TOTAL_DEBIT
                                                LS_PARAMETERS-TOTAL_CREDIT
                                                LS_PARAMETERS-QUANTITY
                                                LS_PARAMETERS-AMOUNT_FACTOR
                                                LS_PARAMETERS-QUANTITY_FACTOR.
  "Get SAP document
  LS_EDIDS = GET_IDOC_STATUS_DETAIL( ).

  CLEAR LV_KLIMK.

* Load customer's account number
  IF LS_EDIDS-STAPA1 IS NOT INITIAL.
    LS_KNKK-KNKLI = LS_EDIDS-STAPA1(10).
  ENDIF.

* Load customer's credit contraol area
  IF LS_EDIDS-STAPA2 IS NOT INITIAL.
    LS_KNKK-KKBER = LS_EDIDS-STAPA2(4).
  ENDIF.

* Get customer's credit limit
  SELECT KLIMK FROM KNKK UP TO 1 ROWS INTO LV_KLIMK                                                "$sst: #601
   WHERE KNKLI = LS_KNKK-KNKLI
     AND KKBER = LS_KNKK-KKBER ORDER BY PRIMARY KEY.                                               "$sst: #601
  ENDSELECT.                                                                                       "$sst: #601

  IF SY-SUBRC EQ 0.
    LV_CREDIT = LV_KLIMK.
  ENDIF.

  ADD 1 TO CS_AUDIT_DATA-DOCUMENTS_COUNTER.

  LV_COUNTER = CS_AUDIT_DATA-DOCUMENTS_COUNTER.

  IF LS_PARAMETERS-TOTAL_CREDIT = ABAP_TRUE.
    CS_AUDIT_DATA-TOTAL_CREDIT = CS_AUDIT_DATA-TOTAL_CREDIT + LV_CREDIT.
  ENDIF.

  CS_AUDIT_DATA-DOCUMENTS_COUNTER = LV_COUNTER.

ENDMETHOD.