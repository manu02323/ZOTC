************************************************************************
* PROGRAM    :  ZOTCN0069B_MODIFY_SELSCRN                              *
* TITLE      :  OTC_CDD_0069B BILLING OUTPUT                           *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0069                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  INCLUDE FOR SELCTION SCREEN                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 19-MAY-2012 APURI    E1DK901634 INITIAL DEVELOPMENT                  *
************************************************************************


* Selection Screen for File Location
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
  PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
               MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.

* Input from Presentation Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

* Presentation Server File Input
  PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3. "Sampling Scheme Flat File

  SELECTION-SCREEN END OF BLOCK b2.

  SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server file path
  PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
* Physical File Path - Application server
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

* for Mode Selection
  SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
*             Verify Only
  PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*             Verify and Post
              rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.


  SELECTION-SCREEN END OF BLOCK b4.
