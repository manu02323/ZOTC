FUNCTION zotc_0337_billquan_00503114.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(FIS_CALLER) TYPE  CHAR1 DEFAULT SPACE
*"     REFERENCE(FIS_VBREVK) TYPE  VBREVKVB OPTIONAL
*"     REFERENCE(FIS_VBREVE) TYPE  VBREVEVB OPTIONAL
*"     REFERENCE(FIS_VBREVR) TYPE  VBREVRVB OPTIONAL
*"  CHANGING
*"     REFERENCE(FCF_CHANGE) TYPE  C DEFAULT SPACE
*"     REFERENCE(FCS_ACCIT) TYPE  ACCIT
*"     REFERENCE(FCS_ACCCR) TYPE  ACCCR
*"     REFERENCE(FCF_BUDAT) TYPE  WWERT_D
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM          :  ZOTC_0337_BILLQUAN_00503114 (Function Module)    *
* TITLE            :  Include billing quantities in Stock              *
* DEVELOPER        :  NASRIN ALI                                       *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D3_OTC_EDD_0337                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  Interface for BTE 00503114 to include billing    *
*                     quantities in Stock                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 01-JUN-2016  NALI     E1DK918440  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
* 14-Dec-2016 U029382 E1DK918440    Changes for Def 7468               *
* Def 7468: Missing qty and cogs in copa document for rev. recognition *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 14-Dec-2016 U033814 E1DK925654    Changes for Def 9529               *
* Def 9529: Fix required for Defect 7468 as always First Delivery is   *
* getting updated                                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 14-Feb-2019 U024694 E1DK937871    D#6336 / INC0391338-07             *
*                                   UOM conversion in Material Master  *
*&---------------------------------------------------------------------*


  DATA: lwa_fklmg_sum TYPE ty_fklmg_sum.
*  FIELD-SYMBOLS: <lfs_xlips>  TYPE ty_xlips.
  CONSTANTS: lc_char_f TYPE char01 VALUE 'F', " Char_f of type CHAR01
             lc_char_b TYPE char01 VALUE 'B', " Char_b of type CHAR01
             lc_char_j TYPE char01 VALUE 'J', " Char_j of type CHAR01
             lc_char_t TYPE char01 VALUE 'T'. " Char_t of type CHAR01

  STATICS: BEGIN OF lst_vbreve,
            vbeln     TYPE vbeln_va,    " Sales Document
            posnr     TYPE posnr_va,    " Sales Document Item
            sakrv     TYPE saknr,       " G/L Account Number
            bdjpoper  TYPE rr_bdjpoper, " Posting year and posting period (YYYYMMM format)
            popupo    TYPE rr_popupo,   " Period sub-item
            vbeln_n   TYPE vbeln_nach,  " Subsequent sales and distribution document
            posnr_n   TYPE posnr_nach,  " Subsequent item of an SD document
          END OF lst_vbreve.

  CHECK NOT ( fis_vbreve-vbeln EQ lst_vbreve-vbeln AND
    fis_vbreve-posnr EQ lst_vbreve-posnr AND
    fis_vbreve-sakrv EQ lst_vbreve-sakrv AND
    fis_vbreve-bdjpoper EQ lst_vbreve-bdjpoper AND
    fis_vbreve-popupo EQ lst_vbreve-popupo AND
    fis_vbreve-vbeln_n EQ lst_vbreve-vbeln_n AND
    fis_vbreve-posnr_n EQ lst_vbreve-posnr_n ) OR
    fis_caller EQ lc_char_f.

  MOVE-CORRESPONDING fis_vbreve TO lst_vbreve.
* Process only performance-based items (Type B)
* in case of amounts
  CHECK fis_vbrevk-rrrel = lc_char_b.

  CASE fis_caller.
    WHEN lc_char_f.

* invoice -> delete updated fields to avoid double postings
      CLEAR: fcs_accit-fkimg,
             fcs_accit-vrkme,
             fcs_accit-fklmg.

    WHEN space.

* only delivery or retoure items or invoice
      CHECK fis_vbreve-vbtyp_n = lc_char_t OR
            fis_vbreve-vbtyp_n = lc_char_j.

      CHECK NOT fis_vbreve-vbeln_n IS INITIAL AND
            NOT fis_vbreve-posnr_n IS INITIAL.

* Changes by Rajendra for Def 7468 by Rajendra on 12/14/2016
**      VF44 fill fields with additional information.
*      READ TABLE i_xlips WITH KEY vbeln = fis_vbreve-vbeln_n
*                                  posnr = fis_vbreve-posnr_n
*                                  BINARY SEARCH.
*     IF sy-subrc NE 0.
* Begin of Defect 9529
* Check if XLIPS is having a previous delivery details then
* reselect the New Delivery Details by clearing the I_XLIPS.
      READ TABLE i_xlips WITH KEY vbeln = fis_vbreve-vbeln_n
                                  posnr = fis_vbreve-posnr_n
                                  BINARY SEARCH.
      IF sy-subrc NE 0.
        REFRESH i_xlips.
      ENDIF. " IF sy-subrc NE 0
* End of Defect 9529
      IF i_xlips[] IS INITIAL.
* Changes by Rajendra for Def 7468 by Rajendra on 12/14/2016

        SELECT * FROM lips " SD document: Delivery: Item data
        INTO TABLE i_xlips
        WHERE vbeln = fis_vbreve-vbeln_n.
*        ORDER BY PRIMARY KEY. " Changes by Rajendra for Def 7468 by Rajendra on 12/14/2016
        IF sy-subrc = 0.
          SORT i_xlips BY vbeln posnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF i_xlips[] IS INITIAL

      READ TABLE i_xlips WITH KEY vbeln = fis_vbreve-vbeln_n
                                  posnr = fis_vbreve-posnr_n
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_fklmg_sum-vbeln = fis_vbreve-vbeln.
        lwa_fklmg_sum-posnr = fis_vbreve-posnr.
        lwa_fklmg_sum-sakrv = fis_vbreve-sakrv.
        lwa_fklmg_sum-fklmg = i_xlips-lfimg.
        lwa_fklmg_sum-vrkme = i_xlips-vrkme.
* Begin of Delete: U024694: 19-Jul-2018: Def#6336 : INC0391338-07
* Pass Sales unit(VRKME) instead of Base Unit of Measure (MEINS)
*        lwa_fklmg_sum-meins = i_xlips-meins.
* End of Delete: U024694: 19-Jul-2018: Def#6336 : INC0391338-07
* Begin of Change: U024694: 19-Jul-2018: Def#6336 : INC0391338-07
* Pass Sales unit(VRKME) instead of Base Unit of Measure (MEINS)
        lwa_fklmg_sum-meins = i_xlips-vrkme.
* End of Change: U024694: 19-Jul-2018: Def#6336: INC0391338-07
        IF lwa_fklmg_sum-fklmg IS INITIAL. " For batch split, get cumulative qty
          lwa_fklmg_sum-fklmg = i_xlips-kcmeng.
        ENDIF. " IF lwa_fklmg_sum-fklmg IS INITIAL
        COLLECT lwa_fklmg_sum INTO i_fklmg_sum.
      ENDIF. " IF sy-subrc = 0
*    ENDIF. " IF sy-subrc NE 0 " Changes by Rajendra for Def 7468 by Rajendra on 12/14/2016

*      Set change flag to avoid item compression
      fcf_change = abap_true.

    WHEN OTHERS.
  ENDCASE.

ENDFUNCTION.
