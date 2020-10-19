*----------------------------------------------------------------------*
***INCLUDE LZOTC_BILPLN_CTRLF01.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
************************************************************************
* Program    :  LZOTC_BILPLN_CTRLF01.                                         *
* Title      :  Track changes in custom tables                         *
* Developer  :  Paramita Bose                                          *
* Object Type:  Include                                                *
* SAP Release:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_EDD_0179_Determine Billing plan - Z-Table creation*
*----------------------------------------------------------------------*
* Description: Track Comments, User ID, Date and Time of the change in *
* a custom table updated in SM30 or a View Cluster.                    *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
* Date        User     Transport  Description                          *
* =========== ======== ========== =====================================*
* 11-Aug-2014 PBOSE   E2DK901255 Initial development                  *
*&---------------------------------------------------------------------*
FORM F_UPDATE_DETAILS.

  FIELD-SYMBOLS:
     <LFS_TAB_NAME> TYPE ANY, "Table name
     <LFS_FIELD>    TYPE ANY. "Field name

* Get table name
 "ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN (VIM_OBJECT) TO <LFS_TAB_NAME>.

  IF SY-SUBRC IS INITIAL.
* Record User ID
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <LFS_TAB_NAME> TO <LFS_FIELD>.
    IF SY-SUBRC IS INITIAL.
      <LFS_FIELD> = SY-UNAME.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <LFS_TAB_NAME> TO <LFS_FIELD>.
    IF SY-SUBRC IS INITIAL.
      <LFS_FIELD> = SY-DATUM.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <LFS_TAB_NAME> TO <LFS_FIELD>.
    IF SY-SUBRC IS INITIAL.
      <LFS_FIELD> = SY-UZEIT.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. "f_update_details
