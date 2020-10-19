FUNCTION zotc_f4if_shlp_exit_docref.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCT
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR
*"     REFERENCE(CALLCONTROL) LIKE  DDSHF4CTRL STRUCTURE  DDSHF4CTRL
*"----------------------------------------------------------------------
************************************************************************
* PROGRAM    :  ZOTC_F4IF_SHLP_EXIT_DOCREF ( Function Module)          *
* TITLE      :  Search help exit for SO doc based on Leg Ref Document  *
* DEVELOPER  :  RAJENDRA K PANIGRAHY                                   *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D2_OTC_EDD_0136                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Search help exit for SO doc based on Leg Ref Document   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 20-MAY-2014 RPANIGR  E2DK900492 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*

************************************************************************
*===========================Data declaration===========================*
************************************************************************
* Local constant declaration
  CONSTANTS: lc_select   TYPE ddshf4step VALUE 'SELECT',   " Select F4 val
             lc_display  TYPE ddshf4step VALUE 'DISP',     " Display F4 val
             lc_zzdocref TYPE shlpfield  VALUE 'ZZDOCREF', " Name of a search help parameter
             lc_vbeln    TYPE shlpfield  VALUE 'VBELN'.    " Name of a search help parameter
*Type Declaration
  TYPES:BEGIN OF lty_vbak,
        vbeln    TYPE vbeln,    " Sales Document
        zzdocref TYPE z_docref, " Legacy Doc Ref
  END OF lty_vbak.
*Internal table of type declaration
  DATA :li_vbak  TYPE STANDARD TABLE OF lty_vbak. "Internal table for local type vbak
*Field sysmbol declaration
  FIELD-SYMBOLS: <lfs_vbak> TYPE lty_vbak. "Field symbol for local type vbak
*Table type declaration
  TYPES :lty_docref TYPE RANGE OF z_docref, " Legacy Doc Ref
         lty_vbeln  TYPE RANGE OF vbeln.    " Sales and Distribution Document Number
*Range table declaration
  DATA:  lr_docref  TYPE lty_docref,         "Range table for docref
         lr_vbeln   TYPE lty_vbeln,          "Range table for vbeln
         lwa_docref TYPE LINE OF lty_docref, "work are for range table for docref
         lwa_vbeln  TYPE LINE OF lty_vbeln.  "work are for range table for vbeln
*Local workarea and Variable declaration
  DATA : lwa_record_tab TYPE seahlpres,     " Search help result structure
         lwa_selopt     TYPE ddshselopt,    " Selection options for value selection with search help
         lv_docref      TYPE vbak-zzdocref, " Legacy Doc Ref
         lv_flag        TYPE char1.         " Flag of type CHAR1

************************************************************************
*===========================Processing Logic===========================*
************************************************************************
* Check the Steps
  CASE callcontrol-step.
*If its 'SELECT' step
    WHEN lc_select.
*Loop at Select Option table
      LOOP AT shlp-selopt INTO lwa_selopt.
*Check Select Option field
        CASE lwa_selopt-shlpfield.
*When VBELN , built range table for VBELN
          WHEN lc_vbeln.
            lwa_vbeln-sign   = lwa_selopt-sign.
            lwa_vbeln-option = lwa_selopt-option.
            lwa_vbeln-low    = lwa_selopt-low.
            lwa_vbeln-high   = lwa_selopt-high.
            APPEND lwa_vbeln TO lr_vbeln.
            CLEAR lwa_vbeln.
*When zzdocref , built range table for zzdocref
          WHEN lc_zzdocref.
            lwa_docref-sign   = lwa_selopt-sign.
            lwa_docref-option = lwa_selopt-option.
            lwa_docref-low    = lwa_selopt-low.
            lwa_docref-high   = lwa_selopt-high.
            APPEND lwa_docref TO lr_docref.
            CLEAR lwa_docref.
          WHEN OTHERS.
        ENDCASE.
      ENDLOOP. " LOOP AT shlp-selopt INTO lwa_selopt
*Get the VBELN and ZZDOCREF field which satisfies the range table values
      SELECT vbeln          " Sales Doc
             zzdocref       " Ref Doc
             FROM vbak " Sales Document: Header Data
             INTO TABLE li_vbak
             UP TO callcontrol-maxrecords ROWS
             WHERE zzdocref IN lr_docref
               AND vbeln    IN lr_vbeln.
*Set the flag, if data found
      IF sy-subrc = 0.
        lv_flag = abap_true.
      ENDIF. " IF sy-subrc = 0
*Loop those records and populate the record_tab table for selected values to appear
      LOOP AT li_vbak ASSIGNING <lfs_vbak>.
        CLEAR  lwa_record_tab.
        MOVE <lfs_vbak> TO lwa_record_tab-string.
        APPEND lwa_record_tab TO record_tab.
      ENDLOOP. " LOOP AT li_vbak ASSIGNING <lfs_vbak>
*If no entry found , display the message
      IF record_tab[] IS INITIAL.
        MESSAGE s801(dh). " No values found
        RETURN.
      ENDIF. " IF record_tab[] IS INITIAL
*If flag is Set (Means Data found from table), set the step to display
      IF lv_flag = abap_true.
*Set step as 'DISP'
        callcontrol-step = lc_display.
      ENDIF. " IF lv_flag = abap_true
    WHEN OTHERS.
  ENDCASE.
ENDFUNCTION.
