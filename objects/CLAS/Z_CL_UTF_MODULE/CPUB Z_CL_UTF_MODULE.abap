class Z_CL_UTF_MODULE definition
  public
  create public .

public section.

  interfaces Z_IN_CORE_COMMUNICATION .
  interfaces Z_IN_UTF_LOG .

    "! <p class="shorttext synchronized" lang="en">Initialize the attributes of dataset class</p>
    "!
    "! @parameter iv_module_id | <p class="shorttext synchronized" lang="en">Module ID of current object</p>
  methods CONSTRUCTOR
    importing
      !IV_MODULE_ID type ZCORE_MODULE_ID .