*&**********************************************************************
* PROGRAM    :  ZOTCE0398B_DET_BATCHES_BACKG                           *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials in background   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER        TRANSPORT         DESCRIPTION                *
* 11-OCT-2018  APODDAR   E1DK938946      Initial Development           *
* =========== ======== ========== =====================================*

REPORT zotce0398b_det_batches_backg
      NO STANDARD PAGE HEADING
       MESSAGE-ID zotc_msg LINE-SIZE  132
                        LINE-COUNT 63(5).

*Data Declaration Include
INCLUDE: zotcn0398b_det_batches_top. " Top Include
*Screen Design Include
INCLUDE: zotcn0398b_det_batches_scr. " Screen Include
* Subroutine Include
INCLUDE: zotcn0398b_det_batches_sub. " Subroutine Include

START-OF-SELECTION.

*&-->Begin of change for D3_OTC_EDD_0398 Defect# 7289_FUT_ISSUE by SMUKHER4 on 17-Jan-2019
     gv_repid = sy-repid.
*&<--Begin of change for D3_OTC_EDD_0398 Defect# 7289_FUT_ISSUE by SMUKHER4 on 17-Jan-2019

  IMPORT i_log_backg[] FROM DATABASE indx(zs) ID 'ZIDY' TO wa_indx .
  DELETE FROM DATABASE indx(zs) ID 'ZIDY'.

 "Read Data Set from App Server to Internal Table
  PERFORM f_read_dataset USING p_apsfil
                        CHANGING i_final_output.


* Lock and Update Sales Orders one by one
  PERFORM f_lock_update_so CHANGING  i_final_output[]
                                     i_log_char[].

*&--Read the job status for cancelled job and send the mail

  PERFORM f_cancel_job  USING p_jobnam
                              p_jobnum.

*&--Fill the log table to be displayed
  PERFORM f_fill_log     USING    i_log_backg[]
                         CHANGING i_log_char[].

*&--Distinguish the error and success records after posting
  PERFORM f_get_records USING i_final_output
                              i_log_char
                        CHANGING i_elog
                                 i_slog.
 "Write Error Log back to Application Server
  PERFORM f_fail_log_aps USING i_elog
                               p_apsfil.

 "Write Success Log back to Application Server
  PERFORM f_succs_log_aps USING i_slog
                                p_apsfil.


*&-->The processed records will be write in the DONE folder.

  PERFORM f_move_files USING p_apsfil.

END-OF-SELECTION.

  IF i_log_char IS NOT INITIAL.
    PERFORM f_display_summary USING i_log_char[].
  ENDIF. " IF i_log_char IS NOT INITIAL

 "Send Mail with Processing Details
  PERFORM f_send_job_details USING i_log_char[]
                                   i_elog[]
                                   i_slog[]
                                   p_jobnam
                                   p_jobnum.
