************************************************************************
* PROGRAM    :  LZOTC_GET_SHP_DTE_N_QUAN_GF01                          *
* TITLE      :  Order to Cash D2_OTC_IDD_0092_SAP_Get Order Status     *
* DEVELOPER  :  Abhishek Gupta3                                        *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0092                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of shipped date and shipped quantity         *
*              also planned date and confirmed quantity along with     *
*              tracking number and Invoices.                           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 02-June-2014  AGUPTA3  E2DK900484 Initial Development                *
* 24-Sep-2014   AGUPTA3  E2DK900484 CR_167 (Tracking number will be    *
*                                    populated from VEKP-SPE_IDENT_01  *
*                                    instead of VEKP-EXIDV. )          *
* 14-APR-2015   SHOBAN   E2DK900484  Defect#5842                       *
* 28-Apr-2015   MBAGDA   E2DK900484  Defect 6248                       *
*                                    Change field LIKP-WADAT to field  *
*                                    LIKP-LFDAT for Delivery Cases     *
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
***INCLUDE LZOTC_GET_SHP_DTE_N_QUAN_GF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_DATA
*&---------------------------------------------------------------------*
*  Subroutine to clear global variables.
*----------------------------------------------------------------------*
FORM f_clear_data .
  REFRESH: i_item_tmp,
         i_item,
         i_item_stat,
         i_docflow,
         i_docflow_tmp,
         i_sch_line,
         i_sch_line_a,
         i_sch_line_b,
         i_sch_line_1,
         i_delv_doc_b,
         i_delv_doc_c,
         i_slsdoc_stat,
         i_sddelivhead_data,
         i_sddelivitm_data,
         i_track_num,
         i_huitem,
         i_schline_out,
         i_output,
         i_ib_delv,
         i_bol,
         i_del_stat,
         i_ord_stat.

  CLEAR:  wa_output,
      wa_schline_out,
      wa_salesorder.
ENDFORM. " F_CLEAR_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_PLANNED_ITEM
*&---------------------------------------------------------------------*
*   Subroutine to get schedule line data of item
*----------------------------------------------------------------------*
*      -->P_<LFS_ITM_STAT>_POSNR  text item number
*      <--P_I_SCH_LINE_A  text Schedule line data
*----------------------------------------------------------------------*
FORM f_get_planned_item  USING fp_posnr TYPE posnr " Item number of the SD document
                         CHANGING fp_sch_line TYPE ty_t_vbep.

  DATA: li_sch_line_tm TYPE STANDARD TABLE OF ty_vbep.
  FIELD-SYMBOLS: <lfs_vbep> TYPE ty_vbep.

**Get the relevent Schedule line for item
  li_sch_line_tm[] = i_sch_line[].
  DELETE li_sch_line_tm WHERE posnr NE fp_posnr.
  LOOP AT li_sch_line_tm ASSIGNING <lfs_vbep>.
    IF ( ( <lfs_vbep>-bmeng NE 0 ) AND ( gv_flag IS INITIAL ) ).
      APPEND <lfs_vbep> TO fp_sch_line.
    ELSEIF ( ( <lfs_vbep>-wmeng NE 0 ) AND ( gv_flag = abap_true ) ).
      APPEND <lfs_vbep> TO fp_sch_line.
    ENDIF. " IF ( ( <lfs_vbep>-bmeng NE 0 ) AND ( gv_flag IS INITIAL ) )
  ENDLOOP. " LOOP AT li_sch_line_tm ASSIGNING <lfs_vbep>

ENDFORM. " F_GET_PLANNED_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERED_ITEM
*&---------------------------------------------------------------------*
*   Subroutine to get Delivery record of item
*----------------------------------------------------------------------*
*      -->P_<LFS_ITM_STAT>_POSNR  text item
*      <--P_I_DELV_DOC_B  text  table to hold delivery related data
*----------------------------------------------------------------------*
FORM f_get_delivered_item  USING fp_posnr TYPE posnr " Item number of the SD document
                           CHANGING fp_delv_doc TYPE ty_t_vbep1.

  DATA: li_docflow_tmp1 TYPE STANDARD TABLE OF vbfa, " Sales Document Flow
        lwa_schline     TYPE ty_vbep1.
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
  DATA: li_huitem TYPE STANDARD TABLE OF ty_vepo.
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3

  CONSTANTS: lc_wbstk_a TYPE wbstk VALUE 'A', " Total goods movement status
             lc_wbstk_b TYPE wbstk VALUE 'B', " Total goods movement status
             lc_wbstk_c TYPE wbstk VALUE 'C', " Total goods movement status
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
             lc_hu      TYPE /spe/de_huidart           VALUE 'T' . "Handling Unit Identification Type
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
  FIELD-SYMBOLS: <lfs_doc_flow>  TYPE vbfa, " Sales Document Flow
                 <lfs_date>      TYPE ty_likp,
                 <lfs_sls_doc_st> TYPE ty_vbuk,
                 <lfs_huitm>     TYPE ty_vepo,
                 <lfs_trck_no>   TYPE ty_vekp,
                 <lfs_quan>      TYPE ty_lips.

  li_docflow_tmp1[] = i_docflow_tmp[].

**Get all delivery related doc for this item
  DELETE li_docflow_tmp1 WHERE posnv NE fp_posnr.
  LOOP AT li_docflow_tmp1 ASSIGNING <lfs_doc_flow>.
    READ TABLE i_slsdoc_stat ASSIGNING <lfs_sls_doc_st>
                             WITH KEY vbeln = <lfs_doc_flow>-vbeln
                             BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_schline-wbstk = <lfs_sls_doc_st>-wbstk.
**Get delivery date
      IF ( <lfs_sls_doc_st>-wbstk = lc_wbstk_a OR <lfs_sls_doc_st>-wbstk = lc_wbstk_b ).
        READ TABLE i_sddelivhead_data ASSIGNING <lfs_date>
        WITH KEY vbeln = <lfs_sls_doc_st>-vbeln
                                         BINARY SEARCH.
        IF sy-subrc = 0.
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 6248 – by MBAGDA
*         lwa_schline-edatu = <lfs_date>-wadat.
          lwa_schline-edatu = <lfs_date>-lfdat.
* <--- End of Change for D2_OTC_IDD_0092_Defect 6248 by MBAGDA
        ENDIF. " IF sy-subrc = 0

      ELSEIF ( <lfs_sls_doc_st>-wbstk = lc_wbstk_c ).
        READ TABLE i_sddelivhead_data ASSIGNING <lfs_date>
      WITH KEY vbeln = <lfs_sls_doc_st>-vbeln
                                       BINARY SEARCH.
        IF sy-subrc = 0.
          lwa_schline-edatu = <lfs_date>-wadat_ist.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF ( <lfs_sls_doc_st>-wbstk = lc_wbstk_a OR <lfs_sls_doc_st>-wbstk = lc_wbstk_b )

**Get delivered quantity
      READ TABLE i_sddelivitm_data ASSIGNING <lfs_quan>
      WITH KEY vbeln = <lfs_sls_doc_st>-vbeln
               posnr = <lfs_doc_flow>-posnn
                                  BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_schline-bmeng = <lfs_quan>-lfimg.
        lwa_schline-vrkme = <lfs_quan>-vrkme.

** Get Handling unit number
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
        REFRESH: li_huitem.

        li_huitem[] = i_huitem[].
        DELETE li_huitem WHERE ( vbeln NE <lfs_quan>-vbeln
                             OR posnr NE <lfs_quan>-posnr ).
        LOOP AT li_huitem ASSIGNING <lfs_huitm>.

*        READ TABLE i_huitem ASSIGNING <lfs_huitm>
*                               WITH KEY vbeln = <lfs_quan>-vbeln
*                                        posnr = <lfs_quan>-posnr
*                                 BINARY SEARCH.
*        IF sy-subrc = 0.
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
**Get tracking number
          READ TABLE i_track_num ASSIGNING <lfs_trck_no>
                                  WITH KEY venum = <lfs_huitm>-venum
                                  BINARY SEARCH.
          IF sy-subrc = 0.
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
            IF <lfs_trck_no>-spe_idart_01 = lc_hu.
* Transferring values of Tracking number
              APPEND <lfs_trck_no>-spe_ident_01 TO lwa_schline-ztrack[]..
            ELSEIF <lfs_trck_no>-spe_idart_02 = lc_hu.
* Transferring values of Tracking number
              APPEND <lfs_trck_no>-spe_ident_02 TO lwa_schline-ztrack[].
            ELSEIF <lfs_trck_no>-spe_idart_03 = lc_hu.
* Transferring values of Tracking number
              APPEND <lfs_trck_no>-spe_ident_03 TO lwa_schline-ztrack[].
            ELSEIF <lfs_trck_no>-spe_idart_04 = lc_hu.
* Transferring values of Tracking number
              APPEND <lfs_trck_no>-spe_ident_04 TO lwa_schline-ztrack[].
            ENDIF. " IF <lfs_trck_no>-spe_idart_01 = lc_hu
* ---> End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447 by NBAIS

* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
*            lwa_schline-ztrack = <lfs_trck_no>-exidv.
*            lwa_schline-ztrack = <lfs_trck_no>-spe_ident_01.
* ---> Begin of Delete for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
*            APPEND <lfs_trck_no>-spe_ident_01 TO lwa_schline-ztrack[].
* ---> End of Delete for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
          ENDIF. " IF sy-subrc = 0
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
*        ENDIF. " IF sy-subrc = 0
        ENDLOOP. " LOOP AT li_huitem ASSIGNING <lfs_huitm>
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
    IF lwa_schline-bmeng NE 0.
      APPEND lwa_schline TO fp_delv_doc.
    ENDIF. " IF lwa_schline-bmeng NE 0
    CLEAR: lwa_schline.
  ENDLOOP. " LOOP AT li_docflow_tmp1 ASSIGNING <lfs_doc_flow>


ENDFORM. " F_GET_DELIVERED_ITEM
*&---------------------------------------------------------------------*
*&      Form  F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*       Subroutine to get Constants from EMI tool
*----------------------------------------------------------------------*
FORM f_get_constants .

  DATA:  lwa_del_stat  TYPE ty_status,
          lwa_ord_stat  TYPE ty_status.
  FIELD-SYMBOLS: <lfs_constants> TYPE zdev_enh_status. " Enhancement Status
  CONSTANTS: lc_0091      TYPE z_enhancement  VALUE 'D2_OTC_IDD_0091', " Enhancement No.
             lc_case_del  TYPE char20  VALUE 'CASE_DELIVERY',          " Enh. Criteria
             lc_case_ord  TYPE char20  VALUE 'CASE_ORDER',             " Case_ord of type CHAR20
             lc_null      TYPE z_criteria    VALUE 'NULL',             " Enh. Criteria
* ---> Begin of Insert for Defect#42,D2_OTC_IDD_0092 by SHOBAN
             lc_val_null  TYPE fpb_low VALUE 'NULL'. " From Value
* <--- End   of Insert for Defect#42,D2_OTC_IDD_0092 by SHOBAN

* getting all the constant values.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_0091
    TABLES
      tt_enh_status     = i_constant.

*first thing is to check for field criterion,for value “NULL” and field Active value:
*i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
*ii.If the  value is:space, then do not proceed further for this enhancement

  READ TABLE i_constant WITH KEY criteria = lc_null  "NULL
                                  active = abap_true "X"
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

    DELETE i_constant WHERE active NE abap_true.

* Collecting the values for which the logic needs to be excluded.
    LOOP AT i_constant ASSIGNING <lfs_constants>.
      IF <lfs_constants>-criteria = lc_case_del.
        lwa_del_stat-sign   = <lfs_constants>-sel_sign.
        lwa_del_stat-option = <lfs_constants>-sel_option.
* ---> Begin of Insert for Defect#5842,D2_OTC_IDD_0092 by SHOBAN
        IF <lfs_constants>-sel_low = lc_val_null. "NULL
          CLEAR lwa_del_stat-low.
        ELSE. " ELSE -> IF <lfs_constants>-criteria = lc_case_del
* <--- End   of Insert for Defect#5842,D2_OTC_IDD_0092 by SHOBAN
          lwa_del_stat-low    = <lfs_constants>-sel_low.
        ENDIF. " IF <lfs_constants>-criteria = lc_case_del
        lwa_del_stat-high   = <lfs_constants>-sel_high.
        APPEND lwa_del_stat TO i_del_stat.
        CLEAR lwa_del_stat.
      ELSEIF <lfs_constants>-criteria = lc_case_ord.
        lwa_ord_stat-sign   = <lfs_constants>-sel_sign.
        lwa_ord_stat-option = <lfs_constants>-sel_option.
* ---> Begin of Insert for Defect#5842,D2_OTC_IDD_0092 by SHOBAN
        IF <lfs_constants>-sel_low = lc_val_null. "NULL
          CLEAR lwa_ord_stat-low.
        ELSE. " ELSE -> IF sy-subrc EQ 0
* <--- End   of Insert for Defect#5842,D2_OTC_IDD_0092 by SHOBAN
          lwa_ord_stat-low    = <lfs_constants>-sel_low.
        ENDIF. " LOOP AT i_constant ASSIGNING <lfs_constants>
        lwa_ord_stat-high   = <lfs_constants>-sel_high.
        APPEND lwa_ord_stat TO i_ord_stat.
        CLEAR lwa_ord_stat.
      ENDIF. " IF sy-subrc EQ 0
    ENDLOOP. " LOOP AT i_constant ASSIGNING <lfs_constants>
  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " F_GET_CONSTANTS
