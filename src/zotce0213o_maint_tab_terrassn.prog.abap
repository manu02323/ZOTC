************************************************************************
* PROGRAM    :  ZOTCE0213O_MAINT_TAB_TERRASSN                          *
* TITLE      :  Program to maintain Territory Assignment table         *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Program for online maintenance of Territory Assignment *
*               table                                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 02-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
* 03-MAY-2016 SBEHERA  E2DK917651  Defect#1461 : 1.Radio button Display*
*                                  Added with display functionality    *
*                                  2.Customer name column is added in  *
*                                    the report output                 *
*                                  3.Download option with download     *
*                                    functionality added in application*
*                                    toolbar in report output          *
*                                  4.Screen display of the output      *
*                                    changed to full screen            *
*                                  5.Remove error message at the time  *
*                                    of any change in the report output*
*                                  6.Duplicate entries removed in the  *
*                                    report output while opening and   *
*                                    closing configuration             *
*&---------------------------------------------------------------------*
* 27-APR-2017 U029267 E1DK927361  Defect#2496 / INC0322445 :           *
*                                 1)Change pointer to be replaced by   *
*                                    BD12 call program.                *
*                                 2)Technical change to lock the       *
*                                   'Created on/Created by' flds on    *
*                                   Commission & Territory tab.        *
*                                 3)Territories duplicating incorrectly*
*                                   in the OTC territory tables in     *
*                                   T-Code ZOTC_MAINT_TERRASSN         *
*                                   (Old Def- 2210).                   *
*                                 4)Enhance t-code:ZOTC_MAINT_TERRASSN *
*                                   to be able to restrict to DISPLAY  *
*                                   only (Old Defect: 2209).           *
*                                 5)In the Display session of T-Code   *
*                                   ZOTC_MAINT_TERRASSN we can only see*
*                                  Canada sales org 1020.(Old Def-2211)*
* 12-JUN-2017 U033959 E1DK927361  Defect#2496/SCTASK0537273 -          *
*                                 Customer account group should        *
*                                 be fetched from EMI                  *
*                                 while validating customer            *
*&---------------------------------------------------------------------*
*18-SEP-2017 amangal E1DK930689  D3R2 Changes
*                                1. Allow mass update of date fields in*
*                                   Maintenance transaction            *
*                                2. Allow Load from AL11 with effective*
*                                   dates populated and properly       *
*                                   formatted                          *
*                                3.	Control the sending of IDoc on     *
*                                   request                            *
*&---------------------------------------------------------------------*

REPORT zotce0213o_maint_tab_terrassn MESSAGE-ID zotc_msg.

INCLUDE zotce0213o_maint_tab_terr_top. " Include ZOTCE0213O_MAINT_TAB_TERR_TOP
INCLUDE zotce0213o_maint_tab_terr_sel. " Include ZOTCE0213O_MAINT_TAB_TERR_SEL
INCLUDE zotce0213o_maint_tab_terr_sub. " Include ZOTCE0213O_MAINT_TAB_TERR_SUB

* ---> Begin of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-Jun-2017
INITIALIZATION.
  PERFORM f_get_cust_acc_grp.
* <--- End of Insert for D3_OTC_EDD_0213 Defect#2496/SCTASK0537273 by U033959 on 12-Jun-2017

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_hide_fields.

* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
AT SELECTION-SCREEN ON RADIOBUTTON GROUP rb1.
  PERFORM f_authorization_check.
* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017

AT SELECTION-SCREEN ON s_vkorg.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_salesorg
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                                USING s_vkorg[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF sy-ucomm = c_onli AND rb_chg = c_check

AT SELECTION-SCREEN ON s_vtweg.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_dist_channel
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                                USING s_vtweg[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF sy-ucomm = c_onli AND rb_chg = c_check

AT SELECTION-SCREEN ON s_spart.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_division
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                                USING s_spart[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF sy-ucomm = c_onli AND rb_chg = c_check

AT SELECTION-SCREEN ON s_kunnr.
  IF sy-ucomm = c_onli AND rb_chg = c_check.
    PERFORM f_validate_custacc_id
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
                                USING s_kunnr[].
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ENDIF. " IF sy-ucomm = c_onli AND rb_chg = c_check
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* Validate Sales Organization in selection screen
AT SELECTION-SCREEN ON s_vkorg1.
  IF sy-ucomm = c_onli AND rb_dis = c_check.
    PERFORM f_validate_salesorg USING s_vkorg1[].
  ENDIF. " IF sy-ucomm = c_onli AND rb_dis = c_check

* Validate Distribution Channel in selection screen
AT SELECTION-SCREEN ON s_vtweg1.
  IF sy-ucomm = c_onli AND rb_dis = c_check.
    PERFORM f_validate_dist_channel USING s_vtweg1[].
  ENDIF. " IF sy-ucomm = c_onli AND rb_dis = c_check

* Validate Division in selection screen
AT SELECTION-SCREEN ON s_spart1.
  IF sy-ucomm = c_onli AND rb_dis = c_check.
    PERFORM f_validate_division USING s_spart1[].
  ENDIF. " IF sy-ucomm = c_onli AND rb_dis = c_check

* Validate Customer Number in selection screen
AT SELECTION-SCREEN ON s_kunnr1.
  IF sy-ucomm = c_onli AND rb_dis = c_check.
    PERFORM f_validate_custacc_id USING s_kunnr1[].
  ENDIF. " IF sy-ucomm = c_onli AND rb_dis = c_check

* Validate Partner Territory ID in selection screen
AT SELECTION-SCREEN ON s_terrid.
  IF sy-ucomm = c_onli AND rb_dis = c_check.
    PERFORM f_validate_territory_id.
  ENDIF. " IF sy-ucomm = c_onli AND rb_dis = c_check

* Validate Partner Role in selection screen
AT SELECTION-SCREEN ON s_partrl.
  IF sy-ucomm = c_onli AND rb_dis = c_check.
    PERFORM f_validate_partner_role.
  ENDIF. " IF sy-ucomm = c_onli AND rb_dis = c_check

* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
START-OF-SELECTION.

  IF rb_add = c_check.
    gv_ind = c_add.
* ---> Begin of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
* For display radio button
  ELSEIF rb_dis = c_check.
    gv_ind = c_disp.
* <--- End of Insert for D2_OTC_EDD_0213_Defect#1461 by SBEHERA
  ELSE. " ELSE -> IF rb_add = c_check
    gv_ind = c_change.
  ENDIF. " IF rb_add = c_check

  CALL SCREEN 9001.
*&---------------------------------------------------------------------*
*&      Module  STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_9002 OUTPUT.
  SET PF-STATUS 'ZSTAT_9002'.
  SET TITLEBAR 'ZTITLE_9002'.

ENDMODULE.                 " STATUS_9002  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9002 INPUT.

  CASE gv_okcode2.
    WHEN 'ENTER'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCEL'.
      lv_cancel = 'X'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND_9002  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATE_FR  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_date_fr INPUT.

  CALL FUNCTION 'F4_DATE'
    EXPORTING
      date_for_first_month = lv_effdate_fr
      display              = ' '
    IMPORTING
      select_date          = lv_effdate_fr
    EXCEPTIONS
      OTHERS               = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.


ENDMODULE.                 " GET_DATE_FR  INPUT
*&---------------------------------------------------------------------*
*&      Module  GET_DATE_TO  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_date_to INPUT.

  CALL FUNCTION 'F4_DATE'
    EXPORTING
      date_for_first_month = lv_effdate_to
      display              = ' '
    IMPORTING
      select_date          = lv_effdate_to
    EXCEPTIONS
      OTHERS               = 8.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

ENDMODULE.                 " GET_DATE_TO  INPUT
