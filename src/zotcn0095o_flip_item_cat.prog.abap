*&---------------------------------------------------------------------*
*&  Include           ZOTCN0095O_FLIP_ITEM_CAT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0095O_FLIP_ITEM_CAT                               *
* TITLE      :  Item category flipping functionality for FOC scenario  *
*               in case of BOM and dropship items.                     *
* DEVELOPER  :  Amlan Mohapatra                                        *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    Defect#1718(D2_OTC_IDD_0095)                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  Item category flipping functionality for FOC scenario  *
*               in case of BOM and dropship items.                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-May-2016 AMOHAPA  E2DK917879 Defect#1718: Item category flipping  *
*                                 functionality for FOC scenario in    *
*                                 case of BOM and dropship items.      *
* 15-Dec-2016 SMUKHER E2DK919873 Defect # 2189 : Repricing removed for *
*                                dropship                              *
*&---------------------------------------------------------------------*

TYPES:  BEGIN OF lty_tvep ,
          ettyp TYPE ettyp, " Schedule line category
          pstyp TYPE pstyp, " Item Category in Purchasing Document
        END OF lty_tvep.

DATA:  lt_tvep  TYPE STANDARD TABLE OF lty_tvep INITIAL SIZE 0,
       lv_tabix TYPE sy-tabix. " Index of Internal Tables

FIELD-SYMBOLS:
               <lfs_vbap3> TYPE vbapvb,   " Document Structure for XVBAP/YVBAP
               <lfs_vbap4> TYPE vbapvb,   " Document Structure for XVBAP/YVBAP
               <lfs_vbep>  TYPE vbepvb,   " Document Structure for XVBEP/YVBEP
               <lfs_tvep>  TYPE lty_tvep. " Document Structure for TVEP

CONSTANTS: lc_pstyp_5 TYPE pstyp VALUE '5'. " Item Category in Purchasing Document

*---> Begin of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER
* Flag is Set based on these custom fields which denotes the fact that
* this is not a manual run and is triggered by a Interface.
DATA:  lv_thrd_prty TYPE flag. " General Flag

IF xvbak-zzdocref IS NOT INITIAL
AND xvbak-zzdoctyp IS NOT INITIAL.
  lv_thrd_prty = abap_true.
ENDIF. " IF xvbak-zzdocref IS NOT INITIAL

IF vbak-zzdocref IS NOT INITIAL
AND vbak-zzdoctyp IS NOT INITIAL.
  lv_thrd_prty = abap_true.
ENDIF. " IF xvbak-zzdocref IS NOT INITIAL

IF lv_thrd_prty = abap_true
OR call_activity = gc_activity_lord.
*<--- End of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER

* Get the Schedule line category from TVEP table
  SELECT ettyp     " Schedule line category
         pstyp     " Item Category in Purchasing Document
         FROM tvep " Sales Document: Schedule Line Categories
         INTO TABLE lt_tvep
         FOR ALL ENTRIES IN xvbep
         WHERE ettyp = xvbep-ettyp .
  IF sy-subrc = 0.
    SORT lt_tvep BY ettyp.
  ENDIF. " IF sy-subrc = 0

  UNASSIGN: <lfs_vbap3>.
*Loop at all the order items matching the Schedule line category
*   to check the dropship items
  LOOP AT xvbap ASSIGNING <lfs_vbap3> WHERE updkz NE 'D'.
    lv_tabix = sy-tabix.
    IF <lfs_vbap3>-updkz IS NOT INITIAL.
      UNASSIGN: <lfs_vbep>, <lfs_tvep>, <lfs_vbap4>.
*  No sort or binary search is required for XVEP table as it is retrived in runtime
      READ TABLE xvbep ASSIGNING <lfs_vbep>
                       WITH KEY posnr = <lfs_vbap3>-posnr.
      IF sy-subrc = 0.
        READ TABLE lt_tvep ASSIGNING <lfs_tvep>
                            WITH KEY ettyp = <lfs_vbep>-ettyp
                            BINARY SEARCH.
        IF sy-subrc = 0.
* If it is a dropship item then flip the item category
          IF <lfs_tvep>-pstyp = lc_pstyp_5. " check for Dropship items

            svbap-tabix = lv_tabix.
*---> Begin of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER
              MOVE-CORRESPONDING <lfs_vbap3> TO *vbap.
              MOVE-CORRESPONDING <lfs_vbap3> TO vbap.
              MOVE-CORRESPONDING <lfs_vbap3> TO vbapd.
*<--- End of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER
            PERFORM maapv_select(sapfv45p) USING vbap-matnr
                                      vbak-vkorg
                                      vbak-vtweg
                                      space
                                      sy-subrc.
*---> Begin of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER
*       Flip the item category
*            IF <lfs_vbap3>-posnr = vbap-posnr.   "
*<--- End of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER

              vbap_ende_bearbeitung    = charx.
              vbap_ende_verfuegbarkeit = charx.
              PERFORM vbap_bearbeiten_ende(sapfv45p).
*            ENDIF. " IF <lfs_vbap3>-posnr = vbap-posnr "
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF <lfs_vbap3>-updkz IS NOT INITIAL

      IF  <lfs_vbap3>-uepos IS NOT INITIAL.

        READ TABLE xvbap ASSIGNING <lfs_vbap4>
                 WITH KEY posnr = <lfs_vbap3>-uepos.
        IF sy-subrc = 0.
*      update the main material for BOM
          <lfs_vbap3>-zzmat = <lfs_vbap4>-matnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF <lfs_vbap3>-uepos IS NOT INITIAL
    ENDIF. " LOOP AT xvbap ASSIGNING <lfs_vbap3> WHERE updkz NE 'D'
    CLEAR lv_tabix.
  ENDLOOP. " IF lv_thrd_prty = abap_true
*---> Begin of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER
ENDIF. "
*<--- End of insert for D2_OTC_IDD_0095 Defect # 2189 by SMUKHER
