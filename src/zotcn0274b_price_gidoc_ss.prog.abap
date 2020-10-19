*&---------------------------------------------------------------------*
*& Report  ZOTCE0274B_PRICE_UPLOAD_GIDOC
*&
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
* DESCRIPTION: Pricing Upload program for pricing condition  (Part 2)  *
* Program will read all the files from specified folder of application *
* server and create the IDOC which will Insert/update/Delete the       *
* condition records.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* Selection Screen
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-002.

* Logical fle path
PARAMETERS:  p_lfpath TYPE  filepath-pathintern " Logical path name
                 DEFAULT 'ZOTC_EDD_0274_TBP' OBLIGATORY,   " Logical file path

             p_pfapth TYPE rlgrap-filename MODIF ID mi .     " Local file for upload/download

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN END OF BLOCK b1.
