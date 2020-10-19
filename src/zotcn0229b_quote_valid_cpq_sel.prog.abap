***********************************************************************
*Program    : ZOTCN0229B_QUOTE_VALID_CPQ_SEL                          *
*Title      : Quote Validation to CPQ                                 *
*Developer  : Raghav Sureddi (u033876)                                *
*Object type: Interface                                               *
*SAP Release: SAP ECC 8.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: OTC_IDD_0229                                              *
*---------------------------------------------------------------------*
*Description: Send Order info for Quote validation  to SOA  and SOA   *
* will send it CPQ for Quote validations and response back.           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*20-June-2019  U033876      E2DK924884     Initial Development.       *
*=========== ============== ============== ===========================*

************************************************************************
*          SELECTION SCREEN DECLARATION
************************************************************************
SELECTION-SCREEN : BEGIN OF BLOCK order WITH FRAME TITLE TEXT-001.
SELECTION-SCREEN SKIP.

SELECT-OPTIONS: s_erdat FOR gv_erdat DEFAULT sy-datum,
* Begin of change for Defect 10289
                s_vkorg FOR gv_vkorg,
* End of change for Defect   10289
                s_vbeln FOR gv_vbeln.


SELECTION-SCREEN : END OF BLOCK order.
