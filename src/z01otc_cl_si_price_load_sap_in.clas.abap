class Z01OTC_CL_SI_PRICE_LOAD_SAP_IN definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_PRICE_LOAD_SAP_IN .

  methods CONSTRUCTOR .
protected section.
private section.

  data ATTRV_PAYLOAD type ref to IF_WSPROTOCOL_PAYLOAD .
ENDCLASS.



CLASS Z01OTC_CL_SI_PRICE_LOAD_SAP_IN IMPLEMENTATION.


METHOD constructor.
***************************************************************************
* Method     :  CONSTRUCTOR                                               *
* TITLE      :  Interface for receiving Price from  Quote System          *
* DEVELOPER  :  Deepanker Dwivedi                                         *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0042                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042   *
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

ENDMETHOD.


METHOD z01otc_ii_si_price_load_sap_in~mt_transfer_price_load_sap_ppm.
***************************************************************************
* PROGRAM :Z01OTC_II_SI_PRICE_LOAD_SAP_IN~MT_TRANSFER_PRICE_LOAD_SAP_PPM  *
* TITLE      :  Interface for receiving Price from  Quote System          *
* DEVELOPER  :  Deepanker Dwivedi                                         *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0042                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042   *
*&------------------------------------------------------------------------*


  DATA : lref_service_hand TYPE REF TO zotccl_price_condition_imp. " Inbound Price condition upload IMP

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

ENDMETHOD.
ENDCLASS.
