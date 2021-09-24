  PRIVATE SECTION.
    "! <p class="shorttext synchronized" lang="en">Define the file type: ASC or BIN</p>
    DATA mv_file_type TYPE string .
    "! <p class="shorttext synchronized" lang="en">Folder where is the file</p>
    DATA mv_current_folder TYPE string .
    "! <p class="shorttext synchronized" lang="en">Root folder of the process</p>
    DATA mv_root_folder TYPE string .
    "! <p class="shorttext synchronized" lang="en">Filename with path</p>
    DATA mv_filename_full TYPE string .
    "! <p class="shorttext synchronized" lang="en">define if file is open or not</p>
    DATA mv_is_open TYPE flag .
    "! <p class="shorttext synchronized" lang="en">Link to the file manager object</p>
    DATA mo_file_manager TYPE REF TO z_cl_utf_file_manager .

    "! <p class="shorttext synchronized" lang="en">Check if the file has been already processed.</p>
    METHODS is_duplicate
      IMPORTING
        !iv_duplicate_check TYPE zfile_duplicate_check DEFAULT '1'
      RETURNING
        VALUE(rv_rc)        TYPE sysubrc .

    "! <p class="shorttext synchronized" lang="en">Return the full path</p>
    "!
    "! @parameter iv_folder    | <p class="shorttext synchronized" lang="en">Folder</p>
    "! @parameter rv_full_path | <p class="shorttext synchronized" lang="en">Full Path</p>
    METHODS get_full_path
      IMPORTING
        !iv_folder          TYPE string OPTIONAL
      RETURNING
        VALUE(rv_full_path) TYPE string .