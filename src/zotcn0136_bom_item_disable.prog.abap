**************************************************************************
* PROGRAM    :  ZOTCN0136_BOM_ITEM_DISABLE                               *
* TITLE      :  Custom Fields on Sales Document                          *
* DEVELOPER  :  Lekhasri Mahendiran                                      *
* OBJECT TYPE:  Enhancement                                              *
* SAP RELEASE:  SAP ECC 6.0                                              *
*------------------------------------------------------------------------*
* WRICEF ID: D2_OTC_EDD_0136
*------------------------------------------------------------------------*
* DESCRIPTION: Include for D2_OTC_EDD_0136
*------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                  *
*========================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                     *
* ===========  ========   =========  ====================================*
* 06.05.2016   LMAHEND    E2DK917765 D2_OTC_EDD_0136_Defect# 1060,Disable*
*                                    BOM Component fields while          *
*                                    creating/Changing Sales order With  *
*                                    BOM Material
*&-----------------------------------------------------------------------*
* 29-Aug-2017   SMUKHER4   E1DK930261 D3_OTC_EDD_0136_Defect# 2831,Enable *
*                                    couple fields to be editable for    *
*                                    sales order with BOM Material which *
*                                    were disabled with Defect# 1060     *
*                                   No fields of BOM components should be*
*                                   editable except Batch and schedule   *
*                                  line delivery block. Batch field      *
*                                  should be editable only if material   *
*                                  is batch managed.                     *
*&-----------------------------------------------------------------------*
*&  Include           ZOTCN0136_BOM_ITEM_DISABLE
*&-----------------------------------------------------------------------*
***//Field Symbol Declaration.
FIELD-SYMBOLS : <fs_vbap>   TYPE vbapvb,          " Document Structure for XVBAP/YVBAP
                <fs_status> TYPE zdev_enh_status, " Enhancement Status
                <fs_vbak>   TYPE vbak.            " Sales Document: Header Data

***//Constants Declaration.
CONSTANTS     : lc_vbap     TYPE char30        VALUE '(SAPMV45A)XVBAP', " Vbap of type CHAR30
                lc_vbak     TYPE char30        VALUE '(SAPMV45A)VBAK',  " Vbak of type CHAR30
                lc_edd_0136 TYPE z_enhancement VALUE 'D2_OTC_EDD_0136', " Enhancement
                lc_auart    TYPE z_criteria    VALUE 'AUART_ZCPR',      " Enh. Criteria
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
                lc_field       TYPE z_criteria    VALUE 'NAME_FELD',  " Enh. Criteria
                lc_vbap_charg  TYPE char30        VALUE 'VBAP-CHARG', " Screen field
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
                lc_exclude  TYPE char1         VALUE 'E'. " Exclude of type CHAR1

***//Data Declaration.
DATA:  li_edd_0136_status   TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
       lv_xchpf TYPE flag,                             " General Flag
       li_emi_field TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
       lwa_status   TYPE zdev_enh_status,              " Enhancement Status
       lwa_field TYPE fkk_ranges.                      " Structure: Select Options
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

*//Logic to Disable BOM Component.
ASSIGN (lc_vbap) TO <fs_vbap>. "RNATHAK
* these two IF statements are added here for Retrofit review point fixing "RNATHAK
IF <fs_vbap> IS ASSIGNED. "RNATHAK
  IF <fs_vbap>-uepos IS NOT INITIAL. "RNATHAK
***// We are using a Custom Authorization Object so
*   that authorized users can edit the BOM coomponents, rest cannot.
    AUTHORITY-CHECK OBJECT 'ZZITEMBOM'
    ID 'ACTVT' FIELD '02'.
    IF sy-subrc NE 0.

*//Call Function Module to Get the EMI entries.
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_edd_0136
      TABLES
        tt_enh_status     = li_edd_0136_status. "Enhancement status table

*//Non active entries are removed.
    DELETE li_edd_0136_status WHERE active EQ abap_false.
*&-->Begin of delete for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*      DELETE li_edd_0136_status WHERE sel_sign NE lc_exclude.
*&<--End of delete for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
    SORT li_edd_0136_status BY criteria sel_low.

*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*&--Exclusion list is maintained for changes at sales order level by the users.
    IF li_edd_0136_status IS NOT INITIAL.
      LOOP AT li_edd_0136_status INTO lwa_status.

        CASE lwa_status-criteria.
          WHEN lc_field.
            lwa_field-sign   = lwa_status-sel_sign.
            lwa_field-option = lwa_status-sel_option.
            lwa_field-low    = lwa_status-sel_low.
            lwa_field-high   = lwa_status-sel_high.
            APPEND lwa_field TO li_emi_field.
            CLEAR lwa_field.
        ENDCASE.
        CLEAR lwa_status.
      ENDLOOP. " LOOP AT li_edd_0136_status INTO lwa_status
    ENDIF. " IF li_edd_0136_status IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

*//Logic to Disable BOM Component.
*      ASSIGN (lc_vbap) TO <fs_vbap>. "TNATHAK

*//Enable when the object type is ZCPR.

*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*&--Checking whether material is batch managed or not
    CLEAR lv_xchpf.
    IF <fs_vbap>-matnr IS NOT INITIAL.
      SELECT SINGLE xchpf " Batch management requirement indicator
      FROM mara           " General Material Data
      INTO lv_xchpf
      WHERE matnr = <fs_vbap>-matnr.
      IF sy-subrc IS INITIAL.
*  do nothing
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF <fs_vbap>-matnr IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

    ASSIGN (lc_vbak) TO <fs_vbak>.
    IF <fs_vbak> IS ASSIGNED.

      READ TABLE li_edd_0136_status ASSIGNING <fs_status> WITH KEY criteria = lc_auart
                                                                   sel_low  = <fs_vbak>-auart
                                                                   BINARY SEARCH.
      IF sy-subrc <> 0.

*          IF <fs_vbap> IS ASSIGNED. "RNATHAK

        LOOP AT SCREEN.
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*No fields of BOM components should be editable except Batch and schedule line delivery block
          IF li_emi_field IS NOT INITIAL.
            IF screen-name IN li_emi_field.
              IF screen-name = lc_vbap_charg.
                IF lv_xchpf = abap_true.
                  screen-input = 1.
                ELSE. " ELSE -> IF lv_xchpf = abap_true
                  screen-input = 0.
                ENDIF. " IF lv_xchpf = abap_true
              ELSE. " ELSE -> IF screen-name = lc_vbap_charg
                screen-input = 1.
              ENDIF. " IF screen-name = lc_vbap_charg
            ELSE. " ELSE -> IF screen-name IN li_emi_field
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
              screen-input = 0.
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
            ENDIF. " IF screen-name IN li_emi_field
            ELSE.
              screen-input = 0.
          ENDIF. " IF li_emi_field IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
          MODIFY SCREEN.
        ENDLOOP. " LOOP AT SCREEN
*          ENDIF. " IF <fs_vbap>-uepos IS NOT INITIAL "RNATHAK
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <fs_vbak> IS ASSIGNED
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF <fs_vbap>-uepos IS NOT INITIAL
ENDIF. " IF <fs_vbap> IS ASSIGNED
