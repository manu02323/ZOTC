class ZOTCCL_RR_CONTRACT_REF definition
  public
  final
  create public .

public section.
*"* public components of class ZOTCCL_RR_CONTRACT_REF
*"* do not include other source files here!!!

  interfaces IF_BADI_INTERFACE .
  interfaces IF_SD_REF_DOC_CUST .
protected section.
*"* protected components of class ZOTCCL_RR_CONTRACT_REF
*"* do not include other source files here!!!
private section.
*"* private components of class ZOTCCL_RR_CONTRACT_REF
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZOTCCL_RR_CONTRACT_REF IMPLEMENTATION.


METHOD IF_SD_REF_DOC_CUST~GET_INFO_STRUCTURES.

* ====================================================================== *
* 1) Archive info strucures (CT_AIND_STR1) can be checked and it is allowed
*    to delete archive info strucures if archived sales documents shall not
*    be selected from deleted archive info strucures. The consequence of this
*    term is that it is not allowed to add (e.g. by INSERT or APPEND) lines.
*    The imported archive info strucures are the maximum valid one.
* ====================================================================== *

* Archive information structure 'Z_SAP_SD_VBAK4' shall not be considered by searching archived sales documents
  DELETE ct_aind_str1 WHERE archindex = 'Z_SAP_SD_VBAK4'  " Archive information structure 'Z_SAP_SD_VBAK4'
                           and ITYPE  = 'I'.              " ITYPE shall be 'I' ('I' means info structure)

ENDMETHOD.


METHOD if_sd_ref_doc_cust~search_for_ref_doc.

************************************************************************
* PROGRAM    :  ZIM_OTC_RR_CONTRACT_REF (Enh Implementation)           *
* TITLE      :  SO Creation with Contracts Reference                   *
* DEVELOPER  :  Suman K Pandit                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0086                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:  SO_Creation_with_Contracts                             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 11-12-2012  SPANDIT  E1DK908349 INITIAL DEVELOPMENT                  *
* 14-Jan-2014 SMUKHER  E1DK912591 CR#1151 : Performance Improvement    *
* 03-Feb-2014 SNIGAM   E1DK912591 CR#1183:System not picking up correct*
*                                 Contract based on Sold-to/Ship-to/Mat*
*                                 -erial combination
* 19-Aug-2015 BMAJI    E2DK914818 Def#856: Items which are marked for  *
*                                 Rejection in the Contract,will not be*
*                                 referenced while creating Sales Order*
*&---------------------------------------------------------------------*

* Local types
*---> Begin of Change for Defect#856 by BMAJI
  TYPES: BEGIN OF lty_vbap,
           vbeln TYPE vbeln_va, "Contract no
           posnr TYPE posnr_va, "Contract Item
           abgru TYPE abgru_va, "Reason for Rejection
          END OF lty_vbap.
*---> End of Change for Defect#856 by BMAJI
  TYPES: BEGIN OF lty_item,
           vbeln TYPE vbeln, "Contract no
           posnr TYPE posnr, "Contract Item
**&&-- Begin of CR#1151
           datab TYPE datab_vi, "Contract valid from
           datbi TYPE datbi_vi, "Contract valid to
**&&-- End of CR#1151
         END OF lty_item,

         lty_t_item TYPE STANDARD TABLE OF lty_item. " local internal table

* Local constants
  CONSTANTS: lc_vbtyp TYPE vbtyp VALUE 'C',                             "Order
             lc_answer TYPE char1 VALUE '2',                            " Answer of type CHAR1
             lc_shipto TYPE char25 VALUE '(SAPMV45A)KUWEV-KUNNR',       " Shipto of type CHAR25
             lc_mprogram   TYPE char30 VALUE 'ZIM_OTC_RR_CONTRACT_REF', "Program name
             lc_mparameter TYPE char05 VALUE 'AUART',                   "Parameter KSCHL
             lc_on TYPE char1 VALUE 'X',                                "Flag ON
             lc_option_eq  TYPE char2 VALUE 'EQ',                       "Option - EQ.
             lc_parvw_we  TYPE parvw VALUE 'WE'.                        "Partner Function Sold-To"CR#1183++

* Local internal table / work area
  DATA: li_item                TYPE lty_t_item,
        lwa_item               TYPE listvbap, " Referenced headers/items

*---> Begin of Change for Defect#856 by BMAJI
        lwa_item1 TYPE lty_item,                                 " Local work area
        lv_vbeln TYPE vbeln_va,                                  " Local variable
        lv_posnr TYPE posnr_va,                                  " Local variable
        li_vbap  TYPE STANDARD TABLE OF lty_vbap INITIAL SIZE 0, " Local internal table
        li_item1 TYPE lty_t_item,                                " Local internal table
        lv_matnr TYPE matnr.                                     " Local variable

  FIELD-SYMBOLS: <lfs_vbap> TYPE lty_vbap. " Field symbols
*<--- End of Change for Defect#856 by BMAJI

* Local Variable
  DATA: lv_trg_typ TYPE edi_bsart. " Document type

* Local field symbol
  FIELD-SYMBOLS: <lfs_ship_to> TYPE kunwe. " Ship-to party

* ====================================================================== *
* 1) Checks for Sales order
* ====================================================================== *
  IF NOT is_vbak-vbtyp = lc_vbtyp. "only in case of sales order
    RETURN.
  ENDIF.

* ====================================================================== *
* 2) search for existing reference documents on database
* ====================================================================== *

  SELECT SINGLE mvalue2          " Select Options: Value High
         FROM   zotc_prc_control " OTC Process Team Control Table
         INTO   lv_trg_typ
         WHERE  vkorg      = is_vbak-vkorg  AND
                vtweg      = is_vbak-vtweg  AND
                mprogram   = lc_mprogram    AND
                mparameter = lc_mparameter  AND
                mactive    = lc_on          AND
                soption    = lc_option_eq   AND
                mvalue1    = is_vbak-auart.
  IF sy-subrc IS INITIAL.
*     Get ship to
    ASSIGN (lc_shipto) TO <lfs_ship_to>.
    IF sy-subrc = 0.

* select respective contract document from database
      SELECT vapma~vbeln
             vapma~posnr
**&&-- Begin of CR#1151
             vapma~datab
             vapma~datbi
**&&-- End of CR#1151.
             INTO TABLE li_item
             FROM vapma
             INNER JOIN vbpa ON
             vapma~vbeln = vbpa~vbeln
                          WHERE vapma~matnr =  is_vbap-matnr AND
                                vapma~vkorg =  is_vbak-vkorg AND
                                vapma~vtweg =  is_vbak-vtweg AND
                                vapma~spart =  is_vbak-spart AND
                                vapma~auart =  lv_trg_typ    AND
                                vapma~kunnr =  is_vbak-kunnr AND
*                                vapma~datab <=  sy-datum     AND    " Commented for  CR#1151.
*                                vapma~datbi >=  sy-datum     AND    " Commented for  CR#1151.
                                vbpa~kunnr   =  <lfs_ship_to> AND
                                vbpa~parvw  = lc_parvw_we. "'WE'.   "Added by SNIGAM under CR-1183 on 03-Feb-2014


**&&-- Begin of CR#1151
      IF sy-subrc EQ 0.
*       Don't consider those contract for which 'Contract start date'
*       is in future. Means delete those contracts for which DATAB (Contract
*       start date) is greater than current date
*       Similarly, Don't consider those contract for which 'Contract End date'
*       is in Past. Means delete those contracts for which DATBI (Contract
*       end date) is less than current date
        DELETE li_item WHERE ( datab GT sy-datum )
                          OR ( datbi LT sy-datum ).
      ENDIF. " IF sy-subrc EQ 0
**&&-- End of CR#1151.
* In case mutiple contracts are found for a given Sold to, Ship to
* and Material. BADI will default the very first contract. Pick
* the contract with the least number.
*      IF sy-subrc EQ 0.         "CR-1151: Commented
      IF li_item IS NOT INITIAL. "CR-1151: Added
        SORT li_item BY vbeln ASCENDING.
*---> Begin of Change for Defect#856 by BMAJI
* We will not delete duplicate entries here.
*        DELETE ADJACENT DUPLICATES FROM li_item COMPARING vbeln.
*<--- End of Change for Defect#856 by BMAJI

*---> Begin Of Change for Defect#856 by BMAJI
*&&-- After filtering out multiple contracts, it will retain ONLY 1 contract#
*     with multiple items (we need these for Valid From & Valid To Dates)
        CLEAR lwa_item1.
        READ TABLE li_item INTO lwa_item1 INDEX 1.
        IF sy-subrc IS INITIAL.
*&&-- Contract #
          lv_vbeln = lwa_item1-vbeln.
* We will now check if the Material which the user has entered on
* the new Sales Order is already marked for Rejection or not.
          SELECT vbeln " Contract Number (in this case)
                 posnr " Item Number
                 abgru " Reason for Rejection
            INTO TABLE li_vbap
            FROM vbap  " Sales Document: Item Data
            WHERE vbeln = lv_vbeln
              AND matnr = is_vbap-matnr.
          IF sy-subrc IS INITIAL.
* It may happen that a Material has one line item
* marked for Rejection, and another line item not.
* In such cases, the Material will not be referenced
* from Contract.
            REFRESH: li_item1.
            li_item1[] = li_item[].
            SORT li_item1 BY posnr.
            REFRESH li_item[].

            LOOP AT li_vbap ASSIGNING <lfs_vbap>.
              IF <lfs_vbap>-abgru IS INITIAL.
                READ TABLE li_item1 INTO lwa_item1
                                    WITH KEY posnr = <lfs_vbap>-posnr
                                    BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  lwa_item-vbeln = <lfs_vbap>-vbeln.
                  lwa_item-posnr = <lfs_vbap>-posnr.
                  lwa_item-datab = lwa_item1-datab.
                  lwa_item-datbi = lwa_item1-datbi.
                  APPEND lwa_item TO li_item.
                  CLEAR lwa_item.
                ENDIF. " IF sy-subrc IS INITIAL
              ELSE. " ELSE -> IF sy-subrc IS INITIAL
* If the item is marked for Rejection, a information message
* will be displayed.
                MESSAGE i948(zotc_msg) WITH <lfs_vbap>-posnr. "'Marked for Rejection.
              ENDIF. " IF <lfs_vbap>-abgru IS INITIAL
            ENDLOOP. " LOOP AT li_vbap ASSIGNING <lfs_vbap>
            UNASSIGN <lfs_vbap>.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF sy-subrc IS INITIAL
*<--- End of Change for Defect#856 by BMAJI


* ====================================================================== *
* 3) Return data
* ====================================================================== *

* if you add one or more items in the empty hnw_vbap
        IF li_item IS NOT INITIAL AND ct_hnw_vbap IS INITIAL.
          cv_answer = lc_answer.
        ENDIF. " IF li_item IS NOT INITIAL AND ct_hnw_vbap IS INITIAL
* if you add one or more items in the already filled hnw_vbap
        IF li_item IS NOT INITIAL AND ct_hnw_vbap IS NOT INITIAL.
          cv_answer         = lc_answer.
          cv_ang_item_exist = space.
          cv_kon_item_exist = space.
        ENDIF. " IF li_item IS NOT INITIAL AND ct_hnw_vbap IS NOT INITIAL

        READ TABLE li_item INTO lwa_item1 INDEX 1.
        IF sy-subrc = 0.
          lwa_item-vbeln = lwa_item1-vbeln.
          lwa_item-posnr = lwa_item1-posnr.
          APPEND lwa_item TO ct_hnw_vbap.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF.

* fill 'hnw_vbap' header line with the first table element
  READ TABLE ct_hnw_vbap INDEX 1 INTO cs_hnw_vbap.
  IF sy-subrc IS INITIAL.
*    nothing to handle
  ENDIF. " IF sy-subrc IS INITIAL
ENDMETHOD.
ENDCLASS.
