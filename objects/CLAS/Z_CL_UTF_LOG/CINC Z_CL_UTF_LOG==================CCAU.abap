
CLASS lcl_bc_t_log DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS FINAL.

  PRIVATE SECTION.
    DATA:
      mo_log TYPE REF TO z_cl_utf_log.  "class under test

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: add_log FOR TESTING.
    METHODS: configure_group FOR TESTING.
    METHODS: get_log FOR TESTING.
*    METHODS: send_mail FOR TESTING.
    METHODS: set_log_level FOR TESTING.
    METHODS: write_log FOR TESTING.
    METHODS: save FOR TESTING.
*    METHODS: load FOR TESTING.
    METHODS: raise_log_message FOR TESTING.
ENDCLASS.       "z_Cl_Bc_T_Log


CLASS lcl_bc_t_log IMPLEMENTATION.

  METHOD class_setup.

  ENDMETHOD.


  METHOD class_teardown.

  ENDMETHOD.


  METHOD setup.
    "Create the object instance before starting the test
    CREATE OBJECT mo_log.
  ENDMETHOD.


  METHOD teardown.
    FREE mo_log.
  ENDMETHOD.


  METHOD add_log.
    DATA:
          lv_cnt_lines TYPE i,

          lt_log TYPE zlog_log_table,
          ls_log TYPE zlog_log_tableline.

    "Test 1: add messages to test the attributes
    "increase log level
    mo_log->configure_group( iv_group = '' iv_level = 7 ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 0 iv_type = 'H' iv_msg1 = 'Test header level 0' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test info level 1' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 2 iv_type = 'W' iv_msg1 = 'Test warning level 2' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 3 iv_type = 'E' iv_msg1 = 'Test error level 3' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 4 iv_type = 'A' iv_msg1 = 'Test abend level 4' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 5 iv_type = '' iv_msg1 = 'Test blank level 5' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 6 iv_type = 'O' iv_msg1 = 'Test Sucess(OK) level 6' ).
    mo_log->add_log( iv_group = 'ADD_LOG1' iv_level = 7 iv_type = 'S' iv_msg1 = 'Test Sucess level 7' ).
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG1' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 1: Messages not logged' level = if_aunit_constants=>fatal ).
    LOOP AT lt_log INTO ls_log.
      CASE sy-tabix.
        WHEN 1.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 0 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = '' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test header level 0' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 2.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 1 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'I' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test info level 1' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 3.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 2 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'W' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test warning level 2' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 4.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 3 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'E' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test error level 3' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 5.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 4 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'A' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test abend level 4' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 6.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 5 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = '' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test blank level 5' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 7.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 6 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'S' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test Sucess(OK) level 6' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 8.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 7 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'S' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test Sucess level 7' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
      ENDCASE.
    ENDLOOP.

    "Test 2: Add a new message with submessage
    mo_log->add_log( iv_group = 'ADD_LOG2' iv_level = 0 iv_type = 'E' iv_msg1 = '&3 &5 &2 &4' iv_msg2 = 'different' iv_msg3 = 'Test2 ADD_LOG' iv_msg4 = 'submessages' iv_msg5 = 'with').
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG2' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 2: Message not logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test2 ADD_LOG with different submessages' msg = 'Test 2: Message not properly logged' level = if_aunit_constants=>fatal ).

    "Test 3: Add a new message with submessage at the end
    mo_log->add_log( iv_group = 'ADD_LOG3' iv_level = 0 iv_type = 'E' iv_msg1 = 'Test3 here is the result:' iv_msg2 = 'msg2' iv_msg3 = 'msg3' iv_msg4 = 'msg4' iv_msg5 = 'msg5' iv_put_at_end = 'X' ).
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG3' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 3: Message not logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test3 here is the result: msg2 msg3 msg4 msg5' msg = 'Test 3: Message not properly logged' level = if_aunit_constants=>fatal ).

    "Test 4: Add a new message in two groups in the same time
    mo_log->add_log( iv_group = 'ADD_LOG41/ADD_LOG42' iv_level = 0 iv_type = 'E' iv_msg1 = 'Test4: multi groups').
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG41/ADD_LOG42' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 4: Message not logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test4: multi groups' msg = 'Test 4: Message not properly logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 2.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test4: multi groups' msg = 'Test 4: Message not properly logged' level = if_aunit_constants=>fatal ).

    "Test 5: Add message which is not logged because of the log level
    "set log level
    mo_log->configure_group( iv_group = '' iv_level = 0 ).
    "Log two messages, the second one should not be logged
    mo_log->add_log( iv_group = 'ADD_LOG5' iv_level = 0 iv_type = 'I' iv_msg1 = 'Test 5: Message logged' ).
    mo_log->add_log( iv_group = 'ADD_LOG5' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test 5: Message not logged' ).
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG5' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 5: Message not logged' level = if_aunit_constants=>fatal ).
    DESCRIBE TABLE lt_log LINES lv_cnt_lines.
    cl_abap_unit_assert=>assert_equals( act = lv_cnt_lines exp = 1 msg = 'Test 5: Messages not properly logged' level = if_aunit_constants=>fatal ).

    "Test 6: add message with class message
    mo_log->add_log( iv_group = 'ADD_LOG6' iv_level = 0 iv_type = 'I' iv_msgid = 'ZFI' iv_msgno = '006' iv_msg1 = '123456789' ).
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG6' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 6: Message not logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Contract is missing. ASL: 123456789' msg = 'Test 6: Message not properly logged' level = if_aunit_constants=>fatal ).

    "Test 7: add message to a group with a different handler
    mo_log->configure_group( iv_group = 'ADD_LOG7' iv_level = 0 iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_AT' ).
    mo_log->add_log( iv_group = 'ADD_LOG7' iv_level = 0 iv_type = 'I' iv_msg1 = 'Test 7: Message to log' ).
    mo_log->get_log( EXPORTING iv_group = 'ADD_LOG7' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 7: Message not logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test 7: Message to log' msg = 'Test 7: Message not properly logged' level = if_aunit_constants=>fatal ).
  ENDMETHOD.


  METHOD configure_group.
    DATA:
          lv_subrc TYPE sysubrc,

          ls_group_line_default TYPE zlog_ts_group_line,
          ls_group_line TYPE zlog_ts_group_line,
          ls_group_line2 TYPE zlog_ts_group_line.

    "Test 1: after constructor default group must created
    CLEAR ls_group_line.
    READ TABLE mo_log->mt_groups_table INTO ls_group_line_default WITH KEY group = space al_object = space al_subobject = space.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 1: Default group not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line_default-al_loghandler msg = 'Test 1: Default AL handler not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_initial( act = ls_group_line_default-level msg = 'Test 1: Default log level is not correct' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line_default-display msg = 'Test 1: Default group is not displayed' level = if_aunit_constants=>fatal ).

    "Test 2:Add a new group
    mo_log->configure_group( iv_group = 'NEW_GROUP' iv_level = 0 iv_display = 'X' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 2: New group not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-al_loghandler exp = ls_group_line_default-al_loghandler msg = 'Test 2: Default handler not assigned to new group' level = if_aunit_constants=>fatal ).

    "Test 3:Reconfigure new group
    mo_log->configure_group( iv_group = 'NEW_GROUP' iv_level = 1 iv_display = ' ' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP'.
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-level exp = 1 msg = 'Test 3: Group log level not updated' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_initial( act = ls_group_line-display msg = 'Test 3: Group log display not updated' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_equals( act = mo_log->mv_level_max exp = 1 msg = 'Test 3: Attribute MV_LEVEL_MAX not updated' level = if_aunit_constants=>fatal ).

    "Test 4:Add a group with AL object
    mo_log->configure_group( iv_group = 'NEW_GROUP_AL' iv_level = 0 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_AT' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP_AL'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 4: New group with AL object not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line-al_object msg = 'Test 4: AL object not filled' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line-al_subobject msg = 'Test 4: AL subobject not filled' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_differs( act = ls_group_line-al_loghandler exp = ls_group_line_default-al_loghandler msg = 'Test 4: New AL handler for group with AL object not created' level = if_aunit_constants=>fatal ).

    "Test 5:Add a second configuration to NEW_GROUP with AL object
    mo_log->configure_group( iv_group = 'NEW_GROUP' iv_level = 0 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_CA' iv_mode = 'C' ).
    "check the first configuration
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP' al_object = space al_subobject = space.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 5: First configuration for NEW_GROUP doesn''t exist anymore' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-al_loghandler exp = ls_group_line_default-al_loghandler msg = 'Test 5: Default handler not more assigned to new group' level = if_aunit_constants=>fatal ).
    "check the new configuration
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_CA'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 5: New configuration for NEW_GROUP is not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line-al_object msg = 'Test 5: AL object not filled' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line-al_subobject msg = 'Test 5: AL subobject not filled' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_differs( act = ls_group_line-al_loghandler exp = ls_group_line_default-al_loghandler msg = 'Test 5: New AL handler for NEW_GROUP not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_not_initial( act = ls_group_line-al_loghandler msg = 'Test 5: New AL handler for NEW_GROUP not created' level = if_aunit_constants=>fatal ).

    "Test 6: Add an AL object to the first configuration of NEW
    mo_log->configure_group( iv_group = 'NEW_GROUP' iv_level = 0 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_BE' iv_mode = 'U' ).
    "Try to find the original entry
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP' al_object = space al_subobject = space.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 4 msg = 'Test 6: First configuration of NEW_GROUP not well reconfigured' level = if_aunit_constants=>fatal ).

    "Try to find the new one
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_BE'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 6: First configuration of NEW_GROUP not well reconfigured' level = if_aunit_constants=>fatal ).
*    cl_abap_unit_assert=>assert_differs( act = ls_group_line-al_loghandler exp = ls_group_line_default-al_loghandler msg = 'Test 6: New AL handler for NEW_GROUP not created' level = if_aunit_constants=>fatal ).

    "Test 7:Add a group with an existing AL object
    mo_log->configure_group( iv_group = 'NEW_GROUP_AL' iv_level = 0 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_CA' iv_mode = 'C'  ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP_AL' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_CA'.
    READ TABLE mo_log->mt_groups_table INTO ls_group_line2 WITH KEY group = 'NEW_GROUP' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_CA'.
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-al_loghandler exp = ls_group_line2-al_loghandler msg = 'Test 7: AL handler not reused' level = if_aunit_constants=>fatal ).

    "Test 8: delete a group configuration
    mo_log->configure_group( iv_group = 'NEW_GROUP' iv_level = 0 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_CA' iv_mode = 'D'  ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_CA'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 4 msg = 'Test 8: NEW_GROUP is not deleted' level = if_aunit_constants=>fatal ).

    "Test 9: Create a group configuration with an external number
    mo_log->configure_group( iv_group = 'NEW_GROUP' iv_level = 0 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_CA' iv_mode = 'C' iv_al_extnumber = '12345' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'NEW_GROUP' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_CA' al_extnumber = '12345'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 9: NEW_GROUP with external number not well created' level = if_aunit_constants=>fatal ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line2 WITH KEY group = 'NEW_GROUP_AL' al_object = 'ZFI_INTERFACES' al_subobject = 'ZFI_ROY_EARN_CA'.
    cl_abap_unit_assert=>assert_differs( act = ls_group_line-al_loghandler exp = ls_group_line2-al_loghandler msg = 'Test 9: AL handler not well created' level = if_aunit_constants=>fatal ).
  ENDMETHOD.


  METHOD get_log.
    DATA:
          lt_log TYPE zlog_log_table,
          ls_log TYPE zlog_log_tableline.

    "Test 1: add messages to test the attributes
    "increase log level
    mo_log->configure_group( iv_group = '' iv_level = 7 ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 0 iv_type = 'H' iv_msg1 = 'Test header level 0' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test info level 1' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 2 iv_type = 'W' iv_msg1 = 'Test warning level 2' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 3 iv_type = 'E' iv_msg1 = 'Test error level 3' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 4 iv_type = 'A' iv_msg1 = 'Test abend level 4' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 5 iv_type = '' iv_msg1 = 'Test blank level 5' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 6 iv_type = 'O' iv_msg1 = 'Test Sucess(OK) level 6' ).
    mo_log->add_log( iv_group = 'GET_LOG1' iv_level = 7 iv_type = 'S' iv_msg1 = 'Test Sucess level 7' ).
    mo_log->get_log( EXPORTING iv_group = 'GET_LOG1' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 1: Messages not logged' level = if_aunit_constants=>fatal ).
    LOOP AT lt_log INTO ls_log.
      CASE sy-tabix.
        WHEN 1.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 0 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = '' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test header level 0' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-date exp = sy-datum msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_not_initial( act = ls_log-hour msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 2.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 1 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'I' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test info level 1' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 3.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 2 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'W' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test warning level 2' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 4.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 3 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'E' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test error level 3' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 5.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 4 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'A' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test abend level 4' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 6.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 5 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = '' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test blank level 5' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 7.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 6 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'S' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test Sucess(OK) level 6' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
        WHEN 8.
          cl_abap_unit_assert=>assert_equals( act = ls_log-level exp = 7 msg = 'Test 1: message level not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-msgtype exp = 'S' msg = 'Test 1: message type not properly logged' level = if_aunit_constants=>fatal ).
          cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test Sucess level 7' msg = 'Test 1: message not properly logged' level = if_aunit_constants=>fatal ).
      ENDCASE.
    ENDLOOP.
  ENDMETHOD.


*  METHOD send_mail.
*
*  ENDMETHOD.


  METHOD set_log_level.
    DATA:
      lv_subrc TYPE sysubrc,

      ls_group_line_default TYPE zlog_ts_group_line,
      ls_group_line TYPE zlog_ts_group_line.

    "Test 1: after constructor default log level is 0 update it to 1
    CLEAR ls_group_line.
    READ TABLE mo_log->mt_groups_table INTO ls_group_line_default WITH KEY group = space al_object = space al_subobject = space.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 1: Default group not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_initial( act = ls_group_line_default-level msg = 'Test 1: Default log level is not correct' level = if_aunit_constants=>fatal ).
    mo_log->set_log_level( iv_level = 1 iv_group = ' ' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line_default WITH KEY group = space al_object = space al_subobject = space.
    cl_abap_unit_assert=>assert_equals( act = ls_group_line_default-level exp = 1 msg = 'Test 1: Log level is not updated' level = if_aunit_constants=>fatal ).

    "Test 2:Add a new group and then update its log level to 2
    mo_log->configure_group( iv_group = 'SETLOGLEVEL2' iv_level = 0 ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'SETLOGLEVEL2'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 2: SETLOGLEVEL2 not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-level exp = 0 msg = 'Test 2: log level is not correct' level = if_aunit_constants=>fatal ).
    mo_log->set_log_level( iv_level = 2 iv_group = 'SETLOGLEVEL2 ' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'SETLOGLEVEL2'.
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-level exp = 2 msg = 'Test 2: log level is not updated' level = if_aunit_constants=>fatal ).

    "Test 3: try to update a group which doesn't exist: it should be created in the same time
    mo_log->set_log_level( iv_level = 2 iv_group = 'SETLOGLEVEL3 ' ).
    READ TABLE mo_log->mt_groups_table INTO ls_group_line WITH KEY group = 'SETLOGLEVEL3'.
    lv_subrc = sy-subrc.
    cl_abap_unit_assert=>assert_equals( act = lv_subrc exp = 0 msg = 'Test 3: SETLOGLEVEL3 not created' level = if_aunit_constants=>fatal ).
    cl_abap_unit_assert=>assert_equals( act = ls_group_line-level exp = 2 msg = 'Test 3: log level is not correct' level = if_aunit_constants=>fatal ).
  ENDMETHOD.


  METHOD write_log.
    "Test 1: test display for all message type and for hidden group
    mo_log->configure_group( iv_group = '' iv_level = 7 ).
    mo_log->configure_group( iv_group = 'EMAIL' iv_level = 7 iv_display = '' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 0 iv_type = 'H' iv_msg1 = 'Test header level 0' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test info level 1' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 2 iv_type = 'W' iv_msg1 = 'Test warning level 2' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 3 iv_type = 'E' iv_msg1 = 'Test error level 3' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 4 iv_type = 'A' iv_msg1 = 'Test abend level 4' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 5 iv_type = '' iv_msg1 = 'Test blank level 5' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1' iv_level = 6 iv_type = 'O' iv_msg1 = 'Test Sucess(OK) level 6' ).
    mo_log->add_log( iv_group = 'WRITE_LOG1/EMAIL' iv_level = 7 iv_type = 'S' iv_msg1 = 'Test Sucess level 7' ).
*    mo_log->write_log(  ). "Activate this line to check the output only

    "Test 2 display in text mode
*    mo_log->write_log( iv_grid = '' )."Activate this line to check the output only

    "Test 2 display in a popup
*    mo_log->write_log( iv_grid = 'X' iv_fullscreen = '' )."Activate this line to check the output only
  ENDMETHOD.

  METHOD save.
    DATA:
           lv_uuid TYPE sysuuid-c,
           lo_log TYPE REF TO z_cl_utf_log.

    mo_log->configure_group( iv_group = 'SAVE1' iv_level = 7 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_AT' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 0 iv_type = 'H' iv_msg1 = 'Test header level 0' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test info level 1' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 2 iv_type = 'W' iv_msg1 = 'Test warning level 2' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 3 iv_type = 'E' iv_msg1 = 'Test error level 3' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 4 iv_type = 'A' iv_msg1 = 'Test abend level 4' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 5 iv_type = '' iv_msg1 = 'Test blank level 5' ).
    mo_log->add_log( iv_group = 'SAVE1' iv_level = 6 iv_type = 'O' iv_msg1 = 'Test Sucess(OK) level 6' ).
    TRY.
        lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        lv_uuid = 0.
    ENDTRY.
    mo_log->configure_group( iv_group = 'SAVE2' iv_level = 7 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_CA' iv_al_extnumber = lv_uuid ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 0 iv_type = 'H' iv_msg1 = 'Test header level 0' ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 1 iv_type = 'I' iv_msg1 = 'Test info level 1' ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 2 iv_type = 'W' iv_msg1 = 'Test warning level 2' ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 3 iv_type = 'E' iv_msg1 = 'Test error level 3' ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 4 iv_type = 'A' iv_msg1 = 'Test abend level 4' ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 5 iv_type = '' iv_msg1 = 'Test blank level 5' ).
    mo_log->add_log( iv_group = 'SAVE2' iv_level = 6 iv_type = 'O' iv_msg1 = 'Test Sucess(OK) level 6' ).
    mo_log->save( ).
    COMMIT WORK AND WAIT.

    "Clear BAL messages from memory
    mo_log->refresh( ).

    CREATE OBJECT lo_log.
    lo_log->configure_group( iv_group = 'SAVE3' iv_level = 7 iv_display = 'X' iv_al_object = 'ZFI_INTERFACES' iv_al_subobject = 'ZFI_ROY_EARN_CA' iv_al_extnumber = lv_uuid ).
    lo_log->load( ).
    lo_log->add_log( iv_group = 'SAVE3' iv_level = 6 iv_type = 'O' iv_msg1 = 'Test Add a message after saving and loading' ).
*    lo_log->write_log(  ). "Activate this line to check the output only
    lo_log->save( ).
    COMMIT WORK AND WAIT.
  ENDMETHOD.

*  METHOD load.
*
*  ENDMETHOD.

  METHOD raise_log_message.
    DATA:
          lt_log TYPE zlog_log_table,
          ls_log TYPE zlog_log_tableline.

    "Test 1: Add a new message with submessage
    SET HANDLER mo_log->add_log.
    z_cl_utf_log=>raise_log_message( iv_group = 'SEND_LOG1' iv_level = 0 iv_type = 'E' iv_msg1 = '&3 &5 &2 &4' iv_msg2 = 'different' iv_msg3 = 'Test1 SEND_LOG' iv_msg4 = 'submessages' iv_msg5 = 'with').
    mo_log->get_log( EXPORTING iv_group = 'SEND_LOG1' IMPORTING et_log = lt_log ).
    cl_abap_unit_assert=>assert_not_initial( act = lt_log[] msg = 'Test 1: Message not logged' level = if_aunit_constants=>fatal ).
    READ TABLE lt_log INTO ls_log INDEX 1.
    cl_abap_unit_assert=>assert_equals( act = ls_log-message exp = 'Test1 SEND_LOG with different submessages' msg = 'Test 1: Message not properly logged' level = if_aunit_constants=>fatal ).
  ENDMETHOD.
ENDCLASS.