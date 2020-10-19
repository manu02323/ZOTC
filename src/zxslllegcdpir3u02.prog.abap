*&---------------------------------------------------------------------*
*&  Include           ZXSLLLEGCDPIR3U02
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
* Correction No.:   OSS Note 676301                                  *
* Description:      SLL-LEG Change Import Document to Export during  *
*                   transfer                                         *
*--------------------------------------------------------------------*
* Author:           Bundalian, Jan Michael SAP-GTS                   *
* Date:             05/13/2005                                       *
*--------------------------------------------------------------------*
*--------------------------------------------------------------------*
* MODIFICATION HISTORY:                                              *
*====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== ===================================*
* 08-08-2014  SPAUL2   E2DK900165 D2_PTP_EDD_0202: As per SAP OSS    *
*                                 note 0001913279, filter out the    *
*                                 indirect procurement items.Remove  *
*                                 text item in interface CS_API6800  *
*                                 before transferring to GTS if the  *
*                                 BEKPO-KNTTP is maintained in EMI   *
*                                 tool.                              *
*&-------------------------------------------------------------------*


TYPE-POOLS sllr3.
DATA: ls_item-gen          TYPE /sapsll/api6800_itm_r3_s,     " SLL: API Comm. Structure: Customs Document: Item
      ls_item_par          TYPE /sapsll/api6800_itm_par_r3_s, " SLL: API Comm. Structure: Customs Document: Item: Partners
      ls_header_par        TYPE /sapsll/api6800_hdr_par_r3_s, " SLL: API Comm. Structure: Customs Document: Header: Partner
      lv_idx               TYPE i.                            " Idx of type Integers
DATA: c_sto_ind            TYPE c VALUE ' ', " Sto_ind of type Character
      v_werks_lf           TYPE t001w-werks, " Plant
      v_kunnr              TYPE t001w-kunnr, " Customer number of plant
      v_ctry_sap           TYPE t001w-land1, " Country Key
      v_ctry_iso           TYPE t005-intca.  " Country ISO code

DATA: li_status    TYPE TABLE OF zdev_enh_status, " Enhancement status
      wa_status    TYPE zdev_enh_status,          " Enhancement status
* ---> Begin of Insert for D2_PTP_EDD_0202 by SPAUL2
      li_status_knttp TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement status

FIELD-SYMBOLS: <lfs_item-gen>     TYPE /sapsll/api6800_itm_r3_s, " SLL: API Comm. Structure: Customs Document: Item
               <lfs_mm0a_item>    TYPE bekpo,                    " Transfer Structure Items for Purchasing Documents
               <lfs_status_knttp> TYPE zdev_enh_status.          " Enhancement status
* <--- End of Insert for D2_PTP_EDD_0202 by SPAUL2

CONSTANTS: lc_enhanc_no TYPE z_enhancement VALUE 'OSS_676301_001', " Enhancement No.
           lc_criteria  TYPE z_criteria VALUE 'DOCUMENT_TYPE',     " Criteria
           lc_enhanc_no1 TYPE z_enhancement VALUE 'OTC_EDD_0344', " Enhancement No.
           lc_criteria1  TYPE z_criteria VALUE 'STO2EXPORT',     " Criteria
* ---> Begin of Insert for D2_PTP_EDD_0202 by SPAUL2
           lc_knttp       TYPE z_criteria    VALUE 'KNTTP',           " Criteria
           lc_enhanc_0202 TYPE z_enhancement VALUE 'D2_PTP_EDD_0202'. " Enhanc_202 of type CHAR14
* <--- End of Insert for D2_PTP_EDD_0202 by SPAUL2

* This enhancement to be used for document type NBC3
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enhanc_no
  TABLES
    tt_enh_status     = li_status.

* If document type is maintained in EMI tool, check the flags
READ TABLE li_status INTO wa_status
                               WITH KEY criteria = lc_criteria
                                        sel_low = cs_api6800-header-gen-document_type.
IF sy-subrc = 0.
  v_werks_lf = is_mm0a_header-reswk.
  c_sto_ind = 'X'.
ENDIF. " IF sy-subrc = 0

IF    iv_application_level = 'MM0A'.
*AND (     cs_api6800-header-gen-document_type = 'FNB'
*      OR  cs_api6800-header-gen-document_type = 'FUB'
*      OR  cs_api6800-header-gen-document_type = 'FNBC3' ). "   Addition by vinita 03.07.2014   Suggested by Sneh
**-Check if PO is an STO
*  CASE cs_api6800-header-gen-document_type.
*    WHEN 'FNB'.
**     if field LLIEF is populated, PO is an STO
**      IF NOT is_mm0a_header-llief IS INITIAL.  " This condition was commented by SNIGAM on 1/10/14 after having meeting with Xavier
**      v_werks_lf = is_mm0a_header-reswk.
**      c_sto_ind = 'X'.
**      ENDIF.
*    WHEN 'FUB'.
**     UBs are always STOs
*      v_werks_lf = is_mm0a_header-reswk.
*      c_sto_ind = 'X'.
*    WHEN 'FNBC3'. "   Addition by vinita 03.07.2014 - Suggested by Sneh.
*      v_werks_lf = is_mm0a_header-reswk.
*      c_sto_ind = 'X'.
*  ENDCASE.

CLEAR : LI_STATUS ,WA_STATUS.
* This enhancement to be used for document type NBC3
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enhanc_no1
  TABLES
    tt_enh_status     = li_status.

* If document type is maintained in EMI tool, check the flags
READ TABLE li_status INTO wa_status
                               WITH KEY enhanc_no   = lc_enhanc_no1
                                        criteria    = lc_criteria1
                                        sel_low     = cs_api6800-header-gen-document_type.
    IF SY-SUBRC EQ 0.
         v_werks_lf = is_mm0a_header-reswk.
         c_sto_ind = 'X'.
    ENDIF.
*-if PO is STO, switch vendor & plant-customer attributes
  IF c_sto_ind = 'X'.
*   Switch application level from purchase order to sales order
    cs_api6800-header-gen-application_level = 'SD0A'.
*---insert vendor-plant from header level to item level
    LOOP AT cs_api6800-item-gen INTO ls_item-gen.
      lv_idx = sy-tabix.
*---  check if plant at item level is setup as a customer
      CLEAR: v_kunnr, v_ctry_sap.
      SELECT SINGLE kunnr land1
        INTO (v_kunnr,
              v_ctry_sap)
        FROM t001w " Plants/Branches
      WHERE werks = ls_item-gen-plant.
      IF sy-subrc = 0.
*---1. Switch original receiving plant with supplying vendor-plant
*---2. Append ship-to plant-customer fr item level to hdr partner table
*------- Initialisierung
        CLEAR: v_ctry_iso.
*------- Aufruf des zugehoerigen FBs
        CALL FUNCTION 'COUNTRY_CODE_SAP_TO_ISO'
          EXPORTING
            sap_code  = v_ctry_sap "dest ctry
          IMPORTING
            iso_code  = v_ctry_iso
          EXCEPTIONS
            not_found = 2
            OTHERS    = 4.
*------- Fehlerhandling
        IF NOT ( sy-subrc  IS INITIAL ) .
          CLEAR: v_ctry_iso.
        ENDIF. " IF NOT ( sy-subrc IS INITIAL )
**------modify line item, insert vendor-plant
        ls_item-gen-plant = v_werks_lf.
        ls_item-gen-invoicing_country = ls_item-gen-departure_country.
        ls_item-gen-invoicing_country_iso =
             ls_item-gen-departure_country_iso.
        ls_item-gen-country_of_origin = ls_item-gen-departure_country.
        ls_item-gen-country_of_origin_iso =
             ls_item-gen-departure_country_iso.
*       arrival country is the country of the destination plant
        ls_item-gen-arrival_country = v_ctry_sap.
        ls_item-gen-arrival_country_iso = v_ctry_iso.

        MODIFY cs_api6800-item-gen FROM ls_item-gen INDEX lv_idx.
        CLEAR ls_header_par.
        ls_header_par-partner_function = 'WE'. "Ship-to
        ls_header_par-partner_type     = '02'. "Customer
        ls_header_par-partner_id       = v_kunnr. "Customer# for plant
        ls_header_par-country          = v_ctry_sap.
        ls_header_par-country_iso      = v_ctry_iso.
        APPEND ls_header_par TO cs_api6800-header-par.
      ENDIF. " IF sy-subrc = 0

    ENDLOOP. " LOOP AT cs_api6800-item-gen INTO ls_item-gen
  ENDIF. " IF c_sto_ind = 'X'
ENDIF. " IF iv_application_level = 'MM0A'

* ---> Begin of Insert for D2_PTP_EDD_0202 by SPAUL2
* This enhancement to be used for Accpount Assignment category KNTTP
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_enhanc_0202
  TABLES
    tt_enh_status     = li_status_knttp.

DELETE li_status_knttp WHERE active EQ space.

LOOP AT cs_api6800-item-gen ASSIGNING <lfs_item-gen>.
  lv_idx = sy-tabix.
*  As this is a standard table we cannot sort and hence no binary search used
  READ TABLE it_mm0a_item ASSIGNING <lfs_mm0a_item>
        WITH KEY ebelp = <lfs_item-gen>-item_number.

  IF sy-subrc = 0.
* If Accnt. Assignment Category is maintained in EMI tool, set a deletion indicator
    READ TABLE li_status_knttp ASSIGNING <lfs_status_knttp>
                                   WITH KEY criteria = lc_knttp
                                            sel_low  = <lfs_mm0a_item>-knttp.
    IF sy-subrc = 0.
      <lfs_item-gen>-deletion_indicator = abap_true.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0
ENDLOOP. " LOOP AT cs_api6800-item-gen ASSIGNING <lfs_item-gen>

DELETE cs_api6800-item-gen WHERE deletion_indicator = abap_true.
* <--- End of Insert for D2_PTP_EDD_0202 by SPAUL2
