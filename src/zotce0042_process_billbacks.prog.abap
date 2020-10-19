************************************************************************
* PROGRAM    :  ZOTCE0042_PROCESS_BILLBACKS                            *
* TITLE      :  Process Billback data                                  *
* DEVELOPER  :  Santosh Vinapamula                                     *
* OBJECT TYPE:  Executable program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0042                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Process Billback data from EDI 867                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 15-JUN-2012  SVINAPA  E1DK901251 INITIAL DEVELOPMENT                 *
* 11-May-2016  SBEHERA  E2DK917823 Defect#1573 : Output Layouts gets   *
*                                  changed before updating documents   *
*&---------------------------------------------------------------------*

REPORT  zotce0042_process_billbacks.

************************************************************************
*         INCLUDE Declaration
************************************************************************
INCLUDE zotcn0042_proc_billbacks_top.
INCLUDE zotcn0042_proc_billbacks_scr.
INCLUDE zotcn0042_proc_billbacks_form.

************************************************************************
*         Initialization
************************************************************************
INITIALIZATION.

************************************************************************
*         At Selection-Screen
************************************************************************
AT SELECTION-SCREEN.

************************************************************************
*         Start-of-Selection
************************************************************************
START-OF-SELECTION. " main logic

* Selection and processing logic
  PERFORM f_selection_and_processing.

************************************************************************
*         End-of-Selection
************************************************************************
END-OF-SELECTION.

* Display Billback data
  PERFORM f_display_billbk_data.
