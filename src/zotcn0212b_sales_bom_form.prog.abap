************************************************************************
* PROGRAM    :  ZOTCE0212B_SALES_BOM_CREATION                          *
* TITLE      :  Auto Creation of Sales BOM                             *
* DEVELOPER  :  NEHA KUMARI                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0212                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Auto Creation of Material BOM and BOM Extension for    *
*               plant assignments                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 16-SEP-2014 NKUMARI  E2DK904869  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 24-Feb-2015 NKUMARI  E2DK904869  Defect 4058: Logic is added for     *
*                                  Background Mode Execution           *
*&---------------------------------------------------------------------*
* 19-Mar-2015 NKUMARI  E2DK904869  Defect 4058_2: Modification in mail *
*                                                 content.             *
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0212B_SALES_BOM_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*     Modify selection screen as per checkbox selection
*----------------------------------------------------------------------*
FORM f_modify_screen.

***---------Constant Declaration---------*****
  CONSTANTS: lc_stlan  TYPE  abtext  VALUE 'P_STLAN', " BOM Usage
             lc_date   TYPE  abtext  VALUE 'P_DATE',  " Current Date of Application Server
             lc_zero   TYPE  xfeld   VALUE '0'.       " constant forscreen active

  DATA lwa_screen TYPE screen. " Structure Description for the System Data Object SCREEN

  LOOP AT screen INTO lwa_screen.
**& BOM Usage field on selection screen is non editable field
    IF lwa_screen-name = lc_stlan.
      lwa_screen-input = lc_zero.
      MODIFY screen FROM lwa_screen.
    ENDIF. " IF lwa_screen-name = lc_stlan

* ---> Begin of change for Defect #4058 by NKUMARI
** If the program run in executed in the background,
    IF sy-batch IS NOT INITIAL.
* <--- End of change for Defect #4058 by NKUMARI
**& Date field on selection screen is non editable
      IF lwa_screen-name = lc_date.
        lwa_screen-input = lc_zero.
        MODIFY screen FROM lwa_screen.
      ENDIF. " IF lwa_screen-name = lc_date
* ---> Begin of change for Defect #4058 by NKUMARI
    ENDIF. " IF sy-batch IS NOT INITIAL
* <--- End of change for Defect #4058 by NKUMARI
  ENDLOOP. " LOOP AT screen INTO lwa_screen
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*     Material Number Validation
*----------------------------------------------------------------------*
*      -->FP_S_MATNR  Material number
*----------------------------------------------------------------------*
* ---> Begin of change for Defect #4058 by NKUMARI
*FORM f_validate_matnr  USING fp_matnr TYPE  matnr. " Material Number
FORM f_validate_matnr  USING fp_s_matnr TYPE ty_r_matnr. " Material Number

****---------Local Data Declaration---------*****
*  DATA: lv_matnr  TYPE  matnr. " Material Number
* <--- End of change for Defect #4058 by NKUMARI

  IF fp_s_matnr IS NOT INITIAL.
    SELECT  matnr " Material Number
      FROM  mara  " General Material Data
* ---> Begin of change for Defect #4058 by NKUMARI
*             INTO  lv_matnr
*       WHERE matnr = p_matnr.
      INTO TABLE i_matnr
      WHERE matnr IN fp_s_matnr. "= fp_matnr.
* <--- End of change for Defect #4058 by NKUMARI
    IF sy-subrc <> 0.
** If material is invalid
      MESSAGE e128 WITH 'Material'(003). " Invalid &.
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of change for Defect #4058 by NKUMARI
** If material number field is blank
  ELSE. " ELSE -> IF sy-subrc <> 0
** If the program is running in background mode
    IF sy-batch IS NOT INITIAL.
      SELECT matnr            " Material Number
             status           " Instance object type
      FROM zotc_bom_create    " Characteristics information for sales BOM creation
      INTO TABLE i_matnr
      WHERE matnr IN s_matnr. " Fetch All the Data From Table
      IF sy-subrc = 0.
        SORT i_matnr BY matnr.
        DELETE ADJACENT DUPLICATES FROM i_matnr COMPARING matnr.

        DELETE i_matnr WHERE status EQ c_complete.
        IF p_create  EQ abap_true
       AND p_extend  EQ abap_false.
          DELETE i_matnr WHERE status NE c_added.
        ELSEIF p_extend EQ abap_true
           AND p_create EQ abap_false.
          DELETE i_matnr WHERE status EQ c_added.
        ENDIF. " IF p_create EQ abap_true
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF p_create EQ abap_true
** If program is running in forground mode, generate error message
*      MESSAGE e127 WITH 'Material'(003).
    ENDIF. " IF sy-batch IS NOT INITIAL
* <--- End of change for Defect #4058 by NKUMARI

  ENDIF. " IF fp_s_matnr IS NOT INITIAL
ENDFORM. " F_VALIDATE_MATNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PLANT
*&---------------------------------------------------------------------*
*     Check Plant Existence
*----------------------------------------------------------------------*
*    -->FP_S_WERKS   Plant
*----------------------------------------------------------------------*
FORM f_validate_plant  USING  fp_s_werk  TYPE  ty_r_werks. " Plant

*  IF fp_s_werk[] IS INITIAL.
*** If checkbox for BOM Extension is selcted and plant is not mention.
*
** ---> Begin of change for Defect #4058_2 by NKUMARI
*
**    SELECT werks " Plant
**      FROM marc  " Plant Data for Material
**      INTO TABLE i_werks
**      WHERE matnr = p_matnr.
*    SELECT matnr " Material Number
*           werks " Plant
*      FROM marc  " Plant Data for Material
*      INTO TABLE i_marc
*      WHERE matnr IN s_matnr[].
** <--- End of change for Defect #4058_2 by NKUMARI
*
*    IF sy-subrc <> 0.
*** Invalid Plant for this material
*      MESSAGE e128 WITH 'Plant'(005). " Invalid &.
*    ENDIF. " IF sy-subrc <> 0
  IF fp_s_werk[] IS NOT INITIAL.
    SELECT werks " Plant
      FROM t001w " Plants/Branches
      INTO TABLE  i_werks
      WHERE werks IN fp_s_werk[].
    IF sy-subrc <> 0.
** If Plant is invalid
      MESSAGE e128 WITH 'Plant'(005). " Invalid &.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_s_werk[] IS NOT INITIAL

ENDFORM. " F_VALIDATE_PLANT
*&---------------------------------------------------------------------*
*&      Form  F_CHAR_INFO
*&---------------------------------------------------------------------*
*    To get the Characteristic detail for material from custom table
*    And Create Sales BOM and Extend for plant assignment
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_char_info. " CHANGING fp_i_bom_create TYPE ty_t_bom_create. "Table for header data for BOM Creation

* ---> Begin of change for Defect #4058 by NKUMARI
*********** Local Data Declaration ************
** Local Table type for Bill of material
  TYPES: BEGIN OF lty_stnum,
             stlnr TYPE stnum, " Bill of material
         END OF lty_stnum.

************** Field Symbol Declaration ************
  FIELD-SYMBOLS: <lfs_matnr> TYPE ty_matnr,
                 <lfs_marc>  TYPE ty_marc.

  DATA:  li_processed_data  TYPE  ty_t_bom_create,                            "Internal table for BOM Processed data
         lwa_plant          TYPE  ty_werks,                                   "Work area for Plant
         lv_tabix           TYPE  sytabix,                                    " Index of Internal Tables
         li_stnum           TYPE  STANDARD TABLE OF lty_stnum INITIAL SIZE 0, "Internal table for BOM
* <--- End of change for Defect #4058 by NKUMARI

***-->> Begin of change by NKUMARI for defect# 1404
         li_bom_create_temp TYPE ty_t_bom_create.
****<<-- End of change by NKUMARI for defect# 1404

** Clear the variable
  CLEAR: gv_message,
         gv_err_flg,
****-->> Begin of change by NKUMARI for defect# 1404
         gv_exist_flg.
****<<-- End of change by NKUMARI for defect# 1404

* ---> Begin of change for Defect #4058 by NKUMARI
  IF i_matnr[] IS INITIAL.
    CLEAR gv_message.
    gv_message = 'No Data Found For This Selection'(007).
    MESSAGE i000 WITH 'No Data Found For This Selection'(007).
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF i_matnr[] IS INITIAL
* <--- End of change for Defect #4058 by NKUMARI
**& Get all the values from the custom table into internal table
    SELECT  mandt           " Client
            matnr           " Material Number
            component       " Material Number
            status          " Checkbox
            created         " Timestamp (char 14 - YYYYMMDDHHMMSS)
            processed       " Timestamp (char 14 - YYYYMMDDHHMMSS)
      FROM  zotc_bom_create " Characteristics information for sales BOM creation
      INTO TABLE i_bom_create
* ---> Begin of change for Defect #4058 by NKUMARI
*      WHERE matnr = p_matnr.
     FOR ALL ENTRIES IN i_matnr
     WHERE matnr = i_matnr-matnr.
* <--- End of change for Defect #4058 by NKUMARI

    IF sy-subrc <> 0.
      gv_message = 'This material does not exist in custom table.'(017).
****-->> Begin of change by NKUMARI for defect# 1404
** Set the flag to show material does not exist in table
      gv_exist_flg = abap_true.
****<<-- End of change by NKUMARI for defect# 1404
    ELSE. " ELSE -> IF sy-subrc <> 0

* ---> Begin of change for Defect #4058_2 by NKUMARI
*** Get MARC data
      PERFORM f_get_marc CHANGING i_marc.
* <--- End of change for Defect #4058_2 by NKUMARI

*** Job to create the Sales BOM
      IF p_create IS NOT INITIAL.
* ---> Begin of change for Defect #4058 by NKUMARI
        LOOP AT i_matnr ASSIGNING <lfs_matnr>.
          CLEAR: li_bom_create_temp[].
          li_bom_create_temp[] = i_bom_create[].

          DELETE li_bom_create_temp WHERE matnr NE <lfs_matnr>-matnr.

*&-- Delete the records where the status is not 'I'
          DELETE li_bom_create_temp WHERE status NE c_added.

          IF NOT li_bom_create_temp[] IS INITIAL.
**-- Commented Out
*        PERFORM f_job_bom_create.
            PERFORM f_job_bom_create USING li_bom_create_temp[]
                                           <lfs_matnr>-matnr.
** Append all processed data into internal table.
            APPEND LINES OF li_bom_create_temp TO li_processed_data.
          ELSE. " ELSE -> IF NOT li_bom_create_temp[] IS INITIAL
            CONTINUE.
          ENDIF. " IF NOT li_bom_create_temp[] IS INITIAL
        ENDLOOP. " LOOP AT i_matnr ASSIGNING <lfs_matnr>
        UNASSIGN <lfs_matnr>.
      ENDIF. " IF p_create IS NOT INITIAL

** Modify the status in Z table
      IF li_processed_data[] IS NOT INITIAL.
        PERFORM f_modify_sales_bom  USING li_processed_data[].
      ENDIF. " IF li_processed_data[] IS NOT INITIAL

      CLEAR: li_processed_data[].

* <--- End of change for Defect #4058 by NKUMARI

      IF gv_err_flg IS INITIAL OR
        sy-batch = abap_true. " Defect # 4058
*** BOM Extension for plant assignments
        IF p_extend IS NOT INITIAL.

* ---> Begin of change for Defect #4058 by NKUMARI
          IF NOT i_bomno IS INITIAL.
            DO 10 TIMES.
              SELECT stlnr " Bill of material
                FROM stko  " BOM Header
                INTO TABLE li_stnum
                FOR ALL ENTRIES IN i_bomno
                WHERE stlnr = i_bomno-bomno.
              IF sy-subrc EQ 0.
                EXIT.
              ENDIF. " IF sy-subrc EQ 0
              WAIT UP TO 1 SECONDS.
            ENDDO.
          ENDIF. " IF NOT i_bomno IS INITIAL

          SORT i_marc BY matnr.

          LOOP AT i_matnr ASSIGNING <lfs_matnr>.

            IF s_werk[] IS INITIAL.
              REFRESH i_werks[].
              READ TABLE i_marc TRANSPORTING NO FIELDS WITH KEY matnr = <lfs_matnr>-matnr
                                                                BINARY SEARCH.
              IF sy-subrc EQ 0.
                lv_tabix = sy-tabix.
                LOOP AT i_marc ASSIGNING <lfs_marc> FROM lv_tabix.
                  IF <lfs_marc>-matnr NE <lfs_matnr>-matnr.
                    EXIT.
                  ENDIF. " IF <lfs_marc>-matnr NE <lfs_matnr>-matnr
                  lwa_plant-werks = <lfs_marc>-werks.
                  APPEND lwa_plant TO i_werks.
                  CLEAR: lwa_plant.
                ENDLOOP. " LOOP AT i_marc ASSIGNING <lfs_marc> FROM lv_tabix
                UNASSIGN <lfs_marc>.
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF s_werk[] IS INITIAL

            CLEAR:  li_bom_create_temp[].

****-->> Begin of change by NKUMARI for defect# 1404
** Copy the content of table into local temporary table
            li_bom_create_temp[] =  i_bom_create[].

*  Delete other materials except the current Material.
            DELETE li_bom_create_temp WHERE matnr NE <lfs_matnr>-matnr.
** Delete the table entry where status is complete.
            DELETE li_bom_create_temp WHERE status = c_complete
                                         OR status = c_added.
            IF li_bom_create_temp IS NOT INITIAL.

****<<-- End of change by NKUMARI for defect# 1404
*           PERFORM f_job_bom_extend  USING  li_bom_create_temp[] "Commented Out

              PERFORM f_job_bom_extend  USING  li_bom_create_temp[]
                                               i_werks[]
                                               <lfs_matnr>-matnr.
** Append all processed data into internal table.
              APPEND LINES OF li_bom_create_temp TO li_processed_data.
****-->> Begin of change by NKUMARI for defect# 1404
            ENDIF. " IF li_bom_create_temp IS NOT INITIAL
****<<-- End of change by NKUMARI for defect# 1404
          ENDLOOP. " LOOP AT i_matnr ASSIGNING <lfs_matnr>
        ENDIF. " IF p_extend IS NOT INITIAL
      ENDIF. " IF gv_err_flg IS INITIAL or

** Modify the status and processed date in Z table
      IF li_processed_data[] IS NOT INITIAL.
        PERFORM f_modify_sales_bom  USING li_processed_data[].
      ENDIF. " IF li_processed_data[] IS NOT INITIAL
* <--- End of change for Defect #4058 by NKUMARI
    ENDIF. " IF sy-subrc <> 0
* ---> Begin of change for Defect #4058 by NKUMARI
  ENDIF. " IF i_matnr[] IS INITIAL
* <--- End of change for Defect #4058 by NKUMARI
ENDFORM. "f_char_info
*&---------------------------------------------------------------------*
*&      Form  F_JOB_BOM_CREATE
*&---------------------------------------------------------------------*
*       Material BOM Creation
*----------------------------------------------------------------------*
* ---> Begin of change for Defect #4058 by NKUMARI
*FORM f_job_bom_create .
FORM f_job_bom_create USING  fp_i_bom_data   TYPE ty_t_bom_create
                             fp_matnr        TYPE matnr. " Material Number

** Local Work area of BOM data
  DATA: lwa_bomno      TYPE  ty_bom_no.
* <--- End of change for Defect #4058 by NKUMARI

****----------Data Declaration------------*****
  DATA : li_stpo        TYPE STANDARD TABLE OF stpo_api01 INITIAL SIZE 0, " BOM item
         lwa_bom_create TYPE  zotc_bom_create,                            " Characteristics information for sales BOM creation
         lx_messages    TYPE  bapireturn,                                 " Return Parameter
         lwa_stpo       TYPE  stpo_api01,                                 " API Structure for BOM Item: Fields that can Be Changed
         lwa_stko       TYPE  stko_api01,                                 " BOM Header
         lv_valid_from  TYPE  csap_mbom-datuv.                            " Valid-From Date (BTCI)

****----------Constant Declaration------------*****
  CONSTANTS: lc_err_cre     TYPE  xtype  VALUE 'EC', " Additional Indicator
             lc_process     TYPE  xfeld  VALUE 'P',  " Checkbox
             lc_item_categ  TYPE  postp  VALUE 'L',  " Item Category (Bill of Material)
             lc_comp_unit   TYPE  kmpme  VALUE 'EA'. " Component unit of measure
** Clear work area
  CLEAR: lwa_stpo,
         lwa_stko.

*** BOM Header Structure
  lwa_stko-base_quan   =  1.
  lwa_stko-base_unit   =  lc_comp_unit.
  lwa_stko-bom_status  =  01.
  lwa_stko-alt_text    =  'Material BOM'(019).
  lwa_stko-bom_text    =  'Material BOM'(019).

*** Looping into custom table to read the all component value for that material
* ---> Begin of change for Defect #4058 by NKUMARI
*  LOOP AT i_bom_create  ASSIGNING <fs_bom_create>
*                            WHERE matnr  = p_matnr
*                             AND  status = c_added.
  LOOP AT fp_i_bom_data  ASSIGNING <fs_bom_create>.
* <--- End of change for Defect #4058 by NKUMARI

*** Assigning the value of custom table into BOM item table
    lwa_stpo-item_categ =  lc_item_categ.
    lwa_stpo-item_no    =  lwa_stpo-item_no + 0010.
    lwa_stpo-component  =  <fs_bom_create>-component.
    lwa_stpo-comp_qty   =  1.
    lwa_stpo-comp_unit  =  lc_comp_unit.
** Begin of change by NKUMARI for defect# 1404
    lwa_stpo-rel_cost   = abap_true.
    lwa_stpo-rel_sales  = abap_true.
** End of change by NKUMARI for defect# 1404
    APPEND lwa_stpo TO li_stpo.

** Change the status of record to P(Processing) from I
    <fs_bom_create>-status = lc_process.
  ENDLOOP. " LOOP AT fp_i_bom_data ASSIGNING <fs_bom_create>
  UNASSIGN <fs_bom_create>.

* ---> Begin of change for Defect #4058 by NKUMARI
**&-- Commented Out
** Update the status as 'P' in custom table.
*  IF i_bom_create[] IS NOT INITIAL.
*    PERFORM f_modify_sales_bom USING i_bom_create[].
*  ENDIF. " IF i_bom_create[] IS NOT INITIAL

*  IF gv_error IS INITIAL.

** Convert Internal Date to External
  IF sy-batch IS INITIAL. " Forground
    WRITE p_date TO lv_valid_from.
  ELSE. " ELSE -> IF li_processed_data[] IS NOT INITIAL
    WRITE sy-datum TO lv_valid_from.
  ENDIF. " IF sy-batch IS INITIAL
* <--- End of change for Defect #4058 by NKUMARI

** Sort the internal table on the basis of material and status
  SORT fp_i_bom_data BY matnr status.

*** Read the table for the status 'P'
  READ TABLE fp_i_bom_data TRANSPORTING NO FIELDS WITH KEY matnr  = fp_matnr
                                                           status = lc_process
                                                           BINARY SEARCH.
  IF sy-subrc = 0.
**& Call the FM to create the Material BOM
    CALL FUNCTION 'CSAP_MAT_BOM_CREATE'
      EXPORTING
        material          = fp_matnr
        bom_usage         = p_stlan
        valid_from        = lv_valid_from
        i_stko            = lwa_stko
** Begin of change by NKUMARI for defect# 1404
*          fl_default_values = abap_true
        fl_default_values = space
** End of change by NKUMARI for defect# 1404
      IMPORTING
        bom_no            = gv_bom_no
      TABLES
        t_stpo            = li_stpo[]
      EXCEPTIONS
        error             = 1
        error_message     = 2
        OTHERS            = 3.

    IF sy-subrc <> 0.
***& Read the error Messages using this FM
      CALL FUNCTION 'BALW_BAPIRETURN_GET'
        EXPORTING
          type                       = sy-msgty "  of type
          cl                         = sy-msgid
          number                     = sy-msgno
          par1                       = sy-msgv1
          par2                       = sy-msgv2
          par3                       = sy-msgv3
          par4                       = sy-msgv4
        IMPORTING
          bapireturn                 = lx_messages
        EXCEPTIONS
          only_2_char_for_message_id = 1
          OTHERS                     = 2.
      IF sy-subrc = 0.
** Enter the Message Text into local variable.
        gv_msg_create = lx_messages-message.
      ENDIF. " IF sy-subrc = 0

      gv_err_flg = abap_true.

** Change the status of record to EC(Error Creation) from P
      CLEAR: lwa_bom_create.
      lwa_bom_create-status = lc_err_cre.
      MODIFY i_bom_create FROM lwa_bom_create TRANSPORTING status
                                                    WHERE matnr = fp_matnr.
* ---> Begin of change for Defect #4058 by NKUMARI
*** Modify the satatus in custom table
*        PERFORM f_modify_sales_bom USING i_bom_create[].

      MODIFY fp_i_bom_data FROM lwa_bom_create TRANSPORTING status
                                                      WHERE matnr = fp_matnr.
* <--- End of change for Defect #4058 by NKUMARI

    ELSE. " ELSE -> IF sy-subrc = 0
** Generate the success message for BOM creation
      gv_msg_create = 'BOM Created for this Material'(016).

* ---> Begin of change for Defect #4058 by NKUMARI
** Update the status 'P' in internal table
      CLEAR: lwa_bom_create.
      lwa_bom_create-status = lc_process.
      MODIFY i_bom_create FROM lwa_bom_create TRANSPORTING status
                                                      WHERE matnr = fp_matnr.

* <--- End of change for Defect #4058 by NKUMARI
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-subrc = 0
* ---> Begin of change for Defect #4058 by NKUMARI
*  ELSE. " ELSE -> IF sy-subrc <> 0
*    gv_err_flg = abap_true.
*  ENDIF. " IF gv_error IS INITIAL

  CLEAR:  lwa_bomno.
  lwa_bomno-matnr = fp_matnr.
  lwa_bomno-bomno = gv_bom_no.
  lwa_bomno-msg1  = gv_msg_create.

  APPEND  lwa_bomno TO i_bomno.
* <--- End of change for Defect #4058 by NKUMARI
ENDFORM. " F_JOB_BOM_CREATE
*&---------------------------------------------------------------------*
*&      Form  F_JOB_BOM_EXTEND
*&---------------------------------------------------------------------*
*    BOM Extension for plant assignments
*----------------------------------------------------------------------*
*  <---   FP_WERKS     Plant
*  <---   FP_I_WERKS   Plant table
*----------------------------------------------------------------------*
FORM f_job_bom_extend  USING  fp_i_bom_create TYPE  ty_t_bom_create
                              fp_i_werks      TYPE  ty_t_werks
                              fp_matnr        TYPE  matnr. " Material Number

****----------Data Declaration------------*****
  DATA: lx_messages     TYPE  bapireturn,      " Return Parameter
        lwa_bom_create  TYPE  zotc_bom_create, " Characteristics information for sales BOM creation
*        lv_stnum        TYPE  stnum,           " Bill of material
        lwa_bomno       TYPE  ty_bom_no. "Work Area of BOM detail -- Added for Defect 4058

***-----------Constant Declaration------------*****
  CONSTANTS: lc_err_ext  TYPE  xtype  VALUE 'EE'. " Additional Indicator

* ---> Begin of change for Defect #4058 by NKUMARI
  FIELD-SYMBOLS: <lfs_bomno> TYPE ty_bom_no.

*&-- Check if the BOM created in step 1 exists in the system.
*&-- This is required in the case where both BOM creation and extension runs sequentially
**-- Commented Out
*  IF NOT gv_bom_no IS INITIAL.
*    DO 10 TIMES.
*      SELECT stlnr " Bill of material
*        FROM stko  " BOM Header
*        INTO lv_stnum
*        UP TO 1 ROWS
*        WHERE stlnr = gv_bom_no.
*      ENDSELECT.
*      IF sy-subrc EQ 0.
*        EXIT.
*      ENDIF. " IF sy-subrc EQ 0
*      WAIT UP TO 1 SECONDS.
*    ENDDO.
*  ENDIF. " IF NOT gv_bom_no IS INITIAL
* <--- End of change for Defect #4058 by NKUMARI

  CLEAR lwa_bom_create.
  lwa_bom_create-status = c_complete.
  CONVERT DATE sy-datum TIME sy-uzeit
          INTO TIME STAMP lwa_bom_create-processed
          TIME ZONE sy-zonlo.

  MODIFY fp_i_bom_create FROM lwa_bom_create TRANSPORTING status processed
                                                    WHERE matnr = fp_matnr.

* ---> Begin of change for Defect #4058 by NKUMARI
**-- Commented Out
** Modify the status in custom table
*  IF fp_i_bom_create[] IS NOT INITIAL.
*    PERFORM f_modify_sales_bom  USING  fp_i_bom_create[]
*                                       fp_matnr.
*  ENDIF. " IF fp_i_bom_create[] IS NOT INITIAL
* <--- End of change for Defect #4058 by NKUMARI

  IF gv_error IS INITIAL.
**& Call FM for BOM Extension
    CALL FUNCTION 'CSAP_MAT_BOM_ALLOC_CREATE'
      EXPORTING
        material      = fp_matnr
        bom_usage     = p_stlan
      TABLES
        t_plant       = fp_i_werks[]
      EXCEPTIONS
        error         = 1
        error_message = 2
        OTHERS        = 3.

    IF sy-subrc <> 0.
***& Read the error Messages using this FM
      CALL FUNCTION 'BALW_BAPIRETURN_GET'
        EXPORTING
          type                       = sy-msgty "  of type
          cl                         = sy-msgid
          number                     = sy-msgno
          par1                       = sy-msgv1
          par2                       = sy-msgv2
          par3                       = sy-msgv3
          par4                       = sy-msgv4
        IMPORTING
          bapireturn                 = lx_messages
        EXCEPTIONS
          only_2_char_for_message_id = 1
          OTHERS                     = 2.
      IF sy-subrc = 0.
** Enter the Message Text into local variable.
        gv_msg_extend = lx_messages-message.
      ENDIF. " IF sy-subrc = 0

      gv_err_flg = abap_true.

** Change the status of record to EE(Error Extension) from P
      lwa_bom_create-status = lc_err_ext.
      lwa_bom_create-processed = space.
      MODIFY fp_i_bom_create FROM lwa_bom_create TRANSPORTING status processed
                                                        WHERE matnr = fp_matnr.

* ---> Begin of change for Defect #4058_2 by NKUMARI
** Get the error message for BOM extension.
      PERFORM f_msg_extend USING fp_i_bom_create
                                 fp_matnr
                        CHANGING gv_msg_extend.

**-- Commented Out
*      IF fp_i_bom_create[] IS NOT INITIAL.
*        PERFORM f_modify_sales_bom  USING  fp_i_bom_create[]
*                                           fp_matnr.
*      ENDIF. " IF fp_i_bom_create[] IS NOT INITIAL
* <--- End of change for Defect #4058_2 by NKUMARI

** IF Plant is assigned to BOM
    ELSE. " ELSE -> IF sy-subrc = 0
** Set the message to be mailed for successful BOM extension.
      gv_msg_extend = 'Successful in Extending Material BOM for plant assignment'(018). " Sequence table for MRP units - scope of planning
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF gv_error IS INITIAL

* ---> Begin of change for Defect #4058_2 by NKUMARI
** Update the BOM extension message detail in BOM detail internal table.
  CLEAR:  lwa_bomno.
  READ TABLE i_bomno ASSIGNING <lfs_bomno> WITH KEY matnr = fp_matnr.
  IF sy-subrc IS INITIAL.
    <lfs_bomno>-msg2 =   gv_msg_extend.
*    lwa_bomno-msg2 =   gv_msg_extend.
*    MODIFY i_bomno FROM  lwa_bomno TRANSPORTING msg2
*                                          WHERE matnr = fp_matnr.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    lwa_bomno-matnr  =  fp_matnr.
    lwa_bomno-msg2   =  gv_msg_extend.
    APPEND lwa_bomno TO i_bomno.
  ENDIF. " IF sy-subrc IS INITIAL
* <--- End of change for Defect #4058_2 by NKUMARI
ENDFORM. " F_JOB_BOM_EXTEND
*&---------------------------------------------------------------------*
*&      Form  f_modify_sales_bom
*&---------------------------------------------------------------------*
*     Modifing the custom table 'ZOTC_BOM_CREATE' with characteristic
*     value and status of material
*----------------------------------------------------------------------*
*  -->FP_I_BOM_CREATE   Internal table for BOM
*----------------------------------------------------------------------*
FORM f_modify_sales_bom  USING fp_i_bom_create TYPE ty_t_bom_create . " Characteristics information for sales BOM creation
  CLEAR gv_error.

* ---> Begin of change for Defect #4058 by NKUMARI
  FIELD-SYMBOLS: <lfs_matnr> TYPE ty_matnr.

  LOOP AT i_matnr ASSIGNING <lfs_matnr>.
* <--- End of change for Defect #4058 by NKUMARI
** Lock the table to update the value
    CALL FUNCTION 'ENQUEUE_EZOTC_BOM_CREATE'
      EXPORTING
        matnr          = <lfs_matnr>-matnr "fp_matnr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.
    IF sy-subrc <> 0.
      CONCATENATE 'DB Locking Failed For Material'(021)
                  <lfs_matnr>-matnr "fp_matnr
             INTO gv_error
             SEPARATED BY space.
* ---> Begin of change for Defect #4058 by NKUMARI
*      ELSE. " ELSE -> IF sy-subrc <> 0
      EXIT.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT i_matnr ASSIGNING <lfs_matnr>
  UNASSIGN <lfs_matnr>.

  IF gv_error IS INITIAL.
* <--- End of change for Defect #4058 by NKUMARI

    IF NOT fp_i_bom_create IS INITIAL.
**& Modify custom table 'ZOTC_BOM_CREATE' with updated status of that material
      MODIFY zotc_bom_create FROM TABLE fp_i_bom_create.
      IF sy-subrc EQ 0.
        COMMIT WORK.
      ELSE. " ELSE -> IF sy-subrc EQ 0
        ROLLBACK WORK.
      ENDIF. " IF sy-subrc EQ 0

* ---> Begin of change for Defect #4058 by NKUMARI
    ENDIF. " IF NOT fp_i_bom_create IS INITIAL
    LOOP AT i_matnr ASSIGNING <lfs_matnr>.
* <--- End of change for Defect #4058 by NKUMARI

      CALL FUNCTION 'DEQUEUE_EZOTC_BOM_CREATE'
        EXPORTING
          matnr = <lfs_matnr>-matnr. "fp_matnr.

* ---> Begin of change for Defect #4058 by NKUMARI
    ENDLOOP. " LOOP AT i_matnr ASSIGNING <lfs_matnr>
    UNASSIGN <lfs_matnr>.
*    ENDIF.
* <--- End of change for Defect #4058 by NKUMARI

  ENDIF. " IF gv_error IS INITIAL
ENDFORM. " f_modify_sales_bom
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMAIL_ADD
*&---------------------------------------------------------------------*
*      Get Group E-mail Address of all recipients
*----------------------------------------------------------------------*
*      <--FP_I_MAIL    Email address Table
*----------------------------------------------------------------------*
FORM f_get_email_id  CHANGING  fp_i_mail  TYPE  ty_t_mail. "Email address Table

****----------Data Declaration------------*****
  DATA: li_status   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
        lv_criteria TYPE  z_criteria,                                      " Enh. Criteria
        lwa_mail    TYPE  ty_mail.

***---------Constant Declaration---------*****
  CONSTANTS:  lc_enh_id    TYPE  z_enhancement  VALUE 'D2_OTC_EDD_0212', " Enhancement No.
              lc_null      TYPE  z_criteria     VALUE 'NULL',            " Enh. Criteria
              lc_email_e   TYPE  z_criteria     VALUE 'EMAIL_ERROR',     " Enh. Criteria
              lc_email_s   TYPE  z_criteria     VALUE 'EMAIL_SUCCESS'.   " Enh. Criteria

***-------------Field Symbol Declaration-------------***
  FIELD-SYMBOLS: <lfs_status>   TYPE  zdev_enh_status. " Enhancement Status

** Checking Enhancement Status
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_id
    TABLES
      tt_enh_status     = li_status.
* Delete the records of the internal which is not active
  DELETE li_status WHERE active IS INITIAL.

  READ TABLE li_status TRANSPORTING NO FIELDS
                           WITH KEY criteria = lc_null.
  IF sy-subrc = 0.

    IF gv_err_flg IS INITIAL. " All Successful? - Remove mail id for error log
      lv_criteria = lc_email_s.
    ELSE. " ELSE -> IF sy-subrc = 0
      lv_criteria = lc_email_e.
    ENDIF. " IF sy-subrc = 0

    LOOP AT li_status ASSIGNING <lfs_status> WHERE criteria = lv_criteria.
      lwa_mail-email = <lfs_status>-sel_low.

      APPEND lwa_mail TO fp_i_mail.
      CLEAR lwa_mail.
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status> WHERE criteria = lv_criteria

  ENDIF. " IF sy-subrc = 0

ENDFORM. "f_get_email_id
*&---------------------------------------------------------------------*
*&      Form  F_SEND_MAIL
*&---------------------------------------------------------------------*
*    Send error log file with notification to DL
*----------------------------------------------------------------------*
*    -->FP_I_MAIL       Mail Recipient Detail
*----------------------------------------------------------------------*
* ---> Begin of change for Defect #4058 by NKUMARI
*FORM f_send_mail  USING    fp_i_mail      TYPE  ty_t_mail. " Mail Recipient Detail
*                           fp_msg_create  TYPE  bapi_msg  " Message Text
*                           fp_msg_extend  TYPE  bapi_msg. " Message Text
FORM f_send_mail  USING    fp_i_mail      TYPE  ty_t_mail. " Mail Recipient Detail
* <--- End of change for Defect #4058 by NKUMARI

****---------Local Data Declaration for Sending Mail------*****
  DATA:  li_recipient TYPE  STANDARD TABLE OF zdev_receipients, " InfoUser (SEM-BIC)
         li_msg_bdy   TYPE  bcsy_text,                          " Mail Body
         lwa_msg_bdy  TYPE  soli,                               " SAPoffice: line, length 255
         lv_subjct    TYPE  so_obj_des,                         " Short description of contents
         lv_result    TYPE  boolean.                            " Boolean Variable (X=True, -=False, Space=Unknown)

****----------Constant Declaration------------*****
  CONSTANTS: lc_coma   TYPE abap_bool VALUE ','. " Coma of type CHAR1

***-------------Field Symbol Declaration-------------***
  FIELD-SYMBOLS: <lfs_mail>   TYPE  ty_mail,
* ---> Begin of change for Defect #4058 by NKUMARI
                 <lfs_bomno>  TYPE  ty_bom_no.

** Generate the mail for each material number
  LOOP AT i_bomno ASSIGNING <lfs_bomno>.

    CLEAR: lv_subjct,
           li_msg_bdy.
* <--- End of change for Defect #4058 by NKUMARI

***---------- Mail Subject-----------****
****-->> Begin of change by NKUMARI for defect# 1404
    CONCATENATE 'Express Bioplex Material'(022)
                  <lfs_bomno>-matnr " p_matnr
                'Sales BOM create Status.'(023)
             INTO lv_subjct
             SEPARATED BY space.

***-------Start of Body Content for Mail----------*****
*    CONCATENATE 'Hi'(006)
*                lc_coma
*           INTO lwa_msg_bdy
*           IN CHARACTER MODE.
*    APPEND lwa_msg_bdy TO li_msg_bdy.
****<<-- End of change by NKUMARI for defect# 1404

    CLEAR lwa_msg_bdy.
    lwa_msg_bdy = space.
    APPEND lwa_msg_bdy TO li_msg_bdy.

    CONCATENATE 'Following is the status of BOM creation for material'(008)
               <lfs_bomno>-matnr " p_matnr
           INTO lwa_msg_bdy
           SEPARATED BY space.
    APPEND lwa_msg_bdy TO li_msg_bdy.

    CLEAR lwa_msg_bdy.
    lwa_msg_bdy = space.
    APPEND lwa_msg_bdy TO li_msg_bdy.
****-->> Begin of change by NKUMARI for defect# 1404
    IF  gv_exist_flg IS INITIAL.
****<<-- End of change by NKUMARI for defect# 1404
      CLEAR lwa_msg_bdy.
      lwa_msg_bdy = 'Status:-'(009).
      APPEND lwa_msg_bdy TO li_msg_bdy.

      CLEAR lwa_msg_bdy.
      lwa_msg_bdy = space.
      APPEND lwa_msg_bdy TO li_msg_bdy.

      IF p_create IS NOT INITIAL.
        CLEAR lwa_msg_bdy.
* ---> Begin of change for Defect #4058_2 by NKUMARI
        IF <lfs_bomno>-msg1 IS INITIAL.
          <lfs_bomno>-msg1 = 'Group BOM already created'(013).
        ENDIF. " IF <lfs_bomno>-msg1 IS INITIAL
*<--- End of change Defect #4058_2 by NKUMARI
        CONCATENATE 'BOM creation: '(010)
                     <lfs_bomno>-msg1 "fp_msg_create
                INTO lwa_msg_bdy
                SEPARATED BY space.
        APPEND lwa_msg_bdy TO li_msg_bdy.

        IF p_extend IS INITIAL.
          lwa_msg_bdy = 'Requested to execute BOM Extension'(015).
          APPEND lwa_msg_bdy TO li_msg_bdy.
        ENDIF. " IF p_extend IS INITIAL
      ENDIF. " IF p_create IS NOT INITIAL

      IF NOT p_extend IS INITIAL.
        CLEAR lwa_msg_bdy.
        CONCATENATE 'BOM Extension: '(011)
                     <lfs_bomno>-msg2 "fp_msg_extend
                INTO lwa_msg_bdy
                SEPARATED BY space.
        APPEND lwa_msg_bdy TO li_msg_bdy.
      ENDIF. " IF NOT p_extend IS INITIAL

      IF NOT gv_error IS INITIAL.
        CLEAR lwa_msg_bdy.
        lwa_msg_bdy = gv_error.
        APPEND lwa_msg_bdy TO li_msg_bdy.
      ENDIF. " IF NOT gv_error IS INITIAL
****-->> Begin of change by NKUMARI for defect# 1404
    ENDIF. " IF gv_exist_flg IS INITIAL
****<<-- End of change by NKUMARI for defect# 1404

    CLEAR lwa_msg_bdy.
    lwa_msg_bdy = space.
    APPEND lwa_msg_bdy TO li_msg_bdy.

    CLEAR lwa_msg_bdy.
    lwa_msg_bdy = gv_message.
    APPEND lwa_msg_bdy TO li_msg_bdy.

*    CLEAR lwa_msg_bdy.
*    lwa_msg_bdy = 'Thanks'(012).
*    APPEND lwa_msg_bdy TO li_msg_bdy.
***-------End of Body Content for Mail----------*****

**& Loop at mail address to send mail
    LOOP AT  fp_i_mail  ASSIGNING  <lfs_mail>.
**& Send Mail to Recipient
      CALL FUNCTION 'ZDEV_SEND_EMAIL'
        EXPORTING
          subject        = lv_subjct
          message_body   = li_msg_bdy
          recipient_mail = <lfs_mail>-email
        IMPORTING
          result         = lv_result
        TABLES
          recipients     = li_recipient.
      IF lv_result EQ abap_true.
*        MESSAGE i000 WITH 'Email sent successfully'(014).
        COMMIT WORK.
      ENDIF. " IF lv_result EQ abap_true
    ENDLOOP. " LOOP AT fp_i_mail ASSIGNING <lfs_mail>
* ---> Begin of change for Defect #4058_2 by NKUMARI
  ENDLOOP. " LOOP AT i_bomno ASSIGNING <lfs_bomno>
  MESSAGE i000 WITH 'Email sent successfully'(014).
* <--- End of change for Defect #4058_2 by NKUMARI
ENDFORM. " F_SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  F_JOB_DELETE_ZRECORD
*&---------------------------------------------------------------------*
*&    Delete header material records which are more than 30 days old
*&---------------------------------------------------------------------*
*&    -->FP_I_BOM_CREATE    Material BOM table
*&---------------------------------------------------------------------*
FORM f_job_delete_record  CHANGING  fp_i_bom_create  TYPE  ty_t_bom_create.

****----------Data Declaration------------*****
  DATA: lv_diff   TYPE  i,      " Diff B/w Date
        lv_delete TYPE boolean. " Boolean Variable (X=True, -=False, Space=Unknown)

  FIELD-SYMBOLS: <lfs_matnr> TYPE ty_matnr.
* ---> Begin of change for Defect #4058 by NKUMARI
**& Get the data from custom table for the input material
**      and status is complete.
  PERFORM f_get_processed_data CHANGING fp_i_bom_create.
* <--- End of change for Defect #4058 by NKUMARI

  LOOP AT fp_i_bom_create  ASSIGNING <fs_bom_create>
                               WHERE status = c_complete.
*&-- Derive difference between dates
    PERFORM f_get_date_diff USING <fs_bom_create>-processed
                         CHANGING lv_diff.
*&-- If the difference is less than 30 days then remove the entry
    IF lv_diff LT 30.
      CLEAR <fs_bom_create>-matnr.
    ENDIF. " IF lv_diff LT 30
    lv_delete = abap_true.
  ENDLOOP. " LOOP AT fp_i_bom_create ASSIGNING <fs_bom_create>

  IF NOT lv_delete IS INITIAL. " Check if there are any records for deletion
    DELETE fp_i_bom_create WHERE matnr IS INITIAL.


**& Delete the processed records from custom table
    IF NOT fp_i_bom_create IS INITIAL.
* ---> Begin of change for Defect #4058 by NKUMARI
      LOOP AT i_matnr  ASSIGNING <lfs_matnr>.
* <--- End of change for Defect #4058 by NKUMARI
        CALL FUNCTION 'ENQUEUE_EZOTC_BOM_CREATE'
          EXPORTING
            matnr          = <lfs_matnr>-matnr "p_matnr
          EXCEPTIONS
            foreign_lock   = 1
            system_failure = 2
            OTHERS         = 3.
        IF sy-subrc <> 0.
          CONCATENATE 'DB Locking Failed For Material - '(021)
                      <lfs_matnr>-matnr " p_matnr
          INTO gv_error SEPARATED BY space.
* ---> Begin of change for Defect #4058 by NKUMARI
*          ELSE. " ELSE -> IF sy-subrc <> 0
          EXIT.
        ENDIF. " IF sy-subrc <> 0
      ENDLOOP. " LOOP AT i_matnr ASSIGNING <lfs_matnr>
      UNASSIGN <fs_bom_create>.

      IF gv_error IS INITIAL.
* <--- End of change for Defect #4058 by NKUMARI

        DELETE zotc_bom_create FROM TABLE fp_i_bom_create.
        IF sy-subrc EQ 0.
** If table successfully updated, Execute external Commit
          COMMIT WORK.
** Generate error message
          gv_message = 'Processed records deteted Successfully'(020).
        ELSE. " ELSE -> IF sy-subrc EQ 0
          ROLLBACK WORK.
        ENDIF. " IF sy-subrc EQ 0
* ---> Begin of change for Defect #4058 by NKUMARI
        LOOP AT i_matnr  ASSIGNING <lfs_matnr>.
* <--- End of change for Defect #4058 by NKUMARI
*&-- Unlock the DB
          CALL FUNCTION 'DEQUEUE_EZOTC_BOM_CREATE'
            EXPORTING
* ---> Begin of change for Defect #4058 by NKUMARI
*              matnr = p_matnr.
               matnr = <lfs_matnr>-matnr.
        ENDLOOP. " LOOP AT i_matnr ASSIGNING <lfs_matnr>
        UNASSIGN <fs_bom_create>.
      ENDIF. " IF gv_error IS INITIAL
*    ENDIF. " LOOP at i_matnr ASSIGNING <lfs_matnr>
* <--- End of change for Defect #4058 by NKUMARI
    ENDIF. " IF NOT fp_i_bom_create IS INITIAL
  ENDIF. " IF NOT LV_DELETE IS INITIAL
ENDFORM. " F_JOB_DELETE_ZRECORD
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATE_DIFF
*&---------------------------------------------------------------------*
*&      Determine the days difference between 2 dates
*----------------------------------------------------------------------*
*      -->FP_PROCESSED  Record creation Timestamp
*      <--FP_DIFF       Difference
*----------------------------------------------------------------------*
FORM f_get_date_diff  USING fp_processed TYPE cts_timestamp " Timestamp (char 14 - YYYYMMDDHHMMSS)
                   CHANGING fp_diff      TYPE i.            " Diff of type Integers

****----------Data Declaration------------*****
  DATA: lv_p_date    TYPE  sydatum,   " Current Date of Application Server
        lv_processed TYPE  ad_tstamp. " Time Stamp

  CLEAR fp_diff.

  lv_processed = fp_processed.
**& Convert the Time stamp into date
  CONVERT TIME STAMP fp_processed
           TIME ZONE sy-zonlo
           INTO DATE lv_p_date.
**& Difference between current date and data processed date
  fp_diff = sy-datum - lv_p_date.

  IF sy-subrc <> 0.
    fp_diff = 0.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_GET_DATE_DIFF

* ---> Begin of change for Defect #4058 by NKUMARI
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATE
*&---------------------------------------------------------------------*
*      Validate input field Date
*----------------------------------------------------------------------*
*      <--FP_DATE  Date
*----------------------------------------------------------------------*
FORM f_validate_date  CHANGING fp_date.
**If the program executed in the foreground,
**Date shall be input and mandatory and not defaulted.
  IF sy-batch IS INITIAL.
    IF fp_date IS INITIAL.
** Generate error message
      MESSAGE e127 WITH 'Date'(024).
    ENDIF. " IF fp_date IS INITIAL
  ELSE. " ELSE -> IF fp_date IS INITIAL
** Convert Internal Date to External
    WRITE sy-datum TO fp_date.
  ENDIF. " IF sy-batch IS INITIAL
ENDFORM. " F_VALIDATE_DATE
*&---------------------------------------------------------------------*
*&      Form  GET_PROCESSED_DATA
*&---------------------------------------------------------------------*
*      Get Processed Data from custom table
*----------------------------------------------------------------------*
*      <--FP_I_BOM_CREATE      Material BOM table
*----------------------------------------------------------------------*
FORM f_get_processed_data  CHANGING fp_i_bom_create TYPE ty_t_bom_create.

  CLEAR: fp_i_bom_create.

**& Get all the complete records from the Custom table.
  IF i_matnr[] IS NOT INITIAL.
    SELECT mandt           " Client
           matnr           " Material Number
           component       " Material Number
           status          " Checkbox
           created         " Timestamp (char 14 - YYYYMMDDHHMMSS)
           processed       " Timestamp (char 14 - YYYYMMDDHHMMSS)
     FROM  zotc_bom_create " Characteristics information for sales BOM creation
     INTO TABLE fp_i_bom_create
     FOR ALL ENTRIES IN i_matnr
     WHERE matnr = i_matnr-matnr
     AND status = c_complete.
    IF sy-subrc = 0.
** Do Nothing
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF i_matnr[] IS NOT INITIAL

ENDFORM. "get_processed_data
* <--- End of change for Defect #4058 by NKUMARI
* ---> Begin of change for Defect #4058_2 by NKUMARI
*&---------------------------------------------------------------------*
*&      Form  F_MSG_EXTEND
*&---------------------------------------------------------------------*
*       Generate the Error message if BOM extension is fail
*----------------------------------------------------------------------*
*      -->FP_I_BOM_CREATE  Material BOM table
*      -->FP_MATNR         Material number
*      <--FP_MSG_EXTEND    Error Message for BOM extension
*----------------------------------------------------------------------*
FORM f_msg_extend  USING fp_i_bom_create TYPE ty_t_bom_create " Material BOM table
                         fp_matnr        TYPE matnr           " Material Number
                CHANGING fp_msg_extend   TYPE bapi_msg.       " Message Text

** Structure of Material component
  TYPES: BEGIN OF lty_component,
           component TYPE matnr, " Material Number
        END OF lty_component.

  DATA:
        lwa_comp      TYPE lty_component,                   " Work area of Material component
        lv_component  TYPE string,                          " Material Component
        li_marc_comp  TYPE ty_t_marc,                       " MARC table
        li_marc_temp  TYPE ty_t_marc,                       " MARC temporary table
        lv_plant      TYPE werks_d,                         " Plant
        lv_plant_msg  TYPE string,                          " Plant string
        li_component  TYPE STANDARD TABLE OF lty_component. " Local internal table of material component

**** Field Symbol Declaration
  FIELD-SYMBOLS : <lfs_marc>  TYPE ty_marc,
                 <lfs_s_comp> TYPE lty_component.

  CONSTANTS: lc_coma TYPE xfeld VALUE ','. " Coma Constant

*&--Copy the plant data into temporary table.
  li_marc_temp[] = i_marc[].
  DELETE li_marc_temp WHERE matnr NE fp_matnr.
*&--Copy the MARC data into another table.
  li_marc_comp[] = i_marc[].
  DELETE li_marc_comp WHERE matnr = fp_matnr.
  SORT li_marc_comp BY matnr werks.

  LOOP AT fp_i_bom_create ASSIGNING <fs_bom_create>.

    LOOP AT li_marc_temp ASSIGNING <lfs_marc> WHERE matnr = <fs_bom_create>-matnr.

      READ TABLE li_marc_comp TRANSPORTING NO FIELDS WITH KEY matnr = <fs_bom_create>-component
                                                              werks = <lfs_marc>-werks
                                                              BINARY SEARCH.
      IF sy-subrc NE 0.
        IF lv_plant_msg IS INITIAL.
          lv_plant     = <lfs_marc>-werks.
          lv_plant_msg = <lfs_marc>-werks.
        ELSE. " ELSE -> IF lv_plant_msg IS INITIAL
** If the plant is not same as previous plant value, then concatenate the plant into variable
          IF lv_plant NE <lfs_marc>-werks.
            CONCATENATE lv_plant
                        lc_coma
                        <lfs_marc>-werks
                   INTO lv_plant_msg
            SEPARATED BY space.
            lv_plant = <lfs_marc>-werks.
          ENDIF. " IF lv_plant NE <lfs_marc>-werks
        ENDIF. " IF lv_plant_msg IS INITIAL
*&--- Move the component which is not maintained against the plant into internal table
        lwa_comp-component = <fs_bom_create>-component.
        APPEND lwa_comp TO li_component.
      ENDIF. " IF sy-subrc NE 0
    ENDLOOP. " LOOP AT li_marc_temp ASSIGNING <lfs_marc> WHERE matnr = <fs_bom_create>-matnr
  ENDLOOP. " LOOP AT fp_i_bom_create ASSIGNING <fs_bom_create>

*&-- Contatenate all the components name into local variable
  IF li_component IS NOT INITIAL.
    CLEAR: lwa_comp.
    LOOP AT li_component ASSIGNING <lfs_s_comp>.
      IF lv_component IS INITIAL.
        lv_component = <lfs_s_comp>.
      ELSE. " ELSE -> IF lv_component IS INITIAL
        CONCATENATE lv_component
                    <lfs_s_comp>
               INTO lv_component
        SEPARATED BY lc_coma.
      ENDIF. " IF lv_component IS INITIAL
    ENDLOOP. " LOOP AT li_component ASSIGNING <lfs_s_comp>

*&-- Generate the BOM extension message
    CONCATENATE 'Error in Extending the BOM.'(006)
                'Component'(025)
                lv_component
                'not maintained in plant'(026)
                lv_plant_msg
           INTO fp_msg_extend
           SEPARATED BY space.

  ENDIF. " IF li_component IS NOT INITIAL
ENDFORM. " F_MSG_EXTEND
*&---------------------------------------------------------------------*
*&      Form  F_GET_MARC
*&---------------------------------------------------------------------*
*      Get the data from MARC table
*----------------------------------------------------------------------*
*      -->FP_I_MARC    MARC table
*----------------------------------------------------------------------*
FORM f_get_marc CHANGING fp_i_marc TYPE ty_t_marc.

  REFRESH i_matnr_range.
  DATA: lwa_range TYPE bapi_rangesmatnr. " BAPI Selection Structure: Material Number

  LOOP AT i_bom_create ASSIGNING <fs_bom_create>.
    IF NOT <fs_bom_create>-component IS INITIAL.
      CLEAR lwa_range.
      lwa_range-sign   = if_cwd_constants=>c_sign_inclusive.
      lwa_range-option = if_cwd_constants=>c_option_equals.
      lwa_range-low = <fs_bom_create>-component.
      APPEND lwa_range TO i_matnr_range.
    ENDIF. " IF NOT <fs_bom_create>-component IS INITIAL

    IF NOT <fs_bom_create>-matnr IS INITIAL.
      CLEAR lwa_range.
      lwa_range-sign   = if_cwd_constants=>c_sign_inclusive.
      lwa_range-option = if_cwd_constants=>c_option_equals.
      lwa_range-low = <fs_bom_create>-matnr.
      APPEND lwa_range TO i_matnr_range.
    ENDIF. " IF NOT <fs_bom_create>-matnr IS INITIAL
  ENDLOOP. " LOOP AT i_bom_create ASSIGNING <fs_bom_create>

**Select from MARC table
  IF NOT i_matnr_range IS INITIAL.
    SELECT matnr " Material Number
           werks " Plant
     FROM marc   " Plant Data for Material
     INTO TABLE fp_i_marc
     FOR ALL ENTRIES IN i_matnr_range
     WHERE matnr = i_matnr_range-low.
    IF sy-subrc = 0.
      IF NOT s_werk IS INITIAL.
        DELETE fp_i_marc WHERE werks NOT IN s_werk.
      ENDIF. " IF NOT s_werk IS INITIAL
      SORT fp_i_marc BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF NOT i_matnr_range IS INITIAL

ENDFORM. " F_GET_MARC
* <--- End of change for Defect #4058_2 by NKUMARI
