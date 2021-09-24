  METHOD save.
    DATA:
          lv_rc TYPE sysubrc,
          lv_cnt_count TYPE zproc_item,
          lr_attribute TYPE REF TO zproc_attr.

    "TODO: raise error message if error when saving. Manage a lock entry Add erdat... and AEDAT to define if process has been updated in meantime
    CLEAR lv_rc.
    IF mv_flg_changed = abap_true.
      RAISE EVENT send_log EXPORTING iv_group = 'PROCESS' iv_level = 1 iv_type = 'I' iv_msg1 = 'Update the DB...'(i06).
      CLEAR mv_flg_changed.
      "Save header data.
      MODIFY zproc_header FROM ms_process.
      lv_rc = sy-subrc.
      MODIFY zproc_text FROM ms_process_text.
      IF lv_rc = 0.
        lv_rc = sy-subrc.
      ENDIF.

      "Update the item number of the attributes.
      SORT mt_attributes BY attribute_id item DESCENDING.
      LOOP AT mt_attributes REFERENCE INTO lr_attribute.
        AT NEW attribute_id.
          lv_cnt_count = 1.
        ENDAT.
        IF lr_attribute->item IS INITIAL.
          lr_attribute->item = lv_cnt_count.
          ADD 1 TO lv_cnt_count.
        ELSE.
          IF lr_attribute->item > lv_cnt_count.
            lv_cnt_count = lr_attribute->item.
          ENDIF.
        ENDIF.
      ENDLOOP.
      MODIFY zproc_attr FROM TABLE mt_attributes.
      IF lv_rc = 0.
        lv_rc = sy-subrc.
      ENDIF.
    ENDIF.
    rv_subrc = lv_rc.
  ENDMETHOD.