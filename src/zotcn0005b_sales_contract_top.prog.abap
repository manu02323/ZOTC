*&---------------------------------------------------------------------*
*&  Include     ZOTCN0005B_SALES_CONTRACT_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0005B_SALES_CONTRACT_TOP                          *
* TITLE      :  Convert Open Reagent Rental and Service Contracts      *
* DEVELOPER  :  Manikandan Pounraj                                     *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0005_Convert Open Reagent Rental                 *
*             and Service Contracts                                    *
*----------------------------------------------------------------------*
* DESCRIPTION: Updating sales contract                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT      DESCRIPTION                     *
* =========== ======== ========== =====================================*
* 03-JULY-2012 MPOUNRA  E1DK901606 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 07-Oct-2014  SMEKALA  E2DK905508 D2:Service Contracts will no longer *
*                                  be used and the scope of conversions*
*                 would only be limited to Reagent Rental Contracts.   *
*&---------------------------------------------------------------------*
* Type Declarations.
*Input file Convert Open Reagent Rental and Service Contracts
TYPES: BEGIN OF ty_contract,
vbeln       TYPE vbeln_va,   " Sales Document
doc_type    TYPE auart,      " Sales Document Type
sales_org   TYPE vkorg,      " Sales Organization
distr_chan  TYPE vtweg,      " Distribution Channel
division    TYPE spart,      " Division
collect_no  TYPE submi,      " Collective Number "D2
purch_date  TYPE bstdk,      " Customer purchase order date
po_method   TYPE bsark,      " Customer purchase order type
name        TYPE bname_v,    " Name of orderer
telephone   TYPE telf1_vp,   " Telephone Number
purch_no_c  TYPE bstkd,      " Customer purchase order number
doc_date    TYPE audat,      " Document Date (Date Received/Sent)
pmnttrms    TYPE dzterm,     " Terms of Payment Key
itm_number  TYPE posnr_va,   " Sales Document Item
material    TYPE matnr,      " Material
target_qty  TYPE dzmeng,     " Target quantity in sales units
target_qu   TYPE dzieme,     " Target quantity UoM
item_categ  TYPE pstyv,      " Sales document item category
partn_role1 TYPE parvw,      " Partner Function
partn_numb1 TYPE kunnr,      " Customer Number 1
partn_role2 TYPE parvw,      " Partner Function
partn_numb2 TYPE kunnr,      " Customer Number 1
inst_date   TYPE vidat_veda, " Installation date
accept_dat  TYPE vadat_veda, " Agreement acceptance date
con_st_dat  TYPE vbdat_veda, " Contract start date
con_en_dat  TYPE vndat_veda, " Contract end date
sernr       TYPE gernr,      " Serial Number
equnr       TYPE equnr,      " Equipment Number
  END OF ty_contract,

* For Denoting Error Records
BEGIN OF ty_contract_e,
vbeln       TYPE vbeln_va,   " Sales Document
doc_type    TYPE auart,      " Sales Document Type
sales_org   TYPE vkorg,      " Sales Organization
distr_chan  TYPE vtweg,      " Distribution Channel
division    TYPE spart,      " Division
collect_no  TYPE submi,      " Collective Number "D2
purch_date  TYPE bstdk,      " Customer purchase order date
po_method   TYPE bsark,      " Customer purchase order type
name        TYPE bname_v,    " Name of orderer
telephone   TYPE telf1_vp,   " Telephone Number
purch_no_c  TYPE bstkd,      " Customer purchase order number
doc_date    TYPE audat,      " Document Date (Date Received/Sent)
pmnttrms    TYPE dzterm,     " Terms of Payment Key
itm_number  TYPE posnr_va,   " Sales Document Item
material    TYPE matnr,      " Material
target_qty  TYPE dzmeng,     " Target quantity in sales units
target_qu   TYPE dzieme,     " Target quantity UoM
item_categ  TYPE pstyv,      " Sales document item category
partn_role1 TYPE parvw,      " Partner Function
partn_numb1 TYPE kunnr,      " Customer Number 1
partn_role2 TYPE parvw,      " Partner Function
partn_numb2 TYPE kunnr,      " Customer Number 1
inst_date   TYPE vidat_veda, " Installation date
accept_dat  TYPE vadat_veda, " Agreement acceptance date
con_st_dat  TYPE vbdat_veda, " Contract start date
con_en_dat  TYPE vndat_veda, " Contract end date
sernr       TYPE gernr,      " Serial Number
equnr       TYPE equnr,      " Equipment Number
error_msg   TYPE char300,    " Error Meassage
  END OF ty_contract_e,

*-- Begin of change D2
* Updating using the Call transaction
BEGIN OF ty_contr_tsn,
*vbeln       TYPE vbeln_va,   " Sales Document
*doc_type    TYPE auart,      " Sales Document Type
*sales_org   TYPE vkorg,      " Sales Organization
*distr_chan  TYPE vtweg,      " Distribution Channel
*division    TYPE spart,      " Division
*collect_no  TYPE submi,      " Collective Number "D2
*purch_date  TYPE bstdk,      " Customer purchase order date
*po_method   TYPE bsark,      " Customer purchase order type
*name        TYPE bname_v,    " Name of orderer
*telephone   TYPE telf1_vp,   " Telephone Number
*purch_no_c  TYPE bstkd,      " Customer purchase order number
*doc_date    TYPE audat,      " Document Date (Date Received/Sent)
*pmnttrms    TYPE dzterm,     " Terms of Payment Key
*itm_number  TYPE posnr_va,   " Sales Document Item
*material    TYPE matnr,      " Material
*target_qty  TYPE dzmeng,     " Target quantity in sales units
*target_qu   TYPE dzieme,     " Target quantity UoM
*item_categ  TYPE pstyv,      " Sales document item category
*partn_role1 TYPE parvw,      " Partner Function
*partn_numb1 TYPE kunnr,      " Customer Number 1
*partn_role2 TYPE parvw,      " Partner Function
*partn_numb2 TYPE kunnr,      " Customer Number 1
*inst_date   TYPE vidat_veda, " Installation date
*accept_dat  TYPE vadat_veda, " Agreement acceptance date
*con_st_dat  TYPE vbdat_veda, " Contract start date
*con_en_dat  TYPE vndat_veda, " Contract end date
*sernr       TYPE gernr,      " Serial Number
*equnr       TYPE equnr,      " Equipment Number
*-- Header data
 vbeln       TYPE vbeln_va,   " Sales Document
 doc_type    TYPE auart,      " Sales Document Type
 sales_org   TYPE vkorg,      " Sales Organization
 distr_chan  TYPE vtweg,      " Distribution Channel
 division    TYPE spart,      " Division
 partn_role1 TYPE parvw,      " Partner Function
 partn_numb1 TYPE kunnr,      " Customer Number 1
 partn_role2 TYPE parvw,      " Partner Function
 partn_numb2 TYPE kunnr,      " Customer Number 1
 con_st_dat  TYPE vbdat_veda, " Contract start date
 con_en_dat  TYPE vndat_veda, " Contract end date
 inst_date   TYPE vidat_veda, " Installation date
 accept_dat  TYPE vadat_veda, " Agreement acceptance date
 collect_no  TYPE submi,      " Collective Number "D2
 purch_date  TYPE bstdk,      " Customer purchase order date
 po_method   TYPE bsark,      " Customer purchase order type
 name        TYPE bname_v,    " Name of orderer
 telephone   TYPE telf1_vp,   " Telephone Number
 purch_no_c  TYPE bstkd,      " Customer purchase order number
 doc_date    TYPE audat,      " Document Date (Date Received/Sent)
 pmnttrms    TYPE dzterm,     " Terms of Payment Key
*-- Item data
 itm_number  TYPE posnr_va, " Sales Document Item
 material    TYPE matnr,    " Material
 target_qty  TYPE dzmeng,   " Target quantity in sales units
 target_qu   TYPE dzieme,   " Target quantity UoM
 item_categ  TYPE pstyv,    " Sales document item category
*-- Serial & Equipment Number
 sernr       TYPE gernr,   " Serial Number
 equnr       TYPE equnr,   " Equipment Number
vbeln1      TYPE vbeln_va, " Sales Document
msgtxt      TYPE char300,  " Error message
  END OF ty_contr_tsn,
*-- End of Change D2

*-- Begin of D2
BEGIN OF ty_chgcon,
*-- Header data
 vbeln       TYPE vbeln_va,   " Sales Document
 doc_type    TYPE auart,      " Sales Document Type
 sales_org   TYPE vkorg,      " Sales Organization
 distr_chan  TYPE vtweg,      " Distribution Channel
 division    TYPE spart,      " Division
 partn_role1 TYPE parvw,      " Partner Function
 partn_numb1 TYPE kunnr,      " Customer Number 1
 partn_role2 TYPE parvw,      " Partner Function
 partn_numb2 TYPE kunnr,      " Customer Number 1
 con_st_dat  TYPE vbdat_veda, " Contract start date
 con_en_dat  TYPE vndat_veda, " Contract end date
 inst_date   TYPE vidat_veda, " Installation date
 accept_dat  TYPE vadat_veda, " Agreement acceptance date
 collect_no  TYPE submi,      " Collective Number "D2
 purch_date  TYPE bstdk,      " Customer purchase order date
 po_method   TYPE bsark,      " Customer purchase order type
 name        TYPE bname_v,    " Name of orderer
 telephone   TYPE telf1_vp,   " Telephone Number
 purch_no_c  TYPE bstkd,      " Customer purchase order number
 doc_date    TYPE audat,      " Document Date (Date Received/Sent)
 pmnttrms    TYPE dzterm,     " Terms of Payment Key
*-- Item data
 itm_number  TYPE posnr_va, " Sales Document Item
 material    TYPE matnr,    " Material
 target_qty  TYPE dzmeng,   " Target quantity in sales units
 target_qu   TYPE dzieme,   " Target quantity UoM
 item_categ  TYPE pstyv,    " Sales document item category
*-- Serial & Equipment Number
 sernr       TYPE gernr, " Serial Number
 equnr       TYPE equnr, " Equipment Number
END OF ty_chgcon,
*-- End of D2
* Check Table VBAK & Field VBELN
BEGIN OF ty_vbak,
  vbeln TYPE vbeln_va, " Sales Document
END OF ty_vbak,

* Check Table TVAK & Field AUART
BEGIN OF ty_tvak,
  auart  TYPE auart, " Sales Document Type
END OF ty_tvak,

* Check Table TVKO & Field VKORG
BEGIN OF ty_tvko,
  vkorg TYPE vkorg, " Sales Organization
END OF ty_tvko,

* Check Table TVTW & Field VTWEG
BEGIN OF ty_tvtw,
  vtweg TYPE vtweg, " Distribution Channel
END OF ty_tvtw,

* Check Table TSPA & Field SPART
BEGIN OF ty_tspa,
  spart TYPE spart, " Division
END OF ty_tspa,

* Check Table TVTA & Field SPART
BEGIN OF ty_tvta,
  vkorg TYPE vkorg, " Sales Organization
  vtweg TYPE vtweg, " Distribution Channel
  spart TYPE spart, " Division
END OF ty_tvta,

* Check Table T176 & Field BSARK
BEGIN OF ty_t176,
  bsark TYPE bsark, " Customer purchase order type
END OF ty_t176,

* Check Table MARA & field MATNR
BEGIN OF ty_mara,
  matnr TYPE matnr, " Material Number
END OF ty_mara,

* Check Table T006 & field MSEHI
BEGIN OF ty_t006,
  msehi TYPE msehi, " Unit of Measurement
END OF ty_t006,

* Check Table TVPT & field PSTYV
BEGIN OF ty_tvpt,
  pstyv TYPE pstyv, " Sales document item category
  pstyo TYPE pstyo, " Object for which you define the item category
END OF ty_tvpt,

* Check Table TPAR & field PARVW
BEGIN OF ty_tpar,
  parvw TYPE parvw, " Partner Function
END OF ty_tpar,

* Check Table KNA1 & field KUNNR
BEGIN OF ty_kna1,
  kunnr TYPE kunnr, " Customer Number
END OF ty_kna1,

* Check Table T052 & field KUNNR
BEGIN OF ty_t052,
  zterm TYPE dzterm,     " Terms of Payment Key
  ztagg TYPE dztagg_052, " Day Limit
END OF ty_t052,

*-- Begin of addition D2
* Validation of duplicate contracts
BEGIN OF ty_dupchk,
  matnr TYPE matnr,    " Material Number
  soldto TYPE kunag,   " Sold-to party
  shipto TYPE kunnr,   " Customer Number
  auart  TYPE auart,   " Sales Document Type
END OF ty_dupchk,

BEGIN OF ty_vapma,
  matnr TYPE matnr,    " Material Number
  vkorg TYPE vkorg,    " Sales Organization
  trvog TYPE trvog,    " Transaction group
  audat TYPE audat,    " Document Date (Date Received/Sent)
  vtweg TYPE vtweg,    " Distribution Channel
  spart TYPE spart,    " Division
  auart TYPE auart,    " Sales Document Type
  soldto TYPE kunag,   " Sold-to party
  vkbur TYPE vkbur,    " Sales Office
  vkgrp TYPE vkgrp,    " Sales Group
  bstnk TYPE bstnk,    " Customer purchase order number
  ernam TYPE ernam,    " Name of Person who Created the Object
  vbeln TYPE vbeln,    " Sales and Distribution Document Number
  posnr TYPE posnr,    " Item number of the SD document
  datab TYPE datab_vi, " Quotation or contract valid from
  datbi TYPE datbi_vi, " Quotation or contract valid to
  shipto TYPE kunnr,   " Customer Number
END OF ty_vapma,

BEGIN OF ty_shipto,
  vbeln TYPE vbeln,    " Sales and Distribution Document Number
  posnr TYPE posnr,    " Item number of the SD document
  parvw TYPE parvw,    " Partner Function
  shipto TYPE kunnr,   " Customer Number
END OF ty_shipto,
*-- End of addition D2
*Final Report Display Structure
BEGIN OF ty_report,
  ref_doc   TYPE vbeln, " Sales Document in input
*-- Begin of addition D2
  doc_type    TYPE auart,      " Sales Document Type
  sales_org   TYPE vkorg,      " Sales Organization
  distr_chan  TYPE vtweg,      " Distribution Channel
  division    TYPE spart,      " Division
  partn_role1 TYPE parvw,      " Partner Function
  partn_numb1 TYPE kunnr,      " Customer Number 1
  partn_role2 TYPE parvw,      " Partner Function
  partn_numb2 TYPE kunnr,      " Customer Number 1
  con_st_dat  TYPE vbdat_veda, " Contract start date
  con_en_dat  TYPE vndat_veda, " Contract end date
  material    TYPE matnr,      " Material
*-- End of addition D2
  doc_flg   TYPE char1,  " Flg of type CHAR1
                         " Flag to identify whether Sales Document created or not
  sales_doc TYPE vbeln,  " Sales Document created by SAP
  equi_flg  TYPE char1,  " Flg of type CHAR1
                         " Flag to identify whether Equipment and Serial Number
                         " created or not
  msgtxt   TYPE char300, " To provide Error/success message
END OF ty_report,
*-- Begin of D2
BEGIN OF ty_val,
  vkorg  TYPE vkorg,        " Sales Organization
  vtweg  TYPE vtweg,        " Distribution Channel
  value1 TYPE z_mvalue_low, " Select Options: Value Low
END OF ty_val,
*-- End of D2
* Table Type Declaration
ty_t_contract  TYPE STANDARD TABLE OF ty_contract   INITIAL SIZE 0,
" For Input data
ty_t_vbak      TYPE STANDARD TABLE OF ty_vbak       INITIAL SIZE 0,
" table Contract Data
ty_t_tvak      TYPE STANDARD TABLE OF ty_tvak       INITIAL SIZE 0,
" Table Sales Document Types
ty_t_tvko      TYPE STANDARD TABLE OF ty_tvko       INITIAL SIZE 0,
" Table Organizational Unit: Sales Organizations
ty_t_tvtw      TYPE STANDARD TABLE OF ty_tvtw       INITIAL SIZE 0,
" Table Organizational Unit: Distribution Channels
ty_t_tspa      TYPE STANDARD TABLE OF ty_tspa       INITIAL SIZE 0,
" Organizational Unit: Sales Divisions
ty_t_tvta      TYPE STANDARD TABLE OF ty_tvta       INITIAL SIZE 0,
" Table Organizational Unit: Sales Area(s)
ty_t_t176      TYPE STANDARD TABLE OF ty_t176       INITIAL SIZE 0,
" Table Sales Documents: Customer Order Types
ty_t_mara      TYPE STANDARD TABLE OF ty_mara       INITIAL SIZE 0,
" Table General Material Data
ty_t_t006      TYPE STANDARD TABLE OF ty_t006       INITIAL SIZE 0,
" Table Units of Measurement
ty_t_tvpt      TYPE STANDARD TABLE OF ty_tvpt       INITIAL SIZE 0,
" Table Sales documents: Item categories
ty_t_tpar      TYPE STANDARD TABLE OF ty_tpar       INITIAL SIZE 0,
" Table Business Partner: Functions
ty_t_kna1      TYPE STANDARD TABLE OF ty_kna1       INITIAL SIZE 0,
" Table General Data in Customer Master
ty_t_t052      TYPE STANDARD TABLE OF ty_t052       INITIAL SIZE 0,
" Table Terms of Payment
ty_t_error     TYPE STANDARD TABLE OF ty_contract_e INITIAL SIZE 0,
" For hoding error data
ty_t_final     TYPE STANDARD TABLE OF ty_contract   INITIAL SIZE 0,
" For holding valid record
ty_t_bdcdata   TYPE STANDARD TABLE OF  bdcdata      INITIAL SIZE 0, " Batch input: New table field structure
" bdc
ty_t_bdcmsg    TYPE STANDARD TABLE OF  bdcmsgcoll   INITIAL SIZE 0, " Collecting messages in the SAP System
"bdc message
ty_t_contr_tsn TYPE STANDARD TABLE OF ty_contr_tsn  INITIAL SIZE 0,
" Table type - fields to be updated using Call Transaction
ty_t_report    TYPE STANDARD TABLE OF ty_report     INITIAL SIZE 0,
" Report
ty_t_chgcon    TYPE STANDARD TABLE OF ty_chgcon  INITIAL SIZE 0,   "D2
ty_t_val       TYPE STANDARD TABLE OF ty_val     INITIAL SIZE 0.   "D2 D2

* Constants
CONSTANTS:
c_tab        TYPE char1   VALUE cl_abap_char_utilities=>horizontal_tab, " Tab of type CHAR1
" TAB value
c_crlf       TYPE char1   VALUE cl_abap_char_utilities=>cr_lf,          " Crlf of type CHAR1
" Carriage Return and Line Feed  Character Pair
c_name       TYPE char30  VALUE 'ZOTC_CDD_0005_NUMBER_RANGE',           " Name of type CHAR30
" ABAP: Name of Variant Variable
c_rbselected TYPE char1   VALUE 'X',                                    " Rbselected of type CHAR1
" constant declaration of type char1 with value 'X'
c_ind1       TYPE char1   VALUE 'X',                                    " constant declaration
c_pipe       TYPE char1   VALUE  '|',                                   "constant declaration
c_ext        TYPE string  VALUE 'TXT',                                  " constant for extension
c_tbp_fld    TYPE char5   VALUE 'TBP',                                  " Tbp_fld of type CHAR5
                                                                        " constant declaration for TBP folder
c_error_fld  TYPE char5   VALUE 'ERROR',                                " ERROR folder
c_done_fld   TYPE char5   VALUE 'DONE',                                 " DONE folder
c_error      TYPE char1   VALUE 'E',                                    " Success Indicator
c_success    TYPE char1   VALUE 'S',                                    " Error Indicator
c_filetype   TYPE char10  VALUE 'ASC',                                  " File Type
c_yes        TYPE char1   VALUE 'Y',                                    " Yes of type CHAR1
" To identify whether its created successfully
c_no         TYPE char1   VALUE 'N',                                    " No of type CHAR1
" To identify if it is not created successfully
c_id         TYPE char2   VALUE 'V1',                                   " Id of type CHAR2
" Constant to extract the message
c_extnl      TYPE char1   VALUE 'E',                                    " Extnl of type CHAR1
" Constant "E" to denote External
c_intnl      TYPE char1   VALUE 'I',                                    " Intnl of type CHAR1
" Constant "I" to denote Internal  "D2
c_update     TYPE char1   VALUE 'A',                                    " Transaction update
c_tcode      TYPE sytcode VALUE 'VA42',                                 " T-code to upload
c_numb       TYPE symsgno VALUE '311',                                  " Number to get the success
" message while using the function module
c_vbtyp      TYPE vbtyp   VALUE 'G',                                    " SD document category
c_slash      TYPE char1   VALUE '/'.                                    " For slash

CLASS cl_abap_char_utilities DEFINITION LOAD. " Class for Characters

* Internal Table Declaration.
DATA:
i_contract TYPE ty_t_contract,                     "For Input data
i_error    TYPE ty_t_error,                        "For holding error record
i_final    TYPE ty_t_final,                        "For holding error record
i_vbak     TYPE ty_t_vbak,                         "Contract Data
i_tvak     TYPE ty_t_tvak,                         "Sales Document Types
i_tvko     TYPE ty_t_tvko,                         "Organizational Unit Sales Organizations
i_tvtw     TYPE ty_t_tvtw,                         "Organizational Unit Distribution Channel
i_tspa     TYPE ty_t_tspa,                         "Organizational Unit: Sales Divisions
i_tvta     TYPE ty_t_tvta,                         "Organizational Unit: Sales Area
i_t176     TYPE ty_t_t176,                         "Sales Documents: Customer Order Types
i_mara     TYPE ty_t_mara,                         "General Material Data
i_t006     TYPE ty_t_t006,                         "Units of Measurement
i_tvpt     TYPE ty_t_tvpt,                         "Sales documents: Item categories
i_tpar     TYPE ty_t_tpar,                         "Business Partner: Functions
i_kna1     TYPE ty_t_kna1,                         "General Data in Customer Master
i_t052     TYPE ty_t_t052,                         " Terms of Payment
i_report   TYPE ty_t_report,                       "Report Internal Table
i_bdcdata  TYPE ty_t_bdcdata,                      "For bdc data
i_tsn      TYPE ty_t_contr_tsn,
" fields to be updated using Call Transaction
i_bdcmsg   TYPE ty_t_bdcmsg,                       "For bdc message
i_val      TYPE ty_t_val, " D2 D2
i_chgcon   TYPE ty_t_chgcon,                       " D2 D2

* Global Work area / structure declaration.
wa_report  TYPE ty_report, " work area for report

* Variable Declaration.
gv_mode      TYPE char10,          " Mode of transaction
gv_contract  TYPE localfile,       " Input Data
gv_scount    TYPE int2,            " Succes Count
gv_ecount    TYPE int2,            " Error Count
gv_val       TYPE tvarv_val,       " To identify the state of updation
gv_mode_bdc  TYPE char1 VALUE 'N'. " Transaction Mode
