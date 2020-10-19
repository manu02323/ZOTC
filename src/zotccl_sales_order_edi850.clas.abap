class ZOTCCL_SALES_ORDER_EDI850 definition
  public
  final
  create public .

public section.

  interfaces IF_ECH_ACTION .

  data ATTRV_MSG_CONTAINER type ref to ZCACL_MESSAGE_CONTAINER .
  class-data ATTRV_COLLECTION_ID type SYSUUID_X16 .

  methods CONSTRUCTOR .
  type-pools ABAP .
  methods HAS_ERROR
    returning
      value(RE_RESULT) type ABAP_BOOL .
  methods REFRESH .
  methods START_PROCESSING
    importing
      !IM_INPUT type Z01OTC_ORDERS05 .
  methods CREATE_IDOC
    importing
      !IM_INPUT type Z01OTC_ORDERS05
    exporting
      !EX_BAPI_MSG type BAPIRETTAB .
  methods FEH_EXECUTE
    importing
      !IM_REF_REGISTRATION type ref to CL_FEH_REGISTRATION optional
    returning
      value(RE_REF_REGISTRATION) type ref to CL_FEH_REGISTRATION
    raising
      resumable(Z01OTC_CX_STANDARD_MESSAGE_FAU) .
  methods FEH_PREPARE
    importing
      !IM_INPUT type Z01OTC_ORDERS05 .
protected section.
private section.

  class-data ATTRV_ECH_ACTION type ref to ZOTCCL_SALES_ORDER_EDI850 .
  constants ATTRC_MSGID type ARBGB value 'ZOTC_MSG'. "#EC NOTEXT
  data ATTRV_FEH_DATA type ZCA_TT_FEH_DATA .
  data ATTRV_OBJTYPE type ECH_DTE_OBJTYPE .
  data ATTRV_PRO_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT .

  methods INITIALIZE
    importing
      !IM_ID_PROCESSING_CONTEXT type BS_SOA_SIW_DTE_PROC_CONTEXT default 'PROXY' .
  methods GET_MESSAGE_ID
    exporting
      !EX_MESSAGE_ID type SXMSMGUID .
ENDCLASS.



CLASS ZOTCCL_SALES_ORDER_EDI850 IMPLEMENTATION.


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
*20-OCT-2016  MGARG/U033814  E1DK918357      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
**Create Object
  CREATE OBJECT attrv_msg_container.
ENDMETHOD.


METHOD create_idoc.
***********************************************************************
*Program    : CREATE_IDOC                                             *
*Title      : ZOTCCL_SALES_ORDER_EDI850~CREATE_IDOC                   *
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
*20-OCT-2016  MGARG/U033814  E1DK918357      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
*13-NOV-2016  MBAGDA         E1DK918357      Adding Message ID in     *
*                                            Idoc control record      *
*                                                     Defect#6544     *
*---------------------------------------------------------------------*
*29-NOV-2016  U033814        E1DK918357      Defect - 7019 - Incorrect*
*                                            Hirearchy and Missing Seg*
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*02-JAN-2017   U033814       E1DK922318      CR D3 CR-313             *
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*12-Apr-2017   BGUNDAB       E1DK926943      Defect# 2482- Comment    *
*                                            ARCKEY code.             *
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*02-May-2017   U033814       E1DK927661    Defect 2723 Sold to Ship to*
*                                          Exception
*---------------------------------------------------------------------*


***** VARIABLES DECLARATION *****
  DATA:
   lv_seg             TYPE posnr,                                     " 2 byte integer (signed)
   lv_log_sys         TYPE tbdls-logsys,                              " Logical system
   li_idoc            TYPE STANDARD TABLE OF z01otc_orders_orders05,  " Purchasing/Sales
   lwa_in_e1edk01     TYPE z01otc_orders05_e1edk01,                   " IDoc: Document header general data
   lwa_sdata_e1edk01  TYPE e1edk01,                                   " IDoc: Document header general data                                                                    " IDoc: Document header general data
   li_in_e1edk14      TYPE STANDARD TABLE OF z01otc_orders05_e1edk14, " IDoc: Document Header Organizational Data
   lwa_sdata_e1edk14  TYPE e1edk14,                                   " IDoc: Document Header Organizational Data
*lwa_sdata_e1edk141  TYPE e1edk14,                                     " IDoc: Document Header Organizational Data
   li_in_e1edk03      TYPE STANDARD TABLE OF z01otc_orders05_e1edk03, " IDoc: Document header date segment
   lwa_sdata_e1edk03  TYPE e1edk03,                                   " IDoc: Document header date segment
   li_in_e1edk04      TYPE STANDARD TABLE OF z01otc_orders05_e1edk04, " IDoc: Document header taxes
   lwa_sdata_e1edk04  TYPE e1edk04,                                   " IDoc: Document header taxes
   li_in_e1edk05 TYPE STANDARD TABLE OF z01otc_orders05_e1edk05,      " IDoc: Document header conditions
   lwa_sdata_e1edk05    TYPE e1edk05,                                 " IDoc: Document header conditions
   li_in_e1edka1 TYPE STANDARD TABLE OF z01otc_orders05_e1edka1,      " IDoc: Document Header Partner Information
   lwa_sdata_e1edka1       TYPE e1edka1,                              " IDoc: Document Header Partner Information
   li_in_e1edka3 TYPE STANDARD TABLE OF z01otc_orders05_e1edka3,      " IDoc: Document Header Partner Information
   lwa_sdata_e1edka3       TYPE e1edka3,                              " IDoc: Document Header Partner Information
  li_in_e1edk02 TYPE STANDARD TABLE OF z01otc_orders05_e1edk02,       " IDoc: Document header reference data
  lwa_sdata_e1edk02    TYPE e1edk02,                                  " IDoc: Document header reference data
   li_in_e1edk17 TYPE STANDARD TABLE OF z01otc_orders05_e1edk17,      " IDoc: Document Header Terms of Delivery
   lwa_sdata_e1edk17 TYPE e1edk17,                                    " IDoc: Document Header Terms of Delivery
   li_in_e1edk18 TYPE STANDARD TABLE OF z01otc_orders05_e1edk18,      " IDoc: Document Header Terms of Payment
   lwa_sdata_e1edk18 TYPE e1edk18,                                    " IDoc: Document Header Terms of Payment
   li_in_e1edk35  TYPE STANDARD TABLE OF z01otc_orders05_e1edk35,     " IDoc: Document Header Additional Data
   lwa_sdata_e1edk35 TYPE e1edk35,                                    " IDoc: Document Header Additional Data
   li_in_e1edk36  TYPE STANDARD TABLE OF z01otc_orders05_e1edk36,     " IDOC: Doc.header payment cards
   lwa_sdata_e1edk36 TYPE e1edk36,                                    " IDOC: Doc.header payment cards
    li_in_e1edkt1 TYPE STANDARD TABLE OF z01otc_orders05_e1edkt1,     " IDoc: Document Header Text Identification
    lwa_sdata_e1edkt1 TYPE e1edkt1,                                   " IDoc: Document Header Text Identification
    li_in_e1edkt2 TYPE STANDARD TABLE OF z01otc_orders05_e1edkt2,     " IDoc: Document Header Texts
    lwa_sdata_e1edkt2 TYPE e1edkt2,                                   " IDoc: Document Header Texts
    li_in_e1edp01  TYPE STANDARD TABLE OF z01otc_orders05_e1edp01,    " IDoc: Document Item General Data
    lwa_sdata_e1edp01 TYPE e1edp01,                                   " IDoc: Document Item General Data
* Begin of Defect - 7019
    li_in_e1edp02  TYPE STANDARD TABLE OF z01otc_orders05_e1edp02, " IDoc: Document Item General Data
    lwa_sdata_e1edp02 TYPE e1edp02,                                " IDoc: Document Item General Data
    lwa_sdata_e1curef TYPE e1curef,                                " IDoc: Document Item General Data
    li_in_e1addi1  TYPE STANDARD TABLE OF z01otc_orders05_e1addi1, " IDoc: Document Item General Data
    lwa_sdata_e1addi1 TYPE e1addi1,                                " IDoc: Document Item General Data
    li_in_e1edp03  TYPE STANDARD TABLE OF z01otc_orders05_e1edp03, " IDoc: Document Item General Data
    lwa_sdata_e1edp03 TYPE e1edp03,                                " IDoc: Document Item General Data
    li_in_e1edp04  TYPE STANDARD TABLE OF z01otc_orders05_e1edp04, " IDoc: Document Item General Data
    lwa_sdata_e1edp04 TYPE e1edp04,                                " IDoc: Document Item General Data
    li_in_e1edp05  TYPE STANDARD TABLE OF z01otc_orders05_e1edp05, " IDoc: Document Item General Data
    lwa_sdata_e1edp05 TYPE e1edp05,                                " IDoc: Document Item General Data
    li_in_e1edps5  TYPE STANDARD TABLE OF z01otc_orders05_e1edps5, " IDoc: Document Item General Data
    lwa_sdata_e1edps5 TYPE e1edps5,                                " IDoc: Document Item General Data
    li_in_e1edp20  TYPE STANDARD TABLE OF z01otc_orders05_e1edp20, " IDoc: Document Item General Data
    lwa_sdata_e1edp20 TYPE e1edp20,                                " IDoc: Document Item General Data
    li_in_e1edpa1  TYPE STANDARD TABLE OF z01otc_orders05_e1edpa1, " IDoc: Document Item General Data
    lwa_sdata_e1edpa1 TYPE e1edpa1,                                " IDoc: Document Item General Data
    li_in_e1edpa3  TYPE STANDARD TABLE OF z01otc_orders05_e1edpa3, " IDoc: Document Item General Data
    lwa_sdata_e1edpa3 TYPE e1edpa3,                                " IDoc: Document Item General Data
    li_in_e1edp19  TYPE STANDARD TABLE OF z01otc_orders05_e1edp19, " IDoc: Document Item Object Identification
    lwa_sdata_e1edp19 TYPE e1edp19,                                " IDoc: Document Item Object Identification
    li_in_e1edpad  TYPE STANDARD TABLE OF z01otc_orders05_e1edpad, " IDoc: Document Item Object Identification
    lwa_sdata_e1edpad TYPE e1edpad,                                " IDoc: Document Item Object Identification
    li_in_e1txth1  TYPE STANDARD TABLE OF z01otc_orders05_e1txth1, " IDoc: Document Item Object Identification
    lwa_sdata_e1txth1 TYPE e1txth1,                                " IDoc: Document Item Object Identification
    li_in_e1txtp1  TYPE STANDARD TABLE OF z01otc_orders05_e1txtp1, " IDoc: Document Item Object Identification
    lwa_sdata_e1txtp1 TYPE e1txtp1,                                " IDoc: Document Item Object Identification
    li_in_e1edp17  TYPE STANDARD TABLE OF z01otc_orders05_e1edp17, " IDoc: Document Item Object Identification
    lwa_sdata_e1edp17 TYPE e1edp17,                                " IDoc: Document Item Object Identification
    li_in_e1edp18  TYPE STANDARD TABLE OF z01otc_orders05_e1edp18, " IDoc: Document Item Object Identification
    lwa_sdata_e1edp18 TYPE e1edp18,                                " IDoc: Document Item Object Identification
    li_in_e1edp35  TYPE STANDARD TABLE OF z01otc_orders05_e1edp35, " IDoc: Document Item Object Identification
    lwa_sdata_e1edp35 TYPE e1edp35,                                " IDoc: Document Item Object Identification
* End of Defect - 7019
    li_in_e1edpt1      TYPE STANDARD TABLE OF z01otc_orders05_e1edpt1, " IDoc: Document Item Text Identification
    lwa_in_e1edpt1     TYPE z01otc_orders05_e1edpt1,                   " IDoc: Document Item Text Identification
    li_in_e1edpt2      TYPE STANDARD TABLE OF z01otc_orders05_e1edpt2, " IDoc: Document Item Texts
    lwa_in_e1edpt2     TYPE z01otc_orders05_e1edpt2,                   " IDoc: Document Item Texts
    lwa_sdata_e1edpt1 TYPE e1edpt1,                                    " IDoc: Document Item Text Identification
    lwa_sdata_e1edpt2 TYPE e1edpt2,                                    " IDoc: Document Item Texts
    li_in_e1cucfg  TYPE STANDARD TABLE OF z01otc_orders05_e1cucfg,     " CU: Configuration data
    lwa_sdata_e1cucfg TYPE e1cucfg,                                    " CU: Configuration data
    li_in_e1edl37  TYPE STANDARD TABLE OF z01otc_orders05_e1edl37,     " Handling unit header
    lwa_sdata_e1edl37  TYPE e1edl37,                                   " Handling unit header
    li_in_e1eds01 TYPE STANDARD TABLE OF z01otc_orders05_e1eds01,      " IDoc: Summary segment general
    lwa_sdata_e1eds01 TYPE e1eds01,                                    " IDoc: Summary segment general
   lwa_idoc_header  TYPE edi_dc40,                                     " IDoc Control Record for Interface to External System
   li_idoc_header   TYPE STANDARD TABLE OF edi_dc40,                   " IDoc Control Record for Interface to External System
   lwa_idoc_data    TYPE edi_dd40,                                     " IDoc Data Record for Interface to External System
   li_idoc_data     TYPE STANDARD TABLE OF edi_dd40,                   " IDoc Data Record for Interface to External System
   lwa_msg_bapi      TYPE bapiret2,                                    "Return Parameter
   lv_message_id    TYPE sxmsmguid.                                    " XI: Message ID

  CONSTANTS : lc_e1edk01 TYPE  edi4segnam VALUE 'E1EDK01', " Segment (external name)
              lc_e1edk14 TYPE  edi4segnam VALUE 'E1EDK14', " Segment (external name)
              lc_e1edk03 TYPE  edi4segnam VALUE 'E1EDK03', " Segment (external name)
              lc_e1edk04 TYPE  edi4segnam VALUE 'E1EDK04', " Segment (external name)
              lc_e1edk05 TYPE  edi4segnam VALUE 'E1EDK05', " Segment (external name)
              lc_e1edka1 TYPE  edi4segnam VALUE 'E1EDKA1', " Segment (external name)
              lc_e1edka3 TYPE  edi4segnam VALUE 'E1EDKA3', " Segment (external name)
              lc_e1edk02 TYPE  edi4segnam VALUE 'E1EDK02', " Segment (external name)
              lc_e1edk17 TYPE  edi4segnam VALUE 'E1EDK17', " Segment (external name)
              lc_e1edk18 TYPE  edi4segnam VALUE 'E1EDK18', " Segment (external name)
              lc_e1edk35 TYPE  edi4segnam VALUE 'E1EDK35', " Segment (external name)
              lc_e1edk36 TYPE  edi4segnam VALUE 'E1EDK36', " Segment (external name)
              lc_e1edkt1 TYPE  edi4segnam VALUE 'E1EDKT1', " Segment (external name)
              lc_e1edkt2 TYPE  edi4segnam VALUE 'E1EDKT2', " Segment (external name)
              lc_e1edp01 TYPE  edi4segnam VALUE 'E1EDP01', " Segment (external name)
              lc_e1edp19 TYPE  edi4segnam VALUE 'E1EDP19', " Segment (external name)
              lc_e1cucfg TYPE  edi4segnam VALUE 'E1CUCFG', " Segment (external name)
              lc_e1edl37 TYPE  edi4segnam VALUE 'E1EDL37', " Segment (external name)
              lc_e1edpt2 TYPE  edi4segnam VALUE 'E1EDPT2', " Segment (external name)
              lc_e1edpt1 TYPE  edi4segnam VALUE 'E1EDPT1', " Segment (external name)
              lc_e1eds01 TYPE  edi4segnam VALUE 'E1EDS01', " Segment (external name)
              lc_sprtype TYPE  edi4sndprt VALUE 'LS'.
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

***** Field Symbols DECLARATION *****
  FIELD-SYMBOLS:
    <lfs_e1edk14>   TYPE z01otc_orders05_e1edk14,         " IDoc: Document Header Organizational Data
    <lfs_e1edk03>   TYPE z01otc_orders05_e1edk03,         " IDoc: Document header date segment
    <lfs_e1edk04>   TYPE z01otc_orders05_e1edk04,         " IDoc: Document header taxes
    <lfs_e1edk05>   TYPE        z01otc_orders05_e1edk05,  " IDoc: Document header conditions
    <lfs_e1edka1>   TYPE         z01otc_orders05_e1edka1, " IDoc: Document Header Partner Information
    <lfs_e1edka3>   TYPE         z01otc_orders05_e1edka3, " IDoc: Document Header Partner Information
    <lfs_e1edk02> TYPE        z01otc_orders05_e1edk02,    " IDoc: Document header reference data
    <lfs_e1edk17> TYPE        z01otc_orders05_e1edk17,    " IDoc: Document Header Terms of Delivery
    <lfs_e1edk18> TYPE         z01otc_orders05_e1edk18,   " IDoc: Document Header Terms of Payment
    <lfs_e1edk35> TYPE       z01otc_orders05_e1edk35,     " IDoc: Document Header Additional Data
    <lfs_e1edk36> TYPE        z01otc_orders05_e1edk36,    " IDOC: Doc.header payment cards
    <lfs_e1edkt1> TYPE        z01otc_orders05_e1edkt1,    " IDoc: Document Header Text Identification
    <lfs_e1edkt2> TYPE      z01otc_orders05_e1edkt2,      " IDoc: Document Header Texts
    <lfs_e1edp01> TYPE      z01otc_orders05_e1edp01,      " IDoc: Document Item General Data
* Begin of Defect - 7019
    <lfs_e1edp02> TYPE      z01otc_orders05_e1edp02,  " IDoc: Document Item Reference Data
    <lfs_e1curef> TYPE      z01otc_orders05_e1curef,  " CU: Reference order item / instance in configuration
    <lfs_e1addi1> TYPE      z01otc_orders05_e1addi1,  " IDoc: Additionals
    <lfs_e1edp03> TYPE      z01otc_orders05_e1edp03,  " IDoc: Document Item Date Segment
    <lfs_e1edp04> TYPE      z01otc_orders05_e1edp04,  " IDoc: Document Item Taxes
    <lfs_e1edp05> TYPE      z01otc_orders05_e1edp05,  " IDoc: Document Item Conditions
    <lfs_e1edps5> TYPE      z01otc_orders05_e1edps5,  " A&D: Price Scale (Quantity)
    <lfs_e1edp20> TYPE      z01otc_orders05_e1edp20,  " IDoc schedule lines
    <lfs_e1edpa1> TYPE      z01otc_orders05_e1edpa1,  " IDoc: Doc.item partner information
    <lfs_e1edpa3> TYPE      z01otc_orders05_e1edpa3,  " IDoc: Document Item Partner Information Additional Data
    <lfs_e1edp19> TYPE      z01otc_orders05_e1edp19,  " IDoc: Document Item Object Identification
    <lfs_e1edpad> TYPE      z01otc_orders05_e1edpad,  " A&D: Material Exchange
    <lfs_e1txth1> TYPE      z01otc_orders05_e1txth1,  " General Text Header
    <lfs_e1txtp1> TYPE      z01otc_orders05_e1txtp1,  " General Text Segment
    <lfs_e1edp17> TYPE      z01otc_orders05_e1edp17,  " IDoc: Document item terms of delivery
    <lfs_e1edp18> TYPE      z01otc_orders05_e1edp18,  " IDoc: Document Item Terms of Payment
    <lfs_e1edp35> TYPE      z01otc_orders05_e1edp35,  " IDoc: Document Item Additional Data
    <lfs_e1edpt2> TYPE       z01otc_orders05_e1edpt2, " IDoc: Document Item Texts
    <lfs_e1edpt1> TYPE       z01otc_orders05_e1edpt1, " IDoc: Document Item Text Identification
* End of Defect - 7019
*    <lfs_e1edp19> TYPE      z01otc_orders05_e1edp19,  " IDoc: Document Item Object Identification
    <lfs_e1cucfg> TYPE       z01otc_orders05_e1cucfg, " CU: Configuration data
    <lfs_e1edl37> TYPE       z01otc_orders05_e1edl37, " Handling unit header
    <lfs_e1eds01> TYPE       z01otc_orders05_e1eds01, " IDoc: Summary segment general
*    <lfs_e1edpt2> TYPE       z01otc_orders05_e1edpt2, " IDoc: Document Item Texts
*    <lfs_e1edpt1> TYPE       z01otc_orders05_e1edpt1, " IDoc: Document Item Text Identification
    <lfs_idoc>      TYPE z01otc_orders_orders05. " Purchasing/Sales

  DATA : ls_output TYPE zotc_soldto_shipto,              " Sold to Shipto Determination
           li_tmp_item TYPE zotc_tt_850_so_item,
           ls_tmp_item TYPE zotc_850_so_item,            " Sales Order Item for IDD 0009 - 850
           lv_posnr    TYPE POSEX,
           lo_object TYPE REF TO zotc_cl_inb_so_edi_850. " Inbound Sales Order EDI 850


**** Get Idoc Info
  li_idoc = im_input-idoc.

  READ TABLE li_idoc ASSIGNING <lfs_idoc> INDEX 1.
  IF sy-subrc IS INITIAL.
*************** Fill IDOC with Control Information

    MOVE-CORRESPONDING <lfs_idoc>-edi_dc40 TO lwa_idoc_header.

** Get Receiver and Sender Partner Number by calling below FM
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = lv_log_sys
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.
    IF sy-subrc IS INITIAL.
****Receiver Partner Number
      lwa_idoc_header-rcvprn = lv_log_sys.
****Sender Partner Number
      lwa_idoc_header-sndprn = lv_log_sys.
    ENDIF. " IF sy-subrc IS INITIAL
**>>> Begin of Change for Defect# 2482 ARCKEY is now passed from SAP PI.
**>>> Begin of Change for Defect#6544 by MBAGDA on 13-Nov-2016
*    CALL METHOD me->get_message_id
*      IMPORTING
*        ex_message_id = lv_message_id.
*    lwa_idoc_header-arckey = lv_message_id.
**<<< End of Change for Defect#6544 by MBAGDA on 13-Nov-2016
**<<< End of Change for Defect# 2482
* Begin of Defect - 6800
    lwa_idoc_header-rcvpor = lwa_idoc_header-sndpor.
    lwa_idoc_header-sndprt = lc_sprtype.
* End of Defect - 6800
    APPEND lwa_idoc_header TO li_idoc_header.
    CLEAR: lwa_idoc_header.

    lwa_in_e1edk01 = <lfs_idoc>-e1edk01.
    li_in_e1edk14 = <lfs_idoc>-e1edk14.
    li_in_e1edk03 = <lfs_idoc>-e1edk03.
    li_in_e1edk04 = <lfs_idoc>-e1edk04.
    li_in_e1edk05 = <lfs_idoc>-e1edk05.
    li_in_e1edka1 = <lfs_idoc>-e1edka1.
*    li_in_e1edka3 = <lfs_idoc>-e1edka3.
    li_in_e1edk02 = <lfs_idoc>-e1edk02.
    li_in_e1edk17 = <lfs_idoc>-e1edk17.
    li_in_e1edk18 = <lfs_idoc>-e1edk18.
    li_in_e1edk35 = <lfs_idoc>-e1edk35.
    li_in_e1edk36 = <lfs_idoc>-e1edk36.
    li_in_e1edkt1 = <lfs_idoc>-e1edkt1.
    li_in_e1edp01 = <lfs_idoc>-e1edp01.
    li_in_e1cucfg = <lfs_idoc>-e1cucfg.
    li_in_e1edl37 = <lfs_idoc>-e1edl37.
    li_in_e1eds01 = <lfs_idoc>-e1eds01.
  ENDIF. " IF sy-subrc IS INITIAL

*************** Fill IDOC with Data Information
***** SEGMENT E1EDK01
  lv_seg = lv_seg + 1.
  MOVE-CORRESPONDING lwa_in_e1edk01 TO lwa_sdata_e1edk01.

  lwa_idoc_data-segnam = lc_e1edk01.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
  lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
  lwa_idoc_data-sdata  = lwa_sdata_e1edk01.
  APPEND lwa_idoc_data TO li_idoc_data.
  CLEAR: lwa_idoc_data.

***** SEGMENT E1EDK14
**********************************************************************

  LOOP AT li_in_e1edk14 ASSIGNING <lfs_e1edk14>.
    lv_seg = lv_seg + 1.

*    MOVE-CORRESPONDING <lfs_e1edk14> TO lwa_sdata_e1edk14.
**********************************************************************
*To Avoid Move CORRESPONDING, below code is written
    DATA :  lo_obj       TYPE REF TO data,                "  class
            lo_field_ref TYPE REF TO cl_abap_structdescr, " Runtime Type Services
            it_comp      TYPE  abap_component_tab.
* Begin of CR - 313
  DATA : lv_katr5 TYPE katr5.
* End of CR 313
    FIELD-SYMBOLS :
            <lfs_any>  TYPE  any,
            <lfs_val>  TYPE any,
            <lfs_comp> TYPE LINE OF abap_component_tab. " abap_componentdescr.

    GET REFERENCE OF lwa_sdata_e1edk14 INTO lo_obj.
    lo_field_ref ?= cl_abap_structdescr=>describe_by_data_ref( lo_obj ) .
    it_comp = lo_field_ref->get_components( ).

    LOOP AT it_comp ASSIGNING <lfs_comp>.
      ASSIGN COMPONENT <lfs_comp>-name OF STRUCTURE lwa_sdata_e1edk14 TO <lfs_any>.
      IF sy-subrc IS INITIAL.
        ASSIGN COMPONENT  <lfs_comp>-name OF STRUCTURE <lfs_e1edk14> TO <lfs_val>.
        IF sy-subrc IS INITIAL.
          <lfs_any> = <lfs_val>.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDLOOP. " LOOP AT it_comp ASSIGNING <lfs_comp>

**********************************************************************
    lwa_idoc_data-segnam = lc_e1edk14.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk14.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk14 ASSIGNING <lfs_e1edk14>

***** SEGMENT E1EDK03

  LOOP AT li_in_e1edk03 ASSIGNING <lfs_e1edk03>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk03> TO lwa_sdata_e1edk03.

    lwa_idoc_data-segnam = lc_e1edk03.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk03.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk03 ASSIGNING <lfs_e1edk03>

***** SEGMENT E1EDK04
  LOOP AT li_in_e1edk04  ASSIGNING <lfs_e1edk04>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk04> TO lwa_sdata_e1edk04.

    lwa_idoc_data-segnam = lc_e1edk04.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk04.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk04 ASSIGNING <lfs_e1edk04>

***** SEGMENT E1EDK05
  LOOP AT li_in_e1edk05  ASSIGNING <lfs_e1edk05>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk05> TO lwa_sdata_e1edk05.

    lwa_idoc_data-segnam = lc_e1edk05.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk05.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk05 ASSIGNING <lfs_e1edk05>

***** SEGMENT E1EDKA1
  LOOP AT li_in_e1edka1  ASSIGNING <lfs_e1edka1>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edka1> TO lwa_sdata_e1edka1.

    lwa_idoc_data-segnam = lc_e1edka1.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edka1.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
    li_in_e1edka3 = <lfs_e1edka1>-e1edka3.
    LOOP AT li_in_e1edka3 ASSIGNING <lfs_e1edka3>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edka3> TO lwa_sdata_e1edka3.

      lwa_idoc_data-segnam = lc_e1edka3.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
      lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
      lwa_idoc_data-sdata  = lwa_sdata_e1edka3.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR: lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edka3 ASSIGNING <lfs_e1edka3>
  ENDLOOP. " LOOP AT li_in_e1edka1 ASSIGNING <lfs_e1edka1>


***** SEGMENT E1EDK02
  LOOP AT li_in_e1edk02 ASSIGNING <lfs_e1edk02>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk02> TO lwa_sdata_e1edk02.

    lwa_idoc_data-segnam = lc_e1edk02.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk02.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk02 ASSIGNING <lfs_e1edk02>

***** SEGMENT E1EDK17
  LOOP AT li_in_e1edk17 ASSIGNING <lfs_e1edk17>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk17> TO lwa_sdata_e1edk17.

    lwa_idoc_data-segnam = lc_e1edk17.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk17.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk17 ASSIGNING <lfs_e1edk17>

***** SEGMENT E1EDK18
  LOOP AT li_in_e1edk18 ASSIGNING <lfs_e1edk18>.
    lv_seg = lv_seg + 1 .
    MOVE-CORRESPONDING <lfs_e1edk18> TO lwa_sdata_e1edk18.

    lwa_idoc_data-segnam = lc_e1edk18.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk18.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk18 ASSIGNING <lfs_e1edk18>

***** B) SEGMENT E1EDK35
  LOOP AT li_in_e1edk35 ASSIGNING <lfs_e1edk35>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk35> TO lwa_sdata_e1edk35.

    lwa_idoc_data-segnam = lc_e1edk35.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk35.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk35 ASSIGNING <lfs_e1edk35>

***** B) SEGMENT E1EDK36
  LOOP AT li_in_e1edk36 ASSIGNING <lfs_e1edk36>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edk36> TO lwa_sdata_e1edk36.

    lwa_idoc_data-segnam = lc_e1edk36.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edk36.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.
  ENDLOOP. " LOOP AT li_in_e1edk36 ASSIGNING <lfs_e1edk36>

***** B) SEGMENT E1EDKT1

  LOOP AT li_in_e1edkt1 ASSIGNING <lfs_e1edkt1>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edkt1> TO lwa_sdata_e1edkt1.

    lwa_idoc_data-segnam = lc_e1edkt1.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edkt1.
    APPEND lwa_idoc_data TO li_idoc_data.
    CLEAR: lwa_idoc_data.


    li_in_e1edkt2 = <lfs_e1edkt1>-e1edkt2.
    LOOP AT li_in_e1edkt2 ASSIGNING <lfs_e1edkt2>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edkt2> TO lwa_sdata_e1edkt2.

      lwa_idoc_data-segnam = lc_e1edkt2.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
      lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
      lwa_idoc_data-sdata  = lwa_sdata_e1edkt2.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR: lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edkt2 ASSIGNING <lfs_e1edkt2>
  ENDLOOP. " LOOP AT li_in_e1edkt1 ASSIGNING <lfs_e1edkt1>


***** B) SEGMENT E1EDP01
  LOOP AT li_in_e1edp01 ASSIGNING <lfs_e1edp01>.
    lv_seg = lv_seg + 1.
    MOVE-CORRESPONDING <lfs_e1edp01> TO lwa_sdata_e1edp01.
    MOVE-CORRESPONDING <lfs_e1edp01> TO ls_tmp_item.
    MOVE <LFS_E1EDP01>-POSEX TO lv_posnr.
    lwa_idoc_data-segnam = lc_e1edp01.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
    lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
    lwa_idoc_data-sdata  = lwa_sdata_e1edp01.
    APPEND lwa_idoc_data TO li_idoc_data.
*    APPEND ls_tmp_item TO li_tmp_item.
    CLEAR: lwa_idoc_data,ls_tmp_item.
******
* Begin of Defect - 7019
    li_in_e1edp02 = <lfs_e1edp01>-e1edp02.
    LOOP AT li_in_e1edp02 ASSIGNING <lfs_e1edp02>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp02> TO lwa_sdata_e1edp02.
      lwa_idoc_data-segnam = lc_e1edp02.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp02.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp02 ASSIGNING <lfs_e1edp02>

    IF <lfs_e1edp01>-e1curef IS NOT INITIAL.
      <lfs_e1curef> = <lfs_e1edp01>-e1curef.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1curef> TO lwa_sdata_e1curef.
      lwa_idoc_data-segnam = lc_e1curef.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1curef.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDIF. " IF <lfs_e1edp01>-e1curef IS NOT INITIAL

    li_in_e1addi1 = <lfs_e1edp01>-e1addi1.
    LOOP AT li_in_e1addi1 ASSIGNING <lfs_e1addi1>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1addi1> TO lwa_sdata_e1addi1.
      lwa_idoc_data-segnam = lc_e1addi1.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1addi1.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1addi1 ASSIGNING <lfs_e1addi1>

    li_in_e1edp03 = <lfs_e1edp01>-e1edp03.
    LOOP AT li_in_e1edp03 ASSIGNING <lfs_e1edp03>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp03> TO lwa_sdata_e1edp03.
      lwa_idoc_data-segnam = lc_e1edp03.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp03.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp03 ASSIGNING <lfs_e1edp03>

    li_in_e1edp04 = <lfs_e1edp01>-e1edp04.
    LOOP AT li_in_e1edp04 ASSIGNING <lfs_e1edp04>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp04> TO lwa_sdata_e1edp04.
      lwa_idoc_data-segnam = lc_e1edp04.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp04.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp04 ASSIGNING <lfs_e1edp04>

    li_in_e1edp05 = <lfs_e1edp01>-e1edp05.
    LOOP AT li_in_e1edp05 ASSIGNING <lfs_e1edp05>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp05> TO lwa_sdata_e1edp05.
      lwa_idoc_data-segnam = lc_e1edp05.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp05.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.

      IF <lfs_e1edps5> IS ASSIGNED.
        li_in_e1edps5 = <lfs_e1edp05>-e1edps5.
        LOOP AT li_in_e1edps5 ASSIGNING <lfs_e1edps5>.
          lv_seg = lv_seg + 1.
          MOVE-CORRESPONDING <lfs_e1edpt2> TO lwa_sdata_e1edps5.
          lwa_idoc_data-segnam = lc_e1edps5.
          lwa_idoc_data-segnum  = lv_seg.
          lwa_idoc_data-sdata  = lwa_sdata_e1edps5.
          APPEND lwa_idoc_data TO li_idoc_data.
          CLEAR lwa_idoc_data.
        ENDLOOP. " LOOP AT li_in_e1edps5 ASSIGNING <lfs_e1edps5>
      ENDIF. " IF <lfs_e1edps5> IS ASSIGNED
    ENDLOOP. " LOOP AT li_in_e1edp05 ASSIGNING <lfs_e1edp05>

    li_in_e1edp20 = <lfs_e1edp01>-e1edp20.
    LOOP AT li_in_e1edp20 ASSIGNING <lfs_e1edp20>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp20> TO lwa_sdata_e1edp20.
      lwa_idoc_data-segnam = lc_e1edp20.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp20.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp20 ASSIGNING <lfs_e1edp20>

    li_in_e1edpa1 = <lfs_e1edp01>-e1edpa1.
    LOOP AT li_in_e1edpa1 ASSIGNING <lfs_e1edpa1>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edpa1> TO lwa_sdata_e1edpa1.
      lwa_idoc_data-segnam = lc_e1edpa1.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edpa1.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.

      IF <lfs_e1edpa1> IS ASSIGNED.
        li_in_e1edpa3 = <lfs_e1edpa1>-e1edpa3.
        LOOP AT li_in_e1edpa3 ASSIGNING <lfs_e1edpa3>.
          lv_seg = lv_seg + 1.
          MOVE-CORRESPONDING <lfs_e1edpa3> TO lwa_sdata_e1edpa3.
          lwa_idoc_data-segnam = lc_e1edpa3.
          lwa_idoc_data-segnum  = lv_seg.
          lwa_idoc_data-sdata  = lwa_sdata_e1edpa3.
          APPEND lwa_idoc_data TO li_idoc_data.
          CLEAR lwa_idoc_data.
        ENDLOOP. " LOOP AT li_in_e1edpa3 ASSIGNING <lfs_e1edpa3>
      ENDIF. " IF <lfs_e1edpa1> IS ASSIGNED
    ENDLOOP. " LOOP AT li_in_e1edpa1 ASSIGNING <lfs_e1edpa1>
* End of Defect - 7019

    li_in_e1edp19 = <lfs_e1edp01>-e1edp19.
    LOOP AT li_in_e1edp19 ASSIGNING <lfs_e1edp19>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp19> TO lwa_sdata_e1edp19.
      MOVE-CORRESPONDING <lfs_e1edp19> TO ls_tmp_item.
      lwa_idoc_data-segnam = lc_e1edp19.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
      lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
      lwa_idoc_data-sdata  = lwa_sdata_e1edp19.
      IF lwa_sdata_e1edp19-qualf EQ '002'.
        MOVE lwa_sdata_e1edp19-idtnr TO ls_tmp_item-matnr.
        move lv_posnr                to ls_tmp_item-posex.
        APPEND ls_tmp_item TO li_tmp_item.
        clear lv_posnr.
      ENDIF. " IF lwa_sdata_e1edp19-qualf EQ '002'
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR: lwa_idoc_data , ls_tmp_item.
    ENDLOOP. " LOOP AT li_in_e1edp19 ASSIGNING <lfs_e1edp19>
* Begin of Defect - 7019
    IF <lfs_e1edp01>-e1edpad IS  NOT INITIAL.
      <lfs_e1edpad> = <lfs_e1edp01>-e1edpad.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edpad> TO lwa_sdata_e1edpad.
      lwa_idoc_data-segnam = lc_e1edpad.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edpad.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDIF. " IF <lfs_e1edp01>-e1edpad IS NOT INITIAL

    li_in_e1edp17 = <lfs_e1edp01>-e1edp17.
    LOOP AT li_in_e1edp17 ASSIGNING <lfs_e1edp17>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp17> TO lwa_sdata_e1edp17.
      lwa_idoc_data-segnam = lc_e1edp17.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp17.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp17 ASSIGNING <lfs_e1edp17>

    li_in_e1edp18 = <lfs_e1edp01>-e1edp18.
    LOOP AT li_in_e1edp18 ASSIGNING <lfs_e1edp18>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp18> TO lwa_sdata_e1edp18.
      lwa_idoc_data-segnam = lc_e1edp18.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp18.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp18 ASSIGNING <lfs_e1edp18>

    li_in_e1edp35 = <lfs_e1edp01>-e1edp35.
    LOOP AT li_in_e1edp35 ASSIGNING <lfs_e1edp35>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edp35> TO lwa_sdata_e1edp35.
      lwa_idoc_data-segnam = lc_e1edp35.
      lwa_idoc_data-segnum  = lv_seg.
      lwa_idoc_data-sdata  = lwa_sdata_e1edp35.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edp35 ASSIGNING <lfs_e1edp35>

* End of Defect - 7019
    li_in_e1edpt1 = <lfs_e1edp01>-e1edpt1.
    LOOP AT li_in_e1edpt1 ASSIGNING <lfs_e1edpt1>.
      lv_seg = lv_seg + 1.
      MOVE-CORRESPONDING <lfs_e1edpt1> TO lwa_sdata_e1edpt1.
      lwa_idoc_data-segnam = lc_e1edpt1.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
      lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
      lwa_idoc_data-sdata  = lwa_sdata_e1edpt1.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR lwa_idoc_data.
    ENDLOOP. " LOOP AT li_in_e1edpt1 ASSIGNING <lfs_e1edpt1>
    IF <lfs_e1edpt1> IS ASSIGNED.
      li_in_e1edpt2 = <lfs_e1edpt1>-e1edpt2.
      LOOP AT li_in_e1edpt2 ASSIGNING <lfs_e1edpt2>.
        lv_seg = lv_seg + 1.
        MOVE-CORRESPONDING <lfs_e1edpt2> TO lwa_sdata_e1edpt2.
        lwa_idoc_data-segnam = lc_e1edpt2.
* Begin of Defect - 7019
*  lwa_idoc_data-hlevel = lv_seg.
        lwa_idoc_data-segnum  = lv_seg.
* End of Defect - 7019
        lwa_idoc_data-sdata  = lwa_sdata_e1edpt2.
        APPEND lwa_idoc_data TO li_idoc_data.
        CLEAR lwa_idoc_data.
      ENDLOOP. " LOOP AT li_in_e1edpt2 ASSIGNING <lfs_e1edpt2>
    ENDIF. " IF <lfs_e1edpt1> IS ASSIGNED
  ENDLOOP. " LOOP AT li_in_e1edp01 ASSIGNING <lfs_e1edp01>
* * Begin of Defect - 7019
* Comented as Discussed with Manoj as this segments are related to Variant configuration
****** B) SEGMENT E1CUCFG
*  LOOP AT li_in_e1cucfg ASSIGNING <lfs_e1cucfg>.
*    lv_seg = lv_seg + 1.
*    MOVE-CORRESPONDING <lfs_e1cucfg> TO lwa_sdata_e1cucfg.
*
*    lwa_idoc_data-segnam = lc_e1cucfg.
** Begin of Defect - 7019
**  lwa_idoc_data-hlevel = lv_seg.
*    lwa_idoc_data-segnum  = lv_seg.
** End of Defect - 7019
*
*    lwa_idoc_data-sdata  = lwa_sdata_e1cucfg.
*    APPEND lwa_idoc_data TO li_idoc_data.
*    CLEAR: lwa_idoc_data.
*  ENDLOOP. " LOOP AT li_in_e1cucfg ASSIGNING <lfs_e1cucfg>
*
****** B) SEGMENT E1EDL37
*  LOOP AT li_in_e1edl37 ASSIGNING <lfs_e1edl37>.
*    lv_seg = lv_seg + 1.
*    MOVE-CORRESPONDING <lfs_e1edl37> TO lwa_sdata_e1edl37.
*
*    lwa_idoc_data-segnam = lc_e1edl37.
** Begin of Defect - 7019
**  lwa_idoc_data-hlevel = lv_seg.
*    lwa_idoc_data-segnum  = lv_seg.
** End of Defect - 7019
*
*    lwa_idoc_data-sdata  = lwa_sdata_e1edl37.
*    APPEND lwa_idoc_data TO li_idoc_data.
*    CLEAR: lwa_idoc_data.
*  ENDLOOP. " LOOP AT li_in_e1edl37 ASSIGNING <lfs_e1edl37>
*
****** B) SEGMENT E1EDS01
*  LOOP AT li_in_e1eds01 ASSIGNING <lfs_e1eds01>.
*    lv_seg = lv_seg + 1.
*    MOVE-CORRESPONDING <lfs_e1eds01> TO lwa_sdata_e1eds01.
*    lwa_idoc_data-segnam = lc_e1eds01.
** Begin of Defect - 7019
**  lwa_idoc_data-hlevel = lv_seg.
*    lwa_idoc_data-segnum  = lv_seg.
** End of Defect - 7019
*    lwa_idoc_data-sdata  = lwa_sdata_e1eds01.
*    APPEND lwa_idoc_data TO li_idoc_data.
*    CLEAR: lwa_idoc_data.
*  ENDLOOP. " LOOP AT li_in_e1eds01 ASSIGNING <lfs_e1eds01>
* End of Defect - 7019
*  create object
  CREATE OBJECT lo_object.
  IF lo_object IS BOUND.

    CALL METHOD lo_object->determine_sold_to
      EXPORTING
        im_input_head       = li_idoc_header
      CHANGING
        ch_item             = li_idoc_data
        ch_output           = ls_output
      EXCEPTIONS
        no_sales_data_found = 1
        no_edsdc_entry      = 2
        no_soldto_shipto    = 3
        others              = 4.

    IF sy-subrc <> 0.
      CASE sy-subrc.
        WHEN 1.
* Implement suitable error handling here
          lwa_msg_bapi-type    = zcacl_message_container=>c_error. "E
          lwa_msg_bapi-id      = 'ZOTC_MSG'. " attrc_msgid. "ZOTC_MSG
          lwa_msg_bapi-number  = '919'.
          APPEND lwa_msg_bapi TO ex_bapi_msg.
          CLEAR lwa_msg_bapi.
          EXIT.
        WHEN 2.
* Implement suitable error handling here
          lwa_msg_bapi-type    = zcacl_message_container=>c_error. "E
          lwa_msg_bapi-id      = 'ZOTC_MSG'. " attrc_msgid. "ZOTC_MSG
          lwa_msg_bapi-number  = '934'.
          APPEND lwa_msg_bapi TO ex_bapi_msg.
          CLEAR lwa_msg_bapi.
          EXIT.
* Begin of Defect 2723
        WHEN 3.
* Implement suitable error handling here
          lwa_msg_bapi-type    = zcacl_message_container=>c_error. "E
          lwa_msg_bapi-id      = 'ZOTC_MSG'. " attrc_msgid. "ZOTC_MSG
          lwa_msg_bapi-number  = '298'.
          APPEND lwa_msg_bapi TO ex_bapi_msg.
          CLEAR lwa_msg_bapi.
          EXIT.
*End of Defect 2723
      ENDCASE.
    ELSE. " ELSE -> IF sy-subrc <> 0
      READ TABLE li_idoc_header INTO lwa_idoc_header INDEX 1.
      IF lwa_idoc_header-rcvlad NE 'D3'.
        SORT li_idoc_data BY segnum.
        LOOP AT li_idoc_data INTO lwa_idoc_data.
          CLEAR lv_seg.
          lv_seg = sy-tabix.
          lwa_idoc_data-segnum = lv_seg.
          MODIFY li_idoc_data FROM lwa_idoc_data INDEX sy-tabix TRANSPORTING segnum.
        ENDLOOP. " LOOP AT li_idoc_data INTO lwa_idoc_data
*************** Create IDOC
        CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
          TABLES
            idoc_control_rec_40 = li_idoc_header
            idoc_data_rec_40    = li_idoc_data.

      ELSE. " ELSE -> IF lwa_idoc_header-rcvlad NE 'D3'
* Validate if Material is Valid for D3 or not
        CALL METHOD lo_object->vaidate_material
          EXPORTING
            im_item            = li_tmp_item
          IMPORTING
            ex_bapi_msg        = ex_bapi_msg
          EXCEPTIONS
            material_not_found = 1
            OTHERS             = 2.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF. " IF sy-subrc <> 0
* Begin of the Split Logic
        IF ls_output-lrd EQ abap_true.
          SELECT SINGLE land1 katr5 FROM kna1 INTO (ls_output-sp_land , lv_katr5) WHERE kunnr EQ ls_output-kunnr_sp.
* Begin of CR 313
          if lv_katr5 is not initial.
            ls_output-sp_land = lv_katr5.
          endif.
* End of CR 313
          IF ls_output-sp_land IS NOT INITIAL.
            CALL METHOD lo_object->process_lrd
              EXPORTING
                im_land1                 = ls_output-sp_land
              IMPORTING
                ex_bapi_msg              = ex_bapi_msg
              CHANGING
                ch_item                  = li_tmp_item
              EXCEPTIONS
                material_class_not_found = 1
                OTHERS                   = 2.
            IF sy-subrc <> 0.
              EXIT.
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF ls_output-sp_land IS NOT INITIAL
          IF li_tmp_item IS NOT INITIAL.

            CALL METHOD lo_object->prepare_edi_split
              EXPORTING
                im_sp               = ls_output-kunnr_sp
                im_lrd              = ls_output-lrd
                im_sp_land          = ls_output-sp_land
                im_head             = li_idoc_header
                im_item             = li_tmp_item
              CHANGING
                ch_item             = li_idoc_data
              EXCEPTIONS
                no_sales_data_found = 1
                OTHERS              = 2.
            IF sy-subrc <> 0.
* Implement suitable error handling here
              lwa_msg_bapi-type    = zcacl_message_container=>c_error. "E
              lwa_msg_bapi-id      = 'ZOTC_MSG'. " attrc_msgid. "ZOTC_MSG
              lwa_msg_bapi-number  = 919.
              APPEND lwa_msg_bapi TO ex_bapi_msg.
              CLEAR lwa_msg_bapi.
              EXIT.
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF li_tmp_item IS NOT INITIAL
        ELSE. " ELSE -> IF ls_output-lrd EQ abap_true
          IF li_tmp_item IS NOT INITIAL.
            CALL METHOD lo_object->process_nlrd
              IMPORTING
                ex_bapi_msg               = ex_bapi_msg
              CHANGING
                ch_item                   = li_tmp_item
              EXCEPTIONS
                lab_office_not_maintained = 1
                OTHERS                    = 2.
            IF sy-subrc <> 0.
              EXIT.
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF li_tmp_item IS NOT INITIAL
          IF ls_output-kunnr_sp IS NOT INITIAL.
            CALL METHOD lo_object->prepare_edi_split
              EXPORTING
                im_sp               = ls_output-kunnr_sp
                im_lrd              = ls_output-lrd
                im_sp_land          = ls_output-sp_land
                im_head             = li_idoc_header
                im_item             = li_tmp_item
              CHANGING
                ch_item             = li_idoc_data
              EXCEPTIONS
                no_sales_data_found = 1
                OTHERS              = 2.
            IF sy-subrc <> 0.
* Implement suitable error handling here
              lwa_msg_bapi-type    = zcacl_message_container=>c_error. "E
              lwa_msg_bapi-id      = 'ZOTC_MSG'. " attrc_msgid. "ZOTC_MSG
              lwa_msg_bapi-number  = 919.
              APPEND lwa_msg_bapi TO ex_bapi_msg.
              CLEAR lwa_msg_bapi.
              EXIT.
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF ls_output-kunnr_sp IS NOT INITIAL
        ENDIF. " IF ls_output-lrd EQ abap_true
      ENDIF. " IF lwa_idoc_header-rcvlad NE 'D3'
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF lo_object IS BOUND
ENDMETHOD.


METHOD feh_execute.
***********************************************************************
*Program    : ZOTCCL_SALES_ORDER_EDI850~FEH_EXECUTE                   *
*Title      : Inbound Sales Order EDI 850                             *
*Developer  : Monika Garg                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
*Description: For Errors, Forward Error Handling(FEH) has been        *
* implemented with business Process ZOTC_ED850.                       *
***********************************************************************
*METH_INST_PUB_FEH_EXECUTE:This method is called further to execute   *
*forward error handling.FEH errors generated can be seen via T-CODE   *
*  /SAPPO/PPO2 or /SAPPO/PPO3.
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG        E1DK918357      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

*Local data declarations
  DATA:lv_raise_exception TYPE xflag,                      " New Input Values
       lref_registration  TYPE REF TO cl_feh_registration, " Registration and Restarting of FEH
       lref_cx_system     TYPE REF TO cx_ai_system_fault,  " Application Integration: Technical Error
       lv_mtext           TYPE string,                     " Text value
       li_bapiret         TYPE bapirettab.                 "Table with BAPI Return Information

  FIELD-SYMBOLS : <lfs_feh_data> TYPE zca_feh_data. " FEH Line
  CONSTANTS  :    lc_msg_fault   TYPE  classname VALUE 'Z01OTC_CX_STANDARD_MESSAGE_FAU'. " Reference type

  IF lines( attrv_feh_data ) > 0.

    IF im_ref_registration IS BOUND.
      CLEAR lv_raise_exception.
      lref_registration = im_ref_registration.
    ELSE. " ELSE -> IF im_ref_registration IS BOUND
      lv_raise_exception = abap_true.
      lref_registration = cl_feh_registration=>s_initialize( is_single = space ).
    ENDIF. " IF im_ref_registration IS BOUND

    TRY.
*--- Process all objects individually ---------------------*
        READ TABLE attrv_feh_data ASSIGNING <lfs_feh_data> INDEX 1.

        IF sy-subrc = 0.
*----- Error in mapping -----------------------------------*
          CALL METHOD lref_registration->collect
            EXPORTING
              i_external_guid  = <lfs_feh_data>-external_guid
              i_single_bo_ref  = <lfs_feh_data>-single_bo_ref
              i_hidden_data    = <lfs_feh_data>-hidden_data
              i_error_category = <lfs_feh_data>-error_category
              i_main_message   = <lfs_feh_data>-main_message
              i_messages       = <lfs_feh_data>-all_messages
              i_main_object    = <lfs_feh_data>-main_object
              i_objects        = <lfs_feh_data>-all_objects
              i_pre_mapping    = <lfs_feh_data>-pre_mapping.
          APPEND LINES OF <lfs_feh_data>-all_messages TO li_bapiret.
        ENDIF. " IF sy-subrc = 0

      CATCH cx_ai_system_fault INTO lref_cx_system.
        lv_mtext = lref_cx_system->get_text( ).
        MESSAGE x026(bs_soa_common) WITH lv_mtext. " System error in the ForwardError Handling: &1
    ENDTRY.
*----- Refresh errors --------------------------------------*
    REFRESH attrv_feh_data.

*----- Raise Exception -------------------------------------*
    IF lv_raise_exception = abap_true.

* Please raise the same exception in the proxy method definition.
      CALL METHOD cl_proxy_fault=>raise(
        EXPORTING
          exception_class_name = lc_msg_fault
          bapireturn_tab       = li_bapiret ).
    ENDIF. " IF lv_raise_exception = abap_true

  ENDIF. " IF lines( attrv_feh_data ) > 0
ENDMETHOD.


METHOD feh_prepare.
***********************************************************************
*Program    : FEH_PREPARE                                             *
*Title      : ZOTCCL_SALES_ORDER_EDI850~FEH_PREPARE                   *
*Developer  : Monika Garg                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                      *
*---------------------------------------------------------------------*
*Description: For Errors, Forward Error Handling(FEH) has been        *
* implemented with business Process ZOTC_ED850.                       *
***********************************************************************
* Method (FEH_PREPARE ) :: This method is called to fill ECH (Error & *
* Conflict Handler) structure and fill in the table I_FEH_DATA.       *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG        E1DK918357      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

*Local data declarations.
  DATA:lwa_feh_data         TYPE zca_feh_data,   "FEH Line
       lwa_ech_main_object  TYPE ech_str_object, "Object of Business Process
       li_applmsg           TYPE applmsgtab,     "Return Table for Messages
** lr_data is used to in reference to proxy, so it can not be avoided
       lr_data              TYPE REF TO data,    "class
       lv_objkey            TYPE ech_dte_objkey, " Object Key
       lwa_bapiret          TYPE bapiret2.       "Return Parameter

  FIELD-SYMBOLS :
        <lfs_appl_msg>      TYPE applmsg. " Return Structure for Messages
  CONSTANTS:
        lc_one              TYPE ech_dte_objcat VALUE '1',            " Object Category
        lc_obj              TYPE char13         VALUE 'OTC_IDD_0009'. " Object Key

  lv_objkey = lc_obj.

* The error category should depends on the actually error not below testing category
  lwa_feh_data-error_category  = attrv_msg_container->get_err_category( ).

  lwa_ech_main_object-objcat  = lc_one.
  lwa_ech_main_object-objtype = me->attrv_objtype.
  lwa_ech_main_object-objkey  = lv_objkey.
  lwa_feh_data-main_object    = lwa_ech_main_object.

  GET REFERENCE OF im_input INTO lr_data.
  IF sy-subrc EQ 0.
    lwa_feh_data-single_bo_ref = lr_data.
  ENDIF. " IF sy-subrc EQ 0

  li_applmsg = attrv_msg_container->get_appl_messages( ).
  LOOP AT li_applmsg ASSIGNING <lfs_appl_msg>.
*Moving all fields isntead of using MOVE CORRESPONDING.
    lwa_bapiret-type        = <lfs_appl_msg>-type.
    lwa_bapiret-id          = <lfs_appl_msg>-id.
    lwa_bapiret-number      = <lfs_appl_msg>-number.
    lwa_bapiret-message     = <lfs_appl_msg>-message.
    lwa_bapiret-log_no      = <lfs_appl_msg>-log_no.
    lwa_bapiret-log_msg_no  = <lfs_appl_msg>-log_msg_no.
    lwa_bapiret-message_v1  = <lfs_appl_msg>-message_v1.
    lwa_bapiret-message_v2  = <lfs_appl_msg>-message_v2.
    lwa_bapiret-message_v3  = <lfs_appl_msg>-message_v3.
    lwa_bapiret-message_v4  = <lfs_appl_msg>-message_v4.
    lwa_bapiret-parameter   = <lfs_appl_msg>-parameter.
    lwa_bapiret-row         = <lfs_appl_msg>-row.
    lwa_bapiret-field       = <lfs_appl_msg>-field.
    lwa_bapiret-system      = <lfs_appl_msg>-system.

    APPEND lwa_bapiret TO lwa_feh_data-all_messages.
    CLEAR lwa_bapiret.
  ENDLOOP. " LOOP AT li_applmsg ASSIGNING <lfs_appl_msg>

* Get main message from message container
  lwa_feh_data-main_message = attrv_msg_container->get_main_error( ).

* To Populate Main message
  READ TABLE lwa_feh_data-all_messages INDEX 1 INTO lwa_feh_data-main_message.
  IF sy-subrc NE 0.
    CLEAR lwa_feh_data-main_message.
  ENDIF. " IF sy-subrc NE 0

*--- Store information locally ----------------------------------------------*
  APPEND lwa_feh_data TO attrv_feh_data.
  CLEAR lwa_feh_data.
ENDMETHOD.


METHOD get_message_id.
***********************************************************************
*Program    : GET MESSAGE ID                                          *
*Title      : ZOTCCL_SALES_ORDER_EDI850~CGET_MESSAGE_ID               *
*Developer  : Manish Bagda / Monika Garg                              *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
* Description: This Method is used to find message ID from Proxy format*
*              and pass it to IDOC Format in Identification field     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*13-Nov-2016   MBAGDA/MGARG E1DK918357      INITIAL DEVELOPMENT       *
*                                    Adding Message ID in Idoc control*
*                                    record Defect#6544               *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
  CONSTANTS:
    lc_err             TYPE char1         VALUE 'E',                        "Err of type CHAR1
    lc_message         TYPE char24        VALUE 'IF_WSPROTOCOL_MESSAGE_ID'. " Message of type CHAR24

  DATA:
     lref_protocol     TYPE REF TO if_wsprotocol,            " ABAP Proxies: Available Protocols
     lref_server_cntxt TYPE REF TO if_ws_server_context,     " Proxy Server Context
     lref_wsprotocol_msg_id
                       TYPE REF TO if_wsprotocol_message_id, " XI and WS: Read Message ID
     lv_protocol_name  TYPE string,
     lref_cx_root      TYPE REF TO cx_root.                  " Abstract Superclass for All Global Exceptions


* Here table will be populated with Message Id and Document number when Document get created
* Get the Protocol Name as IF_WSPROTOCOL_MESSAGE_ID
  lv_protocol_name = lc_message.

  TRY .
      CALL METHOD cl_proxy_access=>get_server_context
        RECEIVING
          server_context = lref_server_cntxt.

* Get the Message ID Reference to fetch XML Message GUID.
      CALL METHOD lref_server_cntxt->get_protocol
        EXPORTING
          protocol_name = lv_protocol_name
        RECEIVING
          protocol      = lref_protocol.
    CATCH cx_ai_system_fault INTO lref_cx_root.
      MESSAGE lref_cx_root TYPE lc_err.
  ENDTRY.

  TRY.
      lref_wsprotocol_msg_id ?= lref_protocol.
    CATCH cx_root INTO lref_cx_root ##catch_all.
      MESSAGE lref_cx_root TYPE lc_err.
  ENDTRY.

  IF lref_cx_root IS NOT BOUND.
*       XML-message ID determination
    ex_message_id = lref_wsprotocol_msg_id->get_message_id( ).
  ENDIF. " IF lref_cx_root IS NOT BOUND

ENDMETHOD.


METHOD has_error.
***********************************************************************
*Program    : HAS_ERROR                                               *
*Title      : ZOTCCL_SALES_ORDER_EDI850~HAS_ERROR                     *
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
*20-OCT-2016  MGARG/U033814  E1DK918357      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
** In case of Error/Abort,Set variable re_result
  re_result = attrv_msg_container->has_error( ).
ENDMETHOD.


METHOD if_ech_action~fail.
***********************************************************************
*Program    : IF_ECH_ACTION~FAIL                                      *
*Title      : Inbound Sales Order EDI 850                             *
*Developer  : Monika Garg                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
*Description: For Errors, Forward Error Handling(FEH) has been        *
* implemented with business Process ZOTC_ED850.                       *
***********************************************************************
*METHOD(IF_ECH_ACTION~FAIL): When error is reprocessed and after repro*
*cess,it got failed, then this method will be called.                 *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG        E1DK918357      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

  CONSTANTS  : lc_fail TYPE  bs_soa_siw_dte_proc_context VALUE 'FAIL'. " Processing context of service implementation

  me->initialize( im_id_processing_context = lc_fail ).

* Set the status to failed in FEH
  CALL METHOD cl_feh_registration=>s_fail
    EXPORTING
      i_data             = i_data
    IMPORTING
      e_execution_failed = e_execution_failed
      e_return_message   = e_return_message.
ENDMETHOD.


method IF_ECH_ACTION~FINALIZE_AFTER_RETRY_ERROR.

endmethod.


METHOD if_ech_action~finish.
***********************************************************************
*Program    : IF_ECH_ACTION~FINISH                                    *
*Title      : Inbound Sales Order EDI 850                             *
*Developer  : Monika Garg                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
*Description: For Errors, Forward Error Handling(FEH) has been        *
* implemented with business Process ZOTC_ED850.                       *
***********************************************************************
* Method:IF_ECH_ACTION~FINISH :: This is in case of FEH. Set status to*
* finish.                                                             *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG        E1DK918357      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*
  CONSTANTS : lc_finish TYPE bs_soa_siw_dte_proc_context  VALUE 'FINISH'. " Processing context of service implementation

  me->initialize( im_id_processing_context = lc_finish ).

* Set the status to finish in FEH
  CALL METHOD cl_feh_registration=>s_finish
    EXPORTING
      i_data             = i_data
    IMPORTING
      e_execution_failed = e_execution_failed
      e_return_message   = e_return_message.
ENDMETHOD.


method IF_ECH_ACTION~NO_ROLLBACK_ON_RETRY_ERROR.

endmethod.


METHOD if_ech_action~retry.
***********************************************************************
*Program    : IF_ECH_ACTION~RETRY                                     *
*Title      : Inbound Sales Order EDI 850                             *
*Developer  : Monika Garg                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
*Description: For Errors, Forward Error Handling(FEH) has been        *
* implemented with business Process ZOTC_ED850.                       *
***********************************************************************
*METHOD:IF_ECH_ACTION~RETRY::When error is reprocessed through T-code *
* /SAPPO/PPO2, Then this method will be called.                       *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG        E1DK918357      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*

  DATA: lref_feh_registration  TYPE REF TO cl_feh_registration, " Registration and Restarting of FEH
        ls_admin               TYPE cl_feh_payload_mapper=>ty_s_admin_data,
        lx_input               TYPE z01otc_orders05.           " Inbound Message type for IDD0183

  CONSTANTS: lc_retry TYPE bs_soa_siw_dte_proc_context  VALUE 'RETRY'. " Processing context of service implementation

  FIELD-SYMBOLS: <lfs_payload_with_admin> TYPE any.

  CLEAR:e_execution_failed,
        e_return_message.
* Initialize business logic class
  me->initialize( im_id_processing_context = lc_retry ).

  lref_feh_registration = cl_feh_registration=>s_retry( i_error_object_id = i_error_object_id ).

** Get Collection GUID
  ASSIGN i_data->* TO <lfs_payload_with_admin>.
  cl_feh_payload_mapper=>s_create( )->map_xml_to_data_type(
                                   EXPORTING iv_payload_xml  = <lfs_payload_with_admin>
                                   IMPORTING
                                             es_data_admin   = ls_admin ).
  attrv_collection_id = ls_admin-collection_id.

* Retrieve data the staged data from ECH
  CALL METHOD lref_feh_registration->retrieve_data
    EXPORTING
      i_data              = i_data
    IMPORTING
      e_post_mapping_data = lx_input.

  me->start_processing( lx_input ). "#EC ENHOK

* If the error happens again, call the FEH API again
  IF me->has_error( ) = abap_true.

    me->feh_execute( im_ref_registration = lref_feh_registration ).

  ENDIF. " IF me->has_error( ) = abap_true

  lref_feh_registration->resolve_retry( ).
ENDMETHOD.


METHOD if_ech_action~s_create.
***********************************************************************
*Program    : IF_ECH_ACTION~S_CREATE                                  *
*Title      : Inbound Sales Order EDI 850                             *
*Developer  : Monika Garg                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_IDD_0009_SAP                                       *
*---------------------------------------------------------------------*
*Description: For Errors, Forward Error Handling(FEH) has been        *
* implemented with business Process ZOTC_ED850.                       *
***********************************************************************
*METHOD:IF_ECH_ACTION~S_CREATE :: Create object of action class ATTRV_*
* ECH_ACTION.  This is for handling FEH.                              *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-OCT-2016   MGARG        E1DK918357      INITIAL DEVELOPMENT       *
*---------------------------------------------------------------------*
  IF NOT attrv_ech_action IS BOUND.
    CREATE OBJECT attrv_ech_action.
  ENDIF. " IF NOT attrv_ech_action IS BOUND
  r_action_class = attrv_ech_action. "  class
ENDMETHOD.


METHOD initialize.
***********************************************************************
*Program    : INITIALIZE                                              *
*Title      : ZOTCCL_SALES_ORDER_EDI850~INITIALIZE                    *
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
*20-OCT-2016  MGARG/U033814  E1DK918357      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*

  CONSTANTS : lc_retry   TYPE bs_soa_siw_dte_proc_context VALUE 'RETRY',  " Processing context of service implementation
              lc_fail    TYPE bs_soa_siw_dte_proc_context VALUE 'FAIL',   " Processing context of service implementation
              lc_finish  TYPE bs_soa_siw_dte_proc_context VALUE 'FINISH', " Processing context of service implementation
              lc_objtype TYPE ech_dte_objtype             VALUE 'BUS2144'.

*--Call the refresh method message container class.
  attrv_msg_container->refresh( ).
  me->refresh( ).
  attrv_pro_context = im_id_processing_context.

*--Check the Processing COntext
  IF attrv_pro_context EQ lc_retry OR
     attrv_pro_context EQ lc_fail OR
     attrv_pro_context EQ lc_finish.
    REFRESH: attrv_feh_data.
  ENDIF. " IF attrv_pro_context EQ lc_retry OR
*--Assign Business Object
  attrv_objtype = lc_objtype.
  attrv_ech_action  = me.
ENDMETHOD.


METHOD refresh.
***********************************************************************
*Program    : REFRESH                                                 *
*Title      : ZOTCCL_SALES_ORDER_EDI850~REFRESH                       *
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
*20-OCT-2016  MGARG/U033814  E1DK918357      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
  REFRESH attrv_feh_data.

  CLEAR:attrv_pro_context,
        attrv_objtype.
ENDMETHOD.


METHOD start_processing.
***********************************************************************
*Program    : START_PROCESSING                                        *
*Title      : ZOTCCL_SALES_ORDER_EDI850~START_PROCESSING              *
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
*20-OCT-2016  MGARG/U033814  E1DK918357      INITIAL DEVELOPMENT      *
*---------------------------------------------------------------------*
* Constant Declaration
  CONSTANTS:
        lc_msg         TYPE symsgno VALUE '000'. " Message Number

*Variables/Internal Table Declaration
  DATA:
        li_bapi_msg    TYPE bapirettab,     "Table with BAPI Return Information
        lwa_bapi_msg   TYPE bapiret2,       "Return Parameter
        lref_oref      TYPE REF TO cx_root, "Abstract Superclass for All Global Exceptions
        lv_text        TYPE string.         "String

* Field symbols
  FIELD-SYMBOLS:
        <lfs_bapi_msg> TYPE bapiret2. " Return Parameter

  TRY.
      me->initialize( ).
*Calling POPULATE_BAPI method for Populating BAPI"BAPI_ACC_DOCUMENT_POST"
*If there is any error, populate table li_bapi_msg, else Post Document
      CALL METHOD me->create_idoc
        EXPORTING
          im_input    = im_input
        IMPORTING
          ex_bapi_msg = li_bapi_msg.

** Adding the BAPI messages
      LOOP AT li_bapi_msg ASSIGNING <lfs_bapi_msg>.
        me->attrv_msg_container->add_bapi_message( <lfs_bapi_msg> ).
      ENDLOOP. " LOOP AT li_bapi_msg ASSIGNING <lfs_bapi_msg>

* IF ERROR HAPPENS, FILL THE ECH STRUCTURE
      IF me->has_error( ) = abap_true.
        me->attrv_msg_container->set_err_category( zcacl_message_container=>c_post_err_category ).
        me->feh_prepare( im_input ).
      ENDIF. " IF me->has_error( ) = abap_true

    CATCH cx_root INTO lref_oref.
      lv_text                 = lref_oref->get_text( ).
      lwa_bapi_msg-type       = zcacl_message_container=>c_error.
      lwa_bapi_msg-id         = attrc_msgid.
      lwa_bapi_msg-number     = lc_msg.
      lwa_bapi_msg-message_v1 = lv_text.
      me->attrv_msg_container->add_bapi_message( lwa_bapi_msg ).

  ENDTRY.
ENDMETHOD.
ENDCLASS.
