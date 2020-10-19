************************************************************************
*Program    : ZOTCN0206O_ORDER_CHANGE                                                *
*Title      : Order Change_EDI860                                      *
*Developer  : Jayanta Ray                                              *
*Object type: Interface                                                *
*SAP Release: SAP ECC 6.0                                              *
*----------------------------------------------------------------------*
*WRICEF ID  : D3_OTC_IDD_0206                                          *
*----------------------------------------------------------------------*
*Description: This development has been done to change sales order item*
*             based on posex value in E1EDP01 segment                  *
*----------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                 *
*======================================================================*
*Date           User          Transport             Description        *
*=========== ============== ============== ============================*
*28-Oct-2016   U033867       E1DK922873    Defect # 4955-EDI860 - Wrong*
*                                          Line Getting Updated in     *
*                                          sales order                 *
*----------------------------------------------------------------------*

DATA : li_constant TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
       li_yvbap    TYPE STANDARD TABLE OF vbap,            " Sales Document: Item Data
       lwa_bdcdata TYPE bdcdata.                           " Batch input: New table field structure


FIELD-SYMBOLS: <lfs_vbap> TYPE vbap. " Sales Document: Item Data

CONSTANTS: lc_idd_206      TYPE z_enhancement       VALUE 'OTC_IDD_0206', " Enhancement No.
           lc_null         TYPE z_criteria          VALUE 'NULL'.         " Enh. Criteria

**Enhancement active check
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_206
  TABLES
    tt_enh_status     = li_constant.

IF li_constant[] IS NOT INITIAL.
*Binary search is not used as there will be few entries
*in the internal table
  READ TABLE li_constant TRANSPORTING NO FIELDS
                     WITH KEY criteria = lc_null
                              active   = abap_true.
  IF sy-subrc = 0.
    READ TABLE dyvbap ASSIGNING <lfs_vbap> INDEX 1.
    IF sy-subrc = 0 . " AND  <lfs_vbap>-posex IS INITIAL.  (-) by ddwivedi .
*In dyvbap table yvbap is passed in this exit. yvbap is of type vbap
*So <lfs_vbap> is declared of type vbap
      LOOP AT dyvbap ASSIGNING <lfs_vbap>.
        <lfs_vbap>-posex = <lfs_vbap>-posnr.
      ENDLOOP. " LOOP AT dyvbap ASSIGNING <lfs_vbap>
*Take data from dyvbap to local internal table and sort based on
*vbeln posex and uepos as standard code expect dyvbap table
*based on these three fields.As posex value is changed in dyvbap
*so need to perform the sort
      li_yvbap[] = dyvbap[].
      SORT li_yvbap BY vbeln posex uepos .
      dyvbap[] = li_yvbap[].
      FREE li_yvbap[].
    ENDIF. " IF sy-subrc = 0 AND <lfs_vbap>-posex IS INITIAL
    READ TABLE dxbdcdata WITH KEY fnam = 'BDC_OKCODE'
                                  fval = 'SICH' TRANSPORTING NO FIELDS.

    IF sy-subrc IS INITIAL.
*Posex value should be same as in vbap table before this update and should not
*be changed by population yvbap-posex value in the logic.Purpose of this population
*is to make standard logic identify correct item. So remove posex value from BDC
*Table
      READ TABLE dxbdcdata INTO lwa_bdcdata WITH KEY fnam+0(10) = 'VBAP-POSEX'.
      IF sy-subrc = 0.
        DELETE dxbdcdata  WHERE fnam+0(10) = 'VBAP-POSEX'.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc = 0
ENDIF. " IF li_constant[] IS NOT INITIAL
