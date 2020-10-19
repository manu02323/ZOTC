
************************************************************************
* PROGRAM    :  ZOTCN0211O_INCLUDE_ZZQUOTEREF(Include)                 *
* TITLE      :  User Exit for Incompletion                             *
* DEVELOPER  :  Kriti Srivastava                                       *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D2_OTC_EDD_0211                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Include zzquoteref in incompletion log procedure
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
* 08-AUG-2014  KSRIVAS E2DK903204  INITIAL DEVELOPMENT                 *
*                                  Include zzquoteref in incompletion  *
*                                  log procedure.                      *
*&---------------------------------------------------------------------*

***********************************************************************
*============================Data Declaration=========================*
***********************************************************************

 DATA: li_enh_status    TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Internal table

 FIELD-SYMBOLS: <lfs_vbuv>         TYPE vbuvvb,          " Structure for Internal Table XVBUV
                <lfs_enh_status>   TYPE zdev_enh_status. " Enhancement Status.

 CONSTANTS:  lc_enhancem_no  TYPE z_enhancement VALUE 'D2_OTC_EDD_0211', " Enhancement NUMBER
             lc_fldnam       TYPE fdnam_vb      VALUE 'ZZQUOTEREF' ,     " Document field name
             lc_tabnam       TYPE tbnam_vb      VALUE 'VBAP',            " Table for documents in sales and distribution
             lc_pzku         TYPE fcode_fe      VALUE 'PZKU',            " Screen for creating missing data
             lc_active       TYPE z_criteria    VALUE 'NULL'.            " Enh. Criteria

***********************************************************************
*============================Procesing logic==========================*
***********************************************************************

*Check Enh is active in EMI tool
 CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
   EXPORTING
     iv_enhancement_no = lc_enhancem_no
   TABLES
     tt_enh_status     = li_enh_status.

*We select only the active entries.
 DELETE li_enh_status WHERE active = space.

*If enh is active in EMI Tool
 IF li_enh_status IS NOT INITIAL.

*Get the active status from EMI tool
   READ TABLE li_enh_status ASSIGNING <lfs_enh_status>
                     WITH KEY criteria = lc_active.
   IF sy-subrc = 0.

*Loop at XVBUV for the table VBAP and field ZZQOUTEREF
     LOOP AT xvbuv ASSIGNING <lfs_vbuv>.

       IF <lfs_vbuv>-tbnam = lc_tabnam  AND <lfs_vbuv>-fdnam = lc_fldnam.
*Pass Fcode as PZKU for Additional data B for items having incom. log
         <lfs_vbuv>-fcode = lc_pzku. "PZKU
       ENDIF. " IF <lfs_vbuv>-tbnam = lc_tabnam AND <lfs_vbuv>-fdnam = lc_fldnam
     ENDLOOP. " LOOP AT xvbuv ASSIGNING <lfs_vbuv>
   ENDIF. " IF sy-subrc = 0
 ENDIF. " IF li_enh_status IS NOT INITIAL
