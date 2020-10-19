***********************************************************************
*Program    : ZOTCN0214O_CHECK_BOM_REV                                *
*Title      : Check Sales BOM revenue distribution                    *
*Developer  : Debomita Chakraborty                                    *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0214                                           *
*---------------------------------------------------------------------*
*Description: Check revenue of BOM main item. If it is not equal to   *
*             the total revenue of the components, then place a       *
*             delivery block on the Sales Order but allow saving it.  *
*             If user changes the Sales Order and again saves it,     *
*             again the above check is performed. If the revenues are *
*             equal then the delivery block is removed.               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*03-SEP-2014  DCHAKRA       E2DK904378      Initial Development       *
*---------------------------------------------------------------------*
*22-OCT-2014  DCHAKRA       E2DK904378      CR# 1006: The BOM revenue *
*                                           check is done for items   *
*                                           that have ABGRU as initial*
*&--------------------------------------------------------------------*
*29-OCT-2014 DCHAKRA        E2DK904378      CR# 548: The BOM revenue  *
*                                           check is restricted for   *
*                                           document types ZOR or ZSTD*
*                                           (maintained in EMI). If   *
*                                           reference document type is*
*                                           ZRRC (maintained in EMI)  *
*                                           then BOM revenue check is *
*                                           not done for that order.  *
*&--------------------------------------------------------------------*
* 12-DEC-2014 KSRIVAS        E2DK904378      Defect#2286
* The delivery block will be placed only on the sales order which has
* delivery status (XVBUP-LFSTA) = 'A' when the price discrepancy exists
* For Sales Order with status 'B' and 'C' even if the price discrepancy
* exists, there will be no delivery block.
*&--------------------------------------------------------------------*
* 24-DEC-2014 DCHAKRA        E2DK904378     Defect #1627: The check   *
*                                           for sub-items of BOM main *
*                                           item is done on the basis *
*                                           of Higher level item(VBAK-*
*                                           UEPOS) and Delivery Group *
*                                           (VBAK-GRKOR)so that       *
*                                           revenue check is valid for*
*                                           Multi-level BOM materials *
*                                           as well.                  *
*&--------------------------------------------------------------------*
* 06-JAN-2015  DCHAKRA       E2DK904378     Defect #2757: If there is *
*                                           no price mismatch the     *
*                                           delivery block is removed *
*                                           only if block on the order*
*                                           is same as that maintained*
*                                           in EMI.                   *
*&--------------------------------------------------------------------*
* 12-JAN-2015  ASK          E2DK904378      Defect #1627: If there is *
*                                           any item which is rejected*
*                                           for that do not execute   *
*                                           the logic                 *
*&--------------------------------------------------------------------*
* 18-FEB-2015 SMEKALA      E2DK904378       D2_CR481 Exclude Subsidiaries
*                                           from delivery block due to*
*                                           missing BOM Revenue split *
*&--------------------------------------------------------------------*
* 09-JUN-2015 ASK         E2DK913436       Defect 7212 : Correct logic*
*                                          for Sales order containing *
*                                          both referenced and        *
*                                          non-referenced items       *
*&--------------------------------------------------------------------*
* 08-AUG-2016 SMUKHER4    E2DK918606       Defect# 1863 : Debit and   *
*                                          credit memo request should *
*                                          go for billing block if the*
*                                          BoM component revenue split*
*                                          are not aggregated to 100% *
*&--------------------------------------------------------------------*
* 24-APR-2018 U100018     E1DK936170       Defect# 5535: Order going  *
*                                          for PD delivery block, when*
*                                          ship complete is checked   *
*                                          and order has multiple BoMs*
*                                          in it                      *
*&--------------------------------------------------------------------*
*&  Include           ZOTCN0214O_CHECK_BOM_REV                        *
*&--------------------------------------------------------------------*
*-->>>Begin of change for defect #548 by DCHAKRA.
 TYPES: BEGIN OF lty_vbak,
        vbeln TYPE vbeln_va, " Sales Document
        auart TYPE auart,    " Sales Document Type
        END OF lty_vbak.
 TYPES: lty_t_vbak TYPE STANDARD TABLE OF lty_vbak.
*<<<--End of change for defect #548 by DCHAKRA.

 DATA: li_constant TYPE STANDARD TABLE OF zdev_enh_status,       " Enhancement Status
       li_xvbap    TYPE STANDARD TABLE OF vbapvb INITIAL SIZE 0, " Internal table for XVBAP
       li_xkomv    TYPE STANDARD TABLE OF komv   INITIAL SIZE 0, " Internal table for XKOMV
       li_posnr    TYPE STANDARD TABLE OF posnr  INITIAL SIZE 0, " Internal table for item no.
       lv_del_blk  TYPE lifsk,                                   " Delivery block (document header)
       lv_con_typ  TYPE kschl,                                   " Condition Type
       lv_posnr    TYPE char50,                                  " String for item no.s
*>>>--Begin of change for defect #2286 by KSRIVAS.
       li_xvbup    TYPE STANDARD TABLE OF vbupvb INITIAL SIZE 0, " Document Structure for XVBAP/YVBAP
*<<<--End of change for defect #2286 by KSRIVAS.

*-->>>Begin of change for defect #548 by DCHAKRA.
       lv_kbetr    TYPE kbetr,             " Rate (condition amount or percentage)
       li_vbak     TYPE lty_t_vbak,
       lv_auart    TYPE auart,             " Sales Document Type
       lv_criteria TYPE z_criteria,        " Enh. Criteria
       lv_val_low  TYPE fpb_low,           " From Value
       lv_allowed  TYPE boolean,           " Boolean Variable (X=True, -=False, Space=Unknown)
       lwa_doctyp  TYPE mnt_s_auart_range, " Ranges Table Structure for 'Order Type'
       lr_doctyp   TYPE mnt_t_auart_range,
       lv_kbetr_temp(16) TYPE c,           "(+)ddwivedi
       li_xvbap_tmp   TYPE va_vbapvb_t,    " Defect 7212
       lwa_xvbap_tmp  TYPE vbapvb,         " Defect 7212
       lv_delblk_flag TYPE char1,          "By Jahan.
*<<<--End of change for defect #548 by DCHAKRA.
*-->>Begin of change for D2_OTC_EDD_0214 Defect# 1863 by SMUKHER4 on 08.08.2016
       lv_bilblk_flag TYPE flag,  " Bilblk_flag of type CHAR1
       lv_bil_blk     TYPE faksk. " Billing Block.
*<<--End of change for D2_OTC_EDD_0214 Defect# 1863 by SMUKHER4 on 08.08.2016
 FIELD-SYMBOLS: <lfs_constants> TYPE zdev_enh_status, " Enhancement Status
                <lfs_xvbap_bom> TYPE vbapvb,          " Sales Document: Item Data
*-->>> Begin of change for Defect #1627 by DCHAKRA
*                <lfs_xvbap_bom_1> TYPE vbapvb,        " Sales Document: Item Data
*<<<-- End of change for Defect #1627 by DCHAKRA
                <lfs_xkomv_bom> TYPE komv, " Pricing Communications-Condition Record
*>>>--Begin of change for defect #2286 by KSRIVAS.
                <lfs_xvbap_m>   TYPE vbapvb, " Sales Document: Item Data
                <lfs_xvbup>     TYPE vbupvb, " Reference Structure for XVBUP/YVBUP
*<<<--End of change for defect #2286 by KSRIVAS.
*-->>>Begin of change for defect #548 by DCHAKRA.
                <lfs_vbak> TYPE lty_vbak.
*<<<--End of change for defect #548 by DCHAKRA.
 CONSTANTS:  lc_enh_no    TYPE z_enhancement VALUE 'D2_OTC_EDD_0214', " Enhancement No.
             lc_cri_del   TYPE z_criteria    VALUE 'LIFSK',           " Enh. Criteria
*-->>Begin of change for D2_OTC_EDD_0214 Defect# 1863 by SMUKHER4 on 08.08.2016
             lc_cri_bil   TYPE z_criteria    VALUE 'FAKSK',          " Enh. Criteria for Billing Block
             lc_billing_auart TYPE z_criteria VALUE 'BILLING_AUART', " Enh. Criteria for ZCMR/ZDMR for billing block
*<<--End of change for D2_OTC_EDD_0214 Defect# 1863 by SMUKHER4 on 08.08.2016
             lc_cri_con   TYPE z_criteria    VALUE 'KSCHL_ZCCR', " Enh. Criteria
             lc_null      TYPE z_criteria    VALUE 'NULL',       " Enh. Criteria
             lc_trtyp_cr  TYPE trtyp         VALUE 'H',          " Transaction type for creation
             lc_trtyp_ch  TYPE trtyp         VALUE 'V',          " Transaction type for change
*>>>--Begin of change for defect #2286 by KSRIVAS.
             lc_lfsta_a   TYPE lfsta         VALUE 'A', " Delivery status
             lc_lfsta_c   TYPE lfsta         VALUE 'B', " Delivery status
*<<<--End of change for defect #2286 by KSRIVAS.
*-->>>Begin of change for defect #548 by DCHAKRA.
             lc_cri_typ1  TYPE z_criteria    VALUE 'AUART_ZOR',  " Enh. Criteria
             lc_cri_typ2  TYPE z_criteria    VALUE 'AUART_ZSTD', " Enh. Criteria
             lc_cri_ref   TYPE z_criteria    VALUE 'AUART_REF',  " Enh. Criteria
             lc_cri_vtweg TYPE z_criteria    VALUE 'VTWEG',      " Enh. Criteria
             lc_100       TYPE char6         VALUE '100.00'.     " 100 of type CHAR6 "By Jahan Defect # 1627

*<<<--End of change for defect #548 by DCHAKRA.

 IF t180-trtyp = lc_trtyp_cr OR
    t180-trtyp = lc_trtyp_ch.

*&-- Get Delivery Block and Condition type maintained in EMI
   CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
     EXPORTING
       iv_enhancement_no = lc_enh_no
     TABLES
       tt_enh_status     = li_constant.

   READ TABLE li_constant WITH KEY criteria = lc_null
                                   active   = abap_true
                                   TRANSPORTING NO FIELDS.
   IF sy-subrc = 0.
     DELETE li_constant WHERE active NE abap_true.
*-->>>Begin of change for defect #548 by DCHAKRA.
     SORT li_constant BY criteria sel_low.

     CONCATENATE 'AUART_' vbak-auart INTO lv_criteria.
     CONDENSE lv_criteria.
     READ TABLE li_constant TRANSPORTING NO FIELDS WITH KEY criteria = lv_criteria
                                                            BINARY SEARCH.
*   " Order Type Allowed For Enhancement
     IF sy-subrc EQ 0.
*-- Begin of D2_CR481
* The Enhancement should be executed only when the following criteria are met in addition
* to the constraints already implemented:  1)	The check should be limited to Order types ZOR / ZSTD
* 2)The distribution channel is VBAK-VTWEG = 10
* Order type check is already considering above, so check the distribution channel
       READ TABLE li_constant TRANSPORTING NO FIELDS WITH KEY criteria = lc_cri_vtweg
                                                              sel_low = vbak-vtweg
                                                              BINARY SEARCH.
       IF sy-subrc EQ 0.
*-- End of D2_CR481

*  Begin of Defect 7212
         li_xvbap_tmp = xvbap[].
         DELETE li_xvbap_tmp WHERE vgbel IS INITIAL.
         READ TABLE li_xvbap_tmp INTO lwa_xvbap_tmp INDEX 1.
*  End of Defect 7212

*         IF NOT vbak-vgbel IS INITIAL.  " Defect 5006
*         IF NOT xvbap-vgbel IS INITIAL. " Defect 5006   " Defect 7212
         IF lwa_xvbap_tmp-vgbel IS NOT INITIAL. "Defect 7212
           SELECT SINGLE auart " Sales Document Type
           FROM vbak           " Sales Document: Header Data
           INTO lv_auart
*           WHERE vbeln = vbak-vgbel.     " Defect 5006
*           WHERE vbeln = xvbap-vgbel. " Defect 5006    " Defect 7212
            WHERE vbeln = lwa_xvbap_tmp-vgbel. " Defect 7212
           IF sy-subrc EQ 0.
             CLEAR lv_val_low.
             lv_val_low = lv_auart.

             SORT li_constant BY criteria sel_low.

             READ TABLE li_constant ASSIGNING <lfs_constants> WITH KEY criteria = lc_cri_ref
                                                                       sel_low  = lv_val_low
                                                                       BINARY SEARCH.
             IF sy-subrc NE 0.
               lv_allowed = abap_true.
             ENDIF. " IF sy-subrc NE 0
           ENDIF. " IF sy-subrc EQ 0
*         ELSE. " ELSE -> IF sy-subrc NE 0    " Defect 7212
*           lv_allowed = abap_true.           " Defect 7212
         ENDIF. " IF lwa_xvbap_tmp-vgbel IS NOT INITIAL

*         IF NOT lv_allowed IS INITIAL.       " Defect 7212
         UNASSIGN <lfs_constants>.
*<<<--End of change for defect #548 by DCHAKRA.
         READ TABLE li_constant WITH KEY criteria = lc_cri_del ASSIGNING <lfs_constants>.
         IF sy-subrc = 0.

           lv_del_blk = <lfs_constants>-sel_low.
           UNASSIGN <lfs_constants>.
           READ TABLE li_constant WITH KEY criteria = lc_cri_con ASSIGNING <lfs_constants>.
           IF sy-subrc = 0.

             lv_con_typ = <lfs_constants>-sel_low.
             UNASSIGN <lfs_constants>.

             li_xvbap[] = xvbap[].
             li_xkomv[] = xkomv[].
*>>>--Begin of change for defect #2286 by KSRIVAS.
             li_xvbup[] = xvbup[].
             SORT li_xvbup BY vbeln posnr .
*<<<--End of change for defect #2286 by KSRIVAS.
             SORT li_xvbap BY uepos stlnr.
             SORT li_xkomv BY kposn kschl.

             CLEAR: lv_kbetr, lv_delblk_flag .
*>>>--Begin of change for defect #2286 by KSRIVAS.
*-&-- Identify the BOM header material
             LOOP AT li_xvbap ASSIGNING <lfs_xvbap_m> WHERE uepos IS INITIAL AND stlnr IS NOT INITIAL
                                                                             AND abgru IS INITIAL. " Defect 1627
*              Begin of Change for Defect 7212
               IF <lfs_xvbap_m>-vgbel IS NOT INITIAL.
                 IF lv_allowed IS INITIAL.
                   CONTINUE.
                 ENDIF. " IF lv_allowed IS INITIAL
               ENDIF. " IF <lfs_xvbap_m>-vgbel IS NOT INITIAL
*              End   of Change for Defect 7212

*-&-- Check the Delivery status of BOM header material
               READ TABLE li_xvbup ASSIGNING <lfs_xvbup> WITH KEY vbeln = <lfs_xvbap_m>-vbeln
                                                                  posnr = <lfs_xvbap_m>-posnr
                                                                  BINARY SEARCH.
               IF sy-subrc = 0.
                 IF <lfs_xvbup>-lfsta = lc_lfsta_a OR <lfs_xvbup>-lfsta = lc_lfsta_c. " Added by ddwivedi for C condition Defect  2286

*<<<--End of change for defect #2286 by KSRIVAS.
*-->>> Begin of change for Defect #1627 by DCHAKRA
*-&-- Identify the sub-items of a particular BOM header material by matching their Delivery group
                   LOOP AT li_xvbap ASSIGNING <lfs_xvbap_bom>.
*--> Begin of delete for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
*                                                          WHERE uepos IS NOT INITIAL
*                                                            AND grkor = <lfs_xvbap_m>-grkor
*                                                            AND abgru IS INITIAL.  " Defect 1627
*<-- End of delete for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
*--> Begin of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
                     IF <lfs_xvbap_bom>-uepos IS NOT INITIAL
                        AND <lfs_xvbap_bom>-uepos = <lfs_xvbap_m>-posnr
                        AND <lfs_xvbap_bom>-abgru IS INITIAL.
*<-- End of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
*-&-- Get the Rate corresponding to Condition type maintained in EMI for the sub-item of BOM header material
                       READ TABLE li_xkomv ASSIGNING <lfs_xkomv_bom> WITH KEY kposn = <lfs_xvbap_bom>-posnr
                                                                              kschl = lv_con_typ.
*<<<-- End of change for Defect #1627 by DCHAKRA
                       IF sy-subrc = 0.
                         lv_kbetr = lv_kbetr + ( <lfs_xkomv_bom>-kbetr / 10 ).
                       ENDIF. " IF sy-subrc = 0
*--> Begin of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
                     ENDIF. " IF uepos IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
                   ENDLOOP. " LOOP AT li_xvbap ASSIGNING <lfs_xvbap_bom>
*-->>> Begin of change for Defect #1627 by DCHAKRA
*               SOC by ddwivedi on 10-12-2014
                   lv_kbetr_temp = lv_kbetr .
                   CONDENSE lv_kbetr_temp .
                   IF lv_kbetr <> lc_100.
*                   IF lv_kbetr_temp+0(5) <> lc_100+0(5).
*               EOC by ddwivedi on 10-12-2014
                     lv_delblk_flag = abap_true.
                     IF <lfs_xvbap_bom> IS ASSIGNED.
                       APPEND <lfs_xvbap_bom>-uepos TO li_posnr.
                     ENDIF. " IF <lfs_xvbap_bom> IS ASSIGNED

                     CONCATENATE LINES OF li_posnr
                                   INTO lv_posnr
                           SEPARATED BY space.
                     CLEAR lv_kbetr.
                     EXIT.
                   ENDIF. " IF lv_kbetr <> lc_100
                   CLEAR lv_kbetr.
*<<<-- End of change for Defect #1627 by DCHAKRA
*>>>--Begin of change for defect #2286 by KSRIVAS.
                 ENDIF. " IF <lfs_xvbup>-lfsta = lc_lfsta_a OR <lfs_xvbup>-lfsta = lc_lfsta_c
               ENDIF. " IF sy-subrc = 0
             ENDLOOP. " LOOP AT li_xvbap ASSIGNING <lfs_xvbap_m> WHERE uepos IS INITIAL AND stlnr IS NOT INITIAL

             IF lv_delblk_flag = abap_true.
*-->>> Begin of change for Defect #2757 by DCHAKRA
*--&- If no manual block already exists on the order, only then Delivery block for BOM price mismatch (from EMI)
*     will be placed on the order.
               IF vbak-lifsk IS INITIAL OR xvbak-lifsk IS INITIAL.
*<<<-- End of change for Defect #2757 by DCHAKRA
                 vbak-lifsk = xvbak-lifsk = lv_del_blk.
                 MESSAGE i161(zotc_msg) WITH lv_posnr. " Order will be saved with Delvry Block.Price discrepancy exists for items &
*-->>> Begin of change for Defect #2757 by DCHAKRA
               ENDIF. " IF vbak-lifsk IS INITIAL OR xvbak-lifsk IS INITIAL
*<<<-- End of change for Defect #2757 by DCHAKRA
             ELSE. " ELSE -> IF lv_delblk_flag = abap_true
*-->>> Begin of change for Defect #2757 by DCHAKRA
*-&-- If price mismatch is not present but the order previously had Delivery Block for BOM price mismatch (from EMI),
*     only then clear the block. So the program can remove only the block which it is capable of placing.
*     All other blocks remain intact.
               IF vbak-lifsk = lv_del_blk OR xvbak-lifsk = lv_del_blk.
*<<<-- End of change for Defect #2757 by DCHAKRA
                 CLEAR: vbak-lifsk, xvbak-lifsk.
*-->>> Begin of change for Defect #2757 by DCHAKRA
               ENDIF. " IF vbak-lifsk = lv_del_blk OR xvbak-lifsk = lv_del_blk
*<<<-- End of change for Defect #2757 by DCHAKRA
             ENDIF. " IF lv_delblk_flag = abap_true
*<<<--End of change for defect #2286 by KSRIVAS.

           ENDIF. " IF sy-subrc = 0
*-->>>Begin of change for defect #548 by DCHAKRA.
*         ENDIF. " IF sy-subrc EQ 0        " Defect 7212
*<<<--End of change for defect #548 by DCHAKRA.
         ENDIF. " IF sy-subrc = 0

       ENDIF. " IF sy-subrc EQ 0
     ENDIF. " IF sy-subrc EQ 0
*-->>> Begin of change for D2_OTC_EDD_0214 Defect# 1863 by SMUKHER4 on 08.08.2016
************************************************************************
* Logic Added for Billing Block
* The Enhancement should be executed only when the following criteria are met in addition
* to the constraints already implemented:  1)	The check should be limited to Order types ZCMR/ZDMR
* 2)The distribution channel is VBAK-VTWEG = 10
* Order type check is already considering above, so check the distribution channel
************************************************************************
**** Fetching the constants from EMI for checking order type (ZCMR/ ZDMR ).
     READ TABLE li_constant ASSIGNING <lfs_constants>
                            WITH KEY criteria = lc_billing_auart
                                     sel_low = vbak-auart.
     IF sy-subrc IS INITIAL.
* Order type check is already considering above, so check the distribution channel
       READ TABLE li_constant TRANSPORTING NO FIELDS WITH KEY criteria = lc_cri_vtweg
                                                              sel_low = vbak-vtweg
                                                              BINARY SEARCH.
       IF sy-subrc EQ 0.
         li_xvbap_tmp = xvbap[].
         DELETE li_xvbap_tmp WHERE vgbel IS INITIAL.
         READ TABLE li_xvbap_tmp INTO lwa_xvbap_tmp INDEX 1.

         IF lwa_xvbap_tmp-vgbel IS NOT INITIAL.
           CLEAR lv_auart.
           SELECT SINGLE auart " Sales Document Type
           FROM vbak           " Sales Document: Header Data
           INTO lv_auart
            WHERE vbeln = lwa_xvbap_tmp-vgbel.
           IF sy-subrc EQ 0.
             CLEAR lv_val_low.
             lv_val_low = lv_auart.

             READ TABLE li_constant ASSIGNING <lfs_constants> WITH KEY criteria = lc_cri_ref
                                                                       sel_low  = lv_val_low
                                                                       BINARY SEARCH.
             IF sy-subrc NE 0.
               lv_allowed = abap_true.
             ENDIF. " IF sy-subrc NE 0
           ENDIF. " IF sy-subrc EQ 0
         ENDIF. " IF lwa_xvbap_tmp-vgbel IS NOT INITIAL

         UNASSIGN <lfs_constants>.
         CLEAR lv_bil_blk.
         READ TABLE li_constant ASSIGNING <lfs_constants>
                                            WITH KEY criteria = lc_cri_bil
                                            BINARY SEARCH. " Billing Block Criteria
         IF sy-subrc = 0.

           lv_bil_blk = <lfs_constants>-sel_low.
           UNASSIGN <lfs_constants>.
           CLEAR lv_con_typ.
*&--Checking the condution type.
           READ TABLE li_constant ASSIGNING <lfs_constants> WITH KEY criteria = lc_cri_con
                                                            BINARY SEARCH.
           IF sy-subrc = 0.

             lv_con_typ = <lfs_constants>-sel_low.
             UNASSIGN <lfs_constants>.

             li_xvbap[] = xvbap[].
             li_xkomv[] = xkomv[].
             li_xvbup[] = xvbup[].
             SORT li_xvbup BY vbeln posnr .
             SORT li_xvbap BY uepos stlnr.
             SORT li_xkomv BY kposn kschl.
*
             CLEAR: lv_kbetr.
             CLEAR lv_bilblk_flag.
*-&-- Identify the BOM header material
             LOOP AT li_xvbap ASSIGNING <lfs_xvbap_m> WHERE uepos IS INITIAL AND stlnr IS NOT INITIAL
                                                                             AND abgru IS INITIAL.
               IF <lfs_xvbap_m>-vgbel IS NOT INITIAL.
                 IF lv_allowed IS INITIAL.
                   CONTINUE.
                 ENDIF. " IF lv_allowed IS INITIAL
               ENDIF. " IF <lfs_xvbap_m>-vgbel IS NOT INITIAL
*-&-- Identify the sub-items of a particular BOM header material by matching their Delivery group
               LOOP AT li_xvbap ASSIGNING <lfs_xvbap_bom>.
*--> Begin of delete for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
*                                                          WHERE uepos IS NOT INITIAL
*                                                            AND grkor = <lfs_xvbap_m>-grkor
*                                                            AND abgru IS INITIAL.
*<-- End of delete for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
*--> Begin of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
                 IF <lfs_xvbap_bom>-uepos IS NOT INITIAL
                    AND <lfs_xvbap_bom>-uepos = <lfs_xvbap_m>-posnr
                    AND <lfs_xvbap_bom>-abgru IS INITIAL.
*<-- End of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
*-&-- Get the Rate corresponding to Condition type maintained in EMI for the sub-item of BOM header material
                   READ TABLE li_xkomv ASSIGNING <lfs_xkomv_bom> WITH KEY kposn = <lfs_xvbap_bom>-posnr
                                                                          kschl = lv_con_typ.
                   IF sy-subrc = 0.
                     lv_kbetr = lv_kbetr + ( <lfs_xkomv_bom>-kbetr / 10 ).
                   ENDIF. " IF sy-subrc = 0
*--> Begin of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
                 ENDIF. " IF uepos IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0214_Defect# 5535 by U100018 on 24-APR-2018
               ENDLOOP. " LOOP AT li_xvbap ASSIGNING <lfs_xvbap_bom>
               lv_kbetr_temp = lv_kbetr .
               CONDENSE lv_kbetr_temp .
               IF lv_kbetr <> lc_100.

                 lv_bilblk_flag = abap_true.
                 IF <lfs_xvbap_bom> IS ASSIGNED.
                   APPEND <lfs_xvbap_bom>-uepos TO li_posnr.
                 ENDIF. " IF <lfs_xvbap_bom> IS ASSIGNED

                 CONCATENATE LINES OF li_posnr
                               INTO lv_posnr
                       SEPARATED BY space.
                 CLEAR lv_kbetr.
                 EXIT.
               ENDIF. " IF lv_kbetr <> lc_100
               CLEAR lv_kbetr.
             ENDLOOP. " LOOP AT li_xvbap ASSIGNING <lfs_xvbap_m> WHERE uepos IS INITIAL AND stlnr IS NOT INITIAL
             IF lv_bilblk_flag = abap_true.
***--&- If no manual block already exists on the order, only then Billing block for BOM price mismatch (from EMI)
***     will be placed on the order.
               IF vbak-faksk IS INITIAL OR xvbak-faksk IS INITIAL.
                 vbak-faksk = xvbak-faksk = lv_bil_blk.
                 MESSAGE i937(zotc_msg) WITH lv_posnr. " Order will be saved with Billng Block.Price discrepancy exists for items &

               ENDIF. " IF vbak-faksk IS INITIAL OR xvbak-faksk IS INITIAL

             ELSE. " ELSE -> IF lv_bilblk_flag = abap_true

*-&-- If price mismatch is not present but the order previously had Billing Block for BOM price mismatch (from EMI),
*     only then clear the block. So the program can remove only the block which it is capable of placing.
*     All other blocks remain intact.
               IF vbak-faksk = lv_bil_blk OR xvbak-faksk = lv_bil_blk.

                 CLEAR: vbak-faksk, xvbak-faksk.

               ENDIF. " IF vbak-faksk = lv_bil_blk OR xvbak-faksk = lv_bil_blk

             ENDIF. " IF lv_bilblk_flag = abap_true
           ENDIF. " IF sy-subrc = 0
         ENDIF. " IF sy-subrc = 0
       ENDIF. " IF sy-subrc EQ 0
     ENDIF. " IF sy-subrc IS INITIAL
*<<<--End of change for D2_OTC_EDD_0214 Defect# 1863 by SMUKHER4 on 08.08.2016

*-->>>Begin of change for defect #548 by DCHAKRA.
   ENDIF. " IF sy-subrc = 0
*<<<--End of change for defect #548 by DCHAKRA.
 ENDIF. " IF t180-trtyp = lc_trtyp_cr OR
