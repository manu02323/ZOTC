class ZCL_IM_OTC_FDD_0067_DOWN_PAY definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_BADI_SD_BIL_PRINT01 .
protected section.
private section.

  class-data ATTRV_FORM_FLIP type FLAG .
ENDCLASS.



CLASS ZCL_IM_OTC_FDD_0067_DOWN_PAY IMPLEMENTATION.


method IF_BADI_SD_BIL_PRINT01~GET_HEAD_DETAILS.
endmethod.


method IF_BADI_SD_BIL_PRINT01~GET_ITEM_DETAILS.
endmethod.


METHOD if_badi_sd_bil_print01~initialize_data.
***********************************************************************
*Program    : INITIALIZE_DATA (BAdI Method)                           *
*Title      : Customer DownPayment                                    *
*Developer  : Dhananjoy Moirangthem/Shelly Goel                       *
*Object type: Forms                                                   *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_FDD_0067                                           *
*---------------------------------------------------------------------*
*Description: Same output type will be used but for D3 the layout is  *
* different. So, this BAdI Implemetation is used to flip the Adobe    *
*form based on Sales Org entry in the EMI.                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*11-OCT-2016  DMOIRAN/U034336  E1DK921459    Initial Development
*---------------------------------------------------------------------*
*{   INSERT         E2DK923990                                        5
*23-May-2019   U105235      E2DK923986       Defect#9572 Proforma Inv *
*                                            changes                  *
*---------------------------------------------------------------------*
*}   INSERT

  DATA: li_enh_status   TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
        lv_vkorg        TYPE vkorg.                             " Sales Organization
*{   INSERT         E2DK923990                                        4
*<---Begin of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
  DATA :lwa_enh TYPE  zdev_enh_status.
*<---End of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
*}   INSERT

  FIELD-SYMBOLS:
        <lfs_tnapr>   TYPE any,
        <lfs_sform>   TYPE any,
        <lfs_sform2>  TYPE any,
        <lfs_nast>    TYPE any,
        <lfs_objky>   TYPE any.

  CONSTANTS:
     lc_enhancement     TYPE z_enhancement    VALUE 'D2_OTC_FDD_0067',           " Enhancement no.
     lc_null            TYPE z_criteria       VALUE 'NULL',                      " Null
     lc_vkorg           TYPE z_criteria       VALUE 'VKORG_FORMAT',              " Enh. Criteria
     lc_prog_nast       TYPE fieldname        VALUE '(SD_INVOICE_PRINT01)NAST',  " Field Name
*{   INSERT         E2DK923990                                        3
*<---Begin of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
     lc_form            TYPE z_criteria       VALUE 'FORM',                      "Form
*<---End of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
*}   INSERT
     lc_prog_tnapr       TYPE fieldname       VALUE '(SD_INVOICE_PRINT01)TNAPR'. " Field Name


  CLEAR attrv_form_flip.

* Get EMI data
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_enh_status.

  IF li_enh_status IS NOT INITIAL.



* Deleting all the non active records.
    DELETE li_enh_status WHERE active <> abap_true.

    SORT li_enh_status BY criteria sel_low.
*{   INSERT         E2DK923990                                        1
*<---Begin of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019

   CLEAR lwa_enh.
   READ TABLE li_enh_status INTO lwa_enh
                   WITH KEY criteria = lc_form.
    IF sy-subrc ne 0.
     clear lwa_enh.
    ENDIF.
*<---End of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
*}   INSERT

* check if EMI is active.
    READ TABLE li_enh_status
                   WITH KEY criteria = lc_null
                   TRANSPORTING NO FIELDS
                   BINARY SEARCH.

    IF sy-subrc IS INITIAL.

* Get the billing doc and output type from NAST
      ASSIGN (lc_prog_nast) TO <lfs_nast>.

      IF <lfs_nast> IS ASSIGNED.

        ASSIGN COMPONENT 'OBJKY' OF STRUCTURE <lfs_nast> TO <lfs_objky>.
        IF <lfs_objky> IS ASSIGNED .

          SELECT SINGLE vkorg " Sales Document
                    FROM vbrk " Billing Document: Item Data
                    INTO lv_vkorg
                    WHERE vbeln = <lfs_objky>.

          IF sy-subrc EQ 0.

            READ TABLE li_enh_status WITH KEY criteria = lc_vkorg
                                              sel_low  = lv_vkorg
                                              BINARY SEARCH
                                     TRANSPORTING NO FIELDS.
            IF sy-subrc EQ 0.

* Check if output type is matching.

* Get the form name as per config in NACE

              ASSIGN (lc_prog_tnapr) TO <lfs_tnapr>.
              IF <lfs_tnapr> IS ASSIGNED.

                ASSIGN COMPONENT 'SFORM' OF STRUCTURE <lfs_tnapr> TO <lfs_sform>.
                IF <lfs_sform> IS ASSIGNED.
                  ASSIGN COMPONENT 'SFORM2' OF STRUCTURE <lfs_tnapr> TO <lfs_sform2>.
                  IF <lfs_sform2> IS ASSIGNED.
                    IF <lfs_sform2> IS NOT INITIAL.
                      <lfs_sform> = <lfs_sform2> .
*{   REPLACE        E2DK923990                                        2
*\                      attrv_form_flip = abap_true.
*<---Begin of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
                    if <lfs_sform> = lwa_enh-sel_low.
                      attrv_form_flip = abap_true.
                    endif.
*<---End of Insert for D3_OTC_FDD_0088 Defect# 9572 8000020217 by U105235 on 22-May-2019
*}   REPLACE
                    ENDIF. " IF <lfs_sform2> IS NOT INITIAL

                  ENDIF. " IF <lfs_sform2> IS ASSIGNED
                ENDIF. " IF <lfs_sform> IS ASSIGNED
              ENDIF. " IF <lfs_tnapr> IS ASSIGNED
            ENDIF. " IF sy-subrc EQ 0
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF <lfs_objky> IS ASSIGNED
      ENDIF. " IF <lfs_nast> IS ASSIGNED
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_enh_status IS NOT INITIAL
ENDMETHOD.


method IF_BADI_SD_BIL_PRINT01~PREPARE_HEAD_PRICES.
endmethod.


method IF_BADI_SD_BIL_PRINT01~PREPARE_ITEM_PRICES.
endmethod.


METHOD if_badi_sd_bil_print01~print_data.
***********************************************************************
*Program    : PRINT_DATA (BAdI Method)                                *
*Title      : Customer DownPayment                                    *
*Developer  : Dhananjoy Moirangthem/Shelly Goel                       *
*Object type: Forms                                                   *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_FDD_0067                                           *
*---------------------------------------------------------------------*
*Description: Same output type will be used but for D3 the layout is  *
* different. So, this BAdI Implemetation is used to flip the Adobe    *
*form based on Sales Org entry in the EMI. After BADI has been called *
*this method will call the adobe form here                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*16-OCT-2016 DMOIRAN/U034336  E1DK921459    Initial Development
**--------------------------------------------------------------------*

  IF attrv_form_flip IS INITIAL.
    CALL FUNCTION iv_fm_name
      EXPORTING
        /1bcdwb/docparams  = is_docparams
        bil_prt_com        = is_interface
      IMPORTING
        /1bcdwb/formoutput = es_formoutput
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
  ELSE. " ELSE -> if ATTRV_FORM_FLIP is INITIAL
    CALL FUNCTION iv_fm_name
      EXPORTING
        /1bcdwb/docparams  = is_docparams
        im_bil_prt_com     = is_interface
        im_nast            = is_nast
      IMPORTING
        /1bcdwb/formoutput = es_formoutput
      EXCEPTIONS
        usage_error        = 1
        system_error       = 2
        internal_error     = 3
        OTHERS             = 4.
  ENDIF. " if ATTRV_FORM_FLIP is INITIAL

  IF sy-subrc NE 0.
    RAISE error.
  ENDIF. " IF sy-subrc NE 0

ENDMETHOD.
ENDCLASS.
