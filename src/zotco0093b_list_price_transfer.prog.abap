*&--------------------------------------------------------------------*
*& PROGRAM   :  ZOTCO0093B_LIST_PRICE_TRANSFER                        *
* TITLE      :  Main program for processing outbound IDOC             *
* DEVELOPER  :  Moushumi Bhattacharya                                 *
* OBJECT TYPE:  INTERFACE                                             *
* SAP RELEASE:  SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:  Outbound program for LIST_PRICE_TRANSFER copied from  *
*               ZMDMI0050_LIST_PRICE_TRANSFER for processing of       *
*               outbound idoc . As per D2 requirement it have been    *
*               copied from existing D1 Development and modifications *
*               have been done.                                       *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-May-2014 MBHATTA1 E2DK902074 INITIAL DEVELOPMENT                 *
* 03-Nov-2014 DARUMUG  E2DK902074 Defect # 1241                       *
*---------------------------------------------------------------------*
* Oct-27-2015  RDAS     E2DK915852 Incident INC0249304 PGL B changes *
* Changes done to replace select option date with parameter date
**---------------------------------------------------------------------*
REPORT zotco0093o_list_price_transfer NO STANDARD PAGE HEADING
                                      LINE-SIZE 132
                                      MESSAGE-ID zotc_msg.

*----------------------------------------------------------------------*
*     INCLUDES
*----------------------------------------------------------------------*
INCLUDE zotcn0093b_list_price_top. " Include ZOTCN0093_LIST_PRICE_TOP

INCLUDE zotcn0093b_list_price_scr. " Include ZOTCN0093_LIST_PRICE_SCR

INCLUDE zotcn0093b_list_price_sub. " Include ZOTCN0093_LIST_PRICE_SUB

*----------------------------------------------------------------------*
*     INITIALIZATION
*----------------------------------------------------------------------*
INITIALIZATION.
  PERFORM f_initialization.

*  Begin of change for D2_OTC_IDD_0093 by MBHATTA1
AT SELECTION-SCREEN ON p_cond.
  PERFORM f_validate_input.

AT SELECTION-SCREEN ON p_tab.
  PERFORM f_validate_input2.
*  End of change for D2_OTC_IDD_0093 by MBHATTA1
*----------------------------------------------------------------------*
*     START - OF - SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_send_idocs.
