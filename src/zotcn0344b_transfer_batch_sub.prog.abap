***********************************************************************
*Program    : ZOTCN0344B_TRANSFER_BATCH_SUB                           *
*Title      : Include for subroutinees                                *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description:Utility program to upload batch data in custom table     *
*            ZOTC_REST_BATCH and also update prject master table in   *
*            GTS table with batch data.                               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016   U033830      E1DK918373      Initial Development       *
*25-JULY-2016 SBEHERA       E1DK918373      Defect#2932: 1.Changed By,*
*                           Changed On, and Changed Time  - To be auto*
*                           updated and to be Grey-out in display and *
*                           change mode on maintenance screen         *
*                                           2.Created By, Created On, *
*                           and Created Time  - To be auto updated and*
*                           to be Grey-out in display and change mode *
*                           on  maintenance screen.                   *
*---------------------------------------------------------------------*
*                                           ITC1 Defect Issue fixed   *
*29-AUG-2016 SBEHERA        E1DK918373      Defect#3396: Picking file *
*                                           from application server   *
*                                           require authorization     *
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Selection screen dynamic modification
*----------------------------------------------------------------------*
FORM f_modify_screen.

  LOOP AT SCREEN .
*   Presentation Server Option is NOT chosen
    IF rb_pres NE abap_true.
*     Hiding Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3

*   Presentation Server Option IS chosen
    ELSE. " ELSE -> IF rb_pres NE abap_true
*     Disaplying Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE abap_true

*   Application Server Option is NOT chosen
    IF rb_app NE abap_true.
*    hiding 1) application server file physical paths with modify id mi2
*     2) Logical Filename Radio Button with with modify id MI5
*     3) Logical Filename input with modify id MI7
      IF screen-group1    = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF rb_app NE abap_true
*     If Application Server Physical File Radio Button is chosen
      IF rb_aphy EQ abap_true.
*       Displaying Application Server Physical paths with modify id MI2
        IF screen-group1 = c_groupmi2.
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Hiding Logical Filaename input with modify id MI7
        IF screen-group1 = c_groupmi7.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
*     If Application Server Logical File Radio Button is chosen
      ELSEIF rb_alog EQ abap_true.
*       Hiding Application Server - Physical paths with modify id MI2
        IF screen-group1 = c_groupmi2.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi2
*       Displaying Logical File name input with modify id MI7
        IF screen-group1 = c_groupmi7.
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF. " IF screen-group1 = c_groupmi7
      ENDIF. " IF rb_aphy EQ abap_true
    ENDIF. " IF rb_app NE abap_true

  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*       Checking extension of file
*----------------------------------------------------------------------*
*      -->FP_P_FILE Local file for upload/download.
*----------------------------------------------------------------------*
FORM f_check_extension  USING fp_p_file TYPE localfile. " Local file for upload/download

* Local data declaration
  DATA lv_extn TYPE char4. "File Extension.

* Local constant declaration
  CONSTANTS:lc_ext_txt TYPE string VALUE 'TXT'. " Extension as txt

  IF fp_p_file IS NOT INITIAL.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_file
                              CHANGING lv_extn.

*   Checking the extension whether its of .txt for application server
    IF rb_app IS NOT INITIAL
      AND lv_extn NE lc_ext_txt.
      MESSAGE e008. " Please provide TXT file

*   hecking the extension whether its of .xls for presentation servefr
    ELSEIF ( rb_pres IS NOT INITIAL ).
*     AND ( lv_extn <> c_ext OR lv_extn <> c_ext1 OR lv_extn <> c_ext2 ).
      IF lv_extn EQ c_ext.
*        Do Nothing
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
*   Checking the extension whether its of .xlsx for presentation server
      ELSEIF lv_extn EQ c_ext1.
*        Do Nothing
*   Checking the extension whether its of .txt for presentation server
      ELSEIF lv_extn EQ c_ext2.
*        Do Nothing
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
      ELSE. " ELSE -> IF lv_extn EQ c_ext
* ---> Begin of Change for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        MESSAGE e071. " File should have extension .XLS ,.XLSX and.TXT
* <--- End of Change for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
      ENDIF. " IF lv_extn EQ c_ext
    ENDIF. " IF rb_app IS NOT INITIAL

  ENDIF. " IF fp_p_file IS NOT INITIAL

ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether the file name has been entered or not
*----------------------------------------------------------------------*
*  <-- FP_P_PFILE Local presentation server file
*  <-- FP_P_AFILE Local application server file
*----------------------------------------------------------------------*
FORM f_check_input USING fp_p_pfile TYPE localfile  " Local presentation server file
                         fp_p_afile TYPE localfile. " Local application server file

* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing message.
  IF rb_pres IS NOT INITIAL AND
     fp_p_pfile IS INITIAL.
    MESSAGE i009. " Presentation server file has not been entered
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       fp_p_afile IS INITIAL.
      MESSAGE i010.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i011. " Logical File Path has not been entered
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL

ENDFORM. " F_CHECK_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*       Uploading the file from presentation server
*----------------------------------------------------------------------*
*      -->fp_p_pfile  Local file for upload/download
*      <--fp_i_batch  Batch data table
*----------------------------------------------------------------------*
FORM f_upload_presnt_files  USING    fp_p_pfile TYPE localfile " Local file for upload/download
                            CHANGING fp_i_batch TYPE ty_t_batch.
* Local Data Declaration
  DATA: lv_filename   TYPE localfile, " Localfile name
* ---> Begin of Delete for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
*        lv_lines      TYPE sytfill,               " Row Number of Internal Tables
*        lv_tabix      TYPE sytabix,               " Index of Internal Tables
*        lv_row        TYPE int4,                  " Row number
*        lv_total_rows TYPE sytfill,               " total rows of type Integers
*        lwa_line      TYPE string,                " Line of file
* <--- End of Delete for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        li_intern     TYPE
         STANDARD TABLE OF zotc_s_alsmex_tabline, " Rows for Table with Excel Data
        lwa_batch     TYPE zotc_rest_batch.       " Store splitted records


* Local constant declaration
  CONSTANTS:lc_beg      TYPE int4  VALUE 1,      " Beg of type Integers
            lc_ecol     TYPE int4  VALUE 256,    " Ecol of type Integers
            lc_erow     TYPE int4  VALUE 9999,   " Erow of type Integers
            lc_row      TYPE int4  VALUE 1,      " Erow of type Integers
            lc_fstcol   TYPE char4 VALUE '0001', " First column
            lc_scdcol   TYPE char4 VALUE '0002', " Second column
            lc_trdcol   TYPE char4 VALUE '0003', " Third column
            lc_fourtcol TYPE char4 VALUE '0004', " Fourth column
            lc_fifthcol TYPE char4 VALUE '0005'. " Fifth column

* Local field symbol declaration
  FIELD-SYMBOLS <lfs_intern> TYPE zotc_s_alsmex_tabline. " Rows for Table with Excel Data

  lv_filename = fp_p_pfile.

* Uploading the excel file from Presentation Server
  CALL FUNCTION 'ZOTC_ALSM_EXCEL_TO_INT_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = lc_beg
      i_begin_row             = lc_beg
      i_end_col               = lc_ecol
      i_end_row               = lc_erow
    TABLES
      intern                  = li_intern
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i017. " File could not be read from presentation server
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL
* ---> Begin of Delete for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
*  DESCRIBE TABLE li_intern LINES lv_lines.
*  READ TABLE li_intern ASSIGNING <lfs_intern> INDEX lv_lines.
*  IF sy-subrc IS INITIAL.
**   Total number of records in file
*    lv_total_rows = <lfs_intern>-row.
*  ENDIF. " IF sy-subrc IS INITIAL
*
*  lv_row = 0.
*  SORT li_intern BY row.
** Split file records to form a table
*  WHILE sy-index <= lv_total_rows  ##NEEDED.
*
*    lv_row = lv_row + 1.
*    READ TABLE li_intern TRANSPORTING NO FIELDS
*                         WITH KEY row = lv_row    "#EC WARNOK
*                         BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*      lv_tabix = sy-tabix.
*
*      LOOP AT li_intern ASSIGNING <lfs_intern> FROM lv_tabix.
*        IF <lfs_intern>-row NE lv_row.
*          EXIT.
*        ENDIF. " IF <lfs_intern>-row NE lv_row
*        CONCATENATE lwa_line
*                <lfs_intern>-value
*               INTO lwa_line SEPARATED BY space.
*      ENDLOOP. " LOOP AT li_intern ASSIGNING <lfs_intern> FROM lv_tabix
*    ENDIF. " IF sy-subrc IS INITIAL
*
*    IF lv_row NE lc_row.
*    SHIFT lwa_line LEFT.
*    SPLIT lwa_line AT space INTO lwa_batch-matnr
*                                 lwa_batch-charg
*                                 lwa_batch-land1
*                                 lwa_batch-kunnr
*                                 lwa_batch-remarks.
*    APPEND lwa_batch TO fp_i_batch.
*    ENDIF.
*    CLEAR: lwa_batch,
*           lwa_line.
*  ENDWHILE.
* <--- End of Delete for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
  SORT li_intern BY row.
* Move file content to internal table row wise
  LOOP AT li_intern ASSIGNING <lfs_intern>.
    CASE <lfs_intern>-col.
      WHEN lc_fstcol.
        lwa_batch-matnr = <lfs_intern>-value.
      WHEN lc_scdcol.
        lwa_batch-charg = <lfs_intern>-value.
      WHEN lc_trdcol.
        lwa_batch-land1 = <lfs_intern>-value.
      WHEN lc_fourtcol.
        lwa_batch-kunnr = <lfs_intern>-value.
      WHEN lc_fifthcol.
        lwa_batch-remarks = <lfs_intern>-value.
    ENDCASE.
    AT END OF row.
      APPEND lwa_batch TO fp_i_batch.
      CLEAR: lwa_batch.
    ENDAT.
  ENDLOOP. " LOOP AT li_intern ASSIGNING <lfs_intern>
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA

* Deleting the Header Line
  DELETE fp_i_batch INDEX 1.

ENDFORM. " F_UPLOAD_PRESNT_FILES
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
        lwa_input  TYPE zdev_file_list_in,      " Input for FM ZDEV_DIRECTORY_FILE_LIST
        li_output  TYPE zdev_t_file_list_out,
        lwa_output TYPE zdev_file_list_out,     " Output for FM ZDEV_DIRECTORY_FILE_LIST
        li_error   TYPE zdev_t_file_list_error. " error

* Local constant declaration
  CONSTANTS:lc_indf TYPE char1 VALUE  'X'. " Identifier.

* Passing the logical file path to get the physical file path
  lwa_input-path = fp_p_alog.
  APPEND lwa_input TO li_input.
  CLEAR lwa_input.

* Retrieving all files within the directory
  CALL FUNCTION 'ZDEV_DIRECTORY_FILE_LIST'
    EXPORTING
      im_identifier      = lc_indf
      im_input           = li_input
    IMPORTING
      ex_output          = li_output
      ex_error           = li_error
    EXCEPTIONS
      no_input           = 1
      invalid_identifier = 2
      no_data_found      = 3
      OTHERS             = 4.
  IF sy-subrc IS INITIAL AND
      li_error IS INITIAL.
*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
      lwa_output-filename
      INTO fp_gv_modify.
    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL AND
    MESSAGE i090. " No proper file exist for the logical file.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL AND

ENDFORM. " F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*       Uploading the file from applicaion server
*----------------------------------------------------------------------*
*      -->fp_p_afile  Local file for upload/download
*      <--fp_i_batch  Batch data table
*----------------------------------------------------------------------*
FORM f_upload_applcn_files  USING    fp_p_afile  TYPE localfile " Local file for upload/download
                            CHANGING fp_i_batch TYPE ty_t_batch.
* Local Variables
  DATA: lv_input_line TYPE zotc_s_alsmex_tabline, " Input Raw lines
        lwa_batch     TYPE zotc_rest_batch,       " Input work area
        lv_subrc      TYPE sysubrc,               " SY-SUBRC value
        lv_message    TYPE string,                " Message variable
        lv_verstufe   TYPE char4.                 " New Insp. Stage - Not OK

* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#3396 by SBEHERA
* Local Constants
  CONSTANTS : lc_activity  TYPE char5  VALUE 'READ'. " File activity read/write
* Local Data Declaration
  DATA: lv_file TYPE fileextern, " Physical file name
        lv_flag TYPE flag.       " General Flag
  lv_file = fp_p_afile.
*   Check authorization
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_activity
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.
  IF sy-subrc <> 0.
    lv_flag = abap_true.
  ELSE. " ELSE -> IF sy-subrc <> 0
    lv_flag = abap_false.
  ENDIF. " IF sy-subrc <> 0
  IF lv_flag IS INITIAL.
* <--- End of Insert for D3_OTC_EDD_0344_Defect#3396 by SBEHERA
* Opening the Dataset for File Read
*  OPEN DATASET fp_p_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. " Set as Ready for Input
    TRY.
      CALL METHOD zdev_cl_abap_file_utilities=>meth_stat_pub_open_dataset
        EXPORTING
          im_file     = fp_p_afile
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

*   Reading the Input File
      WHILE ( lv_subrc EQ 0 ).
*      sy-subrc is checked in while codition
        READ DATASET fp_p_afile INTO lv_input_line.
*     Storing the SY-SUBRC value. To be used as loop-breaking condition.
        lv_subrc = sy-subrc.
        IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
          SPLIT lv_input_line
          AT c_tab
          INTO
          lwa_batch-matnr
          lwa_batch-charg
          lwa_batch-land1
          lwa_batch-kunnr
          lwa_batch-remarks.

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

          IF NOT lwa_batch IS INITIAL.

            APPEND lwa_batch TO fp_i_batch.
            CLEAR lwa_batch.
          ENDIF. " IF NOT lwa_batch IS INITIAL

        ENDIF. " IF lv_subrc IS INITIAL

        CLEAR lv_input_line.

      ENDWHILE.

* If File Open fails, then populating the Error Log
    ELSE. " ELSE -> IF lv_message IS INITIAL
*   Forming the Message
      MESSAGE i016. " System is not able to read the input file
      LEAVE LIST-PROCESSING.
    ENDIF. " IF lv_message IS INITIAL

* Closing the Dataset.
    CLOSE DATASET fp_p_afile.

* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#3396 by SBEHERA
  ELSE. " ELSE -> IF lv_flag IS INITIAL
    MESSAGE e950 WITH fp_p_afile. "No authorization for access to file &.
  ENDIF. " IF lv_flag IS INITIAL
* <--- End of Insert for D3_OTC_EDD_0344_Defect#3396 by SBEHERA
* Deleting the First Index Line from the table
  DELETE fp_i_batch INDEX 1.

ENDFORM. " F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       Validating the fields from input file
*----------------------------------------------------------------------*
*      <--FP_I_BATCH     Batch data table
*      <--FP_I_FINAL     Final table for upload
*      <--FP_I_REPORT    Report table
*      <--FP_GV_SCOUNT   Number of successfully processed record.
*      <--FP_GV_ECOUNT   Number of record failed.
*----------------------------------------------------------------------*
FORM f_validation CHANGING fp_i_batch   TYPE ty_t_batch
                           fp_i_final   TYPE ty_t_final
                           fp_i_report  TYPE ty_t_report
                           fp_gv_scount TYPE int2  " 2 byte integer (signed)
                           fp_gv_ecount TYPE int2. " 2 byte integer (signed)

* Local variable declaration
  DATA:
        lv_error     TYPE char1, " error flag
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        lv_count     TYPE int2,   " Row Number
        lv_row       TYPE string, " Row Number
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        lv_msg       TYPE string, " message text
        lv_key       TYPE string, " local variable for key fields
* Local workarea declaration
        lwa_kunnr    TYPE ty_kunnr,        " Customer
        lwa_report   TYPE ty_report,       " Work area for report
        lwa_final    TYPE zotc_rest_batch, " Final internal table
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        lwa_batch1   TYPE ty_batch1, " Store splitted records
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
*  Local internal table declaration
        li_rest_batch TYPE STANDARD TABLE OF
               ty_batch ,                 " batch data
        li_batch_temp  TYPE ty_t_batch,   "  Temp. batch table
        li_matnr  TYPE HASHED TABLE OF
         ty_matnr WITH UNIQUE KEY matnr,  "  Material
        li_kunnr_val TYPE HASHED TABLE OF
          ty_kunnr WITH UNIQUE KEY kunnr, " Customer number
        li_kunnr   TYPE HASHED TABLE OF
          ty_kunnr WITH UNIQUE KEY kunnr, " Customer number
        li_charg   TYPE HASHED TABLE OF
          ty_charg WITH UNIQUE KEY matnr
                                   charg, " Batch
        li_land1     TYPE HASHED TABLE OF
          ty_land1 WITH UNIQUE KEY land1. " Dest. Country
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
* Local Constant Declaration
  CONSTANTS : lc_row TYPE char3 VALUE 'row',   " Row
              lc_row_value TYPE int4  VALUE 2. " Erow of type Integers
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_batch>  TYPE zotc_rest_batch, " Restricted Batch Table
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
                 <lfs_batch1> TYPE ty_batch1. " Restricted Batch Table
* Add row number in restricted Batch Table
  LOOP AT fp_i_batch ASSIGNING <lfs_batch>.
    lwa_batch1-matnr = <lfs_batch>-matnr.
    lwa_batch1-charg = <lfs_batch>-charg.
    lwa_batch1-land1 = <lfs_batch>-land1.
    lwa_batch1-kunnr = <lfs_batch>-kunnr.
    lwa_batch1-remarks = <lfs_batch>-remarks.
    lv_count = lv_count + lc_row_value.
    lwa_batch1-row = lv_count.
    APPEND lwa_batch1 TO i_batch1.
    CLEAR lwa_batch1.
  ENDLOOP. " LOOP AT fp_i_batch ASSIGNING <lfs_batch>
  SORT i_batch1 BY matnr
                  charg
                  land1
                  kunnr.
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA

  SORT fp_i_batch BY matnr
                  charg
                  land1
                  kunnr.
  DELETE ADJACENT DUPLICATES FROM fp_i_batch COMPARING matnr
                                                    charg
                                                    land1
                                                    kunnr.
  IF fp_i_batch IS NOT INITIAL.

    LOOP AT fp_i_batch ASSIGNING <lfs_batch>.

*   Appending kunnr to li_kunnr_val table
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = <lfs_batch>-kunnr
        IMPORTING
          output = <lfs_batch>-kunnr.
      lwa_kunnr-kunnr = <lfs_batch>-kunnr.
      COLLECT lwa_kunnr INTO li_kunnr_val.

*   Clear workareas
      CLEAR:lwa_kunnr.

    ENDLOOP. " LOOP AT fp_i_batch ASSIGNING <lfs_batch>

    li_batch_temp[] = fp_i_batch[].
    SORT li_batch_temp BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_batch_temp
                                COMPARING matnr.
    IF NOT li_batch_temp IS INITIAL.

*     Validating matnr from MARA table
      SELECT matnr     " Material Number
             FROM mara " General Material Data
             INTO TABLE li_matnr
             FOR ALL ENTRIES IN li_batch_temp
             WHERE matnr EQ li_batch_temp-matnr.
      IF sy-subrc IS INITIAL.
*      No action required
      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF NOT li_batch_temp IS INITIAL

*   Validating Kunnr from KNA1 table
    IF li_kunnr_val IS NOT INITIAL.

      SELECT kunnr " Customer Number
         FROM kna1 " General Data in Customer Master
         INTO TABLE li_kunnr
         FOR ALL ENTRIES IN li_kunnr_val
         WHERE kunnr EQ li_kunnr_val-kunnr.
      IF  sy-subrc EQ 0.
*      No action needed
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF li_kunnr_val IS NOT INITIAL

*   Validating Batch from MCH1 table.
    REFRESH li_batch_temp.
    li_batch_temp[] = fp_i_batch[].
    SORT li_batch_temp BY matnr
                          charg.
    DELETE ADJACENT DUPLICATES FROM li_batch_temp
                                COMPARING matnr
                                          charg.
    IF NOT li_batch_temp IS INITIAL.

      SELECT matnr     " Material Number
             charg     " Batch Number
             FROM mch1 " Batches
             INTO TABLE li_charg
             FOR ALL ENTRIES IN li_batch_temp
             WHERE matnr EQ li_batch_temp-matnr
               AND charg EQ li_batch_temp-charg.
      IF sy-subrc EQ 0.
*      No action needed
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF NOT li_batch_temp IS INITIAL

*   Validating Dest. Country from T005 table
    REFRESH li_batch_temp.
    li_batch_temp[] = fp_i_batch[].
    SORT li_batch_temp BY land1.
    DELETE ADJACENT DUPLICATES FROM li_batch_temp
                                COMPARING land1.
    IF NOT li_batch_temp IS INITIAL.

      SELECT land1     " Country Key
             FROM t005 " Countries
             INTO TABLE li_land1
             FOR ALL ENTRIES IN li_batch_temp
             WHERE land1 EQ li_batch_temp-land1.
      IF  sy-subrc EQ 0.
*      No action needed
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF NOT li_batch_temp IS INITIAL

*   Validate for duplicate records
    SELECT matnr           " Material Number
           charg           " Batch Number
           land1           " Country Key
           kunnr           " Customer
      FROM zotc_rest_batch " Restricted Batch Table
      INTO TABLE li_rest_batch
      FOR ALL ENTRIES IN fp_i_batch
      WHERE matnr = fp_i_batch-matnr
         AND charg = fp_i_batch-charg
         AND land1 = fp_i_batch-land1
         AND kunnr = fp_i_batch-kunnr.
    IF sy-subrc IS INITIAL.
      SORT li_rest_batch BY matnr
                       charg
                       land1
                       kunnr.
    ENDIF. " IF sy-subrc IS INITIAL

    LOOP AT fp_i_batch ASSIGNING <lfs_batch>.
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
* Read Restricted Batch Table and concatenate row number
      READ TABLE i_batch1 ASSIGNING <lfs_batch1>
                          WITH KEY  matnr = <lfs_batch>-matnr
                                   charg = <lfs_batch>-charg
                                   land1 = <lfs_batch>-land1
                                   kunnr = <lfs_batch>-kunnr
                                   BINARY SEARCH.
      IF sy-subrc = 0.
        CLEAR lv_row.
        CONCATENATE lc_row
                    <lfs_batch1>-row
                    INTO lv_row.
      ENDIF. " IF sy-subrc = 0
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
      CLEAR lv_key.
      CONCATENATE    <lfs_batch>-matnr
                     <lfs_batch>-charg
                     <lfs_batch>-land1
                     <lfs_batch>-kunnr
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
                     <lfs_batch>-remarks
                     lv_row
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
         INTO lv_key
         SEPARATED BY c_slash.

*   Material Number
      IF <lfs_batch>-matnr IS NOT INITIAL.
        READ TABLE li_matnr
             TRANSPORTING NO FIELDS
             WITH TABLE KEY matnr = <lfs_batch>-matnr.
        IF sy-subrc NE 0 .
          lv_error = abap_true.
          lwa_report-msgtyp = c_error.
          CONCATENATE text-003 " Material number does not exist
                      <lfs_batch>-matnr
                      INTO lv_msg SEPARATED BY c_slash.
          lwa_report-msgtxt = lv_msg.
          lwa_report-key = lv_key.
          APPEND lwa_report TO fp_i_report.
          CLEAR lwa_report.
        ENDIF. " IF sy-subrc NE 0
      ELSE. " ELSE -> IF <lfs_batch>-matnr IS NOT INITIAL
        lv_error = abap_true.
        lwa_report-msgtyp = c_error.
        CONCATENATE text-004 " Material Number is mandatory
                    <lfs_batch>-matnr
                    INTO lv_msg SEPARATED BY c_slash.
        lwa_report-msgtxt = lv_msg.
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
        CLEAR lwa_report.
      ENDIF. " IF <lfs_batch>-matnr IS NOT INITIAL


*   Validate Batch
      IF NOT <lfs_batch>-charg IS INITIAL.

*     Validate Batch
        READ TABLE li_charg
             TRANSPORTING NO FIELDS
             WITH TABLE KEY matnr = <lfs_batch>-matnr
                            charg =  <lfs_batch>-charg.
        IF sy-subrc NE 0.
          lv_error = abap_true.
          lwa_report-msgtyp = c_error.
          CONCATENATE text-006 " Batch number does not exist
                      <lfs_batch>-charg
                      INTO lv_msg
                      SEPARATED BY c_slash.
          lwa_report-msgtxt = lv_msg.
          lwa_report-key = lv_key.
          APPEND lwa_report TO fp_i_report.
          CLEAR lwa_report.
        ENDIF. " IF sy-subrc NE 0
      ELSE. " ELSE -> IF NOT <lfs_batch>-charg IS INITIAL
        lv_error = abap_true.
        lwa_report-msgtyp = c_error.
        CONCATENATE text-007 " Batch number is mandatory
                    <lfs_batch>-charg
                    INTO lv_msg
                    SEPARATED BY c_slash.
        lwa_report-msgtxt = lv_msg.
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
        CLEAR lwa_report.
      ENDIF. " IF NOT <lfs_batch>-charg IS INITIAL

*   Customer number
      IF <lfs_batch>-kunnr IS NOT INITIAL.
        READ TABLE li_kunnr
             TRANSPORTING NO FIELDS
             WITH TABLE KEY kunnr = <lfs_batch>-kunnr.
        IF sy-subrc NE 0.
          lv_error = abap_true.
          lwa_report-msgtyp = c_error.
          CONCATENATE text-005 " Customer does not exist
                      <lfs_batch>-kunnr
                      INTO lv_msg
                      SEPARATED BY c_slash.
          lwa_report-msgtxt = lv_msg.
          lwa_report-key = lv_key.
          APPEND lwa_report TO fp_i_report.
          CLEAR lwa_report.
        ENDIF. " IF sy-subrc NE 0
      ELSEIF <lfs_batch>-land1 IS INITIAL
        AND <lfs_batch>-kunnr IS INITIAL  ##bool_ok . " ELSE -> IF NOT <lfs_batch>-Kunnr IS INITIAL
        lv_error = abap_true.
        lwa_report-msgtyp = c_error.
        CONCATENATE text-015 " Either Dest. Country or Customer is mandatory
                    <lfs_batch>-charg
                    INTO lv_msg
                    SEPARATED BY c_slash.
        lwa_report-msgtxt = lv_msg.
        lwa_report-key = lv_key.
        APPEND lwa_report TO fp_i_report.
        CLEAR lwa_report.
      ENDIF. " IF <lfs_batch>-kunnr IS NOT INITIAL

*     Destination Country
      IF <lfs_batch>-land1 IS NOT INITIAL.
        READ TABLE li_land1
             TRANSPORTING NO FIELDS
             WITH TABLE KEY land1 = <lfs_batch>-land1.
        IF sy-subrc NE 0.
          lv_error = abap_true.
          lwa_report-msgtyp = c_error.
          CONCATENATE text-008 " Destination Country does not exist
                      <lfs_batch>-land1
                      INTO lv_msg
                      SEPARATED BY c_slash.
          lwa_report-msgtxt = lv_msg.
          lwa_report-key = lv_key.
          APPEND lwa_report TO fp_i_report.
          CLEAR lwa_report.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF <lfs_batch>-land1 IS NOT INITIAL

*   Validate for duplicate records in table
      IF <lfs_batch>-land1 IS NOT INITIAL
        OR <lfs_batch>-kunnr IS NOT INITIAL .

        READ TABLE li_rest_batch TRANSPORTING NO FIELDS
           WITH KEY matnr = <lfs_batch>-matnr
                    charg = <lfs_batch>-charg
                    land1 = <lfs_batch>-land1
                    kunnr = <lfs_batch>-kunnr
                    BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lv_error = abap_true.
          lwa_report-msgtyp = c_inform.
          lwa_report-msgtxt = text-014. " Record already exists in table.
          lwa_report-key = lv_key.
          APPEND lwa_report TO fp_i_report.
          CLEAR lwa_report.
        ENDIF. " IF sy-subrc IS INITIAL

      ENDIF. " IF <lfs_batch>-land1 IS NOT INITIAL

*   If error flag is not 'X' then the record is not in error
*   so populating final internal table
      IF lv_error NE abap_true.
*     Increasing success count
        fp_gv_scount = fp_gv_scount + 1.
        lwa_report-msgtyp = c_success.
        IF NOT cb_test = abap_true.
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
* If test run is not selected
          lwa_report-msgtxt = text-016. " Record Updated
        ELSE. " ELSE -> IF NOT cb_test = abap_true
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
          lwa_report-msgtxt = text-009. " Record verified
        ENDIF. " IF NOT cb_test = abap_true

        CONCATENATE <lfs_batch>-matnr
                    <lfs_batch>-charg
                    <lfs_batch>-land1
                    <lfs_batch>-kunnr
                    <lfs_batch>-remarks
                    INTO lwa_report-key
                    SEPARATED BY c_slash.
        APPEND lwa_report TO fp_i_report.
        CLEAR lwa_report.
* Populating Created By,Created On Date  and Created at Time
        <lfs_batch>-zz_created_by = sy-uname.
        <lfs_batch>-zz_created_on = sy-datum.
        <lfs_batch>-zz_created_at = sy-uzeit.
*    Populating final table
        lwa_final = <lfs_batch>.
        APPEND lwa_final TO fp_i_final.
        CLEAR lwa_final.
      ELSE. " ELSE -> IF lv_error NE abap_true
*     Increasing error count
        fp_gv_ecount = fp_gv_ecount + 1.
      ENDIF. " IF lv_error NE abap_true

      CLEAR lv_error.

    ENDLOOP. " LOOP AT fp_i_batch ASSIGNING <lfs_batch>

  ENDIF. " IF fp_i_batch IS NOT INITIAL

ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE
*&---------------------------------------------------------------------*
*       Update Custom table and GTS project master table
*----------------------------------------------------------------------*
*      -->FP_I_FINAL  Final table for upload
*----------------------------------------------------------------------*
FORM f_update USING fp_i_final TYPE ty_t_final. " Final table for upload

* local data declaration
  DATA: lwa_gts_batch TYPE ty_gts_batch, " Workarea for gts table
        lv_subrc      TYPE sy-subrc,     " sy-subrc value
        lv_rfcdest    TYPE rfcdest,      " Logical Destination (Specified in Function Call)
        li_gts_batch TYPE STANDARD TABLE OF
                        ty_gts_batch.    " GTS project master table

* Local constant declaration
  CONSTANTS:lc_mode TYPE enqmode VALUE 'E',                  " Lock mode
            lc_type TYPE rfctype_d VALUE '3',                " Type of Entry in RFCDES
            lc_tabname TYPE tabname VALUE 'ZOTC_REST_BATCH'. " Table Name

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_batch> TYPE zotc_rest_batch. " Restricted Batch Table

* Lock table ZOTC_REST_BATCH before inserting data
  CALL FUNCTION 'ENQUEUE_E_TABLEE'
    EXPORTING
      mode_rstable   = lc_mode
      tabname        = lc_tabname
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc IS INITIAL.

* Insert data into custom table from final table
    MODIFY zotc_rest_batch FROM TABLE fp_i_final.
    IF sy-subrc IS INITIAL.
      lv_subrc = sy-subrc.
    ENDIF. " IF sy-subrc IS INITIAL

    IF lv_subrc IS INITIAL.

*     Unlock table ZOTC_REST_BATCH
      CALL FUNCTION 'DEQUEUE_E_TABLEE'
        EXPORTING
          mode_rstable = lc_mode
          tabname      = lc_tabname.

*     Build table to update GTS table through RFC call
      LOOP AT fp_i_final ASSIGNING <lfs_batch>.

*       Project ID as Batch number
        lwa_gts_batch-pronr = <lfs_batch>-charg.
*       Created By
        lwa_gts_batch-ernam = sy-uname.
*       Changed by
        lwa_gts_batch-aenam = sy-uname.

        APPEND lwa_gts_batch TO li_gts_batch.
        CLEAR lwa_gts_batch.

      ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_batch>
*  Validation of existance of RFC destination in table RFCDES
      SELECT SINGLE rfcdest              " Logical Destination (Specified in Function Call)
               FROM rfcdes               " Destination table for Remote Function Call
               INTO lv_rfcdest
               WHERE rfcdest EQ gv_dest_system
               AND   rfctype EQ lc_type. " Connection to ABAP System(3)
      IF sy-subrc = 0.
*     Call RFC in GTS system to update project master data table
        CALL FUNCTION 'ZOTC_TRANSFER_BATCH'
          DESTINATION lv_rfcdest " G1DCLNT300
          TABLES
            tbl_gts_batch = li_gts_batch
          EXCEPTIONS
            exc_data_not_inserted = 1
            OTHERS                = 2.
        IF sy-subrc IS INITIAL.

*       Commit work
          COMMIT WORK  ##subrc_after_commit .
          IF sy-subrc IS INITIAL.
            MESSAGE s085. " Data successfully inserted in GTS project master table.
          ENDIF. " IF sy-subrc IS INITIAL

        ELSE. " ELSE -> IF sy-subrc IS INITIAL
*       Rollback work
          ROLLBACK WORK.
          MESSAGE i086. " Data not inserted in GTS project master table.
        ENDIF. " IF sy-subrc IS INITIAL
      ELSE. " ELSE -> IF sy-subrc = 0
        MESSAGE i089. " Destination system does not exits.
      ENDIF. " IF sy-subrc = 0
    ELSE. " ELSE -> IF lv_subrc IS INITIAL

*     Unlock table ZOTC_REST_BATCH
      CALL FUNCTION 'DEQUEUE_E_TABLEE'
        EXPORTING
          mode_rstable = lc_mode
          tabname      = lc_tabname.

      MESSAGE i087. " Data not inserted into table ZOTC_REST_BATCH.

    ENDIF. " IF lv_subrc IS INITIAL

  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE s087 DISPLAY LIKE 'E'. " Data not inserted into table ZOTC_REST_BATCH.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_UPDATE
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_EMI
*&---------------------------------------------------------------------*
*       fetch data from ZDEV_EMI
*----------------------------------------------------------------------*
*      <-- FP_GV_DEST_SYSTEM  RFC Destination system
*      <-- FP_GV_CODEPAGE     Code page
*----------------------------------------------------------------------*
FORM f_fetch_emi  CHANGING fp_gv_dest_system TYPE rfcdest     " Logical Destination (Specified in Function Call)
                           fp_gv_codepage    TYPE cpcodepage. " SAP Character Set ID

* Local internal table Declaration
  DATA : li_status_table
               TYPE STANDARD TABLE OF zdev_enh_status, " Table for Enhancement status data

* Local variable declaration
         lv_log_sys  TYPE logsys. " Logical system

* Local field symbol declaration
  FIELD-SYMBOLS: <lfs_status> TYPE zdev_enh_status. " Enhancement Status

* Local constant declaration
  CONSTANTS: lc_rfc_dest  TYPE z_criteria    VALUE 'RFC_DEST',     " Enh. Criteria
             lc_codepage  TYPE z_criteria    VALUE 'CODEPAGE',     " Enh. Criteria
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
                            active.

*   Read status table for criteria CODEPAGE and active = X
    READ TABLE li_status_table ASSIGNING <lfs_status>
                               WITH KEY criteria = lc_codepage
                                        active   = abap_true
                               BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*     Populate value for Code page
      fp_gv_codepage = <lfs_status>-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL

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
        OTHERS                         = 2 ##fm_subrc_ok.

* GET RFC Destination from EMI Tool on the basis of current system
*&--Read RFC destnation
*   Read status table for criteria RFC DEST and active = X
    READ TABLE li_status_table ASSIGNING <lfs_status>
                               WITH KEY criteria = lc_rfc_dest
                                        sel_low  = lv_log_sys
                                        active   = abap_true
                               BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*       Populate value for RFC Destination
      fp_gv_dest_system = <lfs_status>-sel_high.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_FETCH_EMI
