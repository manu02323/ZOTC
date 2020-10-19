************************************************************************
* PROGRAM    :  ZOTCN0069B_MODIFY_FORM                                 *
* TITLE      :  OTC_CDD_0069B BILLING OUTPUT                           *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0069                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  INCLUDE FOR ALL SUBROUTINES                            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 19-MAY-2012 APURI    E1DK901634 INITIAL DEVELOPMENT                  *
* 23-Dec-2014 SMEKALA  E2DK907954 D2: Add new billing condition types  *
* 23-MAY-2016 U033830  E1DK918109 D3:1.Add new condition types:        *
*                                      ZED1 and ZEIN.                  *
*                                 2. Remove upload for table B911 for  *
*                                    conditions ZRD1 and ZRD0.         *
* 28-OCT-2016 MTHATHA  E1DK918109 Defect#5781 comment the logic due to *
*                                 change in config of acess sequence   *
* 09-Dec-2016 MTHATHA  E1DK918109 D3_Defect#6399:Add new condition     *
*                                 type ZEIN for  B905.                 *
* 16-Nov-2017 U033876  E1DK932575 D3.R2_Defect#4204:Add new conditions *
*                                 type ZEDK, ZEFI, ZENO, ZESE for  B905*
* 21-Feb-2018 U034334  E1DK932575 D3R3 Defect 4204: Add output types   *
*                                 for new E-invoices. Remove hard-coded*
*                                 constants and read them using EMI    *
* 07-MAR-2019 U104864  E2DK922522 SCTASK0801088 Update Key field and   *
*                                 addition of KeyCombination ZRD6905   *
************************************************************************


*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Selection screen dynamic modification
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_modify_screen .
  LOOP AT SCREEN .
*   Presentation Server Option is NOT chosen
    IF rb_pres NE c_true.
*     Hiding Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
*   Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE c_true
*     Disaplying Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*   Application Server Option is NOT chosen
    IF rb_app NE c_true.
*     Hiding 1) Application Server file Physical paths with modify id MI2
*     2) Logical Filename Radio Button with with modify id MI5
*     3) Logical Filename input with modify id MI7
      IF screen-group1    = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE c_true
*     If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ c_true.
*       Displaying Application Server Physical paths with modify id MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_one.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Hiding Logical Filaename input with modify id MI7
        IF screen-group1 = c_groupmi7.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSEIF rb_alog EQ c_true.
*       Hiding Application Server - Physical paths with modify id MI2
        IF screen-group1 = c_groupmi2.
          screen-active = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical File name input with modify id MI7
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
*       Checking extension of file
*----------------------------------------------------------------------*
*      -->fp_p_file TYPE localfile.
*----------------------------------------------------------------------*
FORM f_check_extension  USING fp_p_file TYPE localfile. " Local file for upload/download
  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_file
                              CHANGING gv_extn.
*Checking the extension whether its of .CSV
    IF gv_extn <> c_ext .
      MESSAGE e000 WITH 'Please provide CSV file'(026).
    ENDIF. " IF gv_extn <> c_ext
  ENDIF. " IF fp_p_file IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether the file name has been entered or not
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  IF rb_pres IS NOT INITIAL AND
     p_pfile IS INITIAL.
    MESSAGE i000 WITH 'Presentation server file has not been entered'(007).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_afile IS INITIAL.
      MESSAGE i000 WITH 'Application server file has not been entered'(008).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i000 WITH 'Logical File Path has not been entered'(009).
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL

ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*       Uploading the file from presentation server
*----------------------------------------------------------------------*
*      -->fp_p_pfile  TYPE localfile
*      <--fp_i_modify TYPE ty_t_modify
*----------------------------------------------------------------------*
FORM f_upload_presnt_files  USING    fp_p_pfile  TYPE localfile " Local file for upload/download
                            CHANGING fp_i_modify TYPE ty_t_modify.
* Local Data Declaration
  DATA: lv_filename TYPE string,    "localfile name
        li_str      TYPE STANDARD TABLE OF string
                    INITIAL SIZE 0, "table of type string
*       local work area of type string to split records in csv file.
        lwa_str     TYPE string,      "lwa_str type string
        li_string   TYPE ty_t_modify, "table type ty_t_modify
        lwa_string  TYPE ty_modify.   "type ty_modify.

  lv_filename = fp_p_pfile.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_ftyp
    CHANGING
      data_tab                = li_str[]
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
    MESSAGE i000
    WITH 'File could not be read from presentation server'(028).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

  LOOP AT li_str INTO lwa_str.
    SPLIT lwa_str AT c_comma INTO
        lwa_string-keycombi
        lwa_string-kschl
        lwa_string-vkorg
        lwa_string-bsark " Added for D2
        lwa_string-kunre
        lwa_string-parvw
        lwa_string-parnr
        lwa_string-nacha
        lwa_string-vsztp
        lwa_string-fkart
        lwa_string-tcode
        lwa_string-ldest
        lwa_string-tdarmod
        lwa_string-tdschedule
        lwa_string-dimme
        .
    APPEND lwa_string TO li_string.
    CLEAR  lwa_string.
  ENDLOOP. " LOOP AT li_str INTO lwa_str
  fp_i_modify = li_string[].
*   Deleting the Header Line
  DELETE fp_i_modify INDEX 1.

ENDFORM. " F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*       Moving the file to done folder
*----------------------------------------------------------------------*
*      -->fp_v_source TYPE localfile.
*----------------------------------------------------------------------*
FORM f_move  USING   fp_v_source TYPE localfile. " Local file for upload/download
* Local Data
  DATA: lv_file   TYPE localfile, "File Name
        lv_name   TYPE localfile, "Path Name
        lv_return TYPE sysubrc.   "Return Code

* Splitting File Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_v_source
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* First move the file to the Done folder
  REPLACE c_tbp_fld
          IN lv_file
          WITH c_done_fld .
  CONCATENATE lv_file lv_name
                INTO lv_file.

* Move the file
  PERFORM f_file_move  USING    fp_v_source
                                lv_file
                       CHANGING lv_return.

  IF lv_return IS INITIAL.
    gv_archive_gl_1 = lv_file.
  ELSE. " ELSE -> IF lv_return IS INITIAL
* Error message if lv_return is not initial.
    MESSAGE i000 WITH 'File cannot be archived'(011).
  ENDIF. " IF lv_return IS INITIAL

ENDFORM. " F_MOVE
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*     Moving the file to error folder
*----------------------------------------------------------------------*
*      --> fp_p_afile    TYPE localfile
*      --> fp_i_error    TYPE ty_t_error.
*----------------------------------------------------------------------*
FORM f_move_error USING fp_p_afile TYPE localfile " Local file for upload/download
                        fp_i_error TYPE ty_t_error.
* Local Data
  DATA: lv_file   TYPE localfile,   "File Name
        lv_name   TYPE localfile,   "File Name
        lv_data   TYPE string,      "Output data string
        lwa_error TYPE ty_modify_e. "Error work area

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE c_tbp_fld
  IN lv_file
  WITH c_error_fld .
  CONCATENATE lv_file c_slash lv_name
  INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT " Output type
                       IN TEXT MODE
                       ENCODING DEFAULT.
  IF sy-subrc NE 0.
    MESSAGE i000
    WITH 'Error Folder could not be opened'(012).
  ELSE. " ELSE -> IF sy-subrc NE 0
*   Forming the header text line
    CONCATENATE  'Key combination'(h01)
                 'Condition type'(h17)
                 'Sales organization'(h02)
                 'Purchase order type'(h23) "Added for D2
                 'Bill to party'(h05)
                 'Partner function'(h06)
                 'Partner Number'(h22)
                 'Message transmission medium'(h18)
                 'Dispatch time'(h21)
                 'Billing tpe'(h03)
                 'Communication strategy'(h20)
                 'Spool : output devie'(h07)
                 'Print: Archiving mode'(h10)
                 'Send time request'(h08)
                 'Print immediately'(h09)
                 'Error Message'(h16)
         INTO lv_data
         SEPARATED BY c_tab.
    TRANSFER lv_data TO lv_file.
    CLEAR lv_data.

*   Passing the Error Header data
    LOOP AT fp_i_error INTO lwa_error.
      CONCATENATE
                    lwa_error-keycombi
                    lwa_error-kschl
                    lwa_error-vkorg
                    lwa_error-bsark "Added for D2
                    lwa_error-kunre
                    lwa_error-parvw
                    lwa_error-parnr
                    lwa_error-nacha
                    lwa_error-vsztp
                    lwa_error-fkart
                    lwa_error-tcode
                    lwa_error-ldest
                    lwa_error-tdarmod
                    lwa_error-tdschedule
                    lwa_error-dimme
                    lwa_error-errormsg
           INTO lv_data
           SEPARATED BY c_tab.
*     Transferring the data into application server.
      TRANSFER lv_data TO lv_file.
      CLEAR lv_data.
    ENDLOOP. " LOOP AT fp_i_error INTO lwa_error
  ENDIF. " IF sy-subrc NE 0
  CLOSE DATASET lv_file.
ENDFORM. " F_MOVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       Getting physical file path from logical file path
*----------------------------------------------------------------------*
*      -->fp_p_alog    TYPE pathintern
*      <--fp_gv_modify TYPE localfile.
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING     fp_p_alog    TYPE pathintern " Logical path name
                            CHANGING  fp_gv_modify TYPE localfile. " Local file for upload/download
* Local Data Declaration
  DATA: li_input   TYPE zdev_t_file_list_in,
        lwa_input  TYPE zdev_file_list_in,  " Input for FM ZDEV_DIRECTORY_FILE_LIST
        li_output  TYPE zdev_t_file_list_out,
        lwa_output TYPE zdev_file_list_out, " Output for FM ZDEV_DIRECTORY_FILE_LIST
        li_error   TYPE zdev_t_file_list_error.

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retrieving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = c_ind1
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
    MESSAGE i000 WITH 'No proper file exist for the logical file.'(029).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
      lwa_output-filename
      INTO fp_gv_modify.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL AND
ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*       Uploading the file from applicaion server
*----------------------------------------------------------------------*
*      -->fp_p_afile  TYPE localfile
*      <--fp_i_modify TYPE ty_t_modify.
*----------------------------------------------------------------------*
FORM f_upload_applcn_files  USING    fp_p_afile  TYPE localfile " Local file for upload/download
                            CHANGING fp_i_modify TYPE ty_t_modify.
* Local Variables
  DATA: lv_input_line TYPE string,    "Input Raw lines
        lwa_modify    TYPE ty_modify, "Input work area
        lv_subrc      TYPE sysubrc,   "SY-SUBRC value
        lv_verstufe   TYPE char4.     " New Insp. Stage - Not OK
* Opening the Dataset for File Read
  OPEN DATASET fp_p_afile FOR INPUT " Set as Ready for Input
                          IN TEXT MODE
                          ENCODING DEFAULT.
  IF sy-subrc IS INITIAL.
*   Reading the Input File
    WHILE ( lv_subrc EQ 0 ).
*      sy-subrc is checked in while codition
      READ DATASET fp_p_afile INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condition.
      lv_subrc = sy-subrc.
      IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
        SPLIT lv_input_line AT c_comma
        INTO        lwa_modify-keycombi
                    lwa_modify-kschl
                    lwa_modify-vkorg
                    lwa_modify-bsark "Added for D2
                    lwa_modify-kunre
                    lwa_modify-parvw
                    lwa_modify-parnr
                    lwa_modify-nacha
                    lwa_modify-vsztp
                    lwa_modify-fkart
                    lwa_modify-tcode
                    lwa_modify-ldest
                    lwa_modify-tdarmod
                    lwa_modify-tdschedule
                    lwa_modify-dimme
                    .
*       If the last entry is a Line Feed (i.e. CR_LF), then ignore.
        IF lv_verstufe = c_crlf.
          CLEAR lv_verstufe.
        ELSEIF lv_verstufe CA c_crlf.
*       If the last field does not fills up the full length of
*       field, then the last character will be CR-LF. Replacing the
*       CR-LF from the last field if it contains CR-LF.
          REPLACE ALL OCCURRENCES
          OF c_crlf
          IN lv_verstufe
          WITH space.
*         Removing the space.
          CONDENSE lv_verstufe.
        ENDIF. " IF lv_verstufe = c_crlf
        IF NOT lwa_modify IS INITIAL.
          APPEND lwa_modify TO fp_i_modify.
          CLEAR lwa_modify.
        ENDIF. " IF NOT lwa_modify IS INITIAL
      ENDIF. " IF lv_subrc IS INITIAL
      CLEAR lv_input_line.
    ENDWHILE.
* If File Open fails, then populating the Error Log
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
*   Forming the Message
    MESSAGE i000
    WITH 'System is not able to read the input file'(018).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL
* Closing the Dataset.
  CLOSE DATASET fp_p_afile.
* Deleting the First Index Line from the table
  DELETE fp_i_modify INDEX 1.
ENDFORM. " F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       Validating the fields from input file
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_validation.
  DATA: lwa_vkorg    TYPE ty_vkorg,     " work area decalration for sales organization
        lwa_kunnr    TYPE ty_kunnr,     " work area declaration for customer number
        lwa_parvw    TYPE ty_parvw,     " work area declaration for partner function
        lwa_fkart    TYPE ty_fkart,     " work area decalration for billing type
        lwa_kschl    TYPE ty_kschl,     " work area declaration for condition type
        lwa_bsark    TYPE ty_bsark,     " work area declaration for Purchase order type " Added for D2
        lwa_b905     TYPE ty_b905,      " work area declaration for b905 table
        lwa_b906     TYPE ty_b906,      " work area declaration for b906 table
        lwa_b911     TYPE ty_b911,      " work area declaration for b906 table "Added for D2
        lv_error     TYPE char1,        " error flag
        lv_parvw     TYPE parvw,        " Partner Function
        lv_msg       TYPE string,       " message text
        lv_key       TYPE string,       " local variable for key fields

        li_vkorg_val TYPE STANDARD TABLE OF ty_vkorg
                     INITIAL SIZE 0,
        li_kunnr_val TYPE STANDARD TABLE OF ty_kunnr
                     INITIAL SIZE 0,
        li_parvw_val TYPE STANDARD TABLE OF ty_parvw
                     INITIAL SIZE 0,
        li_fkart_val TYPE STANDARD TABLE OF ty_fkart
                     INITIAL SIZE 0,
        li_kschl_val TYPE STANDARD TABLE OF ty_kschl
                     INITIAL SIZE 0,
        li_bsark_val TYPE STANDARD TABLE OF ty_bsark
                     INITIAL SIZE 0, " Added for D2
        li_b905_val  TYPE STANDARD TABLE OF ty_b905
                     INITIAL SIZE 0,
        li_b906_val  TYPE STANDARD TABLE OF ty_b906
                     INITIAL SIZE 0,
        li_b911_val  TYPE STANDARD TABLE OF ty_b911
                     INITIAL SIZE 0. " Added for D2
  FIELD-SYMBOLS: <lfs_modify> TYPE ty_modify.

*  validating sales organization from tvko table

  LOOP AT i_modify ASSIGNING <lfs_modify>.
*  appending vkorg to li_vkorg_val table
    CLEAR lwa_vkorg.
    lwa_vkorg-vkorg = <lfs_modify>-vkorg.
    APPEND lwa_vkorg TO li_vkorg_val.

*  appending kunnr to li_kunnr_val table
    CLEAR lwa_kunnr.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = <lfs_modify>-kunre
      IMPORTING
        output = <lfs_modify>-kunre.
    lwa_kunnr-kunnr = <lfs_modify>-kunre.
    APPEND lwa_kunnr TO li_kunnr_val.

*  appending parvw to li_parvw_val table
    CLEAR lwa_parvw-parvw.
    CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
      EXPORTING
        input  = <lfs_modify>-parvw
      IMPORTING
        output = lwa_parvw-parvw.
    APPEND lwa_parvw TO li_parvw_val.

*  appending fkart to li_fkart_val table
    CLEAR lwa_fkart.
    lwa_fkart-fkart = <lfs_modify>-fkart.
    APPEND lwa_fkart TO li_fkart_val.

*  appending kschl to li_kschl_val table
    CLEAR lwa_kschl.
    lwa_kschl-kschl = <lfs_modify>-kschl.
    APPEND lwa_kschl TO li_kschl_val.

*-- Begin of D2
*  appending bsark to li_bsark_val table
    CLEAR lwa_bsark.
    lwa_bsark-bsark = <lfs_modify>-bsark.
    APPEND lwa_bsark TO li_bsark_val.
*-- End of D2

*  appending KAPPL,KSCHL,VKORG,FKART,KUNRE,knumh to li_b905_val table
    IF <lfs_modify>-keycombi EQ c_zrd0905 OR
       <lfs_modify>-keycombi EQ c_zrd0f905 OR
       <lfs_modify>-keycombi EQ c_zrd1905 OR
       <lfs_modify>-keycombi EQ c_z810905
* ---> Begin of Insert for D3_OTC_CDD_0069 By U033830
    OR <lfs_modify>-keycombi EQ c_zed1905
* ---> End of Insert for D3_OTC_CDD_0069 By U033830
* ---> Begin of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* Commenting the below hard-coded output types for E-Invoicing,
*   as they will be read from the EMI table
** ---> Begin of Insert for D3_Defect#6399 By mthatha
*          OR <lfs_modify>-keycombi EQ c_zein905
** ---> End of Insert for D3_Defect#6399 By mthatha
** ---> Begin of Insert for D3.R2_Defect#4204 By U033876
*          OR <lfs_modify>-keycombi EQ c_zedk905
*          OR <lfs_modify>-keycombi EQ c_zefi905
*          OR <lfs_modify>-keycombi EQ c_zeno905
*          OR <lfs_modify>-keycombi EQ c_zese905.
**<---- End of Insert for D3.R2_Defect#4204 By U033876
* <--- End   of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
     OR <lfs_modify>-keycombi IN i_einvoice_905.
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
      CLEAR lwa_b905.
      lwa_b905-kappl = c_billing.
      lwa_b905-kschl = <lfs_modify>-kschl.
      lwa_b905-vkorg = <lfs_modify>-vkorg.
      lwa_b905-fkart = <lfs_modify>-fkart.
      lwa_b905-kunre = <lfs_modify>-kunre.
      APPEND lwa_b905 TO li_b905_val.
    ENDIF. " IF <lfs_modify>-keycombi EQ c_zrd0905 OR

*  appending kappl,kschl,vkorg,kunre to li_b906_val table.
    IF <lfs_modify>-keycombi EQ c_zrd0906 OR
       <lfs_modify>-keycombi EQ c_zrd0f906 OR
       <lfs_modify>-keycombi EQ c_zrd1906 OR
       <lfs_modify>-keycombi EQ c_z810906 "Added for D2
* ---> Begin of Insert for D3_OTC_CDD_0069 By U033830
    OR <lfs_modify>-keycombi EQ c_zed1906
* ---> End of Insert for D3_OTC_CDD_0069 By U033830
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
     OR <lfs_modify>-keycombi IN i_einvoice_906.
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18

      CLEAR lwa_b906.
      lwa_b906-kappl = c_billing.
      lwa_b906-kschl = <lfs_modify>-kschl.
      lwa_b906-vkorg = <lfs_modify>-vkorg.
      lwa_b906-kunre = <lfs_modify>-kunre.
      APPEND lwa_b906 TO li_b906_val.
    ENDIF. " IF <lfs_modify>-keycombi EQ c_zrd0906 OR

*-- Begin of D2
*  appending data to li_b911_val table
    IF <lfs_modify>-keycombi EQ c_z810911.
* Required only for condition type Z810 in D3
* ---> Begin of Delete for D3_OTC_CDD_0069 By U033830
*      OR <lfs_modify>-keycombi EQ c_zrd1911 OR
*       <lfs_modify>-keycombi EQ c_zrd0f911 OR
*       <lfs_modify>-keycombi EQ c_zrd0911.
* ---> End of Delete for D3_OTC_CDD_0069 By U033830
      CLEAR lwa_b911.
      lwa_b911-kappl = c_billing.
      lwa_b911-kschl = <lfs_modify>-kschl.
      lwa_b911-vkorg = <lfs_modify>-vkorg.
      lwa_b911-bsark = <lfs_modify>-bsark.
      lwa_b911-kunre = <lfs_modify>-kunre.
      APPEND lwa_b911 TO li_b911_val.
    ENDIF. " IF <lfs_modify>-keycombi EQ c_z810911
*-- End of D2
  ENDLOOP. " LOOP AT i_modify ASSIGNING <lfs_modify>
*  validating vkorg from tvko table
  IF li_vkorg_val[] IS NOT INITIAL.
    SORT li_vkorg_val BY vkorg.
    DELETE ADJACENT DUPLICATES
    FROM li_vkorg_val
    COMPARING vkorg.
    SELECT vkorg     " Sales Organization
           FROM tvko " Organizational Unit: Sales Organizations
           INTO TABLE i_vkorg
           FOR ALL ENTRIES IN li_vkorg_val
           WHERE vkorg EQ li_vkorg_val-vkorg.
    IF sy-subrc EQ 0.
      SORT i_vkorg BY vkorg.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vkorg_val[] IS NOT INITIAL

*  validating kunnr from kna1 table
  IF li_kunnr_val IS NOT INITIAL.
    SORT li_kunnr_val BY kunnr.
    DELETE ADJACENT DUPLICATES
    FROM li_kunnr_val
    COMPARING kunnr.
    SELECT kunnr " Customer Number
       FROM kna1 " General Data in Customer Master
       INTO TABLE i_kunnr
       FOR ALL ENTRIES IN li_kunnr_val
       WHERE kunnr EQ li_kunnr_val-kunnr.
    IF  sy-subrc EQ 0.
      SORT i_kunnr BY kunnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_kunnr_val IS NOT INITIAL

*  validating parvw from tpar table.
  IF  li_parvw_val IS NOT INITIAL.
    SORT li_parvw_val BY parvw.
    DELETE ADJACENT DUPLICATES
    FROM li_parvw_val
    COMPARING parvw.
    SELECT parvw     " Partner Function
           FROM tpar " Business Partner: Functions
           INTO TABLE i_parvw
           FOR ALL ENTRIES IN li_parvw_val
           WHERE parvw EQ li_parvw_val-parvw.
    IF sy-subrc EQ 0.
      SORT i_parvw BY parvw.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_parvw_val IS NOT INITIAL

*  validating fkart from tvfk table
  IF li_fkart_val IS NOT INITIAL.
    SORT li_fkart_val BY fkart.
    DELETE ADJACENT DUPLICATES FROM li_fkart_val
                               COMPARING fkart.
    SELECT fkart     " Billing Type
           FROM tvfk " Billing: Document Types
           INTO TABLE i_fkart
           FOR ALL ENTRIES IN li_fkart_val
           WHERE fkart EQ li_fkart_val-fkart.
    IF  sy-subrc EQ 0.
      SORT i_fkart BY fkart.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_fkart_val IS NOT INITIAL


*  validating kschl from t685 table
  IF li_kschl_val IS NOT INITIAL.
    SORT li_kschl_val BY kschl.
    DELETE ADJACENT DUPLICATES FROM li_kschl_val
                               COMPARING kschl.
    SELECT kschl     " Condition Type
           FROM t685 " Conditions: Types
           INTO TABLE i_kschl
           FOR ALL ENTRIES IN li_kschl_val
           WHERE kschl EQ li_kschl_val-kschl.
    IF sy-subrc EQ 0.
      SORT i_kschl BY kschl.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_kschl_val IS NOT INITIAL

*-- Begin of D2
*  validating BSARK from t176 table
  IF li_bsark_val IS NOT INITIAL.
    SORT li_bsark_val BY bsark.
    DELETE ADJACENT DUPLICATES FROM li_bsark_val
                               COMPARING bsark.
    SELECT bsark     " Customer purchase order type
           FROM t176 " Sales Documents: Customer Order Types
           INTO TABLE i_bsark
           FOR ALL ENTRIES IN li_bsark_val
           WHERE bsark EQ li_bsark_val-bsark.
    IF sy-subrc EQ 0.
      SORT i_bsark BY bsark.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_bsark_val IS NOT INITIAL
*-- End of D2
* validating duplicate record from b905 table
  IF li_b905_val IS NOT INITIAL.
    SORT li_b905_val BY kappl
                        kschl
                        vkorg
                        fkart
                        kunre.
    DELETE ADJACENT DUPLICATES FROM li_b905_val
                               COMPARING kappl
                                         kschl
                                         vkorg
                                         fkart
                                         kunre.
    SELECT kappl kschl vkorg fkart kunre
           FROM b905 " Sales org./Bill. Type/Bill to
           INTO TABLE i_b905
           FOR ALL ENTRIES IN li_b905_val
           WHERE kappl EQ li_b905_val-kappl AND
                 kschl EQ li_b905_val-kschl AND
                 vkorg EQ li_b905_val-vkorg AND
                 fkart EQ li_b905_val-fkart AND
                 kunre EQ li_b905_val-kunre.
    IF sy-subrc EQ 0.
      SORT i_b905 BY kappl kschl vkorg fkart kunre.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_b905_val IS NOT INITIAL

* validating duplicate record from b906 table
  IF li_b906_val IS NOT INITIAL.
    SORT li_b906_val BY kappl
                        kschl
                        vkorg
                        kunre.
    DELETE ADJACENT DUPLICATES FROM li_b906_val
                               COMPARING kappl
                                         kschl
                                         vkorg
                                         kunre.
    SELECT kappl kschl vkorg  kunre
           FROM b906 " Sales org./Bill to
           INTO TABLE i_b906
           FOR ALL ENTRIES IN li_b906_val
           WHERE kappl EQ li_b906_val-kappl AND
                 kschl EQ li_b906_val-kschl AND
                 vkorg EQ li_b906_val-vkorg AND
                 kunre EQ li_b906_val-kunre.
    IF sy-subrc EQ 0.
      SORT i_b906 BY kappl kschl vkorg kunre.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_b906_val IS NOT INITIAL

*-- Begin of D2
* validating duplicate record from b911 table
  IF li_b911_val IS NOT INITIAL.
    SORT li_b911_val BY kappl
                        kschl
                        vkorg
                        bsark
                        kunre.
    DELETE ADJACENT DUPLICATES FROM li_b911_val
                               COMPARING kappl
                                         kschl
                                         vkorg
                                         bsark
                                         kunre.
    SELECT kappl kschl vkorg  zzbsark kunre
           FROM b911 " Sales org./PO type/Bill to
           INTO TABLE i_b911
           FOR ALL ENTRIES IN li_b911_val
           WHERE kappl EQ li_b911_val-kappl AND
                 kschl EQ li_b911_val-kschl AND
                 vkorg EQ li_b911_val-vkorg AND
                 zzbsark EQ li_b911_val-bsark AND
                 kunre EQ li_b911_val-kunre.
    IF sy-subrc EQ 0.
      SORT i_b911 BY kappl kschl vkorg bsark kunre.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_b911_val IS NOT INITIAL
*-- End of D2

  LOOP AT i_modify ASSIGNING <lfs_modify>.
    CLEAR lv_key.
    CONCATENATE    <lfs_modify>-keycombi
                   <lfs_modify>-kschl
                   <lfs_modify>-vkorg
                   <lfs_modify>-bsark "Added for D2
                   <lfs_modify>-kunre
                   <lfs_modify>-parvw
                   <lfs_modify>-parnr
                   <lfs_modify>-nacha
       INTO lv_key
       SEPARATED BY c_slash.
*    sales organization
    IF <lfs_modify>-vkorg IS NOT INITIAL.
      READ TABLE i_vkorg
           TRANSPORTING NO FIELDS
           WITH KEY vkorg = <lfs_modify>-vkorg
           BINARY SEARCH .
      IF sy-subrc NE 0 .
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Sales organization does not exist'(017)
                    <lfs_modify>-vkorg
                    INTO lv_msg SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        wa_error = <lfs_modify>.
        wa_error-errormsg = lv_msg.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF <lfs_modify>-vkorg IS NOT INITIAL
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Sales organization is mandatory'(005)
                  <lfs_modify>-vkorg
                  INTO lv_msg SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      wa_error = <lfs_modify>.
      wa_error-errormsg = lv_msg.
      APPEND wa_error TO i_error.
      CLEAR wa_error.
    ENDIF. " IF <lfs_modify>-vkorg IS NOT INITIAL
* customer number ( bill to party )
    IF <lfs_modify>-kunre IS NOT INITIAL.
      READ TABLE i_kunnr
           TRANSPORTING NO FIELDS
           WITH KEY kunnr = <lfs_modify>-kunre
           BINARY SEARCH .
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Bill to party does not exist'(019)
                    <lfs_modify>-kunre
                    INTO lv_msg
                    SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        wa_error = <lfs_modify>.
        wa_error-errormsg = lv_msg.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF <lfs_modify>-kunre IS NOT INITIAL
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Bill to party is mandatory'(006)
                  <lfs_modify>-kunre
                  INTO lv_msg
                  SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      wa_error = <lfs_modify>.
      wa_error-errormsg = lv_msg.
      APPEND wa_error TO i_error.
      CLEAR wa_error.
    ENDIF. " IF <lfs_modify>-kunre IS NOT INITIAL
*   Validate partner function
    IF NOT <lfs_modify>-parvw IS INITIAL.

*     Convert PArtner Function in the internal format
      CLEAR: lv_parvw.
      CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
        EXPORTING
          input  = <lfs_modify>-parvw
        IMPORTING
          output = lv_parvw.

      IF lv_parvw IS INITIAL.
        lv_parvw = <lfs_modify>-parvw.
      ENDIF. " IF lv_parvw IS INITIAL

*     Validate the partner function
      READ TABLE i_parvw
           TRANSPORTING NO FIELDS
           WITH KEY parvw = lv_parvw
           BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Partner function does not exist'(020)
                    <lfs_modify>-parvw
                    INTO lv_msg
                    SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        wa_error = <lfs_modify>.
        wa_error-errormsg = lv_msg.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF NOT <lfs_modify>-parvw IS INITIAL
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Partner function is mandatory'(010)
                  <lfs_modify>-parvw
                  INTO lv_msg
                  SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      wa_error = <lfs_modify>.
      wa_error-errormsg = lv_msg.
      APPEND wa_error TO i_error.
      CLEAR wa_error.
    ENDIF. " IF NOT <lfs_modify>-parvw IS INITIAL
*    billing type
    IF <lfs_modify>-fkart IS NOT INITIAL.
      READ TABLE i_fkart
           TRANSPORTING NO FIELDS
           WITH KEY fkart = <lfs_modify>-fkart
           BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Billing type does not exist'(021)
                    <lfs_modify>-fkart
                    INTO lv_msg
                    SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        wa_error = <lfs_modify>.
        wa_error-errormsg = lv_msg.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-fkart IS NOT INITIAL

*    condition type
    IF <lfs_modify>-kschl IS NOT INITIAL.
      READ TABLE i_kschl
           TRANSPORTING NO FIELDS
           WITH KEY kschl = <lfs_modify>-kschl
           BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Condition type does not exist'(022)
                    <lfs_modify>-kschl
                    INTO lv_msg
                    SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        wa_error = <lfs_modify>.
        wa_error-errormsg = lv_msg.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF <lfs_modify>-kschl IS NOT INITIAL
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Condition type is mandatory'(031)
                  <lfs_modify>-kschl
                  INTO lv_msg
                  SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      wa_error = <lfs_modify>.
      wa_error-errormsg = lv_msg.
      APPEND wa_error TO i_error.
      CLEAR wa_error.
    ENDIF. " IF <lfs_modify>-kschl IS NOT INITIAL

*-- Begin of D2
*    Purchase Order type
    IF <lfs_modify>-bsark IS NOT INITIAL.
      READ TABLE i_bsark
           TRANSPORTING NO FIELDS
           WITH KEY bsark = <lfs_modify>-bsark
           BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Purchase order type does not exist'(036)
                    <lfs_modify>-bsark
                    INTO lv_msg
                    SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        wa_error = <lfs_modify>.
        wa_error-errormsg = lv_msg.
        APPEND wa_error TO i_error.
        CLEAR wa_error.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_modify>-bsark IS NOT INITIAL
*-- End of D2

*  Validating condition record in table b905
    IF <lfs_modify>-keycombi EQ c_zrd0905 OR
         <lfs_modify>-keycombi EQ c_zrd0f905 OR
         <lfs_modify>-keycombi EQ c_zrd1905 OR
         <lfs_modify>-keycombi EQ c_z810905
* ---> Begin of Insert for D3_OTC_CDD_0069 By U033830
       OR <lfs_modify>-keycombi EQ c_zed1905
* ---> End of Insert for D3_OTC_CDD_0069 By U033830
* ---> Begin of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* Commenting the below hard-coded output types for E-Invoicing,
*   as they will be read from the EMI table
** ---> Begin of Insert for D3_Defect#6399 By mthatha
*       OR <lfs_modify>-keycombi EQ c_zein905
** ---> End of Insert for D3_Defect#6399 By mthatha
** ---> Begin of Insert for D3.R2_Defect#4204 By U033876
*          OR <lfs_modify>-keycombi EQ c_zedk905
*          OR <lfs_modify>-keycombi EQ c_zefi905
*          OR <lfs_modify>-keycombi EQ c_zeno905
*          OR <lfs_modify>-keycombi EQ c_zese905.
**<---- End of Insert for D3.R2_Defect#4204 By U033876
* <--- End   of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
     OR <lfs_modify>-keycombi IN i_einvoice_905.
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18

      IF ( <lfs_modify>-kschl IS NOT INITIAL ) AND
         ( <lfs_modify>-vkorg IS NOT INITIAL ) AND
         ( <lfs_modify>-kunre IS NOT INITIAL ).
        READ TABLE i_b905
             TRANSPORTING NO FIELDS
             WITH KEY kappl  = c_billing
                      kschl  = <lfs_modify>-kschl
                      vkorg  = <lfs_modify>-vkorg
                      fkart  = <lfs_modify>-fkart
                      kunre  = <lfs_modify>-kunre
             BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_error = c_true.
          wa_report-msgtyp = c_error.
          wa_report-msgtxt = 'Condition record already exists in b905 table'(032).
          wa_report-key = lv_key.
          APPEND wa_report TO i_report.
          CLEAR wa_report.
          wa_error = <lfs_modify>.
          wa_error-errormsg = 'Condition record already exists in b905 table'(032).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF ( <lfs_modify>-kschl IS NOT INITIAL ) AND
    ENDIF. " IF <lfs_modify>-keycombi EQ c_zrd0905 OR

*  validating condition record in table b906
    IF <lfs_modify>-keycombi EQ c_zrd0906 OR
       <lfs_modify>-keycombi EQ c_zrd0f906 OR
       <lfs_modify>-keycombi EQ c_zrd1906 OR
       <lfs_modify>-keycombi EQ c_z810906
* ---> Begin of Insert for D3_OTC_CDD_0069 By U033830
    OR <lfs_modify>-keycombi EQ c_zed1906
* ---> End of Insert for D3_OTC_CDD_0069 By U033830
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
     OR <lfs_modify>-keycombi IN i_einvoice_906.
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18

      IF ( <lfs_modify>-kschl IS NOT INITIAL ) AND
         ( <lfs_modify>-vkorg IS NOT INITIAL ) AND
         ( <lfs_modify>-kunre IS NOT INITIAL ).
* ---> Begin of Insert for Defect#5781 By mthatha
        SORT i_b906 BY kappl kschl vkorg kunre.
* ---> End of Insert for Defect#5781 By mthatha
        READ TABLE i_b906
             TRANSPORTING NO FIELDS
             WITH KEY kappl  = c_billing
                      kschl  = <lfs_modify>-kschl
                      vkorg  = <lfs_modify>-vkorg
                      kunre  = <lfs_modify>-kunre
             BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_error = c_true.
          wa_report-msgtyp = c_error.
          wa_report-msgtxt = 'Condition record already exists in b906 table'(033).
          wa_report-key = lv_key.
          APPEND wa_report TO i_report.
          CLEAR wa_report.
          wa_error = <lfs_modify>.
          wa_error-errormsg = 'Condition record already exists in b906 table'(033).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF ( <lfs_modify>-kschl IS NOT INITIAL ) AND
    ENDIF. " IF <lfs_modify>-keycombi EQ c_zrd0906 OR

*-- Begin of D2
*  validating condition record in table b911
    IF <lfs_modify>-keycombi EQ c_z810911.
* Required only for condition type Z810 in D3
* ---> Begin of Delete for D3_OTC_CDD_0069 By U033830
*      OR <lfs_modify>-keycombi EQ c_zrd1911 OR
*       <lfs_modify>-keycombi EQ c_zrd0f911 OR
*       <lfs_modify>-keycombi EQ c_zrd0911.
* ---> End of Delete for D3_OTC_CDD_0069 By U033830

      IF ( <lfs_modify>-kschl IS NOT INITIAL ) AND
         ( <lfs_modify>-vkorg IS NOT INITIAL ) AND
         ( <lfs_modify>-bsark IS NOT INITIAL ) AND
         ( <lfs_modify>-kunre IS NOT INITIAL ).
        READ TABLE i_b911
             TRANSPORTING NO FIELDS
             WITH KEY kappl  = c_billing
                      kschl  = <lfs_modify>-kschl
                      vkorg  = <lfs_modify>-vkorg
                      bsark  = <lfs_modify>-bsark
                      kunre  = <lfs_modify>-kunre
             BINARY SEARCH.
        IF sy-subrc EQ 0.
          lv_error = c_true.
          wa_report-msgtyp = c_error.
          wa_report-msgtxt = 'Condition record already exists in b911 table'(037).
          wa_report-key = lv_key.
          APPEND wa_report TO i_report.
          CLEAR wa_report.
          wa_error = <lfs_modify>.
          wa_error-errormsg = 'Condition record already exists in b911 table'(037).
          APPEND wa_error TO i_error.
          CLEAR wa_error.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF ( <lfs_modify>-kschl IS NOT INITIAL ) AND
    ENDIF. " IF <lfs_modify>-keycombi EQ c_z810911
*-- End of D2
*    validating message transmission medium,  mandatory field
    IF <lfs_modify>-nacha IS INITIAL.
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Message transmission medium is mandatory'(035)
                  <lfs_modify>-nacha
                  INTO lv_msg
                  SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      wa_error = <lfs_modify>.
      wa_error-errormsg = lv_msg.
      APPEND wa_error TO i_error.
      CLEAR wa_error.
    ENDIF. " IF <lfs_modify>-nacha IS INITIAL
*if error flag is not 'X' then the record is not in error
*so populating final internal table
    IF lv_error NE c_true.
*      IF rb_post IS INITIAL.
*    increasing success count
      gv_scount = gv_scount + 1.
      wa_report-msgtyp = c_success.
      wa_report-msgtxt = 'Record verified'(030).
      CONCATENATE <lfs_modify>-keycombi
                  <lfs_modify>-kschl
                  <lfs_modify>-vkorg
                  <lfs_modify>-bsark "Added for D2
                  <lfs_modify>-kunre
                  <lfs_modify>-parvw
                  <lfs_modify>-parnr
                  <lfs_modify>-nacha
                  INTO wa_report-key
                  SEPARATED BY c_slash.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
*      ENDIF.
*populating final table
      CLEAR wa_final.
      wa_final = <lfs_modify>.
      APPEND wa_final TO i_final.
      CLEAR wa_final.
    ELSE. " ELSE -> IF lv_error NE c_true
*    increasing error count
      gv_ecount = gv_ecount + 1.
    ENDIF. " IF lv_error NE c_true
    CLEAR lv_error.
  ENDLOOP. " LOOP AT i_modify ASSIGNING <lfs_modify>
ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_BDCRECORD_VV31
*&---------------------------------------------------------------------*
*       BDC Recording for VV31 tcode
*----------------------------------------------------------------------*
*      --> fp_i_final  TYPE ty_t_modify
*      <--fp_i_error   TYPE ty_t_error
*      <--fp_gv_ecount TYPE int2
*      <--fp_gv_scount TYPE int2
*      <--fp_i_report  TYPE ty_t_report.
*----------------------------------------------------------------------*
FORM f_bdcrecord_vv31  USING    fp_i_final   TYPE ty_t_modify
                       CHANGING fp_i_error   TYPE ty_t_error
                                fp_gv_ecount TYPE int2 " 2 byte integer (signed)
                                fp_gv_scount TYPE int2 " 2 byte integer (signed)
                                fp_i_report  TYPE ty_t_report.

  DATA:  lwa_error TYPE ty_modify_e. " Local work area for input file with error message

  FIELD-SYMBOLS:  <lfs_final>  TYPE ty_modify.

  IF fp_i_final[] IS NOT INITIAL.
    CALL FUNCTION 'BDC_OPEN_GROUP'
      EXPORTING
        client              = sy-mandt
        group               = c_session
        keep                = c_true
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
      MESSAGE i000 WITH 'Error in BDC Session'(023).
    ELSE. " ELSE -> IF sy-subrc <> 0
      LOOP AT fp_i_final ASSIGNING <lfs_final>.

        REFRESH i_bdcdata.
* if the keycombination field in file is ZRD0905
* zrdo denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button
* use ZRD0905 recording
        IF ( <lfs_final>-keycombi = c_zrd0905
*---Begin of Insert SCTASK0801088 by U104864 on 07-March-2019.
        OR  <lfs_final>-keycombi = c_zrd6905 ).
*---End of Insert SCTASK0801088 by U104864 on 07-March-2019.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.

          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl. "condition type
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.


          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*-- Begin of CR D2_385
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(01)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(02)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.

          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          ''.
*-- End of CR D2_385

*---Begin of delete SCTASK0801088 by U104864 on 07-March-2019.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)' "Comment Line
*---End of delete SCTASK0801088 by U104864 on 07-March-2019.

*---Begin of Insert SCTASK0801088 by U104864 on 07-March-2019.
*   Changes in KeyField Value from 'RV130-SELKZ(02) to 'RV130-SELKZ(01)
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*---End of Insert SCTASK0801088 by U104864 on 07-March-2019..
                                          'X'.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg. "sales organization
          PERFORM f_bdc_field       USING 'KOMB-FKART'
                                          <lfs_final>-fkart. "billing type

          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre. "bill to party
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw. "partner function
*************************************************************************
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                          <lfs_final>-parnr. "partner number
**************************************************************************
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha. "message transmission medium
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp. "dispatch time


          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                        'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                        '=MARL'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                        'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                        '=KOMM'.


          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-DIMME'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'NACH-LDEST'
                                          <lfs_final>-ldest.
          PERFORM f_bdc_field       USING 'NACH-DIMME'
                                          <lfs_final>-dimme.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.
* if the keycombination field in file is ZRD0906
* zrdo denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button
* use ZRD0906 recording

        ELSEIF ( <lfs_final>-keycombi = c_zrd0906
*---Begin of Insert SCTASK0801088 by U104864 on 07-March-2019..
          OR   <lfs_final>-keycombi = c_zrd2906             "'ZRD2906'.
          OR   <lfs_final>-keycombi = c_zrd6906 ).          "'ZRD6906'.
*---End of Insert SCTASK0801088 by U104864 on 07-March-2019..
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*-- Begin of CR D2_385
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(02)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*                                          ''.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
*                                          'X'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(03)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          ''.
*-- End of CR D2_385
*---Begin of Delete SCTASK0801088 by U104864 on 07-March-2019..
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'"Comment Line
*---End of Delete SCTASK0801088 by U104864 on 07-March-2019..

*---Begin of Insert SCTASK0801088 by U104864 on 07-March-2019..
*   Changes in KeyField Value from 'RV130-SELKZ(03) to 'RV130-SELKZ(02)
          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
*---End of Insert SCTASK0801088 by U104864 on 07-March-2019..
                                          'X'.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
***************************************************************************************
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                         <lfs_final>-parnr.

****************************************************************************************
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.


          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=MARL'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=KOMM'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-DIMME'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'NACH-LDEST'
                                          <lfs_final>-ldest.
          PERFORM f_bdc_field       USING 'NACH-DIMME'
                                          <lfs_final>-dimme.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

* if the keycombination field in file is ZRD0F905
* zrdo denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button
* use ZRD0F905 recording
        ELSEIF <lfs_final>-keycombi = c_zrd0f905.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=ANTA'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*-- Begin of CR D2_385
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(01)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(02)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          ''.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                          'X'.
*-- End of CR D2_385

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.

          PERFORM f_bdc_field       USING 'KOMB-FKART'
                                          <lfs_final>-fkart.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.

          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
***************************************************************************
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                           <lfs_final>-parnr.

***************************************************************************
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.

          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=MARL'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=KOMM'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-TDSCHEDULE'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'NACH-OBJTYPE'
*                                          '23096'. " rnathak 08/09
                                           ''. "rnathak 08/09
          PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                           <lfs_final>-tdschedule.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

* if the keycombination field in file is ZRD0F906
* zrdo denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button
* use ZRD0F906 recording

        ELSEIF <lfs_final>-keycombi = c_zrd0f906.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=ANTA'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
*                                         'ZRD0'.
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*-- Begin of CR D2_385
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(02)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*                                          ''.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
*                                          'X'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(03)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          ''.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
                                          'X'.
*-- End of CR D2_385

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.

          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
***********************************************************************
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                         <lfs_final>-parnr.

*************************************************************************
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=MARL'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=KOMM'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-TDSCHEDULE'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'NACH-OBJTYPE'
*                                          '23096'. " rnathak 08/09
                                           ''. "rnathak 08/09
          PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                          <lfs_final>-tdschedule.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-OBJTYPE'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'NACH-OBJTYPE'
*                                          '23096'. " rnathak 08/09
                                           ''. "rnathak 08/09
          PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
                                          'IMM'.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

* if the keycombination field in file is ZRD1905
* zrd1 denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button
* use ZRD1905 recording
        ELSEIF ( <lfs_final>-keycombi = c_zrd1905 ).
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.
          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-FKART'
                                          <lfs_final>-fkart.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
*******************************************************************
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                          <lfs_final>-parnr.

********************************************************************
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=MARL'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=KOMM'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-LDEST'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'NACH-TCODE'
                                          <lfs_final>-tcode.
          PERFORM f_bdc_field       USING 'NACH-LDEST'
                                          <lfs_final>-ldest.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-TCODE'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'NACH-TCODE'
                                          <lfs_final>-tcode.
          PERFORM f_bdc_field       USING 'NACH-LDEST'
                                          <lfs_final>-ldest.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

* if the keycombination field in file is ZRD1906
* zrd1 denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button
* use ZRD1906 recording
        ELSEIF <lfs_final>-keycombi = c_zrd1906.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

*--Begin of comment for Defect#5781 mthatha
*          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(02)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
*                                          ''.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
*                                          'X'.
*--End of comment for Defect#5781 mthatha
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
*********************************************************************
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                          <lfs_final>-parnr.
*********************************************************************
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=MARL'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=KOMM'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-LDEST'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'NACH-TCODE'
                                          <lfs_final>-tcode.
          PERFORM f_bdc_field       USING 'NACH-LDEST'
                                           <lfs_final>-ldest.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-TCODE'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'NACH-TCODE'
                                          <lfs_final>-tcode.
          PERFORM f_bdc_field       USING 'NACH-LDEST'
                                           <lfs_final>-ldest.
          PERFORM f_bdc_field       USING 'NACH-TDARMOD'
                                          <lfs_final>-tdarmod.

* if the keycombination field in file is Z810905
* z810 denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button )
* use Z810905 recording
        ELSEIF <lfs_final>-keycombi = c_z810905.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
***************         CR # 106
*-- Begin of CR D2_385
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(03)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
*                                          ''.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(03)'
*                                          'X'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          ''.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          'X'.
*-- End of CR D2_385
***************        CR # 106
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-FKART'
                                          <lfs_final>-fkart.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
*                                          'E1DCLNT300'.
                                          <lfs_final>-parnr.
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.

* if the keycombination field in file is Z810906
* z810 denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button )
* use Z810906 recording
        ELSEIF <lfs_final>-keycombi = c_z810906.
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
********        CR # 106
*-- Begin of CR D2_385
*          PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                          'RV130-SELKZ(04)'.
*          PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                          '=WEIT'.
*
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
*                                          ''.
*          PERFORM f_bdc_field       USING 'RV130-SELKZ(04)'
*                                          'X'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(02)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.

          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                          ''.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                          'X'.
*-- End of CR D2_385
*********       CR # 106
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
*                                          'E1DCLNT300'.
                                          <lfs_final>-parnr.
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'KOMB-KUNRE(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.

**-- Begin of D2
        ELSEIF  <lfs_final>-keycombi = c_z810911.

* ---> Begin of Delete for D3_OTC_CDD_0069 By U033830
* Recodrdings ZRD1911,ZRD0f911,ZRD0911 not needed for D3
*               <lfs_final>-keycombi = c_zrd1911 OR
*               <lfs_final>-keycombi = c_zrd0f911 OR
*               <lfs_final>-keycombi = c_zrd0911 OR
* ---> End of Delete for D3_OTC_CDD_0069 By U033830

*-- Initial screen
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.

          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                           '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.
          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.
*-- Conditions screen
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1911'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-VSZTP(01)'.

* ---> Begin of change for D3_OTC_CDD_0069 By U033830

*          IF <lfs_final>-keycombi = c_z810911.
*            PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                            '=SICH'.
*          ELSE. " ELSE -> IF <lfs_final>-keycombi = c_z810911
*            PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                            '=KOMM'.
*          ENDIF. " IF <lfs_final>-keycombi = c_z810911

          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                            '=SICH'.
* ---> End of change for D3_OTC_CDD_0069 By U033830

          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-ZZBSARK'
                                          <lfs_final>-bsark.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                           <lfs_final>-parnr.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

* ---> Begin of Delete for D3_OTC_CDD_0069 By U033830

**-- Communication screen
*          IF <lfs_final>-keycombi = c_zrd1911.
*            PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0235'.
*            PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                            'NACH-TDARMOD'.
*            PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                            '=SICH'.
*            PERFORM f_bdc_field       USING 'NACH-TCODE'
*                                            <lfs_final>-tcode.
*            PERFORM f_bdc_field       USING 'NACH-LDEST'
*                                            <lfs_final>-ldest.
*            PERFORM f_bdc_field       USING 'NACH-TDARMOD'
*                                            <lfs_final>-tdarmod.
*
*          ELSEIF <lfs_final>-keycombi = c_zrd0f911.
*            PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0233'.
*            PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                            'NACH-DIMME'.
*            PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                            '=SICH'.
*            PERFORM f_bdc_field       USING 'NACH-TDARMOD'
*                                            <lfs_final>-tdarmod.
*            PERFORM f_bdc_field       USING 'NACH-TDSCHEDULE'
*                                            <lfs_final>-tdschedule.
*            PERFORM f_bdc_field       USING 'NACH-DIMME'
*                                            <lfs_final>-dimme.
*          ELSEIF <lfs_final>-keycombi = c_zrd0911.
*            PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0211'.
*            PERFORM f_bdc_field       USING 'BDC_CURSOR'
*                                            'NACH-DIMME'.
*            PERFORM f_bdc_field       USING 'BDC_OKCODE'
*                                            '=SICH'.
*            PERFORM f_bdc_field       USING 'NACH-LDEST'
*                                            <lfs_final>-ldest.
*            PERFORM f_bdc_field       USING 'NACH-DIMME'
*                                            <lfs_final>-dimme.
*            PERFORM f_bdc_field       USING 'NACH-TDARMOD'
*                                            <lfs_final>-tdarmod.
*          ENDIF. " IF <lfs_final>-keycombi = c_zrd1911
**-- End of D2

* ---> End of Delete for D3_OTC_CDD_0069 By U033830

* ---> Begin of Insert for D3_OTC_CDD_0069 By U033830

* if the keycombination field in file is ZED1905
* ZED1 denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button )
* use ZED1905 recording
        ELSEIF <lfs_final>-keycombi = c_zed1905
* ---> Begin of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* Commenting the below hard-coded output types for E-Invoicing,
*   as they will be read from the EMI table
** ---> Begin of Insert for D3_Defect#6399 By mthatha
*          OR <lfs_final>-keycombi = c_zein905
** ---> End of Insert for D3_Defect#6399 By mthatha
** ---> Begin of Insert for D3.R2_Defect#4204 By U033876
*          OR <lfs_final>-keycombi EQ c_zedk905
*          OR <lfs_final>-keycombi EQ c_zefi905
*          OR <lfs_final>-keycombi EQ c_zeno905
*          OR <lfs_final>-keycombi EQ c_zese905.
**<---- End of Insert for D3.R2_Defect#4204 By U033876
* <--- End   of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
     OR <lfs_final>-keycombi IN i_einvoice_905.
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.

          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1905'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-SPRAS(01)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.
          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.
          PERFORM f_bdc_field       USING 'KOMB-FKART'
                                          <lfs_final>-fkart.
          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.
          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.
          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                          <lfs_final>-parnr.
          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.
          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

* if the keycombination field in file is ZED1906 or ZEIN906
* ZED1,ZEIN denotes condition type
* 905 denotes sales org, bill type, bill to radio button
* 906 denotes sales org , bill to  radio button )
* use ZED1906 recording
        ELSEIF <lfs_final>-keycombi = c_zed1906
* ---> Begin of Change for D3R3_Defect_4204 by U034334 on 21-02-18
* Commenting the below hard-coded output types for E-Invoicing,
*  as they will be read from the EMI table
*          OR <lfs_final>-keycombi = c_zein906.
     OR <lfs_final>-keycombi IN i_einvoice_906.
* <--- End   of Change for D3R3_Defect_4204 by U034334 on 21-02-18

          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '0100'.
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV13B-KSCHL'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '/00'.
          PERFORM f_bdc_field       USING 'RV13B-KSCHL'
                                          <lfs_final>-kschl.

          PERFORM f_bdc_dynpro      USING 'SAPLV14A' '0100'.

* ---> Begin of Insert for D3_Defect#6399 By mthatha
*          if <lfs_final>-keycombi = c_zein906.
*            perform f_bdc_field       using 'BDC_CURSOR'
*                                            'RV130-SELKZ(01)'.
*            perform f_bdc_field       using 'BDC_OKCODE'
*                                            '=WEIT'.
*          else. " ELSE -> if <lfs_final>-keycombi = c_zein906
* ---> End of Insert for D3_Defect#6399 By mthatha
          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'RV130-SELKZ(02)'.
          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=WEIT'.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(01)'
                                          ''.
          PERFORM f_bdc_field       USING 'RV130-SELKZ(02)'
                                          'X'.
* ---> Begin of Insert for D3_Defect#6399 By mthatha
*          endif. " if <lfs_final>-keycombi = c_zein906
* ---> End of Insert for D3_Defect#6399 By mthatha
          PERFORM f_bdc_dynpro      USING 'SAPMV13B' '1906'.

          PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                          'NACH-SPRAS(01)'.

          PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                          '=SICH'.

          PERFORM f_bdc_field       USING 'KOMB-VKORG'
                                          <lfs_final>-vkorg.

          PERFORM f_bdc_field       USING 'KOMB-KUNRE(01)'
                                          <lfs_final>-kunre.

          PERFORM f_bdc_field       USING 'NACH-PARVW(01)'
                                          <lfs_final>-parvw.

          PERFORM f_bdc_field       USING 'RV13B-PARNR(01)'
                                          <lfs_final>-parnr.

          PERFORM f_bdc_field       USING 'NACH-NACHA(01)'
                                          <lfs_final>-nacha.

          PERFORM f_bdc_field       USING 'NACH-VSZTP(01)'
                                          <lfs_final>-vsztp.

* ---> End of Insert for D3_OTC_CDD_0069 By U033830

        ENDIF. " IF <lfs_final>-keycombi = c_zrd0905

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
*write  an error message to i_report with the header record.
          MOVE <lfs_final> TO lwa_error.
*               Writing error message if insertion fails.
          CONCATENATE
          'BDC insert failed for key combination'(024) " Synchronization key
          <lfs_final>-keycombi
          INTO lwa_error-errormsg SEPARATED BY space.
          APPEND lwa_error TO fp_i_error.
          fp_gv_ecount = fp_gv_ecount + 1.
          fp_gv_scount = fp_gv_scount - 1.
* Report update
          wa_report-key    = <lfs_final>-keycombi.
          wa_report-msgtyp = c_error.
          wa_report-msgtxt =
          'BDC insert failed for key combination'(024). " Synchronization key
          APPEND wa_report TO fp_i_report.
          CLEAR wa_report.
        ENDIF. " IF sy-subrc <> 0

      ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

      CALL FUNCTION 'BDC_CLOSE_GROUP'
        EXCEPTIONS
          not_open    = 1
          queue_error = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        CLEAR wa_report.
        MESSAGE i000 WITH 'Error in BDC Session'(023) INTO
        wa_report-msgtxt.
        wa_report-msgtyp = c_error.
        APPEND wa_report TO fp_i_report.
      ELSE. " ELSE -> IF sy-subrc <> 0
* Forming the session name
        gv_session_gl_1 = c_session.
      ENDIF. " IF sy-subrc <> 0

    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF fp_i_final[] IS NOT INITIAL
ENDFORM. " F_BDCRECORD_VV31
*&---------------------------------------------------------------------*
*&      Form  f_bdc_dynpro
*&---------------------------------------------------------------------*
*       This is used for populating program name and screen number
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM        BDC Program Name
*      -->FP_V_DYNPRO         BDC Screen Dynpro No.
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
ENDFORM. " f_bdc_dynpro
*&---------------------------------------------------------------------*
*&      Form  F_bdc_field
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any.
* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
  IF NOT fp_v_fval IS INITIAL.
    CLEAR lwa_bdcdata.
    lwa_bdcdata-fnam = fp_v_fnam.
    lwa_bdcdata-fval = fp_v_fval.
    APPEND lwa_bdcdata TO i_bdcdata.
  ENDIF. " IF NOT fp_v_fval IS INITIAL
ENDFORM. " f_bdc_field
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_VALUES
*&---------------------------------------------------------------------*
*       Get constant values from the EMI table
*----------------------------------------------------------------------*
*      <--FP_I_EMI       Internal table for EMI values
*----------------------------------------------------------------------*
FORM f_get_emi_values CHANGING fp_i_emi TYPE ty_t_emi .
  CONSTANTS: lc_cdd_no TYPE z_enhancement  VALUE 'OTC_CDD_0069'. " Enhancement No.

* Retrieve the constants values from EMI table
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_cdd_no
    TABLES
      tt_enh_status     = fp_i_emi.

  DELETE fp_i_emi WHERE active = abap_false.
ENDFORM. "f_get_emi_values
*&---------------------------------------------------------------------*
*&      Form  F_EMI_VALIDATION
*&---------------------------------------------------------------------*
*       Validations based on entries maintained in EMI table
*----------------------------------------------------------------------*
*      -->FP_I_EMI           Internal table for EMI values
*      <--FP_I_EINV_905      E-invoice Output Types for B905
*      <--FP_I_EINV_906      E-invoice Output Types for B906
*----------------------------------------------------------------------*
FORM f_emi_validation USING fp_i_emi TYPE ty_t_emi
                   CHANGING fp_i_einv_905 TYPE ty_t_einvoice
                            fp_i_einv_906 TYPE ty_t_einvoice.

  CONSTANTS: lc_e_inv_905 TYPE z_criteria  VALUE 'E_INV_OUTPUT_905', " E-Inv Output types for B905
             lc_e_inv_906 TYPE z_criteria  VALUE 'E_INV_OUTPUT_906'. " E-Inv Output types for B906
  DATA : lwa_emi   TYPE zdev_enh_status, " Enhancement Status
         lwa_range TYPE selopt.          " Transfer Structure for Select Options

  LOOP AT fp_i_emi INTO lwa_emi.
    CASE lwa_emi-criteria.
      WHEN lc_e_inv_905.
        lwa_range-sign   =  lwa_emi-sel_sign.
        lwa_range-option =  lwa_emi-sel_option.
        CONCATENATE lwa_emi-sel_low lwa_emi-sel_high+1(3) INTO lwa_range-low.
        APPEND lwa_range TO fp_i_einv_905.
        CLEAR lwa_range.
      WHEN lc_e_inv_906.
        lwa_range-sign   =  lwa_emi-sel_sign.
        lwa_range-option =  lwa_emi-sel_option.
        CONCATENATE lwa_emi-sel_low lwa_emi-sel_high+1(3) INTO lwa_range-low.
        APPEND lwa_range TO fp_i_einv_906.
        CLEAR lwa_range.
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP. " LOOP AT fp_i_emi INTO lwa_emi
ENDFORM. " F_GET_EMI_VALUES
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
