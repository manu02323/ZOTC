************************************************************************
* PROGRAM    :  ZOTCR0347O_STANDING_ORDERS                             *
* TITLE      :  D3_OTC_EDD_0347_Upload Standing Orders                 *
* DEVELOPER  :  Debasih Maiti / Bijayeeta Banerjee                     *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0347                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Upload Standing Orders                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 15.06.2016  BBANERJ   E1DK919242    Initial Development              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0347O_STANDING_ORDERS_SEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* 03.01.2017 U033867  E1DK926115  CR# 378:Add sales office in selection
*                                 screen
*&---------------------------------------------------------------------*
*<--Begin of change for CR# 378 by U033867
SELECTION-SCREEN BEGIN OF BLOCK blk0 WITH FRAME TITLE text-015.
PARAMETERS: p_vkbur TYPE vkbur MATCHCODE OBJECT h_tvbur. " Sales Office
SELECTION-SCREEN END OF BLOCK blk0.
*-->End of change for CR# 378 by U033867
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-011.

*presentation sever radiobutton
PARAMETERS: rb_pres  RADIOBUTTON GROUP rb2 USER-COMMAND comm2 MODIF ID mi1 DEFAULT 'X'.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-012.
*file path presentation
PARAMETERS: p_phdr   TYPE localfile MODIF ID mi3. " Local file for upload/download
SELECTION-SCREEN END OF BLOCK b2.

*application sever radiobutton
PARAMETERS: rb_app   RADIOBUTTON GROUP rb2 MODIF ID mi1 .

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-013.

**application sever radiobutton
*PARAMETERS: rb_aphy  RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X' USER-COMMAND comm4,
**file path application server
*            p_ahdr   TYPE localfile MODIF ID mi2. " Local file for upload/download
*
**logical file radiobutton
*PARAMETERS: rb_alog RADIOBUTTON GROUP rb4    MODIF ID mi5,
**logical file path application server
*            p_alog  TYPE filepath-pathintern MODIF ID mi7. " Logical path name

*application sever radiobutton
PARAMETERS: rb_aphy  MODIF ID mi5 DEFAULT 'X' USER-COMMAND comm4,
*file path application server
            p_ahdr   TYPE localfile MODIF ID mi2. " Local file for upload/download

SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-014.
*Verify Only radio button
PARAMETERS: rb_verif RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',

*Load radio button
            rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN END OF BLOCK blk1.
