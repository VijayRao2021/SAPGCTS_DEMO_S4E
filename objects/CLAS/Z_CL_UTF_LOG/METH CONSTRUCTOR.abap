METHOD CONSTRUCTOR.
  CLEAR mv_level_max.
  REFRESH: mt_groups_table.

*Create the entry for the global log
  configure_group( iv_group = '' iv_level = iv_level iv_display = 'X' iv_mode = 'C' iv_al_object = iv_al_object iv_al_subobject = iv_al_subobject iv_al_extnumber = iv_al_extnumber ).

*  set_log_level( 0 ).
ENDMETHOD.