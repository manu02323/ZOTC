************************************************************************
* PROGRAM    :  ZOTCR0043O_POD_REPORT                                  *
* TITLE      :  OTC_RDD_0043_Comprehensive POD Report                  *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0043_Comprehensive POD Report                    *
*----------------------------------------------------------------------*
* DESCRIPTION: This report contains the POD relevant information which *
*              will improve the Business operations and will address to*
*              the issue of not automatically generated PODs.          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 26-FEB-14  SMUKHER   E1DK912803  INITIAL DEVELOPMENT(Defect#1149)    *
* 09-APR-14  SMUKHER   E1DK912803  ADDITIONAL CHANGES ON CR#1149       *
* 13-MAY-14  SMUKHER   E1DK9139959 ADDITION OF NEW FIELD 'SALES OFFICE'*
* 17-JUL-14  SMUKHER   E1DK913409  ADDITION OF DATE LIMIT RANGE ON BACK*
*                                  GROUND MODE.                        *
* 10-SEP-14  SMUKHER   E1DK913409  PERFORMANCE ENHANCEMENT FOR POD REPO*
*                                  -RT                                 *
* 06-OCT-14  SMUKHER   E1DK913409  ADDITIONAL CHANGES ON DELIVERY NUMBE*
*                                  -R AND ACTUAL PGI DATE              *
* 29-MAY-17  U034229   E1DK928313  Defect# 2933: 1)Actual PGI date and *
*                                  Sales organization as mandatory     *
*                                  field.                              *
*                                  2) Profit Center, Serial Number     *
*                                  Profile & POD Date are added in the *
*                                  output.                             *
*                                  3) Sales Org, Dist.Channel, Div,    *
*                                  Del.Type are made as range.         *
*                                  4) Performance Tuning.              *
* 13-Jul-17  U034229   E1DK929131  Defect# 3179 1) Cost column should  *
*                                  be replaced with MBEW-STPRS field.  *
*                                  2) Non-POD relevant shipments should*
*                                  check the PGI Status in POD Report. *
*                                  3) Item Category field is added in  *
*                                  the output.                         *
*                                  4) Multiple Handaling Units issue   *
*                                  need to be solved.                  *
*                                  5) Incorporating the standard ALV   *
*                                  output functionality in PF status.  *
* 29-Aug-17  ASK   E1DK930275  Defect# 3399 1) Cost column logic should*
*                                   be reset to old logic from KONV    *
* 10-Jul-18 U103565 E1DK937670  Defect #6638 1) Addition of new fields *
*                                       Higher Level HU,Tracking Number*
*                                       ESS carrier delivery date      *
*                                       Planned Carrier delivery date  *
*                                       Transit time from route        *
*                                       Installable delivery flag      *
*                                       Customer Acceptance date       *
*                                       Error Message                  *
*                                    2) "POD Relevant" is changed to   *
*                                     "Pending POD" on selection screen*
*12-Sep-2018 AMOHAPA E1DK937670 Defect#6638_FUT_Issue:1) Planned       *
*                               carrier date is not showing properly   *
*                               2)Filter is not working on Transit time*
*                               3)Actual PGI date is refreshed with    *
*                                 incorrect values clicking back       *
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*

REPORT  zotcr0043o_pod_report MESSAGE-ID zotc_msg
                                            LINE-COUNT 60000
                                            LINE-SIZE 132
                                            NO STANDARD PAGE HEADING.
************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Top Include
INCLUDE zotcn0043o_pod_report_top. " Include ZOTCN0043O_POD_REPORT_TOP

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Selection Include
INCLUDE zotcn0043o_pod_report_sel. " Include ZOTCN0043O_POD_REPORT_SEL

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
* Subroutine Include
INCLUDE zotcn0043o_pod_report_sub. " Include ZOTCN0043O_POD_REPORT_SUB

************************************************************************
*---- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
************************************************************************

* Validating Sales Organization

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*at selection-screen on p_vkorg.
** Validating Sales Organization
*  if p_vkorg is not initial.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
AT SELECTION-SCREEN ON s_vkorg.
* Validating Sales Organization
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

  PERFORM f_validate_p_vkorg.

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*     ENDIF. " IF s_vkorg IS NOT INITIAL
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017


* Validating Distribution Channel
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*at selection-screen on p_vtweg.
** Validating the Distribution Channel
*  if p_vtweg is not initial.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
AT SELECTION-SCREEN ON s_vtweg.
* Validating the Distribution Channel
  IF s_vtweg[] IS NOT INITIAL.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

    PERFORM f_validate_p_vtweg.
  ENDIF. " IF s_vtweg[] IS NOT INITIAL

* Validating Division
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*at selection-screen on p_spart.
** Validating the Division
*  if p_spart is not initial.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
AT SELECTION-SCREEN ON s_spart.
* Validating the Division
  IF s_spart[] IS NOT INITIAL.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

    PERFORM f_validate_p_spart.
  ENDIF. " IF s_spart[] IS NOT INITIAL

* Validating Plant
AT SELECTION-SCREEN ON s_werks.
* Validating Plant
  IF s_werks[] IS NOT INITIAL.
    PERFORM f_validate_s_werks.
  ENDIF. " IF s_werks[] IS NOT INITIAL

**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
* Validating Sales Office
AT SELECTION-SCREEN ON s_vkbur.
  IF s_vkbur[] IS NOT INITIAL.
    PERFORM f_validate_s_vkbur.
  ENDIF. " IF s_vkbur[] IS NOT INITIAL
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14

* Validating Delivery Number
AT SELECTION-SCREEN ON s_vbeln.
* Validating Delivery Number
  IF  s_vbeln[] IS NOT INITIAL.
    PERFORM f_validate_s_vbeln.
  ENDIF. " IF s_vbeln[] IS NOT INITIAL
* Validating Delivery Type
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*AT SELECTION-SCREEN ON p_lfart.
*  IF p_lfart IS NOT INITIAL.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
AT SELECTION-SCREEN ON s_lfart.
  IF s_lfart[] IS NOT INITIAL.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
    PERFORM f_validate_p_lfart.
  ENDIF. " IF s_lfart[] IS NOT INITIAL

* Validating Route
AT SELECTION-SCREEN ON s_route.
  IF s_route[] IS NOT INITIAL.
* Validating Route
    PERFORM f_validate_s_route.
  ENDIF. " IF s_route[] IS NOT INITIAL

* Validating Shipping Condition
AT SELECTION-SCREEN ON s_vsbed.
  IF s_vsbed[] IS NOT INITIAL.
* Validating Shipping Condition
    PERFORM f_validate_s_vsbed.
  ENDIF. " IF s_vsbed[] IS NOT INITIAL

* Validating Sold-to-party
AT SELECTION-SCREEN ON s_kunnr.
  IF s_kunnr[] IS NOT INITIAL.
* Validating Sold-to-party
    PERFORM f_validate_s_kunnr.
  ENDIF. " IF s_kunnr[] IS NOT INITIAL

* Validating Ship-to-party
AT SELECTION-SCREEN ON s_kunag.
  IF s_kunag[] IS NOT INITIAL.
* Validating Ship-to-party
    PERFORM f_validate_s_kunag.
  ENDIF. " IF s_kunag[] IS NOT INITIAL

* Validating Handling Unit Number
AT SELECTION-SCREEN ON s_venum.
  IF s_venum[] IS NOT INITIAL.
* Validating Handling Unit Number
    PERFORM f_validate_s_venum.
    PERFORM f_get_hu_delivery.
  ENDIF. " IF s_venum[] IS NOT INITIAL


* Validating Purchase Order Number
AT SELECTION-SCREEN ON s_vbelnp.
  IF s_vbelnp[] IS NOT INITIAL.
* Validating Purchase Order Number
    PERFORM f_validate_s_vbelnp.
    PERFORM f_get_po_delivery.
  ENDIF. " IF s_vbelnp[] IS NOT INITIAL

* Validating Sales Order Number
AT SELECTION-SCREEN ON s_vbelns.
  IF s_vbelns[] IS NOT INITIAL.
* Validating Sales Order Number
    PERFORM f_validate_s_vbelns.
    PERFORM f_get_so_delivery.
  ENDIF. " IF s_vbelns[] IS NOT INITIAL

************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************
AT SELECTION-SCREEN OUTPUT.
**&& -- BOC : ADDITIONAL CHANGES ON DELIVERY NUMBER AND ACTUAL PGI DATE : SMUKHER : 06-OCT-14
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
"As Actual PGI date is a mandatory parameter it will be always filled
"so no need of the below code
*  IF rb_conf IS NOT INITIAL AND s_vbeln[] IS NOT INITIAL.
*    PERFORM f_validate_s_vbeln.
*    PERFORM f_populate_pgi_ac_vbeln.
*  ENDIF. " IF rb_conf IS NOT INITIAL AND s_vbeln[] IS NOT INITIAL
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
**&& -- EOC : ADDITIONAL CHANGES ON DELIVERY NUMBER AND ACTUAL PGI DATE : SMUKHER : 06-OCT-14
  PERFORM f_modify_screen.

************************************************************************
*----- START-OF-SELECTION-----------------------------------------------*
************************************************************************

START-OF-SELECTION.

*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*  Getting the Emi entries for DAYS.
  PERFORM f_fetch_emi_entries CHANGING i_mat_group
                                       i_bom_hd
                                       gv_day.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

* Check the data from ZOTC_PRC_CONTROL table.
  PERFORM f_retrieve_zotc_prc_control.

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- For Foreground processing, Sales Organization and Delivery Type is mandatory
**&&    else for background processing, Plant is mandatory.
  IF sy-batch = abap_true.
    IF s_werks[] IS INITIAL.
      WRITE: 'Please enter the plant'(055).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_werks[] IS INITIAL
**&& --  BOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
    IF rb_conf = abap_true. " s_werks is initial.
      IF s_pgi_ac-high IS NOT INITIAL AND s_pgi_ac-low IS NOT INITIAL.
        IF gv_days GT gv_value_backgr.
          WRITE: 'The Actual PGI date range is greater than 61 days'(061).
          LEAVE LIST-PROCESSING.
        ENDIF. " IF gv_days GT gv_value_backgr
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017.
*      ELSE. " ELSE -> if s_pgi_ac-high is not initial and s_pgi_ac-low is not initial
*        WRITE: 'For POD confirmed records, Actual PGI date (both low and high) is mandatory'(057).
*        LEAVE LIST-PROCESSING.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017.
      ENDIF. " IF s_pgi_ac-high IS NOT INITIAL AND s_pgi_ac-low IS NOT INITIAL
    ENDIF. " IF rb_conf = abap_true
**&& --  EOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
  ELSE. " ELSE -> IF sy-batch = abap_true

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*    if p_vkorg is initial.
*      MESSAGE i977 DISPLAY LIKE gc_e.
*      LEAVE LIST-PROCESSING.
*    ENDIF. " if s_vkorg is initial
*    IF p_lfart IS INITIAL.
*      MESSAGE i978 DISPLAY LIKE gc_e. " Please enter the Delivery Type
*      LEAVE LIST-PROCESSING.
*    ENDIF. " IF s_lfart IS INITIAL
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
** Check if the Actual PGI date range is greater than the maintained value.
    IF s_venum[] IS INITIAL AND
       s_vbelnp[] IS INITIAL AND
       s_vbelns[] IS INITIAL.
      SHIFT gv_days LEFT DELETING LEADING space.
      IF s_pgi_ac-high IS NOT INITIAL AND s_pgi_ac-low IS NOT INITIAL AND rb_conf IS NOT INITIAL AND s_vbeln[] IS INITIAL.
        IF gv_days GT
*-->Begin of delete for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
*          gv_value_forgrnd
*<--End of delete for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
*-->Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
          gv_day
*<--End of insert for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
           AND rb_conf IS NOT INITIAL.
          MESSAGE i995 DISPLAY LIKE gc_e WITH " The date range cannot be greater than & days.
*-->Begin of delete for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
*          gv_value_forgrnd
*<--End of delete for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
*-->Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
          gv_day.
*<--End of insert for D3_OTC_RDD_0043 CR#6638 by U103565(Aaryan) on 10-Jul-2018
          LEAVE LIST-PROCESSING.
        ENDIF. " IF gv_days GT
      ENDIF. " IF s_pgi_ac-high IS NOT INITIAL AND s_pgi_ac-low IS NOT INITIAL AND rb_conf IS NOT INITIAL AND s_vbeln[] IS INITIAL
    ELSE. " ELSE -> IF s_venum[] IS INITIAL AND
*         do nothing.
    ENDIF. " IF s_venum[] IS INITIAL AND
  ENDIF. " IF sy-batch = abap_true

* Checks for Actual PGI Date,for POD Confirmed records it is mandatory.
  PERFORM f_validate_s_pgi_ac.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

* Check if only any one of the additional parameters are chosen
  IF s_venum[] IS NOT INITIAL OR
     s_vbelnp[] IS NOT INITIAL OR
     s_vbelns[] IS NOT INITIAL.
    PERFORM f_check_additional_data.
  ENDIF. " IF s_venum[] IS NOT INITIAL OR

*  Retrieve data from LIKP - Delivery Header details based on selection screen values
  PERFORM f_retrieve_from_likp
                      CHANGING i_likp.
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
* *  Retrieve data from TVRO Transit time
  PERFORM f_retrive_from_tvro USING    i_likp
                              CHANGING i_tvro.

  PERFORM f_retrive_from_vbpa USING    i_likp
                              CHANGING i_vbpa.
*<--- end of Insert for D3_OTC_RDD_0043 CR#6638by U103565(AARYAN) on 10-Jul-2018


*  Retrieve data from LIPS - Delivery Item details based on selection screen values
  PERFORM f_retrieve_from_lips CHANGING i_lips
                                        i_likp.
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*  Retrieve from SER01
  PERFORM f_retrieve_from_ser01 USING    i_lips
                                CHANGING i_ser01
                                         i_objk
                                         i_equi
                                         i_serial_num.
*<--- end of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018


*  Retrieve data from VBUP - Sales Document:Item details based on selection screen values
  PERFORM f_retrieve_from_vbup
**&& -- BOC : Performance Enhancement : SMUKHER : 10-SEP-14
                      CHANGING i_lips
**&& -- EOC : Performance Enhancement : SMUKHER : 10-SEP-14
                               i_vbup
                               i_likp.
*  Retrieve data from KNA1 - Customer Master details based on selection screen values
  PERFORM f_retrieve_from_kna1
                      USING    i_likp
                      CHANGING i_kna1.
* Retrieve data from TVSBT - Shipping Conditions: Texts based on selection screen values
  PERFORM f_retrieve_from_tvsbt
                      USING    i_likp
                      CHANGING i_tvsbt.
*  Retrieve data from TVROT - Routes: Texts based on selection screen values
  PERFORM f_retrieve_from_tvrot
                      USING i_likp
                      CHANGING i_tvrot.
* Retrieve data from BKPF - Accounting Document Header details based on selection screen values
  PERFORM f_retrieve_from_bkpf
                      USING    i_likp
                      CHANGING i_bkpf.
*  Retrieve data from BSEG - Accounting Document Segment details based on selection screen values
  PERFORM f_retrieve_from_bseg
                      USING i_bkpf
                      CHANGING i_bseg.

* Retrieve data from VBAK - Sales Document:Header details based on selection screen values
  PERFORM f_retrieve_from_vbak
                      USING    i_lips
                      CHANGING i_vbak.

* Retrieve data from VBKD - Sales Document:Business data details based on selection screen values
  PERFORM f_retrieve_from_vbkd
                      USING    i_vbak
                      CHANGING i_vbkd.

* Retrieve data from TVM1T - Material Pricing details based on selection screen values
  PERFORM f_retrieve_from_tvm1t
                      USING    i_lips
                      CHANGING i_tvm1t.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
* Retrieve data from MAKT - Material Description details based on selection screen values.
  PERFORM f_retrieve_from_makt
                      USING    i_lips
                      CHANGING i_makt.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*  Retrieve data from VBAP - Sales Document:Item details based on selection screen values
  PERFORM f_retrieve_from_vbap
                      USING i_lips
                      CHANGING i_vbap.
*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
* Revert back to old logic commenting new logic

**---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*  Retrieve data from KONV - Conditions(Transaction Data) details based on selection screen values

  PERFORM f_retrieve_from_konv
                      USING    i_vbak
                      CHANGING i_konv.
**<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399



*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
* Comment new logic for Defcet # 3179
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
* Retrieve data from MBEW - for Cost Details
*  PERFORM f_retrieve_from_mbew USING i_lips
*                               CHANGING i_mbew.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399

* Retrieve data from VEPO - Packing:Handling Unit Item details based on selection screen values
  PERFORM f_retrieve_from_vepo
                      USING    i_lips
                      CHANGING i_vepo.
* Retrieve data from VEKP - Handling Unit header details based on selection screen values
  PERFORM f_retrieve_from_vekp
                      USING    i_vepo
                      CHANGING i_vekp.

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
* Retrieve data from MARC - Serial Number Profile header details based on selection screen values
  PERFORM f_retrieve_from_marc
                        USING    i_lips
                        CHANGING i_marc.

* Retrieve data from ZLEX_POD - POD DATE header details based on selection screen values
  PERFORM f_retrieve_from_zlex_pod
                        USING    i_vekp
                        CHANGING i_zlex_pod.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
* Retrieve data from VBUK - Non-POD relevant shipments should be removed from LIKP table
  PERFORM f_retrieve_from_vbuk CHANGING i_likp
                                        i_vbuk.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

*---> Begin of Insert for D3_OTC_RDD_0043_CR#6638 by U103565(AARYAN) on 10-Jul-2018

*  Getting the Higher leve HU.
  PERFORM f_get_higher_hu USING    i_vekp
                          CHANGING i_hu_header.
*  Getting POD ESS delivery date based on outbound delievery
  PERFORM f_retrieve_from_zlex_pod_his
                        USING    i_vekp
                        CHANGING i_pod_history.
*  Getting error message
  PERFORM f_retrieve_error
                        USING    i_likp
                        CHANGING i_error.
*---> End of Insert for D3_OTC_RDD_0043_CR#6638 by U103565(AARYAN) on 10-Jul-2018
*----------------------------------------------------------------------*
*        E N D - O F - S E L E C T I O N                               *
*----------------------------------------------------------------------*
END-OF-SELECTION.

*  Prepare final table.
  PERFORM f_final_table_population
                        USING i_likp
                              i_kna1
                              i_tvsbt
                              i_tvrot
                              i_bkpf
                              i_bseg
                              i_lips
                              i_vbak
                              i_vbkd
                              i_vbup
                              i_tvm1t
                              i_vbap
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 18-Jul-2017
                              i_konv " Defect 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 18-Jul-2017
                              i_vekp
                              i_makt
*---> Begin of insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
                              i_marc
                              i_zlex_pod
*<--- End of insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
                             i_hu_header
                             i_tvro
                             i_pod_history
                             i_error
                             i_vbpa
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*                              i_mbew  " Defect 3399
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                     CHANGING  i_vepo
                               i_final.

*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

  PERFORM f_get_start_date CHANGING i_final
                                    i_inst.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*  Report display
  IF i_final[] IS NOT INITIAL.
    SORT i_final BY vbeln. "Delivery Number

* prepare fieldcatlog
    PERFORM f_prepare_fieldcat
                          CHANGING i_fieldcat[].

* display ALV report
    PERFORM f_output_display USING i_fieldcat[]
                                   i_final[].
  ELSE. " ELSE -> IF i_final[] IS NOT INITIAL
 "infomation mesaage.
    MESSAGE i996.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_final[] IS NOT INITIAL
