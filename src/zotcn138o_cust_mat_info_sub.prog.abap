*&---------------------------------------------------------------------*
*&  Include           ZOTCC0138O_CUST_MAT_INFO_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCC0138O_CUST_MAT_INFO_SUB (Include)                  *
* TITLE      : Convert Customer Material info records                  *
* DEVELOPER  : Rajiv Banerjee                                          *
* OBJECT TYPE: Conversion                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0138_Convert Customer Material Info Records    *
*----------------------------------------------------------------------*
* DESCRIPTION: Customer material info records are used if the          *
* customer’s material number differs from the Bio-Rad’s material       *
* number, some customer’s would also require their own material number *
* be printed or transmitted in all of their communications.            *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*   DATE        USER    TRANSPORT    DESCRIPTION                       *
* =========== ======== ===========  ===================================*
* 20-APR-2016  RBANERJ1  E1DK917457  Initial Development               *
* 15-May-2016  JAHANM    E1DK918386  Correct error message for long txt*
*                                    Folder deletion from TBP after    *
*                                    processing, Including error record*
*                                    in BDC call transaction. Create   *
*                                    BDC sessions for error records    *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY1_SCREEN                                         *
*&---------------------------------------------------------------------*
* This perform hide/ unhide selection screen parameters based on user
* selection
*----------------------------------------------------------------------*
FORM f_modify1_screen .
  LOOP AT SCREEN .
    IF rb_pres NE c_true.
      IF screen-group1    = c_groupmi3.
        CLEAR: p_phdr.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ELSE. " ELSE -> IF rb_pres NE c_true
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
    IF rb_app NE c_true.
      IF screen-group1    = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        CLEAR: p_ahdr,
               p_alog.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
    ENDIF. " IF rb_app NE c_true
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY1_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*      Checking whether the file name has been entered or not
*----------------------------------------------------------------------*
FORM f_check_input .

* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  IF rb_pres IS NOT INITIAL AND
     p_phdr IS INITIAL.
    MESSAGE i009. "Presentation server file has not been entered'
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_ahdr IS INITIAL.
      MESSAGE i010. "Application server file has not been entered'
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i011. "Logical File Path has not been entered'
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL

ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*      Passing the logical file path to get the physical file path
*----------------------------------------------------------------------*
*      -->FP_P_ALOG     Parameter for Logical Path
*      <--FP_GV_MODIFY  File Path
*----------------------------------------------------------------------*
FORM f_logical_to_physical  USING    fp_p_alog    TYPE pathintern " Logical path name
                            CHANGING fp_gv_modify TYPE localfile. " Local file for upload/download

  DATA:   li_input   TYPE zdev_t_file_list_in,    " Input for FM ZDEV_DIRECTORY_FILE_LIST
          lwa_input  TYPE zdev_file_list_in,      " Input for FM ZDEV_DIRECTORY_FILE_LIST
          li_output  TYPE zdev_t_file_list_out,   " Output for FM ZDEV_DIRECTORY_FILE_LIST
          li_error   TYPE zdev_t_file_list_error. " Output for FM ZDEV_DIRECTORY_FILE_LIST

  FIELD-SYMBOLS: <lfs_output> TYPE zdev_file_list_out. " Output for FM ZDEV_DIRECTORY_FILE_LIST

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retrieving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST' " ZDEV_DIRECTORY_FILE_LIST
    EXPORTING
      im_identifier      = c_true
      im_input           = li_input
    IMPORTING
      ex_output          = li_output
      ex_error           = li_error
    EXCEPTIONS
      no_input           = c_1
      invalid_identifier = c_2
      no_data_found      = c_3
      OTHERS             = c_4.

  IF sy-subrc <> 0.
    MESSAGE i020. "No proper file exist for the logical file'.
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc <> 0
    IF li_error IS INITIAL.
*   Getting the file path
      READ TABLE li_output ASSIGNING <lfs_output> INDEX c_1.
      IF sy-subrc IS INITIAL.
        CONCATENATE <lfs_output>-physical_path
        <lfs_output>-filename
        INTO fp_gv_modify.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_error IS INITIAL
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_READ_FILE
*&---------------------------------------------------------------------*
*      Load File into Internal table i_string
*----------------------------------------------------------------------*
*    <--FP_I_STRING    String Table
*    <--FP_I_REPORT    Report Table
*    <--FP_I_DATA      Data Table
*----------------------------------------------------------------------*
FORM f_read_file CHANGING fp_i_string TYPE ty_t_string
                          fp_i_report TYPE ty_t_report
                          fp_i_data   TYPE ty_t_data.

  DATA:   lv_msg          TYPE string,    " Message
          lv_filename     TYPE string,    " File name
          lv_filecheck    TYPE localfile, "For Authorization check
          lv_flag         TYPE flag,      "General Flag
          lwa_report      TYPE ty_report,
          lv_subrc        TYPE sysubrc,   " Return Value of ABAP Statements
          lwa_string      TYPE ty_string. " Record

  CONSTANTS: lc_asc       TYPE char10 VALUE 'ASC',  " Asc of type CHAR10
             lc_activity  TYPE char5  VALUE 'READ', "File activity read/write
             lc_sep       TYPE char1  VALUE ':',    " Sep of type CHAR1
             lc_12        TYPE char2  VALUE '12',   " constant val 12
             lc_13        TYPE char2  VALUE '13',   " constant val 13
             lc_14        TYPE char2  VALUE '14',   " constant val 14
             lc_15        TYPE char2  VALUE '15',   " constant val 15
             lc_16        TYPE char2  VALUE '16',   " constant val 16
             lc_17        TYPE char2  VALUE '17',   " constant val 17
             lc_18        TYPE char2  VALUE '18',   " constant val 18
             lc_19        TYPE char2  VALUE '19'.   " constant val 19


  CLEAR: gv_subrc,
         lv_filename.

  IF rb_pres = abap_true. " Presentation

    lv_filename = p_phdr.
    gv_filename = p_phdr.
    gv_file     = p_phdr.
  ELSEIF rb_app = abap_true. " Application

    IF rb_aphy = abap_true. " Appl Phy

      lv_filename = p_ahdr.
      gv_filename = p_ahdr.
      gv_file     = p_ahdr.

    ELSEIF rb_alog = abap_true. " Appl Log

      lv_filename = gv_filename.
      gv_file     = lv_filename.
    ENDIF. " IF rb_aphy = abap_true
  ENDIF. " IF rb_pres = abap_true

*&--Presentation Server
  IF rb_pres = abap_true.
    IF sy-batch IS INITIAL.
*&--Read File
      CLEAR : fp_i_string.
      CALL METHOD cl_gui_frontend_services=>gui_upload " GUI_UPLOAD
        EXPORTING
          filename                = lv_filename
          filetype                = lc_asc
          has_field_separator     = space
        CHANGING
          data_tab                = fp_i_string
        EXCEPTIONS
          file_open_error         = c_1
          file_read_error         = c_2
          no_batch                = c_3
          gui_refuse_filetransfer = c_4
          invalid_type            = c_5
          no_authority            = c_6
          unknown_error           = c_7
          bad_data_format         = c_8
          header_not_allowed      = c_9
          separator_not_allowed   = c_10
          header_too_long         = c_11
          unknown_dp_error        = lc_12
          access_denied           = lc_13
          dp_out_of_memory        = lc_14
          disk_full               = lc_15
          dp_timeout              = lc_16
          not_supported_by_gui    = lc_17
          error_no_gui            = lc_18
          OTHERS                  = lc_19.
      IF sy-subrc <> 0.

        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno INTO lv_msg
        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE lv_msg lv_filename INTO lwa_report-msgtxt SEPARATED BY lc_sep.
        APPEND lwa_report TO fp_i_report.
        CLEAR lwa_report.
      ELSE. " ELSE -> IF sy-subrc <> 0
*&--Map data from string to table structure
        PERFORM f_mapping_data USING    fp_i_string
                               CHANGING fp_i_data
                                        fp_i_report.

      ENDIF. " IF sy-subrc <> 0
    ELSE. " ELSE -> IF sy-batch IS INITIAL
      MESSAGE i061.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-batch IS INITIAL
  ELSE. " ELSE -> IF rb_pres = abap_true
*&--Application Server

    lv_filecheck = lv_filename.
    PERFORM f_authorization_check USING lv_filecheck
                                        lc_activity
                               CHANGING lv_flag.
    IF lv_flag IS INITIAL.
 "Authorized
      CLEAR lv_msg.
      CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_open_dataset
        EXPORTING
          im_file     = lv_filecheck
          im_codepage = gv_codepage
        IMPORTING
          ex_subrc    = lv_subrc
          ex_message  = lv_msg.

      IF lv_subrc IS NOT INITIAL.
        MESSAGE i967 WITH lv_filecheck. "Error in opening the file.'
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF lv_subrc IS NOT INITIAL
        WHILE ( gv_subrc EQ 0 ).
          READ DATASET lv_filecheck INTO lwa_string-string.
          gv_subrc = sy-subrc.
          IF gv_subrc = 0.
            APPEND lwa_string TO fp_i_string.
            CLEAR lwa_string-string.
          ENDIF. " IF gv_subrc = 0
        ENDWHILE.
      ENDIF. " IF lv_subrc IS NOT INITIAL
      CLOSE DATASET lv_filecheck.

*&--Map data from string to table structure
      PERFORM f_mapping_data USING    fp_i_string
                             CHANGING fp_i_data
                                      fp_i_report.

    ELSE. " ELSE -> IF lv_flag IS INITIAL
                                      "Not Authorized
      MESSAGE i950 WITH lv_filecheck. "No authorization for access to file &.
      LEAVE LIST-PROCESSING.

    ENDIF. " IF lv_flag IS INITIAL

  ENDIF. " IF rb_pres = abap_true

  IF rb_verif IS INITIAL.

    IF fp_i_data[] IS INITIAL.

      MESSAGE i138. "No Records Found.
      LEAVE LIST-PROCESSING.

    ENDIF. " IF fp_i_data[] IS INITIAL
  ENDIF. " IF rb_verif IS INITIAL

ENDFORM. " F_READ_FILE
*&---------------------------------------------------------------------*
*&      Form  F_MAPPING_DATA
*&---------------------------------------------------------------------*
*       Map Records from String to Structure
*----------------------------------------------------------------------*
*  -->  FP_I_STRING        String Table
*  <--  FP_I_DATA          Data Table
*----------------------------------------------------------------------*
FORM f_mapping_data USING    fp_p_i_string   TYPE ty_t_string
                    CHANGING fp_p_i_data     TYPE ty_t_data
                             fp_p_i_report   TYPE ty_t_report.

  DATA: lwa_data      TYPE ty_data,
        lv_min_qty    TYPE char16, "Minimum delivery quantity in delivery note processing
        lv_max_del    TYPE char1,  "Maximum Number of Partial Deliveries Allowed Per Item
        lwa_report    TYPE ty_report,
        lv_udel_lim   TYPE char4,  "Underdelivery Tolerance Limit
        lv_odel_lim   TYPE char4.  "Overdelivery Tolerance Limit

  FIELD-SYMBOLS: <lfs_string> TYPE ty_string.

  CONSTANTS : lc_pipe TYPE char1 VALUE '|'. " Pipe of type CHAR1

  IF rb_verif IS NOT INITIAL. "Verify file only

 "read the header of file to verify structure only.
    READ TABLE fp_p_i_string ASSIGNING <lfs_string> INDEX c_1.
    IF sy-subrc IS INITIAL.
      gv_header = <lfs_string>-string.
    ENDIF. " IF sy-subrc IS INITIAL

  ELSE. " ELSE -> IF rb_verif IS NOT INITIAL

 "For Load Simulation and Post

    LOOP AT fp_p_i_string ASSIGNING <lfs_string>.
*&--Eliminate header row while mapping data
      IF sy-tabix = c_1.
* Keeping the Header Details in a String to populate the same in Error Report.
        gv_header = <lfs_string>-string.
      ELSE. " ELSE -> IF sy-tabix = c_1
        SPLIT <lfs_string>-string AT lc_pipe INTO
        lwa_data-vkorg     "Sales Organization
        lwa_data-vtweg     "Distribution Channel
        lwa_data-kunnr     "Customer number
        lwa_data-matnr     "Material Number
        lwa_data-sortl     "Sort field
        lwa_data-kdmat     "Material Number Used by Customer
        lwa_data-postx     "Customer description of material
        lwa_data-lprio     "Delivery Priority
        lv_min_qty         "Minimum delivery quantity in delivery note processing
        lwa_data-meins     "Base Unit of Measure
        lwa_data-chspl     "Batch split allowed
        lwa_data-kztlf     "Partial delivery at item level
        lv_max_del         "Maximum Number of Partial Deliveries Allowed Per Item
        lv_udel_lim        "Underdelivery Tolerance Limit
        lv_odel_lim        "Overdelivery Tolerance Limit
        lwa_data-uebtk     "Unlimited overdelivery allowed
        lwa_data-werks     "Plant (Own or External)
        lwa_data-rdprf     "Rounding Profile
        lwa_data-megru     "Unit of Measure Group
        lwa_data-j_1btxsdc "SD tax code
        lwa_data-vwpos     "Item usage
        lwa_data-spras1    "Language Key 1
        lwa_data-text1     "Text 1
        lwa_data-spras2    "Language Key 2
        lwa_data-text2     "Text 2
        lwa_data-spras3    "Language Key 3
        lwa_data-text3     "Text 3
        lwa_data-spras4    "Language Key 4
        lwa_data-text4     "Text 4
        lwa_data-spras5    "Language Key 5
        lwa_data-text5.    "Text 5

        TRY.
            lwa_data-minlf = lv_min_qty.

          CATCH cx_sy_conversion_error.
            CLEAR lwa_report.
            lwa_report-msgtyp = c_error.
            CONCATENATE 'Conversion error occured for:'(076) lv_min_qty
            INTO lwa_report-msgtxt  SEPARATED BY space.

            lwa_report-vkorg = lwa_data-vkorg.
            lwa_report-kunnr = lwa_data-kunnr.
            lwa_report-matnr = lwa_data-matnr.

            APPEND lwa_report TO fp_p_i_report.
            CLEAR lwa_report.
        ENDTRY.


        TRY .
            lwa_data-antlf = lv_max_del.

          CATCH cx_sy_conversion_error.
            CLEAR lwa_report.
            lwa_report-msgtyp = c_error.
            CONCATENATE 'Conversion error occured for:'(076) lv_max_del
            INTO lwa_report-msgtxt  SEPARATED BY space.

            lwa_report-vkorg = lwa_data-vkorg.
            lwa_report-kunnr = lwa_data-kunnr.
            lwa_report-matnr = lwa_data-matnr.

            APPEND lwa_report TO fp_p_i_report.
            CLEAR lwa_report.
        ENDTRY.

        TRY .
            lwa_data-untto = lv_udel_lim.

          CATCH cx_sy_conversion_error.
            CLEAR lwa_report.
            lwa_report-msgtyp = c_error.
            CONCATENATE 'Conversion error occured for:'(076)
            lv_udel_lim INTO lwa_report-msgtxt SEPARATED BY space.

            lwa_report-vkorg = lwa_data-vkorg.
            lwa_report-kunnr = lwa_data-kunnr.
            lwa_report-matnr = lwa_data-matnr.

            APPEND lwa_report TO fp_p_i_report.
            CLEAR lwa_report.
        ENDTRY.

        TRY .
            lwa_data-uebto = lv_odel_lim.

          CATCH cx_sy_conversion_error.
            CLEAR lwa_report.
            lwa_report-msgtyp = c_error.
            CONCATENATE 'Conversion error occured for:'(076)
            lv_odel_lim INTO lwa_report-msgtxt  SEPARATED BY space.

            lwa_report-vkorg = lwa_data-vkorg.
            lwa_report-kunnr = lwa_data-kunnr.
            lwa_report-matnr = lwa_data-matnr.

            APPEND lwa_report TO fp_p_i_report.
            CLEAR lwa_report.
        ENDTRY.


        lwa_data-string     = <lfs_string>-string.

*&&-convert customer input
        PERFORM f_customer_input CHANGING lwa_data-kunnr.

        APPEND lwa_data TO fp_p_i_data.
        CLEAR : lwa_data,
                lv_min_qty,
                lv_max_del,
                lv_udel_lim,
                lv_odel_lim.

      ENDIF. " IF sy-tabix = c_1
    ENDLOOP. " LOOP AT fp_p_i_string ASSIGNING <lfs_string>
  ENDIF. " IF rb_verif IS NOT INITIAL

ENDFORM. " F_MAPPING_DATA
*&---------------------------------------------------------------------*
*&      Form  f_Authorization_check
*&---------------------------------------------------------------------*
*      File access Authorization check
*----------------------------------------------------------------------*
FORM f_authorization_check  USING    fp_filename TYPE localfile " Local file for upload/download
                                     fp_activity TYPE char5     " Activity of type CHAR5
                            CHANGING fp_flag     TYPE flag.     " General Flag

  DATA:      lv_file TYPE fileextern. " Physical file name

  lv_file = fp_filename.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = fp_activity
      filename         = lv_file
    EXCEPTIONS
      no_authority     = c_1
      activity_unknown = c_2
      OTHERS           = c_3.

  IF sy-subrc <> 0.
    fp_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc <> 0
    fp_flag = abap_false.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_CHECK_FILE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*       Validate Data
*----------------------------------------------------------------------*
*  -->  FP_I_DATA     Data Table
*----------------------------------------------------------------------*
FORM f_validate_data USING fp_i_data TYPE ty_t_data.

  DATA : li_data TYPE STANDARD TABLE OF ty_data.


  IF fp_i_data IS NOT INITIAL.

    li_data[] = fp_i_data[].

    SORT li_data BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_data COMPARING kunnr.
    IF li_data IS NOT INITIAL.

      SELECT kunnr "Customer Number
        FROM kna1  " General Data in Customer Master
        INTO TABLE i_kna1
        FOR ALL ENTRIES IN li_data
        WHERE kunnr = li_data-kunnr.
      IF sy-subrc IS INITIAL.
        SORT i_kna1 BY kunnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_data IS NOT INITIAL

    CLEAR li_data.
    li_data[] = fp_i_data[].
    SORT li_data BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_data COMPARING matnr.
    IF li_data IS NOT INITIAL.

      SELECT matnr "Material Number
        FROM mara  " General Material Data
        INTO TABLE i_mara
        FOR ALL ENTRIES IN li_data
        WHERE matnr = li_data-matnr.
      IF sy-subrc IS INITIAL.
        SORT i_mara BY matnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_data IS NOT INITIAL


    CLEAR li_data.
    li_data[] = fp_i_data[].
    SORT li_data BY kunnr vkorg vtweg.
    DELETE ADJACENT DUPLICATES FROM li_data COMPARING kunnr vkorg vtweg.
    IF li_data IS NOT INITIAL.

      SELECT kunnr " Customer Number
             vkorg " Sales Organization
             vtweg " Distribution Channel
             spart " Division
        FROM knvv  " Customer Master Sales Data
        INTO TABLE i_knvv
        FOR ALL ENTRIES IN li_data
        WHERE kunnr = li_data-kunnr AND
              vkorg = li_data-vkorg AND
              vtweg = li_data-vtweg.
      IF sy-subrc IS INITIAL.
        SORT i_knvv BY kunnr vkorg vtweg.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_data IS NOT INITIAL


    CLEAR li_data.
    li_data[] = fp_i_data[].
    SORT li_data BY matnr vkorg vtweg.
    DELETE ADJACENT DUPLICATES FROM li_data COMPARING matnr vkorg vtweg.
    IF li_data IS NOT INITIAL.

      SELECT matnr " Material Number
             vkorg " Sales Organization
             vtweg " Distribution Channel
        FROM mvke  " Sales Data for Material
        INTO TABLE i_mvke
        FOR ALL ENTRIES IN li_data
        WHERE matnr = li_data-matnr AND
              vkorg = li_data-vkorg AND
              vtweg = li_data-vtweg.
      IF sy-subrc IS INITIAL.
        SORT i_mvke BY matnr vkorg vtweg.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_data IS NOT INITIAL

    CLEAR li_data.
    li_data[] = fp_i_data[].
    SORT li_data BY vkorg vtweg kunnr matnr.
    DELETE ADJACENT DUPLICATES FROM li_data COMPARING vkorg vtweg kunnr matnr.
    IF li_data IS NOT INITIAL.

      SELECT vkorg " Sales Organization
             vtweg " Distribution Channel
             kunnr " Customer number
             matnr " Material Number
        FROM knmt  " Customer-Material Info Record Data Table
        INTO TABLE i_knmt
        FOR ALL ENTRIES IN li_data
        WHERE vkorg = li_data-vkorg AND
              vtweg = li_data-vtweg AND
              kunnr = li_data-kunnr AND
              matnr = li_data-matnr.
      IF sy-subrc IS INITIAL.
        SORT i_knmt BY vkorg vtweg kunnr matnr.
      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF li_data IS NOT INITIAL

  ENDIF. " IF fp_i_data IS NOT INITIAL

  FREE : li_data .

ENDFORM. " F_VALIDATE_DATA
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_ERROR_LOG
*&---------------------------------------------------------------------*
*       Populate Error Log
*----------------------------------------------------------------------*
*      <--FP_I_DATA     Data Table
*      <--FP_I_REPORT   Error report
*      <--FP_I_Error    Error record file
*----------------------------------------------------------------------*
FORM f_populate_error_log  CHANGING fp_i_data    TYPE ty_t_data
                                    fp_i_report  TYPE ty_t_report
                                    fp_i_error   TYPE ty_t_string.

  DATA : lwa_report  TYPE ty_report,
         lwa_error   TYPE ty_string,
         lv_flag     TYPE flag. " General Flag

  FIELD-SYMBOLS : <lfs_data>  TYPE ty_data.

  CLEAR : gv_error,
          gv_success.

  LOOP AT fp_i_data ASSIGNING <lfs_data>.

    CLEAR lv_flag.

 "check customer exist
    READ TABLE i_kna1 TRANSPORTING NO FIELDS
    WITH KEY kunnr = <lfs_data>-kunnr BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL. "Customer not found

      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Customer not found.'(015).
      lwa_report-vkorg  = <lfs_data>-vkorg.
      lwa_report-kunnr  = <lfs_data>-kunnr.
      lwa_report-matnr  = <lfs_data>-matnr.

      APPEND lwa_report TO fp_i_report. "Fill error report to display
      CLEAR lwa_report.

      IF lv_flag NE abap_true. "If Error flag not set for record

        lwa_error-string = <lfs_data>-string. "Fill error record file
        APPEND lwa_error TO fp_i_error.
        CLEAR lwa_error.

        <lfs_data>-e_flag = abap_true. "set record as error in data file
        gv_error = gv_error + 1. "total error count
        lv_flag  =  abap_true. "local error flag
      ENDIF. " IF lv_flag NE abap_true
    ENDIF. " IF sy-subrc IS NOT INITIAL


 "check customer is extended
    READ TABLE i_knvv TRANSPORTING NO FIELDS
    WITH KEY kunnr = <lfs_data>-kunnr
             vkorg = <lfs_data>-vkorg
             vtweg = <lfs_data>-vtweg BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL. "Customer not extended

      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Customer is not extended.'(016).
      lwa_report-vkorg  = <lfs_data>-vkorg.
      lwa_report-kunnr  = <lfs_data>-kunnr.
      lwa_report-matnr  = <lfs_data>-matnr.

      APPEND lwa_report TO fp_i_report. "Fill error report to display
      CLEAR lwa_report.

      IF lv_flag NE abap_true. "If Error flag not set for record

        lwa_error-string = <lfs_data>-string. "Fill error record file
        APPEND lwa_error TO fp_i_error.
        CLEAR lwa_error.

        <lfs_data>-e_flag = abap_true. "set record as error in data file
        gv_error = gv_error + 1. "total error count
        lv_flag  =  abap_true. "local error flag
      ENDIF. " IF lv_flag NE abap_true
    ENDIF. " IF sy-subrc IS NOT INITIAL


 "check material is exist
    READ TABLE i_mara TRANSPORTING NO FIELDS
    WITH KEY matnr = <lfs_data>-matnr BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL. "Material not found

      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Material not found.'(017).
      lwa_report-vkorg  = <lfs_data>-vkorg.
      lwa_report-kunnr  = <lfs_data>-kunnr.
      lwa_report-matnr  = <lfs_data>-matnr.

      APPEND lwa_report TO fp_i_report. "Fill error report to display
      CLEAR lwa_report.

      IF lv_flag NE abap_true. "If Error flag not set for record

        lwa_error-string = <lfs_data>-string. "Fill error record file
        APPEND lwa_error TO fp_i_error.
        CLEAR lwa_error.

        <lfs_data>-e_flag = abap_true. "set record as error in data file
        gv_error = gv_error + 1. "total error count
        lv_flag  =  abap_true. "local error flag
      ENDIF. " IF lv_flag NE abap_true
    ENDIF. " IF sy-subrc IS NOT INITIAL


 "check material is extended
    READ TABLE i_mvke TRANSPORTING NO FIELDS
    WITH KEY matnr = <lfs_data>-matnr
             vkorg = <lfs_data>-vkorg
             vtweg = <lfs_data>-vtweg BINARY SEARCH.
    IF sy-subrc IS NOT INITIAL. "Material not extended

      lwa_report-msgtyp = c_error.
      lwa_report-msgtxt = 'Sales Data for Material is not found.'(018).
      lwa_report-vkorg  = <lfs_data>-vkorg.
      lwa_report-kunnr  = <lfs_data>-kunnr.
      lwa_report-matnr  = <lfs_data>-matnr.

      APPEND lwa_report TO fp_i_report. "Fill error report to display
      CLEAR lwa_report.

      IF lv_flag NE abap_true. "If Error flag not set for record

        lwa_error-string = <lfs_data>-string. "Fill error record file
        APPEND lwa_error TO fp_i_error.
        CLEAR lwa_error.

        <lfs_data>-e_flag = abap_true. "set record as error in data file
        gv_error = gv_error + 1. "total error count
        lv_flag  =  abap_true. "local error flag
      ENDIF. " IF lv_flag NE abap_true
    ENDIF. " IF sy-subrc IS NOT INITIAL

    IF lv_flag IS INITIAL. "no error found
      gv_success = gv_success + 1.
    ENDIF. " IF lv_flag IS INITIAL

  ENDLOOP. " LOOP AT fp_i_data ASSIGNING <lfs_data>

ENDFORM. " F_POPULATE_ERROR_LOG
*&---------------------------------------------------------------------*
*&      Form  F_CALL_BDC
*&---------------------------------------------------------------------*
*       Call BDC with data file records
*----------------------------------------------------------------------*
*      -->FP_I_DATA    Data Table
*      <--FP_I_REPORT  Error report
*      <--FP_I_ERROR   Error record file
*      <--FP_I_DONE    Success record file
*----------------------------------------------------------------------*
FORM f_call_bdc   USING   fp_i_data     TYPE ty_t_data
                 CHANGING fp_i_report   TYPE ty_t_report
                          fp_i_error    TYPE ty_t_string
                          fp_i_done     TYPE ty_t_string.

  DATA : lwa_data    TYPE ty_data,
         lwa_report  TYPE ty_report,
         lwa_error   TYPE ty_string,
         lwa_done    TYPE ty_string,
         lv_mode     TYPE char1,                        " Mode of type CHAR1
         lv_update   TYPE char1,                        " Update of type CHAR1
         li_bdcmsg   TYPE STANDARD TABLE OF bdcmsgcoll, " Collecting messages in the SAP System
         li_data     TYPE STANDARD TABLE OF ty_data,    "temp table
         lwa_bdcmsg  TYPE bdcmsgcoll,                   " Collecting messages in the SAP System
         lv_exist    TYPE char1,                        " Text Exist
         lv_kunnr    TYPE kunnr,                        "customer
         lv_count    TYPE sytabix,                      "count
         lv_dflag    TYPE char1.                        "flag for duplicate rec.

  CONSTANTS : lc_vd51   TYPE tstc-tcode VALUE 'VD51',         " Vd51 of type CHAR4
              c_group   TYPE apqi-groupid VALUE   'OTC_0138', " Session Name
              lc_keep   TYPE apq_qdel VALUE 'X',              " Queue deletion indicator for processed sessions
*             lc_vd51   TYPE char4 VALUE 'VD51', " Vd51 of type CHAR4
              lc_mode   TYPE char1 VALUE 'N', " Mode of type CHAR1
              lc_update TYPE char4 VALUE 'S'. " Update of type CHAR4

  CLEAR gv_success. "begin success count

  li_data[] = fp_i_data[].
****************Changes by Jahan
* We need to submit and create for all the records including errored ones.
*  DELETE li_data WHERE e_flag EQ abap_true. "delete error records
****************ENd of Changes by Jahan
  IF li_data IS NOT INITIAL.

    LOOP AT li_data INTO lwa_data.

      CLEAR : lv_dflag,
              lv_exist,
              lv_kunnr.

*&--Check if duplicate record.
      PERFORM f_check_duplicate USING    lwa_data
                                CHANGING lv_dflag.


      PERFORM f_bdc_dynpro      USING 'SAPMV10A' '0100'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'MV10A-VTWEG'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.

      lv_kunnr = lwa_data-kunnr.
      PERFORM f_customer_output CHANGING lv_kunnr.
      PERFORM f_bdc_field       USING 'MV10A-KUNNR'
                                      lv_kunnr.

      PERFORM f_bdc_field       USING 'MV10A-VKORG'
                                      lwa_data-vkorg.

      PERFORM f_bdc_field       USING 'MV10A-VTWEG'
                                      lwa_data-vtweg.

      PERFORM f_bdc_dynpro      USING 'SAPMV10A' '0200'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'MV10A-MATNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SELE'.
      PERFORM f_bdc_field       USING 'MV10A-SELKZ(01)'
                                    'X'.
      PERFORM f_bdc_field       USING 'MV10A-MATNR(01)'
                                      lwa_data-matnr.

      PERFORM f_bdc_field       USING 'MV10A-KDMAT(01)'
                                      lwa_data-kdmat.

      PERFORM f_bdc_field       USING 'MV10A-RDPRF(01)'
                                    ''.
      PERFORM f_bdc_dynpro      USING 'SAPMV10A' '0300'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'MV10A-VWPOS'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    'TEXT'.
      PERFORM f_bdc_field       USING 'MV10A-KDMAT'
                                      lwa_data-kdmat.

      PERFORM f_bdc_field       USING 'MV10A-POSTX'
                                      lwa_data-postx.

      PERFORM f_bdc_field       USING 'MV10A-SORTL'
                                      lwa_data-sortl.

      PERFORM f_bdc_field       USING 'MV10A-WERKS'
                                      lwa_data-werks.

      PERFORM f_bdc_field       USING 'MV10A-LPRIO'
                                      lwa_data-lprio.

      PERFORM f_bdc_field       USING 'MV10A-MINLF'
                                      lwa_data-minlf.

      PERFORM f_bdc_field       USING 'MV10A-KZTLF'
                                      lwa_data-kztlf.

      PERFORM f_bdc_field       USING 'MV10A-UNTTO'
                                      lwa_data-untto.

      PERFORM f_bdc_field       USING 'MV10A-ANTLF'
                                      lwa_data-antlf.

      PERFORM f_bdc_field       USING 'MV10A-UEBTO'
                                      lwa_data-uebto.

      PERFORM f_bdc_field       USING 'MV10A-VWPOS'
                                      lwa_data-vwpos.

      PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'LV70T-LTX01(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.

      IF lwa_data-spras1 IS NOT INITIAL.

        IF lv_dflag EQ abap_true.

 "check text exist
          PERFORM f_check_text USING lwa_data-vkorg
                                     lwa_data-vtweg
                                     lwa_data-kunnr
                                     lwa_data-matnr
                                     lwa_data-spras1
                            CHANGING lv_exist.

          IF lv_exist EQ abap_true.

 "duplicate text exist, delete it before creating new
            PERFORM f_delete_text USING lwa_data-vkorg
                                        lwa_data-vtweg
                                        lwa_data-kunnr
                                        lwa_data-matnr
                                        lwa_data-spras1
                               CHANGING fp_i_report.
          ENDIF. " IF lv_exist EQ abap_true
          CLEAR lv_exist.
        ENDIF. " IF lv_dflag EQ abap_true

        PERFORM f_bdc_field       USING 'LV70T-SPRAS(01)'
                                         lwa_data-spras1.

        PERFORM f_bdc_field       USING 'LV70T-LTX01(01)'
                                        lwa_data-text1.

        PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'LV70T-LTX01(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=TEAN'.
      ENDIF. " IF lwa_data-spras1 IS NOT INITIAL

      PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'LV70T-LTX01(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.

      IF lwa_data-spras2 IS NOT INITIAL.
        IF lv_dflag EQ abap_true.

 "check text exist
          PERFORM f_check_text USING lwa_data-vkorg
                                     lwa_data-vtweg
                                     lwa_data-kunnr
                                     lwa_data-matnr
                                     lwa_data-spras2
                            CHANGING lv_exist.

          IF lv_exist EQ abap_true.

 "duplicate text exist, delete it before creating new
            PERFORM f_delete_text USING lwa_data-vkorg
                                        lwa_data-vtweg
                                        lwa_data-kunnr
                                        lwa_data-matnr
                                        lwa_data-spras2
                               CHANGING fp_i_report.
          ENDIF. " IF lv_exist EQ abap_true
          CLEAR lv_exist.
        ENDIF. " IF lv_dflag EQ abap_true

        PERFORM f_bdc_field       USING 'LV70T-SPRAS(01)'
                                        lwa_data-spras2.

        PERFORM f_bdc_field       USING 'LV70T-LTX01(01)'
                                        lwa_data-text2.

        PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'LV70T-LTX01(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=TEAN'.

      ENDIF. " IF lwa_data-spras2 IS NOT INITIAL



      PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'LV70T-LTX01(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                  '/00'.

      IF lwa_data-spras3 IS NOT INITIAL.
        IF lv_dflag EQ abap_true.

 "check text exist
          PERFORM f_check_text USING lwa_data-vkorg
                                     lwa_data-vtweg
                                     lwa_data-kunnr
                                     lwa_data-matnr
                                     lwa_data-spras3
                            CHANGING lv_exist.

          IF lv_exist EQ abap_true.

 "duplicate text exist, delete it before creating new
            PERFORM f_delete_text USING lwa_data-vkorg
                                        lwa_data-vtweg
                                        lwa_data-kunnr
                                        lwa_data-matnr
                                        lwa_data-spras3
                               CHANGING fp_i_report.
          ENDIF. " IF lv_exist EQ abap_true
          CLEAR lv_exist.
        ENDIF. " IF lv_dflag EQ abap_true

        PERFORM f_bdc_field       USING 'LV70T-SPRAS(01)'
                                        lwa_data-spras3.
        PERFORM f_bdc_field       USING 'LV70T-LTX01(01)'
                                        lwa_data-text3.

        PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'. """
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'LV70T-LTX01(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=TEAN'.

      ENDIF. " IF lwa_data-spras3 IS NOT INITIAL



      PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'LV70T-LTX01(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.
      IF lwa_data-spras4 IS NOT INITIAL.
        IF lv_dflag EQ abap_true.

 "check text exist
          PERFORM f_check_text USING lwa_data-vkorg
                                     lwa_data-vtweg
                                     lwa_data-kunnr
                                     lwa_data-matnr
                                     lwa_data-spras4
                            CHANGING lv_exist.

          IF lv_exist EQ abap_true.

 "duplicate text exist, delete it before creating new
            PERFORM f_delete_text USING lwa_data-vkorg
                                        lwa_data-vtweg
                                        lwa_data-kunnr
                                        lwa_data-matnr
                                        lwa_data-spras4
                               CHANGING fp_i_report.
          ENDIF. " IF lv_exist EQ abap_true
          CLEAR lv_exist.
        ENDIF. " IF lv_dflag EQ abap_true

        PERFORM f_bdc_field       USING 'LV70T-SPRAS(01)'
                                        lwa_data-spras4.
        PERFORM f_bdc_field       USING 'LV70T-LTX01(01)'
                                        lwa_data-text4.
        PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'LV70T-LTX01(01)'.
        PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                      '=TEAN'.

      ENDIF. " IF lwa_data-spras4 IS NOT INITIAL

      PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'LV70T-LTX01(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.

      IF lwa_data-spras5 IS NOT INITIAL.
        IF lv_dflag EQ abap_true.

 "check text exist
          PERFORM f_check_text USING lwa_data-vkorg
                                     lwa_data-vtweg
                                     lwa_data-kunnr
                                     lwa_data-matnr
                                     lwa_data-spras5
                            CHANGING lv_exist.

          IF lv_exist EQ abap_true.

 "duplicate text exist, delete it before creating new
            PERFORM f_delete_text USING lwa_data-vkorg
                                        lwa_data-vtweg
                                        lwa_data-kunnr
                                        lwa_data-matnr
                                        lwa_data-spras5
                               CHANGING fp_i_report.
          ENDIF. " IF lv_exist EQ abap_true
          CLEAR lv_exist.
        ENDIF. " IF lv_dflag EQ abap_true

        PERFORM f_bdc_field       USING 'LV70T-SPRAS(01)'
                                        lwa_data-spras5.
        PERFORM f_bdc_field       USING 'LV70T-LTX01(01)'
                                        lwa_data-text5.
        PERFORM f_bdc_dynpro      USING 'SAPLV70T' '0101'.
        PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                      'LV70T-LTX01(01)'.

      ENDIF. " IF lwa_data-spras5 IS NOT INITIAL
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=BACK'.
      PERFORM f_bdc_dynpro      USING 'SAPMV10A' '0300'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'MV10A-KDMAT'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=BACK'.
      PERFORM f_bdc_field       USING 'MV10A-KDMAT'
                                      lwa_data-kdmat.
      PERFORM f_bdc_field       USING 'MV10A-POSTX'
                                      lwa_data-postx.
      PERFORM f_bdc_field       USING 'MV10A-SORTL'
                                      lwa_data-sortl.
      PERFORM f_bdc_field       USING 'MV10A-WERKS'
                                      lwa_data-werks.
      PERFORM f_bdc_field       USING 'MV10A-LPRIO'
                                      lwa_data-lprio.
      PERFORM f_bdc_field       USING 'MV10A-MINLF'
                                      lwa_data-minlf.
      PERFORM f_bdc_field       USING 'MV10A-KZTLF'
                                      lwa_data-kztlf.
      PERFORM f_bdc_field       USING 'MV10A-UNTTO'
                                      lwa_data-untto.
      PERFORM f_bdc_field       USING 'MV10A-ANTLF'
                                      lwa_data-antlf.
      PERFORM f_bdc_field       USING 'MV10A-UEBTO'
                                      lwa_data-uebto.
      PERFORM f_bdc_field       USING 'MV10A-VWPOS'
                                      lwa_data-vwpos.
      PERFORM f_bdc_dynpro      USING 'SAPMV10A' '0200'.
      PERFORM f_bdc_field       USING 'BDC_CURSOR'
                                    'MV10A-MATNR(01)'.
      PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=SICH'.

      lv_mode = lc_mode.
      lv_update = lc_update.
      CLEAR li_bdcmsg.

      CALL TRANSACTION lc_vd51 USING i_bdcdata
                       MODE   lv_mode
                       UPDATE lv_update
                       MESSAGES INTO li_bdcmsg.

      IF li_bdcmsg IS NOT INITIAL.

 "check error exist
        READ TABLE li_bdcmsg TRANSPORTING NO FIELDS
        WITH KEY msgtyp = c_error.
        IF sy-subrc IS INITIAL.

          CLEAR lv_count.

          LOOP AT li_bdcmsg INTO lwa_bdcmsg.

            IF lwa_bdcmsg-msgtyp = c_error.

              lv_count = lv_count + 1.

              IF lv_count = c_1. "Only for first row with error is read
 "Record with error
                lwa_error-string = lwa_data-string.
                APPEND lwa_error TO fp_i_error.
                CLEAR lwa_error.
                gv_error = gv_error + 1. "error count
              ENDIF. " IF lv_count = c_1

              lwa_report-msgtyp = c_error.

****************Changes by Jahan
*Error message was showing incomplete/truncated texts
*              CONCATENATE lwa_bdcmsg-msgv1 lwa_bdcmsg-msgv2 lwa_bdcmsg-msgv3
*              lwa_bdcmsg-msgv4 INTO lwa_report-msgtxt.

              MESSAGE ID lwa_bdcmsg-msgid
                    TYPE lwa_bdcmsg-msgtyp
                    NUMBER lwa_bdcmsg-msgnr
                    WITH lwa_bdcmsg-msgv1
                          lwa_bdcmsg-msgv2
                          lwa_bdcmsg-msgv3
                          lwa_bdcmsg-msgv4
                     INTO lwa_report-msgtxt.

              lwa_report-vkorg = lwa_data-vkorg.
              lwa_report-kunnr = lwa_data-kunnr.
              lwa_report-matnr = lwa_data-matnr.
****************End of Changes by Jahan
              APPEND lwa_report TO fp_i_report.
              CLEAR : lwa_bdcmsg,
                      lwa_report.
            ENDIF. " IF lwa_bdcmsg-msgtyp = c_error

          ENDLOOP. " LOOP AT li_bdcmsg INTO lwa_bdcmsg

*create BDC session for error records

          CALL FUNCTION 'BDC_OPEN_GROUP'    "Open batch input session for adding transactions
           EXPORTING
              client              = sy-mandt
              group               = c_group "value:PLM_0132
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
* & -- Error in BDC Session & not if already running.
            IF sy-subrc <> 8.
              MESSAGE i051 WITH c_group.
              LEAVE LIST-PROCESSING.
            ELSE. " ELSE -> IF sy-subrc <> 8
****************Changes by Jahan
*Create BDC session for all error records.
*Insert a transaction in BDC session
              gv_bdc_flag = c_true.
              CALL FUNCTION 'BDC_INSERT'
                EXPORTING
                  tcode            = lc_vd51
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
              IF sy-subrc IS NOT INITIAL.

* & -- Error in BDC Session &
                MESSAGE i051 WITH c_group.
                LEAVE TO LIST-PROCESSING.

              ENDIF. " IF sy-subrc IS NOT INITIAL

            ENDIF. " IF sy-subrc <> 8
          ELSE. " ELSE -> IF sy-subrc <> 0
*Insert a transaction in BDC session
            gv_bdc_flag = c_true.
            CALL FUNCTION 'BDC_INSERT'
              EXPORTING
                tcode            = lc_vd51
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
            IF sy-subrc IS NOT INITIAL.

* & -- Error in BDC Session &
              MESSAGE i051 WITH c_group.
              LEAVE TO LIST-PROCESSING.

            ENDIF. " IF sy-subrc IS NOT INITIAL
****************End of Changes by Jahan

          ENDIF. " IF sy-subrc <> 0

        ELSE. " ELSE -> IF sy-subrc IS INITIAL

 "record processed successfully
          lwa_done-string = lwa_data-string.
          APPEND lwa_done TO fp_i_done.
          CLEAR lwa_done.
          gv_success = gv_success + 1. "success count

        ENDIF. " IF sy-subrc IS INITIAL

      ELSE. " ELSE -> IF li_bdcmsg IS NOT INITIAL

 "record processed successfully
        lwa_done-string = lwa_data-string.
        APPEND lwa_done TO fp_i_done.
        CLEAR lwa_done.
        gv_success = gv_success + 1. "success count

      ENDIF. " IF li_bdcmsg IS NOT INITIAL

      CLEAR : lwa_data.
      REFRESH i_bdcdata.
    ENDLOOP. " LOOP AT li_data INTO lwa_data

*    ENDIF. " IF sy-subrc <> 0

  ENDIF. " IF li_data IS NOT INITIAL

****************Changes by Jahan
  IF gv_bdc_flag IS NOT INITIAL.
    CALL FUNCTION 'BDC_CLOSE_GROUP'
      EXCEPTIONS
        not_open    = 1
        queue_error = 2
        OTHERS      = 3.
    IF sy-subrc <> 0.
* & -- Error in BDC Session &
      MESSAGE i051 WITH c_group.
      LEAVE TO LIST-PROCESSING.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF gv_bdc_flag IS NOT INITIAL
****************End of Changes by Jahan
  IF fp_i_error IS NOT INITIAL.

    CLEAR lwa_error.
    lwa_error-string = gv_header. "set header of Error file
    INSERT lwa_error INTO fp_i_error INDEX c_1.
    CLEAR lwa_error.
  ENDIF. " IF fp_i_error IS NOT INITIAL

  IF fp_i_done IS NOT INITIAL.

    CLEAR lwa_done.
    lwa_done-string = gv_header. "set header of done file
    INSERT lwa_done INTO fp_i_done INDEX c_1.
    CLEAR lwa_done.
  ENDIF. " IF fp_i_done IS NOT INITIAL

  FREE: li_bdcmsg,
        li_data .
ENDFORM. " F_CALL_BDC
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_DUPLICATE
*&---------------------------------------------------------------------*
*       Check if duplicate record
*----------------------------------------------------------------------*
*      -->FP_WA_DATA  text
*      <--FP_V_DFLAG  text
*----------------------------------------------------------------------*
FORM f_check_duplicate  USING    fp_wa_data   TYPE ty_data
                        CHANGING fp_v_dflag   TYPE char1. " V_dflag of type CHAR1

  READ TABLE i_knmt TRANSPORTING NO FIELDS
  WITH KEY vkorg = fp_wa_data-vkorg
           vtweg = fp_wa_data-vtweg
           kunnr = fp_wa_data-kunnr
           matnr = fp_wa_data-matnr BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    fp_v_dflag = abap_true. "duplicate record in KNMT found
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    CLEAR fp_v_dflag.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_CHECK_DUPLICATE
*&---------------------------------------------------------------------*
*&      Form  F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       BDC Screen POPULATION
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
FORM f_bdc_field  USING    fp_v_fnam    TYPE fnam_____4 " Field name
                           fp_v_fval    TYPE any.

  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure

  lwa_bdcdata-fnam = fp_v_fnam.
  lwa_bdcdata-fval = fp_v_fval.

  IF lwa_bdcdata-fval IS NOT INITIAL.
    CONDENSE lwa_bdcdata-fval.
  ENDIF. " IF lwa_bdcdata-fval IS NOT INITIAL
  APPEND lwa_bdcdata TO i_bdcdata.
  CLEAR lwa_bdcdata.

ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_CUSTOMER_INPUT
*&---------------------------------------------------------------------*
*       convert customer input
*----------------------------------------------------------------------*
*      <--FP_KUNNR  customer
*----------------------------------------------------------------------*
FORM f_customer_input  CHANGING fp_kunnr TYPE kunnr. " Customer Number

  IF fp_kunnr IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fp_kunnr
      IMPORTING
        output = fp_kunnr.
  ENDIF. " IF fp_kunnr IS NOT INITIAL

ENDFORM. " F_CUSTOMER_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_CUSTOMER_OUTPUT
*&---------------------------------------------------------------------*
*       convert customer output
*----------------------------------------------------------------------*
*      <--FP_KUNNR  Customer
*----------------------------------------------------------------------*
FORM f_customer_output  CHANGING fp_kunnr TYPE kunnr. " Customer Number

  IF fp_kunnr IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = fp_kunnr
      IMPORTING
        output = fp_kunnr.
  ENDIF. " IF fp_kunnr IS NOT INITIAL

ENDFORM. " F_CUSTOMER_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_TEXT
*&---------------------------------------------------------------------*
*       check Text exist
*----------------------------------------------------------------------*
*      -->FP_LWA_DATA_VKORG  Sales Organization
*      -->FP_LWA_DATA_VTWEG  Distribution Channel
*      -->FP_LWA_DATA_KUNNR  Customer number
*      -->FP_LWA_DATA_MATNR  Material Number
*      -->FP_LWA_DATA_SPRAS1 Language Key
*      <--FP_lv_exist Language Key
*----------------------------------------------------------------------*
FORM f_check_text  USING    fp_lwa_data_vkorg TYPE vkorg   " Sales Organization
                            fp_lwa_data_vtweg TYPE vtweg   " Distribution Channel
                            fp_lwa_data_kunnr TYPE kunnr_v " Customer number
                            fp_lwa_data_matnr TYPE matnr   " Material Number
                            fp_lwa_data_spras TYPE char2   " Lwa_data_spras of type CHAR2
                  CHANGING  fp_lv_exist       TYPE char1.  " Lv_exist of type CHAR1



  DATA : lv_name     TYPE tdobname,                " Name
         lv_language TYPE spras,                   " Language Key
         lv_error_txt TYPE string,
         li_lines    TYPE STANDARD TABLE OF tline. " SAPscript: Text Lines

  CONSTANTS : lc_id     TYPE tdid       VALUE '0001', " Text ID
              lc_object TYPE tdobject   VALUE 'KNMT'. " Texts: Application Object

  CONCATENATE fp_lwa_data_vkorg fp_lwa_data_vtweg fp_lwa_data_kunnr
              fp_lwa_data_matnr INTO lv_name.

 "conversion language
  PERFORM f_input_language     USING fp_lwa_data_spras
                            CHANGING lv_language
                                     lv_error_txt.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = lc_id
      language                = lv_language
      name                    = lv_name
      object                  = lc_object
    TABLES
      lines                   = li_lines
    EXCEPTIONS
      id                      = c_1
      language                = c_2
      name                    = c_3
      not_found               = c_4
      object                  = c_5
      reference_check         = c_6
      wrong_access_to_archive = c_7
      OTHERS                  = c_8.
  IF sy-subrc IS NOT INITIAL.
* Object may not exist, hence, do nothing.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

 "if duplicate text exixt
    fp_lv_exist = abap_true.
    FREE: li_lines.

  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_CHECK_TEXT
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_TEXT
*&---------------------------------------------------------------------*
*       Delete text before creating new
*----------------------------------------------------------------------*
*      -->FP_LWA_DATA_VKORG  Sales Organization
*      -->FP_LWA_DATA_VTWEG  Distribution Channel
*      -->FP_LWA_DATA_KUNNR  Customer number
*      -->FP_LWA_DATA_MATNR  Material Number
*      -->FP_LWA_DATA_SPRAS1 Language Key
*      <--FP_I_REPORT        Error Report
*----------------------------------------------------------------------*
FORM f_delete_text  USING    fp_lwa_data_vkorg  TYPE vkorg   " Sales Organization
                             fp_lwa_data_vtweg  TYPE vtweg   " Distribution Channel
                             fp_lwa_data_kunnr  TYPE kunnr_v " Customer number
                             fp_lwa_data_matnr  TYPE matnr   " Material Number
                             fp_lwa_data_spras  TYPE char2   " Lwa_data_spras of type CHAR2
                   CHANGING  fp_i_report        TYPE ty_t_report.

  DATA : lv_name     TYPE tdobname, " Name
         lv_language TYPE spras,    " Language Key
         lwa_report  TYPE ty_report,
         lv_error_txt TYPE string.


  CONSTANTS : lc_id     TYPE tdid       VALUE '0001', " Text ID
              lc_object TYPE tdobject   VALUE 'KNMT'. " Texts: Application Object

  CONCATENATE fp_lwa_data_vkorg fp_lwa_data_vtweg fp_lwa_data_kunnr
              fp_lwa_data_matnr INTO lv_name.

  PERFORM f_input_language     USING fp_lwa_data_spras
                            CHANGING lv_language
                                     lv_error_txt.

  IF lv_error_txt IS NOT INITIAL.
    lwa_report-msgtyp = c_error.
    lwa_report-msgtxt = lv_error_txt.
    lwa_report-vkorg  = fp_lwa_data_vkorg.
    lwa_report-kunnr  = fp_lwa_data_kunnr.
    lwa_report-matnr  = fp_lwa_data_matnr.

    APPEND lwa_report TO fp_i_report. "Fill error report to display
    CLEAR lwa_report.

  ENDIF. " IF lv_error_txt IS NOT INITIAL

  CALL FUNCTION 'DELETE_TEXT'
    EXPORTING
      client          = sy-mandt
      id              = lc_id
      language        = lv_language
      name            = lv_name
      object          = lc_object
      savemode_direct = abap_true
    EXCEPTIONS
      not_found       = c_1
      OTHERS          = c_2.
  IF sy-subrc IS NOT INITIAL.
    lwa_report-msgtyp = c_error.
    lwa_report-msgtxt = 'Unable to delete existing text'(019).
    lwa_report-vkorg  = fp_lwa_data_vkorg.
    lwa_report-kunnr  = fp_lwa_data_kunnr.
    lwa_report-matnr  = fp_lwa_data_matnr.

    APPEND lwa_report TO fp_i_report. "Fill error report to display
    CLEAR lwa_report.

  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_DELETE_TEXT
*&---------------------------------------------------------------------*
*&      Form  F_INPUT_LANGUAGE
*&---------------------------------------------------------------------*
*       conversion language
*----------------------------------------------------------------------*
*      -->FP_LWA_DATA_SPRAS  language
*      <--FP_V_LANGUAGE      language
*      <--FP_V_error_txt     error text
*----------------------------------------------------------------------*
FORM f_input_language   USING    fp_lwa_data_spras  TYPE char2 " Input_language using fp of type CHAR2
                        CHANGING fp_v_language     TYPE spras  " Language Key
                                 fp_v_error_txt    TYPE string.


  IF  fp_lwa_data_spras IS NOT INITIAL.

    CALL FUNCTION 'CONVERSION_EXIT_ISOLA_INPUT'
      EXPORTING
        input            = fp_lwa_data_spras
      IMPORTING
        output           = fp_v_language
      EXCEPTIONS
        unknown_language = c_1
        OTHERS           = c_2.
    IF sy-subrc IS NOT INITIAL.
      CONCATENATE sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO
      fp_v_error_txt.
    ENDIF. " IF sy-subrc IS NOT INITIAL
  ENDIF. " IF fp_lwa_data_spras IS NOT INITIAL

ENDFORM. " F_INPUT_LANGUAGE
*&---------------------------------------------------------------------*
*&      Form  F_VERIFY_FILE
*&---------------------------------------------------------------------*
*       verify file structure
*----------------------------------------------------------------------*
*      -->FP_GV_HEADER  header
*----------------------------------------------------------------------*
FORM f_verify_file  USING    fp_gv_header TYPE string.

  DATA : li_result     TYPE match_result_tab,
         lv_total      TYPE sytabix. " Total of type Integers

  CONSTANTS : lc_pipe  TYPE char1    VALUE '|',  " Pipe of type CHAR1
              lc_count TYPE char2    VALUE '30'. " Count of type CHAR2

  FIND ALL OCCURRENCES OF lc_pipe IN fp_gv_header
  RESULTS li_result.
  IF li_result IS NOT INITIAL.

    DESCRIBE TABLE li_result LINES lv_total.

    IF lv_total EQ lc_count. "no. of column is 31, hence ok

      MESSAGE i065.
      LEAVE LIST-PROCESSING.

    ELSE. " ELSE -> IF lv_total EQ lc_count

      MESSAGE i076.
      LEAVE LIST-PROCESSING.

    ENDIF. " IF lv_total EQ lc_count
  ENDIF. " IF li_result IS NOT INITIAL

ENDFORM. " F_VERIFY_FILE
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*       Moving Error file to Error folder.
*----------------------------------------------------------------------*
*      -->FP_P_AFILE         Source file path
*      -->FP_I_error[]       Error Log
*      <--FP_I_REPORT        ALV Report
*----------------------------------------------------------------------*
FORM f_move_error  USING  fp_p_afile      TYPE localfile " Local file for upload/download
                          fp_i_error      TYPE ty_t_string
                 CHANGING fp_i_report     TYPE ty_t_report.
* Local Data
  DATA: lv_file        TYPE localfile, "File Name
        lv_name        TYPE localfile, "File Name
        lv_ext         TYPE char10,    "file extension
        lv_name1       TYPE localfile, "File Name
        lwa_report     TYPE ty_report,
        lv_flag        TYPE flag,      "General Flag Authorization check
        lv_data        TYPE string.    "Output data string

  CONSTANTS: lc_slash      TYPE char1 VALUE '/',      " Slash of type CHAR1
             lc_tobeprscd  TYPE char3 VALUE 'TBP',    " TBP
             lc_activity   TYPE char5 VALUE 'WRITE',  "File activity read/write"_Error
             lc_suffix     TYPE char6 VALUE '_Error', "file suffix
             lc_dot        TYPE char1 VALUE '.',      "Dot
             lc_error_fold TYPE char5 VALUE 'ERROR'. " Error

  FIELD-SYMBOLS: <lfs_out_string> TYPE ty_string.

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

 "split file name and extension
  SPLIT lv_name AT lc_dot INTO lv_name1 lv_ext.

 "add suffix '_Error' to error file name
  CONCATENATE lv_name1 lc_suffix lc_dot lv_ext INTO lv_name.

* Changing the file path to ERROR folder
  REPLACE lc_tobeprscd IN lv_file WITH lc_error_fold.
  CONCATENATE lv_file lc_slash lv_name INTO lv_file.

 "check authorization for file
  PERFORM f_authorization_check USING   lv_file
                                        lc_activity
                               CHANGING lv_flag.
  IF lv_flag IS INITIAL.
    "Authorized

* Write the records
    OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING UTF-8. " Output type
    IF sy-subrc NE 0.
      CLEAR lwa_report.
      lwa_report-msgtyp = c_error.
      CONCATENATE 'Error Log cannot be uploaded to'(067) lv_file
      INTO lwa_report-msgtxt SEPARATED BY space.

      APPEND lwa_report TO fp_i_report.
      CLEAR: lwa_report.
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Passing the Erroneous Header data
      LOOP AT fp_i_error ASSIGNING <lfs_out_string>.
        lv_data = <lfs_out_string>-string.
*     Transferring the data into application server.
        TRANSFER lv_data TO lv_file.
        CLEAR lv_data.
      ENDLOOP. " LOOP AT fp_i_error ASSIGNING <lfs_out_string>

      CLEAR lwa_report.
      lwa_report-msgtyp = c_info.
      CONCATENATE 'Error Log successfully uploaded to'(068) lv_file
      INTO lwa_report-msgtxt SEPARATED BY space.

      APPEND lwa_report TO fp_i_report.
      CLEAR: lwa_report.

****************Changes by Jahan
* Delete file from TBP after to moved to ERROR folder.
      OPEN DATASET fp_p_afile FOR INPUT IN TEXT MODE ENCODING UTF-8. " Output type
      IF sy-subrc NE 0.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE 'Input file could not be deleted from TBD folder'(069) lv_file
        INTO lwa_report-msgtxt SEPARATED BY space.

        APPEND lwa_report TO fp_i_report.
        CLEAR: lwa_report.
      ELSE. " ELSE -> IF sy-subrc NE 0

        DELETE DATASET fp_p_afile.

        IF sy-subrc NE 0.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE 'Input file deleted from TBD folder'(067) lv_file
        INTO lwa_report-msgtxt SEPARATED BY space.

        APPEND lwa_report TO fp_i_report.
        CLEAR: lwa_report.

        ELSE. " ELSE -> IF SY-SUBRC NE 0
          CLOSE DATASET fp_p_afile.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE 'Input file could not be deleted from TBD folder'(069) lv_file
        INTO lwa_report-msgtxt SEPARATED BY space.

        APPEND lwa_report TO fp_i_report.
        CLEAR: lwa_report.
        ENDIF. " IF SY-SUBRC NE 0

      ENDIF. " IF sy-subrc NE 0

****************End of Changes by Jahan

    ENDIF. " IF sy-subrc NE 0
    CLOSE DATASET lv_file.

  ELSE. " ELSE -> IF lv_flag IS INITIAL
 "Not Authorized
    CLEAR lwa_report.
    lwa_report-msgtyp = c_info.
    CONCATENATE 'No authorization to Write file.'(022) lv_file
    INTO lwa_report-msgtxt SEPARATED BY space.

  ENDIF. " IF lv_flag IS INITIAL

ENDFORM. " F_MOVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_SUCCESS
*&---------------------------------------------------------------------*
*       Moving success file to done folder.
*----------------------------------------------------------------------*
*      -->FP_P_AFILE         Source file path
*      -->FP_I_done[]       Success Log
*      <--FP_I_REPORT        ALV Report
*----------------------------------------------------------------------*
FORM f_move_success  USING    fp_p_afile      TYPE localfile " Local file for upload/download
                              fp_i_done       TYPE ty_t_string
                     CHANGING fp_i_report     TYPE ty_t_report.

* Local Data
  DATA: lv_file        TYPE localfile, "File Name
        lv_name        TYPE localfile, "File Name
        lwa_report     TYPE ty_report,
        lv_flag        TYPE flag,      "General Flag Authorization check
        lv_data        TYPE string.    "Output data string

  CONSTANTS: lc_slash      TYPE char1 VALUE '/',     " Slash of type CHAR1
             lc_tobeprscd  TYPE char3 VALUE 'TBP',   " TBP
             lc_activity   TYPE char5 VALUE 'WRITE', "File activity read/write
             lc_done_fold  TYPE char4 VALUE 'DONE'.  " Done

  FIELD-SYMBOLS: <lfs_out_string> TYPE ty_string.

* Spitting Filae Path & File Name
  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = fp_p_afile
    IMPORTING
      pathname = lv_file
      filename = lv_name.

* Changing the file path to ERROR folder
  REPLACE lc_tobeprscd IN lv_file WITH lc_done_fold.
  CONCATENATE lv_file lc_slash lv_name INTO lv_file.

 "check authorization for file
  PERFORM f_authorization_check USING   lv_file
                                        lc_activity
                               CHANGING lv_flag.
  IF lv_flag IS INITIAL.
    "Authorized

* Write the records
    OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING UTF-8. " Output type
    IF sy-subrc NE 0.
      CLEAR lwa_report.
      lwa_report-msgtyp = c_error.
      CONCATENATE 'Success Log cannot be uploaded to'(023) lv_file
      INTO lwa_report-msgtxt SEPARATED BY space.

      APPEND lwa_report TO fp_i_report.
      CLEAR: lwa_report.
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Passing the Erroneous Header data
      LOOP AT fp_i_done ASSIGNING <lfs_out_string>.
        lv_data = <lfs_out_string>-string.
*     Transferring the data into application server.
        TRANSFER lv_data TO lv_file.
        CLEAR lv_data.
      ENDLOOP. " LOOP AT fp_i_done ASSIGNING <lfs_out_string>

      CLEAR lwa_report.
      lwa_report-msgtyp = c_info.
      CONCATENATE 'Success Log successfully uploaded to'(024) lv_file
      INTO lwa_report-msgtxt SEPARATED BY space.

      APPEND lwa_report TO fp_i_report.
      CLEAR: lwa_report.

****************Changes by Jahan
*----------------------------------------------------------------------*
* Delete file from TBP after to moved to ERROR folder.
      OPEN DATASET fp_p_afile FOR INPUT IN TEXT MODE ENCODING UTF-8. " Output type
      IF sy-subrc NE 0.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE 'Input file could not be deleted from TBD folder'(069) lv_file
        INTO lwa_report-msgtxt SEPARATED BY space.

        APPEND lwa_report TO fp_i_report.
        CLEAR: lwa_report.
      ELSE. " ELSE -> IF sy-subrc NE 0

        DELETE DATASET fp_p_afile.

        IF sy-subrc NE 0.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE 'Input file deleted from TBD folder'(067) lv_file
        INTO lwa_report-msgtxt SEPARATED BY space.

        APPEND lwa_report TO fp_i_report.
        CLEAR: lwa_report.

        ELSE. " ELSE -> IF SY-SUBRC NE 0
          CLOSE DATASET fp_p_afile.
        CLEAR lwa_report.
        lwa_report-msgtyp = c_error.
        CONCATENATE 'Input file could not be deleted from TBD folder'(069) lv_file
        INTO lwa_report-msgtxt SEPARATED BY space.

        APPEND lwa_report TO fp_i_report.
        CLEAR: lwa_report.
        ENDIF. " IF SY-SUBRC NE 0

      ENDIF. " IF sy-subrc NE 0
****************End of Changes by Jahan
*----------------------------------------------------------------------*

    ENDIF. " IF sy-subrc NE 0
    CLOSE DATASET lv_file.
  ELSE. " ELSE -> IF lv_flag IS INITIAL
 "Not Authorized

    CLEAR lwa_report.
    lwa_report-msgtyp = c_info.
    CONCATENATE 'No authorization to Write file.'(022) lv_file
    INTO lwa_report-msgtxt SEPARATED BY space.

  ENDIF. " IF lv_flag IS INITIAL

ENDFORM. " F_MOVE_SUCCESS
*&---------------------------------------------------------------------*
*&      Form  f_display_summary_report1
*&---------------------------------------------------------------------*
*       Dispalying Summary Report for ONE INPUT FILE.
*&---------------------------------------------------------------------*
*      -->FP_P_REPORT     Report Table
*      -->FP_gv_filename_d  Input File Name
*      -->FP_GV_MODE      Mode of execution of program
*      -->FP_NO_SUCCESS   Number of successfully processed record.
*      -->FP_NO_FAILED    Number of record failed.
*----------------------------------------------------------------------*
FORM f_display_summary_report1 USING fp_i_report      TYPE ty_t_report
                                    fp_gv_filename_d  TYPE localfile " Local file for upload/download
                                    fp_gv_mode        TYPE char15    " Gv_mode of type CHAR10
                                    fp_no_success     TYPE int2      " 2 byte integer (signed)
                                    fp_no_failed      TYPE int2.     " 2 byte integer (signed)
* Local Data declaration
  TYPES: BEGIN OF lty_report_b,
          msgtyp TYPE char1,   "Error Type
          msgtxt TYPE char256, "Error Text
          vkorg  TYPE vkorg,   "Sales Organization
          kunnr  TYPE kunnr_v, "Customer number
          matnr  TYPE matnr,   "Material Number
         END OF lty_report_b.

  CONSTANTS: lc_hline TYPE char100           " Dotted Line
             VALUE
'-----------------------------------------------------------',
              lc_slash TYPE char1 VALUE '/'. " Slash of type CHAR1
  CONSTANTS : lc_20      TYPE char2  VALUE '20',                    " 150 of type CHAR3
              lc_7       TYPE char1  VALUE '7',                     " 150 of type CHAR3
              lc_msgtyp  TYPE slis_fieldname VALUE 'MSGTYP',
              lc_msgtxt  TYPE slis_fieldname VALUE 'MSGTXT',
              lc_vkorg   TYPE slis_fieldname VALUE 'VKORG',
              lc_kunnr   TYPE slis_fieldname VALUE 'KUNNR',
              lc_matnr   TYPE slis_fieldname VALUE 'MATNR',
              lc_colon   TYPE char1          VALUE ':',             " Colon of type CHAR1
              lc_group   TYPE apqi-groupid   VALUE   'OTC_0138',    " Session Name
              lc_top_of_page TYPE char15     VALUE 'TOP_OF_PAGE',   " Top_of_page of type CHAR15
              lc_form_top    TYPE char15     VALUE 'F_TOP_OF_PAGE', " Form_top of type CHAR15
              lc_tab     TYPE slis_tabname   VALUE 'LI_REPORT_B'.


  DATA: li_report      TYPE STANDARD TABLE OF lty_report_b
                                                     INITIAL SIZE 0,
        lv_uzeit       TYPE char20,                          "Time
        lv_datum       TYPE char20,                          "Date
        lv_total       TYPE sytabix,                         "Total
        lv_rate        TYPE sytabix,                         "Rate
        lv_rate_c      TYPE char5,                           "Rate text
        lv_alv         TYPE REF TO cl_salv_table,            "ALV Inst.
        lv_ex_msg      TYPE REF TO cx_salv_msg,              "Message
        lv_ex_notfound TYPE REF TO cx_salv_not_found,        "Exception
        lv_grid        TYPE REF TO cl_salv_form_layout_grid, "Grid
        lv_gridx       TYPE REF TO cl_salv_form_layout_grid, "Grid X
        lv_column      TYPE REF TO cl_salv_column_table,     "Column
        lv_columns     TYPE REF TO cl_salv_columns_table,    "Column X
        lv_func        TYPE REF TO cl_salv_functions_list,   "Toolbar
        lv_archive_1   TYPE localfile,                       "Archieve File Path
        lv_session_1   TYPE apq_grpn,                        "BDC Session Name
        lv_session_2   TYPE apq_grpn,                        "BDC Session Name
        lv_session_3   TYPE apq_grpn,                        "BDC Session Name
        lv_session     TYPE char90,                          "All session names
        lv_text        TYPE char50,                          "text message
        lv_text1       TYPE char50,                          "text message
        lv_text_s      TYPE scrtext_s,                       "text message
        lv_text_m      TYPE scrtext_m,                       "text message
        lv_text_l      TYPE scrtext_l,                       "text message
        lv_row         TYPE sytabix,                         "Row number
        lv_width_msg   TYPE outputlen,                       "Column Width
        lv_width_msgty TYPE outputlen,                       "Column Width
        lv_width_vkorg TYPE outputlen,                       "Column Width
        lv_width_kunnr TYPE outputlen,                       "Column Width
        lv_width_matnr TYPE outputlen,                       "Column Width
        li_fieldcat    TYPE slis_t_fieldcat_alv,             "Field Catalog
        li_events      TYPE slis_t_event,
        lwa_events     TYPE slis_alv_event,
        li_report_b    TYPE STANDARD TABLE OF lty_report_b INITIAL SIZE 0,
        lwa_report_b   TYPE lty_report_b.

  FIELD-SYMBOLS: <lfs_rep> TYPE ty_report.

* Getting the archieve file path from Global Variables
  lv_archive_1 = gv_archive_gl_1.

* Importing the First Session Names
  lv_session_1 = gv_session_gl_1.

* Importing the Second Session Names
  lv_session_2 = gv_session_gl_2.

* Importing the Third Session Names
  lv_session_3 = gv_session_gl_3.

* Forming the BDC session name
  IF lv_session_1 IS NOT INITIAL.
    lv_session = lv_session_1.
  ENDIF. " IF lv_session_1 IS NOT INITIAL

  IF lv_session_2 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session lc_slash lv_session_2
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_2.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_2 IS NOT INITIAL

  IF lv_session_3 IS NOT INITIAL.
    IF lv_session IS NOT INITIAL.
      CONCATENATE lv_session lc_slash lv_session_3
      INTO lv_session SEPARATED BY space.
    ELSE. " ELSE -> IF lv_session IS NOT INITIAL
      lv_session = lv_session_3.
    ENDIF. " IF lv_session IS NOT INITIAL
  ENDIF. " IF lv_session_3 IS NOT INITIAL

  IF lv_session IS NOT INITIAL.
    CONCATENATE lv_session text-x32 INTO lv_session
    SEPARATED BY space.
  ENDIF. " IF lv_session IS NOT INITIAL

  LOOP AT fp_i_report ASSIGNING <lfs_rep>.
    lwa_report_b-msgtyp = <lfs_rep>-msgtyp.
    lwa_report_b-msgtxt = <lfs_rep>-msgtxt.
    lwa_report_b-vkorg =  <lfs_rep>-vkorg.
    lwa_report_b-kunnr =  <lfs_rep>-kunnr.
    lwa_report_b-matnr =  <lfs_rep>-matnr.
    APPEND lwa_report_b TO li_report.
    CLEAR lwa_report_b.
  ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_rep>
*
  WRITE sy-uzeit TO lv_uzeit.
  WRITE sy-datum TO lv_datum.
  CONCATENATE lv_datum lv_uzeit INTO lv_datum SEPARATED BY space.

  lv_total = fp_no_success + fp_no_failed.
  IF lv_total <> 0.
    lv_rate = 100 * fp_no_success / lv_total.
  ENDIF. " IF lv_total <> 0

  WRITE lv_rate TO lv_rate_c.
  CONDENSE lv_rate_c.
  CONCATENATE lv_rate_c c_percentage INTO lv_rate_c SEPARATED BY space.

* For ONLINE run, ALV Grid Display
  IF sy-batch IS INITIAL.

    TRY.
        CALL METHOD cl_salv_table=>factory
          IMPORTING
            r_salv_table = lv_alv
          CHANGING
            t_table      = li_report.
      CATCH cx_salv_msg INTO lv_ex_msg.
        MESSAGE lv_ex_msg TYPE 'E'.
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.

    CREATE OBJECT lv_grid.
    lv_row = 1.

    CLEAR lv_text.
    lv_text = 'Run Information'(x01). "text-x01
    CLEAR lv_text1.
    lv_text1 = 'File Read'(x02). "text-x02

    lv_grid->create_header_information( row     = lv_row
                                        column  = lv_row
                                        text    = lv_text     "text-x01
                                        tooltip = lv_text1 ). "text-x02

    lv_row = lv_row + 1.
    lv_gridx = lv_grid->create_grid( row = lv_row  column = 1  ).

    lv_gridx->create_label( row = lv_row column = 1
                           text = lc_hline ).
    lv_row = lv_row + 1.
* File Read
    CLEAR lv_text1.
    lv_text1 = 'File Read'(x02). "text-x02
    lv_gridx->create_label( row = lv_row column = 1
                            text = lv_text1 tooltip = lv_text1 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_filename_d ).

    lv_row = lv_row + 1.
* File Archived.
    IF lv_archive_1 IS NOT INITIAL.

      CLEAR lv_text.
      lv_text = 'Customer'(x28). "text-x28
      lv_gridx->create_label( row = lv_row column = 1
                              text = lv_text tooltip = lv_text ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = lc_colon ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_archive_1 ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_archive_1 IS NOT INITIAL

    CLEAR lv_text.
    lv_text = 'Client'(x03). "text-x03
    lv_gridx->create_label( row = lv_row column = 1
                            text = lv_text tooltip = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-mandt ).
    lv_row = lv_row + 1.
    CLEAR lv_text.
    lv_text = 'Run By / User ID'(x04). "text-x04
    lv_gridx->create_label( row = lv_row column = 1
                           text = lv_text tooltip = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-uname ).
    lv_row = lv_row + 1.
    CLEAR lv_text.
    lv_text = 'Date / Time'(x05). "text-x05
    lv_gridx->create_label( row = lv_row column = 1
                           text = lv_text tooltip = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_datum ).
    lv_row = lv_row + 1.

    CLEAR lv_text.
    lv_text = 'Execution Mode'(x06). "text-x06
    lv_gridx->create_label( row = lv_row column = 1
                           text = lv_text tooltip = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_mode ).
    lv_row = lv_row + 1.

    IF lv_session IS NOT INITIAL.

      CLEAR lv_text.
      lv_text = 'BDC Session Name:'(x29). "text-x29
      lv_gridx->create_label( row = lv_row column = 1
                             text = lv_text tooltip = lv_text ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = lc_colon ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_session ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_session IS NOT INITIAL

    lv_gridx->add_row( ).

    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = lc_hline ).
    lv_row = lv_row + 1.
    CLEAR lv_text.
    lv_text = 'Total no of records in given file'(x08). "text-x08
    lv_gridx->create_label( row = lv_row column = 1
                         text = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_total ).
    lv_row = lv_row + 1.
    CLEAR lv_text.
    lv_text = text-x09. " 'No of success records'(x09). "text-x09
    lv_gridx->create_label( row = lv_row column = 1
                         text = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_success ).
    lv_row = lv_row + 1.

    CLEAR lv_text.
    lv_text = 'No of error records'(x10). "text-x10
    lv_gridx->create_label( row = lv_row column = 1
                         text = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_failed ).
    lv_row = lv_row + 1.

    CLEAR lv_text.
    lv_text = 'Success Rate'(x11). "text-x11
    lv_gridx->create_label( row = lv_row column = 1
                         text = lv_text ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = lc_colon ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_rate_c ).

    lv_row = lv_row + 1.

    IF gv_bdc_flag IS NOT INITIAL.

      CLEAR lv_text.
      lv_text = 'BDC Error Session Created'(x33). "text-x10
      lv_gridx->create_label( row = lv_row column = 1
                           text = lv_text ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = lc_colon ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lc_group ).
      lv_row = lv_row + 1.
    ENDIF. " IF gv_bdc_flag IS NOT INITIAL

    lv_gridx->create_label( row = lv_row column = 1
                           text = lc_hline ).

    CALL METHOD lv_alv->set_top_of_list( lv_grid ).

    CALL METHOD lv_alv->get_columns
      RECEIVING
        value = lv_columns.

    TRY.
        lv_column ?= lv_columns->get_column( lc_msgtyp ). "MSGTYP
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE c_error.
    ENDTRY.
    CLEAR : lv_text_s,
            lv_text_m,
            lv_text_l.
    lv_text_s = 'Status'(x12). "text-x12
    lv_text_m = 'Status'(x12). "text-x12
    lv_text_l = 'Status'(x12). "text-x12
    lv_column->set_short_text( lv_text_s ).
    lv_column->set_medium_text( lv_text_m ).
    lv_column->set_long_text( lv_text_l ).
    lv_columns->set_optimize( abap_true ).

    TRY.
        lv_column ?= lv_columns->get_column( lc_msgtxt ). "MSGTXT
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE c_error.
    ENDTRY.
    CLEAR : lv_text_s,
            lv_text_m,
            lv_text_l.
    lv_text_s = 'Message'(x13). "text-x13
    lv_text_m = 'Message'(x13). "text-x13
    lv_text_l = 'Message'(x13). "text-x13
    lv_column->set_short_text( lv_text_s ).
    lv_column->set_medium_text( lv_text_m ).
    lv_column->set_long_text( lv_text_l ).
    lv_columns->set_optimize( abap_true ).

    TRY.
        lv_column ?= lv_columns->get_column( lc_vkorg ). "vkorg
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE c_error.
    ENDTRY.

    CLEAR : lv_text_s,
            lv_text_m,
            lv_text_l.
    lv_text_s = 'Sales Org'(x14). "text-x14
    lv_text_m = 'Sales Org'(x14). "text-x14
    lv_text_l = 'Sales Org'(x14). "text-x14
    lv_column->set_short_text( lv_text_s ).
    lv_column->set_medium_text( lv_text_m ).
    lv_column->set_long_text( lv_text_l ).
    lv_columns->set_optimize( abap_true ).

    TRY.
        lv_column ?= lv_columns->get_column( lc_kunnr ). "kunnr
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE c_error.
    ENDTRY.

    CLEAR : lv_text_s,
            lv_text_m,
            lv_text_l.
    lv_text_s = 'Customer'(x28). "text-x28
    lv_text_m = 'Customer'(x28). "text-x28
    lv_text_l = 'Customer'(x28). "text-x28
    lv_column->set_short_text( lv_text_s ).
    lv_column->set_medium_text( lv_text_m ).
    lv_column->set_long_text( lv_text_l ).
    lv_columns->set_optimize( abap_true ).

    TRY.
        lv_column ?= lv_columns->get_column( lc_matnr ). "matnr
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE c_error.
    ENDTRY.

    CLEAR : lv_text_s,
            lv_text_m,
            lv_text_l.
    lv_text_s = 'Material'(x31). "text-x31
    lv_text_m = 'Material'(x31). "text-x31
    lv_text_l = 'Material'(x31). "text-x31
    lv_column->set_short_text( lv_text_s ).
    lv_column->set_medium_text( lv_text_m ).
    lv_column->set_long_text( lv_text_l ).
    lv_columns->set_optimize( abap_true ).

* Function Tool bars
    lv_func = lv_alv->get_functions( ).
    lv_func->set_all( ).

* Displaying the report
    CALL METHOD lv_alv->display( ).

* For Background Run - ALV List
  ELSE. " ELSE -> IF sy-batch IS INITIAL
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_session = lv_session.
    gv_total = lv_total.
    gv_no_success = fp_no_success.
    gv_no_failed = fp_no_failed.
    gv_rate_c = lv_rate_c.

    LOOP AT fp_i_report ASSIGNING <lfs_rep>.
      lwa_report_b-msgtyp = <lfs_rep>-msgtyp.
      lwa_report_b-msgtxt = <lfs_rep>-msgtxt.
      lwa_report_b-vkorg = <lfs_rep>-vkorg.
      lwa_report_b-kunnr = <lfs_rep>-kunnr.
      lwa_report_b-matnr = <lfs_rep>-matnr.

*     Getting the maximum length of columns MSGTXT.
      IF lv_width_msg   LT strlen( <lfs_rep>-msgtxt ).
        lv_width_msg = strlen( <lfs_rep>-msgtxt ).
      ENDIF. " IF lv_width_msg LT strlen( <lfs_rep>-msgtxt )


      APPEND lwa_report_b TO li_report_b.
      CLEAR lwa_report_b.
    ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_rep>

*     setting the maximum length of column vkorg.
    lv_width_vkorg = lc_20.
*     setting the maximum length of column kunnr.
    lv_width_kunnr = lc_20.
*     setting the maximum length of column matnr.
    lv_width_matnr = lc_20.
*     setting the maximum length of column msgtyp.
    lv_width_msgty = lc_7.

*   Preparing Field Catalog.
*   Message Type
    CLEAR lv_text_l.
    lv_text_l = 'Status'(x12). "text-x12
    PERFORM f_fill_fieldcat USING lc_msgtyp "MSGTYP'
                                  lc_tab
                                  lv_text_l "text-x12
                                  lv_width_msgty
                          CHANGING li_fieldcat[].
*   Message Text
    CLEAR lv_text_l.
    lv_text_l = 'Message'(x13). "text-x13
    PERFORM f_fill_fieldcat USING  lc_msgtxt "'MSGTXT'
                                  lc_tab
                                  lv_text_l
                                  lv_width_msg
                          CHANGING li_fieldcat[].
*   Message vkorg
    CLEAR lv_text_l.
    lv_text_l = 'Sales Org'(x14). "text-x14
    PERFORM f_fill_fieldcat USING lc_vkorg "vkorg
                                  lc_tab
                                  lv_text_l
                                  lv_width_vkorg
                          CHANGING li_fieldcat[].

*   Message kunnr
    CLEAR lv_text_l.
    lv_text_l = 'Customer'(x28). "text-x28
    PERFORM f_fill_fieldcat USING lc_kunnr "kunnr
                                  lc_tab
                                  lv_text_l
                                  lv_width_kunnr
                          CHANGING li_fieldcat[].

*   Message vkorg
    CLEAR lv_text_l.
    lv_text_l = 'Material'(x31). "text-x31
    PERFORM f_fill_fieldcat USING lc_matnr "matnr
                                  lc_tab
                                  lv_text_l
                                  lv_width_matnr
                          CHANGING li_fieldcat[].



*   Top of page subroutine
    lwa_events-name = lc_top_of_page. "'TOP_OF_PAGE'..
    lwa_events-form = lc_form_top. "'F_TOP_OF_PAGE'.
    APPEND lwa_events TO li_events.
    CLEAR lwa_events.
*   ALV List Display for Background Run
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = li_fieldcat
        it_events          = li_events
      TABLES
        t_outtab           = li_report_b
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE e132. " Issue in ALV display..
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch IS INITIAL

  FREE: li_report,
        li_report_b ,
        li_events .
ENDFORM. "display_summary_report
*&---------------------------------------------------------------------*
*&      Form  F_ALL_VERIFIED
*&---------------------------------------------------------------------*
*       All Records are successfully verified
*----------------------------------------------------------------------*
*      <--FP_I_REPORT  Report table
*----------------------------------------------------------------------*
FORM f_all_verified  CHANGING fp_i_report TYPE ty_t_report.

  DATA : lwa_report  TYPE ty_report.

  lwa_report-msgtyp = c_success.
  lwa_report-msgtxt = 'All Records are successfully verified'(066).
  APPEND lwa_report TO fp_i_report.
  CLEAR: lwa_report.

ENDFORM. " F_ALL_VERIFIED
*&---------------------------------------------------------------------*
*&      Form  F_ALL_PROCESSED
*&---------------------------------------------------------------------*
*       All Records are successfully processed
*----------------------------------------------------------------------*
*      <--FP_I_REPORT  Report table
*----------------------------------------------------------------------*
FORM f_all_processed  CHANGING fp_i_report TYPE ty_t_report.

  DATA : lwa_report  TYPE ty_report.

  lwa_report-msgtyp = c_success.
  lwa_report-msgtxt = 'All Records are successfully processed'(025).
  APPEND lwa_report TO fp_i_report.
  CLEAR: lwa_report.

ENDFORM. " F_ALL_PROCESSED
