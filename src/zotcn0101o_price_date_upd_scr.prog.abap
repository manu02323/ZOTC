*&---------------------------------------------------------------------*
*&  Include           ZOTCN0101O_PRICE_DATE_UPD_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0101O_PRICE_DATE_UPD_SCR                          *
* TITLE      :  Pricing Date Update Report                             *
* DEVELOPER  :  ROHIT VERMA                                            *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0101_Pricing Date Update                       *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0101O_PRICE_DATE_UPD. All selection parameters of  *
*              selection screen are declared in this include program.  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 03-Oct-2013 RVERMA   E1DK913507 INITIAL DEVELOPMENT - CR#649         *
*&---------------------------------------------------------------------*
* 27-Mar-2014 RVERMA   E1DK913507 MOD-002: Def#649 - Addition of Screen*
*                                 fields Customer Grp1 and Customer    *
*                                 Grp2. Also make the screen field     *
*                                 Sold-to single entry field.          *
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

*--> Begin of delete for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
*SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
*SELECT-OPTIONS:
*  s_vkorg FOR gv_vkorg OBLIGATORY, "Sales Organization
*  s_vtweg FOR gv_vtweg OBLIGATORY, "Distribution Channel
*  s_spart FOR gv_spart OBLIGATORY, "Division
*  s_auart FOR gv_auart OBLIGATORY, "Sales Doc Type
*  s_vbeln FOR gv_vbeln ,           "Sales Order Number
*  s_erdat FOR gv_erdat ,           "Sales Order Creation Date
**&-->Begin of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
*  s_deldat FOR gv_deldat, " Requested Delivery Date
**&<--End of change for D3_OTC_EDD_0101 Defect# 3400 by SMUKHER4 on 31-AUG-2017
**&--BOC for MOD-002
**  s_kunag FOR gv_kunag ,            "Sold-to-Party
*
*  s_kunag FOR gv_kunag NO INTERVALS "Sold-to-Party
*                       NO-EXTENSION,
*  s_kvgr1 FOR gv_kvgr1 NO INTERVALS "Customer Group1
*                       NO-EXTENSION,
*  s_kvgr2 FOR gv_kvgr2 NO INTERVALS "Customer Group2
*                       NO-EXTENSION,
**&--EOC for MOD-002
*
*  s_kunnr FOR gv_kunnr , "Ship-to-Party
*  s_matnr FOR gv_matnr . "Material
*SELECTION-SCREEN END OF BLOCK b1.
*<-- End of delete for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018

*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS : rb_d2 RADIOBUTTON GROUP rab1 DEFAULT 'X' USER-COMMAND ucomm.
SELECT-OPTIONS:
  s_vkorg FOR gv_vkorg MODIF ID m1,   "Sales Organization
  s_vtweg FOR gv_vtweg MODIF ID m1,   "Distribution Channel
  s_spart FOR gv_spart MODIF ID m1,   "Division
  s_auart FOR gv_auart MODIF ID m1,   "Sales Doc Type
  s_vbeln FOR gv_vbeln MODIF ID m1,   "Sales Order Number
  s_erdat FOR gv_erdat MODIF ID m1,   "Sales Order Creation Date
  s_deldat FOR gv_deldat MODIF ID m1, " Requested Delivery Date
  s_kunag FOR gv_kunag NO INTERVALS   "Sold-to-Party
                       NO-EXTENSION MODIF ID m1,
  s_kvgr1 FOR gv_kvgr1 NO INTERVALS   "Customer Group1
                       NO-EXTENSION MODIF ID m1,
  s_kvgr2 FOR gv_kvgr2 NO INTERVALS   "Customer Group2
                       NO-EXTENSION MODIF ID m1,
  s_kunnr FOR gv_kunnr MODIF ID m1,   "Ship-to-Party
  s_matnr FOR gv_matnr MODIF ID m1.   "Material
PARAMETERS : rb_d3 RADIOBUTTON GROUP rab1.
SELECT-OPTIONS:
  s_vkorg1 FOR gv_vkorg MODIF ID m2, "Sales Organization
  s_vtweg1 FOR gv_vtweg MODIF ID m2, "Distribution Channel
  s_spart1 FOR gv_spart MODIF ID m2, "Division
  s_auart1 FOR gv_auart MODIF ID m2, "Sales Doc Type
*--> Begin of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  s_wadat  FOR gv_wadat MODIF ID m2, "Actual GI date
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400_FUT Issues by AMOHAPA on 25-Oct-2018
  s_vbeln1 FOR gv_vbeln MODIF ID m2, "Sales Order Number
  s_lfart  FOR gv_lfart MODIF ID m2. "Delivery Type
SELECTION-SCREEN END OF BLOCK b1.
*<-- End of insert for D3_OTC_EDD_0101_Defect#3400(Part 2) by AMOHAPA on 08-Aug-2018
