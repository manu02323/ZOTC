class Z01OTC_CL_SI_CPQPRICE_IN definition
  public
  create public .

public section.

  interfaces Z01OTC_II_SI_CPQPRICE_IN .

  methods CONSTRUCTOR .
protected section.
private section.

  data ATTRV_PAYLOAD type ref to IF_WSPROTOCOL_PAYLOAD .
ENDCLASS.



CLASS Z01OTC_CL_SI_CPQPRICE_IN IMPLEMENTATION.


  METHOD constructor.
***************************************************************************
* Method     :  CONSTRUCTOR                                               *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 05-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
    DATA lr_server_context     TYPE REF TO if_ws_server_context. " Proxy Server Context

    TRY.
        lr_server_context  = cl_proxy_access=>get_server_context( ).

        attrv_payload ?= lr_server_context->get_protocol( protocol_name = if_wsprotocol=>payload ).

        CALL METHOD attrv_payload->set_extended_xml_handling
          EXPORTING
            extended_xml_handling = abap_true.

      CATCH  cx_ai_system_fault ##NO_HANDLER.
    ENDTRY.
  ENDMETHOD.


  METHOD z01otc_ii_si_cpqprice_in~si_cpqprice_in.
***************************************************************************
* Method     :  CONSTRUCTOR                                               *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 05-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
    DATA : lr_price_inbound TYPE REF TO zotccl_cpq_price_cond_inbound. " Inbound Price condition from CPQ

    CALL METHOD me->attrv_payload->set_extended_xml_handling
      EXPORTING
        extended_xml_handling = abap_false.

    CREATE OBJECT lr_price_inbound .

**This statement sets a “local update switch”. When it is set, the system interprets CALL FUNCTION
**IN UPDATE TASK as a request for local update. The update is processed in the same work process as
**the dialog step containing the COMMIT WORK. The transaction waits for the update to finish before
**continuing.
    SET UPDATE TASK LOCAL.

    lr_price_inbound->execute( input ) .

  ENDMETHOD.
ENDCLASS.
