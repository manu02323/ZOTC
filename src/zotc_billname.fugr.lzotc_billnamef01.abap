*----------------------------------------------------------------------*
***INCLUDE LZOTC_BILLNAMEF01.
*----------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  LZOTC_BILLNAMEF01                                      *
* TITLE      :  Proforma Invoice Form                                  *
* DEVELOPER  :  Avanti Sharma                                          *
* OBJECT TYPE:  FORM                                                   *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_FDD_0088                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Proforma Invoice Form                                  *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*15-OCT-2016 ASHARMA8  E1DK921463 Initial development                  *
* =========== ======== ========== =====================================*
*======================================================================*
*&---------------------------------------------------------------------*
*&      Form  f_track_change
*&---------------------------------------------------------------------*
*       Details of Log entries
*----------------------------------------------------------------------*
FORM f_track_change.

** Log Entries
  FIELD-SYMBOLS:
     <lfs_tab_name> TYPE any, "Table name
     <lfs_field>    TYPE any. "Field name

* Get table name
  ASSIGN (master_name) TO <lfs_tab_name>.

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

ENDFORM. "f_track_change
