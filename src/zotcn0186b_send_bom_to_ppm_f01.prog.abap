*&---------------------------------------------------------------------*
*&  Include           ZOTCN0186B_SEND_BOM_TO_PPM_F01
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0186B_SEND_BOM_TO_PPM                             *
* TITLE      :  D2_OTC_IDD_0186_Send Sales BOM structure to PPM        *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0186_Send Sales BOM structure to PPM             *
*----------------------------------------------------------------------*
* DESCRIPTION: The requirement is to send the BOM structure from SAP   *
* to PPM. From each Plant valid BOMs as on date will be extracted and  *
* stored in a flat file. This file subsequently will be uploaded to PPM*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Sep-2014 MBAGDA   E2DK914957 Defect 1089: To remove the decimal   *
*                                 part of Quantity                     *
* 25-Sep-2014 MBAGDA   E2DK914957 Defect 1089: To populate Header      *
*                                 Material Number in file              *
* 15-Sep-2014 SGHOSH   E2DK914957 PGL- INITIAL DEVELOPMENT -           *
*                                 Task Number: E2DK915243,E2DK915041   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_PHDR
*&---------------------------------------------------------------------*
*      validating Presentation File Name
*----------------------------------------------------------------------*
*      -->FP_P_PHDR           Input file name
*----------------------------------------------------------------------*
FORM f_validate_phdr  USING    fp_p_phdr TYPE localfile. " Local file for upload/download

*&--Local Data Declaration
  DATA:
    lv_result TYPE abap_bool, "Result
    lv_file   TYPE string,    "File Name
    lv_n1     TYPE syfdpos,   "Offset location in string
    lv_n2     TYPE syfdpos.   "Offset location in string

*&--Get directiry path
  DO.
    IF sy-index GT 1.
      lv_n1 = lv_n2 + lv_n1 + 1.
    ENDIF. " IF sy-index GT 1
    IF fp_p_phdr+lv_n1 CA c_bslash.
      lv_n2 = sy-fdpos.
    ELSE. " ELSE -> IF fp_p_phdr+lv_n1 CA c_bslash
      lv_file = fp_p_phdr+0(lv_n1).
      EXIT.
    ENDIF. " IF fp_p_phdr+lv_n1 CA c_bslash
  ENDDO.

*&--Check if directory exist or not
  CALL METHOD cl_gui_frontend_services=>directory_exist
    EXPORTING
      directory            = lv_file
    RECEIVING
      result               = lv_result
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      wrong_parameter      = 3
      not_supported_by_gui = 4
      OTHERS               = 5.

*&--If method failed to execute or directory does not exist
  IF sy-subrc IS NOT INITIAL OR
     lv_result IS INITIAL.
*&--If executed foreground than raise an error message
*     Invalid file name. Please check your entry.
    MESSAGE e002(zca_msg). " Invalid file name. Please check your entry.
  ENDIF. " IF sy-subrc IS NOT INITIAL OR
ENDFORM. " F_VALIDATE_PHDR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*       Validating Plant
*----------------------------------------------------------------------*
FORM f_validate_werks .

*&--Local Data Declaration
  DATA: lv_werks TYPE werks_d. " Plant

  SELECT werks   " Plant
      FROM t001w " Plants/Branches
      INTO lv_werks
      UP TO 1 ROWS
      WHERE werks IN s_werks.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE e987. " Plant is invalid.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATE_WERKS
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Subroutine to modify the screen
*----------------------------------------------------------------------*
FORM f_modify_screen .

  LOOP AT SCREEN.
    IF screen-group1 = c_mi4.
      screen-input = c_zero.
      MODIFY SCREEN.
    ENDIF. " IF screen-group1 = c_mi4
    IF rb_fore EQ abap_true.
      IF rb_pres EQ abap_true.
        CLEAR: p_ahdr,p_ahdr1.
        IF screen-group1 = c_mi6
          OR screen-group1 = c_mi9.
          screen-active = c_zero.
          screen-input = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_mi6
      ELSEIF rb_app EQ abap_true.
        CLEAR: p_ahdr1,p_phdr.
        IF screen-group1 = c_mi3
          OR screen-group1 = c_mi9.
          screen-active = c_zero.
          screen-input = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_mi3
        p_ahdr = gv_pfile.
        IF screen-name = c_file_f.
          screen-input = c_zero.
          MODIFY SCREEN.
        ENDIF. " IF screen-name = c_file_f
      ELSEIF rb_pres NE abap_true
        AND rb_app NE abap_true.
        rb_pres = abap_true.
        CLEAR: p_ahdr,p_ahdr1.
      ENDIF. " IF rb_pres EQ abap_true
    ELSEIF rb_back EQ abap_true.
      CLEAR: p_ahdr,p_phdr,rb_pres,rb_app.
      IF  screen-group1 = c_mi3
       OR screen-group1 = c_mi2
       OR screen-group1 = c_mi6.
        screen-active = c_zero.
        screen-input = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_mi3
      p_ahdr1 = gv_pfile.
      IF screen-name = c_file_b.
        screen-input = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-name = c_file_b
    ENDIF. " IF rb_fore EQ abap_true
  ENDLOOP. " LOOP AT SCREEN

ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_DATA_EMI
*&---------------------------------------------------------------------*
*       Retrieve Data from EMI
*----------------------------------------------------------------------*
*      <--FP_GV_FILE    Filename
*      <--FP_GV_PFILE   Filepath
*----------------------------------------------------------------------*
FORM f_retrieve_data_emi  CHANGING fp_gv_file TYPE char50     " Retrieve_data_emi chang of type CHAR50
                                   fp_gv_pfile TYPE localfile " Local file for upload/download
                                   fp_gv_bomtyp TYPE stlan.   " BOM Usage

*&--Local Data Declaration
  CONSTANTS: lc_enh_name TYPE z_enhancement VALUE 'D2_OTC_IDD_0186', " Enhancement No.
             lc_filename TYPE z_criteria VALUE 'Z_FILENAME',         " Enh. Criteria
             lc_filepath TYPE z_criteria VALUE 'Z_FILEPATH',         " Enh. Criteria
             lc_bomtyp   TYPE z_criteria VALUE 'Z_BOMTYP',           " Enh. Criteria
             lc_appl  TYPE char07 VALUE '/appl/'.                    " Appl of type CHAR07

  DATA: li_constant TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0. " Enhancement Status
  FIELD-SYMBOLS: <lfs_constant> TYPE zdev_enh_status. " Enhancement Status

*&--Function Module to retrieve data from EMI
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_name
    TABLES
      tt_enh_status     = li_constant.
*&--Delete inactive entries
  DELETE li_constant WHERE active = space.
  IF li_constant IS NOT INITIAL.
*&--Read filename
    READ TABLE li_constant ASSIGNING <lfs_constant> WITH KEY criteria = lc_filename.
    IF sy-subrc IS INITIAL .
      fp_gv_file = <lfs_constant>-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL
*&--Read filepath
    READ TABLE li_constant ASSIGNING <lfs_constant> WITH KEY criteria = lc_filepath.
    IF sy-subrc IS INITIAL .
      CONCATENATE lc_appl sy-sysid <lfs_constant>-sel_low fp_gv_file c_extn1 INTO fp_gv_pfile.
      CONDENSE fp_gv_pfile.
    ENDIF. " IF sy-subrc IS INITIAL
*&--Read BOM Usage
    READ TABLE li_constant ASSIGNING <lfs_constant> WITH KEY criteria = lc_bomtyp.
    IF sy-subrc IS INITIAL .
      fp_gv_bomtyp = <lfs_constant>-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF li_constant IS NOT INITIAL
ENDFORM. " F_RETRIEVE_DATA_EMI
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Check Selection Screen Input
*----------------------------------------------------------------------*
*  <--  FP_I_MAST        Internal Table
*----------------------------------------------------------------------*
FORM f_check_input CHANGING fp_i_mast TYPE ty_t_mast.
*&--Select without WHERE condition has been used as per onsite suggestion
* as neither full primary key was available nor any index can be utilized.
  SELECT matnr " Material Number
         werks " Plant
         stlan " BOM Usage
    FROM mast  " Material to BOM Link
    INTO TABLE fp_i_mast.
  IF sy-subrc EQ 0.
*&--Filtering based on selection field criteria
    DELETE fp_i_mast WHERE werks NOT IN s_werks.
    DELETE fp_i_mast WHERE stlan NE p_bomtyp.
    IF fp_i_mast IS NOT INITIAL.
      SORT fp_i_mast BY matnr werks.
      DELETE ADJACENT DUPLICATES FROM fp_i_mast COMPARING matnr werks.
    ELSE. " ELSE -> IF fp_i_mast IS NOT INITIAL
      MESSAGE e178.
    ENDIF. " IF fp_i_mast IS NOT INITIAL
  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_BOM_DATA
*&---------------------------------------------------------------------*
*       Retrieve BOM Data
*----------------------------------------------------------------------*
*      -->FP_I_MAST      Internal Table for MAST
*      <--FP_I_FINAL     Final Internal Table
*----------------------------------------------------------------------*
FORM f_retrieve_bom_data  USING    fp_i_mast TYPE ty_t_mast
                          CHANGING fp_i_final TYPE ty_t_final.

*&--Local Data Declaration
  DATA: lwa_final TYPE ty_final,
        li_stb       TYPE STANDARD TABLE OF stpox INITIAL SIZE 0, " BOM Items (Extended for List Displays)
        li_stb_final TYPE STANDARD TABLE OF stpox INITIAL SIZE 0. " BOM Items (Extended for List Displays)
  FIELD-SYMBOLS: <lfs_mast> TYPE ty_mast,
                 <lfs_stb> TYPE stpox. " BOM Items (Extended for List Displays)


  LOOP AT fp_i_mast ASSIGNING <lfs_mast>.
*&--Retrieve BOM Data
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        capid                 = space
        datuv                 = p_vdate
        mktls                 = abap_true
        mehrs                 = abap_true
        mtnrv                 = <lfs_mast>-matnr
        stlan                 = p_bomtyp
        stpst                 = 0
        svwvo                 = abap_true
        werks                 = <lfs_mast>-werks
        vrsvo                 = abap_true
      TABLES
        stb                   = li_stb
      EXCEPTIONS
        alt_not_found         = 1
        call_invalid          = 2
        material_not_found    = 3
        missing_authorization = 4
        no_bom_found          = 5
        no_plant_data         = 6
        no_suitable_bom_found = 7
        conversion_error      = 8
        OTHERS                = 9.
    IF sy-subrc = 0.
* ----> Begin of changes for Defect# 1089 by MBAGDA on 25-Sep-2015
*     APPEND LINES OF li_stb TO li_stb_final.  "DELETE
*&--Populate Final Table
      LOOP AT li_stb ASSIGNING <lfs_stb>.
        lwa_final-matnr = <lfs_mast>-matnr. " Material Number
        lwa_final-idnrk = <lfs_stb>-idnrk. " BOM component
*       lwa_final-stlkn = <lfs_stb>-stlkn. " BOM item node number
        lwa_final-posnr = <lfs_stb>-posnr. " BOM item node number
        lwa_final-datuv = <lfs_stb>-datuv. " Valid-from/to date
        lwa_final-datub = <lfs_stb>-datub. " Valid-to date
        lwa_final-menge = <lfs_stb>-menge. " Component quantity
        lwa_final-werks = <lfs_stb>-werks. " Plant
        APPEND lwa_final TO fp_i_final.
        CLEAR lwa_final.
      ENDLOOP. " LOOP AT li_stb ASSIGNING <lfs_stb>
* <---- End of changes for Defect# 1089 by MBAGDA on 25-Sep-2015
      CLEAR li_stb.
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT fp_i_mast ASSIGNING <lfs_mast>

* ----> Begin of changes for Defect# 1089 by MBAGDA on 25-Sep-2015
*  IF li_stb_final IS NOT INITIAL.
**&--Populate Final Table
*    LOOP AT li_stb_final ASSIGNING <lfs_stb>.
*      lwa_final-matnr = <lfs_stb>-ojtxb. " Material Number
*      lwa_final-idnrk = <lfs_stb>-idnrk. " BOM component
*      lwa_final-stlkn = <lfs_stb>-stlkn. " BOM item node number
*      lwa_final-datuv = <lfs_stb>-datuv. " Valid-from/to date
*      lwa_final-datub = <lfs_stb>-datub. " Valid-to date
*      lwa_final-menge = <lfs_stb>-menge. " Component quantity
*      lwa_final-werks = <lfs_stb>-werks. " Plant
*      APPEND lwa_final TO fp_i_final.
*      CLEAR lwa_final.
*    ENDLOOP. " LOOP AT li_stb_final ASSIGNING <lfs_stb>
* ELSE. " ELSE -> IF li_stb_final IS NOT INITIAL
  IF fp_i_final IS INITIAL.
*   MESSAGE e178.
    MESSAGE s178.
* <---- End of changes for Defect# 1089 by MBAGDA on 25-Sep-2015
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_final IS INITIAL
ENDFORM. " F_RETRIEVE_BOM_DATA
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_APP_DATA
*&---------------------------------------------------------------------*
*       Write Data in Application Directory File
*----------------------------------------------------------------------*
*      -->FP_GV_FILEPATH  File Path
*      -->FP_I_FINAL      Final Internal Table
*      <--FP_I_LOG        Log Table
*----------------------------------------------------------------------*
FORM f_write_app_data  USING fp_gv_filepath TYPE localfile " Local file for upload/download
                             fp_i_final TYPE ty_t_final
                       CHANGING fp_i_log TYPE ty_t_log.

*&--Local Data Declaration
  DATA:
        lwa_log       TYPE ty_log,  " Log Data
        lv_data       TYPE string,
        lv_len        TYPE i,       " Len of type Integers
        lv_menge      TYPE char20,  " Menge of type CHAR20
        lv_string     TYPE char256, " String of type CHAR256
        lv_count      TYPE sytabix. " Records Count

  FIELD-SYMBOLS: <lfs_final>    TYPE ty_final.

* && -- Open dataset to read
  OPEN DATASET fp_gv_filepath FOR INPUT IN TEXT MODE ENCODING DEFAULT IGNORING CONVERSION ERRORS. " Set as Ready for Input
  IF sy-subrc IS INITIAL.
*&--Read application directory file
    READ DATASET fp_gv_filepath INTO lv_string ACTUAL LENGTH lv_len.
    IF sy-subrc IS INITIAL.
      IF lv_string IS NOT INITIAL.
*&--If data already exist in the file message will be displayed
        lwa_log-msgtyp = c_msgtyp_i.
        lwa_log-msgtxt = 'Existing file has been overwritten.'(021).
        CONDENSE lwa_log-msgtxt.
        APPEND lwa_log TO fp_i_log.
        CLEAR lwa_log.
      ENDIF. " IF lv_string IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
*&--Close dataset
  CLOSE DATASET fp_gv_filepath.

* && -- Open dataset to write
  OPEN DATASET fp_gv_filepath FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc IS INITIAL.

    LOOP AT fp_i_final ASSIGNING <lfs_final>.
      CLEAR: lv_data,
             lv_menge.
* ----> Begin of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
* Remove the decimal part of the Quantity
*     lv_menge = <lfs_final>-menge.   "DELETE
*     CONDENSE lv_menge.              "DELETE
      lv_menge = trunc( <lfs_final>-menge ).
      CONDENSE lv_menge NO-GAPS.
* <---- End of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
*&--Write pipe delimited file in application directory
      CONCATENATE <lfs_final>-matnr
                  <lfs_final>-idnrk
* ----> Begin of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
*                 <lfs_final>-stlkn  "DELETE
                  <lfs_final>-posnr "INSERT
* <---- End of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
                  <lfs_final>-datuv
                  <lfs_final>-datub
                  lv_menge
                  <lfs_final>-werks
                  INTO lv_data
                  SEPARATED BY c_pipe.
*&--Transfer string data to application file
      TRANSFER lv_data TO fp_gv_filepath.
    ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

*&--Calculate the number of records written in file
    DESCRIBE TABLE fp_i_final LINES lv_count.

    WRITE lv_count TO lwa_log-msgtxt.
    CONDENSE lwa_log-msgtxt.

*&--Populate Log table for success message
    lwa_log-msgtyp = c_msgtyp_s.
    CONCATENATE lwa_log-msgtxt
                'number of records written.'(013)
                INTO lwa_log-msgtxt
                SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.

    lwa_log-msgtyp = c_msgtyp_s.
    CLEAR lv_count.
    lv_count = strlen( fp_gv_filepath ).
    CONCATENATE 'File written at'(014)
                fp_gv_filepath+0(lv_count)
                INTO lwa_log-msgtxt
                SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL

*&--Populate Log table with error message
    lwa_log-msgtyp = c_msgtyp_e.
    lwa_log-msgtxt = 'Error in creating file.'(015).
    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ENDIF. " IF sy-subrc IS INITIAL

*&--Close dataset
  CLOSE DATASET fp_gv_filepath.

ENDFORM. " F_WRITE_APP_DATA
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_PRES_DATA
*&---------------------------------------------------------------------*
*       Write Data in Presentation Server
*----------------------------------------------------------------------*
*      -->FP_I_FINAL   Final Internal Table
*      <--FP_P_PHDR    File Path
*      <--FP_I_DATA    Data Table
*      <--FP_I_LOG     Log Table
*----------------------------------------------------------------------*
FORM f_write_pres_data  USING fp_i_final TYPE ty_t_final
                        CHANGING fp_p_phdr TYPE localfile " Local file for upload/download
                                 fp_i_data TYPE ty_t_data
                                 fp_i_log  TYPE ty_t_log.

*&--Local Data Declaration
  DATA:
        lwa_log     TYPE ty_log,  " Log Data
        lwa_data    TYPE ty_data, " Pipe delimited data
        lv_filename TYPE string,  " File Name
        lv_data     TYPE string,  " Data
        lv_menge    TYPE char20,  " Menge of type CHAR20
        lv_count    TYPE sytabix. " Record Count

  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

  IF fp_p_phdr IS NOT INITIAL.
*&--Populate file name
    lv_filename = fp_p_phdr.
  ENDIF. " IF fp_p_phdr IS NOT INITIAL

  LOOP AT fp_i_final ASSIGNING <lfs_final>.

    CLEAR lv_data.
    lv_menge = <lfs_final>-menge.
    CONDENSE lv_menge.

    CONCATENATE <lfs_final>-matnr
                <lfs_final>-idnrk
* ----> Begin of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
*               <lfs_final>-stlkn  "DELETE
                <lfs_final>-posnr "INSERT
* <---- End of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
                <lfs_final>-datuv
                <lfs_final>-datub
                lv_menge
                <lfs_final>-werks
                INTO lv_data
                SEPARATED BY c_pipe.

    lwa_data-data = lv_data.
    APPEND lwa_data TO fp_i_data.
    CLEAR lwa_data.

  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

*&--Call method to download the file
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = c_asc
      confirm_overwrite       = abap_true
    CHANGING
      data_tab                = fp_i_data
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
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.

  IF sy-subrc IS INITIAL.
    DESCRIBE TABLE fp_i_data LINES lv_count.

    WRITE lv_count TO lwa_log-msgtxt.
    CONDENSE lwa_log-msgtxt.

*&--Populate Log table for success message
    lwa_log-msgtyp = c_msgtyp_s.
    CONCATENATE lwa_log-msgtxt
                'number of records written.'(013)
    INTO lwa_log-msgtxt
    SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.

    lwa_log-msgtyp = c_msgtyp_s.
    CLEAR lv_count.
    lv_count = strlen( fp_p_phdr ).
    CONCATENATE 'File written at'(014)
                fp_p_phdr+0(lv_count)
                INTO lwa_log-msgtxt
                SEPARATED BY space.
    CONDENSE lwa_log-msgtxt.

    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ELSE. " ELSE -> IF sy-subrc IS INITIAL

*&--Populate Log table for error message
    lwa_log-msgtyp = c_msgtyp_e.
    lwa_log-msgtxt = 'Error in creating file.'(015).
    APPEND lwa_log TO fp_i_log.
    CLEAR lwa_log.
  ENDIF. " IF sy-subrc IS INITIAL
ENDFORM. " F_WRITE_PRES_DATA
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_LOG
*&---------------------------------------------------------------------*
*       Write Log Data
*----------------------------------------------------------------------*
*      -->FP_I_LOG  Log Table
*----------------------------------------------------------------------*
FORM f_write_log  USING    fp_i_log TYPE ty_t_log.

*&--Local Data Declaration
  TYPES: BEGIN OF lty_varinfo,
          flag TYPE c,          " Flag of type Character
          olength TYPE x,       " Olength of type Byte fields
          line TYPE raldb_info, "LIKE raldb-infoline, " Variant information
         END OF lty_varinfo.

  DATA: li_tables TYPE STANDARD TABLE OF trdir-name INITIAL SIZE 0, " ABAP Program Name
        li_infotab TYPE STANDARD TABLE OF lty_varinfo INITIAL SIZE 0.

  FIELD-SYMBOLS: <lfs_log>  TYPE ty_log, "Log Data
                 <lfs_infotab> TYPE lty_varinfo.

  FORMAT INTENSIFIED OFF.

  WRITE:/2(262) sy-uline.

*&--Printing Top-Of-Page Data
  WRITE:/2(50) 'Send Sales BOM structure from SAP to PPM'(016) COLOR 1.

  WRITE:/2(262) sy-uline.

  WRITE:/2(25) 'Run by:'(018),
        27(25) sy-uname.

  WRITE:/2(262) sy-uline.


*&--Print the selection screen
  CALL FUNCTION 'PRINT_SELECTIONS'
    EXPORTING
      mode      = li_tables
      rname     = sy-repid " Program Name
      rvariante = sy-slset "li_variant_info-variant " Varient Name
    TABLES
      infotab   = li_infotab.

*&--Printing Selection Screen
  LOOP AT li_infotab ASSIGNING <lfs_infotab>.
    WRITE / <lfs_infotab>-line.
  ENDLOOP. " LOOP AT li_infotab ASSIGNING <lfs_infotab>

  WRITE:/2(262) sy-uline.

*&--Printing Table Headings
  WRITE:/2(5)   'Type'(019) COLOR 1,
  8(220) 'Message Text'(020) COLOR 1.

  WRITE:/2(262) sy-uline.

*&--Printing Log Data
  LOOP AT fp_i_log ASSIGNING <lfs_log>.
    WRITE:/2(5)   <lfs_log>-msgtyp,
           8(220) <lfs_log>-msgtxt.
  ENDLOOP. " LOOP AT fp_i_log ASSIGNING <lfs_log>

  WRITE:/2(262) sy-uline.

ENDFORM. " F_WRITE_LOG
