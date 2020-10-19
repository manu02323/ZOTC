*&---------------------------------------------------------------------*
*&  Include           ZOTCC0091B_SALESBOM_CONV_SUB
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTCC0091B_SALESBOM_CONV_SUB                           *
* TITLE      :  Sales BOM Conversion                                   *
* DEVELOPER  :  Shoban Mekala                                          *
* OBJECT TYPE:  Conversion Program                                     *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0091                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Sales BOM                                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Sep-2014 SMEKALA  E2DK905288 INITIAL DEVELOPMENT                  *
* 20-FEB-2015 SMEKALA  E2DK905288 Def#3510: Added validation for Material
*                                 and plant combination                *
* 15-May-2015 SMEKALA  E2DK913098 Def#6622: Page down scenario not     *
*                                 working                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*

FORM f_modify_screen .
  LOOP AT SCREEN .
*-- Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*-- Hiding Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*-- Presentation Server Option IS chosen
    ELSE. " ELSE -> IF screen-group1 = c_groupmi3
*-- Disaplying Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*-- Application Server Option is NOT chosen
    IF rb_app NE c_true.
*-- Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*--  Application Server Option IS chosen
    ELSE. " ELSE -> IF screen-group1 = c_groupmi2
*-- If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ c_true.
*       Dispalying Application Server Physical paths with modifid MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Hiding Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSE. " ELSE -> IF screen-group1 = c_groupmi7
*       Hiding Application Server - Physical paths with modifidd MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical Filaename input with modifid MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
      ENDIF. " IF rb_aphy EQ c_true
    ENDIF. " IF rb_app NE c_true

  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
FORM f_check_extension  USING    fp_p_file TYPE localfile. " Local file for upload/download
  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING    fp_p_file
                              CHANGING gv_extn.
    IF gv_extn <> c_text.
*Please provide TXT file
      MESSAGE e008.
    ENDIF. " IF gv_extn <> c_text
  ENDIF. " IF fp_p_file IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
FORM f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issuing the error message.
  IF rb_pres IS NOT INITIAL AND
     p_pfile IS INITIAL.
    MESSAGE i009.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Optin has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_afile IS INITIAL.
      MESSAGE i010.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i011.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL
ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_SET_MODE
*&---------------------------------------------------------------------*
FORM f_set_mode  CHANGING fp_gv_save TYPE char1   " Set mode
                          fp_gv_mode TYPE char10. " mode to decide post run or test run

* If Verify and Post is selected, then putting the Flag ON
  IF rb_post IS NOT INITIAL.
    fp_gv_save = c_true.
  ELSE. " ELSE -> IF rb_post IS NOT INITIAL
    fp_gv_save = space.
  ENDIF. " IF rb_post IS NOT INITIAL

* Choosing the Mode
  IF rb_post = c_true.
    fp_gv_mode = 'Post Run'(004).
  ELSE. " ELSE -> IF rb_post = c_true
    fp_gv_mode = 'Test Run'(005).
  ENDIF. " IF rb_post = c_true
ENDFORM. " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
FORM f_upload_pres  USING    fp_p_file TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA: lv_filename TYPE string. "File Name
* Local Constant Declaration
  CONSTANTS: lc_true TYPE char1 VALUE 'X'. " True of type CHAR1

*if background mode is on,then file cannot be uploaded from presentation server
  IF sy-batch = lc_true.
    MESSAGE i164.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-batch = lc_true

  lv_filename = fp_p_file.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_file_type
      has_field_separator     = c_sep
    CHANGING
      data_tab                = i_final
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      not_supported_by_gui    = 17
      error_no_gui            = 18
      OTHERS                  = 19.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i162 WITH lv_filename.
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

    DELETE i_final INDEX 1.

  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog  TYPE pathintern " Logical path name
                            CHANGING fp_gv_file TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,    "Local Input table
        lwa_input  TYPE zdev_file_list_in,      "Local work area
        li_output  TYPE zdev_t_file_list_out,   "Local Output Table
        lwa_output TYPE zdev_file_list_out,     "Local work area
        li_error   TYPE zdev_t_file_list_error. "Local error table

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retriving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = c_lp_ind "Value: X
      im_input           = li_input
    IMPORTING
      ex_output          = li_output
      ex_error           = li_error
    EXCEPTIONS
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      OTHERS             = 4.

  IF sy-subrc <> 0.
    MESSAGE i000 WITH 'No proper file exist for the logical file.'(006).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
                  lwa_output-filename
     INTO  fp_gv_file.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL AND
ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
FORM f_upload_apps  USING    fp_p_file TYPE localfile. " Local file for upload/download

*local data declaration
  DATA:  lv_input_line TYPE string,  "Input Raw lines
         lv_subrc      TYPE sysubrc. "SY-SUBRC value

* Opening the Dataset for File Read
  OPEN DATASET fp_p_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
  IF sy-subrc IS INITIAL.
* Reading the Header Input File
    WHILE ( lv_subrc EQ 0 ).
      READ DATASET fp_p_file INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
      IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
        SPLIT lv_input_line AT c_tab
        INTO wa_final-matnr "material no.
             wa_final-stlan "BoM usage
             wa_final-postp "Item Category
             wa_final-idnrk "Component
             wa_final-menge "Component quantity
             wa_final-datuv
             wa_final-datub.
        APPEND wa_final TO i_final.
        CLEAR: wa_final.
        CLEAR lv_input_line.

      ENDIF. " IF lv_subrc IS INITIAL
    ENDWHILE.
  ELSE. " ELSE -> IF lv_subrc IS INITIAL
*   Leaving the program if OPEN Dataset fails for data upload
    MESSAGE i163 WITH fp_p_file.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

* Closing the Dataset.
  CLOSE DATASET fp_p_file.

* Deleting the First Index Line from the table
  DELETE i_final INDEX 1.

ENDFORM. " F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
FORM f_validation .

*-- Local Structures
  TYPES:
  BEGIN OF lty_mara,
    matnr TYPE matnr, " Material Number
  END OF lty_mara,

  BEGIN OF lty_stlan,
    stlan TYPE stlan, " BOM Usage
  END OF lty_stlan,

  BEGIN OF lty_postp,
    postp TYPE postp, " Item Category (Bill of Material)
  END OF lty_postp,

*-- Begin of defect#3510
  BEGIN OF lty_marc,
    matnr TYPE matnr,   " Material Number
    werks TYPE werks_d, " Plant
    lvorm TYPE lvowk,   " Flag Material for Deletion at Plant Level
  END OF lty_marc.

*-- End of defect#3510

*-- Local internal tables
  DATA:
  li_mara TYPE STANDARD TABLE OF lty_mara,
  li_stlan TYPE STANDARD TABLE OF lty_stlan,
  li_postp TYPE STANDARD TABLE OF lty_postp,
  li_final TYPE ty_t_final,
  li_marc TYPE STANDARD TABLE OF lty_marc,     "defect#3510
  li_matplant TYPE STANDARD TABLE OF lty_marc. "defect#3510

*-- Local variables
  DATA:
  lv_err_flg TYPE char1,   " Err_flg of type CHAR1
  lv_temp1   TYPE string,  " 4 byte integer (signed)
  lv_temp2   TYPE string,  " 4 byte integer (signed)
  lv_exist   TYPE char1,   " Exist of type CHAR1
  lv_tabix   TYPE sytabix, " Index of Internal Tables
  lv_nomarc  TYPE char1.   "defect#3510

  DATA:
    lwa_matplant TYPE lty_marc.
*-- Local field sysmbols
  FIELD-SYMBOLS:
  <lfs_final> TYPE ty_final,
  <lfs_mast>  TYPE ty_mast,
  <lfs_marc>  TYPE lty_marc,        "defect#3510
  <lfs_plant> TYPE zdev_enh_status. " Enhancement Status

  REFRESH :li_final.
**Get all the materials
  li_final[] = i_final[].
  DELETE li_final WHERE matnr IS INITIAL.
  SORT li_final BY matnr idnrk.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr idnrk.

*-- Begin of defect#3510
*-- collect the combination of materials and plants for validation
  LOOP AT li_final ASSIGNING <lfs_final>.
    LOOP AT i_emiplant ASSIGNING <lfs_plant>.
      lwa_matplant-matnr = <lfs_final>-matnr.
      lwa_matplant-werks = <lfs_plant>-sel_low.
      APPEND lwa_matplant TO li_matplant.
      CLEAR lwa_matplant.
    ENDLOOP. " LOOP AT i_emiplant ASSIGNING <lfs_plant>
  ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final>

  SORT li_matplant BY matnr werks.
  DELETE ADJACENT DUPLICATES FROM li_matplant COMPARING matnr werks.

  IF NOT li_matplant[] IS INITIAL.
    SELECT matnr werks lvorm
      FROM marc " Plant Data for Material
      INTO TABLE li_marc
      FOR ALL ENTRIES IN li_matplant
      WHERE matnr = li_matplant-matnr
        AND werks = li_matplant-werks.
    IF sy-subrc EQ 0.
      DELETE li_marc WHERE lvorm EQ abap_true.
      SORT li_marc BY matnr werks.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_matplant[] IS INITIAL
*-- End of defcet#3510
  IF li_final[] IS NOT INITIAL.
*-- get the materials from MARA for validation
    SELECT matnr " Material Number
      FROM mara  " General Material Data
      INTO TABLE li_mara
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr
      OR    matnr = li_final-idnrk.
    IF sy-subrc = 0.
      SORT li_mara BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**Get all the BoM Usages
  li_final[] = i_final[].
  DELETE li_final WHERE stlan IS INITIAL.
  SORT li_final BY stlan.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING stlan.

  IF li_final[] IS NOT INITIAL.
    SELECT stlan " BOM Usage
    FROM t416    " BOM Usage - Item Statuses
    INTO TABLE li_stlan
    FOR ALL ENTRIES IN li_final
    WHERE stlan = li_final-stlan.
    IF sy-subrc = 0.
      SORT li_stlan BY stlan.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**Get all the Item Categories
  li_final[] = i_final[].
  DELETE li_final WHERE postp IS INITIAL.
  SORT li_final BY postp.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING postp.

  IF li_final[] IS NOT INITIAL.
    SELECT postp " Item category
    FROM t418    " Item Categories
    INTO TABLE li_postp
    FOR ALL ENTRIES IN li_final
    WHERE postp = li_final-postp.
    IF sy-subrc = 0.
      SORT li_postp BY postp.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

* Get existed BOM
  li_final[] = i_final[].
  DELETE li_final WHERE matnr IS INITIAL.
  SORT li_final BY matnr stlan.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr stlan.

  IF li_final[] IS NOT INITIAL.
    SELECT matnr werks stlan stlnr stlal
      FROM mast " Material to BOM Link
      INTO TABLE i_mast
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr
        AND stlan = li_final-stlan.
    IF sy-subrc = 0.
      SORT i_mast BY matnr werks stlan.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**Validate Input fields
  LOOP AT i_final ASSIGNING <lfs_final>.
    CLEAR: lv_err_flg,
           wa_invbom.
**validate Exclusion type
    IF <lfs_final>-matnr IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      MOVE <lfs_final>-matnr TO wa_invbom-matnr.
      APPEND wa_invbom TO i_invbom.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Material Number can not be blank.'(009).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Material Number can not be blank.'(009).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-matnr IS INITIAL
      READ TABLE li_mara TRANSPORTING NO FIELDS
                          WITH KEY matnr = <lfs_final>-matnr
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Material Number.'(010).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Material Number.'(010).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-matnr IS INITIAL

**Validate BoM Component.
    IF <lfs_final>-idnrk IS INITIAL.
* BOM Component should not be validated for the item category = 'T'.

*      error
      lv_err_flg = c_true.
      MOVE <lfs_final>-matnr TO wa_invbom-matnr.
      APPEND wa_invbom TO i_invbom.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'BoM Component can not be blank.'(011).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'BoM Component can not be blank.'(011).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-idnrk IS INITIAL
      READ TABLE li_mara TRANSPORTING NO FIELDS
                          WITH KEY matnr = <lfs_final>-idnrk
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid BoM Component.'(012).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid BoM Component.'(012).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-idnrk IS INITIAL

***Validate BoM Usage
    IF <lfs_final>-stlan IS INITIAL.
*      error
      lv_err_flg = c_true.
      MOVE <lfs_final>-matnr TO wa_invbom-matnr.
      APPEND wa_invbom TO i_invbom.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'BoM Usage can not be blank.'(013).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'BoM Usage can not be blank.'(013).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.
    ELSE. " ELSE -> IF <lfs_final>-stlan IS INITIAL

      READ TABLE li_stlan TRANSPORTING NO FIELDS
                          WITH KEY stlan = <lfs_final>-stlan
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid BoM Usage.'(014).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid BoM Usage.'(014).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-stlan IS INITIAL

**Validate Item Category
    IF <lfs_final>-postp IS INITIAL.
*      error
      lv_err_flg = c_true.
      MOVE <lfs_final>-matnr TO wa_invbom-matnr.
      APPEND wa_invbom TO i_invbom.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Item Category can not be blank.'(015).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Item Category can not be blank.'(015).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.
    ELSE. " ELSE -> IF <lfs_final>-postp IS INITIAL
      READ TABLE li_postp TRANSPORTING NO FIELDS
                          WITH KEY postp = <lfs_final>-postp
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Item Category.'(016).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Item Category.'(016).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-postp IS INITIAL

**Validate Quantity
    IF <lfs_final>-menge IS INITIAL
       OR <lfs_final>-menge EQ '0'
       OR <lfs_final>-menge EQ '0.00'
       OR <lfs_final>-menge EQ '0.000'.
*      error
      lv_err_flg = c_true.
      MOVE <lfs_final>-matnr TO wa_invbom-matnr.
      APPEND wa_invbom TO i_invbom.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Quantity cannot be initial.'(017).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Quantity cannot be initial.'(017).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.
    ENDIF. " IF <lfs_final>-menge IS INITIAL

** Validate BOM for all plants

    LOOP AT i_emiplant ASSIGNING <lfs_plant>.
      IF sy-tabix = 1.
        READ TABLE i_mast WITH KEY matnr = <lfs_final>-matnr
                                    stlan = <lfs_final>-stlan
                                    TRANSPORTING NO FIELDS.
        IF sy-subrc EQ 0.
          lv_exist = c_x.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-tabix = 1

      READ TABLE i_mast WITH KEY matnr = <lfs_final>-matnr
                                 werks = <lfs_plant>-sel_low
                                stlan = <lfs_final>-stlan
                                BINARY SEARCH
                                TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        CLEAR lv_exist.
      ENDIF. " IF sy-subrc NE 0

*-- Begin of defect#3510
* check if Material Plant combination available
      READ TABLE li_marc TRANSPORTING NO FIELDS WITH KEY matnr = <lfs_final>-matnr
                                                         werks = <lfs_plant>-sel_low
                                                         BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_err_flg = c_true.

        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        CONCATENATE 'Material'(031)
                    <lfs_final>-matnr
                    'not extendted to the plant'(030)
                    <lfs_plant>-sel_low
                INTO wa_report-msgtxt
         SEPARATED BY space.
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        CONCATENATE 'Material'(031)
                    <lfs_final>-matnr
                    'not extendted to the plant'(030)
                    <lfs_plant>-sel_low
                INTO wa_report-msgtxt
         SEPARATED BY space.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
*-- End of defect#3510
    ENDLOOP. " LOOP AT i_emiplant ASSIGNING <lfs_plant>

    IF lv_exist = c_x.
*      error
      lv_err_flg = c_true.

      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'BOM already defined.'(021).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'BOM already defined.'(021).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.
    ENDIF. " IF lv_exist = c_x

    IF lv_err_flg IS INITIAL.
**populate data for processing
      APPEND <lfs_final> TO i_valid.
    ENDIF. " IF lv_err_flg IS INITIAL

  ENDLOOP. " LOOP AT i_final ASSIGNING <lfs_final>

* Logic for avoiding to create Partial BOMs by PGOLLA
  IF NOT i_invbom[] IS INITIAL.
    CLEAR wa_invbom.
    LOOP AT i_invbom INTO wa_invbom.
      DELETE i_valid WHERE matnr = wa_invbom-matnr.
      CLEAR wa_invbom.
    ENDLOOP. " LOOP AT i_invbom INTO wa_invbom
  ENDIF. " IF NOT i_invbom[] IS INITIAL
* End of logic by PGOLLA

  SORT i_error BY matnr stlan.
  LOOP AT i_valid ASSIGNING <lfs_final>.
    lv_tabix = sy-tabix.
    CLEAR wa_error.
    READ TABLE i_error INTO wa_error WITH KEY matnr = <lfs_final>-matnr
                                              stlan = <lfs_final>-stlan
                                              BINARY SEARCH.
    IF sy-subrc = 0.
      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'An error record exists with same material and usage'(029).
      APPEND wa_error TO i_error.

      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'An error record exists with same material and usage'(029).
      APPEND wa_report TO i_report.

      DELETE i_valid INDEX lv_tabix.
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT i_valid ASSIGNING <lfs_final>

  SORT i_error BY matnr stlan.

  lv_temp1 = lines( i_final ).
  lv_temp2 = lines( i_valid ).
**Successful records
  gv_scount = lv_temp2.
**Error records
  gv_ecount = lv_temp1 - lv_temp2.

*-- Free internal tables
  FREE:
  li_mara,
  li_stlan,
  li_postp,
  li_final.
ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*
FORM f_error_key_sub  USING  fp_err_key TYPE ty_final.

* populate error Key
  CONCATENATE
  fp_err_key-matnr
  fp_err_key-stlan
  fp_err_key-postp
  fp_err_key-idnrk
  fp_err_key-menge
  fp_err_key-datuv
  fp_err_key-datub
 INTO wa_report-key
 SEPARATED BY c_fslash.

ENDFORM. " F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*
*&      Form  F_POP_ERROR_FILE
*&---------------------------------------------------------------------*
FORM f_pop_error_file  USING    fp_err_data TYPE ty_final.
  wa_error-matnr = fp_err_data-matnr.
  wa_error-stlan = fp_err_data-stlan.
  wa_error-postp = fp_err_data-postp.
  wa_error-idnrk = fp_err_data-idnrk.
  wa_error-menge = fp_err_data-menge.
  wa_error-datuv = fp_err_data-datuv.
  wa_error-datub = fp_err_data-datub.
ENDFORM. " F_POP_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  F_EXECUTE_BDC
*&---------------------------------------------------------------------*
FORM f_execute_bdc  USING    fp_i_final TYPE ty_t_final
                 CHANGING fp_i_error TYPE ty_t_error.

*-- local constant declaration
  CONSTANTS:
    lc_keep TYPE apq_qdel VALUE 'X'. " Queue deletion indicator for processed sessions

*-- local data declaration
  DATA :
    lv_field     TYPE bdc_fval,                   " BoM Item index no.
    lv_index1    TYPE sytabix,                    " Index of Internal Tables
    lv_index     TYPE numc4,                      " Count Parameters
    lv_index2    TYPE numc4,                      " Two digit number
    lv_count     TYPE numc06,                     " Two digit number
    lv_count1    TYPE numc06,                     " Two digit number
    lv_flag      TYPE flag,                       " Control Flag
    lv_error     TYPE char1,                      " Error of type CHAR1
    lv_matbom    TYPE char1,                      " Matbom of type CHAR1
    lv_date      TYPE char10,                     " Date of type CHAR10
    lwa_final    TYPE ty_final,
    lwa_tmp_final TYPE ty_final,
    li_final_tmp TYPE STANDARD TABLE OF ty_final, "int.table for BoM data
    li_final     TYPE STANDARD TABLE OF ty_final. "int.table for BoM data

*------------------------local field symbol declaration----------------*
  FIELD-SYMBOLS :
    <lfs_plant>  TYPE zdev_enh_status,     " Enhancement Status
    <lfs_plant_tmp>  TYPE zdev_enh_status. " Enhancement Status

*if after passing the validation ,the BoM data is there in the table fp_i_final[]
*then open the BDC Group.
  IF fp_i_final[] IS NOT INITIAL.
    CALL FUNCTION 'BDC_OPEN_GROUP'    "Open batch input session for adding transactions
     EXPORTING
        client              = sy-mandt
        group               = c_group "value:OTC_0091
        keep                = lc_keep "value:X
        user                = sy-uname
      EXCEPTIONS
        client_invalid      = 1
        destination_invalid = 2
        group_invalid       = 3
        group_is_locked     = 4
        holddate_invalid    = 5
        internal_error      = 6
        queue_error         = 7
        running             = 8
        system_lock_error   = 9
        user_invalid        = 10
        OTHERS              = 11.

    IF sy-subrc <> 0.
*Error in BDC Session &
      MESSAGE i051 WITH c_group .
    ELSE. " ELSE -> IF sy-subrc <> 0
*assigning the table containing the valid records to a temporary table
      li_final[] = fp_i_final[].

*  sorting the li_final based on the key combination i.e Material,Plant,BoM usage and Alt.BoM
      SORT li_final BY matnr stlan.

      LOOP AT li_final INTO lwa_tmp_final.
        lwa_final = lwa_tmp_final.

        AT NEW stlan.
          CLEAR: lv_error,
                 lv_matbom,
                 lv_index.
*--> Begin of SMEKALA Def#6622
          CLEAR lv_flag.
*<-- End of SMEKALA Def#6622

          READ TABLE i_mast WITH KEY matnr = lwa_final-matnr
                                     stlan = lwa_final-stlan
                                     TRANSPORTING NO FIELDS.
          IF sy-subrc NE 0.
            lv_matbom = c_x.
*-- Screen 100
            PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0100'.
            PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
            PERFORM f_bdc_field       USING 'RC29N-MATNR'
                                            lwa_final-matnr.
            PERFORM f_bdc_field       USING 'RC29N-STLAN'
                                            lwa_final-stlan.
            IF NOT lwa_final-datuv IS INITIAL.
              PERFORM f_bdc_field       USING 'RC29N-DATUV'
                                              lwa_final-datuv.
            ELSE. " ELSE -> IF NOT lwa_final-datuv IS INITIAL
              WRITE sy-datum TO lv_date.
              PERFORM f_bdc_field       USING 'RC29N-DATUV'
                                               lv_date.
            ENDIF. " IF NOT lwa_final-datuv IS INITIAL

*-- Screen 110
            PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0110'.
            PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                            'RC29K-STLST'.
            PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                            '/00'.
            PERFORM f_bdc_field       USING 'RC29K-BMENG'
                                            lwa_final-menge.
            PERFORM f_bdc_field       USING 'RC29K-STLST'
                                             '1'.
            PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                            'SAPLCSDI                                0800STLKOPF'.
*-- Screen 111
            PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0111'.
            PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                            'RC29K-LABOR'.
            PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                             '/00'.
            PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                            'SAPLCSDI                                0801STLKOPF'.

          ENDIF. " IF sy-subrc NE 0
        ENDAT.
        IF lv_matbom EQ c_x.
* set the index of each BOM

**Start of implementing the functionality for Page down
          lv_count = lv_count + 1.
          IF lv_count > 14.
            lv_count1 = lv_count1 + 1.
            IF lv_count1 = 14.
              CLEAR lv_flag.
              CLEAR lv_count1.
              lv_count1 = 01.
            ENDIF. " IF lv_count1 = 14
***clicking the new line item button to add new line items
            IF lv_flag IS INITIAL.
              lv_index2 = 1.
              PERFORM  f_bdc_dynpro USING 'SAPLCSDI' '0140'.
              PERFORM  f_bdc_field  USING 'BDC_OKCODE'
                                          '=FCNP'.
            ENDIF. " IF lv_flag IS INITIAL
            lv_flag   = abap_true.
            lv_index2 = lv_index2 + 1.
            lv_index  = lv_index2.

          ELSE. " ELSE -> IF lv_flag IS INITIAL
            lv_index = lv_index + 1.
          ENDIF. " IF lv_count > 14

*-- Screen 140
          PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0140'.
          CONCATENATE 'RC29P-POSTP' '(' lv_index ')' INTO lv_field.

          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          lv_field.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.

          CONCATENATE 'RC29P-IDNRK' '(' lv_index ')' INTO lv_field.
          PERFORM f_bdc_field       USING lv_field
                                          lwa_final-idnrk.

          CONCATENATE 'RC29P-MENGE' '(' lv_index ')' INTO lv_field.
          PERFORM f_bdc_field       USING lv_field
                                          lwa_final-menge.

          CONCATENATE 'RC29P-POSTP' '(' lv_index ')' INTO lv_field.
          PERFORM f_bdc_field       USING lv_field
                                          lwa_final-postp.

*-- Screen 130

          PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                              'SAPLCSDI                                0802STLKOPF'.

          PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0130'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.

          PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                           'SAPLCSDI                                0802STLKOPF'.

          PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                          'SAPLCSDI                                0840POS_PDAT'.

          PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                          'SAPLCSDI                                0830POS_PHPT'.
          IF NOT lwa_final-postp = 'T'.
            PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                            'RC29P-ITSOB'.
            PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                            'RC29P-POSNR'.

            PERFORM f_bdc_field       USING 'RC29P-IDNRK'
                                            lwa_final-idnrk.
*              PERFORM f_bdc_field       USING 'RC29P-SORTF'
*                                              <lfs_final1>-sortf.
            PERFORM f_bdc_field       USING 'RC29P-MENGE'
                                            lwa_final-menge.

          ENDIF. " IF NOT lwa_final-postp = 'T'
*-- Screen 131
          PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0131'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                          'SAPLCSDI                                0802STLKOPF'.
          PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                          'SAPLCSDI                                0840POS_PDAT'.

          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                              'RC29P-SANKA'.
          IF lwa_final-postp EQ 'L'.

            PERFORM f_bdc_field       USING 'RC29P-SANKA'
                                            'X'.

          ENDIF. " IF lwa_final-postp EQ 'L'

          IF lwa_final-postp EQ 'N'.
*-- Screen 133
            PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0133'.
            PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
            PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                          'SAPLCSDI                                0802STLKOPF'.
            PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                            'SAPLCSDI                                0870POS_PEIN'.
            PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RC29P-EKORG'.
          ENDIF. " IF lwa_final-postp EQ 'N'
        ENDIF. " IF lv_matbom EQ c_x

        AT END OF stlan.
*-- Screen 140
          IF lv_matbom EQ c_x.
            PERFORM f_bdc_dynpro      USING 'SAPLCSDI' '0140'.
            PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                            'RC29P-POSNR(01)'.

            PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                            '=FCBU'.
            PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                             'SAPLCSDI                                0802STLKOPF'.
*--------------------------Sales BOM-----------------------------------*
            CALL FUNCTION 'BDC_INSERT'
              EXPORTING
                tcode            = c_tcode "Value:CS01
              TABLES
                dynprotab        = i_bdcdata
              EXCEPTIONS
                internal_error   = 1
                not_open         = 2
                queue_error      = 3
                tcode_invalid    = 4
                printing_invalid = 5
                posting_invalid  = 6
                OTHERS           = 7.
            IF sy-subrc <> 0.
              lv_error = c_x.
***Populate unsucessful records to error file and report.
              PERFORM f_error_key_sub USING lwa_final.
              wa_report-msgtyp = c_emsg.
              wa_report-msgtxt = 'BDC INSERT failed'(018).
              APPEND wa_report TO i_report.
              CLEAR wa_report.

              PERFORM f_pop_error_file USING lwa_final.
              wa_error-errmsg = 'BDC INSERT failed'(018).
              APPEND wa_error TO fp_i_error.
              CLEAR wa_error.
            ENDIF. " IF sy-subrc <> 0
          ENDIF. " IF lv_matbom EQ c_x
*        ENDIF. " LOOP AT li_final INTO lwa_final_tmp
          IF lv_error NE c_x.
            REFRESH i_bdcdata.
            CLEAR: lv_flag,
                   lv_index.
            LOOP AT i_emiplant ASSIGNING <lfs_plant>.
              READ TABLE i_mast WITH KEY matnr = lwa_final-matnr
                                         werks = <lfs_plant>-sel_low
                                         stlan = lwa_final-stlan
                                         BINARY SEARCH
                                         TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                IF lv_flag NE c_x.
                  lv_flag = c_x.
*-- Screen 100
                  PERFORM f_bdc_dynpro      USING 'SAPLCSAL' '0100'.
                  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                                  '/00'.
                  PERFORM f_bdc_field       USING 'RC29N-MATNR'
                                                  lwa_final-matnr.
                  PERFORM f_bdc_field       USING 'RC29N-STLAN'
                                                  lwa_final-stlan.
                  UNASSIGN <lfs_plant_tmp>.
                  READ TABLE i_emiplant ASSIGNING <lfs_plant_tmp> INDEX 1.
                  IF sy-subrc = 0.
                    PERFORM f_bdc_field       USING 'RC29N-ZWERK'
                                                    <lfs_plant_tmp>-sel_low.
                  ENDIF. " IF sy-subrc = 0

*-- Screen 120
                  PERFORM f_bdc_dynpro      USING 'SAPLCSAL' '0120'.
                  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                                  'RC29K-STLNR'.
                  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                                  '=FCNZ'.
                  PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                                  'SAPLCSAL                                0803BER_ZUORD'.
*-- Screen 120
                  CLEAR lv_index.
                  PERFORM f_bdc_dynpro      USING 'SAPLCSAL' '0120'.
                  lv_index = lv_index + 1.
                  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                                 '/00'.
                  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                                 'RC29K-WERKS(02)'.

                ELSE. " ELSE -> IF sy-subrc = 0
                  lv_index = lv_index + 1.
                  CONCATENATE 'RC29K-WERKS' '(' lv_index ')' INTO lv_field.
                  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                                 '/00'.
                  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                                 lv_field.

                  CONCATENATE 'RC29K-STLAL' '(' lv_index ')' INTO lv_field.
                  PERFORM f_bdc_field       USING lv_field
                                                 '1'.

                  CONCATENATE 'RC29K-MATNR' '(' lv_index ')' INTO lv_field.
                  PERFORM f_bdc_field       USING lv_field
                                                 lwa_final-matnr.

                  CONCATENATE 'RC29K-WERKS' '(' lv_index ')' INTO lv_field.
                  PERFORM f_bdc_field       USING lv_field
                                                 <lfs_plant>-sel_low.
                ENDIF. " IF lv_flag NE c_x
              ENDIF. " IF sy-subrc NE 0
            ENDLOOP. " LOOP AT i_emiplant ASSIGNING <lfs_plant>
            IF i_bdcdata[] IS NOT INITIAL.
*-- Screen 120
              PERFORM f_bdc_dynpro      USING 'SAPLCSAL' '0120'.
              PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                             '=FCBU'.
              PERFORM f_bdc_field       USING 'BDC_SUBSCR'
                                             'SAPLCSAL                                0803BER_ZUORD'.

              CALL FUNCTION 'BDC_INSERT'
                EXPORTING
                  tcode            = c_ptcode "Value:CS07
                TABLES
                  dynprotab        = i_bdcdata
                EXCEPTIONS
                  internal_error   = 1
                  not_open         = 2
                  queue_error      = 3
                  tcode_invalid    = 4
                  printing_invalid = 5
                  posting_invalid  = 6
                  OTHERS           = 7.

              IF sy-subrc <> 0.
***Populate unsucessful records to error file and report.
                PERFORM f_error_key_sub USING lwa_final.
                wa_report-msgtyp = c_emsg.
                wa_report-msgtxt = 'BDC INSERT failed'(018).
                APPEND wa_report TO i_report.
                CLEAR wa_report.

                PERFORM f_pop_error_file USING lwa_final.
                wa_error-errmsg = 'BDC INSERT failed'(018).
                APPEND wa_error TO fp_i_error.
                CLEAR wa_error.

              ELSE. " ELSE -> IF sy-subrc <> 0
                REFRESH i_bdcdata.
              ENDIF. " IF sy-subrc <> 0
            ENDIF. " IF i_bdcdata[] IS NOT INITIAL
          ENDIF. " IF lv_error NE c_x
          CLEAR: lv_index,
                 lv_index2,
                 lv_count,
                 lv_count1.
*--> Begin of SMEKALA Def#6622
          CLEAR lv_flag.
*<-- End of SMEKALA Def#6622
        ENDAT.

      ENDLOOP. " LOOP AT li_final INTO lwa_tmp_final

      CALL FUNCTION 'BDC_CLOSE_GROUP'
        EXCEPTIONS
          not_open    = 1
          queue_error = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        CLEAR wa_report.
        MESSAGE i051 WITH c_group  INTO wa_report-msgtxt.
        wa_report-msgtyp = c_error.
        APPEND wa_report TO i_report.
      ELSE. " ELSE -> IF sy-subrc <> 0
        gv_session_gl_1 = c_group.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_i_final[] IS NOT INITIAL

  FREE:
   li_final_tmp, "int.table for BoM data
   li_final,     "int.table for BoM data
   i_bdcdata,
   i_emiplant,
   i_mast.

ENDFORM. " F_EXECUTE_BDC
*&---------------------------------------------------------------------*
*&      Form  F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       BDC Screen
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM   BDC program
*      -->FP_V_dynpro    BDC screen
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING    fp_v_program  TYPE bdc_prog  " BDC module pool
                            fp_v_dynpro   TYPE bdc_dynr. " BDC Screen number
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure

  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = c_true.
  APPEND lwa_bdcdata TO i_bdcdata.

ENDFORM. " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  F_BDC_FIELD
*&---------------------------------------------------------------------*
*      BDC field population
*----------------------------------------------------------------------*
*      -->FP_V_FNAM  FIELD NAME
*      -->FP_V_FVAL  FIELD VALUE
*----------------------------------------------------------------------*
FORM f_bdc_field  USING    fp_v_fnam    TYPE any
                           fp_v_fval    TYPE any.
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure

  lwa_bdcdata-fnam = fp_v_fnam.
  lwa_bdcdata-fval = fp_v_fval.
  APPEND lwa_bdcdata TO i_bdcdata.
  CLEAR lwa_bdcdata.

ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*       Subroutine to move file to the Done folder
*----------------------------------------------------------------------*
*      -->FP_SOURCEFILE  FILE PATH
*----------------------------------------------------------------------*
FORM f_move  USING    fp_sourcefile TYPE localfile. " Local file for upload/download
  DATA: lv_file TYPE localfile,   " Local file for upload/download
                                  " local variable declaration of type localfile
          lv_name TYPE localfile. " Local file for upload/download
 " local variable declaration of type localfile.

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_sourcefile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE c_tbp_fld  IN lv_file WITH c_done_fld .
  CONCATENATE lv_file lv_name INTO lv_file.
*  Move the file
  PERFORM f_file_move  USING    fp_sourcefile
                                lv_file
                       CHANGING gv_return.
  IF gv_return IS INITIAL.
*   Exporting the archived file name in memory id 'ARCH_1'.
    gv_archive_gl_1 = lv_file.
  ENDIF. " IF gv_return IS INITIAL
ENDFORM. " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FP_P_AFILE  FILE NAME
*      -->FP_I_ERROR[] ERROR RECORDS
*----------------------------------------------------------------------*
FORM f_write_error_file  USING    fp_p_afile TYPE localfile " Local file for upload/download
                                  fp_i_error TYPE ty_t_error.
* local data
  DATA: lv_file     TYPE localfile, "File Name
        lv_name     TYPE localfile, "File Name
        lv_data     TYPE string.    "Output data string

  FIELD-SYMBOLS : <lfs_error> TYPE ty_error.
* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE c_tbp_fld  IN lv_file WITH c_error_fld .
  CONCATENATE lv_file lv_name INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019.
  ELSE. " ELSE -> IF sy-subrc NE 0
*   Forming the header text line
    PERFORM f_header_line_pop CHANGING lv_data.
    TRANSFER lv_data TO lv_file.
    CLEAR lv_data.

*   Passing the Erroneous data
    LOOP AT fp_i_error ASSIGNING <lfs_error>.
      PERFORM f_err_data_pop USING <lfs_error>
                            CHANGING lv_data.
*     Transferring the data into application server.
      TRANSFER lv_data TO lv_file.
      CLEAR lv_data.
    ENDLOOP. " LOOP AT fp_i_error ASSIGNING <lfs_error>
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET lv_file.


ENDFORM. " F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LINE_POP
*&---------------------------------------------------------------------*
*       Subroutine to populate Header text line
*----------------------------------------------------------------------*
*      <--FP_DATA  Header line
*----------------------------------------------------------------------*
FORM f_header_line_pop  CHANGING fp_data TYPE string.
  CONCATENATE
              'Material No'(022)
              'BOM Usage'(023)
              'Item Category'(024)
              'BOM Component'(025)
              'Component quantity'(026)
*              'Component UOM'
              'Valid-from Date'(027)
              'Valid-to Date'(028)
              INTO fp_data
              SEPARATED BY c_tab.

ENDFORM. " F_HEADER_LINE_POP
**&---------------------------------------------------------------------*
*&      Form  F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*       Subroutine to populate the Error Record
*----------------------------------------------------------------------*
*      -->FP_P_ERROR  Error record
*      <--FP_DATA     Error data string
*----------------------------------------------------------------------*
FORM f_err_data_pop  USING    fp_p_error TYPE ty_error
                     CHANGING fp_data    TYPE string.
* Pass the error data to application server
  CONCATENATE
fp_p_error-matnr
fp_p_error-stlan
fp_p_error-postp
fp_p_error-idnrk
fp_p_error-menge
*fp_p_error-meins
fp_p_error-datuv
fp_p_error-datub
INTO fp_data
SEPARATED BY c_tab.
ENDFORM. " F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*&      Form  F_GET_PLANTS
*&---------------------------------------------------------------------*
FORM f_get_plants .
  CONSTANTS:
  lc_0091 TYPE z_enhancement VALUE 'D2_OTC_CDD_0091'. " Enhancement No.
* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_0091
    TABLES
      tt_enh_status     = i_emiplant.

*-- Delete the records whose plant is blank or active ne 'X'
  DELETE i_emiplant WHERE criteria NE 'WERKS' OR
                          active NE c_x.
ENDFORM. " F_GET_PLANTS
