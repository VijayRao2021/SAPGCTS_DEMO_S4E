class Z_CL_BC_LOCK_UTILITIES definition
  public
  final
  create public .

public section.

  interfaces Z_IN_UTF_LOG .

  class-methods LOCK_GENERIC_ENTRY
    importing
      !IV_PART1 type ANY
      !IV_PART2 type ANY default SPACE
      !IV_PART3 type ANY default SPACE
      !IV_PART4 type ANY default SPACE
      !IV_PART5 type ANY default SPACE
      !IV_WAIT type FLAG default SPACE
    returning
      value(RV_SUBRC) type SYSUBRC .
  class-methods UNLOCK_GENERIC_ENTRY
    importing
      !IV_PART1 type ANY
      !IV_PART2 type ANY default SPACE
      !IV_PART3 type ANY default SPACE
      !IV_PART4 type ANY default SPACE
      !IV_PART5 type ANY default SPACE .