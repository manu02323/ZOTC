class Z01OTC_CL_SI_RECEIVE_PRICE_IN definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_RECEIVE_PRICE_IN .

  methods CONSTRUCTOR .
protected section.
private section.

  data ATTRV_PAYLOAD type ref to IF_WSPROTOCOL_PAYLOAD .
ENDCLASS.



CLASS Z01OTC_CL_SI_RECEIVE_PRICE_IN IMPLEMENTATION.


method CONSTRUCTOR.
***************************************************************************
* Method     :  CONSTRUCTOR                                               *
* TITLE      :  Interface for receiving Price from  GAP   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA   E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203   *
*&------------------------------------------------------------------------*


  DATA lref_server_context     TYPE REF TO if_ws_server_context. " Proxy Server Context

  TRY.
      lref_server_context  = cl_proxy_access=>get_server_context( ).

      attrv_payload ?= lref_server_context->get_protocol( protocol_name = if_wsprotocol=>payload ).
      CALL METHOD attrv_payload->set_extended_xml_handling
        EXPORTING
          extended_xml_handling = abap_true.
    CATCH  cx_ai_system_fault.

  ENDTRY.
endmethod.


method Z01OTC_II_SI_RECEIVE_PRICE_IN~SI_RECEIVE_PRICE_IN.
***************************************************************************
* Method     :  CONSTRUCTOR                                               *
* TITLE      :  Interface for receiving Price from  GAP   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA   E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203   *
*&------------------------------------------------------------------------*


  DATA : lref_service_hand TYPE REF TO zotccl_receiveprice_imp. " Inbound Price condition upload IMP

  CALL METHOD me->attrv_payload->set_extended_xml_handling
    EXPORTING
      extended_xml_handling = abap_false.

  CREATE OBJECT lref_service_hand .

**This statement sets a “local update switch”. When it is set, the system interprets CALL FUNCTION
**IN UPDATE TASK as a request for local update. The update is processed in the same work process as
**the dialog step containing the COMMIT WORK. The transaction waits for the update to finish before
**continuing.
  SET UPDATE TASK LOCAL.

  lref_service_hand->execute( input ) .
endmethod.
ENDCLASS.
