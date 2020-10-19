class ZCL_IM_BADI_LORD_DO_PAI definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_BADI_LORD_DO_PAI .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_BADI_LORD_DO_PAI IMPLEMENTATION.


METHOD if_badi_lord_do_pai~add_supply_list.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_SLS_APPL_SE_SOERPCRTRC2~INBOUND_PROCESSING           *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder/Manish Bagda                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090                                           *
*---------------------------------------------------------------------*
*Description: Create Sales Order in SAP using ESR Service Interface   *
*Create Request Confirmation_In V2                                    *
*Map all custom fields in LORD structure for PAI processing           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*06-Jun-2014  JAHAN         E2DK900476      INITIAL DEVELOPMENT       *
*01-Oct-2014  JAHAN         E2DK900476      Changes D2_CR_9, CR_20    *
*30-Mar-2015  MBAGDA        E2DK911715      CR: D2_541                *
*14-Feb-2018  BGUNDAB       E1DK934125      Changes for D3 R3         *
*07-Dec-2018  MTHATHA       E1DK939532      SCTASK0768763-Created by  *
*---------------------------------------------------------------------*
*--Local Data declarations
  CONSTANTS :
     lc_null             TYPE z_criteria           VALUE 'NULL',                " Enh. Criteria
     lc_idd_0090_004     TYPE z_enhancement        VALUE 'D2_OTC_IDD_0090_004'. " Enhancement No.

  DATA: li_status        TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

  DATA : ls_supply TYPE tds_field_supply. " Single PAI Action

*--Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0090_004 "CR: D2_541 changed constant
    TABLES
      tt_enh_status     = li_status.

*--Check for Global user exit activation check
  READ TABLE li_status WITH KEY criteria = lc_null
                                active = abap_true
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

    CASE iv_object_id.
      WHEN 'HEAD'.
*Begin of changes by mthatha for SCTASK0768763
* Field: Created By
        CLEAR ls_supply.
        ls_supply-field = 'ZERNAM' .
        APPEND ls_supply TO ct_supply .
*End of changes by mthatha for SCTASK0768763
* Field: Case Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZCASEREF' .
        APPEND ls_supply TO ct_supply .

* Field: Your Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZIHREZ' .
        APPEND ls_supply TO ct_supply .
*---> Begin of D3 R3 Changes
* Field: Serv.rendered Date
        CLEAR ls_supply.
        ls_supply-field = 'ZFBUDA' .
        APPEND ls_supply TO ct_supply .
*---> End of D3 R3 Changes

      WHEN 'ITEM' .
* Field: Quoatation Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZQUOTEREF' .
        APPEND ls_supply TO ct_supply .

* Field: Agreement Type
        CLEAR ls_supply.
        ls_supply-field = 'ZZAGMNT_TYP' .
        APPEND ls_supply TO ct_supply .

* Field: Agreement Id
        CLEAR ls_supply.
        ls_supply-field = 'ZZAGMNT' .
        APPEND ls_supply TO ct_supply .

* Field: Item Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZITEMREF' .
        APPEND ls_supply TO ct_supply .

* Field: Contract start date
        CLEAR ls_supply.
        ls_supply-field = 'ZZVBEGDAT' .
        APPEND ls_supply TO ct_supply .

* Field: Contract end date
        CLEAR ls_supply.
        ls_supply-field = 'ZZVENDDAT' .
        APPEND ls_supply TO ct_supply .

* Field: Agreement acceptance date
        CLEAR ls_supply.
        ls_supply-field = 'ZZVABNDAT' .
        APPEND ls_supply TO ct_supply .

*---> Begin of CR: D2_541
* Field: Billing Method
        CLEAR ls_supply.
        ls_supply-field = 'ZZ_BILMET' .
        APPEND ls_supply TO ct_supply .

* Field: Billing Frequency
        CLEAR ls_supply.
        ls_supply-field = 'ZZ_BILFR' .
        APPEND ls_supply TO ct_supply .
*<--- End of CR: D2_541
*Begin of changes by mthatha for SCTASK0768763
* Field: Created By
        CLEAR ls_supply.
        ls_supply-field = 'ZERNAM' .
        APPEND ls_supply TO ct_supply .
*End of changes by mthatha for SCTASK0768763
      WHEN 'PARTY'.
        CASE iv_module.
          WHEN 'ON_REQUEST_1000'.
* Field: Building
            CLEAR ls_supply.
            ls_supply-field = 'ZZBUILDING' .
            ls_supply-check = 'N'.
            APPEND ls_supply TO ct_supply .

* Field: Floor
            CLEAR ls_supply.
            ls_supply-field = 'ZZFLOOR' .
            ls_supply-check = 'N'.
            APPEND ls_supply TO ct_supply .

* Field: Room Number
            CLEAR ls_supply.
            ls_supply-field = 'ZZROOMNUMBER' .
            ls_supply-check = 'N'.
            APPEND ls_supply TO ct_supply .

* Field: Default Communication
            CLEAR ls_supply.
            ls_supply-field = 'ZZDEFLT_COMM'.
            ls_supply-check = 'N'.
            APPEND ls_supply TO ct_supply .
*--Changes D2_CR_9, CR_20
* Field: Additional House ID
            CLEAR ls_supply.
            ls_supply-field = 'ZZADDHOUSEID'.
            ls_supply-check = 'N'.
            APPEND ls_supply TO ct_supply .

* Field: Street 2
            CLEAR ls_supply.
            ls_supply-field = 'ZZSTR_SUPPL1'.
            ls_supply-check = 'N'.
            APPEND ls_supply TO ct_supply .
*--Changes D2_CR_9, CR_20
          WHEN 'CHANGE_ADDRESS'.
* Field: Building
            CLEAR ls_supply.
            ls_supply-field = 'ZZBUILDING'.
            ls_supply-check = 'I'.
            APPEND ls_supply TO ct_supply.

* Field: Floor
            CLEAR ls_supply.
            ls_supply-field = 'ZZFLOOR'.
            ls_supply-check = 'I'.
            APPEND ls_supply TO ct_supply.

* Field: Room Number
            CLEAR ls_supply.
            ls_supply-field = 'ZZROOMNUMBER'.
            ls_supply-check = 'I'.
            APPEND ls_supply TO ct_supply.

* Field: Default Communication
            CLEAR ls_supply.
            ls_supply-field = 'ZZDEFLT_COMM'.
            ls_supply-check = 'I'.
            APPEND ls_supply TO ct_supply.
*--Changes D2_CR_9, CR_20
* Field: Additional House ID
            CLEAR ls_supply.
            ls_supply-field = 'ZZADDHOUSEID'.
            ls_supply-check = 'I'.
            APPEND ls_supply TO ct_supply.

* Field: Street 2
            CLEAR ls_supply.
            ls_supply-field = 'ZZSTR_SUPPL1'.
            ls_supply-check = 'I'.
            APPEND ls_supply TO ct_supply.
*--Changes D2_CR_9, CR_20

          WHEN OTHERS.
        ENDCASE.
    ENDCASE.
  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


METHOD if_badi_lord_do_pai~fill_supply_list.
***********************************************************************
***********************************************************************
***********************************************************************
*Method     : IF_SLS_APPL_SE_SOERPCRTRC2~INBOUND_PROCESSING           *
*Title      : ES Sales Order Creation                                 *
*Developer  : Jahan Mazumder/Manish Bagda                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0090                                           *
*---------------------------------------------------------------------*
*Description: Create Sales Order in SAP using ESR Service Interface   *
*Create Request Confirmation_In V2                                    *
*Map all custom fields in LORD structure for PAI processing           *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*06-Jun-2014  JAHAN         E2DK900476      INITIAL DEVELOPMENT       *
*01-Oct-2014  JAHAN         E2DK900476      Changes D2_CR_9, CR_20    *
*30-Mar-2015  MBAGDA        E2DK911715      CR: D2_541                *
*14-Feb-2018  BGUNDAB       E1DK934125      Changes for D3 R3         *
*07-Dec-2018  MTHATHA       E1DK939532      SCTASK0768763-Created by  *
*---------------------------------------------------------------------*

*--Local Data declarations
  CONSTANTS :
     lc_null             TYPE z_criteria           VALUE 'NULL',                " Enh. Criteria
     lc_idd_0090_003     TYPE z_enhancement        VALUE 'D2_OTC_IDD_0090_003'. " Enhancement No.

  DATA: li_status        TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table

  DATA : ls_supply TYPE tds_field_supply. " Single PAI Action

*--Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0090_003 "CR: D2_541 changed constant
    TABLES
      tt_enh_status     = li_status.

*--Check for Global user exit activation check
  READ TABLE li_status WITH KEY criteria = lc_null
                                active = abap_true
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.

    CASE iv_object_id.
      WHEN 'HEAD'  .
*Begin of changes by mthatha for SCTASK0768763
*Add Created by ECC Custom Fields in CRM Web UI ERP Order Using Lean Order Framework
        ls_supply-field = 'ZERNAM' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
*End of changes by mthatha for SCTASK0768763

        ls_supply-field = 'ZZDOCREF' .
*Add ECC Custom Fields in CRM Web UI ERP Order Using Lean Order Framework
*ls_supply-module = 'ZZ_SALES_ORDER_OWNER'.
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .

        APPEND ls_supply TO ct_supply .

        ls_supply-field = 'ZZDOCTYP' .
*Add ECC Custom Fields in CRM Web UI ERP Order Using Lean Order Framework
*ls_supply-module = 'ZZ_SALES_ORDER_OWNER'.
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .

        APPEND ls_supply TO ct_supply .

* Field: Case Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZCASEREF' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Your Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZIHREZ' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .

*---> Begin of D3 R3 Changes
* Field: Service Rendered Date
        CLEAR ls_supply.
        ls_supply-field = 'ZFBUDA' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.
*---> End of D3 R3 Changes

      WHEN 'ITEM' .
* Field: Quoatation Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZQUOTEREF' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Agreement Type
        CLEAR ls_supply.
        ls_supply-field = 'ZZAGMNT_TYP' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Agreement Id
        CLEAR ls_supply.
        ls_supply-field = 'ZZAGMNT' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Item Ref
        CLEAR ls_supply.
        ls_supply-field = 'ZZITEMREF' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Contract start date
        CLEAR ls_supply.
        ls_supply-field = 'ZZVBEGDAT' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .

* Field: Contract end date
        CLEAR ls_supply.
        ls_supply-field = 'ZZVENDDAT' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .

* Field: Agreement acceptance date
        CLEAR ls_supply.
        ls_supply-field = 'ZZVABNDAT' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .

*---> Begin of CR: D2_541
* Field: Billing Method
        CLEAR ls_supply.
        ls_supply-field = 'ZZ_BILMET' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Billing Frequency
        CLEAR ls_supply.
        ls_supply-field = 'ZZ_BILFR' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.
*<--- End of CR: D2_541
*Begin of changes by mthatha for SCTASK0768763
*Add Created by ECC Custom Fields in CRM Web UI ERP Order Using Lean Order Framework
        ls_supply-field = 'ZERNAM' .
        ls_supply-program = 'SAPMV45A'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
*End of changes by mthatha for SCTASK0768763
      WHEN 'PARTY'.
* Field: Building
        CLEAR ls_supply.
        ls_supply-field = 'ZZBUILDING' .
        ls_supply-program = 'SAPLV09C'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Room
        CLEAR ls_supply.
        ls_supply-field = 'ZZROOMNUMBER' .
        ls_supply-program = 'SAPLV09C'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Default Comm. Method
        CLEAR ls_supply.
        ls_supply-field = 'ZZDEFLT_COMM' .
        ls_supply-program = 'SAPLV09C'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Floor
        CLEAR ls_supply.
        ls_supply-field = 'ZZFLOOR' .
        ls_supply-program = 'SAPLV09C'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

*--Start of D2_CR_9, 20
* Field: Additional House ID
        CLEAR ls_supply.
        ls_supply-field = 'ZZADDHOUSEID' .
        ls_supply-program = 'SAPLV09C'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.

* Field: Street 2
        CLEAR ls_supply.
        ls_supply-field = 'ZZSTR_SUPPL1'.
        ls_supply-program = 'SAPLV09C'.
        ls_supply-on_check = 'R' .
        APPEND ls_supply TO ct_supply .
* separation for next statement block
* by initial line
        APPEND INITIAL LINE TO ct_supply.
*--End of D2_CR_9, CR_20.

    ENDCASE.
  ENDIF. " IF sy-subrc EQ 0
ENDMETHOD.


method IF_BADI_LORD_DO_PAI~FILL_SUPPLY_LIST_MULTI.
endmethod.
ENDCLASS.
