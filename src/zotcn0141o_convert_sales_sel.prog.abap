*&---------------------------------------------------------------------*
* PROGRAM    : ZOTCR0141O_CONVERT_SALES_SEL                            *
* TITLE       :  Reconciliation Report                                 *
*                                                                      *
* DEVELOPER  :  Khushboo Mishra                                        *
* OBJECT TYPE:  ALV report                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_CDD_0141                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Selection screen for ZOTCN0007O_CONVERT_SALES_ORDER                           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 05/16/2016   KMISHRA   E1DK917543 Initial Development
* ===========  ========  ========== ===================================*
*&---------------------------------------------------------------------*
*     S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

SELECT-OPTIONS:
     s_vkorg    FOR gv_vkorg,
     s_vtweg    FOR gv_vtweg
                DEFAULT '10'.

PARAMETERS:
     p_spart    TYPE spart
                DEFAULT c_spart.

SELECT-OPTIONS:
     s_auart    FOR gv_auart MATCHCODE OBJECT H_TVAK,

     s_erdat    FOR gv_erdat
                DEFAULT sy-datum,
     s_docref   FOR gv_docref. "MATCHCODE OBJECT ZOTCE_SO_REFDOC.

SELECTION-SCREEN END OF BLOCK b1.
