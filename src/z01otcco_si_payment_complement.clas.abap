class Z01OTCCO_SI_PAYMENT_COMPLEMENT definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods SI_PAYMENT_COMPLEMENT_3_3_IN
    importing
      !OUTPUT type Z01OTCMT_PAYMENT_COMPLEMENT_3
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS Z01OTCCO_SI_PAYMENT_COMPLEMENT IMPLEMENTATION.


method CONSTRUCTOR.

  super->constructor(
    class_name          = 'Z01OTCCO_SI_PAYMENT_COMPLEMENT'
    logical_port_name   = logical_port_name
  ).

endmethod.


method SI_PAYMENT_COMPLEMENT_3_3_IN.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SI_PAYMENT_COMPLEMENT_3_3_IN'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.
ENDCLASS.
