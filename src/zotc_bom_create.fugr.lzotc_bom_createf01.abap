***********************************************************************
*Program    : LZOTC_BOM_CREATEF01                                     *
*Title      : Auto Creation of Sales BOM                              *
*Developer  : Neha Kumari                                             *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0212                                           *
*---------------------------------------------------------------------*
*Description: Sales BOM creation for Express Bio Plex Products when   *
*             New Express BioPlex configurations are performed by web *
*             - users and orders are placed for those products.       *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*18-Feb-2015  NKUMARI       E2DK904869     Initial Development        *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DETAILS
*&---------------------------------------------------------------------*
*   Updating the tracking fields
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
