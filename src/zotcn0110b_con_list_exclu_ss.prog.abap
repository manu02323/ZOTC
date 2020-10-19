*&---------------------------------------------------------------------*
*&  Include           ZOTCN0110B_CON_LIST_EXCLU_SS
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0110B_CON_LIST_EXCLU_SS                           *
* TITLE      :  Order to Cash D2_OTC_CDD_0110_Convert Listing          *
*               exclusion records                                      *
* DEVELOPER  :  Abhishek Gupta                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0110                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Listing exclusion records                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-Sep-2014 AGUPTA3  E2DK904581 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
* 12-May-2016 U033808  E1DK917461 D3: Add tables 915 and 922. File deli*
*                                 miter changed to pipe. Add codepage  *
*----------------------------------------------------------------------*
* 28-SEP-2016 MGARG   E1DK917461  D3_CR_0062:Added logic for call trans*
*                                 action based on EMI Value. Added more*
*                                 access sequences on selection Screen *
*                                 Added option for downloading error   *
*                                 file to presentation server          *
*&---------------------------------------------------------------------*
* 19-OCT-2016 U029639 E1DK917461  D3_CR_0062_2nd_Change:Make changes in*
*                                 logic to address issues mentioned in *
*                                 defect#3121.                         *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

* Radiobutton for presentation server filepath
PARAMETERS : rb_pres  RADIOBUTTON GROUP rb2
             MODIF ID mi1 DEFAULT 'X' USER-COMMAND comm2.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

* Presentation Server File Inputs
PARAMETERS: p_pfile  TYPE localfile  MODIF ID mi3. " Local file for upload/download

SELECTION-SCREEN END OF BLOCK b2.

*SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server filepath
PARAMETERS : rb_app RADIOBUTTON GROUP rb2 MODIF ID mi1 .

* Input from Application Server Block
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.

* Application server PhysFile Path - Radio Button
PARAMETERS: rb_aphy RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X'
            USER-COMMAND comm4,
* Application server File name
            p_afile  TYPE localfile MODIF ID mi2. " Local file for upload/download

*SELECTION-SCREEN SKIP 1.

* Radiobutton for Application Server - Logical Filename
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4 MODIF ID mi5,
*             Logical File Name
            p_alog TYPE filepath-pathintern MODIF ID mi7. " Logical path name

SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF BLOCK b1.

* For Mode Selection
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.

*             Verify Only Radio Button
PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb5 MODIF ID mi9 DEFAULT 'X',
*             Verify and Post Radio Button
            rb_post RADIOBUTTON GROUP rb5 MODIF ID mi9.

SELECTION-SCREEN END OF BLOCK b4.

SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE text-006.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key1 RADIOBUTTON GROUP rb7 MODIF ID m11 DEFAULT 'X'.
SELECTION-SCREEN COMMENT 3(60) text-052.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key2 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-053.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key3 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-054.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key4 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-055.
SELECTION-SCREEN END OF LINE.

*Start comment U033808
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: rb_key5 RADIOBUTTON GROUP rb7 MODIF ID m11.
*SELECTION-SCREEN COMMENT 3(60) text-056.
*SELECTION-SCREEN END OF LINE.
*
*SELECTION-SCREEN BEGIN OF LINE.
*PARAMETERS: rb_key6 RADIOBUTTON GROUP rb7 MODIF ID m11.
*SELECTION-SCREEN COMMENT 3(60) text-057.
*SELECTION-SCREEN END OF LINE.
*End comment U033808

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key7 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-058.
SELECTION-SCREEN END OF LINE.

*&--Begin of Changes for E1DK917461 D3 U033808 Add table 915 to list
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key10 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-061.
SELECTION-SCREEN END OF LINE.
*&--End of Changes for E1DK917461 D3 U033808 Add table 915 to list

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key8 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-059.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key9 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-060.
SELECTION-SCREEN END OF LINE.

*&--Begin of Changes for E1DK917461 D3 U033808 Add table 922 to list
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key11 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-062.
SELECTION-SCREEN END OF LINE.
*&--End of Changes for E1DK917461 D3 U033808 Add table 922 to list

*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key5 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-056.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key6 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-057.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: rb_key12 RADIOBUTTON GROUP rb7 MODIF ID m11.
SELECTION-SCREEN COMMENT 3(60) text-069.
SELECTION-SCREEN END OF LINE.
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

SELECTION-SCREEN END OF BLOCK b6.

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
** Text-066 is changed.
*Previously text has Optional word. But now optional word is removed
* Because file name is mandatory for presentation server.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
SELECTION-SCREEN BEGIN OF BLOCK b7 WITH FRAME TITLE text-066.
PARAMETERS : p_dfile  TYPE localfile.
SELECTION-SCREEN END OF BLOCK b7.
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
