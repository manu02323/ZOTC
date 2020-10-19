interface Z01OTC_II_SI_RECEIVE_PRICE_IN
  public .


  methods SI_RECEIVE_PRICE_IN
    importing
      !INPUT type Z01OTC_MT_RECEIVE_PRICE
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
endinterface.
