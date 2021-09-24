  METHOD process_is_used.
    DATA:
          ls_attribute TYPE zproc_attr.

    super->process_is_used( iv_module_id = iv_module_id iv_object_id = iv_object_id ).
    "Check if the module is already referenced.
    READ TABLE mt_attributes into ls_attribute WITH KEY attribute_id = 'MODULE_ID' value = iv_module_id."TODO create constant for attribute_id
    IF sy-subrc = 0.
      RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 5 iv_type = 'I' iv_msg1 = 'Attribute &2/&3 is already referenced.'(i03) iv_msg2 = 'MODULE_ID' iv_msg3 = iv_module_id.
    ELSE.
      "Create attribute
      CLEAR ls_attribute.
      ls_attribute-process_id = ms_process-process_id.
      ls_attribute-attribute_id = 'MODULE_ID'.
      ls_attribute-value = iv_module_id.
      APPEND ls_attribute TO mt_attributes.
      mv_flg_changed = abap_true.
      RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 1 iv_type = 'I' iv_msg1 = 'Attribute &2/&3 referenced.'(i04) iv_msg2 = 'MODULE_ID' iv_msg3 = iv_module_id.
    ENDIF.

  ENDMETHOD.