FUNCTION zotc_f4if_shlp_exit_prodh4.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  EXPORTING
*"     REFERENCE(NODE_PICKED) TYPE  T179-PRODH
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR_T
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_F4IF_SHLP_EXIT_PRODH4 (FM)                        *
* TITLE      :  Billback Enhancement for Billing User Exit             *
* DEVELOPER  :  ANANYA DAS                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0043                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Search help Exit for Product Family
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 25-APR-2012  RNATHAK   E1DK902572 INITIAL DEVELOPMENT                *
*&---------------------------------------------------------------------*

* Local constant declaration
  CONSTANTS: lc_select  TYPE ddshf4step VALUE 'SELECT', " Select F4 val
             lc_display TYPE ddshf4step VALUE 'DISP'.   " Display F4 val

* Local internal table and workarea declaration
  DATA: li_t179        TYPE STANDARD TABLE OF t179 ,
        " Product hierarchy table
        li_t179t       TYPE STANDARD TABLE OF t179t ,
        " Product hierarchy text table
        lwa_t179t      TYPE t179t,
        " Product hierarchy text workarea
        lwa_record_tab TYPE seahlpres.
        " Record tab

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_t179> TYPE t179.

  IF callcontrol-step = lc_select OR
     callcontrol-step = lc_display.

*   Fetch Product Hierarchy for Level 4
    SELECT * FROM t179 INTO TABLE li_t179
             WHERE stufe = 4.
    IF sy-subrc = 0.
*     Fetch Product Hierarchy text
      SELECT * FROM t179t INTO TABLE li_t179t
               FOR ALL ENTRIES IN li_t179
               WHERE spras = sy-langu
                 AND prodh = li_t179-prodh.
      IF sy-subrc = 0.
        SORT li_t179t BY prodh.
      ENDIF.
    ENDIF.

*   Populate Search Help with Product hierarchy up to level 4
    LOOP AT li_t179 ASSIGNING <lfs_t179>.

*     Unique entry of Product Family will be inserted
      READ TABLE record_tab TRANSPORTING NO FIELDS
           WITH KEY string = <lfs_t179>-prodh(11).
      IF sy-subrc <> 0.
*       Get Product Family Description
        READ TABLE li_t179t INTO lwa_t179t
             WITH KEY prodh = <lfs_t179>-prodh
             BINARY SEARCH.
        IF sy-subrc = 0.
*         Populate Product family and desc
          CONCATENATE <lfs_t179>-prodh(11)
                      lwa_t179t-vtext
                      INTO lwa_record_tab-string.
          INSERT lwa_record_tab INTO TABLE record_tab.
        ENDIF. " IF sy-subrc = 0. READ TABLE li_t179t
      ENDIF. " IF sy-subrc = 0. READ TABLE li_t179
    ENDLOOP. " LOOP AT li_t179 INTO lwa_t179.

  ENDIF. " IF callcontrol-step = 'SELECT' OR
  "    callcontrol-step = 'DISP'.

ENDFUNCTION.
