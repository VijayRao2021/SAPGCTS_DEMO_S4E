*"* use this source file for your ABAP unit test classes

CLASS lcl_bc_t_feature_management DEFINITION FOR TESTING FINAL
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?﻿<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>lcl_Bc_T_Feature_Management
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>Z_CL_BC_FEATURE_MANAGEMENT
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE/>
*?<GENERATE_CLASS_FIXTURE/>
*?<GENERATE_INVOCATION/>
*?<GENERATE_ASSERT_EQUAL/>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: get_parameter_value FOR TESTING.
    METHODS: get_parameter_values FOR TESTING.
    METHODS: is_active FOR TESTING.
ENDCLASS.       "lcl_Bc_T_Feature_Management


CLASS lcl_bc_t_feature_management IMPLEMENTATION.

  METHOD class_setup."Define the test data in the configuration tables
    DATA:
          ls_feature TYPE zfam_feature,
          ls_parameter TYPE zfam_parameters,
          ls_rules_group TYPE zfam_rules_group.

    "Clear the previous tests
    DELETE FROM zfam_feature WHERE feature_id LIKE 'TEST%'.
    DELETE FROM zfam_parameters WHERE feature_id LIKE 'TEST%'.
    DELETE FROM zfam_rules_group WHERE group_id LIKE 'TEST%'.
    COMMIT WORK.

    "Create the test cases in the tables
    "Test1: Non Activated feature
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST1'.
    ls_feature-text = 'TEST FEATURE 1'.
    ls_feature-activated = space.
    MODIFY zfam_feature FROM ls_feature.

    CLEAR ls_parameter.
    ls_parameter-feature_id = 'TEST1'.
    ls_parameter-parameter_name = 'TEST1_GLOBAL'.
    ls_parameter-item = '01'.
    ls_parameter-parameter_value = 'GLOBAL'.
    ls_parameter-rule_level = '01'.
    ls_parameter-group_id = space.
    MODIFY zfam_parameters FROM ls_parameter.

    "Test2: Activated feature with no rule and a global parameter
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST2'.
    ls_feature-text = 'TEST FEATURE 2'.
    ls_feature-activated = 'X'.
    MODIFY zfam_feature FROM ls_feature.

    CLEAR ls_parameter.
    ls_parameter-feature_id = 'TEST2'.
    ls_parameter-parameter_name = 'TEST2_GLOBAL'.
    ls_parameter-item = '01'.
    ls_parameter-parameter_value = 'GLOBAL'.
    ls_parameter-rule_level = '01'.
    ls_parameter-group_id = space.
    MODIFY zfam_parameters FROM ls_parameter.

    "Test3: Activated feature with a rule with a OR operator and a parameter with a global value and a value with a rule
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST3'.
    ls_feature-text = 'TEST FEATURE 3'.
    ls_feature-activated = 'X'.
    ls_feature-group_id = 'TEST3_ACTIVATION'.
    MODIFY zfam_feature FROM ls_feature.

    "Create a rules group to define in detail when it is activated
    "for FR02 and IT01 CC or for US and IT countries
    CLEAR ls_rules_group.
    ls_rules_group-group_id = 'TEST3_ACTIVATION'.
    ls_rules_group-criterias_group = '01'.
    ls_rules_group-criteria = 'BUKRS'.
    ls_rules_group-item = '01'.
    ls_rules_group-sign = 'I'.
    ls_rules_group-opti = 'EQ'.
    ls_rules_group-low = 'FR02'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-item = '02'.
    ls_rules_group-low = 'IT01'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criteria = 'COUNTRY'.
    ls_rules_group-item = '01'.
    ls_rules_group-low = 'US'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-item = '02'.
    ls_rules_group-low = 'IT'.
    MODIFY zfam_rules_group FROM ls_rules_group.

    "Create a default value
    CLEAR ls_parameter.
    ls_parameter-feature_id = 'TEST3'.
    ls_parameter-parameter_name = 'TEST3_PARAM'.
    ls_parameter-item = '01'.
    ls_parameter-parameter_value = 'DEFAULT'.
    ls_parameter-rule_level = '01'.
    ls_parameter-group_id = space.
    MODIFY zfam_parameters FROM ls_parameter.
    "Create a value based on rules
    ls_parameter-item = '02'.
    ls_parameter-parameter_value = 'RULE'.
    ls_parameter-rule_level = '02'.
    ls_parameter-group_id = 'TEST3_ACTIVATION'.
    MODIFY zfam_parameters FROM ls_parameter.

    "Test4: Activation rule with AND operator
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST4'.
    ls_feature-text = 'TEST FEATURE 4'.
    ls_feature-activated = 'X'.
    ls_feature-group_id = 'TEST4_ACTIVATION'.
    MODIFY zfam_feature FROM ls_feature.

    CLEAR ls_rules_group.
    ls_rules_group-group_id = 'TEST4_ACTIVATION'.
    ls_rules_group-criterias_group = '01'.
    ls_rules_group-criteria = 'COUNTRY'.
    ls_rules_group-item = '01'.
    ls_rules_group-sign = 'I'.
    ls_rules_group-opti = 'EQ'.
    ls_rules_group-low = 'IT'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criterias_group = '02'.
    ls_rules_group-criteria = 'BUKRS'.
    ls_rules_group-low = 'IT01'.
    MODIFY zfam_rules_group FROM ls_rules_group.

    "Test5: Activated feature with a wrong rule ID
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST5'.
    ls_feature-text = 'TEST FEATURE 5'.
    ls_feature-activated = 'X'.
    ls_feature-group_id = 'TEST5_WRONG'.
    MODIFY zfam_feature FROM ls_feature.

    "Test6: Activated feature with 5 criterias
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST6'.
    ls_feature-text = 'TEST FEATURE 6'.
    ls_feature-activated = 'X'.
    ls_feature-group_id = 'TEST6_ACTIVATION'.
    MODIFY zfam_feature FROM ls_feature.

    CLEAR ls_rules_group.
    ls_rules_group-group_id = 'TEST6_ACTIVATION'.
    ls_rules_group-criterias_group = '01'.
    ls_rules_group-criteria = 'COUNTRY'.
    ls_rules_group-item = '01'.
    ls_rules_group-sign = 'I'.
    ls_rules_group-opti = 'EQ'.
    ls_rules_group-low = 'IT'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criterias_group = '02'.
    ls_rules_group-criteria = 'BUKRS'.
    ls_rules_group-low = 'IT01'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criterias_group = '03'.
    ls_rules_group-criteria = 'PRCTR'.
    ls_rules_group-low = 'IT01000001'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criterias_group = '04'.
    ls_rules_group-criteria = 'KTOKD'.
    ls_rules_group-low = 'ITC1'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criterias_group = '05'.
    ls_rules_group-criteria = 'BRSCH'.
    ls_rules_group-low = 'ZP3'.
    MODIFY zfam_rules_group FROM ls_rules_group.

    "Test7: Activated feature with a rule with a OR operator and a parameter with a global value and a multiple values with same rule
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST7'.
    ls_feature-text = 'TEST FEATURE 7'.
    ls_feature-activated = 'X'.
    ls_feature-group_id = 'TEST7_ACTIVATION'.
    MODIFY zfam_feature FROM ls_feature.

    "Create a rules group to define in detail when it is activated
    "for FR02 and IT01 CC or for US and IT countries
    CLEAR ls_rules_group.
    ls_rules_group-group_id = 'TEST7_ACTIVATION'.
    ls_rules_group-criterias_group = '01'.
    ls_rules_group-criteria = 'BUKRS'.
    ls_rules_group-item = '01'.
    ls_rules_group-sign = 'I'.
    ls_rules_group-opti = 'EQ'.
    ls_rules_group-low = 'FR02'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-item = '02'.
    ls_rules_group-low = 'IT01'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criteria = 'COUNTRY'.
    ls_rules_group-item = '01'.
    ls_rules_group-low = 'US'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-item = '02'.
    ls_rules_group-low = 'IT'.
    MODIFY zfam_rules_group FROM ls_rules_group.

    "Create a default value
    CLEAR ls_parameter.
    ls_parameter-feature_id = 'TEST7'.
    ls_parameter-parameter_name = 'TEST7_PARAM'.
    ls_parameter-item = '01'.
    ls_parameter-parameter_value = 'DEFAULT'.
    ls_parameter-rule_level = '01'.
    ls_parameter-group_id = space.
    MODIFY zfam_parameters FROM ls_parameter.
    "Create multiple values based on rules
    ls_parameter-item = '02'.
    ls_parameter-parameter_value = 'VALUE1'.
    ls_parameter-rule_level = '02'.
    ls_parameter-group_id = 'TEST7_ACTIVATION'.
    MODIFY zfam_parameters FROM ls_parameter.
    ls_parameter-item = '03'.
    ls_parameter-parameter_value = 'VALUE2'.
    MODIFY zfam_parameters FROM ls_parameter.
    ls_parameter-item = '04'.
    ls_parameter-parameter_value = 'VALUE3'.
    MODIFY zfam_parameters FROM ls_parameter.

    "Test8: Activated feature with a rule with a OR operator and multiple parameters multiple values with same rule
    CLEAR ls_feature.
    ls_feature-feature_id = 'TEST8'.
    ls_feature-text = 'TEST FEATURE 8'.
    ls_feature-activated = 'X'.
    ls_feature-group_id = 'TEST8_ACTIVATION'.
    MODIFY zfam_feature FROM ls_feature.

    "Create a rules group to define in detail when it is activated
    "for FR02 and IT01 CC or for US and IT countries
    CLEAR ls_rules_group.
    ls_rules_group-group_id = 'TEST8_ACTIVATION'.
    ls_rules_group-criterias_group = '01'.
    ls_rules_group-criteria = 'BUKRS'.
    ls_rules_group-item = '01'.
    ls_rules_group-sign = 'I'.
    ls_rules_group-opti = 'EQ'.
    ls_rules_group-low = 'FR02'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-item = '02'.
    ls_rules_group-low = 'IT01'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-criteria = 'COUNTRY'.
    ls_rules_group-item = '01'.
    ls_rules_group-low = 'US'.
    MODIFY zfam_rules_group FROM ls_rules_group.
    ls_rules_group-item = '02'.
    ls_rules_group-low = 'IT'.
    MODIFY zfam_rules_group FROM ls_rules_group.

    "Create first parameter
    CLEAR ls_parameter.
    ls_parameter-feature_id = 'TEST8'.
    ls_parameter-parameter_name = 'TEST8_PARAM1'.
    ls_parameter-item = '01'.
    ls_parameter-parameter_value = 'VALUE1'.
    ls_parameter-rule_level = '01'.
    ls_parameter-group_id = space.
    MODIFY zfam_parameters FROM ls_parameter.
    ls_parameter-item = '02'.
    ls_parameter-parameter_value = 'VALUE2'.
    MODIFY zfam_parameters FROM ls_parameter.

    "Create second parameter with multiple values
    ls_parameter-parameter_name = 'TEST8_PARAM2'.
    ls_parameter-item = '01'.
    ls_parameter-parameter_value = 'VALUE1'.
    MODIFY zfam_parameters FROM ls_parameter.
    ls_parameter-item = '02'.
    ls_parameter-parameter_value = 'VALUE2'.
    MODIFY zfam_parameters FROM ls_parameter.
    ls_parameter-item = '03'.
    ls_parameter-parameter_value = 'VALUE3'.
    MODIFY zfam_parameters FROM ls_parameter.

    COMMIT WORK AND WAIT.
  ENDMETHOD.

  METHOD class_teardown.
    COMMIT WORK."to update the log table.
  ENDMETHOD.

  METHOD get_parameter_value.
    DATA:
          lv_subrc TYPE sysubrc,
          lv_value TYPE zfam_parameter_value.

*Test 1: feature not active
    z_cl_utf_feature_management=>get_parameter_value( EXPORTING iv_feature_id = 'TEST1' iv_parameter_name = 'TEST1_GLOBAL' IMPORTING ev_value = lv_value ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST1.1: feature not active so should return RC=8' ).
    cl_abap_unit_assert=>assert_initial( act = lv_value msg = 'TEST1.1: feature not active so value should be empty' ).

*Test 2: feature active but without 2nd level of activation criteria Parameter is global only
    z_cl_utf_feature_management=>get_parameter_value( EXPORTING iv_feature_id = 'TEST2' iv_parameter_name = 'TEST2_GLOBAL' IMPORTING ev_value = lv_value ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST2.1: parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_equals( exp = 'GLOBAL' act = lv_value msg = 'TEST2.1: parameter value should be ''GLOBAL''' ).
    "Test the immediate buffer
    z_cl_utf_feature_management=>get_parameter_value( EXPORTING iv_feature_id = 'TEST2' iv_parameter_name = 'TEST2_GLOBAL' IMPORTING ev_value = lv_value ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST2.2: parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_equals( exp = 'GLOBAL' act = lv_value msg = 'TEST2.2: parameter value should be ''GLOBAL''' ).

*Test 3: Parameter has rule group
    z_cl_utf_feature_management=>get_parameter_value( EXPORTING iv_feature_id = 'TEST3' iv_parameter_name = 'TEST3_PARAM' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING ev_value = lv_value ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.1: US is in the rule so parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_equals( exp = 'RULE' act = lv_value msg = 'TEST3.1: parameter value should be ''RULE''' ).
    "Test with a wrong parameter
    z_cl_utf_feature_management=>get_parameter_value( EXPORTING iv_feature_id = 'TEST3' iv_parameter_name = 'TEST3_WRONG' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING ev_value = lv_value ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 99 act = lv_subrc msg = 'TEST3.2: Parameter doesn''t exist so should return RC=99' ).
    cl_abap_unit_assert=>assert_initial( act = lv_value msg = 'TEST3.2: Parameter doesn''t exist so value should be empty' ).
    "Test the table buffer
    z_cl_utf_feature_management=>get_parameter_value( EXPORTING iv_feature_id = 'TEST3' iv_parameter_name = 'TEST3_PARAM' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                 IMPORTING ev_value = lv_value ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.3: US is in the rule so parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_equals( exp = 'RULE' act = lv_value msg = 'TEST3.3: parameter value should be ''RULE''' ).

  ENDMETHOD.

  METHOD get_parameter_values.
    DATA:
          lv_subrc TYPE sysubrc,
          ls_parameter_result TYPE zfam_s_parameter_result,
          lt_parameter_results TYPE zfam_t_parameter_results.

**Test 1: feature not active
*    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST1' iv_parameter_name = 'TEST1_GLOBAL' IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
*    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST1.1: feature not active so should return RC=8' ).
*    cl_abap_unit_assert=>assert_initial( act = lt_parameter_results msg = 'TEST1.1: feature not active so value should be empty' ).

*Test 2: feature active but without 2nd level of activation criteria Parameter is global only
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST2' iv_parameter_name = 'TEST2_GLOBAL' IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST2.1: parameter can be retrieved so RC=0' ).
    CLEAR ls_parameter_result.
    REFRESH ls_parameter_result-parameter_values.
    ls_parameter_result-parameter_name = 'TEST2_GLOBAL'.
    APPEND 'GLOBAL' TO ls_parameter_result-parameter_values.
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST2.1: parameter value should be ''GLOBAL''').
    "Test the immediate buffer
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST2' iv_parameter_name = 'TEST2_GLOBAL' IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST2.2: parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST2.1: parameter value should be ''GLOBAL''').

*Test 3: Parameter has rule group
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST3' iv_parameter_name = 'TEST3_PARAM' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.1: US is in the rule so parameter can be retrieved so RC=0' ).
    CLEAR ls_parameter_result.
    REFRESH ls_parameter_result-parameter_values.
    ls_parameter_result-parameter_name = 'TEST3_PARAM'.
    APPEND 'RULE' TO ls_parameter_result-parameter_values.
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST3.1: parameter value should be ''RULE''').
    "Test with a wrong parameter
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST3' iv_parameter_name = 'TEST3_WRONG' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 99 act = lv_subrc msg = 'TEST3.2: Parameter doesn''t exist so should return RC=99' ).
    cl_abap_unit_assert=>assert_initial( act = lt_parameter_results msg = 'TEST3.2: Parameter doesn''t exist so result should be empty' ).
    "Test the table buffer
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST3' iv_parameter_name = 'TEST3_PARAM' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                 IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.3: US is in the rule so parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST3.1: parameter value should be ''RULE''').

*Test 7: Parameter has rule group and multiple values to retrieve
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST7' iv_parameter_name = 'TEST7_PARAM' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST7.1: US is in the rule so parameter can be retrieved so RC=0' ).
    CLEAR ls_parameter_result.
    REFRESH ls_parameter_result-parameter_values.
    ls_parameter_result-parameter_name = 'TEST7_PARAM'.
    APPEND 'VALUE1' TO ls_parameter_result-parameter_values.
    APPEND 'VALUE2' TO ls_parameter_result-parameter_values.
    APPEND 'VALUE3' TO ls_parameter_result-parameter_values.
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST7.2: parameter value should be ''VALUE1, VALUE2 VALUE3''').

    "Test 7.2 Send same request without providing the parameter name Expect same result
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST7' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST7.2: US is in the rule so parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST7.2: parameter value should be ''VALUE1, VALUE2 VALUE3''').

*Test 8: Multiple Parameter retrieving with multiple values to retrieve
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST8' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST8.1: US is in the rule so parameter can be retrieved so RC=0' ).
    CLEAR ls_parameter_result.
    REFRESH ls_parameter_result-parameter_values.
    ls_parameter_result-parameter_name = 'TEST8_PARAM1'.
    APPEND 'VALUE1' TO ls_parameter_result-parameter_values.
    APPEND 'VALUE2' TO ls_parameter_result-parameter_values.
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST8.1: parameter value should be ''VALUE1, VALUE2''').
    CLEAR ls_parameter_result.
    REFRESH ls_parameter_result-parameter_values.
    ls_parameter_result-parameter_name = 'TEST8_PARAM2'.
    APPEND 'VALUE1' TO ls_parameter_result-parameter_values.
    APPEND 'VALUE2' TO ls_parameter_result-parameter_values.
    APPEND 'VALUE3' TO ls_parameter_result-parameter_values.
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST8.1: parameter value should be ''VALUE1, VALUE2 VALUE3''').

    "Test 8.2 retrieve only the second parameter
    z_cl_utf_feature_management=>get_parameter_values( EXPORTING iv_feature_id = 'TEST8' iv_parameter_name = 'TEST8_PARAM2' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A'
                                                     IMPORTING et_results = lt_parameter_results ev_subrc = lv_subrc ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST8.2: US is in the rule so parameter can be retrieved so RC=0' ).
    cl_abap_unit_assert=>assert_table_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST8.2: parameter value should be ''VALUE1, VALUE2 VALUE3''').
    CLEAR ls_parameter_result.
    REFRESH ls_parameter_result-parameter_values.
    ls_parameter_result-parameter_name = 'TEST8_PARAM1'.
    APPEND 'VALUE1' TO ls_parameter_result-parameter_values.
    APPEND 'VALUE2' TO ls_parameter_result-parameter_values.
    cl_abap_unit_assert=>assert_table_not_contains( line = ls_parameter_result table = lt_parameter_results msg = 'TEST8.2: parameter TEST8_PARAM1 should not be there').
  ENDMETHOD.

  METHOD is_active.
    DATA:
          lv_subrc TYPE sysubrc.

*Test 0: feature does not exist
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST0' ).
    cl_abap_unit_assert=>assert_subrc( exp = 99 act = lv_subrc msg = 'TEST0: feature doesn''t exist so should return RC=99' ).

*Test 1: feature not active
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST1' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST1.1: feature not active so should return RC=8' ).

    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST1' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST1.2: feature not active so should return RC=8' ).

*Test 2: feature active but without 2nd level of activation criteria
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST2' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST2: feature active so should return RC=0' ).

*test 3: Feature active with 2nd level of activation criteria
    "test 3.1 test at high level
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.1: feature active so should return RC=0' ).

    "test 3.2 test with an active country
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.2: US is active so should return RC=0' ).
    "test 3.2 bis, test immediate buffer
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'US1A' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.2: US is active so should return RC=0' ).

    "test 3.3 test with an active CC
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'FR' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'FR02' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.3: FR02 is active so should return RC=0' ).

    "test 3.4 test with an active country and CC
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'IT01' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.4: IT and IT01 are active so should return RC=0' ).

    "test 3.5 test with an active country
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'DE' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'DE05' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST3.5: DE and DE05 are inactive so should return RC=8' ).

    "test 3.4bis  test long term buffer with success result
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'IT01' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST3.4: IT and IT01 are active so should return RC=0' ).

    "test 3.5bis test long term buffer with failed result
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'DE' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'DE05' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST3.5: DE and DE05 are inactive so should return RC=8' ).

    "Test 3.5 test with not defined criteria in the rules group
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST3' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' iv_criteria2_name = 'BLABLA' iv_criteria2_value = 'BLABLA' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST3.5: BLABLA criteria is not defined so should return RC=8' ).

*test4: Feature active with two groups of criteria
    "test 4.1 test with one group success
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST4' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST4.1: IT is active so should return RC=0' ).

    "test 4.2 test with one group fail
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST4' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'US' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST4.2: US is not active so should return RC=8' ).

    "test 4.3 test with two groups success
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST4' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'IT01' ).
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST4.3: IT  and IT01 are active so should return RC=0' ).

    "test 4.3 test with two groups one success one fail
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST4' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'IT02' ).
    cl_abap_unit_assert=>assert_subrc( exp = 8 act = lv_subrc msg = 'TEST4.4: IT  is active but not IT02 so should return RC=8' ).

*Test5: feature with a wrong rule ID
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST5' ).
    cl_abap_unit_assert=>assert_subrc( exp = 99 act = lv_subrc msg = 'TEST5: Wrong rule ID so should return RC=99' ).

*Test 6: test acivation with 5 criterias
    lv_subrc = z_cl_utf_feature_management=>is_active( iv_feature_id = 'TEST6' iv_criteria1_name = 'COUNTRY' iv_criteria1_value = 'IT' iv_criteria2_name = 'BUKRS' iv_criteria2_value = 'IT01'
                                                      iv_criteria3_name = 'PRCTR' iv_criteria3_value = 'IT01000001' iv_criteria4_name = 'KTOKD' iv_criteria4_value = 'ITC1' iv_criteria5_name = 'BRSCH' iv_criteria5_value = 'ZP3').
    cl_abap_unit_assert=>assert_subrc( exp = 0 act = lv_subrc msg = 'TEST6.1: all is active so should return RC=0' ).

  ENDMETHOD.

ENDCLASS.