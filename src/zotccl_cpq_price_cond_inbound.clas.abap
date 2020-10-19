class ZOTCCL_CPQ_PRICE_COND_INBOUND definition
  public
  final
  create public .

public section.

  methods EXECUTE
    importing
      !IM_INPUT type Z01OTC_MT_CPQPRICE
    raising
      CX_SAPPLCO_STANDARD_MSG_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZOTCCL_CPQ_PRICE_COND_INBOUND IMPLEMENTATION.


  METHOD execute.
***************************************************************************
* Method     :  EXECUTE                                              *
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
    CONSTANTS:
      c_enh_name           TYPE z_enhancement   VALUE 'D3_OTC_IDD_0230'. " Enhancement No.

    DATA:
      i_enh_status         TYPE STANDARD TABLE OF zdev_enh_status,    " Enhancement Status
      lr_service_impl      TYPE REF TO zotccl_cpq_price_cond_load,    " Inbound Price condition upload
      wa_single_message_in TYPE  z01otc_dt_cpqprice_record.           " Proxy Structure (generated)

* Get EMI Entries at begining of Proxy Call
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = c_enh_name
      TABLES
        tt_enh_status     = i_enh_status[].

    IF i_enh_status[] IS NOT INITIAL.
      DELETE i_enh_status WHERE active IS INITIAL.
    ENDIF. " IF li_enh_status[] IS NOT INITIAL

    "Get reference for object
    CREATE OBJECT lr_service_impl.

    LOOP AT im_input-mt_cpqprice-recordset-record INTO wa_single_message_in .
      SET UPDATE TASK LOCAL .
      lr_service_impl->gi_enh_status[] = i_enh_status[].
**Business Logic is encapsulated in service Class.
      lr_service_impl->process_data( wa_single_message_in ).
    ENDLOOP. " im_input-mt_cpqprice-recordset-record INTO wa_single_message_in .

    lr_service_impl->feh_execute( ).

  ENDMETHOD.
ENDCLASS.
