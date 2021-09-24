FUNCTION CONVERSION_EXIT_ZSIZE_INPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     REFERENCE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

DATA:
    lv_input(15)      TYPE c,
    lv_human_size(15) TYPE p DECIMALS 2,
    lv_size(15)       TYPE p DECIMALS 0,
    lv_output(15) type c.

  lv_input = input.
  IF lv_input CS 'TB'.
    REPLACE 'TB' WITH '' INTO lv_input.
    REPLACE ',' WITH '.' INTO lv_input.
    lv_human_size = lv_input.
    lv_size = lv_human_size * 1000000000000.

  ELSEIF lv_input CS 'GB'.
    REPLACE 'GB' WITH '' INTO lv_input.
    REPLACE ',' WITH '.' INTO lv_input.
    lv_human_size = lv_input.
    lv_size = lv_human_size * 1000000000.
  ELSEIF lv_input CS 'MB'.
    REPLACE 'MB' WITH '' INTO lv_input.
    REPLACE ',' WITH '.' INTO lv_input.
    lv_human_size = lv_input.
    lv_size = lv_human_size * 1000000.
  ELSEIF lv_input CS 'KB'.
    REPLACE 'KB' WITH '' INTO lv_input.
    REPLACE ',' WITH '.' INTO lv_input.
    lv_human_size = lv_input.
    lv_size = lv_human_size * 1000.
  ELSE.
    IF lv_input CS 'B'.
      REPLACE 'B' WITH '' INTO lv_input.
    ENDIF.
    REPLACE ',' WITH '.' INTO lv_input.
    lv_size = lv_input.
  ENDIF.

  WRITE lv_size TO lv_output using EDIT MASK 'LL_______________'.
  CONDENSE lv_output NO-GAPS.
  output = lv_output.

ENDFUNCTION.