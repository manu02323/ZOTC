*&---------------------------------------------------------------------*
*&  Include           ZOTCN0025O_POPULATE_ZZCCINV
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0025_POPULATE_ZZCCINV  (Enhancement)              *
* TITLE      :  D2_OTC_EDD_0025_Output Control Routines                *
* DEVELOPER  :  LALBEE                                                 *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_EDD_0025                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:Populating the custom filed credit card invoice indicator*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-SEP-2012  GLALBEE E2DK905103 Initial Development                  *
*&---------------------------------------------------------------------*
* 23-JUN-2016  BBANERJ E1DK919115 D3_OTC_EDD_0025 : Billing Output     *
*                                 Control Routines.Set flag for        *
*                                 Cross Company Billing                *
*&---------------------------------------------------------------------*
*---> Begin of Insert for D3_OTC_EDD_0025 by BBANERJ
*Local Type Declaration
TYPES : BEGIN OF lty_t001k,
        bwkey TYPE  bwkey, " Valuation Area / Plant
        bukrs	TYPE bukrs,  " Company Code
END OF lty_t001k.
*---> End of Insert for D3_OTC_EDD_0025 by BBANERJ

* Constants to assing a value to the custome filed
CONSTANTS: lc_no     TYPE char1 VALUE 'N',               " No of type CHAR1
           lc_yes    TYPE char1 VALUE 'Y',               " Yes of type CHAR1
           lc_flag   TYPE char1 VALUE 'X',               " Flag of type CHAR1
           lc_cancel TYPE rfbsk VALUE 'C',               " Status for transfer to accounting
           lc_null   TYPE z_criteria                     " Enh. Criteria
                                VALUE 'NULL',            " Enh. Criteria
           lc_0025   TYPE z_enhancement                  " Enhancement No.
                                VALUE 'D2_OTC_EDD_0025'. " Enhancement No.

* Data declaration for Enhancement status
DATA: li_constants TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status

*---> Begin of Insert for D3_OTC_EDD_0025 by BBANERJ
  li_t001k TYPE STANDARD TABLE OF lty_t001k,
  li_com_vbrp_tab TYPE STANDARD TABLE OF vbrpvb . " Reference Structure for XVBRP/YVBRP
*---> End of Insert for D3_OTC_EDD_0025 by BBANERJ

* Function module to get values from EMI tool
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_0025
  TABLES
    tt_enh_status     = li_constants.

* Check if enhancement is active
READ TABLE li_constants WITH KEY criteria = lc_null
                                 active  = abap_true
                                 TRANSPORTING NO FIELDS.
IF sy-subrc = 0.
* if condition to populate the value of zzccinv based on com_vbrk-rplnr
  IF com_vbrk-rplnr IS NOT INITIAL.
    com_kbv3-zzccinv = lc_yes.
  ELSEIF com_vbrk-rplnr IS INITIAL.
    com_kbv3-zzccinv = lc_no.
  ENDIF. " IF com_vbrk-rplnr IS NOT INITIAL

* Condition for RFBSK value to flag the dummy field value
  IF com_vbrk-rfbsk = lc_cancel.
    com_kbv3-dummy = lc_flag.
  ELSEIF com_vbrk-rfbsk NE lc_cancel.
    com_kbv3-dummy = ' '.
  ENDIF. " IF com_vbrk-rfbsk = lc_cancel

ENDIF. " IF sy-subrc = 0

*---> Begin of Insert for D3_OTC_EDD_0025 by BBANERJ
li_com_vbrp_tab[] = com_vbrp_tab[].
SORT li_com_vbrp_tab BY werks.
DELETE ADJACENT DUPLICATES FROM li_com_vbrp_tab
COMPARING werks. " Unique Valuation area / Plant

IF li_com_vbrp_tab IS NOT INITIAL.
*  Fetch Company codes for Valuation Area or Plant
  SELECT
  bwkey      " Valuation Area / Plant
  bukrs      " Company Code
  FROM t001k " Valuation area
  INTO TABLE li_t001k
  FOR ALL ENTRIES IN li_com_vbrp_tab
  WHERE bwkey = li_com_vbrp_tab-werks.

  IF sy-subrc IS INITIAL.
    SORT li_t001k BY bwkey bukrs.
    LOOP AT com_vbrp_tab.
      IF com_vbrp_tab-vbeln = com_vbrk-vbeln.

* Check Billing document's Company code with Company code of
* Plant / Valuation area. If found in the table its same.
        READ TABLE li_t001k
        TRANSPORTING NO FIELDS
        WITH KEY bwkey = com_vbrp_tab-werks
                 bukrs = com_vbrk-bukrs
                 BINARY SEARCH.

        IF sy-subrc IS NOT INITIAL.
*  Set the flag for Cross Company billing
          com_kbv3-cross_comp = abap_true.
          EXIT. " One Item in Billing is Cross Company, Billing document is Cross Company
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ENDIF. " IF com_vbrp_tab-vbeln = com_vbrk-vbeln
    ENDLOOP. " LOOP AT com_vbrp_tab
  ENDIF. " IF sy-subrc IS INITIAL
ENDIF. " IF li_com_vbrp_tab IS NOT INITIAL

CLEAR :
    li_com_vbrp_tab,
    li_t001k.
*---> End of Insert for D3_OTC_EDD_0025 by BBANERJ
