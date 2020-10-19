FUNCTION zotc_0043_billback_mod_tab.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_ZOTC_BILLBACK) TYPE  ZOTC_T_BILLBACK
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_0043_BILLBACK_MOD_TAB (FM)                        *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Update Custom table with Billing informations when
* Invoice is created and Accounting documement is genarated
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK  E1DK901257 INITIAL DEVELOPMENT                 *
* 09-MAY-2013  BMAJI    E1DK910352 D#3745: Change logic for call of FM
*                                  ZOTC_0043_BILLBACK_MOD_TAB in
*                                  UPDATE TASK in Subroutine
*                                  F_UPDATE_DB
*&---------------------------------------------------------------------*

*&&-- BOC of Defect#3745 Incident#INC0092648 on 09/05/2013
* Local workarea declaration
  DATA: lwa_zotc_billback TYPE zotc_billback.

*&&-- Check for each item of Billing doc
  LOOP AT im_zotc_billback INTO lwa_zotc_billback.

* For inserting new line, workarea should contain the billing doc type
      IF NOT lwa_zotc_billback-fkart IS INITIAL.
        MODIFY zotc_billback FROM lwa_zotc_billback.
* To update the original invoice for Credit/debit memo, update
* the particular fields needs to be updated
      ELSE.
        UPDATE zotc_billback SET zzset_qty = lwa_zotc_billback-zzset_qty
                                 zzbal_qty = lwa_zotc_billback-zzbal_qty
                                 zzset_flag = lwa_zotc_billback-zzset_flag
                          WHERE  vbeln = lwa_zotc_billback-vbeln
                            AND  posnr = lwa_zotc_billback-posnr
                            AND  matnr = lwa_zotc_billback-matnr
                            AND  vkorg = lwa_zotc_billback-vkorg
                            AND  vtweg = lwa_zotc_billback-vtweg
                            AND  kunag = lwa_zotc_billback-kunag.
      ENDIF. "IF NOT im_zotc_billback-fkart IS INITIAL.
    ENDLOOP. " LOOP AT fp_i_zotc_billback INTO lwa_zotc_billback.
*&&-- EOC of Defect#3745 Incident#INC0092648 on 09/05/2013

*&&-- Comment BOC of Defect#3745 Incident#INC0092648 on 09/05/2013
** For inserting new line, workarea should contain the billing doc type
*  IF NOT im_zotc_billback-fkart IS INITIAL.
*    MODIFY zotc_billback FROM im_zotc_billback.
** To update the original invoice for Credit/debit memo, update
** the particular fields needs to be updated
*  ELSE.
*    UPDATE zotc_billback SET zzset_qty = im_zotc_billback-zzset_qty
*                             zzbal_qty = im_zotc_billback-zzbal_qty
*                             zzset_flag = im_zotc_billback-zzset_flag
*                      WHERE  vbeln = im_zotc_billback-vbeln
*                        AND  posnr = im_zotc_billback-posnr
*                        AND  matnr = im_zotc_billback-matnr
*                        AND  vkorg = im_zotc_billback-vkorg
*                        AND  vtweg = im_zotc_billback-vtweg
*                        AND  kunag = im_zotc_billback-kunag.
**                        AND  bstkd = im_zotc_billback-bstkd.
*  ENDIF. "IF NOT im_zotc_billback-fkart IS INITIAL.
*&&-- Comment EOC of Defect#3745 Incident#INC0092648 on 09/05/2013


  ENDFUNCTION.
