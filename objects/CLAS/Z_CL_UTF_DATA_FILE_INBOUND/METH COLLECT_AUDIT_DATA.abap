  METHOD collect_audit_data.
    CASE  iv_type.
      WHEN 'RECEIVED'.
        ms_received_audit_data-unique_id = is_audit_data-unique_id.
        ms_received_audit_data-interface_id = is_audit_data-interface_id.
        ADD is_audit_data-documents_counter TO ms_received_audit_data-documents_counter.
        ADD is_audit_data-total_debit TO ms_received_audit_data-total_debit.
        ADD is_audit_data-total_credit TO ms_received_audit_data-total_credit.
        ADD is_audit_data-quantity TO ms_received_audit_data-quantity.
      WHEN 'CALCULATED'.
        ms_calculated_audit_data-unique_id = ms_received_audit_data-unique_id.
        ms_calculated_audit_data-interface_id = ms_received_audit_data-interface_id.
        ADD is_audit_data-documents_counter TO ms_calculated_audit_data-documents_counter.
        ADD is_audit_data-total_debit TO ms_calculated_audit_data-total_debit.
        ADD is_audit_data-total_credit TO ms_calculated_audit_data-total_credit.
        ADD is_audit_data-quantity TO ms_calculated_audit_data-quantity.
    ENDCASE.
  ENDMETHOD.