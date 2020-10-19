class Z01OTC_CO_SI_INTREST_CHARGES_O definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods SI_INTREST_CHARGES_OUT
    importing
      !OUTPUT type Z01OTC_FATTURA_ELETTRONICA1
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS Z01OTC_CO_SI_INTREST_CHARGES_O IMPLEMENTATION.


method CONSTRUCTOR.

  super->constructor(
    class_name          = 'Z01OTC_CO_SI_INTREST_CHARGES_O'
    logical_port_name   = logical_port_name
  ).

endmethod.


method SI_INTREST_CHARGES_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SI_INTREST_CHARGES_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.
ENDCLASS.
