*&---------------------------------------------------------------------*
*&  Include           ZOTCI00219N_INTRSTCHARGE_SEL
*&---------------------------------------------------------------------*
************************************************************************
* INCLUDE    : ZOTCI00219N_INTRSTCHARGE_SEL                            *
* TITLE      : Send Intrest Charges to fabn                            *
* DEVELOPER  : Manoj Thatha                                            *
* OBJECT TYPE: Interface                                               *
* SAP RELEASE: SAP ECC 6.0                                             *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_IDD_0219                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Include for Local Class Definition & Implementation     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 20-FEB-2018  MTHATHA   E1DK934654  Initial Development               *
*----------------------------------------------------------------------*
*&--Block 1Selection Screen: selection criterion
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
SELECT-OPTIONS:
  s_docno  FOR   bkpf-belnr, " Accounting Document Number
  s_cdat   FOR   bkpf-cpudt. " Day On Which Accounting Document Was Entered   Posting Date in the Document
PARAMETERS:
  p_bukrs  TYPE bukrs  OBLIGATORY , " Company Code
  p_gjahr  TYPE gjahr OBLIGATORY.   " Fiscal Year," Fiscal Year
PARAMETERS:p_regn  TYPE c AS CHECKBOX. " Reg of type Character
SELECTION-SCREEN END OF BLOCK blk1.
