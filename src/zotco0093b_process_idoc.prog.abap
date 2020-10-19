*&---------------------------------------------------------------------*
*& Report  ZOTCO0093B_PROCESS_IDOC
*&
*&--------------------------------------------------------------------*
*Report              :  ZOTCO0093B_PROCESS_IDOC                       *
* TITLE              :  get active change pointer and delete          *
* DEVELOPER          :  Deepanker Dwivedi                             *
* OBJECT TYPE        :  INTERFACE                                     *
* SAP RELEASE        :  SAP ECC 6.0                                   *
*---------------------------------------------------------------------*
* WRICEF ID          :  D3_OTC_IDD_0093                               *
* Transport          :  E1DK918891
*---------------------------------------------------------------------*
* DESCRIPTION:   This application is to submit RSEOUT00 program into  *
*                 various job based on IDOC counts for each job       *
*---------------------------------------------------------------------*

REPORT zotco0093b_process_idoc NO STANDARD PAGE HEADING
                               LINE-SIZE 132
                               LINE-COUNT 100
                               MESSAGE-ID zotc_msg.

INCLUDE zotcn0093b_process_idoc_top. " Include ZOTC0093_PROCESS_TOP

INCLUDE zotcn0093b_process_idoc_sel. " Include ZOTC0093_DATA_SEL

*INITIALIZATION .

START-OF-SELECTION .

  PERFORM select_edidc.

  IF gwa_msgty IS NOT INITIAL.
    gwa_msgty[] = s_mestyp[].
  ENDIF. " if lwa_msgty is not INITIAL

  DESCRIBE TABLE git_edidc LINES gv_line .

  gv_max = p_max.
  IF gv_line  IS NOT INITIAL .
    IF gv_line > gv_max .
      gv_job_count = gv_line DIV gv_max.
      LOOP AT git_edidc INTO gwa_edidc.
*    *    prepare table .
        gwa_idoc-sign = 'I'.
        gwa_idoc-option = 'EQ'.
        gwa_idoc-low = gwa_edidc-docnum .
        APPEND gwa_idoc TO git_idoc.
*    conters
        gv_last = gv_last + 1 .
        gv_current_rc = gv_current_rc + 1.
        gv_count = gv_current_rc .

        IF gv_count = gv_max.
          gv_subm_count = gv_subm_count + 1.
          PERFORM submit_job_rseout00 .
          CLEAR :   gv_count,
                     gv_current_rc,
                     git_idoc.
          REFRESH :git_idoc .
        ELSEIF gv_last = gv_line .
*          IF gv_last = gv_line.
            gv_subm_count = gv_subm_count + 1.
            PERFORM submit_job_rseout00 .
            CLEAR :   gv_count,
                      gv_current_rc,
                      git_idoc.
            REFRESH :git_idoc .
*          ENDIF. " IF gv_last = gv_line
        ENDIF. " IF gv_count = gv_max

      ENDLOOP . " LOOP AT git_edidc INTO gwa_edidc
    ELSEIF gv_max >= gv_line .
      LOOP AT git_edidc INTO gwa_edidc.
*    *    prepare table .
        gwa_idoc-sign = 'I'.
        gwa_idoc-option = 'EQ'.
        gwa_idoc-low = gwa_edidc-docnum .
        APPEND gwa_idoc TO git_idoc.
*    conters
        gv_last = gv_last + 1 .
        gv_current_rc = gv_current_rc + 1.
        gv_count = gv_current_rc .

        IF gv_last = gv_line.
          gv_subm_count = gv_subm_count + 1.
          PERFORM submit_job_rseout00 .
          CLEAR :   gv_count,
                    gv_current_rc,
                    git_idoc.
          REFRESH :git_idoc .
        ENDIF. " IF gv_last = gv_line
      ENDLOOP . " LOOP AT git_edidc INTO gwa_edidc
    ENDIF. " IF gv_line > gv_max
  ENDIF. " IF gv_line IS NOT INITIAL

  IF gv_line IS INITIAL .
    WRITE text-007.
  ELSE . " ELSE -> IF gv_line IS INITIAL
    WRITE text-008 . "Follwoing Background Jobs are created and submitted for processing
    ULINE.
    SKIP .
    LOOP AT git_job INTO gwa_job.
      WRITE:/ gwa_job-jobname,   '     ',  gwa_job-count, text-009.
    ENDLOOP. " LOOP AT git_job INTO gwa_job
  ENDIF. " IF gv_line IS INITIAL
