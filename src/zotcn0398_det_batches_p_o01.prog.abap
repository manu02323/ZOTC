*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_O01
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0398_DET_BATCHES                               *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-Jan-2018 DARUMUG  E1DK934038 INITIAL DEVELOPMENT                  *
*                                                                      *
*                                                                      *
*&---------------------------------------------------------------------*

module status output.

  set pf-status 'ZOTCR0398O_MAIN'.
  set titlebar  'ZOTCR0398O_MAIN'.

endmodule.                 " STATUS  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_REPORT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module display_report output.
  perform f_initialize_alv.
endmodule.                 " DISPLAY_REPORT  OUTPUT
