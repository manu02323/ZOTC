*&---------------------------------------------------------------------*
*&  Include           ZOTCN0274B_PRICE_UPLOAD_SS
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0274B_PRICE_UPLOAD                                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Monika Garg                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS:  p_pfile TYPE localfile MODIF ID mod. " Local file for upload/download
SELECTION-SCREEN SKIP 1.
PARAMETERS:  "rb_vrfy  RADIOBUTTON GROUP rb1 USER-COMMAND cmd DEFAULT 'X',
             rb_post  RADIOBUTTON GROUP rb1 USER-COMMAND cmd DEFAULT 'X',
             rb_cidoc RADIOBUTTON GROUP rb1 .

SELECTION-SCREEN END OF BLOCK b1.
