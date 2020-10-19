************************************************************************
* PROGRAM    :  ZOTCN0351B_FLIP_ITEM_CAT_SEL                           *
* TITLE      :  Update open Sales Order                                *
* DEVELOPER  :  Salman Zahir                                           *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0351                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update open Sales Order                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-SEP-2016 U033959  E1DK921540 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*

SELECTION-SCREEN : BEGIN OF BLOCK b1 WITH FRAME TITLE text-007.
SELECT-OPTIONS : s_vbeln FOR gv_vbeln MATCHCODE OBJECT cc_vbeln,          " Sales doc
                 s_erdat FOR gv_erdat,                                    " Date on Which Record Was Created
                 s_vkorg FOR gv_vkorg OBLIGATORY,                         " Sales organization
                 s_vtweg FOR gv_vtweg,                                    " Distribution channel
                 s_auart FOR gv_auart OBLIGATORY MATCHCODE OBJECT h_tvak. " Doc type
PARAMETERS : p_lfstk TYPE lfstk OBLIGATORY DEFAULT 'A'. " Delivery status
SELECTION-SCREEN : END OF BLOCK b1.
