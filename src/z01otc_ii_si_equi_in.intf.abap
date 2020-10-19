interface Z01OTC_II_SI_EQUI_IN
  public .


  methods SI_EQUI_IN
    importing
      !INPUT type Z01OTC_MT_EQUI_REQ
    exporting
      !OUTPUT type Z01OTC_MT_EQUI_RES
    raising
      Z01OTC_CX_FMT_EQUI .
endinterface.
