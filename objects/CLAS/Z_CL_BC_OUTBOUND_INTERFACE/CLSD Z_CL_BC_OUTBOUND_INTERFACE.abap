class-pool .
*"* class pool for class Z_CL_BC_OUTBOUND_INTERFACE

*"* local type definitions
include Z_CL_BC_OUTBOUND_INTERFACE====ccdef.

*"* class Z_CL_BC_OUTBOUND_INTERFACE definition
*"* public declarations
  include Z_CL_BC_OUTBOUND_INTERFACE====cu.
*"* protected declarations
  include Z_CL_BC_OUTBOUND_INTERFACE====co.
*"* private declarations
  include Z_CL_BC_OUTBOUND_INTERFACE====ci.
endclass. "Z_CL_BC_OUTBOUND_INTERFACE definition

*"* macro definitions
include Z_CL_BC_OUTBOUND_INTERFACE====ccmac.
*"* local class implementation
include Z_CL_BC_OUTBOUND_INTERFACE====ccimp.

*"* test class
include Z_CL_BC_OUTBOUND_INTERFACE====ccau.

class Z_CL_BC_OUTBOUND_INTERFACE implementation.
*"* method's implementations
  include methods.
endclass. "Z_CL_BC_OUTBOUND_INTERFACE implementation
