  METHOD convert_table_to_xstring.

    FIELD-SYMBOLS: <table> TYPE ANY TABLE.
    DATA: struct_def TYPE REF TO cl_abap_structdescr,
          table_def  TYPE REF TO cl_abap_tabledescr,
          fldcats    TYPE STANDARD TABLE OF lvc_s_fcat.

    " Get structure definition
    ASSIGN iv_attachment_data_ref->* TO <table>.
    CHECK sy-subrc EQ 0.

    table_def ?= cl_abap_tabledescr=>describe_by_data( <table> ).
    struct_def   ?= table_def->get_table_line_type( ).


    " Build Field Catalog
    LOOP AT struct_def->get_components( ) REFERENCE INTO DATA(structure).

      APPEND VALUE #( no_out    = space
                      fieldname = structure->name
                      outputlen = 255
                      dd_outlen = 255
                      reptext   = structure->name
                      edit      = abap_true ) TO fldcats.
    ENDLOOP.


    DATA(result_data) = cl_salv_ex_util=>factory_result_data_table( r_data         = iv_attachment_data_ref
                                                                    t_fieldcatalog = fldcats  ).

    " Get the version from Abstract Super Class for All Transformations
    DATA(version) = cl_salv_bs_a_xml_base=>get_version( ).
    " Get the file Type
    DATA(file_type) = if_salv_bs_xml=>c_type_xlsx.
    " Get the flavour export
    DATA(flavour)  = if_salv_bs_c_tt=>c_tt_xml_flavour_export.

    " Transformation of data to XSTRING
    CALL METHOD cl_salv_bs_tt_util=>if_salv_bs_tt_util~transform
      EXPORTING
        xml_type      = file_type
        xml_version   = version
        r_result_data = result_data
        xml_flavour   = flavour
        gui_type      = if_salv_bs_xml=>c_gui_type_gui
      IMPORTING
        xml           = rv_xstring.
  ENDMETHOD.