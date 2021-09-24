class Z_CL_UTF_DATA_FILE_INBOUND definition
  public
  inheriting from Z_CL_utf_DATA_FILE
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_DATASET_TYPE type ZDATM_TV_DATASET_TYPE
      !IV_FILENAME type STRING
      !IV_SUBFOLDER type STRING default SPACE
      !IV_PROCESS_ID type ZPROC_PROCESS_ID default SPACE
    exceptions
      CANNOT_DEFINE_FILE .
    "! <p class="shorttext synchronized" lang="en">Control the end to end data</p>
    "!
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Return Code</p>
  methods CHECK_AUDIT_DATA
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Collect the audit data</p>
    "!
    "! @parameter iv_type | <p class="shorttext synchronized" lang="en">RECEIVED or CALCULATED</p>
    "! @parameter iv_audit_data | <p class="shorttext synchronized" lang="en">Audit data to collect</p>
  methods COLLECT_AUDIT_DATA
    importing
      !IV_TYPE type STRING
      !IS_AUDIT_DATA type Z1ZAUDIT .
    "! <p class="shorttext synchronized" lang="en">read the file to extract all required information</p>
    "!
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Return Code</p>
  methods PARSE
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Get a document from the file</p>
    "! @parameter iv_document_number | <p class="shorttext synchronized" lang="en">Document to retrieve</p>
    "! @parameter ro_document | <p class="shorttext synchronized" lang="en">Requested document</p>
  methods GET_DOCUMENT
    importing
      !IV_DOCUMENT_NUMBER type I
    returning
      value(RO_DOCUMENT) type ref to z_cl_utf_data_dataset .