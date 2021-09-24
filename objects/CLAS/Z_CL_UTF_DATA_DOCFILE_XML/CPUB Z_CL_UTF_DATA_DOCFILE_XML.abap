class Z_CL_UTF_DATA_DOCFILE_XML definition
  public
  inheriting from Z_CL_utf_DATA_DOCFILE
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_DATASET_TYPE type ZDATM_TV_DATASET_TYPE
      !IO_DOCUMENT_DATA type ref to IF_IXML_NODE
      !IV_DOCUMENT_NUMBER type I
      !IV_PROCESS_ID type ZPROC_PROCESS_ID optional .