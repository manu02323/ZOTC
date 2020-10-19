interface Z01OTC_II_SI_CPQPRICE_IN
  public .


  methods SI_CPQPRICE_IN
    importing
      !INPUT type Z01OTC_MT_CPQPRICE
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
endinterface.
