**************************************************************************
* PROGRAM    :  ZOTCN0136_BOM_ITLEV_DISABLE                              *
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
* 29-Aug-2017   SMUKHER4   E1DK930261
*                                    D3_OTC_EDD_0136_Defect# 2831,Enable *
*                                    couple fields to be editable for    *
*                                    sales order with BOM Material which *
*                                    were disabled with Defect# 1060     *
*                                   No fields of BOM components should be*
*                                   editable except Batch and schedule   *
*                                  line delivery block. Batch field      *
*                                  should be editable only if material   *
*                                  is batch managed.
*&-----------------------------------------------------------------------*
*&-----------------------------------------------------------------------*
*&  Include           ZOTCN0136_BOM_ITLEV_DISABLE
*&-----------------------------------------------------------------------*
***//Constants Declaration.
CONSTANTS:lc_vbak_136 TYPE char30        VALUE '(SAPMV45A)VBAK',  " Vbak_136 of type CHAR30
          lc_otc_0136 TYPE z_enhancement VALUE 'D2_OTC_EDD_0136', " Enhancement No.
          lc_auart_cr TYPE z_criteria    VALUE 'AUART_ZCPR',      " Enh. Criteria
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
          lc_field       TYPE z_criteria VALUE 'NAME_FELD',  " Enh. Criteria
          lc_vbap_charg  TYPE char40     VALUE 'VBAP-CHARG', " screen field
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
          lc_exd      TYPE char1         VALUE 'E', " Exd of type CHAR1
          lc_ch       TYPE trtyp         VALUE 'V', " Transaction type
          lc_cr       TYPE trtyp         VALUE 'H'. " Transaction type

***//Data Declaration.
DATA:  li_otc_0136 TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
       lv_xchpf TYPE flag,                             " General Flag
       li_emi_field TYPE STANDARD TABLE OF fkk_ranges, " Structure: Select Options
       lwa_status   TYPE zdev_enh_status,              " Enhancement Status
       lwa_field TYPE fkk_ranges.                      " Structure: Select Options
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
***//Field Symbol Declaration.
FIELD-SYMBOLS: <fs_status_136> TYPE zdev_enh_status, " Enhancement Status
               <fs_vbak_136>   TYPE vbak.            " Sales Document: Header Data


IF t180-trtyp = lc_ch OR
   t180-trtyp = lc_cr.
  IF vbap-uepos IS NOT INITIAL.
***// We are using a Custom Authorization Object so
*   that authorized users can edit the BOM coomponents, rest cannot.
    AUTHORITY-CHECK OBJECT 'ZZITEMBOM'
    ID 'ACTVT' FIELD '02'.
    IF sy-subrc NE 0.

***//FM to Get the EMI Entries.
    CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
      EXPORTING
        iv_enhancement_no = lc_otc_0136
      TABLES
        tt_enh_status     = li_otc_0136.

*Non active entries are removed.
    DELETE li_otc_0136 WHERE active EQ abap_false.
*&-->Begin of delete for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*      DELETE li_otc_0136 WHERE sel_sign NE lc_exd.
*&<--End of delete for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
    SORT   li_otc_0136 BY criteria sel_low.

*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*&--EMI list is maintained for changes at sales order field level by the users.
    IF li_otc_0136 IS NOT INITIAL.
      LOOP AT li_otc_0136 INTO lwa_status.

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
      ENDLOOP. " LOOP AT li_otc_0136 INTO lwa_status
    ENDIF. " IF li_otc_0136 IS NOT INITIAL
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017

***//Enable when the object type is ZCPR.
    ASSIGN (lc_vbak_136) TO <fs_vbak_136>.
    IF <fs_vbak_136> IS ASSIGNED.
      READ TABLE li_otc_0136 ASSIGNING <fs_status_136> WITH KEY criteria = lc_auart_cr
                                                                sel_low  = <fs_vbak_136>-auart
                                                                BINARY SEARCH.
      IF sy-subrc <> 0.
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29-Aug-2017
*&--If the criteria does not exist in the exclusion list table,then it should disable the BOM components otherwise it should enable.

*&--Checking whether material is batch managed or not.
        CLEAR lv_xchpf.
        SELECT SINGLE xchpf " Batch management requirement indicator
        FROM mara           " General Material Data
        INTO lv_xchpf
        WHERE matnr = vbap-matnr.

        IF sy-subrc IS INITIAL.
*  do nothing
        ENDIF. " IF sy-subrc IS INITIAL

*&--No fields of BOM components should be editable except Batch and schedule line delivery block
        IF li_emi_field IS NOT INITIAL.
          IF screen-name IN li_emi_field.
*Batch field should be editable only if material is batch managed.
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

      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <fs_vbak_136> IS ASSIGNED
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF vbap-uepos IS NOT INITIAL
ENDIF. " IF t180-trtyp = lc_ch OR
