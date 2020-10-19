*&---------------------------------------------------------------------*
*&  Include           ZOTCN0061O_BILLBACK_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0061O_BILLBACK_SEL                                *
* TITLE      :  OTC_CDD_0061_Convert 1 year history data for billback  *
*               and commission.
* DEVELOPER  :  Deepa Sharma                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0061_SAP                                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Selection screen include for billback and commission   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-MAY-2012 DSHARMA1 E1DK901626  INITIAL DEVELOPMENT                 *
* 16-Oct-2012 SPURI    E1DK906961  Defect 492 :Skip Header Record from
*                                  Input File                          *
*                                  Defect 628 :Do not Check Customer   *
*                                  Material Number From MARA
*&---------------------------------------------------------------------*
* Selection Screen for File Location
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
  PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
               MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.

* Input from Presentation Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-005.

* Presentation Server File Inputs
  PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3.

  SELECTION-SCREEN END OF BLOCK b2.

  SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server filepath
  PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-006.

* Application server PhysFile Path - Radio Button
  PARAMETERS: rb_aphy RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X'
              USER-COMMAND comm4,
* Application server File name
              p_afile  TYPE localfile MODIF ID mi2.

  SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server - Logical Filename
  PARAMETERS: rb_alog RADIOBUTTON GROUP rb4 MODIF ID mi5,
*             Logical File Name
              p_alog TYPE filepath-pathintern MODIF ID mi7.

  SELECTION-SCREEN END OF BLOCK b3.
  SELECTION-SCREEN END OF BLOCK b1.

* For Mode Selection
  SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.

*             Verify Only Radio Button
  PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*             Verify and Post Radio Button
              rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

  SELECTION-SCREEN END OF BLOCK b4.
