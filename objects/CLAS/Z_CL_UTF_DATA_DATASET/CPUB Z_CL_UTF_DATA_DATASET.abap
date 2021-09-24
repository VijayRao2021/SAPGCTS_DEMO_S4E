class Z_CL_UTF_DATA_DATASET definition
  public
  inheriting from Z_CL_UTF_MODULE
  create public .

public section.
  type-pools ZDATM .

  methods CHECK_AND_COMPLETE_OBJECT_DATA
    importing
      !IV_FUNCTION type ZDATM_TV_CCFUNCTION
      !IV_MODE type ZDATM_TV_WHATTODO optional
      !IV_TABNAME type TABNAME optional
      !IV_FIELDNAME type FIELDNAME optional
      !IV_CONDITION type ZDATA_CONDITION optional
      !IS_STRUCTIN type ANY optional
      !IV_NOT_FOUND_ALLOWED type FLAG default SPACE
    exporting
      !ES_STRUCTOUT type ANY
      !EV_VALUE type ANY
      !EV_RC type SUBRC .
  methods CONSTRUCTOR
    importing
      !IV_DATASET_TYPE type ZDATM_TV_DATASET_TYPE
      !IV_PROCESS_ID type ZPROC_PROCESS_ID optional .
    "! <p class="shorttext synchronized" lang="en">Get number of children</p>
    "! Return the number of children of current dataset
    "! @parameter rv_children | <p class="shorttext synchronized" lang="en"></p>
  methods GET_CHILDREN_COUNTER
    returning
      value(RV_CHILDREN) type I .
    "! <p class="shorttext synchronized" lang="en">create a link between two datasets</p>
    "! create a link between the current dataset (parent) and the dataset in parameter (child)
    "! @parameter iv_dataset | <p class="shorttext synchronized" lang="en">Child dataset reference</p>
  methods LINK
    importing
      !IV_DATASET type ref to Z_CL_UTF_DATA_DATASET .
    "! <p class="shorttext synchronized" lang="en">Loop on each child of the dataset object</p>
    "!
    "! @parameter ro_dataset | <p class="shorttext synchronized" lang="en">A dataset child</p>
  methods LOOP_LINKS
    returning
      value(RO_DATASET) type ref to Z_CL_UTF_DATA_DATASET .