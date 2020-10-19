*&---------------------------------------------------------------------*
*&  Include           ZOTCI0042N_PRICE_LOAD_WRAP_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD_WRAPPER                          *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shushant Nigam                                         *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: This is the wrapper program to ZOTCI0042B_PRICE_LOAD. Si*
* nce original program is taking lot of time to finish, hence objective*
* is to split the file into smaller files and schedule job with smaller*
* files                                                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*19-Nov-2015 SNIGAM   E2DK916145  Defect 1351                          *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
PARAMETERS: p_file  TYPE localfile DEFAULT '/appl/E2D/INT/Inbound/OTC/OTC_IDD_0042_SAP/TBP/' OBLIGATORY, " Local file for upload/download
            p_delay TYPE i DEFAULT 30.                                                                   " Delay of type Integers
SELECTION-SCREEN SKIP.
PARAMETERS: p_map AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK blk1.
