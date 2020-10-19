interface Z01OTC_II_SI_EDPAR_IN
  public .


  methods SI_EDPAR_IN
    importing
      !INPUT type Z01OTCMT_EDPAR_REQ
    exporting
      !OUTPUT type Z01OTCMT_EDPAR_RES
    raising
      Z01OTCCX_FMT_EDPAR .
endinterface.
