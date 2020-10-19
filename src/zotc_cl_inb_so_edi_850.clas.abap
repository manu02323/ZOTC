class ZOTC_CL_INB_SO_EDI_850 definition
  public
  final
  create public .

public section.

  class-methods CLASS_CONSTRUCTOR .
  methods DETERMINE_SOLD_TO
    importing
      !IM_INPUT_HEAD type EDI_DC40_TT
    changing
      !CH_ITEM type EDI_DD40_TT
      !CH_OUTPUT type ZOTC_SOLDTO_SHIPTO
    exceptions
      NO_SALES_DATA_FOUND
      NO_EDSDC_ENTRY
      NO_SOLDTO_SHIPTO .
  methods DETERMINE_SOLD_TO_COUNTRY
    importing
      !IM_KUNNR_SP type KUNNR_AG
    exporting
      !EX_LAND1 type LAND1
      !EX_LRD type BOOLEAN
      !EX_SKIP type BOOLEAN .
  methods DETERMINE_ORDERS
    importing
      !IM_HEAD type ZOTC_850_SO_HEADER
    changing
      !CH_ITEM type ZOTC_TT_850_SO_ITEM .
  methods PROCESS_LRD
    importing
      !IM_LAND1 type LAND1
    exporting
      !EX_BAPI_MSG type BAPIRETTAB
    changing
      !CH_ITEM type ZOTC_TT_850_SO_ITEM
    exceptions
      MATERIAL_CLASS_NOT_FOUND .
  methods PROCESS_NLRD
    exporting
      !EX_BAPI_MSG type BAPIRETTAB
    changing
      !CH_ITEM type ZOTC_TT_850_SO_ITEM
    exceptions
      LAB_OFFICE_NOT_MAINTAINED .
  methods BAPI_SIMULATE
    importing
      !IM_HEAD type ZOTC_850_SO_HEADER
    changing
      !CH_ITEM type ZOTC_TT_850_SO_ITEM .
  methods PREPARE_EDI_SPLIT
    importing
      !IM_SP type KUNNR_AG
      !IM_LRD type CHAR1
      !IM_SP_LAND type LAND1
      !IM_HEAD type EDI_DC40_TT
      !IM_ITEM type ZOTC_TT_850_SO_ITEM
    changing
      !CH_ITEM type EDI_DD40_TT
    exceptions
      NO_SALES_DATA_FOUND .
  methods VAIDATE_MATERIAL
    importing
      !IM_ITEM type ZOTC_TT_850_SO_ITEM
    exporting
      !EX_BAPI_MSG type BAPIRETTAB
    exceptions
      MATERIAL_NOT_FOUND .
protected section.
private section.
ENDCLASS.



CLASS ZOTC_CL_INB_SO_EDI_850 IMPLEMENTATION.


METHOD bapi_simulate.
***********************************************************************
*Program    : BAPI_SIMULATE                                          *
*Title      : ZOTC_CL_INB_SO_EDI_850~BAPI_SIMULATE                    *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
***********************************************************************
*(DETERMINE_SOLD_TO_COUNTRY) ::This Method is used for Non EDI Orders *
* determine the Sold country and also to determine wether the Sold to *
* Country belongs to LRD or Non LRD                                   *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*03-JAN-2017   U033867       E1DK922318   D3_OTC_EDD_0362:Defect#7913,*
*                                         Implement the logic of      *
*                                         populating Contract as      *
*                                         reference document and link *
*                                         it to Sales order           *
*&--------------------------------------------------------------------*
* 03-03-2017   NALI          E1DK926119   D3_CR#378:                  *
*                                         1.  The Sales Office value  *
*                                         should be passed to the BAPI*
*                                         to field E1BPSDHD1-SALES_OFF*
*                                         (SAP Field VBAK-VKBUR) for  *
*                                         all sales orders created    *
*                                         2.  The Delivery Block      *
*                                         should be passed to the BAPI*
*                                         to field E1BPSDHD1-DLV_BLOCK*
*                                         (SAP Field VBAK- LIFSK for  *
*                                         all sales orders created.   *
*&--------------------------------------------------------------------*


  TYPES : BEGIN OF ty_post,
          vkorg TYPE  vkorg,    " Sales Organization
          matnr TYPE  matnr,    " Material Number
          maktx TYPE  maktx,    " Material Description (Short Text)
          kwmeng   TYPE kwmeng, " Cumulative Order Quantity in Sales Units
          charg	 TYPE	charg_d,
         END OF ty_post,
*Begin of change for for defect#7913 by u033867
         BEGIN OF lty_trg_typ,
           vkorg TYPE vkorg,                           " Sales Organization
           mvalue2 TYPE z_mvalue_high,                 " Select Options: Value High
         END OF  lty_trg_typ,

         BEGIN OF lty_item_temp,
           matnr TYPE  matnr,                          " Material Number
           vkorg TYPE  vkorg,                          " Sales Organization
           vbeln TYPE  vbeln,                          " Sales and Distribution Document Number
           posnr TYPE  posnr,                          " Item number of the SD document                               " Message Text
           mvalue2 TYPE auart,                         " Select Options: Value High
         END OF  lty_item_temp,

         BEGIN OF lty_item,
           matnr TYPE matnr,                           " Material Number
           vkorg TYPE vkorg,                         " Sales Organization
           vtweg TYPE  vtweg ,                       " Distribution Channel
           auart TYPE auart,                         " Sales Document Type
           kunnr_ag TYPE kunnr,                           " Customer Number
           vbeln TYPE vbeln,                           "Contract no
           posnr TYPE posnr,                           "Contract Item
           datab TYPE datab_vi,                        "Contract valid from
           datbi TYPE datbi_vi,                        "Contract valid to
           kunnr_we TYPE kunnr,                      " Customer Number
         END OF lty_item,

           lty_t_item TYPE STANDARD TABLE OF lty_item. " local internal table

*End of change for for defect#7913 by u033867
  DATA:
      li_final          TYPE  zotc_tt_850_so_item,
      li_post           TYPE STANDARD TABLE OF ty_post INITIAL SIZE 0,
      li_return         TYPE TABLE OF bapiret2,    " Return Parameter
      li_order_items_in TYPE TABLE OF bapisditm,   " Communication Fields: Sales and Distribution Document Item
      li_order_partner  TYPE TABLE OF bapiparnr,   " Communications Fields: SD Document Partner: WWW
      li_order_schedule TYPE TABLE OF bapischdl,   " Communication Fields for Maintaining SD Doc. Schedule Lines
      li_order_text     TYPE TABLE OF bapisdtext,  " Communication fields: SD texts
      li_partneraddresses TYPE TABLE OF bapiaddr1, " BAPI Reference Structure for Addresses (Org./Company)
*Begin of change for for defect#7913 by u033867
      li_trg_typ         TYPE STANDARD TABLE OF lty_trg_typ,
      li_item_temp        TYPE STANDARD TABLE OF lty_item_temp,
      li_item                TYPE lty_t_item,
      lwa_item_tmp         TYPE lty_item_temp,
*End of change for for defect#7913 by u033867
      lwa_order_items_in  TYPE bapisditm,         " Communication Fields: Sales and Distribution Document Item
      lwa_order_partner   TYPE bapiparnr,         " Communications Fields: SD Document Partner: WWW
      lwa_order_schedule  TYPE bapischdl,         " Communication Fields for Maintaining SD Doc. Schedule Lines
      lwa_order_text      TYPE bapisdtext,        " Communication fields: SD texts
      lwa_order_header_in TYPE bapisdhd1,         " Communication Fields: Sales and Distribution Document Header
      lwa_partneraddresses TYPE bapiaddr1,        " BAPI Reference Structure for Addresses (Org./Company)
      lwa_cust_addr       TYPE bapicustomer_04,   " BAPI Interface Structure/GetDetail/General Data
      lwa_cust_gen        TYPE bapicustomer_kna1, "#EC NEEDED
      lwa_return         TYPE bapiret2,           " Return Parameter
      lwa_post           TYPE ty_post,
*      lv_index           TYPE index,               " Index of the valid record
      lv_vbeln  TYPE bapivbeln-vbeln, " Sales Document
      lv_posnr  TYPE posnr_va,        " Sales Document Item
      lv_test TYPE flag,              " General Flag
      lv_flag TYPE flag,              "#EC NEEDED  " Error or Success flag
      lv_type TYPE bapi_mtype,
      lv_bapi_msg TYPE string.        " Error capture in BAPI

* Local constants
  CONSTANTS: lc_smsg TYPE char1        VALUE   'S',     " constant declaration for 'S' success message type
             lc_emsg TYPE char1        VALUE   'E',     " constant declaration for 'E' Error message type
             lc_amsg TYPE char1        VALUE   'A',     " constant declaration for 'A' Error message type
             lc_99999 TYPE char5       VALUE   '99999', " 99999 of type CHAR5
             lc_sep  TYPE char1        VALUE    '/',    " Sep of type CHAR1
*Begin of change for for defect#7913 by u033867
             lc_mprogram   TYPE char30  VALUE 'ZIM_OTC_RR_CONTRACT_REF', "Program name
             lc_mparameter TYPE char05  VALUE 'AUART',                   "Parameter KSCHL
             lc_on         TYPE char1   VALUE 'X',                       "Flag ON
             lc_parvw_we   TYPE parvw   VALUE 'WE',                      " Partner Function
             lc_doc_cat    TYPE vbtyp_v VALUE 'G',                       " Document category of preceding SD document
             lc_option_eq  TYPE char2   VALUE 'EQ'.                      "Option - EQ.
*End of change for for defect#7913 by u033867
  FIELD-SYMBOLS :  <lfs_item>       TYPE lty_item,
                   <lfs_input_item> TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
                   <lfs_trg_typ>    TYPE lty_trg_typ,
                   <lfs_final>      TYPE zotc_850_so_item. " Sales Order Item for IDD 0009 - 850

  li_final = ch_item.

  SORT li_final BY vkorg.
  LOOP AT li_final ASSIGNING <lfs_final> WHERE type IS INITIAL.
    MOVE-CORRESPONDING <lfs_final> TO lwa_post.
    APPEND lwa_post TO li_post.
  ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final> WHERE type IS INITIAL
**  In run in test mode
**  BAPI will be run in test Mode
  IF im_head-testrun EQ abap_true.
    lv_test = abap_true.
  ENDIF. " IF im_head-testrun EQ abap_true

  lwa_order_header_in-doc_type = im_head-auart. " Order Type
  lwa_order_header_in-distr_chan = im_head-vtweg.
  lwa_order_header_in-purch_no_c = im_head-bstnk. " Po No
  lwa_order_header_in-purch_date = im_head-bstdk. " PO Date
  lwa_order_header_in-po_method = im_head-bsark. " PO method
  lwa_order_header_in-ship_cond = im_head-vsbed.
*  lwa_order_header_in-dlv_block = lwa_final-lifsk. " Delivery block (document header)
* ---> Begin of Change for D3_OTC_EDD_0362_CR#378 by NALI
  lwa_order_header_in-dlv_block = im_head-lifsk. " Delivery Bolck
  lwa_order_header_in-sales_off = im_head-vkbur. " Sales Office
* <--- End of Change for D3_OTC_EDD_0362_CR#378 by NALI
*&--populating the partner table and sold to party
  lwa_order_partner-partn_role = 'AG'.
  lwa_order_partner-partn_numb = im_head-kunnr_ag.
  APPEND lwa_order_partner TO li_order_partner.
  CLEAR lwa_order_partner.
  IF im_head-kunnr_we IS NOT INITIAL.
*&--populating the partner table with ship to party
    lwa_order_partner-partn_role = 'WE'. "'SH'."c_shipto.
    lwa_order_partner-partn_numb = im_head-kunnr_we.
    lwa_order_partner-addr_link = lwa_order_partner-partn_numb.

    APPEND lwa_order_partner TO li_order_partner.
    CLEAR lwa_order_partner.

    CALL FUNCTION 'BAPI_CUSTOMER_GETDETAIL2'
      EXPORTING
        customerno                  = im_head-kunnr_we
*       COMPANYCODE                 =
      IMPORTING
        customeraddress             = lwa_cust_addr
        customergeneraldetail       = lwa_cust_gen
*       CUSTOMERCOMPANYDETAIL       =
*       RETURN                      =
*     TABLES
*       CUSTOMERBANKDETAIL          =
              .

    MOVE-CORRESPONDING lwa_cust_addr TO lwa_partneraddresses.

    lwa_partneraddresses-addr_no    = im_head-kunnr_we. "lwa_cust_gen-address.
    lwa_partneraddresses-tel1_numbr  = lwa_cust_addr-telephone. "TEL1_NUMBR.
    lwa_partneraddresses-postl_cod1 = lwa_cust_addr-postl_code.
    lwa_partneraddresses-floor      = im_head-floor.
* ---> Begin of Change for D3_OTC_EDD_0362_Defect#6929 by MGARG
*    lwa_partneraddresses-building   = im_head-ad_bldng.
    lwa_partneraddresses-build_long   = im_head-ad_bldng.
* ---> End of Change for D3_OTC_EDD_0362_Defect#6929 by MGARG
    lwa_partneraddresses-room_no    = im_head-ad_roomnum.

    APPEND lwa_partneraddresses TO li_partneraddresses.
    CLEAR : lwa_partneraddresses.

  ENDIF. " IF im_head-kunnr_we IS NOT INITIAL


*&--populating the partner table with contact person
  lwa_order_partner-partn_role = 'AP' . "'CP Contact Person
  IF im_head-kunnr_cp  IS NOT INITIAL.
    lwa_order_partner-partn_numb = im_head-kunnr_cp.
  ELSE. " ELSE -> IF im_head-kunnr_cp IS NOT INITIAL
    lwa_order_partner-partn_numb = lc_99999.
  ENDIF. " IF im_head-kunnr_cp IS NOT INITIAL

  lwa_order_partner-addr_link = lwa_order_partner-partn_numb.
  lwa_order_partner-name  =  im_head-name1_gp.
  lwa_order_partner-telephone =  im_head-telf1.

  APPEND lwa_order_partner TO li_order_partner.
  CLEAR lwa_order_partner.



**&--populating the partner table with contact person Email and Address

  IF im_head-kunnr_cp IS INITIAL.
    lwa_partneraddresses-addr_no  = lc_99999.
  ELSE. " ELSE -> IF im_head-kunnr_cp IS INITIAL
    lwa_partneraddresses-addr_no    = im_head-kunnr_cp.
  ENDIF. " IF im_head-kunnr_cp IS INITIAL

  lwa_partneraddresses-name       = im_head-name1_gp.
  lwa_partneraddresses-tel1_numbr = im_head-telf1.
  lwa_partneraddresses-e_mail     = im_head-ad_smtpadr.
*  lwa_partneraddresses-floor      = im_head-floor.
*    lwa_partneraddresses-floor      = im_head-floor.
*    lwa_partneraddresses-building   = im_head-ad_bldng.
*    lwa_partneraddresses-room_no    = im_head-ad_roomnum.
  APPEND lwa_partneraddresses TO li_partneraddresses.
  CLEAR : lwa_partneraddresses.

*Populate Header text for ID 0002
  CLEAR : lwa_order_text.
  lwa_order_text-text_id    = '0002'.
  lwa_order_text-langu      = sy-langu.
  lwa_order_text-text_line  = im_head-edi4040_a.
  APPEND lwa_order_text TO li_order_text.

*Begin of change for defect#7913 by u033867

* ====================================================================== *
* 2) search for existing reference documents on database
* ====================================================================== *
  IF NOT li_post[] IS INITIAL.
    SELECT vkorg mvalue2           " Select Options: Value High
           FROM   zotc_prc_control " OTC Process Team Control Table
           INTO TABLE  li_trg_typ
           FOR ALL ENTRIES IN li_post
           WHERE  vkorg      = li_post-vkorg  AND
                  vtweg      = im_head-vtweg  AND
                  mprogram   = lc_mprogram    AND
                  mparameter = lc_mparameter  AND
                  mactive    = lc_on          AND
                  soption    = lc_option_eq   AND
                  mvalue1    = im_head-auart .
    IF sy-subrc IS INITIAL.
      SORT li_trg_typ BY vkorg.
      LOOP AT ch_item ASSIGNING <lfs_input_item>.
        lwa_item_tmp-matnr =  <lfs_input_item>-matnr. " Material Number
        lwa_item_tmp-vkorg =  <lfs_input_item>-vkorg. " Sales Organization
        lwa_item_tmp-vbeln =  <lfs_input_item>-vbeln. " Sales and Distribution Document Number
        lwa_item_tmp-posnr =  <lfs_input_item>-posnr. " Item number of the SD document
        LOOP AT li_trg_typ ASSIGNING <lfs_trg_typ>.
          IF <lfs_trg_typ>-vkorg = <lfs_input_item>-vkorg.
            lwa_item_tmp-mvalue2 = <lfs_trg_typ>-mvalue2.
            APPEND lwa_item_tmp TO   li_item_temp.
          ENDIF. " IF <lfs_trg_typ>-vkorg = <lfs_input_item>-vkorg

        ENDLOOP. " LOOP AT li_trg_typ ASSIGNING <lfs_trg_typ>
        CLEAR lwa_item_tmp .
      ENDLOOP. " LOOP AT ch_item ASSIGNING <lfs_input_item>
      SORT li_item_temp  BY matnr vkorg mvalue2 .
      DELETE  ADJACENT DUPLICATES FROM li_item_temp  COMPARING matnr vkorg mvalue2.
      IF NOT li_item_temp[] IS INITIAL.
* select respective contract document from database
        SELECT vapma~matnr                                   " Material Number
               vapma~vkorg " Sales Organization
               vapma~vtweg " Distribution Channel
               vapma~auart " Sales Document Type
               vapma~kunnr " Sold-to party
               vapma~vbeln " Sales and Distribution Document Number
               vapma~posnr " Item number of the SD document
               vapma~datab " Quotation or contract valid from
               vapma~datbi " Quotation or contract valid to
               vbpa~kunnr  " Sold-to party
               INTO TABLE li_item
               FROM vapma                                    " Sales Index: Order Items by Material
               INNER JOIN vbpa ON
               vapma~vbeln = vbpa~vbeln
             FOR ALL ENTRIES IN li_item_temp
                            WHERE vapma~matnr =  li_item_temp-matnr AND
                                  vapma~vkorg =  li_item_temp-vkorg AND
                                  vapma~vtweg =  im_head-vtweg      AND
                                  vapma~auart =  li_item_temp-mvalue2   AND
                                  vapma~kunnr =  im_head-kunnr_ag   AND
                                  vbpa~kunnr  =  im_head-kunnr_we  AND
                                  vbpa~parvw  =  lc_parvw_we. "'WE'.

        IF sy-subrc EQ 0.
*       Don't consider those contract for which 'Contract start date'
*       is in future. Means delete those contracts for which DATAB (Contract
*       start date) is greater than current date
*       Similarly, Don't consider those contract for which 'Contract End date'
*       is in Past. Means delete those contracts for which DATBI (Contract
*       end date) is less than current date
          DELETE li_item WHERE ( datab GT sy-datum )
                            OR ( datbi LT sy-datum ).
          IF li_item IS NOT INITIAL.
            SORT li_item BY  matnr  vkorg vtweg kunnr_ag kunnr_we   vbeln .
          ENDIF. " IF li_item IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " if not li_item_temp[] is INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF NOT li_post[] IS INITIAL


*End of change for defect#7913 by u033867


  LOOP AT li_post INTO lwa_post.
    lwa_order_header_in-sales_org = lwa_post-vkorg. " Sales org
    lv_posnr = lv_posnr + 10.
    lwa_order_items_in-itm_number = lv_posnr.
    lwa_order_items_in-material = lwa_post-matnr.
    lwa_order_items_in-target_qty = lwa_post-kwmeng.
    lwa_order_items_in-batch = lwa_post-charg.
*Begin of change for for defect#7913 by u033867
* In case mutiple contracts are found for a given Sold to, Ship to
* and Material. BADI will default the very first contract. Pick
* the contract with the least number.

    READ TABLE li_item  ASSIGNING  <lfs_item>  WITH  KEY matnr = lwa_post-matnr
                                                         vkorg = lwa_post-vkorg
                                                         vtweg = im_head-vtweg
                                                         kunnr_ag = im_head-kunnr_ag
                                                         kunnr_we = im_head-kunnr_we
                                                         BINARY SEARCH .
    IF sy-subrc IS INITIAL.


      lwa_order_items_in-ref_doc = <lfs_item>-vbeln .
*Reference document for this scenario will be always contract,so
*document category is considered as "G" as per business requirement
      lwa_order_items_in-ref_doc_ca = lc_doc_cat .
      lwa_order_items_in-ref_doc_it = <lfs_item>-posnr .


    ENDIF. " IF sy-subrc IS INITIAL

*End of change for for defect#7913 by u033867
    APPEND lwa_order_items_in TO li_order_items_in.
*Begin of change for for defect#7913 by u033867
    CLEAR: lwa_order_items_in.
*End of change for for defect#7913 by u033867
    lwa_order_schedule-itm_number = lv_posnr.
    lwa_order_schedule-req_date = sy-datum.
    lwa_order_schedule-req_qty = lwa_post-kwmeng.
    APPEND lwa_order_schedule TO li_order_schedule.

    AT END OF vkorg.
      CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
        EXPORTING
          order_header_in    = lwa_order_header_in
          testrun            = lv_test
          convert            = abap_true
        IMPORTING
          salesdocument      = lv_vbeln
        TABLES
          return             = li_return
          order_items_in     = li_order_items_in
          order_partners     = li_order_partner
          order_schedules_in = li_order_schedule
          order_text         = li_order_text
          partneraddresses   = li_partneraddresses
        EXCEPTIONS
          OTHERS             = 0.

* $ Populating Error for all line items and so loop is required
      CLEAR : lv_bapi_msg.

      LOOP AT li_return INTO lwa_return.
 " Capture Bapi Error Meassage
        IF lwa_return-type = lc_emsg OR lwa_return-type = lc_amsg.
          CONCATENATE lv_bapi_msg lwa_return-message
          INTO lv_bapi_msg
          SEPARATED BY lc_sep.
          lv_type = lwa_return-type.
        ENDIF. " IF lwa_return-type = lc_emsg OR lwa_return-type = lc_amsg
      ENDLOOP. " LOOP AT li_return INTO lwa_return

      IF lv_bapi_msg IS NOT INITIAL.
        IF lv_bapi_msg+0(1) = lc_sep.
          lv_bapi_msg = lv_bapi_msg+1.
        ENDIF. " IF lv_bapi_msg+0(1) = lc_sep
      ENDIF. " IF lv_bapi_msg IS NOT INITIAL

*      CLEAR : lv_flag.
      IF lv_bapi_msg IS INITIAL.
        lv_type = lc_smsg.
* Success in production or Test Mode.
        IF lv_vbeln IS NOT INITIAL. "  Success in Prod Mod
          lv_bapi_msg = lv_vbeln. " Polulate the Order Number
*&--BAPI commit
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.

        ELSE. " ELSE -> IF lv_vbeln IS NOT INITIAL
          lv_bapi_msg = 'Sales Order Can be Posted Successfully'(002).
        ENDIF. " IF lv_vbeln IS NOT INITIAL
      ELSE. " ELSE -> IF lv_bapi_msg IS INITIAL
        lv_flag = abap_true.
*&--BAPI rollback
        IF lv_test IS INITIAL.
          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
        ENDIF. " IF lv_test IS INITIAL
      ENDIF. " IF lv_bapi_msg IS INITIAL

      CONDENSE : lv_bapi_msg.

      LOOP AT li_final ASSIGNING <lfs_final> WHERE vkorg EQ lwa_post-vkorg.
        MOVE lv_vbeln TO <lfs_final>-vbeln.
        MOVE lv_type  TO <lfs_final>-type.
        MOVE lv_bapi_msg TO <lfs_final>-message.
        MODIFY li_final FROM <lfs_final> INDEX sy-tabix TRANSPORTING vbeln message type.
      ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final> WHERE vkorg EQ lwa_post-vkorg
      CLEAR: li_order_items_in[],li_order_schedule[],lv_posnr.
    ENDAT.
*    CLEAR : li_order_items_in,li_order_schedule,lv_posnr,lv_type.
    CLEAR : lv_type.
  ENDLOOP. " LOOP AT li_post INTO lwa_post
  ch_item = li_final.
ENDMETHOD.


method CLASS_CONSTRUCTOR.
endmethod.


METHOD determine_orders.
***********************************************************************
*Program    : DETERMINE_SOLD_TO                                       *
*Title      : ZOTC_CL_INB_SO_EDI_850~DETERMINE_SOLD_TO                *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP        CR -     CR-D3-84              *
*---------------------------------------------------------------------*
***********************************************************************
* Method (DETERMINE_Orders) :: This Mehod is used to determine sales  *
* Area for SKIP Logic Countries (D2 Sites). This method will Process  *
* Non EDI Orders EDD - 362                                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
* 04.07.2017 U033814  E1DK926790  Def# 2455: Batch Validation
*&--------------------------------------------------------------------*
*19-Aug-2019  SMUKHER E1SK901421           HANAtization changes       *
*09-Sep-2019  APODDAR E1SK901421           HANAtization changes       *


  TYPES : BEGIN OF ty_knvv,
           kunnr TYPE kunnr,   " Customer Number
           vkorg TYPE vkorg,   " Sales Organization
           vtweg TYPE vtweg,   " Distribution Channel
           spart TYPE spart,   " Division
          END OF ty_knvv,
          BEGIN OF ty_mcha,
           matnr TYPE matnr,   " Material Number
           werks TYPE werks_d, " Plant
           charg TYPE charg_d, " Batch Number
           vfdat TYPE vfdat,   " Shelf Life Expiration or Best-Before Date
          END OF ty_mcha,
* Begin of Defect - INC0329479
          BEGIN OF lty_mch1,
           matnr TYPE matnr,   " Material Number
           charg TYPE charg_d, " Batch Number
           vfdat TYPE vfdat,    " Shelf Life Expiration or Best-Before Date
          END OF lty_mch1,
* Begin of Defect - INC0329479
          BEGIN OF ty_temp,
           matnr TYPE matnr,     " Material Number
           werks TYPE werks_d,   " Plant
           charg TYPE charg_d,   " Batch Number
          END OF ty_temp,
          BEGIN OF ty_mvke,
           matnr TYPE matnr,     " Material Number
           vkorg TYPE vkorg,     " Sales Organization
           vtweg TYPE vtweg,     " Distribution Channel
           dwerk TYPE dwerk_ext, " Delivering Plant (Own or External)
          END OF ty_mvke.
  CONSTANTS : c_e    TYPE bapireturn-type VALUE 'E', " Message type: S Success, E Error, W Warning, I Info, A Abort
              c_mark TYPE char1           VALUE 'X', " Mark of type CHAR1
              c_msg1 TYPE symsgid VALUE 'VP',        " Message Class
              c_msg  TYPE symsgid VALUE 'V1'.        " Message Class
  DATA : li_temp_item TYPE zotc_tt_850_so_item,
         li_knvv TYPE STANDARD TABLE OF ty_knvv INITIAL SIZE 0,
         li_mvke TYPE STANDARD TABLE OF ty_mvke INITIAL SIZE 0,
         li_mcha TYPE STANDARD TABLE OF ty_mcha INITIAL SIZE 0,
         li_temp TYPE STANDARD TABLE OF ty_temp INITIAL SIZE 0,
         li_mch1 TYPE STANDARD TABLE OF lty_mch1,
         lwa_ret TYPE bapiret2,         " Return Parameter
         lwa_mch1 TYPE lty_mch1,
         ls_mvke TYPE ty_mvke,          " Batches (if Batch Management Cross-Plant)
         ls_mcha TYPE ty_mcha,
         ls_temp TYPE ty_temp,
         lv_error TYPE char1,           " Error of type CHAR1
         lv_par1  TYPE symsgv,          " Message Variable
         lv_par2  TYPE symsgv,          " Message Variable
         ls_knvv TYPE ty_knvv,
         ls_item TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
         lv_line TYPE sy-tabix.         " Index of Internal Tables

  DATA : lv_land1 TYPE land1,              " Country Key
         ls_head  TYPE zotc_850_so_header, " Sales Order Header for IDD 0009 - 850
         lv_lrd   TYPE char1,              " Lrd of type CHAR1
         lv_skip  TYPE char1.              " Skip of type CHAR1

  li_temp_item = ch_item .

  CALL METHOD me->determine_sold_to_country
    EXPORTING
      im_kunnr_sp = im_head-kunnr_ag
    IMPORTING
      ex_land1    = lv_land1
      ex_lrd      = lv_lrd
      ex_skip     = lv_skip.
*** Check to see if the split logic needs to skipped
  DATA : ex_bapi_msg TYPE bapirettab.
  IF lv_skip EQ abap_false.
* LRD Orders
    IF lv_lrd EQ abap_true.
      CALL METHOD me->process_lrd
        EXPORTING
          im_land1                 = lv_land1
        IMPORTING
          ex_bapi_msg              = ex_bapi_msg
        CHANGING
          ch_item                  = li_temp_item
        EXCEPTIONS
          material_class_not_found = 1
          OTHERS                   = 2.
    ELSE. " ELSE -> IF lv_lrd EQ abap_true
* Non LRD Orders
      CALL METHOD me->process_nlrd
        IMPORTING
          ex_bapi_msg               = ex_bapi_msg
        CHANGING
          ch_item                   = li_temp_item
        EXCEPTIONS
          lab_office_not_maintained = 1
          OTHERS                    = 2.
    ENDIF. " IF lv_lrd EQ abap_true
    ls_head = im_head.
  ELSE. " ELSE -> IF lv_skip EQ abap_false
    SELECT kunnr vkorg vtweg spart FROM knvv " Customer Master Sales Data
             INTO TABLE li_knvv WHERE kunnr EQ im_head-kunnr_ag.
    IF sy-subrc EQ 0.
      DESCRIBE TABLE li_knvv LINES lv_line.
      IF lv_line EQ 1.
        READ TABLE li_knvv INTO ls_knvv INDEX 1.
      ELSE. " ELSE -> IF lv_line EQ 1
        CLEAR lv_line.
        CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
          EXPORTING
            endpos_col   = 80
            endpos_row   = 25
            startpos_col = 1
            startpos_row = 1
            titletext    = 'Please select the sales area.'(001)
          IMPORTING
            choise       = lv_line
          TABLES
            valuetab     = li_knvv
          EXCEPTIONS
            break_off    = 1
            OTHERS       = 2.
        IF sy-subrc EQ 0.
          READ TABLE li_knvv INTO ls_knvv INDEX lv_line.
* Implement suitable error handling here
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_line EQ 1
      ls_head = im_head.
      ls_head-spart = ls_knvv-spart.
      ls_head-vtweg = ls_knvv-vtweg.
      LOOP AT ch_item INTO ls_item.
        MOVE ls_knvv-vkorg TO ls_item-vkorg.
        MODIFY ch_item FROM ls_item INDEX sy-tabix TRANSPORTING vkorg.
      ENDLOOP. " LOOP AT ch_item INTO ls_item
      li_temp_item = ch_item.
    ENDIF. " IF sy-subrc EQ 0
** Logic to be implemented here..
* Please Read KNVV table with im_head-kunnr_ag
* IF you find one entry please proceed with the sale org Distribution Channel and Division you get from KNVV table.
* If you find more that one entries please show a pop up with the available Sales Areas  and consider the sales areas choosen by User.
* This should work the same way it works for standard XD03 or XD02 Transaction.
* Populate the sales area thats been choosen by the user into your Item table.
  ENDIF. " IF lv_skip EQ abap_false
*&-- Begin of Changes for HANAtization on OTC_IDD_0009 by U106341 on 16-Sep-2019 E1SK901421
  IF li_temp_item[] IS NOT INITIAL.
*&-- End of Changes for HANAtization on OTC_IDD_0009 by U106341 on 16-Sep-2019 E1SK901421
  SELECT matnr vkorg vtweg dwerk FROM mvke INTO TABLE li_mvke
                      FOR ALL ENTRIES IN li_temp_item
                               WHERE matnr EQ li_temp_item-matnr
                                 AND vkorg EQ li_temp_item-vkorg
                                 AND vtweg EQ im_head-vtweg.
  IF sy-subrc EQ 0.
*&-- Begin of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421
    SORT li_mvke BY matnr vkorg vtweg.
*&-- End of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421

    LOOP AT li_temp_item INTO ls_item.

      READ TABLE li_mvke INTO ls_mvke WITH KEY matnr = ls_item-matnr
                                               vkorg = ls_item-vkorg
                                               vtweg = im_head-vtweg BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE ls_item-charg TO ls_temp-charg.
        MOVE ls_mvke-matnr TO ls_temp-matnr.
        MOVE ls_mvke-dwerk TO ls_temp-werks.
        APPEND ls_temp TO li_temp.
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT li_temp_item INTO ls_item
  ENDIF. " IF sy-subrc EQ 0

*&-- Begin of Changes for HANAtization on OTC_IDD_0009 by U106341 on 16-Sep-2019 E1SK901421
    ENDIF.
*&-- End of Changes for HANAtization on OTC_IDD_0009 by U106341 on 16-Sep-2019 E1SK901421

***--> Begin of Insert for OTC_IDD_0009_SAP Hanatization by APODDAR
      IF li_temp IS NOT INITIAL.
***<-- End of Insert for OTC_IDD_0009_SAP Hanatization by APODDAR

  SELECT
  matnr     " Material Number
  charg     " Batch Number
  vfdat     " Shelf Life Expiration or Best-Before Date
  FROM mch1 " Batches (if Batch Management Cross-Plant)
  INTO TABLE li_mch1
  FOR ALL ENTRIES IN li_temp
  WHERE matnr = li_temp-matnr
      AND charg = li_temp-charg.
* Begin of Defect - 2455
  DELETE li_mch1 WHERE vfdat LT sy-datum.
* End of Defect - 2455

*&-- Begin of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421
  SORT li_mch1 BY matnr charg.
*&-- End of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421

  IF li_mch1 is not initial.

    SELECT matnr  werks charg vfdat FROM mcha " Batches
               INTO TABLE li_mcha FOR ALL ENTRIES IN li_temp
                         WHERE matnr EQ li_temp-matnr
                           AND werks EQ li_temp-werks
                           AND charg EQ li_temp-charg.
*&-- Begin of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421
     IF sy-subrc IS INITIAL.
       SORT li_mcha BY matnr charg.
     ENDIF.
*&-- End of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421
*                         AND vfdat GE sy-datum.
* if sy-subrc eq 0.
  ENDIF. " IF sy-subrc EQ 0

***--> Begin of Insert for OTC_IDD_0009_SAP Hanatization by APODDAR
      ENDIF.
***<-- End of Insert for OTC_IDD_0009_SAP Hanatization by APODDAR

  LOOP AT li_temp_item INTO ls_item.
    lv_line = sy-tabix.
    IF ls_item-charg IS NOT INITIAL.
      CLEAR : ls_mcha,ls_mvke,lv_par1,lv_par2.
      IF ls_item-vkorg IS NOT INITIAL.

        READ TABLE li_mvke INTO ls_mvke WITH KEY matnr = ls_item-matnr
                                                 vkorg = ls_item-vkorg
*&-- Begin of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421
                                                 BINARY SEARCH.
*&-- End of changes for HANAtization on OTC_IDD_0009 by SMUKHER on 19-Aug-2019 in E1SK901421
                                                 .
* Begin of Defect - INC0329479
        READ TABLE li_mch1  INTO lwa_mch1 WITH KEY matnr = ls_item-matnr
                                                   charg = ls_item-charg BINARY SEARCH.
* End of Defect - INC0329479
        READ TABLE li_mcha INTO ls_mcha WITH KEY matnr = ls_item-matnr
                                                 charg = ls_item-charg BINARY SEARCH.
        IF sy-subrc NE 0.
          lv_par1 = ls_item-charg.
          lv_par2 = ls_mvke-dwerk.
          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = c_e     "  of type
              cl     = c_msg
              number = 123
              par1   = lv_par1 "ls_item-charg
              par2   = lv_par2 "ls_mvke-DWERK
            IMPORTING
              return = lwa_ret.

          ls_item-message = lwa_ret-message.
          ls_item-type    = lwa_ret-type.
          MODIFY li_temp_item FROM ls_item INDEX lv_line TRANSPORTING type message. " Message Line for CAD Dialog Interface
          CLEAR ls_item.
          lv_error = c_mark.
        ENDIF. " IF sy-subrc NE 0
      ELSE. " ELSE -> IF ls_item-vkorg IS NOT INITIAL
        CALL FUNCTION 'BALW_BAPIRETURN_GET2'
          EXPORTING
            type   = c_e "  of type
            cl     = c_msg1
            number = 102
          IMPORTING
            return = lwa_ret.
        ls_item-message = lwa_ret-message.
        ls_item-type    = lwa_ret-type.
        MODIFY li_temp_item FROM ls_item INDEX lv_line TRANSPORTING type message. " Message Line for CAD Dialog Interface
        CLEAR ls_item.
        lv_error = c_mark.
      ENDIF. " IF ls_item-vkorg IS NOT INITIAL
    ENDIF. " IF ls_item-charg IS NOT INITIAL
  ENDLOOP. " LOOP AT li_temp_item INTO ls_item
  ch_item = li_temp_item.
*  ENDIF. " IF sy-subrc EQ 0
  IF lv_error IS INITIAL.
    CALL METHOD me->bapi_simulate
      EXPORTING
        im_head = ls_head
      CHANGING
        ch_item = li_temp_item.
    ch_item = li_temp_item .
  ENDIF. " IF lv_error IS INITIAL

ENDMETHOD.


METHOD determine_sold_to.
***********************************************************************
*Program    : DETERMINE_SOLD_TO                                       *
*Title      : ZOTC_CL_INB_SO_EDI_850~DETERMINE_SOLD_TO                *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP        CR -     CR-D3-84              *
*---------------------------------------------------------------------*
***********************************************************************
* Method (DETERMINE_SOLD_TO) :: This Mehod is used to determine sales *
* Area for SKIP Logic Countries (D2 Sites). Earlier this logic was    *
* Processed in a BADI by edditing the IDOC Segments. Once we determine*
* Skip Logic countries. If the Sold to country  not part of Skip Logic*
* then this method will determine if its LRD or Non LRD               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
*29-NOV-2016  U033814        E1DK922318      Defect - 7019 - Incorrect*
*                                            Hirearchy and Missing Seg*
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*02-JAN-2017   U033814       E1DK922318      CR D3 CR-313             *
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*03-APR-2017   U033814       E1DK926575     Defect 11999 INC0327853 -
*                                           Incorrect SAP Sold to acc *
*---------------------------------------------------------------------*
*10-APR-2017   U033814       E1DK926897     Defect 2480 INC0327880 -
*                                           Sold to Name not getting
*                                           Populated Correctly
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*02-May-2017   U033814       E1DK927661    Defect 2723 Clarify Check  *
*---------------------------------------------------------------------*

*Types Decleration
  TYPES :  BEGIN OF ty_edsdc,
               vkorg TYPE knvv-vkorg, " Sales Organization
               vtweg TYPE knvv-vtweg, " Distribution Channel
               spart TYPE knvv-spart, " Division
           END OF ty_edsdc,
           BEGIN OF lty_knvv,
               vkorg TYPE vkorg,      " Sales Organization
               vtweg TYPE vtweg,      " Distribution Channel
               spart TYPE spart,      " Division
           END OF lty_knvv.
* Local Variables
  DATA :
     lwa_idoc_header       TYPE edi_dc40,                                         " IDoc Control Record for Interface to External System
      lv_counter           TYPE posnr,                                            " Counter(3) of type Character
        lwa_data           TYPE edi_dd40,                                         " IDoc Data Records from 4.0 onwards
        lwa_data1          TYPE edi_dd40,                                         " IDoc Data Records from 4.0 onwards
        lwa_insert_rec     TYPE edi_dd40,                                         " Transfer Structure for Inserting Segments
        lv_parvw           TYPE parvw,                                            " Partner Function
        lv_expnr           TYPE edi_expnr,                                        " External partner number (in customer system)
        lv_kunnr           TYPE kunnr,                                            " Customer Number
        lv_inpnr           TYPE edi_inpnr,                                        " Internal partner number (in SAP System)
        lv_inpnr_we        TYPE edi_inpnr,                                        " Internal partner number (in SAP System)
        lv_inpnr_ag        TYPE edi_inpnr,                                        " Internal partner number (in SAP System)
        i_edsdc            TYPE STANDARD TABLE OF ty_edsdc INITIAL SIZE 0,
        lwa_edsdc          TYPE ty_edsdc,
        lv_lines           TYPE i,                                                " Lines of type Integers
        lv_vkorg           TYPE vkorg,                                            " Sales Organization
        lv_vtweg           TYPE vtweg,                                            " Distribution Channel
        lv_spart           TYPE spart,                                            " Division
        lv_ag              TYPE edi_inpnr,                                        " Internal partner number (in SAP System)
        lv_we              TYPE edi_inpnr,                                        " Internal partner number (in SAP System)
        lv_partner         TYPE edi_sndprn,                                       " Partner Number of Sender
        li_status_table    TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
       li_knvv             TYPE STANDARD TABLE OF lty_knvv INITIAL SIZE 0,
       lwa_knvv            TYPE lty_knvv,
       lv_sales            TYPE char1,                                            " Sales of type CHAR1
       lv_edsdc            TYPE char1,                                            " Edsdc of type CHAR1
       lv_tabix            TYPE sytabix,                                          " Index of Internal Tables
       lv_land1            TYPE land1.                                            " Land1
*Constants Declerations
  CONSTANTS: c_inbound(1)                  TYPE c VALUE '2',                        " IDoc Direction
             c_orders(20)                  TYPE c VALUE 'ORDERS',                   " Message TYPE
             c_e1edka1(20)                 TYPE c VALUE 'E1EDKA1',                  " SEGMENT NAME
             c_ag(2)                       TYPE c VALUE 'AG',                       " Ag(2) of type Character
             c_we(2)                       TYPE c VALUE 'WE',                       " We(2) of type Character
             c_006(3)                      TYPE c VALUE '006',                      " 006(3) of type Character
             c_007(3)                      TYPE c VALUE '007',                      " 007(3) of type Character
             c_008(3)                      TYPE c VALUE '008',                      " 008(3) of type Character
             c_x(1)                        TYPE c VALUE 'X',                        " X(1) of type Character
             c_e1edk14(20)                 TYPE c VALUE 'E1EDK14',                  " SEGMENT NAME
             c_e1edk01(20)                 TYPE c VALUE 'E1EDK01',                  " SEGMENT NAME
             c_si                          TYPE edidc-sndlad VALUE 'SI',            " Logical address of sender
             c_clf                         TYPE edidc-mescod VALUE 'CLF',           " Logical address of sender
             lc_null                       TYPE z_criteria   VALUE 'NULL',          " Enh. Criteria
             lc_parvw_soldto               TYPE parvw        VALUE 'AG',            " Partner Function
             lc_parvw_shipto               TYPE parvw        VALUE 'WE',            " Partner Function
             lc_parvw_payer                TYPE parvw        VALUE 'RG',            " Partner Function - RG
             lc_parvw_bilto                TYPE parvw        VALUE 'RE',            " Partner Function - RE
             lc_enh_name                   TYPE z_enhancement VALUE 'OTC_IDD_0009', " Enhancement No
             lc_land_lrd                   TYPE z_criteria    VALUE 'LAND_LRD'.     " Enh. Criteria

* Begin of CR - 313
  DATA : lv_katr5 TYPE katr5. " Attribute 5
* End of CR 313

*Field Symbols
  FIELD-SYMBOLS  :   <lfs_data>     TYPE edi_dd40,        " IDoc Data Records from 4.0 onwards
                    <lfs_status>    TYPE zdev_enh_status. " Enhancement Status
* Modify the Partners from Input
  READ TABLE im_input_head INTO lwa_idoc_header INDEX 1.
  IF sy-subrc IS INITIAL.
    CASE lwa_idoc_header-mestyp.
      WHEN c_orders.
        IF   lwa_idoc_header-direct  = c_inbound AND
         ( lwa_idoc_header-sndlad    = c_si ). " OR
* Begin of Defect 2723
*           lwa_idoc_header-mescod    = c_clf ).
*           lwa_idoc_header-sndprn    = lv_partner ).
* End of Defect 2723
*******User Exit
***ZCL_IM_IM_ORDERS05_OTC_EDI    IF_EX_IDOC_DATA_MAPPER~PROCESS

          LOOP AT ch_item ASSIGNING <lfs_data> WHERE  segnam = c_e1edka1 AND
                            ( sdata+0(2) = lc_parvw_soldto OR sdata+0(2) = lc_parvw_shipto
                             OR sdata+0(2) = lc_parvw_payer
                             OR sdata+0(2) = lc_parvw_bilto ).

            lv_tabix = sy-tabix.
            lv_parvw              = <lfs_data>-sdata+0(3).
            lv_expnr              = <lfs_data>-sdata+20(17).

            IF lv_expnr  IS NOT INITIAL.
*Get internal number
              CLEAR : lv_kunnr , lv_inpnr.
              SELECT SINGLE kunnr " Customer Number
                            inpnr " Internal partner number (in SAP System)
               FROM  edpar        " Convert External <  > Internal Partner Number
               INTO (lv_kunnr,
                     lv_inpnr)
               WHERE parvw = lv_parvw AND
                     expnr = lv_expnr.
              IF sy-subrc = 0.
                <lfs_data>-sdata+3(10) = lv_inpnr.
                MODIFY ch_item FROM <lfs_data> INDEX lv_tabix TRANSPORTING sdata.
              ENDIF. " IF sy-subrc = 0
            ELSE. " ELSE -> IF lv_expnr IS NOT INITIAL
              lv_parvw              = <lfs_data>-sdata+0(3).
              lv_kunnr              = <lfs_data>-sdata+3(10).
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = lv_kunnr
                IMPORTING
                  output = lv_kunnr.
              <lfs_data>-sdata+3(10) = lv_kunnr.
              MODIFY ch_item FROM <lfs_data> INDEX lv_tabix TRANSPORTING sdata.
            ENDIF. " IF lv_expnr IS NOT INITIAL
          ENDLOOP. " LOOP AT ch_item ASSIGNING <lfs_data> WHERE segnam = c_e1edka1 AND

          READ TABLE ch_item ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_ag.
          IF sy-subrc = 0.
*&-- For sold-to(AG) We need to check first if PARTN(internal sold-to) is available before
*&-- checking LIFNR(EXPNR - external sold-to).
*&-- PARTN(internal sold-to) is enough to determine Sales Srea from KNVV.
            CLEAR : lv_parvw,
                    lv_inpnr_ag.

            lv_parvw              = <lfs_data>-sdata+0(3).
            lv_inpnr_ag           = <lfs_data>-sdata+3(10).
            IF NOT lv_inpnr_ag IS INITIAL.

* Begin of Defect 2723
              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = lv_inpnr_ag
                IMPORTING
                  output = lv_inpnr_ag.
* End of Defect 2723
*Fetching Sales office data from KNVV table on the basis of customer no.
              REFRESH li_knvv[].
              SELECT vkorg " Sales Organization
                     vtweg " Distribution Channel
                     spart " Division
              FROM knvv    " Customer Master Sales Data
              INTO TABLE li_knvv
              WHERE kunnr  =  lv_inpnr_ag.

              IF sy-subrc = 0.
*Checking no. of record fetched from KNVV table
                CLEAR lv_lines.
                DESCRIBE TABLE li_knvv LINES lv_lines.
*If single record fetched from knvv table then populating the sales office data in IDOC
                IF lv_lines = 1.
                  CLEAR lwa_knvv.
                  READ TABLE li_knvv INTO lwa_knvv INDEX 1.
                  IF sy-subrc = 0.
                    lv_vkorg = lwa_knvv-vkorg.
                    lv_vtweg = lwa_knvv-vtweg.
                    lv_spart = lwa_knvv-spart.
                    lv_ag    = lv_inpnr_ag.
                  ENDIF. " IF sy-subrc = 0
                ELSE. " ELSE -> IF lv_lines = 1
*Get sales org, dist channel and division
                  REFRESH i_edsdc[].
                  SELECT vkorg " Sales Organization
                         vtweg " Distribution Channel
                         spart " Division
                   FROM edsdc  " Assignment of EDI Partner by Sales Org., Distrib.Ch.,Div.
                   INTO TABLE i_edsdc
                   WHERE kunnr  =  lv_inpnr_ag.
                  IF sy-subrc = 0.
                    CLEAR lwa_edsdc.
                    READ TABLE i_edsdc INTO lwa_edsdc INDEX 1.
                    IF sy-subrc = 0.
                      lv_vkorg = lwa_edsdc-vkorg.
                      lv_vtweg = lwa_edsdc-vtweg.
                      lv_spart = lwa_edsdc-spart.
                      lv_ag    = lv_inpnr_ag.
                    ELSE. " ELSE -> IF sy-subrc = 0
*                      lv_sales = 'X'.
                      lv_edsdc = 'X'.
                    ENDIF. " IF sy-subrc = 0
                  ELSE. " ELSE -> IF sy-subrc = 0
*                    lv_sales = 'X'.
                    lv_edsdc = 'X'.
                  ENDIF. " IF sy-subrc = 0
                ENDIF. " IF lv_lines = 1
              ELSE. " ELSE -> IF sy-subrc = 0
                lv_sales = c_x.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF NOT lv_inpnr_ag IS INITIAL
*=========================Code for SOLD TO PARTY if no SHIP to PARTY Exist==========================
          ELSE. " ELSE -> IF sy-subrc = 0
            READ TABLE ch_item ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_we.
            IF sy-subrc = 0.
*&-- For Ship-to(WE) We need to check first if PARTN(internal ship-to) is available before
*&-- checking LIFNR(EXPNR - external ship-to).
*&-- PARTN(internal ship-to) is enough to determine Sales Srea from KNVV.
              CLEAR : lv_parvw,
                      lv_expnr,
                      lv_inpnr_we.
              lv_parvw              = <lfs_data>-sdata+0(3).
              lv_inpnr_we           = <lfs_data>-sdata+3(10).
              IF NOT lv_inpnr_we IS INITIAL.

* Begin of Defect 2723
                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                  EXPORTING
                    input  = lv_inpnr_we
                  IMPORTING
                    output = lv_inpnr_we.
* End of Defect 2723

                CLEAR : lv_kunnr , lv_inpnr.
*Get Internal number
* Begin of Chnage - Defect 11999.
                lv_expnr              = <lfs_data>-sdata+20(17).
                IF lv_expnr IS INITIAL.
* End of Chnage - Defect 11999.
                  SELECT SINGLE kunnr     " Customer Number
                                inpnr     " Internal partner number (in SAP System)
                   FROM  edpar            " Convert External <  > Internal Partner Number
                   INTO (lv_kunnr,
                         lv_inpnr)
                   WHERE parvw = c_we AND "As there will always be Ship To maintained in EDPAR
                         inpnr = lv_inpnr_we.
                ELSE. " ELSE -> IF lv_expnr IS INITIAL
                  SELECT SINGLE kunnr     " Customer Number
                                inpnr     " Internal partner number (in SAP System)
                   FROM  edpar            " Convert External <  > Internal Partner Number
                   INTO (lv_kunnr,
                         lv_inpnr)
                   WHERE parvw = c_we AND "As there will always be Ship To maintained in EDPAR
                         expnr = lv_expnr AND
                         inpnr = lv_inpnr_we.

                ENDIF. " IF lv_expnr IS INITIAL
*Fetching Sales office data from KNVV table on the basis of customer no.
                CLEAR li_knvv.
                SELECT vkorg " Sales Organization
                       vtweg " Distribution Channel
                       spart " Division
                FROM knvv    " Customer Master Sales Data
                INTO TABLE li_knvv
                WHERE kunnr  =  lv_kunnr.
                IF sy-subrc = 0.
*Checking no. of record fetched from KNVV table
                  CLEAR lv_lines.
                  DESCRIBE TABLE li_knvv LINES lv_lines.
*If single record fetched from knvv table then populating the sales office data in IDOC
                  IF lv_lines = 1.
                    CLEAR lwa_knvv.
                    READ TABLE li_knvv INTO lwa_knvv INDEX 1.
                    IF sy-subrc = 0.
                      lv_vkorg = lwa_knvv-vkorg.
                      lv_vtweg = lwa_knvv-vtweg.
                      lv_spart = lwa_knvv-spart.
                      lv_ag    = lv_inpnr_we.
                    ENDIF. " IF sy-subrc = 0
                  ELSE. " ELSE -> IF lv_lines = 1
*Get sales org, dist channel and division
                    CLEAR i_edsdc.
                    SELECT vkorg " Sales Organization
                           vtweg " Distribution Channel
                           spart " Division
                     FROM edsdc  " Assignment of EDI Partner by Sales Org., Distrib.Ch.,Div.
                     INTO TABLE i_edsdc
                     WHERE kunnr  =  lv_kunnr.
                    IF sy-subrc = 0.
                      CLEAR lwa_edsdc.
                      READ TABLE i_edsdc INTO lwa_edsdc INDEX 1.
                      IF sy-subrc = 0.
                        lv_vkorg = lwa_edsdc-vkorg.
                        lv_vtweg = lwa_edsdc-vtweg.
                        lv_spart = lwa_edsdc-spart.
                        lv_ag    = lv_inpnr_we.
                      ELSE. " ELSE -> IF sy-subrc = 0
*                        lv_sales = 'X'.
                        lv_edsdc = 'X'.
                      ENDIF. " IF sy-subrc = 0
                    ELSE. " ELSE -> IF sy-subrc = 0
*                      lv_sales = 'X'.
                      lv_edsdc = 'X'.
                    ENDIF. " IF sy-subrc = 0
                  ENDIF. " IF lv_lines = 1
                ENDIF. " IF sy-subrc = 0
              ELSE. " ELSE -> IF NOT lv_inpnr_we IS INITIAL
                CLEAR : lv_parvw,
                        lv_expnr.

                lv_parvw              = <lfs_data>-sdata+0(3).
                lv_expnr              = <lfs_data>-sdata+20(17).
*Get internal number
                CLEAR : lv_kunnr ,
                        lv_inpnr.
*Get Internal number
                SELECT SINGLE kunnr     " Customer Number
                              inpnr     " Internal partner number (in SAP System)
                 FROM  edpar            " Convert External <  > Internal Partner Number
                 INTO (lv_kunnr,
                       lv_inpnr)
                 WHERE parvw = c_we AND "As there will always be Ship To maintained in EDPAR
                       expnr = lv_expnr.
                IF sy-subrc EQ 0.
                  lv_we  = lv_inpnr.
                  lv_ag = lv_kunnr.
*Fetching Sales office data from KNVV table on the basis of customer no.
                  REFRESH li_knvv[].
                  SELECT vkorg " Sales Organization
                         vtweg " Distribution Channel
                         spart " Division
                  FROM knvv    " Customer Master Sales Data
                  INTO TABLE li_knvv
                  WHERE kunnr  =  lv_kunnr.

                  IF sy-subrc = 0.
* *Checking no. of record fetched from KNVV table
                    CLEAR lv_lines.
                    DESCRIBE TABLE li_knvv LINES lv_lines.
                    IF lv_lines = 1.
*If single record fetched from knvv table then populating the sales office data in IDOC
                      CLEAR lwa_knvv.
                      READ TABLE li_knvv INTO lwa_knvv INDEX 1.
                      IF sy-subrc = 0.
                        lv_vkorg = lwa_knvv-vkorg.
                        lv_vtweg = lwa_knvv-vtweg.
                        lv_spart = lwa_knvv-spart.
                        lv_ag  = lv_kunnr.
                        lv_we  = lv_inpnr.
                      ENDIF. " IF sy-subrc = 0
                    ELSE. " ELSE -> IF lv_lines = 1
                      CLEAR i_edsdc[].
                      SELECT vkorg " Sales Organization
                             vtweg " Distribution Channel
                             spart " Division
                       FROM edsdc  " Assignment of EDI Partner by Sales Org., Distrib.Ch.,Div.
                       INTO TABLE i_edsdc
                       WHERE kunnr  =  lv_kunnr.
                      IF sy-subrc = 0.
                        CLEAR lwa_edsdc.
                        READ TABLE i_edsdc INTO lwa_edsdc INDEX 1.
                        IF sy-subrc = 0.
                          lv_vkorg = lwa_edsdc-vkorg.
                          lv_vtweg = lwa_edsdc-vtweg.
                          lv_spart = lwa_edsdc-spart.
                          lv_ag  = lv_kunnr.
                          lv_we  = lv_inpnr.
                        ENDIF. " IF sy-subrc = 0
                      ELSE. " ELSE -> IF sy-subrc = 0
* If no record exist in EDSDC tanle for ship to party then fail IDOc
*                        lv_sales = c_x.
                        lv_edsdc = c_x.
                      ENDIF. " IF sy-subrc = 0
                    ENDIF. " IF lv_lines = 1
                  ELSE. " ELSE -> IF sy-subrc = 0
*             If no record exist in KNVV table for ship to party then fail IDOC
                    lv_sales = c_x.
                  ENDIF. " IF sy-subrc = 0
                ELSE. " ELSE -> IF sy-subrc EQ 0
                  lv_sales = c_x.
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF NOT lv_inpnr_we IS INITIAL
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
* Clarify Defect
*        ENDIF. " IF lwa_idoc_header-direct = c_inbound AND
* Clarify Defect
          IF lv_we IS NOT INITIAL.
            ch_output-kunnr_sh = lv_we.
          ELSE. " ELSE -> IF lv_we IS NOT INITIAL
            ch_output-kunnr_sh = lv_kunnr.
          ENDIF. " IF lv_we IS NOT INITIAL

          IF lv_ag IS NOT INITIAL.
            ch_output-kunnr_sp = lv_ag.
          ELSE. " ELSE -> IF lv_ag IS NOT INITIAL
            ch_output-kunnr_sp = lv_kunnr.
          ENDIF. " IF lv_ag IS NOT INITIAL

* Check the Country for Sold to Party.
          SELECT SINGLE land1 katr5 FROM kna1 " General Data in Customer Master
            INTO (lv_land1 , lv_katr5) WHERE kunnr EQ lv_ag.

          IF sy-subrc EQ 0.
* Based on EMI table entries check if the country belongs to LRD/NLRD

* Call function to fetch EMI data
            CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
              EXPORTING
                iv_enhancement_no = lc_enh_name
              TABLES
                tt_enh_status     = li_status_table
              EXCEPTIONS
                OTHERS            = 1.
            IF sy-subrc IS INITIAL.
              SORT li_status_table BY criteria
                                active.
* Read status table for NULL criteria
              READ TABLE li_status_table ASSIGNING <lfs_status>
                                         WITH KEY criteria = lc_null
                                                  active   = abap_true.
*                                       BINARY SEARCH.
              IF sy-subrc IS INITIAL.
* Begin of CR - 313
                IF lv_katr5 IS INITIAL.
* End of CR - 313
                  READ TABLE li_status_table ASSIGNING <lfs_status>
                             WITH KEY criteria = lc_land_lrd
                                      sel_low  = lv_land1
                                      active   = abap_true.
*                           BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    ch_output-lrd = abap_true.
                  ENDIF. " IF sy-subrc IS INITIAL
* Begin of CR - 313
                ELSE. " ELSE -> IF lv_katr5 IS INITIAL
                  READ TABLE li_status_table ASSIGNING <lfs_status>
                                             WITH KEY criteria = lc_land_lrd
                                                      sel_low  = lv_katr5
                                                      active   = abap_true.
                  IF sy-subrc IS INITIAL.
                    ch_output-lrd = abap_true.
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF lv_katr5 IS INITIAL
* End of CR - 313
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc EQ 0
          IF lwa_idoc_header-rcvlad NE 'D3'.
            READ TABLE ch_item ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14 sdata+0(3) = c_008.
            IF sy-subrc <> 0.
              LOOP AT ch_item INTO lwa_data WHERE segnam =  c_e1edk01.
                lv_counter = sy-tabix + 1.
* Begin of Defect - 7019
*              lwa_insert_rec-hlevel   =    lv_counter.
                lwa_insert_rec-segnum        =    lv_counter.
* End of Defect - 7019
                lwa_insert_rec-segnam    =    c_e1edk14.
*              lwa_insert_rec-segnum    =    lwa_data-segnum.
                lwa_data1-sdata+0(3)     =    c_008.
                lwa_data1-sdata+3(35)    =    lv_vkorg.
                lwa_insert_rec-sdata     =    lwa_data1-sdata.
                APPEND  lwa_insert_rec TO ch_item.
                CLEAR : lwa_data1,lwa_insert_rec.

*              lv_counter = lv_counter + 1.
* Begin of Defect - 7019
*              lwa_insert_rec-hlevel   =    lv_counter.
                lwa_insert_rec-segnum        =    lv_counter.
* End of Defect - 7019
                lwa_insert_rec-hlevel   =    lv_counter.
                lwa_insert_rec-segnam    =    c_e1edk14.
*              lwa_insert_rec-segnum    =    lwa_data-segnum.
                lwa_data1-sdata+0(3)     =    c_007.
                lwa_data1-sdata+3(35)    =    lv_vtweg.
                lwa_insert_rec-sdata     =    lwa_data1-sdata.
                APPEND  lwa_insert_rec TO ch_item.
                CLEAR : lwa_data1,lwa_insert_rec.

*              lv_counter = lv_counter + 1.
* Begin of Defect - 7019
*              lwa_insert_rec-hlevel   =    lv_counter.
                lwa_insert_rec-segnum        =    lv_counter.
* End of Defect - 7019
                lwa_insert_rec-segnam    =    c_e1edk14.
*              lwa_insert_rec-segnum    =    lwa_data-segnum.
                lwa_data1-sdata+0(3)     =    c_006.
                lwa_data1-sdata+3(35)    =    lv_spart.
                lwa_insert_rec-sdata     =    lwa_data1-sdata.
                APPEND  lwa_insert_rec TO ch_item.
                CLEAR : lwa_data1,lwa_insert_rec.
*              lv_added = c_x.
              ENDLOOP. " LOOP AT ch_item INTO lwa_data WHERE segnam = c_e1edk01
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF lwa_idoc_header-rcvlad NE 'D3'

          IF lv_parvw = c_we.
*          CLEAR lv_added.
            LOOP AT ch_item INTO lwa_data WHERE segnam     =  c_e1edka1
                                         AND sdata+0(3) =  c_we.
              CLEAR: lv_counter.
              lv_counter = sy-tabix.
              READ TABLE ch_item INTO lwa_data1 WITH KEY segnam = 'E1EDKA3'.
              IF sy-subrc EQ 0.
                lv_counter = sy-tabix.
              ENDIF. " IF sy-subrc EQ 0
* Begin of  Defect 2480
              CLEAR : lwa_data1,lwa_insert_rec.
* End of Defect 2480
* Begin of Defect - 7019
*              lwa_insert_rec-hlevel   =    lv_counter.
              lwa_insert_rec-segnum        =    lv_counter.
* End of Defect - 7019
              lwa_insert_rec-segnam    = c_e1edka1.
              lwa_data1-sdata+0(3)     = c_ag.
              lwa_data1-sdata+3(20)    = lv_kunnr.
              lwa_data1-sdata+20(17)   = lv_expnr.
              ch_output-kunnr_sp       = lv_kunnr.
              lwa_insert_rec-sdata     = lwa_data1-sdata.
              APPEND  lwa_insert_rec TO ch_item.
              CLEAR : lwa_data1,lwa_insert_rec.
            ENDLOOP. " LOOP AT ch_item INTO lwa_data WHERE segnam = c_e1edka1
          ENDIF. " IF lv_parvw = c_we
* Begin of Defect 2723
        ENDIF. " IF lwa_idoc_header-direct = c_inbound AND
* End of Defect 2723
      WHEN  OTHERS.
    ENDCASE.



    IF lv_sales = c_x AND lwa_idoc_header-rcvlad EQ 'D3'.
      RAISE no_sales_data_found.
    ENDIF. " IF lv_sales = c_x AND lwa_idoc_header-rcvlad EQ 'D3'
    IF lv_edsdc = c_x AND lwa_idoc_header-rcvlad EQ 'D3'.
      RAISE no_edsdc_entry.
    ENDIF. " IF lv_edsdc = c_x AND lwa_idoc_header-rcvlad EQ 'D3'
* Begin of Defect 2723
    IF lwa_idoc_header-rcvlad EQ 'D3'.
      READ TABLE ch_item ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_ag.
      IF sy-subrc NE 0.
        READ TABLE ch_item ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_we.
        IF sy-subrc NE 0.
          RAISE no_soldto_shipto.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF lwa_idoc_header-rcvlad EQ 'D3'
* End of Defect 2723
  ENDIF. " IF sy-subrc IS INITIAL
ENDMETHOD.


METHOD determine_sold_to_country.
***********************************************************************
*Program    : DETERMINE_SOLD_TO_COUNTRY                               *
*Title      : ZOTC_CL_INB_SO_EDI_850~DETERMINE_SOLD_TO_COUNTRY        *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
***********************************************************************
*(DETERMINE_SOLD_TO_COUNTRY) ::This Method is used for Non EDI Orders *
* determine the Sold country and also to determine wether the Sold to *
* Country belongs to LRD or Non LRD                                   *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*02-JAN-2017   U033814       E1DK922318      CR D3 CR-313             *
*---------------------------------------------------------------------*

* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status. " Table for Enhancement status data

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status>  TYPE zdev_enh_status. " Enhancement Status
* Local Data
  DATA : lv_land1 TYPE land1. " Country Key
* Begin of CR - 313
  DATA : lv_katr5 TYPE katr5. " Attribute 5
* End of CR 313
  CONSTANTS:
          lc_enh_name   TYPE z_enhancement VALUE 'OTC_IDD_0009', " Enhancement No
          lc_land_lrd  TYPE z_criteria    VALUE 'LAND_LRD',      " Enh. Criteria
          lc_land_skip  TYPE z_criteria    VALUE 'LAND_SKIP',    " Enh. Criteria
          lc_null       TYPE z_criteria    VALUE 'NULL'.         " Null criteria

* Check the Country for Sold to Party.
  SELECT SINGLE land1 katr5 FROM kna1 " General Data in Customer Master
    INTO (lv_land1 , lv_katr5) WHERE kunnr EQ im_kunnr_sp.

  IF sy-subrc EQ 0.
* Based on EMI table entries check if the country belongs to LRD/NLRD

* Call function to fetch EMI data
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enh_name
      TABLES
        tt_enh_status     = li_status_table
      EXCEPTIONS
        OTHERS            = 1.
    IF sy-subrc IS INITIAL.
      SORT li_status_table BY criteria
                        active.
* Read status table for NULL criteria
      READ TABLE li_status_table ASSIGNING <lfs_status>
                                 WITH KEY criteria = lc_null
                                          active   = abap_true.
*                                 BINARY SEARCH.
      IF sy-subrc IS INITIAL.
*   Read status table for criteria Batch val and active = X
* Begin of CR - 313
        IF lv_katr5 IS INITIAL.
* End of CR - 313
          READ TABLE li_status_table ASSIGNING <lfs_status>
                                     WITH KEY criteria = lc_land_skip
                                              sel_low  = lv_land1
                                              active   = abap_true.
*                                     BINARY SEARCH.
          IF sy-subrc EQ 0.
            ex_skip = abap_true.
          ELSE. " ELSE -> IF sy-subrc EQ 0
            READ TABLE li_status_table ASSIGNING <lfs_status>
                                       WITH KEY criteria = lc_land_lrd
                                                sel_low  = lv_land1
                                                active   = abap_true.
*                                       BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              ex_lrd = abap_true.
              ex_land1 = lv_land1.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc EQ 0
* Begin of CR - 313
        ELSE. " ELSE -> IF lv_katr5 IS INITIAL
          READ TABLE li_status_table ASSIGNING <lfs_status>
                                     WITH KEY criteria = lc_land_lrd
                                              sel_low  = lv_katr5
                                              active   = abap_true.
          IF sy-subrc IS INITIAL.
            ex_lrd = abap_true.
            ex_land1 = lv_katr5.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF lv_katr5 IS INITIAL
* End of CR - 313
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc EQ 0

ENDMETHOD.


METHOD prepare_edi_split.
***********************************************************************
*Program    : DETERMINE_SOLD_TO                                       *
*Title      : ZOTC_CL_INB_SO_EDI_850~DETERMINE_SOLD_TO                *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP        CR -     CR-D3-84              *
*---------------------------------------------------------------------*
***********************************************************************
* Method (PREPARE_EDI_SPLIT) :: This Mehod is used to determine sales *
* Area and re build the Split logic for D3 Sites for EDI Orders       *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
*29-NOV-2016  U033814        E1DK922318      Defect - 7019 - Incorrect*
*                                            Hirearchy and Missing Seg*
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*02-JAN-2017   U033814       E1DK922318      CR D3 CR-313             *
*---------------------------------------------------------------------*

* Begin of CR 313
* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status, " Table for Enhancement status data
         lv_vkbur TYPE vkbur,                        " Sales Office
         lv_lrd_val TYPE fpb_low.                    " From Value

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status>  TYPE zdev_enh_status. " Enhancement Status

  CONSTANTS:
          lc_enh_name   TYPE z_enhancement VALUE 'OTC_IDD_0009', " Enhancement No
          lc_vkorg      TYPE z_criteria    VALUE 'LRD_VKORG',    " Enh. Criteria
          lc_ehq        TYPE z_criteria    VALUE 'VKORG_EHQ',    " Enh. Criteria
          lc_uspa       TYPE z_criteria    VALUE 'VKORG_USPA',   " Enh. Criteria
          lc_lrd_vkorg  TYPE z_criteria    VALUE 'LRD_VKORG',    " Enh. Criteria
          lc_biorad TYPE char6 VALUE 'BIORAD',                   " Biorad of type CHAR6
          lc_diamed TYPE char6 VALUE 'DIAMED',                   " Diamed of type CHAR6
          lc_underscore TYPE char1 VALUE '_'.                    " Underscore of type CHAR1

* End of CR 313

  DATA :
    li_tmp_item      TYPE STANDARD TABLE OF edi_dd40, " IDoc Data Record for Interface to External System
    lwa_idoc_data    TYPE edi_dd40.                   " IDoc Data Record for Interface to External System

  FIELD-SYMBOLS  :   <lfs_data>     TYPE edi_dd40, " IDoc Data Records from 4.0 onwards
                     <lfs_datat>    TYPE edi_dd40, " IDoc Data Record for Interface to External System
                     <lfs_data1>    TYPE edi_dd40. " IDoc Data Record for Interface to External System

  CONSTANTS :  c_006(3)                      TYPE c VALUE '006',              " 006(3) of type Character
               c_016(3)                      TYPE c VALUE '016',              " 006(3) of type Character
               c_007(3)                      TYPE c VALUE '007',              " 007(3) of type Character
               c_008(3)                      TYPE c VALUE '008',              " 008(3) of type Character
               c_e1edk14(20)                 TYPE c VALUE 'E1EDK14',          " SEGMENT NAME
               c_e1edk01(20)                 TYPE c VALUE 'E1EDK01',          " SEGMENT NAME
              c_e1edp01                      TYPE edi4segnam VALUE 'E1EDP01', " Segment (external name)
              c_e1edp19                      TYPE edi4segnam VALUE 'E1EDP19', " Segment (external name)
              c_e1edpt1                      TYPE edi4segnam VALUE 'E1EDPT1', " Segment (external name)
              c_e1edpt2                      TYPE edi4segnam VALUE 'E1EDPT2'. " Segment (external name)

* Begin of Defect - 7019
  CONSTANTS :
       lc_e1edp02 TYPE  edi4segnam VALUE 'E1EDP02', " Segment (external name)
       lc_e1curef TYPE  edi4segnam VALUE 'E1CUREF', " Segment (external name)
       lc_e1addi1 TYPE  edi4segnam VALUE 'E1ADDI1', " Segment (external name)
       lc_e1edp03 TYPE  edi4segnam VALUE 'E1EDP03', " Segment (external name)
       lc_e1edp04 TYPE  edi4segnam VALUE 'E1EDP04', " Segment (external name)
       lc_e1edp05 TYPE  edi4segnam VALUE 'E1EDP05', " Segment (external name)
       lc_e1edps5 TYPE  edi4segnam VALUE 'E1EDPS5', " Segment (external name)
       lc_e1edp20 TYPE  edi4segnam VALUE 'E1EDP20', " Segment (external name)
       lc_e1edpa1 TYPE  edi4segnam VALUE 'E1EDPA1', " Segment (external name)
       lc_e1edpa3 TYPE  edi4segnam VALUE 'E1EDPA3', " Segment (external name)
       lc_e1edpad TYPE  edi4segnam VALUE 'E1EDPAD', " Segment (external name)
       lc_e1txth1 TYPE  edi4segnam VALUE 'E1TXTH1', " Segment (external name)
       lc_e1txtp1 TYPE  edi4segnam VALUE 'E1TXTP1', " Segment (external name)
       lc_e1edp17 TYPE  edi4segnam VALUE 'E1EDP17', " Segment (external name)
       lc_e1edp18 TYPE  edi4segnam VALUE 'E1EDP18', " Segment (external name)
       lc_e1edp35 TYPE  edi4segnam VALUE 'E1EDP35'. " Segment (external name)
* End of Defect - 7019


*Data Declerations
  DATA: lv_counter          TYPE posnr,    " Counter(3) of type Character
        lv_tabix            TYPE sy-tabix, " Index of Internal Tables
        lv_tabix1           TYPE sy-tabix, " Index of Internal Tables
        lv_seg              TYPE posnr,    " Two digit number
        lwa_data            TYPE edi_dd40, " IDoc Data Records from 4.0 onwards
        lwa_data1           TYPE edi_dd40, " IDoc Data Records from 4.0 onwards
        lwa_insert_rec      TYPE edi_dd40. " Transfer Structure for Inserting Segments


  TYPES : BEGIN OF ty_vkorg,
          vkorg TYPE vkorg, " Sales Organization
          vkbur TYPE vkbur, " Sales Office
          matnr TYPE matnr, " Material Number
          END OF ty_vkorg.

  DATA : li_vkorg TYPE STANDARD TABLE OF ty_vkorg INITIAL SIZE 0,
         li_vkorgt TYPE STANDARD TABLE OF ty_vkorg INITIAL SIZE 0,
         ls_item  TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
         ls_knvv  TYPE knvv,             " Customer Master Sales Data
         ls_vkorg TYPE ty_vkorg,
         ls_vkorgt TYPE ty_vkorg.

  LOOP AT im_item INTO ls_item.
    MOVE ls_item-vkorg TO ls_vkorg-vkorg.
    MOVE ls_item-vkbur TO ls_vkorg-vkbur.
    MOVE ls_item-matnr TO ls_vkorg-matnr.
    APPEND ls_vkorg TO li_vkorg.
  ENDLOOP. " LOOP AT im_item INTO ls_item
  li_vkorgt = li_vkorg.

  SORT li_vkorg BY vkorg.

  li_tmp_item = ch_item.

  LOOP AT li_vkorg INTO ls_vkorg.
    lv_vkbur = ls_vkorg-vkbur.
    SELECT SINGLE * FROM knvv " Customer Master Sales Data
                INTO ls_knvv
                WHERE kunnr EQ im_sp
                  AND vkorg EQ ls_vkorg-vkorg.
    IF sy-subrc EQ 0.
      AT NEW vkorg.
* Populate Item data based on VKORG
        READ TABLE ch_item ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14 sdata+0(3) = c_008.
        IF sy-subrc <> 0.
          LOOP AT ch_item INTO lwa_data WHERE segnam =  c_e1edk01.

            lv_counter = sy-tabix + 1.
            lwa_insert_rec-segnam    =    c_e1edk14.
            lwa_insert_rec-segnum    =    lv_counter.
            lwa_data1-sdata+0(3)     =    c_008.
            lwa_data1-sdata+3(35)    =    ls_knvv-vkorg.
            lwa_insert_rec-sdata     =    lwa_data1-sdata.
            APPEND  lwa_insert_rec TO ch_item.
            CLEAR : lwa_data1,lwa_insert_rec.


*            lwa_insert_rec-hlevel   =    lv_counter.
            lwa_insert_rec-segnam    =    c_e1edk14.
            lwa_insert_rec-segnum    =    lv_counter.
            lwa_data1-sdata+0(3)     =    c_007.
            lwa_data1-sdata+3(35)    =    ls_knvv-vtweg.
            lwa_insert_rec-sdata     =    lwa_data1-sdata.
            APPEND  lwa_insert_rec TO ch_item.
            CLEAR : lwa_data1,lwa_insert_rec.


*            lwa_insert_rec-hlevel   =    lv_counter.
            lwa_insert_rec-segnam    =    c_e1edk14.
            lwa_insert_rec-segnum    =    lv_counter.
            lwa_data1-sdata+0(3)     =    c_006.
            lwa_data1-sdata+3(35)    =    ls_knvv-spart.
            lwa_insert_rec-sdata     =    lwa_data1-sdata.
            APPEND  lwa_insert_rec TO ch_item.
            CLEAR : lwa_data1,lwa_insert_rec.
* Begin of CR 313
            lwa_insert_rec-segnam    =    c_e1edk14.
            lwa_insert_rec-segnum    =    lv_counter.
            lwa_data1-sdata+0(3)     =    c_016.
            lwa_data1-sdata+3(35)    =    lv_vkbur.
            lwa_insert_rec-sdata     =    lwa_data1-sdata.
            APPEND  lwa_insert_rec TO ch_item.
            CLEAR : lwa_data1,lwa_insert_rec,lv_vkbur.
* End of CR 313
          ENDLOOP. " LOOP AT ch_item INTO lwa_data WHERE segnam = c_e1edk01
        ENDIF. " IF sy-subrc <> 0

* Populate Item Data
        DELETE ch_item WHERE segnam = c_e1edp01.
        DELETE ch_item WHERE segnam = c_e1edp19.
        DELETE ch_item WHERE segnam = c_e1edpt1.
        DELETE ch_item WHERE segnam = c_e1edpt2.
* Begin of Defect - 7019
        DELETE ch_item WHERE segnam = lc_e1edp02.
        DELETE ch_item WHERE segnam = lc_e1curef.
        DELETE ch_item WHERE segnam = lc_e1addi1.
        DELETE ch_item WHERE segnam = lc_e1edp03.
        DELETE ch_item WHERE segnam = lc_e1edp04.
        DELETE ch_item WHERE segnam = lc_e1edp05.
        DELETE ch_item WHERE segnam = lc_e1edps5.
        DELETE ch_item WHERE segnam = lc_e1edp20.
        DELETE ch_item WHERE segnam = lc_e1edpa1.
        DELETE ch_item WHERE segnam = lc_e1edpa3.
        DELETE ch_item WHERE segnam = lc_e1edpad.
        DELETE ch_item WHERE segnam = lc_e1txth1.
        DELETE ch_item WHERE segnam = lc_e1txtp1.
        DELETE ch_item WHERE segnam = lc_e1edp17.
        DELETE ch_item WHERE segnam = lc_e1edp18.
        DELETE ch_item WHERE segnam = lc_e1edp35.
* End of Defect - 7019
        SORT li_tmp_item BY segnum.
        LOOP AT li_vkorgt INTO ls_vkorgt WHERE vkorg EQ ls_vkorg-vkorg.
*          LOOP AT li_tmp_item INTO lwa_data WHERE segnam = c_e1edp19
*                                               AND sdata+3(35) = ls_vkorgt-matnr.
          READ TABLE  li_tmp_item INTO lwa_data WITH KEY segnam = c_e1edp19
                                                    sdata+3(35) = ls_vkorgt-matnr.
          IF sy-subrc EQ 0.
            lv_tabix = sy-tabix.
            lv_tabix1 = lv_tabix - 1.
* Corresponding E1EDP01 Segment
            DO 99 TIMES.
              READ TABLE li_tmp_item INTO lwa_data1 INDEX lv_tabix1.
              IF lwa_data1-segnam EQ c_e1edp01.
                DESCRIBE TABLE ch_item LINES lv_counter.
                lv_seg = lv_counter + 1.
                lwa_data1-segnum = lv_seg.
                APPEND lwa_data1  TO ch_item.
                lwa_data1-hlevel = abap_true.
                MODIFY li_tmp_item FROM lwa_data1 INDEX lv_tabix1 TRANSPORTING hlevel.
                EXIT.
              ENDIF. " IF lwa_data1-segnam EQ c_e1edp01
              lv_tabix1 = lv_tabix1 - 1.
            ENDDO.
* Populate Corresponding Line Item Segmnets
            CLEAR lv_tabix.
            lv_tabix = lv_tabix1 + 1.

            LOOP AT li_tmp_item INTO lwa_data FROM lv_tabix.
              lv_tabix = sy-tabix.
* Exit when New Line item comes.
              IF lwa_data-segnam EQ c_e1edp01.
                EXIT.
              ENDIF. " IF lwa_data-segnam EQ c_e1edp01
              lv_counter = lv_counter + 1.
              lv_seg = lv_counter + 1.
              lwa_data-segnum = lv_seg.
              APPEND lwa_data   TO ch_item.
              lwa_data-hlevel = abap_true.
              MODIFY li_tmp_item FROM lwa_data INDEX lv_tabix TRANSPORTING hlevel.
              CLEAR : lwa_data,lwa_data1.
            ENDLOOP. " LOOP AT li_tmp_item INTO lwa_data FROM lv_tabix
            CLEAR ls_vkorgt.
*          ENDLOOP. " LOOP AT li_tmp_item INTO lwa_data WHERE segnam = c_e1edp19
          ENDIF. " IF sy-subrc EQ 0
          DELETE li_tmp_item WHERE hlevel EQ abap_true.
        ENDLOOP. " LOOP AT li_vkorgt INTO ls_vkorgt WHERE vkorg EQ ls_vkorg-vkorg

        SORT ch_item BY segnum.
        LOOP AT ch_item INTO lwa_idoc_data.
          CLEAR lv_seg.
          lv_seg = sy-tabix.
*          lwa_idoc_data-hlevel = lv_seg.
          lwa_idoc_data-segnum = lv_seg.
          MODIFY ch_item FROM lwa_idoc_data INDEX sy-tabix TRANSPORTING segnum.
        ENDLOOP. " LOOP AT ch_item INTO lwa_idoc_data
* Post the Split Idocs
        CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
          TABLES
            idoc_control_rec_40 = im_head
            idoc_data_rec_40    = ch_item.
      ENDAT.
      DELETE ch_item WHERE segnam = c_e1edk14
                       AND sdata+0(3) = c_008.
      DELETE ch_item WHERE segnam = c_e1edk14
                       AND sdata+0(3) = c_007.
      DELETE ch_item WHERE segnam = c_e1edk14
                       AND sdata+0(3) = c_006.
      DELETE ch_item WHERE segnam = c_e1edk14
                       AND sdata+0(3) = c_016.

    ELSE. " ELSE -> IF sy-subrc EQ 0
      RAISE no_sales_data_found.
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT li_vkorg INTO ls_vkorg
ENDMETHOD.


METHOD process_lrd.
***********************************************************************
*Program    : PROCESS_LRD                                             *
*Title      : ZOTC_CL_INB_SO_EDI_850~PROCESS_LRD                      *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
***********************************************************************
* Method (PROCESS_LRD) ::This Method is used for EDI Orders and       *
* Non EDI Orders  Based on the Material Clasiification we derive the  *
* Sales Office for LRD Logic
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
* ===========  ========  ========== ===================================*
* 08-11-2016   U033814   E1DK922236 Defect # 6154 :
*                                   Binary Search for EMI Entry removed
*&---------------------------------------------------------------------*
* 07-Mar-2017   U033814  E1DK926115 D3 CR 378.
* Reading the error message by the material as line item is not there.
*&---------------------------------------------------------------------*
  TYPES:
          BEGIN OF ty_cabn,
            atinn TYPE  atinn,  " Internal characteristic
            adzhl TYPE  adzhl,  " Internal counter for archiving objects via engin. chg. mgmt
            atnam TYPE  atnam,  " Characteristic Name
          END OF ty_cabn,
          BEGIN OF ty_ausp,
            objek TYPE  objnum, " Key of object to be classified
            atinn TYPE  atinn,  " Internal characteristic
            atzhl	TYPE wzaehl,
            mafid	TYPE klmaf,
            klart	TYPE klassenart,
            atwrt TYPE atwrt,   " Characteristic Value
           END OF ty_ausp,
           BEGIN OF ty_objek,
             objek TYPE objnum, " Key of object to be classified
           END OF ty_objek.
  CONSTANTS :   c_e    TYPE bapireturn-type VALUE 'E', " Message type: S Success, E Error, W Warning, I Info, A Abort
                c_msg  TYPE symsgid VALUE 'M3'.        " Message Class

  CONSTANTS:
            lc_enh_name   TYPE z_enhancement VALUE 'OTC_IDD_0009', " Enhancement No
            lc_null  TYPE z_criteria   VALUE 'NULL',               " Enh. Criteria
            lc_lrd_vkorg  TYPE z_criteria    VALUE 'LRD_VKORG',    " Enh. Criteria
            lc_biorad TYPE char6 VALUE 'BIORAD',                   " Biorad of type CHAR6
            lc_diamed TYPE char6 VALUE 'DIAMED',                   " Diamed of type CHAR6
            lc_underscore TYPE char1 VALUE '_'.                    " Underscore of type CHAR1

* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
         lwa_ret  TYPE bapiret2,                     " Return Parameter
         lv_error TYPE char1,                        " Error of type CHAR1
         lv_par1  TYPE symsgv,                       " Message Variable
         lv_par2  TYPE symsgv.                       " Message Variable


  " Table for Enhancement status data

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status>  TYPE zdev_enh_status. " Enhancement Status

  DATA :
         li_cabn    TYPE STANDARD TABLE OF ty_cabn INITIAL SIZE 0,
         li_ausp    TYPE STANDARD TABLE OF ty_ausp INITIAL SIZE 0,
         li_objek   TYPE STANDARD TABLE OF ty_objek INITIAL SIZE 0,
         li_item    TYPE zotc_tt_850_so_item,
         li_item_t  TYPE zotc_tt_850_so_item,
         lt_msg     TYPE bapirettab,
         ls_ausp    TYPE ty_ausp,
         lv_tabix   TYPE sy-tabix,         " Index of Internal Tables
         ls_objek   TYPE ty_objek,
         lv_lrd_val TYPE fpb_low,          " From Value
         lv_vkorg   TYPE vkorg,            " Sales Organization
         lv_vkorgt  TYPE vkorg,            " Sales Organization
         lv_vkbur   TYPE vkbur,            " Sales Office
         ls_item    TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
         ls_item_t  TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
         lv_posnr   TYPE char6,            " Posnr of type CHAR6
         ls_cabn    TYPE ty_cabn.          " Characteristic

  CONSTANTS : lc_klart TYPE klassenart VALUE '001', " Class Type
*              lc_class TYPE KLASSE_D VALUE 'Z2_FC_ZMC',             " Reference structure: Class data
              lc_atnam TYPE atnam VALUE 'ZM_MATERIAL_OWNERSHIP'. " Characteristic Name

  li_item = ch_item.
  LOOP AT li_item INTO ls_item.
    MOVE ls_item-matnr TO ls_objek-objek.
    APPEND ls_objek TO li_objek.
  ENDLOOP. " LOOP AT li_item INTO ls_item

  READ TABLE ch_item INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc IS INITIAL.
* Call function to fetch EMI data
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enh_name
      TABLES
        tt_enh_status     = li_status_table
      EXCEPTIONS
        OTHERS            = 1.
    IF sy-subrc IS INITIAL.
      SORT li_status_table BY criteria
                        active.
* Read status table for NULL criteria
      READ TABLE li_status_table ASSIGNING <lfs_status>
                                 WITH KEY criteria = lc_null
                                          active   = abap_true.
*                                 BINARY SEARCH.
      IF sy-subrc IS INITIAL.

        SELECT atinn adzhl atnam FROM cabn " Characteristic
                    INTO TABLE li_cabn
                 WHERE atnam EQ lc_atnam
                   AND datuv LT sy-datum.
        READ TABLE li_cabn INDEX 1 INTO ls_cabn.
        IF sy-subrc IS INITIAL.
          SELECT objek atinn atzhl mafid klart atwrt FROM ausp " Characteristic Values
                         INTO TABLE li_ausp FOR ALL ENTRIES IN li_objek
                                          WHERE objek EQ li_objek-objek
                                            AND atinn EQ ls_cabn-atinn
                                            AND klart EQ lc_klart.
        ENDIF. " IF sy-subrc IS INITIAL
*        SORT ch_item BY matnr.
*        SORT li_item BY matnr.
*        SORT li_ausp BY objek.
        LOOP AT ch_item INTO ls_item.
          AT NEW matnr.
            READ TABLE li_ausp INTO ls_ausp WITH KEY objek = ls_item-matnr. " BINARY SEARCH.
            IF sy-subrc EQ 0.
              CASE ls_ausp-atwrt.
* Bio- rad
                WHEN 1.
                  CONCATENATE im_land1 lc_underscore lc_biorad lc_underscore lv_lrd_val INTO lv_lrd_val.
                  READ TABLE li_status_table ASSIGNING <lfs_status>
                                             WITH KEY criteria = lc_lrd_vkorg
                                                      sel_low+0(10)  = lv_lrd_val
                                                      active   = abap_true.
* Begin of Defect - 6151.
*                                             BINARY SEARCH.                        "Deleted by NGARG
* End of Defect - 6151.
                  IF sy-subrc IS INITIAL.
                    CONDENSE <lfs_status>-sel_low NO-GAPS.
                    MOVE <lfs_status>-sel_low+10(4) TO lv_vkorg.
                    MOVE <lfs_status>-sel_high      TO lv_vkbur.
                  ENDIF. " IF sy-subrc IS INITIAL
* Diamed
                WHEN 2.
                  CONCATENATE im_land1 lc_underscore lc_diamed lc_underscore lv_lrd_val INTO lv_lrd_val.
                  READ TABLE li_status_table ASSIGNING <lfs_status>
                                             WITH KEY criteria = lc_lrd_vkorg
                                                      sel_low+0(10)  = lv_lrd_val
                                                      active   = abap_true.
* Begin of Defect - 6151
*                                             BINARY SEARCH.                         "Deleted by NGARG
* End of Defect - 6151
                  IF sy-subrc IS INITIAL.
                    CONDENSE <lfs_status>-sel_low NO-GAPS.
                    MOVE <lfs_status>-sel_low+10(4) TO lv_vkorg.
                    MOVE <lfs_status>-sel_high      TO lv_vkbur.
                  ENDIF. " IF sy-subrc IS INITIAL
              ENDCASE.
            ELSE. " ELSE -> IF sy-subrc EQ 0
              lv_par1 = ls_item-matnr.
              lv_par2 = ls_item-posex.
              CALL FUNCTION 'BALW_BAPIRETURN_GET2'
                EXPORTING
                  type   = c_e     "  of type
                  cl     = c_msg
                  number = 399
                  par1   = lv_par1 "ls_item-charg
                  par2   = lv_par2
                IMPORTING
                  return = lwa_ret.
              lwa_ret-message_v1 = ls_item-matnr.
              APPEND lwa_ret TO ex_bapi_msg.
*              lv_error = 'X'.
            ENDIF. " IF sy-subrc EQ 0
* For Luxemburg Bio-rad has to be treated as Non LRD
            SELECT SINGLE vkorg FROM tvko INTO lv_vkorgt WHERE vkorg EQ lv_vkorg.
*            IF sy-subrc NE 0.                             "-D3 CR 378
            IF sy-subrc NE 0 AND lv_vkorg IS NOT INITIAL. "+D3 CR 378
              CLEAR : lv_vkorg , lv_vkbur , ls_item_t , li_item_t.
              APPEND ls_item TO li_item_t.
              CALL METHOD me->process_nlrd
                IMPORTING
                  ex_bapi_msg               = lt_msg
                CHANGING
                  ch_item                   = li_item_t
                EXCEPTIONS
                  lab_office_not_maintained = 1
                  OTHERS                    = 2.
              IF sy-subrc <> 0.
                APPEND LINES OF lt_msg TO ex_bapi_msg.
              ELSE. " ELSE -> IF sy-subrc <> 0
                READ TABLE li_item_t INTO ls_item_t INDEX 1.
                IF sy-subrc EQ 0.
                  MOVE ls_item_t-vkorg TO lv_vkorg.
                  MOVE ls_item_t-vkbur TO lv_vkbur.
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF sy-subrc <> 0
            ENDIF. " IF sy-subrc NE 0 AND lv_vkorg IS NOT INITIAL

            LOOP AT li_item INTO ls_item WHERE matnr EQ ls_item-matnr.
              MOVE lv_vkorg TO ls_item-vkorg.
              MOVE lv_vkbur TO ls_item-vkbur.
              MODIFY li_item FROM ls_item INDEX sy-tabix TRANSPORTING vkorg vkbur.
            ENDLOOP. " LOOP AT li_item INTO ls_item WHERE matnr EQ ls_item-matnr
            CLEAR : lv_lrd_val,lv_vkorg.
            CLEAR : lv_vkorg , lv_vkbur , ls_item_t , li_item_t.
          ENDAT.
        ENDLOOP. " LOOP AT ch_item INTO ls_item
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

  IF ex_bapi_msg IS NOT INITIAL.
    LOOP AT li_item INTO ls_item.
      lv_tabix = sy-tabix.
      lv_posnr = ls_item-posnr.
      READ TABLE ex_bapi_msg INTO lwa_ret WITH KEY message_v1 = ls_item-matnr
                                                   message_v2 = lv_posnr.
      IF sy-subrc EQ 0.
        MOVE lwa_ret-message TO ls_item-message.
        MOVE lwa_ret-type    TO ls_item-type.
        MODIFY li_item FROM ls_item INDEX lv_tabix TRANSPORTING message type.
* ---> Begin of Insert for D3 CR 378 by U033814
* read using material number
      ELSE. " ELSE -> IF sy-subrc EQ 0
        READ TABLE ex_bapi_msg INTO lwa_ret WITH KEY message_v1 = ls_item-matnr.
        IF sy-subrc EQ 0.
          MOVE lwa_ret-message TO ls_item-message.
          MOVE lwa_ret-type    TO ls_item-type.
          MODIFY li_item FROM ls_item INDEX lv_tabix TRANSPORTING message type.
        ENDIF. " IF sy-subrc EQ 0
* <--- End    of Insert for D3 CR 378 by U033814
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT li_item INTO ls_item

  ENDIF. " IF ex_bapi_msg IS NOT INITIAL
  ch_item = li_item.
  IF ex_bapi_msg IS NOT INITIAL.
    RAISE material_class_not_found.
  ENDIF. " IF ex_bapi_msg IS NOT INITIAL
ENDMETHOD.


METHOD process_nlrd.
***********************************************************************
*Program    : PROCESS_NLRD                                            *
*Title      : ZOTC_CL_INB_SO_EDI_850~PROCESS_NLRD                     *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                      *
*---------------------------------------------------------------------*
***********************************************************************
* Method (PROCESS_NLRD) ::This Method is used for EDI Orders and      *
* Non EDI Orders  Based on the Lab Office field values we derive the  *
* Sales Office for Non LRD Logic                                      *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
  CONSTANTS :   c_e    TYPE bapireturn-type VALUE 'E', " Message type: S Success, E Error, W Warning, I Info, A Abort
                c_msg  TYPE symsgid VALUE 'MM'.        " Message Class


  CONSTANTS:
            lc_enh_name   TYPE z_enhancement VALUE 'OTC_IDD_0009', " Enhancement No
            lc_null  TYPE z_criteria   VALUE 'NULL',               " Enh. Criteria
            lc_ehq  TYPE z_criteria    VALUE 'VKORG_EHQ',          " Enh. Criteria
            lc_uspa  TYPE z_criteria    VALUE 'VKORG_USPA',        " Enh. Criteria
            lc_ehq_val TYPE fpb_low     VALUE '2000',              " From Value
            lc_uspa_val TYPE fpb_low    VALUE '1024'.              " From Value

* Local internal table Declaration
  DATA : li_status_table
             TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status
  " Table for Enhancement status data

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status>  TYPE zdev_enh_status. " Enhancement Status

  TYPES : BEGIN OF ty_mara,
          matnr TYPE matnr, " Material Number
          labor TYPE labor, " Laboratory/design office
          END OF ty_mara.
  DATA : li_mara       TYPE STANDARD TABLE OF ty_mara INITIAL SIZE 0,
         li_item       TYPE  zotc_tt_850_so_item,
         lv_error      TYPE char1,           " Error of type CHAR1
         lwa_ret       TYPE bapiret2,        " Return Parameter
         lv_par1       TYPE symsgv,          " Message Variable
         lv_par2       TYPE symsgv,
         ls_item       TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
         lv_tabix      TYPE sy-tabix,        " Index of Internal Tables
         lv_ehq_vkbur  type vkbur,
         lv_uspa_vkbur type vkbur,
         lv_ehq        TYPE vkorg, " Sales Organization
         lv_uspa       TYPE vkorg. " Sales Organization

  FIELD-SYMBOLS : <lfs_item> TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
                  <lfs_mara> TYPE ty_mara.
  READ TABLE ch_item INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc IS INITIAL.
* Call function to fetch EMI data
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enh_name
      TABLES
        tt_enh_status     = li_status_table
      EXCEPTIONS
        OTHERS            = 1.
    IF sy-subrc IS INITIAL.
      SORT li_status_table BY criteria
                        active.
* Read status table for NULL criteria
      READ TABLE li_status_table ASSIGNING <lfs_status>
                                 WITH KEY criteria = lc_null
                                          active   = abap_true.
*                                 BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        READ TABLE li_status_table ASSIGNING <lfs_status>
                                   WITH KEY criteria = lc_ehq
                                            sel_low  = lc_ehq_val
                                            active   = abap_true.
*                                   BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lv_ehq = <lfs_status>-sel_low.
          lv_ehq_vkbur = <lfs_status>-sel_high.
        ENDIF. " IF sy-subrc IS INITIAL
        READ TABLE li_status_table ASSIGNING <lfs_status>
                                   WITH KEY criteria = lc_uspa
                                            sel_low  = lc_uspa_val
                                            active   = abap_true.
*                                   BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lv_uspa = <lfs_status>-sel_low.
          lv_uspa_vkbur = <lfs_status>-sel_high.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

    li_item = ch_item.
    SELECT matnr labor FROM mara INTO TABLE li_mara
             FOR ALL ENTRIES IN ch_item WHERE matnr EQ ch_item-matnr.
*    SORT ch_item BY matnr.
*    SORT li_mara BY matnr.
*    SORT li_item BY matnr.
    LOOP AT ch_item ASSIGNING <lfs_item>.
      AT NEW matnr.
        READ TABLE li_mara ASSIGNING <lfs_mara>
                                   WITH KEY matnr = <lfs_item>-matnr.
*                                   BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          IF <lfs_mara>-labor IS INITIAL.
            lv_par1 = ls_item-matnr.
            lv_par2 = ls_item-posex.
            CALL FUNCTION 'BALW_BAPIRETURN_GET2'
              EXPORTING
                type   = c_e     "  of type
                cl     = c_msg
                number = 089
                par1   = lv_par1 "ls_item-charg
                par2   = lv_par2
              IMPORTING
                return = lwa_ret.
            APPEND lwa_ret TO ex_bapi_msg.
            lwa_ret-message_v1 = ls_item-matnr.
*            lv_error = 'X'.
          ENDIF. " IF <lfs_mara>-labor IS INITIAL
          IF <lfs_mara>-labor+1(2) GE 22.
            LOOP AT li_item INTO ls_item WHERE matnr EQ <lfs_mara>-matnr.
              ls_item-vkorg = lv_ehq.
              ls_item-vkbur = lv_ehq_vkbur.
              MODIFY li_item FROM ls_item INDEX sy-tabix TRANSPORTING vkorg vkbur.
            ENDLOOP. " LOOP AT li_item INTO ls_item WHERE matnr EQ <lfs_mara>-matnr
          ELSE. " ELSE -> IF <lfs_mara>-labor+1(2) GE 22
            LOOP AT li_item INTO ls_item WHERE matnr EQ <lfs_mara>-matnr.
              ls_item-vkorg = lv_uspa.
              ls_item-vkbur = lv_uspa_vkbur.
              MODIFY li_item FROM ls_item INDEX sy-tabix TRANSPORTING vkorg vkbur.
            ENDLOOP. " LOOP AT li_item INTO ls_item WHERE matnr EQ <lfs_mara>-matnr
          ENDIF. " IF <lfs_mara>-labor+1(2) GE 22
        ENDIF. " IF sy-subrc IS INITIAL
      ENDAT.
    ENDLOOP. " LOOP AT ch_item ASSIGNING <lfs_item>
  if ex_bapi_msg is not initial.
    loop at li_item into ls_item.
      lv_tabix = sy-tabix.
      read table ex_bapi_msg into lwa_ret with key message_v1 = ls_item-matnr.
      if sy-subrc eq 0.
        move lwa_ret-message to ls_item-message.
        move lwa_ret-type    to ls_item-type.
        modify li_item from ls_item index lv_tabix transporting message type.
      endif.
    endloop.
endif.
    ch_item = li_item.

    IF ex_bapi_msg is not initial.
      RAISE lab_office_not_maintained.
    ENDIF. " IF lv_error IS NOT INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDMETHOD.


METHOD vaidate_material.
***********************************************************************
*Program    : VAIDATE_MATERIAL                                        *
*Title      : ZOTC_CL_INB_SO_EDI_850~VAIDATE_MATERIAL                 *
*Developer  : Srinivasa G                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                      *
*---------------------------------------------------------------------*
***********************************************************************
* Method (VAIDATE_MATERIAL) ::This Method is used for EDI Orders to   *
* Check if the Material is Valid for Bio-rad                          *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*07-DEC-2016   U033814       E1DK922318      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*

  CONSTANTS :   c_e    TYPE bapireturn-type VALUE 'E', " Message type: S Success, E Error, W Warning, I Info, A Abort
                c_msg  TYPE symsgid VALUE 'M3'.        " Message Class
  TYPES : BEGIN OF ty_mara,
          matnr TYPE matnr, " Material Number
          END OF ty_mara.
  DATA : li_mara  TYPE STANDARD TABLE OF ty_mara INITIAL SIZE 0,
         ls_item  TYPE zotc_850_so_item, " Sales Order Item for IDD 0009 - 850
         lwa_ret  TYPE bapiret2,         " Return Parameter
         lv_par1  TYPE symsgv,           " Message Variable
         lv_par2  TYPE symsgv,           " Message Variable
         ls_mara  TYPE ty_mara.
  READ TABLE im_item INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    SELECT matnr FROM mara " General Material Data
       INTO TABLE li_mara
        FOR ALL ENTRIES IN im_item
         WHERE matnr EQ im_item-matnr.
    IF sy-subrc EQ 0.
      LOOP AT im_item INTO ls_item.
        READ TABLE li_mara INTO ls_mara WITH KEY matnr = ls_item-matnr.
        IF sy-subrc NE 0.
          lv_par1 = ls_item-matnr.
          lv_par2 = ls_item-posex.
          CALL FUNCTION 'BALW_BAPIRETURN_GET2'
            EXPORTING
              type   = c_e     "  of type
              cl     = c_msg
              number = 305
              par1   = lv_par1 "ls_item-charg
              par2   = lv_par2
            IMPORTING
              return = lwa_ret.
          APPEND lwa_ret TO ex_bapi_msg.
*          RAISE material_not_found.
        ENDIF. " IF sy-subrc NE 0
      ENDLOOP. " LOOP AT im_item INTO ls_item
    ELSE. " ELSE -> IF sy-subrc EQ 0
*      lv_par1 = ls_item-matnr.
*      lv_par2 = ls_item-posex.
      CALL FUNCTION 'BALW_BAPIRETURN_GET2'
        EXPORTING
          type   = c_e     "  of type
          cl     = c_msg
          number = 305
          par1   = lv_par1 "ls_item-charg
          par2   = lv_par2
        IMPORTING
          return = lwa_ret.
      APPEND lwa_ret TO ex_bapi_msg.
*      RAISE material_not_found.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
  READ TABLE ex_bapi_msg INDEX 1 TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    RAISE material_not_found.
  ENDIF. " if sy-subrc eq 0
ENDMETHOD.
ENDCLASS.
