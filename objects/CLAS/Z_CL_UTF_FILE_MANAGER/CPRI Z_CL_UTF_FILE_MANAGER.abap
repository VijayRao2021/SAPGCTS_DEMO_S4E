  PRIVATE SECTION.

    "! <p class="shorttext synchronized" lang="en">Process ID linked to the current instance</p>
    DATA mv_process_id TYPE zproc_process_id .
    "! <p class="shorttext synchronized" lang="en">File configuration for a process</p>
    DATA ms_file_manager TYPE zfile_manager .

    "! <p class="shorttext synchronized" lang="en">Convert logical folder to physical folder</p>
    "! Uses the standard way to Convert a logical folder to a physical folder, but also consider the additional parameter to specify subfolder
    "! @parameter iv_logical_folder | <p class="shorttext synchronized" lang="en">Input logical folder</p>
    "! @parameter ev_physical_folder | <p class="shorttext synchronized" lang="en">Output physical folder</p>
    METHODS convert_logical_2_physical
      IMPORTING
        !iv_logical_folder  TYPE zfile_root_folder
      EXPORTING
        !ev_physical_folder TYPE zfile_root_folder .

    "! <p class="shorttext synchronized" lang="en">Check if a folder exist and create it if not</p>
    "! This method will check the existence of each subfolder of the provided path in parameter and will automatically create it if it doesn't exist
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">Path to check</p>
    CLASS-METHODS folder_check
      IMPORTING
        !iv_subfolder TYPE zfile_root_folder DEFAULT space.

    "! <p class="shorttext synchronized" lang="en">Clean a Folder</p>
    "! This method get the list of files older than retention time and delete them.
    "! @parameter iv_folder | <p class="shorttext synchronized" lang="en">Folder to Clean</p>
    "! Here is specified the file manager folder (ROOT, PROGRESS, ERROR, ARCHIVE) and not the physical folder.
    METHODS folder_cleaning
      IMPORTING
        !iv_folder TYPE string DEFAULT space .

    "! <p class="shorttext synchronized" lang="en">Read the content of a folder</p>
    "!
    "! @parameter iv_folder | <p class="shorttext synchronized" lang="en">Folder to get the content</p>
    "! @parameter et_folder_files | <p class="shorttext synchronized" lang="en">Content of the folder</p>
    CLASS-METHODS get_folder_content
      IMPORTING iv_folder                TYPE string
      RETURNING VALUE(rt_folder_content) TYPE zfile_t_files_list.

    "! <p class="shorttext synchronized" lang="en">Filter for Interface ES046</p>
    "! This Filter method will remove the csv files without corresponding PDF or the PDF files without corresponding csv.
    "! It will also raise an email notification if a file is still missing after 30min and the file will be parked
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">File Manager subfolder where are the files</p>
    "! @parameter CT_FOLDER_FILES | <p class="shorttext synchronized" lang="en">File list before/after filter</p>
    METHODS filter_method_es046
      IMPORTING
        !iv_subfolder    TYPE string
      CHANGING
        !ct_folder_files TYPE zfile_t_files_list.

    METHODS filter_method_usx019
      IMPORTING
        !iv_subfolder    TYPE string
      CHANGING
        !ct_folder_files TYPE zfile_t_files_list.

    "! <p class="shorttext synchronized" lang="en">Filter for file retention</p>
    "! This Filter method will remove the files which are newer than the retention time defined in the ZFILE_MANAGER table
    "! @parameter CT_FOLDER_FILES | <p class="shorttext synchronized" lang="en">File list before/after filter</p>
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">File Manager subfolder where are the files</p>
    METHODS filter_retention
      IMPORTING
        !iv_subfolder    TYPE string
      CHANGING
        !ct_folder_files TYPE zfile_t_files_list.

    "! <p class="shorttext synchronized" lang="en">Filter for Interface ES048</p>
    "! This filter method checks if the payment file is from a proposal run in the REGUT table.
    "! If yes, then corresponding file will be excluded.
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">File Manager subfolder where are the files</p>
    "! @parameter CT_FOLDER_FILES | <p class="shorttext synchronized" lang="en">File list before/after filter</p>
    METHODS filter_method_es048
      IMPORTING
        !iv_subfolder    TYPE string
      CHANGING
        !ct_folder_files TYPE zfile_t_files_list.

    "! <p class="shorttext synchronized" lang="en">Filter for Interface ES048 AMEX</p>
    "! This filter method checks if the payment file is from a proposal run in the REGUT table.
    "! If yes, then corresponding file will be excluded.
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">File Manager subfolder where are the files</p>
    "! @parameter CT_FOLDER_FILES | <p class="shorttext synchronized" lang="en">File list before/after filter</p>
    METHODS filter_method_es062
      IMPORTING
        !iv_subfolder    TYPE string
      CHANGING
        !ct_folder_files TYPE zfile_t_files_list.

    "! <p class="shorttext synchronized" lang="en">Filter for the delta mode</p>
    "! This filter method use the delta framework to select only the files created since the previous run.
    "! @parameter iv_subfolder | <p class="shorttext synchronized" lang="en">File Manager subfolder where are the files</p>
    "! @parameter CT_FOLDER_FILES | <p class="shorttext synchronized" lang="en">File list before/after filter</p>
    METHODS filter_method_delta
      IMPORTING
        !iv_subfolder    TYPE string
      CHANGING
        !ct_folder_files TYPE zfile_t_files_list.

