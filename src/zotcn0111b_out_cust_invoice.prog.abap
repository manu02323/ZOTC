************************************************************************
* INCLUDE    :  ZOTCN0111B_OUT_CUST_INVOICE                            *
* TITLE      :  D2_OTC_IDD_0111                                        *
* DEVELOPER  :  Vivek Gaur                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0111                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Outbound Customer Invoices EDI 810                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 31-JAN-2015  VGAUR     E2DK908545  INITIAL DEVELOPMENT               *
* 26-MAR-2015  VGAUR     E2DK908545  HPQC Defect# 5297                 *
*                                    In segment Z1RTR_E1EDK01_EXT      *
*                                    AMOUNT_IN_WORDS, the words needs  *
*                                    to be spelled out for total amount*
*                                    E1EDS01 Qual = 011 field SUMME    *
* 28-MAR-2015  VGAUR     E2DK908545  HPQC Defect# 5338                 *
*                                    Date and Time stamp logic Should  *
*                                    be UTC -7 hrs. -2 mins            *
* 28-MAR-2015  VGAUR     E2DK908545  HPQC Defect# 5261                 *
*                                    Serial number segment is missing  *
*                                    from the IDOC                     *
* 28-MAR-2015  VGAUR     E2DK908545  HPQC Defect# 5306                 *
*                                    Calculation of Z1RTR_E1EDK01_EXT- *
*                                    BETRG from Pedimento Quantity     *
* 31-MAR-2015  VGAUR     E2DK908545  HPQC Defect# 5442                 *
*                                    When generated idoc for an Invoice*
*                                    the flat file to trailix is not   *
*                                    generated in the AL11 directory   *
* 02-APR-2015  VGAUR     E2DK908545  HPQC Defect# 5702                 *
*                                    Segment E1EDK02 is missing in the *
*                                    IDOC for all debits and credits   *
*                                    created with reference to Invoice *
* 15-APR-2015  VGAUR     E2DK908545  HPQC Defect# 5981                 *
*                                    The Exchange rate in the PI file  *
*                                    is incorrect                      *
* 17-APR-2015  VGAUR     E2DK908545  HPQC Defect# 6062                 *
*                                    KRATE is missing in the PI file   *
* 24-APR-2015  VGAUR     E2DK908545  CR D2_636: Maintain emi entries   *
*                                    for text elements                 *
* 11-MAY-2015  MBAGDA    E2DK908545  HPQC Defect# 6430                 *
*                                    Fix Seq Number in segment         *
*                                    Z1RTR_E1EDP01_EXT-POSEX           *
* 15-JUL-2015  SAGARWA1  E2DK914025  HPQC Defect #8526                 *
*                                    Segment E1EDK04 populated for     *
*                                    Credit Invoice.                   *
* 16-NOV-2015  MGARG     E2DK916033  Defect#540 #468 (Inc INC0255171)  *
*                                    Need to fix custom fields BELNR & *
*                                    AMOUNT_IN_WORDS in segment        *
*                                    Z1RTR_E1EDK01_EXT                 *
* 30-AUG-2017  MTHATHA   E1DK930290  Pass data to new custom fields for*
*                                    SCTASK0515243                     *
* 26-DEC-2017  U034229   E1DK933375  Defect# 4470: (SCTASK0625482)     *
*                                    1. The regular ZF2 invoice should *
*                                    be set to Transfer when issued for*
*                                    a ZNC No Charge order.            *
*                                    2. Eliminating leading 0 of       *
*                                    referenced document number        *
************************************************************************

*----------------------------------------------------------------------*
*                             T Y P E S                                *
*----------------------------------------------------------------------*
TYPES:
  BEGIN OF lty_bseg,                                 " Accounting Document Segment
    koart         TYPE koart,                        " Account Type
    shkzg         TYPE shkzg,                        " Debit/Credit Indicator
    zfbdt         TYPE dzfbdt,                       " Baseline Date for Due Date Calculation
    zbd1t         TYPE dzbd1t,                       " Cash Discount Days 1
    zbd2t         TYPE dzbd2t,                       " Cash Discount Days 2
    zbd3t         TYPE dzbd3t,                       " Net Payment Terms Period
   END OF lty_bseg,

   BEGIN OF lty_sernum,                              " Serial Numbers
    sernum        TYPE gernr,                        " Serial Numbers
   END OF lty_sernum,

   lty_t_sernum   TYPE STANDARD TABLE OF lty_sernum. " Serial Numbers

*----------------------------------------------------------------------*
*                         C O N S T A N T S                            *
*----------------------------------------------------------------------*
CONSTANTS:
*&--Output Type
  lc_output_ty    TYPE z_criteria     VALUE 'OUTPUT_TYPE_MX',         "
*&--Amount
  lc_kursf_1      TYPE char6          VALUE '1.0000',                 "
*&--Pedimento Number
  lc_pedi_0001    TYPE z_ped_sequence VALUE '0001',                   "
*&--Quantity
  lc_quan_1       TYPE char4          VALUE '1.00',                   "
*&--Initial Item Number
  lc_posnr_init   TYPE posnr          VALUE '000000',                 "
*&--Zeros
  lc_zero_0000    TYPE char4          VALUE '0000',                   "
*&--Zero
  lc_zero_0       TYPE char1          VALUE '0',                      "
*&--Symbol: Colon
  lc_colon        TYPE char1          VALUE ':',                      "
*&--Customer Line
  lc_koart_d      TYPE koart          VALUE 'D',                      "
*&--Time Difference for Mexico
  lc_time_diff    TYPE z_criteria     VALUE 'TIME_DIFFER_MX',         "
*&--Billing Type
  lc_bill_type    TYPE z_criteria     VALUE 'BILLING_TYPE',           "
*--Begin of changes for SCTASK0515243 by mthatha
*&--voucher Type
  lc_voucher_type TYPE z_criteria     VALUE 'VOUCHER_TYPE',        "
*--Unit key
  lc_menee        TYPE z_criteria     VALUE 'UNIT_KEY', " Enh. Criteria
*--USE CFDI
  lc_use_cfdi     TYPE z_criteria     VALUE 'USE_CFDI', " Enh. Criteria
*--End of changes for SCTASK0515243 by mthatha
*&--Invoice Document Type
  lc_inv_doctype  TYPE z_criteria     VALUE 'INV_DOCTYPE',            "
*&--Pedimento Inbound
  lc_pedi_in      TYPE z_criteria     VALUE 'BILL_TYPE_PEDI_I',       "
*&--Credit Note
  lc_pedi_out     TYPE z_criteria     VALUE 'BILL_TYPE_PEDI_O',       "
*&--Language
  lc_langu        TYPE z_criteria     VALUE 'LANGUAGE',               "
*&--Currency Text
  lc_curr_text    TYPE z_criteria     VALUE 'CURR_TEXT',              "
*&--Enhancement Number
  lc_idd_0111     TYPE z_enhancement  VALUE 'D2_OTC_IDD_0111_001',    "
*&--Document Category: N
  lc_vbtyp_m      TYPE vbtyp_n        VALUE 'M',                      "
*&--Condition: ZNET
  lc_kschl_znet   TYPE kschl          VALUE 'ZNET',                   "
*&--Value: Hundred
  lc_hundred      TYPE char3          VALUE '100',                    "
*&--Legacy Invoices
  lc_leg_invoice  TYPE z_criteria     VALUE 'FKART_LEGACY',           "
*&--Invoice Type
  lc_invoice_sd   TYPE z_invoice_type VALUE 'SD',                     "
*&--IDOC qualifier: 002
  lc_orgid_m      TYPE edi_qualfr     VALUE 'M',                      "
*&--IDOC qualifier: 002
  lc_orgid_o      TYPE edi_qualfr     VALUE 'O',                      "
*&--IDOC qualifier: 002
  lc_orgid_n      TYPE edi_qualfr     VALUE 'N',                      "
*&--IDOC qualifier: 002
  lc_orgid_s      TYPE edi_qualfr     VALUE 'S',                      "
*&--IDOC qualifier: 001
  lc_qualf_001    TYPE edi_qualfr     VALUE '001',                    "
*&--IDOC qualifier: 002
  lc_qualf_02     TYPE edi_qualfr     VALUE '002',                    "
*&--IDOC qualifier: 010
  lc_qualf_010    TYPE edi_qualfr     VALUE '010',                    "
*&--IDOC qualifier: 011
  lc_qualf_011    TYPE edi_qualfr     VALUE '011',                    "
*&--IDOC qualifier: 014
  lc_qualf_014    TYPE edi_qualfr     VALUE '014',                    "
*&--IDOC qualifier: 016
  lc_qualf_016    TYPE edi_qualfr     VALUE '016',                    "
*&--IDOC qualifier: 017
  lc_qualf_017    TYPE edi_qualfr     VALUE '017',                    "
*&--IDOC qualifier: 021
  lc_qualf_021    TYPE edi_qualfr     VALUE '021',                    "
*&--IDOC qualifier: Z01
  lc_qualf_z01    TYPE edi_qualfr     VALUE 'Z01',                    "
*&--Partner: Sold-to party
  lc_parvw_ag     TYPE edi_qualfr     VALUE 'AG',                     "
*&--Partner: Ship-to party
  lc_parvw_we     TYPE edi_qualfr     VALUE 'WE',                     "
*&--Partner: Ship-to party
  lc_parvw_rg     TYPE edi_qualfr     VALUE 'RG',                     "
*Begin of R2
*&--
  lc_parvw_rs     TYPE edi_qualfr     VALUE 'RS',                     "
*End of R2
*&--Partner: Bill-to party
  lc_parvw_re     TYPE edi_qualfr     VALUE 'RE',                     "
*&--Text ID: Z011
  lc_tdid_z011    TYPE edi4451_a      VALUE 'Z011',                   "
*&--IDoc: Document header general data
  lc_e1edk01      TYPE edilsegtyp     VALUE 'E1EDK01',                "
*&--IDoc: Document header reference data
  lc_e1edk02      TYPE edilsegtyp     VALUE 'E1EDK02',                "
*&--IDoc: Document header date segment
  lc_e1edk03      TYPE edilsegtyp     VALUE 'E1EDK03',                "
*&--IDoc: Document header Org. data segment
  lc_e1edk14      TYPE edilsegtyp     VALUE 'E1EDK14',                "
*&--IDoc: Document Header Partner Information
  lc_e1edka1      TYPE edilsegtyp     VALUE 'E1EDKA1',                "
*&--IDoc: Document Item General Data
  lc_e1edp01      TYPE edilsegtyp     VALUE 'E1EDP01',                "
*&--IDoc: Document Item General Data
  lc_e1edp02      TYPE edilsegtyp     VALUE 'E1EDP02',                "
*&--IDoc: Document Item Date Segment
  lc_e1edp03      TYPE edilsegtyp     VALUE 'E1EDP03',                "
*&--IDoc: Document Item Object Identification
  lc_e1edp19      TYPE edilsegtyp     VALUE 'E1EDP19',                "
*&--IDoc: Summary segment general
  lc_e1eds01      TYPE edilsegtyp     VALUE 'E1EDS01',                "
*&--IDOC: Item Text
  lc_e1edpt1      TYPE edilsegtyp     VALUE 'E1EDPT1',                "
*&--IDOC: Item Text
  lc_e1edpt2      TYPE edilsegtyp     VALUE 'E1EDPT2',                "
*&--IDoc: Document header general data custom fields
  lc_e1edk01_ext  TYPE edilsegtyp     VALUE 'Z1RTR_E1EDK01_EXT',      "
*&--IDoc: Document Header Partner Information custom fields
  lc_e1edka1_ext  TYPE edilsegtyp     VALUE 'Z1RTR_E1EDKA1_EXT',      "
*&--IDoc: Document Item General Data Custom fields
  lc_e1edp01_ext  TYPE edilsegtyp     VALUE 'Z1RTR_E1EDP01_EXT',      "
*&--IDoc: Document Item Text
  lc_e1edpt2_ext  TYPE edilsegtyp     VALUE 'Z1RTR_E1EDPT2_EXT',      "
*--> Begin of CR D2_636
  lc_kverm_txt    TYPE char9 VALUE 'KVERM_TXT',     " Kverm_txt of type CHAR9
  lc_kverm_txt_no TYPE char12 VALUE 'KVERM_TXT_NO', " Kverm_txt_no of type CHAR12
*<-- End of CR D2_636
*--> Begin  of Insert for Defect#8526 by SAGARWA1
*&--IDOC: Item Text Segment Name
  lc_e1edk04      TYPE edilsegtyp     VALUE 'E1EDK04',                "
*&--IDOC: Item Text Segment Name
  lc_e1edk17      TYPE edilsegtyp     VALUE 'E1EDK17',                "
*&--Condition: ZNET
  lc_kschl_mwst   TYPE kschl          VALUE 'MWST',                   "
*&--Vat Indicator: A
  lc_mwskz        TYPE edi5279_a      VALUE 'A1',                     "
*&--IDOC qualifier: 005
  lc_qualf_005    TYPE edi_qualfr     VALUE '005',                    "
*&-- percentage 10
  lc_per_10       TYPE p DECIMALS 2  VALUE '10',                    "
*&--Calculation type for condition
  lc_krech_a      TYPE krech          VALUE 'A',                      "
*--Begin of changes for SCTASK0515243 by mthatha
  lc_g01          TYPE  char3         VALUE 'G01', " G01 of type CHAR3
*--End of changes for SCTASK0515243 by mthatha
*&--Condition Item Number
  lc_kposn_10     TYPE kposn          VALUE '000010'. " Condition item number
*<-- End   of Insert for Defect#8526 by SAGARWA1
*----------------------------------------------------------------------*
*                          V A R I A B L E S                           *
*----------------------------------------------------------------------*
DATA:
  lv_posex        TYPE char10,        " Item Number
  lv_meins        TYPE meins,         " Base Unit of Measure
  lv_div          TYPE int4,          " Divisor
  lv_mod          TYPE int4,          " Mod
  lv_length       TYPE int4,          " Length
  lv_offset       TYPE int4,          " Offset
  lv_line_count   TYPE int4,          " Index
  lv_time_diff    TYPE /kyk/string,   " Time Difference
  lv_mx_time      TYPE sy-uzeit,      " Mexico Time
  lv_mx_date      TYPE sy-datum,      " Mexico Date
  lv_sign         TYPE /bi0/oisignch, " +/- Signs
  lv_hours        TYPE /kyk/string,   " Hours
  lv_minutes      TYPE /kyk/string,   " Minutes
  lv_text         TYPE /kyk/string,   " Text
  lv_kawrt        TYPE kawrt,         " Condition base value
  lv_kbetr        TYPE kbetr,         " Rate (condition amount or percentage)
  lv_seconds      TYPE int4,          " Seconds
  lv_tot_bill     TYPE /kyk/string,   " Total Bill
  lv_dec          TYPE /kyk/string,   " Decimals
  lv_menge        TYPE menge_d,       " Quantity
  lv_betrg        TYPE dec23_2,       " Quantity
  lv_kunnr        TYPE kunnr,         " Customer Number
  lv_kverm        TYPE kverm,         " Memo
  lv_bezei        TYPE bezei20,       " Description
  lv_stcd1        TYPE stcd1,         " Tax Number 1
  lv_langu        TYPE sy-langu,      " Language Key
  lv_curr         TYPE waers,         " Currency
  lv_ktext        TYPE ktext_curt,    " Short text
  lv_kurrf        TYPE oiuh_dec9_4,   " Exchange Rate
  lv_smtp_addr    TYPE ad_smtpadr,    " E-Mail Address
  lv_posnr        TYPE posnr,         " Item number of the SD document
  lv_total        TYPE netwr_ak,      " Net Value of the Sales Order
  lv_datum        TYPE sy-datum,      " Date
  lv_counter      TYPE zrtr_mx_einvoice-counter,
*--> Begin  of Insert for Defect#8526 by SAGARWA1
  lv_index1       TYPE sytabix, " Index for E1EDK04 Segment
*<-- End    of Insert for Defect#8526 by SAGARWA1
*--Begin of changes for SCTASK0515243 by mthatha
  lv_mtart        TYPE mtart,      " Material Type
  lv_use_cfdi     TYPE z_criteria, " Enh. Criteria
  lv_matkl        TYPE matkl,      " Material Group
  lv_zuse_cfdi    TYPE char3,      " Material Group
  lwa_tvbdpr      TYPE vbdpr,      " Document Item View for Billing
*--End of changes for SCTASK0515243 by mthatha
*----->&--Begin of  Insert for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
*Defect #468
lv_billing_type TYPE fkart. "Billing type
*----->&--End of  Insert for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
*Begin of R2
DATA: lv_reqd_flag TYPE flag. " General Flag
*End of R2

*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
** Structure declaration
TYPES: BEGIN OF lty_vbak,
       vbeln  TYPE vbeln_va, " Sales Document
       auart  TYPE auart,    " Sales Document Type
       END OF lty_vbak.
** local variables declaration
DATA: lv_fkart   TYPE string,                                    " Billing Type
      li_vbak    TYPE STANDARD TABLE OF lty_vbak INITIAL SIZE 0, " Internal table
      lwa_vbak   TYPE lty_vbak,                                  " Local Work area
      lwa_status TYPE zdev_enh_status.                           " Enhancement Status
** Constant declaration
CONSTANTS: lc_dash TYPE char1 VALUE '-'. " local constant
*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

*----------------------------------------------------------------------*
*                         S T R U C T U R E S                          *
*----------------------------------------------------------------------*
DATA:
  lx_spell        TYPE spell,             " Amount Spell
  lx_einvoice     TYPE zrtr_mx_einvoice,  " Mexico E-Invoice
  lx_bseg         TYPE lty_bseg,          " Accounting Document Segment
  lx_faede_in     TYPE faede,             " Determining Due Date
  lx_faede_out    TYPE faede,             " Determining Due Date
  lx_bapibatchatt TYPE bapibatchatt,      " BAPI Struct:Batch Attribute
  lx_edidd        TYPE edidd,             " Data record (IDoc)
  lx_e1edk01      TYPE e1edk01,           " IDoc: Header Data
  lx_e1edk02      TYPE e1edk02,           " IDoc: Header Reference
  lx_e1edk03      TYPE e1edk03,           " IDoc: Header Date Segment
  lx_e1edk14      TYPE e1edk14,           " IDoc: Document Header Org. Data
  lx_e1edka1      TYPE e1edka1,           " IDoc: Header Partner Info
  lx_e1edp01      TYPE e1edp01,           " IDoc: Item General Data
  lx_e1edp02      TYPE e1edp02,           " IDoc: Item Reference Data
  lx_e1edp03      TYPE e1edp03,           " IDoc: Item Date Segment
  lx_e1edp05      TYPE e1edp05,           " IDoc: Item Conditions
  lx_e1edp19      TYPE e1edp19,           " IDoc: Document Item ObjectId
  lx_e1eds01      TYPE e1eds01,           " IDoc: Summary segment general
  lx_e1edk01_ext  TYPE z1rtr_e1edk01_ext, " IDoc: Header Custom
  lx_e1edp01_ext  TYPE z1rtr_e1edp01_ext, " IDoc: Item General Custom
  lx_e1edpt2_ext  TYPE z1rtr_e1edpt2_ext, " IDoc: Item Text
  lx_e1edka1_ext  TYPE z1rtr_e1edka1_ext, " IDoc: Header Partner Custom
*--> Begin  of Insert for Defect#8526 by SAGARWA1
  lx_e1edk04      TYPE e1edk04. " Segment
*<-- End    of Insert for Defect#8526 by SAGARWA1
*----------------------------------------------------------------------*
*                    I N T E R N A L   T A B L E S                     *
*----------------------------------------------------------------------*
DATA:
  li_edidd_int    TYPE edidd_tt,           " Segments
  li_object       TYPE ty_t_object,        " Object Details
  li_sernum       TYPE lty_t_sernum,       " Serial Numbers
  li_en_status    TYPE zdev_tt_enh_status. " Enhancement Status

*----------------------------------------------------------------------*
*                     F I E L D    S Y M B O L S                       *
*----------------------------------------------------------------------*
FIELD-SYMBOLS:
  <lfs_pedi_o>     TYPE ty_pedi_o,       " Out. Pedimento Data
  <lfs_en_status>  TYPE zdev_enh_status, " Enhancement Status
*Begin of R2
  <lfs_en_status2>  TYPE zdev_enh_status, " Enhancement Status
* End of R2
  <lfs_komv>       TYPE komv,       " Pricing Communications-Condition Record
  <lfs_serial>     TYPE ty_serial,  " Delv. Serial Nos.
  <lfs_sernum>     TYPE lty_sernum, " Serial Numbers
  <lfs_object>     TYPE ty_object,  " Object
  <lfs_vbdpr>      TYPE vbdpr,      " Document Item View for Billing
  <lfs_edidd_o>    TYPE edidd,      " Data record (IDoc)
*Begin of R2
  <lfs_edidd_2>    TYPE edidd, " Data record (IDoc)
*End of R2
  <lfs_edidd_temp> TYPE edidd. " Data record (IDoc)- Temp

*Begin of R2

DATA: BEGIN OF ty_address,
        name1 TYPE ad_name1,         " Name 1
        name2 TYPE ad_name2,         " Name 2
        street TYPE ad_street,       " Street
        house_number  TYPE ad_hsnm1, " House Number
        str_suppl3  TYPE ad_strspp3, " Street 4
        floor TYPE ad_floor,         " Floor in building
        house_num2 TYPE ad_hsnm2,    " House number supplement
        roomnumber TYPE ad_roomnum,  " Room or Appartment Number
        building TYPE ad_bldng,      " Building (Number or Code)
        city TYPE ad_city1,          " City
        region TYPE regio,           " Region (State, Province, County)
        post_code1 TYPE ad_pstcd1,   " City postal code
  END OF ty_address.

DATA: lv_intca3 TYPE intca3, " ISO country code 3 char
      lv_adrnr2 TYPE adrnr,  " Address
      ls_address LIKE ty_address.

* End of R2
*----------------------------------------------------------------------*
*                             L O G I C                                *
*----------------------------------------------------------------------*
*&--Check Enhancement Status
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_0111
  TABLES
    tt_enh_status     = li_en_status.

*&--First thing is to check for field criterion,for value “NULL” and
*&--field Active value:
*&  1. If the value is: “X”, the overall Enhancement is active and can
*&      proceed further for checks
*&  2. If the value is space, then do not proceed further for this
*&     enhancement
DELETE li_en_status WHERE active = abap_false.

READ TABLE li_en_status
  WITH KEY criteria = zif_plm_constants=>c_plm_null
TRANSPORTING NO FIELDS.
IF sy-subrc EQ 0.

*&--Check if Output type is as per EMI tool entry
  READ TABLE li_en_status ASSIGNING <lfs_en_status>
    WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
             criteria = lc_output_ty
              sel_low = dobject-kschl
           sel_option = if_cwd_constants=>c_option_equals.
  IF sy-subrc EQ 0.

*&--As this will be called for each segment, always check last segment
    DESCRIBE TABLE int_edidd LINES lv_index.

    IF lv_index EQ 1.
      MOVE:
      xvbdkr-bukrs    TO lx_einvoice-bukrs,         " Company Code
      xvbdkr-erdat(4) TO lx_einvoice-gjahr,         " Fiscal Year
      xvbdkr-vbeln    TO lx_einvoice-belnr,         " A/c Document No.
      space           TO lx_einvoice-shkzg,         " Debit/Credit Ind.
      space           TO lx_einvoice-blart,         " Document Type
      abap_true       TO lx_einvoice-processed,     " Processed
      lc_invoice_sd   TO lx_einvoice-inv_type,      " Invoice Type
      sy-uname        TO lx_einvoice-zz_created_by, " Entered by
      sy-datum        TO lx_einvoice-zz_created_on, " Entered On
      sy-uzeit        TO lx_einvoice-zz_created_at. " Entry Time

*&--Checking, if the Invoice is already present in the custom table
      CLEAR: lv_counter.
      SELECT SINGLE counter " Counter of Invice Trigger
             INTO lv_counter
      FROM zrtr_mx_einvoice " Documents for Mexico E-Invoice Interface
      WHERE bukrs     EQ lx_einvoice-bukrs
        AND gjahr     EQ lx_einvoice-gjahr
        AND belnr     EQ lx_einvoice-belnr
        AND blart     EQ lx_einvoice-blart
        AND inv_type  EQ lx_einvoice-inv_type.
      IF sy-subrc = 0.
        lv_counter = lv_counter + 1.
      ELSE. " ELSE -> IF sy-subrc = 0
        lv_counter = '1'.
      ENDIF. " IF sy-subrc = 0
      lx_einvoice-counter = lv_counter.

*&--Locking not required as always new record will be inserted
*&--Insert Record in table
      MODIFY zrtr_mx_einvoice FROM lx_einvoice.
    ENDIF. " IF lv_index EQ 1

    READ TABLE int_edidd ASSIGNING <lfs_edidd_o> INDEX lv_index.
    IF sy-subrc EQ 0.

      CASE <lfs_edidd_o>-segnam.

*----------------------------------------------------------------------*
* Segment E1EDK01 - IDoc: Document header general data
*----------------------------------------------------------------------*
        WHEN lc_e1edk01.

          lx_e1edk01 = <lfs_edidd_o>-sdata.

*&--Read Billing Type
          READ TABLE li_en_status ASSIGNING <lfs_en_status>
                WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                         criteria = lc_bill_type
                          sel_low = xvbdkr-fkart
                       sel_option = if_cwd_constants=>c_option_equals.
          IF sy-subrc EQ 0.
*&--Billing Type
            lx_e1edk01_ext-billing_type = <lfs_en_status>-sel_high.
            UNASSIGN: <lfs_en_status>.
          ENDIF. " IF sy-subrc EQ 0

*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
          CLEAR lwa_vbak.
** Fetching the Sales document & Sales Document type to populate the Billing Type of No charge orders (ZNC-ZF2)
          SELECT SINGLE vbeln " Sales Document
                 auart        " Sales Document Type
            FROM vbak         " Sales Document: Header Data
            INTO lwa_vbak
            WHERE vbeln EQ xvbdkr-vbeln_vauf.

          IF sy-subrc IS INITIAL.

            CONCATENATE lwa_vbak-auart xvbdkr-fkart INTO lv_fkart SEPARATED BY lc_dash.

          ENDIF. " IF sy-subrc IS INITIAL
*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

*--Begin of changes for SCTASK0515243 by mthatha
*&--Read Voucher type
          READ TABLE li_en_status ASSIGNING <lfs_en_status>
                WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                         criteria = lc_voucher_type
*---> Begin of Delete for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
*                          sel_low = xvbdkr-fkart.
*<--- End of Delete for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
                         sel_low = lv_fkart.
*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

          IF sy-subrc EQ 0.
*&--Voucher Type
            lx_e1edk01_ext-zvoucher = <lfs_en_status>-sel_high.
            UNASSIGN: <lfs_en_status>.
*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
          ELSE. " ELSE -> IF sy-subrc EQ 0
 "If we don't find any ZNC-ZF2 voucher type then it will override with I value
            READ TABLE li_en_status INTO lwa_status
               WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                        criteria = lc_voucher_type
                        sel_low  = xvbdkr-fkart.
            IF sy-subrc EQ 0.
              lx_e1edk01_ext-zvoucher = lwa_status-sel_high.
              CLEAR lwa_status.
            ENDIF. " IF sy-subrc EQ 0

*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
          ENDIF. " IF sy-subrc EQ 0

*--End of changes for SCTASK0515243 by mthatha
*&--Get Mexico Time Difference
          READ TABLE li_en_status ASSIGNING <lfs_en_status>
            WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                     criteria = lc_time_diff
                   sel_option = if_cwd_constants=>c_option_equals.
          IF sy-subrc EQ 0.
            lv_time_diff = <lfs_en_status>-sel_low.
*&--Split Time into Hours & Minutes
            SPLIT lv_time_diff
               AT cl_esd_utils=>c_colon
             INTO lv_sign
                  lv_hours
                  lv_minutes.
            UNASSIGN: <lfs_en_status>.
          ENDIF. " IF sy-subrc EQ 0

*&--Convert Time to Mexico Time
          IF lv_sign EQ /spe/if_const=>c_minus.
            lv_hours = lv_hours     * -1.
            lv_minutes = lv_minutes * -1.
          ENDIF. " IF lv_sign EQ /spe/if_const=>c_minus

*&--Calculate Total Seconds
          lv_hours   = lv_hours * wgrc_cons=>gc_mph * wgrc_cons=>gc_mph.
          lv_minutes = lv_minutes * wgrc_cons=>gc_mph.
          lv_seconds = lv_hours + lv_minutes.

*&--As 86400 sec = 60 * 60 * 24 = 1 Day
          lv_div = lv_seconds DIV cl_epm_bo=>gc_secsaday. " 60
          lv_mod = lv_seconds MOD cl_epm_bo=>gc_secsaday. " 60

*& ---> Begin of Comment for Defect# 5338 by VGAUR
*          lv_mx_time = sy-uzeit.
*          lv_mx_date = sy-datum.
*& <--- End of Comment for Defect# 5338 by VGAUR

*& ---> Begin of Insert for Defect# 5338 by VGAUR
*&--Date and Time stamp logic Should be UTC -7 hrs. -2 mins
          lv_mx_time = sy-timlo.
          lv_mx_date = sy-datlo.
*& <--- End of Insert for Defect# 5338 by VGAUR

          lv_mx_time = lv_mx_time + lv_mod.
          IF lv_mx_time < sy-uzeit.
*&--Date One day to Date
            lv_mx_date = lv_mx_date + 1.
          ENDIF. " IF lv_mx_time < sy-uzeit

*&--Date days to Date
          lv_mx_date = lv_mx_date + lv_div.

*&--Delete Leading Zeros from Invoice
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              input  = xvbdkr-vbeln
            IMPORTING
              output = lv_vbeln.

          APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.

*&--Read Invoice Document Type
          READ TABLE li_en_status ASSIGNING <lfs_en_status>
            WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                     criteria = lc_inv_doctype
                      sel_low = xvbdkr-fkart
                   sel_option = if_cwd_constants=>c_option_equals.
          IF sy-subrc EQ 0.
*&--File Name
            CONCATENATE <lfs_en_status>-sel_high
                        /spe/if_const=>c_minus
                        xvbdkr-fkart
                        lv_vbeln
                        /spe/if_const=>c_minus
                        lv_mx_date
                        lv_mx_time
                   INTO lx_e1edk01_ext-file_name.
*&--Invoice Document Number
            CONCATENATE <lfs_en_status>-sel_high
                        lv_vbeln
                   INTO lx_e1edk01_ext-inv_doctype_nbr.
*&--Invoice Document Type
            lx_e1edk01_ext-inv_doctype = <lfs_en_status>-sel_high.
            UNASSIGN: <lfs_en_status>.

          ENDIF. " IF sy-subrc EQ 0
*&--Fetch Company Code Currency
          SELECT SINGLE waers " Currency Key
                   FROM t001  " Company Codes
                   INTO lv_curr
                  WHERE bukrs EQ xvbdkr-bukrs.
          IF sy-subrc EQ 0.
*& ---> Begin of Comment for Defect# 5981 by VGAUR
*            IF lv_curr EQ xvbdkr-waers.
*& <--- End of Comment for Defect# 5981 by VGAUR
*& ---> Begin of Insert for Defect# 5981 by VGAUR

*&--The Exchange rate in the PI file was incorrect . Field changed from
*&--XVBDKR-WAERS to XVBDKR-WAERK
            IF lv_curr EQ xvbdkr-waerk.
*& <--- End of Insert for Defect# 5981 by VGAUR
              lx_e1edk01_ext-kurrf = lc_kursf_1. " Exchange Rate
            ELSE. " ELSE -> IF lv_curr EQ xvbdkr-waerk
              lv_kurrf = xvbdkr-kurrf.
              lx_e1edk01_ext-kurrf = lv_kurrf.
            ENDIF. " IF lv_curr EQ xvbdkr-waerk
            CONDENSE lx_e1edk01_ext-kurrf.
            CLEAR: lv_curr,
                   lv_kurrf.
          ENDIF. " IF sy-subrc EQ 0

*&--Move data to IDOC Segment
          <lfs_edidd>-segnam = lc_e1edk01_ext.
          <lfs_edidd>-sdata  = lx_e1edk01_ext.
          UNASSIGN: <lfs_edidd>.
          CLEAR: lx_e1edk01_ext.

*----------------------------------------------------------------------*
* Segment E1EDK02 - IDoc: Document header reference data
*----------------------------------------------------------------------*
        WHEN lc_e1edk02.

*&--Check if Invoice is Legacy
          READ TABLE li_en_status ASSIGNING <lfs_en_status>
            WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                     criteria = lc_leg_invoice
                     sel_low  = xvbdkr-fkart
                   sel_option = if_cwd_constants=>c_option_equals.
          IF sy-subrc EQ 0.
            READ TABLE int_edidd WITH KEY segnam     = lc_e1edk02
                                          sdata+0(3) = lc_qualf_z01
                                 TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              lx_e1edk02-qualf = lc_qualf_z01.
*&--Fetch Document Reference
              SELECT SINGLE zzdocref " Legacy Doc Ref
                       FROM vbrk     " Billing Document: Header Data
                       INTO lx_e1edk02-belnr
                      WHERE vbeln EQ xvbdkr-vbeln.
              IF sy-subrc EQ 0 AND
                 lx_e1edk02-belnr IS NOT INITIAL.
*&--Legacy Invoice Number
                APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.
                <lfs_edidd>-segnam = lc_e1edk02.
                <lfs_edidd>-sdata  = lx_e1edk02.
              ENDIF. " IF sy-subrc EQ 0 AND

              UNASSIGN: <lfs_edidd>.
              CLEAR: lx_e1edk02.
            ENDIF. " IF sy-subrc NE 0
            UNASSIGN: <lfs_en_status>.
          ENDIF. " IF sy-subrc EQ 0

*----------------------------------------------------------------------*
* Segment E1EDK03 - IDoc: Document header date segment
*----------------------------------------------------------------------*
        WHEN lc_e1edk03.

          lx_e1edk03 = <lfs_edidd_o>-sdata.

          IF lx_e1edk03-datum IS NOT INITIAL AND
             gv_gjahr IS INITIAL.
            gv_gjahr = lx_e1edk03-datum(4).
          ENDIF. " IF lx_e1edk03-datum IS NOT INITIAL AND

*&--Get Mexico Time Difference
          READ TABLE li_en_status ASSIGNING <lfs_en_status>
            WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                     criteria = lc_time_diff
                   sel_option = if_cwd_constants=>c_option_equals.
          IF sy-subrc EQ 0.
            lv_time_diff = <lfs_en_status>-sel_low.
*&--Split Time into Hours & Minutes
            SPLIT lv_time_diff
               AT cl_esd_utils=>c_colon
             INTO lv_sign
                  lv_hours
                  lv_minutes.
            UNASSIGN: <lfs_en_status>.
          ENDIF. " IF sy-subrc EQ 0

*-----------------------------------*
*   Quanlifier: 011
*-----------------------------------*
          IF lx_e1edk03-iddat EQ cl_ifw_status=>c_status_011.
            lx_e1edk03 = <lfs_edidd_o>-sdata.
            lv_datum   = lx_e1edk03-datum.

*&--Convert Time to Mexico Time
            IF lv_sign EQ /spe/if_const=>c_minus.
              lv_hours = lv_hours     * -1.
              lv_minutes = lv_minutes * -1.
            ENDIF. " IF lv_sign EQ /spe/if_const=>c_minus

*&--Calculate Total Seconds
            lv_hours   = lv_hours * wgrc_cons=>gc_mph *
                         wgrc_cons=>gc_mph.
            lv_minutes = lv_minutes * wgrc_cons=>gc_mph.
            lv_seconds = lv_hours + lv_minutes.

*&--As 86400 sec = 60 * 60 * 24 = 1 Day
            lv_div = lv_seconds DIV cl_epm_bo=>gc_secsaday. " 60
            lv_mod = lv_seconds MOD cl_epm_bo=>gc_secsaday. " 60

            lv_mx_time = sy-uzeit.
            lv_mx_date = lv_datum.
            lv_mx_time = lv_mx_time + lv_mod.
            IF lv_mx_time < sy-uzeit.
*&--Date One day to Date
              lv_mx_date = lv_mx_date + 1.
            ENDIF. " IF lv_mx_time < sy-uzeit

*&--Date days to Date
            lv_mx_date = lv_mx_date + lv_div.

*&--Date and Time Stamp of Emission
            lx_e1edk03-iddat = cl_ifw_status=>c_status_011.
            lx_e1edk03-datum = lv_mx_date.
            lx_e1edk03-uzeit = lv_mx_time.
            <lfs_edidd_o>-sdata = lx_e1edk03.
            CLEAR: lx_e1edk03.
          ENDIF. " IF lx_e1edk03-iddat EQ cl_ifw_status=>c_status_011

*-----------------------------------*
* Qualifier: Z01
*-----------------------------------*

          READ TABLE int_edidd WITH KEY segnam = lc_e1edk03
                                    sdata+0(3) = lc_qualf_z01
                                TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0 AND
             gv_gjahr IS NOT INITIAL.

*&--Get Payment Due Date
            SELECT koart " Account Type
                   shkzg " Debit/Credit Indicator
                   zfbdt " Baseline Date for Due Date Calculation
                   zbd1t " Cash Discount Days 1
                   zbd2t " Cash Discount Days 2
                   zbd3t " Net Payment Terms Period
               FROM bseg " Accounting Document Segment
              UP TO 1 ROWS
               INTO lx_bseg
              WHERE bukrs EQ xvbdkr-bukrs
                AND belnr EQ xvbdkr-vbeln
                AND gjahr EQ gv_gjahr
                AND koart EQ lc_koart_d.
            ENDSELECT.
            IF sy-subrc EQ 0.
              lx_faede_in-shkzg = lx_bseg-shkzg. " D/C Indicator
              lx_faede_in-koart = lx_bseg-koart. " Account Type
              lx_faede_in-zfbdt = lx_bseg-zfbdt. " Baseline Date
              lx_faede_in-zbd1t = lx_bseg-zbd1t. " Cash Discount Days 1
              lx_faede_in-zbd2t = lx_bseg-zbd2t. " Cash Discount Days 2
              lx_faede_in-zbd3t = lx_bseg-zbd3t. " Net Payment Terms Prd

*&--Get Due Date
              CALL FUNCTION 'DETERMINE_DUE_DATE'
                EXPORTING
                  i_faede                    = lx_faede_in
                IMPORTING
                  e_faede                    = lx_faede_out
                EXCEPTIONS
                  account_type_not_supported = 1
                  OTHERS                     = 2.
              IF sy-subrc EQ 0.
*&--Convert Time to Mexico Time
                IF lv_sign EQ /spe/if_const=>c_minus.
                  lv_hours = lv_hours     * -1.
                  lv_minutes = lv_minutes * -1.
                ENDIF. " IF lv_sign EQ /spe/if_const=>c_minus

*&--Calculate Total Seconds
                lv_hours   = lv_hours * wgrc_cons=>gc_mph *
                             wgrc_cons=>gc_mph.
                lv_minutes = lv_minutes * wgrc_cons=>gc_mph.
                lv_seconds = lv_hours + lv_minutes.

*&--As 86400 sec = 60 * 60 * 24 = 1 Day
                lv_div = lv_seconds DIV cl_epm_bo=>gc_secsaday. " 60
                lv_mod = lv_seconds MOD cl_epm_bo=>gc_secsaday. " 60

                lv_mx_time = sy-uzeit.
                lv_mx_date = lx_faede_out-netdt.
                lv_mx_time = lv_mx_time + lv_mod.
                IF lv_mx_time < sy-uzeit.
*&--Date One day to Date
                  lv_mx_date = lv_mx_date + 1.
                ENDIF. " IF lv_mx_time < sy-uzeit

*&--Date days to Date
                lv_mx_date = lv_mx_date + lv_div.
                lx_e1edk03-datum = lv_mx_date.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
            lx_e1edk03-iddat = lc_qualf_z01.
            APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.
            <lfs_edidd>-segnam = lc_e1edk03.
            <lfs_edidd>-sdata  = lx_e1edk03.
            UNASSIGN: <lfs_edidd>.
            CLEAR: lx_e1edk03.
            UNASSIGN: <lfs_edidd_o>.
          ENDIF. " IF sy-subrc NE 0 AND

*----------------------------------------------------------------------*
* Segment E1EDK14 - IDoc: Document Header Organizational Data
*----------------------------------------------------------------------*

*& ---> Begin of Insert for Defect# 5702 by VGAUR

*&--E1EDK02 segment was missing in the idoc for all the debits and credits
*&--created with reference to invoice. So BELNR is added to custom segment
*&--ZRTR_E1EDK01_EXT. This will be populated from VBFA-VBELV where VBELN
*&--as Invoice No. and VBTYP_V as M
        WHEN lc_e1edk14.

          lx_e1edk14 = <lfs_edidd_o>-sdata.

          IF lx_e1edk14-qualf = lc_qualf_021.

            READ TABLE int_edidd ASSIGNING <lfs_edidd_o>
                                  WITH KEY segnam = lc_e1edk01_ext.
            IF sy-subrc EQ 0.
              lx_e1edk01_ext = <lfs_edidd_o>-sdata.
*&--Fetch Reference Invoice Number
              SELECT vbelv " Preceding sales and distribution document
                FROM vbfa  " Sales Document Flow
               UP TO 1 ROWS
                INTO lx_e1edk01_ext-belnr
               WHERE vbeln   EQ xvbdkr-vbeln
                 AND vbtyp_v EQ lc_vbtyp_m.
              ENDSELECT.
              IF sy-subrc EQ 0.
*----->&--Begin of delete for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
* Defect #468
* Need the invoice as it is so no need to delete leading zeros
**&--Delete Leading Zeros from Reference Invoice
*                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*                  EXPORTING
*                    input  = lx_e1edk01_ext-belnr
*                  IMPORTING
*                    output = lx_e1edk01_ext-belnr.
*----->&--End of delete for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
*--Begin of changes for SCTASK0515243 by mthatha
*--Populate UUID
                lx_e1edk01_ext-zuuid = lx_e1edk01_ext-belnr.
*--Populate Unit key
*--End of changes for SCTASK0515243 by mthatha
*----->&--Begin of  Insert for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
* Defect #468
*&--Fetch Billing type
                SELECT SINGLE fkart "Billing Type
                         FROM vbrk  " Billing Document: Header Data
                         INTO lv_billing_type
                        WHERE vbeln EQ lx_e1edk01_ext-belnr.
                IF sy-subrc IS INITIAL.
* Read Tralix Inv. type from EMI table
                  READ TABLE li_en_status ASSIGNING <lfs_en_status>
                         WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                                  criteria = lc_inv_doctype
                                  sel_low  = lv_billing_type
                                  sel_option = if_cwd_constants=>c_option_equals.
                  IF sy-subrc IS INITIAL.

* Concatenate Invoice type with invoice number

*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
** Delete Leading Zeros from Reference Invoice
                    SHIFT lx_e1edk01_ext-belnr LEFT DELETING LEADING '0'.
*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

                    CONCATENATE <lfs_en_status>-sel_high
                               lx_e1edk01_ext-belnr
                    INTO lx_e1edk01_ext-belnr.

                    UNASSIGN: <lfs_en_status>.
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF sy-subrc IS INITIAL
*----->&--End of  Insert for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG

                <lfs_edidd_o>-sdata = lx_e1edk01_ext.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
            CLEAR: gv_belnr.
          ENDIF. " IF lx_e1edk14-qualf = lc_qualf_021

*& <--- End of Insert for Defect# 5702 by VGAUR

*----------------------------------------------------------------------*
* Segment E1EDKA1 - IDoc: Document Header Partner Information
*----------------------------------------------------------------------*
        WHEN lc_e1edka1.
          lx_e1edka1 = <lfs_edidd_o>-sdata.
*--Begin of changes for SCTASK0515243 by mthatha
          SELECT SINGLE intca3 FROM t005 INTO lx_e1edka1_ext-iso_cntry
                              WHERE land1 = lx_e1edka1-land1.
*--End of changes for SCTASK0515243 by mthatha
*-------------------------------------*
* Qualifier: RG
*-------------------------------------*
*Begin of R2
*&--Read Voucher type

          READ TABLE li_en_status ASSIGNING <lfs_en_status2>
                WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                         criteria = lc_voucher_type
*---> Begin of Delete for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
*                          sel_low = xvbdkr-fkart.
*<--- End of Delete for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
                         sel_low = lv_fkart.
*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

          lv_reqd_flag = space.
          IF <lfs_en_status2> IS ASSIGNED.
            IF  <lfs_en_status2>-sel_high = 'T'.
              lv_reqd_flag = 'X'.
            ENDIF. " IF <lfs_en_status2>-sel_high = 'T'

*---> Begin of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017
          ELSE. " ELSE -> IF <lfs_en_status2> IS ASSIGNED
 "If we don't find any ZNC-ZF2 voucher type then it will override with I value
            READ TABLE li_en_status ASSIGNING <lfs_en_status2>
               WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                        criteria = lc_voucher_type
                        sel_low  = xvbdkr-fkart.
            IF sy-subrc EQ 0.
              lx_e1edk01_ext-zvoucher = <lfs_en_status2>-sel_high.
              UNASSIGN <lfs_en_status2>.
            ENDIF. " IF sy-subrc EQ 0
*<--- End of Insert for D3_OTC_IDD_0111_Defect# 4470 by U034229 on 26-Dec-2017

          ENDIF. " IF <lfs_en_status2> IS ASSIGNED


*Begin of R2
*          IF lx_e1edka1-parvw = lc_parvw_rg.
          IF lx_e1edka1-parvw = lc_parvw_rg
            OR ( lx_e1edka1-parvw = lc_parvw_rs AND lv_reqd_flag = 'X' ) .
*End of R2
            lv_kunnr = <lfs_edidd_o>-sdata+3(17).

*&--Bank Account Number
            SELECT SINGLE kverm " Memo
              FROM knb1         " Customer Master (Company Code)
              INTO lv_kverm
             WHERE kunnr EQ lv_kunnr
               AND bukrs EQ xvbdkr-bukrs.
            IF sy-subrc EQ 0.
              IF lv_kverm IS NOT INITIAL.
                lv_length = strlen( lv_kverm ).
                IF lv_length <= 4.
                  lx_e1edka1_ext-kverm = lv_kverm.
                ELSE. " ELSE -> IF lv_length <= 4
                  lv_offset = lv_length - 4.
                  lx_e1edka1_ext-kverm = lv_kverm+lv_offset(4).
                ENDIF. " IF lv_length <= 4
              ENDIF. " IF lv_kverm IS NOT INITIAL
            ENDIF. " IF sy-subrc EQ 0

*&--Observations
*--> Begin of CR D2_636
*            IF lx_e1edka1_ext-kverm IS NOT INITIAL.
*              lx_e1edka1_ext-kverm_text = 'TRANSFERENCIA ELECTRONICA'(002).
*            ELSE. " ELSE -> IF lx_e1edka1_ext-kverm IS NOT INITIAL
*              lx_e1edka1_ext-kverm_text = 'NO IDENTIFY'(003).
*            ENDIF. " IF lx_e1edka1_ext-kverm IS NOT INITIAL

            IF lx_e1edka1_ext-kverm IS NOT INITIAL.
              READ TABLE li_en_status ASSIGNING <lfs_en_status>
                WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                         criteria = lc_kverm_txt.
              IF sy-subrc EQ 0.
                lx_e1edka1_ext-kverm_text = <lfs_en_status>-sel_high.
              ENDIF. " IF sy-subrc EQ 0
            ELSE. " ELSE -> IF lx_e1edka1_ext-kverm IS NOT INITIAL
              READ TABLE li_en_status ASSIGNING <lfs_en_status>
                WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                         criteria = lc_kverm_txt_no.
              IF sy-subrc EQ 0.
                lx_e1edka1_ext-kverm_text = <lfs_en_status>-sel_high.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF lx_e1edka1_ext-kverm IS NOT INITIAL
*<-- End of CR D2_636
            APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.
            <lfs_edidd>-segnam = lc_e1edka1_ext.
            <lfs_edidd>-sdata  = lx_e1edka1_ext.
            UNASSIGN: <lfs_edidd>.
            CLEAR: lx_e1edka1_ext.

          ENDIF. " IF lx_e1edka1-parvw = lc_parvw_rg

*-------------------------------------*
* Qualifier: AG
*-------------------------------------*
          IF lx_e1edka1-parvw = lc_parvw_ag.

*&--Colony
            IF lx_e1edka1-strs2 IS NOT INITIAL AND
               lx_e1edka1-strs2 CA lc_colon.
*&--Skip all characters before the colon and write to field all
*&--information after the colon
              SPLIT lx_e1edka1-strs2
                 AT lc_colon
               INTO lv_text
                    lx_e1edka1-strs2.
              <lfs_edidd_o>-sdata = lx_e1edka1.
              CLEAR: lx_e1edka1,
                     lv_text.
            ENDIF. " IF lx_e1edka1-strs2 IS NOT INITIAL AND

            lx_e1edka1 = <lfs_edidd_o>-sdata.
            lv_kunnr = lx_e1edka1-partn.

*&--Get Address
            SELECT SINGLE adrnr " Address
                     FROM vbpa  " Sales Document: Partner
                     INTO lv_adrnr
                    WHERE vbeln EQ xvbdkr-vbeln
                      AND posnr EQ lc_posnr_init
                      AND parvw EQ lx_e1edka1-parvw.
            IF sy-subrc EQ 0.
              SELECT street     " Street
                     house_num1 " House Number
                     house_num2 " House number supplement
                     str_suppl3 " Street 4
                     building   " Building (Number or Code)
                     roomnumber " Room or Appartment Number
               UP TO 1 ROWS
                FROM adrc       " Addresses (Business Address Services)
                INTO (lx_e1edka1_ext-street,
                      lx_e1edka1_ext-house_num1,
                      lx_e1edka1_ext-house_num2,
                      lx_e1edka1_ext-str_suppl3,
                      lx_e1edka1_ext-building,
                      lx_e1edka1_ext-roomnumber)
                WHERE addrnumber EQ lv_adrnr
                  AND date_from  LE sy-datum.
              ENDSELECT.
            ENDIF. " IF sy-subrc EQ 0

*&--Fetch Tax Number
            SELECT SINGLE stcd1 " Tax Number 1
              FROM kna1         " General Data in Customer Master
              INTO lv_stcd1
             WHERE kunnr EQ lv_kunnr.
            IF sy-subrc EQ 0.
              lx_e1edka1_ext-stcd1 = lv_stcd1.
            ENDIF. " IF sy-subrc EQ 0

*&--Get Language
            READ TABLE li_en_status ASSIGNING <lfs_status>
              WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                       criteria = lc_langu
                     sel_option = if_cwd_constants=>c_option_equals.
            IF sy-subrc EQ 0.
              lv_langu = <lfs_status>-sel_low.
              UNASSIGN: <lfs_status>.
            ENDIF. " IF sy-subrc EQ 0

*&--Region Code Description
            SELECT SINGLE bezei " Description
                     FROM t005u " Taxes: Region Key: Texts
                     INTO lv_bezei
                    WHERE spras EQ lv_langu
                      AND land1 EQ lx_e1edka1-land1
                      AND bland EQ lx_e1edka1-regio.
            IF sy-subrc EQ 0.
              lx_e1edka1_ext-zregio_bezei = lv_bezei.
            ENDIF. " IF sy-subrc EQ 0

            APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.
            <lfs_edidd>-segnam = lc_e1edka1_ext.
            <lfs_edidd>-sdata  = lx_e1edka1_ext.
            UNASSIGN: <lfs_edidd>.
            CLEAR: lx_e1edka1_ext.
          ENDIF. " IF lx_e1edka1-parvw = lc_parvw_ag

*-------------------------------------*
* Qualifier: WE
*-------------------------------------*
          IF lx_e1edka1-parvw = lc_parvw_we.
*&--Colony
            IF lx_e1edka1-strs2 IS NOT INITIAL AND
               lx_e1edka1-strs2 CA lc_colon.
*&--Skip all characters before the colon and write to field all
*&--information after the colon
              SPLIT lx_e1edka1-strs2
                 AT lc_colon
               INTO lv_text
                    lx_e1edka1-strs2.
              <lfs_edidd_o>-sdata = lx_e1edka1.
              CLEAR: lx_e1edka1,
                     lv_text.
            ENDIF. " IF lx_e1edka1-strs2 IS NOT INITIAL AND

            lx_e1edka1 = <lfs_edidd_o>-sdata.
            lv_kunnr = lx_e1edka1-partn.

*&--Get Address
            SELECT SINGLE adrnr " Address
                     FROM vbpa  " Sales Document: Partner
                     INTO lv_adrnr
                    WHERE vbeln EQ xvbdkr-vbeln
                      AND posnr EQ lc_posnr_init
                      AND parvw EQ lx_e1edka1-parvw.
            IF sy-subrc EQ 0.
              SELECT street     " Street
                     house_num1 " House Number
                     house_num2 " House number supplement
                     str_suppl3 " Street 4
                     building   " Building (Number or Code)
                     roomnumber " Room or Appartment Number
               UP TO 1 ROWS
                FROM adrc       " Addresses (Business Address Services)
                INTO (lx_e1edka1_ext-street,
                      lx_e1edka1_ext-house_num1,
                      lx_e1edka1_ext-house_num2,
                      lx_e1edka1_ext-str_suppl3,
                      lx_e1edka1_ext-building,
                      lx_e1edka1_ext-roomnumber)
                WHERE addrnumber EQ lv_adrnr
                  AND date_from  LE sy-datum.
              ENDSELECT.
            ENDIF. " IF sy-subrc EQ 0

*&--Fetch Tax Number
            SELECT SINGLE stcd1 " Tax Number 1
              FROM kna1         " General Data in Customer Master
              INTO lv_stcd1
             WHERE kunnr EQ lv_kunnr.
            IF sy-subrc EQ 0.
              lx_e1edka1_ext-stcd1 = lv_stcd1.
            ENDIF. " IF sy-subrc EQ 0

*&--Get Language
            READ TABLE li_en_status ASSIGNING <lfs_status>
              WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                       criteria = lc_langu
                     sel_option = if_cwd_constants=>c_option_equals.
            IF sy-subrc EQ 0.
              lv_langu = <lfs_status>-sel_low.
              UNASSIGN: <lfs_status>.
            ENDIF. " IF sy-subrc EQ 0

*&--Region Code Description
            SELECT SINGLE bezei " Description
                     FROM t005u " Taxes: Region Key: Texts
                     INTO lv_bezei
                    WHERE spras EQ lv_langu
                      AND land1 EQ lx_e1edka1-land1
                      AND bland EQ lx_e1edka1-regio.
            IF sy-subrc EQ 0.
              lx_e1edka1_ext-zregio_bezei = lv_bezei.
            ENDIF. " IF sy-subrc EQ 0

            APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.
            <lfs_edidd>-segnam = lc_e1edka1_ext.
            <lfs_edidd>-sdata  = lx_e1edka1_ext.
            UNASSIGN: <lfs_edidd>.
            CLEAR: lx_e1edka1_ext.
          ENDIF. " IF lx_e1edka1-parvw = lc_parvw_we

*-------------------------------------*
* Qualifier: RE
*-------------------------------------*
          IF lx_e1edka1-parvw = lc_parvw_re.

*&--Fetch Address Number
            SELECT SINGLE adrnr " Address
              FROM vbpa         " Sales Document: Partner
              INTO lv_adrnr
             WHERE vbeln EQ xvbdkr-vbeln
               AND posnr EQ lc_posnr_init
               AND parvw EQ lc_parvw_re.
            IF sy-subrc EQ 0.

*&--Fetch E-mail Address
              SELECT smtp_addr " E-Mail Address
                FROM adr6      " E-Mail Addresses (Business Address Services)
               UP TO 1 ROWS
                INTO lv_smtp_addr
               WHERE addrnumber EQ lv_adrnr
                 AND date_from  LE sy-datum.
              ENDSELECT.
              IF sy-subrc EQ 0.
                lx_e1edka1_ext-smtp_addr = lv_smtp_addr.
                APPEND INITIAL LINE TO int_edidd ASSIGNING <lfs_edidd>.
                <lfs_edidd>-segnam = lc_e1edka1_ext.
                <lfs_edidd>-sdata  = lx_e1edka1_ext.
                UNASSIGN: <lfs_edidd>.
                CLEAR: lx_e1edka1_ext.
              ENDIF. " IF sy-subrc EQ 0

            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lx_e1edka1-parvw = lc_parvw_re

*----------------------------------------------------------------------*
* Segment E1EDP01 - IDoc: Document Item General Data
*----------------------------------------------------------------------*
        WHEN lc_e1edp01.

          CLEAR: gv_uepos.
          lx_e1edp01 = <lfs_edidd_o>-sdata.
          gv_plant   = lx_e1edp01-werks. " Plant
          gv_posnr   = lx_e1edp01-posex. " Item Number
          gv_kposn   = lx_e1edp01-posex. " Item Number
*Begin of Change by BGUNDAB
*          IF lx_e1edp01-uepos IS NOT INITIAL.
*            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*              EXPORTING
*                input  = lx_e1edp01-uepos
*              IMPORTING
*                output = lx_e1edp01-uepos.
*
*            lv_div = strlen( lx_e1edp01-uepos ).
*            lv_div = 6 - lv_div.

**&--Add trailing Zeros to UEPOS
*            DO lv_div TIMES.
*              CONCATENATE lx_e1edp01-uepos
*                          lc_zero_0
*                     INTO lx_e1edp01-uepos.
*            ENDDO.
*            <lfs_edidd_o>-sdata = lx_e1edp01.
*
*            gv_uepos = lx_e1edp01-uepos. " BOM Indicator

*          ENDIF. " IF lx_e1edp01-uepos IS NOT INITIAL
*End of Change by BGUNDAB
*& ---> Begin of Insert for Defect# 5261 by VGAUR
          IF i_serial[] IS INITIAL AND
             xtvbdpr[]  IS NOT INITIAL.
*&--Capture all serial numbers
            SELECT obknr   " Object list number
                   lief_nr " Delivery
                   posnr   " Delivery Item
                   anzsn   " Number of serial numbers
              INTO TABLE i_serial
              FROM ser01   " Document Header for Serial Numbers for Delivery
              FOR ALL ENTRIES IN xtvbdpr
              WHERE lief_nr EQ xtvbdpr-vgbel
                AND posnr   EQ xtvbdpr-vgpos.
            IF sy-subrc EQ 0 AND
               i_serial[] IS NOT INITIAL.
              SELECT obknr " Object list number
                     obzae " Object list counters
                     sernr " Serial Number
                     matnr " Material Number
                INTO TABLE i_object
                FROM objk  " Plant Maintenance Object List
                FOR ALL ENTRIES IN i_serial
                WHERE obknr = i_serial-obknr.
            ENDIF. " IF sy-subrc EQ 0 AND
          ENDIF. " IF i_serial[] IS INITIAL AND

*& <--- End of Insert for Defect# 5261 by VGAUR
*--Begin of changes for SCTASK0515243 by mthatha
          READ TABLE xtvbdpr INTO lwa_tvbdpr WITH KEY posnr = gv_posnr.
          IF sy-subrc EQ 0.
            gv_matnr = lwa_tvbdpr-matnr.
          ENDIF. " IF sy-subrc EQ 0
          SELECT SINGLE matkl mtart FROM mara " General Material Data
                                    INTO (lv_matkl,lv_mtart)
                                    WHERE matnr = gv_matnr.
          lx_e1edp01 = <lfs_edidd_o>-sdata.
          lx_e1edp01-matkl = lv_matkl.
          <lfs_edidd_o>-sdata = lx_e1edp01.
          READ TABLE int_edidd ASSIGNING <lfs_edidd>
                               WITH KEY segnam = lc_e1edk01_ext.
          IF sy-subrc EQ 0.
          ENDIF. " IF sy-subrc EQ 0
          CONCATENATE lc_use_cfdi <lfs_edidd>-sdata+496(3) INTO lv_use_cfdi SEPARATED BY '_'.
          READ TABLE li_en_status ASSIGNING <lfs_status>
            WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                     criteria = lv_use_cfdi
                      sel_low = '*'.
          IF sy-subrc EQ 0.
            lv_zuse_cfdi = <lfs_status>-sel_high.
          ELSE. " ELSE -> IF sy-subrc EQ 0
            READ TABLE li_en_status ASSIGNING <lfs_status>
              WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
             criteria = lv_use_cfdi
              sel_low = lv_mtart.
            IF sy-subrc EQ 0.
              lv_zuse_cfdi = <lfs_status>-sel_high.
            ELSE. " ELSE -> IF sy-subrc EQ 0
              lv_zuse_cfdi = lc_g01.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
          READ TABLE int_edidd ASSIGNING <lfs_edidd>
                               WITH KEY segnam = lc_e1edk01_ext.
          IF sy-subrc EQ 0.
            lx_e1edk01_ext = <lfs_edidd>-sdata.
            lx_e1edk01_ext-zuse_cfdi = lv_zuse_cfdi.
            <lfs_edidd>-sdata = lx_e1edk01_ext.
            CLEAR:lx_e1edk01_ext.
          ENDIF. " IF sy-subrc EQ 0
*--End of changes for SCTASK0515243 by mthatha
          CLEAR: lx_e1edp01,
                 gv_matnr,
                 gv_batch.

*----------------------------------------------------------------------*
* Segment E1EDP02 - IDoc: Document Item Reference Data
*----------------------------------------------------------------------*
        WHEN lc_e1edp02.
          lx_e1edp02 = <lfs_edidd_o>-sdata.
*-------------------------------------*
* Qualifier: 016
*-------------------------------------*
          IF lx_e1edp02-qualf = lc_qualf_016.

* Begin of R2

            READ TABLE int_edidd ASSIGNING <lfs_edidd_2>
                       WITH KEY segnam   = lc_e1edka1.

            IF sy-subrc EQ 0.
              lx_e1edka1 = <lfs_edidd_2>-sdata.

              SELECT SINGLE intca3 " ISO country code 3 char
                INTO lv_intca3
                FROM t005          " Countries
                WHERE land1 = lx_e1edka1-land1.

              READ TABLE int_edidd ASSIGNING <lfs_edidd_2>
                         WITH KEY segnam   = lc_e1edp01.

              IF sy-subrc EQ 0.
                lx_e1edp01 = <lfs_edidd_2>-sdata.

                SELECT SINGLE adrnr " Address
                  INTO lv_adrnr2
                  FROM t001w        " Plants/Branches
                  WHERE werks = lx_e1edp01-werks.

                SELECT SINGLE name1 name2 street house_num1 str_suppl3  floor house_num2
                  roomnumber building city1 region post_code1
                  INTO ls_address
                  FROM adrc " Addresses (Business Address Services)
                  WHERE addrnumber = lv_adrnr2.

                IF sy-subrc EQ 0.

                  CONCATENATE ls_address-name1 ls_address-name2 INTO
                  lx_e1edp01_ext-name.

                  lx_e1edp01_ext-country_iso = lv_intca3.
                  lx_e1edp01_ext-street = ls_address-street.
                  lx_e1edp01_ext-external_number = ls_address-house_number.

                  CONCATENATE ls_address-str_suppl3 ls_address-floor ls_address-house_num2
                   ls_address-roomnumber ls_address-building
                    INTO lx_e1edp01_ext-internal_number SEPARATED BY space.

                  CONDENSE lx_e1edp01_ext-internal_number.

                  lx_e1edp01_ext-town = ls_address-city.
                  lx_e1edp01_ext-state = ls_address-region.
                  lx_e1edp01_ext-zip = ls_address-post_code1.

                ENDIF. " IF sy-subrc EQ 0

              ENDIF. " IF sy-subrc EQ 0

              READ TABLE xtvbdpr INTO lwa_tvbdpr WITH KEY posnr = gv_posnr.
              IF sy-subrc EQ 0.
                gv_matnr = lwa_tvbdpr-matnr.

                SELECT SINGLE profl " Dangerous Goods Indicator Profile
                  INTO lx_e1edp01_ext-dg_profl
                  FROM mara         " General Material Data
                  WHERE matnr = gv_matnr.

                lx_e1edp01_ext-mwsbp = lwa_tvbdpr-mwsbp.
                CONDENSE lx_e1edp01_ext-mwsbp NO-GAPS.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc EQ 0
* End of R2

*&--Check place where extension segment has to be inserted
            LOOP AT int_edidd ASSIGNING <lfs_edidd>.
              IF <lfs_edidd>-segnam EQ lc_e1edp01.
                lv_index = sy-tabix + 1.
                lx_e1edp01 = <lfs_edidd>-sdata.
              ENDIF. " IF <lfs_edidd>-segnam EQ lc_e1edp01
            ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>
            UNASSIGN: <lfs_edidd>.
*--Begin of changes for SCTASK0515243 by mthatha
            READ TABLE li_en_status ASSIGNING <lfs_status>
              WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                       criteria = lc_menee
                        sel_low = lx_e1edp01-menee.
            IF sy-subrc EQ 0.
              lx_e1edp01_ext-menee = <lfs_status>-sel_high.
            ENDIF. " IF sy-subrc EQ 0
            SELECT SINGLE msehl INTO lx_e1edp01_ext-zmenee
                                FROM t006a " Assign Internal to Language-Dependent Unit
                                WHERE spras = 'S' AND
                                      msehi = lx_e1edp01-menee.
*--End of changes for SCTASK0515243 by mthatha
            lx_e1edp02 = <lfs_edidd_o>-sdata.
            lv_vbeln = lx_e1edp02-belnr.
            lv_posnr = lx_e1edp02-zeile.
*&--Check if Pedimento Inbound Delivery
            READ TABLE li_en_status ASSIGNING <lfs_status>
              WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                       criteria = lc_pedi_in
                        sel_low = xvbdkr-fkart
                     sel_option = if_cwd_constants=>c_option_equals.
            IF sy-subrc EQ 0.

*&--Fetch Pedimento data
              SELECT SINGLE werks            " Plant
                            vbeln            " Delivery
                            posnr            " Delivery Item
                            matnr            " Material Number
                            pedimento_nbr    " Pedimento Number
                            custplace        " Customs Place
                            custdate         " Customs Date
                       FROM zlex_pedimento_i " Outbound Pedimento Table
                       INTO x_pedi_i
                      WHERE werks EQ lx_e1edp01-werks
                        AND vbeln EQ lv_vbeln
                        AND posnr EQ lv_posnr.
              IF sy-subrc NE 0.
*&--If no record is found read E1EDP01-POSEX from the main item and set
*&--POSEX = E1EDP01-POSEX concatenate with trailing 0 to make the
*&--number equal the field length of POSEX
                CONCATENATE lx_e1edp01-posex
                            lc_zero_0000
                       INTO lx_e1edp01_ext-posex.
*&--Quantity and Unit
                lx_e1edp01_ext-menge = lx_e1edp01-menge.
                CONDENSE lx_e1edp01_ext-menge.
*--Begin of changes for SCTASK0515243 by mthatha
*                lx_e1edp01_ext-menee      = lx_e1edp01-menee.
*--End changes for SCTASK0515243 by mthatha
                lx_edidd-segnam           = lc_e1edp01_ext.
                lx_edidd-sdata            = lx_e1edp01_ext.
                INSERT lx_edidd INTO int_edidd INDEX lv_index.
                CLEAR: lx_edidd.
              ELSE. " ELSE -> IF sy-subrc NE 0
*&--Read E1EDP01-POSEX concatenate it with ZLEX_PEDIMENTO_I–PEDIMENTO_SEQ
*&--prefixed with leading 0 to make it equal to the field length for
*&--field PEDIMENTO_SEQ
                CONCATENATE lx_e1edp01-posex
                            lc_zero_0
                            lc_pedi_0001
                       INTO lx_e1edp01_ext-posex.
                lx_e1edp01_ext-pedimento_nbr = x_pedi_i-pedimento_nbr.
                lx_e1edp01_ext-custdate      = x_pedi_i-custdate.
                lx_e1edp01_ext-custplace     = x_pedi_i-custplace.
                lx_e1edp01_ext-menge         = lc_quan_1.
*--Begin of changes for SCTASK0515243 by mthatha
*                lx_e1edp01_ext-menee         = lx_e1edp01-menee.
*--End changes for SCTASK0515243 by mthatha
                lx_edidd-segnam = lc_e1edp01_ext. " Item Extension segment name
                lx_edidd-sdata  = lx_e1edp01_ext.

                INSERT lx_edidd INTO int_edidd INDEX lv_index.
                UNASSIGN: <lfs_sernum>.
                CLEAR: lv_index,
                       x_pedi_i.
              ENDIF. " IF sy-subrc NE 0
            ENDIF. " IF sy-subrc EQ 0

*&--Check if Pedimento Outbound Delivery
            READ TABLE li_en_status ASSIGNING <lfs_status>
              WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                       criteria = lc_pedi_out
                        sel_low = xvbdkr-fkart
                     sel_option = if_cwd_constants=>c_option_equals.
            IF sy-subrc EQ 0.
*&--Fetch Pedimento data
              SELECT werks            " Plant
                     vbeln            " Delivery
                     posnr            " Delivery Item
                     pedimento_seq    " Pedimento Sequence Number
                     matnr            " Material Number
                     pedimento_nbr    " Pedimento Number
                     pedimento_qty    " Pedimento Quantity
                     pedimento_uom    " Base Unit of Measure
                     custplace        " Customs Place
                     custdate         " Customs Date
                FROM zlex_pedimento_o " Outbound Pedimento Table
                INTO TABLE i_pedi_o
               WHERE werks EQ lx_e1edp01-werks
                 AND vbeln EQ lv_vbeln
                 AND posnr EQ lv_posnr.
              IF sy-subrc NE 0.
*&--If no record is found read E1EDP01-POSEX from the main item and set
*&--POSEX = E1EDP01-POSEX concatenate with trailing 0 to make the
*&--number equal the field length of POSEX
                CONCATENATE lx_e1edp01-posex
                            lc_zero_0000
                       INTO lx_e1edp01_ext-posex.
*&--Quantity and Unit
                lx_e1edp01_ext-menge = lx_e1edp01-menge.
                CONDENSE lx_e1edp01_ext-menge.
*--Begin of changes for SCTASK0515243 by mthatha
*                lx_e1edp01_ext-menee      = lx_e1edp01-menee.
*--End of changes for SCTASK0515243 by mthatha
                lx_edidd-segnam           = lc_e1edp01_ext. " Item Extension segment name
                lx_edidd-sdata            = lx_e1edp01_ext.
                INSERT lx_edidd INTO int_edidd INDEX lv_index.
                CLEAR: lx_edidd.
              ELSE. " ELSE -> IF sy-subrc NE 0

                LOOP AT i_pedi_o ASSIGNING <lfs_pedi_o>.
*&--Read E1EDP01-POSEX concatenate it with ZLEX_PEDIMENTO_I–PEDIMENTO_SEQ
*&--prefixed with leading 0 to make it equal to the field length for
*&--field PEDIMENTO_SEQ
                  CONCATENATE lx_e1edp01-posex
* ---> Begin of Change for D2_OTC_IDD_0111_Defect 6430 – by MBAGDA
*                             lc_zero_0 "DELETE
* <--- End of Change for D2_OTC_IDD_0111_Defect 6430 by MBAGDA
                              <lfs_pedi_o>-pedimento_seq
                         INTO lx_e1edp01_ext-posex.
                  lx_e1edp01_ext-pedimento_nbr = <lfs_pedi_o>-pedimento_nbr.
                  lx_e1edp01_ext-custdate      = <lfs_pedi_o>-custdate.
                  lx_e1edp01_ext-custplace     = <lfs_pedi_o>-custplace.
                  lx_e1edp01_ext-menge         = <lfs_pedi_o>-pedimento_qty.
                  CONDENSE lx_e1edp01_ext-menge.
*--Begin of changes for SCTASK0515243 by mthatha
*                  lx_e1edp01_ext-menee         = <lfs_pedi_o>-pedimento_uom.
                  READ TABLE li_en_status ASSIGNING <lfs_status>
                    WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                             criteria = lc_menee
                              sel_low = <lfs_pedi_o>-pedimento_uom.
                  IF sy-subrc EQ 0.
                    lx_e1edp01_ext-menee = <lfs_status>-sel_high.
                  ENDIF. " IF sy-subrc EQ 0
*--End of changes for SCTASK0515243 by mthatha
                  lx_edidd-segnam = lc_e1edp01_ext. " Item Extension segment name
                  lx_edidd-sdata  = lx_e1edp01_ext.

                  INSERT lx_edidd INTO int_edidd INDEX lv_index.
                  lv_index = lv_index + 1.
                  CLEAR: lx_edidd,
                         lx_e1edp01_ext.
                ENDLOOP. " LOOP AT i_pedi_o ASSIGNING <lfs_pedi_o>
                UNASSIGN: <lfs_pedi_o>.
                CLEAR: lv_index.
                FREE: i_pedi_o.
              ENDIF. " IF sy-subrc NE 0
            ENDIF. " IF sy-subrc EQ 0

          ENDIF. " IF lx_e1edp02-qualf = lc_qualf_016

*----------------------------------------------------------------------*
* Segment E1EDP05 - IDoc: Document Item Conditions
*----------------------------------------------------------------------*
        WHEN lc_e1edp05.

          lx_e1edp05 = <lfs_edidd_o>-sdata.
*-------------------------------------*
* Qualifier: ZNET
*-------------------------------------*
          IF lx_e1edp05-kschl NE lc_kschl_znet.

*& ---> Begin of Insert for Defect# 5306 by VGAUR
*&--Sum up all ZNET conditions
            LOOP AT xikomv ASSIGNING <lfs_komv> WHERE kposn = gv_kposn
                                                  AND kschl = lc_kschl_znet.
              lv_kawrt = <lfs_komv>-kwert + lv_kawrt.
              lv_kbetr = <lfs_komv>-kbetr + lv_kbetr.
              lx_e1edp05-uprbs = <lfs_komv>-kpein + lx_e1edp05-uprbs.
              lx_e1edp05-meaun = <lfs_komv>-kmein.
              lx_e1edp05-koein = <lfs_komv>-waers.
            ENDLOOP. " LOOP AT xikomv ASSIGNING <lfs_komv> WHERE kposn = gv_kposn
            IF sy-subrc EQ 0.
              lx_e1edp05-alckz = lc_plus.
              lx_e1edp05-kschl = lc_kschl_znet.
              lx_e1edp05-betrg = lv_kawrt.
              IF gv_uepos IS NOT INITIAL.
                CLEAR: lx_e1edp05-betrg.
              ENDIF. " IF gv_uepos IS NOT INITIAL
              lx_e1edp05-krate = lv_kbetr.
              CLEAR: lx_e1edp05-mwskz,
                     lx_e1edp05-kobas.
              SHIFT lx_e1edp05-betrg LEFT DELETING LEADING space.
              SHIFT lx_e1edp05-krate LEFT DELETING LEADING space.
              SHIFT lx_e1edp05-uprbs LEFT DELETING LEADING space.

*&--Fetch Text
              SELECT vtext " Name
                FROM t685t " Conditions: Types: Texts
               UP TO 1 ROWS
                INTO lx_e1edp05-kotxt
               WHERE spras EQ sy-langu
                 AND kschl EQ lc_kschl_znet.
              ENDSELECT.
              lx_edidd-segnam = lc_e1edp05.
              lx_edidd-sdata = lx_e1edp05.
              APPEND lx_edidd TO int_edidd.

* <--- End of Insert for Defect# 5306 by VGAUR

              li_edidd_int[] = int_edidd[].
              DELETE li_edidd_int WHERE segnam NE lc_e1edp01.
              DESCRIBE TABLE li_edidd_int LINES lv_line_count.
*&--Read Invoice Line Item
              READ TABLE li_edidd_int ASSIGNING <lfs_edidd>
                                          INDEX lv_line_count.
              IF sy-subrc EQ 0.
                lx_e1edp01 = <lfs_edidd>-sdata.
              ENDIF. " IF sy-subrc EQ 0
              UNASSIGN: <lfs_edidd>.
              CLEAR: lv_line_count.
              FREE: li_edidd_int[].

*&--Populating Amount
*&--Using Where condition  in loop as parallel cursor cannot be applied
*&--because table cannot be sorted
              LOOP AT int_edidd ASSIGNING <lfs_edidd>
                                    WHERE segnam   EQ lc_e1edp01_ext
                                      AND sdata(6) EQ lx_e1edp01-posex.
                lx_e1edp01_ext = <lfs_edidd>-sdata.
*&--Move value from E1EDP05–BETRG where KSCHL = ZNET to ZE1EDP_EXT–BETRG.
                IF lx_e1edp01-uepos IS INITIAL.
                  IF lx_e1edp01_ext-pedimento_nbr IS INITIAL.
                    lv_betrg = lx_e1edp05-betrg.
                    lx_e1edp01_ext-betrg = lv_betrg.
*& ---> Begin of Insert for Defect# 6062 by VGAUR
                    lx_e1edp01_ext-unit_price = lx_e1edp05-krate.
                    CONDENSE lx_e1edp01_ext-unit_price.
*& <--- End of Insert for Defect# 6062 by VGAUR
                    CONDENSE lx_e1edp01_ext-betrg.
                    <lfs_edidd>-sdata = lx_e1edp01_ext.
                  ELSE. " ELSE -> IF lx_e1edp01_ext-pedimento_nbr IS INITIAL
*&--{(E1EDP05-BETRG for KSCHL = ZNET) / E1EDP01-MENGE} *ZE1EDP01_EXT - PEDIMENTO_NBR
                    lv_betrg = ( lx_e1edp05-betrg / lx_e1edp01-menge ) *
                                 lx_e1edp01_ext-menge.
                    lx_e1edp01_ext-betrg = lv_betrg.
*& ---> Begin of Insert for Defect# 6062 by VGAUR
                    lx_e1edp01_ext-unit_price = lx_e1edp05-krate.
                    CONDENSE lx_e1edp01_ext-unit_price.
*& <--- End of Insert for Defect# 6062 by VGAUR
                    CONDENSE lx_e1edp01_ext-betrg.
                    <lfs_edidd>-sdata = lx_e1edp01_ext.
                  ENDIF. " IF lx_e1edp01_ext-pedimento_nbr IS INITIAL
                ENDIF. " IF lx_e1edp01-uepos IS INITIAL
                CLEAR: lx_e1edp01_ext.
              ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>
              UNASSIGN: <lfs_edidd>.
            ENDIF. " IF sy-subrc EQ 0

          ELSE. " ELSE -> IF lx_e1edp05-kschl NE lc_kschl_znet

            li_edidd_int[] = int_edidd[].
            DELETE li_edidd_int WHERE segnam NE lc_e1edp01.
            DESCRIBE TABLE li_edidd_int LINES lv_line_count.
*&--Read Invoice Line Item
            READ TABLE li_edidd_int ASSIGNING <lfs_edidd>
                                        INDEX lv_line_count.
            IF sy-subrc EQ 0.
              lx_e1edp01 = <lfs_edidd>-sdata.
            ENDIF. " IF sy-subrc EQ 0
            UNASSIGN: <lfs_edidd>.
            CLEAR: lv_line_count.
            FREE: li_edidd_int[].

*&--Populating Amount
*&--Using Where condition  in loop as parallel cursor cannot be applied
*&--because table cannot be sorted
            LOOP AT int_edidd ASSIGNING <lfs_edidd>
                                  WHERE segnam   EQ lc_e1edp01_ext
                                    AND sdata(6) EQ lx_e1edp01-posex.
              lx_e1edp01_ext = <lfs_edidd>-sdata.
*&--Move value from E1EDP05–BETRG where KSCHL = ZNET to ZE1EDP_EXT–BETRG.
              IF lx_e1edp01-uepos IS INITIAL.
                IF lx_e1edp01_ext-pedimento_nbr IS INITIAL.
                  lv_betrg = lx_e1edp05-betrg.
                  lx_e1edp01_ext-betrg = lv_betrg.
                  CONDENSE lx_e1edp01_ext-betrg.
                  <lfs_edidd>-sdata = lx_e1edp01_ext.
                ELSE. " ELSE -> IF lx_e1edp01_ext-pedimento_nbr IS INITIAL
*&--{(E1EDP05-BETRG for KSCHL = ZNET) / E1EDP01-MENGE} *ZE1EDP01_EXT - PEDIMENTO_NBR
                  lv_betrg = ( lx_e1edp05-betrg / lx_e1edp01-menge ) *
                               lx_e1edp01_ext-menge.
                  lx_e1edp01_ext-betrg = lv_betrg.
                  CONDENSE lx_e1edp01_ext-betrg.
                  <lfs_edidd>-sdata = lx_e1edp01_ext.
                ENDIF. " IF lx_e1edp01_ext-pedimento_nbr IS INITIAL
              ENDIF. " IF lx_e1edp01-uepos IS INITIAL
              CLEAR: lx_e1edp01_ext.
            ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>
            UNASSIGN: <lfs_edidd>.
          ENDIF. " IF lx_e1edp05-kschl NE lc_kschl_znet
          CLEAR: lx_e1edp05.

*& ---> Begin of Insert for Defect# 5261 by VGAUR
        WHEN lc_e1edp19.
*&--Insert Serial number segment into the IDOC
          lx_e1edp19 = <lfs_edidd_o>-sdata.
          IF gv_posnr IS NOT INITIAL.

*&--Populate Serial Numbers
            READ TABLE xtvbdpr ASSIGNING <lfs_vbdpr>
                                WITH KEY posnr = gv_posnr.
            IF sy-subrc EQ 0.
*&--Get all Serial Numbers
              LOOP AT i_serial ASSIGNING <lfs_serial>
                                    WHERE lief_nr EQ <lfs_vbdpr>-vgbel
                                      AND posnr   EQ <lfs_vbdpr>-vgpos.

                li_object[] = i_object[].
                DELETE li_object WHERE obknr NE <lfs_serial>-obknr.

*&--Populate all Serial Numbers for current Item
                LOOP AT li_object ASSIGNING <lfs_object>.
                  APPEND INITIAL LINE TO li_sernum ASSIGNING <lfs_sernum>.
                  IF <lfs_sernum> IS ASSIGNED.
                    <lfs_sernum>-sernum = <lfs_object>-sernr.
                    UNASSIGN: <lfs_sernum>.
                  ENDIF. " IF <lfs_sernum> IS ASSIGNED
                ENDLOOP. " LOOP AT li_object ASSIGNING <lfs_object>
              ENDLOOP. " LOOP AT i_serial ASSIGNING <lfs_serial>
            ENDIF. " IF sy-subrc EQ 0

*& ---> Begin of Insert for Defect# 5442 by VGAUR

*&--Populate Batch
            LOOP AT int_edidd ASSIGNING <lfs_edidd>
                                   WHERE segnam   EQ lc_e1edp01_ext
                                     AND sdata(6) EQ gv_posnr.
              IF lx_e1edp19-qualf = lc_qualf_010.
                lx_e1edp01_ext       = <lfs_edidd>-sdata.
                lx_e1edp01_ext-batch = lx_e1edp19-idtnr.
                <lfs_edidd>-sdata = lx_e1edp01_ext.
              ENDIF. " IF lx_e1edp19-qualf = lc_qualf_010
            ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>
            UNASSIGN: <lfs_edidd>.

*& ---> End of Insert for Defect# 5442 by VGAUR

            LOOP AT int_edidd ASSIGNING <lfs_edidd>
                                  WHERE segnam   EQ lc_e1edp01_ext
                                    AND sdata(6) EQ gv_posnr.

              li_edidd_int[] = int_edidd[].

              lx_e1edp01_ext = <lfs_edidd>-sdata.
              lv_index = sy-tabix + 1.
              IF lx_e1edp01_ext-sernum IS INITIAL.
                lv_line_count = lx_e1edp01_ext-menge.

*& ---> Begin of Insert for Defect# 5442 by VGAUR
*&--Get only Idoc segment for custom segment of current Item
                DELETE li_edidd_int WHERE segnam        NE lc_e1edp01_ext.
                DELETE li_edidd_int WHERE sdata(6)      NE gv_posnr.
                DELETE li_edidd_int WHERE sdata+114(15) NE lx_e1edp01_ext-pedimento_nbr.
*& ---> End of Insert for Defect# 5442 by VGAUR
                DESCRIBE TABLE li_edidd_int LINES lv_div.
                IF lv_div = 1.
                  lv_div = lv_line_count.
                ENDIF. " IF lv_div = 1

                DO lv_line_count TIMES.
                  READ TABLE li_sernum ASSIGNING <lfs_sernum>
                                           INDEX 1.
                  IF sy-subrc EQ 0.
                    lv_mod = lv_mod + 1.
                    IF lv_mod = 1.
                      lv_menge = lx_e1edp01_ext-menge.
                      lv_menge = lv_menge / lv_div.
                      lx_e1edp01_ext-menge = lv_menge.
                      CONDENSE lx_e1edp01_ext-menge.
                      lv_betrg = lx_e1edp01_ext-betrg.
                      lv_betrg = lv_betrg / lv_div.
                      lx_e1edp01_ext-betrg = lv_betrg.
                      CONDENSE lx_e1edp01_ext-betrg.
*& ---> Begin of Comment for Defect# 5442 by VGAUR
*                      lx_e1edp05-idtnr = <lfs_sernum>-sernum.
*& <--- End of Comment for Defect# 5442 by VGAUR
*& ---> Begin of Insert for Defect# 5442 by VGAUR
                      lx_e1edp01_ext-sernum = <lfs_sernum>-sernum.
                      SHIFT lx_e1edp01_ext-sernum LEFT DELETING LEADING '0'.
*& <--- End of Insert for Defect# 5442 by VGAUR
                      <lfs_edidd>-sdata = lx_e1edp01_ext.

                      DELETE li_sernum INDEX 1.
                    ELSE. " ELSE -> IF lv_mod = 1
*& ---> Begin of Comment for Defect# 5442 by VGAUR
*                      lx_e1edp05-idtnr = <lfs_sernum>-sernum.
*& <--- End of Comment for Defect# 5442 by VGAUR
*& ---> Begin of Insert for Defect# 5442 by VGAUR
                      lx_e1edp01_ext-sernum = <lfs_sernum>-sernum.
                      SHIFT lx_e1edp01_ext-sernum LEFT DELETING LEADING '0'.
*& <--- End of Insert for Defect# 5442 by VGAUR
                      CLEAR: lx_e1edp01_ext-custdate,
                             lx_e1edp01_ext-custplace.
*& ---> Begin of Comment for Defect# 5442 by VGAUR
*                      lx_edidd-segnam = lc_e1edp05.
*& <--- End of Comment for Defect# 5442 by VGAUR
*& ---> Begin of Insert for Defect# 5442 by VGAUR
                      lx_edidd-segnam = lc_e1edp01_ext.
*& <--- End of Insert for Defect# 5442 by VGAUR
                      lx_edidd-sdata  = lx_e1edp01_ext.
                      INSERT lx_edidd INTO int_edidd INDEX lv_index.
                      DELETE li_sernum INDEX 1.
                      lv_index = lv_index + 1.
                    ENDIF. " IF lv_mod = 1
                  ENDIF. " IF sy-subrc EQ 0
                ENDDO.
                CLEAR: lv_div,
                       lv_mod.
              ENDIF. " IF lx_e1edp01_ext-sernum IS INITIAL
            ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>

          ENDIF. " IF gv_posnr IS NOT INITIAL

          CLEAR: gv_posnr,
                 lv_index,
                 lx_edidd,
                 lx_e1edp19.

*& <--- End of Insert for Defect# 5261 by VGAUR

          lx_e1edp19 = <lfs_edidd_o>-sdata.
*&--Get Material Number
          IF lx_e1edp19-qualf = lc_qualf_02.
            gv_matnr = lx_e1edp19-idtnr.
          ENDIF. " IF lx_e1edp19-qualf = lc_qualf_02
*&--Get Batch
          IF lx_e1edp19-qualf = lc_qualf_010.
            gv_batch = lx_e1edp19-idtnr.
          ENDIF. " IF lx_e1edp19-qualf = lc_qualf_010

          IF gv_matnr IS NOT INITIAL AND
             gv_batch IS NOT INITIAL AND
             gv_plant IS NOT INITIAL.

*&--Get Batch Details
            CALL FUNCTION 'BAPI_BATCH_GET_DETAIL'
              EXPORTING
                material        = gv_matnr
                batch           = gv_batch
                plant           = gv_plant
              IMPORTING
                batchattributes = lx_bapibatchatt.

            lv_datum = lx_bapibatchatt-expirydate.

            IF lv_datum IS NOT INITIAL.
*&--Convert Time to Mexico Time
              IF lv_sign EQ /spe/if_const=>c_minus.
                lv_hours = lv_hours     * -1.
                lv_minutes = lv_minutes * -1.
              ENDIF. " IF lv_sign EQ /spe/if_const=>c_minus

*&--Calculate Total Seconds
              lv_hours   = lv_hours * wgrc_cons=>gc_mph * wgrc_cons=>gc_mph.
              lv_minutes = lv_minutes * wgrc_cons=>gc_mph.
              lv_seconds = lv_hours + lv_minutes.

*&--As 86400 sec = 60 * 60 * 24 = 1 Day
              lv_div = lv_seconds DIV cl_epm_bo=>gc_secsaday. " 60
              lv_mod = lv_seconds MOD cl_epm_bo=>gc_secsaday. " 60

              lv_mx_time = sy-uzeit.
              lv_mx_date = lv_datum.
              lv_mx_time = lv_mx_time + lv_mod.
              IF lv_mx_time < sy-uzeit.
*&--Date One day to Date
                lv_mx_date = lv_mx_date + 1.
              ENDIF. " IF lv_mx_time < sy-uzeit

*&--Date days to Date
              lv_mx_date = lv_mx_date + lv_div.
            ENDIF. " IF lv_datum IS NOT INITIAL

*&--Date and Time Stamp of Emission
            lx_e1edp03-iddat = lc_qualf_z01.
            lx_e1edp03-datum = lv_mx_date.

            lx_edidd-segnam = lc_e1edp03.
            lx_edidd-sdata  = lx_e1edp03.
*&--Get place to insert Z01 qualifier for E1EDP19
            LOOP AT int_edidd ASSIGNING <lfs_edidd>
                                 WHERE segnam EQ lc_e1edp03.
              lv_index = sy-tabix.
            ENDLOOP. " LOOP AT int_edidd ASSIGNING <lfs_edidd>
            UNASSIGN: <lfs_edidd>.

            lv_index = lv_index + 1.
            INSERT lx_edidd INTO int_edidd INDEX lv_index.

            CLEAR: gv_matnr,
                   gv_plant,
                   gv_batch,
                   lx_e1edp03,
                   lx_edidd.

          ENDIF. " IF gv_matnr IS NOT INITIAL AND

*----------------------------------------------------------------------*
* Segment E1EDPT1 - IDoc: Document Item Text Identification
*----------------------------------------------------------------------*
        WHEN lc_e1edpt2.

          li_edidd_int[] = int_edidd[].

          READ TABLE li_edidd_int WITH KEY segnam = lc_e1edp01
                                           sdata(6) = gv_kposn
                                    TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
            lv_line_count = sy-tabix.
          ENDIF. " IF sy-subrc EQ 0

          LOOP AT li_edidd_int ASSIGNING <lfs_edidd>
                                    FROM lv_line_count
                                   WHERE segnam EQ lc_e1edpt1.
            IF <lfs_edidd>-sdata(4) EQ lc_tdid_z011.
              CLEAR lv_mod.
            ELSE. " ELSE -> IF <lfs_edidd>-sdata(4) EQ lc_tdid_z011
              lv_mod = 1.
            ENDIF. " IF <lfs_edidd>-sdata(4) EQ lc_tdid_z011
          ENDLOOP. " LOOP AT li_edidd_int ASSIGNING <lfs_edidd>

          IF lv_mod IS INITIAL.
            LOOP AT int_edidd TRANSPORTING NO FIELDS
                               FROM lv_line_count
                              WHERE segnam = lc_e1edpt2_ext.
              lv_index = sy-tabix.
            ENDLOOP. " LOOP AT int_edidd TRANSPORTING NO FIELDS
            IF sy-subrc NE 0.
              READ TABLE int_edidd ASSIGNING <lfs_edidd>
                                    WITH KEY segnam   = lc_e1edp01_ext
                                             sdata(6) = gv_kposn.
              IF sy-subrc EQ 0.
                lv_index = sy-tabix.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc NE 0

            lv_index = lv_index + 1.

            lx_e1edpt2_ext-tdline = <lfs_edidd_o>-sdata.
            lx_edidd-segnam       = lc_e1edpt2_ext.
            lx_edidd-sdata        = lx_e1edpt2_ext.

            INSERT lx_edidd INTO int_edidd INDEX lv_index.
            CLEAR: lx_e1edpt2_ext.

          ENDIF. " IF lv_mod IS INITIAL

*----------------------------------------------------------------------*
* Segment E1EDS01 - IDoc: Summary segment general
*----------------------------------------------------------------------*
        WHEN lc_e1eds01.

          lx_e1eds01 = <lfs_edidd_o>-sdata.

*& ---> Begin of Insert for Defect# 5297 by VGAUR

*&--In segment  Z1RTR_E1EDK01_EXT  - AMOUNT_IN_WORDS, the wording needs
*&--to be spelled out for the total amount populated in E1EDS01
*&--Qual=011 - SUMME segment
          IF lx_e1eds01-sumid = lc_qualf_011.
*& <--- End of Insert for Defect# 5297 by VGAUR
            READ TABLE int_edidd ASSIGNING <lfs_edidd>
                                  WITH KEY segnam = lc_e1edk01_ext.
            IF sy-subrc EQ 0.
              lx_e1edk01_ext = <lfs_edidd>-sdata.
*&--Total Amount In Words
              lv_tot_bill = lx_e1eds01-summe.
              lv_curr     = lx_e1eds01-waerq.

              SPLIT lv_tot_bill
                 AT cl_cme_dtype_const=>dot
               INTO lv_tot_bill
                    lv_dec.

              SHIFT lv_tot_bill LEFT DELETING LEADING space.
              lv_total = lv_tot_bill.

*&--Get Language
              READ TABLE li_en_status ASSIGNING <lfs_status>
                WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
                         criteria = lc_langu
                       sel_option = if_cwd_constants=>c_option_equals.
              IF sy-subrc EQ 0.
                lv_langu = <lfs_status>-sel_low.
                UNASSIGN: <lfs_status>.
              ENDIF. " IF sy-subrc EQ 0

*&--Amount in Text
              CALL FUNCTION 'SPELL_AMOUNT'
                EXPORTING
                  amount    = lv_total
                  currency  = lv_curr
                  language  = lv_langu
                IMPORTING
                  in_words  = lx_spell
                EXCEPTIONS
                  not_found = 1
                  too_large = 2
                  OTHERS    = 3.
              IF sy-subrc EQ 0.

**&--Fetch Currency Text
                READ TABLE li_en_status ASSIGNING <lfs_en_status>
                   WITH KEY sel_sign   = if_cwd_constants=>c_sign_inclusive
                            criteria   = lc_curr_text
                            sel_option = if_cwd_constants=>c_option_equals
                            sel_low    = lv_curr.
                IF sy-subrc IS INITIAL.
                  CONCATENATE lx_spell-word
                              <lfs_en_status>-sel_high
                         INTO lx_e1edk01_ext-amount_in_words
                 SEPARATED BY space.
                ENDIF. " IF sy-subrc IS INITIAL

*----->&--Begin of Delete for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
* Defect #540
* If value is zero than also print amount in words
*                IF lv_dec NE 00.
*----->&--End of Delete for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
*&--Prepare Decimals
                CONCATENATE lv_dec
                            /plmb/if_ppe_bom_c=>gc_slash
                            lc_hundred
                       INTO lv_dec.
*&--Total Bill Amount
                CONCATENATE lx_e1edk01_ext-amount_in_words
                            lv_dec
                       INTO lx_e1edk01_ext-amount_in_words
               SEPARATED BY space.
*----->&--Begin of Delete for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
* Defect #540
*                ENDIF. " IF lv_dec NE 00
**----->&--End of Delete for D2_OTC_IDD_0111 Defect#540 #468 PGL-B by MGARG
              ENDIF. " IF sy-subrc EQ 0

*& ---> Begin of Insert for Defect# 5297 by VGAUR
              TRY .
                CALL METHOD zdev_cl_convert_firstchar_toup=>meth_inst_pub_firstchar_upper
                  EXPORTING
                    im_input_string  = lx_e1edk01_ext-amount_in_words
                  IMPORTING
                    ex_output_string = lx_e1edk01_ext-amount_in_words.
              ENDTRY.
*& <--- End of Insert for Defect# 5297 by VGAUR

*&--Move data to IDOC Segment
              <lfs_edidd>-segnam = lc_e1edk01_ext.
              <lfs_edidd>-sdata  = lx_e1edk01_ext.
              UNASSIGN: <lfs_edidd>.
              CLEAR: lx_e1edk01_ext.
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF lx_e1eds01-sumid = lc_qualf_011

*--> Begin of Insert for Defect#8526 by SAGARWA1
*&*-- Change is written into this section because E1EDP01 will call
*     everytime irrespective any condition.
**** No need to put binary search as number of records in INT_EDIDD
**** will be less than 100.

          IF lx_e1eds01-sumid = lc_qualf_005.
            CLEAR : lx_edidd.
            READ TABLE int_edidd ASSIGNING <lfs_edidd_temp> WITH KEY segnam = lc_e1edk04.
            IF sy-subrc NE 0.
              READ TABLE int_edidd TRANSPORTING NO FIELDS WITH KEY segnam = lc_e1edk17.
              IF sy-subrc = 0.

                lv_index1        = sy-tabix.
                lx_edidd-segnam  = lc_e1edk04.
                lx_e1edk04-mwsbt = lx_e1eds01-summe. " Tax Amount
* No need for Binary search as it will contain less than 100 records
                READ TABLE xikomv ASSIGNING <lfs_komv> WITH KEY  kposn = lc_kposn_10
                                                                 kschl = lc_kschl_mwst.
                IF sy-subrc = 0.
                  lx_e1edk04-mwskz = <lfs_komv>-mwsk1. " Tax code
                  CLEAR : lv_kbetr.
                  IF <lfs_komv>-krech = lc_krech_a " The condition rate is in percentage
                    AND <lfs_komv>-kbetr NE 0.
* Divide the value by 10 so that the condition rate will be a specific value
                    lv_kbetr  = <lfs_komv>-kbetr / lc_per_10. " Tax Rate
                  ELSE. " ELSE -> IF <lfs_komv>-krech = lc_krech_a
                    lv_kbetr = <lfs_komv>-kbetr. " Tax Rate
                  ENDIF. " IF <lfs_komv>-krech = lc_krech_a
                  lx_e1edk04-msatz = lv_kbetr.
                  CONDENSE lx_e1edk04-msatz.

                ENDIF. " IF sy-subrc = 0
                UNASSIGN <lfs_komv>.

                lx_edidd-sdata  = lx_e1edk04.

                INSERT lx_edidd INTO int_edidd INDEX lv_index1.
                CLEAR : lx_edidd,
                        lx_e1edk04,
                        lv_index1.
              ENDIF. " IF sy-subrc = 0
            ELSE. " ELSE -> IF sy-subrc NE 0
              lx_e1edk04 = <lfs_edidd_temp>-sdata.
              IF  lx_e1edk04-mwsbt IS INITIAL
              AND lx_e1edk04-msatz IS INITIAL.
                lx_e1edk04-mwsbt = lx_e1eds01-summe. " Tax Amount
* No need for Binary search as it will contain less than 100 records
                READ TABLE xikomv ASSIGNING <lfs_komv> WITH KEY  kposn = lc_kposn_10
                                                                 kschl = lc_kschl_mwst.
                IF sy-subrc = 0.
                  CLEAR : lv_kbetr.
                  lx_e1edk04-mwskz = <lfs_komv>-mwsk1. " Tax code
                  IF <lfs_komv>-krech = lc_krech_a " The condition rate is in percentage
                  AND <lfs_komv>-kbetr NE 0.
* Divide the value by 10 so that the condition rate will be a specific value
                    lv_kbetr  = <lfs_komv>-kbetr / lc_per_10. " Tax Rate
                  ELSE. " ELSE -> IF <lfs_komv>-krech = lc_krech_a
                    lv_kbetr = <lfs_komv>-kbetr. " Tax Rate
                  ENDIF. " IF <lfs_komv>-krech = lc_krech_a
                  lx_e1edk04-msatz = lv_kbetr.
                  CONDENSE lx_e1edk04-msatz.

                ENDIF. " IF sy-subrc = 0
                <lfs_edidd_temp>-sdata = lx_e1edk04.
                UNASSIGN: <lfs_komv>, <lfs_edidd_temp>.
                CLEAR : lx_edidd,
                        lx_e1edk04.

              ENDIF. " IF lx_e1edk04-mwsbt IS INITIAL
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF lx_e1eds01-sumid = lc_qualf_005
*<-- End  of Insert for Defect#8526 by SAGARWA1

      ENDCASE.
      UNASSIGN: <lfs_edidd_o>.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF sy-subrc EQ 0

FREE: li_en_status[].
