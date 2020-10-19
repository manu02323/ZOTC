class ZCL_IM_OTC_DELIVERY_DATE definition
  public
  final
  create public .

*"* public components of class ZCL_IM_OTC_DELIVERY_DATE
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
*"* protected components of class ZCL_IM_OTC_DELIVERY_DATE
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_OTC_DELIVERY_DATE
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_OTC_DELIVERY_DATE IMPLEMENTATION.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES .

* Example: Deactivate the function 'Copy picked quantity as delivery
* quantity'
  data: ls_cua_exclude type shp_cua_exclude.

  ls_cua_exclude-function = 'KOMU_T'.
  append ls_cua_exclude to ct_cua_exclude.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES .

  data: ls_field_attributes type shp_screen_attributes,
        ls_xvbup            type vbupvb.

* Example 1: The field 'Actual goods-movement date' should not be
* changed by the user
  ls_field_attributes-name  = 'LIKP-WADAT_IST'.
  ls_field_attributes-input = 0.
  append ls_field_attributes to ct_field_attributes.

* Example 2: The material description should not be changed for a
* certain group of materials after completion of the picking process
  if is_lips-matnr cs 'ZZ'.
    read table it_xvbup into ls_xvbup with key mandt = is_lips-mandt
                                               vbeln = is_lips-vbeln
                                               posnr = is_lips-posnr
                        binary search.
    if ls_xvbup-kosta eq 'C'.
      ls_field_attributes-name  = 'LIKP-WADAT_IST'.
      ls_field_attributes-input = 0.
      append ls_field_attributes to ct_field_attributes.
    endif.
  endif.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES


method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION .

*  data: ls_log type shp_badi_error_log.
*
** Example: Refuse deletion of an item if it contains a certain material
*  if is_xlips-matnr cs 'ZZ'.
*
*    cf_item_not_deletable = 'X'.
*
**   Output of message ZZ001:
**   'Item &1 contains material &2; item can not be deleted'
*    ls_log-msgid = 'ZZ'.
*    ls_log-msgno = '001'.
*    ls_log-msgty = 'E'.
*    ls_log-msgv1 = is_xlips-posnr.
*    ls_log-msgv2 = is_xlips-matnr.
*    append ls_log to ct_log.
*
*  endif.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION .

** Example: Delete delivery dependend data from the global memory of an
** own function group
*  call function 'ZZ_DELETE_CUSTOMER_DATA'
*    exporting
*      if_vbeln = is_likp-vbeln.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK .
*
*  data: lf_not_only_zero type c,
*        ls_finchdel      type finchdel.
*
*  field-symbols: <ls_xlikp> type likpvb,
*                 <ls_xlips> type lipsvb.
*
** Example: Delete delivery (creation mode, collective processing) or
** refuse saving it (dialogue mode) if it contains only items with
** delivery quantity 0.
*
** Loop at all created deliveries
*  loop at it_xlikp assigning <ls_xlikp> where updkz ne 'D'.
*    clear lf_not_only_zero.
*
**   Check delivery quantity of all items belonging to current delivery
*    loop at it_xlips assigning <ls_xlips>
*                     where vbeln eq <ls_xlikp>-vbeln
*                       and updkz ne 'D'.
*      if <ls_xlips>-lfimg ne 0.
*        lf_not_only_zero = 'X'.
*        exit.
*      endif.
*    endloop.
*    if lf_not_only_zero eq space.
**     All items of the delivery have delivery quantity 0:
**     Write message ZZ002 with type E to error log
**     (forces deletion of the delivery or prevents delivery from saving)
*      clear ls_finchdel.
*      ls_finchdel-vbeln    = <ls_xlikp>-vbeln.
*      ls_finchdel-pruefung = '99'.
*      ls_finchdel-msgty    = 'E'.
*      ls_finchdel-msgid    = 'ZZ'.
*      ls_finchdel-msgno    = '002'.
**     Note: CT_FINCHDEL is a hashed table
*      insert ls_finchdel into table ct_finchdel.
*    endif.
*  endloop.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK


method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM


method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY .

** Example: Initialize the data in the global memory of an own
** function group
*  call function 'ZZ_INITIALIZE_CUSTOMER_DATA'.

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY


method IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION .

** Example: Delete item dependend data from the global memory of an own
** function group
*  call function 'ZZ_DELETE_ITEM_CUSTOMER_DATA'
*    exporting
*      if_vbeln = is_xlips-vbeln
*      if_posnr = is_xlips-posnr.

endmethod.                    "IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION


method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM .


endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM


method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY .


** Example: Read delivery dependend data in the global memory of an own
** function group
*  call function 'ZZ_READ_CUSTOMER_DATA'
*    exporting
*      if_vbeln = cs_likp-vbeln.
*.
endmethod.                    "IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT .

endmethod. "IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT


METHOD if_ex_le_shp_delivery_proc~save_document_prepare .
***********************************************************************
*Program    : ZCL_IM_OTC_DELIVERY_DATE                                *
*Title      : Delivery Date Implementation                            *
*Developer  : Sneha Ghosh                                             *
*Object type: Enhancement Implementation                              *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: Implementation of OSS Note 552713                         *
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
*17-Mar-2016  SAGARWA1     E2DK914842    Defect#863:Initial development
*---------------------------------------------------------------------*


  TYPES: BEGIN OF lty_tvst,
            vstel TYPE vstel, " Shipping Point/Receiving Point
            aland TYPE aland, " Departure country (country from which the goods are sent)
         END OF lty_tvst.

  DATA: lwa_xlikp            TYPE likpvb,                                           "v_n_552713l" Reference structure for XLIKP/YLIKP
        lwa_xlips            TYPE lipsvb,                                           " Reference structure for XLIKS/YLIKS
        lwa_xvbpa            TYPE vbpavb,                                           " Reference structure for XVBPA/YVBPA
        lwa_kuwev            TYPE kuwev,                                            " Ship-to Party's View of the Customer Master Record
        lwa_tvst             TYPE lty_tvst,                                         " Organizational Unit: Shipping Points
        lwa_vtcom            TYPE vtcom,                                            " Communications Work Area for Cust.Master Accesses
        lwa_log              TYPE shp_badi_error_log,                               " Messages from BAdI Processing Delivery
        lv_goods_issue_time  TYPE wauhr,                                            " Time of Goods Issue (Local, Relating to a Plant)
        lv_count             TYPE i,                                                " Count of type Integers
        lv_flag              TYPE flag,                                             " Flag
        lv_parvw             TYPE parvw,                                            " Partner Function
        lv_vbtyp             TYPE vbtyp,                                            " SD Document Category
        li_enh_status        TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
        lv_delivery_time     TYPE lfuhr.                                            " Time of delivery

  CONSTANTS : lc_00         TYPE wauhr   VALUE '000000',                " Initial Time
              lc_item_00    TYPE posnr   VALUE '000000',                " Item Number
              lc_u          TYPE msgkz   VALUE 'U',                     " Processing of Messages
              lc_enh_no     TYPE z_enhancement VALUE 'D2_OTC_EDD_0234', " Enhancement No.
              lc_delv_type  TYPE z_criteria    VALUE 'DELV_TYPE',       " Enh. Criteria
              lc_vbtyp      TYPE z_criteria    VALUE 'VBTYP',           " Enh. Criteria
              lc_parvw      TYPE z_criteria    VALUE 'PARVW',           " Enh. Criteria
              lc_updkz_i    TYPE updkz_d VALUE 'I',                     " Update Indicator
              lc_updkz_u    TYPE updkz_d VALUE 'U',                     " Update Indicator
              lc_updkz_d    TYPE updkz_d VALUE 'D'.                     " Update Indicator

* Field Symbol Declaration
  FIELD-SYMBOLS: <lfs_enh_status> TYPE zdev_enh_status. " Enhancement Status
***begin Sneha Ag
***data : lv_temp type i VALUE 5.
***DO.
***  break sagarwa1.
***IF lv_temp > 5.
***exit.
***ENDIF.
***ENDDO.
*****end Sneha Ag

* Call FM to retrieve Enhancement Status
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_enh_status.

* Delete the EMI records where the status is not active
  DELETE li_enh_status WHERE active = space.

* Check whether this Enhancement is Active
  IF li_enh_status IS NOT INITIAL.

    LOOP AT li_enh_status ASSIGNING <lfs_enh_status>
                              WHERE criteria = lc_delv_type.
      IF lwa_xlikp-lfart = <lfs_enh_status>-sel_low.
        lv_flag = abap_true.
        EXIT.
      ENDIF. " IF lwa_xlikp-lfart = <lfs_enh_status>-sel_low
    ENDLOOP. " LOOP AT li_enh_status ASSIGNING <lfs_enh_status>

* Read the SD Document category.
* No need to use binary search as table is containing less entries
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_vbtyp.
    IF sy-subrc = 0.
      lv_vbtyp = <lfs_enh_status>-sel_low.
    ENDIF. " IF sy-subrc = 0

* Read the Partner Functon.
* No need to use binary search as table is containing less entries
    READ TABLE li_enh_status ASSIGNING <lfs_enh_status> WITH KEY criteria = lc_parvw.
    IF sy-subrc = 0.
      lv_parvw = <lfs_enh_status>-sel_low.
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF li_enh_status IS NOT INITIAL

  IF lv_flag IS NOT INITIAL.
* Update of delivery date only if goods movement is posted
    IF is_v50agl-warenausgang NE space.
      READ TABLE ct_xlikp INTO lwa_xlikp INDEX 1.
      IF sy-subrc = 0.
*   Update is only necessary for outbound deliveries and in case of
*   deviations between the planned and the actual goods issue date
        IF lwa_xlikp-vbtyp EQ lv_vbtyp AND
           lwa_xlikp-wadat NE lwa_xlikp-wadat_ist.

*     If actual goods-issue date is today assume that goods issue is
*     posted at the same moment
          IF lwa_xlikp-wadat_ist EQ sy-datlo.
            lv_goods_issue_time = sy-timlo.
          ELSE. " ELSE -> IF lwa_xlikp-wadat_ist EQ sy-datlo
            lv_goods_issue_time = lc_00.
          ENDIF. " IF lwa_xlikp-wadat_ist EQ sy-datlo

*     Read first non-deleted item for information on item level
*     (distribution channel, division, loading group)
          LOOP AT ct_xlips INTO lwa_xlips
                           WHERE vbeln EQ lwa_xlikp-vbeln
                             AND updkz NE lc_updkz_d.
            EXIT.
          ENDLOOP. " LOOP AT ct_xlips INTO lwa_xlips
          IF sy-subrc NE 0.
            EXIT.
          ENDIF. " IF sy-subrc NE 0
          IF lwa_xlikp-vstel is not INITIAL.
*     Get shipping point information
            SELECT SINGLE vstel       " Shipping Point/Receiving Point
                          aland       " Departure country (country from which the goods are sent)
                            FROM tvst " Organizational Unit: Shipping Points
                            INTO lwa_tvst
                            WHERE vstel EQ lwa_xlikp-vstel.
            IF sy-subrc NE 0.
              CLEAR : lwa_tvst.
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF lwa_xlikp-vstel
*     Fill communication structure of ship-to party
* No need for binary search as the records will be less than 100
          READ TABLE ct_xvbpa INTO lwa_xvbpa
                              WITH KEY vbeln = lwa_xlikp-vbeln
                                       posnr = lc_item_00
                                       parvw = lv_parvw.
          IF sy-subrc EQ 0.
            CLEAR lwa_vtcom.
            lwa_vtcom-kunnr = lwa_xvbpa-kunnr.
            lwa_vtcom-parvw = lwa_xvbpa-parvw.
            lwa_vtcom-adrnr = lwa_xvbpa-adrnr.
            lwa_vtcom-adrda = lwa_xvbpa-adrda.
            lwa_vtcom-ablad = lwa_xvbpa-ablad.
            lwa_vtcom-noablad = abap_true.
            lwa_vtcom-vbeln = lwa_xlikp-vbeln.
            lwa_vtcom-posnr = lc_item_00.
            lwa_vtcom-vkorg = lwa_xlikp-vkorg.
            lwa_vtcom-vtweg = lwa_xlips-vtweg.
            lwa_vtcom-spart = lwa_xlips-spart.
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
              lwa_log-vbeln = lwa_xlikp-vbeln.
              lwa_log-posnr = lc_item_00.
              lwa_log-msgty = sy-msgty.
              lwa_log-msgid = sy-msgid.
              lwa_log-msgno = sy-msgno.
              lwa_log-msgv1 = sy-msgv1.
              lwa_log-msgv2 = sy-msgv2.
              lwa_log-msgv3 = sy-msgv3.
              lwa_log-msgv4 = sy-msgv4.
              APPEND lwa_log TO ct_log.
              EXIT.
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF sy-subrc EQ 0

*     Update delivery date in the delivery if necessary
*        IF lv_delivery_date NE lwa_xlikp-lfdat OR
          IF lwa_xlikp-wadat_ist NE  lwa_xlikp-lfdat OR
             lv_delivery_time NE lwa_xlikp-lfuhr.
* No need for binary search as the records will be less than 100
            READ TABLE ct_ylikp WITH KEY vbeln = lwa_xlikp-vbeln
                                TRANSPORTING NO FIELDS.
            IF sy-subrc NE 0.
              APPEND lwa_xlikp TO ct_ylikp.
            ENDIF. " IF sy-subrc NE 0
            lwa_xlikp-lfdat = lwa_xlikp-wadat_ist.
            lwa_xlikp-lfuhr = lv_delivery_time.
            IF lwa_xlikp-updkz NE lc_updkz_i.
              lwa_xlikp-updkz = lc_updkz_u.
            ENDIF. " IF lwa_xlikp-updkz NE lc_updkz_i
            MODIFY ct_xlikp FROM lwa_xlikp INDEX 1.
          ENDIF. " IF lwa_xlikp-wadat_ist NE lwa_xlikp-lfdat OR
        ENDIF. " IF lwa_xlikp-vbtyp EQ lv_vbtyp AND
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF is_v50agl-warenausgang NE space
  ENDIF. " IF lv_flag IS NOT INITIAL

ENDMETHOD. "if_ex_le_shp_delivery_proc~save_document_prepare
ENDCLASS.
