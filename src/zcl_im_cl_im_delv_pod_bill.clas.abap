class ZCL_IM_CL_IM_DELV_POD_BILL definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_LE_SHP_DELIVERY_PROC .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_CL_IM_DELV_POD_BILL IMPLEMENTATION.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_HEADER.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FCODE_ATTRIBUTES.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHANGE_FIELD_ATTRIBUTES.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~CHECK_ITEM_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_DELETION.
endmethod.


METHOD if_ex_le_shp_delivery_proc~delivery_final_check.
*&---------------------------------------------------------------------*
*& Method  IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK        *
* TITLE      :  GTS Compliance Check in STO                            *
* DEVELOPER  :  Sankritya Saurav                                       *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_EDD_0129                                          *
*----------------------------------------------------------------------*
* DESCRIPTION: Compliance checks need to be performed on all           *
* intercompany STO documents to ensure Bio-Rad does not deal with      *
* non-compliant business partners                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-Jun-2014 Pmishra  E2DK900809 Initial Development GTS Compliance   *
*                                 Check in STO                         *
* 15-Dec-2016 DARUMUG  E1DK921679 CR # 299 Validate delivery type and  *
*                                 Mat. Grp 2 to determine batch split  *
* 22-Mar-2017 DARUMUG  E1DK926413 Defect# 11397 - Delivery not created *
*                                 when MVGR2 has X** setting and batch *
*                                 is manually assigned at Sales Order  *
*                                 / STO                                *
* 10-May-2017 DARUMUG  E1DK927882 INC0338424 - Defect# 2779 -          *
*                                 If delivery has update               *
*                                 flag as 'D' do not process into error*
*                                 message as it completely stop        *
*                                 delivery creation                    *
* 13-Dec-2017 SMUKHER4 E1DK933124 Defect# 4500 - Unable to determine a *
*                                 batch for delivery with reference    *
*                                 order – POD cannot be completed      *
* 19-Jul-2018 SMUKHER4 E1DK937907 Defect# 6733 - Batch Determination   *
*                                 not working for RBCs campaign        *
*&---------------------------------------------------------------------*


  DATA:  lwa_finchdel    TYPE finchdel,                     " Return Codes: Delivery Check, Final check
         li_result       TYPE /sapsll/api6800_result_spi_t, " SLL: Result for API 6800
         lv_gts_dest     TYPE bdbapidst,                    " Partner Number of Receiver
         lv_rfcmsg       TYPE bapi_msg,                     " Rfcmsg of type Character
         lv_log_gts_syst TYPE logsys,                       " Logical system
         lwa_result      TYPE /sapsll/api6800_result_spi_s, " SLL: Result for API 6800
         li_constant     TYPE TABLE OF zdev_enh_status,     " Enhancement Status
         lv_vgtyp        TYPE vbtyp,                        " SD document category
         lv_logsys       TYPE logsys,                       " Logical system
         lwa_gts         TYPE /sapsll/api6800_hdr_ref_r3_s, " SLL: API Comm. Struct.: Customs Docmt: Header: Ref. Data
         lwa_xlips       TYPE lipsvb.                       " Reference structure for XLIPS/YLIPS

  CONSTANTS :
           lc_ind      TYPE flag              VALUE 'A',               " General Flag
           lc_val_e    TYPE flag              VALUE 'E',               " General Flag
           lc_msgno    TYPE symsgno           VALUE '156',             " Message Number
           lc_msgno_a  TYPE symsgno           VALUE '281',             " Message Number
           lc_msgid    TYPE symsgid           VALUE 'ZOTC_MSG',        " Message Class
           lc_objtp    TYPE swo_objtyp        VALUE 'BUS2012',         " Object Type
           lc_qrefno   TYPE /sapsll/btdtc_r3  VALUE 'EXTID',           " Qual Reference Number
           lc_null_129 TYPE z_criteria        VALUE 'NULL',            " Enh. Criteria
           lc_vbtyp    TYPE z_criteria        VALUE 'VBTYP',           " From Value
           lc_trtyp    TYPE trtyp             VALUE 'H',               " Create Mode
           lc_logsys   TYPE z_criteria        VALUE 'LOGSYS',          " Enh. Criteria
           lc_0129     TYPE z_enhancement     VALUE 'D2_OTC_EDD_0129', " Enhancement No.
           lc_refapp   TYPE /sapsll/refapp_r3 VALUE 'MM0A',            " Reference Application of a Doc. fr. Backend System for SLL
           lc_check    TYPE pruefung          VALUE '99',              " Check carried out
           lc_upd_del  TYPE c                 VALUE 'D'.               " Upd_del of type Character


**//-->>Begin of changes D3
  DATA:
    li_lips            TYPE shp_lips_t,
    li_status          TYPE STANDARD TABLE OF  zdev_enh_status. "Internal table for Enhancement Status

  CONSTANTS :
    lc_edd_0360 TYPE z_enhancement VALUE 'OTC_EDD_0360', " Enhancement No.
    lc_mvgr2    TYPE char10 VALUE 'MVGR2',               " Material Group 2
    lc_lfart    TYPE char10 VALUE 'LFART'.               " Lfart of type CHAR10

  FIELD-SYMBOLS:
    <lfs_xlikp>  TYPE likpvb,           " Reference structure for XLIKP/YLIKP
    <lfs_status> TYPE  zdev_enh_status. "For Reading enhancement table
**//-->>End of changes D3

  FIELD-SYMBOLS: <lfs_xlips> TYPE lipsvb,             " Reference structure for XLIPS/YLIPS
                 <lfs_xlips1> TYPE lipsvb,            " Reference structure for XLIPS/YLIPS
                 <lfs_constant> TYPE zdev_enh_status. " Enhancement Status

* Setting all the constant values.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_0129
    TABLES
      tt_enh_status     = li_constant.

  DELETE li_constant WHERE active IS INITIAL.
  READ TABLE li_constant WITH KEY criteria = lc_null_129
                                  TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    LOOP AT li_constant ASSIGNING <lfs_constant>.
      IF <lfs_constant>-criteria EQ lc_vbtyp
         AND <lfs_constant>-active EQ abap_true.
        lv_vgtyp = <lfs_constant>-sel_low.
      ENDIF. " if <lfs_constant>-criteria eq lc_vbtyp
      IF <lfs_constant>-criteria EQ lc_logsys
         AND <lfs_constant>-active EQ abap_true.
        lv_logsys = <lfs_constant>-sel_low.
      ENDIF. " if <lfs_constant>-criteria eq lc_logsys
    ENDLOOP. " loop at li_constant assigning <lfs_constant>
* For each line item the following piece of code will trigger in runtime and at any condition
* it_xlips will not contain more than 1 entries. Hence doing a read with index 1.
    READ TABLE it_xlips ASSIGNING <lfs_xlips> INDEX 1.
    IF sy-subrc IS INITIAL.
      IF <lfs_xlips>-vgtyp EQ lv_vgtyp. "  Consider Only when it is PO based Delivery
        IF if_trtyp = lc_trtyp. "  Consider Only if the Transaction type 'H'
*&&&* Call RFC to Get PO document Block Status
* * * Determine RFC destination for GTS system
* Build Business System ID for ECC
*     Retrive the receiver system logical name
          SELECT SINGLE logsys     " Logical system
                        FROM tbdls " Logical system
                        INTO lv_log_gts_syst
                        WHERE logsys = lv_logsys.
          IF sy-subrc IS INITIAL.
*       Retrieve the RFC destination for Logical system
            SELECT SINGLE rfcdest         " Standard RFC destination for synchronous BAPI calls
                          INTO lv_gts_dest
                          FROM tblsysdest " RFC Destination of Logical System
                          WHERE logsys = lv_log_gts_syst.
            IF sy-subrc IS INITIAL.
              CONDENSE lv_gts_dest.
              CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
                IMPORTING
                  own_logical_system             = lwa_gts-org_logsystem
                EXCEPTIONS
                  own_logical_system_not_defined = 1
                  OTHERS                         = 1.
* All the exception needs to be handled in the same way
              IF sy-subrc IS INITIAL.
                lwa_gts-qual_refno = lc_qrefno.
                lwa_gts-refno      = <lfs_xlips>-vgbel.
                lwa_gts-refapp     = lc_refapp.
                lwa_gts-objtp      = lc_objtp.
*&-- Validate PO number from GTS system with RFC Call
                CALL FUNCTION '/SAPSLL/API_6800_STATUS_GET'
                  DESTINATION lv_gts_dest
                  EXPORTING
                    hdr_reference_data    = lwa_gts
                    langu_iso             = sy-langu
                  TABLES
                    result_legal_control  = li_result
                  EXCEPTIONS
                    system_failure        = 1  MESSAGE lv_rfcmsg
                    communication_failure = 2  MESSAGE lv_rfcmsg
                    OTHERS                = 3.
                IF  sy-subrc IS INITIAL
                AND li_result IS NOT INITIAL.
                  DELETE li_result WHERE document_number IS INITIAL.
*               Retrieve the return table for Compliance Management
*               Check Results for GTS to be Type A
                  READ TABLE li_result INTO lwa_result INDEX 1.
                  IF sy-subrc EQ 0
*                 Populate Return Codes: Delivery Check, Final check structure
*                 with custom error message
                    AND lwa_result-check_ind NE lc_ind.
                    lwa_finchdel-vbeln    = <lfs_xlips>-vbeln. "Delivery Number
                    lwa_finchdel-pruefung = lc_check. " Customer-Defined Check
                    lwa_finchdel-msgty    = lc_val_e. " Customer-Defined Check
                    lwa_finchdel-msgno    = lc_msgno. " Customer-Defined Check
                    lwa_finchdel-msgid    = lc_msgid. " Proxy Messages for Delivery Services
                    lwa_finchdel-msgv1    = <lfs_xlips>-vgbel. " PO Number
                    INSERT lwa_finchdel INTO TABLE ct_finchdel.
                  ENDIF. " if sy-subrc eq 0
                ELSE. " ELSE -> if sy-subrc is initial
                  MESSAGE i000(zotc_msg) WITH lv_rfcmsg. " & & & &
                ENDIF. " if sy-subrc is initial
              ELSE. " ELSE -> if sy-subrc is initial
                MESSAGE i043(zotc_msg). " Own logical system not defined
              ENDIF. " if sy-subrc is initial
            ENDIF. " if sy-subrc is initial
          ENDIF. " if sy-subrc is initial
        ENDIF. " if if_trtyp = lc_trtyp
      ENDIF. " if <lfs_xlips>-vgtyp eq lv_vgtyp
    ENDIF. " if sy-subrc is initial
  ENDIF. " if sy-subrc eq 0

**//-->>Begin of changes - DARUMUG - CR# 299
* Get EMI table entries
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0360
    TABLES
      tt_enh_status     = li_status.

  DELETE li_status WHERE active IS INITIAL.

*&--->Begin of delete for D3_OTC_EDD_0360 Defect# 6733 by SMUKHER4 on 19-Jul-2018
*&--lc_edd_0360 is not the criteria, we should put a null check here
*  READ TABLE li_status WITH KEY criteria = lc_edd_0360
*&<---End of delete for D3_OTC_EDD_0360 Defect# 6733 by SMUKHER4 on 19-Jul-2018
*&--->Begin of changes for D3_OTC_EDD_0360 Defect# 6733 by SMUKHER4 on 19-Jul-2018
  READ TABLE li_status WITH KEY criteria = lc_null_129
*&<---End of changes for D3_OTC_EDD_0360 Defect# 6733 by SMUKHER4 on 19-Jul-2018
                                  TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.
    li_lips = it_xlips.

    SORT li_lips BY uecha.
    READ TABLE it_xlikp ASSIGNING <lfs_xlikp> INDEX 1.
    CHECK sy-subrc EQ 0.
* Read status table for criteria LFART and active = X
    READ TABLE li_status ASSIGNING <lfs_status>
                               WITH KEY criteria = lc_lfart
                                        sel_low  = <lfs_xlikp>-lfart
                                        active   = abap_true.
    IF sy-subrc NE 0.
      SORT li_lips BY vgbel vgpos posnr. "Defect# 11397
                                                "If delivery has update flag as 'D' do not process into error
                                                "message as it completely stop delivery creation
      LOOP AT li_lips ASSIGNING <lfs_xlips>
                      WHERE charg EQ space      "Defect# 11397
                      AND   updkz NE lc_upd_del "INC0338424 - Defect# 2779
*&--->Begin of changes for D3_OTC_EDD_0360 Defect# 4500 by SMUKHER4 on 13-Dec-2017
                      AND   lfimg IS NOT INITIAL.
*&<---End of changes for D3_OTC_EDD_0360 Defect# 4500 by SMUKHER4 on 13-Dec-2017
*   Read status table for criteria MVGR2 and active = X
        READ TABLE li_status ASSIGNING <lfs_status>
                                   WITH KEY criteria = lc_mvgr2
                                            sel_low  = <lfs_xlips>-mvgr2
                                            active   = abap_true.
        IF sy-subrc EQ 0.
**//-->>Begin of Changes - Defect# 11397
 " If UECHA does not exist for an existing VGPOS then it means
 " no batch split has been created and then CT_FINCHDEL has to be filled.
          READ TABLE li_lips INTO lwa_xlips WITH KEY vgbel = <lfs_xlips>-vgbel
                                                     vgpos = <lfs_xlips>-vgpos
                                                     uecha = <lfs_xlips>-posnr.
          IF sy-subrc EQ 0 AND
             lwa_xlips-charg NE space.
          ELSE. " ELSE -> if sy-subrc eq 0 and
            lwa_finchdel-vbeln    = <lfs_xlips>-vbeln. "Delivery Number
            lwa_finchdel-pruefung = lc_check. " Customer-Defined Check
            lwa_finchdel-msgty    = lc_val_e. " Customer-Defined Check
            lwa_finchdel-msgno    = lc_msgno_a. " Customer-Defined Check
            lwa_finchdel-msgid    = lc_msgid. " Proxy Messages for Delivery Services
            lwa_finchdel-msgv1    = <lfs_xlips>-vgbel. "SO
            lwa_finchdel-msgv2    = <lfs_xlips>-vgpos. "SO Item
            INSERT lwa_finchdel INTO TABLE ct_finchdel.
          ENDIF. " if sy-subrc eq 0 and
**          " If UECHA does not exist for an existing VGPOS then it means
**          " no batch split has been created and then CT_FINCHDEL has to be filled.
**          read table li_lips assigning <lfs_xlips1>
**                             with key uecha = <lfs_xlips>-vgpos
**                             binary search.
**          if sy-subrc ne 0.
**            lwa_finchdel-vbeln    = <lfs_xlips>-vbeln. "Delivery Number
**            lwa_finchdel-pruefung = lc_check. " Customer-Defined Check
**            lwa_finchdel-msgty    = lc_val_e. " Customer-Defined Check
**            lwa_finchdel-msgno    = lc_msgno_a. " Customer-Defined Check
**            lwa_finchdel-msgid    = lc_msgid. " Proxy Messages for Delivery Services
**            lwa_finchdel-msgv1    = <lfs_xlips>-vgbel.
**            insert lwa_finchdel into table ct_finchdel.
**            exit.
**          endif.
**//-->>End of Changes - Defect# 11397

        ENDIF. " if sy-subrc eq 0
      ENDLOOP. " loop at li_lips assigning <lfs_xlips>
    ENDIF. " if sy-subrc ne 0
  ENDIF. " if sy-subrc eq 0
**//-->>End of changes - DARUMUG - CR# 299
ENDMETHOD. "IF_EX_LE_SHP_DELIVERY_PROC~DELIVERY_FINAL_CHECK


method IF_EX_LE_SHP_DELIVERY_PROC~DOCUMENT_NUMBER_PUBLISH.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_HEADER.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~FILL_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~INITIALIZE_DELIVERY.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~ITEM_DELETION.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~PUBLISH_DELIVERY_ITEM.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~READ_DELIVERY.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_BEFORE_OUTPUT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_AND_PUBLISH_DOCUMENT.
endmethod.


method IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE.
endmethod.
ENDCLASS.
