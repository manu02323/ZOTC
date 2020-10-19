*&---------------------------------------------------------------------*
*&  Include           ZOTCN0235O_COMPLETE_SHIP
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0235O_COMPLETE_SHIP                                *
*Title      : Ship Complete enhancement.                              *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0235                                           *
*---------------------------------------------------------------------*
*Description: Ship Complete enhancement to change route and delivery  *
*group and retrigger the ATP.                                         *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*18-Feb-2015  DMOIRAN        E2DK900492     Initial development.
*---------------------------------------------------------------------*
* 10-Mar-2015 DMOIRAN        E2DK900492  Def 4666:When delivery date  *
* is removed manually it is not updating later.                       *
*---------------------------------------------------------------------*
* 17-Mar-2015 DMOIRAN        E2DK900492  Defect 4953. When new line   *
* items are added and plant change the delivery group and route are   *
* not calculated.                                                     *
* 05-Dec-2016 OBULANO/DMOIRAN E1DK924239  D3 Defect 6763. When Ship   *
* Complete flag is applied and users are clearing Deliver group fields*
* an Abend message is generated.                                      *
*---------------------------------------------------------------------*
* 10-Jan-2016 U029382        E1DK924239 D3Def 6763Part2:Delivery Group*
*                                       on partial confirmation line  *
* 17-Jan-2016 U029382        E1DK924239 D3Def 6763Part3:If Reason for *
*                                       Rejection is applied, Remove  *
*                                       Delivery group                *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* 30-Jul-2018 ASK            E1DK938065 D3Def 6771 : When Item is not
*                                       updated then XVBP-UPDKZ should *
*                                       not be updated and if XVBAP is *
*                                       updated then also update YVBAP *
*07-DEC-2018 U033632        E1DK939612  Defect#7511/SCTASK0767223:     *
*                                       The system should allow to     *
*                                       remove/change delivery block at*
*                                       line level if there is a line  *
*                                       item which is not confirmed    *
*                                       when ship complete is flagged. *
*----------------------------------------------------------------------*

TYPES:
      BEGIN OF lty_route,
        werks TYPE werks_ext,                                 " Plant (Own or External)
        route TYPE route,                                     " Route
        grkor TYPE grkor,                                     " Delivery group (items are delivered together)
      END OF lty_route,
      lty_t_route TYPE STANDARD TABLE OF lty_route,           "table type for route

      BEGIN OF lty_vbep_partial,
        vbeln TYPE vbeln_va,                                  " Sales Document
        posnr TYPE posnr_va,                                  " Sales Document Item
        wmeng TYPE wmeng,                                     " Order quantity in sales units
        bmeng TYPE bmeng,                                     " Confirmed Quantity
     END OF lty_vbep_partial,
     lty_t_vbep_partial TYPE HASHED TABLE OF lty_vbep_partial "table type for schedule line
                      WITH UNIQUE KEY vbeln posnr.

DATA: lv_index_sc         TYPE sytabix,     " Index of Internal Tables
      lv_exit             TYPE flag,        " General Flag
* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
      lv_update           TYPE flag,
      lwa_vbap            TYPE vbapvb,
*< --- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
      lv_prev_prior       TYPE zpriorcount, " Priority Counter
      lv_grkor            TYPE grkor,       " Delivery group (items are delivered together)
      lv_delv_block       TYPE lifsp_ep,    " Schedule line blocked for delivery
      lv_atp_trigger      TYPE flag.        " ATP trigger flags

DATA: lwa_vbep_partial    TYPE lty_vbep_partial. "Work area for schedule line

DATA: li_xvbap_plant      TYPE STANDARD TABLE OF vbapvb,          " Document Structure for XVBAP/YVBAP
      li_xvbap_mod        TYPE STANDARD TABLE OF vbapvb,          " Document Structure for XVBAP/YVBAP
      li_xvbep            TYPE STANDARD TABLE OF vbepvb,          " Structure of Document for XVBEP/YVBEP
      li_route            TYPE lty_t_route,                       " Route for each plant
      li_vbep_partial     TYPE lty_t_vbep_partial,                " Schedule line data
      lwa_gvbap           LIKE LINE OF gvbap,                     " Delivery Group Data
      li_edd_0235_status  TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status



CONSTANTS: lc_create_h    TYPE trtyp            VALUE 'H',               " Transaction type
           lc_change_v    TYPE trtyp            VALUE 'V',               " Transaction type
           lc_grkor_90    TYPE grkor            VALUE '090',             " Delivery group (items are delivered together)
           lc_edd_0235    TYPE z_enhancement    VALUE 'D2_OTC_EDD_0235', " Enhancement
           lc_null_0235   TYPE z_criteria       VALUE 'NULL',            " Enh. Criteria
           lc_lifsp       TYPE z_criteria       VALUE 'LIFSP',           " Enh. Criteria
           lc_del_d       TYPE updkz_d          VALUE 'D',               " Update indicator
           lc_upd_u       TYPE updkz_d          VALUE 'U',               " Update indicator
           lc_upd_i       TYPE updkz_d          VALUE 'I',               " Update indicator
           lc_save_sich   TYPE syucomm          VALUE 'SICH'.            " Function code that PAI triggered


FIELD-SYMBOLS:
      <lfs_xvbap_sc_plant>   TYPE vbapvb,           " Document Structure for XVBAP/YVBAP
      <lfs_xvbap_sc_mod>     TYPE vbapvb,           " Document Structure for XVBAP/YVBAP
      <lfs_xvbep_sc>         TYPE vbepvb,           " Structure of Document for XVBEP/YVBEP
      <lfs_tragr_pref>       TYPE ty_tragr_pref,    "Transportation group peference
      <lfs_route>            TYPE lty_route,        "route
      <lfs_vbep_partial>     TYPE lty_vbep_partial, "Schedule
      <lfs_status_sc>        TYPE zdev_enh_status.  " Enhancement Status
* ---> Begin of Insert for D3_OTC_EDD_0235 Defect# 7511/SCTASK0767223 by U033632
FIELD-SYMBOLS: <lfs_yvbep> TYPE vbepvb. " Structure of Document for XVBEP/YVBEP
* ---> End of Insert for D3_OTC_EDD_0235 Defect# 7511/SCTASK0767223 by U033632

* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_edd_0235
  TABLES
    tt_enh_status     = li_edd_0235_status. "Enhancement status table

*Non active entries are removed.
DELETE li_edd_0235_status WHERE active EQ abap_false.

READ TABLE li_edd_0235_status WITH KEY criteria = lc_null_0235 TRANSPORTING NO FIELDS. "NULL.
IF sy-subrc = 0.

  READ TABLE li_edd_0235_status ASSIGNING <lfs_status_sc> WITH KEY criteria = lc_lifsp.
  IF sy-subrc = 0.
    lv_delv_block = <lfs_status_sc>-sel_low.
  ENDIF. " IF sy-subrc = 0


* valid for Create and change only
  IF t180-trtyp = lc_create_h OR t180-trtyp = lc_change_v.

* check if Complete shipment is set.
    IF vbak-zzshipcomp IS NOT INITIAL.
      li_xvbep[] = xvbep[].
* get only the item relevant for delivery.
      DELETE li_xvbep WHERE lfrel = space
                        OR updkz = lc_del_d.

      SORT li_xvbep BY posnr.
* check for partial confirmation, if so then put delivery block for that line item
      LOOP AT li_xvbep ASSIGNING <lfs_xvbep_sc>.
        CLEAR lwa_vbep_partial.
        lwa_vbep_partial-vbeln = <lfs_xvbep_sc>-vbeln.
        lwa_vbep_partial-posnr = <lfs_xvbep_sc>-posnr.
        lwa_vbep_partial-wmeng  = <lfs_xvbep_sc>-wmeng.
        lwa_vbep_partial-bmeng  = <lfs_xvbep_sc>-bmeng.
        COLLECT lwa_vbep_partial INTO li_vbep_partial.
      ENDLOOP. " LOOP AT li_xvbep ASSIGNING <lfs_xvbep_sc>

      DELETE ADJACENT DUPLICATES FROM li_xvbep COMPARING posnr.
* Proceed only when there are item relevent for delivery
      IF li_xvbep[] IS NOT INITIAL.
        lv_grkor = lc_grkor_90.

* This user exit is called for each sales order line item, so to avoid
* multiple select on DB, a global internal table is used.
* get the transportation group peference
        IF i_tragr_pref IS INITIAL.
          SELECT vkorg              " Sales Organization
                 vkorg              " Sales Organization
                 zpriorcount        " Priority Counter
                 zztragr            " Transportation Group
               FROM zotc_tragr_pref " Transportation Group preference table
               INTO TABLE i_tragr_pref
               WHERE vkorg = vbak-vkorg
                AND vtweg = vbak-vtweg.
          IF sy-subrc = 0.
            SORT i_tragr_pref BY zztragr.
          ELSE. " ELSE -> IF sy-subrc = 0
            CLEAR vbak-zzshipcomp.
            MESSAGE i171(zotc_msg). " No record found in Transportation preference table ZOTC_TRAGR_PREF.
          ENDIF. " IF sy-subrc = 0

        ENDIF. " IF i_tragr_pref IS INITIAL

        IF i_tragr_pref IS NOT INITIAL.
          li_xvbap_mod[] = xvbap[].
          DELETE li_xvbap_mod WHERE abgru IS NOT INITIAL.
          DELETE li_xvbap_mod WHERE uepos IS NOT INITIAL.

          IF li_xvbap_mod IS INITIAL.
            CLEAR vbak-zzshipcomp.
            MESSAGE i173(zotc_msg). " No item relevant for Ship Complete.
          ELSE. " ELSE -> IF li_xvbap_mod IS INITIAL

            CLEAR: lv_index_sc.
            DESCRIBE TABLE li_xvbap_mod LINES lv_index_sc.
            IF lv_index_sc EQ 1.
              CLEAR vbak-zzshipcomp.
              MESSAGE i174(zotc_msg). " Only 1 item relevant for ship Complete.
            ELSE. " ELSE -> IF lv_index_sc EQ 1


              SORT li_xvbap_mod BY werks.

*Get unique plant in line items
              li_xvbap_plant[] = xvbap[].
              SORT li_xvbap_plant BY werks.
              DELETE ADJACENT DUPLICATES FROM li_xvbap_plant COMPARING werks.

* check for each plant if the route needs to be flip or not. This
* is based on priority on transportation group peference
              LOOP AT li_xvbap_plant ASSIGNING <lfs_xvbap_sc_plant>.
                READ TABLE li_xvbap_mod WITH KEY werks = <lfs_xvbap_sc_plant>-werks
                                       TRANSPORTING NO FIELDS.
                IF sy-subrc = 0.
                  CLEAR: lv_index_sc.
                  lv_index_sc = sy-tabix.
                  APPEND INITIAL LINE TO li_route ASSIGNING <lfs_route>.
                  IF <lfs_route> IS ASSIGNED.
                    <lfs_route>-werks = <lfs_xvbap_sc_plant>-werks.
                    <lfs_route>-grkor = lv_grkor.
                    lv_grkor = lv_grkor + 1.
                  ENDIF. " IF <lfs_route> IS ASSIGNED

                  CLEAR: lv_prev_prior.
                  lv_exit = abap_true.
* Use parallel cursor and for the current plant find the highest transportation group.
* Capture the route of that line item and store the delivery group counter.

                  LOOP AT li_xvbap_mod ASSIGNING <lfs_xvbap_sc_mod> FROM lv_index_sc.
                    IF <lfs_xvbap_sc_mod>-werks NE <lfs_xvbap_sc_plant>-werks.
                      EXIT.
                    ENDIF. " IF <lfs_xvbap_sc_mod>-werks NE <lfs_xvbap_sc_plant>-werks

                    READ TABLE i_tragr_pref ASSIGNING <lfs_tragr_pref>
                                                WITH KEY zztragr = <lfs_xvbap_sc_mod>-zztragr
                                                BINARY SEARCH.
                    IF sy-subrc = 0.
                      CLEAR lv_exit.
* Lesser the priority number higher the priority of transportation group.
* Get pefer route for each plant
                      IF lv_prev_prior IS INITIAL.
                        lv_prev_prior = <lfs_tragr_pref>-zpriorcount.
                        <lfs_route>-route = <lfs_xvbap_sc_mod>-route.
                      ELSE. " ELSE -> IF lv_prev_prior IS INITIAL

                        IF <lfs_tragr_pref>-zpriorcount LT lv_prev_prior.
                          lv_prev_prior = <lfs_tragr_pref>-zpriorcount.
                          <lfs_route>-route = <lfs_xvbap_sc_mod>-route.

                        ENDIF. " IF <lfs_tragr_pref>-zpriorcount LT lv_prev_prior
                      ENDIF. " IF lv_prev_prior IS INITIAL

                    ENDIF. " IF sy-subrc = 0

                  ENDLOOP. " LOOP AT li_xvbap_mod ASSIGNING <lfs_xvbap_sc_mod> FROM lv_index_sc
                ENDIF. " IF sy-subrc = 0
* If no priority was found for the plant then exit.
                IF lv_exit = abap_true.
                  CLEAR vbak-zzshipcomp.
                  MESSAGE i172(zotc_msg) " No transportation preference found for items in plant &.
                  WITH <lfs_xvbap_sc_plant>-werks.
* exit from the loop
                  EXIT.
                ENDIF. " IF lv_exit = abap_true

              ENDLOOP. " LOOP AT li_xvbap_plant ASSIGNING <lfs_xvbap_sc_plant>

*  lv_exit = abap_true then no further processing

              IF lv_exit IS INITIAL.

* For partial confirmation delivery block should be set
* This user exit is called multiple times and so for each scheduline line decide to remove
* or set the delivery block.
                LOOP AT li_vbep_partial ASSIGNING <lfs_vbep_partial>.
* Parallel cursor not used as XVBEP can't be sorted
                  LOOP AT xvbep ASSIGNING <lfs_xvbep_sc> WHERE vbeln = <lfs_vbep_partial>-vbeln
                                                           AND posnr = <lfs_vbep_partial>-posnr.
* check line is not marked for delete
                    IF <lfs_xvbep_sc>-updkz NE lc_del_d.

                      IF <lfs_vbep_partial>-wmeng NE <lfs_vbep_partial>-bmeng.
* set delivery block
* ---> Begin of Insert for D3_OTC_EDD_0235 Defect# 7511/SCTASK0767223 by U033632
*Get the data of line item selected by user
                        READ TABLE yvbep ASSIGNING <lfs_yvbep> WITH KEY vbeln = <lfs_xvbep_sc>-vbeln
                                                                        posnr =  <lfs_xvbep_sc>-posnr
                                                                        etenr =  <lfs_xvbep_sc>-etenr.
                        IF sy-subrc EQ 0.
*If the delivery block is changed
                          IF  <lfs_xvbep_sc>-lifsp NE <lfs_yvbep>-lifsp.
**If delivery block changed then assign new value
                            <lfs_yvbep>-lifsp = <lfs_xvbep_sc>-lifsp.

                          ENDIF. " IF <lfs_xvbep_sc>-lifsp = <lfs_yvbep>-lifsp
                        ELSE. " ELSE -> if sy-subrc EQ 0
* ---> End of Insert for D3_OTC_EDD_0235 Defect# 7511/SCTASK0767223 by U033632
                        <lfs_xvbep_sc>-lifsp = lv_delv_block.
* ---> Begin of Insert for D3_OTC_EDD_0235 Defect# 7511/SCTASK0767223 by U033632

                        ENDIF. " if sy-subrc EQ 0
* ---> End of Insert for D3_OTC_EDD_0235 Defect# 7511/SCTASK0767223 by U033632
                      ELSE. " ELSE -> IF <lfs_vbep_partial>-wmeng NE <lfs_vbep_partial>-bmeng
                        CLEAR <lfs_xvbep_sc>-lifsp.
* remove delivery block
                      ENDIF. " IF <lfs_vbep_partial>-wmeng NE <lfs_vbep_partial>-bmeng
                    ENDIF. " IF <lfs_xvbep_sc>-updkz NE lc_del_d
                  ENDLOOP. " LOOP AT xvbep ASSIGNING <lfs_xvbep_sc> WHERE vbeln = <lfs_vbep_partial>-vbeln

                ENDLOOP. " LOOP AT li_vbep_partial ASSIGNING <lfs_vbep_partial>

* overwrite the delivery group and route

                LOOP AT li_route ASSIGNING <lfs_route>.
* Number of record in LI_ROUTE will be low as it will be route for each plant.
* Parallel cursor not used as XVBAP can't be sorted.
                  LOOP AT xvbap ASSIGNING <lfs_xvbap_sc_mod>
                                  WHERE werks = <lfs_route>-werks.

* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                    CLEAR lv_flag.
                    lwa_vbap = <lfs_xvbap_sc_mod>.
* <--- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK

                    IF <lfs_xvbap_sc_mod>-abgru IS INITIAL.
* Begin of change by Rajendra for Def 6763 Part2
* Delivery group to set for partial confirmation as well
*                      READ TABLE li_vbep_partial ASSIGNING <lfs_vbep_partial> WITH KEY posnr = <lfs_xvbap_sc_mod>-posnr.
*                      IF sy-subrc = 0.
*                        IF <lfs_vbep_partial>-wmeng NE <lfs_vbep_partial>-bmeng.
** skip the record as partial confirmation are set delivery block
*                          CONTINUE.
*                        ENDIF. " IF <lfs_vbep_partial>-wmeng NE <lfs_vbep_partial>-bmeng
*                      ENDIF. " IF sy-subrc = 0
* End of change by Rajendra for Def 6763 Part2
                      IF <lfs_xvbap_sc_mod>-route NE <lfs_route>-route.
                        <lfs_xvbap_sc_mod>-route = <lfs_route>-route.
* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                        lv_flag = abap_true.
* <--- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
* ---> Begin of Insert for D2_OTC_EDD_0235 Defect 4953 by DMOIRAN
* When new line item are added route in VBAP needs to be updated
                        IF <lfs_xvbap_sc_mod>-posnr = vbap-posnr.
                          vbap-route = <lfs_route>-route.
                        ENDIF. " IF <lfs_xvbap_sc_mod>-posnr = vbap-posnr
* <--- End    of Insert for D2_OTC_EDD_0235 Defect 4953 by DMOIRAN


                        lv_atp_trigger = abap_true.
                      ENDIF. " IF <lfs_xvbap_sc_mod>-route NE <lfs_route>-route
                      IF <lfs_xvbap_sc_mod>-grkor NE <lfs_route>-grkor.
                        <lfs_xvbap_sc_mod>-grkor = <lfs_route>-grkor.
* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                        lv_flag = abap_true.
* <--- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
* ---> Begin of Insert for D2_OTC_EDD_0235 Defect 4953 by DMOIRAN
                        IF <lfs_xvbap_sc_mod>-posnr = vbap-posnr.
                          vbap-grkor = <lfs_route>-grkor.
                        ENDIF. " IF <lfs_xvbap_sc_mod>-posnr = vbap-posnr
* <--- End    of Insert for D2_OTC_EDD_0235 Defect 4953 by DMOIRAN

* ---> Begin of Insert for D2_OTC_EDD_0235 Defect 4666 by DMOIRAN

* ---> Begin of Delete for D3_OTC_EDD_0235 Defect 6763 by DMOIRAN
*                        IF ( t180-trtyp = lc_change_v AND
*                           <lfs_xvbap_sc_mod>-updkz NE lc_upd_i ).
* <--- End    of Delete for D3_OTC_EDD_0235 Defect 6763 by DMOIRAN

* ---> Begin of Insert for D3_OTC_EDD_0235 Defect 6763 by DMOIRAN
* Added condition Create scenario also.
                        IF ( t180-trtyp = lc_change_v AND
                           <lfs_xvbap_sc_mod>-updkz NE lc_upd_i )
                          OR ( t180-trtyp = lc_create_h AND
                           <lfs_xvbap_sc_mod>-updkz EQ lc_upd_i ).
* <--- End    of Insert for D3_OTC_EDD_0235 Defect 6763 by DMOIRAN

*                         During Chnage mode if GVBAP entry is missing
*                         we have to add the entry
                          READ TABLE gvbap WITH KEY grkor = <lfs_route>-grkor
                                                    posnr = <lfs_xvbap_sc_mod>-posnr
                                                    TRANSPORTING NO FIELDS.
                          IF sy-subrc NE 0.
                            lwa_gvbap-grkor = <lfs_route>-grkor.
                            lwa_gvbap-posnr = <lfs_xvbap_sc_mod>-posnr.
                            lwa_gvbap-matnr = <lfs_xvbap_sc_mod>-matnr.
                            lwa_gvbap-werks = <lfs_xvbap_sc_mod>-werks.
                            APPEND lwa_gvbap TO gvbap.

                            SORT gvbap BY grkor posnr. " Defect 6763 ++ - to avoid Abend message in Form GVBAP_LOESCHEN / line 29
                          ENDIF. " IF sy-subrc NE 0
                        ENDIF. " IF ( t180-trtyp = lc_change_v AND
* <--- End    of Insert for D2_OTC_EDD_0235 Defect 4666 by DMOIRAN
                        lv_atp_trigger = abap_true.
                      ENDIF. " IF <lfs_xvbap_sc_mod>-grkor NE <lfs_route>-grkor

* in case of change mode if update flag is not set then set it.
                      IF t180-trtyp = lc_change_v AND <lfs_xvbap_sc_mod>-updkz IS INITIAL.
* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                        IF lv_flag = abap_true.
* <--- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                          <lfs_xvbap_sc_mod>-updkz = lc_upd_u.
* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
*                        Now check if YVBAP has entry or not. If not then INSERT entry
                          READ TABLE yvbap WITH KEY posnr = <lfs_xvbap_sc_mod>-posnr
                                              TRANSPORTING NO FIELDS.
                          IF sy-subrc NE 0.
                            APPEND lwa_vbap TO yvbap.
                          ENDIF. " if sy-subrc NE 0
* <--- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                        ENDIF. " IF lv_flag = abap_true
                      ENDIF. " IF t180-trtyp = lc_change_v AND <lfs_xvbap_sc_mod>-updkz IS INITIAL
                    ENDIF. " IF <lfs_xvbap_sc_mod>-abgru IS INITIAL
* Begin of change by Rajendra for Def 6763 Part3
* If Reason for Rejection is applied, Remove Delivery group
                    IF vbap-abgru IS NOT INITIAL AND vbap-grkor IS NOT INITIAL.
                      vbap-grkor = space.
                      IF t180-trtyp = lc_change_v AND <lfs_xvbap_sc_mod>-updkz IS INITIAL.
                        <lfs_xvbap_sc_mod>-updkz = lc_upd_u.
* ---> Begin of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
*                        Now check if YVBAP has entry or not. If not then INSERT entry
                          READ TABLE yvbap WITH KEY posnr = <lfs_xvbap_sc_mod>-posnr
                                              TRANSPORTING NO FIELDS.
                          IF sy-subrc NE 0.
                            APPEND lwa_vbap TO yvbap.
                          ENDIF. " if sy-subrc NE 0
* <--- End of Insert for Defect#6771:D3_OTC_EDD_0235 by ASK
                      ENDIF. " IF t180-trtyp = lc_change_v AND <lfs_xvbap_sc_mod>-updkz IS INITIAL
                    ENDIF. " IF vbap-abgru IS NOT INITIAL AND vbap-grkor IS NOT INITIAL
* End of change by Rajendra for Def 6763 Part3
                  ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_xvbap_sc_mod>
                ENDLOOP. " LOOP AT li_route ASSIGNING <lfs_route>

* retrigger the ATP
                IF lv_atp_trigger = abap_true.
                  PERFORM vbap_bearbeiten_ende_verfuegb(sapfv45p).
                ENDIF. " IF lv_atp_trigger = abap_true

              ENDIF. " IF lv_exit IS INITIAL
            ENDIF. " IF lv_index_sc EQ 1
          ENDIF. " IF li_xvbap_mod IS INITIAL
        ENDIF. " IF i_tragr_pref IS NOT INITIAL
      ELSE. " ELSE -> IF li_xvbep[] IS NOT INITIAL
        CLEAR vbak-zzshipcomp.
        MESSAGE i170(zotc_msg). " No item relevant for delivery so ship complete not done.

      ENDIF. " IF li_xvbep[] IS NOT INITIAL
    ENDIF. " IF vbak-zzshipcomp IS NOT INITIAL
  ENDIF. " IF t180-trtyp = lc_create_h OR t180-trtyp = lc_change_v
ENDIF. " IF sy-subrc = 0
