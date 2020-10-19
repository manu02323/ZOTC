*&---------------------------------------------------------------------*
*&  Include  ZPLMN0119B_UPD_MP01_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZPLMN0119B_UPD_MP01_SEL                                *
* TITLE      :  D2_PLM_CDD_0119_Manufacturer_Part_Number_to_AMPL       *
* DEVELOPER  :  Ashis Dey                                              *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_PLM_CDD_0119_Manufacturer_Part_Number_to_AMPL       *
*----------------------------------------------------------------------*
* DESCRIPTION:  Create Manufacturer Part number records from MP01      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-AUG-2014 ADEY     E2DK903904 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* Selection Screen for File Location
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
                               MODIF ID mi1 DEFAULT 'X'
                           USER-COMMAND comm2.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

* Presentation Server File Inputs
PARAMETERS: p_pfile TYPE localfile MODIF ID mi3.

SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server filepath
PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.

* Application server PhysFile Path - Radio Button
PARAMETERS: rb_aphy RADIOBUTTON GROUP rb4
                             MODIF ID mi5 DEFAULT 'X'
                         USER-COMMAND comm4,
* Application server File name
            p_afile  TYPE localfile MODIF ID mi2.

SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server - Logical Filename
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4
                             MODIF ID mi5,
* Logical File Name
            p_alog TYPE filepath-pathintern MODIF ID mi7.

SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF BLOCK b1.

* For Mode Selection
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.

* Verify Only Radio Button
PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5
                             MODIF ID mi9 DEFAULT 'X',
* Verify and Post Radio Button
            rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

SELECTION-SCREEN END OF BLOCK b4.
