FUNCTION CONVERSION_EXIT_ZSIZE_OUTPUT.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(INPUT) TYPE  CLIKE
*"  EXPORTING
*"     REFERENCE(OUTPUT) TYPE  CLIKE
*"----------------------------------------------------------------------

  DATA:
    lv_original_size(15)  TYPE p DECIMALS 0,
    lv_converted_size(15) TYPE p DECIMALS 2,
    lv_output(15)         TYPE c.

  lv_original_size = input.
  IF lv_original_size >= 1000000000000.
    lv_converted_size = lv_original_size / 1000000000000.
    WRITE lv_converted_size TO lv_output.
    condense lv_output no-GAPs.
    CONCATENATE lv_output 'TB' INTO lv_output SEPARATED BY space.
  ELSEIF lv_original_size >= 1000000000.
    lv_converted_size = lv_original_size / 1000000000.
    WRITE lv_converted_size TO lv_output.
    condense lv_output no-GAPs.
    CONCATENATE lv_output 'GB' INTO lv_output SEPARATED BY space.
  ELSEIF lv_original_size >= 1000000.
    lv_converted_size = lv_original_size / 1000000.
    WRITE lv_converted_size TO lv_output.
    condense lv_output no-GAPs.
    CONCATENATE lv_output 'MB' INTO lv_output SEPARATED BY space.
  ELSEIF lv_original_size >= 1000.
    lv_converted_size = lv_original_size / 1000.
    WRITE lv_converted_size TO lv_output.
    condense lv_output no-GAPs.
    CONCATENATE lv_output 'KB' INTO lv_output SEPARATED BY space.
  ELSE.
    WRITE lv_original_size TO lv_output.
    condense lv_output no-GAPs.
    CONCATENATE lv_output 'B' INTO lv_output SEPARATED BY space.
  ENDIF.
  output = lv_output.
ENDFUNCTION.