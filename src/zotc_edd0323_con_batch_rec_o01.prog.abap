*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0323_CON_BATCH_REC_O01
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0323_CON_BATCH_REC                             *
* TITLE      :  Convert Batch Determination Records                    *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0323                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination process will assign a batch based  *
* on Business selection criteria for a combination of values, such as  *
* Material, Ship-to or Country of Destination.                         *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Jul-2016 DARUMUG  E1DK919220 INITIAL DEVELOPMENT                  *
* 04-Nov-2016 DARUMUG  E1DK919220 CR 190: Defect # 3039                *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0501  OUTPUT
*&---------------------------------------------------------------------*
*       Setup screen for Main program screen
*----------------------------------------------------------------------*
module status_0501 output.
  set pf-status 'ZCON_BATCH_REC'.
  set titlebar  'ZCON_BATCH_REC'.
endmodule.                 " STATUS_0501  OUTPUT
