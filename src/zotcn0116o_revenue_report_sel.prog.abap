*&---------------------------------------------------------------------*
*&  Include           ZOTCN0116O_REVENUE_REPORT_SEL
*&---------------------------------------------------------------------*
************************************************************************
* Include       ZOTCN0116O_REVENUE_REPORT_SEL                         *
* TITLE      :  End to End Revenue Report                              *
* DEVELOPER  :  RAGHAV SUREDDI                                         *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0116_REVENUE_REPORT                              *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Revenue   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the Revenue.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Nov-2017 U033876   E1DK934630 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 10-May-2018 U100018   E1DK934630 Defect# 6027: Fix performance issue *
*&---------------------------------------------------------------------*

INITIALIZATION.
* Get emi entires
  PERFORM f_get_emi.
  CLEAR: wa_enh_status.
  SORT  i_enh_status BY criteria.

  READ TABLE i_enh_status INTO wa_enh_status
                  WITH KEY  criteria = c_null BINARY SEARCH.
  IF sy-subrc NE 0.
* Raise an error message
    MESSAGE e305.
  ENDIF. " IF sy-subrc NE 0

  READ TABLE i_enh_status INTO wa_enh_status
                  WITH KEY  criteria = c_days BINARY SEARCH.
  IF sy-subrc = 0.
    gv_days = wa_enh_status-sel_low.
  ENDIF. " IF sy-subrc = 0
  CLEAR: wa_enh_status.
  READ TABLE i_enh_status INTO wa_enh_status
                  WITH KEY  criteria = c_kschl BINARY SEARCH.
  IF sy-subrc = 0.
    gv_kschl = wa_enh_status-sel_low.
  ENDIF. " IF sy-subrc = 0

*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
  PERFORM f_get_fpath CHANGING p_path.

*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018

AT SELECTION-SCREEN.

  IF s_podat[] IS INITIAL AND s_wadat[] IS INITIAL.
    MESSAGE e301.
  ENDIF. " IF s_podat[] IS INITIAL AND s_wadat[] IS INITIAL

  IF s_wadat-high IS NOT INITIAL AND ( s_wadat-high - s_wadat-low > gv_days ) .
    MESSAGE e302 WITH gv_days.
  ENDIF. " IF s_wadat-high IS NOT INITIAL AND ( s_wadat-high - s_wadat-low > gv_days )

  IF s_podat-high IS NOT INITIAL AND ( s_podat-high - s_podat-low > gv_days ) .
    MESSAGE e302 WITH gv_days.
  ENDIF. " IF s_podat-high IS NOT INITIAL AND ( s_podat-high - s_podat-low > gv_days )


AT SELECTION-SCREEN ON s_vkorg.
* Validating Sales Organization
  PERFORM f_validate_vkorg.

AT SELECTION-SCREEN ON s_vtweg.
* Validating the Distribution Channel
  IF s_vtweg[] IS NOT INITIAL.
    PERFORM f_validate_vtweg.
  ENDIF. " IF s_vtweg[] IS NOT INITIAL

* Validating Delivery Number
AT SELECTION-SCREEN ON s_vbelvl.
* Validating Delivery Number
  IF  s_vbelvl[] IS NOT INITIAL.
    PERFORM f_validate_deliv.
  ENDIF. " IF s_vbelvl[] IS NOT INITIAL

AT SELECTION-SCREEN ON s_lfart.
  IF s_lfart[] IS NOT INITIAL.
    PERFORM f_validate_lfart.
  ENDIF. " IF s_lfart[] IS NOT INITIAL

* Validating Plant
AT SELECTION-SCREEN ON s_werks.
* Validating Plant
  IF s_werks[] IS NOT INITIAL.
    PERFORM f_validate_werks.
  ENDIF. " IF s_werks[] IS NOT INITIAL


* Validating Sold-to-party
AT SELECTION-SCREEN ON s_kunnr.
  IF s_kunnr[] IS NOT INITIAL.
* Validating Sold-to-party
    PERFORM f_validate_kunnr.
  ENDIF. " IF s_kunnr[] IS NOT INITIAL

* Validating Ship-to-party
AT SELECTION-SCREEN ON s_kunag.
  IF s_kunag[] IS NOT INITIAL.
* Validating Ship-to-party
    PERFORM f_validate_kunag.
  ENDIF. " IF s_kunag[] IS NOT INITIAL
*--> Begin of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name = 'P_PATH'.
 " Make AL11 file path non-editable
      screen-input = 0.
    ENDIF. " IF screen-name = 'P_PATH'
    MODIFY SCREEN.
  ENDLOOP. " LOOP AT SCREEN
*<-- End of insert for D3_OTC_RDD_0116_Defect# 6027 by U100018 on 10-May-2018
