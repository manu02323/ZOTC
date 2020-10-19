class ZCL_IM_CL_IM_MX_INVOIC_CHK definition
  public
  final
  create public .

public section.

  interfaces IF_EX_IDOC_CREATION_CHECK .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_IM_MX_INVOIC_CHK IMPLEMENTATION.


METHOD if_ex_idoc_creation_check~idoc_data_check.
************************************************************************
* METHOD     :  IDOC_DATA_CHECK                                        *
* TITLE      :  D2_OTC_IDD_0111                                        *
* DEVELOPER  :  Vivek Gaur                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0111                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Control IDOC processing when retrigerred for an Invoice *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 09-APR-2015  VGAUR     E2DK908545  INITIAL DEVELOPMENT               *
* 28-APR-2015  VGAUR     E2DK908545  Defect# 6280                      *
* 08-MAY-2015  VGAUR     E2DK908545  CR D2_640                         *
*                                    Conversion of Invoice Number from *
*                                    EMI tool to internal Invoice No.  *
*                                    before comparing both Invoices    *
*08-SEP-2017   mthatha   E1DK930290  SCTASK0515243 CHANGES             *
************************************************************************


*----------------------------------------------------------------------*
*                         C O N S T A N T S                            *
*----------------------------------------------------------------------*
  CONSTANTS:
*&--Output Type: ZMEX
   lc_kschl_zmex    TYPE sna_kschl      VALUE 'ZMEX',                 "
*&--Application for message conditions: V3
   lc_kappl_v3      TYPE sna_kappl      VALUE 'V3',                   "
*&--Message transmission medium: A
   lc_nacha_a       TYPE na_nacha       VALUE 'A',                    "
*&--Processing status of message: 1
   lc_vstat_1       TYPE na_vstat       VALUE '1',                    "
*&--Posting document has been created
   lc_rfbsk_c       TYPE rfbsk          VALUE 'C',                    "
*Begin of insert for SCTASK0515243 for D3_OTC_IDD_0111 by Manoj Thatha
   lc_vbtyp_u       TYPE vbtyp          VALUE 'U',                    "
*End of insert for SCTASK0515243 for D3_OTC_IDD_0111 by Manoj Thatha
*&--Invoice Type
   lc_invoice_sd    TYPE z_invoice_type VALUE 'SD',                   "
*&--Criteria: Re-trigger Invoice
   lc_trig_invoice  TYPE z_criteria     VALUE 'IDOC_RETRIGGER_INV',   "
*&--IDOC qualifier: 008
   lc_qualf_008     TYPE edi_qualfr     VALUE '008',                  "
*&--IDOC qualifier: 012
   lc_qualf_012     TYPE edi_qualfr     VALUE '012',                  "
*&--IDoc: Document header general data
   lc_e1edk01       TYPE edilsegtyp     VALUE 'E1EDK01',              "
*&--IDoc: Document header date segment
   lc_e1edk03       TYPE edilsegtyp     VALUE 'E1EDK03',              "
*&--IDoc: Document Header Organizational Data
   lc_e1edk14       TYPE edilsegtyp     VALUE 'E1EDK14',              "
*&--Logical Message Variant: MXN
   lc_msgcod_mxn    TYPE edi_mescod     VALUE 'MXN',                  "
*&--Logical message function: OTC
   lc_mesfct_otc    TYPE edi_mesfct     VALUE 'OTC',                  "
*&--Message Type: INVOIC
   lc_idoctp_inv    TYPE edi_mestyp     VALUE 'INVOIC',               "
*&--Basic type: INVOIC02
   lc_bas_tp_inv    TYPE edi_idoctp     VALUE 'INVOIC02',             "
*&--Extension: ZRTRE_INVOIC02_01
   lc_ext_tp_inv    TYPE edi_cimtyp     VALUE 'ZRTRE_INVOIC02_01',    "
*&--Enhancement Number
   lc_idd_0111      TYPE z_enhancement  VALUE 'D2_OTC_IDD_0111_001',  "
   lc_01            TYPE zrtr_mx_einvoice-counter
                                        VALUE '01'.

*----------------------------------------------------------------------*
*                          V A R I A B L E S                           *
*----------------------------------------------------------------------*
  DATA:
   lv_kschl         TYPE sna_kschl,                " Output Type
   lv_vbeln         TYPE vbeln_vf,                 " Billing Document
   lv_bukrs         TYPE bukrs,                    " Company Code
   lv_gjahr         TYPE gjahr,                    " Fiscal Year
   lv_emi_vbeln     TYPE vbeln_vf,                 " Billing Document
   lv_exist         TYPE boolean,                  " Invoice Exist in EMI Tool
   lv_counter       TYPE zrtr_mx_einvoice-counter. " Counter for Idoc trigger

*----------------------------------------------------------------------*
*                         S T R U C T U R E S                          *
*----------------------------------------------------------------------*
  DATA:
   lx_e1edk01       TYPE e1edk01, " IDoc: Header Data
   lx_e1edk03       TYPE e1edk03, " IDoc: Document header date segment
   lx_e1edk14       TYPE e1edk14. " IDoc: Document Header Organizational Data

*----------------------------------------------------------------------*
*                    I N T E R N A L   T A B L E S                     *
*----------------------------------------------------------------------*
  DATA:
   li_en_status     TYPE zdev_tt_enh_status. " Enhancement Status

*----------------------------------------------------------------------*
*                     F I E L D    S Y M B O L S                       *
*----------------------------------------------------------------------*
  FIELD-SYMBOLS:
    <lfs_en_status> TYPE zdev_enh_status, " Enhancement Status
    <lfs_idoc_data> TYPE edidd.           " Data record (IDoc)

*----------------------------------------------------------------------*
*                             L O G I C                                *
*----------------------------------------------------------------------*

  create_idoc = abap_true.

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
  IF sy-subrc NE 0.
    EXIT.
  ENDIF. " IF sy-subrc NE 0

*&--Check if this is Mexico Invoice 810
  IF idoc_control-mescod = lc_msgcod_mxn AND
     idoc_control-mesfct = lc_mesfct_otc AND
     idoc_control-mestyp = lc_idoctp_inv AND
     idoc_control-idoctp = lc_bas_tp_inv AND
     idoc_control-cimtyp = lc_ext_tp_inv.

*&--Read Invoice Number
    READ TABLE idoc_data ASSIGNING <lfs_idoc_data>
                          WITH KEY segnam = lc_e1edk01.
    IF sy-subrc EQ 0.
      lx_e1edk01 = <lfs_idoc_data>-sdata.
      lv_vbeln   = lx_e1edk01-belnr.
    ENDIF. " IF sy-subrc EQ 0

*&--Read Sales Organization
    READ TABLE idoc_data ASSIGNING <lfs_idoc_data>
                          WITH KEY segnam   = lc_e1edk14
                                   sdata(3) = lc_qualf_008.
    IF sy-subrc EQ 0.
      lx_e1edk14 = <lfs_idoc_data>-sdata.
      lv_bukrs   = lx_e1edk14-orgid.
    ENDIF. " IF sy-subrc EQ 0

*&--Read Document Date
    READ TABLE idoc_data ASSIGNING <lfs_idoc_data>
                          WITH KEY segnam   = lc_e1edk03
                                   sdata(3) = lc_qualf_012.
    IF sy-subrc EQ 0.
      lx_e1edk03 = <lfs_idoc_data>-sdata.
      lv_gjahr   = lx_e1edk03-datum(4).
    ENDIF. " IF sy-subrc EQ 0

*&--Now check if the SD Invoice is relased to Accounting by checking
*&--the field VBRK-RFBSK=C(Posting document has been created).
    SELECT SINGLE vbeln " Billing Document
             FROM vbrk  " Billing Document: Header Data
             INTO lv_vbeln
            WHERE vbeln EQ lv_vbeln
*Begin of insert for SCTASK0515243 for D3_OTC_IDD_0111 by Manoj Thatha
*              AND rfbsk EQ lc_rfbsk_c.
               AND ( ( rfbsk EQ lc_rfbsk_c ) OR ( vbtyp EQ lc_vbtyp_u ) ).
*End of insert for SCTASK0515243 for D3_OTC_IDD_0111 by Manoj Thatha
    IF sy-subrc NE 0.
*&--If Invoice is not to be triggered do not create IDOC
      CLEAR: create_idoc.
    ELSE. " ELSE -> IF sy-subrc NE 0
*&--Check if Invoice already processed
      CLEAR lv_counter.
      SELECT SINGLE belnr counter    " Accounting Document Number
               FROM zrtr_mx_einvoice " Documents for Mexico E-Invoice Interface
               INTO (lv_vbeln, lv_counter)
              WHERE bukrs     EQ lv_bukrs
                AND gjahr     EQ lv_gjahr
                AND belnr     EQ lv_vbeln
                AND blart     EQ space
                AND inv_type  EQ lc_invoice_sd
                AND processed EQ abap_true.
      IF sy-subrc EQ 0 AND
         lv_counter GT lc_01.

* --> Begin of Comment for CR D2_640 by VGAUR
** --> Begin of Insert for Defect 6280
*
**&--Delete Leading Zeros from Invoice Number
*        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*          EXPORTING
*            input  = lv_vbeln
*          IMPORTING
*            output = lv_vbeln.
*
** <-- End of Insert for Defect 6280
* <-- End of Comment for CR D2_640 by VGAUR


* --> Begin of Insert for CR D2_640 by VGAUR
        DELETE li_en_status WHERE criteria   NE lc_trig_invoice.
        DELETE li_en_status WHERE sel_sign   NE if_cwd_constants=>c_sign_inclusive.
        DELETE li_en_status WHERE sel_option NE if_cwd_constants=>c_option_equals.

*&--Check if Invoice is set to be re-triggered
        LOOP AT li_en_status ASSIGNING <lfs_en_status>.

          lv_emi_vbeln = <lfs_en_status>-sel_low.

*&--Convert Invoice to Internal
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_emi_vbeln
            IMPORTING
              output = lv_emi_vbeln.

          IF lv_vbeln EQ lv_emi_vbeln.
            lv_exist = abap_true.
            EXIT.
          ENDIF. " IF lv_vbeln EQ lv_emi_vbeln

        ENDLOOP. " LOOP AT li_en_status ASSIGNING <lfs_en_status>

*&--If Invoice is not to be triggered do not create IDOC
        IF lv_exist NE abap_true.
          CLEAR: create_idoc.
        ENDIF. " IF lv_exist NE abap_true
* <-- End of Insert for CR D2_640 by VGAUR

* --> Begin of Comment for CR D2_640 by VGAUR
**&--Check if Invoice is set to be re-triggered
*        READ TABLE li_en_status ASSIGNING <lfs_en_status>
*          WITH KEY sel_sign = if_cwd_constants=>c_sign_inclusive
*                   criteria = lc_trig_invoice
*                    sel_low = lv_vbeln
*                 sel_option = if_cwd_constants=>c_option_equals.
*        IF sy-subrc NE 0.
**&--If Invoice is not to be triggered do not create IDOC
*          CLEAR: create_idoc.
*        ENDIF. " IF sy-subrc NE 0
* <-- End of Comment for CR D2_640 by VGAUR

      ELSE. " ELSE -> IF sy-subrc EQ 0 AND
        IF lv_counter = lc_01.
          create_idoc = abap_true.
        ELSE. " ELSE -> IF lv_counter = lc_01
*&--Invoice not to be triggered, do not create IDOC
          CLEAR: create_idoc.
        ENDIF. " IF lv_counter = lc_01
      ENDIF. " IF sy-subrc EQ 0 AND
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF idoc_control-mescod = lc_msgcod_mxn AND

ENDMETHOD.
ENDCLASS.
