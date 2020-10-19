*&---------------------------------------------------------------------*
*&  Include           ZOTCN0405O_DYN_INCOM_VBAK
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0405O_DYN_INCOM_VBAK(Include)                     *
* TITLE      :  Dynamic Incompletion SalesOrder Header                 *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0405                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Dynamic Incompletion SalesOrder Header .
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 21-Feb-2018  U033876  E1DK934711  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
* 03-May-2018  U033876  E1DK936465  Defect 5811: add Order type in EMI *
* 04-Dec-2018  u033876  E1DK939676 Defect 7788, 8006 add incompletion  *
*                       log, if any item vbap-cepok = "B"              *
* 04-Feb-2019  u033876  E1DK940408 Defect 8291  add incompletion log, if*
*                       if any item vbap-cepok = "B"  and also Check   *
*                       delivery status                                *
*&---------------------------------------------------------------------*
* Begin of change for defect 7788 by U033876
 TYPES: BEGIN OF lty_vbap,
          vbeln TYPE vbeln_va, " Sales Document
          posnr TYPE posnr_va, " Sales Document Item
          cepok TYPE cepok,    " Status expected price
        END OF lty_vbap.
* End of change for defect 7788 by U033876
 DATA:
   lwa_enh_status TYPE zdev_enh_status,                   " Enhancement Status
   li_enh_stat    TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
   lwa_sel_textid TYPE selopt,                            " Transfer Structure for Select Options
   li_sel_textid  TYPE TABLE OF selopt,                   " Transfer Structure for Select Options
   lv_bran1       TYPE bran1_d,                           " Industry Code 1
   li_stxh        TYPE STANDARD TABLE OF stxh,            " STXD SAPscript text file header
   lwa_vbuv_tmp       TYPE vbuvvb,                        " Reference structure for XVBUK/YVBUK
   lwa_thead      TYPE theadvb,                           " Reference Structure for XTHEAD
   lv_no_text     TYPE boole_d,                           " Data element for domain BOOLE: TRUE (='X') and FALSE (=' ')
* Begin of change for defect 7788 by U033876
   li_vbap        TYPE STANDARD TABLE OF lty_vbap,
   lwa_vbap       TYPE lty_vbap,
   lwa_vbap_tmp   TYPE vbapvb,   " Document Structure for XVBAP/YVBAP
   lv_tabix       TYPE sy-tabix, " Index of Internal Tables
* End of change for defect 7788 by U033876
* Begin of Change for Defect 8291 by U033876
   lv_fehgr       TYPE fehgr, " Incompletion procedure for sales document
* End of Change for Defect 8291 by U033876
   li_xvbuv       TYPE STANDARD TABLE OF vbuvvb. " Structure for Internal Table XVBUV

 CONSTANTS: lc_enh_0405    TYPE z_enhancement VALUE 'OTC_EDD_0405', " Enhancement No.
            lc_crit_vkorg  TYPE z_criteria    VALUE 'VKORG',        " Enh. Criteria
* Begin of change for Defect 5811-> Order type EMI  check
            lc_crit_auart  TYPE z_criteria    VALUE 'AUART', " Enh. Criteria
* End of change for  Defect 5811-> Order type EMI  check
            lc_crit_bran1  TYPE z_criteria    VALUE 'BRAN1',        " Enh. Criteria
            lc_crit_null   TYPE z_criteria    VALUE 'NULL',         " Enh. Criteria
            lc_text        TYPE z_criteria    VALUE 'TEXT_ID',      " Enh. Criteria
            lc_vbbk        TYPE tdobject      VALUE 'VBBK',         " Texts: Application Object
            lc_sign        TYPE char1         VALUE 'I',            " Sign "I'
            lc_option      TYPE char4         VALUE 'EQ',           "Equal to
            lc_rv45a       TYPE tabname       VALUE 'RV45A_UV  ',   " Table Name
            lc_posnr       TYPE posnr         VALUE '000000',       " Item number of the SD document
            lc_dyn_incomp  TYPE fdnam_vb      VALUE 'ZZDYN_INCOMP', " Document field name
            lc_fehgr_z1    TYPE fehgr         VALUE 'Z1',           " Incompletion procedure for sales document
            lc_fcode_ktex  TYPE fcode_fe      VALUE 'KTEX_SUB',     " Screen for creating missing data
            lc_statg_01    TYPE statg         VALUE '01',           " Status group
* Begin of change for defect 7788 by U033876
            lc_vbap        TYPE tabname       VALUE 'VBAP',  " Table Name
            lc_cepok       TYPE fdnam_vb      VALUE 'CEPOK', " Document field name
            lc_fehgr_z2    TYPE fehgr         VALUE 'Z2',    " Incompletion procedure for sales document
            lc_fcode_pkon  TYPE fcode_fe      VALUE 'PKON',  " Screen for creating missing data
            lc_sortf_9999  TYPE rang_tvuvf    VALUE '9999',  " Processing sequence of incompletion log
            lc_statg_06    TYPE statg         VALUE '06',    " Status group
            lc_b           TYPE cepok         VALUE 'B',     " Status expected price
* Begin of Change for Defect 8291 by U033876
            lc_pstyv       TYPE z_criteria    VALUE 'PSTYV', " Enh. Criteria
            lc_c           TYPE lfsta         VALUE 'C',     " Delivery status
* End of Change for Defect 8291 by U033876
* End of change for defect 7788 by U033876
            lc_etenr       TYPE etenr         VALUE '0000'. " Delivery Schedule Line Number

* Get Emi details
 CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
   EXPORTING
     iv_enhancement_no = lc_enh_0405
   TABLES
     tt_enh_status     = li_enh_stat.


* binaary Search was not used as the table is low entries
 READ TABLE li_enh_stat INTO lwa_enh_status
                        WITH KEY criteria = lc_crit_null
                                 active   = abap_true .
 IF sy-subrc = 0.

   READ TABLE li_enh_stat INTO lwa_enh_status
                          WITH KEY criteria = lc_crit_vkorg
                                   sel_low  = xvbak-vkorg
                                   active   = abap_true .
   IF sy-subrc = 0.
* Begin of change for Defect 5811-> Order type EMI  check
     READ TABLE li_enh_stat INTO lwa_enh_status
                            WITH KEY criteria = lc_crit_auart
                                     sel_low  = xvbak-auart
                                     active   = abap_true .
     IF sy-subrc = 0.
* End of change for  Defect 5811-> Order type EMI  check
       READ TABLE li_enh_stat INTO lwa_enh_status
                              WITH KEY criteria = lc_crit_bran1
                                       active   = abap_true .
       IF sy-subrc = 0.


         SELECT SINGLE bran1 FROM kna1 " General Data in Customer Master
                     INTO lv_bran1 WHERE kunnr = xvbak-kunnr
                                   AND     bran1 = lwa_enh_status-sel_low.
         IF sy-subrc = 0.

           CLEAR: lwa_enh_status.
           LOOP AT li_enh_stat INTO lwa_enh_status
                     WHERE criteria = lc_text AND active EQ abap_true.
             lwa_sel_textid-sign = lc_sign.
             lwa_sel_textid-option = lc_option.
             lwa_sel_textid-low    = lwa_enh_status-sel_low.
             APPEND lwa_sel_textid TO li_sel_textid.
             CLEAR: lwa_sel_textid.
           ENDLOOP. " LOOP AT li_enh_stat INTO lwa_enh_status

* Now final check to see if there are any heder texts else raise
* incompletion log
* first check in Database, If not check in internal table.
           CLEAR:  lv_no_text .
           SELECT * FROM stxh INTO TABLE li_stxh
                                     WHERE tdobject = lc_vbbk
                                     AND   tdname   = xvbak-vbeln
                                     AND   tdid     IN li_sel_textid.
           IF sy-subrc NE 0.
             lv_no_text = abap_true.
             LOOP AT xthead INTO lwa_thead
                               WHERE  tdobject = lc_vbbk
                               AND    tdid     IN li_sel_textid
                               AND    tdspras IS NOT INITIAL
                               AND    tdfuser IS NOT INITIAL
                               AND    tdfdate IS NOT INITIAL.
               CLEAR:  lv_no_text .
             ENDLOOP. " LOOP AT xthead INTO lwa_thead
             IF sy-subrc NE 0.
               lv_no_text = abap_true.
             ENDIF. " IF sy-subrc NE 0
           ELSE. " ELSE -> IF sy-subrc NE 0
             CLEAR:  lv_no_text .
           ENDIF. " IF sy-subrc NE 0
           IF      lv_no_text = abap_true.
* Only put the entry if there is no entry lredy existing.
             CLEAR: lwa_vbuv_tmp.
             li_xvbuv[] = xvbuv[].
             SORT li_xvbuv BY vbeln posnr tbnam fdnam.
             READ TABLE li_xvbuv INTO lwa_vbuv_tmp
                                   WITH KEY vbeln = xvbak-vbeln
                                            posnr = lc_posnr
                                            tbnam = lc_rv45a
                                            fdnam = lc_dyn_incomp BINARY SEARCH.
             IF sy-subrc NE 0.
               CLEAR: lwa_vbuv_tmp.
               lwa_vbuv_tmp-vbeln = xvbak-vbeln.
               lwa_vbuv_tmp-posnr = lc_posnr.
               lwa_vbuv_tmp-tbnam = lc_rv45a.
               lwa_vbuv_tmp-fdnam = lc_dyn_incomp.
               lwa_vbuv_tmp-fehgr = lc_fehgr_z1.
               lwa_vbuv_tmp-statg = lc_statg_01.
               lwa_vbuv_tmp-fcode = lc_fcode_ktex.

               APPEND lwa_vbuv_tmp TO xvbuv.
               CLEAR:lwa_vbuv_tmp.

             ENDIF. " IF sy-subrc NE 0
           ENDIF. " IF lv_no_text = abap_true

         ENDIF. " IF sy-subrc = 0


       ENDIF. " IF sy-subrc = 0
* Begin of change for Defect 5811-> Order type EMI  check
     ENDIF. " IF sy-subrc = 0
* End of change for Defect 5811-> Order type EMI  check
   ENDIF. " IF sy-subrc = 0

* Begin of change for defect 7788 and 8006 by U033876

   READ TABLE xvbap TRANSPORTING NO FIELDS
                           WITH KEY cepok = lc_b.
   IF sy-subrc = 0.
     LOOP AT xvbap INTO lwa_vbap_tmp  WHERE cepok = lc_b.
* Begin of Change for Defect 8291 by U033876
* trigger below logic only for BOM Header
       READ TABLE li_enh_stat INTO lwa_enh_status
                              WITH KEY criteria = lc_pstyv
                                       sel_low  = lwa_vbap_tmp-pstyv
                                       active   = abap_true .
       IF sy-subrc = 0.
* Begin of Change for Defect 8291 by U033876
         CLEAR: lv_fehgr.
         SELECT SINGLE fehgr FROM tvap INTO lv_fehgr
                 WHERE pstyv =  lwa_vbap_tmp-pstyv.
         IF sy-subrc = 0.
* End of Change for Defect 8291 by U033876
           READ TABLE xvbup TRANSPORTING NO FIELDS
                                    WITH KEY vbeln = xvbak-vbeln
                                             posnr = lwa_vbap_tmp-posnr
                                             lfsta = lc_c.
* Trigger if it is 'A' or "B"
           IF sy-subrc NE 0.
* End of Change for Defect 8291 by U033876
* Only put the entry if there is no entry lredy existing.
             CLEAR: lwa_vbuv_tmp.
             li_xvbuv[] = xvbuv[].
             SORT li_xvbuv BY vbeln posnr tbnam fdnam.
             READ TABLE li_xvbuv INTO lwa_vbuv_tmp
                                   WITH KEY vbeln = xvbak-vbeln
                                            posnr = lwa_vbap_tmp-posnr
                                            tbnam = lc_vbap
                                            fdnam = lc_cepok BINARY SEARCH.
             IF sy-subrc NE 0.

               CLEAR: lwa_vbuv_tmp.
               lwa_vbuv_tmp-mandt = sy-mandt.
               lwa_vbuv_tmp-vbeln = xvbak-vbeln.
               lwa_vbuv_tmp-posnr = lwa_vbap_tmp-posnr.
               lwa_vbuv_tmp-tbnam = lc_vbap.
               lwa_vbuv_tmp-fdnam = lc_cepok.
* Begin of Change for Defect 8291 by U033876
*                 lwa_vbuv_tmp-fehgr = lc_fehgr_z2.
               lwa_vbuv_tmp-fehgr = lv_fehgr.
* End of Change for Defect 8291 by U033876
               lwa_vbuv_tmp-statg = lc_statg_06.
               lwa_vbuv_tmp-fcode = lc_fcode_pkon.
               lwa_vbuv_tmp-sortf = lc_sortf_9999.
               APPEND lwa_vbuv_tmp TO xvbuv.
               CLEAR:lwa_vbuv_tmp.
             ENDIF. " IF sy-subrc NE 0
* Begin of Change for Defect 8291 by U033876
           ENDIF. " IF sy-subrc NE 0
         ENDIF. " IF sy-subrc = 0
       ENDIF. " IF sy-subrc = 0
* End of Change for Defect 8291 by U033876
     ENDLOOP. " LOOP AT xvbap INTO lwa_vbap_tmp WHERE cepok = lc_b
   ELSE. " ELSE -> IF sy-subrc = 0
* Check to see if there is an entry in Xvbuv, if yes just delete it
     LOOP AT xvbap INTO lwa_vbap_tmp  WHERE cepok NE lc_b.
       LOOP AT  xvbuv INTO  lwa_vbuv_tmp
                        WHERE   vbeln = xvbak-vbeln
                        AND     posnr = lwa_vbap_tmp-posnr
                        AND     tbnam = lc_vbap
                        AND     fdnam = lc_cepok
* Begin of Change for Defect 8291 by U033876
*                          AND     fehgr = lc_fehgr_z2
*                          AND     statg = lc_statg_06
* End of Change for Defect 8291 by U033876
                        AND     fcode = lc_fcode_pkon.
         lv_tabix = sy-tabix.
         DELETE xvbuv INDEX lv_tabix.
       ENDLOOP. " LOOP AT xvbuv INTO lwa_vbuv_tmp
     ENDLOOP. " LOOP AT xvbap INTO lwa_vbap_tmp WHERE cepok NE lc_b
   ENDIF. " IF sy-subrc = 0

* End of change for defect 7788 and 8006 by U033876

 ENDIF. " IF sy-subrc = 0
