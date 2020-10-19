***********************************************************************
*Program    : ZOTCN0344B_TRANSFER_BATCH_SEL                           *
*Title      : Include for selection screen declaration                *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description:Utility program to upload batch data in custom table     *
*            ZOTC_REST_BATCH and also update prject master table in   *
*            GTS table with batch data.                               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373     Initial Development
*---------------------------------------------------------------------*

* Selection Screen for File Location
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-010.

* Radiobutton for presentation server filepath
  PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
               MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.

* Input from Presentation Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-011.

* Presentation Server File Input
  PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3. "Sampling Scheme Flat File

  SELECTION-SCREEN END OF BLOCK b2.

  SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server file path
  PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
  SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-012.

* Physical File Path - Application server
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

* for Test Mode Selection
  SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-013.
* Validate Only
  PARAMETERS:cb_test AS CHECKBOX.

  SELECTION-SCREEN END OF BLOCK b4.
