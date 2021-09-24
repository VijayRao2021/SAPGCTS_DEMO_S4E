class Z_CL_UTF_DATA_DOCFILE_FLAT definition
  public
  inheriting from Z_CL_utf_DATA_DOCFILE
  create public .

public section.

  data MT_DOCUMENT_DATA type ZDATM_FILE_TT_FILE_CONTENT .

  methods CONSTRUCTOR
    importing
      !IV_DATASET_TYPE type ZDATM_TV_DATASET_TYPE
      !IV_START_OFFSET type I
      !IV_END_OFFSET type I
      !IT_DOCUMENT_DATA type ZDATM_FILE_TT_FILE_CONTENT
      !IV_PROCESS_ID type ZPROC_PROCESS_ID optional
      !IO_FILE type ref to Z_CL_utf_DATA_FILE optional .
    "! <p class="shorttext synchronized" lang="en">Reduce memory consumption of the class</p>
    "! It is a kind of standby mode
  methods MINIMIZE .
    "! <p class="shorttext synchronized" lang="en">Load the document data from the file</p>
    "! Allow to reload document data from the file after, for example, executing a minimize call to reduce memory fingerprint
    "! Another use case is to reload a document in error without loading all document of the file
  methods LOAD .