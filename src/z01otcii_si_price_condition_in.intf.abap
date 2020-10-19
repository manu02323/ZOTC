interface Z01OTCII_SI_PRICE_CONDITION_IN
  public .


  methods SI_PRICE_CONDITION_IN
    importing
      !INPUT type Z01OTCMT_PRICE_CONDITION
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
endinterface.
