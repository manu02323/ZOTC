*&---------------------------------------------------------------------*
*& Report       ZOTCC0005B_CONV_SALES_CONTRACT
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCC0005B_CONV_SALES_CONTRACT                         *
* TITLE      :  Convert Open Reagent Rental and Service Contracts      *
* DEVELOPER  :  Manikandan Pounraj                                     *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0005_Convert Open Reagent Rental                 *
*             and Service Contracts                                    *
*----------------------------------------------------------------------*
* DESCRIPTION: Updating sales contract                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT      DESCRIPTION                     *
* =========== ======== ========== =====================================*
* 03-JULY-2012 MPOUNRA  E1DK901606 INITIAL DEVELOPMENT                 *
* 07-Oct-2014  SMEKALA  E2DK905508 D2:Service Contracts will no longer *
*                                  be used and the scope of conversions*
*                 would only be limited to Reagent Rental Contracts.   *
*&---------------------------------------------------------------------*

REPORT  zotcc0005b_conv_sales_contract
        NO STANDARD PAGE HEADING
        LINE-SIZE 132
        LINE-COUNT 80
        MESSAGE-ID zotc_msg.

************************************************************************
*---- INCLUDES --------------------------------------------------------*
************************************************************************
* Top Include
INCLUDE zotcn0005b_sales_contract_top. " Include ZOTCN0005B_SALES_CONTRACT_TOP
* Selection Screen Include
INCLUDE zdevnoxxx_common_include. " Include ZDEVNOXXX_COMMON_INCLUDE
*Include for selection screen having a file to process
INCLUDE zotcn0005b_sales_contract_scr. " Include ZOTCN0005B_SALES_CONTRACT_SCR
* Include for all subroutines
INCLUDE zotcn0005b_sales_contract_sub. " Include ZOTCN0005B_SALES_CONTRACT_SUB

***********************************************************************
*---- INITIALIZATION
*--------------------------------------*
***********************************************************************
INITIALIZATION.
*-- Begin of change D2
* To idntify the mode of updation whether its of external or internal
*  PERFORM f_insertion_fmt CHANGING gv_val.
  PERFORM f_insertion_fmt USING i_val.
*-- End of change D2

************************************************************************
*---- AT-SELECTION-SCREEN OUTPUT --------------------------------------*
************************************************************************

AT SELECTION-SCREEN OUTPUT.
*   Modify the screen based on User action.
  PERFORM f_modify_screen.

************************************************************************
*---- AT-SELECTION-SCREEN VALUE REQUEST -------------------------------*
************************************************************************

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pfile.
  PERFORM f_help_l_path CHANGING p_pfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_afile.
  PERFORM f_help_as_path CHANGING p_afile.

***********************************************************************
*--- AT-SELECTION-SCREEN VALIDATION ----------------------------------*
***********************************************************************

*Validating Input File - Presentation Server
AT SELECTION-SCREEN ON p_pfile.
  IF rb_pres = c_true.
    IF p_pfile IS NOT INITIAL.
*Validating the File Name
      PERFORM f_validate_p_file USING p_pfile.
*Checking for ".TXT" extension.
      PERFORM f_check_extension USING p_pfile.
    ENDIF. " IF p_pfile IS NOT INITIAL
  ENDIF. " IF rb_pres = c_true

* Validating Input File - Application Server
AT SELECTION-SCREEN ON p_afile.
  IF p_afile IS NOT INITIAL.
*Checking for ".TXT" extension.
    PERFORM f_check_extension USING p_afile.
  ENDIF. " IF p_afile IS NOT INITIAL

************************************************************************
*---- START-OF-SELECTION ----------------------------------------------*
************************************************************************

START-OF-SELECTION.
*  Checking on File Input.
  PERFORM f_check_input.

*   Uploading the files from Presentation Server
  IF rb_pres IS NOT INITIAL.
    gv_contract = p_pfile.

*     Uploading the file from Presentation Server
    PERFORM f_upload_presnt_files USING gv_contract
                               CHANGING i_contract[].
  ENDIF. " IF rb_pres IS NOT INITIAL

*   Uploading the files from Application Server
  IF rb_app IS NOT INITIAL.
*     If Logical File option is selected.
    IF rb_alog IS NOT INITIAL.
*       Retriving physical file paths from logical file name
      PERFORM f_logical_to_physical USING p_alog
                                 CHANGING gv_contract.
    ELSE. " ELSE -> IF rb_alog IS NOT INITIAL
      gv_contract = p_afile.
    ENDIF. " IF rb_alog IS NOT INITIAL
*     Uploading the file from Application Server
    PERFORM f_upload_applcn_files USING gv_contract
                               CHANGING i_contract[].
  ENDIF. " IF rb_app IS NOT INITIAL

*  Checking whether the uploaded file is empty or not. If empty, then
*   Stop the execution of program
  IF i_contract IS INITIAL.
*   Input file contains no record. Please check your entry.
    MESSAGE i012. " Input file contains no record.Please check entry
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_contract IS INITIAL
*-- Begin of addition D2
    PERFORM f_fill_chgcon USING i_contract
                          CHANGING i_chgcon.
*-- End of addition D2
  ENDIF. " IF i_contract IS INITIAL

* Performing Validations on the input data
  PERFORM f_validation USING  i_chgcon
                     CHANGING i_error
                              i_final
                              gv_scount
                              gv_ecount
                              i_report.

*-- Begin of D2
  REFRESH i_chgcon.
  PERFORM f_fill_chgcon USING i_final
                        CHANGING i_chgcon.
*-- End of D2
  IF rb_post IS NOT INITIAL.
* Uploading data using the function module " BAPI_CONTRACT_CREATEFROMDATA"
    PERFORM f_uploading_fm USING   i_chgcon[]
                          CHANGING i_error[]
                                   gv_ecount
                                   gv_scount
                                   i_report
                                   i_tsn[].
* Uploading data using the Call Transaction " VA42 "
    PERFORM f_uploading_tsn USING  i_tsn[]
                          CHANGING i_report.

  ENDIF. " IF rb_post IS NOT INITIAL

************************************************************************
*---- END-OF-SELECTION ----------------------------------------------*
************************************************************************

END-OF-SELECTION.

*   In case the file was uploaded from Application server, then
*   Moving them in Processed / Error folder depending upon Final
*   Status of Posting.
  IF rb_app IS NOT INITIAL AND
     rb_post IS NOT INITIAL.
*     If Posting is done, then moving the files to DONE folder
*       Moving Input File
    PERFORM f_move USING gv_contract.

*       Moving Error File
    IF i_error IS NOT INITIAL.
      PERFORM f_move_error USING gv_contract
                                 i_error[].
    ENDIF. " IF i_error IS NOT INITIAL

  ENDIF. " IF rb_app IS NOT INITIAL AND

* Choose the Mode
  IF rb_post = c_rbselected .
    gv_mode = 'Post Run'(019).
  ELSE. " ELSE -> IF rb_post = c_rbselected
    gv_mode = 'Test Run'(020).
  ENDIF. " IF rb_post = c_rbselected

* For suppressing the report table, since the same material may holding
* different information.
* If the same error existing, no need of reporting again, thats why
* we are deleting the repetative report message
  IF i_report IS NOT INITIAL.
*-- begin of changes D2
    SORT i_report BY
            ref_doc
            doc_type
            sales_org
            distr_chan
            division
            partn_role1
            partn_numb1
            partn_role2
            partn_numb2
            con_st_dat
            con_en_dat
            material
            doc_flg
            sales_doc
            equi_flg
            msgtxt.
*-- End of changes D2
    DELETE ADJACENT DUPLICATES FROM i_report COMPARING ALL FIELDS.
  ENDIF. " IF i_report IS NOT INITIAL

*   Displaying The Log Report
  IF i_report[] IS NOT INITIAL.
    PERFORM f_display_report USING  i_report
                                    gv_contract
                                    gv_mode
                                    gv_scount
                                    gv_ecount.
  ENDIF. " IF i_report[] IS NOT INITIAL
