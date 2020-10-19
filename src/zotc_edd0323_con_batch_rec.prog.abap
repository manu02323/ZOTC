*&---------------------------------------------------------------------*
*& Module Pool       ZOTC_EDD0323_CON_BATCH_REC
*&
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
* 15-Aug-2016 DARUMUG             Defect # 3039                        *
* 04-Nov-2016 DARUMUG  E1DK919220 CR 190:                              *
*                                 Batch Determination using enhancement*
*                                   ->Remove all the BDC logic         *
*                                   ->Replace it w/ enhancements below *
*                                 User Exit:                           *
*                                    1.	Class: ZIM_BATCH_SELECTION     *
*                                       Method PRESELECT_BATCHES       *
*                                    2.	Enhancement:                   *
*                                        ZIM_BATCH_DETERMINATION2 at   *
*                                        VB_BATCH_DETERMINATION        *
*                                        function module.              *
*                                                                      *
*                                                                      *
*&---------------------------------------------------------------------*
program zotc_edd0323_con_batch_rec message-id zotc_msg.

include zdevnoxxx_common_include.       " Include ZDEVNOXXX_COMMON_INCLUDE
include zotc_edd0323_con_batch_rec_top.
include zotc_edd0323_con_batch_rec_f01.
include zotc_edd0323_con_batch_rec_i01.
include zotc_edd0323_con_batch_rec_o01.
