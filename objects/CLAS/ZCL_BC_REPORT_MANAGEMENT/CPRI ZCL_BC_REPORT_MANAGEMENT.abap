*"* private components of class ZCL_BC_REPORT_MANAGEMENT
*"* do not include other source files here!!!
private section.

  constants:
    c_datas_block(5) TYPE c value 'DATAS'. "#EC NOTEXT
  constants:
    c_list_block(4) TYPE c value 'LIST'. "#EC NOTEXT
  data:
    t_block TYPE STANDARD TABLE OF ts_block_def .
  data:
    t_block_datas TYPE STANDARD TABLE OF string .
  data:
    t_list TYPE STANDARD TABLE OF abaplist .
  data V_RQIDENT type RSPOID .

  methods UPDATE_LIST
    returning
      value(EV_SIZE) type I .