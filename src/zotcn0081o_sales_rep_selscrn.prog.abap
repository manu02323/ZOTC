************************************************************************
* PROGRAM    :  ZOTCN0081O_SALES_REP_SELSCRN                           *
* TITLE      :  OTC_IDD_0081 UPLOAD SALES REP TERRITORY                *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_IDD_0081                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  INCLUDE FOR SELECTION SCREEN                           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT    DESCRIPTION                      *
* ===========  ========  ==========   =================================*
* 27-JUNE-2012 APURI     E1DK903418   INITIAL DEVELOPMENT              *
*----------------------------------------------------------------------*

* Selection Screen for File Location
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECTION-SCREEN SKIP 1.


* Input from Presentation Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

* Presentation Server File Input
  PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3 OBLIGATORY.

  SELECTION-SCREEN END OF BLOCK b2.

  SELECTION-SCREEN SKIP 1.
  SELECTION-SCREEN END OF BLOCK b1.

* for Mode Selection
  SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
*             Verify Only
  PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*             Verify and Post
              rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

  SELECTION-SCREEN END OF BLOCK b4.
