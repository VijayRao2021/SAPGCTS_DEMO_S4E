class Z_CL_UTF_FILE_TRANSFER_MANAGER definition
  public
  inheriting from Z_CL_UTF_MODULE
  final
  create public .

public section.

    "! <p class="shorttext synchronized" lang="en">Constructor of the class</p>
    "!
    "! @parameter iv_process_id | <p class="shorttext synchronized" lang="en">Process ID</p>
  methods CONSTRUCTOR
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID .
    "! <p class="shorttext synchronized" lang="en">Objects factory</p>
    "!
    "! @parameter iv_process_id       | <p class="shorttext synchronized" lang="en">Process ID</p>
    "! @parameter ro_transfer_manager | <p class="shorttext synchronized" lang="en">File transfer manager</p>
  class-methods FACTORY
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
    returning
      value(RO_TRANSFER_MANAGER) type ref to Z_CL_UTF_FILE_TRANSFER_MANAGER .
    "! <p class="shorttext synchronized" lang="en">Transfer a file</p>
    "!
    "! @parameter io_file_object             | <p class="shorttext synchronized" lang="en">File data object</p>
    "! @parameter iv_parameters              | <p class="shorttext synchronized" lang="en">Additional parameters</p>
    "! Provide additional parameters to the transfer logic if the transfer logic requires
    "! @parameter iv_disable_duplicate_check | <p class="shorttext synchronized" lang="en">Disable duplicate check flag</p>
    "! @parameter rv_rc                      | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods TRANSFER_FILE
    importing
      !IO_FILE_OBJECT type ref to Z_CL_UTF_DATA_FILE
      !IV_PARAMETERS type STRING optional
      !IV_DISABLE_DUPLICATE_CHECK type CHAR1 optional
    changing
      !CV_RESPONSE_CODE type ZFILE_RESPONSE_CODE optional
      !CV_RESPONSE_TEXT type ZFILE_RESPONSE_TEXT optional
      !CV_RESPONSE_TIME type DECFLOAT34 optional
      !CV_FILESENT_TIME type TIMESTAMP optional
      !CV_RETRY_ATTEMPTS type I optional
    returning
      value(RV_RC) type SUBRC .
  methods TRANSFER_FOLDER
    returning
      value(RV_RC) type SUBRC .