*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0050O_REBATE_CONVERSION                            *
* TITLE      :  OTC_CDD_0050_Convert_Rebate                            *
* DEVELOPER  :  SATEERTH DAS                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0050_Convert_Recipe                              *
*----------------------------------------------------------------------*
* DESCRIPTION: Uploads a user-generated spreadsheet (tab delimited)
*              file for a Call Transaction of VBO1 (create rebate).
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Jul-2012 SDAS     E1DK903273 INITIAL DEVELOPMENT                  *
* 31-Oct-2012 SPURI    E1DK905593 Defect 1247 : Incorrect
*                                 number of Agreements created for a
*                                 unique combination of Customer  and
*                                 GPO number.  Code Change : Removed
*                                 AT NEW statement  instead declared a
*                                 local variable to hold previous value
*                                 of GPO and customer.
*&---------------------------------------------------------------------*
* Selection Screen for File Location
  selection-screen begin of block b1 with frame title text-001.

* Radiobutton for presentation server filepath
  parameters : rb_pres  radiobutton group rb2
               modif id mi1 default 'X' user-command comm2.

* Input from Presentation Server Block
  selection-screen begin of block b2 with frame title text-002.

* Presentation Server File Inputs
  parameters: p_pfile  type localfile  modif id mi3.

  selection-screen end of block b2.

  selection-screen skip 1.

* Radiobutton for Application Server filepath
  parameters : rb_app radiobutton group rb2 modif id mi1 .

* Input from Application Server Block
  selection-screen begin of block b3 with frame title text-003.

* Application server PhysFile Path - Radio Button
  parameters: rb_aphy radiobutton group rb4 modif id mi5 default 'X'
              user-command comm4,
* Application server File name
              p_afile  type localfile modif id mi2.

  selection-screen skip 1.

* Radiobutton for Application Server - Logical Filename
  parameters: rb_alog radiobutton group rb4 modif id mi5,
*             Logical File Name
              p_alog type filepath-pathintern modif id mi7.

  selection-screen end of block b3.
  selection-screen end of block b1.

* For Mode Selection
  selection-screen begin of block b4 with frame title text-004.

*             Verify Only Radio Button
  parameters: rb_vrfy radiobutton group rb5 modif id mi9 default 'X',
*             Verify and Post Radio Button
              rb_post radiobutton group rb5 modif id mi9.

  selection-screen end of block b4.
