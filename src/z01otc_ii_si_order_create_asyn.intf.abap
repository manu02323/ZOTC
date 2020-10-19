interface Z01OTC_II_SI_ORDER_CREATE_ASYN
  public .


  methods SI_ORDER_CREATE_ASYNC_IN
    importing
      !INPUT type SLS_SALES_ORDER_ERPCREATE_REQ1
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
endinterface.
