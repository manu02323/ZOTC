*&---------------------------------------------------------------------*
*&  Include           ZOTCN0337O_INIT_DELIVERY_QUANT
*&---------------------------------------------------------------------*
************************************************************************
* Program          :  ZOTCN0337O_INIT_DELIVERY_QUANT (Include)         *
* TITLE            :  User-exit to initialize the delivery qauntities  *
* DEVELOPER        :  NASRIN ALI                                       *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D3_OTC_EDD_0337                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  The delivery quantities are initialized when the *
*                     billing document is transfered                   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 23-JUN-2016  NALI     E1DK918440  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*
CONSTANTS: lc_edd_0337         TYPE z_enhancement VALUE 'OTC_EDD_0337', "Enhancement No.
           lc_null             TYPE z_criteria    VALUE 'NULL',         "Enh. Criteria
           lc_fkart            TYPE z_criteria    VALUE 'FKART',        "Enh. Criteria
           lc_pstyv            TYPE z_criteria    VALUE 'PSTYV'.        " Enh. Criteria
DATA:      li_enh_status       TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status
FIELD-SYMBOLS: <lfs_xaccit> TYPE accit.

**  Fetch all enhancement criteria for this object in internal table
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_edd_0337    "OTC_EDD_0337
  TABLES
    tt_enh_status     = li_enh_status. "Enhancement status table

IF sy-subrc = 0 AND li_enh_status IS NOT INITIAL.
  SORT li_enh_status BY criteria sel_low active.
  READ TABLE li_enh_status TRANSPORTING NO FIELDS WITH KEY criteria = lc_null
                                                       active = abap_true.
                                                        " small table hence binary search not used
  IF sy-subrc IS INITIAL.
    READ TABLE cvbrp INDEX 1.
    IF sy-subrc = 0.
      READ TABLE li_enh_status TRANSPORTING NO FIELDS
                         WITH KEY criteria = lc_pstyv
                                  sel_low = cvbrp-pstyv
                                  active = abap_true.
                                                        " small table hence binary search not used
      IF sy-subrc IS INITIAL.
       READ TABLE li_enh_status TRANSPORTING NO FIELDS
                          WITH KEY criteria = lc_fkart
                                   sel_low = cvbrk-fkart
                                   active = abap_true.
       IF sy-subrc IS INITIAL.
        LOOP AT xaccit ASSIGNING <lfs_xaccit>.
          IF <lfs_xaccit>-fkimg NE 0.
            CLEAR: <lfs_xaccit>-fkimg,
                   <lfs_xaccit>-fklmg,
                   <lfs_xaccit>-vrkme.
*            IF <lfs_xaccit> IS ASSIGNED.
*              UNASSIGN <lfs_xaccit>.
*            ENDIF.
          ENDIF. " IF xaccit-fkimg NE 0
        ENDLOOP. " LOOP AT xaccit
       ENDIF.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc IS INITIAL
  REFRESH li_enh_status.
ENDIF. " IF li_enh_status IS NOT INITIAL
