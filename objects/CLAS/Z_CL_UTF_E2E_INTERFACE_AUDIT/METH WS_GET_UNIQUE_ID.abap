METHOD WS_GET_UNIQUE_ID.
  DATA:
        lv_message TYPE string,
        lv_uuid TYPE sysuuid-c,
* Reference variables for exception class
        lo_sys_exception   TYPE REF TO cx_ai_system_fault,
        lo_app_exception   TYPE REF TO cx_ai_application_fault,
        lo_cx_throwable   TYPE REF TO ze2e_cx_throwable,
* Structures to set and get message content
        ls_request         TYPE ze2e_get_unique_id1,
        ls_response        TYPE ze2e_get_unique_id_response1.

  rv_unique_id = 0.
  IF mv_ws_call IS INITIAL.
    CALL FUNCTION 'SYSTEM_UUID_C_CREATE'
      IMPORTING
        uuid = lv_uuid.
    rv_unique_id = lv_uuid.
  ENDIF.

  CHECK NOT mv_ws_call IS INITIAL.

*--- Call the service
  TRY.
      CLEAR lv_message.

      CALL METHOD mo_e2e_ws_proxy->get_unique_id
        EXPORTING
          input  = ls_request
        IMPORTING
          output = ls_response.

    CATCH cx_ai_system_fault      INTO lo_sys_exception.
      lv_message = lo_sys_exception->get_text( ).
    CATCH ze2e_cx_throwable INTO lo_cx_throwable.
      lv_message = lo_cx_throwable->get_text( ).
    CATCH cx_ai_application_fault INTO lo_app_exception.
      lv_message = lo_app_exception->get_text( ).

  ENDTRY.
*  Error handling
  IF NOT lo_sys_exception IS INITIAL
  OR NOT lo_app_exception IS INITIAL
  OR NOT lo_cx_throwable IS INITIAL.
    "Return an error code
    rv_unique_id = 8.
    RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 0 iv_type = 'E' iv_msg1 = 'Can''t get Unique ID from web service: &2'(e05) iv_msg2 = lv_message.
    EXIT.
  ENDIF.
  rv_unique_id = ls_response-parameters-return.
  RAISE EVENT send_log EXPORTING iv_group = 'AUDIT' iv_level = 1 iv_type = 'I' iv_msg1 = 'Get Unique ID &2 from web service.'(m11) iv_msg2 = rv_unique_id.
ENDMETHOD.