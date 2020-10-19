*&---------------------------------------------------------------------*
*& Report  ZOTCR0101O_PRICE_DATE_UPD
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0101O_PRICE_DATE_UPD                              *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report displays the list of Sales Order where Price*
*              can be updated and update the pricing date for the      *
*              selected Sales Order line items.                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*&---------------------------------------------------------------------*
* 07-Feb-2014 RVERMA   E1DK913507 MOD-001: Def#649 - Additional changes*
*                                 related to data fetching from VBUK   *
*                                 (Order Status data), VBKD (Business  *
*                                 data) and VBAP (Order Item) table.   *
*&---------------------------------------------------------------------*
* 27-Mar-2014 RVERMA   E1DK913507 MOD-002: Def#649 - Addition of Screen*
*                                 fields Customer Grp1 and Customer    *
*                                 Grp2. Also make the screen field     *
*                                 Sold-to single entry field.          *
*&---------------------------------------------------------------------*
* 09-Apr-2014 RVERMA   E1DK913507 Def#649 - Update in logic of KNVV    *
*                                 (Customer Sales Data) & VBAK (Order  *
*                                 Header Data) table.                  *
*&---------------------------------------------------------------------*
* 31-AUG-2017 SMUKHER4 E1DK930340/ Defect#3400 -Following changes are done
*                      E1DK930342  in the program:                     *
*                                 1)The selection will have a field    *
*                                 (Range) for Requested Delivery Date  *
*                                  (non-Mandatory).                    *
*                                 2)The mandatory fields should only be*
*                                   removed for background mode, when  *
*                                   the user executes a transaction in *
*                                   the foreground, the mandatory fields*
*                                   should be activated.               *
*                                 3)The system will consider all the   *
*                                  orders line items with requested    *
*                                   delivery date + 1 Day.             *
*                                 4)Once the job is completed          *
*                                  successfully, the date (req del date+1)
*                                 is added to EMI table, this date     *
*                                 will be populated in the requested   *
*                                  delivery date field in the next run.*
*                                5)Currently when the report is executed*
*                                  in the foreground, the user is      *
*                                  expected to select all the lines and*
*                                  click on update button, however, in *
*                                  the background, this should be done *
*                                  automatically.                      *
*                                6)All efforts needs to be made to     *
*                                 increase the performance of program  *
*                                 while executing during background.   *
*08-Aug-2018  AMOHAPA E1DK930340  Defect#3400(Part 2): 1)Program to be *
*                                 Later taged with Defect#7955         *
*                                 made to process D3 sales organization*
*                                 records with different logic from    *
*                                 existing program                     *
*                                 2) Output of Batchjob to be import   *
*                                    in an excel sheet                 *
*25-Oct-2018  AMOHAPA E1DK930340  Defect#3400(Part 2)_FUT Issues:      *
*                                 Later taged with Defect#7955         *
*                                 1)Actual good movement date (LIKP-   *
*                                 WADAT_IST) is added in the selection *
*                                 screen                               *
*                                 2) Now pricing date is updated with  *
*                                 Actual good movement date            *
*                                 3)Instead of VBUK,now we are checking*
*                                 VBUP for Billing,POD and PGI status  *
*                                 4) We will update the pricing date   *
*                                 where pricing date is not same as    *
*                                 Actual goods movement date           *
*&---------------------------------------------------------------------*

REPORT  zotcr0101o_price_date_upd NO STANDARD PAGE HEADING
                                  LINE-SIZE 132
                                  MESSAGE-ID zotc_msg.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
INCLUDE zotcn0101o_price_date_upd_top. " Include ZOTCN0101O_PRICE_DATE_UPD_TOP

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0101o_price_date_upd_scr. " Include ZOTCN0101O_PRICE_DATE_UPD_SCR

************************************************************************
*          SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0101o_price_date_upd_sub. " Include ZOTCN0101O_PRICE_DATE_UPD_SUB

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
************************************************************************
* INITILIZATION
************************************************************************

INITIALIZATION.
*&--Fetching the EMI entries.
  PERFORM f_fetch_emi_entries.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

************************************************************************
* AT SELECTION-SCREEN OUTPUT
************************************************************************
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
AT SELECTION-SCREEN OUTPUT.
**&& -- Perform to modify selection screen.
  PERFORM f_sel_modify.
*&--Validate Sales Organization
AT SELECTION-SCREEN ON s_vkorg1.
  IF s_vkorg1 IS NOT INITIAL.
    PERFORM f_validation_salesorg.
  ENDIF. " IF s_vkorg1 IS NOT INITIAL
*&--Validate Distribution Channel
AT SELECTION-SCREEN ON s_vtweg1.
  IF s_vtweg1 IS NOT INITIAL.
    PERFORM f_validation_distrchnl.
  ENDIF. " IF s_vtweg1 IS NOT INITIAL
*&--Validate Division
AT SELECTION-SCREEN ON s_spart1.
  IF s_spart1 IS NOT INITIAL.
    PERFORM f_validation_division.
  ENDIF. " IF s_spart1 IS NOT INITIAL
*&--Validate Sales Doc Type
AT SELECTION-SCREEN ON s_auart1.
  IF s_auart1 IS NOT INITIAL.
    PERFORM f_validation_sdtype.
  ENDIF. " IF s_auart1 IS NOT INITIAL
*&--Validate Sales Order Number
AT SELECTION-SCREEN ON s_vbeln1.
  IF s_vbeln1 IS NOT INITIAL.
    PERFORM f_validation_sorder.
  ENDIF. " IF s_vbeln1 IS NOT INITIAL
*&--Validate delivery type
AT SELECTION-SCREEN ON s_lfart.
  IF s_lfart IS NOT INITIAL.
    PERFORM f_validate_del_type.
  ENDIF. " IF s_lfart IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*----------------------------------------------------------------------*
*     A T  S E L E C T I O N - S C R E E N
*----------------------------------------------------------------------*
*&--Validate Sales Organization
AT SELECTION-SCREEN ON s_vkorg.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  IF s_vkorg IS NOT INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    PERFORM f_validation_salesorg.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF s_vkorg IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&--Validate Distribution Channel
AT SELECTION-SCREEN ON s_vtweg.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  IF s_vtweg IS NOT INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    PERFORM f_validation_distrchnl.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF s_vtweg IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&--Validate Division
AT SELECTION-SCREEN ON s_spart.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  IF s_spart IS NOT INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    PERFORM f_validation_division.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF s_spart IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&--Validate Sales Doc Type
AT SELECTION-SCREEN ON s_auart.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  IF s_auart IS NOT INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
    PERFORM f_validation_sdtype.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF s_auart IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&--Validate Sales Order Number
AT SELECTION-SCREEN ON s_vbeln.
  IF s_vbeln IS NOT INITIAL.
    PERFORM f_validation_sorder.
  ENDIF. " IF s_vbeln IS NOT INITIAL
*&--Validate Sold-to Party
AT SELECTION-SCREEN ON s_kunag.
  IF s_kunag IS NOT INITIAL.
    PERFORM f_validation_soldparty.
  ENDIF. " IF s_kunag IS NOT INITIAL
*&--BOC for MOD-002
*&--Validate Customer Group1
AT SELECTION-SCREEN ON s_kvgr1.
  IF s_kvgr1 IS NOT INITIAL.
    PERFORM f_validation_kvgr1.
  ENDIF. " IF s_kvgr1 IS NOT INITIAL
*&--Validate Customer Group2
AT SELECTION-SCREEN ON s_kvgr2.
  IF s_kvgr2 IS NOT INITIAL.
    PERFORM f_validation_kvgr2.
  ENDIF. " IF s_kvgr2 IS NOT INITIAL
*&--EOC for MOD-002
*&--Validate Ship-to Party
AT SELECTION-SCREEN ON s_kunnr.
  IF s_kunnr IS NOT INITIAL.
    PERFORM f_validation_shipparty.
  ENDIF. " IF s_kunnr IS NOT INITIAL
*&--Validate Material Number
AT SELECTION-SCREEN ON s_matnr.
  IF s_matnr IS NOT INITIAL.
    PERFORM f_validation_material.
  ENDIF. " IF s_matnr IS NOT INITIAL
*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--BOC for MOD-002
*&--Commented as sy-batch check is not capturing in this event
*AT SELECTION-SCREEN.
*PERFORM f_check_mandatory_fields.
*&--EOC for MOD-002
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*----------------------------------------------------------------------*
*     S T A R T - O F - S E L E C T I O N
*----------------------------------------------------------------------*
START-OF-SELECTION.

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  PERFORM f_check_mandatory_fields.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*--> Begin of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If D3 checkbox is checked then only we will get the Sales organization and
 "Delivery type from EMI entry
  IF rb_d3 IS NOT INITIAL.
    "Filter the Sales Organization value from EMI entries
*--> Begin of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*    PERFORM f_get_entries_emi USING    i_zdev_emi
*                              CHANGING s_vkorg1[].
*<-- End of delete D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018

 "Getting the records for LIKP.LIPS,VBUK,VBAK and VBAP
    PERFORM f_get_data_d3 CHANGING i_likp
                                   i_lips
*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*                                   i_vbuk
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                                   i_vbup_d3
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                                   i_vbak
                                   i_vbap.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
 "If we don't have any valid records in VBAP then we should not proceed
    IF i_vbap[] IS INITIAL.
      MESSAGE i906. " No relevant Order/Item found. Please change Selection values.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF i_vbap[] IS INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
 "Getting records for VBKD
    PERFORM f_get_so_busidata USING    i_vbap
                              CHANGING i_vbkd.
 "Getting records for KNVV
    PERFORM f_get_cust_so_data CHANGING i_vbak
                                        i_knvv.

  ELSE. " ELSE -> IF rb_d3 IS NOT INITIAL

*<-- End of insert D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

*&--BOC : HPQC Defect # 649 : User ID - RVERMA : Date - 09-Apr-2014

*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--First we are fetching Sales Order data from VBAK table to improve the performance of the program
*&--Get Sales Order Header data
    PERFORM f_get_so_header  CHANGING i_vbak.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&-->Begin of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Commented since in background mode it was taking lot of time to execute.
*&--Get Customer Sales Data
*  PERFORM f_get_cust_so_data CHANGING i_knvv.
*&<--End of delete for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017

*&--EOC : HPQC Defect # 649 : User ID - RVERMA : Date - 09-Apr-2014

*&--Get Sales Order Data
    PERFORM f_get_so_data USING i_knvv "HPQC Defect#649 : RVERMA : 09-Apr-2014
                       CHANGING i_vbak
                                i_vbap
                                i_vbpa
                                i_vbup
                                i_vbep
                                i_vbkd.

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF rb_d3 IS NOT INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&--Get Customer Data
  PERFORM f_get_cust_data USING i_vbak
                                i_vbpa
                                i_knvv "HPQC Defect#649 : RVERMA : 09-Apr-2014
                       CHANGING i_kna1
*                                i_knvv "HPQC Defect#649 : RVERMA : 09-Apr-2014
                                i_tvv1t
                                i_tvv2t.

*&--Get Material Description Data
  PERFORM f_get_mat_desc USING i_vbap
                      CHANGING i_makt.
*----------------------------------------------------------------------*
*     E N D - O F - S E L E C T I O N
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
 "If D3 radio button is selected then Background job we will populate the Item
 "table
  IF rb_d3 IS NOT INITIAL AND
     sy-batch IS NOT INITIAL.
    FREE i_final_itm[].
    PERFORM f_get_final_d3 USING i_vbap
                                 i_vbkd
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                                 i_likp
                                 i_lips
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
                           CHANGING i_final_itm.
  ENDIF. " IF rb_d3 IS NOT INITIAL AND

  IF i_final_itm[] IS INITIAL.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&--Build Final Header & Item Table
    PERFORM f_get_final_tab USING i_vbak
                                  i_vbap
                                  i_vbep
                                  i_vbpa
                                  i_vbkd
                                  i_kna1
                                  i_knvv
                                  i_tvv1t
                                  i_tvv2t
                                  i_makt
                         CHANGING i_final_hdr
                                  i_final_itm.
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
  ENDIF. " IF i_final_itm[] IS INITIAL
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--In background mode, the header and line item will automatically be checked and update the pricing date.
  IF sy-batch = abap_false.
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*&--Build Hierarchical ALV
    PERFORM f_build_hier_alv USING i_final_hdr
                                   i_final_itm.
*&-->Begin of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
  ELSE. " ELSE -> IF sy-batch = abap_false
    PERFORM f_update_item_price_date USING i_final_itm.
  ENDIF. " IF sy-batch = abap_false
*&<--End of insert for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
