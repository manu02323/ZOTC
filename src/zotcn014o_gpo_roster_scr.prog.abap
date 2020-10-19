*&---------------------------------------------------------------------*
*&  Include           ZOTCN014O_GPO_ROASTER_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0014O_GPO_ROASTER_UPLOAD                           *
* TITLE      :  OTC_IDD_0014_GPO Roaster Upload                        *
* DEVELOPER  :  Kiran R Durshanapally                                  *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0014_Upload GPO Roster
*----------------------------------------------------------------------*
* DESCRIPTION: Uploading GPO Roaster into Customer Master              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 03-APR-2012 KDURSHA  E1DK900679 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*


* Selection Screen for File Location
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
  PARAMETERS:  rb_pres RADIOBUTTON GROUP rb2
               MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.  " File Name

* Input from Presentation Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

* Presentation Server File Input
  PARAMETERS: p_phdr  TYPE localfile  MODIF ID mi3.

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
              p_ahdr  TYPE localfile MODIF ID mi2.

  SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server - Logical Filename
  PARAMETERS: rb_alog RADIOBUTTON GROUP rb4 MODIF ID mi5,
*             Logical File Name
              p_alog TYPE filepath-pathintern MODIF ID mi7.

  SELECTION-SCREEN END OF BLOCK b3.
  SELECTION-SCREEN END OF BLOCK b1.
