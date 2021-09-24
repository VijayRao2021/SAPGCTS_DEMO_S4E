class Z_CL_CORE_TOOL_SYSTEM definition
  public
  inheriting from Z_CL_UTF_MODULE
  final
  create public .

public section.

    "! <p class="shorttext synchronized" lang="en">System Command execution</p>
    "! This method will check if user has access to call a system command and if yes, it will call it thanks to standard FM
    "! @parameter iv_command_name | <p class="shorttext synchronized" lang="en">Name of Logical Command</p>
    "! @parameter iv_parameter1 | <p class="shorttext synchronized" lang="en">Additional parameter 1</p>
    "! @parameter iv_parameter2 | <p class="shorttext synchronized" lang="en">Additional parameter 2</p>
    "! @parameter iv_parameter3 | <p class="shorttext synchronized" lang="en">Additional parameter 3</p>
    "! @parameter iv_parameter4 | <p class="shorttext synchronized" lang="en">Additional parameter 4</p>
    "! @parameter iv_parameter5 | <p class="shorttext synchronized" lang="en">Additional parameter 5</p>
    "! @parameter rv_rc          | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  class-methods CALL_SYSTEM_COMMAND
    importing
      !IV_COMMAND_NAME type SXPGCOLIST-NAME
      !IV_PARAMETER1 type ANY optional
      !IV_PARAMETER2 type ANY optional
      !IV_PARAMETER3 type ANY optional
      !IV_PARAMETER4 type ANY optional
      !IV_PARAMETER5 type ANY optional
    returning
      value(RV_RC) type SUBRC .