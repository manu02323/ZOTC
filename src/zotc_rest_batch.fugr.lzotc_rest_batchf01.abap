*----------------------------------------------------------------------*
***INCLUDE LZOTC_REST_BATCHF01.
*----------------------------------------------------------------------*
***********************************************************************
*Program    : LZOTC_REST_BATCHF01                                     *
*Title      : Include for table maintenace event                      *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description:Event in table ZOTC_REST_BATCH to update project master  *
*            table in GTS when an entry is created in this table.     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373      Initial Development       *
*25-JULY-2016 SBEHERA       E1DK918373      Defect#2932: 1.Changed By,*
*                           Changed On, and Changed Time  - To be auto*
*                           updated and to be Grey-out in display and *
*                           change mode on maintenance screen         *
*                                           2.Created By, Created On, *
*                           and Created Time  - To be auto updated and*
*                           to be Grey-out in display and change mode *
*                           on  maintenance screen.                   *
*                                           3. FUT Issue fixed        *
*---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&--------------------------------------------------------------------*
*       Validating the fields from input
*---------------------------------------------------------------------*
FORM f_validate.

* Checking Mandatory field(Matnr)
  IF zotc_rest_batch-matnr IS INITIAL.
    MESSAGE e092(zotc_msg). " Material is mandatory field.
    LEAVE TO SCREEN 0.
  ENDIF. " IF zotc_rest_batch-matnr IS INITIAL

* Checking Mandatory field(Batch)
  IF zotc_rest_batch-charg IS INITIAL.
    MESSAGE e093(zotc_msg). " Batch is mandatory field.
    LEAVE TO SCREEN 0.
  ENDIF. " IF zotc_rest_batch-charg IS INITIAL

* Validate atleast customer or country is entered.
  IF zotc_rest_batch-land1 IS INITIAL
    AND zotc_rest_batch-kunnr IS INITIAL.
    MESSAGE e091(zotc_msg). " Either Dest. Country or Customer is mandatory
    LEAVE TO SCREEN 0.
  ENDIF. " IF zotc_rest_batch-land1 IS INITIAL
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by U033870
*  As creating new entry so change by and time will be blank
*  and current date time is to be populated for create date time.
  zotc_rest_batch-zz_created_by = sy-uname.
  zotc_rest_batch-zz_created_on = sy-datum.
  zotc_rest_batch-zz_created_at = sy-uzeit.
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by U033870
ENDFORM. "f_validate
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_GTS
*&---------------------------------------------------------------------*
*       Update batch value in GTS
*----------------------------------------------------------------------*
FORM f_update_gts.

* Local type declaration
  TYPES: BEGIN OF lty_gts_batch,
     mandt TYPE mandt,      " Client
     guid_lcpro TYPE raw16, " RAW16
     pronr TYPE char20,     " Pronr of type CHAR20
     ernam TYPE char12,     " Ernam of type CHAR12
     crtsp TYPE dec15,      " Packed field
     aenam TYPE char12,     " Aenam of type CHAR12
     chtsp TYPE dec15,      " Packed field
   END OF lty_gts_batch.

* Local data declaration
  DATA: lv_dest_sys TYPE rfcdest,         " Logical Destination (Specified in Function Call)
        lwa_gts_batch TYPE lty_gts_batch, " Workarea for gts table
        li_gts_batch TYPE STANDARD TABLE OF
                        lty_gts_batch.    " GTS project master table
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
* Local constant declaration
  CONSTANTS :
    lc_charg    TYPE charg_d VALUE 'CHARG'. " Batch Number
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
  FIELD-SYMBOLS:
      <lfs_charg> TYPE charg_d. " Batch Number
* Fetch EMI data
  PERFORM f_fetch_emi CHANGING lv_dest_sys.
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
  LOOP AT extract.
    ASSIGN COMPONENT lc_charg OF STRUCTURE <vim_extract_struc> TO <lfs_charg>.
    IF sy-subrc = 0 AND <lfs_charg> IS NOT INITIAL .
*   Project ID
      lwa_gts_batch-pronr = <lfs_charg>.
*   Created By
      lwa_gts_batch-ernam = sy-uname.
*   Changed by
      lwa_gts_batch-aenam = sy-uname.
      APPEND lwa_gts_batch TO li_gts_batch.
      CLEAR lwa_gts_batch.
    ENDIF. " IF sy-subrc = 0 AND <lfs_charg> IS NOT INITIAL
  ENDLOOP. " LOOP AT extract
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
*  Call RFC in GTS system to update project master data table
  CALL FUNCTION 'ZOTC_TRANSFER_BATCH'
    DESTINATION lv_dest_sys
    TABLES
      tbl_gts_batch         = li_gts_batch
    EXCEPTIONS
      exc_data_not_inserted = 1
      OTHERS                = 2.
  IF sy-subrc IS INITIAL.
    MESSAGE s085(zotc_msg). " Data successfully inserted in GTS project master table.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE i086(zotc_msg). " Data not inserted in GTS project master table.
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " f_update_gts
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_EMI
*&---------------------------------------------------------------------*
*       fetch data from ZDEV_EMI
*----------------------------------------------------------------------*
*      <-- FP_LV_DEST_SYS  RFC Destination system
*----------------------------------------------------------------------*
FORM f_fetch_emi  CHANGING fp_lv_dest_sys TYPE rfcdest. " Logical Destination (Specified in Function Call)

* Local internal table Declaration
  DATA : li_status_table
               TYPE STANDARD TABLE OF zdev_enh_status, " Table for Enhancement status data

* Local variable declaration
         lv_log_sys  TYPE logsys. " Logical system

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status. " Enhancement Status

* Local constant declaration
  CONSTANTS: lc_rfc_dest  TYPE z_criteria    VALUE 'RFC_DEST',     " Enh. Criteria
             lc_enh_name  TYPE z_enhancement VALUE 'OTC_EDD_0344'. " Enhancement No

* Call function to fetch EMI data
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_status_table
    EXCEPTIONS
      OTHERS            = 1.
  IF sy-subrc IS INITIAL.

    SORT li_status_table BY criteria
                            sel_low
                            active.

* Name of current Logged-on System
* Get Logical system
    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = lv_log_sys
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.
    IF sy-subrc IS INITIAL.
    ENDIF. " IF sy-subrc IS INITIAL

* GET RFC Destination from EMI Tool on the basis of current system
*&--Read RFC destnation
*   Read status table for criteria RFC DEST and active = X
    READ TABLE li_status_table ASSIGNING <lfs_status>
                               WITH KEY criteria = lc_rfc_dest
                                        sel_low  = lv_log_sys
                                        active   = abap_true
                               BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*      Populate value for RFC Destination
      fp_lv_dest_sys = <lfs_status>-sel_high.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_FETCH_EMI

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_DETAILS
*&---------------------------------------------------------------------*
*   Validate input fields
*----------------------------------------------------------------------*
*    -->  FP_P_FILE              File Name
*----------------------------------------------------------------------*
FORM f_update_details.
  PERFORM f_validate.
* ---> Begin of Delete for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
***----Field Symbol Declaration----**
*  FIELD-SYMBOLS:
*     <lfs_tab_name> TYPE any, "Table name
*     <lfs_field>    TYPE any. "Field name
*
***-----------------------Begin of Tracker Logic-------------------**
** Get table name
* "ASSIGN (master_name) TO <lfs_tab_name>.
*  ASSIGN (vim_object) TO <lfs_tab_name>.
*
*  IF sy-subrc IS INITIAL.
** Record User ID
*    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
*    IF sy-subrc IS INITIAL.
*      <lfs_field> = sy-uname.
*    ENDIF. " IF SY-SUBRC IS INITIAL
*
** Record Current Date
*    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
*    IF sy-subrc IS INITIAL.
*      <lfs_field> = sy-datum.
*    ENDIF. " IF SY-SUBRC IS INITIAL
*
** Record Current Time
*    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
*    IF sy-subrc IS INITIAL.
*      <lfs_field> = sy-uzeit.
*    ENDIF. " IF SY-SUBRC IS INITIAL
*  ENDIF. " IF SY-SUBRC IS INITIAL
*
***-----------------------End of Tracker Logic-------------------**
* <--- End of Delete for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
**-----------------------End of Tracker Logic-------------------**
ENDFORM. "F_UPDATE_DETAILS
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
*&---------------------------------------------------------------------*
*&      Form  F_TRACK_CHANGE
*&---------------------------------------------------------------------*
*       Updating the tracking fields
*----------------------------------------------------------------------*
FORM f_track_change.
  FIELD-SYMBOLS:
      <lfs_tab_name> TYPE any,            " Table name
      <lfs_zz_created_by> TYPE tb_cruser, " Entered by
      <lfs_zz_created_on> TYPE tb_dcrdat, " Entered on
      <lfs_zz_created_at> TYPE tb_tcrtim, " Entry Time
      <lfs_zz_changed_by> TYPE tb_upuser, " Last Changed by
      <lfs_zz_changed_on> TYPE tb_dupdat, " Changed on
      <lfs_zz_changed_at> TYPE tb_tuptim, " Time changed
      <lfs_field>    TYPE any.            "Field name

* Local constant declaration
  CONSTANTS :
    lc_created_by    TYPE char13 VALUE 'ZZ_CREATED_BY', " Entered by
    lc_created_on    TYPE char13 VALUE 'ZZ_CREATED_ON', " Entered On
    lc_created_at    TYPE char13 VALUE 'ZZ_CREATED_AT', " Entry Time
    lc_changed_by    TYPE char13 VALUE 'ZZ_CHANGED_BY', " Last Changed by
    lc_changed_on    TYPE char13 VALUE 'ZZ_CHANGED_ON', " Changed on
    lc_changed_at    TYPE char13 VALUE 'ZZ_CHANGED_AT'. " Time changed
* Get table name
 "ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN (vim_object) TO <lfs_tab_name>.
  IF sy-subrc IS INITIAL .

    ASSIGN COMPONENT lc_created_by OF STRUCTURE <lfs_tab_name> TO <lfs_zz_created_by>.
    ASSIGN COMPONENT lc_created_on OF STRUCTURE <lfs_tab_name> TO <lfs_zz_created_on>.
    ASSIGN COMPONENT lc_created_at OF STRUCTURE <lfs_tab_name> TO <lfs_zz_created_at>.
    ASSIGN COMPONENT lc_changed_by OF STRUCTURE <lfs_tab_name> TO <lfs_zz_changed_by>.
    ASSIGN COMPONENT lc_changed_on OF STRUCTURE <lfs_tab_name> TO <lfs_zz_changed_on>.
    ASSIGN COMPONENT lc_changed_at OF STRUCTURE <lfs_tab_name> TO <lfs_zz_changed_at>.

    IF  <lfs_zz_created_by> IS NOT INITIAL.
* Changed By  User ID
      <lfs_zz_changed_by> = sy-uname.
    ELSE. " ELSE -> IF <lfs_zz_created_by> IS NOT INITIAL
* Created By User ID
      <lfs_zz_created_by> = sy-uname.
    ENDIF. " IF <lfs_zz_created_by> IS NOT INITIAL

    IF <lfs_zz_created_on> IS NOT INITIAL.
* Changed On Date
      <lfs_zz_changed_on> = sy-datum.
    ELSE. " ELSE -> IF <lfs_zz_created_on> IS NOT INITIAL
* Created on Date
      <lfs_zz_created_on> = sy-datum.
    ENDIF. " IF <lfs_zz_created_on> IS NOT INITIAL
    IF <lfs_zz_created_at> IS NOT INITIAL
      AND <lfs_zz_created_by> IS NOT INITIAL.
* Created At Time
      <lfs_zz_created_at> = sy-uzeit.
    ENDIF. " IF <lfs_zz_created_at> IS NOT INITIAL
    IF <lfs_zz_created_at> IS NOT INITIAL
       AND <lfs_zz_changed_by> IS NOT INITIAL .
* Changed At Time
      <lfs_zz_changed_at> = sy-uzeit.
    ENDIF. " IF <lfs_zz_created_at> IS NOT INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. "F_TRACK_CHANGE
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
