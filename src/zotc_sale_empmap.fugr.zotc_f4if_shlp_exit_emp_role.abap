FUNCTION zotc_f4if_shlp_exit_emp_role.
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
* PROGRAM    :  ZOTC_F4IF_SHLP_EXIT_EMP_ROLE (FM)                      *
* TITLE      :  Function module to create Search Help Exit for EMP_ROLE*
* DEVELOPER  :  Suman Majumder                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0067                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Search help Exit for Employee Role
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 18-JUL-2012  SMAJUJMD  E1DK902097 INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*

* Local structure declaration
  TYPES:BEGIN OF ty_sal_emp,
        emp_role TYPE z_emprole,
        END OF ty_sal_emp.

* Local constant declaration
  CONSTANTS:lc_para TYPE char10 VALUE 'EMP_ROLE',
          lc_blank TYPE char1 VALUE '',
          lc_sopt  TYPE char2 VALUE 'EQ',
          lc_act   TYPE char1 VALUE 'X',
          lc_select  TYPE ddshf4step VALUE 'SELECT', " Select F4 val
          lc_display TYPE ddshf4step VALUE 'DISP'.   " Display F4 val
* Local internal table and workarea declaration
  DATA: li_sal_emp TYPE STANDARD TABLE OF ty_sal_emp,
        lwa_record_tab TYPE seahlpres.
  " Record tab
*  Local field symbol declaration
  FIELD-SYMBOLS: <lfs_sal_emp> TYPE ty_sal_emp.

  IF callcontrol-step = lc_select OR
     callcontrol-step = lc_display.
*fetch data from zotc_prc_control table
    SELECT mvalue1
      FROM zotc_prc_control
      INTO TABLE li_sal_emp
      WHERE mprogram NE lc_blank
      AND mparameter = lc_para
      AND mactive = lc_act
      AND soption = lc_sopt.
* if the internal table li_sal_emp is not initial
    IF li_sal_emp IS  NOT INITIAL.
      SORT li_sal_emp BY emp_role.
    ENDIF.
*loop at internal table li_sal_emp and insert
*into  table record_tab for display.
    LOOP AT li_sal_emp ASSIGNING <lfs_sal_emp>.
      CLEAR lwa_record_tab.
      lwa_record_tab-string = <lfs_sal_emp>-emp_role.
      INSERT lwa_record_tab INTO TABLE record_tab.

    ENDLOOP.
  ENDIF.
ENDFUNCTION.
*End of change by SMAJUMD with CR#85
