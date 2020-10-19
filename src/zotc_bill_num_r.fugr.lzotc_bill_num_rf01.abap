*----------------------------------------------------------------------*
***INCLUDE LZOTC_BILL_NUM_RF01.
*----------------------------------------------------------------------*
************************************************************************
* Program    :  LZOTC_BILL_NUM_RF01                                    *
* Title      :  Track changes in custom tables                         *
* Developer  :  Srinivasa Gurijala                                     *
* Object Type:  Include                                                *
* SAP Release:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_EDD_0160 - Billing Number Range Maintanence       *
*----------------------------------------------------------------------*
* Description: Track Comments, User ID, Date and Time of the change in *
* a custom table updated in SM30 or a View Cluster.                    *
*----------------------------------------------------------------------*
* Modification History:                                                *
*======================================================================*
*  Date        User     Transport  Description                         *
* =========== ======== ========== =====================================*
* 08-Aug-2016  U033814   E1DK918369 D3 - INITIAL DEVELOPMENT           *
*&---------------------------------------------------------------------*
FORM f_update_details.

  FIELD-SYMBOLS:
     <lfs_tab_name> TYPE any, "Table name
     <lfs_field>    TYPE any. "Field name

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
*-- Make the fields read only
  LOOP AT x_namtab.
    IF x_namtab-viewfield = 'ZZ_LASTCHANGED' OR
       x_namtab-viewfield = 'ZZ_CHANGE_DATE' OR
       x_namtab-viewfield = 'ZZ_CHANGE_TIME'.
      x_namtab-readonly = 'R'.
      MODIFY x_namtab.
    ENDIF. " IF x_namtab-viewfield = 'ZZ_LASTCHANGED' OR
  ENDLOOP. " LOOP AT x_namtab
ENDFORM. "f_update_details*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_readonly_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_readonly_fields.
*-- Make the fields read only
  LOOP AT x_namtab.
    IF x_namtab-viewfield = 'ZZ_LASTCHANGED' OR
       x_namtab-viewfield = 'ZZ_CHANGE_DATE' OR
       x_namtab-viewfield = 'ZZ_CHANGE_TIME'.
      x_namtab-readonly = 'R'.
      MODIFY x_namtab.
    ENDIF. " IF x_namtab-viewfield = 'ZZ_LASTCHANGED' OR
  ENDLOOP. " LOOP AT x_namtab
ENDFORM. "f_readonly_fields
