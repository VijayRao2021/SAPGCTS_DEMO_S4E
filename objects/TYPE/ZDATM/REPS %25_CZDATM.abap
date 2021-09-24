TYPE-POOL zdatm.
**General types and constants
TYPES:
  "Types for variables
  zdatm_tv_dataset_type  TYPE c,
  zdatm_tv_whattodo      TYPE string,
  zdatm_tv_ccfunction    TYPE string,
  zdatm_tv_update_method TYPE string.

TYPES:
  "Types for Structures
  zdatm_ts_object_data TYPE zdset_object_dat,

  BEGIN OF zdatm_ts_link,
    parent_id TYPE zcore_object_id,
    child_id  TYPE zcore_object_id,
    child_ref TYPE REF TO z_cl_utf_data_dataset,
  END OF zdatm_ts_link.

TYPES:
  "Type for Tables
  zdatm_tt_object_data TYPE STANDARD TABLE OF zdatm_ts_object_data,
  zdatm_tt_links       TYPE STANDARD TABLE OF zdatm_ts_link.


CONSTANTS:
  zdatm_c_modid_dataset        TYPE zcore_module_id VALUE 'DATASET',
  zdatm_c_datasettype_inbound  TYPE zdatm_tv_dataset_type VALUE 'I',
  zdatm_c_datasettype_outbound TYPE zdatm_tv_dataset_type VALUE 'O',
  zdatm_c_datasettype_toquery  TYPE zdatm_tv_dataset_type VALUE 'Q',

  zdatm_c_whattodo_create      TYPE zdatm_tv_whattodo VALUE 'CREATE',
  zdatm_c_whattodo_update      TYPE zdatm_tv_whattodo VALUE 'UPDATE',

  zdatm_c_ccfunction_retrieve  TYPE zdatm_tv_ccfunction VALUE 'RETRIEVE', "Retrieve constant field value
  zdatm_c_ccfunction_check     TYPE zdatm_tv_ccfunction VALUE 'CHECK', "Check if required fields are provided
  zdatm_c_ccfunction_copy      TYPE zdatm_tv_ccfunction VALUE 'COPY', "Copy the fields of a change request from a structure to another one
  zdatm_c_ccfunction_group     TYPE zdatm_tv_ccfunction VALUE 'GROUP', "Retrieve the values of a group of values

  zdatm_c_update_method_idoc   TYPE zdatm_tv_update_method VALUE 'IDOC',
  zdatm_c_update_method_bapi   TYPE zdatm_tv_update_method VALUE 'BAPI'.
** Container data object types
TYPES:
  BEGIN OF zdatm_container_ts_content,
    object TYPE REF TO z_cl_utf_data_dataset,
  END OF zdatm_container_ts_content,

  zdatm_container_tt_content TYPE STANDARD TABLE OF zdatm_container_ts_content.

** File data object types
TYPES:
  "Types for Structures
  zdatm_file_ts_file_content TYPE string,
  BEGIN OF zdatm_file_ts_file_doc,
    document TYPE REF TO z_cl_utf_data_docfile,
  END OF zdatm_file_ts_file_doc.

*** Start of uncommented by RAMESHT on 04.08.2021
*** Start of Commented by RAMESHT on 26.07.2021.
" SOC AK-001
** File data object types


" EOC -AK-001
*** End of Commented by RAMESHT on 26.07.2021.
*** End of uncommented by RAMESHT on 04.08.2021

"Type for Tables
TYPES:
  zdatm_file_tt_file_content TYPE STANDARD TABLE OF zdatm_file_ts_file_content,
  zdatm_file_tt_file_docs    TYPE STANDARD TABLE OF zdatm_file_ts_file_doc.

*** Start of uncommented by RAMESHT on 04.08.2021
*** Start of Commented by RAMESHT on 26.07.2021.
" SOC-AK-001

" EOC- AK-001
*** End of Commented by RAMESHT on 26.07.2021.
*** End of uncommented by RAMESHT on 04.08.2021

**Document File data object types and constants
TYPES:
  BEGIN OF zdatm_filedoc_ts_scm010_struct,
    record_type(4) TYPE c,
    matnr          TYPE matnr,
    brgew          TYPE string,
    gewei          TYPE gewei,
    ntgew          TYPE string,
    groes          TYPE groes,
    laeng          TYPE string,
    breit          TYPE string,
    hoehe          TYPE string,
    meabm          TYPE meabm,
    herkl          TYPE herkl,
    herkr          TYPE herkr,
  END OF zdatm_filedoc_ts_scm010_struct.

**Material data object types and constants
TYPES:
  BEGIN OF zdatm_mat_ts_tables_loaded,
    mara(1) TYPE c,
    marc(1) TYPE c,
    mard(1) TYPE c,
    marm(1) TYPE c,
    makt(1) TYPE c,
    mlan(1) TYPE c,
    mbew(1) TYPE c,
    mvke(1) TYPE c,
  END OF zdatm_mat_ts_tables_loaded,

  BEGIN OF zdatm_mat_ts_valuation,
    matnr TYPE matnr,
    bwkey TYPE bwkey,
    stprs TYPE stprs,
    peinh TYPE peinh,
  END OF zdatm_mat_ts_valuation,
  zdatm_mat_tt_valuation TYPE STANDARD TABLE OF zdatm_mat_ts_valuation.

**Intratat data object types and constants
TYPES:
  BEGIN OF zdatm_int_ts_input_struct,
    docnum           TYPE edi_docnum,
    budat            TYPE budat,
    bldat            TYPE bldat,
    bwart            TYPE bwart,
    xblnr            TYPE xblnr1,
    bktxt            TYPE bktxt,
    from_werks       TYPE werks_d,
    to_werks         TYPE werks_d,
    matnr            TYPE matnr,
    menge            TYPE menge_d,
    meins            TYPE meins,
    source_bestiland TYPE bestiland,
    source_bestiregi TYPE bestiregi,
    source_kunnr     TYPE kunnr,
    ebeln            TYPE ebeln,
    ebelp            TYPE ebelp,
    mblnr            TYPE mblnr,
    mjahr            TYPE mjahr,
  END OF zdatm_int_ts_input_struct,
  zdatm_int_tt_input_struct TYPE STANDARD TABLE OF zdatm_int_ts_input_struct.