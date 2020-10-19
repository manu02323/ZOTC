***********************************************************************
*Program    : LZOTC_TRAGR_PREFF01                                     *
*Title      : Transportation Group Preference.                        *
*Developer  : Dhananjoy Moirangthem                                   *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0235                                           *
*---------------------------------------------------------------------*
*Description: Short description of functionality                      *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*18-Feb-2015  DMOIRAN       E2DK909540     Transportation group       *
*                                          preference maintenance.    *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*
***INCLUDE LZOTC_TRAGR_PREFF01.
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DETAILS
*&---------------------------------------------------------------------*
*   Updating the tracking fields
*----------------------------------------------------------------------*
*    -->  FP_P_FILE              File Name
*----------------------------------------------------------------------*
FORM f_update_details.
**----Field Symbol Declaration----**
  FIELD-SYMBOLS:
     <lfs_tab_name> TYPE any, "Table name
     <lfs_field>    TYPE any. "Field name

**-----------------------Begin of Tracker Logic-------------------**
* Get table name
  ASSIGN (vim_object) TO <lfs_tab_name>.

  IF sy-subrc IS INITIAL.
* Record User ID
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF SY-SUBRC IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF SY-SUBRC IS INITIAL

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF SY-SUBRC IS INITIAL
  ENDIF. " IF SY-SUBRC IS INITIAL

**-----------------------End of Tracker Logic-------------------**
ENDFORM. "F_UPDATE_DETAILS
