*&---------------------------------------------------------------------*
*& Report ZUTF_FILE_HOUSEKEEPING
*&---------------------------------------------------------------------*
* Program       : ZUTF_FILE_HOUSEKEEPING
* Title         : Implement the file management
* Author        : Gopala Krishna Kanugolu / KANUGOG
* Date          : 05.12.2018
* GAP number    : 2192
* Sap Original  : n.r.
*------------------------------------------------------------------------------------------------*
* Description
* This program will provide a set of function to clean folders and
* check consistency of the configuration
*----------------------------------------------------------------------------------------------*
* Update functionality
*   none
*----------------------------------------------------------------------------------------------*
* Modification Protocol
* No.    Date        Author                               Transp.Requ.
*----------------------------------------------------------------------------------------------*
REPORT zutf_file_housekeeping.

*INCLUDE zbc_file_housekeeping_top.    " Global variables declaration
*INCLUDE zbc_file_housekeeping_e01.    " Selection screen Events
*INCLUDE zbc_file_housekeeping_f01.    " Subroutine definitions

*Global variables declaration
DATA:
  go_runtime    TYPE REF TO z_cl_utf_core_runtime,
  go_log        TYPE REF TO z_cl_utf_log,      ##NEEDED         " Instance/object for application log class
  gv_process_id TYPE zproc_process_id ##NEEDED.         " Process Id

CONSTANTS:
  gc_group TYPE string  VALUE 'FILE_HOUSEKEEPING',        " The application group to which the log should be assigned
  gc_x     TYPE char1   VALUE 'X'.

*Selection criterion block
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS:p_procid TYPE zproc_process_id OBLIGATORY DEFAULT 'FILE_HOUSEKEEPING',
             p_fldcln TYPE c RADIOBUTTON GROUP grp1 DEFAULT 'X' USER-COMMAND options,          " Folder cleaning radiobutton
             p_fldchk TYPE c RADIOBUTTON GROUP grp1,                      " Folder consistency check radiobutton
             p_report TYPE c RADIOBUTTON GROUP grp1, "Folder report
             p_root   TYPE zfile_root_folder DEFAULT '/PUMGI/' MODIF ID rpt. "Root folder to analyze for the report
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  SELECT-OPTIONS:s_prcid FOR gv_process_id NO INTERVALS MODIF ID pid.  " Process ID
SELECTION-SCREEN END OF BLOCK b02.

AT SELECTION-SCREEN OUTPUT.
  PERFORM dynamic_screen.

****************************************************************************************************
START-OF-SELECTION.
****************************************************************************************************
  go_log = NEW #( ).             " Create instance/object for application log class
  go_log->set_log_level( 5 ).    " Set maximum level as 5
  SET HANDLER go_log->add_log.   " Set handler for raise success/warning/error messages in application log

*Initialize the runtime framework
  go_runtime = NEW #( iv_process_id = p_procid iv_manage_log = abap_false ).

  IF p_report = abap_true.
    PERFORM generate_folders_report.
  ELSE.
    PERFORM process_filehsekeeping.
  ENDIF.
****************************************************************************************************
END-OF-SELECTION.
****************************************************************************************************
  "Close runtime processing
  go_runtime->update_status( zrunt_c_status_completed ).

***Display application log in ALV format and save the log in application server.
  go_log->dispatch_log( ).

*&---------------------------------------------------------------------*
*&      Form  PROCESS_FILEHSEKEEPING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_filehsekeeping .
  "Load the file manager configuration
  SELECT *
   FROM zfile_manager
   INTO TABLE @DATA(lt_file_manager)
   WHERE process_id IN @s_prcid
   ORDER BY PRIMARY KEY.
  IF NOT lt_file_manager IS INITIAL.
    z_cl_utf_log=>raise_log_message( iv_group = gc_group iv_level = 0 iv_type = 'I' iv_msg1 = '&2 Entries loaded from table &3.'(i03) iv_msg2 = sy-dbcnt
                                   iv_msg3 = 'ZFILE_MANAGER'(i02) ).

    LOOP AT lt_file_manager INTO DATA(ls_file_manager).
      DATA(lo_file_manager) = z_cl_utf_file_manager=>factory( ls_file_manager-process_id ).
      CASE gc_x.
        WHEN p_fldcln.
          lo_file_manager->folders_cleaning( ).
        WHEN p_fldchk.
          lo_file_manager->folders_check( ).
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

  ELSE.
    z_cl_utf_log=>raise_log_message( iv_group = gc_group iv_level = 0 iv_type = 'E' iv_msg1 = 'No entries loaded from table &2.'(i01)
                                    iv_msg2 = 'ZFILE_MANAGER'(i02) ).
    RETURN.
  ENDIF.
ENDFORM.

FORM generate_folders_report.
  DATA:
    lo_alv_table      TYPE REF TO z_cl_umg_salv_table,
    lo_columns        TYPE REF TO cl_salv_columns_list,

    lt_folders_report TYPE zfile_t_folder_report.

  lt_folders_report = z_cl_utf_file_manager=>get_folders_report( CONV #( p_root ) ).

  CREATE OBJECT lo_alv_table
    EXPORTING
      iv_report = sy-repid.

  lo_alv_table->initialize_alv( EXPORTING iv_rep_heading = 'Folder Report'(h01) CHANGING ct_table = lt_folders_report ).

  lo_alv_table->change_heading( iv_columnname = 'FOLDER_SIZE' iv_column_desc_l = 'Folder Size'(001) iv_column_desc_m = 'Folder Size'(001) iv_column_desc_s = 'Size'(006) ).
  lo_alv_table->change_heading( iv_columnname = 'FOLDER_FULL_SIZE' iv_column_desc_l = 'Folder + Children'(002) iv_column_desc_m = 'Folder + Children'(002) iv_column_desc_s = 'Fold+Child'(007) ).
  lo_alv_table->change_heading( iv_columnname = 'RECENT_FILE' iv_column_desc_l = 'Most Recent file'(003) iv_column_desc_m = 'Most Recent file'(003) iv_column_desc_s = 'Newest'(008) ).
  lo_alv_table->change_heading( iv_columnname = 'OLDEST_FILE' iv_column_desc_l = 'Oldest file'(004) iv_column_desc_m = 'Oldest file'(004) iv_column_desc_s = 'Oldest'(009) ).
  lo_alv_table->change_heading( iv_columnname = 'BIGGEST_FILE' iv_column_desc_l = 'Biggest file'(005) iv_column_desc_m = 'Biggest file'(005) iv_column_desc_s = 'Biggest'(010) ).

  lo_columns = lo_alv_table->mo_alv_table->get_columns( ).
  lo_columns->set_optimize( abap_true ).



  lo_alv_table->display_alv( 2 ).
ENDFORM.

FORM dynamic_screen.
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'RPT'.
        IF p_report IS INITIAL.
          screen-invisible  = 1.
          screen-input      = 0.
          screen-required   = 0.
          MODIFY SCREEN.
        ENDIF.
      WHEN 'PID'.
        IF p_report IS NOT INITIAL.
          screen-invisible  = 1.
          screen-input      = 0.
          screen-required   = 0.
          MODIFY SCREEN.
        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.