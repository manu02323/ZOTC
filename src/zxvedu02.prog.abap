*&---------------------------------------------------------------------*
*&  Include           ZXVEDU02
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZXVEDU02(User exit include)                             *
*Title      : Customer Order acknowledgement - EDI                    *
*Developer  : Kirti Bansal                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0010                                           *
*---------------------------------------------------------------------*
*Description: This user exit include is used to modify net price in   *
*customer response                                                    *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*13-OCT-2014  KBANSAL       E2DK900755     CR D2 160                  *
*                                          Modification of net price  *
*06-Aug-2015  SGHOSH        E2DK914518     Defect#8864: Net price and
*                                          net value fields are populated
*                                          with respect to currency to
*                                          eliminate decimal discrepancy.
*---------------------------------------------------------------------*
**Local data declaration**
DATA:     lx_e1edp01    TYPE e1edp01,                           "IDoc: Document Item General Data
          li_status     TYPE STANDARD TABLE OF zdev_enh_status, "Enhancement Status table
          lv_lines      TYPE i,                                 " Lines of type Integers
          li_dikomv     TYPE TABLE OF komv.                     " Pricing Communications-Condition Record

**Constants declaration**
CONSTANTS: lc_kschl                   TYPE z_criteria       VALUE 'KSCHL',               "CONDITION TYPE
           lc_partner_seg_e1edp01     TYPE edi_segnam       VALUE 'E1EDP01',             " Name of SAP segment
           lc_idd_0010_001            TYPE z_enhancement    VALUE 'D2_OTC_IDD_0010_001', " Enhancement No.
           lc_null                    TYPE z_criteria       VALUE 'NULL'.                " Enh. Criteria

**Field symbols declaration**
FIELD-SYMBOLS: <lfs_edidd>    TYPE edidd,           " Data record (IDoc)
               <lfs_komv>     TYPE komv,            " Pricing Communications-Condition Record
               <lfs_status>   TYPE zdev_enh_status. " Enhancement Status

* ---> Begin of Change for Defect#8864:D2_OTC_IDD_0010 by SGHOSH
DATA: lv_vprei TYPE edi5118_a, " Price (net)
      lv_netwr TYPE edi5004_d. " Item value (net)
* <--- End of Change for Defect#8864:D2_OTC_IDD_0010 by SGHOSH

* Call to EMI Function Module To Get List Of EMI Statuses
CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_idd_0010_001 "D2_OTC_IDD_0010_001
  TABLES
    tt_enh_status     = li_status.      "Enhancement status table

* Delete all deactive criteria
DELETE li_status WHERE active = space.


***first thing is to check for field criterion,for value “NULL” and field Active value:
***i.If the value is: “X”, the overall Enhancement is active and can proceed further for checks
***ii.If the  value is:space, then do not proceed further for this enhancement

READ TABLE li_status WITH KEY criteria = lc_null "NULL
                       TRANSPORTING NO FIELDS.

IF sy-subrc EQ  0.

*    Calculate number of segments in IDOC.
  DESCRIBE TABLE int_edidd LINES lv_lines. "Data Record
* Binary search can't be used as input IT int_edidd can't be sorted.
*Read the last record of INT_EDIDD table.
  READ TABLE int_edidd ASSIGNING <lfs_edidd> INDEX lv_lines.
  IF sy-subrc = 0.
* If segment is 'E1EDP01'
    IF <lfs_edidd>-segnam = lc_partner_seg_e1edp01. "E1EDP01
      lx_e1edp01 = <lfs_edidd>-sdata. "IDoc: Document Item General Data


      li_dikomv[] = dikomv[].

      SORT li_dikomv BY kposn
                        kschl.

      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_kschl.
      IF sy-subrc EQ 0.

*Read Pricing Communications-Condition Record table
*on the basis of item no. and Condition type 'ZNET' .
        READ TABLE li_dikomv ASSIGNING <lfs_komv> WITH KEY kposn = lx_e1edp01-posex
                                                           kschl = <lfs_status>-sel_low BINARY SEARCH.
        IF sy-subrc = 0.
* ---> Begin of Change for Defect#8864:D2_OTC_IDD_0010 by SGHOSH
          WRITE <lfs_komv>-kbetr CURRENCY <lfs_komv>-waers NO-GROUPING TO lv_vprei.
          WRITE <lfs_komv>-kwert CURRENCY <lfs_komv>-waers NO-GROUPING TO lv_netwr.
          lx_e1edp01-vprei = lv_vprei. "Net price
          lx_e1edp01-netwr = lv_netwr. "Net item value
*          lx_e1edp01-vprei = <lfs_komv>-kbetr. "Net price
*          lx_e1edp01-netwr = <lfs_komv>-kwert. "Net item value
* ---> End of Change for Defect#8864:D2_OTC_IDD_0010 by SGHOSH

* Remove Extra spaces in field.
          SHIFT lx_e1edp01-vprei LEFT DELETING LEADING space. "Net price
          SHIFT lx_e1edp01-netwr LEFT DELETING LEADING space. "Net item value

          <lfs_edidd>-sdata = lx_e1edp01. "Application data
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF <lfs_edidd>-segnam = lc_partner_seg_e1edp01
  ENDIF. " IF sy-subrc = 0

  FREE: li_status,
        li_dikomv.
ENDIF. " IF sy-subrc EQ 0
