class ZCL_IM_CL_IM_INV_ECC_2_GTS definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_CL_IM_INV_ECC_2_GTS
*"* do not include other source files here!!!

  interfaces /SAPSLL/IF_EX_IFEX_SD0C_R3 .
protected section.
*"* protected components of class ZCL_IM_CL_IM_INV_ECC_2_GTS
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_CL_IM_INV_ECC_2_GTS
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_CL_IM_INV_ECC_2_GTS IMPLEMENTATION.


METHOD /sapsll/if_ex_ifex_sd0c_r3~if_extend_cus_cdoc.
*"----------------------------------------------------------------------
* IS_VBRK Importing Type  VBRK                         Bil.Doc.Head
* IT_VBRP Importing Type  /SAPSLL/VBRPVB_R3_T          Billing Doc. Item
* IT_VBPA  Importing Type  VBPAVB_TAB                  Partner
* IS_EIKP  Importing Type  EIKP                        Foreign Trade Header
* IT_EIPO  Importing Type  /SAPSLL/EIPO_R3_T           Foreign trade item
* IT_KOMV  Importing Type  /SAPSLL/KOMV_R3_T           Table Type for Structure KOMV
* CT_EXTENSION1  Changing  Type  /SAPSLL/BAPIEXTC_R3_T Data Container (Unstructured)
* CT_EXTENSION2  Changing  Type  /SAPSLL/BAPIEXT_R3_T  Data Container (Structured)
* CS_HDR_CDOC  Changing  Type  SLLR3_API6800_HEADER_S  Header Transfer Structure for Customs Document
* CS_ITM_CDOC  Changing  Type  SLLR3_API6800_ITEM_S    Item Transfer Structure for Customs Document
*"----------------------------------------------------------------------

************************************************************************
* BADI Definition        : /SAPSLL/IFEX_SD0C_R3                        *
* BADI Implementation    : ZCL_IM_INV_ECC_2_GTS                        *
* Title                  : Populate Commercial Invoice fields from ECC *
*                          to GTS                                      *
* Developer              : Santosh Vinapamula                          *
* Object Type            : BADI Enhancement                            *
* SAP Release            : SAP ECC 6.0                                 *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0013                                             *
*----------------------------------------------------------------------*
* Description:                                                         *
* As part of Bio-Rad export process, commercial invoice has to be      *
* populated with some fields from ECC. These values are not part of    *
* standard ECC-GTS plug-in used for trnasferring pro-forma invoices    *
* from ECC to GTS.                                                     *
* This enhancement has to check for Batch in Billing document table    *
* and read batch expiry date and country of origin. If a batch is not  *
* populated in Billing document item, then the target field has to be  *
* populated with the serial number. Expiry date and country of origin  *
* should be populated from equipment number table                      *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User     Transport  Description                          *
* =========== ======== ========== =====================================*
* 16-Feb-2012 SVINAPA  E1DK900376 Initial development                  *
* 16-May-2012 SVINAPA  E1DK900376 CR#12. Send PO# to GTS               *
* 11-Jun-2012 SVINAPA  E1DK900376 CR#40 - Move ISO country code to GTS *
* 17-Jul-2012 RBASU1   E1DK900376 CR#47 - Move conditions to GTS       *
* 13-Jun-2014 ASK      E2DK901400 D2_OTC_EDD_0013 - Remove hardcoding  *
*                                                   and instead use    *
*                                               ZOTC_PRC_CONTROL table *
* 22-Aug-2014 SPAUL2   E2DK901400 D2_OTC_EDD_0013 - CR D2_71 change:   *
*                                 Addition logic for condition value   *
*                                 for condition type ZHDL,ZNDG,ZTFR    *
*                                 and ZINS.If PO no is not populate    *
*                                 from Proforma Invoice line item level*
*                                 VBKD-BSTKD, pick up the PO reference *
*                                 details value from Proforma Invoice  *
*                                 line item level VBRP-AUBEL.          *
* 11-Sep-2014 RVERMA   ECSK900007 CR#1418: Transmitting Ultimate       *
*                    (E1DK915226) Consignee Type value from Attribute 3*
*                                 field from customer master in ECC to *
*                                 Export Declaration document in GTS.  *
*&---------------------------------------------------------------------*
* 08-Oct-14  SMUKHER   E1DK915226 CR#1418:Included the TVARVC entries  *
*                     (E2DK901400)        in Customizing TR            *
*                  and E1DK915228                                      *
*                     (E2DK907695)                                     *
*&---------------------------------------------------------------------*
* 18-Mar-15  PMISHRA   E2DK901400 D2_OTC_EDD_0013_Defect 4607 Use 'ZBS'*
*                                 document category instead of 'CINV'  *
*                                 for batch and serial number.         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 10-July-15  PMISHRA  E2DK913883  D2_OTC_EDD_0013_Defect 8301 Remove  *
*                                  leading zeros '0' from batch and    *
*                                  serial number.                      *
*&---------------------------------------------------------------------*
* 29-Oct-15  SAGARWA1 / E2DK915307 D2_OTC_EDD_0013_Defect 1017 Get the *
*            PDEBARU               COO from the equipement master and  *
*                                  populate the value at line item in  *
*                                  field Supplement of Custom Declarat-*
*                                  -ion Document.                      *
*&---------------------------------------------------------------------*
* 18-May-16  AMANGAL   E1DK919194 D3_OTC_EDD_0013. Populate Commercial*
*                                  Invoice fields from ECC to GTS      *
*&---------------------------------------------------------------------*
* 6-Apr-17  U033876   E1DK926734 Defect:2438 incident: INC0328008      *
*                                 when Proforma Invoice fields from ECC*
*                                 to GTS, need to append values instead*
*                                 of modifying the content @ line 411  *
* 14-Apr-17 U033867  E1DK927120   Defect:2548 incident: INC0330636     *
*                                 Whenever batch/serial number is being*
*                                 transferred from ECC to GTS - leading*
*                                 zeros are being  eliminated The      *
*                                 enhancement triggered during Invoice *
*                                 transfer from ECC to GTS.fix to be   *
*                                 leading zeros for batch and serial nu*
*                                 to be transferred to GTS.            *
*&---------------------------------------------------------------------*
* 17-May-17  U033876 E1DK928011   Defect:2799 incident: INC0337386     *
*                                 company code currency conversion to  *
*                                 applied only if SHIP_FROM_CTRY = US  *
*                                 or MX or CA otherwise skip the logic *
*                                 to allow transfer GRWR               *
*&---------------------------------------------------------------------*
* 02-Aug-18 SMUKHER E1DK938145    Defect# 6695: Pass the Date of Manuf *
*                                 -acture(MCHA-HSDAT)for a Batch to the*
*                                 field 'Document Date' (PAPDT) in GTS *
*&---------------------------------------------------------------------*
* 28-Aug-18 U033876 E1DK938145    SCTASK0660730: Changes for HU level CI*
*                                 OTC_EDD_0415, Concatenate DELIV+INVOI*
*                                 into ref field                       *
*&---------------------------------------------------------------------*
* 19-Dec-18 U033876 E1DK938145    SCTASK0660730: Defect 7986 Changes for *
*                                 adding netwr of BOM components into  *
*                                 BOm Header                           *
* 04-Feb-19 U033876 E1DK940402    Post golive- Defect 8286 Changes for *
*                                 Serial no and Packaging info error   *
*----------------------------------------------------------------------*
* 16/09/2019  U106341                 HANAtization changes
*----------------------------------------------------------------------*
************************************************************************
*     D A T A   D E C L A R A T I O N S                                *
************************************************************************

* Types decarations
  TYPES: BEGIN OF ty_serial,
          obknr      TYPE objknr,   " Object list number
          lief_nr    TYPE vbeln_vl, " Delivery
          posnr      TYPE posnr_vl, " Delivery item
          anzsn      TYPE anzsn,    " Number of serial numbers
         END OF ty_serial.

  TYPES: BEGIN OF ty_object,
           obknr      TYPE objknr, " Object list number
           obzae      TYPE objza,  " Object list counters
           matnr      TYPE matnr,  " Material number
           sernr      TYPE gernr,  " Serial number
         END OF ty_object.

* CR#12
  TYPES: BEGIN OF ty_po,
           vbeln      TYPE vbeln, " Sales Document number
           posnr      TYPE posnr, " Item number
           bstkd      TYPE bstkd, " Customer PO #
         END OF ty_po.

  DATA: i_po  TYPE STANDARD TABLE OF ty_po.
  FIELD-SYMBOLS: <lfs_po> TYPE ty_po.
* CR#12

* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
  TYPES :   BEGIN OF lty_kschl,
             mparameter TYPE enhee_parameter,         " Parameter
             mvalue1    TYPE z_mvalue_low,            " KSCHL Value
            END OF lty_kschl,

        lty_t_kschl TYPE STANDARD TABLE OF lty_kschl. " Table type for KSCHL Value

  DATA: li_kschl  TYPE lty_t_kschl,    " Int Table for OTC control table for Condition type
        lr_kschl  TYPE RANGE OF kschl, " Range table for all the Condition type from control table
        lr_kschl1 TYPE RANGE OF kschl, " Range table for Condition type ZEND from control table
        lr_kschl2 TYPE RANGE OF kschl, " Range table for Condition type ZA06 from control table
        lr_kschl3 TYPE RANGE OF kschl, " Range table for Condition type GRWR from control table
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
        lr_kschl4 TYPE RANGE OF kschl, " Range table for Condition type ZHDL,ZNDG,ZTFR and ZINS from control table
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
        lwa_kschl LIKE LINE  OF lr_kschl. " WA for range table of Condition type

* Local field sumbols
  FIELD-SYMBOLS: <lfs_kschl>   TYPE lty_kschl. " OTC control table for Condition type

  CONSTANTS: lc_program        TYPE programm        VALUE 'ZCL_IM_INV_ECC_2_GTS', " ABAP Program Name
             lc_kschl1         TYPE enhee_parameter VALUE 'KSCHL1',               " Value 'KSCHL1' indicating condn typ ZEND
             lc_kschl2         TYPE enhee_parameter VALUE 'KSCHL2',               " Value 'KSCHL2' indicating condn typ ZA06
             lc_kschl3         TYPE enhee_parameter VALUE 'KSCHL3',               " Value 'KSCHL3' indicating condn typ GRWR
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
             lc_kschl4         TYPE enhee_parameter  VALUE 'KSCHL4', " Value 'KSCHL4' indicating condn typ ZHDL,ZNDG,ZTFR and ZINS
             lc_doc_cat        TYPE /sapsll/docat_r3 VALUE 'ZZZ',    " Document type
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
* <--- Begin of Change Insert for D2_OTC_EDD_0013 by ASK
             lc_option_eq      TYPE rmsae_option     VALUE 'EQ', " Selection Option value 'EQ'
             lc_sign_i         TYPE sign             VALUE 'I',  " Debit/Credit Sign (+/-) value 'I'
* <--- End of Change Insert for D2_OTC_EDD_0013 by ASK
* ---> Begin of Change for D2_OTC_EDD_0013_Defect_4607 by PMISHRA
             lc_docat_zbs      TYPE /sapsll/docat_r3 VALUE 'ZBS'. " Category of Document
* <--- End of Change for D2_OTC_EDD_0013_Defect_4607 by PMISHRA

* Work area declarations
  DATA:
    wa_mcha       TYPE mcha,                         " Batches
    wa_itm_doc    TYPE /sapsll/api6800_itm_doc_r3_s, " Verification Document Item
    wa_itm_gen    TYPE /sapsll/api6800_itm_r3_s,     " SLL: API Comm. Structure: Customs Document: Item
    wa_konv       TYPE komv,                         " Pricing Communications-Condition Record
    wa_konv_val   TYPE /sapsll/api6800_itm_cvl_r3_s. " API Item Structure: Value for Customs Duty Calculation

* Interal table declarations
  DATA:
    i_serial        TYPE STANDARD TABLE OF ty_serial,
    i_object        TYPE STANDARD TABLE OF ty_object.

* Structure declaration
  DATA:
    x_object_rec  TYPE itob. " Generated Table for View

* Field symbol declaration
  FIELD-SYMBOLS:
    <lfs_vbrp>            TYPE vbrpvb, " Reference Structure for XVBRP/YVBRP
    <lfs_cs_itm_cdoc_doc> TYPE /sapsll/api6800_itm_doc_r3_t,
    <lfs_cs_itm_cdoc_gen> TYPE sllr3_api6800_itm_r3_t,
    <lfs_serial>          TYPE ty_serial,
    <lfs_object>          TYPE ty_object,
    <lfs_cs_konv_val>     TYPE /sapsll/api6800_itm_cvl_r3_t,
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
    <lfs_itm_doc>         TYPE /sapsll/api6800_itm_doc_r3_s. " Verification Document Item
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2

*----> Begin of change for defect 2799- E1DK928011 by u033876
  FIELD-SYMBOLS: <lfs_konv_zend> TYPE /sapsll/api6800_itm_cvl_r3_s, " API Item Structure: Value for Customs Duty Calculation
                 <lfs_konv_za06> TYPE /sapsll/api6800_itm_cvl_r3_s, " API Item Structure: Value for Customs Duty Calculation
                 <lfs_konv_grwr> TYPE /sapsll/api6800_itm_cvl_r3_s. " API Item Structure: Value for Customs Duty Calculation

* <----End of change for defect 2799- E1DK928011 by u033876
* Global variables
  DATA:
    gv_herkl      TYPE herkl, " Country of origin
    gv_itm_nr(10) TYPE n,     "/sapsll/itvsy_r3.  " Item number
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
    gv_flag_batch  TYPE c, " Flag for batch
    gv_flag_serial TYPE c. " Flag for serial no
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2

* CR#40 - Move ISO country code to GTS
  DATA:
    gv_im_land1   TYPE land1, " COO - Import parameter
    gv_ex_intca   TYPE intca, " COO - Export parameter
* CR#40
* CR#47
    gv_waers      TYPE waers. " Currency Key
* CR#47

* ---> Begin of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA
  DATA:
     lv_charg TYPE charg_d, " Batch Number
     lv_sernr TYPE gernr.   " Serial Number
  FIELD-SYMBOLS:
              <lfs_s_itm_gen> TYPE /sapsll/api6800_itm_r3_s. " SLL: API Comm. Structure: Customs Document: Item
* <--- End of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA

* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
  TYPES : BEGIN OF lty_marc,
            matnr TYPE matnr,   " Material Number
            werks TYPE werks_d, " Plant
            herkl TYPE herkl,   " Country of Origin of the Material
          END OF lty_marc.
  DATA : li_marc TYPE STANDARD TABLE OF lty_marc INITIAL SIZE 0,
         li_vbrp TYPE /sapsll/vbrpvb_r3_t,
         lwa_extension1 TYPE bapiextc. " Container for 'Customer Exit' Parameter

  CONSTANTS : lc_papad TYPE char5 VALUE 'PAPAD', " Papad of type CHAR5
              lc_zbs   TYPE char3 VALUE 'ZBS'.   " Zbs of type CHAR3

  FIELD-SYMBOLS : <lfs_marc> TYPE lty_marc.
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU

*&-- Begin of insert for D3_OTC_EDD_0013 Defect# 6695 by SMUKHER on 02-Aug-2018
  CONSTANTS: lc_papdt TYPE char5 VALUE 'PAPDT'. " date of manufacture
*&-- End of insert for D3_OTC_EDD_0013 Defect# 6695 by SMUKHER on 02-Aug-2018


**Begin of D3 changes - E1DK919194, AMANGAL
  CONSTANTS: lc_langu TYPE spras VALUE 'E',      " Language Key
             lc_langu_iso TYPE laiso VALUE 'EN', " 2-Character SAP Language Code
             lc_format TYPE tdformat VALUE '*'.  " Tag column

  TYPES: BEGIN OF ty_vbap,
          vbeln TYPE vbeln,    " Sales and Distribution Document Number
          posnr TYPE posnr,    " Item number of the SD document
          kdmat TYPE matnr_ku, " Material Number Used by Customer
        END OF ty_vbap.

  DATA: li_status TYPE STANDARD TABLE OF zdev_enh_status,      " Enhancement Status
         lv_t001w_land1  TYPE land1,                           " Country Key
         lv_t001_land1 TYPE land1,                             " Country Key
         lv_comp_plant(8) TYPE c,                              " Comp_plant(8) of type Character
         lv_vbrk_bukrs TYPE bukrs,                             " Company Code
         li_vbap TYPE STANDARD TABLE OF ty_vbap,
         wa_cs_itm_cdoc_txt TYPE /sapsll/api6800_itm_txt_r3_s, " SLL: API Comm.Structure: Customs Doc.: Item: Texts
         lv_posnr(10) TYPE n,                                  " Posnr(10) of type Numeric Text Fields
         lv_werks TYPE werks_d,                                " Plant
         lv_random TYPE i.                                     " Random of type Integers

  CONSTANTS: lc_d3_otc_edd_0013 TYPE z_enhancement VALUE 'OTC_EDD_0013', " Enhancement No.
             lc_criteria(13) TYPE c VALUE 'PLANTS_ABROAD',               " Criteria(13) of type Character
             lc_text_id(4) TYPE c VALUE 'ZZ01'.                          " Text_id(4) of type Character

  FIELD-SYMBOLS: <lfs_zdev_enh_status> TYPE zdev_enh_status, " Enhancement Status
                 <lfs_vbap> TYPE ty_vbap,
                 <lfs_cs_itm_cdoc_txt_t> TYPE sllr3_api6800_itm_txt_r3_t.

**End of D3 changes - E1DK919194, AMANGAL
* Begin of Changes for D3_OTC_EDD_0415, SCtask: SCTASK0660730
  FIELD-SYMBOLS : <lfs_cs_itm_cdoc_ref_t> TYPE sllr3_api6800_itm_ref_r3_t,
                  <lfs_cs_itm_cdoc_ref>   TYPE /sapsll/api6800_itm_ref_r3_s, " SLL: API Comm. Structure: Custs Doc.: Item: Reference Data
                  <lfs_cs_hdr_cdoc_ref_t> TYPE sllr3_api6800_hdr_ref_r3_t,
                  <lfs_cs_hdr_cdoc_ref>   TYPE /sapsll/api6800_hdr_ref_r3_s, " SLL: API Comm. Struct.: Customs Docmt: Header: Ref. Data
                  <lfs_cs_hdr_cdoc_pge_t> TYPE sllr3_api6800_hdr_pge_r3_t,
                  <lfs_cs_itm_cdoc_dim_t> TYPE sllr3_api6800_itm_dim_r3_t,   "Defect 8613
                  <lfs_cs_itm_cdoc_dim>   TYPE /sapsll/api6800_itm_dim_r3_s, " SLL: API Comm. Structure: Customs Document: Item: Dimensions
* Begin of change for Defect 7986
                  <lfs_cond_val>          TYPE /sapsll/api6800_itm_cvl_r3_s, " API Item Structure: Value for Customs Duty Calculation
                  <lfs_cond_comp_val>     TYPE /sapsll/api6800_itm_cvl_r3_s, " API Item Structure: Value for Customs Duty Calculation
* end of Change for Defect 7986
                  <lfs_cs_itm_cdoc_pge_t> TYPE sllr3_api6800_itm_pge_r3_t.

  DATA: lv_deliv_inv    TYPE /sapsll/refno_r3, " Reference Number of a Document from Backend System for SLL
        lv_itm_num      TYPE text10,           " Text (10 Characters)
* Begin of change for Defect 7986 by U033876
        li_itm_cond_proc TYPE  /sapsll/api6800_itm_cvl_r3_t,
        lwa_itm_cond_proc TYPE /sapsll/api6800_itm_cvl_r3_s, " API Item Structure: Value for Customs Duty Calculation
        li_itm_comp_cond TYPE /sapsll/api6800_itm_cvl_r3_t,
* end of Change for Defect 7986 by U033876
        li_hu_det       TYPE zlex_tt_hu_details_from_ewm,
        lwa_hu_det      TYPE zlex_s_hu_details_from_ewm,        " HU Details from ewm for Hu level CI
        lwa_serno       TYPE zlex_ser_no_s,                     " Hu level CI - Serial nos for HU
        li_415_status   TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        lwa_415_status  TYPE zdev_enh_status,                   " Enhancement Status
        lwa_pge_data    TYPE /sapsll/api6800_hdr_pge_r3_s,      " GTS: API Comm.Struc: Customs Doc: Header: Packaging Data
        lwa_pge_itmdata TYPE /sapsll/api6800_itm_pge_r3_s.      " GTS: API Comm.Struc: Customs Doc: Item: Packaging Data
  CONSTANTS: lc_enh_name_0415    TYPE  z_enhancement  VALUE 'OTC_EDD_0415', " Enhancement No.
             lc_null             TYPE  z_criteria     VALUE 'NULL',         " Enhancement No.
             lc_hu               TYPE  char2          VALUE 'HU'.           " Hu of type CHAR2
* Begin of change for 8317 for Dimensions add of components to Header OTC_EDD_415
  TYPES: BEGIN OF lty_itm_dim_col,
          item_number TYPE text10,           " Text (10 Characters)
          dim_uom     TYPE meins,            " Base Unit of Measure
          weinet      TYPE /sapsll/dimen_r3, " Dimension (Qty, Weight, Height, Width, Length, ...) for SLL
          weinet_flt  TYPE float,            " Field of type FLTP
          weigro      TYPE /sapsll/dimen_r3, " Dimension (Qty, Weight, Height, Width, Length, ...) for SLL
          weigro_flt  TYPE float,            " Field of type FLTP
         END OF lty_itm_dim_col.
  DATA:lwa_itm_dim_col TYPE lty_itm_dim_col,
       li_itm_dim_col  TYPE STANDARD TABLE OF lty_itm_dim_col,
       li_itm_dim      TYPE sllr3_api6800_itm_dim_r3_t,
       lwa_itm_dim     TYPE /sapsll/api6800_itm_dim_r3_s. " SLL: API Comm. Structure: Customs Document: Item: Dimensions

  FIELD-SYMBOLS: <lfs_itm_cdoc_dim_val> TYPE /sapsll/api6800_itm_dim_r3_s, " SLL: API Comm. Structure: Customs Document: Item: Dimensions
           <lfs_dim_val> TYPE /sapsll/api6800_itm_dim_r3_s.                " SLL: API Comm. Structure: Customs Document: Item: Dimensions
  CONSTANTS:lc_bomh        TYPE  z_criteria     VALUE   'BOMH_PSTYV'. " Enh. Criteria
* End of change for 8317 for Dimensions add of components to Header OTC_EDD_415
* End of Changes for D3_OTC_EDD_0415 , Sctask:SCTASK0660730

** Begin of change for defect 2799- E1DK928011 by u033876.
  DATA: gv_ship_from_ctry  TYPE land1,                             " Country Key
        lv_cond_manual     TYPE kscha,                             " Condition type
        lv_cond_over       TYPE kscha,                             " Condition type
        lv_kschl           TYPE kscha,                             " Condition type
        lv_clear_zend      TYPE boole_d,                           " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
        lwa_itm_doc_gen    TYPE /sapsll/api6800_itm_r3_s,          " SLL: API Comm. Structure: Customs Document: Item
        i_constants_0013   TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        wa_constants_0013  TYPE zdev_enh_status,                   " Enhancement Status
        lwa_komv           TYPE komv.                              " Pricing Communications-Condition Record
  CONSTANTS:  c_enh_name_0013    TYPE  z_enhancement  VALUE 'OTC_EDD_0013',   " Enhancement No.
              c_ship_from_ctry   TYPE  z_criteria     VALUE 'SHIP_FROM_CTRY', " Enh. Criteria
              c_kschl_manual     TYPE  z_criteria     VALUE 'KSCHL_MANUAL',   " Enh. Criteria
              c_grwr_src         TYPE  z_criteria     VALUE 'GRWR_SRC'.       " Enh. Criteria
** End of change for defect 2799- E1DK928011 by u033876.


  REFRESH: i_serial,i_object.
* CR#12
  REFRESH: i_po.
* CR#12

* Begin of change for Defect # 8286 OTC_EDD_0415 by U033876
  DATA: lv_hu_lvl_ci TYPE boole_d. " hu level ci flag
* If below logic is for Hu level CI, then do not move serial no
* data from Delivery as this info will be appended from HU
* inside Hu level code ..Search for "lwa_hu_det-serid"
  CLEAR: li_hu_det[],lv_hu_lvl_ci.
  zcl_otc_edd_0415_hu_lvl_ci=>get_hu_lvl_ci_data(
     IMPORTING
     ex_hu_det = li_hu_det ).
  IF li_hu_det[] IS NOT INITIAL.
    LOOP AT it_vbrp ASSIGNING <lfs_vbrp>.
      READ TABLE li_hu_det INTO lwa_hu_det
                                WITH KEY delivery = <lfs_vbrp>-vgbel
                                         itmno    = <lfs_vbrp>-vgpos .
      IF sy-subrc = 0 .
        lv_hu_lvl_ci = abap_true.
      ENDIF. " IF sy-subrc = 0
    ENDLOOP. " LOOP AT it_vbrp ASSIGNING <lfs_vbrp>
  ENDIF. " IF li_hu_det[] IS NOT INITIAL
* End of change for Defect # 8286 OTC_EDD_0415 by U033876

  IF it_vbrp[] IS NOT INITIAL.
* Begin of change for Defect # 8286 OTC_EDD_0415 by U033876
    IF lv_hu_lvl_ci = abap_false.
* End of change for Defect # 8286 OTC_EDD_0415 by U033876

*   Capture all serial numbers in a local table
      SELECT obknr lief_nr posnr anzsn
        INTO TABLE i_serial
        FROM ser01 " Document Header for Serial Numbers for Delivery
        FOR ALL ENTRIES IN it_vbrp
        WHERE lief_nr = it_vbrp-vgbel
          AND posnr   = it_vbrp-vgpos.
      IF i_serial[] IS NOT INITIAL.
        SELECT obknr obzae matnr sernr
          INTO TABLE i_object
          FROM objk " Plant Maintenance Object List
          FOR ALL ENTRIES IN i_serial
          WHERE obknr = i_serial-obknr.
*          AND obzae = i_serial-anzsn.
      ENDIF. " IF i_serial[] IS NOT INITIAL
* Begin of change for Defect # 8286 OTC_EDD_0415 by U033876
    ENDIF. " IF lv_hu_lvl_ci = abap_false
* End of change for Defect # 8286 OTC_EDD_0415 by U033876
* CR#12
    SELECT vbeln posnr bstkd
      INTO TABLE i_po
      FROM vbkd " Sales Document: Business Data
      FOR ALL ENTRIES IN it_vbrp
      WHERE vbeln = it_vbrp-aubel.
*        AND posnr = it_vbrp-aupos.
    IF sy-subrc = 0.
      SORT i_po BY vbeln. " posnr.
    ENDIF. " IF sy-subrc = 0
* CR#12
  ENDIF. " IF it_vbrp[] IS NOT INITIAL

* cr#47
  SELECT SINGLE waers " Currency Key
  INTO gv_waers
  FROM t001           " Company Codes
  WHERE bukrs = is_vbrk-bukrs.
* cr#47
* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
* Get the Country of Origin from Material master for all the line item
  IF it_vbrp[] IS NOT INITIAL.
    li_vbrp[] = it_vbrp[].
    SORT li_vbrp BY matnr werks.
    DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING matnr werks.
    SELECT matnr " Material Number
           werks " Plant
           herkl " Country of origin of the material
      FROM marc  " Plant Data for Material
      INTO TABLE li_marc
      FOR ALL ENTRIES IN li_vbrp
      WHERE matnr = li_vbrp-matnr
      AND   werks = li_vbrp-werks.
    IF sy-subrc = 0.
      SORT li_marc BY matnr werks.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF it_vbrp[] IS NOT INITIAL
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU

* Begin of change for defect 2799- E1DK928011 by u033876.
* get the emi entries
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enh_name_0013
    TABLES
      tt_enh_status     = i_constants_0013.
* Also read the Dep_from_country into  gv_ship_from_ctry
  CLEAR: gv_ship_from_ctry.
  READ TABLE cs_itm_cdoc-gen INTO lwa_itm_doc_gen INDEX 1.
  IF sy-subrc = 0.
    gv_ship_from_ctry = lwa_itm_doc_gen-departure_country.
  ENDIF. " IF sy-subrc = 0

* End of change for defect 2799- E1DK928011 by u033876.
*&-- Begin of Changes for HANAtization on OTC_EDD_0013 by U106341 on 16-Sep-2019 E1SK901550
 IF it_vbrp[] IS NOT INITIAL.
*&-- End of Changes for HANAtization on OTC_EDD_0013 by U106341 on 16-Sep-2019 E1SK901550

**Begin of D3 changes - E1DK919194, AMANGAL
  SELECT vbeln posnr kdmat
    INTO TABLE li_vbap
    FROM vbap " Sales Document: Item Data
    FOR ALL ENTRIES IN it_vbrp
    WHERE vbeln = it_vbrp-aubel
    AND posnr   = it_vbrp-aupos.
**End of D3 changes - E1DK919194, AMANGAL

  LOOP AT it_vbrp ASSIGNING <lfs_vbrp>.
*   Clear global variables
    CLEAR  : wa_mcha,gv_herkl.
    CLEAR  : x_object_rec.

    gv_itm_nr = <lfs_vbrp>-posnr. "CR#12

    IF <lfs_vbrp>-charg IS NOT INITIAL.
*     Read Batch details
      CALL FUNCTION 'VB_BATCH_GET_DETAIL'
        EXPORTING
          matnr                    = <lfs_vbrp>-matnr
          charg                    = <lfs_vbrp>-charg
          werks                    = <lfs_vbrp>-werks
*         GET_CLASSIFICATION       =
*         EXISTENCE_CHECK          =
*         READ_FROM_BUFFER         =
*         NO_CLASS_INIT            = ' '
*         LOCK_BATCH               = ' '
        IMPORTING
          ymcha                    = wa_mcha
*         CLASSNAME                =
*       TABLES
*         CHAR_OF_BATCH            =
       EXCEPTIONS
         no_material              = 1
         no_batch                 = 2
         no_plant                 = 3
         material_not_found       = 4
         plant_not_found          = 5
         no_authority             = 6
         batch_not_exist          = 7
         lock_on_batch            = 8
         OTHERS                   = 9.
      IF sy-subrc = 0.
* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
**       If country of origin is not maintained for batch, read it from Material master
*        IF wa_mcha-herkl IS INITIAL.
*          SELECT SINGLE herkl " Country of origin of the material
*            INTO gv_herkl
*            FROM marc         " Plant Data for Material
*            WHERE matnr = <lfs_vbrp>-matnr
*              AND werks = <lfs_vbrp>-werks.
*        ELSE. " ELSE -> IF wa_mcha-herkl IS INITIAL
*          gv_herkl  = wa_mcha-herkl.
*        ENDIF. " IF wa_mcha-herkl IS INITIAL

        lwa_extension1-field1 = lc_papad.
        lwa_extension1-field2 = lc_zbs.
        lwa_extension1-field3 = <lfs_vbrp>-charg .
        lwa_extension1-field4 = wa_mcha-herkl.
        APPEND lwa_extension1 TO ct_extension1.
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU

*&-- Begin of insert for D3_OTC_EDD_0013 Defect# 6695 by SMUKHER on 02-Aug-2018
*&-- We populate the 'Date of manufacture' (MCHA-HSDAT) to the field PAPDT
        CLEAR: lwa_extension1.
        lwa_extension1-field1 = lc_papdt.
        lwa_extension1-field2 = lc_zbs.
        lwa_extension1-field3 = wa_mcha-hsdat .
        APPEND lwa_extension1 TO ct_extension1.
        CLEAR: lwa_extension1.
*&-- End of insert for D3_OTC_EDD_0013 Defect# 6695 by SMUKHER on 02-Aug-2018
      ENDIF. " IF sy-subrc = 0
* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
      READ TABLE li_marc ASSIGNING <lfs_marc> WITH KEY matnr = <lfs_vbrp>-matnr
                                                       werks = <lfs_vbrp>-werks
                                              BINARY SEARCH.
      IF sy-subrc EQ 0.
        gv_herkl = <lfs_marc>-herkl.
      ENDIF. " IF sy-subrc EQ 0
      UNASSIGN : <lfs_marc>.
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU

*     Map values to GTS fields
      ASSIGN COMPONENT 'DOC' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_doc>.
      IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED.
*        gv_itm_nr = <lfs_vbrp>-posnr.          "CR#12
        LOOP AT <lfs_cs_itm_cdoc_doc> INTO wa_itm_doc
                                WHERE item_number = <lfs_vbrp>-posnr.

* ---> Begin of Change for D2_OTC_EDD_0013_Defect_4607 by PMISHRA
*          wa_itm_doc-document_category       = 'CINV'. " Document type
          wa_itm_doc-document_category       = lc_docat_zbs. " Document type
* <--- End of Change for D2_OTC_EDD_0013_Defect_4607 by PMISHRA
*&-- Begin of insert for D3_OTC_EDD_0013 Defect# 6695 by SMUKHER on 02-Aug-2018
* We pass the Date of Manufacture to the Document date at item level.
          wa_itm_doc-document_date           = wa_mcha-hsdat.
*&-- End of insert for D3_OTC_EDD_0013 Defect# 6695 by SMUKHER on 02-Aug-2018

* ---> Begin of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA

*        wa_itm_doc-document_no             = <lfs_vbrp>-charg. " Batch

**Begin of delete for Defect#2548 by U033867
*          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*            EXPORTING
*              input  = <lfs_vbrp>-charg
*            IMPORTING
*              output = lv_charg.
*          wa_itm_doc-document_no = lv_charg. " Batch
**End of delete for Defect#2548 by U033867
**Begin of insert for Defect#2548 by U033867
          wa_itm_doc-document_no = <lfs_vbrp>-charg.
**End of insert for Defect#2548 by U033867
* <--- End of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA

          wa_itm_doc-document_validity_end   = wa_mcha-vfdat. " Expiry date

* ---> Begin of Change for D3_OTC_EDD_0013 defect:2438 change by u033876

* Instead of Modify use Append as the content in <lfs_cs_itm_cdoc_doc>
* can have multiple values. commented below modify

*          MODIFY <lfs_cs_itm_cdoc_doc> FROM wa_itm_doc TRANSPORTING
*                                                      document_date
*                                                      document_category
*                                                      document_no
*                                                      document_validity_end.
          APPEND wa_itm_doc TO <lfs_cs_itm_cdoc_doc>.


* <--- End of Change for D3_OTC_EDD_0013 defect:2438 change by u033876

* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
          gv_flag_batch = abap_true.
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2

* ---> Begin of Change for D3_OTC_EDD_0013 defect:2438 change by u033876
* as we changed the modify to append we just exit from loop after
* all the processing
          EXIT.
* <--- End of Change for D3_OTC_EDD_0013 defect:2438 change by u033876
        ENDLOOP. " LOOP AT <lfs_cs_itm_cdoc_doc> INTO wa_itm_doc
      ENDIF. " IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED
      ASSIGN COMPONENT 'GEN' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_gen>.
      IF <lfs_cs_itm_cdoc_gen> IS ASSIGNED.
        LOOP AT <lfs_cs_itm_cdoc_gen> INTO wa_itm_gen
                                WHERE item_number = <lfs_vbrp>-posnr.

* CR#40 - Move ISO country code to GTS
          CLEAR: gv_im_land1,gv_ex_intca.

          gv_im_land1 = gv_herkl.
          CALL FUNCTION 'COUNTRY_CODE_SAP_TO_ISO'
            EXPORTING
              sap_code  = gv_im_land1
            IMPORTING
              iso_code  = gv_ex_intca
            EXCEPTIONS
              not_found = 1
              OTHERS    = 2.
          IF sy-subrc = 0.
            wa_itm_gen-country_of_origin_iso  = gv_ex_intca. " Country of Origin
          ENDIF. " IF sy-subrc = 0
* CR#40

          wa_itm_gen-country_of_origin  = gv_herkl. " Country of Origin

          MODIFY <lfs_cs_itm_cdoc_gen> FROM wa_itm_gen TRANSPORTING country_of_origin
                                                                    country_of_origin_iso.
        ENDLOOP. " LOOP AT <lfs_cs_itm_cdoc_gen> INTO wa_itm_gen
      ENDIF. " IF <lfs_cs_itm_cdoc_gen> IS ASSIGNED
    ELSE. " ELSE -> IF <lfs_vbrp>-charg IS NOT INITIAL
*     Read serial number
      IF <lfs_vbrp>-vgbel IS NOT INITIAL AND
         <lfs_vbrp>-vgpos IS NOT INITIAL.

*        gv_itm_nr = <lfs_vbrp>-posnr.       "CR#12

*       Get the count of serial numbers assigned to material
        READ TABLE i_serial ASSIGNING <lfs_serial> WITH KEY lief_nr = <lfs_vbrp>-vgbel
                                                            posnr   = <lfs_vbrp>-vgpos.
        IF sy-subrc = 0.
*         Read serial number
          LOOP AT i_object ASSIGNING <lfs_object> WHERE obknr = <lfs_serial>-obknr.
            CALL FUNCTION 'ITOB_SERIALNO_READ_SINGLE'
              EXPORTING
*               I_HANDLE       =
*               I_AUTH_TCODE   =
*               I_EQUI_ONLY    =
*               I_LOCK         =
                i_matnr        = <lfs_object>-matnr
                i_sernr        = <lfs_object>-sernr
*               I_UII          =
              IMPORTING
                e_object_rec   = x_object_rec
              EXCEPTIONS
                not_successful = 1
                OTHERS         = 2.
            IF sy-subrc = 0.
* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
***              If country of origin is not maintained, read it from Material master - ONE TIME
**              IF x_object_rec-herld IS INITIAL
*** ---> Begin of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA
***                 gv_herkl IS NOT INITIAL
**             AND gv_herkl IS INITIAL.
*** <--- End of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA
**                SELECT SINGLE herkl " Country of origin of the material
**                  INTO gv_herkl
**                  FROM marc         " Plant Data for Material
**                  WHERE matnr = <lfs_vbrp>-matnr
**                    AND werks = <lfs_vbrp>-werks.
**              ELSE. " ELSE -> IF x_object_rec-herld IS INITIAL
**                gv_herkl  = x_object_rec-herld.
**              ENDIF. " IF x_object_rec-herld IS INITIAL

* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU
              lwa_extension1-field1 = lc_papad.
              lwa_extension1-field2 = lc_zbs.
**Begin of delete for Defect#2548 by U033867
*              lwa_extension1-field3 = <lfs_object>-sernr .
* added the above assignment of serial no, below after conversion.
* Commented the below Shift delete of leading Zeros by Jayanta
*              SHIFT lwa_extension1-field3 LEFT DELETING LEADING '0'.
**End of delete for Defect#2548 by U033867
**Begin of change for Defect#2548 by u033876
* also need to to converion reoutine as Serial no is 8 char in ECC
* and the <LFS_OBJECT>-SERNR is char 18. So we need to do conversion routine

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
                EXPORTING
                  input  = <lfs_object>-sernr
                IMPORTING
                  output = <lfs_object>-sernr.
**End of change for Defect#2548 by u033876
              lwa_extension1-field3 = <lfs_object>-sernr .
              lwa_extension1-field4 = x_object_rec-herld.
              APPEND lwa_extension1 TO ct_extension1.
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU
            ENDIF. " IF sy-subrc = 0
* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
            READ TABLE li_marc ASSIGNING <lfs_marc> WITH KEY matnr = <lfs_vbrp>-matnr
                                                             werks = <lfs_vbrp>-werks
                                                    BINARY SEARCH.
            IF sy-subrc EQ 0.
              gv_herkl = <lfs_marc>-herkl.
            ENDIF. " IF sy-subrc EQ 0
            UNASSIGN : <lfs_marc>.
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU

*             Map values to GTS fields
            ASSIGN COMPONENT 'DOC' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_doc>.
            IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED.
*              gv_itm_nr = <lfs_vbrp>-posnr.            " CR#12
              READ TABLE <lfs_cs_itm_cdoc_doc> INTO wa_itm_doc
                                               WITH KEY item_number = gv_itm_nr
                                                        document_category = 'PINV'.
              IF sy-subrc = 0.
                gv_itm_nr = wa_itm_doc-item_number.
**Begin of delete for Defect#2548 by u033876
*                DELETE <lfs_cs_itm_cdoc_doc> WHERE  item_number = <lfs_vbrp>-posnr AND
*                                                    document_category = 'PINV'.
**End of delete for Defect#2548 by u033876
                CLEAR wa_itm_doc.
              ENDIF. " IF sy-subrc = 0
              wa_itm_doc-item_number             = gv_itm_nr. " Item number
              wa_itm_doc-document_date           = space. " Document date
* ---> Begin of Change for D2_OTC_EDD_0013_Defect_4607 by PMISHRA
*          wa_itm_doc-document_category       = 'CINV'. " Document type
              wa_itm_doc-document_category       = lc_docat_zbs. " Document type
* <--- End of Change for D2_OTC_EDD_0013_Defect_4607 by PMISHRA

* ---> Begin of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA

*              wa_itm_doc-document_no             = x_object_rec-sernr. " Serial number
**Begin of delete for Defect#2548 by U033867
*              CALL FUNCTION 'CONVERSION_EXIT_GERNR_OUTPUT'
*                EXPORTING
*                  input  = x_object_rec-sernr
*                IMPORTING
*                  output = lv_sernr.
*              wa_itm_doc-document_no  = lv_sernr. " Serial number
**End of delete for Defect#2548 by U033867
**Begin of insert for Defect#2548 by U033867
              wa_itm_doc-document_no  = x_object_rec-sernr. " Serial number
**End of insert for Defect#2548 by U033867
* <--- End of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA

              wa_itm_doc-document_validity_end   = x_object_rec-datbi. " Expiry date

              APPEND wa_itm_doc TO <lfs_cs_itm_cdoc_doc>. ".
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
              gv_flag_serial = abap_true.
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
            ENDIF. " IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED
            ASSIGN COMPONENT 'GEN' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_gen>.
            IF <lfs_cs_itm_cdoc_gen> IS ASSIGNED. " AND
*               wa_itm_gen-country_of_origin IS INITIAL.
              LOOP AT <lfs_cs_itm_cdoc_gen> INTO wa_itm_gen
                                      WHERE item_number = <lfs_vbrp>-posnr.

* CR#40 - Move ISO country code to GTS
                CLEAR: gv_im_land1,gv_ex_intca.

                gv_im_land1 = gv_herkl.
                CALL FUNCTION 'COUNTRY_CODE_SAP_TO_ISO'
                  EXPORTING
                    sap_code  = gv_im_land1
                  IMPORTING
                    iso_code  = gv_ex_intca
                  EXCEPTIONS
                    not_found = 1
                    OTHERS    = 2.
                IF sy-subrc = 0.
                  wa_itm_gen-country_of_origin_iso  = gv_ex_intca. " Country of Origin
                ENDIF. " IF sy-subrc = 0
* CR#40
                wa_itm_gen-country_of_origin = gv_herkl. " Country of Origin

                MODIFY <lfs_cs_itm_cdoc_gen> FROM wa_itm_gen TRANSPORTING country_of_origin
                                                                          country_of_origin_iso.
              ENDLOOP. " LOOP AT <lfs_cs_itm_cdoc_gen> INTO wa_itm_gen
            ENDIF. " IF <lfs_cs_itm_cdoc_gen> IS ASSIGNED
          ENDLOOP. " LOOP AT i_object ASSIGNING <lfs_object> WHERE obknr = <lfs_serial>-obknr
* ---> Begin of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA
          CLEAR gv_herkl .
        ELSE. " ELSE -> IF sy-subrc = 0
*&-- If there is no serial number or batch found, then populate the COO
*&-- from material master itself
          IF gv_herkl IS INITIAL.
* Begin of Change for Defect#1017 by SAGARWA1/ PDEBARU
*            SELECT SINGLE herkl " Country of origin of the material
*              INTO gv_herkl
*              FROM marc         " Plant Data for Material
*              WHERE matnr = <lfs_vbrp>-matnr
*                AND werks = <lfs_vbrp>-werks.
*            IF sy-subrc EQ 0.
            READ TABLE li_marc ASSIGNING <lfs_marc> WITH KEY matnr = <lfs_vbrp>-matnr
                                                             werks = <lfs_vbrp>-werks
                                                    BINARY SEARCH.
            IF sy-subrc EQ 0.
              gv_herkl = <lfs_marc>-herkl.
              UNASSIGN : <lfs_marc>.
* End   of Change for Defect#1017 by SAGARWA1/ PDEBARU
              IF NOT <lfs_cs_itm_cdoc_gen> IS ASSIGNED.
                ASSIGN COMPONENT 'GEN' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_gen>.
              ENDIF. " IF NOT <lfs_cs_itm_cdoc_gen> IS ASSIGNED
              IF <lfs_cs_itm_cdoc_gen> IS ASSIGNED.
                LOOP AT <lfs_cs_itm_cdoc_gen> ASSIGNING <lfs_s_itm_gen>
                                                  WHERE item_number = <lfs_vbrp>-posnr.
*&-- Move ISO country code to GTS
                  CLEAR: gv_im_land1, gv_ex_intca.

                  gv_im_land1 = gv_herkl.

                  CALL FUNCTION 'COUNTRY_CODE_SAP_TO_ISO'
                    EXPORTING
                      sap_code  = gv_im_land1
                    IMPORTING
                      iso_code  = gv_ex_intca
                    EXCEPTIONS
                      not_found = 1
                      OTHERS    = 2.

                  IF sy-subrc = 0.
                    <lfs_s_itm_gen>-country_of_origin_iso  = gv_ex_intca. " Country of Origin
                  ENDIF. " IF sy-subrc = 0
                  <lfs_s_itm_gen>-country_of_origin = gv_herkl. " Country of Origin
                ENDLOOP. " LOOP AT <lfs_cs_itm_cdoc_gen> ASSIGNING <lfs_s_itm_gen>
              ENDIF. " IF <lfs_cs_itm_cdoc_gen> IS ASSIGNED
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF gv_herkl IS INITIAL

* <--- End of Change for D2_OTC_EDD_0013_Defect_8301 by PMISHRA
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF <lfs_vbrp>-vgbel IS NOT INITIAL AND
    ENDIF. " IF <lfs_vbrp>-charg IS NOT INITIAL

* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SSAURAV
*&-- Pass the main material item no of a BOM component
    IF <lfs_vbrp>-uepos IS NOT INITIAL.
      IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED.
        ASSIGN COMPONENT 'DOC' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_doc>.
      ENDIF. " IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED
      CLEAR : wa_itm_doc.
      wa_itm_doc-document_date           = space. " Document date
      wa_itm_doc-item_number             = gv_itm_nr. " <lfs_vbrp>-posnr.
      wa_itm_doc-document_category       = 'ZBM'. "'ZZZ'. " Document type
      wa_itm_doc-document_no             = <lfs_vbrp>-uepos. " Batch
      APPEND wa_itm_doc TO <lfs_cs_itm_cdoc_doc>.
      CLEAR : wa_itm_doc.
    ENDIF. " IF <lfs_vbrp>-uepos IS NOT INITIAL
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SSAURAV
* CR#12
    IF NOT <lfs_cs_itm_cdoc_doc> IS ASSIGNED.
      ASSIGN COMPONENT 'DOC' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_doc>.
    ENDIF. " IF NOT <lfs_cs_itm_cdoc_doc> IS ASSIGNED
    CLEAR: wa_itm_doc.
    READ TABLE i_po ASSIGNING <lfs_po> WITH KEY vbeln = <lfs_vbrp>-aubel
*                                                posnr = <lfs_vbrp>-aupos
                                              BINARY SEARCH.
    IF sy-subrc = 0.
      wa_itm_doc-item_number             = gv_itm_nr. " Item number
      wa_itm_doc-document_date           = space. " Document date
      wa_itm_doc-document_category       = 'ZZZ'. " Document type
      wa_itm_doc-document_no             = <lfs_po>-bstkd. " PO Number

      APPEND wa_itm_doc TO <lfs_cs_itm_cdoc_doc>.
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
    ELSE. " ELSE -> IF sy-subrc = 0
      IF gv_flag_batch = abap_true OR gv_flag_serial = abap_true. "If batch or serial no is present

        wa_itm_doc-item_number             = gv_itm_nr. " Item number
        wa_itm_doc-document_date           = space. " Document date
        wa_itm_doc-document_category       = lc_doc_cat. " Document type
        wa_itm_doc-document_no             = <lfs_vbrp>-aubel. " Document no

        APPEND wa_itm_doc TO <lfs_cs_itm_cdoc_doc>.
      ELSE. " ELSE -> IF gv_flag_batch = abap_true OR gv_flag_serial = abap_true

        LOOP AT <lfs_cs_itm_cdoc_doc> ASSIGNING <lfs_itm_doc>
                                        WHERE item_number = <lfs_vbrp>-posnr.

          <lfs_itm_doc>-item_number          = gv_itm_nr. " Item number
          <lfs_itm_doc>-document_date        = space. " Document date
          <lfs_itm_doc>-document_category    = lc_doc_cat. " Document type
          <lfs_itm_doc>-document_no          = <lfs_vbrp>-aubel. " Document no
        ENDLOOP. " LOOP AT <lfs_cs_itm_cdoc_doc> ASSIGNING <lfs_itm_doc>
      ENDIF. " IF gv_flag_batch = abap_true OR gv_flag_serial = abap_true
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
    ENDIF. " IF sy-subrc = 0
* CR#12
**Begin of CR#47
    ASSIGN COMPONENT 'CVL' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_konv_val>.

* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
*   Check the Condition Type maintained in OTC Control table.
    SELECT  mparameter              " Parameter
            mvalue1                 " Select Options: Value Low
      FROM zotc_prc_control         " OTC Process Team Control Table
      INTO TABLE  li_kschl
      WHERE vkorg      = is_vbrk-vkorg
        AND vtweg      = is_vbrk-vtweg
        AND mprogram   = lc_program " Value 'ZCL_IM_INV_ECC_2_GTS'
* ---> Begin of Change Delete for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
*        AND mparameter IN (lc_kschl1, lc_kschl2, lc_kschl3) " Value 'KSCHL1,KSCHL2,KSCHL3'
* <--- End of Change Delete for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
        AND mparameter IN (lc_kschl1, lc_kschl2, lc_kschl3, lc_kschl4) " Value 'KSCHL1,KSCHL2,KSCHL3,KSCHL4'
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
        AND mactive    = abap_true     " Value 'X'
        AND soption    = lc_option_eq. " Value 'EQ'
    IF sy-subrc IS INITIAL.
*     Prepare a range table with the condition type values
      lwa_kschl-sign   = lc_sign_i. " Value 'I'
      lwa_kschl-option = lc_option_eq. " Value 'EQ'
      LOOP AT li_kschl ASSIGNING <lfs_kschl>.
        lwa_kschl-low = <lfs_kschl>-mvalue1.
        APPEND lwa_kschl TO lr_kschl. " ZEND,ZA06,GRWR

        IF <lfs_kschl>-mparameter = lc_kschl1.
          lwa_kschl-low = <lfs_kschl>-mvalue1.
          APPEND lwa_kschl TO lr_kschl1. " ZEND
        ELSEIF <lfs_kschl>-mparameter = lc_kschl2.
          lwa_kschl-low = <lfs_kschl>-mvalue1.
          APPEND lwa_kschl TO lr_kschl2. " ZA06
        ELSEIF <lfs_kschl>-mparameter = lc_kschl3.
          lwa_kschl-low = <lfs_kschl>-mvalue1.
          APPEND lwa_kschl TO lr_kschl3. " GRWR
* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
        ELSEIF <lfs_kschl>-mparameter = lc_kschl4.
          lwa_kschl-low = <lfs_kschl>-mvalue1.
          APPEND lwa_kschl TO lr_kschl4. " ZHDL,ZNDG,ZTFR and ZINS
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
        ENDIF. " IF <lfs_kschl>-mparameter = lc_kschl1

        CLEAR lwa_kschl-low.
      ENDLOOP. " LOOP AT li_kschl ASSIGNING <lfs_kschl>
    ENDIF. " IF sy-subrc IS INITIAL
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK

    LOOP AT it_komv INTO wa_konv WHERE kposn = <lfs_vbrp>-posnr AND
* ---> Begin of Change Delete for D2_OTC_EDD_0013 by ASK
*                                     ( kschl = 'ZEND' OR
*                                       kschl = 'ZA06' OR
*                                       kschl = 'GRWR' ).
* <--- End   of Change Delete for D2_OTC_EDD_0013 by ASK
* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
                                       kschl IN lr_kschl.
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK
      gv_itm_nr = <lfs_vbrp>-posnr.
      wa_konv_val-item_number = gv_itm_nr.
      wa_konv_val-qual_val = wa_konv-kschl.
* ---> Begin of Change Delete for D2_OTC_EDD_0013 by ASK
*      CASE wa_konv-kschl.
*        WHEN 'ZEND'.
* <--- End   of Change Delete for D2_OTC_EDD_0013 by ASK
* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
      IF wa_konv-kschl IN lr_kschl1. "ZEND
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK
*Assumption: ZEND value should be sent to GTS system in user entered currency not in customer currency/document currency/company code currency
        wa_konv_val-value = wa_konv-kbetr * <lfs_vbrp>-fkimg.
        wa_konv_val-val_curr = wa_konv-waers.
* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
      ENDIF. " IF wa_konv-kschl IN lr_kschl1
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK
* ---> Begin of Change Delete for D2_OTC_EDD_0013 by ASK
*        WHEN 'ZA06'.
* <--- End   of Change Delete for D2_OTC_EDD_0013 by ASK
* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
      IF wa_konv-kschl IN lr_kschl2. " ZA06
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK
*Assumption: ZA06 value is being stored in KONV table in customer currency/document currency(KONV table does not store the currency key)
        wa_konv_val-value = wa_konv-kawrt.
        wa_konv_val-val_curr = is_vbrk-waerk.
* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
      ENDIF. " IF wa_konv-kschl IN lr_kschl2
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK
* ---> Begin of Change Delete for D2_OTC_EDD_0013 by ASK
*        WHEN 'GRWR'.
* <--- End   of Change Delete for D2_OTC_EDD_0013 by ASK

* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
      IF wa_konv-kschl IN lr_kschl3. " GRWR
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK
*---->  Begin of change for defect 2799- E1DK928011 by u033876.


* Check to see if the ship_from_country is in emi then only do
* conversion on document currency
        READ TABLE  i_constants_0013 INTO wa_constants_0013
                WITH KEY criteria     =  c_ship_from_ctry
                         sel_low      =  gv_ship_from_ctry
                         active       =  abap_true.
        IF sy-subrc = 0  .
* <----End of change for defect 2799- E1DK928011 by u033876.
*Assumption: GRWR value will be stored in KONV table in customer currency/document currency and needs to be converted to company code currency
          CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
            EXPORTING
              client           = sy-mandt
              date             = sy-datum
              foreign_amount   = wa_konv-kawrt
              foreign_currency = is_vbrk-waerk
              local_currency   = gv_waers
            IMPORTING
              local_amount     = wa_konv-kawrt
            EXCEPTIONS
              no_rate_found    = 1
              overflow         = 2
              no_factors_found = 3
              no_spread_found  = 4
              derived_2_times  = 5
              OTHERS           = 6.
          IF sy-subrc = 0.
            wa_konv_val-value = wa_konv-kawrt.
          ENDIF. " IF sy-subrc = 0
          wa_konv_val-val_curr = gv_waers.
* ---> Begin of Change Delete for D2_OTC_EDD_0013 by ASK
*      ENDCASE.
* <--- End   of Change Delete for D2_OTC_EDD_0013 by ASK
*----> Begin of change for defect 2799- E1DK928011 by u033876.
* If no entry in EMI then do reg processing
        ELSE. " ELSE -> IF sy-subrc = 0

          wa_konv_val-value    = wa_konv-kawrt.
          wa_konv_val-val_curr = is_vbrk-waerk.

        ENDIF. " IF sy-subrc = 0
* <----End of change for defect 2799- E1DK928011 by u033876.
* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
      ENDIF. " IF wa_konv-kschl IN lr_kschl3
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK

* ---> Begin of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2
      IF lr_kschl4[] IS NOT INITIAL.
        IF wa_konv-kschl IN lr_kschl4[]. " ZHDL,ZNDG,ZTFR and ZINS
          wa_konv_val-value = wa_konv-kwert.
          wa_konv_val-val_curr = is_vbrk-waerk.
        ENDIF. " IF wa_konv-kschl IN lr_kschl4[]
      ENDIF. " IF lr_kschl4[] IS NOT INITIAL
* <--- End of Change Insert for D2_OTC_EDD_0013 CR D2_71 change by SPAUL2

      wa_konv_val-value_float = wa_konv_val-value.
      CALL FUNCTION 'SAP_TO_ISO_CURRENCY_CODE'
        EXPORTING
          sap_code    = wa_konv_val-val_curr
        IMPORTING
          iso_code    = wa_konv_val-val_curr_iso
        EXCEPTIONS
          not_found   = 1
          no_iso_code = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF. " IF sy-subrc <> 0
      APPEND wa_konv_val TO <lfs_cs_konv_val>.
      CLEAR wa_konv_val.
    ENDLOOP. " LOOP AT it_komv INTO wa_konv WHERE kposn = <lfs_vbrp>-posnr AND
*End of CR#47

*----> Begin of change for defect 2799- E1DK928011 by u033876
*Need to overwrite ZA06 and GRWR with ZEND. If “ZEND”(manual condition) condition exists.
    CLEAR:  wa_constants_0013,lv_cond_manual, lv_cond_over, lv_clear_zend.
* Read EMI to determine manual condition & overwrite condition
    READ TABLE  i_constants_0013 INTO wa_constants_0013
            WITH KEY criteria     =  c_kschl_manual
                     active       =  abap_true.
    IF sy-subrc = 0.
      lv_cond_manual =  wa_constants_0013-sel_low.
      lv_cond_over   =  wa_constants_0013-sel_high.
    ENDIF. " IF sy-subrc = 0

    READ TABLE <lfs_cs_konv_val> ASSIGNING <lfs_konv_zend>
                                   WITH KEY item_number+4(6) = <lfs_vbrp>-posnr
                                            qual_val = lv_cond_manual.
    IF sy-subrc = 0.

      READ TABLE <lfs_cs_konv_val>  ASSIGNING <lfs_konv_za06>
                                   WITH KEY item_number+4(6) = <lfs_vbrp>-posnr
                                            qual_val = lv_cond_over.
      IF sy-subrc = 0.

* overwrite ZEND value to ZA06 only when we DONT find an entry for ship_to country in emi
        READ TABLE  i_constants_0013 INTO wa_constants_0013
                WITH KEY criteria     =  c_ship_from_ctry
                         sel_low      =  gv_ship_from_ctry
                         active       =  abap_true.
        IF sy-subrc NE 0.

          <lfs_konv_za06>-value        = <lfs_konv_zend>-value.
          <lfs_konv_za06>-value_float  = <lfs_konv_zend>-value_float.
          <lfs_konv_za06>-val_curr     = <lfs_konv_zend>-val_curr.
          <lfs_konv_za06>-val_curr_iso = <lfs_konv_zend>-val_curr_iso.
          lv_clear_zend = abap_true.
        ELSE. " ELSE -> IF sy-subrc NE 0
          CLEAR lv_clear_zend.
        ENDIF. " IF sy-subrc NE 0


      ENDIF. " IF sy-subrc = 0

      CLEAR: lv_cond_manual, lv_cond_over.

*    Need to Overwrite GRWR with ZEND(manual condition )if present
      READ TABLE  i_constants_0013 INTO wa_constants_0013
              WITH KEY criteria     =  c_grwr_src
                       active       =  abap_true.
      IF sy-subrc = 0.
        lv_cond_manual =  wa_constants_0013-sel_low.
        lv_cond_over   =  wa_constants_0013-sel_high.
      ENDIF. " IF sy-subrc = 0

      READ TABLE <lfs_cs_konv_val> ASSIGNING <lfs_konv_zend>
                              WITH KEY item_number+4(6) = <lfs_vbrp>-posnr
                                               qual_val = lv_cond_manual.
      IF sy-subrc = 0.
* Check if there is an entry for "ZEND in KOMV then move the value into GRWR.
        READ TABLE <lfs_cs_konv_val>  ASSIGNING <lfs_konv_grwr>
                                     WITH KEY item_number+4(6) = <lfs_vbrp>-posnr
                                              qual_val = lv_cond_over.
        IF sy-subrc = 0.
* overwrite ZEND vale to GRWR only when we DONT find an entry for ship_to country in emi
          READ TABLE  i_constants_0013 INTO wa_constants_0013
                  WITH KEY criteria     =  c_ship_from_ctry
                           sel_low      =  gv_ship_from_ctry
                           active       =  abap_true.
          IF sy-subrc NE 0.
            <lfs_konv_grwr>-value        = <lfs_konv_zend>-value.
            <lfs_konv_grwr>-val_curr     = <lfs_konv_zend>-val_curr.
            <lfs_konv_grwr>-value_float  = <lfs_konv_zend>-value_float.
            <lfs_konv_grwr>-val_curr_iso = <lfs_konv_zend>-val_curr_iso.
            lv_clear_zend = abap_true.
          ELSE. " ELSE -> IF sy-subrc NE 0
            CLEAR lv_clear_zend.
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF sy-subrc = 0

      ENDIF. " IF sy-subrc = 0
* Clear the ZEND values if lv_cond_manual is not initial.
      IF lv_clear_zend = abap_true.
        CLEAR: <lfs_konv_zend>-value,
               <lfs_konv_zend>-value_float,
               <lfs_konv_zend>-val_curr,
               <lfs_konv_zend>-val_curr_iso.
      ENDIF. " IF lv_clear_zend = abap_true
    ENDIF. " IF sy-subrc = 0
* <----End of change for defect 2799- E1DK928011 by u033876
**Begin of D3 changes - E1DK919194, AMANGAL

    READ TABLE li_vbap ASSIGNING <lfs_vbap>
      WITH KEY vbeln = <lfs_vbrp>-aubel
      posnr = <lfs_vbrp>-aupos.

    IF sy-subrc EQ 0.

      ASSIGN COMPONENT 'TXT' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_txt_t>.

      IF <lfs_cs_itm_cdoc_txt_t> IS ASSIGNED.

        lv_posnr = <lfs_vbrp>-posnr.

        wa_cs_itm_cdoc_txt-item_number    = lv_posnr.
        wa_cs_itm_cdoc_txt-text_id        = lc_text_id.
        wa_cs_itm_cdoc_txt-langu          = lc_langu.
        wa_cs_itm_cdoc_txt-langu_iso      = lc_langu_iso.
        wa_cs_itm_cdoc_txt-format_col     = lc_format.
        wa_cs_itm_cdoc_txt-text_line      = <lfs_vbap>-kdmat.
        APPEND  wa_cs_itm_cdoc_txt TO <lfs_cs_itm_cdoc_txt_t>.

      ENDIF. " IF <lfs_cs_itm_cdoc_txt_t> IS ASSIGNED

    ENDIF. " IF sy-subrc EQ 0
**End of D3 changes - E1DK919194, AMANGALof D3 changes

* Begin of Changes for D3_OTC_EDD_0415, SCtask: SCTASK0660730

    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enh_name_0415
      TABLES
        tt_enh_status     = li_415_status.

    DELETE li_415_status WHERE active = abap_false.

    READ TABLE li_415_status TRANSPORTING NO FIELDS
                          WITH KEY criteria = lc_null
                                   active   = abap_true.
    IF sy-subrc = 0.
      CLEAR: li_hu_det[].
      zcl_otc_edd_0415_hu_lvl_ci=>get_hu_lvl_ci_data(
         IMPORTING
         ex_hu_det = li_hu_det ).

      READ TABLE li_hu_det INTO lwa_hu_det
                                WITH KEY delivery = <lfs_vbrp>-vgbel
                                         itmno    = <lfs_vbrp>-vgpos .
      IF sy-subrc = 0 .
* Printer assignement
        cs_hdr_cdoc-gen-add_data3 = lwa_hu_det-printer.
* add "HU" constant into addition data 1 field
        cs_hdr_cdoc-gen-add_data1 = lc_hu.

* for Serial no:
        IF lwa_hu_det-serid[] IS NOT INITIAL.
          ASSIGN COMPONENT 'DOC' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_doc>.
          IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED.
            LOOP AT lwa_hu_det-serid INTO lwa_serno.
              wa_itm_doc-item_number            =   gv_itm_nr. " Item number
              wa_itm_doc-document_date          =  space. " Document date
              wa_itm_doc-document_category      =  lc_docat_zbs.
              wa_itm_doc-document_no            =  lwa_serno-serno.
              APPEND wa_itm_doc TO <lfs_cs_itm_cdoc_doc>.
            ENDLOOP. " LOOP AT lwa_hu_det-serid INTO lwa_serno
          ENDIF. " IF <lfs_cs_itm_cdoc_doc> IS ASSIGNED
        ENDIF. " IF lwa_hu_det-serid[] IS NOT INITIAL


        ASSIGN COMPONENT 'REF' OF STRUCTURE cs_itm_cdoc TO <lfs_cs_itm_cdoc_ref_t>.
        IF <lfs_cs_itm_cdoc_ref_t> IS ASSIGNED.
* Low entries so no Binary Search.
          READ TABLE <lfs_cs_itm_cdoc_ref_t> ASSIGNING <lfs_cs_itm_cdoc_ref>
                                                       WITH KEY item_number+4(6) = <lfs_vbrp>-posnr
                                                                qual_refno  = 'EXTIDF'
                                                                objtp       = 'LIKP'
                                                                refapp      = 'SD0B'.

          IF sy-subrc = 0.
* Concatenate invoice number and delivery and append same into reference field
            CLEAR: lv_deliv_inv, lv_itm_num.
            lv_itm_num = <lfs_cs_itm_cdoc_ref>-item_number.
            CONCATENATE <lfs_cs_itm_cdoc_ref>-refno+30(10)
*                        is_vbrk-vbeln
                      lwa_hu_det-huident+10(10) "Last 10 char of HU from ewm
                                 INTO lv_deliv_inv.

            <lfs_cs_itm_cdoc_ref>-refno+20(20) = lv_deliv_inv.
          ENDIF. " IF sy-subrc = 0
          IF lv_deliv_inv IS NOT INITIAL.
            ASSIGN COMPONENT 'REF' OF STRUCTURE cs_hdr_cdoc  TO <lfs_cs_hdr_cdoc_ref_t>.
            IF <lfs_cs_hdr_cdoc_ref_t> IS ASSIGNED.
* Low entries so no Binary Search.
              READ TABLE <lfs_cs_hdr_cdoc_ref_t> ASSIGNING <lfs_cs_hdr_cdoc_ref>
                                                           WITH KEY refno+30(10) = <lfs_vbrp>-vgbel
                                                                    qual_refno  = 'EXTIDF'
                                                                    objtp       = 'LIKP'
                                                                    refapp      = 'SD0B'.

              IF sy-subrc = 0.
                <lfs_cs_hdr_cdoc_ref>-refno+20(20) = lv_deliv_inv.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF <lfs_cs_hdr_cdoc_ref_t> IS ASSIGNED
          ENDIF. " IF lv_deliv_inv IS NOT INITIAL
        ENDIF. " IF <lfs_cs_itm_cdoc_ref_t> IS ASSIGNED
* For Packaging data:

* Item level packaging data
        CLEAR: lwa_pge_data .
        ASSIGN COMPONENT 'PGE' OF STRUCTURE cs_itm_cdoc  TO <lfs_cs_itm_cdoc_pge_t>.
        IF <lfs_cs_itm_cdoc_pge_t> IS ASSIGNED.
          CLEAR: lv_random.
          lv_random = 1.
          lwa_pge_itmdata-int_id         = lv_random.
          CONDENSE lwa_pge_itmdata-int_id NO-GAPS.
          lwa_pge_itmdata-item_number    = lv_itm_num.
          lwa_pge_itmdata-quantity       = lwa_hu_det-qty.
          lwa_pge_itmdata-dim_uom        = lwa_hu_det-uom.
          APPEND lwa_pge_itmdata TO <lfs_cs_itm_cdoc_pge_t>.
          CLEAR: lwa_pge_itmdata.
* Begin of change for Defect # 8286 OTC_EDD_0415 by U033876
          DELETE <lfs_cs_itm_cdoc_pge_t> WHERE int_id NE lv_random.
* End of change for Defect # 8286 OTC_EDD_0415 by U033876
        ENDIF. " IF <lfs_cs_itm_cdoc_pge_t> IS ASSIGNED
        CLEAR: lwa_pge_data .

        ASSIGN COMPONENT 'PGE' OF STRUCTURE cs_hdr_cdoc  TO <lfs_cs_hdr_cdoc_pge_t>.
* Populate header only once for all line items
        IF <lfs_cs_hdr_cdoc_pge_t> IS ASSIGNED .
* Begin of change for Defect # 8286 OTC_EDD_0415 by U033876
* When PGI doen in EWM , it will update ECC with HU nos and internal no in VEKP
* are generted based on Delivery info.. We dont want this info to be sent to GTS
          DELETE <lfs_cs_hdr_cdoc_pge_t> WHERE int_id NE lv_random.
* End of change for Defect # 8286 OTC_EDD_0415 by U033876
          IF  <lfs_cs_hdr_cdoc_pge_t> IS INITIAL .
* Append only once for header
            lwa_pge_data-int_id         = lv_random.
            CONDENSE lwa_pge_data-int_id NO-GAPS.
            lwa_pge_data-ext_id         = lwa_hu_det-huident.
            SHIFT lwa_pge_data-ext_id LEFT DELETING LEADING '0'.
            lwa_pge_data-gross_weight   = lwa_hu_det-hu_wieght.
            lwa_pge_data-tare_weight    = lwa_hu_det-hu_wieght. "Total Gross Weight
            lwa_pge_data-dim_uom_tare   = lwa_hu_det-unit_gw. "Total Gross UOM
            lwa_pge_data-net_weight     = lwa_hu_det-n_wieght.
            lwa_pge_data-dim_uom        = lwa_hu_det-unit_gw.
            lwa_pge_data-pgemat_type    = '0001'.
            lwa_pge_data-number         = 1.
            APPEND lwa_pge_data TO <lfs_cs_hdr_cdoc_pge_t>.
            CLEAR: lwa_pge_data.
          ENDIF. " IF <lfs_cs_hdr_cdoc_pge_t> IS INITIAL
        ENDIF. " IF <lfs_cs_hdr_cdoc_pge_t> IS ASSIGNED

* Begin of change for 8317 for Dimensions add of components to header by u033876.
* below logic will add the weights from components into header bom for Hu level CI only
* for delivery level CI this happens in Routine 910

        ASSIGN COMPONENT 'DIM' OF STRUCTURE cs_itm_cdoc  TO <lfs_cs_itm_cdoc_dim_t>.
* for each components collect the weights and add it to bom header
        IF <lfs_cs_itm_cdoc_dim_t> IS ASSIGNED AND <lfs_vbrp>-uepos IS NOT INITIAL.
          APPEND LINES OF  <lfs_cs_itm_cdoc_dim_t> TO li_itm_dim.
          LOOP AT  li_itm_dim INTO  lwa_itm_dim
                              WHERE item_number+4(6) = <lfs_vbrp>-posnr.
            IF lwa_itm_dim-qual_dim = 'WEINET'.
              CLEAR: lwa_itm_dim_col-weigro , lwa_itm_dim_col-weigro_flt.
              lwa_itm_dim-item_number+4(6)     = <lfs_vbrp>-uepos.
              lwa_itm_dim_col-item_number      = lwa_itm_dim-item_number.
              lwa_itm_dim_col-dim_uom          = lwa_itm_dim-dim_uom .
              lwa_itm_dim_col-weinet           = lwa_itm_dim-dimen.
              lwa_itm_dim_col-weinet_flt       = lwa_itm_dim-dimen_flt.
              COLLECT lwa_itm_dim_col INTO li_itm_dim_col.
            ELSEIF lwa_itm_dim-qual_dim = 'WEIGRO'.
              CLEAR:lwa_itm_dim_col-weinet, lwa_itm_dim_col-weinet_flt .
              lwa_itm_dim-item_number+4(6)     = <lfs_vbrp>-uepos.
              lwa_itm_dim_col-item_number      = lwa_itm_dim-item_number.
              lwa_itm_dim_col-dim_uom          = lwa_itm_dim-dim_uom .
              lwa_itm_dim_col-weigro           = lwa_itm_dim-dimen.
              lwa_itm_dim_col-weigro_flt       = lwa_itm_dim-dimen_flt.
              COLLECT lwa_itm_dim_col INTO li_itm_dim_col.
            ENDIF. " IF lwa_itm_dim-qual_dim = 'WEINET'
          ENDLOOP. " LOOP AT li_itm_dim INTO lwa_itm_dim
          CLEAR:li_itm_dim[].
        ENDIF. " IF <lfs_cs_itm_cdoc_dim_t> IS ASSIGNED AND <lfs_vbrp>-uepos IS NOT INITIAL
* End of change for 8317 for Dimensions add of components to Header   by U033876

      ELSE. " ELSE -> IF sy-subrc = 0
* Do nothing for non hu level cI
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

* Begin of change for defect 7986 by U033876
    IF <lfs_vbrp>-uepos IS NOT INITIAL AND <lfs_cs_konv_val> IS ASSIGNED.
      APPEND LINES OF  <lfs_cs_konv_val> TO li_itm_cond_proc.
      LOOP AT  li_itm_cond_proc INTO  lwa_itm_cond_proc
                          WHERE item_number+4(6) = <lfs_vbrp>-posnr.
        lwa_itm_cond_proc-item_number+4(6) = <lfs_vbrp>-uepos.
        COLLECT lwa_itm_cond_proc INTO li_itm_comp_cond.
      ENDLOOP. " LOOP AT li_itm_cond_proc INTO lwa_itm_cond_proc
    ENDIF. " IF <lfs_vbrp>-uepos IS NOT INITIAL AND <lfs_cs_konv_val> IS ASSIGNED
* end of Change for defect 7986 by U033876
* End of Changes for D3_OTC_EDD_0415 , Sctask:SCTASK0660730

  ENDLOOP. " LOOP AT it_vbrp ASSIGNING <lfs_vbrp>

*&-- Begin of Changes for HANAtization on OTC_EDD_0013 by U106341 on 16-Sep-2019 E1SK901550
  ENDIF.
*&-- End of Changes for HANAtization on OTC_EDD_0013 by U106341 on 16-Sep-2019 E1SK901550

* Begin of change for defect 7986 by U033876 OTC_EDD_415
  UNASSIGN: <lfs_cond_comp_val>,<lfs_cond_val>.
  IF <lfs_cs_konv_val> IS ASSIGNED.
    LOOP AT li_itm_comp_cond ASSIGNING <lfs_cond_comp_val>.
      LOOP AT  <lfs_cs_konv_val> ASSIGNING <lfs_cond_val>
                                   WHERE item_number = <lfs_cond_comp_val>-item_number
                                   AND   qual_val    = <lfs_cond_comp_val>-qual_val.
        <lfs_cond_val> = <lfs_cond_comp_val>.
      ENDLOOP. " LOOP AT <lfs_cs_konv_val> ASSIGNING <lfs_cond_val>
    ENDLOOP. " LOOP AT li_itm_comp_cond ASSIGNING <lfs_cond_comp_val>
  ENDIF. " IF <lfs_cs_konv_val> IS ASSIGNED
* end of Change for defect 7986 by U033876 OTC_EDD_415

* Begin of change for 8317 for Dimensions add of components to Header OTC_EDD_415

  IF <lfs_cs_itm_cdoc_dim_t> IS ASSIGNED.
    CLEAR: lwa_itm_dim_col.
    LOOP AT li_itm_dim_col INTO lwa_itm_dim_col.
      LOOP AT  <lfs_cs_itm_cdoc_dim_t> ASSIGNING <lfs_dim_val>
                                   WHERE item_number = lwa_itm_dim_col-item_number.
        IF <lfs_dim_val>-qual_dim = 'WEINET'.
          <lfs_dim_val>-dimen     = lwa_itm_dim_col-weinet.
          <lfs_dim_val>-dimen_flt = lwa_itm_dim_col-weinet_flt.
          <lfs_dim_val>-dim_uom   = lwa_itm_dim_col-dim_uom.
        ELSEIF <lfs_dim_val>-qual_dim = 'WEIGRO'.
          <lfs_dim_val>-dimen     = lwa_itm_dim_col-weigro.
          <lfs_dim_val>-dimen_flt = lwa_itm_dim_col-weigro_flt.
          <lfs_dim_val>-dim_uom   = lwa_itm_dim_col-dim_uom.
        ENDIF. " IF <lfs_dim_val>-qual_dim = 'WEINET'
      ENDLOOP. " LOOP AT <lfs_cs_itm_cdoc_dim_t> ASSIGNING <lfs_dim_val>
    ENDLOOP. " LOOP AT li_itm_dim_col INTO lwa_itm_dim_col
  ENDIF. " IF <lfs_cs_itm_cdoc_dim_t> IS ASSIGNED
* End of change for 8317 for Dimensions add of components to Header OTC_EDD_415

* ---> Begin of Change Insert for D2_OTC_EDD_0013 by ASK
  FREE: li_kschl, lr_kschl, lr_kschl1, lr_kschl2, lr_kschl3,lr_kschl4.
* <--- End   of Change Insert for D2_OTC_EDD_0013 by ASK


*&---------------------------------------------------------------------*
*&-- (Retrofit) BOC: CR#1418 : RVERMA : 11-Sep-2014 (Retrofit)
*&---------------------------------------------------------------------*
*&--CR1418: Transmitting Ultimate Consignee Type value from Attribute 3
*&--field from customer master in ECC to Export Declaration document in
*&--GTS
*&---------------------------------------------------------------------*

  CONSTANTS:
*&--Header data item no
    lc_posnr_00  TYPE posnr      VALUE '000000', " Item number of the SD document
*&--Variant Name for Ship-to partner function constant
    lc_name_we   TYPE rvari_vnam VALUE 'ZOTC_EDD_0013_PARVW_WE', " ABAP: Name of Variant Variable
*&--Variant Name for End-User partner function constant
    lc_name_z5   TYPE rvari_vnam VALUE 'ZOTC_EDD_0013_PARVW_Z5', " ABAP: Name of Variant Variable
*&--Type of selection: P
    lc_type_p    TYPE rsscr_kind VALUE 'P', " ABAP: Type of selection
*&--Current selection number: 0000
    lc_numb_00   TYPE tvarv_numb VALUE '0000'. " ABAP: Current selection number

  DATA:
    li_vbpa      TYPE vbpavb_tab, "Partner Data Table
    li_tvarvc    TYPE tvarvc_t,   "TVARVC table
    lv_parvw_z5  TYPE parvw,      "Partner Function: Ultimate Consignee
    lv_parvw_we  TYPE parvw,      "Partner Function: Ship-to Party
    lv_kunnr     TYPE kunnr,      "Customer Number
    lv_katr3     TYPE katr3.      "Attribute3/Ultimate Consignee

  FIELD-SYMBOLS:
    <lfs_vbpa>   TYPE vbpavb, "Partner Data
    <lfs_tvarvc> TYPE tvarvc. "TVARVC Data


*&--Get Constant values of partner function from TVARVC
  SELECT *
    FROM tvarvc " Table of Variant Variables (Client-Specific)
    INTO TABLE li_tvarvc
    WHERE name IN (lc_name_we, lc_name_z5)
      AND type EQ lc_type_p
      AND numb EQ lc_numb_00.

  IF sy-subrc EQ 0.
*&--Read partner function for Ultimate Consignee
*&--No binary search as there will only 2 records
    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                         WITH KEY name = lc_name_z5.
    IF sy-subrc EQ 0.
      lv_parvw_z5 = <lfs_tvarvc>-low+0(2).
    ENDIF. " IF sy-subrc EQ 0
*&--Read partner function for ship-to
*&--No binary search as there will only 2 records
    READ TABLE li_tvarvc ASSIGNING <lfs_tvarvc>
                         WITH KEY name = lc_name_we.
    IF sy-subrc EQ 0.
      lv_parvw_we = <lfs_tvarvc>-low+0(2).
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0

  IF lv_parvw_z5 IS NOT INITIAL AND
     lv_parvw_we IS NOT INITIAL.

    li_vbpa[] = it_vbpa[].
    SORT li_vbpa BY posnr parvw.

*&--Get Customer Number from Partner data table based on
*&--Ultimate Consignee Partner function
    READ TABLE it_vbpa ASSIGNING <lfs_vbpa>
                       WITH KEY posnr = lc_posnr_00
                                parvw = lv_parvw_z5
                       BINARY SEARCH.
    IF sy-subrc IS INITIAL. "If Customer Number found for
 "Ultimate Consignee Partner Fn
      lv_kunnr = <lfs_vbpa>-kunnr.
    ELSE. " ELSE -> IF sy-subrc IS INITIAL
*&--Get Customer Number from Partner data table based on
*&--Ship-to Partner function
      READ TABLE it_vbpa ASSIGNING <lfs_vbpa>
                         WITH KEY posnr = lc_posnr_00
                                  parvw = lv_parvw_we
                         BINARY SEARCH.
      IF sy-subrc IS INITIAL. "If Customer Number found for
 "Ship-to Partner Fn
        lv_kunnr = <lfs_vbpa>-kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

    IF lv_kunnr IS NOT INITIAL.
*&--Fetch Attribute 3 value from KNA1
      SELECT SINGLE katr3 " Attribute 3
        FROM kna1         " General Data in Customer Master
        INTO lv_katr3
        WHERE kunnr EQ lv_kunnr.

      IF sy-subrc IS INITIAL.
*&--Populate Attribut 3 value to Ultimate Consignee
        cs_hdr_cdoc-gen-ultimate_cnee_type_code = lv_katr3+0(1).
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF lv_kunnr IS NOT INITIAL

  ENDIF. " IF lv_parvw_z5 IS NOT INITIAL AND
*&---------------------------------------------------------------------*
*&--(Retrofit) EOC: CR#1418 : RVERMA : 11-Sep-2014  (Retrofit)
*&---------------------------------------------------------------------*

**Begin of D3 changes - E1DK919194, AMANGAL

  READ TABLE it_vbrp ASSIGNING <lfs_vbrp> INDEX 1.

  IF sy-subrc EQ 0.

    SELECT SINGLE land1 " Country Key
      INTO lv_t001w_land1
      FROM t001w        " Plants/Branches
      WHERE werks EQ <lfs_vbrp>-werks.

    IF sy-subrc EQ 0.
      SELECT SINGLE land1 " Country Key
        INTO lv_t001_land1
        FROM t001         " Company Codes
        WHERE bukrs EQ is_vbrk-bukrs.

      IF sy-subrc EQ 0.
        IF lv_t001w_land1 NE lv_t001_land1.

          lv_vbrk_bukrs = is_vbrk-bukrs.
          lv_werks = <lfs_vbrp>-werks.

          CONDENSE lv_vbrk_bukrs.
          CONDENSE lv_werks.

          CONCATENATE lv_vbrk_bukrs lv_werks INTO lv_comp_plant.

          CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
            EXPORTING
              iv_enhancement_no = lc_d3_otc_edd_0013
            TABLES
              tt_enh_status     = li_status.

          DELETE li_status WHERE active = abap_false.

          READ TABLE li_status ASSIGNING <lfs_zdev_enh_status>
            WITH KEY criteria = lc_criteria
            sel_low = lv_comp_plant.

          IF sy-subrc EQ 0.
            cs_hdr_cdoc-gen-company_code = <lfs_zdev_enh_status>-sel_high.
          ENDIF. " IF sy-subrc EQ 0

        ENDIF. " IF lv_t001w_land1 NE lv_t001_land1
      ENDIF. " IF sy-subrc EQ 0

    ENDIF. " IF sy-subrc EQ 0

  ENDIF. " IF sy-subrc EQ 0

**End of D3 changes - E1DK919194 AMANGAL

ENDMETHOD.


  method /SAPSLL/IF_EX_IFEX_SD0C_R3~IF_EXTEND_PRE_PREFE.
  endmethod.


method /SAPSLL/IF_EX_IFEX_SD0C_R3~IF_EXTEND_PRE_VDWLO.
endmethod.
ENDCLASS.
