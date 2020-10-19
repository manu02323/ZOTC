************************************************************************
* PROGRAM    :  ZOTCN0074O_COST_CNTR_ASSIGN (Include)                  *
* TITLE      :  Sales Rep Cost Center Assignment                       *
* DEVELOPER  :  DEBRAJ HALDAR                                          *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0074                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of cost center from the custom table         *
*               ZOTC_COST_CENTER                                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-JUN-2012  DHALDAR  E1DK903043 INITIAL DEVELOPMENT                 *
*19-Oct-2014  JAHAN     E2DK904476 Defect # 987 Shipping Condition     *
*                                  override for D2_OTC_IDD_90          *
*&---------------------------------------------------------------------*

*Local constant decalration

CONSTANTS: lc_delv_stat TYPE lfstk VALUE 'C', " Delivery status
           lc_trtyp_v   TYPE trtyp VALUE 'V', " Transaction type
           lc_trtyp_h   TYPE trtyp VALUE 'H'. " Transaction type

*Local data declaration
DATA: lv_kostl TYPE kostl. " Cost Center

IF t180-trtyp = lc_trtyp_v OR
   t180-trtyp = lc_trtyp_h.

*Check the delivery status
  IF vbuk-lfstk NE  lc_delv_stat.
* If the delivery status is not complete then continue processing
* Get the value of cost center from ZOTC_COSTCENTER for the
* corresponding Sales organization, Sales Document Type, Sold-to party

    SELECT SINGLE kostl         "Cost Center
           FROM zotc_costcenter " Sales Order Cost Center Determination
           INTO lv_kostl
           WHERE vkorg = vbak-vkorg
           AND   auart = vbak-auart
           AND   kunnr = vbak-kunnr.

    IF sy-subrc = 0.

*Apply conversion exit
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_kostl
        IMPORTING
          output = lv_kostl.

* Move the value of Cost Center retrieved from ZOTC_COSTCENTER to
* VBAK-KOSTL
      vbak-kostl = lv_kostl.

    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF vbuk-lfstk NE lc_delv_stat
ENDIF. " IF t180-trtyp = lc_trtyp_v OR

*----------------Defect # 987 D2_OTC-IDD_0090-------------------------*
*--Start of Defect # 987 D2_OTC-IDD_0090. by Jahan.
   "Assign shipping condition: currently its being determined by the system from customer master,
   "shipping condition maintianed in the particular ship-to party. Here we are trying to override the
   "shipping condition with value coming from the EVO/SVCMX interface.
DATA lv_vsbed TYPE vsbed. " Shipping Conditions

CLEAR: lv_vsbed.
IMPORT lv_vsbed_t TO lv_vsbed FROM MEMORY ID 'IDD_90_VSBED'.

IF NOT lv_vsbed IS INITIAL.
   "Assign shipping condition from interface data to SO haeder data.
  vbak-vsbed = lv_vsbed.
ENDIF. " if NOT lv_vsbed is INITIAL
*--End of Defect # 987 D2_OTC-IDD_0090.
