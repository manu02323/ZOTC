class Z01OTC_CL_SI_EDI850ORDERS_IN1 definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_EDI850ORDERS_IN .

  methods CONSTRUCTOR .
protected section.
private section.

  data ATTRV_PAYLOAD type ref to IF_WSPROTOCOL_PAYLOAD .
ENDCLASS.



CLASS Z01OTC_CL_SI_EDI850ORDERS_IN1 IMPLEMENTATION.


METHOD constructor.
***********************************************************************
*Program    : CONSTRUCTOR                                             *
*Title      : ZOTCCL_SALES_ORDER_EDI850~CONSTRUCTOR                   *
*Developer  : Monika Garg / Srinivasa G                               *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                      *
*---------------------------------------------------------------------*
* Description:: This Method is used to change the Proxy format to IDOC*
* Format and populate all the Idoc segments and Post the IDOC using   *
* IDOC_INBOUND_ASYNCHRONOUS for D2 Sites.                             *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG       E1DK918357      INITIAL DEVELOPMENT        *
*---------------------------------------------------------------------*

  DATA lref_server_context     TYPE REF TO if_ws_server_context. " Proxy Server Context

  TRY.
      lref_server_context  = cl_proxy_access=>get_server_context( ).

      attrv_payload ?= lref_server_context->get_protocol( protocol_name = if_wsprotocol=>payload ).
      CALL METHOD attrv_payload->set_extended_xml_handling
        EXPORTING
          extended_xml_handling = abap_true.
    CATCH  cx_ai_system_fault.

  ENDTRY.
ENDMETHOD.


METHOD z01otc_ii_si_edi850orders_in~si_edi850orders_in.
***********************************************************************
*Program    : CONSTRUCTOR                                             *
*Title      : ZOTCCL_SALES_ORDER_EDI850~CONSTRUCTOR                   *
*Developer  : Monika Garg / Srinivasa G                               *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                      *
*---------------------------------------------------------------------*
* Description:: This Method is used to change the Proxy format to IDOC*
* Format and populate all the Idoc segments and Post the IDOC using   *
* IDOC_INBOUND_ASYNCHRONOUS for D2 Sites.                             *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG       E1DK918357      INITIAL DEVELOPMENT        *
*---------------------------------------------------------------------*
  DATA: lref_service_impl TYPE REF TO zotccl_sales_order_edi850. " Sales Order EDI 850

* Deactivate extended XML-handling
  CALL METHOD me->attrv_payload->set_extended_xml_handling
    EXPORTING
      extended_xml_handling = abap_false.

  CREATE OBJECT lref_service_impl.

  SET UPDATE TASK LOCAL.

*Business Logic is encapsulated in service Class.
  lref_service_impl->start_processing( input ).

**Call FEH, if error occurred
  IF lref_service_impl->has_error( ) = abap_true.
    lref_service_impl->feh_execute( ).
  ENDIF. " IF lref_service_impl->has_error( ) = abap_true
ENDMETHOD.
ENDCLASS.
