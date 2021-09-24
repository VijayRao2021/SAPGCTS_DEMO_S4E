  METHOD CONSTRUCTOR.
    DATA:
          lv_group TYPE string.
    lv_group = iv_module_id.
    mv_object_id = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).

    RAISE EVENT send_log EXPORTING iv_group = lv_group iv_level = 1 iv_type = 'I' iv_msg1 = 'Instance &2 created.'(i02) iv_msg2 = mv_object_id.
    mv_module_id = iv_module_id.
    CLEAR mv_flg_changed.
  ENDMETHOD.