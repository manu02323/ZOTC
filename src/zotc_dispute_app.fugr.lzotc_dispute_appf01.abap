*----------------------------------------------------------------------*
***INCLUDE LZOTC_DISPUTE_APPF01.
*----------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  LZOTC_DISPUTE_APPF01                                   *
* TITLE      :  D2_OTC_WDD_0013
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_WDD_0013 workflow for debit and credit memo     *
*----------------------------------------------------------------------*
* DESCRIPTION: Workflow for debit and credit memo .
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-Jan-2015 Vinita    E2DK907287 INITIAL DEVELOPMENT
*&---------------------------------------------------------------------*

FORM f_update_details.
**----Field Symbol Declaration----**
  FIELD-SYMBOLS:
     <lfs_tab_name> TYPE any, "Table name
     <lfs_field>    TYPE any. "Field name

**-----------------------Begin of Tracker Logic-------------------**
* Get table name
 "ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN (vim_object) TO <lfs_tab_name>.

  IF sy-subrc IS INITIAL.
* Record User ID
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

**-----------------------End of Tracker Logic-------------------**

ENDFORM. "F_UPDATE_DETAILS
