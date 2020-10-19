*----------------------------------------------------------------------*
***INCLUDE LZOTC_COMMUNICATIONF01 .
*----------------------------------------------------------------------*
************************************************************************
* INCLUDE        : LZOTC_COMMUNICATIONF01                              *
* TITLE          : External Communication for Mail/Fax/Print           *
* DEVELOPER      : Vivek Gaur                                          *
* OBJECT TYPE    : Include Program                                     *
* SAP RELEASE    : SAP ECC 6.0                                         *
*----------------------------------------------------------------------*
* WRICEF ID      : OTC_FDD_0013_Monthly Open AR Statement              *
*----------------------------------------------------------------------*
* DESCRIPTION    : Include for Global Subroutines                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* Date         User      Transport  Description                        *
* ===========  ========  ========== ===================================*
* 14-MAY-2012  VGAUR     E1DK901190 Initial development                *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_XSTRING_TO_SOLIX
*&---------------------------------------------------------------------*
*       Convert String to Hexadecimal
*----------------------------------------------------------------------*
*      -->FP_LX_FORMOUT_PDF  Form String
*      -->FP_PDF_CONTENT     SAPoffice: Binary data
*----------------------------------------------------------------------*
FORM f_xstring_to_solix USING fp_lx_formout_pdf TYPE xstring
                              fp_pdf_content    TYPE solix_tab.

  DATA:
    lv_offset          TYPE i,         "Offset
    li_solix           TYPE solix_tab, "SAPoffice: Binary data
    lwa_solix_line     TYPE solix,     "SAPoffice: Binary data
    lv_pdf_string_len  TYPE i,         "PDF String Length
    lv_solix_rows      TYPE i,         "Binary data rows
    lv_last_row_length TYPE i,         "Binary data last row length
    lv_row_length      TYPE i.         "Binary data row length

  CLEAR fp_pdf_content.

*&--Transform xstring to SOLIX
  DESCRIBE TABLE li_solix.
  lv_row_length = sy-tleng.
  lv_offset = 0.

*&--Get PDF form string length
  lv_pdf_string_len = xstrlen( fp_lx_formout_pdf ).

  lv_solix_rows = lv_pdf_string_len DIV lv_row_length.
  lv_last_row_length = lv_pdf_string_len MOD lv_row_length.
  DO lv_solix_rows TIMES.
    lwa_solix_line-line =
           fp_lx_formout_pdf+lv_offset(lv_row_length).
    APPEND lwa_solix_line TO fp_pdf_content.
    ADD lv_row_length TO lv_offset.
  ENDDO.
  IF lv_last_row_length > 0.
    CLEAR lwa_solix_line-line.
    lwa_solix_line-line = fp_lx_formout_pdf+lv_offset(lv_last_row_length).
    APPEND lwa_solix_line TO fp_pdf_content.
  ENDIF.

ENDFORM.                    " F_XSTRING_TO_SOLIX
