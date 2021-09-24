class-pool .
*"* class pool for class Z_CL_UTF_LOG

*"* local type definitions
include Z_CL_UTF_LOG==================ccdef.

*"* class Z_CL_UTF_LOG definition
*"* public declarations
  include Z_CL_UTF_LOG==================cu.
*"* protected declarations
  include Z_CL_UTF_LOG==================co.
*"* private declarations
  include Z_CL_UTF_LOG==================ci.
endclass. "Z_CL_UTF_LOG definition

*"* macro definitions
include Z_CL_UTF_LOG==================ccmac.
*"* local class implementation
include Z_CL_UTF_LOG==================ccimp.

*"* test class
include Z_CL_UTF_LOG==================ccau.

class Z_CL_UTF_LOG implementation.
*"* method's implementations
  include methods.
endclass. "Z_CL_UTF_LOG implementation
