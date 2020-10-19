FUNCTION zotc_0070_revrecog_00503111 .
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FIS_ACCHD) TYPE  ACCHD OPTIONAL
*"     VALUE(FIS_ACCCR) TYPE  ACCCR OPTIONAL
*"     VALUE(FIS_ACCIT) TYPE  ACCIT OPTIONAL
*"     VALUE(FIS_VBREVE) TYPE  VBREVEVB OPTIONAL
*"  CHANGING
*"     VALUE(FBF_BUDAT) TYPE  ACCIT-BUDAT OPTIONAL
*"     VALUE(FBF_BLART) TYPE  ACCIT-BLART OPTIONAL
*"     VALUE(FBF_ERDAT) TYPE  VBREVE-ERDAT OPTIONAL
*"     VALUE(FBF_ERZET) TYPE  VBREVE-ERZET OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& FM  ZOTC_0070_REVRECOG_00503111
*&---------------------------------------------------------------------*
************************************************************************
* Enhancement:  ZOTC_0070_REVRECOG_00503111                            *
* TITLE      :  OTC_EDD_0070_ECC Update the Revenue reorganization     *
* DEVELOPER  :  ANILKUMAR G                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :    OTC_EDD_0070                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Update the Revenue reorganization                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 21-JUN-2012  AGOPU   E1DK902448  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 02-JUL-2014  PMISHRA E2DK902149  D2_OTC_EDD_0070
*                                  Include check for billing documents *
*&---------------------------------------------------------------------*

* Note : The naming convention can not be followed as the parameter names
* should same as the standard FM, name is also as per oss note:0000423799.
  DATA : lv_vkorg TYPE vkorg, " Sales Organization
         lv_vtweg TYPE vtweg, " Distribution Channel
         lv_blart TYPE blart. " Document Type
  CONSTANTS : lc_blart TYPE char5 VALUE 'BLART', " Blart of type CHAR5
              lc_eq    TYPE char2 VALUE 'EQ'.    " Eq of type CHAR2




*Select sales org and dist channel for the order document
  SELECT SINGLE vkorg vtweg
               FROM vbak " Sales Document: Header Data
               INTO (lv_vkorg, lv_vtweg)
              WHERE vbeln = fis_vbreve-vbeln.

*  IF sy-subrc is initial.       comment for D2_OTC_EDD_0070 by PMISHRA


*--> Begin of insert for D2_OTC_EDD_0070 by PMISHRA

  IF sy-subrc IS NOT INITIAL.
*If not found, select sales org and dist channel for the billing document
    SELECT SINGLE vkorg " Sales Organization
                  vtweg " Distribution Channel
      FROM vbrk         " Billing Document: Header Data
      INTO (lv_vkorg, lv_vtweg)
      WHERE  vbeln = fis_vbreve-vbeln.
    IF sy-subrc IS NOT INITIAL .
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF sy-subrc IS NOT INITIAL

*<-- End of insert for D2_OTC_EDD_0070 by PMISHRA


*  If present, get the doc type value from control table
  IF lv_vkorg IS NOT INITIAL
              AND lv_vtweg IS NOT INITIAL .

    SELECT mvalue1         " Select Options: Value Low
          INTO lv_blart
          FROM zotc_prc_control " OTC Process Team Control Table
          UP TO 1 ROWS
          WHERE vkorg      = lv_vkorg
          AND vtweg      = lv_vtweg
          AND mprogram   = sy-cprog
          AND mparameter = lc_blart
          AND mactive    = abap_true
          AND soption    = lc_eq.
    ENDSELECT .
*If entry found and doc type is not blank
    IF sy-subrc IS INITIAL
                AND lv_blart IS NOT INITIAL.
*Then only the document type will be changed to 'RR' or the specified
*entry in control table.
      fbf_blart = lv_blart.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF lv_vkorg IS NOT INITIAL

*  Endif.     comment for D2_OTC_EDD_0070 by PMISHRA



ENDFUNCTION.
