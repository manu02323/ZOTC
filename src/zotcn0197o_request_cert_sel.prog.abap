*&---------------------------------------------------------------------*
*&  Include           ZOTCN0197O_REQUEST_CERT_SEL
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0197O_REQUEST_CERT_SEL                            *
* TITLE      :  Request Certificate of Origin                          *
* DEVELOPER  :  NEHA GARG                                              *
* OBJECT TYPE:  INTERFACE                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0197_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: SELECTION SCREEN INCLUDE                                *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-JUL-2016 NGARG E1DK919089 INITIAL DEVELOPMENT                     *
*&---------------------------------------------------------------------*
* 18-OCT-2016 MGARG   E1DK919089  D3_CR_0077&Defect_4188:              *
*                                 Build two BRFPLUS tables to store    *
*                                 commodity code desc& User logon      *
*                                 information. Added code to fetch EMI *
*                                 entries as country(sel_low)value     *
*&---------------------------------------------------------------------*
***********************************************************************
* Selection screen
***********************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-002.
PARAMETERS:
* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
      p_countr TYPE char2 OBLIGATORY AS LISTBOX DEFAULT 'CH'
      USER-COMMAND zcount VISIBLE LENGTH 27,
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
      p_gestyp TYPE char1 OBLIGATORY AS LISTBOX DEFAULT '1' " Gestyp of type Character
      USER-COMMAND zgest VISIBLE LENGTH 30,
      p_behand TYPE char1 OBLIGATORY AS LISTBOX DEFAULT '1' " Behand of type Character
      USER-COMMAND zbeha VISIBLE LENGTH 10.
SELECTION-SCREEN END OF BLOCK b.

* Bill
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-001.
PARAMETERS:     p_vbeln TYPE vbeln_vf MATCHCODE OBJECT shlp_vbuk. " Billing Document
PARAMETERS:     p_fkart TYPE fkart  MATCHCODE OBJECT h_tvfk MODIF ID mdf."
SELECTION-SCREEN END OF BLOCK a.

* Job Type 1
SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE text-003.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-010 MODIF ID md0.
PARAMETERS:  p_anzkzu(2) TYPE p DEFAULT 1 MODIF ID md0. " Anzkzu(2) of type Packed Number
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-011 MODIF ID md0.
PARAMETERS:  p_anzkre(2) TYPE p DEFAULT 1 MODIF ID md0. " Anzkre(2) of type Packed Number
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-012 MODIF ID md0.
PARAMETERS:  p_anzkdk(2) TYPE p DEFAULT 1 MODIF ID md0. " Anzkdk(2) of type Packed Number
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK c.

* Job type 2
SELECTION-SCREEN BEGIN OF BLOCK d WITH FRAME TITLE text-003.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-010 MODIF ID md1.
PARAMETERS:  p_anzkz2(2) TYPE p DEFAULT 1 MODIF ID md1. " Anzkz2(2) of type Packed Number
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-011 MODIF ID md1.
PARAMETERS:  p_anzkr2(2) TYPE p DEFAULT 1 MODIF ID md1. " Anzkr2(2) of type Packed Number
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK d.

* Job type 3
SELECTION-SCREEN BEGIN OF BLOCK e WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-011 MODIF ID md2.
PARAMETERS:  p_anzkr3(2) TYPE p DEFAULT 1 MODIF ID md2. " Anzkr3(2) of type Packed Number
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK e.

* Job type 4
SELECTION-SCREEN BEGIN OF BLOCK f WITH FRAME TITLE text-003.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(50) text-012 MODIF ID md3.
PARAMETERS:  p_anzkd4(2) TYPE p DEFAULT 1 MODIF ID md3. " Anzkd4(2) of type Packed Number
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK f.
