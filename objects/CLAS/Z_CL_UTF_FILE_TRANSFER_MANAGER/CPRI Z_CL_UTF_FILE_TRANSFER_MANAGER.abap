private section.

    "! <p class="shorttext synchronized" lang="en">Server configuration</p>
  data MS_FILE_SERVER type ZFILE_SERVER .
    "! <p class="shorttext synchronized" lang="en">Transfer configuration</p>
  data MS_FILE_TRANSFER type ZFILE_TRANSFER .
    "! <p class="shorttext synchronized" lang="en">Process ID linked to current instance</p>
  data MV_PROCESS_ID type ZPROC_PROCESS_ID .
    "! <p class="shorttext synchronized" lang="en">Framework Process ID for internal use</p>
  constants CV_TRANSFER_FRAMEWORK_ID type ZPROC_PROCESS_ID value 'UTT_TRANSFER_FRAMEWORK' ##NO_TEXT.

    "! <p class="shorttext synchronized" lang="en">Transfer a file by FTP</p>
    "!
    "! @parameter io_file_object | <p class="shorttext synchronized" lang="en">File data object</p>
    "! @parameter rv_rc          | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods TRANSFER_FILE_FTP
    importing
      !IO_FILE_OBJECT type ref to Z_CL_UTF_DATA_FILE
    returning
      value(RV_RC) type SUBRC .
  methods TRANSFER_FILE_REST
    importing
      !IO_FILE_OBJECT type ref to Z_CL_UTF_DATA_FILE
      !IV_PARAMETERS type STRING
    changing
      !CV_RESPONSE_CODE type ZFILE_RESPONSE_CODE optional
      !CV_RESPONSE_TEXT type ZFILE_RESPONSE_TEXT optional
      !CV_RESPONSE_TIME type DECFLOAT34 optional
      !CV_FILESENT_TIME type TIMESTAMP optional
      !CV_RETRY_ATTEMPTS type I optional
    returning
      value(RV_RC) type SUBRC .
    "! <p class="shorttext synchronized" lang="en">Transfer a file by SFTP</p>
    "! As there is no standard function in SAP to SFTP, this method uses a OS command ZFILE_TRANS_SFTP to use
    "! a Linux script to do the transfer using a Linux program (curl).<br/>
    "! This method was implemented during GAP-3345.
    "! @parameter io_file_object | <p class="shorttext synchronized" lang="en">File data object</p>
    "! @parameter rv_rc          | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods TRANSFER_FILE_SFTP
    importing
      !IO_FILE_OBJECT type ref to Z_CL_UTF_DATA_FILE
    returning
      value(RV_RC) type SUBRC .