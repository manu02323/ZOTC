*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0323_CON_BATCH_REC_I01
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
*01-Jul-2019 U103061  E2DK924987  Defect 9407 Incident: INC0426256-03  *
*                                 Modification required during         *
*                                 Deletion/Updation/Copying/Filtering  *
*&---------------------------------------------------------------------*
MODULE user_command_0501 INPUT.

  gv_okcode = sy-ucomm.
  CLEAR sy-ucomm.
  CASE gv_okcode.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'OK'.
      IF gv_set_ok_hit EQ space.
        PERFORM f_manage_grid.
      ELSE.
        "Flush global objects
        PERFORM f_flush_global_objects.
        PERFORM f_manage_grid.
      ENDIF.
    WHEN 'EXECUTE'.
      "Flush global objects
*--->Begin of Delete for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
*      perform f_flush_global_objects.
*<--End of Delete for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
      PERFORM f_manage_grid.
    WHEN 'SAVE'.
      IF i_output IS NOT INITIAL.
        i_output_add = i_output.
        DELETE i_output_add WHERE flag NE c_add.
        i_output_chg = i_output.
        i_output_del = i_output.
        DELETE i_output_chg WHERE flag NE c_chng.
        DELETE i_output_del WHERE flag NE c_del.
        APPEND LINES OF i_output_del TO i_output_chg.
        IF i_output_chg IS NOT INITIAL.
          "CR 190 - Removed BDC logic and redundant code
          APPEND LINES OF i_output_chg TO i_output_add.
        ENDIF.

        "Update Customer Group Assignment
        PERFORM update_cust_group.
        LOOP AT i_output ASSIGNING <gfs_output>.
          CLEAR <gfs_output>-flag.
        ENDLOOP.
*--->Begin of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
        PERFORM f_get_batch_data . "Required to fetch new saved records and displayed it on screen
        SORT i_output BY matnr kunwe DESCENDING."Sort Output Data
        CALL METHOD go_grid_501->refresh_table_display."Refresh Display Container
*--->End of Insert for D3_OTC_EDD_0323_Defect#9407 by U103061 on 01-Jul-2019
      ENDIF.
    WHEN OTHERS.
      "Do nothing here
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0501  INPUT
