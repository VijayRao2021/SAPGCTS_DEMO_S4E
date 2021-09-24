"! <p class="shorttext synchronized" lang="en">File data object</p>
"! This dataset class allows to easily manipulate a file and its content
"! It provides basic features like, open, close, read, write, but also move advance feature like move, copy, keep data in memory when doing transfer.
"! The class is linked to the file manager framework to automatically determiner the folder where is stored or where to store the file.
"! It is also the basic token for the transfer framework.
class Z_CL_UTF_DATA_FILE definition
  public
  inheriting from z_cl_utf_data_dataset
  create public .

public section.
  type-pools ZDATM .

    "! <p class="shorttext synchronized" lang="en">Move the file in archive folder</p>
    "! the method will use the configuration of table ZFILE_MANAGER to identify the archive folder where to move the file
    "! and also if the file must be renamed in same time. The new name is defined in a logical file.
  methods ARCHIVE
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Move the file in error folder</p>
    "! the method will use the configuration of table ZFILE_MANAGER to identify the error folder where to move the file
    "! and also if the file must be renamed in same time. The new name is defined in a logical file.
  methods PARK
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Class constructor</p>
    "!
    "! @parameter iv_dataset_type    | <p class="shorttext synchronized" lang="en">Dataset type</p>
    "! @parameter iv_filename        | <p class="shorttext synchronized" lang="en">File name</p>
    "! @parameter iv_subfolder       | <p class="shorttext synchronized" lang="en">Sub folder where is the file</p>
    "! @parameter iv_process_id      | <p class="shorttext synchronized" lang="en">Process ID</p>
    "! @exception cannot_define_file | <p class="shorttext synchronized" lang="en">Cannot define the file to process</p>
  methods CONSTRUCTOR
    importing
      !IV_DATASET_TYPE type ZDATM_TV_DATASET_TYPE
      !IV_FILENAME type STRING
      !IV_SUBFOLDER type STRING default SPACE
      !IV_PROCESS_ID type ZPROC_PROCESS_ID default SPACE
    exceptions
      CANNOT_DEFINE_FILE .
    "! <p class="shorttext synchronized" lang="en">Copy a file to another folder</p>
    "! Copy the current file to another folder under a new name if provided.
    "! @parameter iv_target_folder | <p class="shorttext synchronized" lang="en">Folder where to copy the file</p>
    "! @parameter iv_target_filename | <p class="shorttext synchronized" lang="en">New file name of the copy</p>
    "! @parameter rv_rc        | <p class="shorttext synchronized" lang="en">Return code if copy was successful or not</p>
  methods COPY
    importing
      !IV_TARGET_FOLDER type STRING
      !IV_TARGET_FILENAME type STRING default SPACE
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Copy a file and return reference to the new file</p>
    "! Copy the current file to a new file and return the reference to the new file object
    "! @parameter iv_target_folder | <p class="shorttext synchronized" lang="en">Folder where to copy the file</p>
    "! @parameter iv_target_filename | <p class="shorttext synchronized" lang="en">New file name of the copy</p>
    "! @parameter ro_file       | <p class="shorttext synchronized" lang="en">Reference to the new file</p>
    "! if any issue during the copy process then the reference is initial
  methods COPY_WITH_REFERENCE
    importing
      !IV_TARGET_FOLDER type STRING
      !IV_TARGET_FILENAME type STRING
    returning
      value(RO_FILE) type ref to Z_CL_UTF_DATA_FILE .
    "! <p class="shorttext synchronized" lang="en">Delete the file</p>
  methods DELETE
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Sign the file with the certificate</p>
    "!
    "! @parameter iv_application | <p class="shorttext synchronized" lang="en">certificate to use to sign</p>
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Return code if signature was successful or not</p>
  methods SIGN
    importing
      !IV_APPLICATION type SSFAPPL
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Return the content of the file</p>
  methods GET_CONTENT
    importing
      !IV_START_OFFSET type I optional
      !IV_END_OFFSET type I optional
    exporting
      value(ET_CONTENT) type ZDATM_FILE_TT_FILE_CONTENT .
    "! <p class="shorttext synchronized" lang="en">Return the file list for a given folder</p>
    "! /!\ please don't use this method anymore use the GET_FILE_LIST method from the class Z_CL_FILE_MANAGER instead
    "! @parameter iv_process_id | <p class="shorttext synchronized" lang="en">Process ID</p>
    "! @parameter iv_subfolder  | <p class="shorttext synchronized" lang="en">Subfolder</p>
    "! @parameter rt_file_list  | <p class="shorttext synchronized" lang="en">Table Type for eps2fili</p>
  class-methods GET_FILE_LIST
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
      !IV_SUBFOLDER type STRING default SPACE
    returning
      value(RT_FILE_LIST) type EPS2FILIS .
    "! <p class="shorttext synchronized" lang="en">Return the current file name</p>
  methods GET_FILE_NAME
    importing
      !IV_FULL_FILENAME type FLAG optional
    returning
      value(RV_FILE_NAME) type STRING .
    "! <p class="shorttext synchronized" lang="en">Move a file to another folder</p>
    "!
    "! @parameter iv_target_folder | <p class="shorttext synchronized" lang="en">Folder where to move the file</p>
    "! @parameter iv_target_filename | <p class="shorttext synchronized" lang="en">New filename if file must be renamed in same time</p>
  methods MOVE
    importing
      !IV_TARGET_FOLDER type STRING
      !IV_TARGET_FILENAME type STRING default SPACE
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Transfer data to the file</p>
    "!
    "! @parameter iv_data      | <p class="shorttext synchronized" lang="en">Data to transfer to the file</p>
    "! @parameter iv_in_memory | <p class="shorttext synchronized" lang="en">Write the data in the memory</p>
    "! @parameter rv_rc        | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods TRANSFER_DATA
    importing
      !IV_DATA type ANY
      !IV_IN_MEMORY type ABAP_BOOL default ' '
    returning
      value(RV_RC) type SUBRC .
    "! <p class="shorttext synchronized" lang="en">Transfer data to the file in binary format</p>
    "!
    "! @parameter iv_data      | <p class="shorttext synchronized" lang="en">Data to transfer to the file</p>
    "! @parameter iv_in_memory | <p class="shorttext synchronized" lang="en">Write the data in the memory</p>
    "! @parameter rv_rc        | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods TRANSFER_DATAX
    importing
      !IV_DATAX type ANY
      !IV_IN_MEMORY type ABAP_BOOL default ' '
    returning
      value(RV_RC) type SUBRC .
    "! <p class="shorttext synchronized" lang="en">Process the file documents</p>
  methods PROCESS_DOCUMENTS .
    "! <p class="shorttext synchronized" lang="en">Detect the documents inside the file</p>
  methods SPLIT_FILE_CONTENT_TO_DOCS .
    "! <p class="shorttext synchronized" lang="en">Open the file</p>
    "!
    "! @parameter iv_filetype | <p class="shorttext synchronized" lang="en">File type (ASC or BIN)</p>
    "! @parameter iv_opentype | <p class="shorttext synchronized" lang="en">Open in Input/Output</p>
    "! if this parameter is specified it has the priority on the ms_dataset_type attribute
    "! @parameter rv_rc       | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
*        iv_opentype  TYPE string DEFAULT space
  methods OPEN
    importing
      !IV_FILETYPE type STRING default 'ASC'
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Close the file</p>
    "!
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods CLOSE
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Load the file data in memory</p>
    "! This method read the content of the file and load it in a class attribute in memory<br/>
    "! /!\ Take care the file must be open in read mode else the method will return RC=8
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods LOAD_IN_MEMORY
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Check if the file has been already received</p>
    "!
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods IS_ALREADY_RECEIVED
    importing
      !IV_DUPLICATE_CHECK type ZFILE_DUPLICATE_CHECK default '0'
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Check if the file is already open</p>
    "!
    "! @parameter rv_rc | <p class="shorttext synchronized" lang="en">Subroutines for return code</p>
  methods IS_OPEN
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Transfer the content of file from memory to disk</p>
  methods CREATE_FROM_MEMORY
    returning
      value(RV_RC) type SUBRC .
    "! <p class="shorttext synchronized" lang="en">Check if file was already sent to target system</p>
  methods IS_ALREADY_SENT
    importing
      !IV_DUPLICATE_CHECK type ZFILE_DUPLICATE_CHECK default '0'
    returning
      value(RV_RC) type SYSUBRC .
    "! <p class="shorttext synchronized" lang="en">Return the folder where is the file</p>
    "!
    "! @parameter rv_folder | <p class="shorttext synchronized" lang="en">Current folder of the file</p>
  methods GET_CURRENT_FOLDER
    returning
      value(RV_FOLDER) type STRING .