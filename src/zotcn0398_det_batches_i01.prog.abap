*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_I01
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

module user_command input.

  gv_okcode = sy-ucomm.

  case gv_okcode.
    when 'BACK' or 'CANCEL'.
      clear o_alv.
      leave to screen 0.
    when 'EXIT'.
      leave program.
    when 'SAVE'.
      perform f_save_batch_changes.
    when others.
  endcase.

endmodule.                 " USER_COMMAND  INPUT
