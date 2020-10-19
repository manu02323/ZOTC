*&---------------------------------------------------------------------*
*&  Include           ZOTCN0186B_SEND_BOM_TO_PPM_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0186B_SEND_BOM_TO_PPM                             *
* TITLE      :  D2_OTC_IDD_0186_Send Sales BOM structure to PPM        *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0186_Send Sales BOM structure to PPM             *
*----------------------------------------------------------------------*
* DESCRIPTION: The requirement is to send the BOM structure from SAP   *
* to PPM. From each Plant valid BOMs as on date will be extracted and  *
* stored in a flat file. This file subsequently will be uploaded to PPM*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-Sep-2014 SGHOSH   E2DK914957 PGL- INITIAL DEVELOPMENT -           *
*                                 Task Number: E2DK915243,E2DK915041   *
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_werks FOR gv_werks OBLIGATORY.
PARAMETER:      p_bomtyp TYPE stlan MODIF ID mi4 DEFAULT gv_bomtyp, " BOM Usage
                p_vdate TYPE datuv OBLIGATORY.                     " Current Date of Application Server


SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-002.
* Radio-button for Foreground
PARAMETER : rb_fore  RADIOBUTTON GROUP rb1 USER-COMMAND comm2 MODIF ID mi1 DEFAULT 'X'.
SELECTION-SCREEN BEGIN OF BLOCK fore WITH FRAME.
* Radio-button for Presentation Server
PARAMETERS: rb_pres  RADIOBUTTON GROUP rb2 USER-COMMAND comm2 MODIF ID mi2 DEFAULT 'X',
* File Path Presentation
            p_phdr   TYPE localfile MODIF ID mi3. " Local file for upload/download
* Radio-button for Application Server
PARAMETERS: rb_app   RADIOBUTTON GROUP rb2 MODIF ID mi2 ,
* File Path Application Server
            p_ahdr   TYPE localfile MODIF ID mi6 DEFAULT gv_pfile. " Local file for upload/download

SELECTION-SCREEN END OF BLOCK fore.
* Radio-button for Background
PARAMETERS : rb_back  RADIOBUTTON GROUP rb1 MODIF ID mi1.
SELECTION-SCREEN BEGIN OF BLOCK bck WITH FRAME.
* File Path Application Server
PARAMETERS : p_ahdr1   TYPE localfile MODIF ID mi9 DEFAULT gv_pfile. " Local file for upload/download
SELECTION-SCREEN END OF BLOCK bck.
SELECTION-SCREEN END OF BLOCK blk1.
