************************************************************************
* PROGRAM    :  ZOTCN0042_DELETE_BILLBKSTG (Include)                   *
* TITLE      :  Process Billback data                                  *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  Executable program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Delete Billback Staging table if sales doc is deleted   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

CONSTANTS: lc_credit TYPE auart VALUE 'ZBBC',
           lc_debit  TYPE auart VALUE 'ZDBC'.

IF vbak-auart = lc_credit OR
   vbak-auart = lc_debit.

  CALL FUNCTION 'ZOTC_DELETE_BILLBACK_STAGING'
    EXPORTING
      im_vbak       = vbak.

ENDIF.
