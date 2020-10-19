*&---------------------------------------------------------------------*
*&  Include           ZOTCC0008B_PRICE_LOAD_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0008_PRICE_LOAD_SCR                              *
* TITLE      :  OTC_CDD_0008_Price Load                                *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0008_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION:
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 05-June-2012 SPURI   E1DK901614  INITIAL DEVELOPMENT                 *
* 23-July-2012 SPURI   E1DK901614  CR100-Addition of amount column     *
* 12-Oct-2012  SPURI   E1DK906586  Defect:264 Inc ALV count Size /
*                                  Defect:267 Corrected selection
*                                  from table KNA1
* 23-Oct-2012  SPURI   E1DK906586  Defect 1025 . Make Buying group
*                                  mandatory for A901 and A904
* 29-Oct-2012  SPURI   E1DK906586  Defect 1177 . Add check to verify valid
*                                  buying group exist in table TVV1. Right
*                                  now Standard FM raises a error and it halts
*                                  the program. With the new change , it will
*                                  pass the record in error log
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
*presentation sever radiobutton
PARAMETERS: rb_pres  RADIOBUTTON GROUP rb2 USER-COMMAND comm2 MODIF ID mi1 DEFAULT 'X',
*file path presentation
            p_phdr   TYPE localfile MODIF ID mi3,
*application sever radiobutton
            rb_app   RADIOBUTTON GROUP rb2 MODIF ID mi1 .

SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.

*application sever radiobutton
PARAMETERS: rb_aphy  RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X' USER-COMMAND comm4,
*file path application server
            p_ahdr   TYPE localfile MODIF ID mi2.
SELECTION-SCREEN SKIP 1.

*logical file radiobutton
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4    MODIF ID mi5,
*logical file path application server
            p_alog  TYPE filepath-pathintern MODIF ID mi7.
SELECTION-SCREEN END OF BLOCK b3.
*map legacy material to ECC material
PARAMETERS: cb_map AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME.
*Verify Only radio button
PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*Verify and Post radio button
            rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.
SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN END OF BLOCK blk1.
