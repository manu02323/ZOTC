FUNCTION zotc_0212_insert_char_value.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_BOM_DATA) TYPE  ZOTC_BOM_CREATE_TBL
*"----------------------------------------------------------------------
************************************************************************
* FUNCTION MODULE  :  ZOTC_0212_INSERT_CHAR_VALUE                      *
* TITLE            :  Insert Characterisctic value in custom table     *
* DEVELOPER        :  NEHA KUMARI                                      *
* OBJECT TYPE      :  ENHANCEMENT                                      *
* SAP RELEASE      :  SAP ECC 6.0                                      *
*----------------------------------------------------------------------*
*  WRICEF ID       :  D2_OTC_EDD_0212                                  *
*----------------------------------------------------------------------*
* DESCRIPTION      :  Insert material char value into custom table     *
*                     ZOTC_BOM_CREATE                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT   DESCRIPTION                        *
* ===========  ======== ==========  ===================================*
* 11-OCT-2014  NKUMARI  E2DK904869  INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*


TRY .
*&-- Check the input parameter
  IF NOT im_bom_data IS INITIAL.
**& Modify custom table 'ZOTC_BOM_CREATE' with characteristic value
    INSERT zotc_bom_create FROM TABLE im_bom_data.
  ENDIF. " IF NOT im_bom_data IS INITIAL

CATCH cx_root.

ENDTRY.

ENDFUNCTION.
