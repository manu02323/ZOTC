class Z01OTCCL_SI_PRICE_CONDITION_IN definition
  public
  create public .

public section.

  interfaces Z01OTCII_SI_PRICE_CONDITION_IN .

  data ATTRV_MSG_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .
protected section.
private section.

  class-data ATTRV_ECH_ACTION type ref to Z01OTCCL_SI_PRICE_CONDITION_IN .
  constants ATTRC_MSGID type ARBGB value 'ZOTC_MSG'. "#EC NOTEXT
  data ATTRV_FEH_DATA type ZCA_TT_FEH_DATA .
  data ATTRV_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_PRO_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .
ENDCLASS.



CLASS Z01OTCCL_SI_PRICE_CONDITION_IN IMPLEMENTATION.


METHOD z01otcii_si_price_condition_in~si_price_condition_in.
************************************************************************
* PROGRAM    :  Z01OTCII_SI_PRICE_CONDITION_IN~SI_PRICE_CONDITION_IN   *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul,Pallavi Gupta                               *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349   INITIAL DEVELOPMENT               *
*&---------------------------------------------------------------------*


  DATA: lref_service_impl TYPE REF TO zotccl_price_condition_load . " Inbound Price condition upload

  CREATE OBJECT lref_service_impl.

**This statement sets a “local update switch”. When it is set, the system interprets CALL FUNCTION
**IN UPDATE TASK as a request for local update. The update is processed in the same work process as
**the dialog step containing the COMMIT WORK. The transaction waits for the update to finish before
**continuing.
  SET UPDATE TASK LOCAL.

**Business Logic is encapsulated in service Class.
    lref_service_impl->process_data( input ).

**Call FEH, if error occurred
  IF lref_service_impl->has_error( ) = abap_true.
    lref_service_impl->feh_execute( ).
  ENDIF. " IF lref_service_impl->has_error( ) = abap_true
ENDMETHOD.
ENDCLASS.
