  METHOD convert_logical_2_physical.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 09/10/2019 ! GAP-3417: add management of logical path in ZFILE_MANAGER table        *
****************************************************************************************************
    DATA:
      lv_logical_path    TYPE pathintern,
      lv_parameter1      TYPE string,
      lv_parameter2      TYPE string,
      lv_parameter3      TYPE string,
      lv_filename        TYPE string,
      lv_physical_folder TYPE string.

*    CLEAR ev_physical_folder.
    CLEAR: lv_logical_path,lv_parameter1,lv_parameter2,lv_parameter3,lv_filename.
    lv_filename = '/'."Specify an empty filename
    IF iv_logical_folder CS ';'.
      SPLIT iv_logical_folder AT ';' INTO lv_logical_path lv_parameter1 lv_parameter2 lv_parameter3.
    ELSE.
      lv_logical_path = iv_logical_folder.
    ENDIF.

    CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
      EXPORTING
*       client                     = SY-MANDT         " Client for reading the file name table
        logical_path               = lv_logical_path  " Logical path
*       operating_system           = SY-OPSYS         " Operating system
        parameter_1                = lv_parameter1    " Parameter for variable <PARAM_1>
        parameter_2                = lv_parameter2    " Parameter for variable <PARAM_2>
        parameter_3                = lv_parameter3    " Parameter for variable <PARAM_3>
*       use_buffer                 = space            " Buffering flag
        file_name                  = lv_filename      " File name
*       use_presentation_server    = space            " Use SAPtemu operating system
*       eleminate_blanks           = 'X'              " Eliminate blank characters = 'X'
      IMPORTING
        file_name_with_path        = lv_physical_folder " File name with path
      EXCEPTIONS
        path_not_found             = 1                " Logical path unknown
        missing_parameter          = 2                " Parameter not passed
        operating_system_not_found = 3                " Operating system unknown
        file_system_not_found      = 4                " File system unknown
        OTHERS                     = 5.
    IF sy-subrc <> 0.
      "TODO improve error handling management, raise an exception.
      RAISE EVENT send_log EXPORTING iv_group = 'FILE_MANAGER_LOGICAL' iv_level = 1 iv_type = 'E' iv_msg1 = 'Cannot Convert &3'(e03) iv_msg2 = iv_logical_folder.
      RAISE EVENT send_log EXPORTING iv_group = 'FILE_MANAGER_LOGICAL' iv_level = 1 iv_type = sy-msgty iv_msgno = sy-msgno iv_msgid = sy-msgid iv_msg1 = sy-msgv1 iv_msg2 = sy-msgv2 iv_msg3 = sy-msgv3 iv_msg4 = sy-msgv4.
    ELSE.
      REPLACE '//' WITH '/' INTO lv_physical_folder.
      RAISE EVENT send_log EXPORTING iv_group = 'FILE_MANAGER_LOGICAL' iv_level = 1 iv_type = 'I' iv_msg1 = 'Convert &2 to &3'(i01) iv_msg2 = iv_logical_folder iv_msg3 = lv_physical_folder.
      ev_physical_folder = lv_physical_folder.
    ENDIF.
  ENDMETHOD.