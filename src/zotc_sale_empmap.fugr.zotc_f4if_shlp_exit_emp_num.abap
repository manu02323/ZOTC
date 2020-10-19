FUNCTION zotc_f4if_shlp_exit_emp_num.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR_T
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
*  Begin of change by SMAJUMD with CR#85
************************************************************************
* PROGRAM    :  ZOTC_F4IF_SHLP_EXIT_EMP_NUM (FM)                       *
* TITLE      :  Function module to create Search Help Exit for EMP_NUM *
* DEVELOPER  :  Suman Majumder                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0067                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Search help Exit for Employee Number
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-JUL-2012  SMAJUJMD  E1DK902097 INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*

* Local Structure Declaration for table KNA1
  TYPES:
          BEGIN OF ty_kna1,
           kunnr TYPE kunnr,
          END OF ty_kna1.

*  Local constant declaration
  CONSTANTS:lc_ktokd TYPE char10 VALUE 'ZREP',
            lc_select  TYPE ddshf4step VALUE 'SELECT', " Select F4 val
            lc_display TYPE ddshf4step VALUE 'DISP'.   " Display F4 val

* Local internal table and workarea declaration
  DATA:
        li_kna1    TYPE STANDARD TABLE OF ty_kna1,
        lwa_record_tab TYPE seahlpres.
  " Record tab

*  Local field symbol declaration
  FIELD-SYMBOLS: <lfs_kna1> TYPE ty_kna1.

  IF callcontrol-step = lc_select OR
     callcontrol-step = lc_display.

*Select data from Kna1
  SELECT
    kunnr
    FROM kna1
    INTO TABLE li_kna1
    WHERE ktokd = lc_ktokd.

*    if the internal table li_kna1 is not initial
  IF li_kna1 IS  NOT INITIAL.
    SORT li_kna1 BY kunnr.
  ENDIF.

* loop at kna1 and append the kunnr to record_tab
* for display
  LOOP AT li_kna1 ASSIGNING <lfs_kna1>.
    CLEAR lwa_record_tab.
    lwa_record_tab-string = <lfs_kna1>-kunnr.
    APPEND lwa_record_tab TO  record_tab.

  ENDLOOP.
 ENDIF.
ENDFUNCTION.

*End of change by SMAJUMD with CR#85
