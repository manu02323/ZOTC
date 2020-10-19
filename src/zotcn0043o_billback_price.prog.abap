************************************************************************
* PROGRAM    :  ZOTCN0043O_BILLBACK_PRICE (Include)                    *
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

* Populate custom fields in Pricing structure
  CALL FUNCTION 'ZOTC_0043_BILLBACK_PRICE_FM'
    EXPORTING
      im_kuagv   = kuagv
      im_kuwev   = kuwev " CR#162
      im_xvbap   = xvbap
      im_vbak    = vbak  " CR#162
    CHANGING
      chng_tkomk = tkomk.
