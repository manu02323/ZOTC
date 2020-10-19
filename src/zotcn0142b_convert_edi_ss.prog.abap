*&---------------------------------------------------------------------*
*&  Include           ZOTCN0142B_CONVERT_EDI_SS
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0142B_CONVERT_EDI_SS                              *
* TITLE      :  Order to Cash D3_OTC_CDD_0142_Convert EDI Ext Partner  *
*               to Internal Partner (EDPAR)                            *
* DEVELOPER  :  Nasrin Ali                                             *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0142                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert EDI Ext Partner                                *
*               to Internal Partner (EDPAR)                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-MAY-2016 NALI     E1DK918180 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
             MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

* Presentation Server File Inputs
PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3. " Local file for upload/download

SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server filepath
PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.

* Application server PhysFile Path - Radio Button
PARAMETERS: rb_aphy RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X'
            USER-COMMAND comm4,
* Application server File name
            p_afile  TYPE localfile MODIF ID mi2. " Local file for upload/download

SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server - Logical Filename
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4 MODIF ID mi5,
*             Logical File Name
            p_alog TYPE filepath-pathintern MODIF ID mi7. " Logical path name

SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF BLOCK b1.

* For Mode Selection
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.

*             Verify Only Radio Button
PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb6 MODIF ID mi4 DEFAULT 'X',
*             Verify and Post Radio Button
            rb_post RADIOBUTTON GROUP rb6 MODIF ID mi4.

SELECTION-SCREEN END OF BLOCK b4.
