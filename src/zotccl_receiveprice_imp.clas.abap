class ZOTCCL_RECEIVEPRICE_IMP definition
  public
  create public .

public section.

  methods EXECUTE
    importing
      !IM_INPUT type Z01OTC_MT_RECEIVE_PRICE
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZOTCCL_RECEIVEPRICE_IMP IMPLEMENTATION.


method EXECUTE.
****************************************************************************
* Method     :EXECUTE
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9583                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9583                           *
*&------------------------------------------------------------------------*
* Constants
  CONSTANTS:
    lc_enh_name           TYPE z_enhancement   VALUE 'OTC_IDD_0203'. " Enhancement No.

  DATA:
    li_enh_status          TYPE STANDARD TABLE OF zdev_enh_status,    " Enhancement Status
    lref_service_impl      TYPE REF TO zotccl_receiveprice_load,  " Inbound Price condition upload
    lwa_single_message_in  TYPE  Z01OTC_DT_RECEIVE_PRICE_RECOR1,      " Proxy Structure (generated)
    lx_msg_rcords          TYPE REF TO cx_sapplco_standard_msg_fault. " Standard Message Fault

* For perforamnce reasons, calling EMI only at the begining of proxy call
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_enh_status[].
  IF li_enh_status[] IS NOT INITIAL.
    DELETE li_enh_status WHERE active IS INITIAL.
  ENDIF. " IF li_enh_status[] IS NOT INITIAL

  CREATE OBJECT lref_service_impl.

  LOOP AT im_input-mt_receive_price-recordset-record INTO lwa_single_message_in .
    SET UPDATE TASK LOCAL .
    lref_service_impl->gi_enh_status[] = li_enh_status[].
**Business Logic is encapsulated in service Class.
    lref_service_impl->process_data( lwa_single_message_in ).
  ENDLOOP. " LOOP AT im_input-mt_transfer_price_load_sap-recordset-record INTO ls_single_message_in
  lref_service_impl->feh_execute( ).
endmethod.
ENDCLASS.
