***********************************************************************
*Program    : ZOTCN0009B_ORDER                                        *
*Title      : Inbound Sales Order EDI 850                             *
*Developer  : Pradipta K Mishra                                       *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0009                                           *
*---------------------------------------------------------------------*
*Description: Update custom field values, mail id in Order            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*22-May-2014  PMISHRA       E2DK900747     Initial Version
*---------------------------------------------------------------------*
*08-Aug-2014  PMISHRA       E2DK900747     Changes against Defect 312
*                                          and CR - D2_84 Updated logic for
*                                          updating email id for partner
*                                          function 'AP' and extended
*                                          the same logic for partner
*                                          functions 'ZA' and 'ZB'
*---------------------------------------------------------------------*
*17-Oct-2014  PMISHRA       E2DK900747     Changes against D2_21
*                                          Update value for Street 3
*                                          for partner function 'WE'
*                                          Update VBAP-ZZAGMNT and
*                                          VBAP-ZZAGMNT_TYP
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* 10/11/2014  APODDAR  E2DK900747 Defect # 1437 Street 2              *
* 10/11/2014  APODDAR  E2DK900747 Defect # 1481 Blank Postal Code     *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
*03-Dec-2014  PMISHRA  E2DK900747     Changes against Defect_1883, 1950_1966
*                                     Code changed to allow update of
*                                     street 2 and 3 for all cases (with and
*                                     without postal code provided in IDoc)
*                                     for partner function 'WE'. Also clear
*                                     the house number if either or all of these
*                                     - street, street2 or street 3 is provided
*---------------------------------------------------------------------*
*02-Apr-2015  MCHATTE  E2DK900747     Defect# 4905: Corrected logic to
*                                     populate Line refernce
*---------------------------------------------------------------------*
*05-May-2016  U033870  E1DK917543   Changes against D3_OTC_CDD_0005_  *
*                                   0007_0140 Extending BDC logic for *
*                                 Z fields, like Quota, Contract Begin*
*                                   and End dates, Bill Meth Bill Freq*
*                                    etc for partner type BOBJFTR     *
*28-Oct-2016 JAHANM  E1DK917543     Defect 5761 - correct KUNNR logic *
*10-Nov-2016 JAHANM  E1DK917543     Defect 5788 - more than two line
*                                   items issue.
*---------------------------------------------------------------------*
***INCLUDE ZOTCN0009B_ORDER
*---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*&      Form  F_UPDATE_BDCDATA
*&--------------------------------------------------------------------*
*& Purpose of this sub-routine is to update the values for custom fields
*& as well as email id for contact person. For this, BDCDATA needs to be
*& updated.
*----------------------------------------------------------------------*
*      -->FP_IDOC_DATA  Table Type for IDoc Data Records (EDIDD)
*      -->FP_LDYNPRO    Last Screen Number
*      <--FP_BDCDATA    Batch input: New table field structure
*----------------------------------------------------------------------*
FORM f_update_bdcdata USING fp_idoc_data   TYPE idoc_data    " IDoc Data Records (EDIDD)
                            fp_ldynpro     TYPE dynpronr     " Last Screen Number
                   CHANGING fp_bdcdata     TYPE bdcdata_tab. " Table Type for BDCDATA

  TYPES: BEGIN OF lty_posnr,
           posnr TYPE posnr_va, " Sales Document Item
         END OF lty_posnr,
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
         BEGIN OF lty_item_ref,
           posnr      TYPE posnr_va,    " Sales Document Item
           quote      TYPE z_quoteref,  " Legacy Qtn Ref
           agmnt      TYPE z_agmnt,     " Warr / Serv Plan ID
           agmnt_type TYPE z_agmnt_typ, " ID Type
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
           bill_mthd  TYPE z_bmethod,    " Billing Method
           bill_frq   TYPE z_bfrequency, " Billing Frequency
           srv_obj_id TYPE z_itemref,    " ServMax Obj ID
           vbegdat_itm   TYPE char10 ,   " line item Contract Start Date
           venddat_itm   TYPE char10 ,   " Line item Contract End Date
         END OF lty_item_ref,

         BEGIN OF lty_mat_srn,
           posnr    TYPE posnr_va,       " Sales Document Item
           matnr    TYPE matnr,          " Material Number
           sernr    TYPE gernr,          " Serial Number
         END OF  lty_mat_srn.


  DATA:  li_mat_srn  TYPE STANDARD TABLE OF lty_mat_srn INITIAL SIZE 0,
         lwa_mat_srn TYPE lty_mat_srn,
         lv_itemno1    TYPE posnr_va. " Sales Document Item
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

  DATA:
     li_item_ref  TYPE STANDARD TABLE OF lty_item_ref INITIAL SIZE 0,
     lwa_item_ref TYPE lty_item_ref,
     lv_itemno    TYPE posnr_va, " Sales Document Item
     lv_insert    TYPE sytabix.  " Index of Internal Tables


  FIELD-SYMBOLS: <lfs_s_item_ref> TYPE lty_item_ref.

*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966

  STATICS:
      lv_posnr TYPE posnr_va, " Posnr of type Integers
      lv_index TYPE numc1.    " Num1

  DATA:
    lv_tabix     TYPE sy-tabix  , " Index of Internal Tables
* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
    lv_email_za  TYPE ad_smtpadr, " E-Mail Address
    lv_email_zb  TYPE ad_smtpadr, " E-Mail Address
* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
    lv_fnam      TYPE fnam_____4,   " Field name
    lv_docref    TYPE z_docref  ,   " Legacy Doc Ref
    lv_doctyp    TYPE z_doctyp  ,   " Ref Doc type
    lv_quote     TYPE z_quoteref  , " Legacy Qtn Ref
    lv_email     TYPE ad_smtpadr,   " E-Mail Address
    lv_fval      TYPE bdc_fval  ,   " BDC field value
    lv_lines     TYPE sy-tfill  ,   " Row Number of Internal Tables
    lwa_e1edk02  TYPE e1edk02   ,   " IDoc: Document header reference data
    lwa_e1edka1  TYPE e1edka1   ,   " IDoc: Document Header Partner Information
    lwa_e1edp02  TYPE e1edp02   ,   " IDoc: Document Item Reference Data
    lwa_e1edp01  TYPE e1edp01   ,   " IDoc: Document Item General Data
*&-- Begin of Addition CR - D2_21 APODDAR
    lx_e1edka3   TYPE e1edka3   ,  " IDoc: Document Header Partner Information Additional Data
    lv_partn     TYPE partner   ,  " Partner number
    lv_strt_2    TYPE ad_strspp1,  " Street 2 "Restriction in screen field upto 40 char
    lv_stradd    TYPE ad_strspp1,  " Street 3 "Restriction in screen field upto 40 char
    lv_zagmnt    TYPE z_agmnt,     " Warr / Serv Plan ID
    lv_zagmnttyp TYPE z_agmnt_typ, " ID Type
*&-- End of Addition CR - D2_21 APODDAR
    lwa_bdcdata  TYPE bdcdata   , " Batch input: New table field structure
    lwa_posnr    TYPE lty_posnr , " Item Numbers
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
    lv_stras     TYPE edi3042_a, " Street and house number 1
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
    lwa_e1edk03      TYPE e1edk03,                                      " IDoc: Document header reference data
    lwa_e1edp03      TYPE e1edp03,                                      " IDoc: Document header reference data
    lwa_e1edp19      TYPE e1edp19,                                      " IDoc: Document header reference data
    lv_vbegdat_hdr   TYPE char10 ,                                      " Header Contract Start Date
    lv_venddat_hdr   TYPE char10 ,                                      " Header Contract End Date
    lv_vbegdat_itm   TYPE char10 ,                                      " Line Item Contract Start Date
    lv_venddat_itm   TYPE char10 ,                                      " Line Item Contract End Date
    lv_sydatum       TYPE sy-datum,                                     " Date for Conversion
    lv_return_date   TYPE char10,                                       " Date after Conversion
    lv_zbilmet       TYPE z_bmethod,                                    " Bill Method
    lv_zbilfr        TYPE z_bfrequency,                                 " Bill Frequency
    lv_zzagmnt       TYPE z_agmnt,                                      " Warr / Serv Plan ID
    lv_zzitemref     TYPE z_itemref,                                    " ServMax Obj ID
    lv_zzagmnt_typ   TYPE z_agmnt_typ,                                  " ID Type
    lv_fields         TYPE char50,                                      " Fiels of type CHAR50
    lv_pos_ind        TYPE numc2,                                       " Position index for POSNR
    lv_bdc_posnr      TYPE posnr_va,                                    " Posnr of type Integers
    li_constants TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
    lv_partner TYPE edi_sndprn.                                         " Partner Number of Sender
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

  DATA li_posnr TYPE STANDARD TABLE OF lty_posnr. " Item Numbers

  CONSTANTS:
      lc_flg_sel     TYPE bdc_fval     VALUE   'X'   , " BDC field value
      lc_parvw_ap    TYPE parvw        VALUE   'AP'  , " Partner Function
* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
      lc_parvw_za    TYPE parvw        VALUE   'ZA'  , " Partner Function
      lc_parvw_zb    TYPE parvw        VALUE   'ZB'  , " Partner Function
* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
      lc_qualf_z1    TYPE edi_qualfr   VALUE   'Z01' , " IDOC qualifier reference document
      lc_qualf_z2    TYPE edi_qualfr   VALUE   'Z02' , " IDOC qualifier reference document
      lc_qualf_z3    TYPE edi_qualfr   VALUE   'Z03' , " IDOC qualifier reference document
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
      lc_qualf_19    TYPE edi_qualfr   VALUE   '019' ,             " IDOC qualifier reference document
      lc_qualf_20    TYPE edi_qualfr   VALUE   '020' ,             " IDOC qualifier reference document
      lc_qualf_z4    TYPE edi_qualfr   VALUE   'Z04' ,             " IDOC qualifier reference document
      lc_qualf_z5    TYPE edi_qualfr   VALUE   'Z05' ,             " IDOC qualifier reference document
      lc_qualf_z6    TYPE edi_qualfr   VALUE   'Z06' ,             " IDOC qualifier reference document
      lc_qualf_z7    TYPE edi_qualfr   VALUE   'Z07' ,             " IDOC qualifier reference document
      lc_qualf_z8    TYPE edi_qualfr   VALUE   'Z08' ,             " IDOC qualifier reference document
      lc_qualf_z9    TYPE edi_qualfr   VALUE   'Z09' ,             " IDOC qualifier reference document
      lc_kunnr       TYPE bdc_fnam     VALUE   'KUWEV-KUNNR',      "Ship to Party
      lc_veda        TYPE bdc_fnam     VALUE   'VEDA-VBEGDAT',     "Contract Start Date
      lc_ucomm_pzku  TYPE syucomm      VALUE   'PZKU',             " Function code that PAI triggered
      lc_ucomm_poto  TYPE syucomm      VALUE   'POTO',             " Function code that PAI triggered
      lc_bobjftr_prt TYPE edi_sndprn   VALUE   'BOBJFTR',          " Partner Number of Sender
      lc_seg_e1edp19 TYPE edilsegtyp   VALUE   'E1EDP19',          " Segment type
      lc_4001        TYPE bdc_fval     VALUE   '4001',             "Screen Number 4001 for BDC
      lc_partner      TYPE z_criteria    VALUE 'PARTNER',          " Enh. Criteria
      lc_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0007', "Enhancement No.
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  lc_dynnr_4001  TYPE sydynnr      VALUE   '4001', " Current Screen Number
  lc_ucomm_kzku  TYPE syucomm      VALUE   'KZKU', " Function code that PAI triggered
  lc_ucomm_psde  TYPE syucomm      VALUE   'PSDE', " Function code that PAI triggered
  lc_ucomm_save  TYPE syucomm      VALUE   'SICH', " Function code that PAI triggered
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
  lc_ucomm_ent1  TYPE syucomm      VALUE   'ENT1', " Function code that PAI triggered
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
  lc_seg_e1edka1 TYPE edilsegtyp   VALUE   'E1EDKA1', " Segment type
  lc_seg_e1edk02 TYPE edilsegtyp   VALUE   'E1EDK02', " Segment type
  lc_seg_e1edp01 TYPE edilsegtyp   VALUE   'E1EDP01', " Segment type
  lc_seg_e1edp02 TYPE edilsegtyp   VALUE   'E1EDP02', " Segment type
*&-- Begin of Addition CR - D2_21 APODDAR
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  lc_seg_e1edk03 TYPE edilsegtyp   VALUE   'E1EDK03', " Segment type
  lc_seg_e1edp03 TYPE edilsegtyp   VALUE   'E1EDP03', " Segment type
  lc_x           TYPE char1        VALUE   'X',       " for BDC DATA where need to pass X
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  lc_fnam_okcode TYPE fnam_____4   VALUE   'BDC_OKCODE',            " Field name
  lc_fnam_parvw  TYPE fnam_____4   VALUE   'DV_PARVW',              " Field name
  lc_seg_e1edka3 TYPE edilsegtyp   VALUE   'E1EDKA3',               " Segment type
  lc_fnam_strt_1 TYPE fnam_____4   VALUE   'ADDR1_DATA-STR_SUPPL1', " Field name "Defect #1437
  lc_fnam_street TYPE fnam_____4   VALUE   'ADDR1_DATA-STR_SUPPL2', " Field name
  lc_parvw_we    TYPE parvw        VALUE   'WE'  ,                  " Partner Function
*&-- End of Addition CR - D2_21 APODDAR
  lc_fnam_email  TYPE fnam_____4   VALUE   'SZA1_D0100-SMTP_ADDR', " Field name
*&-- Begin of Defect # 1481
  lc_fnam_hnum   TYPE fnam_____4   VALUE   'ADDR1_DATA-HOUSE_NUM1'. " Field name
*&-- End of Defect # 1481

  FIELD-SYMBOLS: <lfs_edidd>    TYPE edidd,   " Data record (IDoc)
                 <lfs_bdcdata>  TYPE bdcdata. " Batch input: New table field structure
*&-- Begin of Defect # 4905
  CONSTANTS : lc_xaprau   TYPE char20 VALUE '(SAPLVEDA)XAPRAU'. " Xaprau of type CHAR20

  FIELD-SYMBOLS : <lfs_xaprau> TYPE char1. " Xaprau> of type CHAR1
*&-- End   of Defect # 4905

*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  FIELD-SYMBOLS: <lfs_fields> TYPE any,
                 <lfs_constant> TYPE zdev_enh_status. " Enhancement Status

*  Fetching Partner Number of Sender from  program SAPLVEDA
  lv_fields = '(SAPLVEDA)IDOC_CONTRL-SNDPRN '.
  ASSIGN (lv_fields) TO <lfs_fields> .
  IF <lfs_fields> IS ASSIGNED.
* EMI entry for Partner

*get the constants
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_enh_name
      TABLES
        tt_enh_status     = li_constants.
*If EMI table is not initial
    IF sy-subrc = 0 AND NOT li_constants[] IS INITIAL.
      DELETE li_constants WHERE active = abap_false.

      READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = lc_partner.
      IF sy-subrc = 0.
        lv_partner = <lfs_constant>-sel_low.
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF sy-subrc = 0 AND NOT li_constants[] IS INITIAL
      lv_partner = lc_bobjftr_prt.
    ENDIF. " IF sy-subrc = 0 AND NOT li_constants[] IS INITIAL

    IF <lfs_fields> = lv_partner. "lc_bobjftr_prt.

      PERFORM f_fetch_idoc_data USING fp_idoc_data   " IDoc Data Records (EDIDD)
                                      fp_ldynpro     " Last Screen Number
                                CHANGING fp_bdcdata. " Table Type for BDCDATA

    ELSE. " ELSE -> IF <lfs_fields> = lv_partner

*&--End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

*&-- Populate individual values and item numbers from incoming IDoc
      LOOP AT fp_idoc_data ASSIGNING <lfs_edidd>.
        CASE <lfs_edidd>-segnam.
          WHEN lc_seg_e1edka1. " 'E1EDKA1'
            lwa_e1edka1 = <lfs_edidd>-sdata.

*&-- Get the value of mail id from contact person segment data
            IF lwa_e1edka1-parvw = lc_parvw_ap   " 'AP' - Contact person
           AND lwa_e1edka1-ilnnr IS NOT INITIAL. " Mail Id
              lv_email = lwa_e1edka1-ilnnr.
            ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_ap

* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
            IF lwa_e1edka1-parvw = lc_parvw_za   " 'ZA' - Contact person
           AND lwa_e1edka1-ilnnr IS NOT INITIAL. " Mail Id
              lv_email_za = lwa_e1edka1-ilnnr.
            ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_za

            IF lwa_e1edka1-parvw = lc_parvw_zb   " 'ZB' - Contact person
           AND lwa_e1edka1-ilnnr IS NOT INITIAL. " Mail Id
              lv_email_zb = lwa_e1edka1-ilnnr.
            ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_zb

* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA

* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_21 by PMISHRA

            IF lwa_e1edka1-parvw = lc_parvw_we   " 'ZB' - Contact person
           AND lwa_e1edka1-partn IS NOT INITIAL. " Mail Id
              lv_partn  = lwa_e1edka1-partn.
              lv_strt_2 = lwa_e1edka1-strs2. " changed as a part of Defect # 1437
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
              lv_stras  = lwa_e1edka1-stras.
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
            ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_we

* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_21 by PMISHRA

          WHEN lc_seg_e1edk02. " 'E1EDK02'
            lwa_e1edk02 = <lfs_edidd>-sdata.
            IF lwa_e1edk02-qualf = lc_qualf_z1. " 'Z02'
              lv_docref = lwa_e1edk02-belnr.
            ELSEIF lwa_e1edk02-qualf = lc_qualf_z2. " 'Z02'
              lv_doctyp = lwa_e1edk02-belnr.
            ENDIF. " IF lwa_e1edk02-qualf = lc_qualf_z1

          WHEN lc_seg_e1edp01. " 'E1EDP01'
            lwa_e1edp01 = <lfs_edidd>-sdata.
*&-- Get the value of item numbers from incoming idoc
            IF NOT lwa_e1edp01-posex IS INITIAL.
              lwa_posnr-posnr = lwa_e1edp01-posex.
              APPEND lwa_posnr TO li_posnr.
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
*&-- Collect all the item numbers
              CLEAR lwa_item_ref.
              lwa_item_ref-posnr = lv_itemno = lwa_e1edp01-posex.
              APPEND lwa_item_ref TO li_item_ref.
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
            ENDIF. " IF NOT lwa_e1edp01-posex IS INITIAL
            CLEAR: lwa_posnr, lwa_e1edp01.

          WHEN lc_seg_e1edp02. " 'E1EDP02'
            lwa_e1edp02 = <lfs_edidd>-sdata.
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
            CLEAR lwa_item_ref.
            IF lwa_e1edp02-qualf = lc_qualf_z3. " 'Z03'.
              lwa_item_ref-quote = lwa_e1edp02-belnr.
              MODIFY li_item_ref FROM lwa_item_ref TRANSPORTING quote WHERE posnr = lv_itemno.
            ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z3

            IF lwa_e1edp02-qualf = lc_qualf_z1.
              lwa_item_ref-agmnt = lwa_e1edp02-belnr.
              MODIFY li_item_ref FROM lwa_item_ref TRANSPORTING agmnt WHERE posnr = lv_itemno.
            ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z1

            IF lwa_e1edp02-qualf = lc_qualf_z2.
              lwa_item_ref-agmnt_type = lwa_e1edp02-belnr.
              MODIFY li_item_ref FROM lwa_item_ref TRANSPORTING agmnt_type WHERE posnr = lv_itemno.
            ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z2
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966

*&-- Begin of Addition CR - D2_21 APODDAR
          WHEN lc_seg_e1edka3.
            lx_e1edka3 = <lfs_edidd>-sdata.
            IF lx_e1edka3-qualp = lc_qualf_z1. " 'Z01'.
              lv_stradd = lx_e1edka3-stdpn.
            ENDIF. " IF lx_e1edka3-qualp = lc_qualf_z1
*&-- End of Addition CR - D2_21 APODDAR
          WHEN OTHERS.
            CONTINUE.
        ENDCASE.
        CLEAR: lwa_e1edk02, lwa_e1edp02, lwa_e1edp01, lwa_e1edka1.
      ENDLOOP. " LOOP AT fp_idoc_data ASSIGNING <lfs_edidd>

      UNASSIGN <lfs_edidd>.

*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
      CLEAR: lv_itemno, lwa_item_ref.
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966


*&-- Use of BINARY SEARCH is not possible for any of the READ operation
*&-- on BDCDATA as the data will not be sorted and explicit SORT will
*&-- disturb the Sequence of Segments. And this will fail the IDoc while posting

*&-- Populate the values for Document Ref and Doc Type in Order Header
      IF fp_ldynpro = lc_dynnr_4001. " '4001'
        CLEAR lv_fval. lv_fval = lc_ucomm_kzku. " 'KZKU'.

        READ TABLE fp_bdcdata TRANSPORTING NO FIELDS WITH KEY fval = lv_fval.
        IF sy-subrc NE 0.
          CLEAR lv_fval. lv_fval = lv_docref.

          PERFORM f_populate_bdcdata USING:
                space   'BDC_OKCODE'     'KZKU'  fp_bdcdata,
                 lc_x    'SAPMV45A'       '4002'  fp_bdcdata,
                space   'VBAK-ZZDOCREF'  lv_fval fp_bdcdata.

          CLEAR lv_fval. lv_fval = lv_doctyp.

          PERFORM f_populate_bdcdata USING:
                space   'VBAK-ZZDOCTYP'   lv_fval   fp_bdcdata,
                space   'BDC_OKCODE'      '/EBACK'  fp_bdcdata.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF fp_ldynpro = lc_dynnr_4001

* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_21 by APODDAR

*&-- Update Street Address 3 for contact person under partner function 'WE'
      CLEAR: lv_fnam, lv_lines, lwa_bdcdata.
      READ TABLE fp_bdcdata TRANSPORTING NO FIELDS WITH KEY fnam = lc_fnam_street
                                                            fval = lv_stradd.
      IF sy-subrc NE 0.

        READ TABLE fp_bdcdata TRANSPORTING NO FIELDS WITH KEY fnam = lc_fnam_parvw
                                                              fval = lc_parvw_we.
        IF sy-subrc EQ 0.
          lv_tabix = sy-tabix + 1.
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
          lv_insert = lv_tabix.
          LOOP AT fp_bdcdata ASSIGNING <lfs_bdcdata> FROM lv_tabix.
            IF <lfs_bdcdata>-fnam = lc_fnam_parvw.
              EXIT.
            ENDIF. " IF <lfs_bdcdata>-fnam = lc_fnam_parvw
            IF <lfs_bdcdata>-fnam = lc_fnam_okcode
           AND <lfs_bdcdata>-fval = lc_ucomm_psde.
              lv_lines = sy-tabix.
              EXIT.
            ENDIF. " IF <lfs_bdcdata>-fnam = lc_fnam_okcode
          ENDLOOP. " LOOP AT fp_bdcdata ASSIGNING <lfs_bdcdata> FROM lv_tabix
          UNASSIGN <lfs_bdcdata>.

          IF NOT lv_lines IS INITIAL.
*** -- > Begin of Changes by APODDAR for Defect # 1437

            lv_lines = lv_lines + 2.
            lwa_bdcdata-fnam = lc_fnam_strt_1.
            lwa_bdcdata-fval = lv_strt_2.
            INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_lines.
*
**&-- Begin of Defect # 1481 If Street 2 is being overwritten Initialize House Numbr
            IF lv_strt_2 IS NOT INITIAL
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
            OR lv_stras  IS NOT INITIAL
            OR lv_stradd IS NOT INITIAL.
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883

              lv_lines = lv_lines + 2.
              lwa_bdcdata-fnam = lc_fnam_hnum.
              lwa_bdcdata-fval = space.
              INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_lines.
            ENDIF. " IF lv_strt_2 IS NOT INITIAL
*&-- End of Defect # 1481
** -- > End of Changes by APODDAR for Defect # 1437
            lv_lines = lv_lines + 2.
            lwa_bdcdata-fnam = lc_fnam_street.
            lwa_bdcdata-fval = lv_stradd.
            INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_lines.
          ELSE. " ELSE -> IF NOT lv_lines IS INITIAL
            lv_tabix = lv_insert.
            READ TABLE fp_bdcdata TRANSPORTING NO FIELDS WITH KEY fnam = lc_fnam_strt_1 " 'ADDR1_DATA-STR_SUPPL1'
                                                                  fval = lv_strt_2.
            IF sy-subrc NE 0.

              IF NOT lv_strt_2 IS INITIAL
              OR NOT lv_stradd IS INITIAL.

                CLEAR lwa_bdcdata.
                lwa_bdcdata-program  = 'SAPMV45A'.
                lwa_bdcdata-dynpro   = '4002'.
                lwa_bdcdata-dynbegin = abap_true.
                INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                CLEAR lwa_bdcdata.
                lv_tabix = lv_tabix + 1.
                lwa_bdcdata-fnam = 'GVS_TC_DATA-SELKZ(01)'.
                lwa_bdcdata-fval = abap_true.
                INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                CLEAR lwa_bdcdata.
                lv_tabix = lv_tabix + 1.
                lwa_bdcdata-fnam = lc_fnam_okcode. " 'BDC_OKCODE'.
                lwa_bdcdata-fval = lc_ucomm_psde.
                INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                CLEAR lwa_bdcdata.
                lv_tabix = lv_tabix + 1.
                lwa_bdcdata-program  = 'SAPLV09C'.
                lwa_bdcdata-dynpro   = '5000'.
                lwa_bdcdata-dynbegin = abap_true.
                INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                IF NOT lv_stradd IS INITIAL
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
                OR lv_stras  IS NOT INITIAL
                OR lv_stradd IS NOT INITIAL.
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883

                  CLEAR lwa_bdcdata.
                  lv_tabix = lv_tabix + 1.

                  lwa_bdcdata-fnam = lc_fnam_street.
                  lwa_bdcdata-fval = lv_stradd.
                  INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.
                ENDIF. " IF NOT lv_stradd IS INITIAL

                IF NOT lv_strt_2 IS INITIAL.
                  CLEAR lwa_bdcdata.
                  lv_tabix = lv_tabix + 1.
                  lwa_bdcdata-fnam = lc_fnam_strt_1.
                  lwa_bdcdata-fval = lv_strt_2.
                  INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                  CLEAR lwa_bdcdata.
                  lv_tabix = lv_tabix + 1.
                  lwa_bdcdata-fnam = lc_fnam_hnum.
                  lwa_bdcdata-fval = space.
                  INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                ENDIF. " IF NOT lv_strt_2 IS INITIAL

                CLEAR lwa_bdcdata.
                lv_tabix = lv_tabix + 1.
                lwa_bdcdata-fnam = lc_fnam_okcode. " 'BDC_OKCODE'
                lwa_bdcdata-fval = lc_ucomm_ent1. " 'ENT1'
                INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

                CLEAR lwa_bdcdata.
                lv_tabix = lv_tabix + 1.
                lwa_bdcdata-program  = 'SAPMV45A'.
                lwa_bdcdata-dynpro   = '4002'.
                lwa_bdcdata-dynbegin = abap_true.
                INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_tabix.

              ENDIF. " IF NOT lv_strt_2 IS INITIAL
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF NOT lv_lines IS INITIAL

*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883

*&-- Begin of Comment By PMISHRA_D2_OTC_IDD_0009_Defect 1883
*      LOOP AT fp_bdcdata ASSIGNING <lfs_bdcdata> FROM lv_tabix.
*        IF <lfs_bdcdata>-fnam = lc_fnam_okcode
*       AND <lfs_bdcdata>-fval = lc_ucomm_psde.
*          lv_lines = sy-tabix.
*          EXIT.
*        ENDIF. " IF <lfs_bdcdata>-fnam = lc_fnam_okcode
*      ENDLOOP. " LOOP AT fp_bdcdata ASSIGNING <lfs_bdcdata> FROM lv_tabix
*      UNASSIGN <lfs_bdcdata>.

*      IF NOT lv_lines IS INITIAL.
*** -- > Begin of Changes by APODDAR for Defect # 1437
*
*        lv_lines = lv_lines + 2.
*        lwa_bdcdata-fnam = lc_fnam_strt_1.
*        lwa_bdcdata-fval = lv_strt_2.
*        INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_lines.
*
**&-- Begin of Defect # 1481 If Street 2 is being overwritten Initialize House Numbr
*        IF lv_strt_2 IS NOT INITIAL.
*          lv_lines = lv_lines + 2.
*          lwa_bdcdata-fnam = lc_fnam_hnum.
*          lwa_bdcdata-fval = space.
*          INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_lines.
*        ENDIF. " IF lv_strt_2 IS NOT INITIAL
*&-- End of Defect # 1481
** -- > End of Changes by APODDAR for Defect # 1437
*      lv_lines = lv_lines + 2.
*      lwa_bdcdata-fnam = lc_fnam_street.
*      lwa_bdcdata-fval = lv_stradd.
*      INSERT lwa_bdcdata INTO fp_bdcdata INDEX lv_lines.
*    ENDIF. " IF sy-subrc EQ 0
*&-- End of Comment By PMISHRA_D2_OTC_IDD_0009_Defect 1883
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc NE 0
      CLEAR: lv_fnam, lv_lines, lwa_bdcdata.

* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_21 by APODDAR

      CLEAR lv_fval. lv_fval = lc_ucomm_psde. " 'PSDE'

      READ TABLE fp_bdcdata TRANSPORTING NO FIELDS WITH KEY fval = lv_fval.
      IF sy-subrc EQ 0.
* ---> Begin of Change For D2_OTC_IDD_0009 / Defect 312 by PMISHRA
*&-- Update Mail id for contact person under partner function 'AP'
        CLEAR lv_fnam.
        lv_fnam = lc_fnam_email.
        PERFORM f_update_mailid USING lc_parvw_ap
                                      lv_email
                                      lv_fnam
                             CHANGING fp_bdcdata[].

* ---> End of Change For D2_OTC_IDD_0009 / Defect 312 by PMISHRA

* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA

        CLEAR lv_fnam.
        lv_fnam = lc_fnam_email.

*&-- Update Mail id for contact person under partner function 'ZA'
        PERFORM f_update_mailid USING lc_parvw_za
                                      lv_email_za
                                      lv_fnam
                             CHANGING fp_bdcdata[].

*&-- Update Mail id for contact person under partner function 'ZB'
        PERFORM f_update_mailid USING lc_parvw_zb
                                      lv_email_zb
                                      lv_fnam
                             CHANGING fp_bdcdata[].
* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
      ENDIF. " IF sy-subrc EQ 0

      CLEAR lv_lines.
      DESCRIBE TABLE fp_bdcdata LINES lv_lines.

      READ TABLE fp_bdcdata INTO lwa_bdcdata INDEX lv_lines.
      IF sy-subrc EQ 0.
* On save clear item / counter number
        IF lwa_bdcdata-fval = lc_ucomm_save. " 'SICH'.
          CLEAR: lv_posnr, lv_index.
        ELSE. " ELSE -> IF lwa_bdcdata-fval = lc_ucomm_save

*&-- The BDCDATA will always have either 1 OR 2 as row number
*&-- value for order item in the table control instead of incrementing with 1
*&-- For ex either it will be VBAP-MATNR(1) or VBAP-MATNR(2) and like wise for
*&-- all the fields

          CLEAR: lv_fnam, lv_fval.

          lv_posnr = lv_posnr + 1. " Index For Table Read
          lv_index = lv_index + 1. " Row Number in BDCDATA

          IF lv_index GT 2. " Row Number
            lv_index = 2.
          ENDIF. " IF lv_index GT 2

          SORT li_posnr BY posnr.

*&-- Determine the current item number to be processed in BDCDATA
          READ TABLE li_posnr INTO lwa_posnr INDEX lv_posnr.
          IF sy-subrc EQ 0.
            lv_fval = lwa_posnr-posnr.
          ENDIF. " IF sy-subrc EQ 0
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
          READ TABLE li_item_ref ASSIGNING <lfs_s_item_ref> WITH KEY posnr = lv_posnr.
          IF sy-subrc EQ 0.
            IF <lfs_s_item_ref> IS ASSIGNED.
              CLEAR: lv_quote, lv_zagmnttyp, lv_zagmnt.
              lv_quote     = <lfs_s_item_ref>-quote.
              lv_zagmnt    = <lfs_s_item_ref>-agmnt.
              lv_zagmnttyp = <lfs_s_item_ref>-agmnt_type.
            ENDIF. " IF <lfs_s_item_ref> IS ASSIGNED
          ENDIF. " IF sy-subrc EQ 0
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966

          CONCATENATE 'VBAP-POSEX(' lv_index ')' INTO lv_fnam.
          CONDENSE lv_fnam.

*Begin of Defect# 4905
*As per the defect commented below code as READ statement was not working
*LOOP statement is written below

*&-- This will check whether BDCDATA is containing item details and if it is a new item
*&-- by comparing POSEX value.
*      READ TABLE fp_bdcdata TRANSPORTING NO FIELDS WITH KEY fnam = lv_fnam
*                                                            fval = lv_fval.
*
*      IF sy-subrc EQ 0.
*        PERFORM f_populate_bdcdata USING:
*               space  'BDC_OKCODE'  'ENT1'  fp_bdcdata,
*               lc_x    'SAPMV45A'    '4001'  fp_bdcdata.
*
*        CLEAR lv_fnam.
*        CONCATENATE 'RV45A-VBAP_SELKZ(' lv_index ')' INTO lv_fnam.
*        CONDENSE lv_fnam.
*
*        CLEAR lv_fval. lv_fval = lv_quote.
*
*        PERFORM f_populate_bdcdata USING:
*               space        lv_fnam            lc_flg_sel fp_bdcdata,
*               abap_true    'SAPMV45A'         '4001'     fp_bdcdata,
*               space        'BDC_OKCODE'       'PZKU'     fp_bdcdata,
*               abap_true    'SAPMV45A'         '4003'     fp_bdcdata,
*               space        'VBAP-ZZQUOTEREF'  lv_fval    fp_bdcdata.
**&-- Begin of Addition
*
*        CLEAR lv_fval. lv_fval = lv_zagmnttyp.
*        PERFORM f_populate_bdcdata USING:
*                    space        'VBAP-ZZAGMNT_TYP' lv_fval    fp_bdcdata.
*
*        CLEAR lv_fval. lv_fval = lv_zagmnt.
*        PERFORM f_populate_bdcdata USING:
*                       space        'VBAP-ZZAGMNT'     lv_fval    fp_bdcdata,
**&-- End of Addition
*                       space        'BDC_OKCODE'       'BACK'     fp_bdcdata.
*
*
*      ELSE. " ELSE -> IF sy-subrc EQ 0
*        lv_index = lv_index - 1.
*        lv_posnr = lv_posnr - 1.
*      ENDIF. " IF sy-subrc EQ 0

*Check if Fieldname has string VBAP-POSEX( and value = lv_fval.
*If found populate BDCDATA and exit

          LOOP AT fp_bdcdata INTO lwa_bdcdata WHERE fnam CS 'VBAP-POSEX('
                                                AND fval = lv_fval.

            PERFORM f_populate_bdcdata USING:
                   space  'BDC_OKCODE'  'ENT1'  fp_bdcdata,
                   lc_x    'SAPMV45A'    lc_4001  fp_bdcdata.

            CLEAR lv_fnam.
            ASSIGN (lc_xaprau) TO <lfs_xaprau>.
            IF <lfs_xaprau> IS ASSIGNED.
              IF <lfs_xaprau> = 'C'.
                MOVE 'RV45A-VBAP_SELKZ(01)' TO lv_fnam.
              ELSE. " ELSE -> IF <lfs_xaprau> = 'C'
                CONCATENATE 'RV45A-VBAP_SELKZ(' lv_index ')' INTO lv_fnam.
              ENDIF. " IF <lfs_xaprau> = 'C'
            ELSE. " ELSE -> IF <lfs_xaprau> IS ASSIGNED
              CONCATENATE 'RV45A-VBAP_SELKZ(' lv_index ')' INTO lv_fnam.
            ENDIF. " IF <lfs_xaprau> IS ASSIGNED
            CONDENSE lv_fnam.

            CLEAR lv_fval. lv_fval = lv_quote.

*-->Start of changes for Defect 5761 by Jahan.
            IF NOT lv_quote IS INITIAL.
*-->End of changes for Defect 5761 by Jahan.

              PERFORM f_populate_bdcdata USING:
                     space        lv_fnam            lc_flg_sel fp_bdcdata,
                     abap_true    'SAPMV45A'         lc_4001     fp_bdcdata,
                     space        'BDC_OKCODE'       'PZKU'     fp_bdcdata,
                     abap_true    'SAPMV45A'         '4003'     fp_bdcdata,
                     space        'VBAP-ZZQUOTEREF'  lv_fval    fp_bdcdata.
*&-- Begin of Addition

              CLEAR lv_fval. lv_fval = lv_zagmnttyp.
              PERFORM f_populate_bdcdata USING:
                          space        'VBAP-ZZAGMNT_TYP' lv_fval    fp_bdcdata.

              CLEAR lv_fval. lv_fval = lv_zagmnt.
              PERFORM f_populate_bdcdata USING:
                             space        'VBAP-ZZAGMNT'     lv_fval    fp_bdcdata,
*&-- End of Addition
                             space        'BDC_OKCODE'       'BACK'     fp_bdcdata.
            ENDIF. " IF NOT lv_quote IS INITIAL
            EXIT.
          ENDLOOP. " LOOP AT fp_bdcdata INTO lwa_bdcdata WHERE fnam CS 'VBAP-POSEX('
*End of Defect# 4905
          IF sy-subrc <> 0.
            lv_index = lv_index - 1.
            lv_posnr = lv_posnr - 1.
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF lwa_bdcdata-fval = lc_ucomm_save
      ELSE. " ELSE -> IF sy-subrc EQ 0
        lv_index = lv_index - 1.
        lv_posnr = lv_posnr - 1.
      ENDIF. " IF sy-subrc EQ 0
*&-- Start of Change D3_OTC_CDD_0005_0007_0140
    ENDIF. " IF <lfs_fields> = lv_partner
  ENDIF. " IF <lfs_fields> IS ASSIGNED
*&-- Start of Change D3_OTC_CDD_0005_0007_0140
ENDFORM. " F_UPDATE_BDCDATA
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_BDCDATA
*&---------------------------------------------------------------------*
*& Populate the BDCDATA internal table
*----------------------------------------------------------------------*
*      -->FP_DYN        BDC screen start
*      -->FP_FNAM       Field name
*      -->FP_FVAL       BDC field value
*      -->FP_I_BDCDATA  Batch input: New table field structure
*----------------------------------------------------------------------*
FORM f_populate_bdcdata USING fp_dyn       TYPE bdc_start    " BDC screen start
                              fp_fnam      TYPE fnam_____4   " Field name
                              fp_fval      TYPE bdc_fval     " BDC field value
                              fp_i_bdcdata TYPE bdcdata_tab. " Table Type for BDCDATA

  DATA lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure


*&-- Populate BDCDATA
  IF NOT fp_dyn IS INITIAL.
    lwa_bdcdata-program = fp_fnam. " Program Name
    lwa_bdcdata-dynpro  = fp_fval. " Dynpro Number
    lwa_bdcdata-dynbegin = fp_dyn. " Screen Begin
  ELSE. " ELSE -> IF NOT fp_dyn IS INITIAL
    lwa_bdcdata-fnam = fp_fnam. " Field Name
    lwa_bdcdata-fval = fp_fval. " Field Value
  ENDIF. " IF NOT fp_dyn IS INITIAL
  APPEND lwa_bdcdata TO fp_i_bdcdata.
ENDFORM. " F_POPULATE_BDCDATA
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_MAILID
*&---------------------------------------------------------------------*
*& Update Email id for partner functions 'AP', 'ZA' and 'ZB'
*----------------------------------------------------------------------*
*      -->FP_PARVW    Partner Function
*      -->FP_EMAIL    Email Id
*      <--FP_BDCDATA  BDCDATA
*----------------------------------------------------------------------*
FORM f_update_mailid USING fp_parvw   TYPE parvw      " Partner Function
                           fp_email   TYPE ad_smtpadr " E-Mail Address
                           fp_fnam    TYPE fnam_____4 " Field name
                  CHANGING fp_bdcdata TYPE bdcdata_tab.

*&-- Determine if the BDCDATA holds records for Partner function 'AP' and Value '99999'
*&-- As these values will be in different rows, need to LOOP and READ
*&-- Logic below is to first determine the position where BDCDATA has the values
*&-- AP and 99999 in consecutive 2 rows. Once the position is identified,
*&-- identify the position where the BDC details for filling other details are
*&-- populated for AP.

  DATA:
      lv_rowno     TYPE sytabix  ,   " Index of Internal Tables
      li_bdc_temp  TYPE bdcdata_tab, " Table Type for BDCDATA
      lv_tabix     TYPE sytabix,     " Index of Internal Tables
      lwa_bdc_data TYPE bdcdata.     " Batch input: New table field structure

  FIELD-SYMBOLS:
           <lfs_bdc_temp> TYPE bdcdata, " Batch input: New table field structure
           <lfs_bdcdata>  TYPE bdcdata. " Batch input: New table field structure

  CONSTANTS:
        lc_fnam_parnr  TYPE fnam_____4   VALUE   'DV_PARNR',   " Field name
        lc_fnam_parvw  TYPE fnam_____4   VALUE   'DV_PARVW',   " Field name
        lc_program     TYPE bdc_prog     VALUE   'SAPLV09C',   " BDC module pool
        lc_dyn_val     TYPE bdc_dynr     VALUE   '5000',       " BDC Screen number
        lc_fval_parnr  TYPE bdc_fval     VALUE   '0000099999'. " BDC field value

  li_bdc_temp[] = fp_bdcdata[].

  LOOP AT fp_bdcdata ASSIGNING <lfs_bdcdata> WHERE fnam = lc_fnam_parvw " 'DV_PARVW'
                                               AND fval = fp_parvw.
    lv_tabix = sy-tabix + 1.
    READ TABLE li_bdc_temp ASSIGNING <lfs_bdc_temp> INDEX lv_tabix.
    IF sy-subrc EQ 0
   AND <lfs_bdc_temp>-fnam = lc_fnam_parnr  " 'DV_PARNR'
   AND <lfs_bdc_temp>-fval = lc_fval_parnr. " '0000099999'.
      lv_rowno = sy-tabix.
      EXIT.
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT fp_bdcdata ASSIGNING <lfs_bdcdata> WHERE fnam = lc_fnam_parvw

*&-- Determine the position of AP/ZA/ZB records
  UNASSIGN <lfs_bdc_temp>. CLEAR lv_tabix.

  LOOP AT li_bdc_temp ASSIGNING <lfs_bdc_temp> FROM lv_rowno.
    IF <lfs_bdc_temp>-program = lc_program " 'SAPLV09C'
   AND <lfs_bdc_temp>-dynpro = lc_dyn_val. " '5000'.
      lv_tabix = sy-tabix + 1.
      READ TABLE fp_bdcdata ASSIGNING <lfs_bdcdata> INDEX lv_tabix.
      IF sy-subrc EQ 0.
*&-- Once Email id is updated in the BDCDATA, it will appear immediately in the next row
*&-- after PROGRAM NAME and DYNPRO value. If found then no need to re-insert the same record
*&-- else create the row in BDCDATA.
        IF <lfs_bdcdata>-fnam NE fp_fnam.
          CLEAR lwa_bdc_data.
          lwa_bdc_data-fnam = fp_fnam.
          lwa_bdc_data-fval = fp_email.
          INSERT lwa_bdc_data INTO fp_bdcdata INDEX lv_tabix.
          EXIT.
        ELSE. " ELSE -> IF <lfs_bdcdata>-fnam NE fp_fnam
          EXIT.
        ENDIF. " IF <lfs_bdcdata>-fnam NE fp_fnam
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF <lfs_bdc_temp>-program = lc_program
  ENDLOOP. " LOOP AT li_bdc_temp ASSIGNING <lfs_bdc_temp> FROM lv_rowno

  FREE li_bdc_temp.
  CLEAR: lwa_bdc_data, lv_tabix, lv_rowno.
  UNASSIGN: <lfs_bdc_temp>, <lfs_bdcdata>.
ENDFORM. " F_UPDATE_MAILID

*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
*&---------------------------------------------------------------------*
*&      Form  CONVERT_DATE_TO_EXTERNAL
*&---------------------------------------------------------------------*
*       Convert internal dat format to SAp external date format
*----------------------------------------------------------------------*
*      -->P_LV_SYDATUM  text
*      <--P_LV_RETURN_DATE  text
*----------------------------------------------------------------------*
FORM convert_date_to_external  USING    p_lv_sydatum TYPE sy-datum     " Current Date of Application Server
                               CHANGING p_lv_return_date TYPE char10 . " Current Date of Application Server
  CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
    EXPORTING
      date_internal            = p_lv_sydatum
    IMPORTING
      date_external            = p_lv_return_date
    EXCEPTIONS
      date_internal_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE e128(zotc_msg) " Invalid &.
    WITH 'Date'(001).
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " CONVERT_DATE_TO_EXTERNAL
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_IDOC_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FP_IDOC_DATA  text
*      -->P_TYPE  text
*      -->P_IDOC_DATA  text
*      -->P_FP_LDYNPRO  text
*      -->P_TYPE  text
*      -->P_DYNPRONR  text
*      <--P_FP_BDCDATA  text
*      <--P_TYPE  text
*      <--P_BDCDATA_TAB  text
*----------------------------------------------------------------------*
FORM f_fetch_idoc_data  USING    fp_fp_idoc_data
                                 TYPE
                                 idoc_data
                                 fp_fp_ldynpro
                                 TYPE
                                 dynpronr
                        CHANGING fp_fp_bdcdata
                                 TYPE
                                 bdcdata_tab.

  TYPES: BEGIN OF lty_posnr,
             posnr TYPE posnr_va, " Sales Document Item
           END OF lty_posnr,
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966
           BEGIN OF lty_item_ref,
             posnr      TYPE posnr_va,    " Sales Document Item
             quote      TYPE z_quoteref,  " Legacy Qtn Ref
             agmnt      TYPE z_agmnt,     " Warr / Serv Plan ID
             agmnt_type TYPE z_agmnt_typ, " ID Type
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
             bill_mthd  TYPE z_bmethod,    " Billing Method
             bill_frq   TYPE z_bfrequency, " Billing Frequency
             srv_obj_id TYPE z_itemref,    " ServMax Obj ID
             vbegdat_itm   TYPE char10 ,   " line item Contract Start Date
             venddat_itm   TYPE char10 ,   " Line item Contract End Date
           END OF lty_item_ref,

           BEGIN OF lty_mat_srn,
             posnr    TYPE posnr_va,       " Sales Document Item
             matnr    TYPE matnr,          " Material Number
             sernr    TYPE gernr,          " Serial Number
           END OF  lty_mat_srn.


  DATA:  li_mat_srn  TYPE STANDARD TABLE OF lty_mat_srn INITIAL SIZE 0,
         lwa_mat_srn TYPE lty_mat_srn,
         lv_itemno1    TYPE posnr_va. " Sales Document Item
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

  DATA:
     li_item_ref  TYPE STANDARD TABLE OF lty_item_ref INITIAL SIZE 0,
     lwa_item_ref TYPE lty_item_ref,
     lv_itemno    TYPE posnr_va, " Sales Document Item
     lv_insert    TYPE sytabix.  " Index of Internal Tables


  FIELD-SYMBOLS: <lfs_s_item_ref> TYPE lty_item_ref.

*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1950 / 1966

  STATICS:
      lv_posnr TYPE posnr_va, " Posnr of type Integers
      lv_index TYPE numc1.    " Num1

  DATA:
    lv_tabix     TYPE sy-tabix  , " Index of Internal Tables
* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
    lv_email_za  TYPE ad_smtpadr, " E-Mail Address
    lv_email_zb  TYPE ad_smtpadr, " E-Mail Address
* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
    lv_fnam      TYPE fnam_____4,   " Field name
    lv_docref    TYPE z_docref  ,   " Legacy Doc Ref
    lv_doctyp    TYPE z_doctyp  ,   " Ref Doc type
    lv_quote     TYPE z_quoteref  , " Legacy Qtn Ref
    lv_email     TYPE ad_smtpadr,   " E-Mail Address
    lv_fval      TYPE bdc_fval  ,   " BDC field value
    lv_lines     TYPE sy-tfill  ,   " Row Number of Internal Tables
    lwa_e1edk02  TYPE e1edk02   ,   " IDoc: Document header reference data
    lwa_e1edka1  TYPE e1edka1   ,   " IDoc: Document Header Partner Information
    lwa_e1edp02  TYPE e1edp02   ,   " IDoc: Document Item Reference Data
    lwa_e1edp01  TYPE e1edp01   ,   " IDoc: Document Item General Data
*&-- Begin of Addition CR - D2_21 APODDAR
    lx_e1edka3   TYPE e1edka3   ,  " IDoc: Document Header Partner Information Additional Data
    lv_partn     TYPE partner   ,  " Partner number
    lv_strt_2    TYPE ad_strspp1,  " Street 2 "Restriction in screen field upto 40 char
    lv_stradd    TYPE ad_strspp1,  " Street 3 "Restriction in screen field upto 40 char
    lv_zagmnt    TYPE z_agmnt,     " Warr / Serv Plan ID
    lv_zagmnttyp TYPE z_agmnt_typ, " ID Type
*&-- End of Addition CR - D2_21 APODDAR
    lwa_bdcdata  TYPE bdcdata   , " Batch input: New table field structure
    lwa_posnr    TYPE lty_posnr , " Item Numbers
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
    lv_stras     TYPE edi3042_a, " Street and house number 1
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
    lwa_e1edk03      TYPE e1edk03,                                      " IDoc: Document header reference data
    lwa_e1edp03      TYPE e1edp03,                                      " IDoc: Document header reference data
    lwa_e1edp19      TYPE e1edp19,                                      " IDoc: Document header reference data
    lv_vbegdat_hdr   TYPE char10 ,                                      " Header Contract Start Date
    lv_venddat_hdr   TYPE char10 ,                                      " Header Contract End Date
    lv_vbegdat_itm   TYPE char10 ,                                      " Line Item Contract Start Date
    lv_venddat_itm   TYPE char10 ,                                      " Line Item Contract End Date
    lv_sydatum       TYPE sy-datum,                                     " Date for Conversion
    lv_return_date   TYPE char10,                                       " Date after Conversion
    lv_zbilmet       TYPE z_bmethod,                                    " Bill Method
    lv_zbilfr        TYPE z_bfrequency,                                 " Bill Frequency
    lv_zzagmnt       TYPE z_agmnt,                                      " Warr / Serv Plan ID
    lv_zzitemref     TYPE z_itemref,                                    " ServMax Obj ID
    lv_zzagmnt_typ   TYPE z_agmnt_typ,                                  " ID Type
    lv_fields         TYPE char50,                                      " Fiels of type CHAR50
    lv_pos_ind        TYPE numc2,                                       " Position index for POSNR
    lv_bdc_posnr      TYPE posnr_va,                                    " Posnr of type Integers
    li_constants TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
    lv_partner TYPE edi_sndprn.                                         " Partner Number of Sender
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

  DATA li_posnr TYPE STANDARD TABLE OF lty_posnr. " Item Numbers

  CONSTANTS:
      lc_flg_sel     TYPE bdc_fval     VALUE   'X'   , " BDC field value
      lc_parvw_ap    TYPE parvw        VALUE   'AP'  , " Partner Function
* ---> Begin of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
      lc_parvw_za    TYPE parvw        VALUE   'ZA'  , " Partner Function
      lc_parvw_zb    TYPE parvw        VALUE   'ZB'  , " Partner Function
* ---> End of Change For D2_OTC_IDD_0009 / CR - D2_84 by PMISHRA
      lc_qualf_z1    TYPE edi_qualfr   VALUE   'Z01' , " IDOC qualifier reference document
      lc_qualf_z2    TYPE edi_qualfr   VALUE   'Z02' , " IDOC qualifier reference document
      lc_qualf_z3    TYPE edi_qualfr   VALUE   'Z03' , " IDOC qualifier reference document
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
      lc_qualf_19    TYPE edi_qualfr   VALUE   '019' ,             " IDOC qualifier reference document
      lc_qualf_20    TYPE edi_qualfr   VALUE   '020' ,             " IDOC qualifier reference document
      lc_qualf_z4    TYPE edi_qualfr   VALUE   'Z04' ,             " IDOC qualifier reference document
      lc_qualf_z5    TYPE edi_qualfr   VALUE   'Z05' ,             " IDOC qualifier reference document
      lc_qualf_z6    TYPE edi_qualfr   VALUE   'Z06' ,             " IDOC qualifier reference document
      lc_qualf_z7    TYPE edi_qualfr   VALUE   'Z07' ,             " IDOC qualifier reference document
      lc_qualf_z8    TYPE edi_qualfr   VALUE   'Z08' ,             " IDOC qualifier reference document
      lc_qualf_z9    TYPE edi_qualfr   VALUE   'Z09' ,             " IDOC qualifier reference document
      lc_kunnr       TYPE bdc_fnam     VALUE   'KUWEV-KUNNR',      "Ship to Party
      lc_veda        TYPE bdc_fnam     VALUE   'VEDA-VBEGDAT',     "Contract Start Date
      lc_ucomm_pzku  TYPE syucomm      VALUE   'PZKU',             " Function code that PAI triggered
      lc_ucomm_poto  TYPE syucomm      VALUE   'POTO',             " Function code that PAI triggered
      lc_bobjftr_prt TYPE edi_sndprn   VALUE   'BOBJFTR',          " Partner Number of Sender
      lc_seg_e1edp19 TYPE edilsegtyp   VALUE   'E1EDP19',          " Segment type
      lc_4001        TYPE bdc_fval     VALUE   '4001',             "Screen Number 4001 for BDC
      lc_partner      TYPE z_criteria    VALUE 'PARTNER',          " Enh. Criteria
      lc_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0007', "Enhancement No.
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  lc_dynnr_4001  TYPE sydynnr      VALUE   '4001', " Current Screen Number
  lc_ucomm_kzku  TYPE syucomm      VALUE   'KZKU', " Function code that PAI triggered
  lc_ucomm_psde  TYPE syucomm      VALUE   'PSDE', " Function code that PAI triggered
  lc_ucomm_save  TYPE syucomm      VALUE   'SICH', " Function code that PAI triggered
*&-- Begin of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
  lc_ucomm_ent1  TYPE syucomm      VALUE   'ENT1', " Function code that PAI triggered
*&-- End of Addition By PMISHRA_D2_OTC_IDD_0009_Defect 1883
  lc_seg_e1edka1 TYPE edilsegtyp   VALUE   'E1EDKA1', " Segment type
  lc_seg_e1edk02 TYPE edilsegtyp   VALUE   'E1EDK02', " Segment type
  lc_seg_e1edp01 TYPE edilsegtyp   VALUE   'E1EDP01', " Segment type
  lc_seg_e1edp02 TYPE edilsegtyp   VALUE   'E1EDP02', " Segment type
*&-- Begin of Addition CR - D2_21 APODDAR
*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  lc_seg_e1edk03 TYPE edilsegtyp   VALUE   'E1EDK03', " Segment type
  lc_seg_e1edp03 TYPE edilsegtyp   VALUE   'E1EDP03', " Segment type
  lc_x           TYPE char1        VALUE   'X',       " for BDC DATA where need to pass X
*&-- End of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  lc_fnam_okcode TYPE fnam_____4   VALUE   'BDC_OKCODE',            " Field name
  lc_fnam_parvw  TYPE fnam_____4   VALUE   'DV_PARVW',              " Field name
  lc_seg_e1edka3 TYPE edilsegtyp   VALUE   'E1EDKA3',               " Segment type
  lc_fnam_strt_1 TYPE fnam_____4   VALUE   'ADDR1_DATA-STR_SUPPL1', " Field name "Defect #1437
  lc_fnam_street TYPE fnam_____4   VALUE   'ADDR1_DATA-STR_SUPPL2', " Field name
  lc_parvw_we    TYPE parvw        VALUE   'WE'  ,                  " Partner Function
*&-- End of Addition CR - D2_21 APODDAR
  lc_fnam_email  TYPE fnam_____4   VALUE   'SZA1_D0100-SMTP_ADDR', " Field name
*&-- Begin of Defect # 1481
  lc_fnam_hnum   TYPE fnam_____4   VALUE   'ADDR1_DATA-HOUSE_NUM1'. " Field name
*&-- End of Defect # 1481

  FIELD-SYMBOLS: <lfs_edidd>    TYPE edidd,   " Data record (IDoc)
                 <lfs_bdcdata>  TYPE bdcdata, " Batch input: New table field structure
                 <lfs_edidd_1> TYPE edidd.    " Data record (IDoc)
*&-- Begin of Defect # 4905
  CONSTANTS : lc_xaprau   TYPE char20 VALUE '(SAPLVEDA)XAPRAU'. " Xaprau of type CHAR20

  FIELD-SYMBOLS : <lfs_xaprau> TYPE char1. " Xaprau> of type CHAR1
*&-- End   of Defect # 4905

*&-- Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
  FIELD-SYMBOLS: <lfs_fields> TYPE any,
                 <lfs_constant> TYPE zdev_enh_status. " Enhancement Status

*&-- Populate individual values and item numbers from incoming IDoc
  LOOP AT fp_fp_idoc_data ASSIGNING <lfs_edidd>.
    CASE <lfs_edidd>-segnam.
      WHEN lc_seg_e1edka1. " 'E1EDKA1'
        lwa_e1edka1 = <lfs_edidd>-sdata.

*&-- Get the value of mail id from contact person segment data
        IF lwa_e1edka1-parvw = lc_parvw_ap   " 'AP' - Contact person
       AND lwa_e1edka1-ilnnr IS NOT INITIAL. " Mail Id
          lv_email = lwa_e1edka1-ilnnr.
        ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_ap

        IF lwa_e1edka1-parvw = lc_parvw_za   " 'ZA' - Contact person
       AND lwa_e1edka1-ilnnr IS NOT INITIAL. " Mail Id
          lv_email_za = lwa_e1edka1-ilnnr.
        ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_za

        IF lwa_e1edka1-parvw = lc_parvw_zb   " 'ZB' - Contact person
       AND lwa_e1edka1-ilnnr IS NOT INITIAL. " Mail Id
          lv_email_zb = lwa_e1edka1-ilnnr.
        ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_zb

        IF lwa_e1edka1-parvw = lc_parvw_we   " 'WE' - Contact person
       AND lwa_e1edka1-partn IS NOT INITIAL. " Partner number
          lv_partn  = lwa_e1edka1-partn. "Partner number
          lv_strt_2 = lwa_e1edka1-strs2. "Street and house number 2
          lv_stras  = lwa_e1edka1-stras. "Street and house number 1
        ENDIF. " IF lwa_e1edka1-parvw = lc_parvw_we

      WHEN lc_seg_e1edk02. " 'E1EDK02'
        lwa_e1edk02 = <lfs_edidd>-sdata.
        IF lwa_e1edk02-qualf = lc_qualf_z1. " 'Z01'
          lv_docref = lwa_e1edk02-belnr.
        ELSEIF lwa_e1edk02-qualf = lc_qualf_z2. " 'Z02'
          lv_doctyp = lwa_e1edk02-belnr.
        ENDIF. " IF lwa_e1edk02-qualf = lc_qualf_z1

      WHEN lc_seg_e1edp01. " 'E1EDP01'
        lwa_e1edp01 = <lfs_edidd>-sdata.
*&-- Get the value of item numbers from incoming idoc
        IF NOT lwa_e1edp01-posex IS INITIAL.
          lwa_posnr-posnr = lwa_e1edp01-posex.
          APPEND lwa_posnr TO li_posnr.
*&-- Collect all the item numbers

          UNASSIGN <lfs_s_item_ref>.
          APPEND INITIAL LINE TO li_item_ref ASSIGNING <lfs_s_item_ref>.
          <lfs_s_item_ref>-posnr = lwa_e1edp01-posex.
          lv_itemno = lwa_e1edp01-posex.
        ENDIF. " IF NOT lwa_e1edp01-posex IS INITIAL
        CLEAR lwa_posnr.
        CLEAR lwa_e1edp01.

      WHEN lc_seg_e1edp02. " 'E1EDP02'
        CHECK <lfs_s_item_ref> IS ASSIGNED.
        lwa_e1edp02 = <lfs_edidd>-sdata.
*            CLEAR lwa_item_ref.

        IF lwa_e1edp02-qualf = lc_qualf_z3. " Quote Ref
          <lfs_s_item_ref>-quote = lwa_e1edp02-belnr.
        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z3

        IF lwa_e1edp02-qualf = lc_qualf_z4. " Z04  Warr / Serv Plan ID
          <lfs_s_item_ref>-agmnt = lwa_e1edp02-belnr.
        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z4

        IF lwa_e1edp02-qualf = lc_qualf_z5. " Z05  ServMax Obj ID
          <lfs_s_item_ref>-srv_obj_id = lwa_e1edp02-belnr.
        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z5

        IF lwa_e1edp02-qualf = lc_qualf_z6. " Z06 ID Type
          <lfs_s_item_ref>-agmnt_type = lwa_e1edp02-belnr.
        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z6

        IF lwa_e1edp02-qualf = lc_qualf_z7. " Z07 Bill Method
          <lfs_s_item_ref>-bill_mthd = lwa_e1edp02-belnr.
        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z7

        IF lwa_e1edp02-qualf = lc_qualf_z8. " Z07 Bill Frequency
          <lfs_s_item_ref>-bill_frq = lwa_e1edp02-belnr.
        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z8

        IF lwa_e1edp02-qualf = lc_qualf_z9. " Z07 Serial Number
          READ TABLE fp_fp_idoc_data ASSIGNING <lfs_edidd_1> WITH KEY
                                 segnam = lc_seg_e1edp19
                                 psgnum = <lfs_edidd>-psgnum.
          IF sy-subrc = 0.
            lwa_e1edp19 = <lfs_edidd_1>-sdata.
            lwa_mat_srn-matnr =  lwa_e1edp19-idtnr.
          ENDIF. " IF sy-subrc = 0
          lwa_mat_srn-posnr = lv_itemno.
          lwa_mat_srn-sernr = lwa_e1edp02-belnr.
          APPEND lwa_mat_srn TO li_mat_srn.

        ENDIF. " IF lwa_e1edp02-qualf = lc_qualf_z9
      WHEN lc_seg_e1edka3.
        lx_e1edka3 = <lfs_edidd>-sdata.
        IF lx_e1edka3-qualp = lc_qualf_z1. " 'Z01'.
          lv_stradd = lx_e1edka3-stdpn.
        ENDIF. " IF lx_e1edka3-qualp = lc_qualf_z1

      WHEN lc_seg_e1edk03.
        lwa_e1edk03 = <lfs_edidd>-sdata.
        IF lwa_e1edk03-iddat = lc_qualf_19. " '019'.
          IF ( lwa_e1edk03-datum IS NOT INITIAL ) OR
             ( lwa_e1edk03-datum NE space ).
            CLEAR lv_sydatum.
            CLEAR lv_return_date.
            lv_sydatum = lwa_e1edk03-datum.
            PERFORM convert_date_to_external
                             USING lv_sydatum
                             CHANGING lv_return_date.
            IF lv_return_date IS NOT INITIAL.
              lv_vbegdat_hdr = lv_return_date.
            ENDIF. " IF lv_return_date IS NOT INITIAL
          ENDIF. " IF ( lwa_e1edk03-datum IS NOT INITIAL ) OR
        ENDIF. " IF lwa_e1edk03-iddat = lc_qualf_19
        IF lwa_e1edk03-iddat = lc_qualf_20. " '020'.
          IF lwa_e1edk03-datum IS NOT INITIAL OR
             lwa_e1edk03-datum NE space.

            CLEAR lv_sydatum.
            CLEAR lv_return_date.
            lv_sydatum = lwa_e1edk03-datum.
            PERFORM convert_date_to_external
                             USING lv_sydatum
                             CHANGING lv_return_date.
            IF lv_return_date IS NOT INITIAL.
              lv_venddat_hdr = lv_return_date.
            ENDIF. " IF lv_return_date IS NOT INITIAL
          ENDIF. " IF lwa_e1edk03-datum IS NOT INITIAL OR
        ENDIF. " IF lwa_e1edk03-iddat = lc_qualf_20
      WHEN lc_seg_e1edp03.
        CHECK <lfs_s_item_ref> IS  ASSIGNED.
        lwa_e1edp03 = <lfs_edidd>-sdata.
        IF lwa_e1edp03-iddat = lc_qualf_19. " '019'.
          IF lwa_e1edp03-datum IS NOT INITIAL OR
             lwa_e1edp03-datum NE space.

            CLEAR lv_sydatum.
            CLEAR lv_return_date.
            lv_sydatum = lwa_e1edp03-datum.
            PERFORM convert_date_to_external
             USING lv_sydatum
             CHANGING lv_return_date.
            IF lv_return_date IS NOT INITIAL.
              lv_vbegdat_itm = lv_return_date.
              <lfs_s_item_ref>-vbegdat_itm = lv_vbegdat_itm.
            ENDIF. " IF lv_return_date IS NOT INITIAL

          ENDIF. " IF lwa_e1edp03-datum IS NOT INITIAL OR
        ENDIF. " IF lwa_e1edp03-iddat = lc_qualf_19
        IF lwa_e1edp03-iddat = lc_qualf_20. " '020'.
          IF lwa_e1edp03-datum IS NOT INITIAL OR
             lwa_e1edp03-datum NE space.

            CLEAR lv_sydatum.
            CLEAR lv_return_date.

            lv_sydatum = lwa_e1edp03-datum.

            PERFORM convert_date_to_external
             USING lv_sydatum
             CHANGING lv_return_date.
            IF lv_return_date IS NOT INITIAL.
              lv_venddat_itm = lv_return_date.
              <lfs_s_item_ref>-venddat_itm = lv_venddat_itm.
            ENDIF. " IF lv_return_date IS NOT INITIAL
          ENDIF. " IF lwa_e1edp03-datum IS NOT INITIAL OR
        ENDIF. " IF lwa_e1edp03-iddat = lc_qualf_20

      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
    CLEAR lwa_e1edk02.
    CLEAR lwa_e1edp02.
    CLEAR lwa_e1edp01.
    CLEAR lwa_e1edka1.
    CLEAR: lwa_e1edp03.
    CLEAR lwa_e1edk03.
    CLEAR  lwa_e1edp19.
    CLEAR lwa_mat_srn.

  ENDLOOP. " LOOP AT fp_fp_idoc_data ASSIGNING <lfs_edidd>

  UNASSIGN: <lfs_edidd_1>,
             <lfs_s_item_ref>.
  UNASSIGN <lfs_edidd>.
  CLEAR: lv_venddat_itm.
  CLEAR lv_vbegdat_itm.
  CLEAR lv_itemno.
  CLEAR lwa_item_ref.

*&-- Use of BINARY SEARCH is not possible for any of the READ operation
*&-- on BDCDATA as the data will not be sorted and explicit SORT will
*&-- disturb the Sequence of Segments. And this will fail the IDoc while posting
*&-- Populate the values for Document Ref and Doc Type in Order Header

*&-- Populate the values for Document Ref and Doc Type in Order Header
  IF fp_fp_ldynpro = lc_dynnr_4001. " '4001'

    CLEAR lv_fnam.
    lv_fnam = lc_kunnr.
    READ TABLE fp_fp_bdcdata
    TRANSPORTING NO FIELDS
    WITH KEY fnam = lv_fnam.
    IF sy-subrc EQ 0.
      CLEAR lv_fnam.
      lv_fnam = lc_veda.
      READ TABLE fp_fp_bdcdata
      TRANSPORTING NO FIELDS
      WITH KEY fnam = lv_fnam.
      IF sy-subrc NE 0.
        IF lv_vbegdat_hdr IS NOT INITIAL.
          CLEAR lv_fval.
          lv_fval = lv_vbegdat_hdr. " VENDDAT.
*          Populating BDC data for screen 4001
          PERFORM f_populate_bdcdata USING:
                space   'BDC_OKCODE'      'UER1' fp_fp_bdcdata,
               lc_x    'SAPMV45A'       lc_4001  fp_fp_bdcdata,
                space   'VEDA-VBEGDAT'  lv_fval    fp_fp_bdcdata.

          CLEAR lv_fval.
          lv_fval = lv_venddat_hdr. " VENDDAT.
          PERFORM f_populate_bdcdata USING:
                space   'VEDA-VENDDAT'   lv_fval   fp_fp_bdcdata,
                space   'BDC_OKCODE'      'UER1' fp_fp_bdcdata.
        ENDIF. " IF lv_vbegdat_hdr IS NOT INITIAL
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF sy-subrc EQ 0
    CLEAR lv_fval.
    lv_fval = lc_ucomm_kzku. " 'KZKU'.

    READ TABLE fp_fp_bdcdata
    TRANSPORTING NO FIELDS
    WITH KEY fval = lv_fval.
    IF sy-subrc NE 0.

      CLEAR lv_fval.
      lv_fval = lv_docref.
*Populating BDC data for screen 4002
      PERFORM f_populate_bdcdata USING:
            space   'BDC_OKCODE'     'KZKU'  fp_fp_bdcdata,
             lc_x    'SAPMV45A'       '4002'  fp_fp_bdcdata,
            space   'VBAK-ZZDOCREF'  lv_fval fp_fp_bdcdata.

      CLEAR lv_fval.
      lv_fval = lv_doctyp.

      PERFORM f_populate_bdcdata USING:
            space   'VBAK-ZZDOCTYP'   lv_fval   fp_fp_bdcdata,
            space   'BDC_OKCODE'      '/EBACK'  fp_fp_bdcdata.
    ENDIF. " IF sy-subrc NE 0

    CLEAR lv_fval.

  ENDIF. " IF fp_fp_ldynpro = lc_dynnr_4001

*&-- Update Street Address 3 for contact person under partner function 'WE'
  CLEAR lv_fnam.
  CLEAR lv_lines.
  CLEAR lwa_bdcdata.
  READ TABLE fp_fp_bdcdata
  TRANSPORTING NO FIELDS
  WITH KEY fnam = lc_fnam_street
           fval = lv_stradd.
  IF sy-subrc NE 0.

    READ TABLE fp_fp_bdcdata
    TRANSPORTING NO FIELDS
    WITH KEY fnam = lc_fnam_parvw
             fval = lc_parvw_we.
    IF sy-subrc EQ 0.
      lv_tabix = sy-tabix + 1.
      lv_insert = lv_tabix.
      LOOP AT fp_fp_bdcdata ASSIGNING <lfs_bdcdata> FROM lv_tabix.
        IF <lfs_bdcdata>-fnam = lc_fnam_parvw.
          EXIT.
        ENDIF. " IF <lfs_bdcdata>-fnam = lc_fnam_parvw
        IF <lfs_bdcdata>-fnam = lc_fnam_okcode
       AND <lfs_bdcdata>-fval = lc_ucomm_psde.
          lv_lines = sy-tabix.
          EXIT.
        ENDIF. " IF <lfs_bdcdata>-fnam = lc_fnam_okcode
      ENDLOOP. " LOOP AT fp_fp_bdcdata ASSIGNING <lfs_bdcdata> FROM lv_tabix
      UNASSIGN <lfs_bdcdata>.

      IF NOT lv_lines IS INITIAL.

        lv_lines = lv_lines + 2.
        lwa_bdcdata-fnam = lc_fnam_strt_1.
        lwa_bdcdata-fval = lv_strt_2.
        INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_lines.
*
        IF lv_strt_2 IS NOT INITIAL
        OR lv_stras  IS NOT INITIAL
        OR lv_stradd IS NOT INITIAL.

          lv_lines = lv_lines + 2.
          lwa_bdcdata-fnam = lc_fnam_hnum.
          lwa_bdcdata-fval = space.
          INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_lines.
        ENDIF. " IF lv_strt_2 IS NOT INITIAL

        lv_lines = lv_lines + 2.
        lwa_bdcdata-fnam = lc_fnam_street.
        lwa_bdcdata-fval = lv_stradd.
        INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_lines.
      ELSE. " ELSE -> IF NOT lv_lines IS INITIAL
        lv_tabix = lv_insert.
        READ TABLE fp_fp_bdcdata
        TRANSPORTING NO FIELDS
        WITH KEY fnam = lc_fnam_strt_1 " 'ADDR1_DATA-STR_SUPPL1'
                 fval = lv_strt_2.
        IF sy-subrc NE 0.

          IF NOT lv_strt_2 IS INITIAL
          OR NOT lv_stradd IS INITIAL.

            CLEAR lwa_bdcdata.
            lwa_bdcdata-program  = 'SAPMV45A'.
            lwa_bdcdata-dynpro   = '4002'.
            lwa_bdcdata-dynbegin = abap_true.
            INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

            CLEAR lwa_bdcdata.
            lv_tabix = lv_tabix + 1.
            lwa_bdcdata-fnam = 'GVS_TC_DATA-SELKZ(01)'.
            lwa_bdcdata-fval = abap_true.
            INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

            CLEAR lwa_bdcdata.
            lv_tabix = lv_tabix + 1.
            lwa_bdcdata-fnam = lc_fnam_okcode. " 'BDC_OKCODE'.
            lwa_bdcdata-fval = lc_ucomm_psde.
            INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

            CLEAR lwa_bdcdata.
            lv_tabix = lv_tabix + 1.
            lwa_bdcdata-program  = 'SAPLV09C'.
            lwa_bdcdata-dynpro   = '5000'.
            lwa_bdcdata-dynbegin = abap_true.
            INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

            IF NOT lv_stradd IS INITIAL
            OR lv_stras  IS NOT INITIAL.

              CLEAR lwa_bdcdata.
              lv_tabix = lv_tabix + 1.
              lwa_bdcdata-fnam = lc_fnam_street.
              lwa_bdcdata-fval = lv_stradd.
              INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.
            ENDIF. " IF NOT lv_stradd IS INITIAL

            IF NOT lv_strt_2 IS INITIAL.
              CLEAR lwa_bdcdata.
              lv_tabix = lv_tabix + 1.
              lwa_bdcdata-fnam = lc_fnam_strt_1.
              lwa_bdcdata-fval = lv_strt_2.
              INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

              CLEAR lwa_bdcdata.
              lv_tabix = lv_tabix + 1.
              lwa_bdcdata-fnam = lc_fnam_hnum.
              lwa_bdcdata-fval = space.
              INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

            ENDIF. " IF NOT lv_strt_2 IS INITIAL

            CLEAR lwa_bdcdata.
            lv_tabix = lv_tabix + 1.
            lwa_bdcdata-fnam = lc_fnam_okcode. " 'BDC_OKCODE'
            lwa_bdcdata-fval = lc_ucomm_ent1. " 'ENT1'
            INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

            CLEAR lwa_bdcdata.
            lv_tabix = lv_tabix + 1.
            lwa_bdcdata-program  = 'SAPMV45A'.
            lwa_bdcdata-dynpro   = '4002'.
            lwa_bdcdata-dynbegin = abap_true.
            INSERT lwa_bdcdata INTO fp_fp_bdcdata INDEX lv_tabix.

          ENDIF. " IF NOT lv_strt_2 IS INITIAL
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF NOT lv_lines IS INITIAL
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc NE 0
  CLEAR lv_fnam.
  CLEAR lv_lines.
  CLEAR lwa_bdcdata.
  CLEAR lv_fval.
  lv_fval = lc_ucomm_psde. " 'PSDE'

  READ TABLE fp_fp_bdcdata
  TRANSPORTING NO FIELDS
  WITH KEY fval = lv_fval.
  IF sy-subrc EQ 0.
*&-- Update Mail id for contact person under partner function 'AP'
    CLEAR lv_fnam.
    lv_fnam = lc_fnam_email.
    PERFORM f_update_mailid USING lc_parvw_ap
                                  lv_email
                                  lv_fnam
                         CHANGING fp_fp_bdcdata[].

*&-- Update Mail id for contact person under partner function 'ZA'
    PERFORM f_update_mailid USING lc_parvw_za
                                  lv_email_za
                                  lv_fnam
                         CHANGING fp_fp_bdcdata[].

*&-- Update Mail id for contact person under partner function 'ZB'
    PERFORM f_update_mailid USING lc_parvw_zb
                                  lv_email_zb
                                  lv_fnam
                         CHANGING fp_fp_bdcdata[].
  ENDIF. " IF sy-subrc EQ 0

  CLEAR lv_lines.
  DESCRIBE TABLE fp_fp_bdcdata LINES lv_lines.

  READ TABLE fp_fp_bdcdata INTO lwa_bdcdata INDEX lv_lines.
  IF sy-subrc EQ 0.
* On save clear item / counter number
    IF lwa_bdcdata-fval = lc_ucomm_save. " 'SICH'.
      CLEAR  lv_posnr.
      CLEAR  lv_index.
    ELSE. " ELSE -> IF lwa_bdcdata-fval = lc_ucomm_save

*&-- The BDCDATA will always have either 1 OR 2 as row number
*&-- value for order item in the table control instead of incrementing with 1
*&-- For ex either it will be VBAP-MATNR(1) or VBAP-MATNR(2) and like wise for
*&-- all the fields

      CLEAR lv_fnam.
      CLEAR lv_fval.

      lv_posnr = lv_posnr + 1. " Index For Table Read
      lv_index = lv_index + 1. " Row Number in BDCDATA

      SORT li_posnr BY posnr.
      SORT li_mat_srn BY posnr.
*&-- Determine the current item number to be processed in BDCDATA
      READ TABLE li_posnr INTO lwa_posnr INDEX lv_posnr.
      IF sy-subrc EQ 0.
        lv_fval = lwa_posnr-posnr.
      ENDIF. " IF sy-subrc EQ 0

      READ TABLE li_item_ref
      ASSIGNING <lfs_s_item_ref>
      WITH KEY posnr = lwa_posnr-posnr.
      IF sy-subrc EQ 0.
        IF <lfs_s_item_ref> IS ASSIGNED.
          CLEAR:
            lv_quote,
            lv_zbilmet,
            lv_zbilfr,
            lv_zagmnt,
            lv_zzitemref,
            lv_zzagmnt_typ,
            lv_vbegdat_itm,
            lv_venddat_itm.

          lv_quote       = <lfs_s_item_ref>-quote. " Quotation
          lv_zbilmet     = <lfs_s_item_ref>-bill_mthd. " Bill Method
          lv_zbilfr      = <lfs_s_item_ref>-bill_frq. " Bill Frequency
          lv_zzagmnt     = <lfs_s_item_ref>-agmnt. " Warr / Serv Plan ID
          lv_zzitemref   = <lfs_s_item_ref>-srv_obj_id. " ServMax Obj ID
          lv_zzagmnt_typ = <lfs_s_item_ref>-agmnt_type. " ID Type
          lv_vbegdat_itm = <lfs_s_item_ref>-vbegdat_itm. " Line Item Contract Begin date
          lv_venddat_itm = <lfs_s_item_ref>-venddat_itm. " Line Item Contract End Date
        ENDIF. " IF <lfs_s_item_ref> IS ASSIGNED
      ENDIF. " IF sy-subrc EQ 0

      CLEAR lv_fnam.
      CONCATENATE 'VBAP-POSEX(' lv_index ')' INTO lv_fnam.
      CONDENSE lv_fnam.

*--Start of defect# 5788 By Jahan
*&-- The BDCDATA will always have either 1 OR 2 as row number
*&-- value for order item in the table control instead of incrementing with 1
*&-- For ex either it will be VBAP-MATNR(1) or VBAP-MATNR(2) and like wise for
*&-- all the fields
      IF lv_index GT 2. " Row Number
        lv_index = 2.
      ENDIF. " IF lv_index GT 2
*--End of defect# 5788 By Jahan

      LOOP AT fp_fp_bdcdata INTO lwa_bdcdata
      WHERE fnam CS lv_fnam
      AND   fval = lv_fval.

* code to add Billing Method and billing Frequency
        IF lv_zbilmet IS NOT INITIAL.

          PERFORM f_populate_bdcdata USING:
                 abap_true    'SAPLSPO4'     '0300'     fp_fp_bdcdata.

          CLEAR lv_fval.
          lv_fval = lv_zbilmet.
          PERFORM f_populate_bdcdata USING:
                         space   'SVALD-VALUE(01)'  lv_fval    fp_fp_bdcdata.

          CLEAR lv_fval.
          lv_fval = lv_zbilfr.
          PERFORM f_populate_bdcdata USING:
                         space   'SVALD-VALUE(02)'  lv_fval    fp_fp_bdcdata,
                         space   'BDC_OKCODE'       '/00'     fp_fp_bdcdata,
                               lc_x    'SAPMV45A'    lc_4001  fp_fp_bdcdata.
        ENDIF. " IF lv_zbilmet IS NOT INITIAL

        CLEAR lv_fval.
        lv_fval = lc_ucomm_pzku. " 'PZKU'.

        PERFORM f_populate_bdcdata USING:
               space  'BDC_OKCODE'  'ENT1'  fp_fp_bdcdata,
               lc_x    'SAPMV45A'    lc_4001  fp_fp_bdcdata.
*          For testing removing ENDIF fom here and placing before Endloop.
        CLEAR lv_fnam.
        ASSIGN (lc_xaprau) TO <lfs_xaprau>.
        IF <lfs_xaprau> IS ASSIGNED.
          IF <lfs_xaprau> = 'C'.
            MOVE 'RV45A-VBAP_SELKZ(01)' TO lv_fnam.
          ELSE. " ELSE -> IF <lfs_xaprau> = 'C'
            CONCATENATE 'RV45A-VBAP_SELKZ(' lv_index ')' INTO lv_fnam.
          ENDIF. " IF <lfs_xaprau> = 'C'
        ELSE. " ELSE -> IF <lfs_xaprau> IS ASSIGNED
          CONCATENATE 'RV45A-VBAP_SELKZ(' lv_index ')' INTO lv_fnam.
        ENDIF. " IF <lfs_xaprau> IS ASSIGNED
        CONDENSE lv_fnam.

        CLEAR lv_fval.
        lv_fval = lv_quote.

**** Populate all Z fields like Agmt type, Agrmt, Item ref
        PERFORM f_populate_bdcdata USING:
               space        lv_fnam            lc_flg_sel fp_fp_bdcdata,
               abap_true    'SAPMV45A'         lc_4001     fp_fp_bdcdata,
               space        'BDC_OKCODE'       'PZKU'     fp_fp_bdcdata,
               abap_true    'SAPMV45A'         '4003'     fp_fp_bdcdata,
               space        'VBAP-ZZQUOTEREF'  lv_fval    fp_fp_bdcdata.

        CLEAR lv_fval.
        lv_fval = lv_zzagmnt_typ.
        PERFORM f_populate_bdcdata USING:
               space        'VBAP-ZZAGMNT_TYP' lv_fval    fp_fp_bdcdata.

        CLEAR lv_fval.
        lv_fval = lv_zzagmnt.
        PERFORM f_populate_bdcdata USING:
               space     'VBAP-ZZAGMNT'     lv_fval    fp_fp_bdcdata.

        CLEAR lv_fval.
        lv_fval = lv_zzitemref.
        PERFORM f_populate_bdcdata USING:
               space      'VBAP-ZZITEMREF'    lv_fval    fp_fp_bdcdata.

***** Method to populate Contract Begin and Contract End date at line Item
        IF lv_vbegdat_itm IS NOT INITIAL.
          CLEAR lv_fval.
          lv_fval = lv_vbegdat_itm.

          PERFORM f_populate_bdcdata USING:
                  abap_true    'SAPMV45A'         '4003'     fp_fp_bdcdata,
                  space        'BDC_OKCODE'       'T\03'     fp_fp_bdcdata,
                  abap_true    'SAPLV45W'         lc_4001     fp_fp_bdcdata,
                  space        'VEDA-VBEGDAT'     lv_fval    fp_fp_bdcdata.

          CLEAR lv_fval.
          lv_fval = lv_venddat_itm.
          PERFORM f_populate_bdcdata USING:
                         space        'VEDA-VENDDAT'     lv_fval    fp_fp_bdcdata,
                         space        'BDC_OKCODE'       'S\BACK'   fp_fp_bdcdata,
                         abap_true    'SAPMV45A'         lc_4001     fp_fp_bdcdata.
        ELSE. " ELSE -> IF lv_vbegdat_itm IS NOT INITIAL
          PERFORM f_populate_bdcdata USING:
           space        'BDC_OKCODE'       'BACK'     fp_fp_bdcdata.
        ENDIF. " IF lv_vbegdat_itm IS NOT INITIAL

        IF NOT li_mat_srn IS INITIAL.
          lv_bdc_posnr = lwa_bdcdata-fval.
          READ TABLE li_mat_srn
          TRANSPORTING NO FIELDS
          WITH KEY posnr = lv_bdc_posnr.
          IF sy-subrc EQ 0.

            CONCATENATE 'RV45A-VBAP_SELKZ(' lv_index ')' INTO lv_fnam.
            CLEAR lv_fval.
            lv_fval = lc_ucomm_poto.

            PERFORM f_populate_bdcdata USING:
                   abap_true    'SAPMV45A'         lc_4001     fp_fp_bdcdata,
                   space        lv_fnam            lc_flg_sel fp_fp_bdcdata,
                   abap_true    'SAPMV45A'         lc_4001     fp_fp_bdcdata,
                   space        'BDC_OKCODE'       lv_fval     fp_fp_bdcdata,
                   abap_true    'SAPLIWOL'         '0220'     fp_fp_bdcdata.


            LOOP AT li_mat_srn INTO lwa_mat_srn
                               WHERE posnr = lv_bdc_posnr.
              CLEAR: lv_fnam.
              CLEAR lv_fval.

              lv_pos_ind = lv_pos_ind + 1. " after 9 need to do page down
              IF lv_pos_ind >= 3.
                PERFORM f_populate_bdcdata USING:
*                          abap_true    'SAPLIWOL'         '0220'      fp_bdcdata,
                      space        'BDC_OKCODE'       'NEWE'     fp_fp_bdcdata, " to add new entry
                      abap_true    'SAPLIWOL'         '0220'     fp_fp_bdcdata.
                lv_pos_ind = 2 . "New Line will always be second line
              ENDIF. " IF lv_pos_ind >= 3
              CONCATENATE 'RIWOL-SERNR(' lv_pos_ind ')' INTO lv_fnam.
              lv_fval = lwa_mat_srn-sernr.
              PERFORM f_populate_bdcdata USING:
                     space        lv_fnam  lv_fval    fp_fp_bdcdata.

              CLEAR: lv_fnam.
              CLEAR: lv_fval.
              lv_fval = lwa_mat_srn-matnr.
              CONCATENATE 'RIWOL-MATNR(' lv_pos_ind ')' INTO lv_fnam.
              PERFORM f_populate_bdcdata USING:
                     space        lv_fnam  lv_fval    fp_fp_bdcdata.
            ENDLOOP. " LOOP AT li_mat_srn INTO lwa_mat_srn
            CLEAR lv_pos_ind.
            PERFORM f_populate_bdcdata USING:
                     abap_true    'SAPLIWOL'         '0220'      fp_fp_bdcdata,
                     space        'BDC_OKCODE'       '=BACK'     fp_fp_bdcdata,
                     abap_true    'SAPMV45A'         lc_4001     fp_fp_bdcdata,
                     space        'BDC_OKCODE'       'BACK'     fp_fp_bdcdata.
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF NOT li_mat_srn IS INITIAL

      ENDLOOP. " LOOP AT fp_fp_bdcdata INTO lwa_bdcdata

      IF sy-subrc <> 0.
        lv_index = lv_index - 1.
        lv_posnr = lv_posnr - 1.
      ENDIF. " IF sy-subrc <> 0

    ENDIF. " IF lwa_bdcdata-fval = lc_ucomm_save
  ELSE. " ELSE -> IF sy-subrc EQ 0
    lv_index = lv_index - 1.
    lv_posnr = lv_posnr - 1.

  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " F_FETCH_IDOC_DATA
