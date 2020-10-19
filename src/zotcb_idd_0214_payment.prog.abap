************************************************************************
* PROGRAM    :  ZOTCB_EDD_0214_PAYMENT                                 *
* TITLE      :  Mexico Payment Supplement for Trailix                  *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0214 SCTASK0515243                            *
*----------------------------------------------------------------------*
* DESCRIPTION: This Program is to Create a Payment Supplement File for *
*              Mexico Trailix.                                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 31-Aug-2017 U033814  E1DK930729 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 09-Nov-2017 U033814  E1DK930729 Defect 3997 Logic change for RT20    *
*                                 Price for DZ Documents               *
*&---------------------------------------------------------------------*

REPORT zotcb_edd_0214_payment NO STANDARD PAGE HEADING
                                            LINE-SIZE 132
                                      MESSAGE-ID zotc_msg.

************************************************************************
*        Top include declaration                                       *
************************************************************************

"Top include declaration.
INCLUDE zotcb_idd_0214_payment_top. " Include ZOTCB_IDD_0214_PAYMENT_TOP

*
"Include programs for selection screen.
INCLUDE zotcb_idd_0214_payment_sel. " Include ZOTCB_IDD_0214_PAYMENT_SEL


"Include programs for form routines.
INCLUDE zotcb_idd_0214_payment_f01. " Include ZOTCB_IDD_0214_PAYMENT_F01


AT SELECTION-SCREEN.
  IF p_reg IS NOT INITIAL AND s_belnr IS INITIAL.
    MESSAGE i168. " Please Enter Document number for Regeneration Option
    gv_subrc = 4.
  ENDIF. " IF p_reg IS NOT INITIAL AND s_belnr IS INITIAL

START-OF-SELECTION.
  IF gv_subrc IS INITIAL.
    PERFORM fetch_payment_details CHANGING gt_bkpf
                                           gt_bseg
                                           gt_bsad
                                           gt_bsid
                                           gv_msg
                                           gv_subrc.

    PERFORM prepare_post_pi_file USING gt_bkpf
                                      gt_bseg
                                    gt_bsad
                                    gt_bsid
                           CHANGING gv_msg
                                    gv_subrc.
  ENDIF. " if gv_subrc is initial

END-OF-SELECTION.
  IF gt_final IS NOT INITIAL.
* Subroutine  to populate fieldcatalog
    PERFORM f_populate_fieldcat.
    PERFORM f_display_alv.
  ELSE. " ELSE -> IF gt_final IS NOT INITIAL
    MESSAGE i095. " No Data Found For The Given Selection Criteria .
  ENDIF. " IF gt_final IS NOT INITIAL
