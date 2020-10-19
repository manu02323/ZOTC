*&---------------------------------------------------------------------*
*& Report  ZOTCP0012B_CUST_ORDER_ACK_FORM
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCP0012B_CUST_ORDER_ACK_FORM                          *
*Title      : Customer Order Acknowledgement Form                     *
*Developer  : Nidhi Saxena                                            *
*Object type: Driver Program                                          *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_FDD_0012_Order acknowledgement form                *
*---------------------------------------------------------------------*
* Description: Order Acknowledgement is sent to the customer through  *
*              email, fax, or print. These forms will need to be auto *
*              generated at the time the Order is saved.              *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*13-Nov-2014  NSAXENA       E2DK906561      INITIAL DEVELOPMENT
*---------------------------------------------------------------------*
*24-Feb-2015  NSAXENA       E2DK906561      Defect #4073 Multpl Issues*
*                                           with Order Confirmtin PDF *
*                                                                     *
*25-Mar-2015  NSAXENA       E2DK906561      Defect-5141 Removing the  *
*text id Z017 detail at item level at line num 1347 to keep FDD-12,   *
*FDD-14 and IDD-0167 in sync.                                         *
*                                                                     *
*25-Mar-2015 NSAXENA       E2DK906561    Defect - 4829 Translations   *
*for french & Spanish language based on company code for standard text*
*also to display the text maintianed in respective langauage.         *
*Adding the new Tax calculations logic at item level.                 *
*                                                                     *
*01-Apr-2015 NSAXENA      E2DK906561    Defect-5438, when there is no *
*confirmed qty for given order qty in that case we need not to print  *
* the Estimated delivery date for taht schedule line.                 *
*09-Apr-2015 NSAXENA     E2DK906561     Defect-5597, Some minor chnage*
* in french layout, only one field value is condensed here.           *
*10-Apr-2015 NSAXENA     E2DK906561    Defect-5822,CR -595 for spanish*
*labels translations,added EMI Entry for Freight value at header.     *
*---------------------------------------------------------------------*
*15-Apr-2015 ASK     E2DK906561    Defect-5935,Unit Price and         *
*extended price logic chnage                                          *
*---------------------------------------------------------------------*
*24-Apr-2015 ASK     E2DK906561    Defect-6209,Discard Rejected Lines *
*---------------------------------------------------------------------*
*10-Jul-2015 ASK     E2DK913902    Defect-8533,Unit and Ext. Price    *
*                                  logic change when there is no ZNET *
*---------------------------------------------------------------------*
*11-Aug-2015 SGHOSH  E2DK914625    Defect#8903: Logic added to display
*                                  CMR/DMR items
*---------------------------------------------------------------------*
*05-May-2016 PDEBARU E2DK917643    Defect # 1697 / CR 1612 : Logic    *
*                                  added to display 'prepaid' or      *
*                                  'collect' in freight header        *
*                                  according to the type of incoterm  *
*---------------------------------------------------------------------*
* 10-Oct-2016 U034336 E1DK917654    Changes for D3_OTC_FDD_0012       *
* Two flags are set in the program one is D3_format_flag
* If this flag is set then appropriate changes in dates, UOM and Currency
* are made specific to the country.
* Other is language flag , which is set if D2 check for langauge is
* not true, then the language to print texts and labels in the form
* is taken from Sold to customer language.
* Labels are  also being translated specific to Sold to customer language
*----------------------------------------------------------------------*
* 26-Oct-2016 U034336 E1DK917654    Changes for Defect 5472,5486,5480  *
*Change in order of fields displayed under material description        *
*separate material desc and external product line text                 *
* 28-Oct-2016 DMOIRAN E1DK917654   Changes for Defect 5455             *
*             U034336.                                                 *
*Change in logic to get phone number and email                         *
*----------------------------------------------------------------------*
*16-Dec-2016 U034336 E1DK917654     Changes for CR#289                 *
* Change number of address lines for sold to and ship to address       *
* along with country should come concatenated                          *
* at the end of the last line                                          *
* 2. Check if text id's text is blank for form language , fetch the    *
* text using english langauge                                          *
*----------------------------------------------------------------------*
*04-Jan-2017 U034336 E1DK917654     Changes for CR#301                 *
*Changes are done only for D3 sales orgnaizations                      *
* ADD INCO2 after INCO1 in the form ( taken from VBKD )                *
* Pass Name of title of form from ADRC-name1 and ADRC-name2            *
* Pass estd delivery date of non confirmed qty only when order type is *
* a standing order                                                     *
*05-Jan-2017 U034336 E1DK917654     Changes for Defect#6168            *
* Loop on text table to get full length of standard text.              *
*----------------------------------------------------------------------*
*9-Jan-2017  U034336 E1DK917654     Changes for CR#301_Part-2          *
*If sold to language is french then reverse the order of printing      *
* of title of the form with name1 and name 2 appearing first and       *
* fixed text order acknowledgemnt as second                            *
* Address into printform - Post code changes have been taken back      *
* Also country needs to be printed in last line and buliding, room     *
* and floor number in last second line if exist.                       *
* if d3 flag is set or is shipping cond exist in TVSBT table           *
* then in both cases we can get the address data in address tables     *
*----------------------------------------------------------------------*
*23-Feb-2017  DMOIRAN E1DK926027    D3 Defect 9886.                    *
* 1. Comment out route as route is not needed in form.
* 2. As Incoterm has replaced frieght, get the label for D2 also.
*----------------------------------------------------------------------*
*05-Apr-2017 Sudhanshu E1DK926599   Defect#12010: Due to structure type
*                                  mismatch wrong address data getting
*                                  printed in the form. Code fix added
*                                  to resolve the issue.
*----------------------------------------------------------------------*
*07-Apr-2017 Debarun Paul  E1DK926599   Defect#2427/2430: Est Del Date not*
*                                   to be populated when order NE ZSTD *

*10-Oct-2017 AMOHAPA    E1DK931099   D3_R2 Defect: 1) Adding of Bill To*
*                                    partner details in the header     *
*                                    2)Adding of Insurance fee and     *
*                                    Environment fee in the form output*
*                                    whereever there is value in ZINS  *
*                                    and ZENV condition type respect-  *
*                                    ively                             *
*                                    3)Printing of TBD where conf.Qty  *
*                                    zero                              *
*                                    4)Adding document charge into     *
*                                    Handling where there is value in  *
*                                    ZDOC condition type               *
*                                    5)GLN Number have been added for  *
*                                    all the partner in Header         *
*                                    6)Translation of the text in      *
*                                     Swedish,Danish,Nowreign,Finish   *
*03-Nov-2017 AMOHAPA   E1DK931099    Defect# 3909: Last line item      *
*                                    missing the delivery date when    *
*                                    confirmed quantity is zero for all*
*                                    line item                         *
*----------------------------------------------------------------------*
*29-Jan-2018   U029267  E1DK931099   D3_R3 Defect: 1)EMI configuration *
*                                    for Portugal, Spain, Italy and    *
*                                    Greece(TBD).                      *
*                                    2)GLN suppression (Global Location*
*                                    Number partners)Subtotal field for*
*                                    the documentation charge (ZDOC).  *
*                                    3)Suppression of subtotal when    *
*                                    value is 0 (freight, dangerous    *
*                                    goods, handling, insurance and    *
*                                    documentation).                   *
*                                    4)Italy CUP/CIG Code.             *
*                                    5)Translation                     *
*----------------------------------------------------------------------*
*07-Feb-2019   U029267  E2DK922074   R6 Defect#8304:Include billing    *
*                                    plan details in order acknowldgemt*
*----------------------------------------------------------------------*
*13-Mar-2019 SMUKHER4  E2DK922074  FUT Issues Defect# 8658:            *
*                                 Tax calculation logic for Split tax  *
*                                 invoices, mulitple tax jurisdictions *
*                                 & European order                     *
*----------------------------------------------------------------------*
*19-Jun-2019   ASK    E2DK924770      Defect# 9877:Order Acknowledgement*
*                                    is create for order orginating    *
*                                    from Esker, the words "Esker Ref  *
*                                    #:XXXXXXXXXXXX" appear incorrectly*
*                                    in the Invoice- Order             *
*                                    Acknowledgement text field.       *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
* 22/08/2019  U106341                 HANAtization changes
*----------------------------------------------------------------------*
REPORT zotcp0012b_cust_order_ack_form MESSAGE-ID zotc_msg.
*----------------------------------------------------------------------*
*       F O R M S
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ENTRY
*&---------------------------------------------------------------------*
*       Entry Routine for Form Processing
*----------------------------------------------------------------------*
*      -->RETURN_CODE  Return Code for errors
*      -->US_SCREEN    Print Preview
*----------------------------------------------------------------------*
FORM entry USING return_code TYPE sy-subrc  ##called " Return Value of ABAP Statements
                 us_screen   TYPE c.                 " Screen of type Character

  CONSTANTS:
    lc_nast  TYPE tabname VALUE 'NAST',  "Messages
    lc_tnapr TYPE tabname VALUE 'TNAPR'. "Processing programs for output
  " Local Constant for  Enh. Criteria
  FIELD-SYMBOLS:
    <lfs_x_nast>  TYPE nast,  "NAST Structure
    <lfs_x_tnapr> TYPE tnapr. "TNAPR Structure
  DATA:lv_retcode    TYPE sy-subrc. "Returncode

*&--Assign NAST Structure
  ASSIGN (lc_tnapr)     TO <lfs_x_tnapr>.
*&--Assign TNAPR Structure
  ASSIGN (lc_nast)      TO <lfs_x_nast>.

  IF <lfs_x_tnapr>     IS ASSIGNED AND
     <lfs_x_nast>      IS ASSIGNED. "AND

*&--Form Print/Fax/Mail Processing
    PERFORM f_processing USING us_screen
                               <lfs_x_nast>
                               <lfs_x_tnapr>
                      CHANGING
                               lv_retcode.
    IF lv_retcode NE 0.
      return_code = 1.
    ELSE. " ELSE -> IF lv_retcode NE 0
      return_code = 0.
    ENDIF. " IF lv_retcode NE 0
  ELSE. " ELSE -> IF <lfs_x_tnapr> IS ASSIGNED AND
    return_code = 1.
  ENDIF. " IF <lfs_x_tnapr> IS ASSIGNED AND
**  ENDIF.
ENDFORM. "ENTRY

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSING
*&---------------------------------------------------------------------*
*       Processing Forms for output Print/Fax/Mail
*----------------------------------------------------------------------*
*      -->FP_US_SCREEN  Print Preview
*      -->FP_NAST       Messages
*      -->FP_TNAPR      Processing programs for output
*      -->FP_ARC_PARAMS ImageLink structure
*      -->FP_TOADARA    SAP ArchiveLink structure of a DARA line
*      -->FP_RETCODE    Return Code for errors
*----------------------------------------------------------------------*
FORM f_processing USING fp_us_screen  TYPE c         " Processing using fp_us_ of type Character
                        fp_nast       TYPE nast      " Message Status
                        fp_tnapr      TYPE tnapr     " Processing programs for output
               CHANGING fp_retcode    TYPE sy-subrc. " Return Value of ABAP Statements

  TYPES: BEGIN OF lty_vbdpa, "Internal table for items
           vbdpa TYPE vbdpa,    " Document Item View for Inquiries,Quotation,Order
         END OF lty_vbdpa.

  CONSTANTS:
    lc_mail       TYPE fpmedium   VALUE 'MAIL',     "Mail Output Device
    lc_telefax    TYPE fpmedium   VALUE 'TELEFAX',  "Fax Output Device
    lc_error      TYPE sy-msgty   VALUE 'E',        "Error
    lc_fax        TYPE ad_comm    VALUE 'FAX',      "Fax Communication
    lc_int        TYPE ad_comm    VALUE 'INT',      "Mail Communication
    lc_pdf        TYPE so_obj_tp  VALUE 'PDF',      "PDF Object Type
    lc_mail_msg   TYPE na_nacha   VALUE '5',        "Mail Message transmission
    lc_fax_msg    TYPE na_nacha   VALUE '2',        "Fax Message transmission
    lc_archive    TYPE syarmod    VALUE '2',        "Archive Only
    lc_pr_archive TYPE syarmod    VALUE '3',        "Print & Archive
    lc_msgno      TYPE sy-msgno   VALUE '000',      "Message No.
    lc_msgid      TYPE sy-msgid   VALUE 'ZOTC_MSG'. "OTC Message ID
*Translations part -
  DATA: lv_bio_rad_conf    TYPE char255,   " Bio_rad_conf of type CHAR70
        lv_contact_id      TYPE char255,     " Contact_id of type CHAR70
        lv_thanks          TYPE char255,         " Thanks of type CHAR70
        lv_ord_date        TYPE char70,        " Ord_date of type CHAR70
        lv_to              TYPE char70,              " To of type CHAR70
        lv_email           TYPE char70,           " Email of type CHAR70
        lv_phone           TYPE char70,           " Phone of type CHAR70
        lv_po_num          TYPE char255,         " Po_num of type CHAR70
        lv_carrier         TYPE char70,         " Carrier of type CHAR70
        lv_freight_heading TYPE char70, " Freight_heading of type CHAR70
        lv_ord_cmt         TYPE char255,        " Ord_cmt of type CHAR70
        lv_sold_to         TYPE char70,         " Sold_to of type CHAR70
        lv_ship_to         TYPE char70,         " Ship_to of type CHAR70
        lv_line_num        TYPE char70,        " Line_num of type CHAR70
        lv_mat_num         TYPE char70,         " Mat_num of type CHAR70
        lv_mat_descr       TYPE char70,       " Mat_descr of type CHAR70
        lv_ord_qty         TYPE char70,         " Ord_qty of type CHAR70
        lv_conf_qty        TYPE char70,        " Conf_qty of type CHAR70
        lv_back_qty        TYPE char70,        " Back_qty of type CHAR70
        lv_ship_date       TYPE char70,       " Ship_date of type CHAR70
        lv_unit_price      TYPE char70,      " Unit_price of type CHAR70
        lv_amount          TYPE char70,          " Amount of type CHAR70
        lv_batch           TYPE char70,           " Batch of type CHAR70
        lv_expiry_date     TYPE char70,     " Expiry_date of type CHAR70
        lv_subtotal        TYPE char70,        " Subtotal of type CHAR70
        lv_hazardous       TYPE char70,       " Hazardous of type CHAR70
        lv_handling        TYPE char70,        " Handling of type CHAR70
        lv_tax_heading     TYPE char70,     " Tax_heading of type CHAR70
        lv_total           TYPE char70,           " Total of type CHAR70
        lv_footer          TYPE char30000,       " Footer of type CHAR30000
        lv_footer_eng      TYPE char30000,   " Footer_eng of type CHAR30000
        lv_freight_footer  TYPE char70.  " Freight_footer of type CHAR70
*translations end

  DATA:
*&---------V A R I A B L E S---------*
    lv_vbeln              TYPE vbeln_va,       "Document No.
    lv_country_key        TYPE char3,            "Country Key
    lv_total_price        TYPE char15,         "netwr_ak,       "Total Price
    lv_subtotal_price     TYPE char15,        "netwr_ak,      " Net Value of the Sales Order in Document Currency
    lv_dangergoods_fee    TYPE char15,       "kwert,        " Condition value
    lv_handling_fee       TYPE char15,          "kwert,           " Condition value
    lv_freight            TYPE char15,               "kwert,                " Condition value
    lv_tax                TYPE char15,                 "mwsbp ,                 " Tax amount in document currency
    lv_formname           TYPE fpname,         "Name of Form Object
    lv_function           TYPE rs38l_fnam,     "Name of Function Module
    lv_pdf_content        TYPE solix_tab,      "SAPoffice: Binary data
    lv_emailaddr          TYPE adr6-smtp_addr, "E-Mail Address
    lv_sent_to_all        TYPE os_boolean,     "Sent to all indicator
    lv_pdf_siz            TYPE so_obj_len,     "PDF Size
    lv_ship_no            TYPE char10,         "Ship-to-Party Number
    lv_sold_no            TYPE char10,         "Bill-tp-Party Number
    lv_ship_att           TYPE char255,        " Ship_att of type CHAR10
    lv_subject            TYPE so_obj_des,     "Mail Subject
    lv_inupd              TYPE i,              "Update task indicator
    lv_comm_type          TYPE ad_comm,        "Communication type for customer
    lv_programm           TYPE tdprogram,      "Program Name
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4874 by NSAXENA
    lv_langu              TYPE char3, " Langu of type CHAR3
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4874 by NSAXENA

*&---------R E F E R E N C E   V A R I A B L E S---------*
    lv_cx_root            TYPE REF TO cx_root,          "All Global Exceptions
    lv_send_request       TYPE REF TO cl_bcs,           "Business Communication Service
    lv_document           TYPE REF TO cl_document_bcs,  "Wrapper Class for Office Documents
    lv_recipient          TYPE REF TO if_recipient_bcs, "Interface of Recipient Object in BCS

*&---------S T R U C T U R E S---------*
    lx_itcpo              TYPE itcpo,                             "SAPscript output interface
    lx_sold_to_addr       TYPE zotc_cust_order_ack_add_info,      "Bill To Address
    lx_ship_to_addr       TYPE zotc_cust_order_ack_add_info,      "Ship-To Address
    lx_contact_addr       TYPE zotc_cust_order_ack_add_info,      "Contact Person Address
    lx_contact_addr_check TYPE zotc_cust_order_ack_add_info, "Contact Person Address
    lx_header             TYPE zotc_cust_order_ack_header,        "Document Header data
    lx_sadr               TYPE sadr,                              "Address Management: Company Data
    lx_docparams          TYPE sfpdocparams,                      "Form Parameters for Form Processing
    lx_outputparams       TYPE sfpoutputparams,                   "Form Processing Output Parameter
    lx_formout            TYPE fpformoutput,                      "Form Output (PDF, PDL)
    lx_vbadr              TYPE vbadr,                             "Address Structure
    lx_comm_values        TYPE szadr_comm_values,                 "Communicaion specific values
    lx_recipient          TYPE swotobjid,                         "Mail Recepeint
    lx_sender             TYPE swotobjid,                         "Mail Sender
    lx_intnast            TYPE snast,                             "Message output
    lx_outputparams_fax   TYPE sfpoutpar,                      "Form Processing Output Fax
    lx_vbco3              TYPE vbco3,                                   "Sales Doc.Access Methods: Key Fields: Document Printing
    lx_vbdka              TYPE vbdka,                                   "Document Header View for Inquiry,Quotation,Order
    lx_addr_key           TYPE addr_key,                              " Structure with reference key fields and address type
*Begin of insert for D3_OTC_FDD_0012 by U034336
    lv_incoterm           TYPE char70, " Incoterm of type CHAR70
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
    lv_name1              TYPE char255. " Name1 of type CHAR255
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336

*&---------I N T E R N A L   T A B L E S---------*
  DATA:
    li_item       TYPE zotc_t_cust_order_ack_item, "Item Data
    li_sch_item   TYPE zotc_t_order_ack_sch_item,  "Schedule Line Data
    li_vbdpa      TYPE STANDARD TABLE OF lty_vbdpa,
    li_mess       TYPE STANDARD TABLE OF vbfs ,                " Error Log for Collective Processing
*Begin of insert for D3_OTC_FDD_0012 by U034336
    lv_sh_to_land TYPE land1, " Country Key
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    lv_fr_langu   TYPE flag. " General Flag
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
  DATA: lv_insurance_fee TYPE char15,                       "Conditional value for insurance
        lv_env_fee       TYPE char15,                       "Conditional value for environmente fee
        lv_bill_no       TYPE char10,                       "Bill to number
        lwa_bill_to      TYPE zotc_cust_order_ack_add_info, "Bill-To Address
        lv_bill_to_lb    TYPE char70,                       " Bill_to_lb of type CHAR70
        lv_insurance_lb  TYPE char70,                       " Insurance_lb of type CHAR70
        lv_env_lb        TYPE char70,                       " Env_lb of type CHAR70
        lv_location_lb   TYPE char70,                       " Location_lb of type CHAR70
        lv_gln_shipto    TYPE char12,                       "Location for Ship to
        lv_gln_billto    TYPE char12,                       "Location for Bill to
        lv_gln_soldto    TYPE char12,                       "Location for Sold to
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        lv_document_chg  TYPE char15,                       "Conditional value for Documentation
        lv_document_lb   TYPE char70,                       " Document charges of type CHAR70
        lv_cup_cig_text  TYPE char8,                       " CUP and CIG text
        lv_cup_cig_val   TYPE char30.                      " CUP and CIG value
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018


  FIELD-SYMBOLS: <lfs_mess> TYPE vbfs. " Error Log for Collective Processing

*&--Check if the subroutine is called in update task.
  CALL METHOD cl_system_transaction_state=>get_in_update_task
    RECEIVING
      in_update_task = lv_inupd.

*&--Fetch form data
  PERFORM f_get_data USING fp_us_screen
                           fp_nast
                  CHANGING lx_vbadr
                           li_item
                           li_sch_item
                           lv_vbeln
                           lv_subtotal_price
                           lv_dangergoods_fee
                           lv_handling_fee
                           lv_freight
                           lv_tax
                           lv_total_price
                           lx_sold_to_addr
                           lx_ship_to_addr
                           lx_contact_addr
                           lx_contact_addr_check
                           lx_header
                           lx_sadr
                           lv_ship_no
                           lv_sold_no
                           lv_ship_att
                           lv_country_key
                           lv_langu
                           fp_retcode
*Begin of insert for D3_OTC_FDD_0012 by U034336
                           lv_sh_to_land
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
                           lv_fr_langu
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                           lv_insurance_fee
                           lv_env_fee
                           lwa_bill_to
                           lv_bill_no
                           lv_gln_shipto
                           lv_gln_soldto
                           lv_gln_billto
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                           lv_document_chg
                           lv_cup_cig_text
                           lv_cup_cig_val.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

  IF fp_retcode = 1.
    RETURN.
  ENDIF. " IF fp_retcode = 1
*For labels in adobe form

*Begin of insert for D3_OTC_FDD_0012 by U034336
* If flag is set then call this subroutine
* with different lables to get translated text
* Also get stanadard temporary dynamic text
* to be printed in form
  IF lx_header-d3_format_flag IS NOT INITIAL.

    PERFORM f_get_labels_eu USING lv_langu
                                  lv_sh_to_land
                         CHANGING lv_bio_rad_conf
                           lv_contact_id
                           lv_thanks
                           lv_ord_date
                           lv_to
                           lv_email
                           lv_phone
                           lv_po_num
                           lv_carrier
                           lv_incoterm
                           lv_ord_cmt
                           lv_sold_to
                           lv_ship_to
                           lv_line_num
                           lv_mat_num
                           lv_mat_descr
                           lv_ord_qty
                           lv_conf_qty
                           lv_ship_date
                           lv_unit_price
                           lv_amount
                           lv_batch
                           lv_expiry_date
                           lv_subtotal
                           lv_hazardous
                           lv_handling
                           lv_tax_heading
                           lv_total
                           lv_footer
                           lv_footer_eng
                           lv_freight_footer
                           lx_header
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                           lv_bill_to_lb
                           lv_insurance_lb
                           lv_env_lb
                           lv_location_lb
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                           lv_document_lb.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

  ELSE. " ELSE -> IF lx_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336
    PERFORM f_get_labels USING lx_header-vkorg
                               lv_langu
                         CHANGING lv_bio_rad_conf
                           lv_contact_id
                           lv_thanks
                           lv_ord_date
                           lv_to
                           lv_email
                           lv_phone
                           lv_po_num
                           lv_carrier
                           lv_freight_heading
                           lv_ord_cmt
                           lv_sold_to
                           lv_ship_to
                           lv_line_num
                           lv_mat_num
                           lv_mat_descr
                           lv_ord_qty
                           lv_conf_qty
                           lv_back_qty
                           lv_ship_date
                           lv_unit_price
                           lv_amount
                           lv_batch
                           lv_expiry_date
                           lv_subtotal
                           lv_hazardous
                           lv_handling
                           lv_tax_heading
                           lv_total
                           lv_footer
                           lv_footer_eng
                           lv_freight_footer
                           lv_incoterm "D3 Defect 9886 by DMOIRAN
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                           lv_bill_to_lb
                           lv_insurance_lb
                           lv_env_lb
                           lv_location_lb
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                           lv_document_lb.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

*Begin of insert for D3_OTC_FDD_0012 by U034336
  ENDIF. " IF lx_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336
*&--Check for external send
  IF fp_nast-nacha EQ lc_mail_msg.

    IF lx_contact_addr_check-adrnr IS NOT INITIAL.
*&--Strategy to get communication type
      CALL FUNCTION 'ADDR_GET_NEXT_COMM_TYPE'
        EXPORTING
          strategy           = fp_nast-tcode               "Tcode
          address_number     = lx_contact_addr_check-adrnr "Address number
        IMPORTING
          comm_type          = lv_comm_type                "Comm type
          comm_values        = lx_comm_values              "Comm Values
        EXCEPTIONS
          address_not_exist  = 1
          person_not_exist   = 2
          no_comm_type_found = 3
          internal_error     = 4
          parameter_error    = 5
          OTHERS             = 6.
      IF sy-subrc <> 0.
        PERFORM f_protocol_update USING fp_us_screen.
        fp_retcode = 1.
        RETURN.
      ENDIF. " IF sy-subrc <> 0
    ELSE. " ELSE -> IF lx_contact_addr_check-adrnr IS NOT INITIAL
      lx_vbco3-mandt = sy-mandt. "Client
      lx_vbco3-spras = fp_nast-spras. "Langague
      lx_vbco3-vbeln = fp_nast-objky. "Object Key
      lx_vbco3-kunde = fp_nast-parnr. "Partner number
      lx_vbco3-parvw = fp_nast-parvw. "Partner function

      CALL FUNCTION 'RV_DOCUMENT_PRINT_VIEW'
        EXPORTING
          comwa                       = lx_vbco3
        IMPORTING
          kopf                        = lx_vbdka
        TABLES
          pos                         = li_vbdpa
          mess                        = li_mess
        EXCEPTIONS
          fehler_bei_datenbeschaffung = 1.
      IF sy-subrc NE 0.
        PERFORM f_protocol_update USING fp_us_screen.
        fp_retcode = 1.
        RETURN.
      ELSE. " ELSE -> IF sy-subrc NE 0
        LOOP AT li_mess ASSIGNING <lfs_mess>.
          sy-msgid = <lfs_mess>-msgid.
          sy-msgno = <lfs_mess>-msgno.
          sy-msgty = <lfs_mess>-msgty.
          sy-msgv1 = <lfs_mess>-msgv1.
          sy-msgv2 = <lfs_mess>-msgv2.
          sy-msgv3 = <lfs_mess>-msgv3.
          sy-msgv4 = <lfs_mess>-msgv4.
          PERFORM f_protocol_update USING fp_us_screen.
        ENDLOOP. " LOOP AT li_mess ASSIGNING <lfs_mess>
      ENDIF. " IF sy-subrc NE 0

* fill address key --> necessary for emails
      lx_addr_key-addrnumber = lx_vbdka-adrnr.
      lx_addr_key-persnumber = lx_vbdka-adrnp.
      lx_addr_key-addr_type  = lx_vbdka-address_type.

*   ... use stratagy to get communication type
      CALL FUNCTION 'ADDR_GET_NEXT_COMM_TYPE'
        EXPORTING
          strategy           = fp_nast-tcode
          address_number     = lx_addr_key-addrnumber "Address number
          person_number      = lx_addr_key-persnumber "Person number
        IMPORTING
          comm_type          = lv_comm_type           "Comm type
          comm_values        = lx_comm_values         "Comm values
        EXCEPTIONS
          address_not_exist  = 1
          person_not_exist   = 2
          no_comm_type_found = 3
          internal_error     = 4
          parameter_error    = 5
          OTHERS             = 6.
      IF sy-subrc <> 0.
        fp_retcode = sy-subrc.
        syst-msgty = 'E'.
        PERFORM f_protocol_update USING fp_us_screen.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF lx_contact_addr_check-adrnr IS NOT INITIAL

*&--Convert communication data
    MOVE fp_nast-mandt      TO lx_intnast-mandt.
    MOVE fp_nast-kschl      TO lx_intnast-kschl.
    MOVE fp_nast-spras      TO lx_intnast-spras.
    MOVE fp_nast-adrnr      TO lx_intnast-adrnr.
    MOVE fp_nast-nacha      TO lx_intnast-nacha.
    MOVE fp_nast-anzal      TO lx_intnast-anzal.
    MOVE fp_nast-vsdat      TO lx_intnast-vsdat.
    MOVE fp_nast-vsura      TO lx_intnast-vsura.
    MOVE fp_nast-tcode      TO lx_intnast-tcode.
    MOVE fp_nast-usnam      TO lx_intnast-usnam.
    MOVE fp_nast-ldest      TO lx_intnast-ldest.
    MOVE fp_nast-dsnam      TO lx_intnast-dsnam.
    MOVE fp_nast-dsuf1      TO lx_intnast-dsuf1.
    MOVE fp_nast-dsuf2      TO lx_intnast-dsuf2.
    MOVE fp_nast-dimme      TO lx_intnast-dimme.
    MOVE fp_nast-delet      TO lx_intnast-delet.
    MOVE fp_nast-telfx      TO lx_intnast-telfx.
    MOVE fp_nast-telx1      TO lx_intnast-telx1.
    MOVE fp_nast-pfld4      TO lx_intnast-pfld4.
    MOVE fp_nast-pfld5      TO lx_intnast-pfld5.
    MOVE fp_nast-tdname     TO lx_intnast-tdname.
    MOVE fp_nast-snddr      TO lx_intnast-snddr.
    MOVE fp_nast-sndbc      TO lx_intnast-sndbc.
    MOVE fp_nast-forfb      TO lx_intnast-forfb.
    MOVE fp_nast-prifb      TO lx_intnast-prifb.
    MOVE fp_nast-tdreceiver TO lx_intnast-tdreceiver.
    MOVE fp_nast-tddivision TO lx_intnast-tddivision.
    MOVE fp_nast-tdocover   TO lx_intnast-tdocover.
    MOVE fp_nast-tdcovtitle TO lx_intnast-tdcovtitle.
    MOVE fp_nast-tdautority TO lx_intnast-tdautority.
    MOVE fp_nast-tdarmod    TO lx_intnast-tdarmod.
    MOVE fp_nast-usrnam     TO lx_intnast-usrnam.
    MOVE fp_nast-event      TO lx_intnast-event.
    MOVE fp_nast-sort1      TO lx_intnast-sort1.
    MOVE fp_nast-sort2      TO lx_intnast-sort2.
    MOVE fp_nast-sort3      TO lx_intnast-sort3.
    MOVE fp_nast-objtype    TO lx_intnast-objtype.
    MOVE fp_nast-tdschedule TO lx_intnast-tdschedule.
    MOVE fp_nast-tland      TO lx_intnast-tland.
    MOVE sy-repid           TO lv_programm.
*To convert the data for communication
    CALL FUNCTION 'CONVERT_COMM_TYPE_DATA'
      EXPORTING
        pi_comm_type              = lv_comm_type
        pi_comm_values            = lx_comm_values
        pi_country                = lx_vbadr-land1
        pi_repid                  = lv_programm
        pi_snast                  = lx_intnast
      IMPORTING
        pe_itcpo                  = lx_itcpo
        pe_device                 = lx_outputparams-device
        pe_mail_recipient         = lx_recipient
        pe_mail_sender            = lx_sender
      EXCEPTIONS
        comm_type_not_supported   = 1
        recipient_creation_failed = 2
        sender_creation_failed    = 3
        OTHERS                    = 4.
    IF sy-subrc <> 0.
      PERFORM f_protocol_update USING fp_us_screen.
      fp_retcode = 1.
      RETURN.
    ENDIF. " IF sy-subrc <> 0
*&--Determine device type for formatting a document with DEVICE=MAIL
    IF lx_outputparams-device = lc_mail.
      CALL FUNCTION 'SX_ADDRESS_TO_DEVTYPE'
        EXPORTING
          recipient_id      = lx_recipient
          sender_id         = lx_sender
        EXCEPTIONS
          err_invalid_route = 1
          err_system        = 2
          OTHERS            = 3.
      IF sy-subrc <> 0.
        PERFORM f_protocol_update USING fp_us_screen.
        fp_retcode = 1.
        RETURN.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF lx_outputparams-device = lc_mail
  ENDIF. " IF fp_nast-nacha EQ lc_mail_msg
*&--Get Function Module name for Form Processing
  lv_function = fp_tnapr-funcname.
  IF NOT fp_tnapr-sform IS INITIAL.
    lv_formname = fp_tnapr-sform.
    TRY.
        CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
          EXPORTING
            i_name     = lv_formname
          IMPORTING
            e_funcname = lv_function.
*Exceptions handling
      CATCH cx_fp_api_repository INTO lv_cx_root.
        MESSAGE lv_cx_root TYPE lc_error.
      CATCH cx_fp_api_usage INTO lv_cx_root.
        MESSAGE lv_cx_root TYPE lc_error.
      CATCH cx_fp_api_internal INTO lv_cx_root.
        MESSAGE lv_cx_root TYPE lc_error.
    ENDTRY.
  ENDIF. " IF NOT fp_tnapr-sform IS INITIAL

*&--Fill Output Parameters Control Structure
  PERFORM f_fill_control_structure USING fp_nast
                                       fp_us_screen
                              CHANGING lx_outputparams.

*&--Sending via Mail or archiving the PDF output
  IF fp_us_screen IS INITIAL "In case of preview message should be displayed only
    AND ( fp_nast-nacha EQ lc_mail_msg OR fp_nast-tdarmod = lc_archive OR fp_nast-nacha EQ lc_fax_msg ).
*&--Setting output parameters only if communication type is fax or email.
    IF fp_nast-nacha EQ lc_mail_msg.
      IF ( lv_comm_type EQ lc_fax OR lv_comm_type EQ lc_int ).
        lx_outputparams-getpdf = abap_true.
        IF lx_itcpo-tdtelenum EQ space.
          lx_outputparams-nodialog = space.
        ENDIF. " IF lx_itcpo-tdtelenum EQ space
      ENDIF. " IF ( lv_comm_type EQ lc_fax OR lv_comm_type EQ lc_int )
    ELSE. " ELSE -> IF fp_nast-nacha EQ lc_mail_msg
      lx_outputparams-getpdf = abap_true.
    ENDIF. " IF fp_nast-nacha EQ lc_mail_msg
*&--Specific setting for FAX
    IF fp_nast-nacha EQ lc_fax_msg.
*&--Setting output parameters
      lx_outputparams-device = lc_telefax.
      IF fp_nast-telfx EQ space.
        lx_outputparams-nodialog = space.
      ENDIF. " IF fp_nast-telfx EQ space
    ENDIF. " IF fp_nast-nacha EQ lc_fax_msg
  ENDIF. " IF fp_us_screen IS INITIAL

*&--Open Spool Job
  CALL FUNCTION 'FP_JOB_OPEN'
    CHANGING
      ie_outputparams = lx_outputparams
    EXCEPTIONS
      cancel          = 1
      usage_error     = 2
      system_error    = 3
      internal_error  = 4
      OTHERS          = 5.
  IF sy-subrc <> 0.
    PERFORM f_protocol_update USING fp_us_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF sy-subrc <> 0
* &--To handle print and archive scenario
  IF fp_nast-tdarmod EQ lc_pr_archive.
    lx_outputparams-getpdf = abap_true.
  ENDIF. " IF fp_nast-tdarmod EQ lc_pr_archive

  CLEAR: lx_docparams.

*Begin of insert for D3_OTC_FDD_0012 by U034336
  IF lx_header-d3_format_flag IS NOT INITIAL
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
     AND lx_header-sold_to_lang IS NOT INITIAL.
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
    lx_docparams-langu = lx_header-sold_to_lang.
  ELSE. " ELSE -> IF lx_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336

    lx_docparams-langu = fp_nast-spras.

*Begin of insert for D3_OTC_FDD_0012 by U034336
  ENDIF. " IF lx_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336

  lx_docparams-country = fp_nast-tland.

*Begin of insert for D3_OTC_FDD_0012 by U034336

* D3 Defect 9886 by DMOIRAN - As carrier is not needed in all sites, remove route.
*  IF lx_header-d3_format_flag IS NOT INITIAL. "-D3 Defect 9886 by DMOIRAN

  CLEAR: lx_header-route.
*  ENDIF. " IF lx_header-d3_format_flag IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336

  IF lx_header-d3_format_flag IS NOT INITIAL.
*Begin of delete for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
* IF  lx_sadr-name2 IS NOT INITIAL.
*
*        CONCATENATE lx_sadr-name1 lx_sadr-name2 INTO lv_name1
*        SEPARATED BY space.
*        CONCATENATE  lv_name1 lv_bio_rad_conf INTO  lv_bio_rad_conf
*        SEPARATED BY space.
*      ELSE. " ELSE -> IF lx_sadr-name2 IS NOT INITIAL
*        CONCATENATE lx_sadr-name1 lv_bio_rad_conf  INTO lv_bio_rad_conf
*        SEPARATED BY space.
*      ENDIF. " IF lx_sadr-name2 IS NOT INITIAL
*End of delete for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    IF lv_fr_langu = abap_true.

      IF  lx_sadr-name2 IS NOT INITIAL.
        CONCATENATE lx_sadr-name1 lx_sadr-name2 INTO lv_name1
        SEPARATED BY space.
        CONCATENATE lv_bio_rad_conf lv_name1  INTO  lv_bio_rad_conf
        SEPARATED BY space.
      ELSE. " ELSE -> IF lx_sadr-name2 IS NOT INITIAL
        CONCATENATE lv_bio_rad_conf lx_sadr-name1  INTO lv_bio_rad_conf
        SEPARATED BY space.
      ENDIF. " IF lx_sadr-name2 IS NOT INITIAL

    ELSE. " ELSE -> IF lv_fr_langu = abap_true
      IF  lx_sadr-name2 IS NOT INITIAL.

        CONCATENATE lx_sadr-name1 lx_sadr-name2 INTO lv_name1
        SEPARATED BY space.
        CONCATENATE  lv_name1 lv_bio_rad_conf INTO  lv_bio_rad_conf
        SEPARATED BY space.
      ELSE. " ELSE -> IF lx_sadr-name2 IS NOT INITIAL
        CONCATENATE lx_sadr-name1 lv_bio_rad_conf  INTO lv_bio_rad_conf
        SEPARATED BY space.
      ENDIF. " IF lx_sadr-name2 IS NOT INITIAL

    ENDIF. " IF lv_fr_langu = abap_true
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

  ENDIF. " IF lx_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
*&--Call the generated function module
  CALL FUNCTION lv_function
    EXPORTING
      /1bcdwb/docparams  = lx_docparams
      im_vbeln           = lv_vbeln        "Sales order
      im_country_key     = lv_country_key  "Country Key
      im_sadr            = lx_sadr         "Sender details
      im_header          = lx_header       "Header details
      im_contact_addr    = lx_contact_addr "Contact address
      im_ship_to_addr    = lx_ship_to_addr "Ship to address
      im_sold_to_addr    = lx_sold_to_addr "Sold to address
      im_item            = li_item         "Line item data
      im_total_price     = lv_total_price  "Total price
      im_ship_no         = lv_ship_no      "Shipping party number
      im_sold_no         = lv_sold_no      "Sold party number
      im_hazardous       = lv_dangergoods_fee "
      im_freight         = lv_freight
      im_handling        = lv_handling_fee
      im_tax             = lv_tax
      im_subtotal        = lv_subtotal_price
      im_ship_att        = lv_ship_att
      im_sales_org       = lx_header-vkorg
      im_bio_rad_conf    = lv_bio_rad_conf
      im_contact_id      = lv_contact_id
      im_thanks          = lv_thanks
      im_ord_date        = lv_ord_date
      im_to              = lv_to
      im_email           = lv_email
      im_phone           = lv_phone
      im_po_num          = lv_po_num
      im_carrier         = lv_carrier
      im_freight_head    = lv_freight_heading
      im_ord_cmt         = lv_ord_cmt
      im_sold_to         = lv_sold_to
      im_ship_to         = lv_ship_to
      im_line_num        = lv_line_num
      im_mat_num         = lv_mat_num
      im_mat_descr       = lv_mat_descr
      im_ord_qty         = lv_ord_qty
      im_conf_qty        = lv_conf_qty
      im_back_qty        = lv_back_qty
      im_ship_date       = lv_ship_date
      im_unit_price      = lv_unit_price
      im_amount          = lv_amount
      im_batch           = lv_batch
      im_expiry_date     = lv_expiry_date
      im_subtotal_head   = lv_subtotal
      im_hazardous_head  = lv_hazardous
      im_handling_head   = lv_handling
      im_tax_head        = lv_tax_heading
      im_total_head      = lv_total
      im_footer          = lv_footer
      im_footer_eng      = lv_footer_eng
*Begin of insert for D3_OTC_FDD_0012 by U034336
      im_incoterm        = lv_incoterm
*End of insert for D3_OTC_FDD_0012 by U034336
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
      "Passing the insurance and environment into interface
      im_insurance       = lv_insurance_fee
      im_environment     = lv_env_fee
      im_bill_to         = lwa_bill_to
      im_bill_no         = lv_bill_no
      im_ins_lb          = lv_insurance_lb
      im_env_lb          = lv_env_lb
      im_bill_lb         = lv_bill_to_lb
      im_loc_lb          = lv_location_lb
      im_gln_shipto      = lv_gln_shipto
      im_gln_soldto      = lv_gln_soldto
      im_gln_billto      = lv_gln_billto
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
      im_freight_footer  = lv_freight_footer
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      im_document        = lv_document_chg         " Documentation charge value
      im_document_lb     = lv_document_lb          " Documentation charge value
      im_cup_cig_text    = lv_cup_cig_text         " CUP / CIG text
      im_cup_cig_val     = lv_cup_cig_val          " CUP / CIG value
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
    IMPORTING
      /1bcdwb/formoutput = lx_formout
    EXCEPTIONS
      usage_error        = 1
      system_error       = 2
      ternal_error       = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    PERFORM f_protocol_update USING fp_us_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF sy-subrc <> 0

*&--sending Document out via mail or FAX
  IF fp_us_screen IS INITIAL "In case of preview message should be displayed only
     AND ( fp_nast-nacha EQ lc_mail_msg OR fp_nast-nacha EQ lc_fax_msg )
     AND lx_formout IS NOT INITIAL.

*&--Get Email id from address no
*    lv_emailaddr = lx_contact_addr-smtp_addr. "Commented by NSXAENA on 10 jan 2015
    lv_emailaddr = lx_contact_addr_check-smtp_addr.

*&--When more than one address is maintained default address should be selected.
*&--When there is only one mail id then that will have default flag set
*&--Set FAX specific setting
    IF fp_nast-nacha EQ lc_mail_msg.
      lx_outputparams_fax-telenum = lx_itcpo-tdtelenum.
      lx_outputparams_fax-teleland = lx_itcpo-tdteleland.
    ELSE. " ELSE -> IF fp_nast-nacha EQ lc_mail_msg
      IF fp_nast-telfx NE space.
        lx_outputparams_fax-telenum  = fp_nast-telfx.
        IF fp_nast-tland IS INITIAL.
          lx_outputparams_fax-teleland = lx_vbadr-land1.
        ELSE. " ELSE -> IF fp_nast-tland IS INITIAL
          lx_outputparams_fax-teleland = fp_nast-tland.
        ENDIF. " IF fp_nast-tland IS INITIAL
      ENDIF. " IF fp_nast-telfx NE space
    ENDIF. " IF fp_nast-nacha EQ lc_mail_msg

    IF lv_comm_type EQ lc_fax OR
       lv_comm_type EQ lc_int OR
       fp_nast-nacha EQ lc_fax_msg.
* ------------ Call BCS interface ----------------------------------
      TRY.
*   ---------- create persistent send request ----------------------
          lv_send_request = cl_bcs=>create_persistent( ).

*   ---------- add document ----------------------------------------
*&--Get PDF xstring and convert it to BCS format
          lv_pdf_siz = xstrlen( lx_formout-pdf ).

          PERFORM f_xstring_to_solix USING lx_formout-pdf
                                           lv_pdf_content.
          CONCATENATE 'Acknowledgement of your Purchase Order'(005) lx_header-bstkd INTO lv_subject
                                     SEPARATED BY space.
          lv_document = cl_document_bcs=>create_document(
                    i_type    = lc_pdf
                    i_hex     = lv_pdf_content
                    i_length  = lv_pdf_siz
                    i_subject = lv_subject ).               "#EC NOTEXT

*&--Add document to send request
          lv_send_request->set_document( lv_document ).

*&--Add recipient (E-mail/Fax address)

          CASE fp_nast-nacha.
            WHEN lc_mail_msg.
              IF lv_comm_type EQ lc_int.
                IF lv_emailaddr IS INITIAL.
                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                    EXPORTING
                      msg_arbgb = lc_msgid
                      msg_nr    = lc_msgno
                      msg_ty    = lc_error
                      msg_v1    = 'Customer Email address not maintained'(006)
                    EXCEPTIONS
                      OTHERS    = 1.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF. " IF sy-subrc <> 0
                  fp_retcode = 1.
                  RETURN.
                ENDIF. " IF lv_emailaddr IS INITIAL

*&--Add recipient (e-mail address)
                lv_recipient = cl_cam_address_bcs=>create_internet_address(
                i_address_string = lv_emailaddr ).
              ELSE. " ELSE -> IF lv_comm_type EQ lc_int
                IF lx_outputparams_fax-telenum IS INITIAL OR
                   lx_outputparams_fax-teleland IS INITIAL.
                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                    EXPORTING
                      msg_arbgb = lc_msgid
                      msg_nr    = lc_msgno
                      msg_ty    = lc_error
                      msg_v1    = 'Customer Fax number not maintained'(007)
                    EXCEPTIONS
                      OTHERS    = 1.
                  IF sy-subrc <> 0.
                    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                  ENDIF. " IF sy-subrc <> 0
                  fp_retcode = 1.
                  RETURN.
                ENDIF. " IF lx_outputparams_fax-telenum IS INITIAL OR
*&--Add recipient (fax address)
                lv_recipient = cl_cam_address_bcs=>create_fax_address(
                                 i_country = lx_outputparams_fax-teleland
                                 i_number  = lx_outputparams_fax-telenum ).
              ENDIF. " IF lv_comm_type EQ lc_int

            WHEN lc_fax_msg.
              IF lx_outputparams_fax-telenum IS INITIAL OR
                 lx_outputparams_fax-teleland IS INITIAL.
                CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                  EXPORTING
                    msg_arbgb = lc_msgid
                    msg_nr    = lc_msgno
                    msg_ty    = lc_error
                    msg_v1    = 'Quote Ref#'(014)
                  EXCEPTIONS
                    OTHERS    = 1.
                IF sy-subrc <> 0.
                  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
                ENDIF. " IF sy-subrc <> 0

                fp_retcode = 1.
                RETURN.
              ENDIF. " IF lx_outputparams_fax-telenum IS INITIAL OR
*&--Add recipient (fax address)
              lv_recipient = cl_cam_address_bcs=>create_fax_address(
                               i_country = lx_outputparams_fax-teleland
                               i_number  = lx_outputparams_fax-telenum ).
          ENDCASE.

*&--Add recipient to send request
          lv_send_request->add_recipient( i_recipient = lv_recipient ).

*&--Send document

          lv_sent_to_all = lv_send_request->send(
              i_with_error_screen = abap_true ).
*&--Issue message and COMMIT only if the subroutine is not called in update task
          IF lv_inupd = 0.
            IF lv_sent_to_all = abap_true.
              MESSAGE i022(so). " Document sent
            ENDIF. " IF lv_sent_to_all = abap_true
*&--Explicit 'commit work' is mandatory!
            COMMIT WORK.
          ENDIF. " IF lv_inupd = 0
* ------------------------------------------------------------------
* *            Exception handling
* ------------------------------------------------------------------
        CATCH cx_bcs.
          IF lv_comm_type EQ lc_int.
*&--Sending fax/mail failed
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb = lc_msgid
                msg_nr    = lc_msgno
                msg_ty    = lc_error
                msg_v1    = 'Sending Mail/Fax Failed'(008)
              EXCEPTIONS
                OTHERS    = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF. " IF sy-subrc <> 0
            fp_retcode = 1.
            RETURN.
          ELSE. " ELSE -> IF lv_comm_type EQ lc_int
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb = lc_msgid
                msg_nr    = lc_msgno
                msg_ty    = lc_error
                msg_v1    = 'Sending Fax Failed'(009)
              EXCEPTIONS
                OTHERS    = 1.
            IF sy-subrc <> 0.
              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
            ENDIF. " IF sy-subrc <> 0
            fp_retcode = 1.
            RETURN.
          ENDIF. " IF lv_comm_type EQ lc_int

          fp_retcode = 1.
          RETURN.
      ENDTRY.
    ENDIF. " IF lv_comm_type EQ lc_fax OR
  ENDIF. " IF fp_us_screen IS INITIAL
*&--Close Job
  CALL FUNCTION 'FP_JOB_CLOSE'
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
    PERFORM f_protocol_update USING fp_us_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF sy-subrc <> 0

  FREE li_item.

ENDFORM. "F_PROCESSING


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
*       General provision of data for the form
*----------------------------------------------------------------------*
*      -->FP_SCREEN               Preview on Printer or Screen
*      -->FP_NAST                 Output Messages
*      -->FP_VBADR                Address work area
*      -->FP_I_ITEM               Order Acknowledgement Item data
*      -->FP_I_SCH_ITEM           Schedule Line Data
*      -->FP_VBELN                Sales Document No.
*      -->FP_TOTAL_PRICE          Total Price
*      -->FP_CRE_ADDR             Created By Address
*      -->FP_BILL_TO_ADDR         Bill To Address
*      -->FP_SHIP_TO_ADDR         Ship To Address
*      -->FP_CONTACT_ADDR         Contact Person Address
*      -->FP_HEADER               Sales Document Header data
*      -->FP_SHIP_NO              Ship-to-Party Number
*      -->FP_BILL_NO              Bill-to-Party Number
*      -->FP_RETCODE              Return Code
*----------------------------------------------------------------------*
FORM f_get_data USING fp_screen       TYPE c                                  " Get_data using fp_scree of type Character
                      fp_nast         TYPE nast                               " Message Status
             CHANGING fp_vbadr        TYPE vbadr                              " Address work area      ##NEEDED
                      fp_i_item       TYPE zotc_t_cust_order_ack_item         "Customer Order Acknowledgement Item dat
                      fp_i_sch_item   TYPE zotc_t_order_ack_sch_item          "Customer Order Acknowledgement Item dat
                      fp_vbeln        TYPE vbeln_va                           " Sales Document
                      fp_subtotal_price TYPE  char15                          " Net Value of the Sales Order in Document Currency
                      fp_dangergoods_fee TYPE char15                          " dangerous goods
                      fp_handling_fee TYPE char15                             "handling fees
                      fp_freight TYPE char15                                  "freight
                      fp_tax   TYPE char15                                    "Tax amount in document currency
                      fp_total_price  TYPE char15                             "Total price
                      fp_sold_to_addr TYPE zotc_cust_order_ack_add_info       " Order Acknowledgement - General Address Information
                      fp_ship_to_addr TYPE zotc_cust_order_ack_add_info       " Order Acknowledgement - General Address Information
                      fp_contact_addr TYPE zotc_cust_order_ack_add_info       " Order Acknowledgement - General Address Information
                      fp_contact_addr_check TYPE zotc_cust_order_ack_add_info " Order Acknowledgement - General Address Information
                      fp_header       TYPE zotc_cust_order_ack_header         " Header data for Order Acknowledgement form
                      fp_sadr         TYPE sadr                               " Address Management: Company Data
                      fp_ship_no      TYPE char10                             " Ship_no of type CHAR10
                      fp_sold_no      TYPE char10                             " Sold_no of type CHAR10
                      fp_ship_att     TYPE char255                            " Ship_att of type CHAR10
                      fp_country_key  TYPE char3                              "Country Key
                      fp_langu        TYPE char3                              " Langu of type CHAR3
                      fp_retcode      TYPE sy-subrc                           " Return Value of ABAP Statements
*Begin of insert for D3_OTC_FDD_0012 by U034336
                      fp_sh_to_land   TYPE land1 " Country Key
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
                      fp_fr_langu     TYPE flag " General Flag
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                      fp_lv_insurance_fee TYPE char15                       "Conditional value for insurance
                      fp_lv_env_fee       TYPE char15                       "Conditional value for environment
                      fp_lwa_bill_to      TYPE zotc_cust_order_ack_add_info "Bill to address
                      fp_bill_no          TYPE char10                       "Bill to number
                      fp_gln_shipto       TYPE char12                       "Location for ship to
                      fp_gln_soldto       TYPE char12                       "Location for sold to
                      fp_gln_billto       TYPE char12                      "Location for Bill to
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                      fp_lv_document_chg  TYPE char15                       " documentation charge
                      fp_cup_cig_text     TYPE char8                        " CIG text
                      fp_cup_cig_val      TYPE char30.                      " CIG text
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018


  DATA: lx_vbpa  TYPE vbpa, "Partner data
*Begin of insert for D3_OTC_FDD_0012 by U034336
        lv_kunnr TYPE kunnr, " Customer Number
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
        lv_auart TYPE auart. " Sales Document Type
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336

*&--Sales Document No. from NAST Object key
  fp_vbeln = fp_nast-objky.

  lx_vbpa-mandt = sy-mandt. "Client
  lx_vbpa-vbeln = fp_nast-objky. "Sales order number
  lx_vbpa-kunnr = fp_nast-parnr. "Customer number
  lx_vbpa-parvw = fp_nast-parvw. "Partner function

*&--Identify addresses for customers
  CALL FUNCTION 'VIEW_VBADR'
    EXPORTING
      input      = lx_vbpa
      langu_prop = fp_nast-spras "language
    IMPORTING
      adresse    = fp_vbadr
    EXCEPTIONS
      error      = 1
      OTHERS     = 2.
  IF sy-subrc NE 0.
    PERFORM f_protocol_update USING fp_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF sy-subrc NE 0

*&--Fetch Sales Document Header data
  PERFORM f_get_header_data USING fp_vbeln   ##needed
                                  fp_nast
                                  fp_screen
                         CHANGING fp_sold_to_addr
                                  fp_ship_to_addr
                                  fp_contact_addr
                                  fp_contact_addr_check
                                  fp_header
                                  fp_ship_no
                                  fp_sold_no
                                  fp_ship_att
                                  fp_vbadr
                                  fp_langu
                                  fp_retcode
*Begin of insert for D3_OTC_FDD_0012 by U034336
                                  lv_kunnr
                                  fp_sh_to_land
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                                  lv_auart
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
                                  fp_fr_langu
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                                  fp_lwa_bill_to
                                  fp_bill_no
                                  fp_gln_shipto
                                  fp_gln_soldto
                                  fp_gln_billto
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                                  fp_cup_cig_text     " CUP CIG text
                                  fp_cup_cig_val .    " CUP CIG text
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

*&--Fetch Sales Document Item data
  PERFORM f_get_item_data USING fp_vbeln
                                fp_header
*Begin of insert for D3_OTC_FDD_0012 by U034336
                                lv_kunnr
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                                lv_auart
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
                       CHANGING fp_i_item
                                fp_i_sch_item
                                fp_subtotal_price
                                fp_dangergoods_fee
                                fp_handling_fee
                                fp_freight
                                fp_tax
                                fp_total_price
                                fp_country_key
                                fp_langu
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                                fp_lv_insurance_fee "Conditional value for insurance
                                fp_lv_env_fee      "Conditional value for environment
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                                fp_lv_document_chg.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

*&--Determines the address of the sender (Table TVKO)
  PERFORM f_sender USING fp_header-vkorg
                         fp_screen
                CHANGING fp_sadr
                         fp_retcode.

ENDFORM. "F_GET_DATA
**
*---------------------------------------------------------------------*
*       FORM F_PROTOCOL_UPDATE                                          *
*---------------------------------------------------------------------*
*       The messages are collected for the processing protocol.       *
*---------------------------------------------------------------------*
*      -->FP_SCREEN        Print Preview Indicator
*---------------------------------------------------------------------*
FORM f_protocol_update USING fp_screen TYPE c. " Update using fp_ of type Character

  IF fp_screen <> space.
    RETURN.
  ENDIF. " IF fp_screen <> space
  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
    EXPORTING
      msg_arbgb = syst-msgid
      msg_nr    = syst-msgno
      msg_ty    = syst-msgty
      msg_v1    = syst-msgv1
      msg_v2    = syst-msgv2
      msg_v3    = syst-msgv3
      msg_v4    = syst-msgv4
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. "PROTOCOL_UPDATE



*&---------------------------------------------------------------------*
*&     Form  F_SENDER
*&---------------------------------------------------------------------*
*      This routine determines the address of the sender (Table TVKO)  *
*----------------------------------------------------------------------*
*      -->FP_VKORG    Sales Organization
*      -->FP_SCREEN   Output Preview or Print
*      -->FP_SADR     Address
*      -->FP_RETCODE  Return Code
*----------------------------------------------------------------------*
FORM f_sender USING fp_vkorg   TYPE vkorg     " Sales Organization
                    fp_screen  TYPE c         " Screen of type Character
           CHANGING fp_sadr    TYPE sadr      " Address Management: Company Data
                    fp_retcode TYPE sy-subrc. " Return Value of ABAP Statements     ##NEEDED

  CONSTANTS:
    lc_vn    TYPE sy-msgid VALUE 'VN',   "Message ID
    lc_error TYPE sy-msgty VALUE 'E',    "Error Message
    lc_203   TYPE sy-msgno VALUE '203',  "Message No.
    lc_tvko  TYPE sy-msgv1 VALUE 'TVKO', "TVKO Table name
    lc_ca01  TYPE ad_group VALUE 'CA01'. "Customizing addresses Group

  DATA:
    lv_adrnr   TYPE adrnr,     "Address Key
    lx_fb_addr TYPE addr1_sel. "Address selection parameter

*&--Fetch Sales Organizations Address
  SELECT SINGLE adrnr "Address
           FROM tvko  " Organizational Unit: Sales Organizations
           INTO lv_adrnr
    WHERE vkorg = fp_vkorg.
  IF sy-subrc NE 0.
    syst-msgid = lc_vn.
    syst-msgno = lc_203.
    syst-msgty = lc_error.
    syst-msgv1 = lc_tvko.
    syst-msgv2 = syst-subrc.
    PERFORM f_protocol_update USING fp_screen.
    fp_retcode = 1.
    RETURN.
  ENDIF. " IF sy-subrc NE 0

  lx_fb_addr-addrnumber = lv_adrnr.
*&--Read an address
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = lx_fb_addr
      address_group     = lc_ca01
    IMPORTING
      sadr              = fp_sadr
    EXCEPTIONS
      OTHERS            = 01.
  IF sy-subrc NE 0.
    CLEAR fp_sadr.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. "F_SENDER


*&---------------------------------------------------------------------*
*&      Form  F_GET_ITEM_DATA
*&---------------------------------------------------------------------*
*       Fetch Sales Document Item data
*----------------------------------------------------------------------*
*      -->FP_VBELN           Sales Document Number
*      -->FP_HEADER          Header data
*      -->FP_I_ITEM          Order Acknowledgement Item data
*      -->FP_I_SCH_ITEM      Schedule Line Data
*      -->FP_SUBTOTAL_PRICE  Subtotal price
*      -->FP_DANGERGOODS_FEE dangergoods fees
*      -->FP_HANDLING_FEE    handling fees
*      -->FP_FREIGHT         freight charges
*      -->FP_TAX             tax amount
*      -->FP_TOTAL_PRICE     Total Item Price
*     -->FP_COUNTRY_KEY      Country key
*     --> FP_LANGU          Language type
*----------------------------------------------------------------------*
FORM f_get_item_data USING fp_vbeln  TYPE vbeln_va                    " Sales Document
                           fp_header  TYPE zotc_cust_order_ack_header " Header data for Order Acknowledgement form
*Begin of insert for D3_OTC_FDD_0012 by U034336
                           fp_kunnr   TYPE kunnr " Customer Number
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                           fp_auart  TYPE auart " Sales Document Type
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
                     CHANGING fp_i_item TYPE zotc_t_cust_order_ack_item  "Customer Order Acknowledgement Item data
                           fp_i_sch_item  TYPE zotc_t_order_ack_sch_item "Customer Order Acknowledgement schedule lines data
                           fp_subtotal_price TYPE char15                 "Subtotal price
                           fp_dangergoods_fee TYPE char15                "Dangergoods
                           fp_handling_fee TYPE char15                   "Handling fees
                           fp_freight TYPE char15                        "freight
                           fp_tax   TYPE char15                          "Tax
                           fp_total_price TYPE char15                    "Total price
                           fp_country_key TYPE char3                     " Country_key of type CHAR3
                           fp_langu TYPE char3                           " Langu of type CHAR3
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                           fp_lv_insurance_fee TYPE char15  "Conditional value for insurance
                           fp_lv_env_fee       TYPE char15 "Conditional value for environment
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                           fp_lv_document_chg   TYPE char15. "Conditional value for documentation
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

  TYPES:
*&--Batches data for Items
    BEGIN OF lty_mcha,
      matnr	TYPE  matnr,   "Material Number
      werks TYPE werks_d,   " Plant
      charg	TYPE  charg_d, "Batch Number
      vfdat TYPE  vfdat,   "Expiration Date
    END OF lty_mcha,
*&--Batches data for Item
    BEGIN OF lty_mch1,
      matnr	TYPE  matnr,   "Material Number
      charg	TYPE  charg_d, "Batch Number
      vfdat TYPE  vfdat,   "Expiration Date
    END OF lty_mch1,

*&--VBAP Item data

    BEGIN OF lty_vbap,
      vbeln      TYPE vbeln_va,   " Sales Document
      posnr      TYPE  posnr_va, "Item No.
      matnr	     TYPE  matnr,    "Material Number
      charg	     TYPE  charg_d,  "Batch Number
      arktx      TYPE  arktx,    "Description
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
      fkrel      TYPE fkrel,     " Relevant for Billing
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
      uepos      TYPE uepos,      " Higher-level item in bill of material structures
      zmeng      TYPE dzmeng,     " Target quantity in sales units
      zieme      TYPE dzieme,     " Target quantity UoM
      netwr      TYPE netwr_ap,   " Net value of the order item in document currency
      waerk      TYPE waerk,      " SD Document Currency
      kwmeng     TYPE  kwmeng,   "Quantity
      kbmeng     TYPE kbmeng,    " Cumulative confirmed quantity in sales unit
      vrkme      TYPE vrkme,      " Sales unit
      werks      TYPE   werks_d,  "Plant
      stlnr      TYPE stnum,      " Bill of material
      kzwi1      TYPE kzwi1,      " Subtotal 1 from pricing procedure for condition
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
      kowrr      TYPE kowrr, " Statistical values
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
      mwsbp      TYPE mwsbp,           " Tax amount in document currency
      zzagmnt    TYPE z_agmnt,       " Warr / Serv Plan ID
      zzitemref  TYPE z_itemref,   " ServMax Obj ID
      zzquoteref TYPE z_quoteref, " Legacy Qtn Ref
      zzlnref    TYPE z_lnref,      " Instrument Reference
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
      zz_bilmet  TYPE z_bmethod, " Billing Method
      zz_bilfr   TYPE z_bfrequency, " Billing Frequency
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
    END OF lty_vbap,

*Conditions
    BEGIN OF lty_konv,
      knumv TYPE knumv,  " Number of the document condition
      kposn TYPE kposn,  " Condition item number
      stunr TYPE stunr,  " Step number
      zaehk TYPE dzaehk, " Condition counter
      kschl TYPE kscha,  " Condition type
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
      kbetr TYPE kbetr, " Condition Rate
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
      kntyp TYPE kntyp, "Condition category (examples: tax, freight, price, cost)
      kstat TYPE kstat, "Condition is used for statistics
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
      kwert TYPE kwert, " Condition value
    END OF lty_konv,
*For Text id at item level
    BEGIN OF ty_object_id_item,
      name TYPE tdobname, " Name of type CHAR15
      id   TYPE tdid,       " Text ID
    END OF ty_object_id_item,
*Types for stxh internal table
    BEGIN OF lty_name,
      object TYPE tdobject, " Texts: Application Object
      name   TYPE tdobname,   " Name
      id     TYPE tdid,         " Text ID
      lang   TYPE tdspras,    " Language key
    END OF lty_name,
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*Begin of insert for D3_OTC_FDD_0012 by U034336
    BEGIN OF lty_knmt,
      vkorg TYPE vkorg,    " Sales Organization
      vtweg TYPE vtweg,    " Distribution Channel
      kunnr TYPE kunnr,    " Customer Number
      matnr TYPE matnr,    " Material Number
      kdmat TYPE matnr_ku, " Material Number Used by Customer
    END OF lty_knmt,
*End of insert for D3_OTC_FDD_0012 by U034336

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
    BEGIN OF lty_vbkd,
      vbeln TYPE vbeln,    " Sales Document
      posnr TYPE posnr,    " Item No.
      fplnr TYPE fplnr,    " Billing Plan Number / Invoicing Plan Number
    END OF lty_vbkd,

    BEGIN OF lty_fplt,
      fplnr TYPE fplnr,       " Billing Plan Number / Invoicing Plan Number
      fpltr TYPE fpltr,       " Item for billing plan/invoice plan/payment cards
      fkdat TYPE bfdat,       " Settlement date for deadline
    END OF lty_fplt,

    BEGIN OF lty_fpla,
      fplnr TYPE fplnr,         " Billing Plan Number / Invoicing Plan Number
      bedat TYPE bedat_fp,      " Start date for billing plan/invoice plan
      endat TYPE endat_fp,      " End date billing plan/invoice plan
    END OF lty_fpla.

*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019

*Local Internal tables
  DATA:
    li_mcha      TYPE STANDARD TABLE OF lty_mcha, "Batches data
    li_mch1      TYPE STANDARD TABLE OF lty_mch1,
    li_vbap      TYPE STANDARD TABLE OF lty_vbap, "Item Data
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    li_vbap_tmp1 TYPE STANDARD TABLE OF lty_vbap, "Item Data
    li_name      TYPE STANDARD TABLE OF lty_name,
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    li_vbap_tmp  TYPE STANDARD TABLE OF lty_vbap,                "Item Data
    li_lines     TYPE STANDARD TABLE OF tline,                   "Material Sales text
    li_vbep      TYPE STANDARD TABLE OF zotc_order_ack_sch_item, " Order Acknowledgement Schedule Line Item data
    li_vbep_tmp  TYPE STANDARD TABLE OF zotc_order_ack_sch_item, " Order Acknowledgement Schedule Line Item data
    li_konv      TYPE STANDARD TABLE OF lty_konv,                "Conditions
    li_status    TYPE STANDARD TABLE OF  zdev_enh_status,         " Internal table for Enhancement Status
*Begin of insert for D3_OTC_FDD_0012 by U034336
    li_knmt      TYPE STANDARD TABLE OF lty_knmt INITIAL SIZE 0,
    lwa_knmt     TYPE lty_knmt,
*End of insert for D3_OTC_FDD_0012 by U034336
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
    li_vbkd      TYPE STANDARD TABLE OF lty_vbkd INITIAL SIZE 0, "Table for VBKD
    li_fpla      TYPE STANDARD TABLE OF lty_fpla INITIAL SIZE 0, "Table for FPLA
    li_fplt      TYPE STANDARD TABLE OF lty_fplt INITIAL SIZE 0, "table for FPLT
    li_konv_tmp  TYPE STANDARD TABLE OF lty_konv INITIAL SIZE 0.                "Conditions
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019


*Work Area
  DATA: lwa_item     TYPE zotc_cust_order_ack_item, "zotc_cust_order_ack_item,
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
        lwa_vbkd     TYPE lty_vbkd, " Wrk area for VBKD
        lwa_fplt     TYPE lty_fplt, " Wrk area for FPLT
        lwa_fpla     TYPE lty_fpla, " Wrk area for FPLA
        lwa_konv_tmp TYPE lty_konv, " Temp KONv table
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
        li_id_item   TYPE STANDARD TABLE OF ty_object_id_item, "Internal table for text id at item level
        lwa_id_item  TYPE ty_object_id_item,
        lv_langu1    TYPE sylangu,                              " Language Key of Current Text Environment
        lv_langu2    TYPE sylangu.                              " Language Key of Current Text Environment
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*Local variables
  DATA:
    lv_index            TYPE int2,               " Index of type Integers
    lv_adrnr_1          TYPE adrnr,            "Address Key
    lv_country_key1     TYPE char3,       "Country Key
    lv_name             TYPE tdobname,            "Object name - Order no+ item no
    lv_num              TYPE int2,                 " Num of type Numeric Text Fields
    lv_bmeng            TYPE char13,             "local variable for Confirmed Quantity
    lv_bmeng_abs        TYPE char13,         "local variable for Confirmed Quantity
    lv_matnr            TYPE matnr,              " Material Number
    lv_kwmeng           TYPE char18,            "kwmeng,                                  " Cumulative Order Quantity in Sales Units
    lv_kbmeng           TYPE char18,            "kbmeng.                                  " Cumulative confirmed quantity in sales unit
    lv_vrkme            TYPE char3,              " Vrkme of type CHAR3
    lv_back_ord_qty     TYPE char18,      " Back_ord_qty of type CHAR18
    lv_conf_qty         TYPE char18,          " Conf_qty of type CHAR18
    lv_text_z015        TYPE char255,        " Text_z015 of type CHAR255
    lv_zzitemref        TYPE char255,        " Zzitemref of type CHAR255
    lv_zzqouteref       TYPE char255,       " Zzqouteref of type CHAR255
    lv_zzlnref          TYPE char255,          " Zzlnref of type CHAR255
    lv_cuky             TYPE sycurr,              " Currency Key
    lv_unit_price       TYPE netwr_ap,      " Net value of the order item in document currency
    lv_ext_price        TYPE netwr_ap,       " Net value of the order item in document currency
    lv_dangergoods_fee1 TYPE kwert,   " Net value of the order item in document currency
    lv_subtotal_price1  TYPE netwr_ap, " Net value of the order item in document currency
    lv_handling_fee1    TYPE kwert,      " Net value of the order item in document currency
    lv_freight1         TYPE kwert,           " Net value of the order item in document currency
    lv_tax1             TYPE mwsbp,               " Net value of the order item in document currency
    lv_total_price1     TYPE netwr_ap,    " Net value of the order item in document currency
    lv_date             TYPE char10,              " Date of type CHAR10
    lv_year             TYPE char2,               " Year of type CHAR2
    lv_month            TYPE char2,              " Month of type CHAR2
    lv_day              TYPE char2,                " Day of type CHAR2
    lv_znet             TYPE kschl,               " Condition Type
    lv_zdng             TYPE kschl,               " Condition Type
    lv_zhdl             TYPE kschl,               " Condition Type
*Begin of insert for D3_OTC_FDD_0012 by U034336
    lv_sl_language      TYPE sylangu, " Language Key of Current Text Environment
    lv_sold_to_lang     TYPE tdspras, " Language key
    lv_cust_mat_text    TYPE char70,  " Cust_mat_text of type CHAR70
*End of insert for D3_OTC_FDD_0012 by U034336
    lv_ztfr             TYPE kschl, " Condition Type
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
    lv_order_match_flag TYPE flag, " General Flag
*---> Begin of Insert for D3_OTC_FDD_0012 Defect# #2427/2430 by PDEBARU
    lv_order_flag       TYPE flag, " General flag
*<--- End of Insert for D3_OTC_FDD_0012 Defect# #2427/2430 by PDEBARU
    lv_tabix            TYPE sytabix, " Index of Internal Tables
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
    lv_bmethod          TYPE char70,   " Short text for Billing Method
    lv_bfrequency       TYPE char70,   " Short text for Billing Frequency
    lv_bmethod_nam      TYPE tdobname,   " SO10 text for Billing Method
    lv_bfreq_nam        TYPE tdobname,   " SO10 text for Billing Frequency
    lv_bedat            TYPE char15,     " Contract start date
    lv_endat            TYPE char15,     " Contract end date
    lv_fkdat            TYPE char15,     " Billing date
    lv_recurring        TYPE char70,     " Recurring
    lv_bill_st_dt       TYPE char70,     " Billing start date
    lv_till             TYPE char70,     " Till
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
    li_kntyp            TYPE STANDARD TABLE OF fkk_ranges,
    lwa_kntyp           TYPE fkk_ranges.
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

** ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Local data declaration
  DATA: lv_mat_text TYPE char40. " Mat_text of type CHAR40
  DATA:
    lv_text_zvalues TYPE string,                    "String
    li_text_lines   TYPE STANDARD TABLE OF char30000. " Text_lines type standard ta of type CHAR30000
*Field Symbols
  FIELD-SYMBOLS :  <lfs_text_lines> TYPE char30000. " Text_line of type CHAR30000
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA

*Field symbols
  FIELD-SYMBOLS:
    <lfs_vbap>     TYPE lty_vbap,                  "Item Data
    <lfs_mcha>     TYPE lty_mcha,                  "Batches data
    <lfs_mch1>     TYPE lty_mch1,                  "Batches
    <lfs_lines>    TYPE tline,                   " SAPscript: Text Lines
    <lfs_vbep>     TYPE zotc_order_ack_sch_item, " Order Acknowledgement Schedule Line Item data
    <lfs_vbep1>    TYPE zotc_order_ack_sch_item, " Order Acknowledgement Schedule Line Item data
    <lfs_vbep_tmp> TYPE zotc_order_ack_sch_item, " Order Acknowledgement Schedule Line Item data
    <lfs_konv>     TYPE lty_konv,
    <lfs_status>   TYPE zdev_enh_status,            "For Reading enhancement table
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    <lfs_name>     TYPE lty_name.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*Local constants
  CONSTANTS: lc_id           TYPE tdid     VALUE '0001', " Material-sales text
             lc_slash        TYPE char1 VALUE '/',        " Slach of type CHAR1
             lc_null         TYPE z_criteria VALUE 'NULL', " Local Constant for  Enh. Criteria
             lc_id_z011      TYPE tdid VALUE 'Z011',    " Text ID
             lc_id_z015      TYPE tdid VALUE 'Z015',    " Text ID

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
             lc_id_z014      TYPE tdid VALUE 'Z014', " Text ID

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5141 by NSAXENA
*Commenting out the text id - Z017
*             lc_id_z017 TYPE tdid VALUE 'Z017',          " Text ID
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5141 by NSAXENA

             lc_ztfr         TYPE z_criteria VALUE 'ZCOND_ZTFR', " Condition Type
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
             lc_yes          TYPE kowrr VALUE 'Y',       " Statistical values
             lc_english      TYPE sylangu VALUE 'E', " Language Key of Current Text Environment
             lc_space        TYPE char1 VALUE ' ',     " Space of type CHAR1
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
             lc_object       TYPE tdobject VALUE 'VBBP',                   " Order item text
             lc_fdd_0012     TYPE z_enhancement VALUE 'D2_OTC_FDD_0012', "Enhancement number
             lc_znet         TYPE z_criteria VALUE 'COND_ZNET',              " Condition Type
             lc_zdng         TYPE z_criteria VALUE 'COND_ZDNG',              " Condition Type
             lc_zhdl         TYPE z_criteria VALUE 'COND_ZHDL',              " Condition Type
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4874 by NSAXENA
             lc_langu        TYPE z_criteria VALUE 'VKORG_LANGU', " Enh. Criteria
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4874 by NSAXENA
*Begin of insert for D3_OTC_FDD_0012 by U034336
             lc_tdid         TYPE tdid     VALUE 'ST',               " Text ID
             lc_tdobject     TYPE tdobject VALUE 'TEXT',             " Texts: Application Object
             lc_cust_mat     TYPE tdobname VALUE 'ZOTC_CUST_MAT_EU', " Name
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
             lc_order_type   TYPE z_criteria VALUE 'AUART',
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
             lc_bill_st_dt   TYPE tdobname   VALUE 'ZOTC_0012_BP_FIRST_DATE', " Bill date
             lc_recurring    TYPE tdobname   VALUE 'ZOTC_0012_RECURRING',    " Object Name
             lc_till         TYPE tdobname   VALUE 'ZOTC_0012_TILL',         " Object Name
             lc_mwst         TYPE kschl      VALUE 'MWST',                   " Condition type
             lc_fkrel_i      TYPE fkrel      VALUE 'I',                      " Relevant for Billing
             lc_fareg_4      TYPE fareg      VALUE '4',                      " Down payment in milestone billing on percentage basis
             lc_fareg_5      TYPE fareg      VALUE '5',                      " Down payment in milestone billing on a value basis
             lc_z_bmethod    TYPE z_criteria VALUE 'Z_BMETHOD',              " EMI criteria for Z_BMETHOD
             lc_z_bfrequency TYPE z_criteria VALUE 'Z_BFREQUENCY',           " EMI criteria for Z_BFREQUENCY
             lc_evergreen    TYPE z_criteria VALUE 'EVERGREEN',              " EMI criteria 'EVERGREEN'
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
             lc_zmw0         TYPE kschl      VALUE 'ZMW0',
             lc_kntyp        TYPE z_criteria VALUE 'KNTYP',
             lc_i            TYPE char_01    VALUE 'I',                   " Include constant
             lc_eq           TYPE char_02    VALUE 'EQ'.                  " EQ constant
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
  DATA: lv_document    TYPE kwert,           " Condition value for ZDOC
        lv_insurance   TYPE kwert,           " Condition value for ZINS
        lv_environment TYPE kwert,           " Condition value for ZENV
        lv_zins        TYPE kschl,           "Condition type ZINS
        lv_zdoc        TYPE kschl,           " Condition Type
        lv_zenv        TYPE kschl,           " Condition Type
        lv_tbd         TYPE tdline,          "Variable to store TBD
        lwa_status     TYPE zdev_enh_status, "Workarea for EMI entries
        lwa_lines      TYPE tline,           " Work area for standard text
        lwa_konv       TYPE lty_konv.        "Workarea for KONV table


  CONSTANTS: lc_zdoc TYPE z_criteria VALUE 'COND_ZDOC',            "Condition Type ZDOC
             lc_zins TYPE z_criteria VALUE 'COND_ZINS',            "Condition Type ZINS
             lc_zenv TYPE z_criteria VALUE 'COND_ZENV',            "Condition Type ZENV
             lc_tbd  TYPE tdobname  VALUE 'ZOTC_BIORAD_DATE_TBD'. " Object Name

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017


*Calling FM to check if the enhancement is active for object id
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_fdd_0012
    TABLES
      tt_enh_status     = li_status.
*Non active entries are removed.
*This table will not result out in many entries
  DELETE li_status WHERE active EQ abap_false.

*Since this table does not result out in many entries
*so binary search is not used
*First of all criteria “NULL” in LI_STATUS is checked ,If it has Active flag as “X”.
*Binary search not done as numnber of entries are less
  READ TABLE li_status WITH KEY criteria = lc_null TRANSPORTING NO FIELDS. "NULL.
  IF sy-subrc EQ 0.
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_znet.
*For condtion type ZNET
    IF sy-subrc EQ 0.
      lv_znet = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc EQ 0

*Since this table does not result out in many entries
*so binary search is not used in the folloeing read statements
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

*Since this table does not result out in many entries
*so binary search is not used
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4874 by NSAXENA
*Read table to get the language code based on the company code comaprision
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_langu
                                                         sel_low = fp_header-vkorg.

*For language check
    IF sy-subrc EQ 0.
      fp_langu = <lfs_status>-sel_high.
*Begin of insert for D3_OTC_FDD_0012 by U034336
    ELSE. " ELSE -> IF sy-subrc EQ 0

      fp_langu = fp_header-sold_to_lang.

*End of insert for D3_OTC_FDD_0012 by U034336

    ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4874 by NSAXENA

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*For condtion type ZDOC
    READ TABLE li_status INTO lwa_status WITH KEY criteria = lc_zdoc.
    IF sy-subrc EQ 0.
      lv_zdoc = lwa_status-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    CLEAR lwa_status.
*For condition type ZINS
    READ TABLE li_status INTO lwa_status WITH KEY criteria = lc_zins.
    IF sy-subrc EQ 0.
      lv_zins = lwa_status-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    CLEAR lwa_status.

*For condition type ZENV
    READ TABLE li_status INTO lwa_status WITH KEY criteria = lc_zenv.
    IF sy-subrc EQ 0.
      lv_zenv = lwa_status-sel_low.
    ENDIF. " IF sy-subrc EQ 0

    CLEAR lwa_status.

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*Select currency code from table vbak
    lv_cuky = fp_header-waerk.
*&--Fetch Item data from VBAP
    SELECT vbeln      " Sales Document
           posnr      "Item No.
           matnr      "Material Number
           charg      "Batch
           arktx      "Description
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
           fkrel      " Relevant for Billing
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
           uepos      " Higher-level item in bill of material structures
           zmeng      " Target quantity in sales units
           zieme      " Target quantity UoM
           netwr      "Net Price
           waerk      "Document Currency
           kwmeng     "Quantity
           kbmeng     " Cumulative confirmed quantity in sales unit
           vrkme      " UOM  Added by SBASU Def 1833
           werks      " Plant (Own or External)
           stlnr      " Bill of material
           kzwi1      " Subtotal 1 from pricing procedure for condition
           kowrr      " Statistical values
           mwsbp      " Tax amount in document currency
           zzagmnt    " Warr / Serv Plan ID
           zzitemref  " ServMax Obj ID
           zzquoteref " Legacy Qtn Ref
           zzlnref    " Instrument Reference
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
           zz_bilmet  " Billing Method
           zz_bilfr   " Billing Frequency
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
      FROM vbap       " Sales Document: Item Data
      INTO TABLE li_vbap
     WHERE vbeln = fp_vbeln
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #6209 by NSAXENA
*Added code for discarding the rejcted line items.
     AND abgru = space.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #6209 by NSAXENA
    IF sy-subrc = 0.

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
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

*      Fetch the Billing plan no and Contract dates for the Sales Order
      SELECT fplnr           " Billing Plan Number / Invoicing Plan Number
             bedat            " Start date for billing plan/invoice plan
             endat            " End date billing plan/invoice plan
             FROM fpla       " Billing Plan
             INTO TABLE li_fpla
             WHERE vbeln  = fp_vbeln.

      IF sy-subrc = 0 .
        SORT li_fpla BY fplnr.
*      Fetch the Billing start Date for the billing no
        SELECT fplnr      " Billing Plan Number / Invoicing Plan Number
               fpltr      " Item for billing plan/invoice plan/payment cards
               fkdat      " Settlement date for deadline
              FROM fplt   " Billing Plan: Dates
              INTO TABLE li_fplt
              FOR ALL ENTRIES IN li_fpla
              WHERE fplnr = li_fpla-fplnr
              AND   ( fareg NE lc_fareg_4 OR fareg NE lc_fareg_5 ).

        IF sy-subrc = 0.
*            Do nothing
        ENDIF." IF sy-subrc = 0.->SELECT fplnr...FROM fplt
      ENDIF." IF sy-subrc = 0 AND lwa_fpla-fplnr IS NOT INITIAL.

*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019


*Begin of insert for D3_OTC_FDD_0012 by U034336

      li_vbap_tmp1[] = li_vbap[].
      SORT li_vbap_tmp1[] BY matnr.
      DELETE ADJACENT DUPLICATES FROM li_vbap_tmp1[] COMPARING matnr.
      IF li_vbap_tmp1[] IS NOT INITIAL.

        SELECT vkorg " Sales Organization
               vtweg " Distribution Channel
               kunnr " Customer number
               matnr " Material Number
               kdmat " Material Number Used by Customer
         FROM knmt   " Customer-Material Info Record Data Table
          INTO TABLE li_knmt
         FOR ALL ENTRIES IN li_vbap_tmp1
         WHERE vkorg = fp_header-vkorg
         AND   vtweg = fp_header-vtweg
         AND   kunnr = fp_kunnr
         AND   matnr = li_vbap_tmp1-matnr.
        IF sy-subrc EQ 0.
          SORT li_knmt BY matnr.
          CLEAR: li_vbap_tmp1[].

          lv_sold_to_lang = fp_langu.

          CALL FUNCTION 'READ_TEXT'
            EXPORTING
              id                      = lc_tdid
              language                = lv_sold_to_lang
              name                    = lc_cust_mat
              object                  = lc_tdobject
            TABLES
              lines                   = li_lines
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
              MOVE <lfs_lines>-tdline TO lv_cust_mat_text.
            ENDIF. " IF sy-subrc EQ 0
            UNASSIGN <lfs_lines>.
          ENDIF. " IF sy-subrc EQ 0

        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF li_vbap_tmp1[] IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*For calculating tax we will move the item details to seperate internal table
*The Tax will be calculated for BOM Items which will contain all the VBAP line item except the
*line item where KOWRR = 'Y' i.e. the header one, so will delete that entry from internal table
*and calculate the total tax value - VBAP-MWSBP.
      li_vbap_tmp1[] = li_vbap[].
*Deletion where kowrr field is equals to 'Y'.
      DELETE li_vbap_tmp1 WHERE kowrr EQ lc_yes.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*To print details at item level remove where uepos is not blank.
      DELETE li_vbap WHERE uepos IS NOT INITIAL.
*&-- Begin of Changes for HANAtization on OTC_FDD_0012 by U106341 on 22-Aug-2019 in E1SK901453
      SORT li_vbap.
*&-- End of Changes for HANAtization on OTC_FDD_0012 by U106341 on 22-Aug-2019 in E1SK901453
      DELETE ADJACENT DUPLICATES FROM li_vbap COMPARING ALL FIELDS.
      SORT li_vbap BY vbeln posnr.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
      CLEAR: lv_name.
      REFRESH li_id_item[].
*Inserting the text ids at item level so that based on these text id we will fetch the data
*from STXH table and then we will read individual text id at item level as per language and other
*input parameter
      LOOP AT li_vbap ASSIGNING <lfs_vbap>.
        CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
        lwa_id_item-name = lv_name.
        lwa_id_item-id = lc_id_z014. "Text id Z014
        APPEND lwa_id_item TO li_id_item.
        lwa_id_item-name = lv_name.
        lwa_id_item-id = lc_id. "Text id 0001
        APPEND lwa_id_item TO li_id_item.
        lwa_id_item-name = lv_name.
        lwa_id_item-id = lc_id_z011. "Text id Z011
        APPEND lwa_id_item TO li_id_item.
        lwa_id_item-name = lv_name.
        lwa_id_item-id = lc_id_z015. "Text id Z015
        APPEND lwa_id_item TO li_id_item.
        CLEAR lv_name.
      ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
*Checking the language that is fetched from EMI Table based on sales org.
*For French case the language passed will be F_E so keeping a check on it
*If the sales org = 1020 , langu = F_E then we need to check first for french text then for englsih text.
      IF fp_langu CS '_'.
        SPLIT fp_langu AT '_' INTO lv_langu1  "French
                                   lv_langu2. "English
      ELSE. " ELSE -> IF fp_langu CS '_'
        lv_langu1 = fp_langu.
        lv_langu2 = lc_space.
      ENDIF. " IF fp_langu CS '_'
*Check if the text id table is not blank.
      IF li_id_item[] IS NOT INITIAL.
*Begin of delete for D3_OTC_FDD_0012 by U034336
*        CLEAR lv_langu1.
*End of delete for D3_OTC_FDD_0012 by U034336
        SELECT tdobject                         " Texts: Application Object
                   tdname                       " Name
                   tdid                         " Text ID
                   tdspras                      " Language Key
                   FROM stxh                    " STXD SAPscript text file header
                   INTO TABLE li_name
                  FOR ALL ENTRIES IN li_id_item "internal table for Item level text id
                   WHERE tdobject = lc_object   "Objecr id
                   AND tdname = li_id_item-name "Name
                   AND tdid = li_id_item-id     "Text ids
                   AND tdspras = lv_langu1.     "language key
        IF sy-subrc EQ 0.
          SORT li_name BY name id.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF li_id_item[] IS NOT INITIAL
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

* ---> Begin of Insert for D2_OTC_FDD_0012  by NSAXENA
      READ TABLE li_vbap ASSIGNING <lfs_vbap> INDEX 1.
      IF sy-subrc EQ 0.
        SELECT SINGLE adrnr " Address
             INTO lv_adrnr_1
             FROM t001w     " Plants/Branches
          WHERE werks = <lfs_vbap>-werks.
        IF sy-subrc EQ 0.
          SELECT SINGLE country " Country Key
            FROM adrc           " Addresses (Business Address Services)
            INTO lv_country_key1
            WHERE addrnumber = lv_adrnr_1.
          IF sy-subrc EQ 0.
            fp_country_key = lv_country_key1.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
*--- End of Insert for D2_OTC_FDD_0012 by NSAXENA
*&--Fetch Planned Ship Date from Schedule Line Data
      SELECT vbeln " Sales Document
             posnr "Item No.
             etenr "Delivery Schedule Line Number
             edatu "Planned Ship Date
             bmeng "Confirmed Quantity
        FROM vbep  " Sales Document: Schedule Line Data
        INTO TABLE fp_i_sch_item
     FOR ALL ENTRIES IN li_vbap
       WHERE vbeln = fp_vbeln
         AND posnr = li_vbap-posnr.
      IF sy-subrc = 0.
        SORT fp_i_sch_item BY posnr edatu ASCENDING.
      ENDIF. " IF sy-subrc = 0

      li_vbap_tmp[] = li_vbap[].
      SORT li_vbap_tmp BY matnr charg.
      DELETE ADJACENT DUPLICATES FROM li_vbap_tmp COMPARING matnr charg.
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
* ---> Begin of Change for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
             kbetr " Condition rate
* <--- End of Change for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
             kntyp  " Condition category (examples: tax, freight, price, cost)
             kstat  " Condition is used for statistics
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-Mar-2019
             kwert     " Condition value
             FROM konv " Conditions (Transaction Data)
             INTO TABLE li_konv
             WHERE knumv = fp_header-knumv.
      IF sy-subrc EQ 0.
        SORT li_konv BY kposn kschl.
      ENDIF. " IF sy-subrc EQ 0
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_order_type
                                                           sel_low  = fp_auart.
      IF sy-subrc EQ 0.
        lv_order_match_flag = abap_true.
*---> Begin of Insert for D3_OTC_FDD_0012 Defect# #2427/2430 by PDEBARU
      ELSE. " ELSE -> IF sy-subrc EQ 0
        lv_order_flag = abap_true.
*<--- End of Insert for D3_OTC_FDD_0012 Defect# #2427/2430 by PDEBARU

      ENDIF. " IF sy-subrc EQ 0

*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
*&--Merging Item data and Batches data
      LOOP AT li_vbap ASSIGNING <lfs_vbap>.

        lwa_item-posnr  = <lfs_vbap>-posnr. "Position number

        lv_matnr        = <lfs_vbap>-matnr.
        IF NOT lv_matnr EQ lwa_item-matnr.
          lwa_item-matnr  = <lfs_vbap>-matnr. "material number
        ENDIF. " IF NOT lv_matnr EQ lwa_item-matnr
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Material Description from VBAP Table
        IF <lfs_vbap>-arktx IS NOT INITIAL.
          lv_mat_text = <lfs_vbap>-arktx.
* Begin of insert for D3_OTC_FDD_0012, Defect#5472 by U034336
* Get materail description
          lwa_item-arktx = <lfs_vbap>-arktx.
* End of insert for D3_OTC_FDD_0012, Defect#5472 by U034336
        ENDIF. " IF <lfs_vbap>-arktx IS NOT INITIAL
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
        CLEAR: lv_name.
        REFRESH: li_lines[].
        CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read text with text id Z014
        READ TABLE li_name ASSIGNING <lfs_name> WITH KEY name = lv_name
                                                         id = lc_id_z014
                                                         BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
        IF sy-subrc NE 0.
          lv_langu1 = lc_english.
        ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*FM to read text lines for External product text with text id Z014
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id_z014 "Id
            language                = lv_langu1  "lang
            name                    = lv_name    "Sales ord number
            object                  = lc_object  "Object Id
          TABLES
            lines                   = li_lines   "Text lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Calling FM to convert the text line table data into string
          CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
            EXPORTING
              language    = lv_langu1      "language
              lf          = ' '
            TABLES
              itf_text    = li_lines       "Text line data
              text_stream = li_text_lines. "String format
          IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
            LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
              MOVE <lfs_text_lines> TO lv_text_zvalues.
* Begin of delete for D3_OTC_FDD_0012, Defect#5472 by U034336
* Separate material desc and Z014 id text , for that this part of code
* is commented
*              CONCATENATE lwa_item-arktx lv_text_zvalues INTO lwa_item-arktx
*             SEPARATED BY space.
* End of delete for D3_OTC_FDD_0012, Defect#5472 by U034336
* Begin of insert for D3_OTC_FDD_0012, Defect#5472 by U034336
* Do not concatenate material desc with Z014 id text
* They have been separted into two different lines
              CONCATENATE lwa_item-ext_prod_text lv_text_zvalues INTO lwa_item-ext_prod_text
             SEPARATED BY space.
              CONDENSE lwa_item-ext_prod_text.
* End of insert for D3_OTC_FDD_0012, Defect#5472 by U034336
            ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
          ENDIF. " IF sy-subrc EQ 0

*Begin of insert for D3_OTC_FDD_0012 CR#289 by U034336
        ELSE. " ELSE -> IF sy-subrc = 0
          IF lv_langu1 NE lc_english.

            CALL FUNCTION 'READ_TEXT'
              EXPORTING
                id                      = lc_id_z014 "Id
                language                = lc_english "lang
                name                    = lv_name    "Sales ord number
                object                  = lc_object  "Object Id
              TABLES
                lines                   = li_lines   "Text lines
              EXCEPTIONS
                id                      = 1
                language                = 2
                name                    = 3
                not_found               = 4
                object                  = 5
                reference_check         = 6
                wrong_access_to_archive = 7
                OTHERS                  = 8.
            IF sy-subrc = 0.

*Calling FM to convert the text line table data into string
              CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
                EXPORTING
                  language    = lv_langu1      "language
                  lf          = ' '
                TABLES
                  itf_text    = li_lines       "Text line data
                  text_stream = li_text_lines. "String format
              IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
                LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
                  MOVE <lfs_text_lines> TO lv_text_zvalues.

                  CONCATENATE lwa_item-ext_prod_text lv_text_zvalues INTO lwa_item-ext_prod_text
                 SEPARATED BY space.
                  CONDENSE lwa_item-ext_prod_text.

                ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc = 0

          ENDIF. " IF lv_langu1 NE lc_english
*End of insert for D3_OTC_FDD_0012 CR#289 by U034336

        ENDIF. " IF sy-subrc = 0
        CLEAR: lv_text_zvalues,
               lv_name.
        REFRESH: li_text_lines[],
                 li_lines[].
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA

*Check if the External product text is blank then
*only read the text with id Z017 else skip it.

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5141 by NSAXENA
*Commenting out the z017 text reading part for defect - 5141.

*        IF lwa_item-arktx IS INITIAL.
*          CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
**FM to read text lines for detailed product description
*          CALL FUNCTION 'READ_TEXT'
*            EXPORTING
*              id                      = lc_id_z017 "Id
*              language                = sy-langu   "lang
*              name                    = lv_name    "Sales ord number
*              object                  = lc_object  "Object Id
*            TABLES
*              lines                   = li_lines   "Text lines
*            EXCEPTIONS
*              id                      = 1
*              language                = 2
*              name                    = 3
*              not_found               = 4
*              object                  = 5
*              reference_check         = 6
*              wrong_access_to_archive = 7
*              OTHERS                  = 8.
*          IF sy-subrc = 0.
*
** ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
**Calling FM to convert the text line table data into string
*            CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
*              EXPORTING
*                language    = sy-langu       "language
*                lf          = ' '
*              TABLES
*                itf_text    = li_lines       "Text lines
*                text_stream = li_text_lines. "String format
*            IF sy-subrc EQ 0.
**Add this string into proxy structure field z01otc_zline_text
*              LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
*                MOVE <lfs_text_lines> TO lv_text_zvalues.
*                CONCATENATE lwa_item-arktx lv_text_zvalues INTO lwa_item-arktx
*               SEPARATED BY space.
*              ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
*            ENDIF. " IF sy-subrc EQ 0
*          ENDIF. " IF sy-subrc = 0
*        ENDIF. " IF lwa_item-arktx IS INITIAL
*Combine the material Description into item level text field.
*  CLEAR:lv_text_zvalues,
*        lv_name.
*        REFRESH: li_text_lines[],
*                 li_lines[].
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5141 by NSAXENA
* Begin of delete for D3_OTC_FDD_0012, Defect#5480 by U034336
* To Separate material desc and material sales text, this code
* is commented
*        CONCATENATE lv_mat_text lwa_item-arktx INTO lwa_item-arktx SEPARATED BY space.
* End of delete for D3_OTC_FDD_0012, Defect#5480 by U034336
* <--- End of Insert for D2_OTC_FDD_0012,Defect 4073 by NSAXENA
        CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read text with text id - 0001.
        READ TABLE li_name ASSIGNING <lfs_name> WITH KEY name = lv_name
                                                         id = lc_id
                                                         BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
        IF sy-subrc NE 0.
          lv_langu1 = lc_english.
        ENDIF. " IF sy-subrc NE 0

* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*FM to read text lines for material description
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id     "Id
            language                = lv_langu1 "lang
            name                    = lv_name   "Sales ord number
            object                  = lc_object "Object Id
          TABLES
            lines                   = li_lines  "Text lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Calling FM to convert the text line table data into string
          CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
            EXPORTING
              language    = lv_langu1      "Language
              lf          = ' '
            TABLES
              itf_text    = li_lines       "Text lines
              text_stream = li_text_lines. "String format
          IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
            LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
              MOVE <lfs_text_lines> TO lv_text_zvalues.
              CONCATENATE lwa_item-sales_text lv_text_zvalues INTO lwa_item-sales_text
             SEPARATED BY space.
            ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc = 0
        CLEAR: lv_text_zvalues,
       lv_name.
        REFRESH: li_text_lines[],
                 li_lines[].

* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
        CONDENSE lwa_item-sales_text.
        UNASSIGN <lfs_lines>.
        CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read text with text id - z011
        READ TABLE li_name ASSIGNING <lfs_name> WITH KEY name = lv_name
                                                         id = lc_id_z011
                                                         BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
        IF sy-subrc NE 0.
          lv_langu1 = lc_english.
        ENDIF. " IF sy-subrc NE 0
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        IF fp_langu IS NOT INITIAL.
          lv_langu1 = fp_langu.
        ENDIF.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id_z011 "Id
            language                = lv_langu1  "lang
            name                    = lv_name    "Sales order number
            object                  = lc_object  "Object id
          TABLES
            lines                   = li_lines   "Text lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Calling FM to convert the text line table data into string
          CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
            EXPORTING
              language    = lv_langu1      "Language
              lf          = ' '
            TABLES
              itf_text    = li_lines       "Text lines
              text_stream = li_text_lines. "String format
          IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
            LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
              MOVE <lfs_text_lines> TO lv_text_zvalues.
* Begin of delete for D3_OTC_FDD_0012, Defect#5480 by U034336
* This code is commented as ext line text needs to be displayed in
* a new line
*              CONCATENATE lwa_item-sales_text lv_text_zvalues INTO lwa_item-sales_text
*             SEPARATED BY space.
* End of delete for D3_OTC_FDD_0012, Defect#5480 by U034336
* Begin of insert for D3_OTC_FDD_0012, Defect#5480 by U034336
* Ext line text has been displayed in new line
              CONCATENATE lwa_item-ext_line_text lv_text_zvalues INTO lwa_item-ext_line_text.
* Begin of insert for D3_OTC_FDD_0012, Defect#5480 by U034336
            ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
          ENDIF. " IF sy-subrc EQ 0


*Begin of insert for D3_OTC_FDD_0012 CR#289 by U034336
        ELSE. " ELSE -> IF sy-subrc = 0
          IF lv_langu1 NE lc_english.

            CALL FUNCTION 'READ_TEXT'
              EXPORTING
                id                      = lc_id_z011 "Id
                language                = lc_english "lang
                name                    = lv_name    "Sales order number
                object                  = lc_object  "Object id
              TABLES
                lines                   = li_lines   "Text lines
              EXCEPTIONS
                id                      = 1
                language                = 2
                name                    = 3
                not_found               = 4
                object                  = 5
                reference_check         = 6
                wrong_access_to_archive = 7
                OTHERS                  = 8.
            IF sy-subrc = 0.

*Calling FM to convert the text line table data into string
              CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
                EXPORTING
                  language    = lv_langu1      "Language
                  lf          = ' '
                TABLES
                  itf_text    = li_lines       "Text lines
                  text_stream = li_text_lines. "String format
              IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
                LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
                  MOVE <lfs_text_lines> TO lv_text_zvalues.

                  CONCATENATE lwa_item-ext_line_text lv_text_zvalues INTO lwa_item-ext_line_text.

                ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
              ENDIF. " IF sy-subrc EQ 0

            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_langu1 NE lc_english
*End of insert for D3_OTC_FDD_0012 CR#289 by U034336
        ENDIF. " IF sy-subrc = 0

        CLEAR:lv_text_zvalues,
              lv_name.
        REFRESH: li_lines[],
                 li_text_lines[].
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
        UNASSIGN <lfs_lines>.
        CONDENSE lwa_item-sales_text.
        CONCATENATE fp_vbeln <lfs_vbap>-posnr INTO lv_name.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read text with text id - z015
        READ TABLE li_name ASSIGNING <lfs_name> WITH KEY name = lv_name
                                                         id = lc_id_z015
                                                         BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
        IF sy-subrc NE 0.
          lv_langu1 = lc_english.
        ENDIF. " IF sy-subrc NE 0
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        IF fp_langu IS NOT INITIAL.
          lv_langu1 = fp_langu.
        ENDIF.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read text lines with id Z015
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id_z015 "Id
            language                = lv_langu1  "lang
            name                    = lv_name    "Sales order number
            object                  = lc_object  "Object id
          TABLES
            lines                   = li_lines   "Text lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Calling FM to convert the text line table data into string
          CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
            EXPORTING
              language    = lv_langu1
              lf          = ' '
            TABLES
              itf_text    = li_lines
              text_stream = li_text_lines.
          IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
            LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
              MOVE <lfs_text_lines> TO lv_text_zvalues.
*For first line it should print with Promotion
              IF sy-tabix EQ 1.
                CONCATENATE 'Promotion'(001) lv_text_zvalues INTO lwa_item-promo_text
               SEPARATED BY space.
*Concatenate other text lines
              ELSE. " ELSE -> IF sy-tabix EQ 1
                CONCATENATE lwa_item-promo_text lv_text_zvalues INTO lwa_item-promo_text SEPARATED BY space.
              ENDIF. " IF sy-tabix EQ 1
            ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
          ENDIF. " IF sy-subrc EQ 0
*Begin of insert for D3_OTC_FDD_0012 CR#289 by U034336
        ELSE. " ELSE -> IF sy-subrc = 0
          IF lv_langu1 NE lc_english.

            CALL FUNCTION 'READ_TEXT'
              EXPORTING
                id                      = lc_id_z015 "Id
                language                = lc_english "lang
                name                    = lv_name    "Sales order number
                object                  = lc_object  "Object id
              TABLES
                lines                   = li_lines   "Text lines
              EXCEPTIONS
                id                      = 1
                language                = 2
                name                    = 3
                not_found               = 4
                object                  = 5
                reference_check         = 6
                wrong_access_to_archive = 7
                OTHERS                  = 8.
            IF sy-subrc = 0.
*Calling FM to convert the text line table data into string
              CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
                EXPORTING
                  language    = lv_langu1
                  lf          = ' '
                TABLES
                  itf_text    = li_lines
                  text_stream = li_text_lines.
              IF sy-subrc EQ 0.
*Pass this string into proxy structure field z01otc_zline_text
                LOOP AT li_text_lines ASSIGNING <lfs_text_lines>.
                  MOVE <lfs_text_lines> TO lv_text_zvalues.
*For first line it should print with Promotion
                  IF sy-tabix EQ 1.
                    CONCATENATE 'Promotion'(001) lv_text_zvalues INTO lwa_item-promo_text
                   SEPARATED BY space.
*Concatenate other text lines
                  ELSE. " ELSE -> IF sy-tabix EQ 1
                    CONCATENATE lwa_item-promo_text lv_text_zvalues INTO lwa_item-promo_text SEPARATED BY space.
                  ENDIF. " IF sy-tabix EQ 1
                ENDLOOP. " LOOP AT li_text_lines ASSIGNING <lfs_text_lines>
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_langu1 NE lc_english
*End of insert for D3_OTC_FDD_0012 CR#289 by U034336

        ENDIF. " IF sy-subrc = 0
        CLEAR: lv_text_zvalues,
               lv_name.
        REFRESH: li_lines[],
                 li_text_lines[].
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073,CR by NSAXENA
        CONDENSE lwa_item-promo_text.
        UNASSIGN <lfs_lines>.
*Check for ServiceMax Obj ID
        IF <lfs_vbap>-zzitemref IS NOT INITIAL.
          CONCATENATE 'ServiceMax Obj ID'(002) <lfs_vbap>-zzitemref INTO lv_zzitemref SEPARATED BY space.
        ENDIF. " IF <lfs_vbap>-zzitemref IS NOT INITIAL
*check for Qoute ref
        IF <lfs_vbap>-zzquoteref IS NOT INITIAL.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
*Only Change in the description from Quote Ref to Qoute.
          CONCATENATE 'Quote'(003) <lfs_vbap>-zzquoteref INTO lv_zzqouteref SEPARATED BY space.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4073 by NSAXENA
        ENDIF. " IF <lfs_vbap>-zzquoteref IS NOT INITIAL
*Check for Instrument ref
        IF <lfs_vbap>-zzlnref IS NOT INITIAL.
          CONCATENATE 'Instrument Ref'(004) <lfs_vbap>-zzlnref INTO lv_zzlnref SEPARATED BY space.
        ENDIF. " IF <lfs_vbap>-zzlnref IS NOT INITIAL
        CONCATENATE lv_zzitemref lv_zzqouteref lv_zzlnref  INTO lwa_item-qoute_text SEPARATED BY space.
        CONDENSE lwa_item-qoute_text.

        lwa_item-charg  = <lfs_vbap>-charg. "Batch number
*Order qty
        lv_kwmeng = trunc( <lfs_vbap>-kwmeng ).
        IF lv_kwmeng EQ <lfs_vbap>-kwmeng.
          lwa_item-kwmeng = lv_kwmeng.
        ELSE. " ELSE -> IF lv_kwmeng EQ <lfs_vbap>-kwmeng
          lwa_item-kwmeng = <lfs_vbap>-kwmeng.
        ENDIF. " IF lv_kwmeng EQ <lfs_vbap>-kwmeng
        CONDENSE lwa_item-kwmeng.

*Begin of insert for D3_OTC_FDD_0012 by U034336
*Convert UOM for respective sold to cust lang
        IF fp_header-d3_format_flag IS NOT INITIAL.

          lv_sl_language = fp_langu.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = <lfs_vbap>-vrkme
              language       = lv_sl_language
            IMPORTING
              output         = lwa_item-vrkme
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc EQ 0.
            lv_vrkme = lwa_item-vrkme.
            CLEAR: lv_sl_language.
          ENDIF. " IF sy-subrc EQ 0

        ELSE. " ELSE -> IF fp_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336

          lwa_item-vrkme  = <lfs_vbap>-vrkme.
          lv_vrkme = lwa_item-vrkme.

*Begin of insert for D3_OTC_FDD_0012 by U034336
        ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336

        CONCATENATE lwa_item-kwmeng lv_vrkme INTO lwa_item-quantity SEPARATED BY space. "Order Qty
*For Back Order quantity
        lv_kbmeng = trunc( <lfs_vbap>-kbmeng ).
        IF lv_kbmeng EQ <lfs_vbap>-kbmeng.
          lwa_item-kbmeng = lv_kbmeng.
        ELSE. " ELSE -> IF lv_kbmeng EQ <lfs_vbap>-kbmeng
          lwa_item-kbmeng = <lfs_vbap>-kbmeng.
        ENDIF. " IF lv_kbmeng EQ <lfs_vbap>-kbmeng
        lv_back_ord_qty = lwa_item-kwmeng - lwa_item-kbmeng. "Back Order Qty
        CONDENSE lv_back_ord_qty.
        CONCATENATE lv_back_ord_qty lv_vrkme INTO lwa_item-back_ord_qty SEPARATED BY space.
*
        lwa_item-stlnr = <lfs_vbap>-stlnr. "Bill of material
        lwa_item-uepos = <lfs_vbap>-uepos. "Higher-level item in bill of material structures
        lwa_item-kzwi1 = <lfs_vbap>-kzwi1. "Subtotal 1 from pricing procedure for condition
        lwa_item-zmeng = <lfs_vbap>-zmeng. "Target quantity in sales units
*        lwa_item-mwsbp   = <lfs_vbap>-mwsbp. "Tax amount in document currency

        lwa_item-netwr = <lfs_vbap>-netwr. "Net price
        lwa_item-waerk  = <lfs_vbap>-waerk.
*Unit Price
        READ TABLE li_konv ASSIGNING <lfs_konv> WITH KEY kposn = lwa_item-posnr
                                                         kschl = lv_znet
                                                         BINARY SEARCH.
        IF sy-subrc EQ 0.
* ---> Begin of Change for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
*As part of defect, 5935 the logic for unit price and extended price has been changed.
*hence commenting the previous logic and keeping new logic.
*          IF lwa_item-kwmeng IS NOT INITIAL.
*            lv_unit_price = <lfs_konv>-kwert / lwa_item-kwmeng.
*          ENDIF. " IF lwa_item-kwmeng IS NOT INITIAL
*Unit Price calculations
          lv_unit_price = <lfs_konv>-kbetr. "Condition Amount
*Extended price calculations
          lv_ext_price  = <lfs_konv>-kwert. "Condition value
* <--- End of Change for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
*   ---> Begin of Defect 8533
        ELSE. " ELSE -> IF sy-subrc EQ 0
          IF <lfs_vbap>-kwmeng IS NOT INITIAL.
            lv_unit_price = <lfs_vbap>-kzwi1 / <lfs_vbap>-kwmeng.
          ENDIF. " IF <lfs_vbap>-kwmeng IS NOT INITIAL

          lv_ext_price = <lfs_vbap>-kzwi1.
*  <---  End of Defect 8533
        ENDIF. " IF sy-subrc EQ 0



        WRITE lv_unit_price TO lwa_item-unit_price CURRENCY lv_cuky.
        CONDENSE lwa_item-unit_price.
* ---> Begin of Change for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
*Commented out as a part of defect 5935 - Extended price
*        lv_ext_price =  lv_unit_price * lwa_item-kwmeng.
* <--- End of Change for D2_OTC_FDD_0012,Defect #5935 by NSAXENA
        WRITE lv_ext_price TO lwa_item-ext_price CURRENCY lv_cuky.
        CONDENSE lwa_item-ext_price.
*Subtotal price
        lv_subtotal_price1 =  lv_subtotal_price1 + lv_ext_price.

        lwa_item-waerk  = <lfs_vbap>-waerk.

*Begin of insert for D3_OTC_FDD_0012 by U034336
*Convert UOM for respective sold to cust lang
        IF fp_header-d3_format_flag IS NOT INITIAL.

          lv_sl_language = fp_langu.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = <lfs_vbap>-zieme
              language       = lv_sl_language
            IMPORTING
              output         = lwa_item-zieme
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc EQ 0.
            CLEAR:  lv_sl_language.
          ENDIF. " IF sy-subrc EQ 0
        ELSE. " ELSE -> IF fp_header-d3_format_flag IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336
          lwa_item-zieme = <lfs_vbap>-zieme.

*Begin of insert for D3_OTC_FDD_0012 by U034336
        ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336

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
              lwa_item-edatu = <lfs_mch1>-vfdat.
            ENDIF. " IF sy-subrc EQ 0
          ELSE. " ELSE -> IF <lfs_mcha>-vfdat IS INITIAL
            lwa_item-edatu = <lfs_mcha>-vfdat.
          ENDIF. " IF <lfs_mcha>-vfdat IS INITIAL
        ELSE. " ELSE -> IF sy-subrc = 0
          READ TABLE li_mch1 ASSIGNING <lfs_mch1> WITH KEY matnr = <lfs_vbap>-matnr
                                                       charg = <lfs_vbap>-charg
                                              BINARY SEARCH.
          IF sy-subrc EQ 0.
            lwa_item-edatu = <lfs_mch1>-vfdat.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc = 0
        CONDENSE lwa_item-edatu.

        IF lwa_item-edatu IS NOT INITIAL.

*Begin of insert for D3_OTC_FDD_0012 by U034336
*Convert date for respective sold to cust lang
          IF fp_header-d3_format_flag IS NOT INITIAL.

            PERFORM f_convert_date_format USING   li_status
                                                  lwa_item-edatu
                                                   fp_header
                                          CHANGING lwa_item-edatu.

          ELSE. " ELSE -> IF fp_header-d3_format_flag IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336
            lv_date = lwa_item-edatu.
            lv_year = lv_date+2(2).
            lv_month = lv_date+4(2).
            lv_day = lv_date+6(2).
            CONCATENATE lv_month lv_day lv_year INTO lwa_item-edatu SEPARATED BY lc_slash.

*Begin of insert for D3_OTC_FDD_0012 by U034336
          ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336

        ENDIF. " IF lwa_item-edatu IS NOT INITIAL
        CLEAR: lv_date,
        lv_month,
        lv_year,
        lv_day.
*For Confirmed Quantity and ship date

        li_vbep[] = fp_i_sch_item[].
        li_vbep_tmp[] = fp_i_sch_item[].


        READ TABLE li_vbep ASSIGNING <lfs_vbep> WITH KEY posnr = <lfs_vbap>-posnr
                                                                    BINARY SEARCH.
        IF sy-subrc EQ 0.

          lv_index = sy-tabix.

          LOOP AT li_vbep ASSIGNING <lfs_vbep> FROM lv_index. "WHERE posnr = <lfs_vbap>-posnr.
*          IF sy-subrc IS INITIAL.
            IF <lfs_vbep>-posnr NE <lfs_vbap>-posnr.
              EXIT.
            ENDIF. " IF <lfs_vbep>-posnr NE <lfs_vbap>-posnr

            IF <lfs_vbep>-bmeng IS NOT INITIAL.
*            lv_bmeng_abs = abs( <lfs_vbep>-bmeng ).   " Change by ASK on 01/14/15
              lv_bmeng_abs = ceil( <lfs_vbep>-bmeng ). " Change by ASK on 01/14/15
              IF lv_bmeng_abs EQ <lfs_vbep>-bmeng.
*            lwa_item-bmeng = <lfs_vbep>-bmeng. "Confirmed qty
                lv_bmeng = trunc( <lfs_vbep>-bmeng ).
                IF lv_bmeng EQ <lfs_vbep>-bmeng.
                  lwa_item-bmeng = lv_bmeng. "Confirmed qty
                ENDIF. " IF lv_bmeng EQ <lfs_vbep>-bmeng
                lwa_item-vfdat  = <lfs_vbep>-edatu. "Expiry Date
              ELSE. " ELSE -> IF lv_bmeng_abs EQ <lfs_vbep>-bmeng
                lv_bmeng = trunc( <lfs_vbep>-bmeng ).
                IF lv_bmeng EQ <lfs_vbep>-bmeng.
                  lwa_item-bmeng = lv_bmeng. "Confirmed qty
                ELSE. " ELSE -> IF lv_bmeng EQ <lfs_vbep>-bmeng
                  lwa_item-bmeng = <lfs_vbep>-bmeng.
                ENDIF. " IF lv_bmeng EQ <lfs_vbep>-bmeng
                lwa_item-vfdat  = <lfs_vbep>-edatu. "Expiry Date
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
                      IF <lfs_vbep_tmp>-posnr EQ <lfs_vbep>-posnr.
                        IF <lfs_vbep_tmp>-bmeng NE 0.
                          CONTINUE.
                        ELSE. " ELSE -> IF <lfs_vbep_tmp>-bmeng NE 0
                          lv_bmeng = 0.
                          lwa_item-bmeng = lv_bmeng. "Confirmed qty
                          lwa_item-vfdat = <lfs_vbep>-edatu. " Expiry Date
                        ENDIF. " IF <lfs_vbep_tmp>-bmeng NE 0
                      ENDIF.
                    ENDIF. " IF sy-subrc EQ 0
                  ENDIF. " IF <lfs_vbep_tmp>-bmeng NE 0
                ELSE. " ELSE -> IF <lfs_vbep_tmp>-posnr EQ <lfs_vbep>-posnr

***&--> Begin of delete for D3_OTC_FDD_0012_Defect# 3909 by AMOHAPA on 03-Nov-2017
**                  "Data should be populated from li_vbep
***                  lv_bmeng = trunc( <lfs_vbep_tmp>-bmeng ).
***                  lwa_item-bmeng = lv_bmeng. "Confirmed qty
***                  lwa_item-vfdat = <lfs_vbep_tmp>-edatu. " Expiry Date
**
***&<-- End of delete for D3_OTC_FDD_0012_Defect# 3909 by AMOHAPA on 03-Nov-2017
**
***&-- Begin of insert for D3_OTC_FDD_0012_Defect# 3909 by AMOHAPA on 03-Nov-2017
*
                  lv_bmeng = 0.
                  lwa_item-bmeng = lv_bmeng. "Confirmed qty
                  lwa_item-vfdat = <lfs_vbep>-edatu. " Expiry Date
**
***&-- End of insert for D3_OTC_FDD_0012_Defect# 3909 by AMOHAPA on 03-Nov-2017

                ENDIF. " IF <lfs_vbep_tmp>-posnr EQ <lfs_vbep>-posnr

***&--> Begin of insert for D3_OTC_FDD_0012_Defect# 3909 by AMOHAPA on 03-Nov-2017
**                    "If it fails the read, then also it should populate Confirm qty and delivery date
**
              ELSE. " ELSE -> IF sy-subrc EQ 0
                lv_bmeng = 0.
                lwa_item-bmeng = lv_bmeng. "Confirmed qty
                lwa_item-vfdat = <lfs_vbep>-edatu. " Expiry Date
**
***&<-- End of insert for D3_OTC_FDD_0012_Defect# 3909 by AMOHAPA on 03-Nov-2017

              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF <lfs_vbep>-bmeng IS NOT INITIAL

*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
            IF fp_header-d3_format_flag IS NOT INITIAL.
              IF lwa_item-bmeng  IS INITIAL.
                MOVE 0 TO lwa_item-bmeng.
              ENDIF. " IF lwa_item-bmeng IS INITIAL
            ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5438 by NSAXENA

*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336

* Below mentioned change will only be true for standing orders
* and D3 sales organizations.
*If the confirmed qty is passed as 0 then we need not to pass the estimated delivery date
*for that particular line item in output.

            IF  lv_order_match_flag IS NOT INITIAL
              AND fp_header-d3_format_flag IS NOT INITIAL.

*End of insert for D3_OTC_FDD_0012 CR#301 by U034336

              IF lwa_item-bmeng EQ 0.

*Keep conf qty as 0.
* ---> Begin of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU
*  As part of this  defect VFDAT should not be cleared out it should take firt schedule line item date,

*              lwa_item-bmeng = 0.
*              CLEAR lwa_item-vfdat.
                READ TABLE li_vbep ASSIGNING <lfs_vbep1> WITH KEY posnr = <lfs_vbap>-posnr
                                                                     BINARY SEARCH.
                IF sy-subrc = 0.
                  lwa_item-vfdat = <lfs_vbep1>-edatu.
                ENDIF. " IF sy-subrc = 0
* <--- End of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU
              ENDIF. " IF lwa_item-bmeng EQ 0
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5438 by NSAXENA
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336


**---> Begin of Insert for D3_OTC_FDD_0012 Defect# #2427/2430 by PDEBARU
            ELSEIF lv_order_flag IS NOT INITIAL
              AND fp_header-d3_format_flag IS NOT INITIAL.
              IF lwa_item-bmeng = 0.
*&--> Begin of delete D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                " Whenever we found no delivery date we should print TBD instead.
*                CLEAR lwa_item-vfdat.
*&<-- End of delete D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

                "Standard text for TBD should be populated in Estimate delivery date

                CALL FUNCTION 'READ_TEXT'
                  EXPORTING
                    id                      = lc_tdid     "Id
                    language                = lv_langu1  " Language
                    name                    = lc_tbd      " TBD
                    object                  = lc_tdobject "Object Id
                  TABLES
                    lines                   = li_lines    "Text lines
                  EXCEPTIONS
                    id                      = 1
                    language                = 2
                    name                    = 3
                    not_found               = 4
                    object                  = 5
                    reference_check         = 6
                    wrong_access_to_archive = 7
                    OTHERS                  = 8.
                IF li_lines[] IS NOT INITIAL.
                  READ TABLE li_lines INTO lwa_lines INDEX 1.
                  IF sy-subrc = 0.
                    lv_tbd = lwa_lines-tdline.
                  ENDIF. " IF sy-subrc = 0
                  lwa_item-vfdat = lv_tbd.

                  CLEAR : lv_tbd,
                          lwa_lines.
                  REFRESH : li_lines[].
                ENDIF. " IF li_lines[] IS NOT INITIAL

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

              ENDIF. " IF lwa_item-bmeng = 0

*<--- End of Insert for D3_OTC_FDD_0012 Defect# #2427/2430 by PDEBARU

            ENDIF. " IF lv_order_match_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336

            IF lwa_item-vfdat IS NOT INITIAL.

*Begin of insert for D3_OTC_FDD_0012 by U034336
*Convert date for respective sold to cust lang
              IF fp_header-d3_format_flag IS NOT INITIAL.
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
* Check if the date is valid .


                IF lwa_item-vfdat+0(1) CA '0123456789'.
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

                  PERFORM f_convert_date_format USING    li_status
                                                         lwa_item-vfdat
                                                         fp_header
                                                CHANGING lwa_item-vfdat.
                ENDIF. " IF lwa_item-vfdat+0(1) CA '0123456789'

              ELSE. " ELSE -> IF fp_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336

                CONDENSE lwa_item-vfdat.
                lv_date = lwa_item-vfdat.
                lv_year = lv_date+2(2).
                lv_month = lv_date+4(2).
                lv_day = lv_date+6(2).
                CONCATENATE lv_month lv_day lv_year INTO lwa_item-vfdat
                 SEPARATED BY lc_slash.
*Begin of insert for D3_OTC_FDD_0012 by U034336
              ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 by U034336

            ENDIF. " IF lwa_item-vfdat IS NOT INITIAL

            CONDENSE lwa_item-bmeng.
            lv_conf_qty = lwa_item-bmeng.
            CONCATENATE lv_conf_qty lv_vrkme INTO lwa_item-conf_qty
            SEPARATED BY space.
            CONDENSE lwa_item-vfdat.

*Begin of insert for D3_OTC_FDD_0012 by U034336
* Get customer material number if present
* for respective material number
            READ TABLE li_knmt INTO lwa_knmt
            WITH KEY matnr = <lfs_vbap>-matnr
            BINARY SEARCH.
            IF sy-subrc EQ 0.
              lwa_item-cust_mat = lwa_knmt-kdmat.
              CONCATENATE lv_cust_mat_text lwa_item-cust_mat INTO lwa_item-cust_mat
              SEPARATED BY space.
            ENDIF. " IF sy-subrc EQ 0

*End of insert for D3_OTC_FDD_0012 by U034336

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
            IF <lfs_vbap>-fkrel = lc_fkrel_i. "If Item is Billing relevant


*        Fetch Billing method
*        As very less data there in the Status table no binary search done
              READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_z_bmethod
                                                             sel_low = <lfs_vbap>-zz_bilmet.
              IF  sy-subrc = 0.

                lv_bmethod_nam = <lfs_status>-sel_high.
*               Fetch the SO10 text for Billing method text
                PERFORM f_get_texts USING lc_tdid
                                        lv_langu1
                                        lv_bmethod_nam
                                        lc_tdobject
                              CHANGING  lv_bmethod.
                CONDENSE lv_bmethod.
              ENDIF.

*         Fetch Billing Frequency
*        As very less data there in the Status table no binary search done
              READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_z_bfrequency
                                                             sel_low = <lfs_vbap>-zz_bilfr.
              IF  sy-subrc = 0.

                lv_bfreq_nam = <lfs_status>-sel_high.
*           Fetch the SO10 text for Billing Frequency text
                PERFORM f_get_texts USING lc_tdid
                                        lv_langu1
                                        lv_bfreq_nam
                                        lc_tdobject
                              CHANGING  lv_bfrequency.
                CONDENSE lv_bfrequency.
              ENDIF.

*          Fetch the Contract start and end dates
              READ TABLE li_vbkd INTO lwa_vbkd
                WITH KEY vbeln = <lfs_vbap>-vbeln
                         posnr = <lfs_vbap>-posnr
                         BINARY SEARCH.
              IF sy-subrc = 0.
*           Populate Billing Start date
                READ TABLE li_fplt INTO lwa_fplt WITH KEY fplnr = lwa_vbkd-fplnr.
                IF sy-subrc = 0.
                  lv_fkdat = lwa_fplt-fkdat.

                  PERFORM f_convert_date_format USING    li_status
                                                         lv_fkdat
                                                         fp_header
                                                CHANGING lv_fkdat.

*           Fetch the SO10 text for 'Billing start'
                  PERFORM f_get_texts USING lc_tdid
                                          lv_langu1
                                          lc_bill_st_dt
                                          lc_tdobject
                                CHANGING  lv_bill_st_dt.
                  CONCATENATE lv_bill_st_dt lv_fkdat INTO lwa_item-fkdat SEPARATED BY space.
                ENDIF." IF sy-subrc = 0. ->READ TABLE li_fplt INTO lwa_fplt INDEX 1.
                CLEAR lwa_fplt.

                READ TABLE li_fpla INTO lwa_fpla
                WITH KEY fplnr = lwa_vbkd-fplnr
                BINARY SEARCH.
                IF sy-subrc = 0 AND lwa_fpla-bedat IS NOT INITIAL AND lwa_fpla-endat IS NOT INITIAL.
                  lv_bedat = lwa_fpla-bedat.
                  lv_endat = lwa_fpla-endat.
                ENDIF.
              ENDIF.
              CLEAR : lwa_fpla, lwa_vbkd.

              IF lv_bedat IS NOT INITIAL.
                PERFORM f_convert_date_format USING    li_status
                                                       lv_bedat
                                                       fp_header
                                              CHANGING lv_bedat.
              ENDIF.

              IF lv_endat IS NOT INITIAL.
                PERFORM f_convert_date_format USING    li_status
                                                       lv_endat
                                                       fp_header
                                              CHANGING lv_endat.
              ENDIF.

*           Fetch the SO10 text for 'Recurring'
              PERFORM f_get_texts USING lc_tdid
                                      lv_langu1
                                      lc_recurring
                                      lc_tdobject
                            CHANGING  lv_recurring.
*           Fetch the SO10 text for 'Till'
              PERFORM f_get_texts USING lc_tdid
                                      lv_langu1
                                      lc_till
                                      lc_tdobject
                            CHANGING  lv_till.

*        As very less data there in the Status table no binary search done
              READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_evergreen
                                                             sel_low = <lfs_vbap>-zz_bilmet.
              IF  sy-subrc = 0. "Evergreen
                CONCATENATE lv_recurring  lv_bmethod lv_bfrequency lv_bedat
                INTO lwa_item-contract_info SEPARATED BY space.
              ELSE. "Non-evergreen
                CONCATENATE lv_recurring  lv_bmethod lv_bfrequency lv_bedat lv_till lv_endat
                INTO lwa_item-contract_info SEPARATED BY space.
              ENDIF.
            ENDIF.
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019

            APPEND lwa_item TO fp_i_item.
            CLEAR: lv_zzitemref,
            lv_zzqouteref,
            lv_zzlnref,
            lv_bmeng,
            lv_date,
            lv_year,
            lv_day,
            lv_month.
            CLEAR: lwa_item-matnr,
            lwa_item-arktx,
            lwa_item-promo_text,
            lwa_item-quantity,
            lwa_item-back_ord_qty,
            lwa_item-unit_price,
            lwa_item-ext_price,
            lwa_item-sales_text,
            lwa_item-charg,
            lwa_item-qoute_text,
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
            lwa_item-fkdat,
            lwa_item-contract_info,
            lv_bedat,
            lv_endat,
            lv_fkdat,
            lv_bmethod,
            lv_bfrequency,
            lv_bfreq_nam,
            lv_bmethod_nam,
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
            lv_tabix.
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
            UNASSIGN <lfs_vbep_tmp>.
            EXIT.
          ENDLOOP. " LOOP AT li_vbep ASSIGNING <lfs_vbep> FROM lv_index
        ENDIF. " IF sy-subrc EQ 0
****** ---> Begin of Insert for Defect#8903:D2_OTC_FDD_0012 by SGHOSH
*****        ELSE. " ELSE -> IF lwa_item-vfdat IS NOT INITIAL
*****          APPEND lwa_item TO fp_i_item.
*****        ENDIF. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
****** <--- End of Insert for Defect#8903:D2_OTC_FDD_0012 by SGHOSH

        CLEAR: lwa_item,
        lv_num.
        UNASSIGN: <lfs_vbep>.
      ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>

*Dangerous goods
      LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lv_zdng.
        lv_dangergoods_fee1 = lv_dangergoods_fee1 + <lfs_konv>-kwert.
      ENDLOOP. " LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lv_zdng
*Handling_fees
      LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lv_zhdl.
        lv_handling_fee1 = lv_handling_fee1 + <lfs_konv>-kwert.
      ENDLOOP. " LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lv_zhdl
*Freight
      LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lv_ztfr.
        lv_freight1 = lv_freight1 + <lfs_konv>-kwert.
      ENDLOOP. " LOOP AT li_konv ASSIGNING <lfs_konv> WHERE kschl = lv_ztfr

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
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
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
*For calculating the Tax value
      li_konv_tmp[] = li_konv[].

*&--> Begin of delete for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*      DELETE li_konv_tmp WHERE kschl NE lc_mwst.
*&<-- End of delete for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*&--Taking care of Split tax functionality for Italian Invoices
      DELETE li_konv_tmp WHERE kschl = lc_zmw0.

      SORT li_konv_tmp BY kposn.
      SORT li_vbap_tmp1 BY posnr.
      SORT li_konv BY kposn.
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 by U029267 on 07-Feb-2019

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*Tax calculation
*Li_VBAP_TMP1 is replica of li_vbap internal table, only the line item with kowrr = Y
*field is removed from table and then we are adding the mwsbp values of line item to get the
*total tax value.
      LOOP AT li_vbap_tmp1 ASSIGNING <lfs_vbap>.
*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
*Remove logic in program to summary the total billing plan VAT (mwst) in the VAT totals field.
*The requirement is to print the VAT of the line item only once in the VAT total.
*        So taking the value from KONV table
*&--> Begin of delete for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*          READ TABLE li_konv_tmp INTO lwa_konv_tmp
*          WITH KEY kposn = <lfs_vbap>-posnr
*          BINARY SEARCH.
*          IF sy-subrc = 0.
*            lv_tax1 = lv_tax1 + lwa_konv_tmp-kwert.
*          ENDIF.
*          CLEAR lwa_konv_tmp.
*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
*&<-- End of delete for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019
*&--->Tax calculation logic for Split tax invoices, mulitple tax jurisdictions & European order
        IF li_konv_tmp IS NOT INITIAL.
          READ TABLE li_konv_tmp INTO lwa_konv_tmp WITH KEY kposn = <lfs_vbap>-posnr
                                                   BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*&--Catching the index value
            lv_index = sy-tabix.
*&--Parallel cursor have been used to check for all the line items
            LOOP AT li_konv_tmp INTO lwa_konv_tmp FROM lv_index.
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
                 lv_index.

*        ELSE.
**&--For US order taxes no MWST & ZMW0 condition type will be present
*          READ TABLE li_konv INTO lwa_konv_tmp WITH KEY kposn = <lfs_vbap>-posnr
*                                               BINARY SEARCH.
*          IF sy-subrc IS INITIAL.
**&--Catching the index value
*            lv_index = sy-tabix.
**&--Parallel cursor have been used to check for all the line items
*            LOOP AT li_konv INTO lwa_konv_tmp FROM lv_index.
*              IF lwa_konv_tmp-kposn <> <lfs_vbap>-posnr.
*                EXIT.
*              ENDIF.
*              IF  lwa_konv_tmp-kntyp IN li_kntyp[] AND
*              lwa_konv_tmp-kstat IS INITIAL AND
*              lwa_konv_tmp-kschl NE lc_zmw0.
*
*                lv_tax1 = lv_tax1 + lwa_konv_tmp-kwert.
*              ENDIF.
*
*            ENDLOOP.
*          ENDIF.
        ENDIF.

        CLEAR: lwa_konv_tmp,
               lv_index.

*&<-- End of insert for R6 Upgrade D3_OTC_FDD_0012_Defect#8658 SCTASK0793188 FUT_ISSUES by SMUKHER4 on 13-MAR-2019

*&--> Begin of Delete for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
*        lv_tax1 = lv_tax1 + <lfs_vbap>-mwsbp.
*&<-- End of Delete for R6 Upgrade D3_OTC_FDD_0012_Defect#8304 SCTASK0793188 by U029267 on 07-Feb-2019
      ENDLOOP. " LOOP AT li_vbap_tmp1 ASSIGNING <lfs_vbap>
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA


*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

      "Populating conditional value for ZINS, ZENV and ZDOC
      LOOP AT li_konv INTO lwa_konv.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        "Considering Documentation charge, Insurance charge and Environmental charge will be present at item level
        IF lwa_konv-kposn IS NOT INITIAL.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
          CASE lwa_konv-kschl.
              "Taking the conditional value for ZDOC into one variable to add it into Handling Fee
            WHEN lv_zdoc.
              lv_document = lv_document + lwa_konv-kwert.
              "Taking the value for ZINS condition type to populate it in the insurance field output
            WHEN lv_zins.
              lv_insurance = lv_insurance + lwa_konv-kwert.
              "Taking the value for ZENV condition type to populate it in envirnomental field output
            WHEN lv_zenv.
              lv_environment  = lv_environment  + lwa_konv-kwert.
            WHEN OTHERS.
              CONTINUE.
          ENDCASE.
          "Clearing the local workarea
          CLEAR lwa_konv.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        ENDIF.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      ENDLOOP. " LOOP AT li_konv INTO lwa_konv

*&--> Begin of delete D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      "If lv_documnet is not initial then ae per the requirement we should add this value into Handling fee
*      IF lv_document IS NOT INITIAL.
*        lv_handling_fee1 = lv_handling_fee1 + lv_document.
*      ENDIF. " IF lv_document IS NOT INITIAL
*
*      CLEAR: lv_document.
*&<-- End of delete D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*Total Amount
      lv_total_price1 =  lv_subtotal_price1
                     + lv_dangergoods_fee1 + lv_handling_fee1
                     + lv_freight1 + lv_tax1 +
                     lv_insurance + lv_environment " D3_R2 for D3_OTC_FDD_0012
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                      + lv_document.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
*Writing the all the prices as per the document currency
      WRITE lv_total_price1 TO fp_total_price CURRENCY lv_cuky.
      CONDENSE fp_total_price.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      IF lv_dangergoods_fee1 IS NOT INITIAL.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        WRITE lv_dangergoods_fee1 TO fp_dangergoods_fee CURRENCY lv_cuky.
        CONDENSE fp_dangergoods_fee.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      ENDIF.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      WRITE lv_subtotal_price1 TO fp_subtotal_price CURRENCY lv_cuky.
      CONDENSE fp_subtotal_price.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      IF lv_handling_fee1 IS NOT INITIAL.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        WRITE lv_handling_fee1 TO fp_handling_fee CURRENCY lv_cuky.
        CONDENSE fp_handling_fee.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      ENDIF.
      IF lv_freight1 IS NOT INITIAL.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
        WRITE lv_freight1 TO fp_freight CURRENCY lv_cuky.
        CONDENSE fp_freight.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      ENDIF.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      WRITE lv_tax1 TO fp_tax CURRENCY lv_cuky.
      CONDENSE fp_tax.
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
      "Populating insurance
      IF lv_insurance IS NOT INITIAL.
        WRITE lv_insurance TO fp_lv_insurance_fee CURRENCY lv_cuky.
        CONDENSE fp_lv_insurance_fee.
      ENDIF. " IF lv_insurance IS NOT INITIAL
      "Populating environment
      IF lv_environment IS NOT INITIAL.
        WRITE lv_environment  TO fp_lv_env_fee CURRENCY lv_cuky.
        CONDENSE fp_lv_env_fee.
      ENDIF. " IF lv_environment IS NOT INITIAL
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      "Populating documentation charge
      IF lv_document IS NOT INITIAL.
        WRITE lv_document  TO fp_lv_document_chg CURRENCY lv_cuky.
        CONDENSE fp_lv_document_chg.
      ENDIF. " IF lv_environment IS NOT INITIAL
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

      CLEAR:lv_total_price1,
      lv_dangergoods_fee1,
      lv_subtotal_price1,
      lv_handling_fee1,
      lv_freight1,
      lv_tax1,
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
      lv_insurance,
      lv_environment,
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
      lv_document.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc EQ 0
  FREE: li_mcha,
   li_vbap,
   li_vbap_tmp,
        li_vbep,
        li_vbep_tmp,
        li_lines,
        li_konv,
        li_mch1,
        li_mcha.

ENDFORM. " F_GET_ITEM_DATA


*&---------------------------------------------------------------------*
*&      Form  F_GET_HEADER_DATA
*&---------------------------------------------------------------------*
*       Get Sales Document Header data
*----------------------------------------------------------------------*
*      -->FP_VBELN                Sales Document No.
*      -->FP_NAST                 NAST
*      -->FP_SCREEN               Screen value
*      -->FP_SOLD_TO_ADDR         Sold to Address
*      -->FP_SHIP_TO_ADDR         Ship To Address
*      -->FP_CONTACT_ADDR         Contact Person Address
*      -->FP_HEADER               Sales Document Header data
*      -->FP_SHIP_NO              Ship-to-Party Number
*      -->FP_SOLD_NO              Sold-to-Party Number
*      -->FP_SHIP_ATT             Shipping Attention
*      -->FP_VBADR                Address
*      -->FP_RETCODE              Return code
*----------------------------------------------------------------------*
FORM f_get_header_data USING fp_vbeln        TYPE vbeln_va                              " Sales Document
                             fp_nast         TYPE nast                                  " Message Status
                             fp_screen       TYPE c                            ##needed "Screen of type Character
                    CHANGING fp_sold_to_addr TYPE zotc_cust_order_ack_add_info          " Order Acknowledgement - General Address Information
                             fp_ship_to_addr TYPE zotc_cust_order_ack_add_info          " Order Acknowledgement - General Address Information
                             fp_contact_addr TYPE zotc_cust_order_ack_add_info          " Order Acknowledgement - General Address Information
                             fp_contact_addr_check TYPE zotc_cust_order_ack_add_info    " Order Acknowledgement - General Address Information
                             fp_header       TYPE zotc_cust_order_ack_header            " Header data for Order Acknowledgement form
                             fp_ship_no      TYPE char10                                " Ship_no of type CHAR10
                             fp_sold_no      TYPE char10                                " Bill_no of type CHAR10
                             fp_ship_att     TYPE char255                               " Ship_att of type CHAR10
                             fp_vbadr        TYPE vbadr "#EC NEEDED  "Address work area
                             fp_langu        TYPE char3                                 " Langu of type CHAR3
                             fp_retcode      TYPE sy-subrc "#EC NEEDED  "Return Value of ABAP Statements
*Begin of insert for D3_OTC_FDD_0012 by U034336
                             fp_kunnr        TYPE kunnr " Customer Number
                             fp_sh_to_land   TYPE land1 " Country Key
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                             fp_auart        TYPE auart " Sales Document Type
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
                             fp_lang_fr      TYPE flag " Language Key
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                             fp_lwa_bill_to      TYPE zotc_cust_order_ack_add_info "Bill to address
                             fp_bill_no          TYPE char10                       "Bill to number
                             fp_gln_shipto       TYPE char12                       "Location for ship to
                             fp_gln_soldto       TYPE char12                       "Location for sold to
                             fp_gln_billto       TYPE char12                      "Location for Bill to
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                             fp_cup_cig_text     TYPE char8                      " CUP / CIG text
                             fp_cup_cig_val      TYPE char30.                    " CUP / CIG value
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
  TYPES:
*&--For VBPA data
    BEGIN OF lty_vbpa,
      vbeln TYPE vbeln,             " Sales and Distribution Document Number
      posnr TYPE posnr,             " Item number of the SD document
      parvw TYPE parvw,          "Partner Function
      kunnr TYPE kunnr,          "Customer Number
      parnr TYPE parnr,          "Contact Person number
      adrnr TYPE adrnr,          "Address
      adrnp TYPE ad_persnum,      " Person number
    END OF lty_vbpa,

    BEGIN OF lty_email,
      addrnumber TYPE	ad_addrnum,
      date_from  TYPE ad_date_fr,  " Valid-from date - in current Release only 00010101 possible
      consnumber TYPE ad_consnum, "++D3_OTC_FDD_0012 Defect 5455
      smtp_addr  TYPE ad_smtpadr,  "E-Mail Address
    END OF lty_email,

* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
    BEGIN OF lty_telno,
      addrnumber TYPE	ad_addrnum,
      date_from  TYPE ad_date_fr,  " Valid-from date - in current Release only 00010101 possible
      consnumber TYPE ad_consnum, " Sequence Number
      tel_number TYPE ad_tlnmbr,  " Telephone no.: dialling code+number
    END OF lty_telno,
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336


* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*For Storing the hedaer text ids.
    BEGIN OF ty_object_id,
      id TYPE tdid, " Text ID
    END OF ty_object_id,
*Types for stxh internal table
    BEGIN OF lty_name,
      object TYPE tdobject, " Texts: Application Object
      name   TYPE tdobname,   " Name
      id     TYPE tdid,         " Text ID
      lang   TYPE tdspras,    " Language key
    END OF lty_name,
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
    BEGIN OF lty_address,
      adrnr      TYPE adrnr,           " Address
      date_from  TYPE ad_date_fr,  " Valid-from date - in current Release only 00010101 possible
      nation     TYPE ad_nation,      " Version ID for International Addresses
      name1      TYPE ad_name1,        " Name 1
      name2      TYPE ad_name2,        " Name 2
      name3      TYPE ad_name3,        " Name 3
      name4      TYPE ad_name4,        " Name 4
      building   TYPE ad_bldng,     " Building (Number or Code)
      floor      TYPE ad_floor,        " Floor in building
      roomnumber TYPE ad_roomnum, " Room or Appartment Number
      house_num2 TYPE ad_hsnm2,   " House number supplement
      house_num1 TYPE ad_hsnm1,   " House Number
      street     TYPE ad_street,      " Street
      str_suppl1 TYPE ad_strspp1, " Street 2
      str_suppl2 TYPE ad_strspp2, " Street 3
      str_suppl3 TYPE ad_strspp3, " Street 4
      po_box     TYPE ad_pobx,        " PO Box
      city1      TYPE ad_city1,        " City
      city2      TYPE ad_city2,        " District
      post_code1 TYPE ad_pstcd1,  " City postal code
      post_code2 TYPE ad_pstcd2,  " PO Box Postal Code
      country    TYPE land1,         " Country Key
      langu      TYPE spras,           " Language Key
      region     TYPE regio,          " Region (State, Province, County)
      tel_number TYPE ad_tlnmbr1, " First telephone no.: dialling code+number
    END OF lty_address,
* ---> End of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
    "Local structure declaration for KNA1
    BEGIN OF lty_kna1,
      kunnr TYPE kunnr, "Customer Number
      bbbnr TYPE bbbnr, "International location number  (part 1)
      bbsnr TYPE bbsnr, "International location number (Part 2)
    END OF lty_kna1.
  DATA: li_kna1       TYPE STANDARD TABLE OF lty_kna1 INITIAL SIZE 0,  "Local internal table for KNA1
        lwa_kna1      TYPE lty_kna1,                                   "Local workarea for KNA1
        li_vbpa_kunnr TYPE STANDARD TABLE OF  lty_vbpa INITIAL SIZE 0. "Local internal table for VBPA

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*Local Internal tables
  DATA: li_lines      TYPE STANDARD TABLE OF tline, "Material Sales text
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
        li_lines_temp TYPE STANDARD TABLE OF tline, "Material Sales text
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
        li_vbpa       TYPE STANDARD TABLE OF lty_vbpa, "Table for Partner data
        li_email      TYPE STANDARD TABLE OF lty_email,
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
        li_telno      TYPE STANDARD TABLE OF lty_telno,
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
        li_address    TYPE STANDARD TABLE OF lty_address,
* ---> End of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
* ---> Begin of Delete for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
*        li_address TYPE STANDARD TABLE OF zotc_cust_order_ack_add_info, " Order Acknowledgement - General Address Information
* ---> End of Delete for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
        li_id         TYPE STANDARD TABLE OF ty_object_id,            "Internal table for header text id
        li_status     TYPE STANDARD TABLE OF  zdev_enh_status, " Internal table for Enhancement Statu
        lwa_id        TYPE ty_object_id,
        li_name       TYPE STANDARD TABLE OF lty_name,
        lv_langu1     TYPE sylangu,                               " Language Key of Current Text Environment
        lv_langu2     TYPE sylangu.                               " Language Key of Current Text Environment
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA


*Local Work Area
  DATA:  lwa_vbpa   TYPE lty_vbpa. "VBPA
*Local constants
  CONSTANTS:
    lc_contact       TYPE parvw    VALUE 'AP',     "Contact person " added by nsaxena
    lc_contact_other TYPE parvw VALUE 'ZA',  "Contact person "added by nsaxena
    lc_sold_to       TYPE parvw    VALUE 'AG',     "Bill-to party " added by nsaxena
    lc_ship_to       TYPE parvw    VALUE 'WE',     "Ship-to party  " added by nsaxena
    lc_posnr         TYPE posnr_va VALUE '000000', "Header Item count
    lc_id_0002       TYPE tdid VALUE '0002',       " Text ID
    lc_id_z009       TYPE tdid VALUE 'Z009',       " Text ID
    lc_id_z012       TYPE tdid VALUE 'Z012',       " Text ID
    lc_object        TYPE tdobject VALUE 'VBBK',    " Texts: Application Object
    lc_domname       TYPE char10 VALUE 'Z_DOCTYP', " Domname of type CHAR10
    lc_as4local      TYPE char1 VALUE 'A',        " As4local of type CHAR1
    lc_cons_0000     TYPE char4 VALUE '0000',    " Cons_0000 of type CHAR4
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    lc_english       TYPE sylangu VALUE 'E',                      " Language Key of Current Text Environment
    lc_space         TYPE char1 VALUE ' ',                          " Space of type CHAR1
    lc_fdd_0012      TYPE z_enhancement VALUE 'D2_OTC_FDD_0012', "Enhancement number
    lc_langu         TYPE z_criteria VALUE 'VKORG_LANGU',           " Enh. Criteria
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5822 by NSAXENA
    lc_freight       TYPE z_criteria VALUE 'ZFREIGHT', " Enh. Criteria
*Begin of insert for D3_OTC_FDD_0012 by U034336
    lc_vkorg_format  TYPE z_criteria VALUE 'VKORG_FORMAT', " Enh. Criteria
    lc_eu_langu      TYPE z_criteria VALUE 'EU_LANGU',     " Enh. Criteria
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
    lc_id            TYPE char4      VALUE 'ST',                       " Id of type CHAR4
    lc_object_txt    TYPE char10     VALUE 'TEXT',                     " Object of type CHAR10
    lc_att_to        TYPE char70     VALUE 'ZOTC_BIO_ATTENTION_TO_EU', " Att_to of type CHAR70
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
*End of insert for D3_OTC_FDD_0012 by U034336
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
* ---> Begin of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU
    lc_dap           TYPE z_criteria VALUE 'INCO_DAP',    " Enh. Criteria
    lc_fca           TYPE z_criteria VALUE 'INCO_FCA',    " Enh. Criteria
    lc_freight1      TYPE z_criteria VALUE 'ZFREIGHT1', " Enh. Criteria
* <--- End of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    lc_language      TYPE z_criteria VALUE 'LANGUAGE', " Enh. Criteria
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
    lc_id_cup        TYPE tdid   VALUE 'CUP',                " Text ID
    lc_id_cig        TYPE tdid   VALUE 'CIG',                " Text ID
    lc_cup_cig_id    TYPE char70 VALUE 'ZOTC_0012_CUP_CIG',  " Text name
    lc_cup_id        TYPE char70 VALUE 'ZOTC_0012_CUP',      " Text name
    lc_cig_id        TYPE char70 VALUE 'ZOTC_0012_CIG',      " Text name
    lc_slash         TYPE char1  VALUE '/',                  " Slash
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

* ---> Begin of Insert for D3_OTC_FDD_0012_Defect#9877
    lc_zzdoctyp_08 TYPE z_doctyp VALUE '08',              "Esker doc type
* <--- End    of Insert for D3_OTC_FDD_0012_Defect#9877

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
    lc_bill_to       TYPE parvw  VALUE 'RE', "Partner function for Bill to
    lc_zero          TYPE char1  VALUE '0'.  "Local constants for zero

  DATA: lwa_vbpa_bill TYPE lty_vbpa,    "Workarea for VBPA
        lwa_addr_bill TYPE lty_address. "Workarea to keep bill to address
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017


*Local variables
  DATA:
    lv_vsbed              TYPE vsbed, "Shipping Conditions
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5822 by NSAXENA
    lv_freight_header     TYPE char10, " Freight_header of type CHAR10
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5822 by NSAXENA
    lv_bstkd              TYPE bstkd,                " Customer purchase order number
    lv_zzdocref           TYPE z_docref,          " Legacy Doc Ref
    lv_zzdoctyp           TYPE z_doctyp,          " Ref Doc type
    lv_zzcaseref          TYPE z_caseref,        " Index of Internal Tables
    lv_adrnr              TYPE adrnr,              "Address number of Customer
    lv_ship_attention     TYPE char255,     " SAPscript: Text Lines
    lv_name               TYPE tdobname,             " Name
    lv_ord_comments_part1 TYPE char255, " SAPscript: Text Lines
    lv_ord_comments_part2 TYPE char255, " SAPscript: Text Lines
    lv_ord_comments       TYPE char255,       " Ord_comments of type CHAR40
    lv_doctyp             TYPE val_text,            " Doctyp of type CHAR255
    lv_ord_1              TYPE char255,              " Ord_1 of type CHAR255
    lv_ord_2              TYPE char255,              " Ord_2 of type CHAR255
    lv_caseref            TYPE char255,            " Caseref of type CHAR255
    lv_docref             TYPE char255,             " Docref of type CHAR255
    lv_smtp_addr          TYPE ad_smtpadr,       " E-Mail Address
    lv_name1              TYPE ad_name1,             " Name 1
    lv_valpos             TYPE valpos,              " Domain value key
    lv_doctyp_ord         TYPE val_text,       " Short Text for Fixed Values
*Begin of insert for D3_OTC_FDD_0012 by U034336
    lv_sold_to_lang       TYPE spras,  " Language Key
    lv_ord_date_char      TYPE char15, " Ord_date_char of type CHAR12
    lv_langu_read_text    TYPE spras,  " Language Key
    li_vbpa_tmp           TYPE STANDARD TABLE OF lty_vbpa INITIAL SIZE 0,
*End of insert for D3_OTC_FDD_0012 by U034336
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
    li_vbpa_temp          TYPE STANDARD TABLE OF lty_vbpa INITIAL SIZE 0,
    li_vbpa_tmp1          TYPE STANDARD TABLE OF lty_vbpa INITIAL SIZE 0,
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
* ---> Begin of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU

    lv_dap                TYPE inco1,  " Incoterms (Part 1)
    lv_fca                TYPE inco1,  " Incoterms (Part 1)
    lv_inco               TYPE inco1, " Incoterms (Part 1)
*
* <--- End of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612by PDEBARU
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    lv_flag_skip          TYPE flag. " General Flag
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
  DATA: lv_cup_val TYPE char15,          " CUP text
        lv_cig_val TYPE char10.         " CIG text
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
*Field Symbols
  FIELD-SYMBOLS:
    <lfs_vbpa>       TYPE lty_vbpa, "Partner data
    <lfs_lines>      TYPE tline,   " SAPscript: Text Lines
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
    <lfs_lines_temp> TYPE tline, " SAPscript: Text Lines
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
    <lfs_email>      TYPE lty_email,
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
    <lfs_addr>       TYPE lty_address, " Customer Order Acknowledgement - General Address Information
* ---> End of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
* ---> Begin of Delete for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
*    <lfs_addr> TYPE zotc_cust_order_ack_add_info, " Customer Order Acknowledgement - General Address Information
* ---> End of Delete for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    <lfs_status>     TYPE zdev_enh_status, "For Reading enhancement table
    <lfs_name>       TYPE lty_name,
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
    <lfs_adrc>       TYPE lty_address, " Customer Order Acknowledgement - General Address Information
* ---> End of Insert for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
* ---> Begin of Delete for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu
*Begin of insert for D3_OTC_FDD_0012 by U034336
*   <lfs_adrc>   TYPE zotc_cust_order_ack_add_info, " Customer Order Acknowledgement - General Address Information
*End of insert for D3_OTC_FDD_0012 by U034336
* ---> End of Delete for D2_OTC_FDD_0012,Defect #12010 by Sudhanshu

* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
    <lfs_telno>      TYPE lty_telno.
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
  CLEAR: lwa_id.
  REFRESH li_id[].
*Inserting the text ids at header level so that based on these text id we will fetch the data
*from STXH table and then we will read individual text id at header level as per language and other
*input parameter
  lwa_id-id = lc_id_0002. "text id 0002
  APPEND lwa_id TO li_id.
  CLEAR lwa_id.
  lwa_id-id = lc_id_z009. "text id z009
  APPEND lwa_id TO li_id.
  CLEAR lwa_id.
  lwa_id-id = lc_id_z012. "text id z012
  APPEND lwa_id TO li_id.
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
  CLEAR lwa_id.
  lwa_id-id = lc_id_cup. "text id cup
  APPEND lwa_id TO li_id.
  CLEAR lwa_id.
  lwa_id-id = lc_id_cig. "text id cig
  APPEND lwa_id TO li_id.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
  CLEAR: lwa_id,
        lv_langu1.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*&--Fetch Sales Document: Partner data
*This piece of code under the tags has been moved form
*its earlier position so that we can make use of the those varaibles
*whose values are being populated during the select
*Begin of insert for D3_OTC_FDD_0012 by U034336
  SELECT     vbeln " Sales and Distribution Document Number
             posnr " Item number of the SD document
             parvw "Partner Function
             kunnr "Customer Number
             parnr "Contact person number
             adrnr "Address Number
             adrnp "personnel number in case of ZA partner function
        FROM vbpa  " Sales Document: Partner
        INTO TABLE li_vbpa
       WHERE vbeln = fp_vbeln
         AND posnr = lc_posnr
         AND parvw IN (lc_contact,lc_contact_other, lc_sold_to, lc_ship_to,
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
"Fetching bill to details
                       lc_bill_to
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
    ).

  IF sy-subrc = 0.

    li_vbpa_tmp[] = li_vbpa[].
    SORT li_vbpa_tmp BY adrnr.
    DELETE ADJACENT DUPLICATES FROM li_vbpa_tmp COMPARING  adrnr.
    IF  li_vbpa_tmp[] IS NOT INITIAL.

*&--Get all address correspoding to partner data
      SELECT addrnumber "Address No.              "#EC NEEDED
             date_from  " Valid-from date - in current Release only 00010101 possible
             nation     " Version ID for International Addresses
             name1      " Name 1
             name2      " Name 2
             name3      " Name 3
             name4      " Name 4
             building   " Building (Number or Code)
             floor      " Floor in building
             roomnumber " Room or Appartment Number
             house_num2 " House number supplement
             house_num1 " House No.
             street     " Street
             str_suppl1 " Street 2
             str_suppl2 " Street 3
             str_suppl3 " Street 4
             po_box     " PO Box
             city1      " City
             city2      " District
             post_code1 " City postal code
             post_code2 " PO Box Postal Code
             country    " Country Key
             langu      " Language Key
             region     " Region
             tel_number " First telephone no.: dialling code+number
        INTO TABLE li_address
        FROM adrc       " Addresses (Business Address Services)
         FOR ALL ENTRIES IN li_vbpa_tmp
       WHERE addrnumber = li_vbpa_tmp-adrnr.
      IF sy-subrc = 0.

*Delete address lines where the valid date is greater then current date
        DELETE li_address WHERE date_from GT sy-datum.

        IF li_address[] IS NOT INITIAL.
          SORT li_address BY adrnr.

* Get sold to customer data

          CLEAR: li_vbpa_tmp[].

          li_vbpa_tmp[] = li_vbpa[].
          SORT li_vbpa_tmp BY parvw.

          READ TABLE li_vbpa_tmp INTO lwa_vbpa
          WITH KEY parvw = lc_sold_to
          BINARY SEARCH.
          IF sy-subrc EQ 0.

            READ TABLE li_address ASSIGNING <lfs_adrc>
            WITH KEY adrnr = lwa_vbpa-adrnr
            BINARY SEARCH.

            IF sy-subrc EQ 0.
              fp_header-country      = <lfs_adrc>-country.
              lv_sold_to_lang        = <lfs_adrc>-langu.

            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
          CLEAR: lwa_vbpa.
          UNASSIGN <lfs_adrc>.
* Get ship to customer data

          READ TABLE li_vbpa_tmp INTO lwa_vbpa
          WITH KEY parvw = lc_ship_to
          BINARY SEARCH.
          IF sy-subrc EQ 0.

            READ TABLE li_address ASSIGNING <lfs_adrc>
            WITH KEY adrnr = lwa_vbpa-adrnr
            BINARY SEARCH.

            IF sy-subrc EQ 0.
              fp_sh_to_land  = <lfs_adrc>-country.

            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
          CLEAR: lwa_vbpa.
          UNASSIGN <lfs_adrc>.

        ENDIF. " IF li_address[] IS NOT INITIAL

      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_vbpa_tmp[] IS NOT INITIAL

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

    "Taking VBPA records into a local internal table to use FAE in KNA1
    li_vbpa_kunnr[] = li_vbpa[].

    IF li_vbpa_kunnr IS NOT INITIAL.

      SORT li_vbpa_kunnr BY kunnr.


      DELETE ADJACENT DUPLICATES FROM li_vbpa_kunnr COMPARING kunnr.

      "Fetching GLN numbers from KNA1 by passing VBPA-KUNNR
      SELECT kunnr     " Customer Number
             bbbnr     " International location number  (part 1)
             bbsnr     " International location number (Part 2)
             FROM kna1 " General Data in Customer Master
             INTO TABLE li_kna1
             FOR ALL ENTRIES IN li_vbpa_kunnr
             WHERE kunnr = li_vbpa_kunnr-kunnr.
      IF sy-subrc IS INITIAL.
        SORT li_kna1 BY kunnr.
        "By reading the kunnr from vbpa we are getting GLN location from KNA1
        LOOP AT li_vbpa INTO lwa_vbpa.

          CASE lwa_vbpa-parvw.

            WHEN lc_sold_to.
              READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_vbpa-kunnr
                                                        BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                IF lwa_kna1-bbsnr IS NOT INITIAL.
                  CONCATENATE lwa_kna1-bbbnr lwa_kna1-bbsnr INTO fp_gln_soldto.
                  SHIFT fp_gln_soldto LEFT DELETING LEADING lc_zero.
                ELSEIF lwa_kna1-bbbnr IS NOT INITIAL.
                  fp_gln_soldto = lwa_kna1-bbbnr.
                ENDIF. " IF lwa_kna1-bbsnr IS NOT INITIAL
              ENDIF. " IF sy-subrc IS INITIAL

            WHEN lc_ship_to.
              READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_vbpa-kunnr
                                                        BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                IF lwa_kna1-bbsnr IS NOT INITIAL.
                  CONCATENATE lwa_kna1-bbbnr lwa_kna1-bbsnr INTO fp_gln_shipto.
                  SHIFT fp_gln_shipto LEFT DELETING LEADING lc_zero.
                ELSEIF lwa_kna1-bbbnr IS NOT INITIAL.
                  fp_gln_shipto = lwa_kna1-bbbnr.
                ENDIF. " IF lwa_kna1-bbsnr IS NOT INITIAL
              ENDIF. " IF sy-subrc IS INITIAL

            WHEN lc_bill_to.
              READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_vbpa-kunnr
                                                        BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                IF lwa_kna1-bbsnr IS NOT INITIAL.
                  CONCATENATE lwa_kna1-bbbnr lwa_kna1-bbsnr INTO fp_gln_billto.
                  SHIFT fp_gln_billto LEFT DELETING LEADING lc_zero.
                ELSEIF lwa_kna1-bbbnr IS NOT INITIAL.
                  fp_gln_billto = lwa_kna1-bbbnr.
                ENDIF. " IF lwa_kna1-bbsnr IS NOT INITIAL
              ENDIF. " IF sy-subrc IS INITIAL

            WHEN OTHERS.
              CONTINUE.
          ENDCASE.
          CLEAR: lwa_vbpa,
                 lwa_kna1.
        ENDLOOP. " LOOP AT li_vbpa INTO lwa_vbpa
      ENDIF. " IF sy-subrc IS INITIAL
      FREE: li_kna1[],
            li_vbpa_kunnr[].
    ENDIF. " IF li_vbpa_kunnr IS NOT INITIAL
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

  ENDIF. " IF sy-subrc = 0
*End of insert for D3_OTC_FDD_0012 by U034336

*&--Fetch Sales document header data
  SELECT SINGLE ernam "Name of Person who Created the Object
                vkorg "Sales Organization
                audat "Document Date
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                auart
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
                waerk     "Currency
                vtweg     " Distribution Channel
                vsbed     "Shipping Conditions
                zzdocref  " Legacy Doc Ref
                zzdoctyp  " Ref Doc type
                zzcaseref " Case Ref No
                knumv     " Number of the document condition
*Begin of insert for D3_OTC_FDD_0012 by U034336
                kunnr
*End of insert for D3_OTC_FDD_0012 by U034336
           FROM vbak " Sales Document: Header Data
           INTO (fp_header-ernam, fp_header-vkorg,fp_header-audat,
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                 fp_auart,
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
                 fp_header-waerk,fp_header-vtweg, lv_vsbed,
                 lv_zzdocref,lv_zzdoctyp,lv_zzcaseref,fp_header-knumv,
*Begin of insert for D3_OTC_FDD_0012 by U034336
                 fp_kunnr)
*End of insert for D3_OTC_FDD_0012 by U034336
          WHERE vbeln = fp_vbeln.

  IF sy-subrc = 0.

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*Calling FM to check if the enhancement is active for object id
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_fdd_0012
      TABLES
        tt_enh_status     = li_status.
*Non active entries are removed.
**This table does not result out in many entries
    DELETE li_status WHERE active EQ abap_false.

*Begin of insert for D3_OTC_FDD_0012 by U034336

*Since this table does not result out in many entries
*so binary search is not used
* Check if sales organisation falls under the list of sales org for D3
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_vkorg_format
                                                         sel_low = fp_header-vkorg.

    IF sy-subrc EQ 0.
      fp_header-d3_format_flag = abap_true.
    ENDIF. " IF sy-subrc EQ 0

*End of insert for D3_OTC_FDD_0012 by U034336

*Since this table does not result out in many entries
*so binary search is not used
*Read table to get the language code based on the company code comaprision
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_langu
                                                         sel_low = fp_header-vkorg.

*For language check
    IF sy-subrc EQ 0.
      fp_langu = <lfs_status>-sel_high.

*Begin of insert for D3_OTC_FDD_0012 by U034336
* If D2 check fails , then language is populated from Sold to csutomer language
    ELSE. " ELSE -> IF sy-subrc EQ 0
* First check if nast-spras is not blank, else take sold to cust lang form ADRC
* and if language comes blank or it is not FR, DE or ES, then make it english
      IF fp_nast-spras IS NOT INITIAL.
        fp_langu               = fp_nast-spras.
        fp_header-sold_to_lang = fp_nast-spras.
      ELSE. " ELSE -> IF fp_nast-spras IS NOT INITIAL

        fp_langu               = lv_sold_to_lang.
        fp_header-sold_to_lang = lv_sold_to_lang.
      ENDIF. " IF fp_nast-spras IS NOT INITIAL

*Since this table does not result out in many entries
*so binary search is not used
      READ TABLE li_status TRANSPORTING NO FIELDS WITH KEY criteria = lc_eu_langu
                                                           sel_low =  fp_langu.
      IF sy-subrc NE 0.
        fp_langu               = lc_english.
        fp_header-sold_to_lang = lc_english.
      ENDIF. " IF sy-subrc NE 0

      IF  fp_header-d3_format_flag IS NOT INITIAL.
        lv_ord_date_char =  fp_header-audat.

        PERFORM f_convert_date_format USING    li_status
                                               lv_ord_date_char
                                               fp_header
                                      CHANGING lv_ord_date_char.

        fp_header-audat_char = lv_ord_date_char.
      ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL

*End of insert for D3_OTC_FDD_0012 by U034336

    ENDIF. " IF sy-subrc EQ 0

*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    READ TABLE li_status TRANSPORTING NO FIELDS WITH KEY criteria = lc_language
                                                          sel_low = fp_langu.
    IF sy-subrc EQ 0.
      fp_lang_fr  = abap_true.
    ENDIF. " IF sy-subrc EQ 0
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*Since this table does not result out in many entries
*so binary search is not used
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5822 by NSAXENA

* ---> Begin of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU
** the below code is commented
*Read table to get the value of freight - PREPAID
*    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_freight.
*
**For language check
*    IF sy-subrc EQ 0.
*      lv_freight_header = <lfs_status>-sel_low.
*    ENDIF. " IF sy-subrc EQ 0
**Freight value
*    fp_header-freight  = lv_freight_header.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5822 by NSAXENA

    SELECT SINGLE inco1    " Incoterms (Part 1)
                 INTO lv_inco
                 FROM vbkd " Sales Document: Business Data
                WHERE vbeln = fp_vbeln
                  AND posnr = lc_posnr.
    IF sy-subrc = 0.
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_dap.
      IF sy-subrc = 0.
        lv_dap = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc = 0
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_fca.
      IF sy-subrc = 0.
        lv_fca = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

    CASE lv_inco.
      WHEN lv_dap.
*Read table to get the value of freight - PREPAID
        READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_freight.

        IF sy-subrc EQ 0.
          lv_freight_header = <lfs_status>-sel_low.
        ENDIF. " IF sy-subrc EQ 0
*Freight value
        fp_header-freight  = lv_freight_header.
      WHEN lv_fca.
*Read table to get the value of freight - COLLECT
        READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_freight1.

        IF sy-subrc EQ 0.
          lv_freight_header = <lfs_status>-sel_low.
        ENDIF. " IF sy-subrc EQ 0
*Freight value
        fp_header-freight  = lv_freight_header.
    ENDCASE.
* <--- End of Change for D2_OTC_FDD_0012 Defect# 1697 / CR 1612 by PDEBARU


    IF li_id[] IS NOT INITIAL.
      IF fp_langu CS '_'.
        SPLIT fp_langu AT '_' INTO lv_langu1
                                   lv_langu2.
      ELSE. " ELSE -> IF fp_langu CS '_'
        lv_langu1 = fp_langu.
        lv_langu2 = lc_space.
      ENDIF. " IF fp_langu CS '_'

*Begin of insert for D3_OTC_FDD_0012 by U034336
*Passed value of order number so that the next select does not
*fail
      lv_name = fp_vbeln.
      lv_langu_read_text = lv_langu1.
*End of insert for D3_OTC_FDD_0012 by U034336

*When language is accepted we can chehck for texts
*maintrianed in STXH table with text id for header details
      SELECT tdobject                   " Texts: Application Object
             tdname                     " Name
             tdid                       " Text ID
             tdspras                    " Language Key
             FROM stxh                  " STXD SAPscript text file header
             INTO TABLE li_name
            FOR ALL ENTRIES IN li_id    "Header text internal table with text ids
             WHERE tdobject = lc_object "Object
             AND tdname = lv_name       "Sales order number
             AND tdid = li_id-id        "Text IDs
             AND tdspras = lv_langu1.   "language key
      IF sy-subrc EQ 0.
        SORT li_name BY id.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_id[] IS NOT INITIAL
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    IF fp_header-d3_format_flag IS INITIAL.
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*&--Fetch Route/Shipping Conditions: Texts
      SELECT SINGLE vsbed vtext "Description of the shipping conditions
               INTO (fp_header-vsbed,fp_header-route)
               FROM tvsbt       " Shipping Conditions: Texts
              WHERE spras = fp_nast-spras
                AND vsbed = lv_vsbed.
      IF sy-subrc EQ 0.

*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
* If shipping cond exists then set this flag
        lv_flag_skip = abap_true.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF fp_header-d3_format_flag IS INITIAL
* if it is a part of D3 or shipping cond flag is set then
* fetch address data for any of the cases.
    IF  fp_header-d3_format_flag IS NOT INITIAL
      OR  lv_flag_skip IS NOT INITIAL.
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336

*Begin of delete for D3_OTC_FDD_0012 by U034336
*This piece of code under the tags has been moved form
*this position so that we can make use of the those varaibles
*whose values are being populated during the select
**&--Fetch Sales Document: Partner data
*      SELECT     vbeln " Sales and Distribution Document Number
*                 posnr " Item number of the SD document
*                 parvw "Partner Function
*                 kunnr "Customer Number
*                 parnr "Contact person number
*                 adrnr "Address Number
*                 adrnp "personnel number in case of ZA partner function
*            FROM vbpa  " Sales Document: Partner
*            INTO TABLE li_vbpa
*           WHERE vbeln = fp_vbeln
*             AND posnr = lc_posnr
*             AND parvw IN (lc_contact,lc_contact_other, lc_sold_to, lc_ship_to).
*
*      IF sy-subrc = 0.
*       DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING ALL FIELDS.
*
**&--Get all address correspoding to partner data
*      SELECT addrnumber "Address No.              "#EC NEEDED
*             date_from  " Valid-from date - in current Release only 00010101 possible
*             nation     " Version ID for International Addresses
*             name1      " Name 1
*             name2      " Name 2
*             name3      " Name 3
*             name4      " Name 4
*             building   " Building (Number or Code)
*             floor      " Floor in building
*             roomnumber " Room or Appartment Number
*             house_num2 " House number supplement
*             house_num1 " House No.
*             street     " Street
*             str_suppl1 " Street 2
*             str_suppl2 " Street 3
*             str_suppl3 " Street 4
*             po_box     " PO Box
*             city1      " City
*             city2      " District
*             post_code1 " City postal code
*             post_code2 " PO Box Postal Code
*             country    " Country Key
*             region     " Region
*             tel_number " First telephone no.: dialling code+number
*        INTO TABLE li_address
*        FROM adrc       " Addresses (Business Address Services)
*         FOR ALL ENTRIES IN li_vbpa
*       WHERE addrnumber = li_vbpa-adrnr.
*      IF sy-subrc = 0.
**Delete address lines where the valid date is greater then current date
*        DELETE li_address WHERE date_from GT sy-datum.
*        DELETE ADJACENT DUPLICATES FROM li_address COMPARING ALL FIELDS.
*End of delete for D3_OTC_FDD_0012 by U034336

* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
* Change in logic to get telephone number , it was coming blank from ADRC
* So now it is being fetched from ADR2 based on VBPA-ADRNR.
      IF li_vbpa[] IS NOT INITIAL.
        li_vbpa_tmp1[] = li_vbpa[].
        SORT li_vbpa_tmp1 BY parvw kunnr.

        li_vbpa_temp[]  = li_vbpa[].
        SORT li_vbpa_temp  BY adrnr.
        DELETE ADJACENT DUPLICATES FROM li_vbpa_temp  COMPARING adrnr.
        IF li_vbpa_temp[] IS NOT INITIAL.

          SELECT addrnumber                     " Address number
                 date_from                      " Valid-from date - in current Release only 00010101 possible
                 consnumber                     " Sequence Number
                 tel_number                     " Telephone no.: dialling code+number
         INTO TABLE li_telno
         FROM adr2                              " Telephone Numbers (Business Address Services)
         FOR ALL ENTRIES IN li_vbpa_temp
         WHERE addrnumber = li_vbpa_temp-adrnr. "Address number
          IF sy-subrc EQ 0.
* Delete the invalid record based on date_from and select the latest record based on consnumber(seq no).
            DELETE li_telno WHERE date_from GT sy-datum.
            IF li_telno[] IS NOT INITIAL.
              SORT li_telno BY addrnumber
                               date_from DESCENDING
                               consnumber DESCENDING.
            ENDIF. " IF li_telno[] IS NOT INITIAL
          ENDIF. " IF sy-subrc EQ 0

* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336

          SELECT  addrnumber                            " Address number
                   date_from                            " Valid-from date - in current Release only 00010101 possible
                   consnumber                           "++D3_OTC_FDD_0012 Defect 5455
                   smtp_addr                            "E-Mail Address
                   INTO TABLE li_email
                   FROM adr6                            " E-Mail Addresses (Business Address Services)
                  FOR ALL ENTRIES IN li_vbpa_temp
                 WHERE addrnumber = li_vbpa_temp-adrnr. "Address number
          IF sy-subrc EQ 0.
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
* Delete the invalid record based on date_from and select the latest record based on consnumber(seq no).
            DELETE li_email WHERE date_from GT sy-datum.
            IF li_email[] IS NOT INITIAL.
              SORT li_email BY addrnumber
                               date_from DESCENDING
                               consnumber DESCENDING.
            ENDIF. " IF li_email[] IS NOT INITIAL
* <--- End    of Insert for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN

*&--Read tabel for the condition Partner fucntion equals to CP.
            READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact. " for PARVW=CP
            IF sy-subrc EQ 0.
*&--Read Contact Person Address details
              READ TABLE li_address ASSIGNING <lfs_addr>
                                WITH KEY adrnr = <lfs_vbpa>-adrnr. "Address number
              IF sy-subrc = 0.
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* Code commented here as structure type doesn't match with the table type so
* structure have been populated below explicitly
*                fp_contact_addr = <lfs_addr>.
* ---> End of Delete for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
                fp_contact_addr-adrnr = <lfs_addr>-adrnr.
                fp_contact_addr-date_from = <lfs_addr>-date_from.
                fp_contact_addr-nation = <lfs_addr>-nation.
                fp_contact_addr-name1 = <lfs_addr>-name1.
                fp_contact_addr-name2 = <lfs_addr>-name2.
                fp_contact_addr-name3 = <lfs_addr>-name3.
                fp_contact_addr-name4 = <lfs_addr>-name4.
                fp_contact_addr-building = <lfs_addr>-building.
                fp_contact_addr-floor = <lfs_addr>-floor.
                fp_contact_addr-roomnumber = <lfs_addr>-roomnumber.
                fp_contact_addr-house_num2 = <lfs_addr>-house_num2.
                fp_contact_addr-house_num1 = <lfs_addr>-house_num1.
                fp_contact_addr-street = <lfs_addr>-street.
                fp_contact_addr-str_suppl1 = <lfs_addr>-str_suppl1.
                fp_contact_addr-str_suppl2 = <lfs_addr>-str_suppl2.
                fp_contact_addr-str_suppl3 = <lfs_addr>-str_suppl3.
                fp_contact_addr-po_box = <lfs_addr>-po_box.
                fp_contact_addr-city1 = <lfs_addr>-city1.
                fp_contact_addr-city2 = <lfs_addr>-city2.
                fp_contact_addr-post_code1 = <lfs_addr>-post_code1.
                fp_contact_addr-post_code2 = <lfs_addr>-post_code2.
                fp_contact_addr-country = <lfs_addr>-country.
                fp_contact_addr-region = <lfs_addr>-region.
                fp_contact_addr-tel_number = <lfs_addr>-tel_number.
                fp_contact_addr-langu = <lfs_addr>-langu.
* ---> End of Insert for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect 5455 by U034336
*            CONDENSE fp_contact_addr-tel_number.
* ---> End of Delete for D3_OTC_FDD_0012 Defect 5455 by U034336
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
*&--Fetch Contact Person Tel No
                READ TABLE li_telno ASSIGNING <lfs_telno> WITH KEY addrnumber = <lfs_vbpa>-adrnr
                                                                              BINARY SEARCH.
                IF sy-subrc EQ 0.
                  fp_contact_addr-tel_number = <lfs_telno>-tel_number.
                ENDIF. " IF sy-subrc EQ 0

* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
*&--Fetch Contact Person E-Mail Address
                READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
                                                                              BINARY SEARCH.
                IF sy-subrc EQ 0.
                  IF NOT <lfs_email>-date_from GT sy-datum.
                    fp_contact_addr-smtp_addr = <lfs_email>-smtp_addr.
                  ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF sy-subrc = 0
            ELSE. " ELSE -> IF sy-subrc EQ 0
*&--Read Bill to customer Address no.
              READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact_other. "For PARVW=ZA
              IF sy-subrc EQ 0.
*&--Read Contact Person Address details
                READ TABLE li_address ASSIGNING <lfs_addr>
                                  WITH KEY adrnr = <lfs_vbpa>-adrnr. "Address number
                IF sy-subrc = 0.
                  fp_contact_addr = <lfs_addr>.

* ---> Begin of Delete for D3_OTC_FDD_0012 Defect 5455 by U034336
*            CONDENSE fp_contact_addr-tel_number.
* ---> End of Delete for D3_OTC_FDD_0012 Defect 5455 by U034336
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
*&--Fetch Contact Person Tel No
                  READ TABLE li_telno ASSIGNING <lfs_telno> WITH KEY addrnumber = <lfs_vbpa>-adrnr
                                                                                BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    fp_contact_addr-tel_number = <lfs_telno>-tel_number.
                  ENDIF. " IF sy-subrc EQ 0

* ---> End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
*&--Fetch Contact Person E-Mail Address
                  READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
                                                      BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    IF NOT <lfs_email>-date_from GT sy-datum.
                      fp_contact_addr-smtp_addr = <lfs_email>-smtp_addr.
                    ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
                  ENDIF. " IF sy-subrc EQ 0
                ENDIF. " IF sy-subrc = 0
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336
        ENDIF. " IF li_vbpa_temp[] IS NOT INITIAL
      ENDIF. " IF li_vbpa[] IS NOT INITIAL
* --->End of Insert for D3_OTC_FDD_0012 Defect 5455 by U034336

*       If Contact Person Details are not maintained,
*       Get the Email ID & Telephone Number of customer
      IF fp_contact_addr-name1 IS INITIAL.
*         Get the Address Numbder of Customer from KNA1 table
        SELECT SINGLE name1 " Address
          INTO lv_name1
          FROM kna1         " General Data in Customer Master
          WHERE kunnr = fp_nast-parnr.
        IF sy-subrc EQ 0.
          fp_contact_addr-name1 = lv_name1.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF fp_contact_addr-name1 IS INITIAL

      IF fp_contact_addr-smtp_addr IS INITIAL.

*         Get the Address Numbder of Customer from KNA1 table
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
* Address should always be pick up from VBPA. So, get the address number
* from VBPA instead of KNA1.

*        SELECT SINGLE adrnr " Address
*          FROM kna1         " General Data in Customer Master
*          INTO lv_adrnr     " General Data in Customer Master
*          WHERE kunnr = fp_nast-parnr.
* <--- End    of Delete for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
        READ TABLE li_vbpa_tmp1 ASSIGNING <lfs_vbpa> WITH KEY parvw = fp_nast-parvw
                                                              kunnr = fp_nast-parnr
                                                              BINARY SEARCH.
* <--- End    of Insert for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN

        IF sy-subrc EQ 0.
          lv_adrnr = <lfs_vbpa>-adrnr. "++D3_OTC_FDD_0012 Defect 5455
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
                CONDENSE fp_contact_addr-tel_number.
              ENDIF. " IF fp_contact_addr-tel_number IS NOT INITIAL
            ENDIF. " IF sy-subrc EQ 0
*           Get Email-ID of Customer
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
* Below select is not required as parnter in NAST will be one of parnter in VBPA.
* Data selection of ADR6 is already done for parnters in VBPA.
*            SELECT smtp_addr "E-Mail Address
*                  UP TO 1 ROWS
*                   FROM adr6 " E-Mail Addresses (Business Address Services)
*                    INTO fp_contact_addr-smtp_addr
*                  WHERE addrnumber = lv_adrnr.
*            ENDSELECT.
* <--- End    of Delete for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
* Instead of select use read statement to get the email id.
            READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = lv_adrnr
                                                  BINARY SEARCH.
* <--- End    of Insert for D3_OTC_FDD_0012 Defect 5455 by DMOIRAN

            IF sy-subrc EQ 0.
              fp_contact_addr-smtp_addr = <lfs_email>-smtp_addr. "++D3_OTC_FDD_0012 Defect 5455 by DMOIRAN
              IF fp_contact_addr-smtp_addr IS NOT INITIAL.
                CONDENSE fp_contact_addr-smtp_addr.
              ENDIF. " IF fp_contact_addr-smtp_addr IS NOT INITIAL
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lv_adrnr IS NOT INITIAL
        ELSE. " ELSE -> IF sy-subrc EQ 0
          CLEAR lwa_vbpa.
          READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact_other. " for parvw = ZA
          IF sy-subrc = 0.
*           Get Email-ID of Customer
            SELECT smtp_addr "E-Mail Address
                  UP TO 1 ROWS
                   FROM adr6 " E-Mail Addresses (Business Address Services)
                    INTO fp_contact_addr-smtp_addr
                  WHERE addrnumber = <lfs_vbpa>-adrnr.
*                           AND persnumber = <lfs_vbpa>-adrnp."COmmented by NSAXENA.
            ENDSELECT.
            IF sy-subrc EQ 0.
              IF fp_contact_addr-smtp_addr IS NOT INITIAL.
                CONDENSE fp_contact_addr-smtp_addr.
              ENDIF. " IF fp_contact_addr-smtp_addr IS NOT INITIAL
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF fp_contact_addr-smtp_addr IS INITIAL

      READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact_other.
      IF sy-subrc EQ 0.
        fp_contact_addr_check-adrnr = <lfs_vbpa>-adrnr.
        READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
                                                  BINARY SEARCH.
        IF sy-subrc EQ 0.
          IF NOT <lfs_email>-date_from GT sy-datum.
            fp_contact_addr_check-smtp_addr = <lfs_email>-smtp_addr.
          ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
        ENDIF. " IF sy-subrc EQ 0
      ELSE. " ELSE -> IF sy-subrc EQ 0
        READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact.
        IF sy-subrc EQ 0.
          fp_contact_addr_check-adrnr = <lfs_vbpa>-adrnr.
          READ TABLE li_email ASSIGNING <lfs_email> WITH KEY addrnumber = <lfs_vbpa>-adrnr
                                                BINARY SEARCH.
          IF sy-subrc EQ 0.
            IF NOT <lfs_email>-date_from GT sy-datum.
              fp_contact_addr_check-smtp_addr = <lfs_email>-smtp_addr.
            ENDIF. " IF NOT <lfs_email>-date_from GT sy-datum
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0


*&--Read ship to customer Address no.with parvw = WE
      READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_ship_to.
      IF sy-subrc = 0.
*&--Populate Ship-to-Party Number
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = <lfs_vbpa>-kunnr
          IMPORTING
            output = fp_ship_no.

*&--Read ship to customer Address details
        READ TABLE li_address ASSIGNING <lfs_addr>
                          WITH KEY adrnr = <lfs_vbpa>-adrnr.
        IF sy-subrc EQ 0.
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* Code commented here as structure type doesn't match with the table type so
* structure have been populated below explicitly
*          fp_ship_to_addr = <lfs_addr>.
* ---> End of Delete for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
          fp_ship_to_addr-adrnr = <lfs_addr>-adrnr.
          fp_ship_to_addr-date_from = <lfs_addr>-date_from.
          fp_ship_to_addr-nation = <lfs_addr>-nation.
          fp_ship_to_addr-name1 = <lfs_addr>-name1.
          fp_ship_to_addr-name2 = <lfs_addr>-name2.
          fp_ship_to_addr-name3 = <lfs_addr>-name3.
          fp_ship_to_addr-name4 = <lfs_addr>-name4.
          fp_ship_to_addr-building = <lfs_addr>-building.
          fp_ship_to_addr-floor = <lfs_addr>-floor.
          fp_ship_to_addr-roomnumber = <lfs_addr>-roomnumber.
          fp_ship_to_addr-house_num2 = <lfs_addr>-house_num2.
          fp_ship_to_addr-house_num1 = <lfs_addr>-house_num1.
          fp_ship_to_addr-street = <lfs_addr>-street.
          fp_ship_to_addr-str_suppl1 = <lfs_addr>-str_suppl1.
          fp_ship_to_addr-str_suppl2 = <lfs_addr>-str_suppl2.
          fp_ship_to_addr-str_suppl3 = <lfs_addr>-str_suppl3.
          fp_ship_to_addr-po_box = <lfs_addr>-po_box.
          fp_ship_to_addr-city1 = <lfs_addr>-city1.
          fp_ship_to_addr-city2 = <lfs_addr>-city2.
          fp_ship_to_addr-post_code1 = <lfs_addr>-post_code1.
          fp_ship_to_addr-post_code2 = <lfs_addr>-post_code2.
          fp_ship_to_addr-country = <lfs_addr>-country.
          fp_ship_to_addr-region = <lfs_addr>-region.
          fp_ship_to_addr-tel_number = <lfs_addr>-tel_number.
          fp_ship_to_addr-langu = <lfs_addr>-langu.
* ---> End of Insert for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
        ENDIF. " IF sy-subrc EQ 0
*Ship to Attention to text
        CLEAR: lv_name.
        REFRESH: li_lines[].
        lv_name = fp_vbeln.
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
        READ TABLE li_name ASSIGNING <lfs_name> WITH KEY id = lc_id_0002
                                                         BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
        IF sy-subrc NE 0.
          lv_langu1 = lc_english. "English language
*Begin of insert for D3_OTC_FDD_0012 by U034336
        ELSE. " ELSE -> IF sy-subrc NE 0
          lv_langu1 = lv_langu_read_text.
*End of insert for D3_OTC_FDD_0012 by U034336
        ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read the text with id 0002
        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id_0002 " Id
            language                = lv_langu1  "Lang
            name                    = lv_name    "Sales order number
            object                  = lc_object  "Object id
          TABLES
            lines                   = li_lines   "Text lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          LOOP AT li_lines ASSIGNING <lfs_lines>.
            MOVE <lfs_lines>-tdline TO lv_ship_attention.
            IF sy-tabix EQ 1.
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
*To Read the text with id lc_att_to
*  Attention to
              CALL FUNCTION 'READ_TEXT'
                EXPORTING
                  id                      = lc_id              "ST
                  language                = lv_langu_read_text "language
                  name                    = lc_att_to          "Stndrd text
                  object                  = lc_object_txt      "object id
                TABLES
                  lines                   = li_lines_temp      "Text lines
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
                READ TABLE li_lines_temp ASSIGNING <lfs_lines_temp> INDEX 1.
                IF sy-subrc EQ 0.
                  CONCATENATE <lfs_lines_temp>-tdline lv_ship_attention INTO fp_ship_att SEPARATED BY space.
                ENDIF. " IF sy-subrc EQ 0
              ENDIF. " IF sy-subrc EQ 0
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect 5486 by U034336
*Eralier attention to was hard coded as a text symbol but now this
*code is no more needed as we have made it as a standard text
*              CONCATENATE 'Attention to:'(013) lv_ship_attention INTO fp_ship_att SEPARATED BY space.
* ---> End of Delete for D3_OTC_FDD_0012 Defect 5486 by U034336
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
            ELSE. " ELSE -> IF sy-tabix EQ 1
              CONCATENATE fp_ship_att lv_ship_attention INTO fp_ship_att SEPARATED BY space.
* ---> End of Insert for D3_OTC_FDD_0012 Defect 5486 by U034336
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
      UNASSIGN <lfs_lines>.


*&--Read sold to customer Address no. with parvw = AG
      READ TABLE li_vbpa ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_sold_to.
      IF sy-subrc = 0.
*&--Populate sold-to-Party Number
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = <lfs_vbpa>-kunnr
          IMPORTING
            output = fp_sold_no.

*&--Read Ship to customer Address details
        READ TABLE li_address ASSIGNING <lfs_addr>
                          WITH KEY adrnr = <lfs_vbpa>-adrnr.
        IF sy-subrc EQ 0.
* ---> Begin of Delete for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* Code commented here as structure type doesn't match with the table type so
* structure have been populated below explicitly
*          fp_sold_to_addr = <lfs_addr>.
* ---> End of Delete for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
* ---> Begin of Insert for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
          fp_sold_to_addr-adrnr = <lfs_addr>-adrnr.
          fp_sold_to_addr-date_from = <lfs_addr>-date_from.
          fp_sold_to_addr-nation = <lfs_addr>-nation.
          fp_sold_to_addr-name1 = <lfs_addr>-name1.
          fp_sold_to_addr-name2 = <lfs_addr>-name2.
          fp_sold_to_addr-name3 = <lfs_addr>-name3.
          fp_sold_to_addr-name4 = <lfs_addr>-name4.
          fp_sold_to_addr-building = <lfs_addr>-building.
          fp_sold_to_addr-floor = <lfs_addr>-floor.
          fp_sold_to_addr-roomnumber = <lfs_addr>-roomnumber.
          fp_sold_to_addr-house_num2 = <lfs_addr>-house_num2.
          fp_sold_to_addr-house_num1 = <lfs_addr>-house_num1.
          fp_sold_to_addr-street = <lfs_addr>-street.
          fp_sold_to_addr-str_suppl1 = <lfs_addr>-str_suppl1.
          fp_sold_to_addr-str_suppl2 = <lfs_addr>-str_suppl2.
          fp_sold_to_addr-str_suppl3 = <lfs_addr>-str_suppl3.
          fp_sold_to_addr-po_box = <lfs_addr>-po_box.
          fp_sold_to_addr-city1 = <lfs_addr>-city1.
          fp_sold_to_addr-city2 = <lfs_addr>-city2.
          fp_sold_to_addr-post_code1 = <lfs_addr>-post_code1.
          fp_sold_to_addr-post_code2 = <lfs_addr>-post_code2.
          fp_sold_to_addr-country = <lfs_addr>-country.
          fp_sold_to_addr-region = <lfs_addr>-region.
          fp_sold_to_addr-tel_number = <lfs_addr>-tel_number.
          fp_sold_to_addr-langu = <lfs_addr>-langu.
* ---> End of Insert for D3_OTC_FDD_0012 Defect#12010 by Sudhanshu
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

      "Read bill to customer for getting details
      READ TABLE li_vbpa INTO lwa_vbpa_bill WITH KEY parvw = lc_bill_to.
      IF sy-subrc = 0.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lwa_vbpa_bill-kunnr
          IMPORTING
            output = fp_bill_no.

        READ TABLE li_address INTO lwa_addr_bill
                            WITH KEY adrnr = lwa_vbpa_bill-adrnr.
        IF sy-subrc EQ 0.
          fp_lwa_bill_to-adrnr      = lwa_addr_bill-adrnr.
          fp_lwa_bill_to-date_from  = lwa_addr_bill-date_from.
          fp_lwa_bill_to-nation     = lwa_addr_bill-nation.
          fp_lwa_bill_to-name1      = lwa_addr_bill-name1.
          fp_lwa_bill_to-name2      = lwa_addr_bill-name2.
          fp_lwa_bill_to-name3      = lwa_addr_bill-name3.
          fp_lwa_bill_to-name4      = lwa_addr_bill-name4.
          fp_lwa_bill_to-building   = lwa_addr_bill-building.
          fp_lwa_bill_to-floor      = lwa_addr_bill-floor.
          fp_lwa_bill_to-roomnumber = lwa_addr_bill-roomnumber.
          fp_lwa_bill_to-house_num2 = lwa_addr_bill-house_num2.
          fp_lwa_bill_to-house_num1 = lwa_addr_bill-house_num1.
          fp_lwa_bill_to-street     = lwa_addr_bill-street.
          fp_lwa_bill_to-str_suppl1 = lwa_addr_bill-str_suppl1.
          fp_lwa_bill_to-str_suppl2 = lwa_addr_bill-str_suppl2.
          fp_lwa_bill_to-str_suppl3 = lwa_addr_bill-str_suppl3.
          fp_lwa_bill_to-po_box     = lwa_addr_bill-po_box.
          fp_lwa_bill_to-city1      = lwa_addr_bill-city1.
          fp_lwa_bill_to-city2      = lwa_addr_bill-city2.
          fp_lwa_bill_to-post_code1 = lwa_addr_bill-post_code1.
          fp_lwa_bill_to-post_code2 = lwa_addr_bill-post_code2.
          fp_lwa_bill_to-country    = lwa_addr_bill-country.
          fp_lwa_bill_to-region     = lwa_addr_bill-region.
          fp_lwa_bill_to-tel_number = lwa_addr_bill-tel_number.
          fp_lwa_bill_to-langu      = lwa_addr_bill-langu.

        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc = 0
      "Clearing the local variables
      CLEAR: lwa_addr_bill,
             lwa_vbpa_bill.


*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017


*Begin of delete for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*    ENDIF. " IF sy-subrc EQ 0
*End of delete for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
    ENDIF. " IF fp_header-d3_format_flag IS NOT INITIAL
*End of insert for D3_OTC_FDD_0012 CR#301_Part-2 by U034336
*      ENDIF. " IF sy-subrc = 0
*    ENDIF. " IF sy-subrc EQ 0

    CLEAR: lv_name.
    REFRESH: li_lines[].
    lv_name = fp_vbeln.

* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    READ TABLE li_name ASSIGNING <lfs_name> WITH KEY id = lc_id_z009
                                                       BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
    IF sy-subrc NE 0.
      lv_langu1 = lc_english. "English language
*Begin of insert for D3_OTC_FDD_0012 by U034336
    ELSE. " ELSE -> IF sy-subrc NE 0
      lv_langu1 = lv_langu_read_text.
*End of insert for D3_OTC_FDD_0012 by U034336
    ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA

*To Read the text with id z009
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id_z009 "Id
        language                = lv_langu1  "Lang
        name                    = lv_name    "Sales Order number
        object                  = lc_object  "Object Id
      TABLES
        lines                   = li_lines   "Text lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      LOOP AT li_lines ASSIGNING <lfs_lines> .
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
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
    READ TABLE li_name ASSIGNING <lfs_name> WITH KEY id = lc_id_z012
                                                     BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
    IF sy-subrc NE 0.
      lv_langu1 = lc_english. "English language
*Begin of insert for D3_OTC_FDD_0012 by U034336
    ELSE. " ELSE -> IF sy-subrc NE 0
      lv_langu1 = lv_langu_read_text.
*End of insert for D3_OTC_FDD_0012 by U034336
    ENDIF. " IF sy-subrc NE 0
* <--- End of Insert for D2_OTC_FDD_0012,Defect #4829 by NSAXENA
*To Read the text with id z012
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id_z012 "Id
        language                = lv_langu1  "lang
        name                    = lv_name    "sales order number
        object                  = lc_object  "Object id
      TABLES
        lines                   = li_lines   "Text lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      LOOP AT li_lines ASSIGNING <lfs_lines>.
        IF sy-tabix EQ 1.
          MOVE <lfs_lines>-tdline TO lv_ord_comments_part2.
        ELSE. " ELSE -> IF sy-tabix EQ 1
          CONCATENATE lv_ord_comments_part2 <lfs_lines>-tdline INTO lv_ord_comments_part2 SEPARATED BY space.
        ENDIF. " IF sy-tabix EQ 1
      ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
*Begin of insert for D3_OTC_FDD_0012 CR#289 by U034336
    ELSE. " ELSE -> IF sy-subrc = 0
      IF lv_langu1 NE lc_english.

        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = lc_id_z012 "Id
            language                = lc_english
            name                    = lv_name    "sales order number
            object                  = lc_object  "Object id
          TABLES
            lines                   = li_lines   "Text lines
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.
        IF sy-subrc = 0.
          LOOP AT li_lines ASSIGNING <lfs_lines>.
            IF sy-tabix EQ 1.
              MOVE <lfs_lines>-tdline TO lv_ord_comments_part2.
            ELSE. " ELSE -> IF sy-tabix EQ 1
              CONCATENATE lv_ord_comments_part2 <lfs_lines>-tdline INTO lv_ord_comments_part2 SEPARATED BY space.
            ENDIF. " IF sy-tabix EQ 1
          ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lv_langu1 NE lc_english
*End of insert for D3_OTC_FDD_0012 CR#289 by U034336
    ENDIF. " IF sy-subrc = 0
    UNASSIGN <lfs_lines>.

*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
    REFRESH: li_lines[].

    READ TABLE li_name ASSIGNING <lfs_name> WITH KEY id = lc_id_cup
                                                     BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
    IF sy-subrc NE 0.
      lv_langu1 = lc_english. "English language
    ELSE. " ELSE -> IF sy-subrc NE 0
      lv_langu1 = lv_langu_read_text.
    ENDIF. " IF sy-subrc NE 0

*To Read the text with id CUP
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id_cup  "Id
        language                = lv_langu1  "Lang
        name                    = lv_name    "Sales Order number
        object                  = lc_object  "Object Id
      TABLES
        lines                   = li_lines   "Text lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
      IF sy-subrc EQ 0.
        MOVE <lfs_lines>-tdline TO lv_cup_val.
      ENDIF. " IF sy-tabix EQ 1
    ENDIF. " IF sy-subrc = 0
    UNASSIGN <lfs_lines>.

    CLEAR: lv_name.
    REFRESH: li_lines[].
    lv_name = fp_vbeln.

    READ TABLE li_name ASSIGNING <lfs_name> WITH KEY id = lc_id_cig
                                                     BINARY SEARCH.
*if the text is not maintained in respective language by default we will
*fetch pass english language.
    IF sy-subrc NE 0.
      lv_langu1 = lc_english. "English language
    ELSE. " ELSE -> IF sy-subrc NE 0
      lv_langu1 = lv_langu_read_text.
    ENDIF. " IF sy-subrc NE 0

*To Read the text with id CIG
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id_cig  "Id
        language                = lv_langu1  "Lang
        name                    = lv_name    "Sales Order number
        object                  = lc_object  "Object Id
      TABLES
        lines                   = li_lines   "Text lines
      EXCEPTIONS
        id                      = 1
        language                = 2
        name                    = 3
        not_found               = 4
        object                  = 5
        reference_check         = 6
        wrong_access_to_archive = 7
        OTHERS                  = 8.
    IF sy-subrc = 0.
      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
      IF sy-subrc EQ 0.
        MOVE <lfs_lines>-tdline TO lv_cig_val.
      ENDIF. " IF sy-tabix EQ 1
    ENDIF. " IF sy-subrc = 0
    UNASSIGN <lfs_lines>.

    IF lv_cup_val IS NOT INITIAL AND lv_cig_val IS NOT INITIAL.
      CONCATENATE lv_cup_val lc_slash lv_cig_val INTO fp_cup_cig_val SEPARATED BY space.
*CUP/CIG
      FREE li_lines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lc_id         "ST
          language                = lv_langu1     "Lang
          name                    = lc_cup_cig_id "Stndrd text
          object                  = lc_object_txt  "object id
        TABLES
          lines                   = li_lines      "Text lines
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
          MOVE <lfs_lines>-tdline TO fp_cup_cig_text.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0

    ELSEIF lv_cup_val IS NOT INITIAL AND lv_cig_val IS INITIAL.
      fp_cup_cig_val = lv_cup_val.
*CUP
      FREE li_lines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lc_id          "ST
          language                = lv_langu1      "Lang
          name                    = lc_cup_id      "Stndrd text
          object                  = lc_object_txt  "object id
        TABLES
          lines                   = li_lines      "Text lines
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
          MOVE <lfs_lines>-tdline TO fp_cup_cig_text.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0

    ELSEIF lv_cup_val IS INITIAL AND lv_cig_val IS NOT INITIAL.
      fp_cup_cig_val = lv_cig_val.
*CIG
      FREE li_lines.
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          id                      = lc_id          "ST
          language                = lv_langu1      "Lang
          name                    = lc_cig_id      "Stndrd text
          object                  = lc_object_txt  "object id
        TABLES
          lines                   = li_lines       "Text lines
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
          MOVE <lfs_lines>-tdline TO fp_cup_cig_text.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

    IF lv_zzdoctyp IS NOT INITIAL.
      CONCATENATE '00' lv_zzdoctyp INTO lv_valpos.
      SELECT SINGLE ddtext " Short Text for Fixed Values
             FROM dd07t    " DD: Texts for Domain Fixed Values (Language-Dependent)
             INTO lv_doctyp
             WHERE domname = lc_domname
             AND   ddlanguage = sy-langu
             AND   as4local =  lc_as4local
             AND   valpos  = lv_valpos
             AND   as4vers = lc_cons_0000.
      IF sy-subrc EQ 0.
        lv_doctyp_ord = lv_doctyp.
      ENDIF. " IF sy-subrc EQ 0

    ENDIF. " IF lv_zzdoctyp IS NOT INITIAL
*Check for Ref text
    IF lv_zzdocref IS NOT INITIAL.
      CONCATENATE 'Ref#'(010) lv_zzdocref INTO lv_docref SEPARATED BY space.
    ENDIF. " IF lv_zzdocref IS NOT INITIAL
*Check for case ref text
    IF lv_zzcaseref IS NOT INITIAL.
* Begin of Delete for D3_OTC_FDD_0012, Defect#5480 by U034336
* Thi spart is commented as Case_Reference is no more required
*        CONCATENATE 'Case_Reference'(011) lv_zzcaseref INTO lv_caseref SEPARATED BY space.
* End of Delete for D3_OTC_FDD_0012, Defect#5480 by U034336
* Begin of insert for D3_OTC_FDD_0012, Defect#5480 by U034336
* Case_Reference has been changed to Case Ref #
      CONCATENATE 'Case Ref#'(015) lv_zzcaseref INTO lv_caseref SEPARATED BY space.
* End of insert for D3_OTC_FDD_0012, Defect#5480 by U034336
    ENDIF. " IF lv_zzcaseref IS NOT INITIAL
*Check for order comments part
    IF lv_ord_comments_part1 IS NOT INITIAL.
      lv_ord_1 = lv_ord_comments_part1.
    ENDIF. " IF lv_ord_comments_part1 IS NOT INITIAL
*Check for PROMO text
    IF lv_ord_comments_part2 IS NOT INITIAL.
      CONCATENATE 'Promotion'(001) lv_ord_comments_part2 INTO lv_ord_2 SEPARATED BY space.
    ENDIF. " IF lv_ord_comments_part2 IS NOT INITIAL
*combine the text for order comments
*Begin of insert for D3_OTC_FDD_0012 by U034336

    fp_header-ord_commnts_part2 = lv_ord_1.

* ---> Begin of Insert for D3_OTC_FDD_0012_Defect#9877
    IF lv_zzdoctyp = lc_zzdoctyp_08.
      IF lv_ord_comments_part2 IS NOT INITIAL.
        CONCATENATE 'Promotion'(001) lv_ord_comments_part2 INTO lv_ord_comments
             SEPARATED BY space.
      ENDIF.
    ELSE.
* <--- End    of Insert for D3_OTC_FDD_0012_Defect#9877

    CONCATENATE lv_ord_2 lv_doctyp_ord
            lv_docref lv_caseref INTO lv_ord_comments
            SEPARATED BY space.
* ---> Begin of Insert for D3_OTC_FDD_0012_Defect#9877
    ENDIF.
* <--- End    of Insert for D3_OTC_FDD_0012_Defect#9877
* <--- End
    CONDENSE lv_ord_comments.

*End of insert for D3_OTC_FDD_0012 by U034336

*Begin of delete for D3_OTC_FDD_0012 by U034336
*    CONCATENATE lv_ord_1 lv_ord_2 lv_doctyp_ord
*           lv_docref lv_caseref INTO lv_ord_comments
*           SEPARATED BY space.
*    CONDENSE lv_ord_comments.
*End of delete for D3_OTC_FDD_0012 by U034336
*Order Comments
*    fp_header-ord_comments
    fp_header-ord_comments = lv_ord_comments.

  ENDIF. " IF sy-subrc = 0

  SELECT SINGLE
*Begin of insert for D3_OTC_FDD_0012 by U034336
                inco1
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                inco2
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
                bstkd "Customer purchase order number
*Begin of insert for D3_OTC_FDD_0012 by U034336
           INTO (fp_header-inco1
*End of insert for D3_OTC_FDD_0012 by U034336
*Begin of insert for D3_OTC_FDD_0012 CR#301 by U034336
                ,fp_header-inco2
*End of insert for D3_OTC_FDD_0012 CR#301 by U034336
                 ,lv_bstkd)
           FROM vbkd " Sales Document: Business Data
          WHERE vbeln = fp_vbeln
            AND posnr = lc_posnr.
  IF sy-subrc EQ 0.
    fp_header-bstkd = lv_bstkd.
  ENDIF. " IF sy-subrc EQ 0

  REFRESH: li_lines[].
  CLEAR: lv_ord_comments,
         lv_valpos,
         lv_bstkd,
         lv_ord_1,
         lv_ord_comments_part1,
         lv_ord_2,
         lv_ord_comments_part2,
         lv_doctyp_ord,
         lv_doctyp,
         lv_docref,
         lv_zzdocref,
         lv_caseref,
         lv_zzcaseref.

ENDFORM. " F_GET_HEADER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_FILL_CONTROL_STRUCTURE
*&---------------------------------------------------------------------*
*       Fill Output Parameters Control Structure
*----------------------------------------------------------------------*
*      -->FP_NAST             Message Status
*      -->FP_FP_US_SCREEN     Print Preview
*      <--FP_LX_outputparams  Form Processing Output Parameter
*----------------------------------------------------------------------*
FORM f_fill_control_structure USING fp_nast      TYPE nast                  " Message Status
                                  fp_us_screen TYPE c                       " Us_screen of type Character
                         CHANGING fp_outputparams     TYPE sfpoutputparams. " Form Processing Output Parameter

  CLEAR: fp_outputparams.
*&--Fill Output Parameters Control Structure
  IF fp_us_screen IS INITIAL.
    CLEAR: fp_outputparams-preview.
  ELSE. " ELSE -> IF fp_us_screen IS INITIAL
    fp_outputparams-preview = abap_true.

*&&-- To enable the PRINT button in the toolbar of the form print preview
    fp_outputparams-noprint = space.

  ENDIF. " IF fp_us_screen IS INITIAL
  fp_outputparams-nodialog = abap_true.
  fp_outputparams-dest     = fp_nast-ldest.
  fp_outputparams-reqimm   = fp_nast-dimme.
  fp_outputparams-reqdel   = fp_nast-delet.
  fp_outputparams-copies   = fp_nast-anzal.
  fp_outputparams-dataset  = fp_nast-dsnam.
  fp_outputparams-suffix1  = fp_nast-dsuf1.
  fp_outputparams-suffix2  = fp_nast-dsuf2.
  fp_outputparams-covtitle = fp_nast-tdcovtitle.
  fp_outputparams-cover    = fp_nast-tdocover.
  fp_outputparams-receiver = fp_nast-tdreceiver.
  fp_outputparams-division = fp_nast-tddivision.
  fp_outputparams-reqfinal = abap_true.
  fp_outputparams-arcmode  = fp_nast-tdarmod.
  fp_outputparams-schedule = fp_nast-tdschedule.
  fp_outputparams-senddate = fp_nast-vsdat.
  fp_outputparams-sendtime = fp_nast-vsura.

ENDFORM. " FILL_CONTROL_STRUCTURE



*&---------------------------------------------------------------------*
*&      Form  F_XSTRING_TO_SOLIX
*&---------------------------------------------------------------------*
*       Convert String to Hexadecimal
*----------------------------------------------------------------------*
*      -->FP_LX_FORMOUT_PDF  Form String
*      -->FP_PDF_CONTENT     SAPoffice: Binary data
*----------------------------------------------------------------------*
FORM f_xstring_to_solix USING fp_lx_formout_pdf TYPE xstring
                              fp_pdf_content    TYPE solix_tab.

  DATA:
    lv_offset          TYPE int4, "Offset
*     lv_offset          TYPE int2,      "Offset
    li_solix           TYPE solix_tab, "SAPoffice: Binary data
    lx_solix_line      TYPE solix,     "SAPoffice: Binary data
    lv_pdf_string_len  TYPE int4,      "PDF String Length
*    lv_pdf_string_len  TYPE int2,      "PDF String Length
    lv_solix_rows      TYPE int4, "Binary data rows
    lv_last_row_length TYPE int4, "Binary data last row length
    lv_row_length      TYPE int4. "Binary data row length

  CLEAR fp_pdf_content.

*&--Transform xstring to SOLIX
  DESCRIBE TABLE li_solix.
  lv_row_length = sy-tleng.
  lv_offset = 0.

*&--Get PDF form string length
  lv_pdf_string_len = xstrlen( fp_lx_formout_pdf ).

  lv_solix_rows = lv_pdf_string_len DIV lv_row_length.
  lv_last_row_length = lv_pdf_string_len MOD lv_row_length.
  DO lv_solix_rows TIMES.
    lx_solix_line-line =
           fp_lx_formout_pdf+lv_offset(lv_row_length).
    APPEND lx_solix_line TO fp_pdf_content.
    lv_offset = lv_offset + lv_row_length.
  ENDDO.
  IF lv_last_row_length > 0.
    CLEAR lx_solix_line-line.
    lx_solix_line-line = fp_lx_formout_pdf+lv_offset(lv_last_row_length).
    APPEND lx_solix_line TO fp_pdf_content.
  ENDIF. " IF lv_last_row_length > 0

ENDFORM. " F_XSTRING_TO_SOLIX
*&---------------------------------------------------------------------*
*&      Form  F_GET_LABELS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_HEADER_VKORG  text
*      -->FP_LANGU    Language type
*      <--FP_BIO_RAD_CONF  text
*      <--FP_CONTACT_ID  text
*      <--FP_THANKS  text
*      <--FP_ORD_DATE  text
*      <--FP_TO  text
*      <--FP_EMAIL  text
*      <--FP_PHONE  text
*      <--FP_PO_NUM  text
*      <--FP_CARRIER  text
*      <--FP_FREIGHT  text
*      <--FP_ORD_CMT  text
*      <--FP_SOLD_TO  text
*      <--FP_SHIP_TO  text
*      <--FP_LINE_NUM  text
*      <--FP_MAT_NUM  text
*      <--FP_MAT_DESCR  text
*      <--FP_ORD_QTY  text
*      <--FP_CONF_QTY  text
*      <--FP_BACK_QTY  text
*      <--FP_SHIP_DATE  text
*      <--FP_SOLD_DATE  text
*      <--FP_UNIT_PRICE  text
*      <--FP_AMOUNT  text
*      <--FP_BATCH  text
*      <--FP_EXPIRY_DATE  text
*      <--FP_SUBTOTAL  text
*      <--FP_HAZARDOUS  text
*      <--FP_HANDLING  text
*      <--FP_TAX  text
*      <--FP_TOTAL  text
*      <--FP_FOOTER  text
*      <--FP_FOOTER_ENG text
*      <--FP_FOOTER_ENG text
*      <--FP_FREIGHT_FOOTER  text
*----------------------------------------------------------------------*
FORM f_get_labels  USING    fp_header_vkorg TYPE vkorg    " Sales Organization
                            fp_langu TYPE char3           " Langu of type CHAR3
                   CHANGING fp_bio_rad_conf TYPE char255  " Bio_rad_conf of type CHAR70
                            fp_contact_id TYPE char255    " Contact_id of type CHAR70
                            fp_thanks TYPE char255        " Thanks of type CHAR70
                            fp_ord_date TYPE char70       " Ord_date of type CHAR70
                            fp_to TYPE char70             " To of type CHAR70
                            fp_email TYPE char70          " Email of type CHAR70
                            fp_phone TYPE char70          " Phone of type CHAR70
                            fp_po_num TYPE char255        " Po_num of type CHAR70
                            fp_carrier TYPE char70        " Carrier of type CHAR70
                            fp_freight TYPE char70        " Freight of type CHAR70
                            fp_ord_cmt TYPE char255       " Ord_cmt of type CHAR70
                            fp_sold_to TYPE char70        " Sold_to of type CHAR70
                            fp_ship_to TYPE char70        " Ship_to of type CHAR70
                            fp_line_num TYPE char70       " Line_num of type CHAR70
                            fp_mat_num TYPE char70        " Mat_num of type CHAR70
                            fp_mat_descr TYPE char70      " Mat_descr of type CHAR70
                            fp_ord_qty TYPE char70        " Ord_qty of type CHAR70
                            fp_conf_qty TYPE char70       " Conf_qty of type CHAR70
                            fp_back_qty TYPE char70       " Back_qty of type CHAR70
                            fp_ship_date TYPE char70      " Ship_date of type CHAR70
                            fp_unit_price TYPE char70     " Unit_price of type CHAR70
                            fp_amount TYPE char70         " Amount of type CHAR70
                            fp_batch TYPE char70          " Batch of type CHAR70
                            fp_expiry_date TYPE char70    " Expiry_date of type CHAR70
                            fp_subtotal TYPE char70       " Subtotal of type CHAR70
                            fp_hazardous TYPE char70      " Hazardous of type CHAR70
                            fp_handling TYPE char70       " Handling of type CHAR70
                            fp_tax TYPE char70            " Tax of type CHAR70
                            fp_total TYPE char70          " Total of type CHAR70
                            fp_footer TYPE char30000      " Footer of type CHAR30000
                            fp_footer_eng TYPE char30000  " Footer_eng of type CHAR30000
                            fp_freight_footer TYPE char70 " Freight_footer of type CHAR70
                            fp_incoterm TYPE char70       " Incoterm of type CHAR70 D3 Defect 9886 by DMOIRAN
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                            fp_bill_to_lb     TYPE char70  "Text for Bill to
                            fp_insurance_lb   TYPE char70  "Text for insurance
                            fp_env_lb         TYPE char70  "Text for environment
                            fp_location_lb    TYPE char70 "Text for GLN
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                            fp_document_lb    TYPE char70.  "Text for Documentation
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

  DATA: li_lines  TYPE STANDARD TABLE OF tline,             " SAPscript: Text Lines
        li_status TYPE STANDARD TABLE OF  zdev_enh_status. " Internal table for Enhancement Status

  DATA: lv_langu1    TYPE sylangu,      " Language Key of Current Text Environment
        lv_langu2    TYPE sylangu,      " Language Key of Current Text Environment
        lv_variable1 TYPE char30000, " Variable1 of type CHAR30000
        lv_variable  TYPE char70.     " Variable of type CHAR70

  FIELD-SYMBOLS: <lfs_lines>  TYPE tline,            " SAPscript: Text Lines
                 <lfs_status> TYPE zdev_enh_status. " Enhancement Status
  " Space of type CHAR1
  CONSTANTS:
    lc_fdd_0012       TYPE z_enhancement VALUE 'D2_OTC_FDD_0012',           " Enhancement No.nt
    lc_id             TYPE char4 VALUE 'ST',                                      " Id of type CHAR4
    lc_object         TYPE char10 VALUE 'TEXT',                               " Object of type CHAR10
    lc_slash          TYPE char1 VALUE '/',                                    " Slash of type CHAR1
    lc_bio_rad_conf   TYPE char70 VALUE 'ZOTC_BIORAD_ORD_CONF',         " Bio_rad_conf of type CHAR70
    lc_contact_id     TYPE char70 VALUE 'ZOTC_CONTACT_ID',                " Contact_id of type CHAR70
    lc_thanks         TYPE char70 VALUE 'ZOTC_BIORAD_THANKS_NOTE',            " Thanks of type CHAR70
    lc_ord_date       TYPE char70 VALUE 'ZOTC_ORDER_DATE',                  " Ord_date of type CHAR70
    lc_to             TYPE char70 VALUE 'ZOTC_TO',                                " To of type CHAR70
    lc_email          TYPE char70 VALUE 'ZOTC_EMAIL',                          " Email of type CHAR70
    lc_phone          TYPE char70 VALUE 'ZOTC_BIO_RAD_PHONE',                  " Phone of type CHAR70
    lc_po_num         TYPE char70 VALUE 'ZOTC_BIORAD_PO_NUM',                 " Po_num of type CHAR70
    lc_carrier        TYPE char70 VALUE 'ZOTC_BIORAD_CARRIER',               " Carrier of type CHAR70
    lc_freight        TYPE char70 VALUE 'ZOTC_BIORAD_FREIGHT',               " Freight of type CHAR70
    lc_ord_cmt        TYPE char70 VALUE 'ZOTC_ORDER_COMMENTS',               " Ord_cmt of type CHAR70
    lc_sold_to        TYPE char70 VALUE 'ZOTC_0012_SOLD_TO',                 " Sold_to of type CHAR70
    lc_ship_to        TYPE char70 VALUE 'ZOTC_0012_SHIP_TO',                 " Ship_to of type CHAR70
    lc_line_num       TYPE char70 VALUE 'ZOTC_POSN',                        " Line_num of type CHAR70
    lc_mat_num        TYPE char70 VALUE 'ZOTC_MATERIAL',                     " Mat_num of type CHAR70
    lc_mat_descr      TYPE char70 VALUE 'ZOTC_DESCRIPTION',                " Mat_descr of type CHAR70
    lc_ord_qty        TYPE char70 VALUE 'ZOTC_ORD_QTY',                      " Ord_qty of type CHAR70
    lc_conf_qty       TYPE char70 VALUE 'ZOTC_BIORAD_CONF_QTY',             " Conf_qty of type CHAR70
    lc_back_qty       TYPE char70 VALUE 'ZOTC_BIORAD_BO_QTY',               " Back_qty of type CHAR70
    lc_ship_date      TYPE char70 VALUE 'ZOTC_PLANNED_SHIP_DATE',          " Ship_date of type CHAR70
    lc_unit_price     TYPE char70 VALUE 'ZOTC_UNIT_PRICE',                " Unit_price of type CHAR70
    lc_amount         TYPE char70 VALUE 'ZOTC_AMOUNT',                        " Amount of type CHAR70
    lc_batch          TYPE char70 VALUE 'ZOTC_BATCH_SERIAL_NUM',               " Batch of type CHAR70
    lc_expiry_date    TYPE char70 VALUE 'ZOTC_EXPIRY_DATE',              " Expiry_date of type CHAR70
    lc_subtotal       TYPE char70 VALUE 'ZOTC_BIORAD_SUBTOTAL',             " Subtotal of type CHAR70
    lc_hazardous      TYPE char70 VALUE 'ZOTC_BIORAD_HAZARDOUS',           " Hazardous of type CHAR70
    lc_handling       TYPE char70 VALUE 'ZOTC_BIORAD_HANDLING',             " Handling of type CHAR70
    lc_tax            TYPE char70 VALUE 'ZOTC_BIORAD_TAX',                       " Tax of type CHAR70
    lc_total          TYPE char70 VALUE 'ZOTC_TOTAL',                          " Total of type CHAR70
    lc_footer         TYPE char70 VALUE 'ZOTC_BIORAD_FOOTER',                 " Footer of type CHAR70
    lc_freight_footer TYPE char70 VALUE 'ZOTC_BIORAD_FREIGHT_FOOTER', " Freight_footer of type CHAR70
    lc_langu          TYPE z_criteria VALUE 'VKORG_LANGU',                     " Enh. Criteria
    lc_space          TYPE char1 VALUE ' ',                                    " Space of type CHAR1
    lc_incoterm       TYPE char70 VALUE 'ZOTC_INCOTERM_EU',                 " Carrier of type CHAR70
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

    lc_ins_lb         TYPE char70 VALUE 'ZOTC_0012_INSURANCE',   "Standard text for Insurance
    lc_location_lb    TYPE char70 VALUE 'ZOTC_0012_LOCATION',    "Standard text for Location
    lc_env_lb         TYPE char70 VALUE 'ZOTC_0012_ENVIRONMENT', "Standard text for environment
    lc_bill_lb        TYPE char70 VALUE 'ZOTC_0012_BILL_TO',     "Standard text for Bill to

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
    lc_document_lb    TYPE char70 VALUE 'ZOTC_0012_DOCUMENT'.    "Standard text for documentation
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

  CLEAR: lv_langu1,
         lv_langu2,
         lv_variable1,
         lv_variable.

*For language check
  IF fp_langu CS '_'.
    SPLIT fp_langu AT '_' INTO lv_langu1
                               lv_langu2.
  ELSE. " ELSE -> IF fp_langu CS '_'
    lv_langu1 = fp_langu.
    lv_langu2 = lc_space.
  ENDIF. " IF fp_langu CS '_'

* ---> Begin of Insert for D3 Defect 9886 by DMOIRAN
* As freight has been replaced by incoterm, get the label for D1/D2 also.

  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_incoterm
                          lc_object
                  CHANGING  fp_incoterm .
* <--- End    of Insert for D3 Defect 9886 by DMOIRAN


*Read text - Bio rad conf
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id           "ST
      language                = lv_langu1       "language
      name                    = lc_bio_rad_conf "Stndrd text
      object                  = lc_object       "object id
    TABLES
      lines                   = li_lines        "text lines
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
      MOVE <lfs_lines>-tdline TO fp_bio_rad_conf.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*contact id
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id         "ST
      language                = lv_langu1     "Lang
      name                    = lc_contact_id "Stndrd text
      object                  = lc_object     "object id
    TABLES
      lines                   = li_lines      "Text lines
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
* Begin of Defect 8857
     LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix EQ 1.
        MOVE <lfs_lines>-tdline TO fp_contact_id.
      ELSE. " ELSE -> IF sy-tabix EQ 1
        MOVE <lfs_lines>-tdline TO lv_variable1.
        CONCATENATE fp_contact_id lv_variable1 INTO fp_contact_id SEPARATED BY space.
      ENDIF. " IF sy-tabix EQ 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
* End of Defect 8857
*    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
*    IF sy-subrc EQ 0.
*      MOVE <lfs_lines>-tdline TO fp_contact_id.
*    ENDIF. " IF sy-subrc EQ 0
* End of Defect 8857
  ENDIF. " IF sy-subrc EQ 0
*thanks note
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "lang
      name                    = lc_thanks "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_thanks.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*order date
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id       "ST
      language                = lv_langu1   "langu
      name                    = lc_ord_date "Stndrd text
      object                  = lc_object   "object id
    TABLES
      lines                   = li_lines    "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_ord_date.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*To
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "langu
      name                    = lc_to     "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_to.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*email
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "language
      name                    = lc_email  "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_email.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*Phone
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "language
      name                    = lc_phone  "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_phone.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*PO Num

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "language
      name                    = lc_po_num "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_po_num.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Carrier
*Begin of delete for D3_OTC_FDD_0012 by U034336
*  CALL FUNCTION 'READ_TEXT'
*    EXPORTING
*      id                      = lc_id      "ST
*      language                = lv_langu1  "language
*      name                    = lc_carrier "Stndrd text
*      object                  = lc_object  "object id
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
*  IF sy-subrc EQ 0.
*    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
*    IF sy-subrc EQ 0.
*      MOVE <lfs_lines>-tdline TO fp_carrier.
*    ENDIF. " IF sy-subrc EQ 0
*  ENDIF. " IF sy-subrc EQ 0
*End of delete for D3_OTC_FDD_0012 by U034336

*Freight
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id      "ST
      language                = lv_langu1  "language
      name                    = lc_freight "Stndrd text
      object                  = lc_object  "object id
    TABLES
      lines                   = li_lines   "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_freight.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*ORD comment
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id      "ST
      language                = lv_langu1  "language
      name                    = lc_ord_cmt "Stndrd text
      object                  = lc_object  "object id
    TABLES
      lines                   = li_lines   "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_ord_cmt.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id      "ST
      language                = lv_langu1  "language
      name                    = lc_sold_to "Stndrd text
      object                  = lc_object  "object id
    TABLES
      lines                   = li_lines   "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_sold_to.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Ship to
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id      "ST
      language                = lv_langu1  "language
      name                    = lc_ship_to "Stndrd text
      object                  = lc_object  "object id
    TABLES
      lines                   = li_lines   "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_ship_to.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*line number
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id       "ST
      language                = lv_langu1   "language
      name                    = lc_line_num "Stndrd text
      object                  = lc_object   "object id
    TABLES
      lines                   = li_lines    "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_line_num.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*material number
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id      "ST
      language                = lv_langu1  "language
      name                    = lc_mat_num "Stndrd text
      object                  = lc_object  "object id
    TABLES
      lines                   = li_lines   "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_mat_num.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*Material Description
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id        "ST
      language                = lv_langu1    "language
      name                    = lc_mat_descr "Stndrd text
      object                  = lc_object    "object id
    TABLES
      lines                   = li_lines     "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_mat_descr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Order quantity
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id      "ST
      language                = lv_langu1  "language
      name                    = lc_ord_qty "Stndrd text
      object                  = lc_object  "object id
    TABLES
      lines                   = li_lines   "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_ord_qty.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*Confirmed qty

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id       "ST
      language                = lv_langu1   "language
      name                    = lc_conf_qty "Stndrd text
      object                  = lc_object   "object id
    TABLES
      lines                   = li_lines    "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_conf_qty.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*Back order qty
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id       "ST
      language                = lv_langu1   "language
      name                    = lc_back_qty "Stndrd text
      object                  = lc_object   "object id
    TABLES
      lines                   = li_lines    "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_back_qty.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Ship date

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_ship_date
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_ship_date.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Unit Price
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id         "ST
      language                = lv_langu1     "language
      name                    = lc_unit_price "Stndrd text
      object                  = lc_object     "object id
    TABLES
      lines                   = li_lines      "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_unit_price.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Extended price
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "language
      name                    = lc_amount "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_amount.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Batches
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id     "ST
      language                = lv_langu1 "language
      name                    = lc_batch  "Stndrd text
      object                  = lc_object "object id
    TABLES
      lines                   = li_lines  "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_batch.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*Expiry date
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id          "ST
      language                = lv_langu1      "language
      name                    = lc_expiry_date "Stndrd text
      object                  = lc_object      "object id
    TABLES
      lines                   = li_lines       "Text lines
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
      MOVE <lfs_lines>-tdline TO fp_expiry_date.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*subtotal
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_subtotal
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_subtotal.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Hazardous
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_hazardous
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_hazardous.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Handling
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_handling
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_handling.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Tax
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_tax
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_tax.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Total

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_total
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_total.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
*Footer
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_footer
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix EQ 1.
        MOVE <lfs_lines>-tdline TO fp_footer.
      ELSE. " ELSE -> IF sy-tabix EQ 1
        MOVE <lfs_lines>-tdline TO lv_variable1.
        CONCATENATE fp_footer lv_variable1 INTO fp_footer SEPARATED BY space.
      ENDIF. " IF sy-tabix EQ 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc EQ 0


*Frieght footer
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_freight_footer
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
      MOVE <lfs_lines>-tdline TO fp_freight_footer.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

  "Getting the labels for insurance, environment fee, bill to and GLN

  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_bill_lb
                          lc_object
              CHANGING    fp_bill_to_lb.

  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_location_lb
                           lc_object
               CHANGING    fp_location_lb.
  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_env_lb
                           lc_object
               CHANGING    fp_env_lb.
  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_ins_lb
                          lc_object
              CHANGING    fp_insurance_lb.

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
* Fetch the standard text for Documentation
  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_document_lb
                          lc_object
              CHANGING    fp_document_lb.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

*When sales order is corresponding to french canada need to print text in french and english language.
*bio rad conf deatil
  IF lv_langu2 IS NOT INITIAL.
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_bio_rad_conf
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_bio_rad_conf lv_variable INTO fp_bio_rad_conf SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
* ---> Begin of Insert for D2_OTC_FDD_0012,Defect #5597 by NSAXENA
    CONDENSE fp_bio_rad_conf.
* <--- End of Insert for D2_OTC_FDD_0012,Defect #5597 by NSAXENA

*contact id
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_contact_id
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_contact_id lv_variable INTO fp_contact_id SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*thanks note
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_thanks
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_thanks lv_variable INTO fp_thanks SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*order date
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_ord_date
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_ord_date lv_variable INTO fp_ord_date SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*To
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_to
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_to lv_variable INTO fp_to SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*email
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_email
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_email lv_variable INTO fp_email SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*Phone
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_phone
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_phone lv_variable INTO fp_phone SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*PO Num

    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_po_num
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_po_num lv_variable INTO fp_po_num SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Carrier
*Begin of delete for D3_OTC_FDD_0012 by U034336
*    CALL FUNCTION 'READ_TEXT'
*      EXPORTING
*        id                      = lc_id
*        language                = lv_langu2
*        name                    = lc_carrier
*        object                  = lc_object
*      TABLES
*        lines                   = li_lines
*      EXCEPTIONS
*        id                      = 1
*        language                = 2
*        name                    = 3
*        not_found               = 4
*        object                  = 5
*        reference_check         = 6
*        wrong_access_to_archive = 7
*        OTHERS                  = 8.
*    IF sy-subrc EQ 0.
*      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
*      IF sy-subrc EQ 0.
*        MOVE <lfs_lines>-tdline TO lv_variable.
*        CONCATENATE fp_carrier lv_variable INTO fp_carrier SEPARATED BY lc_slash.
*      ENDIF. " IF sy-subrc EQ 0
*    ENDIF. " IF sy-subrc EQ 0
*End of delete for D3_OTC_FDD_0012 by U034336
*Freight
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_freight
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_freight lv_variable INTO fp_freight SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*ORD comment
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_ord_cmt
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_ord_cmt lv_variable INTO fp_ord_cmt SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Sold to
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_sold_to
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_sold_to lv_variable INTO fp_sold_to SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Ship to
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_ship_to
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_ship_to lv_variable INTO fp_ship_to SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*line number
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_line_num
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_line_num lv_variable INTO fp_line_num SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*material number
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_mat_num
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_mat_num lv_variable INTO fp_mat_num SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0

*Material Description
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_mat_descr
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        IF fp_mat_descr IS NOT INITIAL.
          CONCATENATE fp_mat_descr lv_variable INTO fp_mat_descr SEPARATED BY lc_slash.
        ELSE. " ELSE -> IF fp_mat_descr IS NOT INITIAL
          fp_mat_descr = lv_variable.
        ENDIF. " IF fp_mat_descr IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Order quantity
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_ord_qty
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_ord_qty lv_variable INTO fp_ord_qty SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Confirmed qty
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_conf_qty
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_conf_qty lv_variable INTO fp_conf_qty SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Back order qty
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_back_qty
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_back_qty lv_variable INTO fp_back_qty SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Ship date
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_ship_date
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_ship_date lv_variable INTO fp_ship_date SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Unit Price
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_unit_price
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_unit_price lv_variable INTO fp_unit_price SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Extended price
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_amount
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_amount lv_variable INTO fp_amount SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Batches
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_batch
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_batch lv_variable INTO fp_batch SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Expiry date
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_expiry_date
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_expiry_date lv_variable INTO fp_expiry_date SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*subtotal
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_subtotal
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        IF fp_subtotal IS NOT INITIAL.
          CONCATENATE fp_subtotal lv_variable INTO fp_subtotal SEPARATED BY lc_slash.
        ELSE. " ELSE -> IF fp_subtotal IS NOT INITIAL
          fp_subtotal = lv_variable.
        ENDIF. " IF fp_subtotal IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Hazardous
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_hazardous
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_hazardous lv_variable INTO fp_hazardous SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Handling
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_handling
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_handling lv_variable INTO fp_handling SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Tax
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_tax
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_tax lv_variable INTO fp_tax SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Total
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_total
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        IF fp_total IS NOT INITIAL.
          CONCATENATE fp_total lv_variable INTO fp_total SEPARATED BY lc_slash.
        ELSE. " ELSE -> IF fp_total IS NOT INITIAL
          fp_total = lv_variable.
        ENDIF. " IF fp_total IS NOT INITIAL
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*Footer
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_footer
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
      LOOP AT li_lines ASSIGNING <lfs_lines>.
        IF sy-tabix EQ 1.
          CONCATENATE lc_slash <lfs_lines>-tdline INTO fp_footer_eng.
        ELSE. " ELSE -> IF sy-tabix EQ 1
          CONCATENATE fp_footer_eng <lfs_lines>-tdline INTO fp_footer_eng.
        ENDIF. " IF sy-tabix EQ 1
      ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
    ENDIF. " IF sy-subrc EQ 0
*Frieght footer
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        id                      = lc_id
        language                = lv_langu2
        name                    = lc_freight_footer
        object                  = lc_object
      TABLES
        lines                   = li_lines
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
        MOVE <lfs_lines>-tdline TO lv_variable.
        CONCATENATE fp_freight_footer lv_variable INTO fp_freight_footer SEPARATED BY lc_slash.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
    "Getting the labels for insurance, environment fee, bill to and GLN

    PERFORM f_get_texts USING lc_id
                            lv_langu2
                            lc_bill_lb
                            lc_object
                CHANGING    fp_bill_to_lb.

    PERFORM f_get_texts USING lc_id
                             lv_langu2
                             lc_location_lb
                             lc_object
                 CHANGING    fp_location_lb.
    PERFORM f_get_texts USING lc_id
                             lv_langu2
                             lc_env_lb
                             lc_object
                 CHANGING    fp_env_lb.
    PERFORM f_get_texts USING lc_id
                            lv_langu2
                            lc_ins_lb
                            lc_object
                CHANGING    fp_insurance_lb.

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

  ENDIF. " IF lv_langu2 IS NOT INITIAL

ENDFORM. " F_GET_LABELS
*Begin of insert for D3_OTC_FDD_0012 by U034336
*&---------------------------------------------------------------------*
*&      Form  f_convert_date_format
*&---------------------------------------------------------------------*
*       This FM will convert the date into required  langauge dependent
*       format
*
*----------------------------------------------------------------------*
*      -->fp_date          text
*      -->fp_header        text
*      <--FP_LV_DATE_CHAR  text
*----------------------------------------------------------------------*

FORM f_convert_date_format  USING   fp_status TYPE zdev_tt_enh_status
                                    fp_date   TYPE char15                      " Convert_date_format usi of type CHAR11
                                     fp_header TYPE zotc_cust_order_ack_header " Header data for Customer Order Acknowledgement form
                            CHANGING fp_lv_date_char TYPE char15.              " Lv_date_char of type CHAR11

  CONSTANTS: lc_date   TYPE z_criteria VALUE 'DATE'. " Format of type CHAR12
  DATA: lv_date   TYPE sydatum, " Current Date of Application Server
        lv_format TYPE char15.  " Format of type CHAR15

  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status. " Enhancement Status

* BInary search is not required as fp_status does not have much data
  READ TABLE fp_status ASSIGNING <lfs_status>
  WITH KEY   criteria = lc_date.
  IF sy-subrc EQ 0 .
    lv_format = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc EQ 0

  lv_date = fp_date.

  CALL FUNCTION 'ZDEV_DATE_FORMAT'
    EXPORTING
      i_date       = lv_date
      i_format     = lv_format
      i_langu      = fp_header-sold_to_lang
    IMPORTING
      e_date_final = fp_lv_date_char.

ENDFORM. " F_CONVERT_DATE_FORMAT


*&---------------------------------------------------------------------*
*&      Form  F_GET_LABELS_EU
*&---------------------------------------------------------------------*
*       This form will retutrn all the standard texts
*       translated into required language
*----------------------------------------------------------------------*
*      -->P_LX_HEADER_VKORG  text
*      -->P_LV_LANGU  text
*      <--P_LV_BIO_RAD_CONF  text
*      <--P_LV_CONTACT_ID  text
*      <--P_LV_THANKS  text
*      <--P_LV_ORD_DATE  text
*      <--P_LV_TO  text
*      <--P_LV_EMAIL  text
*      <--P_LV_PHONE  text
*      <--P_LV_PO_NUM  text
*      <--P_LV_CARRIER  text
*      <--P_LV_FREIGHT_HEADING  text
*      <--P_LV_ORD_CMT  text
*      <--P_LV_SOLD_TO  text
*      <--P_LV_SHIP_TO  text
*      <--P_LV_LINE_NUM  text
*      <--P_LV_MAT_NUM  text
*      <--P_LV_MAT_DESCR  text
*      <--P_LV_ORD_QTY  text
*      <--P_LV_CONF_QTY  text
*      <--P_LV_BACK_QTY  text
*      <--P_LV_SHIP_DATE  text
*      <--P_LV_UNIT_PRICE  text
*      <--P_LV_AMOUNT  text
*      <--P_LV_BATCH  text
*      <--P_LV_EXPIRY_DATE  text
*      <--P_LV_SUBTOTAL  text
*      <--P_LV_HAZARDOUS  text
*      <--P_LV_HANDLING  text
*      <--P_LV_TAX_HEADING  text
*      <--P_LV_TOTAL  text
*      <--P_LV_FOOTER  text
*      <--P_LV_FOOTER_ENG  text
*      <--P_LV_FREIGHT_FOOTER  text
*----------------------------------------------------------------------*
FORM f_get_labels_eu  USING fp_langu       TYPE char3                      " Langu of type CHAR3
                            fp_sh_to_land  TYPE land1                      " Country Key
                   CHANGING fp_bio_rad_conf TYPE char255                   " Bio_rad_conf of type CHAR70
                            fp_contact_id TYPE char255                     " Contact_id of type CHAR70
                            fp_thanks TYPE char255                         " Thanks of type CHAR70
                            fp_ord_date TYPE char70                        " Ord_date of type CHAR70
                            fp_to TYPE char70                              " To of type CHAR70
                            fp_email TYPE char70                           " Email of type CHAR70
                            fp_phone TYPE char70                           " Phone of type CHAR70
                            fp_po_num TYPE char255                         " Po_num of type CHAR70
                            fp_carrier TYPE char70                         " Carrier of type CHAR70
                            fp_incoterm TYPE char70                        " Incoterm of type CHAR70
                            fp_ord_cmt TYPE char255                        " Ord_cmt of type CHAR70
                            fp_sold_to TYPE char70                         " Sold_to of type CHAR70
                            fp_ship_to TYPE char70                         " Ship_to of type CHAR70
                            fp_line_num TYPE char70                        " Line_num of type CHAR70
                            fp_mat_num TYPE char70                         " Mat_num of type CHAR70
                            fp_mat_descr TYPE char70                       " Mat_descr of type CHAR70
                            fp_ord_qty TYPE char70                         " Ord_qty of type CHAR70
                            fp_conf_qty TYPE char70                        " Conf_qty of type CHAR70
                            fp_ship_date TYPE char70                       " Ship_date of type CHAR70
                            fp_unit_price TYPE char70                      " Unit_price of type CHAR70
                            fp_amount TYPE char70                          " Amount of type CHAR70
                            fp_batch TYPE char70                           " Batch of type CHAR70
                            fp_expiry_date TYPE char70                     " Expiry_date of type CHAR70
                            fp_subtotal TYPE char70                        " Subtotal of type CHAR70
                            fp_hazardous TYPE char70                       " Hazardous of type CHAR70
                            fp_handling TYPE char70                        " Handling of type CHAR70
                            fp_tax TYPE char70                             " Tax of type CHAR70
                            fp_total TYPE char70                           " Total of type CHAR70
                            fp_footer TYPE char30000                       " Footer of type CHAR30000
                            fp_footer_eng TYPE char30000                   " Footer_eng of type CHAR30000
                            fp_freight_footer TYPE char70                  " Freight_footer of type CHAR70
                            fp_header_data TYPE zotc_cust_order_ack_header " Header data for Customer Order Acknowledgement form
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
                            fp_bill_to_lb     TYPE char70  "Text for Bill to
                            fp_insurance_lb   TYPE char70  "Text for insurance
                            fp_env_lb         TYPE char70  "Text for environment
                            fp_location_lb    TYPE char70 "Text for GLN
*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
                            fp_document_lb    TYPE char70.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

  DATA: li_lines  TYPE STANDARD TABLE OF tline,             " SAPscript: Text Lines
        li_status TYPE STANDARD TABLE OF  zdev_enh_status. " Internal table for Enhancement Status

  DATA: lv_langu1    TYPE sylangu,      " Language Key of Current Text Environment
        lv_variable1 TYPE char30000. " Variable1 of type CHAR30000

  FIELD-SYMBOLS: <lfs_lines> TYPE tline. " SAPscript: Text Lines
  " Space of type CHAR1
  CONSTANTS:
    lc_eu_dest_country TYPE land1 VALUE 'EU',                           " Country Key
    lc_fdd_0012        TYPE z_enhancement VALUE 'D2_OTC_FDD_0012',      " Enhancement No.nt
    lc_id              TYPE tdid VALUE 'ST',                                          " Id of type CHAR4
    lc_object          TYPE tdobject VALUE 'TEXT',                                " Object of type CHAR10
    lc_slash           TYPE char1 VALUE '/',                                       " Slash of type CHAR1
    lc_bio_rad_conf    TYPE char70 VALUE 'ZOTC_BIORAD_ORD_CONF_EU',         " Bio_rad_conf of type CHAR70
    lc_contact_id      TYPE char70 VALUE 'ZOTC_CONTACT_ID_EU',                " Contact_id of type CHAR70
    lc_thanks          TYPE char70 VALUE 'ZOTC_BIORAD_THANKS_NOTE_EU',            " Thanks of type CHAR70
    lc_ord_date        TYPE char70 VALUE 'ZOTC_ORDER_DATE_EU',                  " Ord_date of type CHAR70
    lc_to              TYPE char70 VALUE 'ZOTC_TO_EU',                                " To of type CHAR70
    lc_email           TYPE char70 VALUE 'ZOTC_EMAIL_EU',                          " Email of type CHAR70
    lc_phone           TYPE char70 VALUE 'ZOTC_BIO_RAD_PHONE_EU',                  " Phone of type CHAR70
    lc_po_num          TYPE char70 VALUE 'ZOTC_BIORAD_PO_NUM_EU',                 " Po_num of type CHAR70
    lc_incoterm        TYPE char70 VALUE 'ZOTC_INCOTERM_EU',                    " Carrier of type CHAR70
    lc_ord_cmt         TYPE char70 VALUE 'ZOTC_ORDER_COMMENTS_EU',               " Ord_cmt of type CHAR70
    lc_sold_to         TYPE char70 VALUE 'ZOTC_0012_SOLD_TO_EU',                 " Sold_to of type CHAR70
    lc_ship_to         TYPE char70 VALUE 'ZOTC_0012_SHIP_TO_EU',                 " Ship_to of type CHAR70
    lc_line_num        TYPE char70 VALUE 'ZOTC_POSN_EU',                        " Line_num of type CHAR70
    lc_mat_num         TYPE char70 VALUE 'ZOTC_MATERIAL_EU',                     " Mat_num of type CHAR70
    lc_mat_descr       TYPE char70 VALUE 'ZOTC_DESCRIPTION_EU',                " Mat_descr of type CHAR70
    lc_ord_qty         TYPE char70 VALUE 'ZOTC_ORD_QTY_EU',                      " Ord_qty of type CHAR70
    lc_conf_qty        TYPE char70 VALUE 'ZOTC_BIORAD_CONF_QTY_EU',             " Conf_qty of type CHAR70
    lc_back_qty        TYPE char70 VALUE 'ZOTC_BIORAD_BO_QTY_EU',               " Back_qty of type CHAR70
    lc_ship_date       TYPE char70 VALUE 'ZOTC_PLANNED_SHIP_DATE_EU',          " Ship_date of type CHAR70
    lc_unit_price      TYPE char70 VALUE 'ZOTC_UNIT_PRICE_EU',                " Unit_price of type CHAR70
    lc_amount          TYPE char70 VALUE 'ZOTC_AMOUNT_EU',                        " Amount of type CHAR70
    lc_batch           TYPE char70 VALUE 'ZOTC_BATCH_SERIAL_NUM_EU',               " Batch of type CHAR70
    lc_expiry_date     TYPE char70 VALUE 'ZOTC_EXPIRY_DATE_EU',              " Expiry_date of type CHAR70
    lc_subtotal        TYPE char70 VALUE 'ZOTC_BIORAD_SUBTOTAL_EU',             " Subtotal of type CHAR70
    lc_hazardous       TYPE char70 VALUE 'ZOTC_BIORAD_HAZARDOUS_EU',           " Hazardous of type CHAR70
    lc_handling        TYPE char70 VALUE 'ZOTC_BIORAD_HANDLING_EU',             " Handling of type CHAR70
    lc_tax             TYPE char70 VALUE 'ZOTC_BIORAD_TAX_EU',                       " Tax of type CHAR70
    lc_total           TYPE char70 VALUE 'ZOTC_TOTAL_EU',                          " Total of type CHAR70
    lc_footer          TYPE char70 VALUE 'ZOTC_BIORAD_FOOTER_EU',                 " Footer of type CHAR70
    lc_freight_footer  TYPE char70 VALUE 'ZOTC_BIORAD_FREIGHT_FOOTER_EU', " Freight_footer of type CHAR70
    lc_langu           TYPE z_criteria VALUE 'VKORG_LANGU',                        " Enh. Criteria
    lc_space           TYPE char1 VALUE ' ',                                       " Space of type CHAR1
    lc_temp_text       TYPE char70 VALUE 'ZOTC_BIORAD_CUST_INF',               " Temp_text of type CHAR70
    lc_underscore      TYPE char1 VALUE '_',                                  " Underscore of type CHAR1
*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
    lc_ins_lb          TYPE char70 VALUE 'ZOTC_0012_INSURANCE',   "Standard text for Insurance
    lc_location_lb     TYPE char70 VALUE 'ZOTC_0012_LOCATION',    "Standard text for Location
    lc_env_lb          TYPE char70 VALUE 'ZOTC_0012_ENVIRONMENT', "Standard text for environment
    lc_bill_to_lb      TYPE char70 VALUE 'ZOTC_0012_BILL_TO',     "Standard text for Bill to

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
    lc_document_lb     TYPE char70 VALUE 'ZOTC_0012_DOCUMENT'.    "Standard text for Documentation
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
  CLEAR: lv_langu1,
         lv_variable1.

  lv_langu1 = fp_langu.

  IF fp_sh_to_land IS NOT INITIAL.
    CONCATENATE lc_temp_text fp_header_data-vkorg fp_sh_to_land
     INTO fp_header_data-std_text SEPARATED BY lc_underscore.
  ELSE. " ELSE -> IF fp_sh_to_land IS NOT INITIAL
    CONCATENATE lc_temp_text fp_header_data-vkorg lc_eu_dest_country
    INTO fp_header_data-std_text_eur SEPARATED BY lc_underscore.
  ENDIF. " IF fp_sh_to_land IS NOT INITIAL

  PERFORM f_get_long_texts USING lc_id
                            lv_langu1
                            lc_bio_rad_conf
                            lc_object
                     CHANGING  fp_bio_rad_conf.

  PERFORM f_get_long_texts USING lc_id
                            lv_langu1
                            lc_contact_id
                            lc_object
                    CHANGING fp_contact_id.

*Begin of delete for D3_OTC_FDD_0012 Defect#6168 by U034336
*  PERFORM f_get_long_texts USING lc_id
*                            lv_langu1
*                            lc_thanks
*                            lc_object
*                    CHANGING  fp_thanks.
*End of delete for D3_OTC_FDD_0012 Defect#6168 by U034336

  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_ord_date
                           lc_object
                   CHANGING fp_ord_date.


  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_to
                          lc_object
                  CHANGING fp_to.


  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_email
                          lc_object
                  CHANGING  fp_email.



  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_phone
                          lc_object
                  CHANGING  fp_phone.

  PERFORM f_get_long_texts USING lc_id
                          lv_langu1
                          lc_po_num
                          lc_object
                  CHANGING  fp_po_num.



  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_incoterm
                          lc_object
                  CHANGING  fp_incoterm .


  PERFORM f_get_long_texts USING lc_id
                          lv_langu1
                          lc_ord_cmt
                          lc_object
                  CHANGING  fp_ord_cmt.


  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_sold_to
                          lc_object
                  CHANGING  fp_sold_to.



  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_ship_to
                          lc_object
                  CHANGING  fp_ship_to.


  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_line_num
                          lc_object
                  CHANGING  fp_line_num.

  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_mat_num
                           lc_object
                   CHANGING  fp_mat_num.


  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_mat_descr
                           lc_object
                   CHANGING  fp_mat_descr.



  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_ord_qty
                          lc_object
                  CHANGING  fp_ord_qty.


  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_conf_qty
                          lc_object
                  CHANGING  fp_conf_qty.


  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_ship_date
                          lc_object
                  CHANGING   fp_ship_date.



  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_unit_price
                          lc_object
                  CHANGING    fp_unit_price.

  PERFORM f_get_texts USING lc_id
                         lv_langu1
                         lc_amount
                         lc_object
                 CHANGING     fp_amount.


  PERFORM f_get_texts USING lc_id
                         lv_langu1
                         lc_batch
                         lc_object
                 CHANGING     fp_batch.

  PERFORM f_get_texts USING lc_id
                         lv_langu1
                         lc_expiry_date
                         lc_object
                 CHANGING     fp_expiry_date.


  PERFORM f_get_texts USING lc_id
                         lv_langu1
                         lc_subtotal
                         lc_object
                 CHANGING     fp_subtotal.

  PERFORM f_get_texts USING lc_id
                     lv_langu1
                     lc_hazardous
                     lc_object
             CHANGING     fp_hazardous.

  PERFORM f_get_texts USING lc_id
                     lv_langu1
                     lc_handling
                     lc_object
             CHANGING      fp_handling.


  PERFORM f_get_texts USING lc_id
             lv_langu1
             lc_tax
             lc_object
     CHANGING      fp_tax.

  PERFORM f_get_texts USING lc_id
                     lv_langu1
                     lc_total
                     lc_object
             CHANGING      fp_total.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = lc_id
      language                = lv_langu1
      name                    = lc_footer
      object                  = lc_object
    TABLES
      lines                   = li_lines
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
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix EQ 1.
        MOVE <lfs_lines>-tdline TO fp_footer.
      ELSE. " ELSE -> IF sy-tabix EQ 1
        MOVE <lfs_lines>-tdline TO lv_variable1.
        CONCATENATE fp_footer lv_variable1 INTO fp_footer SEPARATED BY space.
      ENDIF. " IF sy-tabix EQ 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
  ENDIF. " IF sy-subrc EQ 0

  PERFORM f_get_texts USING lc_id
                     lv_langu1
                     lc_freight_footer
                     lc_object
             CHANGING  fp_freight_footer.

*&--> Begin of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017
  "Getting the labels for insurance, environment fee, bill to and GLN

  PERFORM f_get_long_texts USING lc_id
                                 lv_langu1
                                 lc_thanks
                                 lc_object
                    CHANGING     fp_thanks.

  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_bill_to_lb
                          lc_object
              CHANGING    fp_bill_to_lb.

  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_location_lb
                           lc_object
               CHANGING    fp_location_lb.
  PERFORM f_get_texts USING lc_id
                           lv_langu1
                           lc_env_lb
                           lc_object
               CHANGING    fp_env_lb.
  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_ins_lb
                          lc_object
              CHANGING    fp_insurance_lb.

*&<-- End of insert D3_R2 for D3_OTC_FDD_0012 by AMOHAPA on 10-Oct-2017

*&--> Begin of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018
* Fetch the standard text for Documentation
  PERFORM f_get_texts USING lc_id
                          lv_langu1
                          lc_document_lb
                          lc_object
              CHANGING    fp_document_lb.
*&<-- End of insert D3_R3 for D3_OTC_FDD_0012 by U029267 on 29-Jan-2018

ENDFORM. " F_GET_LABELS_EU

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_ID  text
*      -->P_LV_LANGU1  text
*      -->P_LC_BIO_RAD_CONF  text
*      -->P_LC_OBJECT  text
*      <--P_FP_BIO_RAD_CONF  text
*----------------------------------------------------------------------*
FORM f_get_texts  USING    fp_id          TYPE tdid     " Text ID
                           fp_langu1      TYPE  spras   " Language Key
                           fp_tdname      TYPE char70   " TDIC text name
                           fp_object      TYPE tdobject " Texts: Application Object
                  CHANGING fp_tdline      TYPE char70.  " Fp_bio_rad_conf of type CHAR70

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

ENDFORM. " F_GET_TEXTS
*&---------------------------------------------------------------------*
*&      Form  F_GET_LONG_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_ID  text
*      -->P_LV_LANGU1  text
*      -->P_LC_ORD_CMT  text
*      -->P_LC_OBJECT  text
*      <--P_FP_ORD_CMT  text
*----------------------------------------------------------------------*
FORM f_get_long_texts  USING     fp_id          TYPE tdid     " Text ID
                                 fp_langu1      TYPE  spras   " Language Key
                                 fp_tdname      TYPE char70   " TDIC text name
                                 fp_object      TYPE tdobject " Texts: Application Object
                       CHANGING  fp_tdline      TYPE char255. " Fp_bio_rad_conf of type CHAR70

  DATA : li_lines     TYPE STANDARD TABLE OF tline, " SAPscript: Text Lines
*Begin of insert for D3_OTC_FDD_0012 Defect#6168 by U034336
         lv_variable1 TYPE char255. " Variable1 of type CHAR30000
*End of insert for D3_OTC_FDD_0012 Defect#6168 by U034336

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
*Begin of delete for D3_OTC_FDD_0012 Defect#6168 by U034336
*    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
*    IF sy-subrc EQ 0.
*      MOVE <lfs_lines>-tdline TO fp_tdline.
*    ENDIF. " IF sy-subrc EQ 0
*End of delete for D3_OTC_FDD_0012 Defect#6168 by U034336
*Begin of insert for D3_OTC_FDD_0012 Defect#6168 by U034336
    LOOP AT li_lines ASSIGNING <lfs_lines>.
      IF sy-tabix EQ 1.
        MOVE <lfs_lines>-tdline TO fp_tdline.
      ELSE. " ELSE -> IF sy-tabix EQ 1
        MOVE <lfs_lines>-tdline TO lv_variable1.
        CONCATENATE fp_tdline lv_variable1 INTO fp_tdline SEPARATED BY space.
      ENDIF. " IF sy-tabix EQ 1
    ENDLOOP. " LOOP AT li_lines ASSIGNING <lfs_lines>
*End of insert for D3_OTC_FDD_0012 Defect#6168 by U034336

  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " F_GET_LONG_TEXTS
*End of insert for D3_OTC_FDD_0012 by U034336
