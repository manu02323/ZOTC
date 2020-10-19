FUNCTION zotc_interface_vkoa0100.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IDOC_DATA STRUCTURE  EDIDD
*"  CHANGING
*"     REFERENCE(IDOC_HEADER) TYPE  EDIDC
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_INTERFACE_VKOA0100 (FM)                           *
* TITLE      :  FM for BTE - VKOA0100                                  *
* DEVELOPER  :  Manish Bagda/Vinita Choudhary                          *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_IDD_0093                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: This FM avoids creation of segments in idoc
*              with future valid from dates.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 24-Nov-2015  MBAGDA    E2DK915852 Initial Development                *
*&---------------------------------------------------------------------*

* Types Declaration

* Local Constant Declaration
  CONSTANTS:
       lc_zotc_cond_a  TYPE edi_mestyp VALUE 'ZOTC_COND_A',              " Message Type
       lc_e1konh       TYPE edilsegtyp VALUE 'E1KONH',                   " Segment type
       lc_enhancement_no TYPE z_enhancement VALUE 'D2_OTC_IDD_0093_003'. " Enhancement No.


* Local Data Declaration
  DATA:
       lwa_e1konh      TYPE e1konh,                  " Filter segment with separated condition key
        li_enh_status TYPE TABLE OF zdev_enh_status. " Enhancement Status
  DATA : lv_flg TYPE char1. " Flg of type CHAR1

* Local Field Symbol Declaration
  DATA : li_idoc_data TYPE TABLE OF edidd. " Data record (IDoc)
  FIELD-SYMBOLS:
       <lfs_edidd>     TYPE edidd. " Data record (IDoc)

* FM for EMI status check.
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = li_enh_status.

  READ TABLE li_enh_status WITH KEY criteria = 'NULL'
                                    active = abap_true
                                    TRANSPORTING NO FIELDS.
  IF sy-subrc IS INITIAL.
    IF idoc_header-mestyp = lc_zotc_cond_a. "   Message type- ZOTC_COND_A
      CLEAR lv_flg.

      LOOP AT idoc_data ASSIGNING <lfs_edidd>.
* lv_flg is set for the sub record. When the record is of future start date
*         is deleted, sub record should also be deleted.
        IF lv_flg = abap_true.
          CLEAR lv_flg.
          CONTINUE.
        ELSE. " ELSE -> IF lv_flg = abap_true
          CASE <lfs_edidd>-segnam.
            WHEN lc_e1konh.
              CLEAR lwa_e1konh.
              lwa_e1konh = <lfs_edidd>-sdata.

* Check, if there is any record with Future Valid From Date-DATAB
              IF lwa_e1konh-datab > sy-datum.
* for record with future valid date, idoc should not be created.
                lv_flg = abap_true.
                CONTINUE.
              ELSE. " ELSE -> IF lwa_e1konh-datab > sy-datum
                APPEND <lfs_edidd> TO li_idoc_data.
                CLEAR lv_flg.
              ENDIF. " IF lwa_e1konh-datab > sy-datum
            WHEN OTHERS.
              APPEND <lfs_edidd> TO li_idoc_data.
              CLEAR lv_flg.
          ENDCASE.
        ENDIF. " IF lv_flg = abap_true

      ENDLOOP. " LOOP AT idoc_data ASSIGNING <lfs_edidd>

*  Replacing records in idoc_data, with the records only with current valid date.
      IF li_idoc_data IS NOT INITIAL.
        REFRESH idoc_data.
        idoc_data[] = li_idoc_data[].
        REFRESH li_idoc_data.
      ENDIF. " IF li_idoc_data IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL
ENDFUNCTION.
