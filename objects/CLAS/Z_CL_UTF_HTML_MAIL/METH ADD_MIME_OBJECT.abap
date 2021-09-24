  METHOD add_mime_object.
    " Get MIME-Repository Object
    cl_mime_repository_api=>get_api( )->get(
      EXPORTING
        i_url                  = |SAP/PUBLIC/BC/ABAP/{ iv_filename }|
        i_check_authority      = abap_true
      IMPORTING
        e_content              = DATA(lv_content)
        e_mime_type            = DATA(lv_mime_type)
      EXCEPTIONS
        parameter_missing      = 1
        error_occured          = 2
        not_found              = 3
        permission_failure     = 4
        OTHERS                 = 5 ).

    IF sy-subrc EQ 0 AND lv_content IS NOT INITIAL.
" split xstring into lt_solix table (which is need for email)
      DATA(lt_solix) = VALUE solix_tab( LET lv_total_length = xstrlen( lv_content ) lv_max_off = lv_total_length - 255 IN
                                        FOR lv_off = 0 THEN lv_off + 255  UNTIL lv_off GT lv_total_length
                                        ( line = COND #( WHEN lv_off LE lv_max_off
                                                         THEN lv_content+lv_off(255)
                                                         ELSE lv_content+lv_off ) ) ).
" Attach image to HTML body
      DATA(lv_obj_len) = xstrlen( lv_content ).

      co_mime_helper->add_binary_part( content      = lt_solix
                                       content_type = CONV #( lv_mime_type )
                                       length       = CONV #( lv_obj_len )
                                       content_id   = iv_filename ).

    ENDIF.
  ENDMETHOD.