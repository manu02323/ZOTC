*&---------------------------------------------------------------------*
*&  Include           ZOTCO0093B_PROCESS_IDOC_SEL
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
* Report             :  ZOTC0093_DATA_SEL                             *
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
* 5-Dec-2019 U106341   E1SK901643   HANAtization changes
*---------------------------------------------------------------------*

FORM select_edidc.

  gv_direction = '1'.
  gv_select_all_use = 'Y'.
  LOOP AT s_docnum.
    IF s_docnum-sign NE 'I' OR s_docnum-option NE 'EQ'.
      gv_select_all_use = 'N'.
      EXIT.
    ENDIF. " IF s_docnum-sign NE 'I' OR s_docnum-option NE 'EQ'
  ENDLOOP. " LOOP AT s_docnum
  IF sy-subrc NE 0.
    gv_select_all_use = 'N'.
  ELSE. " ELSE -> IF sy-subrc NE 0

  ENDIF. " IF sy-subrc NE 0
  IF gv_direction = '1'.
    IF gv_select_all_use = 'N'.
      SELECT docnum FROM edidc INTO TABLE git_edidc
        WHERE       upddat >= s_credat-low
        AND         docnum  IN s_docnum
        AND         status  IN s_status
        AND         direct  = gv_direction
        AND         idoctp  IN s_idoctp
        AND         cimtyp  IN s_cimtyp
        AND         mestyp  IN s_mestyp
        AND         mescod  IN s_mescod
        AND         mesfct  IN s_mesfct
        AND         credat  IN s_credat
        AND         cretim  IN s_cretim
        AND         upddat  IN s_upddat
        AND         updtim  IN s_updtim .
      IF sy-subrc = 0.
        "Do nothing
      ENDIF. " IF sy-subrc = 0
          " Sortierung ist schon erfolgt
    ELSE. " ELSE -> IF gv_select_all_use = 'N'
*&-- Begin of changes for HANAtization on OTC_IDD_0093 by U106341 on 5 Dec 2019 in E1SK901643
    IF S_DOCNUM[] IS NOT INITIAL.
*&-- End of changes for HANAtization on OTC_IDD_0093 by U106341 on 5 Dec 2019 in E1SK901643
      SELECT docnum FROM edidc INTO TABLE git_edidc
                  FOR ALL ENTRIES IN s_docnum
        WHERE       upddat >= s_credat-low
        AND         docnum  =  s_docnum-low
        AND         status  IN s_status
        AND         direct  = gv_direction
        AND         idoctp  IN s_idoctp
        AND         cimtyp  IN s_cimtyp
        AND         mestyp  IN s_mestyp
        AND         mescod  IN s_mescod
        AND         mesfct  IN s_mesfct
        AND         credat  IN s_credat
        AND         cretim  IN s_cretim
        AND         upddat  IN s_upddat
        AND         updtim  IN s_updtim
      ORDER BY PRIMARY KEY. " Sortierung ist schon erfolgt
      IF sy-subrc = 0.
        "Do nothing
      ENDIF. " IF sy-subrc = 0
*&-- Begin of changes for HANAtization on OTC_IDD_0093 by U106341 on 5 Dec 2019 in E1SK901643
    ENDIF.
*&-- End of changes for HANAtization on OTC_IDD_0093 by U106341 on 5 Dec 2019 in E1SK901643
    ENDIF. " IF gv_select_all_use = 'N'
  ELSEIF gv_direction EQ '2'.
* Do nothing .
  ENDIF. " IF gv_direction = '1'
ENDFORM. "SELECT_EDIDC
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_JOB_RSEOUT00
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM submit_job_rseout00 .

  DATA : lv_job_name      TYPE tbtcjob-jobname VALUE 'ZRSEOUT00_93', " Background job name
         lv_job_number    TYPE tbtcjob-jobcount,                     " Job ID
         lwa_jobs         TYPE ty_jobs,
         lv_count         TYPE char3.                                " Count of type CHAR3

  lv_count = gv_subm_count .

  CONCATENATE lv_job_name sy-datlo sy-timlo INTO lv_job_name SEPARATED BY '_'.
  CONCATENATE lv_job_name lv_count INTO lv_job_name SEPARATED BY '_' .

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_job_name
    IMPORTING
      jobcount         = lv_job_number
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc = 0.

    SUBMIT rseout00
      WITH docnum  IN git_idoc
      WITH mestyp  IN gwa_msgty
* Additional parameter for Job processing
WITH p_queue = p_queue
WITH p_compl =  p_compl
WITH p_rcvpor = p_rcvpor
WITH p_rcvprt = p_rcvprt
WITH p_rcvpfc = p_rcvpfc
WITH p_test = p_test
WITH rcvprn IN s_rcvprn
* Addition parameter for job processing
      VIA JOB lv_job_name NUMBER lv_job_number
      AND RETURN.

    IF sy-subrc = 0.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_job_number
          jobname              = lv_job_name
          strtimmed            = 'X'
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          OTHERS               = 8.
      IF sy-subrc = 0.
        lwa_jobs-jobname = lv_job_name.
        lwa_jobs-count = gv_count.
        APPEND lwa_jobs TO git_job.
        CLEAR lwa_jobs .
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0
*
  REFRESH git_idoc .

ENDFORM. " SUBMIT_JOB_RSEOUT00
