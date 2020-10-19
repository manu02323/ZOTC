FUNCTION zotc_delete_billback_staging.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IM_VBAK) TYPE  VBAK
*"----------------------------------------------------------------------

************************************************************************
* PROGRAM    :  ZIM_UPDATE_BILLBACK_STAGING (Enhancement)              *
* TITLE      :  Populate Billback staging table with Sales data        *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  FUNCTION MODULE                                        *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Delete Billback Staging table for Sales Order           *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*   Delete Billback Staging table
    DELETE FROM zotc_billbk_stg WHERE vbeln_s = im_vbak-vbeln.

ENDFUNCTION.
