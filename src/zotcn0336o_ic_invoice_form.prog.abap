************************************************************************
* PROGRAM    :  ZOTCR0336O_IC_INVOICE_FORM                             *
* TITLE      :  EHQ_Delivery Output Routine                            *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0336                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Create intercompany invoice after PGI by calling       *
*                     BAPI_BILLINGDOC_CREATEMULTIPLE                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-JUN-2016 U033959  E1DK918578 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*


*&---------------------------------------------------------------------*
*&  Include           ZOTCN0336O_IC_INVOICE_FORM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_process
*&---------------------------------------------------------------------*
*       Process message
*----------------------------------------------------------------------*
*      -->FP_RETURN_CODE  return code
*      -->FP_US_SCREEN    screen
*----------------------------------------------------------------------*
FORM f_process USING fp_return_code TYPE sy-subrc " Return Value of ABAP Statements
                     fp_us_screen   TYPE c.       " Us_screen of type Character


*--TABLES--------------------------------------------------------------*
  DATA : li_billingdatain TYPE STANDARD TABLE OF bapivbrk,           " Communication Fields for Billing Header Fields
         li_delv_header   TYPE STANDARD TABLE OF ty_delivery_header, " Delivery header
         li_delv_items    TYPE STANDARD TABLE OF ty_delivery_items.  " Delivery item

*--VARIABLES-----------------------------------------------------------*
  DATA : lv_vbeln         TYPE vbeln_vl. " Delivery

*--FIELD SYMBOLS-------------------------------------------------------*
  FIELD-SYMBOLS : <lfs_nast> TYPE nast. " Message Status

  ASSIGN (c_nast) TO <lfs_nast>.
  lv_vbeln = <lfs_nast>-objky.

* Fetch delivery header and item data
  PERFORM f_fetch_delivery_data  USING    lv_vbeln       " delivery number
                                 CHANGING li_delv_header " develiry header
                                          li_delv_items. " delivery items

* Fill BAPI structure
  PERFORM f_fill_bapi_structure  USING    li_delv_header    " delivery header
                                          li_delv_items     " delivery items
                                 CHANGING li_billingdatain. " BAPI billing header fields

* Call BAPI to post invoice
  PERFORM f_create_billingdoc   USING    li_billingdatain " BAPI billing header fields
                                         lv_vbeln         " delivery number
                                CHANGING fp_return_code.  " return

ENDFORM. "f_process
*&      Form  F_FETCH_DELIVERY_DATA
*&---------------------------------------------------------------------*
*       Fetch delivery header and item
*----------------------------------------------------------------------*
*      -->FP_LV_VBELN        Delivery number
*      <--FP_LI_DELV_HEADER  Delivery header data
*      <--FP_LI_DELV_ITEMS   Develiry item data
*----------------------------------------------------------------------*
FORM f_fetch_delivery_data  USING    fp_lv_vbeln       TYPE vbeln_vl  " Delivery
                            CHANGING
                              fp_li_delv_header TYPE ty_t_delv_header " Delivery header
                              fp_li_delv_items  TYPE ty_t_delv_items. " Delivery item

  SELECT vbeln " Delivery
         vbtyp " SD document category
         vkoiv " Sales organization for intercompany billing
         vtwiv " Distribution channel for intercompany billing
         spaiv " Division for intercompany billing
         fkaiv " Billing type for intercompany billing
         fkdiv " Billing date for intercompany billing
         kuniv " Customer number for intercompany billing
    FROM likp  " SD Document: Delivery Header Data
    INTO TABLE fp_li_delv_header
    WHERE vbeln = fp_lv_vbeln.
  IF sy-subrc IS INITIAL.
    SELECT vbeln " Delivery
           posnr " Delivery Item
           pstyv " Delivery item category
           matnr " Material Number
           werks " Plant
           lfimg " Actual quantity delivered (in sales units)
           vrkme " Sales unit
      FROM lips  " SD document: Delivery: Item data
      INTO TABLE fp_li_delv_items
      WHERE vbeln = fp_lv_vbeln.
    IF sy-subrc IS INITIAL.
      SORT fp_li_delv_items BY vbeln posnr.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " F_FETCH_DELIVERY_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FILL_BAPI_STRUCTURE
*&---------------------------------------------------------------------*
*       Fill BAPI structure
*----------------------------------------------------------------------*
*      -->FP_LI_DELV_HEADER    Delivery header data
*      -->FP_LI_DELV_ITEMS     Delivery item data
*      <--FP_LI_BILLINGDATAIN  Communication Fields for Billing Header Fields
*----------------------------------------------------------------------*
FORM f_fill_bapi_structure  USING
                            fp_li_delv_header    TYPE ty_t_delv_header    " Delivery header data
                            fp_li_delv_items     TYPE ty_t_delv_items     " Delivery item data
                            CHANGING
                            fp_li_billingdatain  TYPE ty_t_billingdatain. " Communication Fields for Billing Header Fields
*---FIELD SYMBOLS------------------------------------------------------*
  FIELD-SYMBOLS :
       <lfs_delv_header>      TYPE ty_delivery_header, " Delivery header data
       <lfs_delv_items>       TYPE ty_delivery_items,  " Delivery item data
       <lfs_billing>          TYPE bapivbrk.           " Communication Fields for Billing Header Fields

* Read index 1 as header table will have only one record
  READ TABLE fp_li_delv_header ASSIGNING <lfs_delv_header> INDEX 1.
  IF sy-subrc IS INITIAL.
    LOOP AT fp_li_delv_items ASSIGNING <lfs_delv_items>.
      APPEND INITIAL LINE TO fp_li_billingdatain ASSIGNING <lfs_billing>.
*     Item number of the reference item
      <lfs_billing>-ref_item    = <lfs_delv_items>-posnr.
*     Material number
      <lfs_billing>-material    = <lfs_delv_items>-matnr.
*     Cumulative Order Quantity in Sales Units
      <lfs_billing>-req_qty     = <lfs_delv_items>-lfimg.
*     Sales unit
      <lfs_billing>-sales_unit  = <lfs_delv_items>-vrkme.
*     Plant
      <lfs_billing>-plant       = <lfs_delv_items>-werks.
*     Sales document item category
      <lfs_billing>-item_categ  = <lfs_delv_items>-pstyv.
      IF <lfs_delv_header> IS ASSIGNED.
*       Sales Organization
        <lfs_billing>-salesorg   = <lfs_delv_header>-vkoiv.
*       Distribution Channel
        <lfs_billing>-distr_chan = <lfs_delv_header>-vtwiv.
*       Division
        <lfs_billing>-division   = <lfs_delv_header>-spaiv.
*       Document number of the reference document(Delivery number)
        <lfs_billing>-ref_doc    = <lfs_delv_header>-vbeln.
*       Date for pricing and exchange rate
        <lfs_billing>-price_date = <lfs_delv_header>-fkdiv.
*       Billing date for billing index and printout
        <lfs_billing>-bill_date  = <lfs_delv_header>-fkdiv.
*       Proposed billing type for an order-related billing document
        <lfs_billing>-ordbilltyp = <lfs_delv_header>-fkaiv.
*       Payer
        <lfs_billing>-payer      = <lfs_delv_header>-kuniv.
*       Document category of preceding SD document
        <lfs_billing>-ref_doc_ca = <lfs_delv_header>-vbtyp.
      ENDIF. " IF <lfs_delv_header> IS ASSIGNED
      UNASSIGN <lfs_billing>.
    ENDLOOP. " LOOP AT fp_li_delv_items ASSIGNING <lfs_delv_items>
    UNASSIGN : <lfs_delv_items> , " delivery items
               <lfs_delv_header>. " delivery header
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " F_FILL_BAPI_STRUCTURE
*&---------------------------------------------------------------------*
*&      Form  F_BAPI_TEST_RUN
*&---------------------------------------------------------------------*
*       Test run BAPI before actual posting
*----------------------------------------------------------------------*
*      -->FP_LI_BILLINGDATAIN  Communication Fields for Billing Header Fields
*      <--FP_LI_SUCCESS        Information for Successfully Processing Billing Doc. Items
*      <--FP_LI_ERRORS         Information on Incorrect Processing of Preceding Items
*      <--FP_LI_RETURN         Return Parameter
*----------------------------------------------------------------------*
FORM f_bapi_test_run  USING  fp_li_billingdatain TYPE ty_t_billingdatain " Communication Fields for Billing Header Fields
                      CHANGING fp_li_success     TYPE ty_t_success       " Information for Successfully Processing Billing Doc. Items
                               fp_li_errors      TYPE ty_t_errors        " Information on Incorrect Processing of Preceding Items
                               fp_li_return      TYPE ty_t_return.       " Return Parameter

  CALL FUNCTION 'BAPI_BILLINGDOC_CREATEMULTIPLE'
    EXPORTING
      testrun       = abap_true
    TABLES
      billingdatain = fp_li_billingdatain
      errors        = fp_li_errors
      return        = fp_li_return
      success       = fp_li_success.

ENDFORM. " F_BAPI_TEST_RUN
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_BILLINGDOC
*&---------------------------------------------------------------------*
*       Create billing document
*----------------------------------------------------------------------*
*      -->FP_LI_BILLINGDATAIN  Communication Fields for Billing Header Fields
*      -->FP_LV_VBELN          Delivery number
*      <--FP_RETURN_CODE       Return code
*----------------------------------------------------------------------*
FORM f_create_billingdoc  USING
                             fp_li_billingdatain TYPE ty_t_billingdatain " Communication Fields for Billing Header Fields
                             fp_lv_vbeln         TYPE vbeln_vl           " Delivery number
                          CHANGING
                             fp_return_code      TYPE sy-subrc.          " Return code

*--TABLES--------------------------------------------------------------*
  DATA : li_errors        TYPE STANDARD TABLE OF bapivbrkerrors,  " Information on Incorrect Processing of Preceding Items
         li_return        TYPE STANDARD TABLE OF bapiret1,        " Return Parameter
         li_success       TYPE STANDARD TABLE OF bapivbrksuccess, " Information for Successfully Processing Billing Doc. Items
         li_billingdatain TYPE ty_t_billingdatain.                " Communication Fields for Billing Header Fields
* BAPI is called twice, once with test run mode and once for actual ---
* --- posting of data.
  PERFORM f_bapi_test_run USING    fp_li_billingdatain
                          CHANGING li_success
                                   li_errors
                                   li_return.
* Only if test run mode is successful, we call the BAPI again in a  ---
* --- background task. Return code is also cleared so that traffic  ---
* --- signal icon against the output type turns green.
  IF li_success IS NOT INITIAL.
    CLEAR fp_return_code.
*   assign to local table
    li_billingdatain = fp_li_billingdatain.
    CALL FUNCTION 'ZOTC_BILLINGDOC_CREATE' IN BACKGROUND TASK
      CHANGING
        chng_billingdatain = li_billingdatain.

  ELSE. " ELSE -> IF li_success IS NOT INITIAL
* Else if the BAPI runs into any error populate custom appl. log
    READ TABLE li_return WITH KEY type = c_error_e TRANSPORTING NO FIELDS. " Return with key of type
*   Binary search not included in READ as li_return will have very few records
    IF sy-subrc IS INITIAL.
*   implement error logging logic
      PERFORM f_create_application_log USING li_return    " BAPI return table
                                             fp_lv_vbeln. " Delivery number
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
*     Binary search not included in READ as li_return will have very few records
      READ TABLE li_return WITH KEY type = c_error_a TRANSPORTING NO FIELDS. " Return with key of type
      IF sy-subrc IS INITIAL.
*   implement error logging logic
        PERFORM f_create_application_log USING li_return    " BAPI return table
                                               fp_lv_vbeln. " Delivery number
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_success IS NOT INITIAL

ENDFORM. "f_create_billingdoc
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_APPLICATION_LOG
*&---------------------------------------------------------------------*
*       Create custom application log
*----------------------------------------------------------------------*
*      -->FP_LI_RETURN  Return parameter
*----------------------------------------------------------------------*
FORM f_create_application_log  USING    fp_li_return TYPE ty_t_return " Return parameter
                                        fp_lv_vbeln  TYPE vbeln_vl  . " Delivery

*--INTERNAL TABLE------------------------------------------------------*

  DATA : li_log_handle  TYPE bal_t_logh. " Application Log: Log Handle

*--WORK AREA-----------------------------------------------------------*
  DATA : lwa_log        TYPE bal_s_log,  " Application Log: Log header data
         lwa_log_handle TYPE balloghndl, " Application Log: Log Handle
         lwa_balmsg     TYPE bal_s_msg.  " Application Log: Message Data

*--FIELD SYMBOLS-------------------------------------------------------*
  FIELD-SYMBOLS : <lfs_bapiret1> TYPE bapiret1. " Return Parameter


  lwa_log-extnumber = fp_lv_vbeln.
  lwa_log-object    = c_object.
  lwa_log-subobject = c_sub_object.

  CALL FUNCTION 'BAL_LOG_CREATE'
    EXPORTING
      i_s_log                 = lwa_log
    IMPORTING
      e_log_handle            = lwa_log_handle
    EXCEPTIONS
      log_header_inconsistent = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0

  APPEND lwa_log_handle TO li_log_handle.

  LOOP AT fp_li_return ASSIGNING <lfs_bapiret1> .
    CLEAR lwa_balmsg.
    lwa_balmsg-msgty = <lfs_bapiret1>-type.
    lwa_balmsg-msgid = <lfs_bapiret1>-id.
    lwa_balmsg-msgno = <lfs_bapiret1>-number.
    lwa_balmsg-msgv1 = <lfs_bapiret1>-message_v1.
    lwa_balmsg-msgv2 = <lfs_bapiret1>-message_v2.
    lwa_balmsg-msgv3 = <lfs_bapiret1>-message_v3.
    lwa_balmsg-msgv4 = <lfs_bapiret1>-message_v4.

    CALL FUNCTION 'BAL_LOG_MSG_ADD'
      EXPORTING
        i_log_handle     = lwa_log_handle
        i_s_msg          = lwa_balmsg
      EXCEPTIONS
        log_not_found    = 1
        msg_inconsistent = 2
        log_is_full      = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT fp_li_return ASSIGNING <lfs_bapiret1>


  CALL FUNCTION 'BAL_DB_SAVE'
    EXPORTING
      i_save_all       = abap_true
      i_t_log_handle   = li_log_handle
    EXCEPTIONS
      log_not_found    = 1
      save_not_allowed = 2
      numbering_error  = 3
      OTHERS           = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_CREATE_APPLICATION_LOG
