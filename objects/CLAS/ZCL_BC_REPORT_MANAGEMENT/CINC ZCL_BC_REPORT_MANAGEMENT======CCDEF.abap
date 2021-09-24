*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

TYPES:
 BEGIN OF ts_block_def,
  name(20)       TYPE c,
  typeofblock(5) TYPE c,
  endlinetype(1) TYPE c,
  begin_idx      TYPE sy-tabix,
  end_idx        TYPE sy-tabix,
  data_type      type sood-objtp, " AK-001
 END OF ts_block_def.