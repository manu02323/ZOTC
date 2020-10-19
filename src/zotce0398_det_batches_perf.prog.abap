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
* 05-Mar-2018 DARUMUG  E1DK934038 CR# 212 Added Corresponding Batch    *
*                                 logic                                *
* 11-Mar-2018 DDWIVEDI E1DK934038 CR# 231 Manual batch inclusion       *
* 03-May-2018 DARUMUG  E1DK936439 Defect# 5957 Add Multiple SOrg's     *
*                                                                      *
*&---------------------------------------------------------------------*
report zotce0398_det_batches_perf message-id zotc_msg.

include zotcn0398_det_batches_p_top.
*include zotcn0398_det_batches_top.
include zotcn0398_det_batches_p_sel.
*include zotcn0398_det_batches_sel.

*----------------------------------------------------------------------*
*                 AT SELECTION SCREEN ON                               *
*----------------------------------------------------------------------*
* Validation for Material
at selection-screen on s_matnr.
  perform f_validate_matnr.

* Validation for Plant
at selection-screen on s_werks.
  perform f_validate_plant.

* Validation on Sales Organization.
at selection-screen on s_vkorg.
  perform f_validate_vkorg.

* Validation on Distribution Channel
at selection-screen on s_vtweg.
  perform f_validate_vtweg.

* Validate Order type
at selection-screen on s_ordty.
  perform f_validate_doc_typ.

* Validation for Documents
at selection-screen on s_docno.
  perform f_validate_docno.

* Validation on Customer Number.
at selection-screen on s_soldto.
  perform f_validate_kunnr.

* Validate Batches
at selection-screen on s_charg.
  perform f_validate_batch.

*----------------------------------------------------------------------*
*                     START OF SELECTION                               *
*----------------------------------------------------------------------*
start-of-selection.

* Get the values maintained in EMI table
  perform f_get_emi_values.

* Get the Sales orders
  perform f_get_orders.

  "Perform Lock Orders
  perform f_lock_orders.

  perform f_sequence_batches.

  if sy-batch is initial.
    "Display the report to the user
    perform f_display_report.
  else.
    i_batch_a[] = i_batch[].
    perform f_determine_batches.
  endif.

  include zotcn0398_det_batches_p_o01.
*  include zotcn0398_det_batches_o01.
  include zotcn0398_det_batches_p_i01.
*  include zotcn0398_det_batches_i01.
  include zotcn0398_det_batches_p_c01.
*  include zotcn0398_det_batches_c01.
  include zotcn0398_det_batches_p_f01.
*  include zotcn0398_det_batches_f01.
