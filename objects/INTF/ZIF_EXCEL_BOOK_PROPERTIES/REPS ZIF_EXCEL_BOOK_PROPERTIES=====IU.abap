interface ZIF_EXCEL_BOOK_PROPERTIES
  public .


  data VBAPROJECT type XSTRING read-only .
  data CODENAME type STRING read-only .
  data CODENAME_PR type STRING read-only .

  methods SET_VBAPROJECT
    importing
      !IP_VBAPROJECT type XSTRING .
  methods SET_CODENAME
    importing
      !IP_CODENAME type STRING .
  methods SET_CODENAME_PR
    importing
      !IP_CODENAME_PR type STRING .
endinterface.