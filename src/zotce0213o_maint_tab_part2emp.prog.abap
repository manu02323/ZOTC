************************************************************************
* PROGRAM    :  ZOTCE0213O_MAINT_TAB_PART2EMP                          *
* TITLE      :  Program to maintain Partner to Employee table          *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Program for online maintenance of  Partner to Employee *
*               table                                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*

REPORT zotce0213o_maint_tab_part2emp MESSAGE-ID zotc_msg.

*Top Include
INCLUDE zotce0213o_maint_tab_p2e_top. " Include ZOTCE0213O_MAINT_TAB_P2E_TOP
*Selection Screen Include
INCLUDE zotce0213o_maint_tab_p2e_sel. " Include ZOTCE0213O_MAINT_TAB_P2E_SEL
*Subroutine Include
INCLUDE zotce0213o_maint_tab_p2e_sub. " Include ZOTCE0213O_MAINT_TAB_P2E_SUB

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_hide_fields.

AT SELECTION-SCREEN ON s_vkorg.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_salesorg.
  ENDIF.

AT SELECTION-SCREEN ON s_vtweg.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_dist_channel.
  ENDIF.

AT SELECTION-SCREEN ON s_spart.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_division.
  ENDIF.

AT SELECTION-SCREEN ON s_terrid.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_territory_id.
  ENDIF.

START-OF-SELECTION.

  IF rb_add = c_check.
    gv_ind = c_add.
  ELSE. " ELSE -> IF rb_add = c_check
    gv_ind = c_change.
  ENDIF. " IF rb_add = c_check

  CALL SCREEN 9001.
