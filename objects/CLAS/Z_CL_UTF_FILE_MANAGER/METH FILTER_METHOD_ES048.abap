  METHOD filter_method_es048.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 09/10/2019 ! GAP-3397: Add filter method for ES048 Trax interface                   *
****************************************************************************************************
    DATA:
      lv_fsnam  TYPE fsnam,
      lv_folder TYPE string,
      lr_file   TYPE REF TO zfile_s_file_attributes.

    "Get the folder
    lv_folder = get_folder( iv_subfolder ).

    LOOP AT ct_folder_files REFERENCE INTO lr_file.
      "remove the .DAT files
      IF lr_file->name CP '*.DAT'.
        CLEAR lr_file->name.
        CONTINUE.
      ENDIF.

      CONCATENATE lv_folder lr_file->name INTO lv_fsnam.

      "Check in the REGUT if the file is generated from a proposal run or not
      SELECT fsnam INTO lv_fsnam
             FROM  regut CLIENT SPECIFIED UP TO 1 ROWS
             WHERE  xvorl  = 'X'
             AND    fsnam  = lv_fsnam ORDER BY PRIMARY KEY.
      ENDSELECT.
      IF sy-subrc IS INITIAL.
        "it is a proposal run then don't send it for now.
        CLEAR lr_file->name.
      ENDIF.
    ENDLOOP.

    "remove all unexpected files
    DELETE ct_folder_files WHERE name IS INITIAL.

  ENDMETHOD.