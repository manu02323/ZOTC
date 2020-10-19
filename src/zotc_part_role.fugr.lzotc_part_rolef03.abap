************************************************************************
* PROGRAM    :  LZOTC_PART_ROLEF03                                     *
* TITLE      :  Routine to track create/change detail                  *
* DEVELOPER  :  Mayukh CHatterjee                                      *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0213                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Routine to track create/change detail                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 09-OCT-2014 MCHATTE  E2DK904939  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZOTC_PART_ROLEF03.
*----------------------------------------------------------------------*
FORM f_track_change.
  FIELD-SYMBOLS:
     <lfs_tab_name> TYPE any, "Table name
     <lfs_field>    TYPE any. "Field name

* Get table name
  "ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN (vim_object) TO <lfs_tab_name>.

  IF sy-subrc IS INITIAL.
* Record User ID
    ASSIGN COMPONENT 'ZZ_CHANGED_BY' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Date
    ASSIGN COMPONENT 'ZZ_CHANGED_ON' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Time
    ASSIGN COMPONENT 'ZZ_CHANGED_AT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM.                    "f_track_change
