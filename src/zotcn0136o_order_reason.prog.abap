*&---------------------------------------------------------------------*
*&  Include           ZOTCN0136O_ORDER_REASON
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0136O_ORDER_REASON                                 *
*Title      : Update order reason based on order type.                *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0136                                *
*---------------------------------------------------------------------*
*Description: Populate the order reason based on sales order type     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date         User ID     Transport      Description
*===========  ==========  ============== =============================*
*18-OCT-2016  APAUL       E1DK919119     Initial Development          *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*



* Constant declaration
CONSTANTS : lc_h TYPE char1 VALUE 'H',                                      " H of type CHAR1
            lc_v TYPE char1 VALUE 'V',                                      " V of type CHAR1
*            lc_zfield2      TYPE char14        VALUE 'VBAP-KOSTL',          " Zfield2 of type CHAR14
*            lc_zfield3      TYPE char14        VALUE 'VBAP-ZKOSTL' ,        " Zfield3 of type CHAR14
            lc_auart_zicm_n   TYPE z_criteria    VALUE 'AUART_ZICM',          " Enh. Criteria
            lc_auart_zidm_n   TYPE z_criteria    VALUE 'AUART_ZIDM',          " Enh. Criteria
            lc_edd_0136_n     TYPE z_enhancement VALUE 'D2_OTC_EDD_0136',     " Enhancement
            lc_augru_c21    TYPE z_criteria    VALUE 'AUGRU_C21'          , " Enh. Criteria
            lc_augru_d21    TYPE z_criteria    VALUE 'AUGRU_D21'.           " Enh. Criteria

* Enhancement table
DATA: li_emi TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

* Field symbol
FIELD-SYMBOLS: <lfs_emi> TYPE zdev_enh_status. " Enhancement Status


*  CLEAR li_emi.
*
*
*  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*    EXPORTING
*      iv_enhancement_no = lc_edd_0136_n
*    TABLES
*      tt_enh_status     = li_emi. "Enhancement status table
*
*
*  IF li_emi IS NOT INITIAL.
*
**    ASSIGN (lc_vbak) TO <lfs_vbak>.
**
**    IF <lfs_vbak> IS   ASSIGNED .
*
*
**  Did not use Binary search as internal table is too small
** Check EMI activated or not
*      READ TABLE  li_emi
*                  WITH KEY criteria =  lc_null
*                           active   = abap_true
*                           TRANSPORTING NO FIELDS.
*      IF sy-subrc EQ 0.
*
** Check for Sales order create or change
*        IF    t180-trtyp EQ lc_create
*          OR  t180-trtyp EQ lc_change .
*
**  Did not use Binary search as internal table is too small
** Check for order type ZICM
*          READ TABLE li_emi
*                    ASSIGNING <lfs_emi>
*                    WITH KEY criteria = lc_auart_zicm_n
*                     sel_low  = vbak-auart   "<lfs_vbak>-auart
*                     active   = abap_true .
*          IF sy-subrc NE  0 .
**  Did not use Binary search as internal table is too small
** Check order type ZIDM enable in EMI
*            READ TABLE li_emi
*                       ASSIGNING <lfs_emi>
*                       WITH KEY criteria = lc_auart_zidm_n
*                                sel_low  = vbak-auart "<lfs_vbak>-auart
*                                active   = abap_true.
*            IF sy-subrc EQ  0 .
**  Did not use Binary search as internal table is too small
*              READ TABLE li_emi
*                         ASSIGNING <lfs_emi>
*                         WITH KEY criteria = lc_augru_d21
*                                  active   = abap_true .
*              IF sy-subrc EQ  0 .
** Populate order reason  D21
*                vbak-augru = <lfs_emi>-sel_low .
*              ENDIF. " IF sy-subrc EQ 0
*            ENDIF. " IF sy-subrc EQ 0
*          ELSE. " ELSE -> IF sy-subrc NE 0
**  Did not use Binary search as internal table is too small
*            READ TABLE li_emi
*                       ASSIGNING <lfs_emi>
*                       WITH KEY criteria = lc_augru_c21
*                                active   = abap_true.
*            IF sy-subrc EQ  0 .
** Populate order reason  C21
*              vbak-augru = <lfs_emi>-sel_low .
*            ENDIF. " IF sy-subrc EQ 0
*          ENDIF. " IF sy-subrc NE 0
*        ENDIF. " IF t180-trtyp EQ lc_create
*      ENDIF. " IF sy-subrc EQ 0
**    ENDIF. " IF <lfs_vbak> IS ASSIGNED
*  ENDIF. " IF li_emi IS NOT INITIAL
