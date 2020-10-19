*&---------------------------------------------------------------------*
*& Report  ZOTCI0217B_RIBA_OUTB_CITI_BANK
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0217B_RIBA_OUTB_CITI_BANK                         *
* TITLE      :  Interface for RIBA Payments Italy Outbound CITI Bank   *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    R3. D3_OTC_IDD_0217_RIBA_ITALY_Outbound-CITI Bank      *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Interface generate the payment medium files from  *
*               SAP system with RIBA (payment method R) Payment method *
*               based on the due date of customer open invoices        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
*18-Apr-2018  U033876   E1DK936113   Initial Development               *
*----------------------------------------------------------------------*
*16-May-2018  U033876   E1DK936113   Defect 6115 :Fixes to file name   *
*----------------------------------------------------------------------*
REPORT zotci0217b_riba_outb_citi_bank NO STANDARD PAGE HEADING
                                     LINE-SIZE 132
                                     MESSAGE-ID zotc_msg.

************************************************************************
*               INCLUDE DECLARATION
************************************************************************
INCLUDE  zdevnoxxx_common_include. "Common include
* Top Include
INCLUDE zotcn0217b_riba_citi_bank_top. " Include ZOTCN0217B_RIBA_CITI_BANK_TOP

*Include for selection screen
INCLUDE zotcn0217b_riba_citi_bank_sel. " " Include ZOTCN0217B_RIBA_CITI_BANK_SEL

*Include for forms
INCLUDE zotcn0217b_riba_citi_bank_form. " Include ZOTCN0217B_RIBA_CITI_BANK_FORM


*----------------------------------------------------------------------*
*           I N I T I A L I Z A T I O N                                *
*----------------------------------------------------------------------*
INITIALIZATION.
*&& -- Fetch data from EMI
PERFORM f_retrieve_data_emi CHANGING gv_file
                                     gv_pfile.

*----------------------------------------------------------------------*
*     AT SELECTION SCREEN OUTPUT
*--------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
*Hide / Unhide Screen based on user selection
  PERFORM f_modify1_screen.

************************************************************************
*     AT SELECTION SCREEN ON
************************************************************************
AT SELECTION-SCREEN ON p_phdr.
  IF p_phdr IS NOT INITIAL.
    CLEAR gv_extn.
*Check for text file
    PERFORM f_file_extn_check USING p_phdr
                              CHANGING gv_extn.
    IF gv_extn <> c_extn.
      MESSAGE e000 WITH 'Please provide text file for presentation server.'(007). " & & & &
    ENDIF. " IF gv_extn <> c_extn
  ENDIF. " IF p_phdr IS NOT INITIAL

* Begin of change for Defect 6115 by U033876
* Not required as we concatenate the file name at end of file generation
*AT SELECTION-SCREEN ON p_ahdr.
*  IF  p_ahdr IS NOT INITIAL.
*    CLEAR gv_extn.
**Check for text file
*    PERFORM f_file_extn_check USING p_ahdr
*                              CHANGING gv_extn.
*    IF gv_extn <> c_extn.
*      MESSAGE e000  WITH 'Please provide text file for application server.'(008). " & & & &
*    ENDIF. " IF gv_extn <> c_extn
*  ENDIF. " IF p_ahdr IS NOT INITIAL
* End of change for Defect 6115 by U033876

*----------------------------------------------------------------------*
*     AT SELECTION SCREEN ON VALUE REQUEST
*----------------------------------------------------------------------*

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_phdr.
  PERFORM f_help_l_path CHANGING p_phdr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_ahdr.
  PERFORM f_help_as_path CHANGING p_ahdr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_laufi.
  PERFORM f_f4_help_iden.

************************************************************************
*        Start-of-selection Event
************************************************************************
START-OF-SELECTION.

  PERFORM f_get_payment_data USING p_laufd p_laufi
                             CHANGING i_reguh
                                      i_regup
                                      i_kna1
                                      i_knb1
                                      i_t001
                                      i_adrc.

  PERFORM f_fill_rec_strc USING i_reguh
                                i_regup
                                i_kna1
                                i_knb1
                                i_t001
                                i_adrc
                          CHANGING    wa_header
                                      wa_14_disp
                                      wa_20_odesc
                                      wa_30_db_info
                                      wa_40_db_add
                                      wa_50_db_notes
                                      wa_51_pir_info
                                      wa_70_ck_detail
                                      wa_trailer
                                      i_final.


************************************************************************
*        End-of-selection Event
************************************************************************
END-OF-SELECTION.

* Using Final internal table move the content to Application server.

  IF p_ahdr IS NOT INITIAL.
*&& -- Write Output in Application Server File
    PERFORM f_write_app_data USING p_ahdr
                                   i_final
                             CHANGING i_log.

  ELSEIF p_phdr IS NOT INITIAL.
*&& -- Write Output in Presentation Server File
    PERFORM f_write_pres_data USING i_final
                              CHANGING  p_phdr
                                        i_data
                                        i_log.
  ENDIF. " IF p_ahdr IS NOT INITIAL


  IF i_log[] IS NOT INITIAL.
*&--Write log
    PERFORM f_write_log USING i_log.
  ENDIF. " IF i_log[] IS NOT INITIAL
