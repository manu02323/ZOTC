*&---------------------------------------------------------------------*
*&  Include           ZOTCE0213B_COMM_GRP_SELECTION
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    :  ZOTCE0213B_COMM_GRP_SELECTION                          *
* TITLE      :  D2_OTC_EDD_0213_Commision Group Sales Role assignment  *
* DEVELOPER  :  NLIRA (Nic Lira)                                       *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Update table ZOTC_TERRIT_ASSN from tab delimited file.  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 29-Sep-2014  NLIRA   E2DK904939 Initial development                  *
*&---------------------------------------------------------------------*
* 18-SEP-2017 amangal E1DK930689  D3R2 Changes
*                                1. Allow mass update of date fields in*
*                                   Maintenance transaction            *
*                                2. Allow Load from AL11 with effective*
*                                   dates populated and properly       *
*                                   formatted                          *
*                                3.	Control the sending of IDoc on     *
*                                   request                            *
*&---------------------------------------------------------------------*
PARAMETERS :  rb_pr RADIOBUTTON GROUP rb1 USER-COMMAND c12 DEFAULT 'X'.  " Presentation server radio button
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-101.
PARAMETERS      p_filepr     TYPE rlgrap-filename MODIF ID prs.  " Physical file from AP server
* PARAMETERS      p_filepr     TYPE rlgrap-filename MODIF ID prs default 'c:\temp\test.txt'.  " Physical file from AP server
SELECTION-SCREEN END OF BLOCK bl2.

PARAMETERS :  rb_ap RADIOBUTTON GROUP rb1.                " Application server radio button
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-102.
PARAMETERS : p_fileap TYPE localfile MODIF ID aps.  "LOGICAL FILENAME
SELECTION-SCREEN END OF BLOCK bl1.

* Begin of D3_OTC_EDD_0213 D3R2

SELECTION-SCREEN BEGIN OF LINE.
*
PARAMETERS cb_chk AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN COMMENT 20(10) text-026 FOR FIELD cb_chk. " Send IDOC

SELECTION-SCREEN END OF LINE.

* End of D3_OTC_EDD_0213 D3R2
