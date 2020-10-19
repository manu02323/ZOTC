************************************************************************
* PROGRAM    :  ZOTCE0212B_SALES_BOM_CREATION                          *
* TITLE      :  Auto Creation of Sales BOM                             *
* DEVELOPER  :  NEHA KUMARI                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0212                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Auto Creation of Material BOM and BOM Extension for    *
*               plant assignments                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 16-SEP-2014 NKUMARI  E2DK904869  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 24-Feb-2015 NKUMARI  E2DK904869  Defect 4058: Logic is added for     *
*                                  Background Mode Execution           *
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

*&---- Common Selection Parameters
* ---> Begin of change for Defect #4058 by NKUMARI

SELECT-OPTIONS: s_matnr  FOR  gv_matnr NO INTERVALS
                                       NO-EXTENSION.

PARAMETERS:
*             p_matnr  TYPE  matnr OBLIGATORY,       " Material Number
* <--- End of change for Defect #4058 by NKUMARI
             p_stlan  TYPE  stlan    DEFAULT c_stlan, " BOM Usage
             p_date   TYPE  sydatum  DEFAULT sy-datum. " Current Date of Application Server
SELECTION-SCREEN SKIP.

*&----  Checkbox for step1 and step2 option
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS :
       p_create AS CHECKBOX USER-COMMAND comm1, " Step 1 - Create BOM
       p_extend AS CHECKBOX USER-COMMAND comm1. " Step 2 - Extend BOM

*&---- Block to Extend Group BOM to Plant assignment
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-004.
SELECT-OPTIONS:  s_werk  FOR  gv_werks. " Plant

SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN END OF BLOCK b1.
