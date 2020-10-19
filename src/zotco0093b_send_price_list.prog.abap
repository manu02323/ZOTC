***********************************************************************
*Program    : ZOTCO0093B_SEND_PRICE_LIST                              *
*Title      : Send Price List                                         *
*Developer  : Salman Zahir                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0093                                           *
*---------------------------------------------------------------------*
*Description: This interface program send  price list to application  *
*             server in a text file format                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*22-NOV-2016    U033959     E1DK918891      Initial development for   *
*                                           CR#249 and CR#255         *
*---------------------------------------------------------------------*
*=========== ============== ============== ===========================*
*06-DEC-2016    DDWIVEDI    E1DK918891      Delete active change      *
*         pointers for selected records based on selection criteria   *
*                                           CR#249 and CR#255         *
*---------------------------------------------------------------------*


REPORT zotco0093b_send_price_list NO STANDARD PAGE HEADING
                                      LINE-SIZE 132
                                      LINE-COUNT 100
                                      MESSAGE-ID zotc_msg.

*----------------------------------------------------------------------*
*     INCLUDES
*----------------------------------------------------------------------*

INCLUDE zotcn0093b_send_price_list_top IF FOUND. " Include ZOTCN0093_LIST_PRICE_TOP

INCLUDE zotcn0093b_send_price_list_scr IF FOUND. " Include ZOTCN0093_LIST_PRICE_SCR

INCLUDE zotcn0093b_send_price_list_sub IF FOUND. " Include ZOTCN0093_LIST_PRICE_SUB

INCLUDE zotcn0093b_send_price_list_cp IF FOUND . "" Include to call global Subrotine to delete change pointers

* Modify selection screen
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen. "Control screen elements visibility

* Validate condition type
AT SELECTION-SCREEN ON p_cond.
  PERFORM f_validate_input.
* Validate condition table
AT SELECTION-SCREEN ON p_tab.
  PERFORM f_validate_input2.
* Validate sales org
AT SELECTION-SCREEN ON s_vkorg.
  PERFORM f_validate_salesorg.
* Validate dist channel
AT SELECTION-SCREEN ON s_vtweg.
  PERFORM f_validate_distchannel.
*  Validate material
AT SELECTION-SCREEN ON s_matnr.
  PERFORM f_validate_matnr.
*  Validate sold to party
AT SELECTION-SCREEN ON s_kunag.
  PERFORM f_validate_soldtoparty.
*  Validate ship to party
AT SELECTION-SCREEN ON s_kunwe.
  PERFORM f_validate_shiptoparty.

* F4 Help for presentation server file
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phdr.
  PERFORM f_path_pserv CHANGING p_phdr.

* F4 help for application server
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ahdr.
  PERFORM f_help_as_path CHANGING p_ahdr.


* Start of selection
START-OF-SELECTION.

  PERFORM f_check_input.

* Get the presentation server file path
  IF rb_pres IS NOT INITIAL.

    gv_file = p_phdr.

  ELSEIF rb_app IS NOT INITIAL.
*  Get the file path for application server
    IF rb_alog IS NOT INITIAL.
*  Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                    CHANGING gv_file.
    ELSE. " ELSE -> IF rb_alog IS NOT INITIAL
      gv_file = p_ahdr.
    ENDIF. " IF rb_alog IS NOT INITIAL
  ENDIF. " IF rb_pres IS NOT INITIAL

* Fetch pricing records
  PERFORM f_fetch_records USING     rb_act
                                    rb_inact
                          CHANGING  i_final
                                    gv_key_date. "Used for InActive cond records


* If presentation server is selected write the text file to presentation server
  IF rb_pres IS NOT INITIAL AND i_final IS NOT INITIAL.

    PERFORM f_write_presentation_server USING gv_file
                                              i_final.
* Else if application server is selected write text file to application server
  ELSEIF rb_app IS NOT INITIAL AND i_final IS NOT INITIAL.

*    PERFORM f_write_app_server USING gv_file
*                                     i_final.
    PERFORM f_write_app_server USING    i_final
                               CHANGING gv_file.

  ENDIF. " IF rb_pres IS NOT INITIAL AND i_final IS NOT INITIAL

* SOC by ddwivedi to delete the change pointers - CR#255-2

* Check if Delete CP is acivated in EMI.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = gc_enh_idd_0093
    TABLES
      tt_enh_status     = git_status.

*  Binary search not used as number of reocrds will be < 10
  READ TABLE git_status WITH KEY criteria = gc_delcp
                                  active   = abap_true
                               TRANSPORTING NO FIELDS.
  IF sy-subrc = 0 AND rb_act IS NOT INITIAL.
    PERFORM delete_active_cp TABLES s_vkorg s_vtweg s_matnr
                               USING p_ersda p_tab p_cond
                               CHANGING gv_dcp_flag .
  ENDIF. " IF sy-subrc = 0 AND rb_act IS NOT INITIAL
* EOC by ddwivedi  to Delete the change Pointers - CR#255-2

* End of selection
END-OF-SELECTION.

* Get the number of records
  gv_lines = lines( i_final ).
  IF gv_lines = 0.
    CLEAR gv_file.
  ENDIF. " IF gv_lines = 0
* Write the values entered in the selection screen
  PERFORM f_write_selection_screen USING gv_file
                                         gv_lines.

  READ TABLE git_status WITH KEY criteria = gc_delcp
                                  active   = abap_true
                               TRANSPORTING NO FIELDS.
  IF sy-subrc = 0 AND gv_dcp_flag IS NOT INITIAL .
    WRITE text-101 .
  ELSEIF sy-subrc = 0 AND gv_dcp_flag IS INITIAL .
    WRITE text-102 .
  ELSEIF sy-subrc <> 0.
    WRITE text-103 .
  ENDIF. " if sy-subrc = 0 and gv_dcp_flag is not INITIAL

  IF rb_inact IS NOT INITIAL.
    WRITE: / 'For InActive mode the Key Date used is'(104), gv_key_date.
  ENDIF. " if rb_inact is not INITIAL
