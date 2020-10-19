*&---------------------------------------------------------------------*
*&  Include           ZOTCN0156B_BATCH_DETER_SUB                       *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* PROGRAM    : ZOTCC0156_BATCH_DETER                                   *
* TITLE      :D3_OTC_CDD_0156_Convert Batch Determination Records      *
* DEVELOPER  : Jahan Mazumder
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0156
*----------------------------------------------------------------------*
* DESCRIPTION: Convert Batch Determination Records                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
*06/01/2016   U029639   E1DK917995 Initial Development
*
*----------------------------------------------------------------------*

FORM f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Optin has been chosen, then issueing error message.
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
*        Set the execution mode
*----------------------------------------------------------------------*
*      <--fP_GV_SAVE   flag
*      <--fP_GV_MODE   mode
*----------------------------------------------------------------------*
FORM f_set_mode  CHANGING fp_gv_save TYPE char1   " Set_mode changing fp_gv of type CHAR1
                          fp_gv_mode TYPE char10. " Gv_mode of type CHAR10

* If Verify and Post is selected, then putting the Flag ON
  IF rb_post IS NOT INITIAL.
    fp_gv_save = c_true.
  ELSE. " ELSE -> IF rb_post IS NOT INITIAL
    fp_gv_save = space.
  ENDIF. " IF rb_post IS NOT INITIAL

* Choosin the Mode
  IF rb_post = c_true.
    fp_gv_mode = 'Post Run'(034).
  ELSE. " ELSE -> IF rb_post = c_true
    fp_gv_mode = 'Test Run'(035).
  ENDIF. " IF rb_post = c_true
ENDFORM. " F_SET_MODE
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*    Upload application server file data
*----------------------------------------------------------------------*
*      -->fP_p_FILE  presentation server file name
*----------------------------------------------------------------------*
FORM f_upload_pres  USING    fp_p_file  TYPE localfile. " Local file for upload/download

* Local Data Declaration
  DATA: lv_filename TYPE string. "File Name
  CONSTANTS: lc_true TYPE char1 VALUE 'X'. " True of type CHAR1

  IF sy-batch = lc_true.
    MESSAGE i164.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-batch = lc_true

  lv_filename = fp_p_file.

  IF <fs_tab> IS ASSIGNED.
    UNASSIGN <fs_tab>.
  ENDIF. " IF <fs_tab> IS ASSIGNED
  ASSIGN i_fs_tab TO <fs_tab>.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_file_type
    CHANGING
      data_tab                = <fs_tab>
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
    PERFORM f_pop_final_tab.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_UPLOAD_PRES
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*         Screen Modification based on user selection
*----------------------------------------------------------------------*
FORM f_modify_screen .
  LOOP AT SCREEN .
*   Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*     Hiding Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*   Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE c_true
*     Disaplying Presentation Server file paths with modifidd MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*   Application Server Option is NOT chosen
    IF rb_app NE c_true.
*     Hiding 1) Application Server file Physical paths with modifid MI2
*     2) Logical Filename Radio Button with with modifid MI5
*     3) Logical Filename input with modifid MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE c_true
*     If Application Server Physical File Radio Button is chosen
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
      ELSE. " ELSE -> IF rb_aphy EQ c_true
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
*      Check the file extension whether it is .TXT or not
*----------------------------------------------------------------------*
*      -->fP_P_PFILE      file name
*----------------------------------------------------------------------*
FORM f_check_extension  USING    fp_p_file TYPE localfile. " Local file for upload/download
  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_file
                           CHANGING gv_extn.
    IF gv_extn <> c_text.
      MESSAGE e008.
    ENDIF. " IF gv_extn <> c_text
  ENDIF. " IF fp_p_file IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*     get the physical file path from logical path
*----------------------------------------------------------------------*
*      -->FP_P_ALOG    file path
*      <--FP_GV_FILE   file name
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog TYPE pathintern  " Logical path name
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
      im_identifier      = c_lp_ind
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
    MESSAGE i000 WITH 'No proper file exist for the logical file'(036).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
             lwa_output-filename
             INTO fp_gv_file.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL AND

ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*     Move file to the Done folder
*----------------------------------------------------------------------*
*      -->fp_sourcefile     file path
*----------------------------------------------------------------------*
FORM f_move  USING    fp_sourcefile TYPE localfile. " Local file for upload/download

  DATA: lv_file TYPE localfile, " Local file for upload/download
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
*&      Form  F_POP_FINAL_TAB
*&---------------------------------------------------------------------*
*      Populate input table into a generic final table
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_pop_final_tab .

* Local Variables
  DATA: lv_temp1  TYPE string,
        lv_temp2  TYPE string,
        lv_temp3  TYPE string,
        lv_temp4  TYPE string,
        lv_temp5  TYPE string,
        lv_temp6  TYPE string,
        lv_temp7  TYPE string,
        lv_temp8  TYPE string,
        lv_temp9  TYPE string,
        lv_temp10 TYPE string,
        lv_temp11 TYPE string,
        lv_temp12 TYPE string,
        lv_temp13 TYPE string,
        lv_temp14 TYPE string,
        lv_temp15 TYPE string,
        lv_temp16 TYPE string,
        lv_datum  TYPE char10.     " Datum of type CHAR10


  FIELD-SYMBOLS:   <fs_line> TYPE ty_tab.

  LOOP AT <fs_tab> ASSIGNING <fs_line>.

    SPLIT <fs_line>-input_line AT c_tab
    INTO
    lv_temp1
    lv_temp2
    lv_temp3
    lv_temp4
    lv_temp5
    lv_temp6
    lv_temp7
    lv_temp8
    lv_temp9
    lv_temp10
    lv_temp11
    lv_temp12
    lv_temp13
    lv_temp14
    lv_temp15
    lv_temp16.

    wa_final-kschl   = lv_temp1.
    wa_final-kotabnr = lv_temp2.

    lv_datum = sy-datum.
    PERFORM f_convert_date CHANGING lv_datum.
    wa_final-datab = lv_datum.
    wa_final-datbi = c_date.

    wa_final-kzame = c_kzame.
    wa_final-chmvs = c_chmvs.

    IF gv_flg1 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-matnr = lv_temp6.
      wa_final-kunnr = lv_temp5.
      wa_final-chasp = lv_temp7.
      wa_final-chspl = lv_temp8.
      wa_final-chmdg = lv_temp9.
      wa_final-chvll = lv_temp10.
      wa_final-chvsk = lv_temp11.
      wa_final-srtsq = lv_temp12.
      wa_final-klass = lv_temp13.
      wa_final-atnam = lv_temp14.
      wa_final-atwrt = lv_temp15.
    ENDIF. " IF gv_flg1 IS NOT INITIAL

    IF gv_flg2 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-matnr = lv_temp5.
      wa_final-chasp = lv_temp6.
      wa_final-chspl = lv_temp7.
      wa_final-chmdg = lv_temp8.
      wa_final-chvll = lv_temp9.
      wa_final-chvsk = lv_temp10.
      wa_final-srtsq = lv_temp11.
      wa_final-klass = lv_temp12.
      wa_final-atnam = lv_temp13.
      wa_final-atwrt = lv_temp14.
    ENDIF. " IF gv_flg2 IS NOT INITIAL

    IF gv_flg3 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-kunwe = lv_temp5.
      wa_final-chasp = lv_temp6.
      wa_final-chspl = lv_temp7.
      wa_final-chmdg = lv_temp8.
      wa_final-chvll = lv_temp9.
      wa_final-chvsk = lv_temp10.
      wa_final-srtsq = lv_temp11.
      wa_final-klass = lv_temp12.
      wa_final-atnam = lv_temp13.
      wa_final-atwrt = lv_temp14.
    ENDIF. " IF gv_flg3 IS NOT INITIAL

    IF gv_flg4 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-lgnum = lv_temp5.
      wa_final-auart = lv_temp6.
      wa_final-mvgr2 = lv_temp7.
      wa_final-chasp = lv_temp8.
      wa_final-chspl = lv_temp9.
      wa_final-chmdg = lv_temp10.
      wa_final-chvll = lv_temp11.
      wa_final-chvsk = lv_temp12.
      wa_final-srtsq = lv_temp13.
      wa_final-klass = lv_temp14.
      wa_final-atnam = lv_temp15.
      wa_final-atwrt = lv_temp16.
    ENDIF. " IF gv_flg4 IS NOT INITIAL

    IF gv_flg5 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-lgnum = lv_temp5.
      wa_final-mvgr2 = lv_temp6.
      wa_final-chasp = lv_temp7.
      wa_final-chspl = lv_temp8.
      wa_final-chmdg = lv_temp9.
      wa_final-chvll = lv_temp10.
      wa_final-chvsk = lv_temp11.
      wa_final-srtsq = lv_temp12.
      wa_final-klass = lv_temp13.
      wa_final-atnam = lv_temp14.
      wa_final-atwrt = lv_temp15.
    ENDIF. " IF gv_flg5 IS NOT INITIAL

    IF gv_flg6 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-bwart = lv_temp5.
      wa_final-chasp = lv_temp6.
      wa_final-chspl = lv_temp7.
      wa_final-chmdg = lv_temp8.
      wa_final-chvll = lv_temp9.
      wa_final-chvsk = lv_temp10.
      wa_final-srtsq = lv_temp11.
      wa_final-klass = lv_temp12.
      wa_final-atnam = lv_temp13.
      wa_final-atwrt = lv_temp14.
    ENDIF. " IF gv_flg6 IS NOT INITIAL

    IF gv_flg7 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-mvgr2 = lv_temp5.
      wa_final-chasp = lv_temp6.
      wa_final-chspl = lv_temp7.
      wa_final-chmdg = lv_temp8.
      wa_final-chvll = lv_temp9.
      wa_final-chvsk = lv_temp10.
      wa_final-srtsq = lv_temp11.
      wa_final-klass = lv_temp12.
      wa_final-atnam = lv_temp13.
      wa_final-atwrt = lv_temp14.
    ENDIF. " IF gv_flg7 IS NOT INITIAL

    IF gv_flg8 IS NOT INITIAL.
      wa_final-vkorg = lv_temp3.
      wa_final-vtweg = lv_temp4.
      wa_final-auart = lv_temp5.
      wa_final-werks = lv_temp6.
      wa_final-chasp = lv_temp7.
      wa_final-chspl = lv_temp8.
      wa_final-chmdg = lv_temp9.
      wa_final-chvll = lv_temp10.
      wa_final-chvsk = lv_temp11.
      wa_final-srtsq = lv_temp12.
      wa_final-klass = lv_temp13.
      wa_final-atnam = lv_temp14.
      wa_final-atwrt = lv_temp15.
    ENDIF. " IF gv_flg8 IS NOT INITIAL

    IF gv_flg9 IS NOT INITIAL.
      wa_final-matnr = lv_temp3.
      wa_final-kunwe = lv_temp4.
      wa_final-chasp = lv_temp5.
      wa_final-chspl = lv_temp6.
      wa_final-chmdg = lv_temp7.
      wa_final-chvll = lv_temp8.
      wa_final-chvsk = lv_temp9.
      wa_final-srtsq = lv_temp10.
      wa_final-klass = lv_temp11.
      wa_final-atnam = lv_temp12.
      wa_final-atwrt = lv_temp13.
    ENDIF. " IF gv_flg9 IS NOT INITIAL

    IF gv_flg10 IS NOT INITIAL.
      wa_final-matnr = lv_temp3.
      wa_final-land1 = lv_temp4.
      wa_final-chasp = lv_temp5.
      wa_final-chspl = lv_temp6.
      wa_final-chmdg = lv_temp7.
      wa_final-chvll = lv_temp8.
      wa_final-chvsk = lv_temp9.
      wa_final-srtsq = lv_temp10.
      wa_final-klass = lv_temp11.
      wa_final-atnam = lv_temp12.
      wa_final-atwrt = lv_temp13.
    ENDIF. " IF gv_flg10 IS NOT INITIAL

    APPEND wa_final TO i_final.

    CLEAR: wa_final.
  ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <fs_line>

** Delete first line from Tab ..field header
  DELETE i_final INDEX 1.

ENDFORM. " F_POP_FINAL_TAB
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*     download data from application server
*----------------------------------------------------------------------*
*      -->FP_P_FILE  file name
*----------------------------------------------------------------------*
FORM f_upload_apps  USING    fp_p_file TYPE localfile. " Local file for upload/download

* Local Variables
  DATA: lv_input_line TYPE string, "Input Raw lines
        lv_temp1  TYPE string,
        lv_temp2  TYPE string,
        lv_temp3  TYPE string,
        lv_temp4  TYPE string,
        lv_temp5  TYPE string,
        lv_temp6  TYPE string,
        lv_temp7  TYPE string,
        lv_temp8  TYPE string,
        lv_temp9  TYPE string,
        lv_temp10 TYPE string,
        lv_temp11 TYPE string,
        lv_temp12 TYPE string,
        lv_temp13 TYPE string,
        lv_temp14 TYPE string,
        lv_temp15 TYPE string,
        lv_temp16 TYPE string,
        lv_message TYPE string,
        lv_datum  TYPE char10,     " Datum of type CHAR10
        lv_subrc  TYPE sysubrc.    "SY-SUBRC value

* Opening the Dataset for File Read
*  OPEN DATASET fp_p_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
  TRY.
    CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_open_dataset
      EXPORTING
        im_file     = fp_p_file
        im_codepage = gv_codepage
      IMPORTING
        ex_subrc    = lv_subrc
        ex_message  = lv_message.

    IF lv_message IS NOT INITIAL.
      MESSAGE i000 WITH lv_message.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF lv_message IS NOT INITIAL
  ENDTRY.

*  IF sy-subrc IS INITIAL.
  IF  lv_message IS INITIAL.
*   Reading the Header Input File
    WHILE ( lv_subrc EQ 0 ).
      READ DATASET fp_p_file INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
      IF lv_subrc IS INITIAL.

*       Aligning the values as per the structure
        SPLIT lv_input_line AT c_tab
        INTO
        lv_temp1
        lv_temp2
        lv_temp3
        lv_temp4
        lv_temp5
        lv_temp6
        lv_temp7
        lv_temp8
        lv_temp9
        lv_temp10
        lv_temp11
        lv_temp12
        lv_temp13
        lv_temp14
        lv_temp15
        lv_temp16.

**populate corresponding fields in final table
        wa_final-kschl   = lv_temp1.
        wa_final-kotabnr = lv_temp2.

        lv_datum = sy-datum.
        PERFORM f_convert_date CHANGING lv_datum.
        wa_final-datab = lv_datum.
        wa_final-datbi = c_date.

        wa_final-kzame = c_kzame.
        wa_final-chmvs = c_chmvs.

        IF gv_flg1 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-matnr = lv_temp6.
          wa_final-kunnr = lv_temp5.
          wa_final-chasp = lv_temp7.
          wa_final-chspl = lv_temp8.
          wa_final-chmdg = lv_temp9.
          wa_final-chvll = lv_temp10.
          wa_final-chvsk = lv_temp11.
          wa_final-srtsq = lv_temp12.
          wa_final-klass = lv_temp13.
          wa_final-atnam = lv_temp14.
          wa_final-atwrt = lv_temp15.
        ENDIF. " IF gv_flg1 IS NOT INITIAL

        IF gv_flg2 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-matnr = lv_temp5.
          wa_final-chasp = lv_temp6.
          wa_final-chspl = lv_temp7.
          wa_final-chmdg = lv_temp8.
          wa_final-chvll = lv_temp9.
          wa_final-chvsk = lv_temp10.
          wa_final-srtsq = lv_temp11.
          wa_final-klass = lv_temp12.
          wa_final-atnam = lv_temp13.
          wa_final-atwrt = lv_temp14.
        ENDIF. " IF gv_flg2 IS NOT INITIAL

        IF gv_flg3 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-kunwe = lv_temp5.
          wa_final-chasp = lv_temp6.
          wa_final-chspl = lv_temp7.
          wa_final-chmdg = lv_temp8.
          wa_final-chvll = lv_temp9.
          wa_final-chvsk = lv_temp10.
          wa_final-srtsq = lv_temp11.
          wa_final-klass = lv_temp12.
          wa_final-atnam = lv_temp13.
          wa_final-atwrt = lv_temp14.
        ENDIF. " IF gv_flg3 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-lgnum = lv_temp5.
          wa_final-auart = lv_temp6.
          wa_final-mvgr2 = lv_temp7.
          wa_final-chasp = lv_temp8.
          wa_final-chspl = lv_temp9.
          wa_final-chmdg = lv_temp10.
          wa_final-chvll = lv_temp11.
          wa_final-chvsk = lv_temp12.
          wa_final-srtsq = lv_temp13.
          wa_final-klass = lv_temp14.
          wa_final-atnam = lv_temp15.
          wa_final-atwrt = lv_temp16.
        ENDIF. " IF gv_flg4 IS NOT INITIAL

        IF gv_flg5 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-lgnum = lv_temp5.
          wa_final-mvgr2 = lv_temp6.
          wa_final-chasp = lv_temp7.
          wa_final-chspl = lv_temp8.
          wa_final-chmdg = lv_temp9.
          wa_final-chvll = lv_temp10.
          wa_final-chvsk = lv_temp11.
          wa_final-srtsq = lv_temp12.
          wa_final-klass = lv_temp13.
          wa_final-atnam = lv_temp14.
          wa_final-atwrt = lv_temp15.
        ENDIF. " IF gv_flg5 IS NOT INITIAL

        IF gv_flg6 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-bwart = lv_temp5.
          wa_final-chasp = lv_temp6.
          wa_final-chspl = lv_temp7.
          wa_final-chmdg = lv_temp8.
          wa_final-chvll = lv_temp9.
          wa_final-chvsk = lv_temp10.
          wa_final-srtsq = lv_temp11.
          wa_final-klass = lv_temp12.
          wa_final-atnam = lv_temp13.
          wa_final-atwrt = lv_temp14.
        ENDIF. " IF gv_flg6 IS NOT INITIAL

        IF gv_flg7 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-mvgr2 = lv_temp5.
          wa_final-chasp = lv_temp6.
          wa_final-chspl = lv_temp7.
          wa_final-chmdg = lv_temp8.
          wa_final-chvll = lv_temp9.
          wa_final-chvsk = lv_temp10.
          wa_final-srtsq = lv_temp11.
          wa_final-klass = lv_temp12.
          wa_final-atnam = lv_temp13.
          wa_final-atwrt = lv_temp14.
        ENDIF. " IF gv_flg7 IS NOT INITIAL

        IF gv_flg8 IS NOT INITIAL.
          wa_final-vkorg = lv_temp3.
          wa_final-vtweg = lv_temp4.
          wa_final-auart = lv_temp5.
          wa_final-werks = lv_temp6.
          wa_final-chasp = lv_temp7.
          wa_final-chspl = lv_temp8.
          wa_final-chmdg = lv_temp9.
          wa_final-chvll = lv_temp10.
          wa_final-chvsk = lv_temp11.
          wa_final-srtsq = lv_temp12.
          wa_final-klass = lv_temp13.
          wa_final-atnam = lv_temp14.
          wa_final-atwrt = lv_temp15.
        ENDIF. " IF gv_flg8 IS NOT INITIAL

        IF gv_flg9 IS NOT INITIAL.
          wa_final-matnr = lv_temp3.
          wa_final-kunwe = lv_temp4.
          wa_final-chasp = lv_temp5.
          wa_final-chspl = lv_temp6.
          wa_final-chmdg = lv_temp7.
          wa_final-chvll = lv_temp8.
          wa_final-chvsk = lv_temp9.
          wa_final-srtsq = lv_temp10.
          wa_final-klass = lv_temp11.
          wa_final-atnam = lv_temp12.
          wa_final-atwrt = lv_temp13.
        ENDIF. " IF gv_flg9 IS NOT INITIAL

        IF gv_flg10 IS NOT INITIAL.
          wa_final-matnr = lv_temp3.
          wa_final-land1 = lv_temp4.
          wa_final-chasp = lv_temp5.
          wa_final-chspl = lv_temp6.
          wa_final-chmdg = lv_temp7.
          wa_final-chvll = lv_temp8.
          wa_final-chvsk = lv_temp9.
          wa_final-srtsq = lv_temp10.
          wa_final-klass = lv_temp11.
          wa_final-atnam = lv_temp12.
          wa_final-atwrt = lv_temp13.
        ENDIF. " IF gv_flg10 IS NOT INITIAL
        APPEND wa_final TO i_final.
        CLEAR: wa_final.
        CLEAR lv_input_line.

      ENDIF. " IF lv_subrc IS INITIAL
    ENDWHILE.
* If File Open fails, then populating the Error Log
  ELSE. " ELSE -> IF lv_message IS INITIAL
*   Leaving the program if OPEN Dataset fails for data upload
    MESSAGE i163 WITH fp_p_file.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF lv_message IS INITIAL
* Closing the Dataset.
  TRY.
      CLOSE DATASET fp_p_file.

    CATCH cx_sy_file_close.
      MESSAGE i021 WITH fp_p_file.
      LEAVE LIST-PROCESSING.
  ENDTRY.

* Deleting the First Index Line from the table
  DELETE i_final INDEX 1.

ENDFORM. " F_UPLOAD_APPS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*     Validate all the Input fields from file.
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_validation .
** local structures

**For material
  TYPES: BEGIN OF lty_mara,
        matnr TYPE matnr, " Material Number
        END OF lty_mara,
**For Sales Org
        BEGIN OF lty_tvko,
        vkorg TYPE vkorg, " Sales Organization
        END OF lty_tvko,
**For Warehouse No
        BEGIN OF lty_lgnum,
        lgnum TYPE lgnum, " Sales Organization
        END OF lty_lgnum,

**Foe Condition Type
        BEGIN OF lty_type,
          kschl TYPE kschl, " Condition Type
        END OF lty_type,
** For Ship-to Customer
        BEGIN OF lty_cust,
          kunnr TYPE kunnr, " Customer Number
        END OF lty_cust,
**For Country
        BEGIN OF lty_cntry,
          land1 TYPE land1, " Country Key
        END OF lty_cntry,
**For distribution channel
         BEGIN OF lty_dc,
           vtweg TYPE vtweg, " Distribution Channel
         END OF lty_dc.

**Local Constants
  CONSTANTS: lc_v TYPE kappl VALUE 'V', " Application
             lc_g TYPE kvewe VALUE 'H'. " Usage of the condition table

**Local Internal Tables
  DATA: li_final TYPE STANDARD TABLE OF ty_final,
        li_mara  TYPE STANDARD TABLE OF lty_mara,
        li_tvko  TYPE STANDARD TABLE OF lty_tvko,
        li_lgnum TYPE STANDARD TABLE OF lty_lgnum,
        li_type  TYPE STANDARD TABLE OF lty_type,
        li_cust  TYPE STANDARD TABLE OF lty_cust,
        li_cust1 TYPE STANDARD TABLE OF lty_cust,
        li_cntry TYPE STANDARD TABLE OF lty_cntry,
        li_cntry1 TYPE STANDARD TABLE OF lty_cntry,
        li_dcha  TYPE STANDARD TABLE OF lty_dc.

**Local variables
  DATA:  lwa_cust1  TYPE lty_cust,
         lwa_cntry1 TYPE lty_cntry,
         lv_message TYPE string,
         lv_err_flg TYPE char1, " Err_flg of type CHAR1
         lv_temp1   TYPE i,     " Temp1 of type Integers
         lv_temp2   TYPE i.     " Temp2 of type Integers

**Local Field symbols
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final,
                 <lfs_final_t> TYPE ty_final.

  REFRESH : li_final.


*Validate if the file is correct for selected key combination.

  li_final[] = i_final[].
  SORT li_final BY kotabnr.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kotabnr.
  LOOP AT li_final ASSIGNING <lfs_final_t>.
    IF <lfs_final_t>-kotabnr NE gv_key_comb.
** error
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final_t>.
      wa_report-msgtyp = c_emsg.
      CONCATENATE 'Invalid file with wrong keycombination'(062) <lfs_final_t>-kotabnr ', Radio button selected is'(063) gv_key_comb INTO lv_message SEPARATED BY space.
      wa_report-msgtxt = lv_message.
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final_t>.
      wa_error-errmsg = 'Invalid file with wrong keycombination'(062).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      STOP.
    ENDIF. " IF <lfs_final_t>-kotabnr NE gv_key_comb
  ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final_t>



**get all exclusion type
  li_final[] = i_final[].
  DELETE li_final WHERE kschl IS INITIAL.
  SORT li_final BY kschl.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kschl.
  IF li_final[] IS NOT INITIAL.
    SELECT kschl " Condition Type
      FROM t685  " Conditions: Types
      INTO TABLE li_type
      FOR ALL ENTRIES IN li_final
      WHERE kvewe = lc_g
        AND kappl = lc_v
        AND kschl = li_final-kschl.
    IF sy-subrc = 0.
      SORT li_type BY kschl.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**Get all material
  li_final[] = i_final[].
  DELETE li_final WHERE matnr IS INITIAL.
  SORT li_final BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr.
  IF li_final[] IS NOT INITIAL.
    SELECT matnr " Material Number
      FROM mara  " General Material Data
      INTO TABLE li_mara
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr.
    IF sy-subrc = 0.
      SORT li_mara BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**Get all Sales Org
  li_final[] = i_final[].
  DELETE li_final WHERE vkorg IS INITIAL.
  SORT li_final BY vkorg.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING vkorg.
  IF li_final[] IS NOT INITIAL.
    SELECT vkorg " Sales Organization
      FROM tvko  " Organizational Unit: Sales Organizations
      INTO TABLE li_tvko
      FOR ALL ENTRIES IN li_final
      WHERE vkorg = li_final-vkorg.
    IF sy-subrc = 0.
      SORT li_tvko BY vkorg.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**Get all warehouse numbers.
  li_final[] = i_final[].
  DELETE li_final WHERE lgnum IS INITIAL.
  SORT li_final BY lgnum.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING lgnum.
  IF li_final[] IS NOT INITIAL.
    SELECT lgnum " Warehouse Number / Warehouse Complex
      FROM t300  " WM Warehouse Numbers
      INTO TABLE li_lgnum
      FOR ALL ENTRIES IN li_final
      WHERE lgnum = li_final-lgnum.
    IF sy-subrc = 0.
      SORT li_lgnum BY lgnum.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL



**get all Sold-to  customer
  li_final[] = i_final[].
  DELETE li_final WHERE kunnr IS INITIAL.
  SORT li_final BY kunnr.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kunnr.
  IF li_final[] IS NOT INITIAL.
    LOOP AT li_final ASSIGNING <lfs_final_t>.
      CLEAR: lwa_cust1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_final_t>-kunnr
        IMPORTING
          output = lwa_cust1-kunnr.
      APPEND lwa_cust1 TO li_cust1.
    ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final_t>
  ENDIF. " IF li_final[] IS NOT INITIAL

**get all Ship-to  customer
  li_final[] = i_final[].
  DELETE li_final WHERE kunwe IS INITIAL.
  SORT li_final BY kunwe.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kunwe.
  IF li_final[] IS NOT INITIAL.
    LOOP AT li_final ASSIGNING <lfs_final_t>.
      CLEAR: lwa_cust1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_final_t>-kunwe
        IMPORTING
          output = lwa_cust1-kunnr.
      APPEND lwa_cust1 TO li_cust1.
    ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final_t>
  ENDIF. " IF li_final[] IS NOT INITIAL

  IF li_cust1[] IS NOT INITIAL.
    SORT li_cust1 BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_cust1 COMPARING ALL FIELDS.
    SELECT kunnr " Customer Number
      FROM kna1  " General Data in Customer Master
      INTO TABLE li_cust
      FOR ALL ENTRIES IN li_cust1
      WHERE kunnr = li_cust1-kunnr.
    IF sy-subrc = 0.
      SORT li_cust BY kunnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_cust1[] IS NOT INITIAL

  li_final[] = i_final[].
  DELETE li_final WHERE land1 IS INITIAL.
  SORT li_final BY land1.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING land1.
  IF li_final[] IS NOT INITIAL.
    LOOP AT li_final ASSIGNING <lfs_final_t>.
      CLEAR: lwa_cntry1.
      lwa_cntry1-land1 = <lfs_final_t>-land1.
      APPEND lwa_cntry1 TO li_cntry1.
    ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final_t>
  ENDIF. " IF li_final[] IS NOT INITIAL

  IF li_cntry1[] IS NOT INITIAL.
    SORT li_cntry1 BY land1.
    DELETE ADJACENT DUPLICATES FROM li_cntry1 COMPARING ALL FIELDS.
    SELECT land1 " Country Key
      FROM t005  " Countries
      INTO TABLE li_cntry
      FOR ALL ENTRIES IN li_cntry1
      WHERE land1 = li_cntry1-land1.
    IF sy-subrc = 0.
      SORT li_cntry BY land1.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_cntry1[] IS NOT INITIAL

*** Get all distribution channel
  li_final[] = i_final[].
  DELETE li_final WHERE vtweg IS INITIAL.
  SORT li_final BY vtweg.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING vtweg.
  IF li_final[] IS NOT INITIAL.
    SELECT vtweg " Distribution Channel
      FROM tvtw  " Organizational Unit: Distribution Channels
      INTO TABLE li_dcha
      FOR ALL ENTRIES IN li_final
      WHERE vtweg = li_final-vtweg.
    IF sy-subrc = 0.
      SORT li_dcha BY vtweg.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL


*****Validate Input fields
  LOOP AT i_final ASSIGNING <lfs_final>.
    CLEAR: lv_err_flg.

    IF <lfs_final>-kschl IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Strategy type can not be blank'(007).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Strategy type can not be blank'(007).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.

    ELSE. " ELSE -> IF <lfs_final>-kschl IS INITIAL
      READ TABLE li_type TRANSPORTING NO FIELDS
                          WITH KEY kschl = <lfs_final>-kschl
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Strategy type'(008).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Strategy type'(008).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-kschl IS INITIAL

**Validate Sales Org
    IF gv_flg1 IS NOT INITIAL
      OR gv_flg2 IS NOT INITIAL
      OR gv_flg3 IS NOT INITIAL
      OR gv_flg4 IS NOT INITIAL
      OR gv_flg5 IS NOT INITIAL
      OR gv_flg6 IS NOT INITIAL
      OR gv_flg7 IS NOT INITIAL
      OR gv_flg8 IS NOT INITIAL.

      IF <lfs_final>-vkorg IS INITIAL.
*      error

        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Sales Org can not be blank'(009).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Sales Org can not be blank'(009).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-vkorg IS INITIAL
        READ TABLE li_tvko TRANSPORTING NO FIELDS
                            WITH KEY vkorg = <lfs_final>-vkorg
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Sales Org'(010).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Sales Org'(010).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-vkorg IS INITIAL

****validate distribution channel
      IF <lfs_final>-vtweg IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Distribution Channel can not be blank'(025).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Distribution Channel can not be blank'(025).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-vtweg IS INITIAL
        READ TABLE li_dcha TRANSPORTING NO FIELDS
                            WITH KEY vtweg = <lfs_final>-vtweg
                                     BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Distribution Channel'(026).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Distribution Channel'(026).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-vtweg IS INITIAL

    ENDIF. " IF gv_flg1 IS NOT INITIAL

**Validate material.
    IF gv_flg1 IS NOT INITIAL
      OR gv_flg2 IS NOT INITIAL
      OR gv_flg9 IS NOT INITIAL
      OR gv_flg10 IS NOT INITIAL.

      IF <lfs_final>-matnr IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Material can not be blank'(011).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Material can not be blank'(011).
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
          wa_report-msgtxt = 'Invalid Material'(012).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Material'(012).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-matnr IS INITIAL
    ENDIF. " IF gv_flg1 IS NOT INITIAL

**Warehouse Number Validation

    IF gv_flg4 IS NOT INITIAL
      OR gv_flg5 IS NOT INITIAL.

      IF <lfs_final>-lgnum IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Warehouse No.'(049).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Warehouse No.'(049).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-lgnum IS INITIAL
        READ TABLE li_lgnum TRANSPORTING NO FIELDS
                            WITH KEY lgnum = <lfs_final>-lgnum
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Warehouse No'(051).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Warehouse No'(051).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-lgnum IS INITIAL
    ENDIF. " IF gv_flg4 IS NOT INITIAL

***Validate Ship To Party.
    IF gv_flg3 IS NOT INITIAL
      OR gv_flg9 IS NOT INITIAL.

      IF <lfs_final>-kunwe IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Ship To Party can not be blank'(013).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Ship To Party can not be blank'(013).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-kunwe IS INITIAL
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lfs_final>-kunwe
          IMPORTING
            output = <lfs_final>-kunwe.

        READ TABLE li_cust TRANSPORTING NO FIELDS
                            WITH KEY kunnr = <lfs_final>-kunwe
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Ship To Party'(014).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Ship To Party'(014).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-kunwe IS INITIAL
    ENDIF. " IF gv_flg3 IS NOT INITIAL

**validate Sold To Party
    IF gv_flg1 IS NOT INITIAL.
      IF <lfs_final>-kunnr IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Sold To Party can not be blank'(015).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Sold To Party can not be blank'(015).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-kunnr IS INITIAL
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lfs_final>-kunnr
          IMPORTING
            output = <lfs_final>-kunnr.

        READ TABLE li_cust TRANSPORTING NO FIELDS
                            WITH KEY kunnr = <lfs_final>-kunnr
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Sold To Party'(016).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Sold To Party'(016).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-kunnr IS INITIAL
    ENDIF. " IF gv_flg1 IS NOT INITIAL

****Validate Destination Country
    IF gv_flg10 IS NOT INITIAL.
      IF <lfs_final>-land1 IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Destination Country can not be blank'(021).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Destination Country can not be blank'(021).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-land1 IS INITIAL
        READ TABLE li_cntry TRANSPORTING NO FIELDS
                            WITH KEY land1 = <lfs_final>-land1
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Destination Country'(022).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Destination Country'(022).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-land1 IS INITIAL
    ENDIF. " IF gv_flg10 IS NOT INITIAL

    IF lv_err_flg IS INITIAL.
**populate data for processing
      APPEND <lfs_final> TO i_valid.
    ENDIF. " IF lv_err_flg IS INITIAL
  ENDLOOP. " LOOP AT i_final ASSIGNING <lfs_final>

  lv_temp1 = lines( i_final ).
  lv_temp2 = lines( i_valid ).

**Successful records
  gv_scount = lv_temp2.
**Error records
  gv_ecount = lv_temp1 - lv_temp2.

ENDFORM. " F_VALIDATION

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_KEY_SUB
*&---------------------------------------------------------------------*
*   Populate error Key for report display
*----------------------------------------------------------------------*
*      -->FP_ERR_KEY    Error record
*----------------------------------------------------------------------*
FORM f_error_key_sub  USING    fp_err_key TYPE ty_final.

  PERFORM f_convert_date CHANGING fp_err_key-datbi.
  PERFORM f_convert_date CHANGING fp_err_key-datab.

**Populate error Key based on Key combination
  IF gv_flg1 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-matnr
                fp_err_key-kunnr
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg1 IS NOT INITIAL

  IF gv_flg2 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-matnr
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg2 IS NOT INITIAL

  IF gv_flg3 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-kunwe
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg3 IS NOT INITIAL

  IF gv_flg4 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-lgnum
                fp_err_key-auart
                fp_err_key-mvgr2
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg4 IS NOT INITIAL

  IF gv_flg5 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-lgnum
                fp_err_key-mvgr2
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg5 IS NOT INITIAL

  IF gv_flg6 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-bwart
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg6 IS NOT INITIAL

  IF gv_flg7 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-mvgr2
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg7 IS NOT INITIAL

  IF gv_flg8 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-auart
                fp_err_key-werks
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg8 IS NOT INITIAL

  IF gv_flg9 IS NOT INITIAL.
    CONCATENATE fp_err_key-matnr
                fp_err_key-kunwe
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg9 IS NOT INITIAL

  IF gv_flg10 IS NOT INITIAL.
    CONCATENATE fp_err_key-matnr
                fp_err_key-land1
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg10 IS NOT INITIAL

ENDFORM. " F_ERROR_KEY_SUB

*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_DATE
*&---------------------------------------------------------------------*
*       Convert date
*----------------------------------------------------------------------*
*      <--P_WA_FINAL_DATAB  text
*----------------------------------------------------------------------*
FORM f_convert_date  CHANGING pf_datum.

  CALL FUNCTION 'CONVERSION_EXIT_PDATE_OUTPUT'
    EXPORTING
      input  = pf_datum
    IMPORTING
      output = pf_datum.

ENDFORM. " F_CONVERT_DATE
*&---------------------------------------------------------------------*
*&      Form  F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*       Get Constants From EMI Tool
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_constants .
*data declaration
  DATA: li_constants TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status
*field symbol dclaration
  FIELD-SYMBOLS: <lfs_constant> TYPE zdev_enh_status. " Enhancement Status
*constant declaration
  CONSTANTS:
             lc_codepage      TYPE z_criteria    VALUE 'CODEPAGE',        " Enh. Criteria
             lc_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0156'. "Enhancement No.

*get the constants
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_constants.
*If EMI table is not initial
  IF li_constants[] IS NOT INITIAL. "sy-subrc IS INITIAL AND
    READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = lc_codepage
                                                              active = abap_true.
    IF sy-subrc = 0.
      gv_codepage = <lfs_constant>-sel_low.

      IF gv_codepage IS NOT INITIAL.
        CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_check_codepage
          CHANGING
            ch_codepage = gv_codepage.
      ENDIF. " IF gv_codepage IS NOT INITIAL

    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_constants[] IS NOT INITIAL


ENDFORM. " F_GET_CONSTANTS

*&---------------------------------------------------------------------*
*&      Form  F_GET_KEY_COMB_SUB
*&---------------------------------------------------------------------*
*   get the user selected key combination from the screen and set flag
*----------------------------------------------------------------------*
FORM f_get_key_comb_sub .
  CLEAR: gv_flg1,
         gv_flg2,
         gv_flg3,
         gv_flg4,
         gv_flg5,
         gv_flg6,
         gv_flg7,
         gv_flg8,
         gv_flg9,
         gv_flg10.

  IF rb_key1 IS NOT INITIAL.
    gv_flg1 = c_true.
    gv_key_comb = c_key_com1.
  ELSEIF rb_key2 IS NOT INITIAL.
    gv_flg2 = c_true.
    gv_key_comb = c_key_com2.
  ELSEIF rb_key3 IS NOT INITIAL.
    gv_flg3 = c_true.
    gv_key_comb = c_key_com3.
  ELSEIF rb_key4 IS NOT INITIAL.
    gv_flg4 = c_true.
    gv_key_comb = c_key_com4.
  ELSEIF rb_key5 IS NOT INITIAL.
    gv_flg5 = c_true.
    gv_key_comb = c_key_com5.
  ENDIF. " IF rb_key1 IS NOT INITIAL
  IF rb_key6 IS NOT INITIAL.
    gv_flg6 = c_true.
    gv_key_comb = c_key_com6.
  ELSEIF rb_key7 IS NOT INITIAL.
    gv_flg7 = c_true.
    gv_key_comb = c_key_com7.
  ELSEIF rb_key8 IS NOT INITIAL.
    gv_flg8 = c_true.
    gv_key_comb = c_key_com8.
  ELSEIF rb_key9 IS NOT INITIAL.
    gv_flg9 = c_true.
    gv_key_comb = c_key_com9.
  ELSEIF rb_key10 IS NOT INITIAL.
    gv_flg10 = c_true.
    gv_key_comb = c_key_com10.
  ENDIF. " IF rb_key6 IS NOT INITIAL

ENDFORM. " F_GET_KEY_COMB_SUB


*&---------------------------------------------------------------------*
*&      Form  F_POP_ERROR_FILE
*&---------------------------------------------------------------------*
*      populate error record to file
*----------------------------------------------------------------------*
*      -->FP_ERR_DATA  error data record
*----------------------------------------------------------------------*
FORM f_pop_error_file  USING    fp_err_data TYPE ty_final.

  wa_error-kschl = fp_err_data-kschl.
  wa_error-vkorg = fp_err_data-vkorg.
  wa_error-vtweg = fp_err_data-vtweg.
  wa_error-werks = fp_err_data-werks.
  wa_error-matnr = fp_err_data-matnr.
  wa_error-mvgr2 = fp_err_data-mvgr2.
  wa_error-bwart = fp_err_data-bwart.
  wa_error-lgnum = fp_err_data-lgnum.
  wa_error-kunwe = fp_err_data-kunwe.
  wa_error-kunnr = fp_err_data-kunnr.
  wa_error-auart = fp_err_data-auart.
  wa_error-charg = fp_err_data-charg.
  wa_error-land1 = fp_err_data-land1.
  wa_error-datbi = fp_err_data-datbi.
  wa_error-datab = fp_err_data-datab.

ENDFORM. " F_POP_ERROR_FILE

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ERROR_FILE
*&---------------------------------------------------------------------*
*   Populate error records to ERROR folder
*----------------------------------------------------------------------*
*      -->FP_P_AFILE     file name
*      -->FP_I_ERROR[]    error records
*----------------------------------------------------------------------*
FORM f_write_error_file  USING    fp_p_afile TYPE localfile " Local file for upload/download
                                  fp_i_error TYPE ty_t_error.

* Local Data
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
*&      Form  F_VCH01_BDC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_VALID[]  text
*      <--P_I_ERROR[]  text
*----------------------------------------------------------------------*
FORM f_vch01_bdc  USING    fp_i_final TYPE ty_t_final
                  CHANGING fp_i_error TYPE ty_t_error.

  DATA: lv_group TYPE apqi-groupid.
  CONSTANTS: lc_keep TYPE apq_qdel VALUE 'X'. " Queue deletion indicator for processed sessions
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

  CONCATENATE c_group gv_key_comb INTO lv_group SEPARATED BY '_'.

  IF fp_i_final[] IS NOT INITIAL.
    CALL FUNCTION 'BDC_OPEN_GROUP'
      EXPORTING
        client              = sy-mandt
        group               = lv_group
        keep                = lc_keep
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
      MESSAGE i051 WITH c_group .
    ELSE. " ELSE -> IF sy-subrc <> 0

      LOOP AT fp_i_final ASSIGNING <lfs_final>.

        IF gv_flg1 IS NOT INITIAL.
          PERFORM f_bdc_koth916 USING <lfs_final>.
        ENDIF. " IF gv_flg1 IS NOT INITIAL

        IF gv_flg2 IS NOT INITIAL.
          PERFORM f_bdc_koth917 USING <lfs_final>.
        ENDIF. " IF gv_flg2 IS NOT INITIAL

        IF gv_flg3 IS NOT INITIAL.
          PERFORM f_bdc_koth920 USING <lfs_final>.
        ENDIF. " IF gv_flg3 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL.
          PERFORM f_bdc_koth906 USING <lfs_final>.
        ENDIF. " IF gv_flg4 IS NOT INITIAL

        IF gv_flg5 IS NOT INITIAL.
          PERFORM f_bdc_koth907 USING <lfs_final>.
        ENDIF. " IF gv_flg5 IS NOT INITIAL

        IF gv_flg6 IS NOT INITIAL.
          PERFORM f_bdc_koth915 USING <lfs_final>.
        ENDIF. " IF gv_flg6 IS NOT INITIAL

        IF gv_flg7 IS NOT INITIAL.
          PERFORM f_bdc_koth905 USING <lfs_final>.
        ENDIF. " IF gv_flg7 IS NOT INITIAL

        IF gv_flg8 IS NOT INITIAL.
          PERFORM f_bdc_koth908 USING <lfs_final>.
        ENDIF. " IF gv_flg8 IS NOT INITIAL

        IF gv_flg9 IS NOT INITIAL.
          PERFORM f_bdc_koth921 USING <lfs_final>.
        ENDIF. " IF gv_flg9 IS NOT INITIAL

        IF gv_flg10 IS NOT INITIAL.
          PERFORM f_bdc_koth922 USING <lfs_final>.
        ENDIF. " IF gv_flg10 IS NOT INITIAL


        CALL FUNCTION 'BDC_INSERT'
          EXPORTING
            tcode            = c_tcode
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
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'BDC INSERT failed'(033).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'BDC INSERT failed'(033).
          APPEND wa_error TO fp_i_error.
          CLEAR wa_error.

        ELSE. " ELSE -> IF sy-subrc <> 0
          REFRESH i_bdcdata.
        ENDIF. " IF sy-subrc <> 0

      ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

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

ENDFORM. " F_VCH01_BDC

*&---------------------------------------------------------------------*
*&      Form  f_bdc_dynpro
*&---------------------------------------------------------------------*
*      BDC screen
*----------------------------------------------------------------------*
*      -->fp_v_program     BDC program
*      -->fp_v_dynpro      BDC screen
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING fp_v_program  TYPE bdc_prog  " BDC module pool
                         fp_v_dynpro   TYPE bdc_dynr. " BDC Screen number
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = c_true.
  APPEND lwa_bdcdata TO i_bdcdata.
ENDFORM. " BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  f_bdc_field
*&---------------------------------------------------------------------*
*       BDC field population
*----------------------------------------------------------------------*
*      -->fp_v_fnam   field name
*      -->fp_v_fval    field value
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any.
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  lwa_bdcdata-fnam = fp_v_fnam.
  lwa_bdcdata-fval = fp_v_fval.
  APPEND lwa_bdcdata TO i_bdcdata.
  CLEAR lwa_bdcdata.
ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH916
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bdc_koth916  USING  fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1916'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-KUNNR'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-KUNNR'
                                fp_lfs_final-kunnr.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1916'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MATNR(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-KUNNR'
                                fp_lfs_final-kunnr.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-MATNR(01)'
                                fp_lfs_final-matnr.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1916'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MATNR(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH916
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH917
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bdc_koth917  USING  fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(02)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1917'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-VTWEG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1917'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MATNR(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-MATNR(01)'
                                fp_lfs_final-matnr.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1917'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MATNR(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH917
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH920
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_bdc_koth920  USING  fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(03)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1920'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-VTWEG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1920'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-KUNWE(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-KUNWE(01)'
                                fp_lfs_final-kunwe.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1920'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-KUNWE(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH920
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH921
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_fp_lfs_final  text
*----------------------------------------------------------------------*
FORM f_bdc_koth921  USING fp_lfs_final TYPE ty_final.



  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(09)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(09)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1921'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MATNR'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-MATNR'
                                fp_lfs_final-matnr.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1921'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-KUNWE(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-MATNR'
                                fp_lfs_final-matnr.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-KUNWE(01)'
                                fp_lfs_final-kunwe.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1921'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-KUNWE(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH921
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH906
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*----------------------------------------------------------------------*
FORM f_bdc_koth906  USING fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(04)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1906'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-AUART_SD'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-LGNUM'
                                fp_lfs_final-lgnum.
  PERFORM f_bdc_field       USING 'KOMGH-AUART_SD'
                                fp_lfs_final-auart.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1906'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MVGR2(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-LGNUM'
                                fp_lfs_final-lgnum.
  PERFORM f_bdc_field       USING 'KOMGH-AUART_SD'
                                fp_lfs_final-auart.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-MVGR2(01)'
                                fp_lfs_final-mvgr2.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1906'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MVGR2(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH906
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH907
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*----------------------------------------------------------------------*
FORM f_bdc_koth907  USING fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(05)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(05)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1907'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-LGNUM'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-LGNUM'
                                fp_lfs_final-lgnum.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1907'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MVGR2(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-LGNUM'
                                fp_lfs_final-lgnum.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-MVGR2(01)'
                                fp_lfs_final-mvgr2.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1907'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MVGR2(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH907
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH915
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*----------------------------------------------------------------------*
FORM f_bdc_koth915  USING fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(06)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(06)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1915'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-VTWEG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1915'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-BWART(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-BWART(01)'
                                fp_lfs_final-bwart.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1915'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-BWART(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH915
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH905
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*----------------------------------------------------------------------*
FORM f_bdc_koth905  USING fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(07)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(07)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1905'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-VTWEG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1905'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MVGR2(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-MVGR2(01)'
                                fp_lfs_final-mvgr2.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1905'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MVGR2(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH905
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH908
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*----------------------------------------------------------------------*
FORM f_bdc_koth908  USING fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(08)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(08)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1908'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-AUART_SD'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-AUART_SD'
                                fp_lfs_final-auart.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1908'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-WERKS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-VKORG'
                                fp_lfs_final-vkorg.
  PERFORM f_bdc_field       USING 'KOMGH-VTWEG'
                                fp_lfs_final-vtweg.
  PERFORM f_bdc_field       USING 'KOMGH-AUART_SD'
                                fp_lfs_final-auart.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-WERKS(01)'
                                fp_lfs_final-werks.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1908'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-WERKS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH908
*&---------------------------------------------------------------------*
*&      Form  F_BDC_KOTH922
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*----------------------------------------------------------------------*
FORM f_bdc_koth922  USING fp_lfs_final TYPE ty_final.

  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'H000-KSCHL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'H000-KSCHL'
                                fp_lfs_final-kschl.
  PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RV130-SELKZ(10)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=WEIT'.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                ''.
  PERFORM f_bdc_field       USING 'RV130-SELKZ(10)'
                                'X'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1922'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-MATNR'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-MATNR'
                                fp_lfs_final-matnr.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1922'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-LAND1(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KOMGH-MATNR'
                                fp_lfs_final-matnr.
  PERFORM f_bdc_field       USING 'H000-DATAB'
                                fp_lfs_final-datab.
  PERFORM f_bdc_field       USING 'H000-DATBI'
                                fp_lfs_final-datbi.
  PERFORM f_bdc_field       USING 'KOMGH-LAND1(01)'
                                fp_lfs_final-land1.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '1922'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KOMGH-LAND1(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=DETA'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SEVO'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RMCLF-CLASS(01)'
                                fp_lfs_final-klass.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCTMS-MNAME(01)'
                                fp_lfs_final-atnam.
  PERFORM f_bdc_field       USING 'RCTMS-MWERT(01)'
                                fp_lfs_final-atwrt.
  PERFORM f_bdc_dynpro      USING 'SAPLCTMS' '0109'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCTMS-MNAME(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_dynpro      USING 'SAPLCLFM' '0500'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RMCLF-CLASS(01)'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=ENDE'.
  PERFORM f_bdc_field       USING 'RMCLF-PAGPOS'
                                '1'.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SORT'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0220'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'RCUD5-SRTSQ'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=BACK'.
  PERFORM f_bdc_field       USING 'RCUD5-SRTSQ'
                                fp_lfs_final-srtsq.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVSK'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHSPL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHSPL'
                                fp_lfs_final-chspl.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHVLL'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHMDG'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHMDG'
                                fp_lfs_final-chmdg.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.
  PERFORM f_bdc_dynpro      USING 'SAPMV13H' '0200'.
  PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                'KONDH-CHASP'.
  PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                '=SICH'.
  PERFORM f_bdc_field       USING 'KONDH-CHASP'
                                fp_lfs_final-chasp.
  PERFORM f_bdc_field       USING 'KONDH-CHMVS'
                                fp_lfs_final-chmvs.
  PERFORM f_bdc_field       USING 'KONDH-CHVSK'
                                fp_lfs_final-chvsk.
  PERFORM f_bdc_field       USING 'KONDH-CHVLL'
                                fp_lfs_final-chvll.
  PERFORM f_bdc_field       USING 'KONDH-KZAME'
                                fp_lfs_final-kzame.

ENDFORM. " F_BDC_KOTH922

*&---------------------------------------------------------------------*
*&      Form  F_HEADER_LINE_POP
*&---------------------------------------------------------------------*
*    Populate Header text line
*----------------------------------------------------------------------*
*  -->  fp_data    header line
*----------------------------------------------------------------------*
FORM f_header_line_pop CHANGING fp_data TYPE string.

***Populate header based on Key combination
  IF gv_flg1 IS NOT INITIAL.
    CONCATENATE  'Strategy Type'(005)
                 'Sales Org'(039)
                 'Distribution Channel'(045)
                 'Sold To Party'(041)
                 'Material'(040)
                 'Valid To'(043)
                 'Valid From'(044)
          INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg1 IS NOT INITIAL

  IF gv_flg2 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Material'(040)
                'Valid To'(043)
                'Valid From'(044)
         INTO fp_data
            SEPARATED BY c_tab.
  ENDIF. " IF gv_flg2 IS NOT INITIAL

  IF gv_flg3 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Ship To Party'(046)
                'Valid To'(043)
                'Valid From'(044)
          INTO fp_data
            SEPARATED BY c_tab.
  ENDIF. " IF gv_flg3 IS NOT INITIAL

  IF gv_flg4 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Sales Doc Type'(050)
                'Material Group 2'(027)
                'Valid To'(043)
                'Valid From'(044)
          INTO fp_data
            SEPARATED BY c_tab.
  ENDIF. " IF gv_flg4 IS NOT INITIAL

  IF gv_flg5 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Material Group 2'(027)
                'Valid To'(043)
                'Valid From'(044)
         INTO fp_data
         SEPARATED BY c_tab.
  ENDIF. " IF gv_flg5 IS NOT INITIAL

  IF gv_flg6 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Movement Type'(042)
                'Valid To'(043)
                'Valid From'(044)
        INTO fp_data
        SEPARATED BY c_tab.
  ENDIF. " IF gv_flg6 IS NOT INITIAL

  IF gv_flg7 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Material Group 2'(027)
                'Valid To'(043)
                'Valid From'(044)
       INTO fp_data
            SEPARATED BY c_tab.
  ENDIF. " IF gv_flg7 IS NOT INITIAL

  IF gv_flg8 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Sales Doc Type'(050)
                'Plant'(023)
                'Valid To'(043)
                'Valid From'(044)
       INTO fp_data
            SEPARATED BY c_tab.
  ENDIF. " IF gv_flg8 IS NOT INITIAL

  IF gv_flg9 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Ship To Party'(046)
                'Valid To'(043)
                'Valid From'(044)
        INTO fp_data
            SEPARATED BY c_tab.
  ENDIF. " IF gv_flg9 IS NOT INITIAL

  IF gv_flg10 IS NOT INITIAL.
    CONCATENATE 'Strategy Type'(005)
                'Sales Org'(039)
                'Distribution Channel'(045)
                'Destination Country'(048)
                'Valid To'(043)
                'Valid From'(044)
        INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg10 IS NOT INITIAL

  CONCATENATE fp_data
              'Error message'(047)
              INTO fp_data
            SEPARATED BY c_tab.

ENDFORM. " F_HEADER_LINE_POP

*&---------------------------------------------------------------------*
*&      Form  F_ERR_DATA_POP
*&---------------------------------------------------------------------*
*     Populate the error record
*----------------------------------------------------------------------*
*      -->FP_P_ERROR  Error record
*      <--FP_DATA     error data string
*----------------------------------------------------------------------*
FORM f_err_data_pop  USING    fp_p_error TYPE ty_error
                     CHANGING fp_data TYPE string.

*** Pass the error data to application server
** based on Key combination

  IF gv_flg10 IS INITIAL.
    CONCATENATE  fp_p_error-kschl
                 fp_p_error-vkorg
                 INTO fp_data

             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg10 IS INITIAL
  IF gv_flg1 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-matnr
                fp_p_error-kunnr
            INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg1 IS NOT INITIAL

  IF gv_flg2 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-matnr
                fp_p_error-kunwe
         INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg2 IS NOT INITIAL

  IF gv_flg3 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-werks
                fp_p_error-kunnr
         INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg3 IS NOT INITIAL

  IF gv_flg4 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-vtweg
                fp_p_error-matnr
                fp_p_error-land1
         INTO fp_data
*            SEPARATED BY c_tab.
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg4 IS NOT INITIAL

  IF gv_flg5 IS NOT INITIAL.
    CONCATENATE fp_data
               fp_p_error-matnr
               fp_p_error-charg
               fp_p_error-kunwe
          INTO fp_data
          SEPARATED BY c_tab.
  ENDIF. " IF gv_flg5 IS NOT INITIAL

  IF gv_flg6 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-matnr
                fp_p_error-charg
                fp_p_error-land1
       INTO fp_data
       SEPARATED BY c_tab.
  ENDIF. " IF gv_flg6 IS NOT INITIAL

  IF gv_flg7 IS NOT INITIAL.
    CONCATENATE fp_data
                 fp_p_error-matnr
                 fp_p_error-land1
        INTO fp_data
        SEPARATED BY c_tab.
  ENDIF. " IF gv_flg7 IS NOT INITIAL

  IF gv_flg8 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-vtweg
                fp_p_error-kunnr
                fp_p_error-matnr
        INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg8 IS NOT INITIAL

  IF gv_flg9 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-vtweg
                fp_p_error-matnr
        INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg9 IS NOT INITIAL

  IF gv_flg10 IS NOT INITIAL.
    CONCATENATE fp_p_error-kschl
                fp_p_error-land1
        INTO fp_data
             SEPARATED BY c_tab.
  ENDIF. " IF gv_flg10 IS NOT INITIAL

  IF gv_flg11 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-kunnr
                fp_p_error-matnr
        INTO fp_data
        SEPARATED BY c_tab.
  ENDIF. " IF gv_flg11 IS NOT INITIAL

  CONCATENATE  fp_data
               fp_p_error-datbi
               fp_p_error-datab
               fp_p_error-errmsg
           INTO fp_data
             SEPARATED BY c_tab.

ENDFORM. " F_ERR_DATA_POP
