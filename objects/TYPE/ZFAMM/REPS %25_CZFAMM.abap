****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 07/10/2015 ! Align the FAM range used in the FAM object with the size of range in   *
*  DC-001    !            !  ZFAM_RULES_GROUP                                                      *
****************************************************************************************************
TYPE-POOL zfamm.

TYPES:
BEGIN OF zfamm_ts_feature_buffer.
        INCLUDE STRUCTURE zfam_feature.
TYPES:
    logged TYPE flag,
  END OF zfamm_ts_feature_buffer,
zfamm_tt_feature_buffer TYPE STANDARD TABLE OF zfamm_ts_feature_buffer WITH KEY feature_id,

*zfamm_tt_generic_range TYPE RANGE OF char10,"DC-001-
zfamm_tt_generic_range TYPE RANGE OF tvarv_low,"DC-001+
zfamm_ts_generic_range TYPE LINE OF zfamm_tt_generic_range,

 BEGIN OF zfamm_ts_2nd_level_buffer,
   feature_id TYPE zfam_feature_id,
   criterias_group TYPE zfam_criterias_group,
   criteria TYPE zfam_criteria,
   values TYPE zfamm_tt_generic_range,
 END OF zfamm_ts_2nd_level_buffer,

zfamm_tt_2nd_level_buffer TYPE STANDARD TABLE OF zfamm_ts_2nd_level_buffer WITH KEY feature_id criterias_group criteria,

 BEGIN OF zfamm_ts_rules_group_buffer,
   group_id TYPE zfam_criterias_group_id,
   criterias_group TYPE zfam_criterias_group,
   criteria TYPE zfam_criteria,
   values TYPE zfamm_tt_generic_range,
 END OF zfamm_ts_rules_group_buffer,

zfamm_tt_rules_groups_buffer TYPE STANDARD TABLE OF zfamm_ts_rules_group_buffer WITH KEY group_id criterias_group criteria,

BEGIN OF zfamm_ts_group_result,
  criterias_group TYPE zfam_criterias_group,
  group_result TYPE sysubrc,
END OF zfamm_ts_group_result,

zfamm_tt_groups_result TYPE STANDARD TABLE OF zfamm_ts_group_result WITH KEY criterias_group,

BEGIN OF zfamm_ts_result_buffer,
  feature_id TYPE zfam_feature_id,
  criteria1_name TYPE zfam_criteria,
  criteria1_value TYPE string,
  criteria2_name TYPE zfam_criteria,
  criteria2_value TYPE string,
  criteria3_name TYPE zfam_criteria,
  criteria3_value TYPE string,
  criteria4_name TYPE zfam_criteria,
  criteria4_value TYPE string,
  criteria5_name TYPE zfam_criteria,
  criteria5_value TYPE string,
  criteria1_result TYPE sysubrc,"For debug purpose
  criteria2_result TYPE sysubrc,"For debug purpose
  criteria3_result TYPE sysubrc,"For debug purpose
  criteria4_result TYPE sysubrc,"For debug purpose
  criteria5_result TYPE sysubrc,"For debug purpose
  criterias_result TYPE sysubrc,
END OF zfamm_ts_result_buffer,

zfamm_tt_result_buffer TYPE STANDARD TABLE OF zfamm_ts_result_buffer WITH KEY feature_id criteria1_name criteria1_value criteria2_name criteria2_value criteria3_name criteria3_value criteria4_name criteria4_value criteria5_name criteria5_value,

*Single param value buffer.
BEGIN OF zfamm_ts_param_result_buffer,
  feature_id TYPE zfam_feature_id,
  parameter_name TYPE zfam_parameter,
  criteria1_name TYPE zfam_criteria,
  criteria1_value TYPE string,
  criteria2_name TYPE zfam_criteria,
  criteria2_value TYPE string,
  criteria3_name TYPE zfam_criteria,
  criteria3_value TYPE string,
  criteria4_name TYPE zfam_criteria,
  criteria4_value TYPE string,
  criteria5_name TYPE zfam_criteria,
  criteria5_value TYPE string,
  parameter_value TYPE zfam_parameter_value,
  rc TYPE sysubrc,
END OF zfamm_ts_param_result_buffer,

zfamm_tt_param_result_buffer TYPE STANDARD TABLE OF zfamm_ts_param_result_buffer WITH KEY feature_id parameter_name criteria1_name criteria1_value criteria2_name criteria2_value criteria3_name criteria3_value criteria4_name criteria4_value
criteria5_name criteria5_value,

*Multiple values param buffer
BEGIN OF zfamm_ts_param_results_buffer,
  feature_id TYPE zfam_feature_id,
  parameter_name TYPE zfam_parameter,
  criteria1_name TYPE zfam_criteria,
  criteria1_value TYPE string,
  criteria2_name TYPE zfam_criteria,
  criteria2_value TYPE string,
  criteria3_name TYPE zfam_criteria,
  criteria3_value TYPE string,
  criteria4_name TYPE zfam_criteria,
  criteria4_value TYPE string,
  criteria5_name TYPE zfam_criteria,
  criteria5_value TYPE string,
  parameters_values TYPE zfam_T_parameter_results,
  rc TYPE sysubrc,
END OF zfamm_ts_param_results_buffer,

zfamm_tt_param_results_buffer TYPE STANDARD TABLE OF zfamm_ts_param_results_buffer WITH KEY feature_id parameter_name criteria1_name criteria1_value criteria2_name criteria2_value criteria3_name criteria3_value criteria4_name criteria4_value
criteria5_name criteria5_value,



*begin of zfamm_ts_parameter_value,
*  value type zfam_parameter_value,
*
*end of zfamm_ts_parameter_value,
*
*zfamm_tt_parameter_values type STANDARD TABLE OF zfamm_ts_parameter_value,

BEGIN OF zfamm_ts_parameter_buffer,
  feature_id TYPE zfam_feature_id,
  name TYPE zfam_parameter,
  rule_level TYPE zfam_level,
  value TYPE zfam_parameter_value,
  group_id TYPE zfam_criterias_group_id,
END OF zfamm_ts_parameter_buffer,

zfamm_tt_parameters_buffer TYPE STANDARD TABLE OF zfamm_ts_parameter_buffer.