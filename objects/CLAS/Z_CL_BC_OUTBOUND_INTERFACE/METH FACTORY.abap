  METHOD factory.
****************************************************************************************************
*                                      MODIFICATIONS HISTORIC                                      *
*------------+------------+------------------------------------------------------------------------*
*   Author   !    Date    !                             Modification                               *
*------------+------------+------------------------------------------------------------------------*
* D. CRESSON ! 11/10/2019 ! GAP-3397: Introduce a factory method to the class                      *
****************************************************************************************************
    TYPES:
      BEGIN OF lts_delta_manager_instance,
        interface_id  TYPE zinterface_id,
        variant_name  TYPE raldb_vari,
        mestyp        TYPE edi_mestyp,
        mescod        TYPE edi_mescod,
        mesfct        TYPE edi_mesfct,
        delta_manager TYPE REF TO z_cl_bc_outbound_interface,
      END OF lts_delta_manager_instance,

      ltt_delta_manager_instances TYPE STANDARD TABLE OF lts_delta_manager_instance.

    STATICS: ss_delta_manager  TYPE lts_delta_manager_instance,
             st_delta_managers TYPE ltt_delta_manager_instances.

    IF ss_delta_manager-interface_id <> iv_interface_id OR
       ss_delta_manager-variant_name <> iv_variant_name OR
       ss_delta_manager-mestyp <> iv_mestyp OR
       ss_delta_manager-mescod <> iv_mescod OR
       ss_delta_manager-mesfct <> iv_mesfct.
      READ TABLE st_delta_managers INTO ss_delta_manager WITH KEY interface_id = iv_interface_id
                                                                  variant_name = iv_variant_name
                                                                  mestyp = iv_mestyp
                                                                  mescod = iv_mescod
                                                                  mesfct = iv_mesfct.
      IF sy-subrc <> 0.
        CLEAR ss_delta_manager.
        ss_delta_manager-delta_manager = NEW #( iv_interface_id = iv_interface_id iv_variant_name = iv_variant_name iv_mestyp = iv_mestyp
                                                iv_mescod = iv_mescod iv_mesfct = iv_mesfct iv_catchup_mode = iv_catchup_mode
                                                iv_test_mode = iv_test_mode iv_mode = iv_mode iv_date_from = iv_date_from
                                                iv_time_from = iv_time_from iv_date_to = iv_date_to iv_time_to = iv_time_to ).
        IF ss_delta_manager-delta_manager IS BOUND.
          ss_delta_manager-interface_id = iv_interface_id.
          ss_delta_manager-variant_name = iv_variant_name.
          ss_delta_manager-mestyp = iv_mestyp.
          ss_delta_manager-mescod = iv_mescod.
          ss_delta_manager-mesfct = iv_mesfct.
          APPEND ss_delta_manager TO st_delta_managers.
        ENDIF.
      ENDIF.
    ENDIF.
    ro_delta_manager = ss_delta_manager-delta_manager.
  ENDMETHOD.