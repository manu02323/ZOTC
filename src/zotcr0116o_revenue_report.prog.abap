*&---------------------------------------------------------------------*
*& Report  ZOTCR0116O_REVENUE_REPORT
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0116O_REVENUE_REPORT                              *
* TITLE      :  End to End Revenue Report                              *
* DEVELOPER  :  RAGHAV SUREDDI                                         *
* OBJECT TYPE:  REPORT                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0116_REVENUE_REPORT                              *
*----------------------------------------------------------------------*
* DESCRIPTION: This Report can be utilized by users to track Revenue   *
*               Documents created on a specific date or within a date  *
*               range. The report will provide all key information     *
*               about the Revenue.                                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Nov-2017 U033876   E1DK934630 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 11-Apr-2018 MGARG/    E1DK934630 Defect#4360                         *
*             U024694              Fix performance Issue, Add Search   *
*                                  help and change the description of  *
*                                  column headings.                    *
*&---------------------------------------------------------------------*
REPORT zotcr0116o_revenue_report  MESSAGE-ID zotc_msg
                                            LINE-COUNT 80000
                                            LINE-SIZE 1023
                                            NO STANDARD PAGE HEADING.

************************************************************************
*          DATA DECLARATION INCLUDE                                    *
************************************************************************
INCLUDE zotcn0116o_revenue_report_top. " Data Declarations Include ZOTCN0116O_REVENUE_REPORT_TOP

************************************************************************
*          SELECTION SCREEN DECLARATION INCLUDE                        *
************************************************************************
INCLUDE zotcn0116o_revenue_report_scr. " Selection screen Include ZOTCN0116O_REVENUE_REPORT_SCR

************************************************************************
*          FORM SUBROUTINE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0116o_revenue_report_form. " Form Subroutines Include ZOTCN0116O_REVENUE_REPORT_FORM

************************************************************************
*          Selection screen processing INCLUDE                                          *
************************************************************************
INCLUDE zotcn0116o_revenue_report_sel. " Selection screen Include ZOTCN0116O_REVENUE_REPORT_SEL

************************************************************************
*          MAIN CODE INCLUDE                                          *
************************************************************************
INCLUDE zotcn0116o_revenue_report_sub. " Include ZOTCN0116O_REVENUE_REPORT_SUB
