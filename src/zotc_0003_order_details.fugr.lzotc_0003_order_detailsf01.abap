*----------------------------------------------------------------------*
***INCLUDE LZOTC_0003_ORDER_DETAILSF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_ADDRESS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_VBPA_ADRNR  text
*      <--P_EX_HEADER_DATA_SHIP_TO_ADDR  text
*----------------------------------------------------------------------*
FORM f_get_address  USING    fp_adrnr      TYPE  ad_addrnum
                    CHANGING fp_i_addr     TYPE  zotc_address_t.

* Get Address Data
  CALL FUNCTION 'ADDRESS_INTO_PRINTFORM'
    EXPORTING
      address_type                   = '1'
      address_number                 = fp_adrnr
      receiver_language              = sy-langu
    IMPORTING
      address_printform_table        = fp_i_addr
    EXCEPTIONS
      address_blocked                = 1
      person_blocked                 = 2
      contact_person_blocked         = 3
      addr_to_be_formated_is_blocked = 4
      OTHERS                         = 5.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0237   text
*      -->P_LV_VBELN  text
*      <--P_LI_LINES  text
*----------------------------------------------------------------------*
FORM f_read_text  USING    fp_id      TYPE tdid
                           fp_vbeln   TYPE vbeln
                  CHANGING fp_i_lines TYPE text_lines.

  CONSTANTS:
             lc_object TYPE tdobject VALUE 'VBBK'. " Order text
  DATA: lv_name  TYPE tdobname.


  CLEAR fp_i_lines.
  lv_name = fp_vbeln.
* Get Text
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = fp_id
      language                = sy-langu
      name                    = lv_name
      object                  = lc_object
    TABLES
      lines                   = fp_i_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc = 0.
    DELETE fp_i_lines WHERE tdline IS INITIAL.
  ENDIF.
ENDFORM.
