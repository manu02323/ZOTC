interface Z01OTCII_SI_SALES_ORDER_LIST_I
  public .


  methods SI_SALES_ORDER_LIST_IN
    importing
      !INPUT type Z01OTCMT_ORDER_LIST_REQ
    exporting
      !OUTPUT type Z01OTCMT_ORDER_LIST_RES
    raising
      Z01OTCCX_FMT_SALES_ORDER_LIST .
endinterface.
