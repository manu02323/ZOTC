*&---------------------------------------------------------------------*
*& INCLUDE ZXVVFU02
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZXVVFU02                                               *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Update Custom table with Billing informations when
* Invoice is created and Accounting documement is geenrated
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK  E1DK901257 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
INCLUDE zotcn0043o_billback_upd.
*{   INSERT         E1SK901727                                        1
IF xaccit-vkorg = '2037'.

DATA :  lv_bstkd TYPE bstkd,
        lv_vbelv TYPE vbeln_von.
CLEAR  : lv_bstkd,
         lv_vbelv.


SELECT SINGLE vbelv FROM vbfa INTO lv_vbelv WHERE vbeln EQ gv_vgbel
                                            AND   vbtyp_v EQ 'C'.
  IF sy-subrc EQ 0.
SELECT SINGLE bstkd FROM vbkd INTO lv_bstkd WHERE vbeln EQ lv_vbelv
                                            AND   posnr EQ '000000'.
 IF sy-subrc EQ 0.
   xaccit-xref3 = lv_bstkd.
 ENDIF.
 ENDIF.
ENDIF.
*}   INSERT
