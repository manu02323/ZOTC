*&---------------------------------------------------------------------*
*&  Include           ZOTCR0123O_REVENUE_AUDIT_SEL
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_REVENUE_AUDITREPORT                         *
* TITLE      :  Revenue Report for Audit                               *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0123                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Revenue Report for Audit                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 07-MAY-2018 U034334  E1DK936497 Initial Development                  *
*&---------------------------------------------------------------------*

*&-- Selection Options
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs  FOR  gv_bukrs  OBLIGATORY,            " Company Code
                s_budat  FOR  gv_budat  OBLIGATORY,            " Posting Date
                s_vbeln  FOR  gv_vbeln  MATCHCODE OBJECT vmva, " Sales Document
                s_sakrv  FOR  gv_sakrv,                        " G/L Account
                s_blart  FOR  gv_blart  DEFAULT c_rr.          " Document Type
SELECTION-SCREEN END OF BLOCK a1.

*&-- Processing Mode
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-004.
PARAMETERS: rb_onlin RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND comm1, " Online
            rb_backg RADIOBUTTON GROUP rb1,                                " Background
            p_afile  TYPE localfile MODIF ID mi1.                          " Output File
SELECTION-SCREEN END OF BLOCK b1.
