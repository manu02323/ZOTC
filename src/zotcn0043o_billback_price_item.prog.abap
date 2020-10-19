************************************************************************
* PROGRAM    :  ZOTCN0043O_BILLBACK_PRICE_ITEM (Include)               *
* TITLE      :  Billback Enhancement for Pricing structure update in
*               Item level                                             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of custom fields in Pricing structure in item
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 11-FEB-2013  ADAS1   E1DK909221 D#2743:Populate pricing at Item level
*======================================================================*
* 20-June-2014 PMISHRA E2DK901708 D2_OTC_EDD_0134 - Pass the structure *
*                                 MAAPV to the FM                      *
*&---------------------------------------------------------------------*
*IF maapv-matnr IS NOT INITIAL.
IF maapv-tragr IS NOT INITIAL.
  xvbap-zztragr = maapv-tragr.
ENDIF.
CALL FUNCTION 'ZOTC_0043_BILLBACK_PRICE_ITEM'
  EXPORTING
    im_vbap          = vbap
    im_xvbap         = xvbap
* ---> Begin of Change for D2_OTC_EDD_0134 by PMISHRA
    im_maapv         = maapv
    im_maepv         = maepv
    im_vbkd          = vbkd
    im_t_xvbap       = xvbap[]
    im_vbak          = vbak
* ---> End of Change for D2_OTC_EDD_0134 by PMISHRA
  CHANGING
    chng_tkomp       = tkomp.
*ENDIF.
