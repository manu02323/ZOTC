************************************************************************
* PROGRAM    :  ZOTCN0021O_COPY_PO_TYPE(Include)                       *
* TITLE      :  Sales Doc to Delivery Doc Copy Control Routines        *
* DEVELOPER  :  Ramya Thumma                                           *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0021                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Copying the PO Type from Sales order Header When        *
*              referenced to a document instead of copied from the     *
*              Contract Header.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-JUN-2017  U034229 E1DK928617  CR# 3029: PO Type at Line Level of  *
*                                  Order Created with Reference to a   *
*                                  Contract                            *
*&---------------------------------------------------------------------*

FIELD-SYMBOLS: <lfs_vbkd>  TYPE vbkdvb, " Reference structure for XVBKD/YVBKD
               <lfs_vbkd1> TYPE vbkdvb. " Sales Document: Business Data

CONSTANTS lc_h TYPE trtyp VALUE 'H'. " Transaction type

CONSTANTS: lc_emi_proj TYPE z_enhancement VALUE 'D3_OTC_EDD_0021', " Enhancement No.
           lc_null     TYPE z_criteria    VALUE 'NULL'.            " Enh. Criteria

DATA: li_status TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

** Check if the object is active from EMI.
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_emi_proj
  TABLES
    tt_enh_status     = li_status.

IF li_status IS NOT INITIAL.
  SORT li_status BY criteria active.
  READ TABLE li_status WITH KEY
                     criteria = lc_null
                     active = abap_true
                     BINARY SEARCH
                     TRANSPORTING NO FIELDS.
  IF sy-subrc EQ 0.


* Checking for Creation mode
    IF t180-trtyp = lc_h.
*  Sales Order should be created from contract
      IF vbak-vgbel IS NOT INITIAL.
        READ TABLE xvbkd ASSIGNING <lfs_vbkd> WITH KEY posnr = '000000'.
        IF sy-subrc = 0.
          IF <lfs_vbkd>-bsark IS NOT INITIAL AND
          xvbkd-posnr IS NOT INITIAL.
*        reading XBBKD from current POSNR
            READ TABLE xvbkd ASSIGNING <lfs_vbkd1> WITH KEY posnr = xvbkd-posnr.
            IF sy-subrc = 0.
*          flipping line item BSARK value with the header BSARK
              <lfs_vbkd1>-bsark = <lfs_vbkd>-bsark.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF <lfs_vbkd>-bsark IS NOT INITIAL AND
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF vbak-vgbel IS NOT INITIAL
    ENDIF. " IF t180-trtyp = lc_h
  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF li_status IS NOT INITIAL
