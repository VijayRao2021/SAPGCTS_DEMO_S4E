"! File Manager class: this class provide service to simplify the files management<br/>
"! - Define the paths for the file based on the Process ID: root, progress, error and archive folder<br/>
"! - Retrieve files list based on pattern, in the configured folders above <br/>
class Z_CL_UTF_FILE_MANAGER definition
  public
  inheriting from Z_CL_UTF_MODULE
  create public .

public section.

    "! <p class="shorttext synchronized" lang="en">Objects factory</p>
    "! Create a new instance of the object or get the reference from memory if already existing
    "! @parameter iv_process_id   | <p class="shorttext synchronized" lang="en">Process ID</p>
    "! @parameter ro_file_manager | <p class="shorttext synchronized" lang="en">File manager</p>
  class-methods FACTORY
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
    returning
      value(RO_FILE_MANAGER) type ref to Z_CL_UTF_FILE_MANAGER .
    "! <p class="shorttext synchronized" lang="en"></p>
    "!
    "! @parameter iv_root_folder | <p class="shorttext synchronized" lang="en"></p>
    "! @parameter rt_folders_report | <p class="shorttext synchronized" lang="en"></p>
  class-methods GET_FOLDERS_REPORT
    importing
      !IV_ROOT_FOLDER type STRING
    returning
      value(RT_FOLDERS_REPORT) type ZFILE_T_FOLDER_REPORT .
    "! <p class="shorttext synchronized" lang="en">Constructor of the class</p>
    "!
    "! @parameter iv_process_id | <p class="shorttext synchronized" lang="en">Process ID</p>
    "! @exception no_configuration | <p class="shorttext synchronized" lang="en">There is no configuration for the given Process ID</p>
  methods CONSTRUCTOR
    importing
      !IV_PROCESS_ID type ZPROC_PROCESS_ID
    exceptions
      NO_CONFIGURATION .
    "! <p class="shorttext synchronized" lang="en">Return the file type</p>
    "! Return the master file type (Binary or Ascii) of the current process ID
    "! @parameter rv_file_type | <p class="shorttext synchronized" lang="en">File type</p>
  methods GET_FILE_TYPE
    returning
      value(RV_FILE_TYPE) type STRING .
    "! <p class="shorttext synchronized" lang="en">Return the new file name for a given folder</p>
    "!
    "! @parameter iv_current_filename | <p class="shorttext synchronized" lang="en">Current Filename</p>
    "! @parameter iv_folder           | <p class="shorttext synchronized" lang="en">Folder to provide the new filename</p>
    "! @parameter iv_custom_filename  | <p class="shorttext synchronized" lang="en">Specific custom logical filename</p>
    "! This parameter is used in conjunction of CUSTOM value for iv_folder parameter
    "! @parameter rv_new_filename     | <p class="shorttext synchronized" lang="en">new filename</p>
  methods GET_NEW_FILENAME
    importing
      !IV_CURRENT_FILENAME type STRING
      !IV_FOLDER type STRING
      !IV_CUSTOM_FILENAME type FILEINTERN default SPACE
    returning
      value(RV_NEW_FILENAME) type STRING .
    "! <p class="shorttext synchronized" lang="en">Return the file list available in the folder</p>
    "! Main folder will be defined from ROOT field of ZFILE_MANAGER table. If subfolder is provided then it will add this subfolder to the main folder.
    "! if a pattern is provided then it is will be used instead of the pattern of the ZFILE_MANAGER table, and if the iv_last_one parameter is provided then it
    "! will retrieve the more recent file matching this pattern (parameter or ZFILE_MANAGER pattern)
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">Subfolder where to fetch the list</p>
    "! @parameter iv_pattern | <p class="shorttext synchronized" lang="en">Use this pattern to select the file</p>
    "! @parameter iv_last_one | <p class="shorttext synchronized" lang="en">Retrieve last file for the given pattern</p>
    "! @parameter iv_filter_method | <p class="shorttext synchronized" lang="en">Specify a filter method</p>This method is called in addition of the one configured in the ZFILE_MANAGER table
  methods GET_FILE_LIST
    importing
      !IV_SUBFOLDER type STRING default 'ROOT'
      !IV_PATTERN type STRING default SPACE
      !IV_LAST_ONE type FLAG default SPACE
      !IV_FILTER_METHOD type ZFILE_FILTER_METHOD default SPACE
    returning
      value(RO_FILE_CONTAINER) type ref to z_cl_utf_data_container .
    "! <p class="shorttext synchronized" lang="en">Get requested folder name</p>
    "!
    "! @parameter iv_folder      | <p class="shorttext synchronized" lang="en">Folder code</p>
    "! @parameter rv_folder_name | <p class="shorttext synchronized" lang="en">Physical path</p>
  methods GET_FOLDER
    importing
      !IV_FOLDER type STRING
    returning
      value(RV_FOLDER_NAME) type STRING .
    "! <p class="shorttext synchronized" lang="en">Folders cleaning</p>
    "! This method checks if a retention time is defined for the current process ID in table ZFILE_MANAGER.
    "! If a retention time is defined then it will execute a folder cleaning for each folder defined in the process ID (ROOT, PROGRESS, ERROR, ARCHIVE)
  methods FOLDERS_CLEANING .
    "! <p class="shorttext synchronized" lang="en">Folders Check</p>
    "! This method checks for each folder defined for the process ID (ROOT, PROGRESS, ERROR, ARCHIVE), if the folder exists; if not then it will create it.
  methods FOLDERS_CHECK .