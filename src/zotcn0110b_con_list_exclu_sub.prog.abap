*&---------------------------------------------------------------------*
*&  Include           ZOTCN0110B_CON_LIST_EXCLU_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0110B_CON_LIST_EXCLU_SUB                          *
* TITLE      :  Order to Cash D2_OTC_CDD_0110_Convert Listing          *
*               exclusion records                                      *
* DEVELOPER  :  Abhishek Gupta                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_CDD_0110                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Convert Listing exclusion records                      *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-Sep-2014 AGUPTA3  E2DK904581 INITIAL DEVELOPMENT                  *
* =========== ======== ========== =====================================*
* 12-May-2016 U033808  E1DK917461 D3: Add tables 915 and 922. File deli*
*                                 miter changed to pipe. Add codepage  *
* 23-Aug-2016 U033808  E1DK917461 D3 Defect #3121: Sort sequence for   *
*                                 tables changed in VB01               *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*                                      ITC1 Defect Issue fixed         *
* 30-AUG-2016 U033870  E1DK917461      Defect#3488: Picking file       *
*                                      from application server require *
*                                             S_DATASET authorization  *
*---------------------------------------------------------------------*
* 09-Sept-2016 U033808  E1DK917461 D3 Defect #3121 090916 : Validate   *
*                                 dest country in simulation mode      *
*----------------------------------------------------------------------*
* 28-SEP-2016 MGARG   E1DK917461  D3_CR_0062:Added logic for call trans*
*                                 action based on EMI Value. Added more*
*                                 access sequences on selection Screen *
*                                 Added option for downloading error   *
*                                 file to presentation server          *
*&---------------------------------------------------------------------*
* 19-OCT-2016 U029639 E1DK917461  D3_CR_0062_2nd_Change:Make changes in*
*                                 logic to address issues mentioned in *
*                                 defect#3121.                         *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*      Check if file name is provided or not
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
  DATA: lv_codepage TYPE abap_encoding. "code page  U033808
  CONSTANTS: lc_true TYPE char1 VALUE 'X'. " True of type CHAR1

  IF sy-batch = lc_true.
    MESSAGE i164.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-batch = lc_true

  lv_filename = fp_p_file.

*&--Begin of Changes for E1DK917461 D3 U033808
  IF gv_codepage IS NOT INITIAL.
    lv_codepage = gv_codepage.
  ELSE. " ELSE -> IF gv_codepage IS NOT INITIAL
    lv_codepage = space.
  ENDIF. " IF gv_codepage IS NOT INITIAL

  IF <fs_tab> IS ASSIGNED.
    UNASSIGN <fs_tab>.
  ENDIF. " IF <fs_tab> IS ASSIGNED
  ASSIGN i_fs_tab TO <fs_tab>.
*&--End of Changes for E1DK917461 D3 U033808

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_file_type
*     has_field_separator     = c_sep                       "Commented for E1DK917461 D3 U033808
      codepage                = lv_codepage
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
    MESSAGE i000 WITH 'No proper file exist for the logical file.'(036).
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
*&      Form  F_GET_KEY_COMB_SUB
*&---------------------------------------------------------------------*
*   get the user selected key combination from the screen and set flag
*----------------------------------------------------------------------*
FORM f_get_key_comb_sub .
  CLEAR: gv_flg1,
         gv_flg2,
         gv_flg3,
         gv_flg4,
*        gv_flg5,   "Commented for E1DK917461 D3 U033808
*        gv_flg6,   "Commented for E1DK917461 D3 U033808
         gv_flg7,
         gv_flg8,
         gv_flg9,
         gv_flg10, "Added for E1DK917461 D3 U033808
         gv_flg11, "Added for E1DK917461 D3 U033808
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
         gv_flg5,
         gv_flg6,
         gv_flg12,
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
         gv_scr_num.

  IF rb_key1 IS NOT INITIAL.
    gv_flg1 = c_true.
    gv_scr_num = c_scr_n1.
    ASSIGN i_z001_1 TO <fs_tab>.
  ELSEIF rb_key2 IS NOT INITIAL.
    gv_flg2 = c_true.
    gv_scr_num = c_scr_n2.
    ASSIGN i_z001_2 TO <fs_tab>.
  ELSEIF rb_key3 IS NOT INITIAL.
    gv_flg3 = c_true.
    gv_scr_num = c_scr_n3.
    ASSIGN i_z001_3 TO <fs_tab>.
  ELSEIF rb_key4 IS NOT INITIAL.
    gv_flg4 = c_true.
    gv_scr_num = c_scr_n4.
    ASSIGN i_z001_4 TO <fs_tab>.
*Start Changes U033808  Comment out tables 903/904
*  ELSEIF rb_key5 IS NOT INITIAL.
*    gv_flg5 = c_true.
*    gv_scr_num = c_scr_n5.
*    ASSIGN i_z001_5 TO <fs_tab>.
*  ELSEIF rb_key6 IS NOT INITIAL.
*    gv_flg6 = c_true.
*    gv_scr_num = c_scr_n6.
*    ASSIGN i_z001_6 TO <fs_tab>.
*End Changes U033808
  ELSEIF rb_key7 IS NOT INITIAL.
    gv_flg7 = c_true.
    gv_scr_num = c_scr_n7.
    ASSIGN i_z001_7 TO <fs_tab>.
  ENDIF. " IF rb_key1 IS NOT INITIAL

  IF rb_key8 IS NOT INITIAL.
    gv_flg8 = c_true.
    gv_scr_num = c_scr_n8.
    ASSIGN i_z002_1 TO <fs_tab>.
  ELSEIF rb_key9 IS NOT INITIAL.
    gv_flg9 = c_true.
    gv_scr_num = c_scr_n9.
    ASSIGN i_z002_2 TO <fs_tab>.
*Start Changes U033808  Add tables 915/922
  ELSEIF rb_key10 IS NOT INITIAL.
    gv_flg10 = c_true.
    gv_scr_num = c_scr_n10.
    ASSIGN i_z001_8 TO <fs_tab>.
  ELSEIF rb_key11 IS NOT INITIAL.
    gv_flg11 = c_true.
    gv_scr_num = c_scr_n11.
    ASSIGN i_z001_9 TO <fs_tab>.
*End Changes U033808  Add tables 915/922
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  ELSEIF rb_key5 IS NOT INITIAL.
    gv_flg5    = c_true.
    gv_scr_num = c_scr_n5.
    ASSIGN i_z001_5 TO <fs_tab>.
  ELSEIF rb_key6 IS NOT INITIAL.
    gv_flg6 = c_true.
    gv_scr_num = c_scr_n6.
    ASSIGN i_z001_6 TO <fs_tab>.
  ELSEIF rb_key12 IS NOT INITIAL.
    gv_flg12 = c_true.
    gv_scr_num = c_scr_n12.
    ASSIGN i_z002_3 TO <fs_tab>.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  ENDIF. " IF rb_key8 IS NOT INITIAL

ENDFORM. " F_GET_KEY_COMB_SUB
*&---------------------------------------------------------------------*
*&      Form  F_POP_FINAL_TAB
*&---------------------------------------------------------------------*
*      Populate input table into a generic final table
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_pop_final_tab .

  FIELD-SYMBOLS : <lfs_1> TYPE ty_key1,
                 <lfs_2>  TYPE ty_key2,
                 <lfs_3>  TYPE ty_key3,
                 <lfs_4>  TYPE ty_key4,
*                <lfs_5> TYPE ty_key5,  "Commented for E1DK917461 D3 U033808
*                <lfs_6> TYPE ty_key6,  "Commented for E1DK917461 D3 U033808
                 <lfs_7>  TYPE ty_key7,
                 <lfs_8>  TYPE ty_key8,
                 <lfs_9>  TYPE ty_key9,
                 <lfs_10> TYPE ty_key10, "Added for E1DK917461 D3 U033808
                 <lfs_11> TYPE ty_key11. "Added for E1DK917461 D3 U033808

*&--Begin of Changes for E1DK917461 D3 U033808
* Local Variables
  DATA: lv_input_line TYPE string,  "Input Raw lines
        lv_temp1 TYPE string,
        lv_temp2 TYPE string,
        lv_temp3 TYPE string,
        lv_temp4 TYPE string,
        lv_temp5 TYPE string,
        lv_temp6 TYPE string,
        lv_temp7 TYPE string,
        lv_temp8 TYPE string,
        lv_message      TYPE string,
        lv_subrc      TYPE sysubrc. "SY-SUBRC value


  FIELD-SYMBOLS:   <fs_line> TYPE ty_tab.        ##gen_ok
  LOOP AT <fs_tab> ASSIGNING <fs_line> .
    SPLIT <fs_line>-input_line AT c_pipe INTO
    lv_temp1
    lv_temp2
    lv_temp3
    lv_temp4
    lv_temp5
    lv_temp6
    lv_temp7
    lv_temp8.

    wa_final-kschl = lv_temp1.

    IF gv_flg10 IS INITIAL
*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
          AND gv_flg12 IS INITIAL.
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      wa_final-vkorg = lv_temp2.
    ENDIF. " IF gv_flg10 IS INITIAL

    IF gv_flg1 IS NOT INITIAL.
      wa_final-matnr = lv_temp3.
      wa_final-kunag = lv_temp4.
      wa_final-datbi = lv_temp5.
      wa_final-datab = lv_temp6.
    ENDIF. " IF gv_flg1 IS NOT INITIAL

    IF gv_flg2 IS NOT INITIAL.
      wa_final-matnr = lv_temp3.
      wa_final-kunwe = lv_temp4.
      wa_final-datbi = lv_temp5.
      wa_final-datab = lv_temp6.
    ENDIF. " IF gv_flg2 IS NOT INITIAL

    IF gv_flg3 IS NOT INITIAL.
      wa_final-werks = lv_temp3.
      wa_final-kunag = lv_temp4.
      wa_final-datbi = lv_temp5.
      wa_final-datab = lv_temp6.
    ENDIF. " IF gv_flg3 IS NOT INITIAL

    IF gv_flg4 IS NOT INITIAL.
      wa_final-vtweg = lv_temp3.
      wa_final-aland = lv_temp4.
      wa_final-matnr = lv_temp5.
      wa_final-land1 = lv_temp6.
      wa_final-datbi = lv_temp7.
      wa_final-datab = lv_temp8.
    ENDIF. " IF gv_flg4 IS NOT INITIAL

    IF gv_flg7 IS NOT INITIAL.
      wa_final-aland = lv_temp3.
      wa_final-matnr = lv_temp4.
      wa_final-land1 = lv_temp5.
      wa_final-datbi = lv_temp6.
      wa_final-datab = lv_temp7.
    ENDIF. " IF gv_flg7 IS NOT INITIAL

    IF gv_flg8 IS NOT INITIAL.
      wa_final-vtweg = lv_temp3.
      wa_final-zzpotype = lv_temp4.
      wa_final-kunag = lv_temp5.
      wa_final-matnr = lv_temp6.
      wa_final-datbi = lv_temp7.
      wa_final-datab = lv_temp8.
    ENDIF. " IF gv_flg8 IS NOT INITIAL

    IF gv_flg9 IS NOT INITIAL.
      wa_final-vtweg = lv_temp3.
      wa_final-zzpotype = lv_temp4.
      wa_final-matnr = lv_temp5.
      wa_final-datbi = lv_temp6.
      wa_final-datab = lv_temp7.
    ENDIF. " IF gv_flg9 IS NOT INITIAL

    IF gv_flg10 IS NOT INITIAL.
      wa_final-land1 = lv_temp2.
      wa_final-matnr = lv_temp3.
      wa_final-datbi = lv_temp4.
      wa_final-datab = lv_temp5.
    ENDIF. " IF gv_flg10 IS NOT INITIAL

    IF gv_flg11 IS NOT INITIAL.
      wa_final-kunag = lv_temp3.
      wa_final-zzprctr = lv_temp4.
      wa_final-datab = lv_temp5.
      wa_final-datbi = lv_temp6.
    ENDIF. " IF gv_flg11 IS NOT INITIAL

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
    IF gv_flg5 IS NOT INITIAL.
      wa_final-aland = lv_temp3.
      wa_final-matnr = lv_temp4.
      wa_final-charg = lv_temp5.
      wa_final-kunwe = lv_temp6.
      wa_final-datbi = lv_temp7.
      wa_final-datab = lv_temp8.
    ENDIF. " IF gv_flg5 IS NOT INITIAL
*
    IF gv_flg6 IS NOT INITIAL.
      wa_final-aland = lv_temp3.
      wa_final-matnr = lv_temp4.
      wa_final-charg = lv_temp5.
      wa_final-land1 = lv_temp6.
      wa_final-datbi = lv_temp7.
      wa_final-datab = lv_temp8.
    ENDIF. " IF gv_flg6 IS NOT INITIAL

    IF gv_flg12 IS NOT INITIAL.
      wa_final-matnr = lv_temp3.
      wa_final-charg = lv_temp4.
      wa_final-land1 = lv_temp2.
      wa_final-datbi = lv_temp5.
      wa_final-datab = lv_temp6.
    ENDIF. " IF gv_flg12 IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

    PERFORM f_convert_date CHANGING wa_final-datab.
    PERFORM f_convert_date CHANGING wa_final-datbi.
    APPEND wa_final TO i_final.
    CLEAR: wa_final.
    CLEAR lv_input_line.
  ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <fs_line>
*&--End of Changes for E1DK917461 D3 U033808

*&--Start of Commented for E1DK917461 D3 U033808
*  IF gv_flg1 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_1>.
*      wa_final-kschl = <lfs_1>-kschl.
*      wa_final-vkorg = <lfs_1>-vkorg.
*      wa_final-datab = <lfs_1>-datab.
*      wa_final-datbi = <lfs_1>-datbi.
*      wa_final-matnr = <lfs_1>-matnr.
*      wa_final-kunag = <lfs_1>-kunag.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_1>
*  ENDIF. " IF gv_flg1 IS NOT INITIAL
*
*  IF gv_flg2 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_2>.
*      wa_final-kschl = <lfs_2>-kschl.
*      wa_final-vkorg = <lfs_2>-vkorg.
*      wa_final-datab = <lfs_2>-datab.
*      wa_final-datbi = <lfs_2>-datbi.
*      wa_final-matnr = <lfs_2>-matnr.
*      wa_final-kunwe = <lfs_2>-kunwe.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_2>
*  ENDIF. " IF gv_flg2 IS NOT INITIAL
*
*  IF gv_flg3 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_3>.
*      wa_final-kschl = <lfs_3>-kschl.
*      wa_final-vkorg = <lfs_3>-vkorg.
*      wa_final-datab = <lfs_3>-datab.
*      wa_final-datbi = <lfs_3>-datbi.
*      wa_final-werks = <lfs_3>-werks.
*      wa_final-kunag = <lfs_3>-kunag.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_3>
*  ENDIF. " IF gv_flg3 IS NOT INITIAL
*
*  IF gv_flg4 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_4>.
*      wa_final-kschl = <lfs_4>-kschl.
*      wa_final-vkorg = <lfs_4>-vkorg.
*      wa_final-datab = <lfs_4>-datab.
*      wa_final-datbi = <lfs_4>-datbi.
*      wa_final-matnr = <lfs_4>-matnr.
*      wa_final-vtweg = <lfs_4>-vtweg.
*      wa_final-aland = <lfs_4>-aland.
*      wa_final-land1 = <lfs_4>-land1.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_4>
*  ENDIF. " IF gv_flg4 IS NOT INITIAL
*
** Start comment tables 903/904
**  IF gv_flg5 IS NOT INITIAL.
**    LOOP AT <fs_tab> ASSIGNING <lfs_5>.
**      wa_final-kschl = <lfs_5>-kschl.
**      wa_final-vkorg = <lfs_5>-vkorg.
**      wa_final-datab = <lfs_5>-datab.
**      wa_final-datbi = <lfs_5>-datbi.
**      wa_final-matnr = <lfs_5>-matnr.
**      wa_final-kunwe = <lfs_5>-kunwe.
**      wa_final-aland = <lfs_5>-aland.
**      wa_final-charg = <lfs_5>-charg.
**      APPEND wa_final TO i_final.
**      CLEAR: wa_final.
**    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_5>
**  ENDIF. " IF gv_flg5 IS NOT INITIAL
**
**  IF gv_flg6 IS NOT INITIAL.
**    LOOP AT <fs_tab> ASSIGNING <lfs_6>.
**      wa_final-kschl = <lfs_6>-kschl.
**      wa_final-vkorg = <lfs_6>-vkorg.
**      wa_final-datab = <lfs_6>-datab.
**      wa_final-datbi = <lfs_6>-datbi.
**      wa_final-matnr = <lfs_6>-matnr.
**      wa_final-aland = <lfs_6>-aland.
**      wa_final-charg = <lfs_6>-charg.
**      wa_final-land1 = <lfs_6>-land1.
**      APPEND wa_final TO i_final.
**      CLEAR: wa_final.
**    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_6>
**  ENDIF. " IF gv_flg6 IS NOT INITIAL
** End comment tables 903/904
*
*  IF gv_flg7 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_7>.
*      wa_final-kschl = <lfs_7>-kschl.
*      wa_final-vkorg = <lfs_7>-vkorg.
*      wa_final-datab = <lfs_7>-datab.
*      wa_final-datbi = <lfs_7>-datbi.
*      wa_final-matnr = <lfs_7>-matnr.
*      wa_final-aland = <lfs_7>-aland.
*      wa_final-land1 = <lfs_7>-land1.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_7>
*  ENDIF. " IF gv_flg7 IS NOT INITIAL
*
*  IF gv_flg8 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_8>.
*      wa_final-kschl = <lfs_8>-kschl.
*      wa_final-vkorg = <lfs_8>-vkorg.
*      wa_final-vtweg = <lfs_8>-vtweg.
*      wa_final-datab = <lfs_8>-datab.
*      wa_final-datbi = <lfs_8>-datbi.
*      wa_final-zzpotype = <lfs_8>-zzpotype.
*      wa_final-matnr = <lfs_8>-matnr.
*      wa_final-kunag = <lfs_8>-kunag.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_8>
*  ENDIF. " IF gv_flg8 IS NOT INITIAL
*
*  IF gv_flg9 IS NOT INITIAL.
*    LOOP AT <fs_tab> ASSIGNING <lfs_9>.
*      wa_final-kschl = <lfs_9>-kschl.
*      wa_final-vkorg = <lfs_9>-vkorg.
*      wa_final-vtweg = <lfs_9>-vtweg.
*      wa_final-datab = <lfs_9>-datab.
*      wa_final-datbi = <lfs_9>-datbi.
*      wa_final-zzpotype = <lfs_9>-zzpotype.
*      wa_final-matnr = <lfs_9>-matnr.
*      APPEND wa_final TO i_final.
*      CLEAR: wa_final.
*    ENDLOOP. " LOOP AT <fs_tab> ASSIGNING <lfs_9>
*  ENDIF. " IF gv_flg9 IS NOT INITIAL
*
*&--End of Commented for E1DK917461 D3 U033808

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
  DATA: lv_input_line TYPE string,   "Input Raw lines
        lv_temp1 TYPE string,
        lv_temp2 TYPE string,
        lv_temp3 TYPE string,
        lv_temp4 TYPE string,
        lv_temp5 TYPE string,
        lv_temp6 TYPE string,
        lv_temp7 TYPE string,
        lv_temp8 TYPE string,
        lv_message      TYPE string, "Added for E1DK917461 D3 U033808
        lv_subrc      TYPE sysubrc.  "SY-SUBRC value
* Opening the Dataset for File Read
*&--Begin of Changes for E1DK917461 D3 U033808 Change App Server file open method
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
*&--End of Changes for E1DK917461 D3 U033808 Change App Server file open method
*   Reading the Header Input File
    WHILE ( lv_subrc EQ 0 ).
      READ DATASET fp_p_file INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condn.
      lv_subrc = sy-subrc.
      IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
*        SPLIT lv_input_line AT c_tab                 "Commented for E1DK917461 D3 U033808

        SPLIT lv_input_line AT c_pipe "Added for E1DK917461 D3 U033808
        INTO
              lv_temp1
              lv_temp2
              lv_temp3
              lv_temp4
              lv_temp5
              lv_temp6
              lv_temp7
              lv_temp8.

**populate corresponding fields in final table
        wa_final-kschl = lv_temp1.

        IF gv_flg10 IS INITIAL "Added for E1DK917461 D3 U033808 No VKORG for  915
*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
          AND gv_flg12 IS INITIAL. " Added for 923
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
          wa_final-vkorg = lv_temp2.
        ENDIF. " IF gv_flg10 IS INITIAL

        IF gv_flg1 IS NOT INITIAL.
          wa_final-matnr = lv_temp3.
          wa_final-kunag = lv_temp4.
          wa_final-datbi = lv_temp5.
          wa_final-datab = lv_temp6.
        ENDIF. " IF gv_flg1 IS NOT INITIAL

        IF gv_flg2 IS NOT INITIAL.
          wa_final-matnr = lv_temp3.
          wa_final-kunwe = lv_temp4.
          wa_final-datbi = lv_temp5.
          wa_final-datab = lv_temp6.
        ENDIF. " IF gv_flg2 IS NOT INITIAL

        IF gv_flg3 IS NOT INITIAL.
          wa_final-werks = lv_temp3.
          wa_final-kunag = lv_temp4.
          wa_final-datbi = lv_temp5.
          wa_final-datab = lv_temp6.
        ENDIF. " IF gv_flg3 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL.
          wa_final-vtweg = lv_temp3.
          wa_final-aland = lv_temp4.
          wa_final-matnr = lv_temp5.
          wa_final-land1 = lv_temp6.
          wa_final-datbi = lv_temp7.
          wa_final-datab = lv_temp8.
        ENDIF. " IF gv_flg4 IS NOT INITIAL
*&--Begin of Changes for E1DK917461 D3 U033808 Comment 903/904
*        IF gv_flg5 IS NOT INITIAL.
*          wa_final-aland = lv_temp3.
*          wa_final-matnr = lv_temp4.
*          wa_final-charg = lv_temp5.
*          wa_final-kunwe = lv_temp6.
*          wa_final-datbi = lv_temp7.
*          wa_final-datab = lv_temp8.
*        ENDIF. " IF gv_flg5 IS NOT INITIAL
*
*        IF gv_flg6 IS NOT INITIAL.
*          wa_final-aland = lv_temp3.
*          wa_final-matnr = lv_temp4.
*          wa_final-charg = lv_temp5.
*          wa_final-land1 = lv_temp6.
*          wa_final-datbi = lv_temp7.
*          wa_final-datab = lv_temp8.
*        ENDIF. " IF gv_flg6 IS NOT INITIAL
*&--End of Changes for E1DK917461 D3 U033808 Comment 903/904
        IF gv_flg7 IS NOT INITIAL.
          wa_final-aland = lv_temp3.
          wa_final-matnr = lv_temp4.
          wa_final-land1 = lv_temp5.
          wa_final-datbi = lv_temp6.
          wa_final-datab = lv_temp7.
        ENDIF. " IF gv_flg7 IS NOT INITIAL

        IF gv_flg8 IS NOT INITIAL.
          wa_final-vtweg = lv_temp3.
          wa_final-zzpotype = lv_temp4.
          wa_final-kunag = lv_temp5.
          wa_final-matnr = lv_temp6.
          wa_final-datbi = lv_temp7.
          wa_final-datab = lv_temp8.
        ENDIF. " IF gv_flg8 IS NOT INITIAL

        IF gv_flg9 IS NOT INITIAL.
          wa_final-vtweg = lv_temp3.
          wa_final-zzpotype = lv_temp4.
          wa_final-matnr = lv_temp5.
          wa_final-datbi = lv_temp6.
          wa_final-datab = lv_temp7.
        ENDIF. " IF gv_flg9 IS NOT INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 Add 915/922
        IF gv_flg10 IS NOT INITIAL.
          wa_final-land1 = lv_temp2.
          wa_final-matnr = lv_temp3.
          wa_final-datbi = lv_temp4.
          wa_final-datab = lv_temp5.
        ENDIF. " IF gv_flg10 IS NOT INITIAL

        IF gv_flg11 IS NOT INITIAL.
          wa_final-kunag = lv_temp3.
          wa_final-zzprctr = lv_temp4.
          wa_final-datbi = lv_temp5.
          wa_final-datab = lv_temp6.
        ENDIF. " IF gv_flg11 IS NOT INITIAL

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        IF gv_flg5 IS NOT INITIAL.
          wa_final-aland = lv_temp3.
          wa_final-matnr = lv_temp4.
          wa_final-charg = lv_temp5.
          wa_final-kunwe = lv_temp6.
          wa_final-datbi = lv_temp7.
          wa_final-datab = lv_temp8.
        ENDIF. " IF gv_flg5 IS NOT INITIAL
*
        IF gv_flg6 IS NOT INITIAL.
          wa_final-aland = lv_temp3.
          wa_final-matnr = lv_temp4.
          wa_final-charg = lv_temp5.
          wa_final-land1 = lv_temp6.
          wa_final-datbi = lv_temp7.
          wa_final-datab = lv_temp8.
        ENDIF. " IF gv_flg6 IS NOT INITIAL

        IF gv_flg12 IS NOT INITIAL.
          wa_final-matnr = lv_temp4.
          wa_final-charg = lv_temp5.
          wa_final-land1 = lv_temp6.
          wa_final-datbi = lv_temp7.
          wa_final-datab = lv_temp8.
        ENDIF. " IF gv_flg12 IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

        PERFORM f_convert_date CHANGING wa_final-datab.
        PERFORM f_convert_date CHANGING wa_final-datbi.
*&--End of Changes for E1DK917461 D3 U033808 Add 915/922
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
  TRY. "Added for E1DK917461 D3 U033808
      CLOSE DATASET fp_p_file.

    CATCH cx_sy_file_close. "Added for E1DK917461 D3 U033808
      MESSAGE i021 WITH fp_p_file. "Added for E1DK917461 D3 U033808
      LEAVE LIST-PROCESSING. "Added for E1DK917461 D3 U033808
  ENDTRY. "Added for E1DK917461 D3 U033808
* Deleting the First Index Line from the table
  DELETE i_final INDEX 1.

ENDFORM. " F_UPLOAD_APPS
*&---------------------------------------------------------------------*
*&      Form  F_VB01_BDC
*&---------------------------------------------------------------------*
*       Process BDC data
*----------------------------------------------------------------------*
*      -->FP_I_FINAL[]  valid records
*      <--FP_I_ERROR[]  Error records
*----------------------------------------------------------------------*
FORM f_vb01_bdc  USING    fp_i_final TYPE ty_t_final
                 CHANGING fp_i_error TYPE ty_t_error.

  CONSTANTS: lc_keep TYPE apq_qdel VALUE 'X'. " Queue deletion indicator for processed sessions
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  DATA:
    lv_flag   TYPE char1,                          " Flag of type CHAR1
    li_bdcmsg   TYPE STANDARD TABLE OF bdcmsgcoll, " Collecting messages in the SAP System
    lv_mode     TYPE char1.                        " Mode of type CHAR1

  CONSTANTS:
    lc_mode     TYPE char1 VALUE 'N', " Mode of type CHAR1
    lc_update   TYPE char1 VALUE 'S'. " Update of type CHAR1 - Lock issue by Jahan
  FIELD-SYMBOLS:
   <lfs_bdcmsg> TYPE bdcmsgcoll. " Collecting messages in the SAP System
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

*--Added for Defect#1079-------*
  CONSTANTS : lc_z001 TYPE char4 VALUE 'Z001', " Z001 of type CHAR4
              lc_z002 TYPE char4 VALUE 'Z002', " Z002 of type CHAR4
              lc_z003 TYPE char4 VALUE 'Z003'. " Z003 of type CHAR4
*--End of Defect#1079---------*

  IF fp_i_final[] IS NOT INITIAL.

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
    IF gv_flag_calltrans NE abap_true.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      CALL FUNCTION 'BDC_OPEN_GROUP'
        EXPORTING
          client              = sy-mandt
          group               = c_group
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
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        lv_flag = abap_false.
      ELSE. " ELSE -> IF sy-subrc <> 0
        lv_flag = abap_true.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF gv_flag_calltrans NE abap_true
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

    IF lv_flag = abap_true OR gv_flag_calltrans = abap_true.
      LOOP AT fp_i_final ASSIGNING <lfs_final>.
        PERFORM f_bdc_dynpro      USING 'SAPMV13G' '0100'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'G000-KSCHL'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                      '/00'.
                                       '=ANTA'. "Commented for Defect # 1240
        PERFORM f_bdc_field       USING 'G000-KSCHL'
                                      <lfs_final>-kschl.
        PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*        PERFORM f_bdc_field       USING 'BDC_CURSOR'        "Commented for Defect # 1240
*                                      'RV130-SELKZ(02)'.   "Commented for Defect # 1240
*                                      'RV130-SELKZ(01)'.    "Commented for Defect # 1240
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=WEIT'.

*        IF ( gv_flg1 IS INITIAL
*          AND gv_flg8 IS INITIAL ). "KOTG896- Sales org./Material/Sold-to pt or KOTG918- Sales org./Distr. Chl/PO type/Sold-to pt/Material
        IF ( gv_flg1 IS NOT INITIAL
          OR gv_flg8 IS NOT INITIAL ). "KOTG896- Sales org./Material/Sold-to pt or KOTG918- Sales org./Distr. Chl/PO type/Sold-to pt/Material
*--Added for Defect#1079-------*
          IF <lfs_final>-kschl = lc_z001 OR <lfs_final>-kschl = lc_z002.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          'X'.
          ELSEIF <lfs_final>-kschl = lc_z003.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'  "Commented for Defect # 1240
*                                          'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001 OR <lfs_final>-kschl = lc_z002
        ENDIF. " IF ( gv_flg1 IS NOT INITIAL
*--End for Defect#1079-------*
        IF gv_flg2 IS NOT INITIAL "KOTG898- Sales org./Material/Ship-to or KOTG919- Sales org./Distr. Chl/PO type/Material
          OR gv_flg9 IS NOT INITIAL.
*--Added for Defect#1079-------*
          IF <lfs_final>-kschl = lc_z001 OR <lfs_final>-kschl = lc_z002.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                          'X'.
          ELSEIF <lfs_final>-kschl = lc_z003.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'  "Commented for Defect # 1240
            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)' "Added for Defect # 1240
                                          'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001 OR <lfs_final>-kschl = lc_z002
*--End for Defect#1079-------*
        ENDIF. " IF gv_flg2 IS NOT INITIAL

        IF gv_flg3 IS NOT INITIAL. "KOTG911- Sales org./Plant/Sold-to pt
*--Added for Defect#1079-------*
          IF <lfs_final>-kschl = lc_z001.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                        'X'.
          ELSE. " ELSE -> IF <lfs_final>-kschl = lc_z001
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'   "Commented for Defect # 1240
*                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
*--End for Defect#1079-------*
        ENDIF. " IF gv_flg3 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL. "KOTG912- Sales org./Distr. Chl/Country/Material/Dest. Ctry
*--Added for Defect#1079-------*
          IF <lfs_final>-kschl = lc_z001.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
                                        'X'.
          ELSEIF <lfs_final>-kschl = lc_z003.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'   "Commented for Defect # 1240
*                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
*--End for Defect#1079-------*
        ENDIF. " IF gv_flg4 IS NOT INITIAL

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        IF gv_flg5 IS NOT INITIAL. "KOTG903- Sales org./Country/Material/Batch/Ship-to
          IF <lfs_final>-kschl = lc_z001.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(05)'
                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
        ENDIF. " IF gv_flg5 IS NOT INITIAL

        IF gv_flg6 IS NOT INITIAL.
          IF <lfs_final>-kschl = lc_z001.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(06)'
                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
        ENDIF. " IF gv_flg6 IS NOT INITIAL

        IF gv_flg12 IS NOT INITIAL.
          IF <lfs_final>-kschl = lc_z001.
            PERFORM f_bdc_field       USING 'RV130-SELKZ(10)'
                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
        ENDIF. " IF gv_flg12 IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

*&--Begin of Changes for E1DK917461 D3 U033808 Comment 903/904
*        IF gv_flg5 IS NOT INITIAL. "KOTG903- Sales org./Country/Material/Batch/Ship-to
**--Added for Defect#1079-------*
*          IF <lfs_final>-kschl = lc_z001.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(05)'
*                                        'X'.
*          ELSEIF <lfs_final>-kschl = lc_z003.
**            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)' "Commented for Defect # 1240
**                                         'X'.
*          ENDIF. " IF <lfs_final>-kschl = lc_z001
**--End for Defect#1079-------*
*        ENDIF. " IF gv_flg5 IS NOT INITIAL

*        IF gv_flg6 IS NOT INITIAL. "KOTG904- Sales org./Country/Material/Batch/Dest. Ctry
*--Added for Defect#1079-------*
        IF gv_flg11 IS NOT INITIAL. "KOTG922
*&--End of Changes for E1DK917461 D3 U033808 Comment 903
          IF <lfs_final>-kschl = lc_z001.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(06)'  " "Commented for E1DK917461 D3 Defect #3121
            PERFORM f_bdc_field       USING 'RV130-SELKZ(08)' "  "Added for E1DK917461 D3 Defec #t3121
                                        'X'.
          ELSEIF <lfs_final>-kschl = lc_z003.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'  "Commented for Defect # 1240
*                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
*--End for Defect#1079-------*
        ENDIF. " IF gv_flg11 IS NOT INITIAL

        IF gv_flg7 IS NOT INITIAL. "KOTG907- Sales org./Country/Material/Dest. Ctry
*--Added for Defect#1079-------*
          IF <lfs_final>-kschl = lc_z001.
*           PERFORM f_bdc_field       USING 'RV130-SELKZ(07)'    "Commented for E1DK917461 D3 U033808
            PERFORM f_bdc_field       USING 'RV130-SELKZ(05)' "Added for E1DK917461 D3 U033808
                                       'X'.
          ELSEIF <lfs_final>-kschl = lc_z003.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(01)' "Commented for Defect # 1240
*                                        'X'.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
*--End for Defect#1079-------*
        ENDIF. " IF gv_flg7 IS NOT INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 Add tables 915
        IF gv_flg10 IS NOT INITIAL. "KOTG915
          IF <lfs_final>-kschl = lc_z001.
*            PERFORM f_bdc_field       USING 'RV130-SELKZ(08)'  "Commented for E1DK917461 D3 Defect #3121
            PERFORM f_bdc_field       USING 'RV130-SELKZ(11)' "Added for E1DK917461 D3 Defec #t3121
                                       'X'.
          ELSEIF <lfs_final>-kschl = lc_z003.
          ENDIF. " IF <lfs_final>-kschl = lc_z001
        ENDIF. " IF gv_flg10 IS NOT INITIAL
*&--End of Changes for E1DK917461 D3 U033808 Add tables 915

        PERFORM f_bdc_dynpro      USING 'SAPMV13G' gv_scr_num.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'G000-DATAB'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=SICH'.

        IF gv_flg10 IS INITIAL "Added for E1DK917461 D3 U033808
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
         AND gv_flg12 IS INITIAL.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
          PERFORM f_bdc_field       USING 'KOMGG-VKORG'
                                        <lfs_final>-vkorg.
        ENDIF. " IF gv_flg10 IS INITIAL

        PERFORM f_bdc_field       USING 'G000-DATAB'
                                        <lfs_final>-datab.
        PERFORM f_bdc_field       USING 'G000-DATBI'
                                        <lfs_final>-datbi.
        IF gv_flg3 IS INITIAL
         AND gv_flg11 IS INITIAL. "Added for E1DK917461 D3 U033808
          PERFORM f_bdc_field       USING 'KOMGG-MATNR(01)'
                                        <lfs_final>-matnr.
        ENDIF. " IF gv_flg3 IS INITIAL
        IF gv_flg2 IS NOT INITIAL
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
          OR gv_flg5 IS NOT INITIAL.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*          OR gv_flg5 IS NOT INITIAL.            "Commented for E1DK917461 D3 U033808
          PERFORM f_bdc_field       USING 'KOMGG-KUNWE(01)'
                                        <lfs_final>-kunwe.
        ENDIF. " IF gv_flg2 IS NOT INITIAL

        IF gv_flg1 IS NOT INITIAL
          OR gv_flg3 IS NOT INITIAL
          OR gv_flg8 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-KUNAG(01)'
                                           <lfs_final>-kunag.
        ENDIF. " IF gv_flg1 IS NOT INITIAL

        IF gv_flg3 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-WERKS(01)'
                                            <lfs_final>-werks.
        ENDIF. " IF gv_flg3 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-VTWEG(01)'
                                            <lfs_final>-vtweg.
        ENDIF. " IF gv_flg4 IS NOT INITIAL

        IF gv_flg8 IS NOT INITIAL
        OR gv_flg9 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-VTWEG'
                                            <lfs_final>-vtweg.

        ENDIF. " IF gv_flg8 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-ALAND(01)'
                                            <lfs_final>-aland.
        ENDIF. " IF gv_flg4 IS NOT INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 Remove 903 and 904
*        IF gv_flg5 IS NOT INITIAL
*        OR gv_flg6 IS NOT INITIAL
*         OR gv_flg7 IS NOT INITIAL .

* ---> Begin of Delete for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*        IF gv_flg7 IS NOT INITIAL.
* ---> End of Delete for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

*&--End of Changes for E1DK917461 D3 U033808 Remove 903 and 904

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        IF gv_flg5 IS NOT INITIAL
        OR gv_flg6 IS NOT INITIAL
        OR gv_flg7 IS NOT INITIAL .
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
          PERFORM f_bdc_field       USING  'KOMGG-ALAND'
                                            <lfs_final>-aland.

        ENDIF. " IF gv_flg5 IS NOT INITIAL

        IF gv_flg4 IS NOT INITIAL
*        OR gv_flg6 IS NOT INITIAL                 "Commented for E1DK917461 D3 U033808 Remove 904
         OR gv_flg7 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-LAND1(01)'
                                            <lfs_final>-land1.

        ENDIF. " IF gv_flg4 IS NOT INITIAL

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        IF gv_flg5 IS NOT INITIAL
        OR gv_flg6 IS NOT INITIAL
        OR gv_flg12 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-CHARG(01)'
                                            <lfs_final>-charg.
        ENDIF. " IF gv_flg5 IS NOT INITIAL

        IF gv_flg6 IS NOT INITIAL
          OR gv_flg12 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-LAND1(01)'
                                            <lfs_final>-land1.
        ENDIF. " IF gv_flg6 IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

*&--Begin of Changes for E1DK917461 D3 U033808 Remove 903 and 904
*        IF gv_flg5 IS NOT INITIAL
*        OR gv_flg6 IS NOT INITIAL.
*          PERFORM f_bdc_field       USING  'KOMGG-CHARG(01)'
*                                            <lfs_final>-charg.
*        ENDIF. " IF gv_flg5 IS NOT INITIAL
*&--End of Changes for E1DK917461 D3 U033808 Remove 903 and 904
        IF gv_flg8 IS NOT INITIAL
        OR gv_flg9 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-ZZPOTYPE'
                                            <lfs_final>-zzpotype.

        ENDIF. " IF gv_flg8 IS NOT INITIAL
*&--Begin of Changes for E1DK917461 D3 U033808 Add prctr for 922
        IF gv_flg10 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-LAND1'
                                            <lfs_final>-land1.
        ENDIF. " IF gv_flg10 IS NOT INITIAL

        IF gv_flg11 IS NOT INITIAL.
          PERFORM f_bdc_field       USING  'KOMGG-KUNAG'
                                           <lfs_final>-kunag.
          PERFORM f_bdc_field       USING  'KOMGG-ZZPRCTR(01)'
                                            <lfs_final>-zzprctr.

        ENDIF. " IF gv_flg11 IS NOT INITIAL
*&--End of Changes for E1DK917461 D3 U033808 Add prctr for 922

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
** When EMI flag is active for criteria BATCH_CALLTRANS, then Call transaction
** will be called
        IF gv_flag_calltrans =  abap_true.

          lv_mode = lc_mode.
          CALL TRANSACTION c_tcode USING i_bdcdata
                MODE lv_mode
                UPDATE  lc_update
                MESSAGES INTO li_bdcmsg.

          DELETE li_bdcmsg WHERE msgtyp NE c_error AND
                                 msgtyp NE c_abort.
          LOOP AT li_bdcmsg ASSIGNING <lfs_bdcmsg>.

***Populate unsucessful records to error file and report.
            PERFORM f_error_key_sub USING <lfs_final>.
            CONCATENATE 'Call Transaction Failed'(070) <lfs_bdcmsg>-fldname INTO wa_report-msgtxt
            SEPARATED BY c_fslash.
            wa_report-msgtyp = c_emsg.
            APPEND wa_report TO i_report.
            CLEAR wa_report.

            PERFORM f_pop_error_file USING <lfs_final>.
            CONCATENATE 'Call Transaction Failed'(070) <lfs_bdcmsg>-fldname INTO wa_error-errmsg
            SEPARATED BY c_fslash.
            APPEND wa_error TO fp_i_error.
            CLEAR wa_error.

          ENDLOOP. " LOOP AT li_bdcmsg ASSIGNING <lfs_bdcmsg>
          REFRESH: i_bdcdata,
                   li_bdcmsg.
        ELSE. " ELSE -> IF gv_flag_calltrans = abap_true
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

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
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        ENDIF. " IF gv_flag_calltrans = abap_true
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      IF gv_flag_calltrans NE  abap_true.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

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

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      ENDIF. " IF gv_flag_calltrans NE abap_true
    ENDIF. " IF lv_flag = abap_true OR gv_flag_calltrans = abap_true
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  ENDIF. " IF fp_i_final[] IS NOT INITIAL


* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  IF gv_flag_calltrans NE  abap_true.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*&--Added by JAHAN.
*&--Submit the created batch input session for execution.
    SUBMIT rsbdcsub WITH mappe = c_group
                        WITH von   = sy-datum
                        WITH bis   = sy-datum
                        WITH z_verarb = 'X' EXPORTING LIST TO MEMORY AND RETURN.

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  ENDIF. " IF gv_flag_calltrans NE abap_true
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
  DELETE ADJACENT DUPLICATES FROM fp_i_error COMPARING ALL FIELDS.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639

ENDFORM. " F_VB01_BDC
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
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
*&      Form  F_BDC_FIELD
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
**Foe Condition Type
        BEGIN OF lty_type,
          kvewe TYPE kvewe, " Usage of the condition table
          kappl TYPE kappl, " Application
          kschl TYPE kschl, " Condition Type
        END OF lty_type,
** For Customer
        BEGIN OF lty_cust,
          kunnr TYPE kunnr, " Customer Number
        END OF lty_cust,
**For Country
        BEGIN OF lty_cntry,
          land1 TYPE land1, " Country Key
        END OF lty_cntry,
**For Plant
         BEGIN OF lty_plnt,
           werks TYPE werks_d, " Plant
         END OF lty_plnt,
**For distribution channel
         BEGIN OF lty_dc,
           vtweg TYPE vtweg, " Distribution Channel
         END OF lty_dc,
**For batch number
         BEGIN OF lty_bnum,
           matnr TYPE matnr,   " Material Number
           charg TYPE charg_d, " Batch Number
         END OF lty_bnum,
** For PO type
           BEGIN OF lty_potyp,
             bsark TYPE bsark, " Customer purchase order type
           END OF lty_potyp.
*&--Begin of Changes for E1DK917461 D3 U033808 For profit Center
** For Profit Center
  TYPES:   BEGIN OF lty_profctr,
       prctr TYPE prctr, " Profit Center
     END OF lty_profctr.
*&--End of Changes for E1DK917461 D3 U033808 For profit Center

**Local Internal Tables
  DATA: li_final TYPE STANDARD TABLE OF ty_final,
        li_mara  TYPE STANDARD TABLE OF lty_mara,
        li_tvko  TYPE STANDARD TABLE OF lty_tvko,
        li_type  TYPE STANDARD TABLE OF lty_type,
        li_cust  TYPE STANDARD TABLE OF lty_cust,
        li_cust1  TYPE STANDARD TABLE OF lty_cust,
        li_cntry TYPE STANDARD TABLE OF lty_cntry,
        li_cntry1 TYPE STANDARD TABLE OF lty_cntry,
        li_plnt  TYPE STANDARD TABLE OF lty_plnt,
        li_dcha  TYPE STANDARD TABLE OF lty_dc,
        li_bnum  TYPE STANDARD TABLE OF lty_bnum,
        li_profctr TYPE STANDARD TABLE OF lty_profctr, "Added for E1DK917461 D3 U033808
        li_potyp TYPE STANDARD TABLE OF lty_potyp.

**Local variables
  DATA:  lwa_cust1  TYPE lty_cust,
         lwa_cntry1 TYPE lty_cntry,
         lv_err_flg TYPE char1, " Err_flg of type CHAR1
         lv_temp1 TYPE i,       " Temp1 of type Integers
         lv_temp2 TYPE i.       " Temp2 of type Integers


**Local Constants
  CONSTANTS: lc_v TYPE kappl VALUE 'V', " Application
             lc_g TYPE kvewe VALUE 'G'. " Usage of the condition table
**Local Field symbols
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final,
                 <lfs_final_t> TYPE ty_final.

  REFRESH : li_final.
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

**get all exclusion type
  li_final[] = i_final[].
  DELETE li_final WHERE kschl IS INITIAL.
  SORT li_final BY kschl.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kschl.
  IF li_final[] IS NOT INITIAL.
    SELECT kvewe " Usage of the condition table
           kappl " Application
           kschl " Condition Type
      FROM t685  " Conditions: Types
      INTO TABLE li_type
      FOR ALL ENTRIES IN li_final
      WHERE kvewe = lc_g
      AND   kappl = lc_v
      AND kschl = li_final-kschl.
    IF sy-subrc = 0.
      SORT li_type BY kschl.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**get all customer
  li_final[] = i_final[].
  DELETE li_final WHERE kunag IS INITIAL.
  SORT li_final BY kunag.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING kunag.
  IF li_final[] IS NOT INITIAL.
    LOOP AT li_final ASSIGNING <lfs_final_t>.
      CLEAR: lwa_cust1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_final_t>-kunag
        IMPORTING
          output = lwa_cust1-kunnr.
      APPEND lwa_cust1 TO li_cust1.
    ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final_t>
  ENDIF. " IF li_final[] IS NOT INITIAL

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

**Get all countries
  li_final[] = i_final[].
  DELETE li_final WHERE aland IS INITIAL.
  SORT li_final BY aland.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING aland.
  IF li_final[] IS NOT INITIAL.
    LOOP AT li_final ASSIGNING <lfs_final_t>.
      CLEAR: lwa_cntry1.
      lwa_cntry1-land1 = <lfs_final_t>-aland.
      APPEND lwa_cntry1 TO li_cntry1.
    ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final_t>
  ENDIF. " IF li_final[] IS NOT INITIAL

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

**Get all plants
  li_final[] = i_final[].
  DELETE li_final WHERE werks IS INITIAL.
  SORT li_final BY werks.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING werks.
  IF li_final[] IS NOT INITIAL.
    SELECT werks " Sales Organization
      FROM t001w " Organizational Unit: Sales Organizations
      INTO TABLE li_plnt
      FOR ALL ENTRIES IN li_final
      WHERE werks = li_final-werks.
    IF sy-subrc = 0.
      SORT li_plnt BY werks.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

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

**Get all PO Type
  li_final[] = i_final[].
  DELETE li_final WHERE zzpotype IS INITIAL.
  SORT li_final BY zzpotype.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING zzpotype.
  IF li_final[] IS NOT INITIAL.
    SELECT bsark " Customer purchase order type
      FROM t176  " Sales Documents: Customer Order Types
      INTO TABLE li_potyp
      FOR ALL ENTRIES IN li_final
      WHERE bsark = li_final-zzpotype.
    IF sy-subrc = 0.
      SORT li_potyp BY bsark.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

**get all batch number
  li_final[] = i_final[].
  DELETE li_final WHERE ( matnr IS INITIAL OR charg IS INITIAL ).
  SORT li_final BY matnr ASCENDING
                   charg ASCENDING.
  DELETE ADJACENT DUPLICATES FROM li_final COMPARING matnr charg.
  IF li_final[] IS NOT INITIAL.
    SELECT matnr " Material Number
           charg " Batch Number
      FROM mch1  " Batches (if Batch Management Cross-Plant)
      INTO TABLE li_bnum
      FOR ALL ENTRIES IN li_final
      WHERE matnr = li_final-matnr
      AND  charg = li_final-charg.
    IF sy-subrc = 0.
      SORT li_bnum BY matnr ASCENDING
                      charg ASCENDING.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_final[] IS NOT INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 Get all profit centers
**Get all Profit Center (Small table)
  SELECT prctr " Profit Center
    FROM cepc  " profit center
    INTO TABLE li_profctr.
  IF sy-subrc = 0.
    SORT li_profctr BY prctr.
  ENDIF. " IF sy-subrc = 0
*&--End of Changes for E1DK917461 D3 U033808 Get all profit centers

**Validate Input fields
  LOOP AT i_final ASSIGNING <lfs_final>.
    CLEAR: lv_err_flg.
**validate Exclusion type
    IF <lfs_final>-kschl IS INITIAL.
*      error flag
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Exclusion type can not be blank.'(007).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Exclusion type can not be blank.'(007).
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
        wa_report-msgtxt = 'Invalid Exclusion type.'(008).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Exclusion type.'(008).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-kschl IS INITIAL

**Validate Sales Org
    IF <lfs_final>-vkorg IS INITIAL.
*      error
      IF gv_flg10 IS INITIAL "Added for E1DK917461 D3 U033808 Table 915 does not have vkorg
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        AND gv_flg12 IS INITIAL.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Sales Org can not be blank.'(009).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Sales Org can not be blank.'(009).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF gv_flg10 IS INITIAL
    ELSE. " ELSE -> IF <lfs_final>-vkorg IS INITIAL
      READ TABLE li_tvko TRANSPORTING NO FIELDS
                          WITH KEY vkorg = <lfs_final>-vkorg
                          BINARY SEARCH.
      IF sy-subrc <> 0.
** error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Invalid Sales Org.'(010).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Invalid Sales Org.'(010).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF <lfs_final>-vkorg IS INITIAL

**Validate material.
    IF gv_flg3 IS INITIAL
    AND gv_flg11 IS INITIAL. "Added for E1DK917461 D3 U033808
      IF <lfs_final>-matnr IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Material can not be blank.'(011).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Material can not be blank.'(011).
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
          wa_report-msgtxt = 'Invalid Material.'(012).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Material.'(012).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-matnr IS INITIAL
    ENDIF. " IF gv_flg3 IS INITIAL


***Validate Ship To Party
    IF gv_flg2 IS NOT INITIAL
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      OR gv_flg5 IS NOT INITIAL.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*      OR gv_flg5 IS NOT INITIAL.     "Commented for E1DK917461 D3 U033808
      IF <lfs_final>-kunwe IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Ship To Party can not be blank.'(013).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Ship To Party can not be blank.'(013).
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
          wa_report-msgtxt = 'Invalid Ship To Party.'(014).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Ship To Party.'(014).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-kunwe IS INITIAL
    ENDIF. " IF gv_flg2 IS NOT INITIAL


**validate Sold To Party
    IF gv_flg1 IS NOT INITIAL
       OR gv_flg3 IS NOT INITIAL
          OR gv_flg8 IS NOT INITIAL.
      IF <lfs_final>-kunag IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Sold To Party can not be blank.'(015).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Sold To Party can not be blank.'(015).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-kunag IS INITIAL
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lfs_final>-kunag
          IMPORTING
            output = <lfs_final>-kunag.

        READ TABLE li_cust TRANSPORTING NO FIELDS
                            WITH KEY kunnr = <lfs_final>-kunag
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Sold To Party.'(016).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Sold To Party.'(016).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-kunag IS INITIAL
    ENDIF. " IF gv_flg1 IS NOT INITIAL


**Validate plant
    IF gv_flg3 IS NOT INITIAL.
      IF <lfs_final>-werks IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Plant can not be blank.'(017).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Plant can not be blank.'(017).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-werks IS INITIAL
        READ TABLE li_plnt TRANSPORTING NO FIELDS
                            WITH KEY werks = <lfs_final>-werks
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Plant.'(018).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Plant.'(018).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-werks IS INITIAL
    ENDIF. " IF gv_flg3 IS NOT INITIAL

**Validate Departure Country
    IF gv_flg4 IS NOT INITIAL
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      OR gv_flg5 IS NOT INITIAL
      OR gv_flg6 IS NOT INITIAL
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*     OR gv_flg5 IS NOT INITIAL   "Commented for E1DK917461 D3 U033808
*     OR gv_flg6 IS NOT INITIAL   "Commented for E1DK917461 D3 U033808
      OR gv_flg7 IS NOT INITIAL.
      IF <lfs_final>-aland IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Departure Country can not be blank.'(019).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Departure Country can not be blank.'(019).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-aland IS INITIAL
        READ TABLE li_cntry TRANSPORTING NO FIELDS
                            WITH KEY land1 = <lfs_final>-aland
                            BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Departure Country.'(020).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Departure Country.'(020).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-aland IS INITIAL
    ENDIF. " IF gv_flg4 IS NOT INITIAL

    IF gv_flg10 IS NOT INITIAL ""Added for Defect#3121 090916 U033808
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
      OR gv_flg6 IS NOT INITIAL
      OR gv_flg12 IS NOT INITIAL.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
****Validate Destination Country
*      IF gv_flg5 IS INITIAL.             "Commented for E1DK917461 D3 U033808
      IF <lfs_final>-land1 IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Destination Country can not be blank.'(021).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Destination Country can not be blank.'(021).
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
          wa_report-msgtxt = 'Invalid Destination Country.'(022).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Destination Country.'(022).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-land1 IS INITIAL
    ENDIF. " IF gv_flg10 IS NOT INITIAL

*&----Begin Comment for E1DK917461 D3 U033808
**Validate Batch number
*      IF gv_flg5 IS NOT INITIAL
*        OR gv_flg6 IS NOT INITIAL.
*        IF <lfs_final>-charg IS INITIAL.
**      error
*          lv_err_flg = c_true.
*          PERFORM f_error_key_sub USING <lfs_final>.
*          wa_report-msgtyp = c_emsg.
*          wa_report-msgtxt = 'Batch Number can not be blank.'(023).
*          APPEND wa_report TO i_report.
*          CLEAR wa_report.
*
*          PERFORM f_pop_error_file USING <lfs_final>.
*          wa_error-errmsg = 'Batch Number can not be blank.'(023).
*          APPEND wa_error TO i_error.
*          CLEAR wa_error.
*          CONTINUE.
*        ELSE. " ELSE -> IF <lfs_final>-charg IS INITIAL
*          READ TABLE li_bnum TRANSPORTING NO FIELDS
*                              WITH KEY matnr = <lfs_final>-matnr
*                                       charg = <lfs_final>-charg
*                                       BINARY SEARCH.
*          IF sy-subrc <> 0.
*** error
*            lv_err_flg = c_true.
*            PERFORM f_error_key_sub USING <lfs_final>.
*            wa_report-msgtyp = c_emsg.
*            wa_report-msgtxt = 'Invalid Batch Number.'(024).
*            APPEND wa_report TO i_report.
*            CLEAR wa_report.
*
*            PERFORM f_pop_error_file USING <lfs_final>.
*            wa_error-errmsg = 'Invalid Batch Number.'(024).
*            APPEND wa_error TO i_error.
*            CLEAR wa_error.
*            CONTINUE.
*          ENDIF. " IF sy-subrc <> 0
*        ENDIF. " IF <lfs_final>-charg IS INITIAL
*      ENDIF. " IF gv_flg5 IS NOT INITIAL
*&----End Comment for E1DK917461 D3 U033808
*    ENDIF. " IF gv_flg4 IS NOT INITIAL

****Validate Distribution channel
    IF gv_flg4 IS NOT INITIAL
       OR gv_flg8 IS NOT INITIAL
        OR gv_flg9 IS NOT INITIAL.
      IF <lfs_final>-vtweg IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Distribution Channel can not be blank.'(025).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Distribution Channel can not be blank.'(025).
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
          wa_report-msgtxt = 'Invalid Distribution Channel.'(026).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Distribution Channel.'(026).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-vtweg IS INITIAL

***Validate PO type
      IF gv_flg4 IS INITIAL.
        IF <lfs_final>-zzpotype IS INITIAL.
*      error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'PO Type can not be blank.'(027).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'PO Type can not be blank.'(027).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ELSE. " ELSE -> IF <lfs_final>-zzpotype IS INITIAL
          READ TABLE li_potyp TRANSPORTING NO FIELDS
                              WITH KEY bsark = <lfs_final>-zzpotype
                                       BINARY SEARCH.
          IF sy-subrc <> 0.
** error
            lv_err_flg = c_true.
            PERFORM f_error_key_sub USING <lfs_final>.
            wa_report-msgtyp = c_emsg.
            wa_report-msgtxt = 'Invalid PO Type.'(028).
            APPEND wa_report TO i_report.
            CLEAR wa_report.

            PERFORM f_pop_error_file USING <lfs_final>.
            wa_error-errmsg = 'Invalid PO Type.'(028).
            APPEND wa_error TO i_error.
            CLEAR wa_error.
            CONTINUE.
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF <lfs_final>-zzpotype IS INITIAL
      ENDIF. " IF gv_flg4 IS INITIAL

    ENDIF. " IF gv_flg4 IS NOT INITIAL

***Validate start date
    IF <lfs_final>-datab IS INITIAL.
**error
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Valid From date can not be blank.'(029).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Valid From date can not be blank.'(029).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.
    ENDIF. " IF <lfs_final>-datab IS INITIAL

*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
**Validate Batch number
    IF gv_flg5 IS NOT INITIAL
      OR gv_flg6 IS NOT INITIAL.
      IF <lfs_final>-charg IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Batch Number can not be blank.'(023).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Batch Number can not be blank.'(023).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-charg IS INITIAL
        READ TABLE li_bnum TRANSPORTING NO FIELDS
                            WITH KEY matnr = <lfs_final>-matnr
                                     charg = <lfs_final>-charg
                                     BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Batch Number.'(024).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Batch Number.'(024).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-charg IS INITIAL
    ENDIF. " IF gv_flg5 IS NOT INITIAL
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

***Validate end date
    IF <lfs_final>-datbi IS INITIAL.
**error
      lv_err_flg = c_true.
      PERFORM f_error_key_sub USING <lfs_final>.
      wa_report-msgtyp = c_emsg.
      wa_report-msgtxt = 'Valid To date can not be blank.'(030).
      APPEND wa_report TO i_report.
      CLEAR wa_report.

      PERFORM f_pop_error_file USING <lfs_final>.
      wa_error-errmsg = 'Valid To date can not be blank.'(030).
      APPEND wa_error TO i_error.
      CLEAR wa_error.
      CONTINUE.
    ENDIF. " IF <lfs_final>-datbi IS INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 Validate Profit Center
    IF gv_flg11 IS NOT INITIAL.
      IF <lfs_final>-zzprctr IS INITIAL.
*      error
        lv_err_flg = c_true.
        PERFORM f_error_key_sub USING <lfs_final>.
        wa_report-msgtyp = c_emsg.
        wa_report-msgtxt = 'Profit Center can not be blank.'(063).
        APPEND wa_report TO i_report.
        CLEAR wa_report.

        PERFORM f_pop_error_file USING <lfs_final>.
        wa_error-errmsg = 'Profit Center can not be blank.'(063).
        APPEND wa_error TO i_error.
        CLEAR wa_error.
        CONTINUE.
      ELSE. " ELSE -> IF <lfs_final>-zzprctr IS INITIAL
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = <lfs_final>-zzprctr
          IMPORTING
            output = <lfs_final>-zzprctr.

        READ TABLE li_profctr TRANSPORTING NO FIELDS
                            WITH KEY prctr = <lfs_final>-zzprctr
                                     BINARY SEARCH.
        IF sy-subrc <> 0.
** error
          lv_err_flg = c_true.
          PERFORM f_error_key_sub USING <lfs_final>.
          wa_report-msgtyp = c_emsg.
          wa_report-msgtxt = 'Invalid Profit Center.'(064).
          APPEND wa_report TO i_report.
          CLEAR wa_report.

          PERFORM f_pop_error_file USING <lfs_final>.
          wa_error-errmsg = 'Invalid Profit Center.'(064).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
      ENDIF. " IF <lfs_final>-zzprctr IS INITIAL
    ENDIF. " IF gv_flg11 IS NOT INITIAL
*&--End of Changes for E1DK917461 D3 U033808 Validate profit Center

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

*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
** When Call Transaction is chosen then No need to convert Date field
  IF gv_flag_calltrans NE abap_true.
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*Start U033808
    PERFORM f_convert_error_date USING fp_err_key-datbi.
    PERFORM f_convert_error_date USING fp_err_key-datab.
*End U033808
*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  ENDIF. " IF gv_flag_calltrans NE abap_true
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

**Populate error Key based on Key combination
  IF gv_flg1 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-matnr
                fp_err_key-kunag
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg1 IS NOT INITIAL

  IF gv_flg2 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-matnr
                fp_err_key-kunwe
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg2 IS NOT INITIAL

  IF gv_flg3 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-werks
                fp_err_key-kunag
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg3 IS NOT INITIAL

  IF gv_flg4 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-aland
                fp_err_key-matnr
                fp_err_key-land1
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg4 IS NOT INITIAL

*&----Begin Comment for E1DK917461 D3 U033808
*  IF gv_flg5 IS NOT INITIAL.
*    CONCATENATE fp_err_key-kschl
*                fp_err_key-vkorg
*                fp_err_key-aland
*                fp_err_key-matnr
*                fp_err_key-charg
*                fp_err_key-kunwe
*                fp_err_key-datbi
*                fp_err_key-datab
*    INTO wa_report-key SEPARATED BY c_fslash.
*  ENDIF. " IF gv_flg5 IS NOT INITIAL
*
*  IF gv_flg6 IS NOT INITIAL.
*    CONCATENATE fp_err_key-kschl
*                fp_err_key-vkorg
*                fp_err_key-aland
*                fp_err_key-matnr
*                fp_err_key-charg
*                fp_err_key-land1
*                fp_err_key-datbi
*                fp_err_key-datab
*    INTO wa_report-key SEPARATED BY c_fslash.
*  ENDIF. " IF gv_flg6 IS NOT INITIAL
*&----End Comment for E1DK917461 D3 U033808

  IF gv_flg7 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-aland
                fp_err_key-matnr
                fp_err_key-land1
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg7 IS NOT INITIAL

  IF gv_flg8 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-zzpotype
                fp_err_key-kunag
                fp_err_key-matnr
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg8 IS NOT INITIAL

  IF gv_flg9 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-vtweg
                fp_err_key-zzpotype
                fp_err_key-matnr
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg9 IS NOT INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 add tables 915/922
  IF gv_flg10 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-land1
                fp_err_key-matnr
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg10 IS NOT INITIAL

  IF gv_flg11 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-land1
                fp_err_key-kunag
                fp_err_key-zzprctr
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg11 IS NOT INITIAL
*&--Begin of Changes for E1DK917461 D3 U033808 add tables 915/922

*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  IF gv_flg5 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-aland
                fp_err_key-matnr
                fp_err_key-charg
                fp_err_key-kunwe
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg5 IS NOT INITIAL

  IF gv_flg6 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-vkorg
                fp_err_key-aland
                fp_err_key-matnr
                fp_err_key-charg
                fp_err_key-land1
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg6 IS NOT INITIAL

  IF gv_flg12 IS NOT INITIAL.
    CONCATENATE fp_err_key-kschl
                fp_err_key-land1
                fp_err_key-matnr
                fp_err_key-charg
                fp_err_key-datbi
                fp_err_key-datab
    INTO wa_report-key SEPARATED BY c_fslash.
  ENDIF. " IF gv_flg12 IS NOT INITIAL
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG


ENDFORM. " F_ERROR_KEY_SUB
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
  wa_error-werks = fp_err_data-werks.
  wa_error-matnr = fp_err_data-matnr.
  wa_error-kunwe = fp_err_data-kunwe.
  wa_error-kunag = fp_err_data-kunag.
  wa_error-vtweg = fp_err_data-vtweg.
  wa_error-aland = fp_err_data-aland.
  wa_error-land1 = fp_err_data-land1.
  wa_error-charg = fp_err_data-charg.
  wa_error-zzpotype = fp_err_data-zzpotype.
  wa_error-zzprctr = fp_err_data-zzprctr. "Added for E1DK917461 D3 U033808
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

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
  CONCATENATE c_error_file lv_name INTO lv_name.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639

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
*    Populate Header text line
*----------------------------------------------------------------------*
*  -->  fp_data    header line
*----------------------------------------------------------------------*
FORM f_header_line_pop CHANGING fp_data TYPE string.

***Populate header based on Key combination
  IF gv_flg1 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
                 'Sales Org'(039)
                 'Material'(040)
                 'Sold To Party'(041)
                 'Valid To'(043)
                 'Valid From'(044)
          INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808

  ENDIF. " IF gv_flg1 IS NOT INITIAL

  IF gv_flg2 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
                'Sales Org'(039)
                'Material'(040)
                'Ship To Party'(046)
                'Valid To'(043)
                'Valid From'(044)
         INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg2 IS NOT INITIAL

  IF gv_flg3 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
                 'Sales Org'(039)
                 'Plant'(049)
                 'Sold To Party'(041)
                 'Valid To'(043)
                 'Valid From'(044)
          INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg3 IS NOT INITIAL

  IF gv_flg4 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
                 'Sales Org'(039)
                 'Distribution Channel'(045)
                 'Departure Country'(050)
                 'Material'(040)
                 'Destination Country'(048)
                 'Valid To'(043)
                 'Valid From'(044)
          INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808

  ENDIF. " IF gv_flg4 IS NOT INITIAL

*&--Begin of comments for E1DK917461 D3 U033808
*  IF gv_flg5 IS NOT INITIAL.
*    CONCATENATE 'Exclusion Type'(005)
*                'Sales Org'(039)
*                'Departure Country'(050)
*                'Material'(040)
*                'Batch Number'(051)
*                'Ship To Party'(046)
*                'Valid To'(043)
*                'Valid From'(044)
*         INTO fp_data
*         SEPARATED BY c_tab.
*  ENDIF. " IF gv_flg5 IS NOT INITIAL
*
*  IF gv_flg6 IS NOT INITIAL.
*    CONCATENATE 'Exclusion Type'(005)
*               'Sales Org'(039)
*               'Departure Country'(050)
*               'Material'(040)
*               'Batch Number'(051)
*               'Destination Country'(048)
*               'Valid To'(043)
*               'Valid From'(044)
*        INTO fp_data
*        SEPARATED BY c_tab.
*  ENDIF. " IF gv_flg6 IS NOT INITIAL
*&--End of comments for E1DK917461 D3 U033808

  IF gv_flg7 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
              'Sales Org'(039)
              'Departure Country'(050)
              'Material'(040)
              'Destination Country'(048)
              'Valid To'(043)
              'Valid From'(044)
       INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg7 IS NOT INITIAL

  IF gv_flg8 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
              'Sales Org'(039)
              'Distribution Channel'(045)
              'PO Type'(042)
              'Sold To Party'(041)
              'Material'(040)
              'Valid To'(043)
              'Valid From'(044)
       INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg8 IS NOT INITIAL

  IF gv_flg9 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
               'Sales Org'(039)
               'Distribution Channel'(045)
               'PO Type'(042)
               'Material'(040)
               'Valid To'(043)
               'Valid From'(044)
        INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808

  ENDIF. " IF gv_flg9 IS NOT INITIAL

*&--Begin of Changes for E1DK917461 D3 U033808 Header for 915/922
  IF gv_flg10 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
               'Destination Country'(048)
               'Material'(040)
               'Valid To'(043)
               'Valid From'(044)
        INTO fp_data
             SEPARATED BY c_pipe.

  ENDIF. " IF gv_flg10 IS NOT INITIAL

  IF gv_flg11 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
               'Sales Org'(039)
               'Sold To Party'(041)
               'Profit Center'(065)
               'Valid To'(043)
               'Valid From'(044)
        INTO fp_data
              SEPARATED BY c_pipe.

  ENDIF. " IF gv_flg11 IS NOT INITIAL

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

  IF gv_flg5 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
                'Sales Org'(039)
                'Departure Country'(050)
                'Material'(040)
                'Batch Number'(051)
                'Ship To Party'(046)
                'Valid To'(043)
                'Valid From'(044)
         INTO fp_data
         SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg5 IS NOT INITIAL

  IF gv_flg6 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
               'Sales Org'(039)
               'Departure Country'(050)
               'Material'(040)
               'Batch Number'(051)
               'Destination Country'(048)
               'Valid To'(043)
               'Valid From'(044)
        INTO fp_data
        SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg6 IS NOT INITIAL

  IF gv_flg12 IS NOT INITIAL.
    CONCATENATE 'Exclusion Type'(005)
               'Departure Country'(050)
               'Material'(040)
               'Batch Number'(051)
               'Valid To'(043)
               'Valid From'(044)
        INTO fp_data
        SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg12 IS NOT INITIAL

* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  CONCATENATE fp_data
              'Error message'(047)
              INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808

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

  IF gv_flg10 IS INITIAL "Added for E1DK917461 D3 U033808
*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
    AND gv_flg12 IS INITIAL.
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
    CONCATENATE  fp_p_error-kschl
                 fp_p_error-vkorg
                 INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg10 IS INITIAL
  IF gv_flg1 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-matnr
                fp_p_error-kunag
            INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg1 IS NOT INITIAL

  IF gv_flg2 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-matnr
                fp_p_error-kunwe
         INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg2 IS NOT INITIAL

  IF gv_flg3 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-werks
                fp_p_error-kunag
         INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg3 IS NOT INITIAL

  IF gv_flg4 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-vtweg
                fp_p_error-aland
                fp_p_error-matnr
                fp_p_error-land1
         INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg4 IS NOT INITIAL

*&--Begin of comments for E1DK917461 D3 U033808
*  IF gv_flg5 IS NOT INITIAL.
*    CONCATENATE fp_data
*               fp_p_error-aland
*               fp_p_error-matnr
*               fp_p_error-charg
*               fp_p_error-kunwe
*          INTO fp_data
*          SEPARATED BY c_tab.
*  ENDIF. " IF gv_flg5 IS NOT INITIAL
*
*  IF gv_flg6 IS NOT INITIAL.
*    CONCATENATE fp_data
*                fp_p_error-aland
*                fp_p_error-matnr
*                fp_p_error-charg
*                fp_p_error-land1
*       INTO fp_data
*       SEPARATED BY c_tab.
*  ENDIF. " IF gv_flg6 IS NOT INITIAL
*
*  IF gv_flg7 IS NOT INITIAL.
*    CONCATENATE fp_data
*                 fp_p_error-aland
*                 fp_p_error-matnr
*                 fp_p_error-land1
*        INTO fp_data
*        SEPARATED BY c_tab.
*  ENDIF. " IF gv_flg7 IS NOT INITIAL
*&--End of comments for E1DK917461 D3 U033808

  IF gv_flg8 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-vtweg
                fp_p_error-zzpotype
                fp_p_error-kunag
                fp_p_error-matnr
        INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg8 IS NOT INITIAL

  IF gv_flg9 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-vtweg
                fp_p_error-zzpotype
                fp_p_error-matnr
        INTO fp_data
*            SEPARATED BY c_tab.              "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808
  ENDIF. " IF gv_flg9 IS NOT INITIAL

*&--Start of Changes for E1DK917461 D3 U033808 Header for 915/922
  IF gv_flg10 IS NOT INITIAL.
    CONCATENATE fp_p_error-kschl
                fp_p_error-land1
                fp_p_error-matnr
* ---> Begin of Delete for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
*                fp_p_error-zzprctr this field is not available for this key comb.
* ---> End of Delete for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
        INTO fp_data
        SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg10 IS NOT INITIAL

  IF gv_flg11 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-kunag
                fp_p_error-zzprctr
                fp_p_error-matnr
        INTO fp_data
        SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg11 IS NOT INITIAL
*&--End of Changes for E1DK917461 D3 U033808 Header for 915/922

*---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  IF gv_flg5 IS NOT INITIAL.
    CONCATENATE fp_data
               fp_p_error-aland
               fp_p_error-matnr
               fp_p_error-charg
               fp_p_error-kunwe
          INTO fp_data
          SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg5 IS NOT INITIAL

  IF gv_flg6 IS NOT INITIAL.
    CONCATENATE fp_data
                fp_p_error-aland
                fp_p_error-matnr
                fp_p_error-charg
                fp_p_error-land1
       INTO fp_data
       SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg6 IS NOT INITIAL

  IF gv_flg12 IS NOT INITIAL.
    CONCATENATE fp_p_error-kschl
                fp_p_error-land1
                fp_p_error-matnr
                fp_p_error-charg
        INTO fp_data
             SEPARATED BY c_pipe.
  ENDIF. " IF gv_flg12 IS NOT INITIAL
*---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

  CONCATENATE  fp_data
               fp_p_error-datbi
               fp_p_error-datab
               fp_p_error-errmsg
           INTO fp_data
*            SEPARATED BY c_tab. "Comments for E1DK917461 D3 U033808
             SEPARATED BY c_pipe. "Comments for E1DK917461 D3 U033808

ENDFORM. " F_ERR_DATA_POP
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
             lc_codepage      TYPE z_criteria    VALUE 'CODEPAGE', " Enh. Criteria
* ---> Begin of Delete for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*             lc_enh_name      TYPE z_enhancement VALUE 'D3_OTC_CDD_0110'. "Enhancement No,
* ---> End of Delete for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
             lc_calltra       TYPE z_criteria     VALUE 'BATCH_CALLTRANS', " Enh. Criteria
             lc_enh_name      TYPE z_enhancement  VALUE 'OTC_CDD_0110'.    "Enhancement No,
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG

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

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
    READ TABLE li_constants ASSIGNING <lfs_constant> WITH KEY criteria = lc_calltra
                                                              active = abap_true.
    IF sy-subrc = 0.
      gv_flag_calltrans = <lfs_constant>-sel_low.
    ENDIF. " IF sy-subrc = 0
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
  ENDIF. " IF li_constants[] IS NOT INITIAL


ENDFORM. " F_GET_CONSTANTS
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_ERROR_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_FP_ERR_KEY_DATBI  text
*----------------------------------------------------------------------*
FORM f_convert_error_date  USING    p_key_date.

  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external       = p_key_date
*     ACCEPT_INITIAL_DATE =
    IMPORTING
      date_internal       = p_key_date.
* EXCEPTIONS
*   DATE_EXTERNAL_IS_INVALID       = 1
*   OTHERS                         = 2

*No subrc date check. just leave as is


ENDFORM. " F_CONVERT_ERROR_DATE
*--> Begin of change for Defect#3488 by U033870 on 08/30/2016
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FILE
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*         Authorization check based on filename for AL11 action        *
*----------------------------------------------------------------------*
*      -->FP_LV_FILENAME  Local file for upload/download
*      <--FP_LV_FLAG      General Flag
*----------------------------------------------------------------------*
FORM f_check_file  USING    fp_filename TYPE localfile " Local file for upload/download
                   CHANGING fp_flag     TYPE flag.     " General Flag


  CONSTANTS: lc_act  TYPE char5 VALUE 'READ'. " Act of type Character
  DATA:      lv_file TYPE fileextern. " Physical file name

  CLEAR lv_file.

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_act
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc IS INITIAL.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_CHECK_FILE
*<-- End of change for Defect#3488 by U033870 on 08/30/2016

* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
*&---------------------------------------------------------------------*
*&      Form  F_SAVE_PRESENTATION
*&---------------------------------------------------------------------*
*       Save Error File on presentation server
*----------------------------------------------------------------------*
*  -->  FP_I_ERROR   Error Table
*----------------------------------------------------------------------*
FORM f_save_presentation USING fp_i_error TYPE ty_t_error .

  TYPES:
       BEGIN OF lty_data,
         data TYPE string,
       END OF lty_data.

  DATA:
        li_data   TYPE STANDARD TABLE OF lty_data,
        lwa_data  TYPE lty_data,
        lv_file   TYPE string.

  FIELD-SYMBOLS :
       <lfs_error> TYPE ty_error.

*   Forming the header text line
  PERFORM f_header_line_pop CHANGING lwa_data-data.
  APPEND lwa_data TO li_data.
  CLEAR: lwa_data.

*   Passing the Erroneous data
  LOOP AT fp_i_error  ASSIGNING <lfs_error>.
    PERFORM f_err_data_pop USING <lfs_error>
                          CHANGING lwa_data-data.
    APPEND lwa_data TO li_data.
    CLEAR: lwa_data.
  ENDLOOP. " LOOP AT fp_i_error ASSIGNING <lfs_error>

  lv_file = p_dfile.
  REPLACE ALL OCCURRENCES OF '.XLSX' IN lv_file WITH '.TXT'.
  REPLACE ALL OCCURRENCES OF '.XLS'  IN lv_file WITH '.TXT'.

  IF lv_file IS NOT INITIAL.

    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_file
        filetype                = c_file_type
      TABLES
        data_tab                = li_data
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        OTHERS                  = 22.
    IF sy-subrc NE 0.
      wa_report-msgtyp = c_imsg.
      wa_report-msgtxt = 'Unable to Open the file'(068). "Unable to open file
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ELSE. " ELSE -> IF sy-subrc NE 0
      wa_report-msgtyp = c_imsg.
      wa_report-msgtxt = 'Error File downloaded to Presentation Server'(067). "File downloaded on Presentation Server
* ---> Begin of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
      wa_report-key    = lv_file.
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062_2nd_Change by u029639
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF lv_file IS NOT INITIAL
ENDFORM. " F_SAVE_PRESENTATION
* ---> End of Insert for D3_OTC_CDD_0110_D3_CR_0062 by MGARG
