METHOD update_list.

  CALL FUNCTION 'SAVE_LIST'
*   EXPORTING
*     LIST_INDEX               = '0'
*     FORCE_WRITE              =
    TABLES
      listobject               = t_list
   EXCEPTIONS
     list_index_invalid       = 1
     OTHERS                   = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  DESCRIBE TABLE t_list LINES ev_size.
ENDMETHOD.