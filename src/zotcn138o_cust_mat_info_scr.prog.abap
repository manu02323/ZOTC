*&---------------------------------------------------------------------*
*&  Include           ZOTCC0138O_CUST_MAT_INFO_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0138O_CUST_MAT_INFO_SCR (Include)                  *
* TITLE      : Convert Customer Material info records                  *
* DEVELOPER  : Rajiv Banerjee                                          *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0138_Convert Customer Material Info Records    *
*----------------------------------------------------------------------*
* DESCRIPTION: Customer material info records are used if the          *
* customer’s material number differs from the Bio-Rad’s material       *
* number, some customer’s would also require their own material number *
* be printed or transmitted in all of their communications.            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 20-APR-2016  RBANERJ1  E1DK917457  Initial Development               *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.

*presentation sever radiobutton
PARAMETERS: rb_pres  RADIOBUTTON GROUP rb2 USER-COMMAND comm2 MODIF ID mi1 DEFAULT 'X'.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
*file path presentation
PARAMETERS: p_phdr   TYPE localfile MODIF ID mi3. " Local file for upload/download
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN SKIP 1.
*application sever radiobutton
PARAMETERS: rb_app   RADIOBUTTON GROUP rb2 MODIF ID mi1 .

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.

*application sever radiobutton
PARAMETERS: rb_aphy  RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X' USER-COMMAND comm4,
*file path application server
            p_ahdr   TYPE localfile MODIF ID mi2. " Local file for upload/download
SELECTION-SCREEN SKIP 1.

*logical file radiobutton
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4    MODIF ID mi5,
*logical file path application server
            p_alog  TYPE filepath-pathintern MODIF ID mi7. " Logical path name
SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
*Verify Only radio button
PARAMETERS: rb_verif RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*Load Simulation
            rb_simu RADIOBUTTON GROUP rb5 MODIF ID mi9,
*Load radio button
            rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN END OF BLOCK blk1.
