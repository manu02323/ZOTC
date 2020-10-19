*&---------------------------------------------------------------------*
*&  Include           ZOTCN0217B_RIBA_CITI_BANK_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0217B_RIBA_CITI_BANK_SEL                          *
* TITLE      :  Interface for RIBA Payments Italy Outbound CITI Bank   *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    R3. D3_OTC_IDD_0217_RIBA_ITALY_Outbound-CITI Bank      *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Interface generate the payment medium files from  *
*               SAP system with RIBA (payment method R) Payment method *
*               based on the due date of customer open invoices        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
*18-Apr-2018  U033876   E1DK936113   Initial Development               *
*----------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS : p_laufd   TYPE laufd OBLIGATORY, " Date on Which the Program Is to Be Run
             p_laufi   TYPE laufi OBLIGATORY. " Additional Identification
SELECTION-SCREEN SKIP.
PARAMETERS: rb_pres  RADIOBUTTON GROUP rb2 USER-COMMAND comm2 MODIF ID mi2 DEFAULT 'X',
            p_phdr   TYPE localfile MODIF ID mi3,                  " Local file for upload/download
            rb_app   RADIOBUTTON GROUP rb2 MODIF ID mi2 ,
            p_ahdr   TYPE localfile MODIF ID mi6 DEFAULT gv_pfile. " Local file for upload/download

SELECTION-SCREEN END OF BLOCK b1 .
