FUNCTION zotc_0337_billquan_00503110.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      FIT_ACCHD STRUCTURE  ACCHD
*"      FIT_ACCCR STRUCTURE  ACCCR
*"      FIT_ACCIT STRUCTURE  ACCIT
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM          :  ZOTC_0337_BILLQUAN_00503110 (Function Module)    *
* TITLE            :  Include billing quantities in Stock              *
* DEVELOPER        :  NASRIN ALI                                       *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D3_OTC_EDD_0337                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  Interface for BTE 00503110 to include billing    *
*                     quantities in Stock                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 01-JUN-2016  NALI     E1DK918440  INITIAL DEVELOPMENT                *
* 14-Feb-2019  U024694  E1DK937871  D#6336/PCR#543 - Plant value to be *
*                                   displayed in Rev Recognition doc   *
*&---------------------------------------------------------------------*


  FIELD-SYMBOLS : <lfs_accit> TYPE accit, " Accounting Interface: Item Information
                  <lfs_fklmg_sum> TYPE ty_fklmg_sum,

* Begin of Insert by U024694 for D#6336/PCR#543 on 14-Feb-2019
                   <lfs_fit_accit> TYPE accit . " Accounting Interface: Item Information

* Local constant for Doc type
  CONSTANTS: lc_blart_rr TYPE blart VALUE  'RR' . " Document Type

* Local Type decleration for Sales Doc & Plant
  TYPES: BEGIN OF lty_sales_plant,
          vbeln TYPE vbeln_va  , " Sales Document
          posnr TYPE posnr_va,   " Sales Document Item
          werks  TYPE werks_ext, " Plant (Own or External)
         END OF  lty_sales_plant.

* Local Work area & Internal table decleration
  DATA: lwa_fit_accit   TYPE accit,                    " Accounting Interface: Item Information
        lwa_sales_sele  TYPE vlc_sdoc_item,            " VELO: Structure for vbeln posnr data
        lwa_sales_plant TYPE lty_sales_plant,          " Work Area for Sales Doc / Plant
        li_sales_sele   TYPE TABLE OF vlc_sdoc_item,   " VELO: Structure for vbeln posnr data
        li_fit_accit    TYPE TABLE OF accit ,          " Accounting Interface: Item Information
        li_sales_plant  TYPE TABLE OF lty_sales_plant. " Internal table for Sales / Plant
* End of Insert by U024694 for D#6336/PCR#543 on 14-Feb-2019


  DESCRIBE TABLE i_fklmg_sum.
*  SORT i_fklmg_sum BY vbeln posnr.
  IF sy-tfill > 0.
    LOOP AT fit_accit ASSIGNING <lfs_accit>.
      READ TABLE i_fklmg_sum ASSIGNING <lfs_fklmg_sum>
      WITH KEY vbeln = <lfs_accit>-zuonr(10)
               posnr = <lfs_accit>-zuonr+10(6). "#EC WARNOK
*      BINARY SEARCH.
      IF sy-subrc = 0.
** FKLMG is filled with previously determined partial delivery quantity
        MOVE <lfs_fklmg_sum>-fklmg TO <lfs_accit>-fklmg.
** VRKME is filled with the sales unit
        MOVE <lfs_fklmg_sum>-vrkme TO <lfs_accit>-vrkme.
** Populate Unit of Measure in MEINS
        MOVE <lfs_fklmg_sum>-meins TO <lfs_accit>-meins.
*        CLEAR <lfs_fklmg_sum>.
      ENDIF. " IF sy-subrc = 0
*      CLEAR <lfs_accit>.
    ENDLOOP. " LOOP AT fit_accit ASSIGNING <lfs_accit>
  ENDIF. " IF sy-tfill > 0

* Begin of Insert by U024694 for D#6336/PCR#543 on 14-Feb-2019

* Consider the Revenue Recognition document and  populate sales order information
  li_fit_accit =  fit_accit[]    .
  DELETE li_fit_accit WHERE blart NE lc_blart_rr    .
  SORT li_fit_accit BY zuonr.
  DELETE ADJACENT DUPLICATES FROM li_fit_accit COMPARING zuonr .

  LOOP AT li_fit_accit INTO lwa_fit_accit.
    lwa_sales_sele-vbeln = lwa_fit_accit-zuonr+0(10).
    lwa_sales_sele-posnr = lwa_fit_accit-zuonr+10(6).
    APPEND lwa_sales_sele TO li_sales_sele.

    CLEAR : lwa_fit_accit,
            lwa_sales_sele.
  ENDLOOP . " LOOP AT li_fit_accit INTO lwa_fit_accit

  IF li_sales_sele IS NOT INITIAL.
* Select the  plant data
    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           werks " Plant (Own or External)
      FROM vbap  " Sales Document: Item Data
      INTO TABLE li_sales_plant
      FOR ALL ENTRIES IN li_sales_sele
      WHERE vbeln  = li_sales_sele-vbeln
      AND   posnr  = li_sales_sele-posnr .

    IF sy-subrc EQ 0.

      SORT li_sales_plant BY vbeln posnr.
* Populate the plant data
      LOOP AT  fit_accit ASSIGNING <lfs_fit_accit>.

*       Check if it is Revenue Recognition Document
        IF <lfs_fit_accit>-blart = lc_blart_rr.

*         Read corrosponding Sales Doc
          READ TABLE li_sales_plant INTO lwa_sales_plant
          WITH KEY  vbeln = <lfs_fit_accit>-zuonr+0(10)
                    posnr = <lfs_fit_accit>-zuonr+10(6)
                    BINARY SEARCH .

          IF sy-subrc EQ 0.
*           Get the plant from SO and update it in FIT_ACCIT table
            <lfs_fit_accit>-werks = lwa_sales_plant-werks .

            CLEAR : lwa_sales_plant .

          ENDIF. " IF sy-subrc EQ 0

        ENDIF. " IF <lfs_fit_accit>-blart = lc_blart_rr

      ENDLOOP . " LOOP AT fit_accit ASSIGNING <lfs_fit_accit>

    ENDIF. " IF sy-subrc EQ 0

  ENDIF . " IF li_sales_sele IS NOT INITIAL

  CLEAR : li_sales_plant,
          li_sales_sele,
          li_fit_accit.
* End of Insert by U024694 for D#6336/PCR#543 on 14-Feb-2019

ENDFUNCTION.
