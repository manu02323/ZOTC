class ZOTCCL_PRICE_CONDITION_IMP definition
  public
  final
  create public .

public section.

  interfaces IF_ECH_ACTION .

  constants GC_FLTM_CLASS type CLASSNAME value 'CX_MDG_BS_STD_MSG_FAULT'. "#EC NOTEXT

  methods EXECUTE
    importing
      !IM_INPUT type Z01OTC_MT_TRANSFER_PRICE_LOAD
    raising
      resumable(CX_SAPPLCO_STANDARD_MSG_FAULT) .
  methods CONSTRUCTOR .
protected section.
private section.

  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
  methods FEH_PREPARE
    importing
      !IM_INPUT_ERROR type Z01OTC_MT_TRANSFER_PRICE_LOAD
      !IM_INPUT type Z01OTC_MT_TRANSFER_PRICE_LOAD .
ENDCLASS.



CLASS ZOTCCL_PRICE_CONDITION_IMP IMPLEMENTATION.


method CONSTRUCTOR.
endmethod.


METHOD execute.
****************************************************************************
* Method     :EXECUTE
* TITLE      :  Interface for receiving Price from  Quote System          *
* DEVELOPER  :  Deepanker Dwivedi                                         *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0042_DEFEC#9621                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form PPM                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 27-Jan-2017 DDWIVEDI  E1DK919349  INITIAL DEVELOPMENT/D3_OTC_IDD_0042_  *
*                                   DEFECT_9621                           *
*&------------------------------------------------------------------------*
* Constants
  CONSTANTS:
    lc_enh_name           TYPE z_enhancement   VALUE 'OTC_IDD_0042'. " Enhancement No.

  DATA:
    li_enh_status         TYPE STANDARD TABLE OF zdev_enh_status,    " Enhancement Status
    lref_service_impl     TYPE REF TO zotccl_price_condition_load3,  " Inbound Price condition upload
    ls_single_message_in  TYPE  z01otc_dt_transfer_price_load1,      " Proxy Structure (generated)
    lx_msg_rcords         TYPE REF TO cx_sapplco_standard_msg_fault. " Standard Message Fault

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

  LOOP AT im_input-mt_transfer_price_load_sap-recordset-record INTO ls_single_message_in .
    SET UPDATE TASK LOCAL .
    lref_service_impl->gi_enh_status[] = li_enh_status[].
**Business Logic is encapsulated in service Class.
    lref_service_impl->process_data( ls_single_message_in ).
  ENDLOOP. " LOOP AT im_input-mt_transfer_price_load_sap-recordset-record INTO ls_single_message_in
  lref_service_impl->feh_execute( ).
ENDMETHOD.


method FEH_EXECUTE.
endmethod.


method FEH_PREPARE.
endmethod.
ENDCLASS.
