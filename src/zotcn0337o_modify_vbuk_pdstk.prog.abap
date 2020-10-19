***********************************************************************
*Program    : ZOTCN0337O_MODIFY_VBUK_PDSTK (Include)                  *
*Title      : Prevent the deletion of delivery items with service     *
*             based revenue recognition with POD as per SAP           *
*             recommendation.                                         *
*Developer  : NASRIN ALI                                              *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0337                                           *
*---------------------------------------------------------------------*
*Description: EHQ_Invoice_Before_POD                                  *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date         User ID     Transport      Description
*===========  ==========  ============== =============================*
*13-JUN-2016  NALI        E1DK918440     Initial Development
*---------------------------------------------------------------------*
*18-Oct-2016  NALI        E1DK918440     D3_OTC_EDD_0337_CR_189 - If
*                                        Sales Organisation is
*                                        maintained in EMI then the
*                                        flag to set VBUK-PDSTK should
*                                        not be changed to 'C' in order
*                                        not to allow to create customer
*                                        billing document until POD is
*                                        received.
*---------------------------------------------------------------------*
TYPES: BEGIN OF lty_lips,
        vbeln TYPE vbeln_vl,   "Delivery
        posnr TYPE posnr_vl,   "Delivery Item
        pstyv TYPE pstyv_vl,   "Delivery item category
       END OF lty_lips,

       BEGIN OF lty_tvap,
         pstyv TYPE pstyv,     "Sales document item category
         rrrel TYPE rr_reltyp, "Revenue recognition category
       END OF lty_tvap,

       BEGIN OF lty_tvlp,
         pstyv TYPE pstyv_vl,  "Delivery item category
         podkz TYPE podkzs,    "Control of POD relevance for deliveries
       END OF lty_tvlp.

CONSTANTS: lc_enh_no      TYPE z_enhancement VALUE 'OTC_EDD_0337',    " Enhancement Project
           lc_null        TYPE z_criteria    VALUE 'NULL',            "Enhancement Criteria
           lc_rrrel       TYPE z_criteria    VALUE 'RRREL',           "Enhancement Criteria
           lc_strum       TYPE z_criteria    VALUE 'STRUM',           "Enhancement Criteria
           lc_podkz       TYPE z_criteria    VALUE 'PODKZ',           "Enhancement Criteria
           lc_doc_status  TYPE z_criteria    VALUE 'DOC_STATUS', "Enhancement Criteria
* ---> Begin of change for D3_OTC_EDD_0337_CR_189 by NALI
           lc_vkorg       TYPE z_criteria    VALUE 'VKORG'. "Enhancement Criteria
* <--- End of change for D3_OTC_EDD_0337_CR_189 by NALI

DATA: lv_rrrel      TYPE rr_reltyp,                         "Revenue recognition category
      lv_podkz      TYPE podkzs,                            "Control of POD relevance for deliveries
      lv_doc_status TYPE statv,                             "Document Status
      lv_strum      TYPE strum,                             "Structural scope of a material with bill of material
      li_status     TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status
      li_lips       TYPE STANDARD TABLE OF lty_lips,
      li_tvap       TYPE STANDARD TABLE OF lty_tvap,
      li_tvlp       TYPE STANDARD TABLE OF lty_tvlp.

DATA: li_strum TYPE RANGE OF strum, " Structural scope of a material with bill of material
      lx_strum LIKE LINE OF li_strum.

FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status, " Enhancement Status
               <lfs_lips>   TYPE lty_lips.

CLEAR lv_rrrel.
CLEAR lv_podkz.
CLEAR lv_doc_status.
** get all constants from EMI.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enh_no
  TABLES
    tt_enh_status     = li_status.
IF sy-subrc = 0 AND li_status IS NOT INITIAL.
  SORT li_status BY criteria active.
**  check if the object is active in EMI
  READ TABLE li_status WITH KEY
                     criteria = lc_null
                     active = abap_true
                     TRANSPORTING NO FIELDS. " small table hence Binary Search not used
  IF sy-subrc EQ 0.
**  get the value of RRREL from constant table
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY
                                criteria = lc_rrrel
                                active = abap_true. " small table hence Binary Search not used
    IF sy-subrc = 0.
      lv_rrrel = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc = 0
**  get the value of STRUM from constant table
    LOOP AT li_status ASSIGNING <lfs_status> WHERE criteria = lc_strum AND
                                                   active = abap_true.
      lv_strum = <lfs_status>-sel_low.
      lx_strum-sign = 'I'.
      lx_strum-option = 'EQ'.
      lx_strum-low = lv_strum.

      APPEND lx_strum TO li_strum.
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status> WHERE criteria = lc_strum AND
**  get the value of PODKZ from constant table
    READ TABLE li_status ASSIGNING <lfs_status> WITH KEY
                                    criteria = lc_podkz
                                    active = abap_true. " small table hence Binary Search not used
    IF sy-subrc = 0.
      lv_podkz = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc = 0
* ---> Begin of change for D3_OTC_EDD_0337_CR_189 by NALI
*&--Check if the Sales Organisation is maintained in EMI.
    READ TABLE li_status TRANSPORTING NO FIELDS WITH KEY criteria = lc_vkorg
                                                         sel_low  = likp-vkorg
                                                         active   = abap_true.
    IF sy-subrc <> 0.
*&--If the Sales Organisation is not maintained, then only set the flag to change the status of VBUK-PDSTK.
* <--- End of change for D3_OTC_EDD_0337_CR_189 by NALI
**  get the value of UVK01 from constant table
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY
                                      criteria = lc_doc_status
                                      active = abap_true. " small table hence Binary Search not used
      IF sy-subrc = 0.
        lv_doc_status = <lfs_status>-sel_low.
      ENDIF. " IF sy-subrc = 0
* ---> Begin of change for D3_OTC_EDD_0337_CR_189 by NALI
    ENDIF. " IF sy-subrc <> 0
    IF lv_doc_status  IS NOT INITIAL.
* <--- End of change for D3_OTC_EDD_0337_CR_189 by NALI
*      get the SD document: Delivery: Item data for the corresponding VBUK-VBELN
      SELECT vbeln " Delivery
             posnr " Delivery Item
             pstyv " Delivery item category
        FROM lips  " SD document: Delivery: Item data
        INTO TABLE li_lips
        WHERE vbeln = vbuk-vbeln.
      IF sy-subrc = 0.
        SORT li_lips BY pstyv.
        DELETE ADJACENT DUPLICATES FROM li_lips COMPARING pstyv.
      ENDIF. " IF sy-subrc = 0
      IF li_lips IS NOT INITIAL.
        SELECT pstyv " Sales document item category
             rrrel   " Revenue recognition category
        FROM tvap    " Sales Document: Item Categories
        INTO TABLE li_tvap
        FOR ALL ENTRIES IN li_lips
        WHERE pstyv = li_lips-pstyv
        AND   rrrel NE lv_rrrel
        AND   strum NOT IN li_strum.
        IF sy-subrc = 0.
          SORT li_tvap BY pstyv.
        ENDIF. " IF sy-subrc = 0

        SELECT pstyv " Delivery item category
               podkz " Control of POD relevance for deliveries
          FROM tvlp  " Deliveries: Item Categories
          INTO TABLE li_tvlp
          FOR ALL ENTRIES IN li_lips
          WHERE pstyv = li_lips-pstyv
          AND   podkz NE lv_podkz.
        IF sy-subrc = 0.
          SORT li_tvlp BY pstyv.
        ENDIF. " IF sy-subrc = 0
        IF li_tvap IS INITIAL AND li_tvlp IS INITIAL.
          vbuk-pdstk = lv_doc_status.
        ENDIF. " IF li_tvap IS INITIAL AND li_tvlp IS INITIAL
      ENDIF. " IF li_lips IS NOT INITIAL
* ---> Begin of change for D3_OTC_EDD_0337_CR_189 by NALI
    ENDIF. " IF lv_doc_status IS NOT INITIAL
* <--- End of change for D3_OTC_EDD_0337_CR_189 by NALI
  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF sy-subrc = 0 AND li_status IS NOT INITIAL
