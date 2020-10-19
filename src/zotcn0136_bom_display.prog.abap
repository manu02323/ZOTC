*&----------------------------------------------------------------------&*
**************************************************************************
* PROGRAM    :  ZOTCN0136_BOM_DISPLAY                                    *
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
*                                    BOM Material                        *
* 18-Jun-2018  DARUMUG    E1DK937241 Defect# 6315 Enable Conditions tab  *
*                                    for Sales Org. 2037                 *
*&-----------------------------------------------------------------------*
*&  Include           ZOTCN0136_BOM_DISPLAY
*&-----------------------------------------------------------------------*
***//Field Symbol Declaration.
field-symbols: <fs_status>     type zdev_enh_status, " Enhancement Status
               <fs_vbak>       type vbak.            " Sales Document: Header Data
***//Constant Declaration
constants:lc_vbak          type char30        value '(SAPMV45A)VBAK',  " Vbak of type CHAR30
          lc_edd_0136      type z_enhancement value 'D2_OTC_EDD_0136', " Enhancement
          lc_auart         type z_criteria    value 'AUART_ZCPR',      " Enh. Criteria
          lc_vkorg         type z_criteria    value 'VKORG_SECURITY',  " Enh. Criteria  "D#6315
          lc_exclude       type char1         value 'E',               " Exclude of type CHAR1
          lc_v             type trtyp         value 'V',               " Transaction type
          lc_h             type trtyp         value 'H',               " Transaction type
          lc_x             type char1         value 'X'.               " X of type CHAR1

***//Data Declaration
data:  li_edd_0136_status  type standard table of zdev_enh_status. " Enhancement Status

if trtyp_i = lc_v or
   trtyp_i = lc_h.
  if comm_item_i-zzuposnr is not initial.
***// We are using a Custom Authorization Object so
*   that authorized users can edit the BOM coomponents, rest cannot.
    authority-check object 'ZZITEMBOM'
    id 'ACTVT' field '02'.
    if sy-subrc ne 0.

*//Call to EMI Function Module To Get List Of EMI Statuses
      call function 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        exporting
          iv_enhancement_no = lc_edd_0136
        tables
          tt_enh_status     = li_edd_0136_status. "Enhancement status table

*//Non active entries are removed.
      delete li_edd_0136_status where active eq abap_false.
      delete li_edd_0136_status where sel_sign ne lc_exclude.
      sort   li_edd_0136_status by criteria sel_low.

*//Logic to Disable the BOM Component.
      assign (lc_vbak) to <fs_vbak>.
*&-->Begin of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29.08.2017
*      ASSIGN (lc_vbap) TO <fs_vbap>.
*&<--End of insert for D3_OTC_EDD_0136 Defect# 2831 by SMUKHER4 on 29.08.2017
      if sy-subrc = 0.
*//Enable when the Order type is ZCPR.

        read table li_edd_0136_status assigning <fs_status> with key criteria = lc_auart
                                                                     sel_low  = <fs_vbak>-auart
                                                                     binary search.
        if sy-subrc <> 0.
          " Read EMI entry to enable conditions tab for SOrg 2037
          read table li_edd_0136_status assigning <fs_status> with key criteria = lc_vkorg
                                                                       sel_low  = <fs_vbak>-vkorg     "D#6315
                                                                       binary search.
          if sy-subrc <> 0.
            display_only = lc_x.
          endif.
        endif. " IF sy-subrc <> 0
      endif. " IF sy-subrc = 0
    endif. " IF sy-subrc NE 0
  endif. " IF comm_item_i-zzuposnr IS NOT INITIAL
endif. " IF trtyp_i = lc_v OR
