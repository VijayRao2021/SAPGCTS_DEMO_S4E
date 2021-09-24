*"* use this source file for any type declarations (class
*"* definitions, interfaces or data types) you need for method
*"* implementation or private method's signature

TYPE-POOLS: abap,zetoe.

TYPES:
    ts_calculation_customizing TYPE zbc_audit_cust,
    tt_calculation_customizing TYPE STANDARD TABLE OF ts_calculation_customizing,
    tt_edids type STANDARD TABLE OF edids.