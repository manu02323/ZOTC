class ZCL_IM_LORD_INPUT_MODE definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_BADI_LORD_GET_INPUT_MODE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_LORD_INPUT_MODE IMPLEMENTATION.


METHOD if_badi_lord_get_input_mode~get_input_mode.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_BADI_LORD_GET_INPUT_MODE~GET_INPUT_MODE              *
*Title      : ES Sales Order Creation                                 *
*Developer  : Raghu Achar                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090                                           *
*---------------------------------------------------------------------*
*Description: Create Sales Order in SAP using ESR Service Interface   *
*Create Request Confirmation_In V2                                    *
*Modify screen attributes for all the custom fields. Screen fields    *
*input attribute is set to active                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*21-May-2014  RACHAR                        INITIAL DEVELOPMENT
*30-Mar-2015  MBAGDA        E2DK911715      CR: D2_541                *
*14-Feb-2018  BGUNDAB       E1DK934125      Changes for D3:R3         *
*07-Dec-2018  MTHATHA       E1DK939532      SCTASK0768763-Created by  *
*---------------------------------------------------------------------*

*--Local Data declarations
  CONSTANTS :
     lc_null             TYPE z_criteria           VALUE 'NULL',                " Enh. Criteria
     lc_idd_0090_005     TYPE z_enhancement        VALUE 'D2_OTC_IDD_0090_005'. " Enhancement No.

  DATA: li_status        TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

  DATA : ls_supply TYPE tds_field_supply. " Single PAI Action

*--Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0090_005 "CR: D2_541 changed constant
    TABLES
      tt_enh_status     = li_status.

*--Check for Global user exit activation check
  READ TABLE li_status WITH KEY criteria = lc_null
                                active = abap_true
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

    CASE is_screen-name.
      WHEN 'VBKD-IHREZ' OR
           'VBAK-ZZDOCREF' OR
           'VBAK-ZZDOCTYP' OR
           'VBAK-ZZCASEREF' OR
           'VBAP-ZZQUOTEREF' OR
           'VBAP-ZZAGMNT' OR
           'VBAP-ZZAGMNT_TYP' OR
           'GV_MESSAGE_POSNR_REF' OR
           'GV_MESSAGE_VBELN_REF' OR
           'VBAP-ZZITEMREF' OR
*---> Begin of CR: D2_541
           'VBAP-ZZ_BILMET' OR
           'VBAP-ZZ_BILFR' OR
*<--- End of CR: D2_541
*---> Begin of changes for D3:R3
*Begin of changes by mthatha for SCTASK0768763
           'VBAK-ERNAM' OR
           'VBAP-ERNAM' OR
*End of changes by mthatha for SCTASK0768763
           'VBKD-FBUDA'.
*---> End of changes for D3:R3

        es_screen-active = 1.
        es_screen-input = 1.

    ENDCASE.
  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.
ENDCLASS.
