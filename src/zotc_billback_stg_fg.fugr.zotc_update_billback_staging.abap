FUNCTION zotc_update_billback_staging.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_VBAK) TYPE  VBAK
*"     VALUE(IM_VBAP) TYPE  VA_VBAPVB_T
*"     VALUE(IM_VBPA) TYPE  VA_VBPAVB_T
*"     VALUE(IM_VBKD) TYPE  VA_VBKDVB_T
*"     VALUE(IM_KOMV) TYPE  KOMV_TAB
*"----------------------------------------------------------------------

************************************************************************
* PROGRAM    :  ZIM_UPDATE_BILLBACK_STAGING (Enhancement)              *
* TITLE      :  Populate Billback staging table with Sales data        *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  FUNCTION MODULE                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate Billback staging table with EDI 867 data       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

* Internal table declaration
  DATA:
    i_billbk_stg        TYPE STANDARD TABLE OF zotc_billbk_stg. "  Billback Processing Staging Table

* Work area declaration
  DATA:
    wa_billbk_stg       TYPE  zotc_billbk_stg. " Billback Staging

* Field symbol declaration
  FIELD-SYMBOLS:
    <lfs_vbap>          TYPE vbapvb, " Sales doc item data
    <lfs_vbpa>          TYPE vbpavb, " Sales doc partner data
    <lfs_vbkd>          TYPE vbkdvb, " Sales doc business data
    <lfs_komv>          TYPE komv.   " Condition values

* Sales order number in VBAP import table
  LOOP AT im_vbap ASSIGNING <lfs_vbap>.
    <lfs_vbap>-vbeln = im_vbak-vbeln.
  ENDLOOP. " LOOP AT im_vbap ASSIGNING <lfs_vbap>

* Sales order number in VBPA import table
  LOOP AT im_vbpa ASSIGNING <lfs_vbpa>.
    <lfs_vbpa>-vbeln = im_vbak-vbeln.
  ENDLOOP. " LOOP AT im_vbpa ASSIGNING <lfs_vbpa>

* Sales order number in VBKD import table
  LOOP AT im_vbkd ASSIGNING <lfs_vbkd>.
    <lfs_vbkd>-vbeln = im_vbak-vbeln.
  ENDLOOP. " LOOP AT im_vbkd ASSIGNING <lfs_vbkd>

  LOOP AT im_vbap ASSIGNING <lfs_vbap>.
    wa_billbk_stg-vbeln_s          = im_vbak-vbeln.
    wa_billbk_stg-posnr_s          = <lfs_vbap>-posnr.
    wa_billbk_stg-vkorg            = im_vbak-vkorg.
    wa_billbk_stg-vtweg            = im_vbak-vtweg.
    wa_billbk_stg-auart            = im_vbak-auart.
*    wa_billbk_stg-zzdistr_code     = im_vbak-.  "Cardinal ? required? control table?
    wa_billbk_stg-matnr            = <lfs_vbap>-matnr.
    wa_billbk_stg-zmeng           = <lfs_vbap>-zmeng.
    wa_billbk_stg-zieme            = <lfs_vbap>-zieme.
    wa_billbk_stg-netwr            = <lfs_vbap>-netwr.
    wa_billbk_stg-waerk            = <lfs_vbap>-waerk.
    wa_billbk_stg-faksp            = <lfs_vbap>-faksp.
    wa_billbk_stg-erdat            = im_vbak-erdat.
    wa_billbk_stg-erzet            = im_vbak-erzet.
    wa_billbk_stg-ernam            = im_vbak-ernam.

*   Read Sales document business data
    READ TABLE im_vbkd ASSIGNING <lfs_vbkd> WITH KEY
                                                  vbeln = im_vbak-vbeln
                                                  posnr = <lfs_vbap>-posnr.
    IF sy-subrc = 0.
      wa_billbk_stg-bstkd            = <lfs_vbkd>-bstkd.
      wa_billbk_stg-bstdk            = <lfs_vbkd>-bstdk.
      wa_billbk_stg-fkdat            = <lfs_vbkd>-fkdat.
      wa_billbk_stg-bstkd_e          = <lfs_vbkd>-bstkd_e.
      wa_billbk_stg-bstdk_e          = <lfs_vbkd>-bstdk_e.
    ENDIF. " IF sy-subrc = 0

    IF wa_billbk_stg-fkdat IS INITIAL.
      UNASSIGN <lfs_vbkd>.
      READ TABLE im_vbkd ASSIGNING <lfs_vbkd> WITH KEY
                                                    vbeln = im_vbak-vbeln.
*                                                  posnr = <lfs_vbap>-posnr.
      IF sy-subrc = 0.
        wa_billbk_stg-fkdat            = <lfs_vbkd>-fkdat.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF wa_billbk_stg-fkdat IS INITIAL

*   Read Sales document partner data - Sold-to
    READ TABLE im_vbpa ASSIGNING <lfs_vbpa> WITH KEY
                                                  vbeln = im_vbak-vbeln
*                                                  posnr = <lfs_vbap>-posnr
                                                  parvw  = 'AG'. " conversion?
    IF sy-subrc = 0.
      wa_billbk_stg-kunag            = <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc = 0

*   Read Sales document partner data - Ship-to
    READ TABLE im_vbpa ASSIGNING <lfs_vbpa> WITH KEY
                                                  vbeln = im_vbak-vbeln
*                                                  posnr = <lfs_vbap>-posnr
                                                  parvw  = 'WE'. " conversion?
    IF sy-subrc = 0.
      wa_billbk_stg-kunwe            = <lfs_vbpa>-kunnr.
    ENDIF. " IF sy-subrc = 0

*   Claim value
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZDBS'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzclaim_val      = <lfs_komv>-kwert.
    ENDIF. " IF sy-subrc = 0

*   Cardinal End user price
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZCEN'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzcen_price      = <lfs_komv>-kbetr.
    ENDIF. " IF sy-subrc = 0

*   Acquisition Unit price
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZCAS'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzacq_price      = <lfs_komv>-kbetr.
    ENDIF. " IF sy-subrc = 0

*   Margin value
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZCMC'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzmar_val         = <lfs_komv>-kwert.
    ENDIF. " IF sy-subrc = 0

*   Contract price
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZC00'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzcont_price       = <lfs_komv>-kbetr.
    ENDIF. " IF sy-subrc = 0

*   Commission
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZCRT'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzcom_val         = <lfs_komv>-kwert.
    ENDIF. " IF sy-subrc = 0

*   Rebates - Old / New indicator
    READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZNEW'.
    IF sy-subrc = 0.
      wa_billbk_stg-zzold_new_ind      = 'N'.
      wa_billbk_stg-zzreb_val          = <lfs_komv>-kwert.
    ELSE. " ELSE -> IF sy-subrc = 0
      READ TABLE im_komv ASSIGNING <lfs_komv> WITH KEY
                                                   kposn = <lfs_vbap>-posnr
                                                   kschl = 'ZOLD'.
      IF sy-subrc = 0.
        wa_billbk_stg-zzold_new_ind      = 'O'.
        wa_billbk_stg-zzreb_val          = <lfs_komv>-kwert.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

    IF NOT wa_billbk_stg-zzcont_price IS INITIAL AND
       NOT wa_billbk_stg-zzcen_price IS INITIAL.
      wa_billbk_stg-zzprc_diff1          = wa_billbk_stg-zzcont_price - wa_billbk_stg-zzcen_price.
    ENDIF. " IF NOT wa_billbk_stg-zzcont_price IS INITIAL AND

    IF NOT wa_billbk_stg-zzcom_val IS INITIAL AND
       NOT wa_billbk_stg-zzreb_val IS INITIAL.
      wa_billbk_stg-zzprc_diff2          = wa_billbk_stg-zzreb_val - wa_billbk_stg-zzmar_val.
    ENDIF. " IF NOT wa_billbk_stg-zzcom_val IS INITIAL AND

**** Following fields in ZOTC_BILLBK_STG table will get populated after the look-up from ZOTC-BILLBACK
*ZZSET_QTY    ?? required in this table - already part of ZOTC_billback
*ZZBAL_QTY    ?? required in this table - already part of ZOTC_billback
*ZZDUP_CLM_IND & ZZFULLY_PROC  will be updated from cockpit

    wa_billbk_stg-mandt = sy-mandt.
    APPEND wa_billbk_stg TO i_billbk_stg.
    CLEAR  wa_billbk_stg.

  ENDLOOP. " LOOP AT im_vbap ASSIGNING <lfs_vbap>

* Insert into database table from internal table
***?? check if this exception is catchable as insert happens in anothe internal session
  IF i_billbk_stg[] IS NOT INITIAL.
    TRY.
*        INSERT zotc_billbk_stg FROM TABLE i_billbk_stg.
        MODIFY zotc_billbk_stg FROM TABLE i_billbk_stg.
      CATCH cx_sy_open_sql_db.
    ENDTRY.
  ENDIF. " IF i_billbk_stg[] IS NOT INITIAL

ENDFUNCTION.
