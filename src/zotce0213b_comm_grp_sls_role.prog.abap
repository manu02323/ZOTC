*&---------------------------------------------------------------------*
*& Report  ZOTCE0213B_COMM_GRP_SLS_ROLE
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0213B_COMM_GRP_SLS_ROLE                           *
* TITLE      :  D2_OTC_EDD_0213_Commision Group Sales Role assignment  *
* DEVELOPER  :  NLIRA (Nic Lira)                                       *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Update table ZOTC_TERRIT_ASSN from tab delimited file.  *
* Program uploads a tab delimited local file into internal table.
* Numeric fields are left padded with zeros so they match the values in
* the check tables.
* Some fields are validated against the check tables.
* If the validation fails, an error is generated for each of the failed
* validations.
* Good records are appended to an internal table.
* After all records are processed, the custom table ZOTC_TERRIT_ASSN is
* updated (with MODIFY command) from the good records internal table.
* The errors are sent to ALV Grid report.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 29-Sep-2014  NLIRA   E2DK904939 Initial development                  *
*&---------------------------------------------------------------------*
* 28-APR-2016 SBEHERA  E2DK917651  Defect#1461: 1.Validation Customer  *
*                                    with sales area                   *
*                                  2.Validate customer not to allow an *
*                                    entry with account group ZREP     *
*&---------------------------------------------------------------------*
* 19-JUL-2016 PDEBARU E2DK917651  Defect # 1461 : Fut Issue : change   *
*                                  pointer included                    *
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
*&---------------------------------------------------------------------*
* 02-Aug-2017 U029267 E1DK927361  Defect#2496_Part2 : FUT issue:       *
*                                 Authorization check added for        *
*                                 updating table.                      *
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
*&---------------------------------------------------------------------*


REPORT zotce0213b_comm_grp_sls_role
       MESSAGE-ID zotc_msg
       NO STANDARD PAGE HEADING LINE-SIZE 132.

INCLUDE zotce0213b_comm_grp_sls_rl_top. " Include ZLEXE0070_STORAGEBIN_TOP

* Common Include
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
* Selection Screen parameters
INCLUDE zotce0213b_comm_grp_selection. " Include ZOTCE0213B_COMM_GRP_SELECTION
* Forms for processing
INCLUDE zotce0213b_comm_grp_forms. " Include ZOTCE0213B_COMM_GRP_FORMS

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_select_from_prsoraps.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filepr.
* Get file location and name for loading.
  PERFORM f_get_filename.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fileap.
* F4 help for application server
  PERFORM f_help_as_path CHANGING p_fileap.
* Check the existance of application server file
AT SELECTION-SCREEN ON p_fileap.
  IF rb_ap = c_true AND p_fileap IS NOT INITIAL.
* Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_fileap.
  ENDIF. " IF rb_ap = c_true AND p_fileap IS NOT INITIAL

START-OF-SELECTION.
*<-- Begin of Insert for D3_OTC_EDD_0213_Defect#2496_Part2 by U029267 on 02-Aug-2017
  PERFORM f_authorization_check.
*--> End of Insert for D3_OTC_EDD_0213_Defect#2496_Part2 by U029267 on 02-Aug-2017

  IF rb_pr EQ abap_true
  AND sy-batch EQ abap_false.
*   Upload from local file
    PERFORM f_upload_filedata_ps.
*   Upload from application server (must be CSV file)
  ELSEIF rb_ap EQ abap_true.
    PERFORM f_upload_filedata_ap.
  ENDIF. " IF rb_pr EQ abap_true

* Process the file
  PERFORM f_process_inbound_file.

* ---> Begin of Delete for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
***--> Begin of change for D2_OTC_EDD_0213 Defect # 1461 by PDEBARU on 19/07/2016
*  PERFORM f_chg_pointer USING i_territory_assn3.
***<-- End of change for D2_OTC_EDD_0213 Defect # 1461 by PDEBARU on 19/07/2016
* <--- End of Delete for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017
* ---> Begin of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017

* ---> Begin of Insert for D3_OTC_EDD_0213 D3R2
  IF cb_chk EQ 'X'.
    PERFORM f_call_bd12_prog USING i_territory_assn3.
  ENDIF.
* ---> End of Insert for D3_OTC_EDD_0213 D3R2

* <--- End of Insert for D3_OTC_EDD_0213_Defect#2496 by U029267 on 27-Apr-2017


  IF i_display_data[] IS NOT INITIAL.
    PERFORM f_display_alv.
  ENDIF. " IF i_display_data[] IS NOT INITIAL

END-OF-SELECTION.
* Moving the file to done or error folder.
  IF rb_ap IS NOT INITIAL.
    PERFORM f_movefile USING p_fileap.
  ENDIF. " IF rb_ap IS NOT INITIAL
* if it has the error records and getting file from application server.
  IF gv_ecount IS NOT INITIAL
  AND rb_ap IS NOT INITIAL.
* Write the error records in error file
    PERFORM f_write_error_file .
  ENDIF. " IF gv_ecount IS NOT INITIAL

* Check whether the program is being processed in background or foreground.
  IF sy-batch EQ abap_true.
* Now show the summary report
    PERFORM f_display_summary_report3 USING  i_log
                                            p_fileap
                                            gv_mode
                                            gv_scount
                                            gv_ecount.
  ENDIF. " IF sy-batch EQ abap_true
