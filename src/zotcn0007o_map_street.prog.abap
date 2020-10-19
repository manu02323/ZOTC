*Title      : Convert Open Sales Orders_va01                           *
*Developer  : Suparna Paul                                             *
*Object type: Conversion                                               *
*SAP Release: SAP ECC 6.0                                              *
*----------------------------------------------------------------------*
*WRICEF ID  : D3_OTC_CDD_0007                                          *
*----------------------------------------------------------------------*
*Description: This development has been done to map the below 2 fields:*
*          Street 2: E1EDKA1-STRS2                                     *
*          Street 3: E1EDKA3.QUALP ='Z01' and E1EDKA3.STDPN = Street 3 *
*----------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                 *
*======================================================================*
*Date           User          Transport             Description        *
*=========== ============== ============== ============================*
*23-Apr-2019   U029267       E2DK923553    PCR#621 - Map fields Street *
*                                          2 and Street 3 to the sales *
*                                          order data (ORDCHG)         *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0007O_MAP_STREET
*&---------------------------------------------------------------------*

DATA: lwa_didoc_data_e1edka1 TYPE edidd,     " Wrk area for E1EDKA1
      lwa_didoc_data_e1edka3 TYPE edidd,     " Wrk area for E1EDKA3
      lwa_dxbdcdata          TYPE bdcdata,   " Wrk area for BDC data
      lx_e1edka1             TYPE e1edka1,
      lwa_bdcdata1           TYPE bdcdata,   " Batch input: New table field structure
      lv_street2             TYPE bdc_fval,  " Street 2
      lv_street3             TYPE bdc_fval,  " Street 3
      lv_house               TYPE ad_hsnm1,  " House
      lv_index3              TYPE syindex,   " Index for House
      lv_index1              TYPE syindex,   " Index for Street 2
      lv_index2              TYPE syindex.   " Index for Street 3

CONSTANTS: lc_street2  TYPE fnam_____4 VALUE 'ADDR1_DATA-STR_SUPPL1',
           lc_street3  TYPE fnam_____4 VALUE 'ADDR1_DATA-STR_SUPPL2',
           lc_house    TYPE fnam_____4 VALUE 'ADDR1_DATA-HOUSE_NUM1',
           lc_street1  TYPE fnam_____4 VALUE 'ADDR1_DATA-STREET',
           lc_cdd_0007 TYPE z_enhancement VALUE   'D3_OTC_CDD_0007', " Enhancement No.
           lc_e1edka1  TYPE edilsegtyp VALUE 'E1EDKA1',
           lc_e1edka3  TYPE edilsegtyp VALUE 'E1EDKA3',
           lc_z01      TYPE char3      VALUE 'Z01'.


* Setting all the constant values.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_cdd_0007
  TABLES
    tt_enh_status     = li_constant.

READ TABLE li_constant WITH KEY criteria = lc_null
                                active   = abap_true
                                TRANSPORTING NO FIELDS.

IF sy-subrc = 0.

*Check BDC data table if Street 2 is populated.
*If it is not populated then ony populated the BDC table with Street 2 and Street 3
  READ TABLE  dxbdcdata  INTO lwa_dxbdcdata
  WITH KEY fnam = lc_street2.

  IF sy-subrc NE 0.
    CLEAR: lv_index1,
           lv_index2.

*   Fetch the index for Street after which Street 2 and Street 3 will get appended in the BDC table
    READ TABLE  dxbdcdata  WITH KEY fnam = lc_street1
    TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      lv_index1 = sy-tabix + 1. " Index for Street 2
      lv_index2 = sy-tabix + 2. " Index for Street 3
      lv_index3 = sy-tabix + 3. " Index for House

*      Fetch Street 2 from the IDOC structure E1EDKA1
      READ TABLE didoc_data INTO lwa_didoc_data_e1edka1
           WITH KEY segnam = lc_e1edka1.
      IF sy-subrc = 0.
        lx_e1edka1 = lwa_didoc_data_e1edka1-sdata.
        lv_house = lx_e1edka1-hausn.
        lv_street2 = lwa_didoc_data_e1edka1-sdata+212(35).  "E1EDKA1-STRS2
      ENDIF.

*      Fetch Street 3 from the IDOC structure E1EDKA3
      READ TABLE didoc_data INTO lwa_didoc_data_e1edka3
           WITH KEY segnam = lc_e1edka3.
      IF sy-subrc = 0.
        IF lwa_didoc_data_e1edka3-sdata+0(3) = lc_z01.
          lv_street3 = lwa_didoc_data_e1edka3-sdata+3(70).  "E1EDKA3-STDPN
        ENDIF.
      ENDIF.

*    Populate the BDC data with Street 2 and Street 3
      IF lv_street2 IS NOT INITIAL.
**  Populate Street2
        lwa_bdcdata1-fnam = lc_street2. " Field Name
        lwa_bdcdata1-fval = lv_street2. " Field Value


        INSERT lwa_bdcdata1 INTO dxbdcdata[] INDEX lv_index1.
      ENDIF.

      IF lv_street3 IS NOT INITIAL.
**  Populate Street3
        lwa_bdcdata1-fnam = lc_street3. " Field Name
        lwa_bdcdata1-fval = lv_street3. " Field Value

        INSERT lwa_bdcdata1 INTO dxbdcdata[] INDEX lv_index2.
      ENDIF.
      IF lv_house IS NOT INITIAL.
**  Populate Hosue
        lwa_bdcdata1-fnam = lc_house. " Field Name
        lwa_bdcdata1-fval = lv_house. " Field Value

        INSERT lwa_bdcdata1 INTO dxbdcdata[] INDEX lv_index3.
      ENDIF.
    ENDIF."IF sy-subrc = 0.->READ TABLE  dxbdcdata....fnam = lc_street1...
  ENDIF."IF sy-subrc = 0.->READ TABLE  dxbdcdata....fnam = lc_street2.
ENDIF.
