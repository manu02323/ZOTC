*&---------------------------------------------------------------------*
*& Report  ZOTCR0101B_PRICE_DATE_UPD
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0101B_PRICE_DATE_UPD                              *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report update the pricing date for the sales       *
*              documents line item which is passed from Report         *
*              ZOTCR0101O_PRICE_DATE_UPD.                              *
*----------------------------------------------------------------------*
*       !!This Report can not run stand alone!!
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*08-Aug-2018  AMOHAPA E1DK930340  Defect#3400(Part 2):                 *
*                                 Later taged with Defect#7955         *
*                                 1)Program to be                      *
*                                 made to process D3 sales organization*
*                                 records with different logic from    *
*                                 existing program                     *
*                                 2) Output of Batchjob to be import   *
*                                    in an excel sheet                 *
*&---------------------------------------------------------------------*

REPORT  zotcr0101b_price_date_upd NO STANDARD PAGE HEADING
                                  LINE-SIZE 200
                                  MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
INCLUDE zotcn0101b_price_date_upd_top. " Include ZOTCN0101B_PRICE_DATE_UPD_TOP

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0101b_price_date_upd_scr. " Include ZOTCN0101B_PRICE_DATE_UPD_SCR

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0101b_price_date_upd_sub. " Include ZOTCN0101B_PRICE_DATE_UPD_SUB

*----------------------------------------------------------------------*
*     S T A R T - O F - S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.
*&--Build SO Business data table splitting data string
  PERFORM f_split_data CHANGING i_vbkd.

*----------------------------------------------------------------------*
*     E N D - O F - S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.
*&--Update Pricing Date
  PERFORM f_update_price_date USING    i_vbkd
                              CHANGING i_log
                                       gv_count_e
                                       gv_count_s.
*&--Display Log
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  IF gv_flag IS INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    PERFORM f_display_log USING i_log
                                gv_count_e
                                gv_count_s.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ELSE. " ELSE -> IF gv_flag IS INITIAL
 "Display output as ALV so that user can download the data
    PERFORM f_populate_fieldcatalog CHANGING i_fieldcat.

    PERFORM f_populate_alv_display USING    i_fieldcat
                                            i_log
                                   CHANGING i_log_d3.


  ENDIF. " IF gv_flag IS INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
