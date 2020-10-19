*&---------------------------------------------------------------------*
*&  Include           ZOTCN0092O_AR_AGING_REPORT_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZOTCR0092O_AR_AGING_REPORT
************************************************************************
* PROGRAM    :  ZOTCN0092O_AR_AGING_REPORT_SUB                         *
* TITLE      :  AR Aging Report                                        *
* DEVELOPER  :  Sneha/Moushumi/Sayantan                                *
* OBJECT TYPE:  Report                                               *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D2_OTC_RDD_0092
*----------------------------------------------------------------------*
* DESCRIPTION: AR Aging Report
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 18-Mar-2016  SMUKHER   E2DK917181  AR Aging Report                   *
* 22-Jun-2016  SMUKHER   E2DK918149  Defect# 1829 : Following changes  *
*                                    were done:-                       *
*                                    1.Key Date on selection screen was*
*                                    getting overwitten to current date*
*                                    while saving variant.             *
*                                    2.Clearing Documents not showing  *
*                                    correctly at past Key Date        *
*                                    3.Column Heading 'Profile Center' *
*                                     to be changed to 'Profit Center'.*
*                                    4.ALV File should now be appended *
*                                    with User Name                    *
*                                    5.Leading 0's to be removed from  *
*                                      Customer Number.                *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE input.
*************************************************************************
SELECT-OPTIONS: s_kunnr  FOR gv_kunnr, " Customer Number
                s_comp   FOR gv_bukrs, " Company Code
                s_reccon FOR gv_reconn." Reconcilliation account
*************************************************************************
SELECT-OPTIONS: s_sbgrp FOR   gv_sbgrp. " Credit representative group for credit management

*-->Begin of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
PARAMETERS: p_datum TYPE datum MODIF ID dat. " Key Date
*<-- End of change for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*-->Begin of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016
*PARAMETERS:     p_datum TYPE  datum DEFAULT sy-datum MODIF ID dat. " Key Date
*<-- End of delete for D2_OTC_RDD_0092 Def#1829 by SMUKHER on 22-Jun-2016

SELECT-OPTIONS: s_knkli FOR   gv_knkli. " Customer's account number with credit limit reference
PARAMETERS:     p_kkber TYPE  kkber MATCHCODE OBJECT h_t014. " Credit Control Area
*************************************************************************
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE radio.

PARAMETERS:rb_sumdc RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND sel, "Summary Report by Doc Date
           rb_sumnt RADIOBUTTON GROUP rb1,                              "Summary Report by Net Due Date
           rb_detdc RADIOBUTTON GROUP rb1,                              "Detail Report by Doc Date
           rb_detnt RADIOBUTTON GROUP rb1,                              "Detail Report by Net Due Date
           rb_creif RADIOBUTTON GROUP rb1.                              "Credit Report

SELECTION-SCREEN END OF BLOCK b2.

*&-- Application Server Upload / ALV
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE display.
PARAMETERS:rb_afile  RADIOBUTTON GROUP rb2 DEFAULT 'X' USER-COMMAND ucomm, "Application Server Upload
           p_path    TYPE rlgrap-filename MODIF ID p,
           rb_alv    RADIOBUTTON GROUP rb2 .                               "ALV Display
SELECTION-SCREEN END OF BLOCK b3.
