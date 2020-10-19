FUNCTION zotc_0043_billback_price_fm.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_KUAGV) TYPE  KUAGV
*"     REFERENCE(IM_KUWEV) TYPE  KUWEV OPTIONAL
*"     REFERENCE(IM_XVBAP) TYPE  VBAPVB OPTIONAL
*"     REFERENCE(IM_VBAK) TYPE  VBAK OPTIONAL
*"     REFERENCE(IM_XVBRP) TYPE  VBRP OPTIONAL
*"  CHANGING
*"     REFERENCE(CHNG_TKOMK) TYPE  KOMK
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_0043_BILLBACK_PRICE_FM (FM)                       *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of custom fields in Pricing structure
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK  E1DK901257 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 20-SEP-2012  ADAS1    E1DK906242 CR 162: For Cardinal Customer,      *
*                                  Populate Buying Group and IDN Code  *
*                                  from Ship-to-Party                  *
*&---------------------------------------------------------------------*
* 11-FEB-2013  ADAS1    E1DK909221 D#2743:Comment pricing for item     *
*&---------------------------------------------------------------------*
* 20-June-2014 PMISHRA E2DK901708 D2_OTC_EDD_0134 - Populate the values*
*                                 for customer fields in pricing       *
*                                 structure TKOMK.                     *
*&---------------------------------------------------------------------*
* Declare Local Structure
  TYPES: BEGIN OF lty_cust_details,
           kunnr TYPE kunnr, " Customer number
           kdgrp TYPE kdgrp, " Customer group
           kvgr1 TYPE kvgr1, " Customer group1
           kvgr2 TYPE kvgr2, " Customer group2
         END OF   lty_cust_details.

* Declare Local Internal table and workarea
  DATA: li_cust_details  TYPE STANDARD TABLE OF lty_cust_details,
        lwa_cust_details TYPE lty_cust_details.

* BOC ADAS1 CR#162 20-Sep-2012
* Get Customer group details for sold/ship to party
  SELECT kunnr     " Customer Number
         kdgrp     " Customer group
         kvgr1     " Customer group1
         kvgr2     " Customer group2
         INTO TABLE li_cust_details
         FROM knvv " Customer Master Sales Data
         WHERE ( kunnr = im_kuagv-kunnr
            OR   kunnr = im_kuwev-kunnr )
           AND vkorg = im_vbak-vkorg
           AND vtweg = im_vbak-vtweg.

* If Sold--to-party is Cardinal Customer,
  CLEAR: lwa_cust_details.
  READ TABLE li_cust_details INTO lwa_cust_details
       WITH KEY kunnr = im_kuagv-kunnr
                kdgrp = 'CR'.

  IF sy-subrc = 0.
*   Populate Buying Group and IDN Code from Ship-to-party
    CLEAR: lwa_cust_details.
    READ TABLE li_cust_details INTO lwa_cust_details
       WITH KEY kunnr = im_kuwev-kunnr.

    chng_tkomk-zzkvgr1 = lwa_cust_details-kvgr1. " Buying Group
    chng_tkomk-zzkvgr2 = lwa_cust_details-kvgr2. " IDN Code
  ELSE. " ELSE -> IF sy-subrc = 0
*   Populate Buying Group and IDN Code from Sold-to-party  for all other
*   customers except Cardinal
    chng_tkomk-zzkvgr1 = im_kuagv-kvgr1. " Buying Group
    chng_tkomk-zzkvgr2 = im_kuagv-kvgr2. " IDN Code
  ENDIF. " IF sy-subrc = 0

* EOC ADAS1 CR#162  20-Sep-2012

  chng_tkomk-zzkdkg1 = im_kuagv-kdkg1. " Handling Charge Indicator
  chng_tkomk-zzkdkg2 = im_kuagv-kdkg2. " Dangerous Goods Handling
                                       " Charge Indicator
  chng_tkomk-zzkdkg3 = im_kuagv-kdkg3. " Freight Charge Indicator
  chng_tkomk-zzkdkg4 = im_kuagv-kdkg4. " Future Pricing Requirement
  chng_tkomk-zzkdkg5 = im_kuagv-kdkg5. " Future Pricing Requirement

  chng_tkomk-zzkvgr3 = im_kuagv-kvgr3. " Future Pricing Requirement
  chng_tkomk-zzkvgr4 = im_kuagv-kvgr4. " Future Pricing Requirement
  chng_tkomk-zzkvgr5 = im_kuagv-kvgr5. " Future Pricing Requirement

*  Comment pricing for items
*  BOC DEL ADAS1 D#2743
*  chng_tkomk-zzprodh4 = im_xvbap-prodh(11). " Product Family
*  chng_tkomk-zzprofl  = im_xvbap-profl. " Dangerous Goods Indicator Prof
*  chng_tkomk-zzmvgr4  = im_xvbap-mvgr4. " Material Group 4
*  EOC DEL ADAS1 D#2743

* ---> Begin of Change for D2_OTC_EDD_0134 by PMISHRA
  chng_tkomk-zzkukla = im_kuagv-zzkukla.
  chng_tkomk-zzkatr7 = im_kuagv-zzkatr7.
* change made per request Jim rich
*  IF NOT im_xvbap-profl IS INITIAL.
  chng_tkomk-cont_dg = im_vbak-cont_dg.
*  ENDIF. " IF NOT im_xvbap-profl IS INITIAL
*  IF NOT im_xvbap-profl IS INITIAL.
*    chng_tkomk-cont_dg = im_xvbap-profl.
*  ENDIF. " IF NOT im_xvbap-profl IS INITIAL
*end of change
* ---> End of Change for D2_OTC_EDD_0134 by PMISHRA
ENDFUNCTION.
