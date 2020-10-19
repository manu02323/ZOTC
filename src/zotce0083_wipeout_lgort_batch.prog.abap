*&---------------------------------------------------------------------*
*&  Include           ZOTCE0083_WIPEOUT_LGORT_BATCH
***********************************************************************
* PROGRAM    :  ZIM_WIPEOUT_LGORT_FOR_BATCHES (Enhancement)            *
* TITLE      :  Wipe out storage location(LGORT)for Batch Managed      *
*               products                                               *
* DEVELOPER  :  Abdulla Mangalore                                      *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0083                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Wipe out storage location(LGORT)for Batch Managed       *
*               products                                               *                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 11-NOV-2012  AMANGAL  E1DK908046 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 28-OCT-2014  MSINGH1  E2DK906022 D2_OTC_EDD_0083 -
*                                  Changes to consider plant in addition
*                                  with sales order type and replacement
*                                  of ZOTC_PRC_CONTROL With EMI Tool
*&---------------------------------------------------------------------*
* 05-MAY-2017  NALI     E1DK927736 COE Defect - 2736 -
*                                  1.Currently the program checks for  *
*                                  Batch# is not blank. This check is  *
*                                  not required.                       *
*                                  if XVBAP[row#]-XCHARG ≠ NULL        *
*                                  2.	If VBKD-BSARK=”ZSMX” where       *
*                                  VBKD-POSNR=blank (Header value),    *
*                                  then do not wipe out SLOC and exit  *
*                                  the enhancement. PO Type exclusion  *
*                                  values e.g. ZSMX is to be maintained*
*                                  in EMI table.                       *
*                                  3.	If VBAK-VKORG =”XXXX”, then do   *
*                                  not wipe out SLOC and exit the      *
*                                  enhancement. Sales Org. exclusion   *
*                                  values (XXXX) to be maintained      *
*                                  in EMI table. This option is for any*
*                                  future requirement.                 *
*                                  4.	If VBAK-VTWEG =”YY”, then do not *
*                                  wipe out SLOC and exit the          *
*                                  enhancement. Distribution Channel   *
*                                  exclusion values (YY) to be         *
*                                  maintained in EMI table. This option*
*                                  is for any future requirement.      *
*&---------------------------------------------------------------------*
* ---> Begin of Change/Insert/Delete for D2_OTC_EDD_0083 by MSINGH1
*
  CONSTANTS :
            lc_idd_0083     TYPE z_enhancement    VALUE 'D2_OTC_EDD_0083', " Enhancement No.
            lc_con_check    TYPE xchar            VALUE 'X',               " Batch management indicator (internal)
            lc_auart        TYPE z_criteria       VALUE 'AUART',           " Enh. Criteria
            lc_werks        TYPE z_criteria       VALUE 'WERKS',           " Enh. Criteria
            lc_trtyp        TYPE z_criteria       VALUE 'TRTYP',           " Enh. Criteria
            lc_lfsta        TYPE z_criteria       VALUE 'LFSTA',           " Enh. Criteria
* ---> Begin of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI
            lc_bsark        TYPE z_criteria       VALUE 'BSARK',           " Enh. Criteria
            lc_vkorg        TYPE z_criteria       VALUE 'VKORG',           " Enh. Criteria
            lc_vtweg        TYPE z_criteria       VALUE 'VTWEG'.           " Enh. Criteria
* <--- End of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI

  DATA :
        li_status          TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status tabl
* ---> Begin of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI
        lv_no_wipe         TYPE flag. " Flag to determine whether not to wipe out Storage Location
* <--- End of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI

  FIELD-SYMBOLS: <lfs_xvbap> TYPE vbapvb. " Document Structure for XVBAP/YVBAP


* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0083
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

  DELETE li_status WHERE active = space.

  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

* ---> Begin of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI
   READ TABLE li_status WITH KEY criteria = lc_bsark
                                 sel_low  = vbkd-bsark
                                 TRANSPORTING NO FIELDS. " No Binary Search required as table containes very few entries.
    IF sy-subrc = 0.
      lv_no_wipe = abap_true. " Flag set in order not to wipe out Storage Location.
    ELSE.
      CLEAR lv_no_wipe.
    ENDIF.
    IF lv_no_wipe IS INITIAL.
      READ TABLE li_status WITH KEY criteria = lc_vkorg
                                 sel_low  = vbak-vkorg
                                 TRANSPORTING NO FIELDS. " No Binary Search required as table containes very few entries.
      IF sy-subrc = 0.
        lv_no_wipe = abap_true. " Flag set in order not to wipe out Storage Location.
      ELSE.
        CLEAR lv_no_wipe.
      ENDIF.
    ENDIF.
    IF lv_no_wipe IS INITIAL.
        READ TABLE li_status WITH KEY criteria = lc_vtweg
                                      sel_low  = vbak-vtweg
                                      TRANSPORTING NO FIELDS. " No Binary Search required as table containes very few entries.
        IF sy-subrc = 0.
          lv_no_wipe = abap_true.
        ELSE.
          CLEAR lv_no_wipe.
        ENDIF.
    ENDIF.
* <--- End of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI

    READ TABLE li_status WITH KEY criteria = lc_auart
                                   sel_low = vbak-auart
                                   TRANSPORTING NO FIELDS.
    IF sy-subrc EQ  0.
*   Check on when transaction type is Add or Change
      READ TABLE li_status WITH KEY criteria = lc_trtyp
                                     sel_low = t180-trtyp
                                     TRANSPORTING NO FIELDS.
      IF sy-subrc EQ  0.

        LOOP AT xvbap ASSIGNING <lfs_xvbap>.
*   Check for plants maintained in EMI Tool with Criteria WERKS
          READ TABLE li_status WITH KEY criteria = lc_werks
                                         sel_low = <lfs_xvbap>-werks
                                         TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
*    Check whether delivery status is not completely processed and Batch is not blank
            READ TABLE li_status WITH KEY criteria = lc_lfsta
                                           sel_low = vbup-lfsta
                                           TRANSPORTING NO FIELDS.

            IF sy-subrc NE 0
              AND <lfs_xvbap>-abgru EQ space " Rejection reason is blank

                AND <lfs_xvbap>-xchar EQ lc_con_check
* ---> Begin of Delete for D3_OTC_EDD_0083_Defect#2736 by NGARG
*              AND <lfs_xvbap>-charg NE space  " Batch is populated
* <--- End of Delete for D3_OTC_EDD_0083_Defect#2736 by NGARG
* ---> Begin of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI
                AND lv_no_wipe  EQ space
* <--- End of Change for D3_OTC_EDD_0083_COE_Defect#2736 by NALI
                AND <lfs_xvbap>-lgort NE space. " Storage location is populated

              <lfs_xvbap>-lgort = space.
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF sy-subrc EQ 0
        ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_xvbap>

      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0


  ENDIF. " IF sy-subrc EQ 0
*DATA: li_prc_control TYPE TABLE OF zotc_prc_control,
*      lv_order_type_found TYPE flag.
*
*
*CONSTANTS : lc_mprogram    TYPE char35 VALUE 'ZOTCE0083_WIPEOUT_LGORT_BATCH', "Program name
*            lc_x           TYPE char1   VALUE 'X'.
*
*FIELD-SYMBOLS: <lfs_xvbap> TYPE vbapvb,
*               <lfs_prc_control> TYPE zotc_prc_control.
*
*
*
*IF t180-trtyp EQ 'H' OR t180-trtyp EQ 'V'.
*
*  SELECT *
*    FROM zotc_prc_control
*    INTO TABLE  li_prc_control
*    WHERE vkorg = vbak-vkorg
*    AND vtweg = vbak-vtweg
*    AND mprogram = lc_mprogram
*    AND   mactive = lc_x.
*
*  lv_order_type_found = space.
*
*  LOOP AT li_prc_control ASSIGNING <lfs_prc_control>.
*    IF <lfs_prc_control>-soption EQ 'EQ'
*      AND ( <lfs_prc_control>-mvalue1 = vbak-auart
*      OR  <lfs_prc_control>-mvalue2 = vbak-auart ).
*      lv_order_type_found  = 'X'.
*      EXIT.
*    ENDIF.
*  ENDLOOP.
*
*  IF lv_order_type_found = 'X'.
*
*    LOOP AT xvbap ASSIGNING <lfs_xvbap>.
*
*      IF vbup-lfsta NE 'C' AND <lfs_xvbap>-abgru EQ space
*         AND <lfs_xvbap>-xchar EQ 'X' AND <lfs_xvbap>-charg NE space
*         AND <lfs_xvbap>-lgort NE space.
*
*        <lfs_xvbap>-lgort = space.
*
*      ENDIF.
*
*    ENDLOOP.
*
*  ENDIF.
*
*ENDIF.
* <--- End    of Change/Insert/Delete for D2_OTC_EDD_0083 by MSINGH1
