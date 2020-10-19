***********************************************************************
*Program    : ZOTCI0216B_SEND_TRANSFER_PRICE                          *
*Title      : D3_OTC_IDD_0216_SEND TRANSFER PRICE TO EXTERNAL SYSTEM  *
*Developer  : Amlan mohapatra                                         *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_IDD_0216                                          *
*---------------------------------------------------------------------*
*Description: SEND TRANSEFER PRICE TO EXTERNAL  SYSTEM                *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport         Description
*=========== ============== ============== ===========================*
*02-NOV-2017   AMOHAPA      E1DK931691        Initial development
*22-DEC-2017   AMOHAPA      E1DK931691       FUT_ISSUE: MVKE needs to  *
*                                            be filtered from EMI entry*
*                                            Distribution-chain-specif-*
*                                            ic material status        *
*12-FEB-2018   AMOHAPA      E1DK931691       FUT_ISSUE: File Name      *
*                                            should be populated as    *
*                                            IDD_0216_YYYYMMDD_Running *
*                                            number in AL11            *
*----------------------------------------------------------------------*



REPORT zotci0216b_send_transfer_price NO STANDARD PAGE HEADING
                                      MESSAGE-ID zotc_msg
                                      LINE-COUNT 145
                                      LINE-SIZE 132.

INCLUDE zotcn0216b_send_tran_price_top. " Include ZOTCN0216B_SEND_TRAN_PRICE_TOP

INCLUDE zotcn0216b_send_tran_price_sel. " Include ZOTCN0216B_SEND_TRAN_PRICE_SEL

INCLUDE zotcn0216b_send_tran_price_sub. " Include ZOTCN0216B_SEND_TRAN_PRICE_SUB

*----------------------------------------------------------
*   INITIALIZATION                                        *
*----------------------------------------------------------
INITIALIZATION.

 "Clearing Global Variables

  PERFORM f_clear_global_data.

  PERFORM f_folder_path_name.

*----------------------------------------------------------
*  AT SELECTION SCREEN OUTPUT                             *
*----------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.

  PERFORM f_sel_modify.

*-----------------------------------------------------------
*    AT SELECTION SCREEN VALIDATION                        *
*-----------------------------------------------------------

 "Validation for slaes organization

AT SELECTION-SCREEN ON p_vkorg.

  PERFORM f_validation_sales_org.

 "Validation for Distribution Channel

AT SELECTION-SCREEN ON p_vtweg.

  PERFORM f_validation_dist_channel.

 "Validation for Division

AT SELECTION-SCREEN ON p_spart.

  PERFORM f_validation_sales_division.

 "Validation for Customer

AT SELECTION-SCREEN ON p_kunnr.

  PERFORM f_validation_customer.

*-->Begin of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018
 "Validating Material Type

AT SELECTION-SCREEN ON s_mtart.
  IF s_mtart[] IS NOT INITIAL.
    PERFORM f_vaildation_mat_type.
  ENDIF. " IF s_mtart[] IS NOT INITIAL
*<--End of Insert for D3_OTC_IDD_0216_R2_FUT_Issue by AMOHAPA on 23-Mar-2018

 "Validation for Material group

AT SELECTION-SCREEN ON s_kondm.

  IF s_kondm[] IS NOT INITIAL.
    PERFORM f_validation_mat_group.
  ENDIF. " IF s_kondm[] IS NOT INITIAL

 "Validation for Material

AT SELECTION-SCREEN ON s_matnr.
  IF s_matnr[] IS NOT INITIAL.
    PERFORM f_validation_material.
  ENDIF. " IF s_matnr[] IS NOT INITIAL


*--------------------------------------------------
*    START OF SELECTION                          *
*--------------------------------------------------
START-OF-SELECTION.

 "Combine validation for Customer, sales organisation, Distribution channel and Division

  IF p_vkorg IS NOT INITIAL AND
     p_vtweg IS NOT INITIAL AND
     p_spart IS NOT INITIAL AND
     p_kunnr IS NOT INITIAL.

    PERFORM f_validate_combination_cust.

  ENDIF. " IF p_vkorg IS NOT INITIAL AND

  PERFORM f_get_emi_entry CHANGING i_status[]
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                                   i_vmsta[]. " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

  IF rb_dl IS NOT INITIAL.

 "Change date in the section screen is mandatory if delta load mode is selected
    IF s_cdate[] IS INITIAL.
 "Change date is required.
      MESSAGE i895.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF s_cdate[] IS INITIAL

 "Populating MVKE table for DELTA load

    PERFORM f_get_recods_delta_load USING    i_status[]
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                                             i_vmsta[] " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                                    CHANGING i_cdhdr[]
                                             i_cdpos[]
                                             i_mvke[].



  ELSEIF rb_fl IS NOT INITIAL.

 "Populating MVKE table for Full load
    PERFORM f_get_records_mvke
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                                USING    i_vmsta[] " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
                                CHANGING i_mvke[]
                                         i_mbew[]
                                         i_mvke_pt[].

  ENDIF. " IF rb_dl IS NOT INITIAL

*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
  IF i_mvke IS INITIAL.
 "If there is no records found in MVKE then the program
 "should not execute more steps
    MESSAGE i138.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF i_mvke IS INITIAL
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

*--------------------------------------------------
*    END OF SELECTION                             *
*--------------------------------------------------

END-OF-SELECTION.

 "Populating the Internal table for MVKE with plant in first position

  IF rb_dl IS NOT INITIAL.

    PERFORM f_make_mvke_plant  USING    i_mvke
                               CHANGING i_mvke_pt.

  ENDIF. " IF rb_dl IS NOT INITIAL

 "Sending the materials with pack of plants into SDNETPRO
 "to populate the final output table
 "Logic is added in the below perform to send 5000 records at one go
 "while submitting the standard program SDNETPR0



  PERFORM f_send_to_sdnetpro USING    i_mvke_pt[]
                                      i_status[]
                                      i_mbew[]
                             CHANGING i_final[].

 "Populating Final error internal table using various condition
 " with zero netprice,Not found entry in MBEW and Plant is initial in MVKE

  PERFORM f_get_error_entry USING    i_final
                            CHANGING i_error[].



  IF i_final[] IS NOT INITIAL.

    IF rb_alv IS NOT INITIAL.

      PERFORM f_prepare_fieldcat CHANGING i_fieldcat[].

      PERFORM f_display_alv USING i_fieldcat[]
                                  i_final[].
    ELSEIF rb_file IS NOT INITIAL.

      IF p_path IS NOT INITIAL.

 "Upload the output in Text File format in AL11 in the given directory

        PERFORM f_appl_server_upload USING i_final[]
                                           i_error[].


      ENDIF. " IF p_path IS NOT INITIAL

    ENDIF. " IF rb_alv IS NOT INITIAL

  ELSE. " ELSE -> IF i_final[] IS NOT INITIAL

 "If no records found to populate the final internal table

    MESSAGE i138.
    LEAVE LIST-PROCESSING.

  ENDIF. " IF i_final[] IS NOT INITIAL
