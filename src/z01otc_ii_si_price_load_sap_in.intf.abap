interface Z01OTC_II_SI_PRICE_LOAD_SAP_IN
  public .


  methods MT_TRANSFER_PRICE_LOAD_SAP_PPM
    importing
      !INPUT type Z01OTC_MT_TRANSFER_PRICE_LOAD
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
endinterface.
