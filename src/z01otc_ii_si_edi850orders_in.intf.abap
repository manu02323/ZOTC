interface Z01OTC_II_SI_EDI850ORDERS_IN
  public .


  methods SI_EDI850ORDERS_IN
    importing
      !INPUT type Z01OTC_ORDERS05
    raising
      Z01OTC_CX_STANDARD_MESSAGE_FAU .
endinterface.
