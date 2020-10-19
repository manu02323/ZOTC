*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093_LIST_PRICE_SCR
*&---------------------------------------------------------------------*
**&--------------------------------------------------------------------*
**& PROGRAM   :  ZOTCO0093O_LIST_PRICE_SCR                             *
** TITLE      :  Selection Screen Details                              *
** DEVELOPER  :  Moushumi Bhattacharya                                 *
** OBJECT TYPE:  INTERFACE                                             *
** SAP RELEASE:  SAP ECC 6.0                                           *
**---------------------------------------------------------------------*
** WRICEF ID  :  D2_OTC_IDD_0093                                       *
**---------------------------------------------------------------------*
** DESCRIPTION:  Selection Screen Details                              *
**---------------------------------------------------------------------*
** MODIFICATION HISTORY:                                               *
**=====================================================================*
** DATE        USER     TRANSPORT  DESCRIPTION                         *
** =========== ======== ===============================================*
** 21-May-2014 MBHATTA1 E2DK900420 INITIAL DEVELOPMENT                 *
**---------------------------------------------------------------------*
* Oct-27-2015  RDAS     E2DK915852 Incident INC0249304 PGL B changes *
* Changes done to replace select option date with parameter.
* 28-Oct-2016 JAHANM  E1DK918891 Defect#5444 Performance Improvement   *
**---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK bl1 WITH FRAME.
SELECTION-SCREEN: BEGIN OF BLOCK bl2 WITH FRAME TITLE text-003.
*  Begin of change for D2_OTC_IDD_0093 / Incident INC0249304 by RDAS
*SELECT-OPTIONS: s_ersda FOR gv_ersda OBLIGATORY.
PARAMETERS : p_ersda TYPE ersda OBLIGATORY. " Created On
*End of change for D2_OTC_IDD_0093 / Incident INC0249304 by RDAS
SELECTION-SCREEN: END OF BLOCK bl2.
*  Begin of change for D2_OTC_IDD_0093 by MBHATTA1
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK bl3 WITH FRAME TITLE text-004.
PARAMETERS : p_cond TYPE kschl OBLIGATORY. "Selection Condition Type
PARAMETERS : p_tab  TYPE kotabnr OBLIGATORY. " Condition table
SELECTION-SCREEN: END OF BLOCK bl3.
* End of change for D2_OTC_IDD_0093 by MBHATTA1

*->> Start of Defect#5444 by Jahan.
SELECTION-SCREEN: BEGIN OF BLOCK bl6 WITH FRAME TITLE text-007.
SELECT-OPTIONS  : s_vkorg FOR gv_vkorg NO INTERVALS.
SELECT-OPTIONS  : s_vtweg FOR gv_vtweg NO INTERVALS.
SELECTION-SCREEN: END OF BLOCK bl6.
*->> Start of Defect#5444 by Jahan.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK bl4 WITH FRAME TITLE text-005.
SELECT-OPTIONS  : s_matnr FOR gv_matnr. "Material Number
SELECTION-SCREEN: END OF BLOCK bl4.

*->> Start of Defect#5444 by Jahan.
SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN: BEGIN OF BLOCK bl5 WITH FRAME TITLE text-006.
PARAMETERS : p_max TYPE i DEFAULT '5000'. " Created On
SELECTION-SCREEN: END OF BLOCK bl5.
*->> End of Defect#5444 by Jahan.

SELECTION-SCREEN: END OF BLOCK bl1.
