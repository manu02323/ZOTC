*&---------------------------------------------------------------------*
*& Program      ZOTCE0285B_SORD_ATP_CHECK_SEL
*&
************************************************************************
* PROGRAM    :  ZOTCE0285B_SORD_ATP_CHECK_SEL                          *
* TITLE      :  ATP Check for Sales orders                             *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0285                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: This is a BDC program to run ATP check                  *
* using Call Transaction to VA02.                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 05-OCT-2015 DARUMUG  E2DK915626  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-h99.

PARAMETERS : rb_sord  RADIOBUTTON GROUP rb1.

SELECTION-SCREEN BEGIN OF BLOCK b7 WITH FRAME TITLE text-h01.
PARAMETERS:
  p_sord  TYPE vbeln.
SELECT-OPTIONS:
  s_sitm  FOR gv_itm NO INTERVALS.
SELECTION-SCREEN END OF BLOCK b7.

PARAMETERS : rb_file  RADIOBUTTON GROUP rb1.

* Selection Screen for File Location
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
             MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-002.

* Presentation Server File Inputs
PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3. "for upload/download

SELECTION-SCREEN END OF BLOCK b3.

SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server filepath
PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-003.

* Application server PhysFile Path - Radio Button
PARAMETERS: rb_aphy RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X'
            USER-COMMAND comm4,
* Application server File name
            p_afile  TYPE localfile MODIF ID mi2. "for upload/download

SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server - Logical Filename
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4 MODIF ID mi5,
*             Logical File Name
            p_alog TYPE filepath-pathintern MODIF ID mi7. " path name

SELECTION-SCREEN END OF BLOCK b4.
SELECTION-SCREEN END OF BLOCK b2.

* For Mode Selection
SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-004.

*             Verify Only Radio Button
PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*             Verify and Post Radio Button
            rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

SELECTION-SCREEN END OF BLOCK b5.

SELECTION-SCREEN END OF BLOCK b1.
