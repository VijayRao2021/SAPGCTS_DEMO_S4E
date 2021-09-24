  METHOD get_full_path.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 14/11/2018 ! GAP-2974: Integrate the folder constant coming from File Manager       *
* GAP-2974   !            ! Framework                                                              *
****************************************************************************************************
*-Begin of GAP-2974+
    "Define the target folder where to copy the file
    IF 'ROOT/ARCHIVE/PROGRESS/ERROR' CS iv_folder AND mo_file_manager IS BOUND.
      rv_full_path = mo_file_manager->get_folder( iv_folder ).
    ELSE.
*-End of GAP-2974+
      IF iv_folder IS INITIAL.
        rv_full_path = mv_current_folder.
      ELSE.
        IF iv_folder(1) <> '/'.
          CONCATENATE mv_root_folder '/' iv_folder INTO rv_full_path.
        ELSE.
          rv_full_path = iv_folder.
        ENDIF.
      ENDIF.
    ENDIF.                                                  "GAP-2974+
  ENDMETHOD.