PROCESS BEFORE OUTPUT.
 MODULE detail_init.
*
PROCESS AFTER INPUT.
 MODULE DETAIL_EXIT_COMMAND AT EXIT-COMMAND.
 MODULE DETAIL_SET_PFSTATUS.
 CHAIN.
    FIELD ZV_FILE_MANAGER-PROCESS_ID .
    FIELD ZV_FILE_MANAGER-ROOT_LOGICAL .
    FIELD ZV_FILE_MANAGER-ROOT_FOLDER .
    FIELD ZV_FILE_MANAGER-FILE_PATTERN .
    FIELD ZV_FILE_MANAGER-PROGRESS_LOGICAL .
    FIELD ZV_FILE_MANAGER-PROGRESS_FOLDER .
    FIELD ZV_FILE_MANAGER-ARCHIVE_LOGICAL .
    FIELD ZV_FILE_MANAGER-ARCHIVE_FOLDER .
    FIELD ZV_FILE_MANAGER-ARCHIVED_FILE_NAME .
    FIELD ZV_FILE_MANAGER-ERROR_LOGICAL .
    FIELD ZV_FILE_MANAGER-ERROR_FOLDER .
    FIELD ZV_FILE_MANAGER-ERROR_FILE_NAME .
    FIELD ZV_FILE_MANAGER-RETENTION .
    FIELD ZV_FILE_MANAGER-USE_METADATA .
    FIELD ZV_FILE_MANAGER-METADATA_VERSION .
    FIELD ZV_FILE_MANAGER-FILE_TYPE .
    FIELD ZV_FILE_MANAGER-DELTA_MODE .
    FIELD ZV_FILE_MANAGER-FILTER_METHOD .
  MODULE SET_UPDATE_FLAG ON CHAIN-REQUEST.
 endchain.
 chain.
    FIELD ZV_FILE_MANAGER-PROCESS_ID .
  module detail_pai.
 endchain.