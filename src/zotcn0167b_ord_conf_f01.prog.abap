*&---------------------------------------------------------------------*
*&  Include           ZOTCN0167B_ORD_CONF_F01
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0167B_ORD_CONF_F01                                 *
*Title      : Order acknowledgement                                   *
*Developer  : Nidhi Saxena (NSAXENA)                                  *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0167_SAP                                       *
*---------------------------------------------------------------------*
*Description: Send Order acknowledgement to PI and PI will send it    *
* as EMAIL in HTML format.                                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*======================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ============================*
*01-Dec-2014  NSAXENA        E2DK906816     Initial DEvelopment.       *
*22-jan-2014  NSAXENA        E2DK906816     Defect #3124- Change the   *
*                                           logic for ship to and sold *
*                                           to address details.        *
*27-Feb-2015  NSAXENA       E2DK906816      Defect # 3587-Using FM to  *
*                                           Convert intrnal format txt *
*                                           to external format text    *
*18-Mar-2015  NSAXENA       E2DK906816      Defect - 4825,Add texts id *
* at item level with text id Z014 and Z017  for more matrl description *
*Also, adding Street 3 logic for Mexico address                        *
*For Defect - 4872, no change ate ABAP Side only PI mapping required   *
*for Additional House id at Ship to address details                    *
*                                                                      *
*30-Mar-2015 NSAXENA        E2DK906816     Defect-5418 Removing the    *
*text id Z017 detail at item level to keep FDD-12,FDD-14 and IDD-0167  *
* in sync. Adding the new Tax calculations logic at item level.        *
*                                                                      *
*31-Mar-2015 NSAXENA       E2DK906816      Defect-4414 email id blank  *
*has been picked up for contact perosn details.                        *
*                                                                      *
*31-Mar-2015 NSAXENA       E2DK906816      Defect-5424 Est del date    *
* should not print when the confirmed qty is 0 for that line item.     *
*13-Apr-2015 NSAXENA       E2DK906816      Defect-5319 Processing log  *
* has been updated with message id whenever the the sales order get    *
* successfully triggered.                                              *
*                                                                      *
*16-Apr-2015 NSAXENA       E2DK906816  Defect-6018,Unit Price and      *
*extended price logic chnage                                           *
*                                                                      *
*24-Apr-2015 NSAXENA      E2DK906816 Defect-6219,Discard Rejected Lines*
*----------------------------------------------------------------------*
*29-Jun-2016 NGARG       E1DK919590 Description:D3_OTC_IDD_0167:Change *
*                                   language,use SOLD-TO-PARTY's       *
*                                   language for ZBA1 and ZBA0 output  *
*                                   where VKORG is not 1000/1020/1103 .*
*                                   For ZCON , set default system      *
*                                   language                           *
*                                   Email Address: For cases where     *
*                                   both CP and ZA are maintained ,    *
*                                   fill email address for both        *
*----------------------------------------------------------------------*
*24-Aug-2016  NGARG     E1DK919590 Defect #3102: The Label             *
*                                 'Attention To' is being sent from    *
*                                 ABAP, hence needed translation here. *
*                                 Also, 'Order Comment' value text was *
*                                 being read in english, hence every   *
*                                 where a text is being read using     *
*                                'READ_TEXT', we have passed gv_spras  *
*                                 language based on Partner). So now   *
*                                 whole email is sent only in partner's*
*                                language.                             *
*----------------------------------------------------------------------*
* 31-Aug-2016  NGARG  E1DK919590 Defect#3682: In order comments field, *
*                                convert the single string into 3      *
*                                different strings.                    *
*                                Each for sales order text, reference  *
*                                text and case reference text          *
*
*----------------------------------------------------------------------*
* 09-Sep-2016 NGARG  E1DK919590 Defect#3931: Remove Carrier( Shipping  *
*                                            conditions) field         *
*----------------------------------------------------------------------*
* 15-Sep-2016 NGARG E1DK919590 Defect#4090: Change text and position   *
*                              of refernce doc type and change subject *
*                              line text
*---------------------------------------------------------------------*
*30-Nov-2015 SAGARWA1     E2DK916249 Defect#1225: Changes for Planned *
*                                    Date and Freight                 *
*---------------------------------------------------------------------*
*09-May-2016 PDEBARU    E2DK917647   CR# 1612 :Change text TBD to     *
*                                    Header date if conf qty is 0     *
*---------------------------------------------------------------------*
*24-May-2016 PDEBARU    E2DK917647   Defect# 1697 : Conversion exit   *
*                                    is used for vbeln                *
*&--------------------------------------------------------------------*
*23-Nov-2016 MGARG      E1DK919590   Defect# 6807: "Attention To"label*
*                                    text language change.            *
*&--------------------------------------------------------------------*
*20-Dec-2016 MGARG      E1DK919590   Defect#6837_CR#289               *
*                                    Defect#6837:If customer’s langu  *
*                                    is neither EN, DE,ES orFR,default*
*                                    printing language should be EN   *
*                                    CR#289:Get Customer Address using*
*                                    FM for D3 only.                  *
*&--------------------------------------------------------------------*
*30-Dec-2016 MGARG      E1DK919590   Defect#8215: Contact Partner ZA  *
*                                    not receiving mail               *
*&--------------------------------------------------------------------*
*11-Jan-2016 U034334/MGARG E1DK919590 CR#301: For D3 Sales Org        *
* - Print Name1, Name 2 fields of sales org in header                 *
* - Print Inco1 and Inco2 under incoterms                             *
*&--------------------------------------------------------------------*
*18-Jan-2016  MGARG     E1DK919590   Defect#8553: For D3 Sales Org    *
*                                    Customer Address format Change   *
*&--------------------------------------------------------------------*
*09-Oct-2017  U029267   E1DK931267   D3 R2 Changes:                   *
*                                    1)Translate existing layout to   *
*                                      the languages Danish, Swedish, *
*                                      Norwegian and Finnish.         *
*                                    2)New labels are added for the   *
*                                      new field “Insurance”, “GLN”.  *
*                                    3) For Document Charges add the  *
*                                      value for the header pricing   *
*                                      condition ZDOC to the field    *
*                                     “Handling” when the pricing     *
*                                      condition is existing in the   *
*                                      sales order header.            *
*                                    4)Fix the Batch print alignment. *
*                                    5)Add Footer text for French only*
*                                    6)Include the bill-to partner    *
*                                      from the SO into the form      *
*                                    7)Envirmt. charge to be added in *
*                                      between "Tax" and "Handling".  *
*                                      Suppress the field from        *
*                                      printing when the value of the *
*                                      field is initial/zero.         *
*                                    8)If email ID of either Contact  *
*                                      Person (AP) or ORDER-Contact   *
*                                      Person (ZA) is present, output *
*                                      ZBA1 triggers 2 messges to PI, *
*                                      but if one of the partnr funct *
*                                      does not contain email ID,     *
*                                      that message fails in PI.      *
*&--------------------------------------------------------------------*
*03-Nov-2017  U029267   E1DK931267     Defect #3909: Date format and  *
*                                     date repeating on Order ack frm *
*&--------------------------------------------------------------------*
*05-Feb-2018  U029267   E1DK931267   D3 R3 Changes:                   *
*                                    1) GLN suppression rules         *
*                                    2) Subtotal for the documentation*
*                                    charge                           *
*                                    3) Suppression when the subtotal *
*                                    is 0 (Freight, dangerous goods,  *
*                                    insurance,documentation handling)*
*                                    4) CUP and CIG Italy             *
*                                    5) EMI setup                     *
*                                    6) Translation                   *
*&--------------------------------------------------------------------*
*07-Feb-2019 SMUKHER4  E2DK922055  R6 Defect# 8305(SCTASK0793192):    *
*                                  1) Add Billing Plan details        *
*                                  2) VAT amount in invoice totals    *
*                                  3) Translations                    *
*&---------------------------------------------------------------------*
*13-Mar-2019 SMUKHER4 E2DK922055  FUT Issues Defect# 8656:             *
*                                 Tax calculation logic for Split tax  *
*                                 invoices, mulitple tax jurisdictions *
*                                 & European order                     *
*&---------------------------------------------------------------------*
*28-Nov-2018   MTHATHA  E1DK937583   SCTASK0764894:Doctype and Doc ref *
*                                    to be passed for ESKER            *
*&---------------------------------------------------------------------*
*29-Mar-2019   U029267  E1DK937579   Defect# 8796:Order Acknowledgement*
*                                    is create for order orginating    *
*                                    from Esker, the words "Esker Ref  *
*                                    #:XXXXXXXXXXXX" appear incorrectly*
*                                    in the Invoice- Order             *
*                                    Acknowledgement text field.       *
*&---------------------------------------------------------------------*
*21-May-2019   ASK  E2DK924099    INC0485087-01 Put the ESKER related change for    *
*                                 skipping EMAIL validations          *
*&--------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*18-Jun-2019   ASK   E2DK924727    Defect 9877 Remove 'Promo Code #' text*
*                                 from Attent to field                *
*&--------------------------------------------------------------------*
*24-Jul-2019   MTHATHA   E2DK924485  CPQ order confirmation           *
*&--------------------------------------------------------------------*
*----------------------------------------------------------------------*
* 22/08/2019  U106341                 HANAtization changes
*----------------------------------------------------------------------*



*&      Form  F_GET_ITEM_DATA
*&---------------------------------------------------------------------*
* Populate the item data
*----------------------------------------------------------------------*
*      -->FP_VBELN        Sales Document Number                        *
*      -->FP_HEADER       Header data                                  *
*     -->FP_STRUCTURE_OUT  Purchase order confirmation structure       *
*     -->FP_LANGU          Langauge key                                *
*     -->FP_RETCODE        Return Code                                 *
*----------------------------------------------------------------------*

FORM f_get_item_data USING fp_vbeln  TYPE vbeln_va                    " Sales Document
                           fp_header  TYPE zotc_cust_order_ack_header " Header data for Order Acknowledgement form
                           fp_langu TYPE char2                        "sylangu                                  "language
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                           fp_vkorg  TYPE vkorg      " Sales Organization
                           fp_land   TYPE land1_gp   " Country Key
                           fp_status TYPE tty_status
                           fp_dateformat TYPE char15 " Dateformat of type CHAR10
                           fp_kunnr TYPE kunnr       " Customer Number
                           fp_i_recipient_party2 TYPE sapplsef_business_document_tab
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                     CHANGING
                             fp_structure_out TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                             fp_struc_out2 TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                             fp_retcode TYPE sy-subrc ##needed. " Return Value of ABAP Statements


  TYPES:
*&--Batches data for Items
    BEGIN OF lty_mcha,
      matnr TYPE  matnr,   "Material Number
      werks TYPE werks_d,  " Plant
      charg TYPE  charg_d, "Batch Number
      vfdat TYPE vfdat,
    END OF lty_mcha,
*&--Batches data for Item
    BEGIN OF lty_mch1,
      matnr TYPE  matnr,   "Material Number
      charg TYPE  charg_d, "Batch Number
      vfdat TYPE vfdat,
    END OF lty_mch1,

*&--VBAP Item data
    BEGIN OF lty_vbap,
      vbeln      TYPE vbeln_va,  " Sales Document
      posnr      TYPE  posnr_va, "Item No.
      matnr      TYPE  matnr,    "Material Number
      charg      TYPE  charg_d,  "Batch Number
      arktx      TYPE  arktx,    "Description
*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
      fkrel      TYPE  fkrel,    "Relevant for Billing
*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
      uepos      TYPE uepos,     " Higher-level item in bill of material structures
      waerk      TYPE waerk,     " SD Document Currency
      kwmeng     TYPE  kwmeng,  "Quantity
      kbmeng     TYPE kbmeng,   " Cumulative confirmed quantity in sales unit
      vrkme      TYPE vrkme,     " Sales unit
      werks      TYPE werks_d,   " Plant
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
      kowrr      TYPE kowrr, " Statistical values
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
      mwsbp      TYPE mwsbp,           " Tax amount in document currency
      zzagmnt    TYPE z_agmnt,       " Warr / Serv Plan ID
      zzitemref  TYPE z_itemref,   " ServMax Obj ID
      zzquoteref TYPE z_quoteref, " Legacy Qtn Ref
      zzlnref    TYPE z_lnref,      " Instrument Reference
*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
      zz_bilmet  TYPE z_bmethod,      "Billing Method
      zz_bilfr   TYPE z_bfrequency,   "Billing Frequency
*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
    END OF lty_vbap,

    BEGIN OF lty_vbep,
      vbeln TYPE vbeln_va,        " Sales Document
      posnr TYPE posnr_va,        " Sales Document Item
      etenr TYPE etenr,           " Delivery Schedule Line Number
      edatu TYPE edatu,           " Schedule line date
      bmeng TYPE bmeng,           " Confirmed Quantity
    END OF lty_vbep,
*Conditions
    BEGIN OF lty_konv,
      knumv TYPE knumv,  " Number of the document condition
      kposn TYPE kposn,  " Condition item number
      stunr TYPE stunr,  " Step number
      zaehk TYPE dzaehk, " Condition counter
      kschl TYPE kscha,  " Condition type
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
      kbetr TYPE kbetr, " Condition Rate
* <--- End of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
*&--> Begin of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
      kntyp TYPE kntyp, "Condition category (examples: tax, freight, price, cost)
      kstat TYPE kstat, "Condition is used for statistics
*&<-- End of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
      kwert TYPE kwert, " Condition value
    END OF lty_konv,
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*For Text id at item level
    BEGIN OF ty_object_id_item,
      name TYPE tdobname, " Name of type CHAR15
      id   TYPE tdid,       " Text ID
    END OF ty_object_id_item,
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
    BEGIN OF lty_veda,
      vbeln   TYPE vbeln_va,      "Sales Document
      vposn   TYPE posnr_va,      " Sales Document Item
      vbegdat TYPE vbdat_veda,    "Contract start date
      venddat TYPE vndat_veda,    "Contract end date
    END OF lty_veda,

    BEGIN OF lty_vbkd,
      vbeln TYPE vbeln,    " Sales Document
      posnr TYPE posnr,    " Item No.
      fplnr TYPE fplnr,    " Billing Plan Number / Invoicing Plan Number
    END OF lty_vbkd,

    BEGIN OF lty_fplt,
      fplnr TYPE fplnr,       " Billing Plan Number / Invoicing Plan Number
      fpltr TYPE fpltr,       " Item for billing plan/invoice plan/payment cards
      fkdat TYPE bfdat,       " Settlement date for deadline
      fareg TYPE fareg,       " Rule in billing plan/invoice plan
    END OF lty_fplt,

    BEGIN OF lty_fpla,
      fplnr TYPE fplnr,          " Billing Plan Number / Invoicing Plan Number
      bedat TYPE bedat_fp,       " Start date for billing plan/invoice plan
      endat TYPE endat_fp,       " End date billing plan/invoice plan
    END OF lty_fpla,
*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019


*BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

    BEGIN OF lty_knmt,
      vkorg TYPE vkorg,  " Sales Organization
      vtweg TYPE vtweg,  " Distribution Channel
      kunnr TYPE kunnr,  " Customer Number
      matnr TYPE matnr,  " Material Number
      kdmat TYPE kdmat , " Material belonging to the customer
    END OF lty_knmt.

  DATA : li_knmt TYPE  STANDARD TABLE OF lty_knmt.
  FIELD-SYMBOLS : <lfs_knmt> TYPE lty_knmt.

*END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
*Local Internal tables
  DATA:
    li_mcha      TYPE STANDARD TABLE OF lty_mcha,     "Batches data
    li_mch1      TYPE STANDARD TABLE OF lty_mch1,     "Batches data
    li_vbap      TYPE STANDARD TABLE OF lty_vbap,     "Item Data
    li_vbap_tmp  TYPE STANDARD TABLE OF lty_vbap, "Item Data
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
    li_vbap_tmp1 TYPE STANDARD TABLE OF lty_vbap, "internal table vbap
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
    li_konv      TYPE STANDARD TABLE OF lty_konv,           "Conditions
    li_konv_temp TYPE STANDARD TABLE OF lty_konv,
    li_vbep      TYPE STANDARD TABLE OF lty_vbep,
    li_vbep_tmp  TYPE STANDARD TABLE OF lty_vbep,
    li_status    TYPE STANDARD TABLE OF  zdev_enh_status, " Internal table for Enhancement Status
    li_lines     TYPE STANDARD TABLE OF tline,             "Material Sales text
    li_item      TYPE sapplsef_purchase_order_it_tab,       "SAPPLSEF_PURCHASE_ORDER_IT_TAB,   "Line of Item
    li_lines_td  TYPE STANDARD TABLE OF tdline,         "26 feb
    li_sdln      TYPE sapplsef_pur_ord_itm_sched_tab.       "SAPPLSEF_PUR_ORD_ITM_SCHED_TAB. "workarea for schedule line
*Work area
  DATA: lwa_item              TYPE sapplsef_purchase_order_item,   "Line of Item
        lwa_sdln              TYPE sapplsef_pur_ord_item_schedule, "workarea for schedule line
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
        lwa_physical_address  TYPE sapplsef_address_physical_addr,  " Proxy Structure (generated)
        lwa_physical_address1 TYPE sapplsef_address_physical_addr, " Proxy Structure (generated)
        li_main_address1      TYPE sapplsef_address_tab,
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
        lwa_physical_address2 TYPE sapplsef_address_physical_addr, " Proxy Structure (generated)
        li_main_address2      TYPE sapplsef_address_tab,           " Proxy Structure (generated)
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
        li_main_address       TYPE sapplsef_address_tab,                 "Internal tables

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
        li_id_item            TYPE STANDARD TABLE OF ty_object_id_item, "Internal table for text id at item level
        lwa_id_item           TYPE ty_object_id_item.                  "Work Area for text id at item level
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* <--- End of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*Local variables
  DATA:
    lv_index             TYPE int2,    " Index of type Integers
    lv_name              TYPE tdobname, "Object name - Order no+ item no
    lv_num               TYPE int2,      " Num of type Numeric Text Fields
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
    lv_num1              TYPE int2, " 2 byte integer (signed)
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
    lv_bmeng             TYPE char13,             "local variable for Confirmed Quantity
    lv_bmeng_abs         TYPE char13,         "local variable for Confirmed Quantity
    lv_matnr             TYPE matnr,              " Material Number
    lv_kwmeng            TYPE char18,            "kwmeng
    lv_kbmeng            TYPE char18,            "kbmeng
    lv_back_ord_qty      TYPE char18,      " Back_ord_qty of type CHAR18
    lv_text_z015         TYPE string,         " Text_z015 of type CHAR255
    lv_zzitemref         TYPE char255,        " Zzitemref of type CHAR255
    lv_zzqouteref        TYPE char255,       " Zzqouteref of type CHAR255
    lv_zzlnref           TYPE char255,          " Zzlnref of type CHAR255
    lv_promo_text        TYPE char255,       " Promo_text of type CHAR255
    lv_cuky              TYPE sycurr,              " Currency Key
    lv_unit_price        TYPE netwr_ap,      " Net value of the order item in document currency
    lv_ext_price         TYPE netwr_ap,       " Net value of the order item in document currency
    lv_dangergoods_fee1  TYPE kwert,   " Net value of the order item in document currency
    lv_subtotal_price1   TYPE netwr_ap, " Net value of the order item in document currency
    lv_handling_fee1     TYPE kwert,      " Net value of the order item in document currency
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    lv_documentation     TYPE kwert,      " Net value of the order item in document currency
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    lv_freight1          TYPE kwert,           " Net value of the order item in document currency
    lv_tax1              TYPE mwsbp,               " Net value of the order item in document currency
    lv_total_price1      TYPE netwr_ap,    " Net value of the order item in document currency
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_env_fee           TYPE kwert,          " Environmental value of the order item in document currency
    lv_insurance         TYPE kwert,          " Insurance value of the order item in document currency
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_date              TYPE char10,              " Date of type CHAR10
    lv_year              TYPE char2,               " Year of type CHAR2
    lv_month             TYPE char2,              " Month of type CHAR2
    lv_day               TYPE char2,                " Day of type CHAR2
    lv_znet              TYPE kschl,               " Condition Type
    lv_zdng              TYPE kschl,               " Condition Type
    lv_zhdl              TYPE kschl,               " Condition Type
    lv_ztfr              TYPE kschl,               " Condition Type
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
    lv_country_ship_key  TYPE char3,  "SCUSTOM-COUNTRY,
    lv_country_sold_key  TYPE char3,  " Country_sold_key of type CHAR3
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_zdoc              TYPE kschl,               " Condition Type
    lv_zenv              TYPE kschl,               " Condition Type
    lv_zins              TYPE kschl,               " Condition Type
    lv_country_bill_key  TYPE char3,  " Country_bill_key of type CHAR3
    lv_country_bill_name TYPE landx, " Country Name
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_country_sold_name TYPE landx, " Country Name
    lv_country_ship_name TYPE landx, " Country Name
    lv_country_key1      TYPE char3,      "Country Key
    lv_adrnr_1           TYPE adrnr,           "Address Key
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA

* --->  Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
    lv_langu1            TYPE sylangu. " Name
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect#3587 by NSAXENA
*Local data declaration
*We are using text lines of type char30000 instead of String type as the
*FM can support only character type format not string.
  DATA:
    lv_text_zvalues TYPE char30000,                 "String
    li_text_lines   TYPE STANDARD TABLE OF char30000. " Text_lines type standard ta of type CHAR30000
*Field Symbols
  FIELD-SYMBOLS : <lfs_text_lines> TYPE char30000. " Text_line of type CHAR30000
* <--- End of Insert for D2_OTC_IDD_0167,Defect#3587 by NSAXENA


*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*&>> Local Data declarations
  DATA:
*&--Internal Table
    li_veda        TYPE STANDARD TABLE OF lty_veda INITIAL SIZE 0,  "Local internal table for VEDA
    li_fplt        TYPE STANDARD TABLE OF lty_fplt INITIAL SIZE 0,  "Local internal table for FPLT
    li_fpla        TYPE STANDARD TABLE OF lty_fpla INITIAL SIZE 0, "Table for FPLA
    li_vbkd        TYPE STANDARD TABLE OF lty_vbkd INITIAL SIZE 0, "Table for VBKD

*&--Work Area
    lwa_vbkd       TYPE lty_vbkd,                                   " Wrk area for VBKD
    lwa_fpla       TYPE lty_fpla,                                   "Local work Area for FPLA
    lwa_fplt       TYPE lty_fplt,                                   "Local work area for FPLT table
    lwa_konv_tmp   TYPE lty_konv,                                    " Temp KONv table

*&--Local Variable

    lv_vbegdat     TYPE sydatum,                                    " Contract start date
    lv_venddat     TYPE sydatum,                                    " Contract end date
    lv_bmethod     TYPE char70,                                     " Short text for Billing Method
    lv_bfrequency  TYPE char70,                                     " Short text for Billing Frequency
    lv_bmethod_dom TYPE tdobname,                                   " SO10 text for Billing Method
    lv_bfreq_dom   TYPE tdobname,                                   " SO10 text for Billing Frequency
    lv_fplnr       TYPE fplnr.                                      "Billing Plan Number / Invoicing Plan Number

*&--> Local constants declarations
  CONSTANTS: lc_vposn        TYPE posnr_va   VALUE '000000',         " Sales Document Item
             lc_mwst         TYPE kschl      VALUE 'MWST',           " Condition type
             lc_4            TYPE fareg      VALUE '4',              " Down payment in milestone billing on percentage basis
             lc_5            TYPE fareg      VALUE '5',              " Down payment in milestone billing on a value basis
             lc_fkrel        TYPE fkrel      VALUE 'I',              "Relevant for Billing
             lc_z_bmethod    TYPE z_criteria VALUE 'Z_BMETHOD',      "constant for Z_BMETHOD
             lc_z_bfrequency TYPE z_criteria VALUE 'Z_BFREQUENCY',   "constant for Z_BFREQUENCY
             lc_evergreen    TYPE z_criteria VALUE 'EVERGREEN'.      "Criteria 'EVERGREEN'

*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019

*&--> Begin of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
  DATA: li_kntyp     TYPE STANDARD TABLE OF fkk_ranges,
        lv_index_val TYPE sytabix,
        lwa_kntyp    TYPE fkk_ranges.

  CONSTANTS: lc_zmw0  TYPE kschl      VALUE 'ZMW0',
             lc_kntyp TYPE z_criteria VALUE 'KNTYP',
             lc_eq    TYPE char_02    VALUE 'EQ'.                  " EQ constant
*&<-- End of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*Field symbols
  FIELD-SYMBOLS:
    <lfs_vbap>          TYPE lty_vbap,       "Item Data
    <lfs_mcha>          TYPE lty_mcha,       "Batches data
    <lfs_mch1>          TYPE lty_mch1,       "Batches
    <lfs_lines>         TYPE tline,        " SAPscript: Text Lines
    <lfs_lines_td>      TYPE tdline,       " Text Line
    <lfs_vbep>          TYPE lty_vbep,     " Order Acknowledgement Schedule Line Item data
    <lfs_vbep_tmp>      TYPE lty_vbep,     " Order Acknowledgement Schedule Line Item data
    <lfs_konv>          TYPE lty_konv,
    <lfs_status>        TYPE zdev_enh_status, "For Reading enhancement table
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
    <lfs_main_address>  TYPE sapplsef_address,  " Proxy Structure (Generated)
    <lfs_main_address1> TYPE sapplsef_address, " Proxy Structure (Generated)
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    <lfs_main_address2> TYPE sapplsef_address. " Proxy Structure (Generated)
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*Local constants
  CONSTANTS:
    lc_id        TYPE tdid     VALUE '0001', " Material-sales text
    lc_slash     TYPE char1 VALUE '/',        " Slach of type CHAR1
* ---> Begin of Insert for D2_OTC_IDD_0167,CR by NSAXENA
    lc_id_z014   TYPE tdid VALUE 'Z014', " Text ID
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
*Commenting out the text id
*        lc_id_z017 TYPE tdid VALUE 'Z017', " Text ID
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
* <--- End of Insert for D2_OTC_IDD_0167,CR by NSAXENA
    lc_id_z011   TYPE tdid VALUE 'Z011',                      " Text ID
    lc_id_z015   TYPE tdid VALUE 'Z015',                      " Text ID
    lc_object    TYPE tdobject VALUE 'VBBP',                   " Order item text
    lc_idd_0167  TYPE z_enhancement VALUE 'D2_OTC_IDD_0167', "Enhancement number
    lc_znet      TYPE z_criteria VALUE 'ZCOND_ZNET',             " Condition Type
    lc_zdng      TYPE z_criteria VALUE 'ZCOND_ZDNG',             " Condition Type
    lc_zhdl      TYPE z_criteria VALUE 'ZCOND_ZHDL',             " Condition Type
    lc_ztfr      TYPE z_criteria VALUE 'ZCOND_ZTFR',             " Condition Type
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lc_zdoc      TYPE z_criteria VALUE 'ZCOND_ZDOC',             " Condition Type
    lc_zenv      TYPE z_criteria VALUE 'ZCOND_ZENV',             " Condition Type
    lc_zins      TYPE z_criteria VALUE 'ZCOND_ZINS',             " Condition Type
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
    lc_new_line  TYPE char8 VALUE 'NEW-LINE', " New_line of type CHAR8
*       lc_new_line1 TYPE char16 VALUE 'NEW-LINENEW-LINE', " New_line1 of type CHAR16
    lc_new_line1 TYPE char16 VALUE '$NEW-LINENEW-LINE$', " New_line1 of type CHAR16
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
    lc_yes       TYPE kowrr VALUE 'Y', " Statistical values
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA

*& --> Begin of Insert for Defect#1225 by SAGARWA1
    lc_st        TYPE tdid      VALUE 'ST',                   " Text ID
    lc_text      TYPE tdobject  VALUE 'TEXT',                 " Text Object
    lc_tbd       TYPE tdobname  VALUE 'ZOTC_BIORAD_DATE_TBD'. " Object Name

  DATA : lwa_lines TYPE tline,  " Work area for standard text
         lv_tbd    TYPE tdline. " Standard text
*& --> End of Insert for Defect#1225 by SAGARWA1

* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
  FIELD-SYMBOLS : <lfs_textpool> TYPE textpool. " ABAP Text Pool Definition

  DATA : lv_date2    TYPE sydatum,                       " Current Date of Application Server
         lv_custmat  TYPE char57,                      " Custmat of type CHAR57
         lv_date_f   TYPE char15,                       " Date_f of type CHAR15
         li_textpool TYPE STANDARD TABLE OF textpool. " ABAP Text Pool Definition


  CONSTANTS: lc_vkorg TYPE z_criteria VALUE 'VKORG_LANG',          " Enh. Criteria
             lc_prog  TYPE char30     VALUE 'ZOTCO0167B_ORD_CONF', " Prog of type CHAR30
             lc_i     TYPE textpoolid VALUE 'I',                   " ABAP/4 text pool ID (selection text/numbered text)
             lc_14    TYPE textpoolky VALUE '014',                 " Text element key (number/selection name)
             lc_space TYPE char1      VALUE ': '.                  " Space of type CHAR1

  IF fp_land IS NOT INITIAL.
    SET COUNTRY fp_land.
  ENDIF. " IF fp_land IS NOT INITIAL

  li_status[] = fp_status[].
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

* BEGIN OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

*  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*    EXPORTING
*      iv_enhancement_no = lc_idd_0167
*    TABLES
*      tt_enh_status     = li_status.
**Non active entries are removed.
*  DELETE li_status WHERE active EQ abap_false.
* END OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

*retrieve the constants values for condition types.
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_znet.
*For condtion type ZNET
  IF sy-subrc EQ 0.
    lv_znet = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0
*For condtion type ZTFR
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_ztfr.
  IF sy-subrc EQ 0.
    lv_ztfr = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0
*For condtion type ZHDL
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_zhdl.
  IF sy-subrc EQ 0.
    lv_zhdl = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0
*For condtion type ZDNG
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_zdng.
  IF sy-subrc EQ 0.
    lv_zdng = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*For condtion type ZHDL
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_zdoc.
  IF sy-subrc EQ 0.
    lv_zdoc = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

*For condtion type ZENV
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_zenv.
  IF sy-subrc EQ 0.
    lv_zenv = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

*For condtion type ZINS
  READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_zins.
  IF sy-subrc EQ 0.
    lv_zins = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

*Select currency code from table vbak
  lv_cuky = fp_header-waerk.
*&--Fetch Item data from VBAP
  SELECT vbeln  " Sales Document
         posnr  "Item No.
         matnr  "Material Number
         charg  "Batch
         arktx  "Description
*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
         fkrel  "Relevant for Billing
*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
         uepos  " Higher-level item in bill of material structures
         waerk  "Document Currency
         kwmeng "Quantity
         kbmeng " Cumulative confirmed quantity in sales unit
         vrkme  " UOM  Added by SBASU Def 1833
         werks  " Plant (Own or External)
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
         kowrr " Statistical values
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
         mwsbp      " Tax amount in document currency
         zzagmnt    " Warr / Serv Plan ID
         zzitemref  " ServMax Obj ID
         zzquoteref " Legacy Qtn Ref
         zzlnref    " Instrument Reference
*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
         zz_bilmet  " Billing Method
         zz_bilfr   " Billing Frequency
*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
    FROM vbap       " Sales Document: Item Data
    INTO TABLE li_vbap
   WHERE vbeln = fp_vbeln
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #6219 by NSAXENA
*Added code for discarding the rejcted line items.
     AND abgru = space.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #6219 by NSAXENA
  IF sy-subrc EQ 0.
*&-->Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019

    li_vbap_tmp[] = li_vbap[].
    SORT li_vbap_tmp BY vbeln posnr.
    DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING vbeln posnr.

*Fetch the link between the SO line item and billing plan no
    SELECT vbeln      " Sales Document
           posnr      " Item No.
           fplnr      " Billing Plan Number / Invoicing Plan Number
           FROM vbkd
           INTO TABLE li_vbkd
           FOR ALL ENTRIES IN li_vbap_tmp
           WHERE vbeln  = li_vbap_tmp-vbeln
           AND   posnr  = li_vbap_tmp-posnr.
    IF sy-subrc = 0.
      SORT li_vbkd BY vbeln posnr.
      DELETE li_vbkd WHERE fplnr IS INITIAL.
    ENDIF.
*      Fetch the Billing plan no for the Sales Order
    SELECT fplnr           " Billing Plan Number / Invoicing Plan Number
           bedat           " Start date for billing plan/invoice plan
           endat           " End date billing plan/invoice plan
           FROM fpla       " Billing Plan Table
           INTO TABLE li_fpla
           WHERE vbeln  = fp_vbeln.       "Sales Document Number


    IF sy-subrc IS INITIAL.
      SORT li_fpla BY fplnr.
*      Fetch the Billing start Date for the billing no
      SELECT fplnr      " Billing Plan Number / Invoicing Plan Number
             fpltr      " Item for billing plan/invoice plan/payment cards
             fkdat      " Settlement date for deadline
             fareg      " Rule in billing plan/invoice plan
            FROM fplt   " Billing Plan: Dates
            INTO TABLE li_fplt
            FOR ALL ENTRIES IN li_fpla
            WHERE fplnr = li_fpla-fplnr        " Billing Plan Number / Invoicing Plan Number
            AND   ( fareg NE lc_4 OR fareg NE lc_5 ).

      IF sy-subrc IS INITIAL.
*&--> Taking the line items count of the table.
*&-->Do nothing.
      ENDIF.
    ENDIF.

*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019

* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

    li_vbap_tmp1[] = li_vbap[].
    SORT li_vbap_tmp1 BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_vbap_tmp1 COMPARING matnr.
    IF li_vbap_tmp1[] IS NOT INITIAL.
      SELECT vkorg " Sales Organization
        vtweg      " Distribution Channel
        kunnr      " Customer number
        matnr      " Material Number
         kdmat     " Material Number Used by Customer
        FROM knmt INTO TABLE li_knmt
        FOR ALL ENTRIES IN li_vbap_tmp1
        WHERE vkorg EQ fp_vkorg
        AND vtweg EQ fp_header-vtweg
        AND kunnr EQ fp_kunnr
        AND matnr EQ li_vbap_tmp1-matnr.
      IF sy-subrc EQ 0.
        SORT li_knmt BY matnr.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_vbap_tmp1[] IS NOT INITIAL
    CLEAR: li_vbap_tmp[].
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
*For calculating tax we will move the item details to seperate internal table
*The Tax will be calculated for BOM Items which will contain all the VBAP line item except the
*line item where KOWRR = 'Y' i.e. the header one, so will delete that entry from internal table
*and calculate the total tax value - VBAP-MWSBP.
    li_vbap_tmp1[] = li_vbap[].
*Deletion where kowrr field is equals to 'Y'.
    DELETE li_vbap_tmp1 WHERE kowrr EQ lc_yes.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA

*To print details at item level remove where uepos is not blank.
    DELETE li_vbap WHERE uepos IS NOT INITIAL.
*&-- Begin of Changes for HANAtization on OTC_IDD_0167 by U106341 on 22-Aug-2019 in E1SK901449
    SORT li_vbap.
*&-- End of Changes for HANAtization on OTC_IDD_0167 by U106341 on 22-Aug-2019 in E1SK901449
    DELETE ADJACENT DUPLICATES FROM li_vbap COMPARING ALL FIELDS.

    SORT li_vbap BY vbeln posnr.

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
    CLEAR: lv_name.
    REFRESH li_id_item[].
*Inserting the text ids at item level so that based on these text id we will fetch the data
*from STXH table and then we will read individual text id at item level as per language and other
*input parameter
    LOOP AT li_vbap ASSIGNING <lfs_vbap>.
      CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
      lwa_id_item-name = lv_name.
      lwa_id_item-id = lc_id_z014.
      APPEND lwa_id_item TO li_id_item.
*      lwa_id_item-name = lv_name.
*      lwa_id_item-id = lc_id_z017.
*      APPEND lwa_id_item TO li_id_item.
      lwa_id_item-name = lv_name.
      lwa_id_item-id = lc_id.
      APPEND lwa_id_item TO li_id_item.
      lwa_id_item-name = lv_name.
      lwa_id_item-id = lc_id_z011.
      APPEND lwa_id_item TO li_id_item.
      lwa_id_item-name = lv_name.
      lwa_id_item-id = lc_id_z015.
      APPEND lwa_id_item TO li_id_item.
      CLEAR lv_name.
    ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
    IF li_id_item[] IS NOT INITIAL.
      CLEAR lv_langu1.
**Using this FM we convert the two character language key
*to system generated langugae key of type sylangu.
      CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
        EXPORTING
          input            = fp_langu  "language of char2 type
        IMPORTING
          output           = lv_langu1 "sylangu type
        EXCEPTIONS
          unknown_language = 1
          OTHERS           = 2.
      IF sy-subrc EQ 0.
        SELECT tdobject                         " Texts: Application Object
                   tdname                       " Name
                   tdid                         " Text ID
                   tdspras                      " Language Key
                   FROM stxh                    " STXD SAPscript text file header
                   INTO TABLE i_name
                  FOR ALL ENTRIES IN li_id_item "internal table for Item level text id
                   WHERE tdobject = lc_object   "Objecr id
                   AND tdname = li_id_item-name "Name
                   AND tdid = li_id_item-id     "Text ids
                   AND tdspras = lv_langu1.     "language key
        IF sy-subrc EQ 0.
          SORT i_name BY name id.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_id_item[] IS NOT INITIAL
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA


* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*Read fisrt line item plant details and then fetch the country code for shipping plant
    READ TABLE li_vbap ASSIGNING <lfs_vbap> INDEX 1.
    IF sy-subrc EQ 0.
*Fetch address number based on company code.
      SELECT SINGLE adrnr " Address
           INTO lv_adrnr_1
           FROM t001w     " Plants/Branches
        WHERE werks = <lfs_vbap>-werks.
      IF sy-subrc EQ 0.
*Fetch country key based on plant
        SELECT country " Country Key
          FROM adrc    " Addresses (Business Address Services)
          INTO lv_country_key1
          UP TO 1 ROWS
          WHERE addrnumber = lv_adrnr_1.
        ENDSELECT.
        IF sy-subrc EQ 0.
*Once we get the country key for 1st line item -shipping plant, we will chcek for the sold to country code and
*Shipping plantcountry code.
*Passing data to modify Sold to party details
          li_main_address[] = fp_structure_out-purchase_order_confirmation-purchase_order-buyer_party-address.
*Passing data to modify the Ship to party details
          li_main_address1[] = fp_structure_out-purchase_order_confirmation-purchase_order-vendor_party-address.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*Passing data to modify the Bill to party details
          li_main_address2[] = fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-address.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
          READ TABLE li_main_address ASSIGNING <lfs_main_address> INDEX 1.
          IF sy-subrc EQ 0.
            lwa_physical_address = <lfs_main_address>-physical_address. "Sold to
          ENDIF. " IF sy-subrc EQ 0
          READ TABLE li_main_address1 ASSIGNING <lfs_main_address1> INDEX 1. "Ship to
          IF sy-subrc EQ 0.
            lwa_physical_address1 = <lfs_main_address1>-physical_address.
          ENDIF. " IF sy-subrc EQ 0
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
          READ TABLE li_main_address2 ASSIGNING <lfs_main_address2> INDEX 1. "Bill to
          IF sy-subrc EQ 0.
            lwa_physical_address2 = <lfs_main_address2>-physical_address.
          ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*chcek for sold to country code and move the data into work area for ship to and sold to
*so that we can modify the Country name field in PI structure.
          IF lwa_physical_address-country_code IS NOT INITIAL.
            IF lwa_physical_address-country_code EQ lv_country_key1. "Sold to
              <lfs_main_address>-z01otc_zcountry_name = abap_false. "Sold to
              <lfs_main_address1>-z01otc_zcountry_name = abap_false. "Ship to
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              <lfs_main_address2>-z01otc_zcountry_name = abap_false. "Bill to
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              fp_structure_out-purchase_order_confirmation-purchase_order-buyer_party-address = li_main_address[]. "sold to
              fp_structure_out-purchase_order_confirmation-purchase_order-vendor_party-address =  li_main_address1[]. "ship to
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-address =  li_main_address2[]. "Bill to
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            ELSE. " ELSE -> IF lwa_physical_address-country_code EQ lv_country_key1
              lv_country_sold_key = lwa_physical_address-country_code.
* Read Country name for sold to party
              SELECT SINGLE landx " Country Name
                FROM t005t        " Country Names
                INTO lv_country_sold_name
                WHERE spras = sy-langu
                AND land1 = lv_country_sold_key.
              IF sy-subrc EQ 0.
                <lfs_main_address>-z01otc_zcountry_name = lv_country_sold_name.
*Modify the Sold to details with country name details in Z field.
                fp_structure_out-purchase_order_confirmation-purchase_order-buyer_party-address = li_main_address[].
              ENDIF. " IF sy-subrc EQ 0
              lv_country_ship_key = lwa_physical_address1-country_code.
* Read Country name for ship to party
              SELECT SINGLE landx " Country Name
                FROM t005t        " Country Names
                INTO lv_country_ship_name
                WHERE spras = sy-langu
                AND land1 = lv_country_ship_key.
              IF sy-subrc EQ 0.
                <lfs_main_address1>-z01otc_zcountry_name = lv_country_ship_name.
*Modify the Sold to details with country name details in Z field.
                fp_structure_out-purchase_order_confirmation-purchase_order-vendor_party-address = li_main_address1[].
              ENDIF. " IF sy-subrc EQ 0
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              lv_country_bill_key = lwa_physical_address2-country_code.
* Read Country name for bill to party
              SELECT SINGLE landx " Country Name
                FROM t005t        " Country Names
                INTO lv_country_bill_name
                WHERE spras = sy-langu
                AND land1 = lv_country_bill_key.
              IF sy-subrc EQ 0.
                <lfs_main_address2>-z01otc_zcountry_name = lv_country_bill_name.
*Modify the Bill to details with country name details in Z field.
                fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-address = li_main_address2[].
              ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            ENDIF. " IF lwa_physical_address-country_code EQ lv_country_key1
          ENDIF. " IF lwa_physical_address-country_code IS NOT INITIAL
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*&--Fetch Planned Ship Date from Schedule Line Data
    SELECT vbeln " Sales Document
           posnr "Item No.
           etenr "Delivery Schedule Line Number
           edatu "Planned Ship Date
           bmeng "Confirmed Quantity
      FROM vbep  " Sales Document: Schedule Line Data
      INTO TABLE li_vbep
   FOR ALL ENTRIES IN li_vbap
     WHERE vbeln = li_vbap-vbeln
       AND posnr = li_vbap-posnr.
    IF sy-subrc = 0.
      SORT li_vbep BY posnr edatu ASCENDING.
    ENDIF. " IF sy-subrc = 0
    li_vbap_tmp[] = li_vbap[].
*Sort the table as per primary key
    SORT li_vbap_tmp BY matnr werks charg.
    DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING matnr werks charg.
    IF li_vbap_tmp[] IS NOT INITIAL.
*&--Fetch Batches data from MCHA
      SELECT matnr "Material Number
             werks " Plant
             charg "Batch
             vfdat "Expiration date
        FROM mcha  " Batches (if Batch Management Cross-Plant)
        INTO TABLE li_mcha
         FOR ALL ENTRIES IN li_vbap_tmp
       WHERE matnr = li_vbap_tmp-matnr
         AND werks = li_vbap_tmp-werks
         AND charg = li_vbap_tmp-charg.
      IF sy-subrc = 0.
        SORT li_mcha BY matnr werks charg.
      ENDIF. " IF sy-subrc = 0
      SORT li_vbap_tmp BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING matnr charg.
*&--Fetch Batches data from MCH1
      SELECT matnr "Material Number
             charg "Batch
             vfdat "Expiration date
        FROM mch1  " Batches (if Batch Management Cross-Plant)
        INTO TABLE li_mch1
         FOR ALL ENTRIES IN li_vbap_tmp
       WHERE matnr = li_vbap_tmp-matnr
         AND charg = li_vbap_tmp-charg.
      IF sy-subrc = 0.
        SORT li_mch1 BY matnr charg.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_vbap_tmp[] IS NOT INITIAL

    SELECT knumv " Number of the document condition
           kposn " Condition item number
           stunr " Step number
           zaehk " Condition counter
           kschl " Condition type
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
           kbetr " Condition Rate
* <--- End of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
*&--> Begin of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
           kntyp  " Condition category (examples: tax, freight, price, cost)
           kstat  " Condition is used for statistics
*&<-- End of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
           kwert     " Condition value
           FROM konv " Conditions (Transaction Data)
           INTO TABLE li_konv
           WHERE knumv = fp_header-knumv.
    IF sy-subrc EQ 0.
      SORT li_konv BY kposn kschl.
    ENDIF. " IF sy-subrc EQ 0

*&--Merging Item data and Batches data
    LOOP AT li_vbap ASSIGNING <lfs_vbap>.
* Line item number
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbap>-posnr
        IMPORTING
          output = lwa_item-seller_id.
      CONDENSE lwa_item-seller_id.
*Material
      lv_matnr        = <lfs_vbap>-matnr.
      IF NOT lv_matnr EQ lwa_item-product-internal_id-value.
        lwa_item-product-internal_id-value = <lfs_vbap>-matnr. "material number
      ENDIF. " IF NOT lv_matnr EQ lwa_item-product-internal_id-value

      IF <lfs_vbap>-arktx IS NOT INITIAL.
        lwa_item-product-z01otc_zshort_text = <lfs_vbap>-arktx.
        CONDENSE lwa_item-product-z01otc_zshort_text.
      ENDIF. " IF <lfs_vbap>-arktx IS NOT INITIAL
      CLEAR: lv_name,
            lv_num1.
      REFRESH: li_lines[],
               li_text_lines[].
      CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*To Read text with text id Z014
      READ TABLE i_name ASSIGNING <fs_name> WITH KEY name = lv_name
                                                       id = lc_id_z014
                                                       BINARY SEARCH.

      IF sy-subrc NE 0.
        lv_langu1 = c_english.
      ENDIF. " IF sy-subrc NE 0

* Begin of Insert for Defect#3012 by NGARG
      IF gv_spras IS NOT INITIAL.
        lv_langu1 = gv_spras.
      ENDIF. " IF gv_spras IS NOT INITIAL
* End of Insert for Defect#3012 by NGARG
*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_z014
                               lv_langu1
                               lv_name
                               lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*For Defect_6837
* If no text maintained for sold-to-langu(other than EN), then read with
* EN language.
      IF li_lines IS INITIAL AND lv_langu1 NE c_english.
*** If Sales Org belongs to D3 only
        IF gv_d3_flag = abap_true.
          lv_langu1 = c_english.

*Get text subroutine.
          PERFORM f_get_text TABLES li_lines
                              USING lc_id_z014
                                    lv_langu1
                                    lv_name
                                    lc_object.
        ENDIF. " IF gv_d3_flag = abap_true
      ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

      IF sy-subrc = 0.
*Calling FM to convert the text line table data into string
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          EXPORTING
            language    = lv_langu1      "sy-langu       "language
            lf          = ' '
          TABLES
            itf_text    = li_lines       "Text line data
            text_stream = li_text_lines. "String format
        IF sy-subrc EQ 0.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
          DESCRIBE TABLE li_lines LINES lv_num1.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Pass this string into proxy structure field z01otc_zline_text
          LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
            MOVE <lfs_text_lines> TO lv_text_zvalues.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
            IF lv_num1 > 1.
              REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text_zvalues WITH lc_new_line.
              IF lv_text_zvalues CS lc_new_line1.
                REPLACE ALL OCCURRENCES OF lc_new_line1 IN lv_text_zvalues WITH lc_new_line.
              ENDIF. " IF lv_text_zvalues CS lc_new_line1
            ENDIF. " IF lv_num1 > 1
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
            CONCATENATE lwa_item-z01otc_zline_text lv_text_zvalues INTO lwa_item-z01otc_zline_text SEPARATED BY space.
          ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0

      REFRESH: li_lines[],
               li_text_lines[].
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
**To Read text id - z017
*      READ TABLE i_name ASSIGNING <fs_name> WITH KEY  name = lv_name
*                                                        id = lc_id_z017
*                                                        BINARY SEARCH.
*      IF sy-subrc NE 0.
*        lv_langu1 = c_english.
*      ENDIF. " IF sy-subrc NE 0
*Check if the z014 details are initial, we need to pass the details of z017 text id
*      IF lwa_item-z01otc_zline_text IS INITIAL.
*
**FM to read text lines for detailed product description
*        CALL FUNCTION 'READ_TEXT'
*          EXPORTING
*            id                      = lc_id_z017 "Id
*            language                = lv_langu1  "lang
*            name                    = lv_name    "Sales ord number
*            object                  = lc_object  "Object Id
*          TABLES
*            lines                   = li_lines   "Text lines
*          EXCEPTIONS
*            id                      = 1
*            language                = 2
*            name                    = 3
*            not_found               = 4
*            object                  = 5
*            reference_check         = 6
*            wrong_access_to_archive = 7
*            OTHERS                  = 8.
*        IF sy-subrc = 0.
*
**Calling FM to convert the text line table data into string
*          CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
*            EXPORTING
*              language    = lv_langu1      "sy-langu       "language
*              lf          = ' '
*            TABLES
*              itf_text    = li_lines       "Text lines
*              text_stream = li_text_lines. "String format
*          IF sy-subrc EQ 0.
**Add this string into proxy structure field z01otc_zline_text
*            LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
*              MOVE <lfs_text_lines> TO lv_text_zvalues.
*              CONCATENATE lwa_item-z01otc_zline_text lv_text_zvalues INTO lwa_item-z01otc_zline_text
*             SEPARATED BY space.
*            ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
*          ENDIF. " IF sy-subrc EQ 0
*        ENDIF. " IF sy-subrc = 0
*      ENDIF. " IF lwa_item-z01otc_zline_text IS INITIAL
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
*To Read text with text id - 0001.
      CLEAR lv_num1.
      READ TABLE i_name ASSIGNING <fs_name> WITH KEY name = lv_name
                                                       id = lc_id
                                                       BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_langu1 = c_english.
      ENDIF. " IF sy-subrc NE 0

* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* Begin of Insert for Defect#3012 by NGARG
      IF gv_spras IS NOT INITIAL.
        lv_langu1 = gv_spras.
      ENDIF. " IF gv_spras IS NOT INITIAL
* End of Insert for Defect#3012 by NGARG
*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id
                               lv_langu1
                               lv_name
                               lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*For Defect_6837
* If no text maintained for sold-to-langu(other than EN), then read with
* EN language.
      IF li_lines IS INITIAL AND lv_langu1 NE c_english.

*** If Sales Org belongs to D3
        IF gv_d3_flag = abap_true.
          lv_langu1 = c_english.

*Get text subroutine.
          PERFORM f_get_text TABLES li_lines
                              USING lc_id
                                   lv_langu1
                                   lv_name
                                   lc_object.
        ENDIF. " IF gv_d3_flag = abap_true
      ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

      IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Calling FM to convert the text line table data into string
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          EXPORTING
            language    = lv_langu1      "sy-langu       "Language
            lf          = ' '
          TABLES
            itf_text    = li_lines       "Text lines
            text_stream = li_text_lines. "String format
        IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
          DESCRIBE TABLE li_lines LINES lv_num1.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
          LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
            MOVE <lfs_text_lines> TO lv_text_zvalues.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
            IF lv_num1 > 1.
              REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text_zvalues WITH lc_new_line.
              IF lv_text_zvalues CS lc_new_line1.
                REPLACE ALL OCCURRENCES OF lc_new_line1 IN lv_text_zvalues WITH lc_new_line.
              ENDIF. " IF lv_text_zvalues CS lc_new_line1
            ENDIF. " IF lv_num1 > 1
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
            IF sy-tabix EQ 1.
              CONCATENATE lwa_item-z01otc_zline_text lc_new_line lv_text_zvalues INTO lwa_item-z01otc_zline_text
            SEPARATED BY space.
            ELSE. " ELSE -> IF sy-tabix EQ 1
              CONCATENATE lwa_item-z01otc_zline_text lv_text_zvalues INTO lwa_item-z01otc_zline_text
           SEPARATED BY space.
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0
      CLEAR: lv_text_zvalues,
             lv_num1.

      REFRESH: li_text_lines[],
               li_lines[].
      UNASSIGN <lfs_text_lines>.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
      CONDENSE lwa_item-z01otc_zline_text.

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*To Read text with text id - Z011
      READ TABLE i_name ASSIGNING <fs_name> WITH KEY name = lv_name
                                                       id = lc_id_z011
                                                       BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_langu1 = c_english.
      ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* Begin of Insert for Defect#3012 by NGARG
      IF gv_spras IS NOT INITIAL.
        lv_langu1 = gv_spras.
      ENDIF. " IF gv_spras IS NOT INITIAL
* End of Insert for Defect#3012 by NGARG
*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_z011
                               lv_langu1
                               lv_name
                               lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*For Defect_6837
* If no text maintained for sold-to-langu(other than EN), then read with
* EN language.
      IF li_lines IS INITIAL AND lv_langu1 NE c_english.

*** If sales Org belongs to D3
        IF gv_d3_flag = abap_true.
          lv_langu1 = c_english.

*Get text subroutine.
          PERFORM f_get_text TABLES li_lines
                              USING lc_id_z011
                                   lv_langu1
                                   lv_name
                                   lc_object.
        ENDIF. " IF gv_d3_flag = abap_true
      ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

      IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Calling FM to convert the text line table data into string
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          EXPORTING
            language    = lv_langu1      "sy-langu       "Language
            lf          = ' '
          TABLES
            itf_text    = li_lines       "Text lines
            text_stream = li_text_lines. "text data format
        IF sy-subrc EQ 0.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
          DESCRIBE TABLE li_lines LINES lv_num1.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Pass the text data into proxy structure field z01otc_zline_text
          LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
            MOVE <lfs_text_lines> TO lv_text_zvalues.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
            IF lv_num1 > 1.
              REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text_zvalues WITH lc_new_line.
              IF lv_text_zvalues CS lc_new_line1.
                REPLACE ALL OCCURRENCES OF lc_new_line1 IN lv_text_zvalues WITH lc_new_line.
              ENDIF. " IF lv_text_zvalues CS lc_new_line1
            ENDIF. " IF lv_num1 > 1
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
            IF sy-tabix EQ 1.
              CONCATENATE lwa_item-z01otc_zline_text lc_new_line lv_text_zvalues INTO lwa_item-z01otc_zline_text
            SEPARATED BY space.
            ELSE. " ELSE -> IF sy-tabix EQ 1
              CONCATENATE lwa_item-z01otc_zline_text lv_text_zvalues INTO lwa_item-z01otc_zline_text
              SEPARATED BY space.
*           SEPARATED BY cl_abap_char_utilities=>newline.
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0
      CLEAR:lv_text_zvalues,
            lv_num1.

      REFRESH: li_lines[],
               li_text_lines[].
      UNASSIGN <lfs_text_lines>.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*Read text with text id - Z015
      READ TABLE i_name ASSIGNING <fs_name> WITH KEY name = lv_name
                                                       id = lc_id_z015
                                                       BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_langu1 = c_english.
      ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* Begin of Insert for Defect#3012 by NGARG
      IF gv_spras IS NOT INITIAL.
        lv_langu1 = gv_spras.
      ENDIF. " IF gv_spras IS NOT INITIAL
* End of Insert for Defect#3012 by NGARG
*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_z015
                               lv_langu1
                               lv_name
                               lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*For Defect_6837
* If no text maintained for sold-to-langu(other than EN), then read with
* EN language.
      IF li_lines IS INITIAL AND lv_langu1 NE c_english.

*** If sales Org belongs to D3
        IF gv_d3_flag = abap_true.
          lv_langu1 = c_english.

*Get text subroutine.
          PERFORM f_get_text TABLES li_lines
                              USING lc_id_z015
                                   lv_langu1
                                   lv_name
                                   lc_object.
        ENDIF. " IF gv_d3_flag = abap_true
      ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

      IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Calling FM to convert the text line table data into string
        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
          EXPORTING
            language    = lv_langu1      "sy-langu       "Language
            lf          = ' '
          TABLES
            itf_text    = li_lines       "Text lines
            text_stream = li_text_lines. "Text data format
        IF sy-subrc EQ 0.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA, string test
          DESCRIBE TABLE li_lines LINES lv_num1.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Pass this text data into proxy structure field z01otc_zline_text
          LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
            MOVE <lfs_text_lines> TO lv_text_zvalues.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA, string test
            IF lv_num1 > 1.
              REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf IN lv_text_zvalues WITH lc_new_line.
              IF lv_text_zvalues CS lc_new_line1.
                REPLACE ALL OCCURRENCES OF lc_new_line1 IN lv_text_zvalues WITH lc_new_line.
              ENDIF. " IF lv_text_zvalues CS lc_new_line1
            ENDIF. " IF lv_num1 > 1
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA , string test
            IF sy-tabix EQ 1.
*For first line it should print with Promotion
              CONCATENATE lc_new_line 'Promotion'(001) lv_text_zvalues INTO lv_promo_text
              SEPARATED BY space.
            ELSE. " ELSE -> IF sy-tabix EQ 1
*Concatenate other text lines
              CONCATENATE lv_promo_text lv_text_zvalues INTO lv_promo_text SEPARATED BY space.
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0
      CLEAR: lv_text_zvalues,
             lv_name.
      REFRESH: li_lines[],
               li_text_lines[].
      UNASSIGN <lfs_text_lines>.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #3587 by NSAXENA
*Check for ServiceMax Obj ID
      IF <lfs_vbap>-zzitemref IS NOT INITIAL.
        CONCATENATE  lc_new_line 'ServiceMax Obj ID'(002) <lfs_vbap>-zzitemref INTO lv_zzitemref SEPARATED BY space.
      ENDIF. " IF <lfs_vbap>-zzitemref IS NOT INITIAL
*check for Qoute ref
      IF <lfs_vbap>-zzquoteref IS NOT INITIAL.
        CONCATENATE lc_new_line 'Quote'(003) <lfs_vbap>-zzquoteref INTO lv_zzqouteref SEPARATED BY space.
      ENDIF. " IF <lfs_vbap>-zzquoteref IS NOT INITIAL
*Check for Instrument ref
      IF <lfs_vbap>-zzlnref IS NOT INITIAL.
        CONCATENATE lc_new_line 'Instrument Ref'(004) <lfs_vbap>-zzlnref INTO lv_zzlnref SEPARATED BY space.
      ENDIF. " IF <lfs_vbap>-zzlnref IS NOT INITIAL
      CONCATENATE lwa_item-z01otc_zline_text lv_zzqouteref lv_promo_text lv_zzitemref lv_zzlnref INTO lwa_item-z01otc_zline_text SEPARATED BY space.
      CONDENSE lwa_item-z01otc_zline_text.
*Order qty
      lv_kwmeng = trunc( <lfs_vbap>-kwmeng ).
      CONDENSE lv_kwmeng.
      IF lv_kwmeng EQ <lfs_vbap>-kwmeng.
        lwa_item-z01otc_zorder_quantity-content = lv_kwmeng.
      ELSE. " ELSE -> IF lv_kwmeng EQ <lfs_vbap>-kwmeng
        lwa_item-z01otc_zorder_quantity-content = <lfs_vbap>-kwmeng.
      ENDIF. " IF lv_kwmeng EQ <lfs_vbap>-kwmeng
*     BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
      READ TABLE li_status WITH KEY criteria = lc_vkorg
                                    sel_low    = fp_vkorg
                                          TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
*      Show commerical UOM
        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = <lfs_vbap>-vrkme
            language       = gv_spras
          IMPORTING
            output         = lwa_item-z01otc_zorder_quantity-unit_code
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.
        IF sy-subrc EQ 0.
*        do nothing
        ENDIF. " IF sy-subrc EQ 0
      ELSE. " ELSE -> IF sy-subrc NE 0
*     END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

        lwa_item-z01otc_zorder_quantity-unit_code = <lfs_vbap>-vrkme.
*     BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

      ENDIF. " IF sy-subrc NE 0
*     END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*Batch
      lwa_item-z01otc_zbatch-id = <lfs_vbap>-charg. "Batch number

*For Back Order quantity
      lv_kbmeng = trunc( <lfs_vbap>-kbmeng ).
      CONDENSE lv_kbmeng.
      IF lv_kbmeng EQ <lfs_vbap>-kbmeng.
        <lfs_vbap>-kbmeng = lv_kbmeng.
      ENDIF. " IF lv_kbmeng EQ <lfs_vbap>-kbmeng
      lv_back_ord_qty = <lfs_vbap>-kwmeng - <lfs_vbap>-kbmeng. "Back Order Qty
      CONDENSE lv_back_ord_qty.
      lwa_item-z01otc_zback_order_qty  = lv_back_ord_qty.
      CONDENSE: lwa_item-z01otc_zorder_quantity-content,
      lwa_item-z01otc_zorder_quantity-unit_code,
      lwa_item-z01otc_zbatch-id,
      lwa_item-z01otc_zback_order_qty.
*Unit Price
      READ TABLE li_konv ASSIGNING <lfs_konv> WITH KEY kposn = lwa_item-seller_id "#EC WARNOK
                                                       kschl = lv_znet
                                                       BINARY SEARCH.
      IF sy-subrc EQ 0.
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
*As part of defect, 6018 the logic for unit price and extended price has been changed.
*hence commenting the previous logic and keeping new logic.
*        IF <lfs_vbap>-kwmeng IS NOT INITIAL.
*          lv_unit_price = <lfs_konv>-kwert / <lfs_vbap>-kwmeng.
*        ENDIF. " IF <lfs_vbap>-kwmeng IS NOT INITIAL
*Unit Price calculations
        lv_unit_price = <lfs_konv>-kbetr. "Condition Amount
*Extended price calculations
        lv_ext_price  = <lfs_konv>-kwert. "Condition value
* <--- End of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
      ENDIF. " IF sy-subrc EQ 0

      WRITE lv_unit_price TO lwa_item-z01otc_zunit_price CURRENCY lv_cuky.
      lwa_item-confirmed_price-net_unit_price-amount-currency_code = lv_cuky.
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
*Commented out as a part of defect 6018 - Extended price
*Extended price
*      lv_ext_price =  lv_unit_price * <lfs_vbap>-kwmeng.
* <--- End of Change for D2_OTC_IDD_0167,Defect #6018 by NSAXENA
      WRITE lv_ext_price TO lwa_item-z01otc_zextended_price CURRENCY lv_cuky.
*Subtotal price
      lv_subtotal_price1 =  lv_subtotal_price1 + lv_ext_price.

*&--Read Expiration date for Batches
      READ TABLE li_mcha ASSIGNING <lfs_mcha> WITH KEY matnr = <lfs_vbap>-matnr
                                                       werks = <lfs_vbap>-werks
                                                       charg = <lfs_vbap>-charg
                                              BINARY SEARCH.
      IF sy-subrc = 0.
        IF <lfs_mcha>-vfdat IS INITIAL.
          READ TABLE li_mch1 ASSIGNING <lfs_mch1> WITH KEY matnr = <lfs_vbap>-matnr
                                                       charg = <lfs_vbap>-charg
                                              BINARY SEARCH.
          IF sy-subrc EQ 0.
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
*            lwa_item-z01otc_zbatch-expiration_date = <lfs_mch1>-vfdat.
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
            lwa_item-z01otc_zbatch-expiration_date-content = <lfs_mch1>-vfdat.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
          ENDIF. " IF sy-subrc EQ 0
        ELSE. " ELSE -> IF <lfs_mcha>-vfdat IS INITIAL
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
*          lwa_item-z01otc_zbatch-expiration_date = <lfs_mcha>-vfdat.
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
          lwa_item-z01otc_zbatch-expiration_date-content = <lfs_mcha>-vfdat.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
        ENDIF. " IF <lfs_mcha>-vfdat IS INITIAL
      ELSE. " ELSE -> IF sy-subrc = 0
        READ TABLE li_mch1 ASSIGNING <lfs_mch1> WITH KEY matnr = <lfs_vbap>-matnr
                                                     charg = <lfs_vbap>-charg
                                            BINARY SEARCH.
        IF sy-subrc EQ 0.
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
*          lwa_item-z01otc_zbatch-expiration_date = <lfs_mch1>-vfdat.
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
          lwa_item-z01otc_zbatch-expiration_date-content = <lfs_mch1>-vfdat.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0
      CONDENSE lwa_item-z01otc_zbatch-expiration_date-content.
      IF lwa_item-z01otc_zbatch-expiration_date IS NOT INITIAL.

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
        READ TABLE li_status WITH KEY criteria = lc_vkorg
                                      sel_low    = fp_vkorg
        TRANSPORTING NO FIELDS.
        IF sy-subrc NE 0.
          lv_date2 = lwa_item-z01otc_zbatch-expiration_date-content.
          CALL FUNCTION 'ZDEV_DATE_FORMAT'
            EXPORTING
              i_date       = lv_date2
              i_format     = fp_dateformat
              i_langu      = gv_spras
            IMPORTING
              e_date_final = lv_date_f.
          IF lv_date_f IS NOT INITIAL.
            lwa_item-z01otc_zbatch-expiration_date-content = lv_date_f.
          ENDIF. " IF lv_date_f IS NOT INITIAL
          CLEAR: lv_date2,
                 lv_date_f.
        ELSE. " ELSE -> IF sy-subrc NE 0
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
*          lv_date = lwa_item-z01otc_zbatch-expiration_date.
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
          lv_date = lwa_item-z01otc_zbatch-expiration_date-content.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
          lv_year = lv_date+2(2).
          lv_month = lv_date+4(2).
          lv_day = lv_date+6(2).
          CONCATENATE lv_month lv_day lv_year
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
*          INTO lwa_item-z01otc_zbatch-expiration_date
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
           INTO lwa_item-z01otc_zbatch-expiration_date-content
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #3909 by U029267 on 09-Oct-17
          SEPARATED BY lc_slash.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167  by U029267 on 09-Oct-17
        ENDIF.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
      ENDIF. " IF lwa_item-z01otc_zbatch-expiration_date IS NOT INITIAL
      CLEAR: lv_date,
      lv_month,
      lv_year,
      lv_day,
      lv_promo_text.

*For Confirmed Quantity and ship date

      li_vbep_tmp[] = li_vbep[].
      READ TABLE li_vbep ASSIGNING <lfs_vbep> WITH KEY posnr = <lfs_vbap>-posnr
                                                                  BINARY SEARCH.
      IF sy-subrc EQ 0.
        lv_index = sy-tabix.

        LOOP AT li_vbep ASSIGNING <lfs_vbep> FROM lv_index.
          IF <lfs_vbep>-posnr NE <lfs_vbap>-posnr.
            EXIT.
          ENDIF. " IF <lfs_vbep>-posnr NE <lfs_vbap>-posnr
          IF <lfs_vbep>-bmeng IS NOT INITIAL.
            lv_bmeng_abs = abs( <lfs_vbep>-bmeng ).
            IF lv_bmeng_abs EQ <lfs_vbep>-bmeng.
              lv_bmeng = trunc( <lfs_vbep>-bmeng ).
              IF lv_bmeng EQ <lfs_vbep>-bmeng.
                lwa_sdln-quantity-value = lv_bmeng. "Confirmed qty
              ENDIF. " IF lv_bmeng EQ <lfs_vbep>-bmeng
              lwa_sdln-id = <lfs_vbep>-etenr.
              lwa_sdln-delivery_period-start_date_time-content  = <lfs_vbep>-edatu. "Expiry Date
            ELSE. " ELSE -> IF lv_bmeng_abs EQ <lfs_vbep>-bmeng
              lv_bmeng = trunc( <lfs_vbep>-bmeng ).
              IF lv_bmeng EQ <lfs_vbep>-bmeng.
              ELSE. " ELSE -> IF lv_bmeng EQ <lfs_vbep>-bmeng
                lwa_sdln-quantity-value = <lfs_vbep>-bmeng.
              ENDIF. " IF lv_bmeng EQ <lfs_vbep>-bmeng
              lwa_sdln-id = <lfs_vbep>-etenr.
              lwa_sdln-delivery_period-start_date_time-content  = <lfs_vbep>-edatu. "Expiry Date
            ENDIF. " IF lv_bmeng_abs EQ <lfs_vbep>-bmeng
          ELSE. " ELSE -> IF <lfs_vbep>-bmeng IS NOT INITIAL
            lv_num = sy-tabix + 1.
            READ TABLE li_vbep_tmp ASSIGNING <lfs_vbep_tmp> INDEX lv_num.
            IF sy-subrc EQ 0.
              IF <lfs_vbep_tmp>-posnr EQ <lfs_vbep>-posnr.
                IF  <lfs_vbep_tmp>-bmeng NE 0.
                  CONTINUE.
                ELSE. " ELSE -> IF <lfs_vbep_tmp>-bmeng NE 0
                  lv_num = lv_num + 1.
                  READ TABLE li_vbep_tmp ASSIGNING <lfs_vbep_tmp> INDEX lv_num.
                  IF sy-subrc EQ 0.
                    IF <lfs_vbep_tmp>-bmeng NE 0.
                      CONTINUE.
                    ELSE. " ELSE -> IF <lfs_vbep_tmp>-bmeng NE 0
                      lv_bmeng = 0.
                      CONDENSE lv_bmeng.
                      lwa_sdln-id = <lfs_vbep>-etenr.
                      lwa_sdln-quantity-value = lv_bmeng. "Confirmed qty
                      lwa_sdln-delivery_period-start_date_time-content = <lfs_vbep>-edatu. " Expiry Date
                    ENDIF. " IF <lfs_vbep_tmp>-bmeng NE 0
                  ENDIF. " IF sy-subrc EQ 0
                ENDIF. " IF <lfs_vbep_tmp>-bmeng NE 0
              ELSE. " ELSE -> IF <lfs_vbep_tmp>-posnr EQ <lfs_vbep>-posnr
                lv_bmeng = trunc( <lfs_vbep>-bmeng ).
                CONDENSE lv_bmeng.
                lwa_sdln-id = <lfs_vbep>-etenr.
                lwa_sdln-quantity-value = lv_bmeng. "Confirmed qty
                lwa_sdln-delivery_period-start_date_time-content = <lfs_vbep>-edatu. " Expiry Date
              ENDIF. " IF <lfs_vbep_tmp>-posnr EQ <lfs_vbep>-posnr
* --->Begin of Insert for D2_OTC_IDD_0167,Defect #1612 by ASK
            ELSE. " ELSE -> IF sy-subrc EQ 0
              lv_bmeng = trunc( <lfs_vbep>-bmeng ).
              CONDENSE lv_bmeng.
              lwa_sdln-id = <lfs_vbep>-etenr.
              lwa_sdln-quantity-value = lv_bmeng. "Confirmed qty
              lwa_sdln-delivery_period-start_date_time-content = <lfs_vbep>-edatu. " Expiry Date
* <--- End of Insert for D2_OTC_IDD_0167,Defect #1612 by ASK
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF <lfs_vbep>-bmeng IS NOT INITIAL
* --->Begin of Insert for D2_OTC_IDD_0167,Defect #5424 by NSAXENA
* --->Begin of Insert for D2_OTC_IDD_0167,Defect #1612 by ASK
*          IF lwa_sdln-quantity-value IS INITIAL.
*            CLEAR lwa_sdln-delivery_period-start_date_time-content.
*          ENDIF. " IF lwa_sdln-quantity-value IS INITIAL
* <--- End of Insert for D2_OTC_IDD_0167,Defect #1612 by ASK
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5424 by NSAXENA
          IF lwa_sdln-delivery_period-start_date_time IS NOT INITIAL.

*           BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

            READ TABLE li_status WITH KEY criteria = lc_vkorg
                                          sel_low    = fp_vkorg
            TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              lv_date2 = lwa_sdln-delivery_period-start_date_time-content.
              CALL FUNCTION 'ZDEV_DATE_FORMAT'
                EXPORTING
                  i_date       = lv_date2
                  i_format     = fp_dateformat
                  i_langu      = gv_spras
                IMPORTING
                  e_date_final = lv_date_f.
              IF lv_date_f IS NOT INITIAL.
                lwa_sdln-delivery_period-start_date_time-content = lv_date_f.
              ENDIF. " IF lv_date_f IS NOT INITIAL
              CLEAR: lv_date2,
                     lv_date_f.
            ELSE. " ELSE -> IF sy-subrc NE 0
*           END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
              CONDENSE lwa_sdln-delivery_period-start_date_time-content.
              lv_date = lwa_sdln-delivery_period-start_date_time-content.
              lv_year = lv_date+2(2).
              lv_month = lv_date+4(2).
              lv_day = lv_date+6(2).
              CONCATENATE lv_month lv_day lv_year INTO lwa_sdln-delivery_period-start_date_time-content
               SEPARATED BY lc_slash.
*           BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
            ENDIF. " IF sy-subrc NE 0
*           END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*& --> Begin of Insert for Defect#1225 by SAGARWA1
* If the confirmed quentity is 0 then date should be TBD
            IF lwa_sdln-quantity-value = 0.

* ---> Begin of Change for D2_OTC_IDD_0167 CR# 1612 by PDEBARU
* The below code is commented
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*  As per R2 change 6.  If no confirmation date is found, print “TBD” in field “Est Del Date”.
***              PERFORM f_get_text TABLES li_lines
***                                 USING lc_st
***                                       lv_langu1
***                                       lc_tbd
***                                       lc_text.
***
***              READ TABLE li_lines INTO lwa_lines INDEX 1.
***              IF sy-subrc = 0.
***                lv_tbd = lwa_lines-tdline.
***              ENDIF. " IF sy-subrc = 0
***
***              lwa_sdln-delivery_period-start_date_time-content = lv_tbd. " Est. Del Date
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*            lwa_sdln-delivery_period-start_date_time-content = fp_header-audat. " Est. Del Date  " Defcet 1612
* <--- End of Change for D2_OTC_IDD_0167 CR# 1612 by PDEBARU
            ENDIF. " IF lwa_sdln-quantity-value = 0
*& --> End of Insert for Defect#1225 by SAGARWA1
          ENDIF. " IF lwa_sdln-delivery_period-start_date_time IS NOT INITIAL
          APPEND lwa_sdln TO  li_sdln.
          lwa_item-confirmed_schedule_line = li_sdln[].

*         BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
*         get Customer material number
          READ TABLE li_knmt
          ASSIGNING <lfs_knmt>
          WITH KEY matnr = <lfs_vbap>-matnr
          BINARY SEARCH.
          IF sy-subrc EQ 0
            AND <lfs_knmt>-kdmat IS NOT INITIAL.
*           Get Customer material no label in form language
            READ TEXTPOOL lc_prog INTO li_textpool LANGUAGE gv_spras.
            IF sy-subrc EQ 0 AND li_textpool IS NOT INITIAL.
              READ TABLE li_textpool
               ASSIGNING <lfs_textpool>
               WITH KEY id = lc_i
                        key = lc_14.
              IF sy-subrc EQ 0.

                CONDENSE <lfs_knmt>-kdmat.
                CONDENSE <lfs_textpool>-entry.
                CONCATENATE  <lfs_textpool>-entry
                             lc_space
                           <lfs_knmt>-kdmat
                      INTO lv_custmat.

                lwa_item-z01otc_zcustomer_material_numb = lv_custmat.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0 AND li_textpool IS NOT INITIAL
          ENDIF. " IF sy-subrc EQ 0
*         END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*&--> Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
* Determine for the sales order line item whether the item is relevant for a billing plan.
          IF <lfs_vbap>-fkrel = lc_fkrel.

*&--> Set the language key
            IF gv_langu1 IS NOT INITIAL.

              CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
                EXPORTING
                  input            = gv_langu1
                IMPORTING
                  output           = lv_langu1
                EXCEPTIONS
                  unknown_language = 1
                  OTHERS           = 2.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

            ENDIF. " IF gv_spras IS NOT INITIAL



*Since this table does not result out in many entries
*so binary search is not used
*&--> Population logic for Billing method
            READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_z_bmethod
                                                        sel_low = <lfs_vbap>-zz_bilmet.
            IF  sy-subrc = 0.
              lv_bmethod_dom   = <lfs_status>-sel_high.

*               Fetch the SO10 text for Billing method text

              PERFORM f_get_texts USING     lc_st                " Text ID
                                            lv_langu1            " Language Key
                                            lv_bmethod_dom       " TDIC text name
                                            lc_text              " Texts: Application Object
                                CHANGING    lv_bmethod.          " Texts of type CHAR70
              CONDENSE lv_bmethod.
              IF lv_bmethod IS NOT INITIAL.
                lwa_item-product-z01otc_zbilling_method = lv_bmethod.
              ENDIF.
            ENDIF.

*&--> Population logic for Billing frequency

            READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_z_bfrequency
                                                           sel_low = <lfs_vbap>-zz_bilfr.
            IF  sy-subrc = 0.

              lv_bfreq_dom = <lfs_status>-sel_high.
*           Fetch the SO10 text for Billing Frequency text
              PERFORM f_get_texts USING lc_st                    " Text ID
                                        lv_langu1                " Language Key
                                        lv_bfreq_dom             " TDIC text name
                                        lc_text                  " Texts: Application Object
                            CHANGING    lv_bfrequency.           " Texts of type CHAR70
              CONDENSE lv_bfrequency.
              IF lv_bfrequency IS NOT INITIAL.
                lwa_item-product-z01otc_zbilling_frequency = lv_bfrequency.
              ENDIF.
            ENDIF.


*&--> Populating contract start date and end date from FPLA

            READ TABLE li_vbkd INTO lwa_vbkd
              WITH KEY vbeln = <lfs_vbap>-vbeln
                       posnr = <lfs_vbap>-posnr
                       BINARY SEARCH.
            IF sy-subrc = 0.
              READ TABLE li_fplt INTO lwa_fplt WITH KEY fplnr = lwa_vbkd-fplnr.
              IF sy-subrc IS INITIAL.
*&-->Fetching the billing start date
                lwa_item-product-z01otc_zfirst_billing_date = lwa_fplt-fkdat.
*&--Changing the date format as DD-MM-YYYY
                lv_date2 = lwa_item-product-z01otc_zfirst_billing_date.
                CALL FUNCTION 'ZDEV_DATE_FORMAT'
                  EXPORTING
                    i_date       = lv_date2
                    i_format     = fp_dateformat
                    i_langu      = gv_spras
                  IMPORTING
                    e_date_final = lv_date_f.
                IF lv_date_f IS NOT INITIAL.
                  lwa_item-product-z01otc_zfirst_billing_date = lv_date_f.
                ENDIF. " IF lv_date_f IS NOT INITIAL
                CLEAR: lv_date2,
                       lwa_fplt,
                       lv_date_f.

              ENDIF.

*&--Contract start date and end date for billing plan/invoice plan
              READ TABLE li_fpla INTO lwa_fpla
              WITH KEY fplnr = lwa_vbkd-fplnr
              BINARY SEARCH.
              IF sy-subrc = 0 AND lwa_fpla-bedat IS NOT INITIAL AND lwa_fpla-endat IS NOT INITIAL.
                lv_vbegdat = lwa_fpla-bedat.
                lv_venddat = lwa_fpla-endat.
              ENDIF.
            ENDIF.
            CLEAR : lwa_fpla, lwa_vbkd.

*&--Changing the date format as DD-MM-YYYY
            IF lv_vbegdat IS NOT INITIAL.
              CALL FUNCTION 'ZDEV_DATE_FORMAT'
                EXPORTING
                  i_date       = lv_vbegdat
                  i_format     = fp_dateformat
                  i_langu      = gv_spras
                IMPORTING
                  e_date_final = lv_date_f.
              IF lv_date_f IS NOT INITIAL.
                lwa_item-product-z01otc_zcontract_begin_date = lv_date_f.
              ENDIF. " IF lv_date_f IS NOT INITIAL
              CLEAR: lv_vbegdat,
                     lv_date_f.
            ENDIF.
*&--Contract end date for billing plan/invoice plan
*&--Changing the date format as DD-MM-YYYY
            IF lv_venddat IS NOT INITIAL.
              CALL FUNCTION 'ZDEV_DATE_FORMAT'
                EXPORTING
                  i_date       = lv_venddat
                  i_format     = fp_dateformat
                  i_langu      = gv_spras
                IMPORTING
                  e_date_final = lv_date_f.
              IF lv_date_f IS NOT INITIAL.
                lwa_item-product-z01otc_zcontract_end_date = lv_date_f.
              ENDIF. " IF lv_date_f IS NOT INITIAL
              CLEAR: lv_venddat,
                     lv_date_f.
            ENDIF.

*&-->Checking from EMi whether the billing method is EVERGREEN or NON-EVERGREEN
*&--For evergreen, contract end date will be blank.
            READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_evergreen
                                                             sel_low = <lfs_vbap>-zz_bilmet.
            IF sy-subrc IS INITIAL.

              CLEAR lwa_item-product-z01otc_zcontract_end_date.

            ENDIF.
          ENDIF.
*&<-- End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*--Begin of insert for D3_OTC_IDD_0167 CPQ by MTHATHA on 24-Jul-2019
          lwa_item-z01otc_zquoteref  = <lfs_vbap>-zzquoteref.
*--End of insert for D3_OTC_IDD_0167 CPQ by MTHATHA on 24-Jul-2019
          APPEND lwa_item TO li_item.
          CLEAR:  lwa_sdln,
                  lwa_item-product-internal_id-value,
                  lwa_item-product-z01otc_zshort_text,
                  lwa_item-z01otc_zline_text,
                  lwa_item-z01otc_zorder_quantity-content,
                  lwa_item-z01otc_zback_order_qty,
                  lwa_item-z01otc_zunit_price,
                  lwa_item-confirmed_price-net_unit_price-amount-currency_code,
                  lwa_item-z01otc_zextended_price,
                  lwa_item-z01otc_zbatch-id.
          REFRESH li_sdln.
          CLEAR: lv_zzitemref,
          lv_zzqouteref,
          lv_zzlnref,
          lv_bmeng,
          lv_date,
          lv_year,
          lv_day,
          lv_month,
*&---> Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*&-->Clearing local variables used.
          lv_bfrequency,
          lv_bmethod,
          lv_bfreq_dom,
          lv_bmethod_dom.
*&<--End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
          UNASSIGN <lfs_vbep_tmp>.
        ENDLOOP. " LOOP AT li_vbep ASSIGNING <lfs_vbep> FROM lv_index
      ENDIF. " IF sy-subrc EQ 0
      CLEAR lwa_item.
    ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>

*&--> Begin of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
    LOOP AT li_status ASSIGNING <lfs_status>.
      IF <lfs_status>-criteria = lc_kntyp.
        lwa_kntyp-sign   = lc_i.
        lwa_kntyp-option = lc_eq.
        lwa_kntyp-low    = <lfs_status>-sel_low.
        lwa_kntyp-high   = <lfs_status>-sel_high.
        APPEND lwa_kntyp TO li_kntyp[].
        CLEAR lwa_kntyp.
      ENDIF.
    ENDLOOP.
    IF <lfs_status> IS ASSIGNED.
      UNASSIGN <lfs_status>.
    ENDIF.
*&<-- End of insert for R6 Upgrade d3_otc_idd_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*Dangerous goods
    li_konv_temp[] = li_konv[].
    DELETE li_konv_temp WHERE kschl NE lv_zdng.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    DELETE li_konv_temp WHERE kposn IS INITIAL.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
      lv_dangergoods_fee1 = lv_dangergoods_fee1 + <lfs_konv>-kwert.
    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
    REFRESH li_konv_temp[].
*Handling_fees
    li_konv_temp[] = li_konv[].
    DELETE li_konv_temp WHERE kschl NE lv_zhdl.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    DELETE li_konv_temp WHERE kposn IS INITIAL.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
      lv_handling_fee1 = lv_handling_fee1 + <lfs_konv>-kwert.
    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
    REFRESH li_konv_temp[].

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
**   Add (summarize) the value for the header pricing condition ZDOC to the field
**  “Handling” when the pricing condition is existing in the sales order header.
*    li_konv_temp[] = li_konv[].
*    DELETE li_konv_temp WHERE kschl NE lv_zdoc.
*    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
*      lv_handling_fee1 = lv_handling_fee1 + <lfs_konv>-kwert.
*    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
*    FREE li_konv_temp[].
* <--- End of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    li_konv_temp[] = li_konv[].
    DELETE li_konv_temp WHERE kschl NE lv_zdoc.
    DELETE li_konv_temp WHERE kposn IS INITIAL.

    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
      lv_documentation = lv_documentation + <lfs_konv>-kwert.
    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
    FREE li_konv_temp[].
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18

*environmental charge
    li_konv_temp[] = li_konv[].
    DELETE li_konv_temp WHERE kschl NE lv_zenv.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    DELETE li_konv_temp WHERE kposn IS INITIAL.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
      lv_env_fee = lv_env_fee + <lfs_konv>-kwert.
    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
    FREE li_konv_temp[].

*Insurance charge
    li_konv_temp[] = li_konv[].
    DELETE li_konv_temp WHERE kschl NE lv_zins.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    DELETE li_konv_temp WHERE kposn IS INITIAL.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
      lv_insurance = lv_insurance + <lfs_konv>-kwert.
    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
    FREE li_konv_temp[].
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

*Freight
    li_konv_temp[] = li_konv[].
    DELETE li_konv_temp WHERE kschl NE lv_ztfr.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    DELETE li_konv_temp WHERE kposn IS INITIAL.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    LOOP AT li_konv_temp ASSIGNING <lfs_konv>.
      lv_freight1 = lv_freight1 + <lfs_konv>-kwert.
    ENDLOOP. " LOOP AT li_konv_temp ASSIGNING <lfs_konv>
    FREE li_konv_temp[].

*&--> Begin of insert for R6 Upgrade  D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
    li_konv_temp[] = li_konv[].
*&--> Begin of delete for R6 Upgrade D3_OTC_IDD_0167_Defect#8305 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*      DELETE li_konv_tmp WHERE kschl NE lc_mwst.
*&<-- End of delete for R6 Upgrade D3_OTC_IDD_0167_Defect#8305 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of insert for R6 Upgrade D3_OTC_IDD_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
    DELETE li_konv_temp WHERE kschl = lc_zmw0.
    SORT li_vbap_tmp1 BY posnr.
    SORT li_konv BY kposn.
*&<-- End of insert for R6 Upgrade D3_OTC_IDD_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

    SORT li_konv_temp BY kposn.
*&<-- End of insert for R6 Upgrade  D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA
*Tax calculation
*Li_VBAP_TMP1 is replica of li_vbap internal table, only the line item with kowrr = Y
*field is removed from table and then we are adding the mwsbp values of line item to get the
*total tax value.
    LOOP AT li_vbap_tmp1 ASSIGNING <lfs_vbap>.
*&--> Begin of delete for R6 Upgrade D3_OTC_IDD_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*&--> Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*Remove logic in program to summary the total billing plan VAT (mwst) in the VAT totals field.
*The requirement is to print the VAT of the line item only once in the VAT total.
*        READ TABLE li_konv_temp INTO lwa_konv_tmp
*             WITH KEY kposn = <lfs_vbap>-posnr
*             BINARY SEARCH.
*        IF sy-subrc = 0.
*          lv_tax1 = lv_tax1 + lwa_konv_tmp-kwert.
*        ENDIF.
*        CLEAR lwa_konv_tmp.
*&<-- End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*&<-- End of delete for R6 Upgrade D3_OTC_IDD_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of insert for R6 Upgrade D3_OTC_IDD_0167Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*&--->Tax calculation logic for Split tax invoices, mulitple tax jurisdictions & European order
      IF li_konv_temp IS NOT INITIAL.
        READ TABLE li_konv_temp INTO lwa_konv_tmp WITH KEY kposn = <lfs_vbap>-posnr
                                                     BINARY SEARCH.
        IF sy-subrc IS INITIAL.
*&--Catching the index value
          lv_index_val = sy-tabix.
*&--Parallel cursor have been used to check for all the line items
          LOOP AT li_konv_temp INTO lwa_konv_tmp FROM lv_index_val.
            IF lwa_konv_tmp-kposn <> <lfs_vbap>-posnr.
              EXIT.
            ENDIF.
            IF  lwa_konv_tmp-kntyp IN li_kntyp[] AND
            lwa_konv_tmp-kstat IS INITIAL .
              lv_tax1 = lv_tax1 + lwa_konv_tmp-kwert.
            ENDIF.
          ENDLOOP.

        ENDIF.
        CLEAR: lwa_konv_tmp,
               lv_index_val.
*      ELSE.
*
**&--For US order taxes no MWST & ZMW0 condition type will be present
*        READ TABLE li_konv INTO lwa_konv_tmp WITH KEY kposn = <lfs_vbap>-posnr
*                                             BINARY SEARCH.
*        IF sy-subrc IS INITIAL.
**&--Catching the index value
*          lv_index_val = sy-tabix.
**&--Parallel cursor have been used to check for all the line items
*          LOOP AT li_konv INTO lwa_konv_tmp FROM lv_index_val.
*            IF lwa_konv_tmp-kposn <> <lfs_vbap>-posnr.
*              EXIT.
*            ENDIF.
*            IF  lwa_konv_tmp-kntyp IN li_kntyp[] AND
*            lwa_konv_tmp-kstat IS INITIAL AND
*            lwa_konv_tmp-kschl NE lc_zmw0.
*
*              lv_tax1 = lv_tax1 + lwa_konv_tmp-kwert.
*            ENDIF.
*
*          ENDLOOP.
*      ENDIF.
      ENDIF.

      CLEAR: lwa_konv_tmp,
             lv_index_val.
*&<-- End of insert for R6 Upgrade D3_OTC_IDD_0167_Defect#8656 SCTASK0793192 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of delete for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*    lv_tax1 = lv_tax1 + <lfs_vbap>-mwsbp.
*&<-- End of delete for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019

    ENDLOOP. " LOOP AT li_vbap_tmp1 ASSIGNING <lfs_vbap>
* <--- End of Insert for D2_OTC_IDD_0167,Defect #5418 by NSAXENA

*Total Amount
    lv_total_price1 =  lv_subtotal_price1
                   + lv_dangergoods_fee1 + lv_handling_fee1
                   + lv_freight1 + lv_tax1
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
                   + lv_documentation
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                   +  lv_env_fee + lv_insurance.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

*writing prices for amounts
    WRITE: lv_total_price1 TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_ztotal_amt CURRENCY lv_cuky.
*Danger goods fees
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    IF lv_dangergoods_fee1 IS NOT INITIAL.
      WRITE:
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
     lv_dangergoods_fee1 TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zdangerous_goods_fee CURRENCY lv_cuky.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    ENDIF.
    WRITE:
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*Subtotal Price
  lv_subtotal_price1 TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zsub_total_amt CURRENCY lv_cuky.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    IF lv_handling_fee1 IS NOT INITIAL.
      WRITE:
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*Handling fees
   lv_handling_fee1 TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zhandling_fee CURRENCY lv_cuky.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    ENDIF.
    IF lv_freight1 IS NOT INITIAL.
      WRITE:
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*Freight charges
  lv_freight1 TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zfreight_amt CURRENCY lv_cuky.
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    ENDIF.
    WRITE:
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*Tax Amount
  lv_tax1 TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_ztax_amt CURRENCY lv_cuky.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    IF lv_env_fee IS NOT INITIAL .
      WRITE: lv_env_fee TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zenvironment_charge CURRENCY lv_cuky.
    ENDIF.
    IF lv_insurance IS NOT INITIAL .
      WRITE: lv_insurance TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zinsurance CURRENCY lv_cuky.
    ENDIF.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    IF lv_documentation IS NOT INITIAL .
      WRITE: lv_documentation TO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zdocumentation CURRENCY lv_cuky.
    ENDIF.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18

    CLEAR:lv_total_price1,
    lv_dangergoods_fee1,
    lv_subtotal_price1,
    lv_handling_fee1,
    lv_freight1,
    lv_tax1,
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    lv_documentation,
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_env_fee,
    lv_insurance.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

    fp_structure_out-purchase_order_confirmation-purchase_order-item = li_item[].

  ENDIF. " IF sy-subrc EQ 0
*Refreshing internal table
  REFRESH: i_name[],
             li_id_item[].
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
  fp_struc_out2 = fp_structure_out.
  fp_struc_out2-purchase_order_confirmation-message_header-recipient_party = fp_i_recipient_party2[].
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
ENDFORM. "f_get_item_data
*&---------------------------------------------------------------------*
*&      Form  F_PROCESSING
*&---------------------------------------------------------------------*
*       Processing form
*----------------------------------------------------------------------*
*      -->FP_US_SCREEN   Screen type                                   *
*      -->FP_NAST        Messae status                                 *
*      -->FP_TNAPR       Processing programs for output                *
*      -->FP_VBAP        Internal table                                *
*     -->FP_STRUCTURE_OUT  Purchase order confirmation structure       *
*     -->FP_RETCODE        Return Code                                 *
*----------------------------------------------------------------------*
FORM f_processing USING fp_us_screen  TYPE c                                     " Processing using fp_us_ of type Character
                         fp_nast TYPE nast                                       " Message Status
                         fp_tnapr TYPE tnapr                            ##needed " Processing programs for output
                         fp_vbpa  TYPE tt_vbpa                                   "Internal table VBPA
*  BEGIN OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG
                         fp_status TYPE tty_status
*  END OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG

                CHANGING fp_structure_out TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                         fp_struc_out2 TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                         fp_retcode TYPE sy-subrc. " Return Value of ABAP Statements

  DATA:
*Variables
     lv_vbeln TYPE vbeln_va. "Document No.

*Structures
  DATA:
    lx_contact_addr TYPE ty_address,           "Contact Person Address
    lx_header       TYPE zotc_cust_order_ack_header. "Document Header data


* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

  CONSTANTS: lc_output           TYPE z_criteria    VALUE 'KSCHL'. " Enh. Criteria

  CLEAR: gv_spras,
         gv_partner,
         gv_partner2,
         gv_zba1.

  READ TABLE fp_status
  WITH KEY criteria = lc_output
           sel_low  = fp_nast-kschl
  TRANSPORTING NO FIELDS .
  IF sy-subrc EQ 0 .
    gv_zba1 = abap_true.
  ENDIF. " IF sy-subrc EQ 0
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*&--Fetch form data
  PERFORM f_get_data USING fp_us_screen
                           fp_nast
                           fp_vbpa
*  BEGIN OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG
                           fp_status
*  END OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG

                  CHANGING lv_vbeln
                           lx_contact_addr
                           lx_header
                           fp_structure_out
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                           fp_struc_out2
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

                           fp_retcode.

  IF fp_retcode = 1.
    RETURN.
  ENDIF. " IF fp_retcode = 1

ENDFORM. " F_PROCESSING
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       Complete data for sales order
*----------------------------------------------------------------------*
*      -->FP_SCREEN       Screen                                       *
*      -->FP_NAST         Messages status                              *
*      -->FP_VBAP        Internal table                                *
*      -->FP_VBELN        Sales Document Number                        *
*      -->FP_CONTACT_ADDR General Address                              *
*      -->FP_HEADER        HEADER DATA                                 *
*     -->FP_STRUCTURE_OUT  Purchase order confirmation structure       *
*     -->FP_RETCODE        Return Code                                 *
*----------------------------------------------------------------------*
FORM f_get_data USING fp_screen       TYPE c       " Get_data using fp_scree of type Character
                      fp_nast         TYPE nast    " Message Status
                      fp_vbpa         TYPE tt_vbpa "Internal table VBPA
*  BEGIN OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG
                      fp_status       TYPE tty_status
*  END OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG
             CHANGING fp_vbeln        TYPE vbeln_va                        " Sales Document
                      fp_contact_addr TYPE ty_address                      " Order Acknowledgement - General Address Information
                      fp_header       TYPE zotc_cust_order_ack_header      " Header data for Order Acknowledgement form
                      fp_structure_out TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                      fp_struc_out2    TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                      fp_retcode      TYPE sy-subrc. " Return Value of ABAP Statements


  DATA: lv_sales_ord TYPE vbeln. " Sales and Distribution Document Number
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
  DATA: lv_langu TYPE char2. "sylangu. " Langu of type CHAR2
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
  DATA : lv_land       TYPE land1_gp,                           " Country Key
         lv_vkorg      TYPE vkorg,                              " Sales Organization
         lv_kunnr      TYPE kunnr,                              " Customer Number
         li_status     TYPE STANDARD TABLE OF  zdev_enh_status, " Internal table for Enhancement Status
         li_recipient  TYPE sapplsef_business_document_tab,
         lv_dateformat TYPE char15.                             " Dateformat of type CHAR10

  CONSTANTS:         lc_idd_0167 TYPE z_enhancement VALUE 'D2_OTC_IDD_0167'. " Enhancement No.

  li_status[] = fp_status[].
*  * END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*&--Sales Document No. from NAST Object key
  fp_vbeln = fp_nast-objky.

*Using FM to pass the Sales order in output format to sap
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = fp_vbeln
    IMPORTING
      output = lv_sales_ord.
*Passing value to structure out
  fp_structure_out-purchase_order_confirmation-purchase_order-seller_id-value =  fp_vbeln.
*To get the Header data
  PERFORM f_get_header_data USING lv_sales_ord
                                  fp_nast
                                  fp_screen
                                  fp_vbpa
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                                  li_status
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                         CHANGING fp_contact_addr
                                  fp_header
                                  fp_structure_out
                                  lv_langu
                                  fp_retcode
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                                  fp_struc_out2
                                  li_recipient
                                  lv_kunnr
                                  lv_vkorg
                                  lv_land
                                  lv_dateformat.
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*&--Fetch Sales Document Item data
  PERFORM f_get_item_data USING lv_sales_ord
                                fp_header
                                lv_langu
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                                lv_vkorg
                                lv_land
                                li_status
                                lv_dateformat
                                lv_kunnr
                                li_recipient
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                       CHANGING fp_structure_out
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                                fp_struc_out2
* END  OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                                fp_retcode.


ENDFORM. " F_GET_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_DATA
*&---------------------------------------------------------------------*
* Populate the Header data                                             *
*----------------------------------------------------------------------*
*      -->FP_VBELN        Sales Document Number                        *
*      -->FP_NAST         Message Status                               *
*      -->FP_SCREEN       Screen                                       *
*      -->FP_VBAP        Internal table                                *
*      -->FP_CONTACT_ADDR General Address                              *
*      -->FP_HEADER        HEADER DATA                                 *
*     -->FP_STRUCTURE_OUT  Purchase order confirmation structure       *
*     -->FP_LANGU          Language type                               *
*     -->FP_RETCODE        Return Code                                 *
*----------------------------------------------------------------------*
FORM f_get_header_data USING fp_vbeln       TYPE vbeln_va                               " Sales Document
                             fp_nast         TYPE nast                                  " Message Status
                             fp_screen       TYPE c                            ##needed "Screen of type Character
                             fp_vbpa         TYPE tt_vbpa                               "Internal table VBPA
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                             fp_status       TYPE tty_status
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

                    CHANGING fp_contact_addr TYPE ty_address                      " Order Acknowledgement - General Address Information
                             fp_header       TYPE zotc_cust_order_ack_header      " Header data for Order Acknowledgement form
                             fp_structure_out TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
                             fp_langu        TYPE char2                           " Language Key of Current Text Environment
                             fp_retcode      TYPE sy-subrc "#EC NEEDED  "Return Value of ABAP Statements
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                             fp_struc_out2   TYPE sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
                             fp_i_recipient  TYPE sapplsef_business_document_tab
                             fp_kunnr        TYPE kunnr                          " Customer Number
                             fp_vkorg        TYPE vkorg                          " Sales Organization
                             fp_land         TYPE land1_gp                       " Country Key
                             fp_dateformat   TYPE char15.                        " Dateformat of type CHAR10
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
  TYPES:
    BEGIN OF lty_email,
      addrnumber TYPE	ad_addrnum,
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
      persnumber TYPE ad_persnum, " Person number
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
      date_from  TYPE ad_date_fr, " Valid-from date - in current Release only 00010101 possible
      smtp_addr  TYPE ad_smtpadr, "E-Mail Address
    END OF lty_email,

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*For Storing the hedaer text ids.
    BEGIN OF ty_object_id,
      id TYPE tdid, " Text ID
    END OF ty_object_id,
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
    BEGIN OF ty_kna1,
      kunnr TYPE kunnr,    " Customer Number
      land1 TYPE land1_gp, " Country Key
      spras TYPE spras,    " Language Key
    END OF ty_kna1,
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    BEGIN OF lty_kna1,
      kunnr TYPE kunnr, " Customer Number
      bbbnr TYPE bbbnr, " International location number  (part 1)
      bbsnr TYPE bbsnr, " International location number (Part 2)
    END OF lty_kna1.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

*Local Internal tables
  DATA: li_lines     TYPE STANDARD TABLE OF tline, "Material Sales text
        li_vbpa      TYPE STANDARD TABLE OF ty_vbpa,  "Table for Partner data
        li_vbpa_tmp  TYPE STANDARD TABLE OF ty_vbpa,
        li_email     TYPE STANDARD TABLE OF lty_email,
*             li_status TYPE STANDARD TABLE OF  zdev_enh_status, " Internal table for Enhancement Status
        li_address   TYPE STANDARD TABLE OF ty_address, " Order Acknowledgement - General Address Information
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
        li_kna1      TYPE STANDARD TABLE OF lty_kna1 INITIAL SIZE 0, "Local Table for KNA1
        lwa_kna1_gln TYPE lty_kna1, "Local work area for KNA1
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
        li_id        TYPE STANDARD TABLE OF ty_object_id, "Internal table for header text id
        lwa_id       TYPE ty_object_id.                  "Work Area for header text id
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

*Local Work Area
  DATA:
    lwa_physical_address  TYPE sapplsef_address_physical_addr, " Proxy Structure (generated)
    lwa_main_address      TYPE sapplsef_address,               " Proxy Structure (Generated)
    lwa_organisation_name TYPE sapplsef_languageindependent_m, " Proxy Data Element (Generated)
    lwa_phone_number      TYPE sapplsef_phone_number,          " Proxy Structure (Generated)
    lwa_email_id          TYPE    sapplsefemail_uri,           " Proxy Structure (Generated)
    lwa_prefix_name       TYPE sapplsef_languageindependent_m, " Proxy Data Element (Generated)
    lwa_suffix_name       TYPE sapplsef_languageindependent_m. " Proxy Data Element (Generated)

*Local internal tables and variables
  DATA:
    li_recipient_party TYPE sapplsef_business_document_tab,
    lx_recipient_party TYPE sapplsef_business_document_me1, " General information about a party that is responsible for se
    li_phone_number    TYPE sapplsef_phone_number_tab,      "Internal tables
    li_email_id        TYPE sapplsef_email_uri_tt,          "Internal tables
    li_main_address    TYPE sapplsef_address_tab,           "Internal tables
    li_org_name        TYPE sapplsef_address_organisat_tab, "Internal tables
    li_prefix_name     TYPE sapplsef_address_street_su_tab, "Internal tables
    li_suffix_name     TYPE sapplsef_address_street_su_tab, "Internal tables
*           Begin of Insert for Defect#2008 by NGARG
    li_textpool        TYPE STANDARD TABLE OF textpool. " ABAP Text Pool Definition
*           End of Insert for Defect#2008 by NGARG

  " General information about a party that is responsible for se
*Local constants
  CONSTANTS:
    lc_contact       TYPE parvw          VALUE 'AP',              "Contact person " added by nsaxena
    lc_contact_other TYPE parvw          VALUE 'ZA',              "Contact person "added by nsaxena
    lc_sold_to       TYPE parvw          VALUE 'AG',              "Bill-to party " added by nsaxena
    lc_ship_to       TYPE parvw          VALUE 'WE',              "Ship-to party  " added by nsaxena
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lc_bill_to       TYPE parvw          VALUE 'RE',              "Bill-to party
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lc_posnr         TYPE posnr_va       VALUE '000000',          "Header Item count
    lc_slash         TYPE char1          VALUE '/',               " Slash of type CHAR1
    lc_id_0002       TYPE tdid           VALUE '0002',            " Text ID
    lc_id_z009       TYPE tdid           VALUE 'Z009',            " Text ID
    lc_id_z012       TYPE tdid           VALUE 'Z012',            " Text ID
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    lc_id_cup        TYPE tdid           VALUE 'CUP',             " Text ID
    lc_id_cig        TYPE tdid           VALUE 'CIG',             " Text ID
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    lc_object        TYPE tdobject       VALUE 'VBBK',            " Texts: Application Object
    lc_domname       TYPE char10         VALUE 'Z_DOCTYP',        " Domname of type CHAR10
    lc_as4local      TYPE char1          VALUE 'A',               " As4local of type CHAR1
    lc_cons_0000     TYPE char4          VALUE '0000',            " Cons_0000 of type CHAR4
    lc_idd_0167      TYPE z_enhancement  VALUE 'D2_OTC_IDD_0167', "Enhancement number
    lc_lang          TYPE z_criteria     VALUE 'VKORG_LANG',      " Enh. Criteria
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
    lc_freight       TYPE z_criteria     VALUE 'ZFREIGHT', " Enh. Criteria
* <--- End of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
    lc_lang_en       TYPE char_02        VALUE 'EN', " Character length 2
* <--- End of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN

*& --> Begin of Insert for Defect#1225 by SAGARWA1
    lc_prepaid       TYPE char10         VALUE 'PREPAID', " Freight Text
    lc_collect       TYPE char10         VALUE 'COLLECT', " Freight Text
    lc_dap           TYPE inco1          VALUE 'DAP',     " Incoterm 1 value
    lc_fca           TYPE inco1          VALUE 'FCA',     " Incoterm 1 value
*& --> End of Insert for Defect#1225 by SAGARWA1

*  BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
    lc_english       TYPE spras         VALUE'E',           " Language Key
    lc_date          TYPE z_criteria    VALUE 'DATE',       " Enh. Criteria
    lc_vkorg         TYPE z_criteria    VALUE 'VKORG_LANG', " Enh. Criteria
    lc_vkorg_date    TYPE z_criteria    VALUE 'VKORG',      " Enh. Criteria
    lc_spras         TYPE z_criteria    VALUE 'SPRAS',      " Enh. Criteria
    lc_output        TYPE z_criteria    VALUE 'KSCHL',      " Enh. Criteria
    lc_y             TYPE char1         VALUE 'Y',          " Y of type CHAR1
    lc_n             TYPE char1         VALUE 'N',          " N of type CHAR1
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
*           Begin of Insert for Defect#2008 by NGARG
    lc_i             TYPE textpoolid     VALUE 'I',   " ABAP/4 text pool ID (selection text/numbered text)
    lc_008           TYPE textpoolky     VALUE '008', " Text element key (number/selection name)
*           End of Insert for Defect#2008 by NGARG
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
    lc_comma         TYPE char1 VALUE ',', " Comma of type CHAR1
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8796  by u029267 on 29-Mar-2019
    lc_zzdoctyp_08   TYPE z_doctyp VALUE '08'.              "Esker doc type
* <--- End    of Insert for D3_OTC_IDD_0167_Defect#8796  by u029267 on 29-Mar-2019

*Local variables
  DATA:
    lv_guid                TYPE guid_32,                             " GUID in 'CHAR' Format in Uppercase
    lv_timestamp           TYPE timestamp,                      " UTC Time Stamp in Short Form (YYYYMMDDhhmmss)
    lv_vsbed               TYPE vsbed,                            "Shipping Conditions
    lv_zzdocref            TYPE z_docref,                        " Legacy Doc Ref
    lv_zzdoctyp            TYPE z_doctyp,                        " Ref Doc type
    lv_zzcaseref           TYPE z_caseref,                      " Index of Internal Tables
    lv_adrnr               TYPE adrnr,                            "Address number of Customer
    lv_vkorg               TYPE vkorg,                              " Sales Organization
    lv_ship_attention      TYPE char255,                   " SAPscript: Text Lines
    lv_name                TYPE tdobname,                           " Name
    lv_ord_comments_part1  TYPE char255,               " SAPscript: Text Lines
    lv_ord_comments_part2  TYPE char255,               " SAPscript: Text Lines
    lv_ord_comments        TYPE char255,                     " Ord_comments of type CHAR40
    lv_doctyp              TYPE val_text,                          " Doctyp of type CHAR255
    lv_ord_1               TYPE char255,                            " Ord_1 of type CHAR255
    lv_ord_2               TYPE char255,                            " Ord_2 of type CHAR255
    lv_caseref             TYPE char255,                          " Caseref of type CHAR255
    lv_docref              TYPE char255,                           " Docref of type CHAR255
    lv_name1               TYPE ad_name1,                           " Name 1
    lv_valpos              TYPE valpos,                            " Domain value key
    lv_date                TYPE char10,                              " Date of type CHAR10
    lv_year                TYPE char2,                               " Year of type CHAR2
    lv_month               TYPE char2,                              " Month of type CHAR2
    lv_day                 TYPE char2,                                " Day of type CHAR2
    lv_doctyp_ord          TYPE val_text,                     " Short Text for Fixed Values
    lv_org_name1           TYPE sapplsef_languageindependent_m, " Proxy Data Element (Generated)
    lv_org_name2           TYPE sapplsef_languageindependent_m, " Proxy Data Element (Generated)
    lv_org_name3           TYPE sapplsef_languageindependent_m, " Proxy Data Element (Generated)
    lv_org_name4           TYPE sapplsef_languageindependent_m, " Proxy Data Element (Generated)
    lv_ship_no             TYPE char10,                           " Ship_no of type CHAR10
    lv_sold_no             TYPE char10,                           " Sold_no of type CHAR10
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_bill_no             TYPE char10,                           " Bill_no of type CHAR10
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    lv_ship_att            TYPE char255,                         " Ship_att of type CHAR255
    lv_langu1              TYPE sylangu,                           " Langu of type CHAR2
    lv_inco1               TYPE inco1,                              " Incoterms (Part 1)
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
    lv_freight_header      TYPE char10, " Freight_header of type CHAR10
* <--- End of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*---> Begin of change for D2_OTC_IDD_0167 Defect # 1697 by PDEBARU
    lv_vbeln               TYPE vbeln, " Sales and Distribution Document Number
*<--- End of change for D2_OTC_IDD_0167 Defect # 1697 by PDEBARU
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    lv_z01otc_zgln_ship_to TYPE char12, " GLN for Ship-to address
    lv_cup_val             TYPE char15, " CUP text
    lv_cig_val             TYPE char10, " CIG text
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*  BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

    lwa_kna1               TYPE ty_kna1,
    lv_date2               TYPE sydatum,  " Current Date of Application Server
    lv_date_f              TYPE char15,   " Date_f of type CHAR15
    lv_time                TYPE sy-uzeit, " Current Time of Application Server
    lv_dateformat          TYPE char15,   " Dateformat of type CHAR15
    lv_sold_to             TYPE kunag,    " Sold-to party
    lv_spras               TYPE laiso,    " Language Key of Current Text Environment
    lv_emailid             TYPE string,
    li_status              TYPE tty_status,
    li_status_temp         TYPE tty_status,
    li_recipient_party2    TYPE sapplsef_business_document_tab,
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
    lv_buildline           TYPE adrs-line0, " Address line
    lv_flag_skip           TYPE char1,      " Flag_skip of type CHAR1
    lv_flag_set            TYPE char1,      " Flag_set of type CHAR1
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
* ---> Begin of Insert for D3_OTC_IDD_0167_CR#301 by U034334
    lv_vkorg_adrnr         TYPE adrnr,                " Address
    lv_vkorg_name1         TYPE ad_name1,             " Name 1
    lv_vkorg_name2         TYPE ad_name1,             " Name 1
    lwa_seller_address     TYPE sapplsef_address. " Proxy Structure (Generated)
* ---> End   of Insert for D3_OTC_IDD_0167_CR#301 by U034334

  FIELD-SYMBOLS : <lfs_email_id> TYPE sapplsefemail_uri. " Proxy Structure (Generated)

  CONSTANTS : lc_semicolon TYPE char1 VALUE ';'. " Semicolon of type CHAR1
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
*           Begin of Insert for Defect#2008 by NGARG
  FIELD-SYMBOLS :<lfs_textpool> TYPE textpool. " ABAP Text Pool Definition
*           End of Insert for Defect#2008 by NGARG


*Field Symbols
  FIELD-SYMBOLS:
    <lfs_vbpa>   TYPE ty_vbpa,           "Partner data
    <lfs_email>  TYPE lty_email,
    <lfs_lines>  TYPE tline,            " SAPscript: Text Lines
    <lfs_status> TYPE zdev_enh_status, "For Reading enhancement table
    <lfs_addr>   TYPE ty_address.        "Customer Order Acknowledgement - General Address Information



*  Begin of Insert for defect#3682 by NGARG
  TYPES: BEGIN OF lty_ordertexts,
           text TYPE string,
         END OF lty_ordertexts.

  DATA  : li_ordertexts  TYPE STANDARD TABLE OF lty_ordertexts,
          lwa_ordertexts TYPE lty_ordertexts,
          lv_tabix       TYPE sytabix. " Index of Internal Tables

  FIELD-SYMBOLS : <lfs_ordertexts> TYPE lty_ordertexts.

*  End of Insert for defect#3682 by NGARG
*            Begin of change for Defect#4090 by NGARG
  CONSTANTS : lc_doctyp TYPE z_criteria VALUE 'DOC_TYPE'. " Enh. Criteria
*            End of change for Defect#4090 by NGARG
*  BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

  li_status[] = fp_status[].

  li_status_temp[] = li_status[].
  SORT li_status_temp BY criteria sel_low.

* Get Date format
  READ TABLE li_status
   ASSIGNING <lfs_status>
    WITH KEY criteria = lc_date.
  IF sy-subrc EQ 0.
    fp_dateformat = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

  CLEAR fp_langu.
* Calling Method to Fill UUID
  TRY.
      CALL METHOD cl_system_uuid=>if_system_uuid_static~create_uuid_c32
        RECEIVING
          uuid = lv_guid.
    CATCH cx_uuid_error.
      fp_retcode = 1.
      RETURN.
  ENDTRY.

  MOVE lv_guid TO fp_structure_out-purchase_order_confirmation-message_header-id-value.
  fp_structure_out-purchase_order_confirmation-purchase_order-note-value = fp_nast-kschl.

* Fill CreationDateTime - UTC
  GET TIME STAMP FIELD lv_timestamp.
  IF sy-subrc EQ 0.
    TRY.
        CALL METHOD cl_gdt_conversion=>date_time_outbound
          EXPORTING
            im_value_short = lv_timestamp
          IMPORTING
            ex_value       = fp_structure_out-purchase_order_confirmation-message_header-creation_date_time.
      CATCH cx_gdt_conversion .
        fp_retcode = 1.
        RETURN.
    ENDTRY.
  ENDIF. " IF sy-subrc EQ 0

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
  CLEAR: lwa_id.
  REFRESH li_id[].
*Inserting the text ids at header level so that based on these text id we will fetch the data
*from STXH table and then we will read individual text id at header level as per language and other
*input parameter
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
  lwa_id-id = lc_id_cup. "text id cup
  APPEND lwa_id TO li_id.
  CLEAR:lwa_id.
  lwa_id-id = lc_id_cig. "text id cig
  APPEND lwa_id TO li_id.
  CLEAR:lwa_id.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
  lwa_id-id = lc_id_0002. "Object id 0002
  APPEND lwa_id TO li_id.
  CLEAR lwa_id.
  lwa_id-id = lc_id_z009. "Object id z009
  APPEND lwa_id TO li_id.
  CLEAR lwa_id.
  lwa_id-id = lc_id_z012. "Object id z012
  APPEND lwa_id TO li_id.
  CLEAR: lwa_id,
        lv_langu1.
  IF li_id[] IS NOT INITIAL.

*Using this FM we convert the two character language key
*to system generated langugae key of type sylangu.
    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
      EXPORTING
        input            = fp_langu  "Language of char2 type
      IMPORTING
        output           = lv_langu1 "Sylangu type
      EXCEPTIONS
        unknown_language = 1
        OTHERS           = 2.
    IF sy-subrc EQ 0.
      lv_name = fp_vbeln.
*When language is accepted we can cehck for texts
*maintrianed in STXH table with text id for header details
      SELECT tdobject                   " Texts: Application Object
             tdname                     " Name
             tdid                       " Text ID
             tdspras                    " Language Key
             FROM stxh                  " STXD SAPscript text file header
             INTO TABLE i_name
            FOR ALL ENTRIES IN li_id    "Header text internal table with text ids
             WHERE tdobject = lc_object "Object
             AND tdname = lv_name       "Sales order number
             AND tdid = li_id-id.       "Text IDs
*             AND tdspras = lv_langu1.   "language key
      IF sy-subrc EQ 0.
        SORT i_name BY id.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_id[] IS NOT INITIAL
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

*---> Begin of change for D2_OTC_IDD_0167 Defect # 1697 by PDEBARU
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = fp_vbeln
    IMPORTING
      output = lv_vbeln.

*<--- End of change for D2_OTC_IDD_0167 Defect # 1697 by PDEBARU

*&--Fetch Sales document header data
  SELECT SINGLE audat "Document Date
                waerk "Currency
                vkorg " Sales Organization
                vtweg " Distribution Channel
                knumv " Number of the document condition
                vsbed "Shipping Conditions
*  BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                kunnr
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                zzdocref  " Legacy Doc Ref
                zzdoctyp  " Ref Doc type
                zzcaseref " Case Ref No

           FROM vbak      " Sales Document: Header Data
           INTO (fp_header-audat,fp_header-waerk,lv_vkorg,fp_header-vtweg,fp_header-knumv,lv_vsbed,
*  BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
                  lv_sold_to,
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

                 lv_zzdocref,lv_zzdoctyp,lv_zzcaseref)
*---> Begin of change for D2_OTC_IDD_0167 Defect # 1697 by PDEBARU
** The below line is commented
*          WHERE vbeln = fp_vbeln.
          WHERE vbeln = lv_vbeln.
*<--- End of change for D2_OTC_IDD_0167 Defect # 1697 by PDEBARU
  IF sy-subrc = 0.
* BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
    fp_kunnr = lv_sold_to.
    READ TABLE li_status_temp WITH KEY criteria = lc_vkorg
                                  sel_low = lv_vkorg
                                  BINARY SEARCH
                                  TRANSPORTING NO FIELDS.
    IF sy-subrc EQ 0.
      fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zmulti_language = lc_y.
    ELSE. " ELSE -> IF sy-subrc EQ 0
      fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zmulti_language = lc_n.
    ENDIF. " IF sy-subrc EQ 0
* END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG


*  BEGIN OF DELETE FOR D3_OTC_IDD_0167 by NGARG
*MOVED TO COMMON FORM F_GET_DATA
*Calling FM to get the emi table values.
*    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*      EXPORTING
*        iv_enhancement_no = lc_idd_0167
*      TABLES
*        tt_enh_status     = li_status.
**Non active entries are removed.
*    DELETE li_status WHERE active EQ abap_false.

*  END OF DELETE FOR D3_OTC_IDD_0167 by NGARG

*Read table to get the language code based on the company code comaprision.
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_lang
                                                         sel_low  = lv_vkorg.
*For language check
    IF sy-subrc EQ 0.
      fp_langu = <lfs_status>-sel_high.

*Pass langauge code to PI mapping parameter.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
      fp_structure_out-purchase_order_confirmation-purchase_order-note-language_code = fp_langu.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
      fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zlanguage_code = fp_langu.
*&-->Begin of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
      gv_langu1 = fp_langu.
*&<--End of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
    ELSE. " ELSE -> IF sy-subrc EQ 0
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
*Default language as english
      fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zlanguage_code = lc_lang_en.
*&-->Begin of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
      gv_langu1 = lc_lang_en.
*&<--End of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019

*     BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*     Overwrite language based on SOLD TO PARTY,
*     only for entries where Sales org is not 1000 or 1020 or 1103
      IF lv_sold_to IS NOT INITIAL.
*       Get Sold to partner LAnguage and country
        SELECT SINGLE kunnr " Customer Number
                      land1 " Country Key
                      spras " Language Key
          FROM kna1         " General Data in Customer Master
          INTO lwa_kna1
          WHERE kunnr EQ lv_sold_to.
        IF sy-subrc EQ 0.
*         Set Country as Sold to country ,
*         so the decimal notation is set as per that accordance
          fp_land = lwa_kna1-land1.
          SET COUNTRY fp_land.

*       Check  if  OUTPUT type is ZBA1 .

          IF gv_zba1 EQ abap_true.

            gv_spras = lwa_kna1-spras.
*         Check  if fetched language
*         is maintained in EMI entry
*        ( only English, Spanish, German, French )
            READ TABLE li_status_temp
             WITH KEY criteria = lc_spras
                      sel_low  = gv_spras
             BINARY SEARCH
             TRANSPORTING NO FIELDS.

            IF sy-subrc EQ 0.
              CALL FUNCTION 'CONVERT_SAP_LANG_TO_ISO_LANG'
                EXPORTING
                  input            = gv_spras
                IMPORTING
                  output           = lv_spras
                EXCEPTIONS
                  unknown_language = 1
                  OTHERS           = 2.
              IF sy-subrc EQ 0.
                fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zlanguage_code = lv_spras.
*&-->Begin of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
                gv_langu1 = lv_spras.
*&<--End of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
              ENDIF. " IF sy-subrc EQ 0
            ELSE. " ELSE -> IF sy-subrc EQ 0
              gv_spras = lc_english.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF gv_zba1 EQ abap_true
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lv_sold_to IS NOT INITIAL

*    END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

    ENDIF. " IF sy-subrc EQ 0
*&-->Begin of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
*    gv_langu1 = gv_spras.
*&<--End of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
* <--- End of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*   Freight Value
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_freight.
    IF sy-subrc EQ 0.
      lv_freight_header = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0
*   Freight details:
    fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zfreight_text = lv_freight_header.
* <--- End of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*   Order date
    fp_structure_out-purchase_order_confirmation-message_header-creation_date_time = fp_header-audat.

*   BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
    lv_date2 = fp_structure_out-purchase_order_confirmation-message_header-creation_date_time.

*   Check if sales org is not  1000, 1020, or  1103
    READ TABLE li_status_temp ASSIGNING <lfs_status>
    WITH KEY criteria = lc_vkorg_date
    sel_low = lv_vkorg
    BINARY SEARCH.
    IF sy-subrc NE 0.

*     if not date format will be DD-MMM-YYYY ,where MMM is in sold to country language
      CALL FUNCTION 'ZDEV_DATE_FORMAT'
        EXPORTING
          i_date       = lv_date2
          i_format     = fp_dateformat
          i_langu      = gv_spras
        IMPORTING
          e_date_final = lv_date_f.
      IF lv_date_f IS NOT INITIAL.
        fp_structure_out-purchase_order_confirmation-message_header-creation_date_time  = lv_date_f.
      ENDIF. " IF lv_date_f IS NOT INITIAL
      CLEAR :lv_date2,
      lv_date_f.
    ELSE. " ELSE -> IF sy-subrc NE 0
*   END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*   BEGIN OF DELETE FOR D3_OTC_IDD_0167 BY NGARG
*      IF fp_structure_out-purchase_order_confirmation-message_header-creation_date_time IS NOT INITIAL.
*        lv_date = fp_structure_out-purchase_order_confirmation-message_header-creation_date_time.
*        lv_year = lv_date+2(2).
*        lv_month = lv_date+4(2).
*        lv_day = lv_date+6(2).
*        CONCATENATE lv_month lv_day lv_year
*        INTO fp_structure_out-purchase_order_confirmation-message_header-creation_date_time
*        SEPARATED BY lc_slash.
*      ENDIF. " IF fp_structure_out-purchase_order_confirmation-message_header-creation_date_time IS NOT INITIAL
*      CLEAR: lv_date,
*      lv_month,
*      lv_year,
*      lv_day.
*   END OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

*   BEGIN OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG

*       if yes then date will be format of DD-MMM-YY
      lv_dateformat =  <lfs_status>-sel_high.
      CALL FUNCTION 'ZDEV_DATE_FORMAT'
        EXPORTING
          i_date       = lv_date2
          i_format     = lv_dateformat
        IMPORTING
          e_date_final = lv_date_f.
      IF lv_date_f IS NOT INITIAL.
        fp_structure_out-purchase_order_confirmation-message_header-creation_date_time  = lv_date_f.
      ENDIF. " IF lv_date_f IS NOT INITIAL
      CLEAR: lv_date2,
      lv_date_f.
    ENDIF. " IF sy-subrc NE 0
*   END OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*For Defect#6837
*If sold to language is neither EN, DE, FR or ES, default language EN
*    should apply (without table TVSBT check)
    CLEAR:
         lv_flag_set,
         gv_d3_flag,
         lv_flag_skip.
*Check if sales org is not  1000, 1020, or  1103
*Check if sales org is not  1000, 1020, or  1103
    READ TABLE li_status_temp ASSIGNING <lfs_status> WITH KEY
                         criteria = lc_vkorg_date
                         sel_low = lv_vkorg
                         BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL.
      gv_d3_flag = abap_true.
*Check  if fetched language is maintained in EMI entry
* ( only English, Spanish, German, French )
      READ TABLE li_status_temp TRANSPORTING NO FIELDS WITH KEY
                           criteria = lc_spras
                           sel_low  = fp_nast-spras
                           BINARY SEARCH.
      IF sy-subrc IS NOT INITIAL.
        lv_flag_set =  abap_true.
        gv_spras    = c_english.
      ENDIF. " IF sy-subrc IS NOT INITIAL
    ENDIF. " IF sy-subrc IS NOT INITIAL

**If ORG is of D2, then fetch from TVSBT.
* ---> Begin of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
***When only D3 flag is not set, then fetch shipping condition from TVSBT
    IF gv_d3_flag EQ abap_false.
* ---> End of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
* ---> Begin of Delete for D3_OTC_IDD_0167_CR#301 by MGARG
*    IF lv_flag_set EQ abap_false.
* ---> End of Delete for D3_OTC_IDD_0167_CR#301 by MGARG

*&--Fetch Route/Shipping Conditions: Texts
      SELECT SINGLE vsbed vtext "Description of the shipping conditions
               INTO (fp_header-vsbed,fp_header-route)
               FROM tvsbt       " Shipping Conditions: Texts
              WHERE spras = fp_nast-spras
                AND vsbed = lv_vsbed.
      IF sy-subrc EQ 0.
        lv_flag_skip =  abap_true.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF gv_d3_flag EQ abap_false

* ---> Begin of Delete for D3_OTC_IDD_0167_CR#301 by MGARG
*    IF  lv_flag_set EQ abap_true OR
*        lv_flag_skip EQ abap_true.
* ---> End of Delete for D3_OTC_IDD_0167_CR#301 by MGARG
* ---> Begin of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
    IF  gv_d3_flag = abap_true OR
        lv_flag_skip EQ abap_true.
* ---> End of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

* ---> Begin of Delete for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
**&--Fetch Route/Shipping Conditions: Texts
*    SELECT SINGLE vsbed vtext "Description of the shipping conditions
*             INTO (fp_header-vsbed,fp_header-route)
*             FROM tvsbt       " Shipping Conditions: Texts
*            WHERE spras = fp_nast-spras
*              AND vsbed = lv_vsbed.
*    IF sy-subrc EQ 0.
* ---> End of Delete for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
**********************************************************************
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*Shipping Condition
*   BEGIN OF DELETE FOR DEFECT#3931 BY NGARG

*      fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zshipping_condition = fp_header-route.
*   BEGIN OF DELETE FOR DEFECT#3931 BY NGARG

* <--- End of Change for D2_OTC_IDD_0167,Defect #3124 by NSAXENA
*&--Fetch Sales Document: Partner data
      li_vbpa[] = fp_vbpa[].
* ---> Begin of Delete for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*      IF sy-subrc = 0.
* ---> End of Delete for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
      li_vbpa_tmp[] = li_vbpa[].
      SORT li_vbpa_tmp BY adrnr.
      DELETE ADJACENT DUPLICATES FROM li_vbpa_tmp COMPARING adrnr.
* Begin of Change for INC0485087-01
      IF li_vbpa_tmp[] IS NOT INITIAL.
* END of Change for INC0485087-01
*&--Get all address correspoding to partner data
        SELECT addrnumber "Address No.              "#EC NEEDED
               date_from  " Valid-from date - in current Release only 00010101 possible
               nation     " Version ID for International Addresses
               name1      " Name 1
               name2      " Name 2
               name3      " Name 3
               name4      " Name 4
               city1      " City
               city2      " District
               post_code1 " City postal code
               post_code2 " PO Box Postal Code
               po_box     " PO Box
               street     " Street
               house_num1 " House No.
               house_num2 " House number supplement
               str_suppl1 " Street 2
               str_suppl2 " Street 3
               str_suppl3 " Street 4
               building   " Building (Number or Code)
               floor      " Floor in building
               roomnumber " Room or Appartment Number
               country    " Country Key
               region     " Region (State, Province, County)
               tel_number " First telephone no.: dialling code+number
          INTO TABLE li_address
          FROM adrc       " Addresses (Business Address Services)
           FOR ALL ENTRIES IN li_vbpa_tmp
         WHERE addrnumber = li_vbpa_tmp-adrnr.
        IF sy-subrc = 0.
*Delete address lines where the valid date is greater then current date
          DELETE li_address WHERE date_from GT sy-datum.
          SORT li_address BY addrnumber.
          DELETE ADJACENT DUPLICATES FROM li_address COMPARING addrnumber.


          SELECT  addrnumber " Address number
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
                  persnumber
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
                   date_from                           " Valid-from date - in current Release only 00010101 possible
                   smtp_addr                           "E-Mail Address
                   INTO TABLE li_email
                   FROM adr6                           " E-Mail Addresses (Business Address Services)
                  FOR ALL ENTRIES IN li_vbpa_tmp
                 WHERE addrnumber = li_vbpa_tmp-adrnr. "Address number
          IF sy-subrc EQ 0.
            DELETE li_email WHERE date_from GT sy-datum.
* ---> Begin of Delete for D3_OTC_IDD_0167_Defect#8215 by MGARG
*          SORT li_email BY addrnumber.
*          DELETE ADJACENT DUPLICATES FROM li_email COMPARING addrnumber.
* ---> End of Delete for D3_OTC_IDD_0167_Defect#8215 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
*** Sort table with addressnumber and person number.
            SORT li_email BY addrnumber persnumber.
            DELETE ADJACENT DUPLICATES FROM li_email COMPARING addrnumber persnumber.
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG

          ENDIF. " IF sy-subrc EQ 0
*&--Read tabel for the condition Partner fucntion equals to CP.
*Since we are reading the Contact person partner function with constant value there is no need of binary search,
*Hence please ignore the binary search for next statement.

          READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact. " for PARVW=CP
          IF sy-subrc EQ 0.
* --->Begin of Insert for D2_OTC_IDD_0167,Defect #4414 by NSAXENA
*Checking if the email id is maintained for this partner function (AP)or not.
*If the email id is maintained, then proceed else directly go to the another contact perosn- partner function(ZA).
            READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
                                                               persnumber = <lfs_vbpa>-adrnp
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
                                                                BINARY SEARCH.
            IF sy-subrc = 0.
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4414 by NSAXENA
              IF NOT <lfs_email>-date_from GT sy-datum.
                fp_contact_addr-smtp_addr = <lfs_email>-smtp_addr.
                lwa_email_id-value = fp_contact_addr-smtp_addr.
                CONDENSE lwa_email_id-value.
                APPEND lwa_email_id TO li_email_id.
                lx_recipient_party-contact_person-email_uri = li_email_id[].
              ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
*&--Read Contact Person Address details
              READ TABLE li_address ASSIGNING <lfs_addr>
                                 WITH KEY addrnumber = <lfs_vbpa>-adrnr "Address number
                                                          BINARY SEARCH.
              IF sy-subrc = 0.
                fp_contact_addr = <lfs_addr>.
*telephone number
                lwa_phone_number-subscriber_id =  fp_contact_addr-tel_number.
                CONDENSE lwa_phone_number-subscriber_id.
                APPEND lwa_phone_number TO li_phone_number.
                lx_recipient_party-contact_person-phone_number = li_phone_number[].
*name
                lwa_organisation_name = fp_contact_addr-name1.
                CONDENSE lwa_organisation_name.
                APPEND lwa_organisation_name TO li_org_name .
                lx_recipient_party-contact_person-organisation_formatted_name = li_org_name[].
              ENDIF. " IF sy-subrc = 0
*    BEGIN OF DELETE FOR D3_OTC_IDD_0167 by NGARG
*            ELSE. " ELSE -> IF sy-subrc = 0
*
** ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4414 by NSAXENA
*********If partner function is mainatined but email id is not maintained for AP the go for the ZA partner function.
*********Below code is the previous code only we have added it in if else condition to capture the cases.
*
**&--Read tabel for the condition Partner fucntion equals to ZA.
**Since we are reading the Contact person partner function with constant value there is no need of binary search,
**Hence please ignore the binary search for next statement.
*              READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact_other. "For PARVW=ZA
*
*              IF sy-subrc EQ 0.
**               READ TABLE li_email ASSIGNING <lfs_email> with key addrnumber = <lfs_vbpa>-adrnr.
**          if sy-subrc eq 0.
**&--Read Contact Person Address details
*                READ TABLE li_address ASSIGNING <lfs_addr>
*                                  WITH KEY addrnumber = <lfs_vbpa>-adrnr "Address number
*                                  BINARY SEARCH.
*                IF sy-subrc = 0.
*                  fp_contact_addr = <lfs_addr>.
**telephone number
*                  lwa_phone_number-subscriber_id =  fp_contact_addr-tel_number.
*                  CONDENSE  lwa_phone_number-subscriber_id.
*                  APPEND lwa_phone_number TO li_phone_number.
*                  lx_recipient_party-contact_person-phone_number = li_phone_number[].
**Name1
*                  lwa_organisation_name = fp_contact_addr-name1.
*                  CONDENSE lwa_organisation_name.
*                  APPEND lwa_organisation_name TO li_org_name .
*                  lx_recipient_party-contact_person-organisation_formatted_name = li_org_name[].
**&--Fetch Contact Person E-Mail Address
*                  READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
*                                                      BINARY SEARCH.
*                  IF sy-subrc EQ 0.
*                    IF NOT <lfs_email>-date_from GT sy-datum.
*                      fp_contact_addr-smtp_addr = <lfs_email>-smtp_addr.
*                      lwa_email_id-value = fp_contact_addr-smtp_addr.
*                      CONDENSE lwa_email_id-value.
*                      APPEND lwa_email_id TO li_email_id.
*                      lx_recipient_party-contact_person-email_uri = li_email_id[].
*                    ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
*                  ENDIF. " IF sy-subrc EQ 0
*                ENDIF. " IF sy-subrc = 0
*              ENDIF. " IF sy-subrc EQ 0
*    END OF DELETE FOR D3_OTC_IDD_0167 by NGARG
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* gv_partner will be populated if AP partner contact email id is present
              gv_partner = lc_contact.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            ENDIF. " IF sy-subrc = 0
********If partner function is not mainatined then check for the ZA partner function.
********Below code is the previous code only we have added it in if else condition to capture the cases.
*         BEGIN OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

*          ELSE. " ELSE -> IF sy-subrc EQ 0
*         END OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

*         BEGIN OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG
            APPEND lx_recipient_party TO li_recipient_party.
            CLEAR  : lx_recipient_party ,
                     li_email_id[],
                     lwa_email_id,
                     li_phone_number[],
                     lwa_phone_number,
                     lwa_organisation_name,
                     li_org_name[].
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*          gv_partner = lc_contact.
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
          ENDIF. " IF sy-subrc EQ 0

*         Either the output type is ZBA1 or if CP partner is not maintained
*         then only fetch ZA partner details
          IF gv_zba1    EQ abap_true
          OR gv_partner IS INITIAL.
*         END OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG

*&--Read tabel for the condition Partner fucntion equals to ZA.
*Since we are reading the Contact person partner function with constant value there is no need of binary search,
*Hence please ignore the binary search for next statement.
            READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact_other. "For PARVW=ZA

            IF sy-subrc EQ 0.
*&--Read Contact Person Address details
              READ TABLE li_address ASSIGNING <lfs_addr>
                                WITH KEY addrnumber = <lfs_vbpa>-adrnr "Address number
                                BINARY SEARCH.
              IF sy-subrc = 0.
                fp_contact_addr = <lfs_addr>.
*telephone number
                lwa_phone_number-subscriber_id =  fp_contact_addr-tel_number.
                CONDENSE  lwa_phone_number-subscriber_id.
                APPEND lwa_phone_number TO li_phone_number.
                lx_recipient_party-contact_person-phone_number = li_phone_number[].
*Name1
                lwa_organisation_name = fp_contact_addr-name1.
                CONDENSE lwa_organisation_name.
                APPEND lwa_organisation_name TO li_org_name .
                lx_recipient_party-contact_person-organisation_formatted_name = li_org_name[].
*&--Fetch Contact Person E-Mail Address
                READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
                                                                  persnumber = <lfs_vbpa>-adrnp
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8215 by MGARG
                                                    BINARY SEARCH.
                IF sy-subrc EQ 0.
                  IF NOT <lfs_email>-date_from GT sy-datum.
                    fp_contact_addr-smtp_addr = <lfs_email>-smtp_addr.
                    lwa_email_id-value = fp_contact_addr-smtp_addr.

                    CONDENSE lwa_email_id-value.
                    APPEND lwa_email_id TO li_email_id.
                    lx_recipient_party-contact_person-email_uri = li_email_id[].

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* gv_partner2 will be populated if ZA partner contact email id is present
                    gv_partner2 =  lc_contact_other.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                  ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF sy-subrc = 0
*BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*            gv_partner2 =  lc_contact_other.
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            ENDIF. " IF sy-subrc EQ 0
*END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

          ENDIF. " IF gv_zba1 EQ abap_true
*           BEGIN OF DELETE FOR D3_OTC_IDD_0167 by NGARG
*          ENDIF. " IF sy-subrc EQ 0
*          END OF DELETE FOR D3_OTC_IDD_0167 by NGARG
          CLEAR: lwa_email_id,
                 lwa_organisation_name,
                 lwa_phone_number.
          REFRESH: li_org_name[],
                   li_email_id[],
                   li_phone_number[].
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4414 by NSAXENA
*       If Contact Person Details are not maintained,
*       Get the Email ID & Telephone Number of customer

          IF fp_contact_addr-name1 IS INITIAL.
*         Get the Address Numbder of Customer from KNA1 table
            SELECT SINGLE name1 adrnr " Address
              INTO (lv_name1,lv_adrnr)
              FROM kna1               " General Data in Customer Master
              WHERE kunnr = fp_nast-parnr.
            IF sy-subrc EQ 0.
              IF lv_name1 IS NOT INITIAL.
                fp_contact_addr-name1 = lv_name1.
                lwa_organisation_name = fp_contact_addr-name1.
                CONDENSE lwa_organisation_name.
                APPEND lwa_organisation_name TO li_org_name .
                lx_recipient_party-contact_person-organisation_formatted_name = li_org_name[].
              ENDIF. " IF lv_name1 IS NOT INITIAL
              IF lv_adrnr IS NOT INITIAL.
*           Get Telephone Number of Customer
                SELECT  tel_number " First telephone no.: dialling code+number
                  UP TO 1 ROWS
                  INTO fp_contact_addr-tel_number
                  FROM adrc        " Addresses (Business Address Services)
                  WHERE addrnumber = lv_adrnr.
                ENDSELECT.
                IF sy-subrc EQ 0.
                  IF fp_contact_addr-tel_number IS NOT INITIAL.
                    lwa_phone_number-subscriber_id =  fp_contact_addr-tel_number.
                    CONDENSE lwa_phone_number-subscriber_id.
                    APPEND lwa_phone_number TO li_phone_number.
                    lx_recipient_party-contact_person-phone_number = li_phone_number[].
                  ENDIF. " IF fp_contact_addr-tel_number IS NOT INITIAL
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF lv_adrnr IS NOT INITIAL
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF fp_contact_addr-name1 IS INITIAL
        ENDIF. " IF sy-subrc = 0
* ---> * Begin of Change for INC0485087-01
      ENDIF. " IF li_vbpa_tmp[] IS NOT INITIAL
* ---> * End of Change for INC0485087-01
* ---> Begin of Delete for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*      ENDIF. " IF sy-subrc = 0
* ---> End of Delete for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
    ENDIF. " IF gv_d3_flag = abap_true OR

*BEGIN OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

*  APPEND lx_recipient_party TO li_recipient_party.
*END OF DELETE FOR D3_OTC_IDD_0167 BY NGARG
*BEGIN  OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

    APPEND lx_recipient_party TO li_recipient_party2[].
*END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG


    fp_structure_out-purchase_order_confirmation-message_header-recipient_party = li_recipient_party[].
    CLEAR: lwa_organisation_name,
   lwa_phone_number,
   lwa_email_id.
    REFRESH : li_org_name[],
    li_email_id[],
    li_phone_number[].

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    REFRESH li_vbpa_tmp.
    IF li_vbpa IS NOT INITIAL.
*&--Fetching KNA1 to get GLN number.
      li_vbpa_tmp[] = li_vbpa[].
      SORT li_vbpa_tmp BY kunnr.
      DELETE ADJACENT DUPLICATES FROM  li_vbpa_tmp COMPARING kunnr.

      SELECT kunnr " Customer Number
             bbbnr " International location number  (part 1)
             bbsnr " International location number (Part 2)
      FROM kna1  " General Data in Customer Master
      INTO TABLE li_kna1
      FOR ALL ENTRIES IN li_vbpa_tmp
      WHERE kunnr = li_vbpa_tmp-kunnr.
      IF sy-subrc IS INITIAL.
        SORT li_kna1 BY kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

*&--Read ship to customer Address no.with parvw = WE
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_ship_to.
    IF sy-subrc = 0.
*&--Populate Ship-to-Party Number
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-kunnr
        IMPORTING
          output = lv_ship_no.

      fp_structure_out-purchase_order_confirmation-purchase_order-vendor_party-internal_id-value = lv_ship_no.
*&--Read ship to customer Address details

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*** CR#289 Changes: Address format
*** For D3, Ship-To address should be picked by using Function module.
      IF gv_d3_flag = abap_true.
        CLEAR: lv_buildline.
*** Get Building,Floor and Roomnumber, if any.Then Concatenate these values.
        READ TABLE li_address ASSIGNING <lfs_addr>
                     WITH KEY addrnumber = <lfs_vbpa>-adrnr
                     BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF <lfs_addr>-building   IS NOT INITIAL OR
             <lfs_addr>-roomnumber IS NOT INITIAL  OR
            <lfs_addr>-floor       IS NOT INITIAL.
            CONCATENATE <lfs_addr>-building <lfs_addr>-roomnumber <lfs_addr>-floor
            INTO lv_buildline SEPARATED BY lc_comma.
            CONDENSE lv_buildline.
          ENDIF. " IF <lfs_addr>-building IS NOT INITIAL OR
        ENDIF. " IF sy-subrc EQ 0

*** Calling FM ADDRESS_INTO_PRINTFORM
        PERFORM f_address_byfm USING <lfs_vbpa>-adrnr
                                     lv_buildline
                            CHANGING lwa_main_address.

        APPEND lwa_main_address TO li_main_address.
        fp_structure_out-purchase_order_confirmation-purchase_order-vendor_party-address = li_main_address[].
        CLEAR lwa_main_address.
        REFRESH: li_main_address.
      ENDIF. " IF gv_d3_flag = abap_true

*** Other than D3, Execute existing code
      IF gv_d3_flag = abap_false.
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

        READ TABLE li_address ASSIGNING <lfs_addr>
                          WITH KEY addrnumber = <lfs_vbpa>-adrnr.

        IF sy-subrc EQ 0.
          lv_org_name1 = <lfs_addr>-name1.
          lv_org_name2 = <lfs_addr>-name2.
          lv_org_name3 = <lfs_addr>-name3.
          lv_org_name4 = <lfs_addr>-name4.
          CONCATENATE lv_org_name1 lv_org_name2 lv_org_name3 lv_org_name4 INTO lwa_organisation_name.
          APPEND lwa_organisation_name TO li_org_name.
          lwa_physical_address-building_id = <lfs_addr>-building.
          lwa_physical_address-floor_id = <lfs_addr>-floor.
          lwa_physical_address-room_id = <lfs_addr>-roomnumber.
          lwa_physical_address-additional_house_id = <lfs_addr>-house_num2.
          lwa_physical_address-house_id = <lfs_addr>-house_num1.
          lwa_physical_address-street_name = <lfs_addr>-street.
          lwa_suffix_name = <lfs_addr>-str_suppl1.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
          IF lwa_physical_address-building_id IS INITIAL OR
             lwa_physical_address-floor_id IS INITIAL OR
             lwa_physical_address-room_id IS INITIAL.
            lwa_prefix_name = <lfs_addr>-str_suppl2.
            APPEND lwa_prefix_name TO li_prefix_name.
          ENDIF. " IF lwa_physical_address-building_id IS INITIAL OR
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
          APPEND lwa_suffix_name TO li_suffix_name.
          lwa_physical_address-city_name = <lfs_addr>-city1.
          lwa_physical_address-region_code-value = <lfs_addr>-region.
          lwa_physical_address-street_postal_code = <lfs_addr>-post_code1.
          lwa_physical_address-country_code = <lfs_addr>-country.
          lwa_physical_address-pobox_id = <lfs_addr>-po_box.
          lwa_physical_address-pobox_postal_code = <lfs_addr>-post_code2.
          lwa_physical_address-street_prefix_name = li_prefix_name[].
          lwa_physical_address-street_suffix_name = li_suffix_name[].
          lwa_main_address-physical_address = lwa_physical_address.
          lwa_main_address-organisation_formatted_name = li_org_name[].
          APPEND lwa_main_address TO li_main_address.
          fp_structure_out-purchase_order_confirmation-purchase_order-vendor_party-address = li_main_address[].
          CLEAR: lwa_physical_address,
                 lwa_organisation_name,
                 lwa_suffix_name.
        ENDIF. " IF sy-subrc EQ 0

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
      ENDIF. " IF gv_d3_flag = abap_false
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*Ship to Attention to text
      CLEAR: lv_name,
             lwa_physical_address,
             lwa_organisation_name,
             lwa_suffix_name.

      REFRESH: li_lines[],
                li_suffix_name[],
                li_org_name[],
                li_main_address[].
      lv_name = fp_vbeln.

* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
      READ TABLE i_name ASSIGNING <fs_name> WITH KEY id = lc_id_cup
                                            BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_langu1 = c_english. "English language
      ELSE.
        lv_langu1 = <fs_name>-lang.
      ENDIF. " IF sy-subrc NE 0
*lv_langu1 = fp_nast-spras.
*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_cup
                               lv_langu1
                               lv_name
                               lc_object.
      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
      IF sy-subrc EQ 0.
        MOVE <lfs_lines>-tdline TO lv_cup_val.
      ENDIF. " IF sy-tabix EQ 1
      UNASSIGN <lfs_lines>.
      REFRESH: li_lines[].

      READ TABLE i_name ASSIGNING <fs_name> WITH KEY id = lc_id_cig
                                            BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_langu1 = c_english. "English language
      ELSE.
        lv_langu1 = <fs_name>-lang.
      ENDIF. " IF sy-subrc NE 0

*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_cig
                               lv_langu1
                               lv_name
                               lc_object.
      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
      IF sy-subrc EQ 0.
        MOVE <lfs_lines>-tdline TO lv_cig_val.
      ENDIF. " IF sy-tabix EQ 1
      UNASSIGN <lfs_lines>.
      REFRESH: li_lines[].

*     CUP
      IF lv_cup_val IS NOT INITIAL.
        fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zcup = lv_cup_val.
      ENDIF.
*     CIG
      IF lv_cig_val IS NOT INITIAL.
        fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zcig = lv_cig_val.
      ENDIF.

* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
      READ TABLE i_name ASSIGNING <fs_name> WITH KEY id = lc_id_0002
                                                       BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_langu1 = c_english. "English language
      ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

*To Read the text with id 0002
*      Begin of Insert for defect#3102 by NGARG.
      IF gv_spras IS NOT INITIAL.
        lv_langu1 = gv_spras.
      ENDIF. " IF gv_spras IS NOT INITIAL
*      End of Insert for defect#3102 by NGARG.

*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_0002
                               lv_langu1
                               lv_name
                               lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*For Defect#6837
* If no text maintained for sold-to-langu(other than E), then read with
* EN language.
      IF li_lines IS INITIAL AND lv_langu1 NE c_english.

*** If sales Org belongs to D3
        IF gv_d3_flag = abap_true.
          lv_langu1 = c_english.

*Get text subroutine.
          PERFORM f_get_text TABLES li_lines
                              USING lc_id_0002
                                   lv_langu1
                                   lv_name
                                   lc_object.
        ENDIF. " IF gv_d3_flag = abap_true
      ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*      CALL FUNCTION 'READ_TEXT'
*        EXPORTING
*          id                      = lc_id_0002 " Id
*          language                = lv_langu1  "Lang
*          name                    = lv_name    "Sales order number
*          object                  = lc_object  "Object id
*        TABLES
*          lines                   = li_lines   "Text lines
*        EXCEPTIONS
*          id                      = 1
*          language                = 2
*          name                    = 3
*          not_found               = 4
*          object                  = 5
*          reference_check         = 6
*          wrong_access_to_archive = 7
*          OTHERS                  = 8.
      IF sy-subrc = 0.
        LOOP AT li_lines ASSIGNING <lfs_lines>.
          MOVE <lfs_lines>-tdline TO lv_ship_attention.
* Begin of Defcet 9877
*          IF sy-tabix EQ 1.
**           Begin of Insert for Defect#2008 by NGARG
*
** ---> Begin of Delete for D3_OTC_IDD_0167_Defect#6807 by MGARG
***We need to read Text on the basis of lv_langu1.
**            READ TEXTPOOL sy-repid INTO li_textpool LANGUAGE gv_spras.
** ---> End of Delete for D3_OTC_IDD_0167_Defect#6807 by MGARG
** ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6807 by MGARG
*            READ TEXTPOOL sy-repid INTO li_textpool LANGUAGE lv_langu1.
** ---> End of Insert for D3_OTC_IDD_0167_Defect#6807 by MGARG
*
*            IF sy-subrc EQ 0.
*              LOOP AT li_textpool ASSIGNING <lfs_textpool>.
*                IF <lfs_textpool>-id EQ lc_i
*                  AND <lfs_textpool>-key EQ lc_008.
*                  CONCATENATE <lfs_textpool>-entry lv_ship_attention INTO lv_ship_att SEPARATED BY space.
*
*                ENDIF. " IF <lfs_textpool>-id EQ lc_i
*              ENDLOOP. " LOOP AT li_textpool ASSIGNING <lfs_textpool>
*            ENDIF. " IF sy-subrc EQ 0
**           End of Insert for Defect#2008 by NGARG
**           Begin of Delete Insert for Defect#2008 by NGARG
**                CONCATENATE 'Attention To:'(008) lv_ship_attention INTO lv_ship_att SEPARATED BY space.
**           End of Delete Insert for Defect#2008 by NGARG
*
*          ELSE. " ELSE -> IF sy-tabix EQ 1
* End of Defcet 9877
          CONCATENATE lv_ship_att lv_ship_attention INTO lv_ship_att SEPARATED BY space.
*          ENDIF. " IF sy-tabix EQ 1    " Defcet 9877
        ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
      ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*  Populate the GLN value for Ship to address
      CLEAR lwa_kna1_gln.
      READ TABLE li_kna1 INTO lwa_kna1_gln
       WITH KEY kunnr = <lfs_vbpa>-kunnr
       BINARY SEARCH.
      IF sy-subrc =  0.
        CONDENSE: lwa_kna1_gln-bbbnr,
                  lwa_kna1_gln-bbsnr.
        IF lwa_kna1_gln-bbbnr IS NOT INITIAL AND lwa_kna1_gln-bbsnr IS NOT INITIAL.
* ---> Begin of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*          CONCATENATE lwa_kna1_gln-bbbnr  lwa_kna1_gln-bbsnr
*          INTO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_ship_to.
*        ELSEIF lwa_kna1_gln-bbsnr IS NOT INITIAL.
*          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_ship_to = lwa_kna1_gln-bbsnr.
*        ELSEIF lwa_kna1_gln-bbbnr IS NOT INITIAL.
*          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_ship_to = lwa_kna1_gln-bbbnr.
* <--- End of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
          CONCATENATE lwa_kna1_gln-bbbnr  lwa_kna1_gln-bbsnr
          INTO lv_z01otc_zgln_ship_to.
        ELSEIF lwa_kna1_gln-bbsnr IS NOT INITIAL.
          lv_z01otc_zgln_ship_to = lwa_kna1_gln-bbsnr.
        ELSEIF lwa_kna1_gln-bbbnr IS NOT INITIAL.
          lv_z01otc_zgln_ship_to = lwa_kna1_gln-bbbnr.
* <--- End of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
        ENDIF.
      ENDIF.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
    ENDIF. " IF sy-subrc = 0
    UNASSIGN <lfs_lines>.
    fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zship_to_attention = lv_ship_att.

*&--Read sold to customer Address no. with parvw = AG
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_sold_to.
    IF sy-subrc = 0.
*&--Populate sold-to-Party Number
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-kunnr
        IMPORTING
          output = lv_sold_no.

      fp_structure_out-purchase_order_confirmation-purchase_order-buyer_party-internal_id-value = lv_sold_no.

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*** CR#289 Changes: Address format
** For D3 only.
      IF gv_d3_flag = abap_true.
        CLEAR: lv_buildline.
*** Get Building,Floor and Roomnumber, if any.Then concatenate these values
        READ TABLE li_address ASSIGNING <lfs_addr>
                     WITH KEY addrnumber = <lfs_vbpa>-adrnr.
        IF sy-subrc EQ 0.
          IF <lfs_addr>-building   IS  NOT INITIAL OR
             <lfs_addr>-roomnumber IS NOT INITIAL  OR
             <lfs_addr>-floor      IS NOT INITIAL.
            CONCATENATE <lfs_addr>-building  <lfs_addr>-roomnumber <lfs_addr>-floor
            INTO lv_buildline SEPARATED BY lc_comma.
            CONDENSE lv_buildline.
          ENDIF. " IF <lfs_addr>-building IS NOT INITIAL OR
        ENDIF. " IF sy-subrc EQ 0

** Calling FM for adress formating.
        PERFORM f_address_byfm USING <lfs_vbpa>-adrnr
                                     lv_buildline
                            CHANGING lwa_main_address.

        APPEND lwa_main_address TO li_main_address.
        fp_structure_out-purchase_order_confirmation-purchase_order-buyer_party-address = li_main_address[].
        CLEAR lwa_main_address.
        REFRESH: li_main_address.

      ENDIF. " IF gv_d3_flag = abap_true

**Other than D3.
      IF gv_d3_flag  = abap_false.
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*&--Read Ship to customer Address details
        READ TABLE li_address ASSIGNING <lfs_addr>
                          WITH KEY addrnumber = <lfs_vbpa>-adrnr.
        IF sy-subrc EQ 0.
          lv_org_name1 = <lfs_addr>-name1. "name
          lv_org_name2 = <lfs_addr>-name2. "name
          lv_org_name3 = <lfs_addr>-name3. "name
          lv_org_name4 = <lfs_addr>-name4. "name
          CONCATENATE lv_org_name1 lv_org_name2 lv_org_name3 lv_org_name4 INTO lwa_organisation_name.
          APPEND lwa_organisation_name TO li_org_name.

          lwa_physical_address-building_id = <lfs_addr>-building. "building
          lwa_physical_address-floor_id    = <lfs_addr>-floor. "floor
          lwa_physical_address-room_id     = <lfs_addr>-roomnumber. "room number
          lwa_physical_address-additional_house_id = <lfs_addr>-house_num2. "house number
          lwa_physical_address-house_id    = <lfs_addr>-house_num1. "house number
          lwa_physical_address-street_name = <lfs_addr>-street. "street
          lwa_suffix_name = <lfs_addr>-str_suppl1. "string supplier
          APPEND lwa_suffix_name TO li_suffix_name.

          lwa_physical_address-city_name         = <lfs_addr>-city1. "city
          lwa_physical_address-region_code-value = <lfs_addr>-region. "region
          lwa_physical_address-street_postal_code = <lfs_addr>-post_code1. "post code
          lwa_physical_address-country_code       = <lfs_addr>-country. "country
          lwa_physical_address-pobox_id           = <lfs_addr>-po_box. "po box
          lwa_physical_address-pobox_postal_code  = <lfs_addr>-post_code2. "post code
          lwa_physical_address-street_suffix_name = li_suffix_name[].
          lwa_main_address-physical_address       = lwa_physical_address.
          lwa_main_address-organisation_formatted_name = li_org_name[].
          APPEND lwa_main_address TO li_main_address.

          fp_structure_out-purchase_order_confirmation-purchase_order-buyer_party-address = li_main_address[].
        ENDIF. " IF sy-subrc EQ 0

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
      ENDIF. " IF gv_d3_flag = abap_false
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
* ---> Begin of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
** ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
**  Populate the GLN value for Sold to address
*      CLEAR lwa_kna1_gln.
*      READ TABLE li_kna1 INTO lwa_kna1_gln
*       WITH KEY kunnr = <lfs_vbpa>-kunnr
*       BINARY SEARCH.
*      IF sy-subrc =  0.
*        CONDENSE: lwa_kna1_gln-bbbnr,
*                  lwa_kna1_gln-bbsnr.
*        IF lwa_kna1_gln-bbbnr IS NOT INITIAL AND lwa_kna1_gln-bbsnr IS NOT INITIAL.
*          CONCATENATE lwa_kna1_gln-bbbnr  lwa_kna1_gln-bbsnr
*          INTO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_sold_to.
*        ELSEIF lwa_kna1_gln-bbsnr IS NOT INITIAL.
*          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_sold_to = lwa_kna1_gln-bbsnr.
*        ELSEIF lwa_kna1_gln-bbbnr IS NOT INITIAL.
*          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_sold_to = lwa_kna1_gln-bbbnr.
*        ENDIF.
*      ENDIF.
** <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* <--- End of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
    ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*Populate the Bill to address details in the proxy structure
*&--Read bill to customer Address no.with parvw = RE
    READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_bill_to.
    IF sy-subrc = 0.
*&--Populate Bill-to-Party Number
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = <lfs_vbpa>-kunnr
        IMPORTING
          output = lv_bill_no.

      fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-internal_id-value = lv_bill_no.
*&--Read bill to customer Address details

*** For D3, Bill-To address should be picked by using Function module.
      IF gv_d3_flag = abap_true.
        CLEAR: lv_buildline.
*** Get Building,Floor and Roomnumber, if any.Then Concatenate these values.
        READ TABLE li_address ASSIGNING <lfs_addr>
                     WITH KEY addrnumber = <lfs_vbpa>-adrnr
                     BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF <lfs_addr>-building   IS NOT INITIAL OR
             <lfs_addr>-roomnumber IS NOT INITIAL  OR
            <lfs_addr>-floor       IS NOT INITIAL.
            CONCATENATE <lfs_addr>-building <lfs_addr>-roomnumber <lfs_addr>-floor
            INTO lv_buildline SEPARATED BY lc_comma.
            CONDENSE lv_buildline.
          ENDIF. " IF <lfs_addr>-building IS NOT INITIAL OR
        ENDIF. " IF sy-subrc EQ 0

*** Calling FM ADDRESS_INTO_PRINTFORM
        PERFORM f_address_byfm USING <lfs_vbpa>-adrnr
                                     lv_buildline
                            CHANGING lwa_main_address.

        APPEND lwa_main_address TO li_main_address.
        fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-address = li_main_address[].
        CLEAR lwa_main_address.
        REFRESH: li_main_address.
      ENDIF. " IF gv_d3_flag = abap_true

*** Other than D3, Execute existing code
      IF gv_d3_flag = abap_false.

        READ TABLE li_address ASSIGNING <lfs_addr>
                          WITH KEY addrnumber = <lfs_vbpa>-adrnr
                          BINARY SEARCH.

        IF sy-subrc EQ 0.
          lv_org_name1 = <lfs_addr>-name1.
          lv_org_name2 = <lfs_addr>-name2.
          lv_org_name3 = <lfs_addr>-name3.
          lv_org_name4 = <lfs_addr>-name4.
          CONCATENATE lv_org_name1 lv_org_name2 lv_org_name3 lv_org_name4 INTO lwa_organisation_name.
          APPEND lwa_organisation_name TO li_org_name.
          lwa_physical_address-building_id = <lfs_addr>-building.
          lwa_physical_address-floor_id = <lfs_addr>-floor.
          lwa_physical_address-room_id = <lfs_addr>-roomnumber.
          lwa_physical_address-additional_house_id = <lfs_addr>-house_num2.
          lwa_physical_address-house_id = <lfs_addr>-house_num1.
          lwa_physical_address-street_name = <lfs_addr>-street.
          lwa_suffix_name = <lfs_addr>-str_suppl1.
          IF lwa_physical_address-building_id IS INITIAL OR
             lwa_physical_address-floor_id IS INITIAL OR
             lwa_physical_address-room_id IS INITIAL.
            lwa_prefix_name = <lfs_addr>-str_suppl2.
            APPEND lwa_prefix_name TO li_prefix_name.
          ENDIF. " IF lwa_physical_address-building_id IS INITIAL OR
          APPEND lwa_suffix_name TO li_suffix_name.
          lwa_physical_address-city_name = <lfs_addr>-city1.
          lwa_physical_address-region_code-value = <lfs_addr>-region.
          lwa_physical_address-street_postal_code = <lfs_addr>-post_code1.
          lwa_physical_address-country_code = <lfs_addr>-country.
          lwa_physical_address-pobox_id = <lfs_addr>-po_box.
          lwa_physical_address-pobox_postal_code = <lfs_addr>-post_code2.
          lwa_physical_address-street_prefix_name = li_prefix_name[].
          lwa_physical_address-street_suffix_name = li_suffix_name[].
          lwa_main_address-physical_address = lwa_physical_address.
          lwa_main_address-organisation_formatted_name = li_org_name[].
          APPEND lwa_main_address TO li_main_address.
          fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-address = li_main_address[].
          CLEAR: lwa_physical_address,
                 lwa_organisation_name,
                 lwa_suffix_name.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF gv_d3_flag = abap_false

*  Populate the GLN value for Bill to address
      CLEAR lwa_kna1_gln.
      READ TABLE li_kna1 INTO lwa_kna1_gln
       WITH KEY kunnr = <lfs_vbpa>-kunnr
       BINARY SEARCH.
      IF sy-subrc =  0.
        CONDENSE: lwa_kna1_gln-bbbnr,
                  lwa_kna1_gln-bbsnr.
        IF lwa_kna1_gln-bbbnr IS NOT INITIAL AND lwa_kna1_gln-bbsnr IS NOT INITIAL.
          CONCATENATE lwa_kna1_gln-bbbnr  lwa_kna1_gln-bbsnr
          INTO fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_bill_to.
        ELSEIF lwa_kna1_gln-bbsnr IS NOT INITIAL.
          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_bill_to = lwa_kna1_gln-bbsnr.
        ELSEIF lwa_kna1_gln-bbbnr IS NOT INITIAL.
          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_bill_to = lwa_kna1_gln-bbbnr.
        ENDIF.

* ---> Begin of Insert for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
*  Populate the GLN value for Ship to address
        IF fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_bill_to NE lv_z01otc_zgln_ship_to.
          fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_ship_to = lv_z01otc_zgln_ship_to.
        ELSE.
          CLEAR fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zgln_ship_to.
        ENDIF.
        CLEAR: lv_z01otc_zgln_ship_to.
* <--- End of Delete for D3 R3 changes for D3_OTC_IDD_0167 by U029267 on 05-Feb-18
      ENDIF.
    ENDIF. " IF sy-subrc = 0
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
  ENDIF. " IF sy-subrc = 0

  CLEAR: lwa_physical_address,
         lwa_organisation_name,
         lwa_suffix_name,
         lv_name.

  REFRESH:  li_lines[],
            li_suffix_name[],
            li_org_name[],
            li_main_address[].
  lv_name = fp_vbeln.

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*To Read text with id Z009.
  READ TABLE i_name ASSIGNING <fs_name> WITH KEY id = lc_id_z009
                                                    BINARY SEARCH.
  IF sy-subrc NE 0.
    lv_langu1 = c_english.
  ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*Begin of Insert for  Defect#3102 by NGARG
  IF gv_spras IS NOT INITIAL.
    lv_langu1 = gv_spras.
  ENDIF. " IF gv_spras IS NOT INITIAL
*End of Insert for  Defect#3102 by NGARG

*To Read the text with id z009
*Get text subroutine.
  PERFORM f_get_text TABLES li_lines
                      USING lc_id_z009
                           lv_langu1
                           lv_name
                           lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
* Defect#6837
  IF li_lines IS INITIAL AND lv_langu1 NE c_english.

*** If sales Org belongs to D3
    IF gv_d3_flag = abap_true.
      lv_langu1 = c_english.

*Get text subroutine(with id z009)
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_z009
                               lv_langu1
                               lv_name
                               lc_object.
    ENDIF. " IF gv_d3_flag = abap_true
  ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      id                      = lc_id_z009 "Id
*      language                = lv_langu1  "Lang
*      name                    = lv_name    "Sales Order number
*      object                  = lc_object  "Object Id
*    TABLES
*      lines                   = li_lines   "Text lines
*    EXCEPTIONS
*      id                      = 1
*      language                = 2
*      name                    = 3
*      not_found               = 4
*      object                  = 5
*      reference_check         = 6
*      wrong_access_to_archive = 7
*      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix EQ 1.
        MOVE <lfs_lines>-tdline TO lv_ord_comments_part1.
      ELSE. " ELSE -> IF sy-tabix EQ 1
        CONCATENATE lv_ord_comments_part1 <lfs_lines>-tdline INTO lv_ord_comments_part1 SEPARATED BY space.
      ENDIF. " IF sy-tabix EQ 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
  UNASSIGN <lfs_lines>.

  CLEAR: lv_name.
  REFRESH: li_lines[].
  lv_name = fp_vbeln.

* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*To Read text with text id Z012.
  READ TABLE i_name ASSIGNING <fs_name> WITH KEY id = lc_id_z012
                                                   BINARY SEARCH.
  IF sy-subrc NE 0.
    lv_langu1 = c_english. "English language
  ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
*To Read the text with id z012
*Begin of Insert for  Defect#3102 by NGARG
  IF gv_spras IS NOT INITIAL.
    lv_langu1 = gv_spras.
  ENDIF. " IF gv_spras IS NOT INITIAL
*End of Insert for  Defect#3102 by NGARG

*Get text subroutine.
  PERFORM f_get_text TABLES li_lines
                      USING lc_id_z012
                           lv_langu1
                           lv_name
                           lc_object.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
* Defect#6837
* If no text maintained for sold-to-langu(other than E), then read with
* EN language.
  IF li_lines IS INITIAL AND lv_langu1 NE c_english.

*** If sales Org belongs to D3
    IF gv_d3_flag = abap_true.
      lv_langu1 = c_english.

*Get text subroutine.
      PERFORM f_get_text TABLES li_lines
                          USING lc_id_z012
                               lv_langu1
                               lv_name
                               lc_object.
    ENDIF. " IF gv_d3_flag = abap_true
  ENDIF. " IF li_lines IS INITIAL AND lv_langu1 NE c_english
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      id                      = lc_id_z012 "Id
*      language                = lv_langu1  "lang
*      name                    = lv_name    "sales order number
*      object                  = lc_object  "Object id
*    TABLES
*      lines                   = li_lines   "Text lines
*    EXCEPTIONS
*      id                      = 1
*      language                = 2
*      name                    = 3
*      not_found               = 4
*      object                  = 5
*      reference_check         = 6
*      wrong_access_to_archive = 7
*      OTHERS                  = 8.
  IF sy-subrc = 0.
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix EQ 1.
        MOVE <lfs_lines>-tdline TO lv_ord_comments_part2.
      ELSE. " ELSE -> IF sy-tabix EQ 1
        CONCATENATE lv_ord_comments_part2 <lfs_lines>-tdline INTO lv_ord_comments_part2 SEPARATED BY space.
      ENDIF. " IF sy-tabix EQ 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc = 0
  UNASSIGN <lfs_lines>.
  IF lv_zzdoctyp IS NOT INITIAL.
*--Begin of changes for SCTASK0764894 Defect# 6476 by mthatha
    fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zdoctyp = lv_zzdoctyp.
*--End of changes for SCTASK0764894 Defect# 6476 by mthatha
*    Begin of change for Defect#4090 by NGARG
*   Pick the description of doc type text from EMI data
    READ TABLE li_status_temp
    ASSIGNING <lfs_status>
    WITH KEY criteria = lc_doctyp
             sel_low = lv_zzdoctyp
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_doctyp = <lfs_status>-sel_high.
    ENDIF. " IF sy-subrc EQ 0
*   End of change for Defect#4090 by NGARG

*    Begin of Delete  for Defect#4090 by NGARG
*Logic not needed any more , will pickup the Doc type text from EMI
*    lv_valpos = lv_zzdoctyp.
**Converting valpos into specific format
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = lv_valpos
*      IMPORTING
*        output = lv_valpos.
*
*    SELECT SINGLE ddtext " Short Text for Fixed Values
*           FROM dd07t    " DD: Texts for Domain Fixed Values (Language-Dependent)
*           INTO lv_doctyp
*           WHERE domname = lc_domname
**      Begin of Delete for defect#3102 by NGARG.
**           AND   ddlanguage = sy-langu
**      End of Delete for defect#3102 by NGARG.
**      Begin of Insert for defect#3102 by NGARG.
*           AND ddlanguage = gv_spras
**      End of Insert for defect#3102 by NGARG.
*
*           AND   as4local =  lc_as4local
*           AND   valpos  = lv_valpos
*           AND   as4vers = lc_cons_0000.
*    IF sy-subrc EQ 0.

*    End of Delete  for Defect#4090 by NGARG
    lv_doctyp_ord = lv_doctyp.
*    Begin of Delete  for Defect#4090 by NGARG

*    ENDIF. " IF sy-subrc EQ 0
*    End of Delete  for Defect#4090 by NGARG

  ENDIF. " IF lv_zzdoctyp IS NOT INITIAL
*Check for Ref text
  IF lv_zzdocref IS NOT INITIAL.
    CONCATENATE 'Ref'(005) lv_zzdocref INTO lv_docref SEPARATED BY space.
*--Begin of changes for SCTASK0764894 Defect# 6476 by mthatha
    fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zdocref = lv_zzdocref.
*--End of changes for SCTASK0764894 Defect# 6476 by mthatha
  ENDIF. " IF lv_zzdocref IS NOT INITIAL
*Check for case ref text
  IF lv_zzcaseref IS NOT INITIAL.
    CONCATENATE 'Case_Reference'(006) lv_zzcaseref INTO lv_caseref SEPARATED BY space.
  ENDIF. " IF lv_zzcaseref IS NOT INITIAL
*Check for order comments part
  IF lv_ord_comments_part1 IS NOT INITIAL.
    lv_ord_1 = lv_ord_comments_part1.
  ENDIF. " IF lv_ord_comments_part1 IS NOT INITIAL
*Check for PROMO text
  IF lv_ord_comments_part2 IS NOT INITIAL.
    CONCATENATE 'Promotion'(001) lv_ord_comments_part2 INTO lv_ord_2 SEPARATED BY space.
  ENDIF. " IF lv_ord_comments_part2 IS NOT INITIAL

*  Begin of Delete for defect#3682 by NGARG
*combine the text for order comments
*  CONCATENATE lv_ord_1 lv_ord_2 lv_doctyp_ord
*         lv_docref lv_caseref INTO lv_ord_comments
*         SEPARATED BY space.
*  CONDENSE lv_ord_comments.
*  End of Delete for defect#3682 by NGARG

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8796  by u029267 on 29-Mar-2019
  IF lv_zzdoctyp = lc_zzdoctyp_08 .

    IF  lv_ord_comments_part2 IS NOT INITIAL.  " Defect 9877
*      CONCATENATE 'Promo #:'(008) lv_ord_comments_part2 INTO lwa_ordertexts-text   " Defect 9877
      CONCATENATE 'Promotion'(001) lv_ord_comments_part2 INTO lwa_ordertexts-text " Defect 9877
     SEPARATED BY space.
    ENDIF.
  ELSE.
* <--- End    of Insert for D3_OTC_IDD_0167_Defect#8796  by u029267 on 29-Mar-2019


*  Begin of Insert for defect#3682 by NGARG
* Build Order comments table
    CONCATENATE
*    Begin of Insert  for Defect#4090 by NGARG
* Append doc type to first line
    lv_doctyp_ord
*    End  of Insert  for Defect#4090 by NGARG
    lv_docref
    lv_caseref
     lv_ord_2
     INTO lwa_ordertexts-text
     SEPARATED BY space.
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8796  by u029267 on 29-Mar-2019
  ENDIF.
* <--- End    of Insert for D3_OTC_IDD_0167_Defect#8796  by u029267 on 29-Mar-2019

  CONDENSE lwa_ordertexts-text.
  IF  lwa_ordertexts-text NE space.
    APPEND lwa_ordertexts TO li_ordertexts.
    CLEAR lwa_ordertexts.
  ENDIF. " IF lwa_ordertexts-text NE space

*  Begin of Delete  for Defect#4090 by NGARG
*  Remove doc type from second line
*  CONCATENATE lv_ord_1
*              lv_doctyp_ord
*  into        lv_ord_comments
*  separated by space.
*  CONDENSE lv_ord_comments.
*  End  of Delete  for Defect#4090 by NGARG
*  Begin of Insert  for Defect#4090 by NGARG

  lv_ord_comments = lv_ord_1.
*  End of Insert  for Defect#4090 by NGARG

  IF lv_ord_comments IS NOT INITIAL.
    lwa_ordertexts-text = lv_ord_comments.
    APPEND lwa_ordertexts TO li_ordertexts.
    CLEAR lwa_ordertexts.
  ENDIF. " IF lv_ord_comments IS NOT INITIAL

* Populate order comments in proxy structure
  CLEAR lv_tabix.
  LOOP AT li_ordertexts ASSIGNING <lfs_ordertexts>.
    lv_tabix = sy-tabix.
    CASE lv_tabix.
*     Fill Header text
      WHEN 1.
        fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zheader_text = <lfs_ordertexts>-text.

*     Fill header text 1
      WHEN 2.
        fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zheader_text1 = <lfs_ordertexts>-text.

      WHEN OTHERS.
    ENDCASE.
  ENDLOOP. " LOOP AT li_ordertexts ASSIGNING <lfs_ordertexts>

  CLEAR : li_ordertexts[].
*  End of Insert for defect#3682 by NGARG

*  Begin of Delete for defect#3682 by NGARG

*Order Comments
*  fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zheader_text = lv_ord_comments.
*  End of Delete for defect#3682 by NGARG

  SELECT SINGLE
                inco1 "Incoterms (Part 1)
                inco2 " Incoterms (Part 2)
                bstkd "Customer purchase order number
           INTO (lv_inco1,fp_header-inco2,fp_header-bstkd)
           FROM vbkd  " Sales Document: Business Data
          WHERE vbeln = fp_vbeln
            AND posnr = lc_posnr.
  IF sy-subrc EQ 0.
*Customer purcahse order  number
    fp_structure_out-purchase_order_confirmation-purchase_order-id-value = fp_header-bstkd.

* ---> Begin of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
*** If sales Org belongs to D3, print Inco terms2 also
    IF gv_d3_flag = abap_true.
      CONCATENATE lv_inco1 fp_header-inco2 INTO
       fp_structure_out-purchase_order_confirmation-purchase_order-delivery_terms-incoterms-zinco_term
                  SEPARATED BY space.
    ELSE. " ELSE -> IF gv_d3_flag = abap_true
* ---> End of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
      fp_structure_out-purchase_order_confirmation-purchase_order-delivery_terms-incoterms-classification_code = lv_inco1.
* ---> Begin of Insert for D3_OTC_IDD_0167_CR#301 by MGARG
    ENDIF. " IF gv_d3_flag = abap_true
* ---> End of Insert for D3_OTC_IDD_0167_CR#301 by MGARG

  ENDIF. " IF sy-subrc EQ 0

*& --> Begin of Insert for Defect#1225 by SAGARWA1
  IF lv_inco1 = lc_dap.
    fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zfreight_text = lc_prepaid.
  ELSEIF lv_inco1 = lc_fca.
    fp_structure_out-purchase_order_confirmation-purchase_order-z01otc_zfreight_text = lc_collect.
  ENDIF. " IF lv_inco1 = lc_dap
*& --> End of Insert for Defect#1225 by SAGARWA1

  REFRESH: li_lines[],
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA
           li_id[],
           i_name[].
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

* ---> Begin of Insert for D3_OTC_IDD_0167_CR#301 by U034334
*&--For D3 sales Org, print the Name1 & Name (Seller Party Address)
  IF gv_d3_flag = abap_true.
    SELECT SINGLE adrnr "Address
             FROM tvko  " Organizational Unit: Sales Organizations
             INTO lv_vkorg_adrnr
      WHERE vkorg = lv_vkorg.
    IF sy-subrc = 0.

      SELECT name1 name2
        FROM adrc " Addresses (Business Address Services)
        INTO (lv_vkorg_name1, lv_vkorg_name2 )
        UP TO 1 ROWS
        WHERE addrnumber = lv_vkorg_adrnr.
      ENDSELECT.
      IF sy-subrc = 0.

        IF  lv_vkorg_name2 IS NOT INITIAL.
          CONCATENATE lv_vkorg_name1 lv_vkorg_name2
          INTO lwa_seller_address-z01otc_zsales_org_name
          SEPARATED BY space.
        ELSE. " ELSE -> IF lv_vkorg_name2 IS NOT INITIAL
          lwa_seller_address-z01otc_zsales_org_name = lv_vkorg_name1.
        ENDIF. " IF lv_vkorg_name2 IS NOT INITIAL
        APPEND lwa_seller_address TO fp_structure_out-purchase_order_confirmation-purchase_order-seller_party-address.
        CLEAR lwa_seller_address.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF gv_d3_flag = abap_true
* ---> End   of Insert for D3_OTC_IDD_0167_CR#301 by U034334

  CLEAR: lv_ord_comments,
         lv_name,
         lv_valpos,
         lv_ord_1,
         lv_ord_comments_part1,
         lv_ord_2,
         lv_ord_comments_part2,
         lv_doctyp_ord,
         lv_doctyp,
         lv_docref,
         lv_zzdocref,
         lv_caseref,
         lv_zzcaseref,
*--Begin of changes for SCTASK0764894 Defect# 6476 by mthatha
         lv_zzdoctyp.
*--End of changes for SCTASK0764894 Defect# 6476 by mthatha

  fp_retcode = 0.

*  BEGIN OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG

  fp_vkorg = lv_vkorg.
  fp_i_recipient = li_recipient_party2[].
*  END OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG


ENDFORM. " F_GET_HEADER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_ID_Z014  text
*      -->P_LV_LANGU1  text
*      -->P_LV_NAME  text
*      -->P_LC_OBJECT  text
*      <--P_LI_LINES  text
*----------------------------------------------------------------------*
FORM f_get_text TABLES fp_lines
                  USING fp_id     " Text ID
                       fp_langu1  " Language Key of Current Text Environment
                       fp_name    " Name
                       fp_object. " Texts: Application Object

*FM to read text lines for material description with text id 0001
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = fp_id     "Id
      language                = fp_langu1 "lang
      name                    = fp_name   "Sales ord number
      object                  = fp_object "Object Id
    TABLES
      lines                   = fp_lines  "Text lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

ENDFORM. " F_GET_TEXT
*BEGIN OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG
*The below Form f_create_proxy , the code has been copied from d2 code in form f_call_proxy.
*we need this so we can create 2 seperate XMLS with seperate email address for both CP and ZA partner
*hence the code in the form below will also have d2 tags
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_PROXY
*&---------------------------------------------------------------------*
*       Create XML and update NAST with message id
*----------------------------------------------------------------------*
*      -->P_LX_STRUCTURE_OUT  text
*----------------------------------------------------------------------*
FORM f_create_proxy  USING  fp_structure_out TYPE  sls_purchase_order_confirmati2 " MT PurchaseOrderConfirmation
                           fp_vbeln TYPE vbeln_va.                                " Sales Document


  DATA: lref_po_proxy_out      TYPE REF TO co_sls_purchaseorderco,        "Ref for Proxy Object
        lref_system_fault      TYPE REF TO cx_ai_system_fault,            " Application Integration: Technical Error
        lv_text                TYPE oia_char50,                           "NAST Messa
        lref_protocol          TYPE REF TO if_wsprotocol_async_messaging, "Routing Protocoll for EOIO
        lv_context             TYPE prx_scnt,                             "Context
        lref_wsprotocol        TYPE REF TO if_wsprotocol,              " ABAP Proxies: Available Protocols
        lref_wsprotocol_msg_id TYPE REF TO if_wsprotocol_message_id,   " XI and WS: Read Message ID
        lx_cx_root             TYPE REF TO cx_root,                    " Abstract Superclass for All Global Exceptions
        lv_xml_message_id      TYPE sxmsmguid,                         " XI: Message ID
        lv_msg_v1              TYPE oia_char50.                        "NAST Message

  CONSTANTS : lc_otc_msg TYPE arbgb VALUE 'ZOTC_MSG',     "Message Class
              lc_msg_000 TYPE symsgno VALUE '000',        "Message Number
              lc_ponof   TYPE char6  VALUE 'POCONF',        "Ponof of type CHAR6
              lc_msg_907 TYPE symsgno     VALUE '907'. " Message Number

* Create Proxy
  TRY.
      CREATE OBJECT lref_po_proxy_out.
    CATCH cx_ai_system_fault INTO lref_system_fault.        "#EC *
      lv_text = lref_system_fault->get_text( ).

      IF NOT lv_text IS INITIAL.
* Update the Log in NAST
        CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
          EXPORTING
            msg_arbgb              = lc_otc_msg "Message class
            msg_nr                 = lc_msg_000 "Message number
            msg_ty                 = if_cwd_constants=>c_message_error
            msg_v1                 = lv_text
          EXCEPTIONS
            message_type_not_valid = 0
            no_sy_message          = 0
            OTHERS                 = 0.
        RETURN.
      ENDIF. " IF NOT lv_text IS INITIAL
  ENDTRY.
* Send XML via Proxy
  TRY.
*         Note: Currently we only support this message mediated with Excatly-Once-In-Order
      lref_protocol ?= lref_po_proxy_out->get_protocol( if_wsprotocol=>async_messaging ).
      CONCATENATE lc_ponof fp_vbeln INTO lv_context.
      lref_protocol->set_serialization_context( lv_context ).
*calling method
      CALL METHOD lref_po_proxy_out->execute_asynchronous
        EXPORTING
          output = fp_structure_out.
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
*get_WSprotocol
      CALL METHOD lref_po_proxy_out->get_protocol
        EXPORTING
          protocol_name = 'IF_WSPROTOCOL_MESSAGE_ID' " todo use constant
        RECEIVING
          protocol      = lref_wsprotocol.           "Protocol
*Try a narrowing cast - try and catch
      TRY.
          lref_wsprotocol_msg_id ?= lref_wsprotocol.
        CATCH cx_root INTO lx_cx_root.                      "#EC *
      ENDTRY.
      IF lx_cx_root IS NOT BOUND.
*       XML-message ID determination
        lv_xml_message_id = lref_wsprotocol_msg_id->get_message_id( ).
        IF lv_xml_message_id IS NOT INITIAL.
          lv_msg_v1 = lv_xml_message_id.
*Once we get the message id that has been generated
*when the sales order processing is done successfully we will update the processing log.
*This will help in keeping the track for particular sales order with message id it get generated.
          CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
            EXPORTING
              msg_arbgb              = lc_otc_msg "Message class
              msg_nr                 = lc_msg_907 "message number Message id is &
              msg_ty                 = if_cwd_constants=>c_message_success
              msg_v1                 = lv_msg_v1
            EXCEPTIONS
              message_type_not_valid = 0
              no_sy_message          = 0
              OTHERS                 = 0.
        ENDIF. " IF lv_xml_message_id IS NOT INITIAL
      ENDIF. " IF lx_cx_root IS NOT BOUND
* <--- End of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
*To catch exceptions
    CATCH cx_ai_system_fault INTO lref_system_fault.        "#EC *
      lv_text = lref_system_fault->get_text( ).

      IF NOT lv_text IS INITIAL.
* Update the Log in NAST
        CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
          EXPORTING
            msg_arbgb              = lc_otc_msg "Message class
            msg_nr                 = lc_msg_000 "message number
            msg_ty                 = if_cwd_constants=>c_message_error
            msg_v1                 = lv_text
          EXCEPTIONS
            message_type_not_valid = 0
            no_sy_message          = 0
            OTHERS                 = 0.
        RETURN.


      ENDIF. " IF NOT lv_text IS INITIAL

  ENDTRY.

ENDFORM. " F_CREATE_PROXY
*END OF CHANGE FOR D3_OTC_IDD_0167 BY NGARG

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*** CR#289 Changes: Address format
*&---------------------------------------------------------------------*
*&      Form  F_ADDRESS_BYFM
*&---------------------------------------------------------------------*
*       Calling FM "ADDRESS_INTO_PRINTFORM"
*----------------------------------------------------------------------*
*      -->FP_VBPA_ADRNR  Address
*      -->FP_BUILDLINE   Address line belongs to Floor/Building/Room
*      <--FP_ADDRESS     Proxy Structre
*----------------------------------------------------------------------*
FORM f_address_byfm  USING    fp_vbpa_adrnr TYPE adrnr          " Address
                              fp_buildline TYPE adrs-line0      " Address line
                     CHANGING fp_address TYPE sapplsef_address. " Proxy Structure (Generated)
****** Local Constants
  CONSTANTS:
    lc_post_code    TYPE ad_line_tp     VALUE 'O', " Address line type in the formatted address
    lc_country_code TYPE ad_line_tp     VALUE 'L', " Address line type in the formatted address
    lc_6            TYPE anzei          VALUE '6', " Number of lines in address
    lc_1            TYPE ad_adrtype     VALUE '1'. " Address type (1=Organization, 2=Person, 3=Contact person)

** Local Variables Declaration
  DATA:
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
    lv_lines        TYPE int4, " Natural Number
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
    li_add          TYPE STANDARD TABLE OF szadr_printform_table_line,
    lv_country_name TYPE char80,                   " Country_name of type CHAR80
    lv_lastline     TYPE char80,                   " Lastline of type CHAR80
    lv_index        TYPE int4,                     " Natural Number
    lwa_add         TYPE fsbp_address_printf_line. " Print Form Row
** Local Field Symbols
  FIELD-SYMBOLS :
  <lfs_ad>         TYPE szadr_printform_table_line.

******Address Format According to Post Office Guidelines
  CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
    EXPORTING
      address_type                   = lc_1
      address_number                 = fp_vbpa_adrnr
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
      receiver_language              = gv_spras
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
      number_of_lines                = lc_6
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
      country_name_in_receiver_langu = abap_true
*     language_for_country_name      = gv_spras
      no_upper_case_for_city         = abap_true
* ---> End of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
      iv_country_name_separate_line  = abap_true
    IMPORTING
      address_printform_table        = li_add.

* ---> Begin of Delete for D3_OTC_IDD_0167_Defect#8553 by MGARG
*Address format should not be accrding to addres type
** Binary search not required as there can be max 6 lines of records.
**** Get Country name
*  READ TABLE li_add ASSIGNING <lfs_ad>
*                    WITH KEY  line_type = lc_country_code.
*  IF sy-subrc EQ 0.
*    lv_country_name = <lfs_ad>-address_line.
*  ENDIF. " IF sy-subrc EQ 0
*
*  DELETE li_add WHERE line_type = lc_country_code.
*
**** Binary search not required as there can be max 6 lines of records.
*  READ TABLE li_add ASSIGNING <lfs_ad>
*                    WITH KEY line_type = lc_post_code.
*  IF sy-subrc EQ 0.
*    CONCATENATE <lfs_ad>-address_line lv_country_name INTO lv_lastline
*                                      SEPARATED BY space.
*    <lfs_ad>-address_line = lv_lastline.
*    lv_index = sy-tabix.
*    IF fp_buildline IS NOT INITIAL.
*      lwa_add-address_line = fp_buildline.
*      INSERT lwa_add INTO li_add INDEX lv_index.
*    ENDIF. " IF fp_buildline IS NOT INITIAL
*  ELSE. " ELSE -> IF sy-subrc EQ 0
*    lv_lastline = lv_country_name.
*  ENDIF. " IF sy-subrc EQ 0
* ---> End of Delete for D3_OTC_IDD_0167_Defect#8553 by MGARG

* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG
** Binary search not required as there can be max 6 lines of records.
****
  DESCRIBE TABLE li_add LINES lv_lines.
** Binary search not required as there can be max 6 lines of records.
****As per requirement, Last line needs to be concatenate with the previous line.
  READ TABLE li_add ASSIGNING <lfs_ad> INDEX lv_lines.
  IF sy-subrc EQ 0.
    lv_country_name = <lfs_ad>-address_line.
  ENDIF. " IF sy-subrc EQ 0
** Delete last line and line count decrease by 1.
  DELETE li_add INDEX lv_lines.
  lv_lines = lv_lines - 1.

*** Append last line into previous line.
* Binary search not required as there can be max 6 lines of records.
  READ TABLE li_add ASSIGNING <lfs_ad> INDEX lv_lines.
  IF sy-subrc IS INITIAL.
    CONCATENATE <lfs_ad>-address_line lv_country_name INTO lv_lastline
                                      SEPARATED BY space.
    <lfs_ad>-address_line = lv_lastline.
  ENDIF. " IF sy-subrc IS INITIAL

  IF fp_buildline IS NOT INITIAL.
    lwa_add-address_line = fp_buildline.
    INSERT lwa_add INTO li_add INDEX lv_lines.
  ENDIF. " IF fp_buildline IS NOT INITIAL

* ---> End of Insert for D3_OTC_IDD_0167_Defect#8553 by MGARG

****** Populate Proxy structure
  LOOP AT li_add ASSIGNING <lfs_ad>.
    IF sy-tabix = 1.
      fp_address-z01otc_zaddress_line1  =  <lfs_ad>-address_line.
    ELSEIF sy-tabix = 2.
      fp_address-z01otc_zaddress_line2  =  <lfs_ad>-address_line.
    ELSEIF sy-tabix = 3.
      fp_address-z01otc_zaddress_line3  =  <lfs_ad>-address_line.
    ELSEIF sy-tabix = 4.
      fp_address-z01otc_zaddress_line4  =  <lfs_ad>-address_line.
    ELSEIF sy-tabix =  5.
      fp_address-z01otc_zaddress_line5  =  <lfs_ad>-address_line.
    ELSEIF sy-tabix = 6.
      fp_address-z01otc_zaddress_line6  =  <lfs_ad>-address_line.
    ENDIF. " IF sy-tabix = 1

  ENDLOOP. " LOOP AT li_add ASSIGNING <lfs_ad>

ENDFORM. " F_ADDRESS_BYFM
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG

*&---> Begin of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXTS
*&---------------------------------------------------------------------*
*   Fetching standard texts
*----------------------------------------------------------------------*
*      -->fp_id      Text ID
*      -->fp_langu1  Language Key
*      -->fp_tdname  TDIC text name
*      -->fp_object  Texts: Application Object
*      <--fp_tdline  Texts line of CHAR70
*----------------------------------------------------------------------*
FORM f_get_texts  USING    fp_id          TYPE tdid     " Text ID
                           fp_langu1      TYPE  spras   " Language Key
                           fp_tdname      TYPE char70   " TDIC text name
                           fp_object      TYPE tdobject " Texts: Application Object
                  CHANGING fp_tdline      TYPE char70.  " Texts of type CHAR70

  DATA : li_lines TYPE STANDARD TABLE OF tline. " SAPscript: Text Lines
  FIELD-SYMBOLS: <lfs_lines> TYPE tline. " SAPscript: Text Lines

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = fp_id     "ST
      language                = fp_langu1 "language
      name                    = fp_tdname "Stndrd text
      object                  = fp_object "object id
    TABLES
      lines                   = li_lines  "text lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc EQ 0.
    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
    IF sy-subrc EQ 0.
      MOVE <lfs_lines>-tdline TO fp_tdline.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

ENDFORM.
*&<-- End of insert for R6_Upgrade D3_OTC_IDD_0167 Defect# 8305 SCTASK0793192 by SMUKHER4 on 07-Feb-2019
