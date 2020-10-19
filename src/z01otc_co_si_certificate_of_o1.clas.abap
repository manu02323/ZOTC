class Z01OTC_CO_SI_CERTIFICATE_OF_O1 definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods SO_ADD_ARTICLE_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_ADD_A1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_ADD_AR
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_ADD_DOCUMENT_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_ADD_D1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_ADD_DO
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_CREATE_REQUEST_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_CREATE
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_CREAT1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_EXPORTER_DATA_REQUEST_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SET_EX
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SET_E1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_GLOBAL_ORIGIN_COUNTRY_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SET_G1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SET_GL
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_LOGIN_REQUEST_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_LOG_I1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_LOG_I3
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_LOGOUT_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_LOG_O1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_LOG_OU
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_SET_COPIES_NB_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SET_C1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SET_CO
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_SET_MULTIPLE_ORIGINALS_S_OU
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SET_M1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SET_MU
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_SET_RECEIVER_DATA_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SET_R1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SET_RE
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_SUBMIT_REQUEST_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SUBMI1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SUBMIT
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
  methods SO_TOTAL_GROSS_WEIGHT_S_OUT
    importing
      !OUTPUT type Z01OTC_IREQUEST_SERVICE_SET_T1
    exporting
      !INPUT type Z01OTC_IREQUEST_SERVICE_SET_TO
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
protected section.
private section.
ENDCLASS.



CLASS Z01OTC_CO_SI_CERTIFICATE_OF_O1 IMPLEMENTATION.


method CONSTRUCTOR.

  super->constructor(
    class_name          = 'Z01OTC_CO_SI_CERTIFICATE_OF_O1'
    logical_port_name   = logical_port_name
  ).

endmethod.


method SO_ADD_ARTICLE_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_ADD_ARTICLE_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_ADD_DOCUMENT_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_ADD_DOCUMENT_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_CREATE_REQUEST_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_CREATE_REQUEST_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_EXPORTER_DATA_REQUEST_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_EXPORTER_DATA_REQUEST_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_GLOBAL_ORIGIN_COUNTRY_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_GLOBAL_ORIGIN_COUNTRY_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_LOGIN_REQUEST_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_LOGIN_REQUEST_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_LOGOUT_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_LOGOUT_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_SET_COPIES_NB_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_SET_COPIES_NB_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_SET_MULTIPLE_ORIGINALS_S_OU.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_SET_MULTIPLE_ORIGINALS_S_OU'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_SET_RECEIVER_DATA_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_SET_RECEIVER_DATA_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_SUBMIT_REQUEST_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_SUBMIT_REQUEST_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.


method SO_TOTAL_GROSS_WEIGHT_S_OUT.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'SO_TOTAL_GROSS_WEIGHT_S_OUT'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.
ENDCLASS.
