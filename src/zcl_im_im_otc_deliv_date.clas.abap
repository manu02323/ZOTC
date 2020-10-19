class ZCL_IM_IM_OTC_DELIV_DATE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_SMOD_V50B0001 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_IM_OTC_DELIV_DATE IMPLEMENTATION.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_001.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_002.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_003.
endmethod.


METHOD if_ex_smod_v50b0001~exit_saplv50i_004.
***********************************************************************
*Program    : ZCL_IM_IM_OTC_DELIV_DATE                                *
*Title      : Delivery Date Implementation                            *
*Developer  : Sneha Agrawal                                           *
*Object type: Enhancement Implementation                              *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0234                                           *
*---------------------------------------------------------------------*
*Description: The delivery date of an outbound delivery corresponds to*
*             the planned goods receipt date of the goods at the      *
*             customer. If deviations occur during the goods issue,   *
*             that is the goods are delivered earlier or later than   *
*             planned, the planned delivery date is not adjusted. It  *
*             is even possible that the actual goods issue date is    *
*             later than the delivery date. To acheive this functional*
*             -ity Implement OSS Note 552713.                         *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============= ============= =============================*
*17-Mar-2016   SAGARWA1    E2DK914842    Defect#863:Initial development
*---------------------------------------------------------------------*


  TYPES : BEGIN OF lty_likp,
            vbeln TYPE vbeln,    " Delivery
            vstel TYPE vstel,    " Shipping Point/Receiving Point
            vkorg TYPE vkorg,    " Sales Organization
            lfart TYPE lfart,    " Delivery Type
          END OF lty_likp,

          BEGIN OF lty_lips,
            vbeln TYPE vbeln_vl, " Delivery
            vtweg TYPE vtweg,    " Distribution Channel
            spart TYPE spart,    " Division
          END OF lty_lips,

          BEGIN OF lty_vbpa,
            vbeln TYPE vbeln,    " Sales and Distribution Document Number
            posnr TYPE posnr,    " Item number of the SD document
            parvw TYPE parvw,    " Partner Function
            kunnr TYPE kunnr,    " Customer Number
            adrnr TYPE adrnr,    " Address
            ablad TYPE ablad,    " Unloading Point
            adrda TYPE adrda,    " Address indicator
          END OF lty_vbpa,

          BEGIN OF lty_tvst,
            vstel TYPE vstel,    " Shipping Point/Receiving Point
            aland TYPE aland,    " Departure country (country from which the goods are sent)
          END OF lty_tvst.


  DATA : lv_goods_issue_time TYPE wauhr,                                            " Time of Goods Issue (Local, Relating to a Plant)
         lwa_vbpok           TYPE vbpok,                                            " Reference structure for XVBPOK
         lwa_tvst            TYPE lty_tvst,                                         " Organizational Unit: Shipping Points
         lwa_vbpa            TYPE lty_vbpa,                                         " Reference structure for XVBPA/YVBPA
         lwa_likp            TYPE lty_likp,                                         " Reference structure for XLIKP/YLIKP
         lwa_lips            TYPE lty_lips,                                         " Reference structure for XLIKS/YLIKS
         lwa_vtcom           TYPE vtcom,                                            " Communications Work Area for Cust.Master Accesses
         lwa_kuwev           TYPE kuwev,                                            " Ship-to Party's View of the Customer Master Record
         lv_delivery_time    TYPE lfuhr,                                            " Time of Delivery
         lv_delivery_date    TYPE lfdat_v,                                          " Date of Delivery
         lv_parvw            TYPE parvw,                                            " Partner Function
         lv_vbtyp            TYPE vbtyp,                                            " SD Document Category
         lv_flag             TYPE flag,                                             " Flag
         li_enh_status       TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status

  CONSTANTS : lc_00         TYPE wauhr   VALUE '000000',                " Initial Time
              lc_item_00    TYPE posnr   VALUE '000000',                " Item Number
              lc_enh_no     TYPE z_enhancement VALUE 'D2_OTC_EDD_0234', " Enhancement No.
              lc_delv_type  TYPE z_criteria    VALUE 'DELV_TYPE',       " Enh. Criteria
              lc_vbtyp      TYPE z_criteria    VALUE 'VBTYP',           " Enh. Criteria
              lc_parvw      TYPE z_criteria    VALUE 'PARVW',           " Enh. Criteria
              lc_u          TYPE msgkz   VALUE 'U'.                     " Processing of Messages


* Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_enh_status> TYPE zdev_enh_status. " Enhancement Status


* Call FM to retrieve Enhancement Status
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_enh_status.

* Delete the EMI records where the status is not active
  DELETE li_enh_status WHERE active = space.

  IF li_enh_status[] IS NOT INITIAL.
* Read the SD Document category.
* No need to use binary search as table is containing less entries
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_vbtyp.
    IF sy-subrc = 0.
      lv_vbtyp = <lfs_enh_status>-sel_low.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_enh_status[] IS NOT INITIAL

* Update of delivery date only if goods movement is posted
  IF cs_vbkok-wadat_ist IS NOT INITIAL.

    IF cs_vbkok-vbtyp_vl EQ lv_vbtyp AND
         cs_vbkok-wadat NE cs_vbkok-wadat_ist.

*     If actual goods-issue date is today assume that goods issue is
*     posted at the same moment
      IF cs_vbkok-wadat_ist EQ sy-datlo.
        lv_goods_issue_time = sy-timlo.
      ELSE. " ELSE -> IF cs_vbkok-wadat_ist EQ sy-datlo
        lv_goods_issue_time = lc_00.
      ENDIF. " IF cs_vbkok-wadat_ist EQ sy-datlo

****************************************************************************************
*     Read first non-deleted item for information on item level
*     (distribution channel, division, loading group)
      LOOP AT ct_vbpok INTO lwa_vbpok
                       WHERE vbeln_vl EQ cs_vbkok-vbeln_vl.

        EXIT.
      ENDLOOP. " LOOP AT ct_vbpok INTO lwa_vbpok
      IF sy-subrc NE 0.
        EXIT.
      ENDIF. " IF sy-subrc NE 0
*     Get shipping point information

      SELECT SINGLE vbeln " Delivery
                    vstel " Shipping Point/Receiving Point
                    vkorg " Sales Organization
                    lfart " Delivery Type
             INTO lwa_likp
             FROM likp WHERE vbeln = cs_vbkok-vbeln_vl.
      IF sy-subrc = 0.
        IF lwa_likp-vstel IS NOT INITIAL.
          SELECT SINGLE  vstel " Shipping Point/Receiving Point
                         aland " Departure country (country from which the goods are sent)
             FROM tvst         " Organizational Unit: Shipping Points
             INTO lwa_tvst
             WHERE vstel EQ lwa_likp-vstel.
          IF sy-subrc NE 0.
            CLEAR lwa_tvst.
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF lwa_likp-vstel IS NOT INITIAL
* Select first Item from LIPS

        SELECT  vbeln    " Delivery
                vtweg    " Distribution Channel
                spart    " Division
               UP TO 1 ROWS
               FROM lips " SD document: Delivery: Item data
               INTO lwa_lips
               WHERE vbeln = lwa_likp-vbeln.
        ENDSELECT.
        IF sy-subrc NE   0.
          CLEAR : lwa_lips.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF sy-subrc = 0

      IF li_enh_status[] IS NOT INITIAL.
* Read the Partner Functon.
* No need to use binary search as table is containing less entries
        READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_parvw.
        IF sy-subrc = 0.
          lv_parvw = <lfs_enh_status>-sel_low.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_enh_status[] IS NOT INITIAL

**     Fill communication structure of ship-to party
      IF lwa_likp-vbeln IS NOT INITIAL.
* Select from VBPA table first.
        SELECT SINGLE
                  vbeln  " Sales and Distribution Document Number
                  posnr  " Item number of the SD document
                  parvw  " Partner Function
                  kunnr  " Customer Number
                  adrnr  " Address
                  ablad  " Unloading Point
                  adrda  " Address indicator
               FROM vbpa " Sales Document: Partner
               INTO lwa_vbpa
               WHERE vbeln = lwa_likp-vbeln
                 AND posnr = lc_item_00
                 AND parvw = lv_parvw.


        IF sy-subrc EQ 0.
          CLEAR lwa_vtcom.
          lwa_vtcom-kunnr = lwa_vbpa-kunnr.
          lwa_vtcom-parvw = lwa_vbpa-parvw.
          lwa_vtcom-adrnr = lwa_vbpa-adrnr.
          lwa_vtcom-adrda = lwa_vbpa-adrda.
          lwa_vtcom-ablad = lwa_vbpa-ablad.
          lwa_vtcom-noablad = abap_true.
          lwa_vtcom-vbeln = lwa_likp-vbeln.
          lwa_vtcom-posnr = lc_item_00.
          lwa_vtcom-vkorg = lwa_likp-vkorg.
          lwa_vtcom-vtweg = lwa_lips-vtweg.
          lwa_vtcom-spart = lwa_lips-spart.
          lwa_vtcom-msgkz = lc_u.
          lwa_vtcom-aland = lwa_tvst-aland.

          CALL FUNCTION 'VIEW_KUWEV'
            EXPORTING
              comwa      = lwa_vtcom
            IMPORTING
              wewa       = lwa_kuwev
            EXCEPTIONS
              no_kna1    = 1
              no_knva    = 2
              no_knvi    = 3
              no_knvs    = 4
              no_knvv    = 5
              no_tpakd   = 6
              no_address = 7
              OTHERS     = 8.
          IF sy-subrc NE 0.
            EXIT.
          ENDIF. " IF sy-subrc NE 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF lwa_likp-vbeln IS NOT INITIAL
* Check whether this Enhancement is Active
      IF li_enh_status IS NOT INITIAL.
        CLEAR : lv_flag.
        LOOP AT li_enh_status ASSIGNING <lfs_enh_status>
                              WHERE criteria = lc_delv_type.
          IF lwa_likp-lfart = <lfs_enh_status>-sel_low.
            lv_flag = abap_true.
            EXIT.
          ENDIF. " IF lwa_likp-lfart = <lfs_enh_status>-sel_low
        ENDLOOP. " LOOP AT li_enh_status ASSIGNING <lfs_enh_status>

      ENDIF. " IF li_enh_status IS NOT INITIAL
      IF lv_flag IS NOT INITIAL.
*     Update delivery date in the delivery if necessary
        IF cs_vbkok-wadat_ist NE cs_vbkok-lfdat OR
           lv_delivery_time NE cs_vbkok-lfuhr.

          cs_vbkok-lfdat = cs_vbkok-wadat_ist.
          cs_vbkok-lfuhr = lv_delivery_time.
          cs_vbkok-kzlfd = abap_true.

        ENDIF. " IF cs_vbkok-wadat_ist NE cs_vbkok-lfdat OR
      ENDIF. " IF lv_flag IS NOT INITIAL
    ENDIF. " IF cs_vbkok-vbtyp_vl EQ lv_vbtyp AND
  ENDIF. " IF cs_vbkok-wadat_ist IS NOT INITIAL

ENDMETHOD. "if_ex_smod_v50b0001~exit_saplv50i_004


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_009.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50I_010.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_005.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_006.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_007.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_008.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_011.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_012.
endmethod.


method IF_EX_SMOD_V50B0001~EXIT_SAPLV50K_013.
endmethod.
ENDCLASS.
