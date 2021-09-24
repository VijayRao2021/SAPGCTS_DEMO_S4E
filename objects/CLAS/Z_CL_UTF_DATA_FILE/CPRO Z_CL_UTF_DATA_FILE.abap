  PROTECTED SECTION.
    DATA:
      mv_has_metadata_file    TYPE flag,
      mv_has_md5checksum_file TYPE flag,
      mv_has_tmp_file         TYPE flag,

      "! <p class="shorttext synchronized" lang="en">File content</p>
      mt_file_data            TYPE zdatm_file_tt_file_content,
      "! <p class="shorttext synchronized" lang="en">Documents in the file</p>
      mt_file_docs            TYPE zdatm_file_tt_file_docs,
      "! <p class="shorttext synchronized" lang="en">Filename</p>
      mv_filename             TYPE string.

    "! <p class="shorttext synchronized" lang="en">Return current file name with path</p>
    METHODS get_full_filename
      IMPORTING
        !iv_folder              TYPE string OPTIONAL
      RETURNING
        VALUE(rv_full_filename) TYPE string.
