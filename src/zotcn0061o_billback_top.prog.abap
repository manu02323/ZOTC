*&---------------------------------------------------------------------*
*&  Include           ZOTCN0061O_BILLBACK_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0061O_BILLBACK_TOP                                *
* TITLE      :  OTC_CDD_0061_Convert 1 year history data for billback  *
*               and commission.
* DEVELOPER  :  Deepa Sharma                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0061_SAP                                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Data Declaration include for billback and commission   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-MAY-2012 DSHARMA1 E1DK901626  INITIAL DEVELOPMENT                 *
* 16-Oct-2012 SPURI    E1DK906961  Defect 492 :Skip Header Record from
*                                  Input File                          *
*                                  Defect 628 :Do not Check Customer   *
*                                  Material Number From MARA
* 02-Nov-2012 SPURI    E1DK906961  Defect 1353: In case no product
*                                  hierarchy is passed from input file
*                                  read it from table MARA for a given
*                                  material
*&---------------------------------------------------------------------*
* Types Declarations
*       Final Report Display Structure
  TYPES: BEGIN OF ty_report,
          msgtyp TYPE char1,          "Message Type E / S
          msgtxt TYPE string,         "Message Text
          key    TYPE string,         "Key of message
         END OF ty_report,

*       Input Table structure,
         BEGIN OF ty_input,
           vbeln            TYPE vbeln_vf,      "Billing doc
           posnr            TYPE posnr_vf,      "Billing Item
           matnr            TYPE matnr,         "Material
           vkorg            TYPE vkorg,         "SO
           vtweg            TYPE vtweg,         "DC
           kunag            TYPE kunag,         "Sold to party
           kunnr            TYPE kunnr,         "End Customer
           bstkd            TYPE bstkd,         "PO Number
           fkart            TYPE fkart,         "Billing Type
           zzleg_inv_typ    TYPE z_leg_inv_typ, "Legacy Invoice type
           zzleg_so         TYPE z_leg_so,      "Legacy SO
           fkdat            TYPE fkdat,         "Billing Date
           expnr            TYPE edi_expnr,     "Customer code
           bstdk            TYPE bstdk,         "PO Date
           prodh            TYPE prodh_d,       "Product Family
           zzcus_mat_no     TYPE z_cus_mat_no,  "Customer Material Number
           fkimg            TYPE fkimg,         "Actual Invoiced Quantity
           zzgln_code       TYPE z_gln_code,    "GLN Code
           kdgrp            TYPE kdgrp,         "Customer Group
           kvgr1            TYPE kvgr1,         "Group1
           kvgr2            TYPE kvgr2,         "Group2
           netwr            TYPE netwr,         "Net value in Doc curr
           zzcont_price     TYPE z_cont_price,  "Contract price
           zzset_qty        TYPE z_set_qty,     "Setteled Quantity
           zzbal_qty        TYPE z_bal_qty,     "Balanced Quanity
           zzref_inv_no     TYPE z_ref_inv_no,  "Ref Invoice Number
           zzref_inv_date   TYPE z_ref_inv_date,"Ref Invoice date
           auart            TYPE auart,         "Sales Date
           zzset_amnt       TYPE z_set_amnt,    "Setled Amount
           zzold_new_ind    TYPE z_old_new_ind, "Old/New Sales Indicator
           zzlot_number     TYPE z_lot_number,  "Lot Number
           zzpo_date        TYPE z_po_date,     "PO Date
           zzprod_family_cd TYPE z_prod_family_cd, "Product Family code
         END OF ty_input,
*        Error Table struecture
         BEGIN OF ty_input_e,
           vbeln            TYPE vbeln_vf,      "Billing doc
           posnr            TYPE posnr_vf,      "Billing Item
           matnr            TYPE matnr,         "Material
           vkorg            TYPE vkorg,         "SO
           vtweg            TYPE vtweg,         "DC
           kunag            TYPE kunag,         "Sold to party
           kunnr            TYPE kunnr,         "End Customer
           bstkd            TYPE bstkd,         "PO Number
           fkart            TYPE fkart,         "Billing Type
           zzleg_inv_typ    TYPE z_leg_inv_typ, "Legacy Invoice type
           zzleg_so         TYPE z_leg_so,      "Legacy SO
           fkdat            TYPE fkdat,         "Billing Date
           expnr            TYPE edi_expnr,     "Customer code
           bstdk            TYPE bstdk,         "PO Date
           prodh            TYPE prodh_d,       "Product Family
           zzcus_mat_no     TYPE z_cus_mat_no,  "Customer Material Number
           fkimg            TYPE fkimg,         "Actual Invoiced Quantity
           zzgln_code       TYPE z_gln_code,    "GLN Code
           kdgrp            TYPE kdgrp,         "Customer Group
           kvgr1            TYPE kvgr1,         "Group1
           kvgr2            TYPE kvgr2,         "Group2
           netwr            TYPE netwr,         "Net value in Doc curr
           zzcont_price     TYPE z_cont_price,  "Contract price
           zzset_qty        TYPE z_set_qty,     "Setteled Quantity
           zzbal_qty        TYPE z_bal_qty,     "Balanced Quanity
           zzref_inv_no     TYPE z_ref_inv_no,  "Ref Invoice Number
           zzref_inv_date   TYPE z_ref_inv_date,"Ref Invoice date
           auart            TYPE auart,         "Sales Date
           zzset_amnt       TYPE z_set_amnt,    "Setled Amount
           zzold_new_ind    TYPE z_old_new_ind, "Old/New Sales Indicator
           zzlot_number     TYPE z_lot_number,  "Lot Number
           zzpo_date        TYPE z_po_date,     "PO Date
           zzprod_family_cd TYPE z_prod_family_cd, "Product Family code
           message          TYPE string,        "Error Message
         END OF ty_input_e,

*       MARA Structure for Validation of Material Number
         BEGIN OF ty_mara,
           matnr TYPE matnr,           "Material
*START DEFECT 1353
           prdha type PRODH_D, " ++Defect 1353 product Family
*END   DEFECT 1353
         END OF ty_mara,

*       TVKO Structure for validation of sales organization
         BEGIN OF ty_tvko,
           vkorg TYPE vkorg,           "Sales Organization
         END OF ty_tvko,

*       TVTW Structure for Validation of Ditribution Channel
         BEGIN OF ty_tvtw,
           vtweg TYPE vtweg,           "Distribution Channel
         END OF ty_tvtw,

*       KNA1 Structure for Validation of Sold to Party and Customer Number
         BEGIN OF ty_kna1,
           kunnr TYPE kunnr,           "Customer Number
         END OF ty_kna1,

*       T151 Structure for Validation of Customer Group
         BEGIN OF ty_t151,
           kdgrp TYPE kdgrp,           "Customer Group
         END OF ty_t151,

*       TVV1 Structure for Validation of Customer Group1
         BEGIN OF ty_tvv1,
           kvgr1 TYPE kvgr1,           "Customer Group 1
         END OF ty_tvv1,

*       TVV2 Structure For Validation of Customer Group 2
         BEGIN OF ty_tvv2,
           kvgr2 TYPE kvgr2,           "Customer Group 2
         END OF ty_tvv2,

*       EDPAR Structure to validate distributor customer code
         BEGIN OF ty_edpar,
           kunnr TYPE kunnr,           "Customer
           expnr TYPE edi_expnr,       "Distributor customer code
         END OF ty_edpar.

* Constants
  CONSTANTS: c_tab          TYPE char1   VALUE
                              cl_abap_char_utilities=>horizontal_tab,
*            New Line Feed
             c_crlf         TYPE char1      VALUE
                               cl_abap_char_utilities=>cr_lf,
             c_text         TYPE char3      VALUE 'TXT',     "Extension .TXT
             c_shipto       TYPE parvw      VALUE 'WE',      "Ship to party
             c_slash        TYPE char1      VALUE '/',       "Slash
             c_error        TYPE char1      VALUE 'E',       "Error Indicator
             c_emode        TYPE enqmode    VALUE 'E',       "Enque Mode
             c_success      TYPE char1      VALUE 'S',       "Success Indicator
             c_lp_ind       TYPE char1      VALUE 'X',       "X = Logical File Path
             c_tobeprscd    TYPE char3      VALUE 'TBP',     "TBP Folder
             c_done_fold    TYPE char4      VALUE 'DONE',    "Done Folder
             c_err_fold     TYPE char5      VALUE 'ERROR',   "Error folder
             c_filetype     TYPE char10     VALUE 'ASC'.     "File type

* Table Type Declaration
  TYPES: ty_t_input    TYPE STANDARD TABLE OF ty_input,      "Input Tab
         ty_t_input_e  TYPE STANDARD TABLE OF ty_input_e,    "Error table
         ty_t_report   TYPE STANDARD TABLE OF ty_report,     "Report
         ty_t_mara     TYPE STANDARD TABLE OF ty_mara,       "To vaidate MARA
         ty_t_tvko     TYPE STANDARD TABLE OF ty_tvko,       "To validate Sales organization
         ty_t_tvtw     TYPE STANDARD TABLE OF ty_tvtw,       "to validate Distribution Channel
         ty_t_kna1     TYPE STANDARD TABLE OF ty_kna1,       "TO validate sold to and customer
         ty_t_t151     TYPE STANDARD TABLE OF ty_t151,       "Validate Customer group
         ty_t_tvv1     TYPE STANDARD TABLE OF ty_tvv1,       "To validate Buying Group
         ty_t_tvv2     TYPE STANDARD TABLE OF ty_tvv2,       "to validate GLN code
         ty_t_edpar    TYPE STANDARD TABLE OF ty_edpar.      "For Distributor Customer code

* Internal Table Declaration.
  DATA: i_input     TYPE ty_t_input,    "Input table
        i_input_e   TYPE ty_t_input_e,  "Error Table
        i_report    TYPE ty_t_report,   "Report Table
        i_mara      TYPE ty_t_mara,     "Mara table
        i_tvko      TYPE ty_t_tvko,     "TVKO table
        i_tvtw      TYPE ty_t_tvtw,     "TVTW table
        i_kna1      TYPE ty_t_kna1,     "KNA1 Table
        i_t151      TYPE ty_t_t151,     "T151 table
        i_tvv1      TYPE ty_t_tvv1,     "TVV1 table
        i_tvv2      TYPE ty_t_tvv2,     "TVV2 Table
        i_edpar     TYPE ty_t_edpar.    "EDPAR Table

* Variable Declaration.
  DATA:
        gv_file     TYPE localfile,    "File name
        gv_mode     TYPE char10,       "Mode of transaction
        gv_succ     TYPE int4,         "Success counter
        gv_error    TYPE int4,         "Error Count
        gv_err_flg  TYPE char1,        "Error Flag
        gv_total2           TYPE int4,  "Total Record
        gv_no_success2      TYPE int4,  "Succes
        gv_no_failed2       TYPE int4.  "Failed
