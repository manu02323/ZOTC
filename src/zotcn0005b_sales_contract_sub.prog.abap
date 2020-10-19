*&---------------------------------------------------------------------*
*&  Include           ZOTCN0005B_SALES_CONTRACT_SUB
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0005B_SALES_CONTRACT_SUB                          *
* TITLE      :  Convert Open Reagent Rental and Service Contracts      *
* DEVELOPER  :  Manikandan Pounraj                                     *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0005_Convert Open Reagent Rental                 *
*             and Service Contracts                                    *
*----------------------------------------------------------------------*
* DESCRIPTION: Updating sales contract                                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT      DESCRIPTION                     *
* =========== ======== ========== =====================================*
* 03-JULY-2012 MPOUNRA  E1DK901606 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 12-OCT-2012  ASK  E1DK901606  DEFECT 346: 1) Making Acceptance Date  *
*                               Optional                               *
*                           2)Code Correction - Error internal         *
*                           table "li_contract_temp" was getting       *
*                           populated with blank records.Correction    *
*                           is made to populate "lwa_contract_temp'    *
*                           with contract number  and correct error    *
*                           msg before appending it to li_contract_temp*
*&---------------------------------------------------------------------*
*06-Nov-2012  SPURI E1DK901606  DEFECT 1438 ( CR# 197 ) : Make Serial  *
*                               Number Optional                        *
*&---------------------------------------------------------------------*
* 12-Dec-2012 RVERMA    E1DK901606 Defect#2090: Purchase date, Document*
*                                  date & Equipment Number should not  *
*                                  be mandatory.                       *
**&--------------------------------------------------------------------*
* 07-Oct-2014  SMEKALA  E2DK905508 D2:Service Contracts will no longer *
*                                  be used and the scope of conversions*
*                 would only be limited to Reagent Rental Contracts.   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*     Modify the selection screen based on radio button selection.
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
    ELSE. " ELSE -> IF screen-group1 = c_groupmi3
*     Disaplying Presentation Server file paths with modify id MI3.
      IF screen-group1 = c_groupmi3.
        screen-active = c_one.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi3
    ENDIF. " IF rb_pres NE c_true
*   Application Server Option is NOT chosen
    IF rb_app NE c_true.
*Hiding 1) Application Server file Physical paths with modify id MI2
*     2) Logical Filename Radio Button with with modify id MI5
*     3) Logical Filename input with modify id MI7
      IF screen-group1 = c_groupmi2
         OR screen-group1 = c_groupmi5
         OR screen-group1 = c_groupmi7.
        screen-active = c_zero.
        MODIFY SCREEN.
      ENDIF. " IF screen-group1 = c_groupmi2
*   Application Server Option IS chosen
    ELSE. " ELSE -> IF screen-group1 = c_groupmi2
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
*       Checking whether the file has .TXT extension.
*----------------------------------------------------------------------*
*      -->fp_p_file Input File Location
*----------------------------------------------------------------------*
FORM f_check_extension USING fp_p_file TYPE localfile. " Local file for upload/download

  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING    fp_p_file
                              CHANGING gv_extn.
*Checking the extension whether its of .TXT
    IF gv_extn <> c_ext .
      MESSAGE e008.
    ENDIF. " IF gv_extn <> c_ext
  ENDIF. " IF fp_p_file IS NOT INITIAL
ENDFORM. " F_CHECK_EXTENSION

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_INPUT
*&---------------------------------------------------------------------*
*       Checking whether file names have entered for chosen option at
*       Run time.
*----------------------------------------------------------------------*
FORM f_check_input .
* If No presentation Server file name is entered and Presentation
* Server Option has been chosen, then issueing error message.
  IF rb_pres IS NOT INITIAL AND
     p_pfile IS INITIAL.
    MESSAGE i032.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF rb_pres IS NOT INITIAL AND

* For Application Server
  IF rb_app IS NOT INITIAL.
*   If No Application Server file name is entered and Application
*   Server Option has been chosen, then issueing error message.
    IF rb_aphy IS NOT INITIAL AND
       p_afile IS INITIAL.
      MESSAGE i033.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_aphy IS NOT INITIAL AND

* If No Logical File Path is entered and Logical File Path Option
* has been chosen, then issueing error message.
    IF rb_alog IS NOT INITIAL AND
       p_alog IS INITIAL.
      MESSAGE i034.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF rb_alog IS NOT INITIAL AND
  ENDIF. " IF rb_app IS NOT INITIAL

ENDFORM. " F_CHECK_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*       Uploading the file from Presentation Server
*----------------------------------------------------------------------*
*      -->FP_p_pfile           Input File location
*      <--FP_I_CONTRACT        Data
*----------------------------------------------------------------------*
FORM f_upload_presnt_files USING    fp_p_pfile    TYPE localfile " Local file for upload/download
                           CHANGING fp_i_contract TYPE ty_t_contract.
* Local Data Declaration
  DATA:
  lv_filename   TYPE string,                   " For file name
  lv_target_qty TYPE char14,                   "Target quantity in sales units
  li_str        TYPE STANDARD TABLE OF string, "table of type string
  lwa_str       TYPE string,
                                               " local work area of type string to split records in pipe delimeted file.
  lwa_string    TYPE ty_contract.              "type ty_input.

  lv_filename = fp_p_pfile.

* Uploading the file from Presentation Server
  CALL METHOD cl_gui_frontend_services=>gui_upload
    EXPORTING
      filename                = lv_filename
      filetype                = c_filetype
      has_field_separator     = c_ind1
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

  IF sy-subrc <> 0.
    MESSAGE i017.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

*   Deleting the Header Line
  DELETE li_str INDEX 1.

  LOOP AT li_str INTO lwa_str.
    SPLIT lwa_str AT c_pipe INTO
lwa_string-vbeln       " Sales Document
lwa_string-doc_type    " Sales Document Type
lwa_string-sales_org   " Sales Organization
lwa_string-distr_chan  " Distribution Channel
lwa_string-division    " Division
lwa_string-collect_no  " Collective Number
lwa_string-purch_date  " Customer purchase order date
lwa_string-po_method   " Customer purchase order type
lwa_string-name        " Name of orderer
lwa_string-telephone   " Telephone Number
lwa_string-purch_no_c  " Customer purchase order number
lwa_string-doc_date    " Document Date (Date Received/Sent)
lwa_string-pmnttrms    " Terms of Payment Key
lwa_string-itm_number  " Sales Document Item
lwa_string-material    " Material
lv_target_qty          " Target quantity in sales units
lwa_string-target_qu   " Target quantity UoM
lwa_string-item_categ  " Sales document item category
lwa_string-partn_role1 " Partner Function
lwa_string-partn_numb1 " Customer Number 1
lwa_string-partn_role2 " Partner Function
lwa_string-partn_numb2 " Customer Number 1
lwa_string-inst_date   " Installation date
lwa_string-accept_dat  " Agreement acceptance date
lwa_string-con_st_dat  " Contract start date
lwa_string-con_en_dat  " Contract end date
lwa_string-sernr       " Serial Number
lwa_string-equnr.      " Equipment Number

    lwa_string-target_qty = lv_target_qty.
*-- Below conversion logic is commented as there is a chance of
* materials with leading zeroes
**-- Begin of add D2
*    PERFORM f_conv_material USING    lwa_string-material
*                            CHANGING lwa_string-material.
**-- En dof add D2

* Conversion Exit for Division
    PERFORM f_conv_input USING    lwa_string-division
                         CHANGING lwa_string-division.

* Conversion Exit for Partner Function
    PERFORM f_conv_inp USING    lwa_string-partn_role1
                       CHANGING lwa_string-partn_role1.

* Conversion Exit for Partner Function
    PERFORM f_conv_inp USING    lwa_string-partn_role2
                       CHANGING lwa_string-partn_role2.

* Conversion Exit for Customer Number
    PERFORM f_con_inp USING    lwa_string-partn_numb1
                      CHANGING lwa_string-partn_numb1.

* Conversion Exit for Customer Number
    PERFORM f_con_inp USING    lwa_string-partn_numb2
                      CHANGING lwa_string-partn_numb2.

* Conversion Exit for Item Number
    PERFORM f_conv_item  USING    lwa_string-itm_number
                         CHANGING lwa_string-itm_number.

    APPEND lwa_string TO fp_i_contract.
    CLEAR  lwa_string.
  ENDLOOP. " LOOP AT li_str INTO lwa_str

ENDFORM. " F_UPLOAD_PRESNT_FILES
*&---------------------------------------------------------------------*
*&      Form  F_LOGICAL_TO_PHYSICAL
*&---------------------------------------------------------------------*
*       Retrieving physical file paths from logical file name
*----------------------------------------------------------------------*
*      -->FP_P_ALOG     Logical File Name
*      <--FP_gv_batch   Physical File Path
*----------------------------------------------------------------------*
FORM f_logical_to_physical USING    fp_p_alog      TYPE pathintern " Logical path name
                           CHANGING fp_gv_contract TYPE localfile. " Local file for upload/download

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
  IF sy-subrc IS INITIAL AND
     li_error IS INITIAL.

*   Getting the file path
    READ TABLE li_output INTO lwa_output INDEX 1.
    IF sy-subrc IS INITIAL.
      CONCATENATE lwa_output-physical_path
      lwa_output-filename
      INTO fp_gv_contract.
    ENDIF. " IF sy-subrc IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
    MESSAGE i000 WITH 'No File exist in the directory'(005).
  ENDIF. " IF sy-subrc IS INITIAL AND
ENDFORM. " F_LOGICAL_TO_PHYSICAL

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_APPLCN_FILES
*&---------------------------------------------------------------------*
*       Uploading file from Application Server
*----------------------------------------------------------------------*
*      -->FP_p_afile  Input File Location
*      <--FP_I_batch  Uploaded Header File
*----------------------------------------------------------------------*
FORM f_upload_applcn_files USING    fp_p_afile    TYPE localfile " Local file for upload/download
                           CHANGING fp_i_contract TYPE ty_t_contract.


* Local Variables
  DATA: lv_input_line  TYPE string,      "Input Raw lines
        lwa_contract   TYPE ty_contract, "Input work area
        lv_subrc       TYPE sysubrc,     "SY-SUBRC value
        lv_first       TYPE char1,       "For deleting the header
        lv_target_qty  TYPE char7.       "Target quantity in sales units

  lv_first = c_true.

* Opening the Dataset for File Read
  OPEN DATASET fp_p_afile FOR INPUT IN TEXT MODE ENCODING NON-UNICODE. " Set as Ready for Input
  IF sy-subrc IS INITIAL.
*   Reading the Input File
    WHILE ( lv_subrc EQ 0 ).
      READ DATASET fp_p_afile INTO lv_input_line.
*     Sotring the SY-SUBRC value. To be used as loop-breaking condition.
      lv_subrc = sy-subrc.
      IF lv_first IS INITIAL.
        IF lv_subrc IS INITIAL.
*       Aligning the values as per the structure
          SPLIT lv_input_line AT c_pipe
          INTO  lwa_contract-vbeln       " Sales Document
                lwa_contract-doc_type    " Sales Document Type
                lwa_contract-sales_org   " Sales Organization
                lwa_contract-distr_chan  " Distribution Channel
                lwa_contract-division    " Division
                lwa_contract-collect_no  " Collective Number
                lwa_contract-purch_date  " Customer purchase order date
                lwa_contract-po_method   " Customer purchase order type
                lwa_contract-name        " Name of orderer
                lwa_contract-telephone   " Telephone Number
                lwa_contract-purch_no_c  " Customer purchase order number
                lwa_contract-doc_date    " Document Date
                lwa_contract-pmnttrms    " Terms of Payment Key
                lwa_contract-itm_number  " Sales Document Item
                lwa_contract-material    " Material
                lv_target_qty            " Target quantity in sales units
                lwa_contract-target_qu   " Target quantity UoM
                lwa_contract-item_categ  " Sales document item category
                lwa_contract-partn_role1 " Partner Function
                lwa_contract-partn_numb1 " Customer Number 1
                lwa_contract-partn_role2 " Partner Function
                lwa_contract-partn_numb2 " Customer Number 1
                lwa_contract-inst_date   " Installation date
                lwa_contract-accept_dat  " Agreement acceptance date
                lwa_contract-con_st_dat  " Contract start date
                lwa_contract-con_en_dat  " Contract end date
                lwa_contract-sernr       " Serial Number
                lwa_contract-equnr.      " Equipment Number

*       If the last entry is a Line Feed (i.e. CR_LF), then ignore.
          IF lwa_contract-equnr = c_crlf.
            CLEAR lwa_contract-equnr.
          ELSEIF  lwa_contract-equnr CA c_crlf.
*       If the last field does not fills up the full length of
*       field, then the last character will be CR-LF. Replacing the
*       CR-LF from the last field if it contains CR-LF.
            REPLACE ALL OCCURRENCES OF c_crlf IN lwa_contract-equnr
            WITH space.
*         Removing the space.
            CONDENSE lwa_contract-equnr.
          ENDIF. " IF lwa_contract-equnr = c_crlf

          lwa_contract-target_qty = lv_target_qty.
*-- Below conversion logic is commented as there is a chance of
* materials with leading zeroes
**-- Begin of add D2
*          PERFORM f_conv_material USING    lwa_contract-material
*                                  CHANGING lwa_contract-material.
**-- En dof add D2
* Conversion Exit for Division
          PERFORM f_conv_input USING    lwa_contract-division
                               CHANGING lwa_contract-division.

* Conversion Exit for Partner Function
          PERFORM f_conv_inp USING    lwa_contract-partn_role1
                             CHANGING lwa_contract-partn_role1.

* Conversion Exit for Partner Function
          PERFORM f_conv_inp USING    lwa_contract-partn_role2
                             CHANGING lwa_contract-partn_role2.

* Conversion Exit for Customer Number
          PERFORM f_con_inp USING    lwa_contract-partn_numb1
                            CHANGING lwa_contract-partn_numb1.

* Conversion Exit for Customer Number
          PERFORM f_con_inp USING    lwa_contract-partn_numb2
                            CHANGING lwa_contract-partn_numb2.

* Conversion Exit for Item Number
          PERFORM f_conv_item USING    lwa_contract-itm_number
                              CHANGING lwa_contract-itm_number.

          IF NOT lwa_contract IS INITIAL.
            APPEND lwa_contract TO fp_i_contract.
            CLEAR lwa_contract.
          ENDIF. " IF NOT lwa_contract IS INITIAL
        ENDIF. " IF lv_subrc IS INITIAL
      ELSE. " ELSE -> IF NOT lwa_contract IS INITIAL
        CLEAR lv_first.
      ENDIF. " IF lv_first IS INITIAL
      CLEAR lv_input_line.
    ENDWHILE.
* If File Open fails, then populating the Error Log
  ELSE. " ELSE -> IF lwa_contract-equnr = c_crlf
*   Forming the Message
    MESSAGE i000 WITH 'System is not able to read the input file'(006).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

* Closing the Dataset.
  CLOSE DATASET fp_p_afile.

ENDFORM. " F_UPLOAD_APPLCN_FILES

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATION
*&---------------------------------------------------------------------*
*       Validating the input
*----------------------------------------------------------------------*
*      -->FP_I_MODIFY    Internal Table contains Raw data
*      <--FP_I_ERROR     Internal Table Error record
*      <--FP_I_FINAL     Internal Table contains Valid record
*      <--FP_GV_SCOUNT   Variable for success count
*      <--FP_GV_ECOUNT   Variable for Error count
*      <--FP_I_REPORT    Internal Table for writing the report
*----------------------------------------------------------------------*
FORM f_validation USING fp_i_contract TYPE ty_t_chgcon
               CHANGING fp_i_error    TYPE ty_t_error
                        fp_i_final    TYPE ty_t_contract
                        fp_gv_scount  TYPE int2 " 2 byte integer (signed)
                        fp_gv_ecount  TYPE int2 " 2 byte integer (signed)
                        fp_i_report   TYPE ty_t_report.

  DATA:
    lwa_contract_temp TYPE ty_contract_e, " Local Work area for error
    lwa_report        TYPE ty_report,     " To display error report
    lwa_vbak          TYPE ty_vbak,
                                          " Local work area- Contract Data
    lwa_tvak          TYPE ty_tvak,
                                          " Local work area- Sales Document Types
    lwa_tvko          TYPE ty_tvko,
                                          " Local work area- Organizational Unit: Sales Organizations
    lwa_tvtw          TYPE ty_tvtw,
                                          " Local work area- Organizational Unit: Distribution Channels
    lwa_tspa          TYPE ty_tspa,
                                          " Local work area- Organizational Unit: Sales Divisions
    lwa_tvta          TYPE ty_tvta,
                                          " Local work area- Organizational Unit: Sales Area
    lwa_t176          TYPE ty_t176,
                                          " Local work area- Sales Documents: Customer Order Types
    lwa_mara          TYPE ty_mara,
                                          " Local work area- General Material Data
    lwa_t006          TYPE ty_t006,
                                          " Local work area- Units of Measurement
    lwa_tvpt          TYPE ty_tvpt,
                                          " Local work area- Sales documents: Item categories
    lwa_tpar          TYPE ty_tpar,
                                          " Local work area- Business Partner: Functions
    lwa_kna1          TYPE ty_kna1,
                                          " Local work area- General Data in Customer Master
    lwa_t052          TYPE ty_t052,
                                          " Local work area- Terms of Payment
*-- Begin of addition D2
    lwa_dupchk        TYPE ty_dupchk,
    lwa_vapma         TYPE ty_vapma,
    lv_lines          TYPE int4,    " Natural Number
    lv_msgvbeln       TYPE char100, " Msgvbeln of type CHAR100
    lv_tabix          TYPE sytabix, " Index of Internal Tables
*-- End of addition D2
    lv_error          TYPE char1,    " Error of type CHAR1
                                     " Local variable- has to be set incase of error
    lv_err            TYPE char1,    " Err of type CHAR1
                                     " Local variable- has to be set incase of error
    lv_date           TYPE sy-datum, " Current Date of Application Server
                                     " To check for doing validation
    lv_role           TYPE parvw,    " Partner Function
    lv_numb           TYPE kunnr,    " Customer Number
    lv_msg            TYPE char300,  " to represent error message
    li_vbak           TYPE STANDARD TABLE OF ty_vbak,
                                     " Local Internal Table- Contract Data
    li_tvak           TYPE STANDARD TABLE OF ty_tvak,
                                     " Local Internal Table- Sales Document Types
    li_tvko           TYPE STANDARD TABLE OF ty_tvko,
                                     " Local Internal Table- Organizational Unit: Sales Organizations
    li_tvtw           TYPE STANDARD TABLE OF ty_tvtw,
                                     " Local Internal Table- Organizational Unit: Distribution Channels
    li_tspa           TYPE STANDARD TABLE OF ty_tspa,
                                     " Local Internal Table- Organizational Unit: Sales Divisions
    li_tvta           TYPE STANDARD TABLE OF ty_tvta,
                                     " Local Internal Table- Organizational Unit: Sales Area
    li_t176           TYPE STANDARD TABLE OF ty_t176,
                                     " Local Internal Table- Sales Documents: Customer Order Types
    li_mara           TYPE STANDARD TABLE OF ty_mara,
                                     " Local Internal Table- General Material Data
    li_t006           TYPE STANDARD TABLE OF ty_t006,
                                     " Local Internal Table- Units of Measurement
    li_tvpt           TYPE STANDARD TABLE OF ty_tvpt,
                                     " Local Internal Table- Sales documents: Item categories
    li_tpar           TYPE STANDARD TABLE OF ty_tpar,
                                     " Local Internal Table- Business Partner: Functions
    li_kna1           TYPE STANDARD TABLE OF ty_kna1,
                                     " Local Internal Table- General Data in Customer Master
    li_t052           TYPE STANDARD TABLE OF ty_t052,
                                     " Terms of Payment
    li_contract_temp  TYPE STANDARD TABLE OF ty_contract_e,
                                     " To hold all the error records
*-- Begin of addition D2
     li_dupchk        TYPE STANDARD TABLE OF ty_dupchk,
     li_vapma         TYPE STANDARD TABLE OF ty_vapma,
     li_shipto        TYPE STANDARD TABLE OF ty_shipto,
     li_vapmatmp      TYPE STANDARD TABLE OF ty_vapma.
*-- End of addition D2

*-- Begin of D2
  CONSTANTS:
  lc_shipto  TYPE parvw VALUE 'WE',     " Partner Function
  lc_posnr   TYPE posnr VALUE '000000'. " Item number of the SD document

*-- End of D2
  FIELD-SYMBOLS: <lfs_contract>  TYPE ty_chgcon, " D2D2
*                 <lfs_contract>  TYPE ty_contract," D2D2
                 <lfs_val>       TYPE ty_val,     "D2
                 <lfs_vapma>     TYPE ty_vapma,   "D2
                 <lfs_shipto>     TYPE ty_shipto. "D2
* Colecting the Material from the input file
  LOOP AT fp_i_contract ASSIGNING <lfs_contract>.
    lwa_vbak-vbeln = <lfs_contract>-vbeln. " sales Document
    lwa_tvak-auart = <lfs_contract>-doc_type. " Document Type
    lwa_tvko-vkorg = <lfs_contract>-sales_org. " Sales Organization
    lwa_tvtw-vtweg = <lfs_contract>-distr_chan.
                                               " Distribution Channel
    lwa_tvta-vkorg = <lfs_contract>-sales_org. " Sales Organization
    lwa_tvta-vtweg = <lfs_contract>-distr_chan.
                                              " Distribution Channel
    lwa_tvta-spart = <lfs_contract>-division. " Division
    lwa_tspa-spart = <lfs_contract>-division. " Division
    lwa_t176-bsark = <lfs_contract>-po_method.
                                              " Customer Purchase Order Type
    lwa_mara-matnr = <lfs_contract>-material. " Material
    lwa_t006-msehi = <lfs_contract>-target_qu. " Target quantity UoM
    lwa_tvpt-pstyv = <lfs_contract>-item_categ.
                                              " Sales document item category
    lwa_t052-zterm = <lfs_contract>-pmnttrms. " Terms of Payment Key
    lwa_tpar-parvw = <lfs_contract>-partn_role1. " Partner Function
    lwa_kna1-kunnr = <lfs_contract>-partn_numb1. " Customer Number
    APPEND lwa_tpar TO li_tpar.
    APPEND lwa_kna1 TO li_kna1.
    lwa_tpar-parvw = <lfs_contract>-partn_role2. " Partner Function
    lwa_kna1-kunnr = <lfs_contract>-partn_numb2. " Customer Number
*-- Begin of addition D2
    lwa_dupchk-matnr = <lfs_contract>-material.
    lwa_dupchk-soldto = <lfs_contract>-partn_numb1.
    lwa_dupchk-shipto = <lfs_contract>-partn_numb2.
    lwa_dupchk-auart = <lfs_contract>-doc_type.
    APPEND lwa_dupchk TO li_dupchk.
*-- End of addition D2
    APPEND lwa_vbak TO li_vbak.
    APPEND lwa_tvak TO li_tvak.
    APPEND lwa_tvko TO li_tvko.
    APPEND lwa_tvtw TO li_tvtw.
    APPEND lwa_tvta TO li_tvta.
    APPEND lwa_tspa TO li_tspa.
    APPEND lwa_t176 TO li_t176.
    APPEND lwa_mara TO li_mara.
    APPEND lwa_t006 TO li_t006.
    APPEND lwa_tvpt TO li_tvpt.
    APPEND lwa_tpar TO li_tpar.
    APPEND lwa_kna1 TO li_kna1.
    APPEND lwa_t052 TO li_t052.
    CLEAR: lwa_vbak,
           lwa_tvak,
           lwa_tvko,
           lwa_tvtw,
           lwa_tvta,
           lwa_t176,
           lwa_mara,
           lwa_t006,
           lwa_tvpt,
           lwa_tpar,
           lwa_kna1,
           lwa_t052.
  ENDLOOP. " LOOP AT fp_i_contract ASSIGNING <lfs_contract>
*-- Begin of addition D2
  SORT li_dupchk BY
              matnr
              auart
              soldto.

  DELETE ADJACENT DUPLICATES FROM li_dupchk
                    COMPARING matnr auart soldto.
  IF NOT li_dupchk[] IS INITIAL.
    SELECT matnr vkorg trvog audat vtweg
           spart auart kunnr vkbur vkgrp
           bstnk ernam vbeln posnr datab
           datbi " Quotation or contract valid to
      FROM vapma " Sales Index: Order Items by Material
      INTO TABLE li_vapma
      FOR ALL ENTRIES IN li_dupchk
      WHERE matnr = li_dupchk-matnr
        AND auart = li_dupchk-auart
        AND kunnr = li_dupchk-soldto.

    IF sy-subrc EQ 0.
      li_vapmatmp[] = li_vapma[].
      SORT li_vapmatmp BY vbeln.
      DELETE ADJACENT DUPLICATES FROM li_vapmatmp COMPARING vbeln.
      IF NOT li_vapmatmp[] IS INITIAL.
        SELECT vbeln posnr parvw kunnr
          FROM vbpa " Sales Document: Partner
          INTO TABLE li_shipto
          FOR ALL ENTRIES IN li_vapmatmp
          WHERE vbeln = li_vapmatmp-vbeln
            AND posnr = lc_posnr
            AND parvw = lc_shipto.
        IF sy-subrc = 0.
          SORT li_shipto BY vbeln.
          LOOP AT li_vapma ASSIGNING <lfs_vapma>.
            READ TABLE li_shipto ASSIGNING <lfs_shipto> WITH KEY
                                           vbeln = <lfs_vapma>-vbeln
                                           BINARY SEARCH.
            IF sy-subrc = 0.
              <lfs_vapma>-shipto = <lfs_shipto>-shipto.
            ENDIF. " IF sy-subrc = 0
          ENDLOOP. " LOOP AT li_vapma ASSIGNING <lfs_vapma>
          SORT li_vapma BY vbeln matnr auart soldto shipto datbi DESCENDING.
          DELETE ADJACENT DUPLICATES FROM li_vapma
                                 COMPARING vbeln matnr auart soldto shipto.
          SORT li_vapma BY matnr auart soldto shipto datbi DESCENDING.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF NOT li_vapmatmp[] IS INITIAL
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_dupchk[] IS INITIAL
*-- End of addition D2
* Check TABLE VAPMA and VBAP for duplicate contract
* Check Table VBAK & Field VBELN
  IF li_vbak IS NOT INITIAL.
    SORT li_vbak BY vbeln.
    DELETE ADJACENT DUPLICATES FROM li_vbak COMPARING vbeln.
    SELECT vbeln " Sales Document
    FROM vbak    " Sales Document: Header Data
    INTO TABLE i_vbak
    FOR ALL ENTRIES IN li_vbak
    WHERE vbeln = li_vbak-vbeln AND
          vbtyp = c_vbtyp.
    IF sy-subrc = 0.
      SORT i_vbak BY vbeln.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_vbak IS NOT INITIAL

* Check Table TVAK & Field AUART
  IF li_tvak IS NOT INITIAL.
    SORT li_tvak BY auart.
    DELETE ADJACENT DUPLICATES FROM li_tvak COMPARING auart.
    SELECT auart " Sales Document Type
    FROM tvak    " Sales Document Types
    INTO TABLE i_tvak
    FOR ALL ENTRIES IN li_tvak
    WHERE auart = li_tvak-auart.
    IF sy-subrc = 0.
      SORT i_tvak BY auart.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tvak IS NOT INITIAL

* Check Table TVKO & Field VKORG
  IF li_tvko IS NOT INITIAL.
    SORT li_tvko BY vkorg.
    DELETE ADJACENT DUPLICATES FROM li_tvko COMPARING vkorg.
    SELECT vkorg " Sales Organization
    FROM tvko    " Organizational Unit: Sales Organizations
    INTO TABLE i_tvko
    FOR ALL ENTRIES IN li_tvko
    WHERE vkorg = li_tvko-vkorg.
    IF sy-subrc = 0.
      SORT i_tvko BY vkorg.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tvko IS NOT INITIAL

* Check Table TVTW & Field VTWEG
  IF li_tvtw IS NOT INITIAL.
    SORT li_tvtw BY vtweg.
    DELETE ADJACENT DUPLICATES FROM li_tvtw COMPARING vtweg.
    SELECT vtweg " Distribution Channel
    FROM tvtw    " Organizational Unit: Distribution Channels
    INTO TABLE i_tvtw
    FOR ALL ENTRIES IN li_tvtw
    WHERE vtweg = li_tvtw-vtweg.
    IF sy-subrc = 0.
      SORT i_tvtw BY vtweg.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tvtw IS NOT INITIAL

* Check Table TSPA & Field SPART
  IF li_tspa IS NOT INITIAL.
    SORT li_tspa BY spart.
    DELETE ADJACENT DUPLICATES FROM li_tspa COMPARING spart.
    SELECT spart " Division
    FROM tspa    " Organizational Unit: Sales Divisions
    INTO TABLE i_tspa
    FOR ALL ENTRIES IN li_tspa
    WHERE spart = li_tspa-spart.
    IF sy-subrc = 0.
      SORT i_tspa BY spart.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tspa IS NOT INITIAL

* Check Table TVTA & Field VKORG VTWEG SPART
  IF li_tvta IS NOT INITIAL.
    SORT li_tvta BY vkorg vtweg spart.
    DELETE ADJACENT DUPLICATES FROM li_tvta
    COMPARING vkorg vtweg spart.
    SELECT
      vkorg   " Sales Organization
      vtweg   " Distribution Channel
      spart   " Division
    FROM tvta " Organizational Unit: Sales Area(s)
    INTO TABLE i_tvta
    FOR ALL ENTRIES IN li_tvta
    WHERE vkorg = li_tvta-vkorg AND
          vtweg = li_tvta-vtweg AND
          spart = li_tvta-spart.
    IF sy-subrc = 0.
      SORT i_tvta BY vkorg vtweg spart.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tvta IS NOT INITIAL

* Check Table T176 & Field BSARK
  IF li_t176 IS NOT INITIAL.
    SORT li_t176 BY bsark.
    DELETE ADJACENT DUPLICATES FROM li_t176 COMPARING bsark.
    SELECT bsark " Customer purchase order type
    FROM t176    " Sales Documents: Customer Order Types
    INTO TABLE i_t176
    FOR ALL ENTRIES IN li_t176
    WHERE bsark = li_t176-bsark.
    IF sy-subrc = 0.
      SORT i_t176 BY bsark.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_t176 IS NOT INITIAL

* Check Table MARA & field MATNR
  IF li_mara IS NOT INITIAL.
    SORT li_mara BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_mara COMPARING matnr.
    SELECT matnr " Material Number
    FROM mara    " General Material Data
    INTO TABLE i_mara
    FOR ALL ENTRIES IN li_mara
    WHERE matnr = li_mara-matnr.
    IF sy-subrc = 0.
      SORT i_mara BY matnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_mara IS NOT INITIAL

* Check Table T006 & field MSEHI
  IF li_t006 IS NOT INITIAL.
    SORT li_t006 BY msehi.
    DELETE ADJACENT DUPLICATES FROM li_t006 COMPARING msehi.
    SELECT msehi " Unit of Measurement
    FROM t006    " Units of Measurement
    INTO TABLE i_t006
    FOR ALL ENTRIES IN li_t006
    WHERE msehi = li_t006-msehi.
    IF sy-subrc = 0.
      SORT i_t006 BY msehi.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_t006 IS NOT INITIAL

* Check Table TVPT & field PSTYV
  IF li_tvpt IS NOT INITIAL.
    SORT li_tvpt BY pstyv.
    DELETE ADJACENT DUPLICATES FROM li_tvpt COMPARING pstyv.
    SELECT
      pstyv   " Sales document item category
      pstyo   " Object for which you define the item category
    FROM tvpt " Sales documents: Item categories
    INTO TABLE i_tvpt
    FOR ALL ENTRIES IN li_tvpt
    WHERE pstyv = li_tvpt-pstyv.
    IF sy-subrc = 0.
      SORT i_tvpt BY pstyv.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tvpt IS NOT INITIAL

* Check Table TPAR & field PARVW
  IF li_tpar IS NOT INITIAL.
    SORT li_tpar BY parvw.
    DELETE ADJACENT DUPLICATES FROM li_tpar COMPARING parvw.
    SELECT parvw " Partner Function
    FROM tpar    " Business Partner: Functions
    INTO TABLE i_tpar
    FOR ALL ENTRIES IN li_tpar
    WHERE parvw = li_tpar-parvw.
    IF sy-subrc = 0.
      SORT i_tpar BY parvw.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_tpar IS NOT INITIAL

* Check Table KNA1 & field KUNNR
  IF li_kna1 IS NOT INITIAL.
    SORT li_kna1 BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_kna1 COMPARING kunnr.
    SELECT kunnr " Customer Number
    FROM kna1    " General Data in Customer Master
    INTO TABLE i_kna1
    FOR ALL ENTRIES IN li_kna1
    WHERE kunnr = li_kna1-kunnr.
    IF sy-subrc = 0.
      SORT i_kna1 BY kunnr.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_kna1 IS NOT INITIAL

* Check Table T052 & field ZTERM
  IF li_t052 IS NOT INITIAL.
    SORT li_t052 BY zterm.
    DELETE ADJACENT DUPLICATES FROM li_t052 COMPARING zterm.
    SELECT zterm " Terms of Payment Key
           ztagg " Day limit
    FROM t052    " Terms of Payment
    INTO TABLE i_t052
    FOR ALL ENTRIES IN li_t052
    WHERE zterm = li_t052-zterm.
    IF sy-subrc = 0.
      SORT i_t052 BY zterm.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_t052 IS NOT INITIAL

* Validating the necessary fields
  LOOP AT fp_i_contract ASSIGNING <lfs_contract>.
    CLEAR: lwa_contract_temp.

*-- Begin of change D2
    CLEAR lwa_report.
    lwa_report-ref_doc   = <lfs_contract>-vbeln.
    lwa_report-doc_type   = <lfs_contract>-doc_type.
    lwa_report-sales_org   = <lfs_contract>-sales_org.
    lwa_report-distr_chan   = <lfs_contract>-distr_chan.
    lwa_report-division   = <lfs_contract>-division.
    lwa_report-partn_role1   = <lfs_contract>-partn_role1.
    lwa_report-partn_numb1   = <lfs_contract>-partn_numb1.
    lwa_report-partn_role2   = <lfs_contract>-partn_role2.
    lwa_report-partn_numb2   = <lfs_contract>-partn_numb2.
    lwa_report-con_st_dat   = <lfs_contract>-con_st_dat.
    lwa_report-con_en_dat   = <lfs_contract>-con_en_dat.
    lwa_report-material   = <lfs_contract>-material.

    PERFORM f_move_chngcon_error USING <lfs_contract>
                                 CHANGING lwa_contract_temp.

* Validation on Sales document is not required.
    READ TABLE i_val ASSIGNING <lfs_val> WITH KEY
                                 vkorg = <lfs_contract>-sales_org
                                 vtweg = <lfs_contract>-distr_chan.
    IF sy-subrc EQ 0 AND  <lfs_val>-value1 = c_extnl.
*-- End of change D2
      IF <lfs_contract>-vbeln IS NOT INITIAL.
* For Validating Sales Document
* whether its already exist in the table VBAK
        READ TABLE i_vbak TRANSPORTING NO FIELDS
        WITH KEY vbeln = <lfs_contract>-vbeln
        BINARY SEARCH.
        IF sy-subrc EQ 0.
*          lwa_contract_temp = <lfs_contract>. " D2
*          MOVE-CORRESPONDING <lfs_contract> TO lwa_contract_temp. "D2
          PERFORM f_move_chngcon_error USING <lfs_contract>
                                       CHANGING lwa_contract_temp.

          lwa_contract_temp-error_msg =
          'Sales Document already exists'(007).
* I_REPORT table update
          CONCATENATE 'Sales Document'(h01) <lfs_contract>-vbeln
          'already exists'(034) INTO lv_msg
          SEPARATED BY space.
          lwa_report-ref_doc   = <lfs_contract>-vbeln.
          lwa_report-doc_flg   = c_no.
          lwa_report-sales_doc = space.
          lwa_report-equi_flg  = c_no.
          lwa_report-msgtxt    = lv_msg.
*          APPEND lwa_contract_temp TO li_contract_temp.
          APPEND lwa_report TO fp_i_report.
*          CLEAR lwa_report. "D2
          CLEAR lv_msg.
          lv_error = c_ind1.
        ENDIF. " IF sy-subrc EQ 0
      ELSE. " ELSE -> IF sy-subrc EQ 0
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
*       MOVE-CORRESPONDING <lfs_contract> TO lwa_contract_temp. "D2
        lwa_contract_temp-error_msg =
        'Sales Document is mandatory'(028).
*   End  of Changes Defect 346
* I_REPORT table update
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    =
        'Sales Document is mandatory'(028).
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        lv_error = c_ind1.
      ENDIF. " IF <lfs_contract>-vbeln IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0 AND <lfs_val>-value1 = c_extnl

*-- Begin of change D2
* validation for contract availability
    READ TABLE li_vapma ASSIGNING <lfs_vapma> WITH KEY
                                   matnr = <lfs_contract>-material
                                   auart = <lfs_contract>-doc_type
                                   soldto = <lfs_contract>-partn_numb1
                                   shipto = <lfs_contract>-partn_numb2
                                   BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_tabix = sy-tabix.
*        AND <lfs_contract>-con_st_dat LE <lfs_vapma>-datbi ).
*          lwa_contract_temp = <lfs_contract>. " D2
      CLEAR lv_msgvbeln.
      LOOP AT li_vapma INTO lwa_vapma FROM lv_tabix.
        IF  lwa_vapma-matnr = <lfs_contract>-material AND
            lwa_vapma-auart = <lfs_contract>-doc_type AND
            lwa_vapma-soldto = <lfs_contract>-partn_numb1 AND
            lwa_vapma-shipto = <lfs_contract>-partn_numb2.
          IF <lfs_contract>-con_st_dat LE lwa_vapma-datbi.
            CONCATENATE lwa_vapma-vbeln lv_msgvbeln
                   INTO lv_msgvbeln
                   SEPARATED BY space.
          ENDIF. " IF <lfs_contract>-con_st_dat LE lwa_vapma-datbi
        ELSE. " ELSE -> IF <lfs_contract>-con_st_dat LE lwa_vapma-datbi
          EXIT.
        ENDIF. " IF lwa_vapma-matnr = <lfs_contract>-material AND
      ENDLOOP. " LOOP AT li_vapma INTO lwa_vapma FROM lv_tabix
      IF lv_msgvbeln IS NOT INITIAL.
        CONCATENATE 'Contract'(064)
                    'already exists for given'(066)
                    ' Material, Soldto and Shipto'(065)
            INTO lwa_contract_temp-error_msg
            SEPARATED BY space.
*      lwa_contract_temp-error_msg =
*      'Contract already exists for the given Material, Soldto and Shipto'(063).
* I_REPORT table update
        CONCATENATE 'Contract'(064) lv_msgvbeln
        'already exists for given'(066)
        ' Material, Soldto and Shipto'(065) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF lv_msgvbeln IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0
*-- End of change D2

    IF <lfs_contract>-doc_type IS NOT INITIAL.
* For Validating Sales Document Type
* whether its already exist in the table TVAK
      READ TABLE i_tvak TRANSPORTING NO FIELDS
      WITH KEY auart = <lfs_contract>-doc_type
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Sales Document Type does not exist'(008).
* I_REPORT table update
        CONCATENATE 'Sales Document Type'(h02) <lfs_contract>-sales_org
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      lwa_contract_temp-error_msg =
      'Sales Document Type is mandatory'(029).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Sales Document Type is mandatory'(029).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-doc_type IS NOT INITIAL

    IF <lfs_contract>-sales_org IS NOT INITIAL.
* For Validating Sales Organization
* whether its already exist in the table TVKO
      READ TABLE i_tvko TRANSPORTING NO FIELDS
      WITH KEY vkorg = <lfs_contract>-sales_org
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Sales Organization does not exist'(009).
* I_REPORT table update
        CONCATENATE 'Sales Organization'(h03) <lfs_contract>-sales_org
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Sales Organization is mandatory'(032).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Sales Organization is mandatory'(032).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-sales_org IS NOT INITIAL

    IF <lfs_contract>-distr_chan IS NOT INITIAL.
* For Validating Distribution Channel
* whether its already exist in the table TVTW
      READ TABLE i_tvtw TRANSPORTING NO FIELDS
      WITH KEY vtweg = <lfs_contract>-distr_chan
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Distribution Channel does not exist'(010).
* I_REPORT table update
        CONCATENATE 'Distribution Channel'(h04) <lfs_contract>-distr_chan
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Distribution Channel is mandatory'(043).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Distribution Channel is mandatory'(043).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report.  "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-distr_chan IS NOT INITIAL

    IF <lfs_contract>-division IS NOT INITIAL.
* For Validating Division
* whether its already exist in the table TSPA
      READ TABLE i_tspa TRANSPORTING NO FIELDS
      WITH KEY spart = <lfs_contract>-division
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg = 'Division does not exist'(011).
* I_REPORT table update
        CONCATENATE 'Division'(h05) <lfs_contract>-division
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Division is mandatory'(046).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Division is mandatory'(046).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-division IS NOT INITIAL

    IF <lfs_contract>-sales_org IS NOT INITIAL AND
       <lfs_contract>-distr_chan IS NOT INITIAL AND
       <lfs_contract>-division IS NOT INITIAL.
* For Validating Sales Organization, Distribution Channel
* & Division Combination whether its exist in the table TVTA
      READ TABLE i_tvta TRANSPORTING NO FIELDS
      WITH KEY vkorg = <lfs_contract>-sales_org
               vtweg = <lfs_contract>-distr_chan
               spart = <lfs_contract>-division
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'sales org,dist chan,div combination does not exist'(045).
* I_REPORT table update
        CONCATENATE 'sales org,dist chan,div combination'(036)
        <lfs_contract>-sales_org
        <lfs_contract>-distr_chan
        <lfs_contract>-division
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_contract>-sales_org IS NOT INITIAL AND

    IF <lfs_contract>-po_method IS NOT INITIAL.
* For Validating Customer purchase order type
* whether its already exist in the table T176
      READ TABLE i_t176 TRANSPORTING NO FIELDS
      WITH KEY bsark = <lfs_contract>-po_method
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
         'Customer purchase order type does not exist'(012).
* I_REPORT table update
        CONCATENATE 'Customer purchase order type'(h07)
       <lfs_contract>-po_method
       'does not exist'(035) INTO lv_msg
       SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc NE 0
*-- Begin of D2
**   Start of Changes for Defect 346
**          lwa_contract_temp = <lfs_contract>. " D2
*      "
*      lwa_contract_temp-error_msg =
*      'Customer purchase order type is mandatory'(047).
**   End  of Changes Defect 346
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Customer purchase order type is mandatory'(047).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
**      CLEAR lwa_report. "D2
*      lv_error = c_ind1.
*-- End of D2
    ENDIF. " IF <lfs_contract>-po_method IS NOT INITIAL

    IF <lfs_contract>-material IS NOT INITIAL.
* For Validating Material whether its already there in the table MARA
      READ TABLE i_mara TRANSPORTING NO FIELDS
      WITH KEY matnr = <lfs_contract>-material
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg = 'Material does not exist'(013).
* I_REPORT table update
        CONCATENATE 'Material'(h14)
        <lfs_contract>-material
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ELSE. " ELSE -> IF sy-subrc NE 0
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Material is mandatory'(048).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Material is mandatory'(048).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-material IS NOT INITIAL

    IF <lfs_contract>-target_qu IS NOT INITIAL.
* For Validating Target quantity UoM
* whether its already exist in the table T006
      READ TABLE i_t006 TRANSPORTING NO FIELDS
      WITH KEY msehi = <lfs_contract>-target_qu
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Target quantity UoM does not exist'(014).
* I_REPORT table update
        CONCATENATE 'Target quantity UoM'(h16)
        <lfs_contract>-target_qu
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
*-- begin of delete D2
    ENDIF. " IF <lfs_contract>-target_qu IS NOT INITIAL
*    ELSE. " ELSE -> IF sy-subrc NE 0
**   Start of Changes for Defect 346
*      lwa_contract_temp = <lfs_contract>.
*      lwa_contract_temp-error_msg =
*      'Target quantity UoM is mandatory'(049).
**   End  of Changes Defect 346
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Target quantity UoM is mandatory'(049).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
**      CLEAR lwa_report. "D2
*      lv_error = c_ind1.
*    ENDIF. " IF <lfs_contract>-target_qu IS NOT INITIAL
*-- End of delete D2

    IF <lfs_contract>-item_categ IS NOT INITIAL.
* For Validating Sales document item category
* whether its already exist in the table TVPT
      READ TABLE i_tvpt TRANSPORTING NO FIELDS
      WITH KEY pstyv = <lfs_contract>-item_categ
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Sales document item category does not exist'(015).
* I_REPORT table update
        CONCATENATE 'Sales document item category'(h17)
        <lfs_contract>-item_categ
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_contract>-item_categ IS NOT INITIAL

    IF <lfs_contract>-pmnttrms IS NOT INITIAL.
* For Validating Terms of Payment Key
* whether its already exist in the table T052
      READ TABLE i_t052 TRANSPORTING NO FIELDS
      WITH KEY zterm = <lfs_contract>-pmnttrms
      BINARY SEARCH.
      IF sy-subrc NE 0.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Terms of payment category does not exist'(044).
* I_REPORT table update
        CONCATENATE 'Terms of payment category'(037)
        <lfs_contract>-pmnttrms
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc = <lfs_contract>-vbeln.
        lwa_report-doc_flg = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg = c_no.
        lwa_report-msgtxt = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF sy-subrc NE 0
    ENDIF. " IF <lfs_contract>-pmnttrms IS NOT INITIAL

    IF <lfs_contract>-partn_role1 IS NOT INITIAL.
* For Validating Partner Function
* whether its already exist in the table TPAR
      CLEAR lv_err.
      lv_role = <lfs_contract>-partn_role1.
      PERFORM f_partrole USING    lv_role
                         CHANGING lv_err.

      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Partner Function does not exist'(016).
* I_REPORT table update
        CONCATENATE 'Partner Function'(h18)
        <lfs_contract>-partn_role1
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc = <lfs_contract>-vbeln.
        lwa_report-doc_flg = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg = c_no.
        lwa_report-msgtxt = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_role.
    ELSE. " ELSE -> IF lv_err IS NOT INITIAL
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Partner Function is mandatory'(050).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Partner Function is mandatory'(050).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-partn_role1 IS NOT INITIAL

    IF <lfs_contract>-partn_numb1 IS NOT INITIAL.
* For Validating Customer Number
* whether its already exist in the table KNA1
      CLEAR lv_err.
      lv_numb = <lfs_contract>-partn_numb1.
      PERFORM f_partnumb USING    lv_numb
                         CHANGING lv_err.

      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Customer Number does not exist'(017).
* I_REPORT table update
        CONCATENATE 'Customer Number'(h19)
        <lfs_contract>-partn_numb1
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_numb.
    ELSE. " ELSE -> IF lv_err IS NOT INITIAL
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Customer Number is mandatory'(051).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Customer Number is mandatory'(051).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-partn_numb1 IS NOT INITIAL

    IF <lfs_contract>-partn_role2 IS NOT INITIAL.
* For Validating Partner Function
* whether its already exist in the table TPAR
      CLEAR lv_err.
      lv_role = <lfs_contract>-partn_role2.
      PERFORM f_partrole USING    lv_role
                         CHANGING lv_err.

      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Partner Function does not exist'(016).
* I_REPORT table update
        CONCATENATE 'Partner Function'(h18)
        <lfs_contract>-partn_role2
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_role.
    ELSE. " ELSE -> IF lv_err IS NOT INITIAL
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Partner Function is mandatory'(050).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Partner Function is mandatory'(050).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-partn_role2 IS NOT INITIAL

    IF <lfs_contract>-partn_numb2 IS NOT INITIAL.
* For Validating Customer Number
* whether its already exist in the table KNA1
      CLEAR lv_err.
      lv_numb = <lfs_contract>-partn_numb2.
      PERFORM f_partnumb USING    lv_numb
                         CHANGING lv_err.

      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Customer Number does not exist'(017).
* I_REPORT table update
        CONCATENATE 'Customer Number'(h19)
        <lfs_contract>-partn_numb2
        'does not exist'(035) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
        lv_error = c_ind1.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_numb.
    ELSE. " ELSE -> IF lv_err IS NOT INITIAL
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Customer Number is mandatory'(051).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Customer Number is mandatory'(051).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-partn_numb2 IS NOT INITIAL

    IF <lfs_contract>-purch_date IS NOT INITIAL AND
       <lfs_contract>-purch_date <> space.

      CLEAR lv_err.
      lv_date = <lfs_contract>-purch_date.
      PERFORM f_datecheck USING    lv_date
                          CHANGING lv_err.
      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Purchase date is not valid'(023).
* I_REPORT table update
        CONCATENATE 'Purchase date'(038)
        <lfs_contract>-purch_date
        'is not valid'(039) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_date.
*&--BOC COMMENT Defect#2090 RVERMA 12/12/2012
*    ELSE.
**   Start of Changes for Defect 346
*        lwa_contract_temp = <lfs_contract>.
*        lwa_contract_temp-error_msg =
*        'Purchase date is mandatory'(052).
**   End  of Changes Defect 346
*
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Purchase date is mandatory'(052).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report.
*      lv_error = c_ind1.
*&--EOC COMMENT Defect#2090 RVERMA 12/12/2012
    ENDIF. " IF <lfs_contract>-purch_date IS NOT INITIAL AND

    IF <lfs_contract>-doc_date IS NOT INITIAL AND
       <lfs_contract>-doc_date  <> space.
      CLEAR lv_err.
      lv_date = <lfs_contract>-doc_date.
      PERFORM f_datecheck USING lv_date
                          CHANGING lv_err.
      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Document date is not valid'(024).
* I_REPORT table update
        CONCATENATE 'Document date'(040)
        <lfs_contract>-doc_date
        'is not valid'(039) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_date.
*&--BOC COMMENT Defect#2090 RVERMA 12/12/2012
*    ELSE.
**   Start of Changes for Defect 346
*        lwa_contract_temp = <lfs_contract>.
*        lwa_contract_temp-error_msg =
*        'Document date is mandatory'(053).
**   End  of Changes Defect 346
*
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Document date is mandatory'(053).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report.
*      lv_error = c_ind1.
*&--EOC COMMENT Defect#2090 RVERMA 12/12/2012
    ENDIF. " IF <lfs_contract>-doc_date IS NOT INITIAL AND
*START OF CHANGE Defect 346
*    IF <lfs_contract>-accept_dat IS NOT INITIAL.
*      CLEAR lv_err.
*      lv_date = <lfs_contract>-accept_dat.
*      PERFORM f_datecheck USING lv_date
*                          CHANGING lv_err.
*      IF lv_err IS NOT INITIAL.
*        lwa_contract_temp = <lfs_contract>.
*        lwa_contract_temp-error_msg =
*        'Acceptance date is not valid'(025).
** I_REPORT table update
*        CONCATENATE 'Acceptance date'(041)
*        <lfs_contract>-accept_dat
*        'is not valid'(039) INTO lv_msg
*        SEPARATED BY space.
*        lwa_report-ref_doc   = <lfs_contract>-vbeln.
*        lwa_report-doc_flg   = c_no.
*        lwa_report-sales_doc = space.
*        lwa_report-equi_flg  = c_no.
*        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
*        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report.
*        CLEAR lv_msg.
*      ENDIF.
*      CLEAR lv_date.
*    ELSE.
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Acceptance date is mandatory'(054).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report.
*      lv_error = c_ind1.
*    ENDIF.
*END OF CHANGE Defect 346

    IF <lfs_contract>-con_st_dat IS NOT INITIAL AND
       <lfs_contract>-con_st_dat <> space.
      CLEAR lv_err.
      lv_date = <lfs_contract>-con_st_dat.
      PERFORM f_datecheck USING lv_date
                          CHANGING lv_err.
      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Contract Start date is not valid'(026).
* I_REPORT table update
        CONCATENATE 'Contract Start date'(042)
        <lfs_contract>-con_st_dat
        'is not valid'(039) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_date.
    ELSE. " ELSE -> IF lv_err IS NOT INITIAL
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Contract start date is mandatory'(055).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Contract start date is mandatory'(055).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-con_st_dat IS NOT INITIAL AND

    IF <lfs_contract>-con_en_dat IS NOT INITIAL AND
       <lfs_contract>-con_en_dat <> space.
      CLEAR lv_err.
      lv_date = <lfs_contract>-con_en_dat.
      PERFORM f_datecheck USING lv_date
                          CHANGING lv_err.
      IF lv_err IS NOT INITIAL.
*          lwa_contract_temp = <lfs_contract>. " D2
        "
        lwa_contract_temp-error_msg =
        'Contract End date is not valid'(027).
* I_REPORT table update
        CONCATENATE 'Contract End date'(h23)
        <lfs_contract>-con_en_dat
        'is not valid'(039) INTO lv_msg
        SEPARATED BY space.
        lwa_report-ref_doc   = <lfs_contract>-vbeln.
        lwa_report-doc_flg   = c_no.
        lwa_report-sales_doc = space.
        lwa_report-equi_flg  = c_no.
        lwa_report-msgtxt    = lv_msg.
*        APPEND lwa_contract_temp TO li_contract_temp.
        APPEND lwa_report TO fp_i_report.
*        CLEAR lwa_report. "D2
        CLEAR lv_msg.
      ENDIF. " IF lv_err IS NOT INITIAL
      CLEAR lv_date.
    ELSE. " ELSE -> IF lv_err IS NOT INITIAL
*   Start of Changes for Defect 346
*          lwa_contract_temp = <lfs_contract>. " D2
      "
      lwa_contract_temp-error_msg =
      'Contract end date is mandatory'(056).
*   End  of Changes Defect 346
* I_REPORT table update
      lwa_report-ref_doc   = <lfs_contract>-vbeln.
      lwa_report-doc_flg   = c_no.
      lwa_report-sales_doc = space.
      lwa_report-equi_flg  = c_no.
      lwa_report-msgtxt    =
      'Contract end date is mandatory'(056).
*      APPEND lwa_contract_temp TO li_contract_temp.
      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report. "D2
      lv_error = c_ind1.
    ENDIF. " IF <lfs_contract>-con_en_dat IS NOT INITIAL AND
*-- begin of D2
*    IF <lfs_contract>-purch_no_c IS INITIAL.
**   Start of Changes for Defect 346
**          lwa_contract_temp = <lfs_contract>. " D2
*      "
*      lwa_contract_temp-error_msg =
*      'Customer purchase order number is mandatory'(057).
**   End  of Changes Defect 346
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Customer purchase order number is mandatory'(057).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
**      CLEAR lwa_report. "D2
*      lv_error = c_ind1.
*    ENDIF. " IF <lfs_contract>-purch_no_c IS INITIAL
*-- End of D2

*-- Begin of D2
*    IF <lfs_contract>-itm_number IS INITIAL.
**   Start of Changes for Defect 346
**          lwa_contract_temp = <lfs_contract>. " D2
*      "
*      lwa_contract_temp-error_msg =
*      'Sales document item is mandatory'(058).
**   End  of Changes Defect 346
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Sales document item is mandatory'(058).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
**      CLEAR lwa_report. "D2
*      lv_error = c_ind1.
*    ENDIF. " IF <lfs_contract>-itm_number IS INITIAL
*-- End of D2

*Start Of Defect 1438 ( CR 197 )
*    IF <lfs_contract>-sernr IS INITIAL.
**   Start of Changes for Defect 346
*        lwa_contract_temp = <lfs_contract>.
*        lwa_contract_temp-error_msg =
*        'Serial Number is mandatory'(059).
**   End  of Changes Defect 346
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Serial Number is mandatory'(059).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report.
*      lv_error = c_ind1.
*    ENDIF.
*End Of Defect 1438 ( CR 197 )

*&--BOC COMMENT Defect#2090 RVERMA 12/12/2012
*    IF <lfs_contract>-equnr IS INITIAL.
**   Start of Changes for Defect 346
*        lwa_contract_temp = <lfs_contract>.
*        lwa_contract_temp-error_msg =
*        'Equipment Number is mandatory'(060).
**   End  of Changes Defect 346
** I_REPORT table update
*      lwa_report-ref_doc   = <lfs_contract>-vbeln.
*      lwa_report-doc_flg   = c_no.
*      lwa_report-sales_doc = space.
*      lwa_report-equi_flg  = c_no.
*      lwa_report-msgtxt    =
*      'Equipment Number is mandatory'(060).
*      APPEND lwa_contract_temp TO li_contract_temp.
*      APPEND lwa_report TO fp_i_report.
*      CLEAR lwa_report.
*      lv_error = c_ind1.
*    ENDIF.
*&--EOC COMMENT Defect#2090 RVERMA 12/12/2012

*    IF lv_error IS INITIAL.
*-- Begin of D2
* check for the duplicate records in the file
*      READ TABLE li_contract_temp WITH KEY
*                              vbeln = lwa_contract_temp-vbeln
*                              doc_type = lwa_contract_temp-doc_type
*                              sales_org = lwa_contract_temp-sales_org
*                              distr_chan = lwa_contract_temp-distr_chan
*                              division = lwa_contract_temp-division
*                              partn_role1 = lwa_contract_temp-partn_role1
*                              partn_numb1 = lwa_contract_temp-partn_numb1
*                              partn_role2 = lwa_contract_temp-partn_role2
*                              partn_numb2 = lwa_contract_temp-partn_numb2
*                              con_st_dat = lwa_contract_temp-con_st_dat
*                              con_en_dat = lwa_contract_temp-con_en_dat
*                              material = lwa_contract_temp-material
*                              TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        lv_error = c_ind1.
*        lwa_contract_temp-error_msg =
*              'Duplicate record exists'(067).
*        lwa_report-ref_doc   = <lfs_contract>-vbeln.
*        lwa_report-doc_flg   = c_no.
*        lwa_report-sales_doc = space.
*        lwa_report-equi_flg  = c_no.
*        lwa_report-msgtxt    =
*        'Duplicate record exists'(067).
*        APPEND lwa_report TO fp_i_report.
*      ENDIF. " IF sy-subrc = 0
*-- End of D2
    APPEND lwa_contract_temp TO li_contract_temp. "D2
*      APPEND <lfs_contract> TO li_contract_temp."D2
*    ENDIF. " IF lv_error IS INITIAL

*    AT END OF vbeln.  "D2
    AT END OF pmnttrms. "D2
      IF li_contract_temp IS NOT INITIAL.
* Seggregating the records based on the error flag
        IF lv_error EQ c_ind1. " error flag
*-- Begin of D2
          CLEAR lv_lines.
          DESCRIBE TABLE li_contract_temp LINES lv_lines.
          fp_gv_ecount = fp_gv_ecount + lv_lines. " Error count
*          fp_gv_ecount = fp_gv_ecount + 1. " Error count
*-- End of D2
          APPEND LINES OF li_contract_temp TO fp_i_error.
        ELSE. " ELSE -> IF li_contract_temp IS NOT INITIAL
*-- Begin of deletion D2
          IF rb_vrfy EQ c_ind1.
*            READ TABLE li_contract_temp INTO lwa_contract_temp INDEX 1.
*            IF sy-subrc EQ 0.
* I_REPORT table update
            LOOP AT li_contract_temp INTO lwa_contract_temp.
              CLEAR lwa_report.
              lwa_report-ref_doc   = lwa_contract_temp-vbeln.
              lwa_report-doc_type   = lwa_contract_temp-doc_type.
              lwa_report-sales_org   = lwa_contract_temp-sales_org.
              lwa_report-distr_chan   = lwa_contract_temp-distr_chan.
              lwa_report-division   = lwa_contract_temp-division.
              lwa_report-partn_role1   = lwa_contract_temp-partn_role1.
              lwa_report-partn_numb1   = lwa_contract_temp-partn_numb1.
              lwa_report-partn_role2   = lwa_contract_temp-partn_role2.
              lwa_report-partn_numb2   = lwa_contract_temp-partn_numb2.
              lwa_report-con_st_dat   = lwa_contract_temp-con_st_dat.
              lwa_report-con_en_dat   = lwa_contract_temp-con_en_dat.
              lwa_report-material   = lwa_contract_temp-material.

              lwa_report-ref_doc   = lwa_contract_temp-vbeln.
              lwa_report-doc_flg   = c_no.
              lwa_report-sales_doc = space.
              lwa_report-equi_flg  = c_no.
              lwa_report-msgtxt    =
*          'valid sales document'(061). "D2
              'valid record'(062). "D2
              APPEND lwa_report TO fp_i_report.
*            ENDIF. " IF sy-subrc EQ 0
            ENDLOOP. " loop at li_contract_temp into lwa_contract_temp
          ENDIF. " IF rb_vrfy EQ c_ind1

*-- End of deletion D2
*-- Begin of D2
          CLEAR lv_lines.
          DESCRIBE TABLE li_contract_temp LINES lv_lines.
          fp_gv_scount = fp_gv_scount + lv_lines. " Success Count
*          fp_gv_scount = fp_gv_scount + 1. " Success Count
*-- End of D2
          APPEND LINES OF li_contract_temp TO fp_i_final.
          CLEAR lwa_contract_temp.
        ENDIF. " IF li_contract_temp IS NOT INITIAL
        REFRESH li_contract_temp.
        CLEAR lv_error.
      ENDIF. " LOOP AT fp_i_contract ASSIGNING <lfs_contract>
    ENDAT.

  ENDLOOP.
ENDFORM. " F_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_DATECHECK
*&---------------------------------------------------------------------*
*       Function module to validate the date fields
*----------------------------------------------------------------------*
*      -->FP_LV_DATE   Input date that has to be validated
*      <--FP_LV_ERROR  Setting the error flag in case of error
*----------------------------------------------------------------------*
FORM f_datecheck  USING    fp_lv_date TYPE sy-datum " Current Date of Application Server
                  CHANGING fp_lv_err TYPE char1.    " Lv_err of type CHAR1
  CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
    EXPORTING
      date                      = fp_lv_date
    EXCEPTIONS
      plausibility_check_failed = 1
      OTHERS                    = 2.
  IF sy-subrc <> 0.
    fp_lv_err = c_ind1.
  ENDIF. " IF sy-subrc <> 0


ENDFORM. " F_DATECHECK
*&---------------------------------------------------------------------*
*&      Form  F_PARTROLE
*&---------------------------------------------------------------------*
*       To validate the Partner Function
*----------------------------------------------------------------------*
*      -->FP_LV_ROLE   Partner Function
*      <--FP_LV_ERR    Error Flag
*----------------------------------------------------------------------*
FORM f_partrole  USING    fp_lv_role TYPE parvw  " Partner Function
                 CHANGING fp_lv_err  TYPE char1. " Lv_err of type CHAR1

  IF fp_lv_role IS NOT INITIAL.
    READ TABLE i_tpar TRANSPORTING NO FIELDS
  WITH KEY parvw = fp_lv_role
  BINARY SEARCH.
    IF sy-subrc NE 0.
      fp_lv_err = c_ind1.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF fp_lv_role IS NOT INITIAL

ENDFORM. " F_PARTROLE
*&---------------------------------------------------------------------*
*&      Form  F_PARTNUMB
*&---------------------------------------------------------------------*
*       To validate customer Number
*----------------------------------------------------------------------*
*      -->FP_LV_NUMB   customer Number
*      <--FP_LV_ERROR  Error Flag
*----------------------------------------------------------------------*
FORM f_partnumb  USING    fp_lv_numb TYPE kunnr  " Customer Number
                 CHANGING fp_lv_err  TYPE char1. " Lv_err of type CHAR1

  IF fp_lv_numb IS NOT INITIAL.
    READ TABLE i_kna1 TRANSPORTING NO FIELDS
  WITH KEY kunnr = fp_lv_numb
  BINARY SEARCH.
    IF sy-subrc NE 0.
      fp_lv_err = c_ind1.
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF fp_lv_numb IS NOT INITIAL

ENDFORM. " F_PARTNUMB

*&---------------------------------------------------------------------*
*&      Form  F_UPLOADING_TSN
*&---------------------------------------------------------------------*
*       Uploading the records using the function module
*----------------------------------------------------------------------*
*      -->FP_I_TSN[]    Internal table containing valid records
*      <--FP_I_ERROR[]  Internal table containing the error records
*      <--FP_GV_ECOUNT  Gives the Error count
*      <--FP_GV_SCOUNT  Gives the success count
*      <--FP_I_REPORT   For populating the report
*----------------------------------------------------------------------*
FORM f_uploading_tsn  USING     fp_i_final   TYPE ty_t_contr_tsn
                       CHANGING fp_i_report  TYPE ty_t_report.

  DATA:
        lwa_bdcmsg TYPE bdcmsgcoll,  " BDC Message
        lv_msgid   TYPE symsgid,     " Message Class
        lv_msgnr   TYPE symsgno,     " Message Number
        lv_msgv1   TYPE symsgv,      " Message Variable
        lv_msgv2   TYPE symsgv,      " Message Variable
        lv_msgv3   TYPE symsgv,      " Message Variable
        lv_msgv4   TYPE symsgv,      " Message Variable
        lv_msg     TYPE char200,     " Reporting the error message
        lv_key     TYPE bapi_msg,    " Message Text
        lv_txtfmt  TYPE bapi_tfrmt,  " Format of documentation texts
        lv_posnr      TYPE posnr_va. " Sales Document Item
* Call Transaction( Transaction VA42 ) for loading the fields
* Serial Number and Equipment Number

  FIELD-SYMBOLS: <lfs_final> TYPE ty_contr_tsn. " Field symbol for input records

  LOOP AT fp_i_final ASSIGNING <lfs_final>.
*    AT NEW vbeln."D2
    AT NEW pmnttrms. "D2
      CLEAR lv_posnr.
      REFRESH i_bdcdata.
      PERFORM f_bdc_dynpro    USING 'SAPMV45A' '0102'.
      PERFORM f_bdc_field     USING 'BDC_OKCODE'
                                    '/00'.
      PERFORM f_bdc_field     USING 'VBAK-VBELN'
                                    <lfs_final>-vbeln1.
    ENDAT.
    lv_posnr = lv_posnr + 10. " D2
    PERFORM f_bdc_dynpro      USING 'SAPMV45A' '4001'.
    PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                    '=POPO'.
    PERFORM f_bdc_dynpro      USING 'SAPMV45A' '0251'.
    PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                  '=POSI'.
*-- Begin of D2
    IF <lfs_final>-itm_number IS NOT INITIAL AND
      <lfs_final>-itm_number NE ''.
      PERFORM f_bdc_field       USING 'RV45A-POSNR'
                                     <lfs_final>-itm_number.
    ELSE. " ELSE -> IF <lfs_final>-itm_number IS NOT INITIAL AND
      PERFORM f_bdc_field       USING 'RV45A-POSNR'
                                    lv_posnr.
    ENDIF. " IF <lfs_final>-itm_number IS NOT INITIAL AND
*-- End of D2
    PERFORM f_bdc_dynpro      USING 'SAPMV45A' '4001'.
    PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                  '=POTO'.
    PERFORM f_bdc_field       USING 'RV45A-VBAP_SELKZ(01)'
                                   c_ind1.
    PERFORM f_bdc_dynpro      USING 'SAPLIWOL' '0220'.
    PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM f_bdc_field       USING 'RIWOL-SERNR(01)'
                                  <lfs_final>-sernr.
*-- Begin of D2
*    PERFORM f_bdc_field       USING 'RIWOL-MATNR(01)'
*                                  <lfs_final>-equnr.
    PERFORM f_bdc_field       USING 'RIWOL-MATNR(01)'
                                  <lfs_final>-material.
    PERFORM f_bdc_field       USING 'RIWOL-EQUNR(01)'
                                  <lfs_final>-equnr.
*-- End of D2
    PERFORM f_bdc_dynpro      USING 'SAPLIWOL' '0220'.
    PERFORM f_bdc_field       USING 'BDC_OKCODE'
                                  '=BACK'.

*    AT END OF vbeln. "D2
    AT END OF pmnttrms. "D2
*-- Begin of changes D2
      CLEAR wa_report.
      wa_report-ref_doc   = <lfs_final>-vbeln.
      wa_report-doc_type   = <lfs_final>-doc_type.
      wa_report-sales_org   = <lfs_final>-sales_org.
      wa_report-distr_chan   = <lfs_final>-distr_chan.
      wa_report-division   = <lfs_final>-division.
      wa_report-partn_role1   = <lfs_final>-partn_role1.
      wa_report-partn_numb1   = <lfs_final>-partn_numb1.
      wa_report-partn_role2   = <lfs_final>-partn_role2.
      wa_report-partn_numb2   = <lfs_final>-partn_numb2.
      wa_report-con_st_dat   = <lfs_final>-con_st_dat.
      wa_report-con_en_dat   = <lfs_final>-con_en_dat.
      wa_report-material   = <lfs_final>-material.
*-- End of changes D2

** Call Transaction
      IF i_bdcdata IS NOT INITIAL.
        PERFORM f_bdc_dynpro  USING 'SAPMV45A' '4001'.
        PERFORM f_bdc_field   USING 'BDC_OKCODE'
                                      '=SICH'.
      ENDIF. " IF i_bdcdata IS NOT INITIAL
      REFRESH i_bdcmsg. " D2
      CALL TRANSACTION c_tcode
      USING i_bdcdata
            MODE gv_mode_bdc
            UPDATE c_update
            MESSAGES INTO i_bdcmsg.

* If the call transaction fails
      IF sy-subrc NE 0.
* I_REPORT table update
        wa_report-ref_doc   = <lfs_final>-vbeln.
        wa_report-doc_flg   = c_yes.
        wa_report-sales_doc = space.
        wa_report-equi_flg  = c_no.
        wa_report-sales_doc  = <lfs_final>-vbeln1. " D2
        wa_report-msgtxt    = 'Transaction failed'(018).
*        APPEND wa_report TO fp_i_report. " D2

        LOOP AT i_bdcmsg INTO lwa_bdcmsg.
          CLEAR: lv_key,
                 lv_msg.
          lv_msgid = lwa_bdcmsg-msgid.
          lv_msgnr = lwa_bdcmsg-msgnr.
          lv_msgv1 = lwa_bdcmsg-msgv1.
          lv_msgv2 = lwa_bdcmsg-msgv2.
          lv_msgv3 = lwa_bdcmsg-msgv3.
          lv_msgv4 = lwa_bdcmsg-msgv4.

* FUnction Module to get the message text- BAPI_MESSAGE_GETDETAIL

          CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
            EXPORTING
              id         = lv_msgid
              number     = lv_msgnr
              textformat = lv_txtfmt
              message_v1 = lv_msgv1
              message_v2 = lv_msgv2
              message_v3 = lv_msgv3
              message_v4 = lv_msgv4
            IMPORTING
              message    = lv_key.

* Report Update
*-- Begin of deletion D2
*          wa_report-ref_doc  = <lfs_final>-vbeln.
*          wa_report-doc_flg  = c_yes.
*          wa_report-equi_flg = c_no.
*          wa_report-msgtxt   = lv_key.
*-- End of deletion D2
          IF NOT wa_report-msgtxt IS INITIAL.
            CONCATENATE lv_key wa_report-msgtxt
                   INTO wa_report-msgtxt
                   SEPARATED BY c_slash. " D2
          ELSE. " ELSE -> IF NOT wa_report-msgtxt IS INITIAL
            wa_report-msgtxt   = lv_key.
          ENDIF. " IF NOT wa_report-msgtxt IS INITIAL
*-- Begin of deletion D2
*            MODIFY fp_i_report FROM wa_report TRANSPORTING equi_flg msgtxt
*              WHERE ref_doc = <lfs_final>-vbeln.
*-- End of deletion D2
        ENDLOOP. " LOOP AT i_bdcmsg INTO lwa_bdcmsg
*-- Begin of changes " D2
        MODIFY fp_i_report FROM wa_report TRANSPORTING equi_flg msgtxt
          WHERE ref_doc = <lfs_final>-vbeln
            AND sales_doc = <lfs_final>-vbeln1.
*-- End of changes " D2
      ELSE. " ELSE -> IF sy-subrc NE 0
* Report Update
        CONCATENATE 'Serial Number'(h24) <lfs_final>-sernr
        'Equipment Number'(h25) <lfs_final>-equnr 'updated'(033)
        INTO lv_msg
        SEPARATED BY space.
        wa_report-ref_doc = <lfs_final>-vbeln.
        wa_report-doc_flg = c_yes.
        wa_report-equi_flg = c_yes.
        wa_report-msgtxt = lv_msg.
        wa_report-sales_doc  = <lfs_final>-vbeln1. " D2
*-- Begin of changes " D2
        MODIFY fp_i_report FROM wa_report TRANSPORTING equi_flg msgtxt
          WHERE ref_doc = <lfs_final>-vbeln
            AND sales_doc = <lfs_final>-vbeln1.
*-- End of changes " D2
      ENDIF. " IF sy-subrc NE 0
    ENDAT.
  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

ENDFORM. " F_UPLOADING_TSN
*&---------------------------------------------------------------------*
*&      Form  f_bdc_dynpro
*&---------------------------------------------------------------------*
*       This is used for populating program name and screen number
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM        BDC Program Name
*      -->FP_V_DYNPRO         BDC Screen Dynpro No.
*      <--FP_I_BDCDATA        Filled up BDC Data
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
ENDFORM. " F_f_bdc_dynpro

*&---------------------------------------------------------------------*
*&      Form  F_f_bdc_field
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*      <--FP_I_BDCDATA   Populated BDC Data
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
ENDFORM. " F_f_bdc_field

*&---------------------------------------------------------------------*
*&      Form  F_MOVE
*&---------------------------------------------------------------------*
*       Moving Source File to DONE Folder if Validate & Post option is
*       chosen
*----------------------------------------------------------------------*
*      -->FP_V_SOURCE  Source File Path
*----------------------------------------------------------------------*
FORM f_move  USING    fp_v_source TYPE localfile. " Local file for upload/download

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
    MESSAGE i018.
  ENDIF. " IF lv_return IS INITIAL



ENDFORM. " F_MOVE

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_ERROR
*&---------------------------------------------------------------------*
*       Moving Error file to Error folder.
*----------------------------------------------------------------------*
*      -->FP_P_AFILE      Source file path
*      -->FP_I_ERROR[]    Error File with error records
*----------------------------------------------------------------------*
FORM f_move_error  USING  fp_p_afile  TYPE localfile " Local file for upload/download
                          fp_i_error  TYPE ty_t_error.
* Local Data
  DATA: lv_file        TYPE localfile,     "File Name
        lv_name        TYPE localfile,     "File Name
        lv_data        TYPE string,        "Output data string
        lv_target_qty  TYPE char7,         "Target quantity in sales units
        lwa_error      TYPE ty_contract_e. "Error work area

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
  CONCATENATE lv_file c_slash lv_name INTO lv_file.

* Write the records
  OPEN DATASET lv_file FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc NE 0.
    MESSAGE i019.
  ELSE. " ELSE -> IF sy-subrc NE 0
*   Forming the header text line
    CONCATENATE  'Sales Document'(h01)
                 'Sales Document Type'(h02)
                 'Sales Organization'(h03)
                 'Distribution Channel'(h04)
                 'Division'(h05)
                 'Collect No'(h28)
                 'Customer purchase order date'(h06)
                 'Customer purchase order type'(h07)
                 'Name of orderer'(h08)
                 'Telephone Number'(h09)
                 'Customer purchase order number'(h10)
                 'Document Date'(h11)
                 'Terms of Payment Key'(h12)
                 'Sales Document Item'(h13)
                 'Material'(h14)
                 'Target quantity in sales units'(h15)
                 'Target quantity UoM'(h16)
                 'Sales document item category'(h17)
                 'Partner Function'(h18)
                 'Customer Number'(h19)
                 'Partner Function'(h18)
                 'Customer Number'(h19)
                 'Installation date'(h20)
                 'Agreement acceptance date'(h21)
                 'Contract start date'(h22)
                 'Contract End date'(h23)
                 'Serial Number'(h24)
                 'Equipment Number'(h25)
                 'Error Message'(h26)
         INTO lv_data
         SEPARATED BY c_tab.
    TRANSFER lv_data TO lv_file.
    CLEAR lv_data.

*   Passing the Error Header data
    LOOP AT fp_i_error INTO lwa_error.
      CLEAR lv_target_qty.
      lv_target_qty = lwa_error-target_qty.
      CONCATENATE
lwa_error-vbeln       " Sales Document
lwa_error-doc_type    " Sales Document Type
lwa_error-sales_org   " Sales Organization
lwa_error-distr_chan  " Distribution Channel
lwa_error-division    " Division
lwa_error-collect_no  " Collective No
lwa_error-purch_date  " Customer purchase order date
lwa_error-po_method   " Customer purchase order type
lwa_error-name        " Name of orderer
lwa_error-telephone   " Telephone Number
lwa_error-purch_no_c  " Customer purchase order number
lwa_error-doc_date    " Document Date (Date Received/Sent)
lwa_error-pmnttrms    " Terms of Payment Key
lwa_error-itm_number  " Sales Document Item
lwa_error-material    " Material
lv_target_qty         " Target quantity in sales units
lwa_error-target_qu   " Target quantity UoM
lwa_error-item_categ  " Sales document item category
lwa_error-partn_role1 " Partner Function
lwa_error-partn_numb1 " Customer Number 1
lwa_error-partn_role2 " Partner Function
lwa_error-partn_numb2 " Customer Number 1
lwa_error-inst_date   " Installation date
lwa_error-accept_dat  " Agreement acceptance date
lwa_error-con_st_dat  " Contract start date
lwa_error-con_en_dat  " Contract end date
lwa_error-sernr       " Serial Number
lwa_error-equnr       " Equipment Number
lwa_error-error_msg   " Error Meassage
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
*&      Form  F_CONV_INPUT
*&---------------------------------------------------------------------*
*       Conversion Exit for the input field Division
*----------------------------------------------------------------------*
*  -->  fp_division        input field Division
*  <--  fp_division        input field Division after conversion Exit
*----------------------------------------------------------------------*
FORM f_conv_input USING fp_division TYPE spart   " Division
                  CHANGING fp_divisn TYPE spart. " Division

  IF fp_division IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fp_division
      IMPORTING
        output = fp_divisn.

  ENDIF. " IF fp_division IS NOT INITIAL

ENDFORM. " F_CONV_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_CONV_INP
*&---------------------------------------------------------------------*
*       Conversion Exit for Partner Function
*----------------------------------------------------------------------*
*      -->FP_PARTN_ROLE  Partner Function
*      <--FP_PARTN_ROL  Partner Function
*----------------------------------------------------------------------*
FORM f_conv_inp  USING    fp_partn_role TYPE parvw " Partner Function
                 CHANGING fp_partn_rol TYPE parvw. " Partner Function

  IF fp_partn_role IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_PARVW_INPUT'
      EXPORTING
        input  = fp_partn_role
      IMPORTING
        output = fp_partn_rol.

  ENDIF. " IF fp_partn_role IS NOT INITIAL

ENDFORM. " F_CONV_INP
*&---------------------------------------------------------------------*
*&      Form  F_CON_INP
*&---------------------------------------------------------------------*
*       Conversion Exit for the input field Customer Number
*----------------------------------------------------------------------*
*  -->  fp_division  input field Customer Number
*  <--  fp_division  input field Customer Number after conversion Exit
*----------------------------------------------------------------------*
FORM f_con_inp USING       fp_numb  TYPE kunnr  " Customer Number
                  CHANGING fp_numbr TYPE kunnr. " Customer Number

  IF fp_numb IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fp_numb
      IMPORTING
        output = fp_numbr.

  ENDIF. " IF fp_numb IS NOT INITIAL

ENDFORM. " F_CONV_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CONV_ITEM
*&---------------------------------------------------------------------*
*       Conversion Exit for the input field item Number
*----------------------------------------------------------------------*
*  -->  fp_itemnr        input field Item Number
*  <--  fp_item          input field Item Number after conversion Exit
*----------------------------------------------------------------------*
FORM f_conv_item USING fp_itemnr   TYPE posnr_va  " Sales Document Item
                  CHANGING fp_item TYPE posnr_va. " Sales Document Item

  IF fp_itemnr IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = fp_itemnr
      IMPORTING
        output = fp_item.

  ENDIF. " IF fp_itemnr IS NOT INITIAL

ENDFORM. " F_CONV_INPUT
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  f_display_summary_report
*&---------------------------------------------------------------------*
*       Dispalying Summary Report for ONE INPUT FILE.
*&---------------------------------------------------------------------*
*      -->FP_P_REPORT       Report Table
*      -->FP_gv_filename_d  Input File Name
*      -->FP_GV_MODE        Mode of execution of program
*      -->FP_NO_SUCCESS     Number of successfully processed record.
*      -->FP_NO_FAILED      Number of record failed.
*----------------------------------------------------------------------*
FORM f_display_report  USING    fp_i_report      TYPE ty_t_report
                                fp_gv_filename_d TYPE localfile " Local file for upload/download
                                fp_gv_mode       TYPE char10    " Gv_mode of type CHAR10
                                fp_no_success    TYPE int2      " 2 byte integer (signed)
                                fp_no_failed     TYPE int2.     " 2 byte integer (signed)
* Local Data declaration
  TYPES: BEGIN OF lty_report_b,
           ref_doc   TYPE vbeln, " Sales Document in input
*-- Begin of addition D2
          doc_type    TYPE auart,      " Sales Document Type
          sales_org   TYPE vkorg,      " Sales Organization
          distr_chan  TYPE vtweg,      " Distribution Channel
          division    TYPE spart,      " Division
          partn_role1 TYPE parvw,      " Partner Function
          partn_numb1 TYPE kunnr,      " Customer Number 1
          partn_role2 TYPE parvw,      " Partner Function
          partn_numb2 TYPE kunnr,      " Customer Number 1
          con_st_dat  TYPE vbdat_veda, " Contract start date
          con_en_dat  TYPE vndat_veda, " Contract end date
          material    TYPE matnr,      " Material
*-- End of addition D2
           doc_flg   TYPE char1,   " Flg of type CHAR1
                                   " Flag to identify whether Sales Document created or not
           sales_doc TYPE vbeln,   " Sales Document created by SAP
           equi_flg  TYPE char1,   " Flg of type CHAR1
                                   " Flag to identify whether Equipment and Serial Number
                                   " created or not
           msgtxt    TYPE char300, " To provide Error/Success Message
         END OF lty_report_b.

  CONSTANTS: lc_hline TYPE char100 " Dotted Line
             VALUE
'-----------------------------------------------------------'.

  DATA: li_report      TYPE STANDARD TABLE OF lty_report_b
                                                     INITIAL SIZE 0,
        lv_uzeit       TYPE char20,                          "Time
        lv_datum       TYPE char20,                          "Date
        lv_total       TYPE int4,                            "Total
        lv_rate        TYPE int4,                            "Rate
        lv_rate_c      TYPE char5,                           "Rate text
        lv_alv         TYPE REF TO cl_salv_table,            "ALV Inst.
        lv_ex_msg      TYPE REF TO cx_salv_msg,              "Message
        lv_ex_notfound TYPE REF TO cx_salv_not_found,        "Exception
        lv_grid        TYPE REF TO cl_salv_form_layout_grid, "Grid
        lv_gridx       TYPE REF TO cl_salv_form_layout_grid, "Grid X
        lv_column      TYPE REF TO cl_salv_column_table,     "Column
        lv_columns     TYPE REF TO cl_salv_columns_table,    "Column X
        lv_func        TYPE REF TO cl_salv_functions_list,   "Toolbar
        lv_archive_1   TYPE localfile,                       " Archieve File Path
        lv_row         TYPE int4,                            " Row number
        lv_ref_doc     TYPE outputlen,                       " Column Width
        lv_sales_doc   TYPE outputlen,                       " Column Width
        lv_msgtxt      TYPE outputlen,                       " Column Width
        li_fieldcat    TYPE slis_t_fieldcat_alv,             "Field Catalog
        li_events      TYPE slis_t_event,                    " internal table - Event
        lwa_events     TYPE slis_alv_event,                  " work area table - Event
        li_report_b    TYPE STANDARD TABLE OF lty_report_b INITIAL SIZE 0,
                                                             " Loacal internal table for reporting
        lwa_report_b   TYPE lty_report_b.
 " Local work area table for reporting

  FIELD-SYMBOLS: <lfs_report> TYPE ty_report.

* Getting the archieve file path from Global Variables
  lv_archive_1 = gv_archive_gl_1.

  LOOP AT fp_i_report ASSIGNING <lfs_report>.
    lwa_report_b-ref_doc   = <lfs_report>-ref_doc.
*-- Begin of addition D2
    lwa_report_b-doc_type   = <lfs_report>-doc_type.
    lwa_report_b-sales_org   = <lfs_report>-sales_org.
    lwa_report_b-distr_chan   = <lfs_report>-distr_chan.
    lwa_report_b-division   = <lfs_report>-division.
    lwa_report_b-partn_role1   = <lfs_report>-partn_role1.
    lwa_report_b-partn_numb1   = <lfs_report>-partn_numb1.
    lwa_report_b-partn_role2   = <lfs_report>-partn_role2.
    lwa_report_b-partn_numb2   = <lfs_report>-partn_numb2.
    lwa_report_b-con_st_dat   = <lfs_report>-con_st_dat.
    lwa_report_b-con_en_dat   = <lfs_report>-con_en_dat.
    lwa_report_b-material   = <lfs_report>-material.
*-- End of addition D2
    lwa_report_b-doc_flg   = <lfs_report>-doc_flg.
    lwa_report_b-sales_doc = <lfs_report>-sales_doc.
    lwa_report_b-equi_flg  = <lfs_report>-equi_flg.
    lwa_report_b-msgtxt    = <lfs_report>-msgtxt.
    APPEND lwa_report_b TO li_report.
    CLEAR lwa_report_b.
  ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_report>

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
    lv_grid->create_header_information( row     = lv_row
                                        column  = lv_row
                                        text    = text-x01
                                        tooltip = text-x02 ).

    lv_row = lv_row + 1.
    lv_gridx = lv_grid->create_grid( row = lv_row  column = 1  ).

    lv_gridx->create_label( row = lv_row column = 1
                           text = lc_hline ).
    lv_row = lv_row + 1.
* File Read
    lv_gridx->create_label( row = lv_row column = 1
                            text = text-x02 tooltip = text-x02 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_filename_d ).

    lv_row = lv_row + 1.
* File Archived.
    IF lv_archive_1 IS NOT INITIAL.
      lv_gridx->create_label( row = lv_row column = 1
                              text = text-x28 tooltip = text-x28 ).
      lv_gridx->create_label( row = lv_row column = 2
                              text = ':' ).
      lv_gridx->create_label( row = lv_row column = 3
                              text = lv_archive_1 ).
      lv_row = lv_row + 1.
    ENDIF. " IF lv_archive_1 IS NOT INITIAL

    lv_gridx->create_label( row = lv_row column = 1
                            text = text-x03 tooltip = text-x03 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-mandt ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x04 tooltip = text-x04 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = sy-uname ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x05 tooltip = text-x05 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_datum ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = text-x06 tooltip = text-x06 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_gv_mode ).
    lv_row = lv_row + 1.

    lv_gridx->add_row( ).

    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                           text = lc_hline ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x08 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_total ).
    lv_row = lv_row + 1.
    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x09 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_success ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x10 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = fp_no_failed ).
    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                         text = text-x11 ).
    lv_gridx->create_label( row = lv_row column = 2
                            text = ':' ).
    lv_gridx->create_label( row = lv_row column = 3
                            text = lv_rate_c ).

    lv_row = lv_row + 1.

    lv_gridx->create_label( row = lv_row column = 1
                           text = lc_hline ).

    CALL METHOD lv_alv->set_top_of_list( lv_grid ).

    CALL METHOD lv_alv->get_columns
      RECEIVING
        value = lv_columns.

    TRY.
        lv_column ?= lv_columns->get_column( 'REF_DOC' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x38 ).
    lv_column->set_medium_text( text-x38 ).
    lv_column->set_long_text( text-x38 ).
    lv_columns->set_optimize( 'X' ).

*-- begin of addition D2
    TRY.
        lv_column ?= lv_columns->get_column( 'DOC_TYPE' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x53 ).
    lv_column->set_medium_text( text-x53 ).
    lv_column->set_long_text( text-x53 ).
    lv_columns->set_optimize( 'X' ).
    TRY.
        lv_column ?= lv_columns->get_column( 'SALES_ORG' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x43 ).
    lv_column->set_medium_text( text-x43 ).
    lv_column->set_long_text( text-x43 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'DISTR_CHAN' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x44 ).
    lv_column->set_medium_text( text-x44 ).
    lv_column->set_long_text( text-x44 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'DIVISION' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x45 ).
    lv_column->set_medium_text( text-x45 ).
    lv_column->set_long_text( text-x45 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'PARTN_ROLE1' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x54 ).
    lv_column->set_medium_text( text-x54 ).
    lv_column->set_long_text( text-x54 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'PARTN_NUMB1' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x46 ).
    lv_column->set_medium_text( text-x46 ).
    lv_column->set_long_text( text-x46 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'PARTN_ROLE2' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x47 ).
    lv_column->set_medium_text( text-x47 ).
    lv_column->set_long_text( text-x47 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'PARTN_NUMB2' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x48 ).
    lv_column->set_medium_text( text-x48 ).
    lv_column->set_long_text( text-x48 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'CON_ST_DAT' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x49 ).
    lv_column->set_medium_text( text-x49 ).
    lv_column->set_long_text( text-x49 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'CON_EN_DAT' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x50 ).
    lv_column->set_medium_text( text-x50 ).
    lv_column->set_long_text( text-x50 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'MATERIAL' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x51 ).
    lv_column->set_medium_text( text-x51 ).
    lv_column->set_long_text( text-x51 ).
    lv_columns->set_optimize( 'X' ).
*-- End of addition D2
    TRY.
        lv_column ?= lv_columns->get_column( 'DOC_FLG' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x39 ).
    lv_column->set_medium_text( text-x40 ).
    lv_column->set_long_text( text-x34 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'SALES_DOC' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x41 ).
    lv_column->set_medium_text( text-x41 ).
    lv_column->set_long_text( text-x35 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'EQUI_FLG' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x42 ).
    lv_column->set_medium_text( text-x42 ).
    lv_column->set_long_text( text-x36 ).
    lv_columns->set_optimize( 'X' ).

    TRY.
        lv_column ?= lv_columns->get_column( 'MSGTXT' ).
      CATCH  cx_salv_not_found INTO lv_ex_notfound.
        MESSAGE lv_ex_notfound TYPE 'E'.
    ENDTRY.
    lv_column->set_short_text( text-x37 ).
    lv_column->set_medium_text( text-x37 ).
    lv_column->set_long_text( text-x37 ).
    lv_columns->set_optimize( 'X' ).

* Function Tool bars
    lv_func = lv_alv->get_functions( ).
    lv_func->set_all( ).

* Displaying the report
    CALL METHOD lv_alv->display( ).

* For Background Run - ALV List
  ELSE. " ELSE -> IF lv_archive_1 IS NOT INITIAL
*   Passing local variable values to global variable to make it
*   avilable in top of page subroutine.
    gv_filename_d = fp_gv_filename_d.
    gv_filename_d_arch = lv_archive_1.
    gv_mode_b = fp_gv_mode.
    gv_total = lv_total.
    gv_no_success = fp_no_success.
    gv_no_failed = fp_no_failed.
    gv_rate_c = lv_rate_c.

    LOOP AT fp_i_report ASSIGNING <lfs_report>.
      lwa_report_b-ref_doc = <lfs_report>-ref_doc.
*-- Begin of D2
      lwa_report_b-sales_org = <lfs_report>-sales_org.
      lwa_report_b-distr_chan = <lfs_report>-distr_chan.
      lwa_report_b-division = <lfs_report>-division.
      lwa_report_b-doc_type = <lfs_report>-doc_type.
      lwa_report_b-partn_role1 = <lfs_report>-partn_role1.
      lwa_report_b-partn_numb1 = <lfs_report>-partn_numb1.
      lwa_report_b-partn_role2 = <lfs_report>-partn_role2.
      lwa_report_b-partn_numb2 = <lfs_report>-partn_numb2.
      lwa_report_b-con_st_dat = <lfs_report>-con_st_dat.
      lwa_report_b-con_en_dat = <lfs_report>-con_en_dat.
      lwa_report_b-material = <lfs_report>-material.
*-- End of D2
      lwa_report_b-doc_flg = <lfs_report>-doc_flg.
      lwa_report_b-sales_doc = <lfs_report>-sales_doc.
      lwa_report_b-equi_flg = <lfs_report>-equi_flg.
      lwa_report_b-msgtxt = <lfs_report>-msgtxt.

*     Getting the maximum length of columns Sales Document.
      IF lv_ref_doc LT strlen( <lfs_report>-ref_doc ).
        lv_ref_doc = strlen( <lfs_report>-ref_doc ).
      ENDIF. " IF lv_ref_doc LT strlen( <lfs_report>-ref_doc )
*     Getting the maximum length of column SAP Sales Document.
      IF lv_sales_doc   LT strlen( <lfs_report>-sales_doc ).
        lv_sales_doc = strlen( <lfs_report>-sales_doc ).
      ENDIF. " IF lv_sales_doc LT strlen( <lfs_report>-sales_doc )
*     Getting the maximum length of columns MSGTXT.
      IF lv_msgtxt   LT strlen( <lfs_report>-msgtxt ).
        lv_msgtxt = strlen( <lfs_report>-msgtxt ).
      ENDIF. " IF lv_msgtxt LT strlen( <lfs_report>-msgtxt )
      APPEND lwa_report_b TO li_report_b.
      CLEAR lwa_report_b.
    ENDLOOP. " LOOP AT fp_i_report ASSIGNING <lfs_report>

    IF lv_msgtxt LT 150.
      lv_msgtxt = 150.
    ENDIF. " IF lv_msgtxt LT 150

*   Preparing Field Catalog.

* Sales Document
    PERFORM f_fill_fieldcat USING
*                                  'SALES DOCUMENT'     " Defect 346
                                  'REF_DOC' " Defect 346
                                  'LI_REPORT_B'
                                  text-x33
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
*-- Begin of addition D2
* Doc Type
    PERFORM f_fill_fieldcat USING
                                  'DOC_TYPE' " Defect 346
                                  'LI_REPORT_B'
                                  text-x53
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Sales org
    PERFORM f_fill_fieldcat USING
                                  'SALES_ORG' " Defect 346
                                  'LI_REPORT_B'
                                  text-x43
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Distribution Channel
    PERFORM f_fill_fieldcat USING
                                  'DISTR_CHAN' " Defect 346
                                  'LI_REPORT_B'
                                  text-x44
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Division
    PERFORM f_fill_fieldcat USING
                                  'DIVISION' " Defect 346
                                  'LI_REPORT_B'
                                  text-x45
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Collective Number
    PERFORM f_fill_fieldcat USING
                                  'PARTN_ROLE1' " Defect 346
                                  'LI_REPORT_B'
                                  text-x54
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Purchase date
    PERFORM f_fill_fieldcat USING
                                  'PARTN_NUMB1' " Defect 346
                                  'LI_REPORT_B'
                                  text-x46
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* PO Method
    PERFORM f_fill_fieldcat USING
                                  'PARTN_ROLE2' " Defect 346
                                  'LI_REPORT_B'
                                  text-x47
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Name
    PERFORM f_fill_fieldcat USING
                                  'PARTN_NUMB2' " Defect 346
                                  'LI_REPORT_B'
                                  text-x48
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Telephone
    PERFORM f_fill_fieldcat USING
                                  'CON_ST_DAT' " Defect 346
                                  'LI_REPORT_B'
                                  text-x49
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Purch no c
    PERFORM f_fill_fieldcat USING
                                  'CON_EN_DAT' " Defect 346
                                  'LI_REPORT_B'
                                  text-x50
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
* Doc date
    PERFORM f_fill_fieldcat USING
                                  'MATERIAL' " Defect 346
                                  'LI_REPORT_B'
                                  text-x51
                                  lv_ref_doc
                          CHANGING li_fieldcat[].
** Payment terms
*    PERFORM f_fill_fieldcat USING
*                                  'PMNTTRMS' " Defect 346
*                                  'LI_REPORT_B'
*                                  text-x52
*                                  lv_ref_doc
*                          CHANGING li_fieldcat[].
*-- End of addition D2
*   SALES DOC CREATED
    PERFORM f_fill_fieldcat USING  'DOC_FLG' " Defect 346
*                                  'SALES DOC CREATED'   " Defect 346
                                  'LI_REPORT_B'
                                  text-x34
                                  7
                          CHANGING li_fieldcat[].
*   * SAP Sales Document
    PERFORM f_fill_fieldcat USING
*                                  'SAP SALES DOCUMENT'    " Defect 346
                                  'SALES_DOC' " Defect 346
                                  'LI_REPORT_B'
                                  text-x35
                                  lv_sales_doc
                          CHANGING li_fieldcat[].

*   SERIAL/EQUIPMENT NO CREATED
    PERFORM f_fill_fieldcat USING  'EQUI_FLG' "DEFECT 346
*                                  'SERIAL/EQUIPMENT NO CREATED'   " Defect 346
                                  'LI_REPORT_B'
                                  text-x36
                                  7
                          CHANGING li_fieldcat[].

*   MESSAGE TEXT
    PERFORM f_fill_fieldcat USING
*                                  'MESSAGE'                       " Defect 346
                                  'MSGTXT' " Defect 346
                                  'LI_REPORT_B'
                                  text-x37
                                  lv_msgtxt
                          CHANGING li_fieldcat[].

*   Top of page subroutine
    lwa_events-name = 'TOP_OF_PAGE'.
    lwa_events-form = 'F_TOP_OF_PAGE'.
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
      MESSAGE e002(zca_msg). " Invalid file name. Please check your entry.
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF sy-batch IS INITIAL

ENDFORM. " F_DISPLAY_REPORT
*&---------------------------------------------------------------------*
*&      Form  F_INSERTION_FMT
*&---------------------------------------------------------------------*
*       To identify the format in which the data has to updated
* Either external or internal
*----------------------------------------------------------------------*
*  <--  fp_gv_sign Variable to identify the mode
*----------------------------------------------------------------------*
FORM f_insertion_fmt USING fp_i_val TYPE ty_t_val. " ABAP/4: Selection value (LOW or HIGH value, external format)
*-- Begin of change  D2
*begin of change by rnathak - Def # 1014
  CONSTANTS : lc_vkorg TYPE vkorg VALUE '1000',                          " Sales Organization
              lc_vtweg TYPE vtweg VALUE '10',                            " Distribution Channel
       lc_mprogram TYPE programm VALUE 'ZOTCC0005B_CONV_SALES_CONTRACT', " ABAP Program Name
              lc_mactive TYPE ain_epc_active_ind VALUE 'X',              " Active or Inactive Indicator
  lc_mparameter TYPE enhee_parameter VALUE 'ZOTC_CDD_0005_NUMBER_RANGE', " Parameter
              lc_soption TYPE rmsae_option VALUE 'EQ'.                   " Selection Option

*  SELECT mvalue1          " Select Options: Value Low
*    FROM zotc_prc_control " OTC Process Team Control Table
*    UP TO 1 ROWS
*    INTO fp_gv_val
*    WHERE vkorg = lc_vkorg
*    AND vtweg = lc_vtweg
*    AND mprogram = lc_mprogram
*    AND mparameter = lc_mparameter
*    AND mactive = lc_mactive
*    AND soption = lc_soption.
*  ENDSELECT.


  SELECT vkorg vtweg mvalue1 " Select Options: Value Low
      FROM zotc_prc_control  " OTC Process Team Control Table
      INTO TABLE fp_i_val
      WHERE mprogram = lc_mprogram
      AND mparameter = lc_mparameter
      AND mactive = lc_mactive
      AND soption = lc_soption.
*-- End of change  D2
ENDFORM. " F_INSERTION_FMT
*&---------------------------------------------------------------------*
*&      Form  F_CONV_MATERIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_STRING_MATERIAL  text
*      <--P_LWA_STRING_MATERIAL  text
*----------------------------------------------------------------------*
FORM f_conv_material  USING    fp_material TYPE matnr  " Material Number
                      CHANGING fp_matnr    TYPE matnr. " Material Number

  IF fp_material IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = fp_material
      IMPORTING
        output = fp_matnr.

  ENDIF. " IF fp_material IS NOT INITIAL
ENDFORM. " F_CONV_MATERIAL
*&---------------------------------------------------------------------*
*&      Form  F_FILL_CHGCON
*&---------------------------------------------------------------------*
FORM f_fill_chgcon  USING    fp_i_contract TYPE ty_t_contract
                    CHANGING fp_i_chgcon   TYPE ty_t_chgcon.
  FIELD-SYMBOLS:
     <lfs_contract>  TYPE ty_contract.
  DATA:
     lwa_chgcon    TYPE ty_chgcon.

  LOOP AT fp_i_contract ASSIGNING <lfs_contract>.
*    MOVE-CORRESPONDING <lfs_contract> TO lwa_chgcon.
    PERFORM f_move_contract USING <lfs_contract>
                               CHANGING lwa_chgcon.
    APPEND lwa_chgcon TO fp_i_chgcon.
  ENDLOOP. " LOOP AT fp_i_contract ASSIGNING <lfs_contract>

  SORT fp_i_chgcon BY
        vbeln
        doc_type
        sales_org
        distr_chan
        division
        partn_role1
        partn_numb1
        partn_role2
        partn_numb2
        con_st_dat
        con_en_dat
        inst_date
        accept_dat
        collect_no
        purch_date
        po_method
        name
        telephone
        purch_no_c
        doc_date
        pmnttrms.

ENDFORM. " F_FILL_CHGCON
*&---------------------------------------------------------------------*
*&      Form  F_UPLOADING_FM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_FINAL[]  text
*      <--P_I_ERROR[]  text
*      <--P_GV_ECOUNT  text
*      <--P_GV_SCOUNT  text
*      <--P_I_REPORT  text
*      <--P_I_TSN[]  text
*----------------------------------------------------------------------*
FORM f_uploading_fm  USING    fp_i_final   TYPE ty_t_chgcon
                     CHANGING fp_i_error   TYPE ty_t_error
                              fp_gv_ecount TYPE int2 " 2 byte integer (signed)
                              fp_gv_scount TYPE int2 " 2 byte integer (signed)
                              fp_i_report  TYPE ty_t_report
                              fp_i_tsn     TYPE ty_t_contr_tsn.
  DATA:
  lwa_final     TYPE ty_contract,                  " Local work area for input records
  lwa_final1    TYPE ty_contract_e,                " Local work area for error records
  lx_hdr_in     TYPE bapisdhd1,                    " Document Header Data
  lx_hdr_inx    TYPE bapisdhd1x,                   " For Header Data Checkboxes - Updation
  lwa_item_in   TYPE bapisditm,                    " Item Data
  lwa_item_inx  TYPE bapisditmx,                   " Item Data Checkboxes
  lwa_partner   TYPE bapiparnr,                    " Document Partner
  lwa_contr_in  TYPE bapictr,                      " Contract Data
  lwa_contr_inx TYPE bapictrx,                     " Checkbox: Contract Data
  lwa_return    TYPE bapiret2,                     " Return Parameter
  lwa_tsn       TYPE ty_contr_tsn,
                                                   " For Header Data Checkboxes - Updation
  lwa_contract  TYPE ty_contract,                  " D2
  li_item_in    TYPE STANDARD TABLE OF bapisditm,  " Item Data
  li_item_inx   TYPE STANDARD TABLE OF bapisditmx, " Communication Fields: Sales and Distribution Document Item
                                                   " Item Data Checkboxes
  li_partner    TYPE STANDARD TABLE OF bapiparnr,  " Document Partner
  li_contr_in   TYPE STANDARD TABLE OF bapictr,    " Contract Data
  li_contr_inx  TYPE STANDARD TABLE OF bapictrx,   " Communication fields: SD Contract Data Checkbox
                                                   " Checkbox: Contract Data
  li_return     TYPE STANDARD TABLE OF bapiret2,   " Return Parameter
                                                   " Return Parameter
  li_final      TYPE STANDARD TABLE OF ty_contract,
  li_final1     TYPE STANDARD TABLE OF ty_contract_e,
                                                   " Local work area for error records
  lv_msgid      TYPE symsgid,                      " Message Class
  lv_msgnr      TYPE symsgno,                      " Message Number
  lv_msgv1      TYPE symsgv,                       " Message Variable
  lv_msgv2      TYPE symsgv,                       " Message Variable
  lv_msgv3      TYPE symsgv,                       " Message Variable
  lv_msgv4      TYPE symsgv,                       " Message Variable
  lv_msg        TYPE char200,                      " Reporting the error message
  lv_key        TYPE bapi_msg,                     " Message Text
  lv_txtfmt     TYPE bapi_tfrmt,                   " Format of documentation texts
  lv_salesdoc   TYPE vbeln_va,                     " For SAP createdsales document
  lv_vbeln      TYPE vbeln_va,                     " For sales document
  lv_key1       TYPE char30,                       " Key1 of type CHAR30
  lv_posnr      TYPE posnr_va,                     " Sales Document Item
  lv_count      TYPE int4.                         " Natural Number

  FIELD-SYMBOLS: <lfs_final>   TYPE ty_chgcon, " D2
                                               " Field symbol for input records
*                  <lfs_final>   TYPE ty_contract,    "D2
*                                            " Field symbol for input records "D2
                  <lfs_final1> TYPE ty_contract,
                                            " Field symbol for collecting records for performing call transaction
                  <lfs_val>    TYPE ty_val. "D2


  LOOP AT fp_i_final ASSIGNING <lfs_final>.
*    AT NEW vbeln. "D2
    AT NEW pmnttrms. "D2
      " Document Header Data
*-- Begin of  D2
      CLEAR lv_posnr.
      lx_hdr_in-collect_no  = <lfs_final>-collect_no.
*-- End of  D2
      lx_hdr_in-doc_type   = <lfs_final>-doc_type.
      lx_hdr_in-sales_org  = <lfs_final>-sales_org.
      lx_hdr_in-distr_chan = <lfs_final>-distr_chan.
      lx_hdr_in-division   = <lfs_final>-division.
      lx_hdr_in-purch_date = <lfs_final>-purch_date.
      lx_hdr_in-po_method  = <lfs_final>-po_method.
      lx_hdr_in-name       = <lfs_final>-name.
      lx_hdr_in-telephone  = <lfs_final>-telephone.
      lx_hdr_in-purch_no_c = <lfs_final>-purch_no_c.
      lx_hdr_in-doc_date   = <lfs_final>-doc_date.
      lx_hdr_in-pmnttrms   = <lfs_final>-pmnttrms.

      " For Header Data Checkboxes - Updation
*-- Begin of  D2
      lx_hdr_inx-collect_no   = c_ind1.
*-- End of  D2

      lx_hdr_inx-doc_type   = c_ind1.
      lx_hdr_inx-sales_org  = c_ind1.
      lx_hdr_inx-distr_chan = c_ind1.
      lx_hdr_inx-division   = c_ind1.
      lx_hdr_inx-purch_date = c_ind1.
      lx_hdr_inx-po_method  = c_ind1.
      lx_hdr_inx-name       = c_ind1.
      lx_hdr_inx-telephone  = c_ind1.
      lx_hdr_inx-purch_no_c = c_ind1.
      lx_hdr_inx-doc_date   = c_ind1.
      lx_hdr_inx-pmnttrms   = c_ind1.

 " Document Partner
      lwa_partner-partn_role = <lfs_final>-partn_role1.
      lwa_partner-partn_numb = <lfs_final>-partn_numb1.
      APPEND lwa_partner TO li_partner.
      lwa_partner-partn_role = <lfs_final>-partn_role2.
      lwa_partner-partn_numb = <lfs_final>-partn_numb2.
      APPEND lwa_partner TO li_partner.

 " Contract Data
      lwa_contr_in-inst_date  = <lfs_final>-inst_date.
      lwa_contr_in-accept_dat = <lfs_final>-accept_dat.
      lwa_contr_in-con_st_dat = <lfs_final>-con_st_dat.
      lwa_contr_in-con_en_dat = <lfs_final>-con_en_dat.

 " Checkbox: Contract Data
      lwa_contr_inx-inst_date  = <lfs_final>-inst_date.
      lwa_contr_inx-accept_dat = c_ind1.
      lwa_contr_inx-con_st_dat = c_ind1.
      lwa_contr_inx-con_en_dat = c_ind1.

      APPEND: lwa_contr_in TO li_contr_in,
              lwa_contr_inx TO li_contr_inx.
    ENDAT.
    " Item Data
*-- Begin of D2
    CLEAR lwa_contract.
    lv_posnr = lv_posnr + 10.
    IF NOT <lfs_final>-itm_number IS INITIAL AND
          <lfs_final>-itm_number NE ''.
      lwa_item_in-itm_number = <lfs_final>-itm_number.
    ELSE. " ELSE -> IF NOT <lfs_final>-itm_number IS INITIAL AND
      lwa_item_in-itm_number = lv_posnr.
      lwa_contract-itm_number = lv_posnr.
    ENDIF. " IF NOT <lfs_final>-itm_number IS INITIAL AND
*-- End of D2
*    lwa_item_in-po_itm_no  = " Get the info
    lwa_item_in-material   = <lfs_final>-material.
    lwa_item_in-target_qty = <lfs_final>-target_qty.
    lwa_item_in-target_qu  = <lfs_final>-target_qu.
    lwa_item_in-item_categ = <lfs_final>-item_categ.

 " Item Data Checkboxes
    lwa_item_inx-itm_number = <lfs_final>-itm_number.
*    lwa_item_inx-po_itm_no  = " Get the info
    lwa_item_inx-material   = c_ind1.
    lwa_item_inx-target_qty = c_ind1.
    lwa_item_inx-target_qu  = c_ind1.
    lwa_item_inx-item_categ = c_ind1.

 " Appending to the respective internal table
    APPEND: lwa_item_in TO li_item_in,
            lwa_item_inx TO li_item_inx.
*    <lfs_final> to li_final. "D2

*    MOVE-CORRESPONDING <lfs_final> TO <lfs_final1>. "D2

    PERFORM f_move_chgcon USING <lfs_final>
                               CHANGING lwa_contract.
    APPEND lwa_contract TO li_final. "D2

*    AT END OF vbeln. "D2
    AT END OF pmnttrms. "D2
      REFRESH li_return.
      CLEAR lv_vbeln.
*-- Begin of change D2
      CLEAR wa_report.
      wa_report-ref_doc   = <lfs_final>-vbeln.
      wa_report-doc_type   = <lfs_final>-doc_type.
      wa_report-sales_org   = <lfs_final>-sales_org.
      wa_report-distr_chan   = <lfs_final>-distr_chan.
      wa_report-division   = <lfs_final>-division.
      wa_report-partn_role1   = <lfs_final>-partn_role1.
      wa_report-partn_numb1   = <lfs_final>-partn_numb1.
      wa_report-partn_role2   = <lfs_final>-partn_role2.
      wa_report-partn_numb2   = <lfs_final>-partn_numb2.
      wa_report-con_st_dat   = <lfs_final>-con_st_dat.
      wa_report-con_en_dat   = <lfs_final>-con_en_dat.
      wa_report-material   = <lfs_final>-material.
      READ TABLE i_val ASSIGNING <lfs_val> WITH KEY
                                      vkorg = <lfs_final>-sales_org
                                      vtweg = <lfs_final>-distr_chan.
      IF sy-subrc = 0.
        IF <lfs_val>-value1 = c_intnl.
          CLEAR lv_vbeln.
        ELSEIF  <lfs_val>-value1 = c_extnl.
          lv_vbeln = <lfs_final>-vbeln.
        ENDIF. " IF <lfs_val>-value1 = c_intnl
      ENDIF. " IF sy-subrc = 0
** To identify the mode of updating
*      IF gv_val = c_extnl.
*        lv_vbeln = <lfs_final>-vbeln.
*      ELSE.
*        lv_vbeln = space.
*      ENDIF.
*-- End of change D2
 " Function Module for Creating a Sales and Distribution Document
      CALL FUNCTION 'BAPI_CONTRACT_CREATEFROMDATA'
        EXPORTING
          salesdocumentin     = lv_vbeln
          contract_header_in  = lx_hdr_in
          contract_header_inx = lx_hdr_inx
        IMPORTING
          salesdocument       = lv_salesdoc
        TABLES
          return              = li_return
          contract_items_in   = li_item_in
          contract_items_inx  = li_item_inx
          contract_partners   = li_partner
          contract_data_in    = li_contr_in
          contract_data_inx   = li_contr_inx.

      IF li_return IS NOT INITIAL.
        LOOP AT li_return INTO lwa_return WHERE type EQ c_error.
          CLEAR: lv_key,
                 lv_msg.
          lv_msgid = lwa_return-id.
          lv_msgnr = lwa_return-number.
          lv_msgv1 = lwa_return-message_v1.
          lv_msgv2 = lwa_return-message_v2.
          lv_msgv3 = lwa_return-message_v3.
          lv_msgv4 = lwa_return-message_v4.

* FUnction Module to get the message text- BAPI_MESSAGE_GETDETAIL

          CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
            EXPORTING
              id         = lv_msgid
              number     = lv_msgnr
              textformat = lv_txtfmt
              message_v1 = lv_msgv1
              message_v2 = lv_msgv2
              message_v3 = lv_msgv3
              message_v4 = lv_msgv4
            IMPORTING
              message    = lv_key.

* Report Update
          CONCATENATE 'Sales Document not created'(030)
          <lfs_final>-vbeln lv_key lv_key1
          INTO lv_msg
          SEPARATED BY space.
          wa_report-ref_doc   = <lfs_final>-vbeln.
          wa_report-doc_flg   = c_no.
          wa_report-sales_doc = space.
          wa_report-equi_flg  = c_no.
          wa_report-msgtxt    = lv_msg.
          APPEND wa_report TO fp_i_report.
*          CLEAR wa_report. "D2

          IF lwa_return-row IS INITIAL.
            LOOP AT li_final INTO lwa_final.
              lwa_final1 = lwa_final.
              lwa_final1-error_msg = lv_key.
              APPEND lwa_final1 TO li_final1.
              CLEAR lwa_final1.
            ENDLOOP. " LOOP AT li_final INTO lwa_final
          ELSE. " ELSE -> IF lwa_return-row IS INITIAL
            READ TABLE li_final INTO lwa_final INDEX lwa_return-row.
            IF sy-subrc IS INITIAL.
              lwa_final1 = lwa_final.
              lwa_final1-error_msg = lv_key.
              APPEND lwa_final1 TO li_final1.
              CLEAR lwa_final1.
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF lwa_return-row IS INITIAL
          CLEAR lwa_return.
        ENDLOOP. " LOOP AT li_return INTO lwa_return WHERE type EQ c_error
        IF sy-subrc = 0.
          CLEAR lv_count.
          DESCRIBE TABLE li_final LINES lv_count.
*          SORT li_final1 BY itm_number.
          fp_gv_ecount = fp_gv_ecount + lv_count.
          fp_gv_scount = fp_gv_scount - lv_count.
          APPEND LINES OF li_final1 TO fp_i_error.
          REFRESH: li_final1,
                   li_final.

          CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        ELSE. " ELSE -> IF sy-subrc = 0
          CLEAR lwa_return.
          READ TABLE li_return INTO lwa_return WITH KEY
          type = c_success "  of type
          id = c_id
          number = c_numb
          BINARY SEARCH.
          IF sy-subrc = 0.

            wa_report-msgtxt = lwa_return-message.
          ENDIF. " IF sy-subrc = 0
          wa_report-ref_doc   = <lfs_final>-vbeln.
          wa_report-doc_flg   = c_yes.
          wa_report-sales_doc = lv_salesdoc.
          wa_report-equi_flg  = c_no.
          wa_report-msgtxt    = 'Sales Document created'(031).
          APPEND wa_report TO fp_i_report.
*          CLEAR wa_report. "D2

          LOOP AT li_final ASSIGNING <lfs_final1>.
*            lwa_tsn = <lfs_final1>. " D2
*            MOVE-CORRESPONDING <lfs_final1> TO lwa_tsn. "D2
            PERFORM f_move_chngcon_tsn USING <lfs_final1>
                                       CHANGING lwa_tsn. "D2
            lwa_tsn-vbeln1 = lv_salesdoc.
            APPEND lwa_tsn TO fp_i_tsn.
            CLEAR lwa_tsn.
          ENDLOOP. " LOOP AT li_final ASSIGNING <lfs_final1>
          REFRESH li_final.
          CLEAR lv_salesdoc.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = c_true.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_return IS NOT INITIAL

* Refreshing the entries
      CLEAR:   lx_hdr_in,
               lx_hdr_inx.
      REFRESH: li_item_in,
               li_item_inx,
               li_partner,
               li_contr_in,
               li_contr_inx.

    ENDAT.
  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>
  SORT fp_i_error BY vbeln itm_number.
**-- Begin of addition D2
  SORT fp_i_tsn BY vbeln
                     doc_type
                     sales_org
                     distr_chan
                     division
                     collect_no
                     purch_date
                     po_method
                     name
                     telephone
                     purch_no_c
                     doc_date
                     pmnttrms.
*-- End of addition D2
ENDFORM. " F_UPLOADING_FM
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_CHNGCON_ERROR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_CONTRACT>  text
*      <--P_LWA_CONTRACT_TEMP  text
*----------------------------------------------------------------------*
FORM f_move_chngcon_error  USING    fp_contract TYPE ty_chgcon
                           CHANGING fp_contract_temp TYPE ty_contract_e.

  fp_contract_temp-vbeln  = fp_contract-vbeln. " Ref Doc
  fp_contract_temp-doc_type  = fp_contract-doc_type. " Sales Document Type
  fp_contract_temp-sales_org  = fp_contract-sales_org. " Sales Organization
  fp_contract_temp-distr_chan  = fp_contract-distr_chan. " Distribution Channel
  fp_contract_temp-division  = fp_contract-division. " Division
  fp_contract_temp-partn_role1  = fp_contract-partn_role1. " Partner Function
  fp_contract_temp-partn_numb1  = fp_contract-partn_numb1. " Customer Number 1
  fp_contract_temp-partn_role2  = fp_contract-partn_role2. " Partner Function
  fp_contract_temp-partn_numb2  = fp_contract-partn_numb2. " Customer Number 1
  fp_contract_temp-con_st_dat  = fp_contract-con_st_dat. " Contract start date
  fp_contract_temp-con_en_dat  = fp_contract-con_en_dat. " Contract end date
  fp_contract_temp-inst_date   = fp_contract-inst_date . " Installation date
  fp_contract_temp-accept_dat  = fp_contract-accept_dat. " Agreement acceptance date
  fp_contract_temp-collect_no  = fp_contract-collect_no. " Collective Number "D2
  fp_contract_temp-purch_date  = fp_contract-purch_date. " Customer purchase order date
  fp_contract_temp-po_method  = fp_contract-po_method. " Customer purchase order type
  fp_contract_temp-name  = fp_contract-name. " Name of orderer
  fp_contract_temp-telephone  = fp_contract-telephone. " Telephone Number
  fp_contract_temp-purch_no_c  = fp_contract-purch_no_c. " Customer purchase order number
  fp_contract_temp-doc_date  = fp_contract-doc_date. " Document Date (Date Received/Sent)
  fp_contract_temp-pmnttrms  = fp_contract-pmnttrms. " Terms of Payment Key
  fp_contract_temp-itm_number  = fp_contract-itm_number. " Sales Document Item
  fp_contract_temp-material  = fp_contract-material. " Material
  fp_contract_temp-target_qty  = fp_contract-target_qty. " Target quantity in sales units
  fp_contract_temp-target_qu  = fp_contract-target_qu. " Target quantity in sales units
  fp_contract_temp-item_categ   = fp_contract-item_categ . " Sales document item category
  fp_contract_temp-sernr  = fp_contract-sernr. " Serial Number
  fp_contract_temp-equnr  = fp_contract-equnr. " Equipment Number

ENDFORM. " F_MOVE_CHNGCON_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_CHNGCON_TSN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL1>  text
*      <--P_LWA_TSN  text
*----------------------------------------------------------------------*
FORM f_move_chngcon_tsn  USING    fp_contract  TYPE ty_contract
                         CHANGING fp_contract_temp TYPE ty_contr_tsn.
  fp_contract_temp-vbeln  = fp_contract-vbeln. " Ref Doc
  fp_contract_temp-doc_type  = fp_contract-doc_type. " Sales Document Type
  fp_contract_temp-sales_org  = fp_contract-sales_org. " Sales Organization
  fp_contract_temp-distr_chan  = fp_contract-distr_chan. " Distribution Channel
  fp_contract_temp-division  = fp_contract-division. " Division
  fp_contract_temp-partn_role1  = fp_contract-partn_role1. " Partner Function
  fp_contract_temp-partn_numb1  = fp_contract-partn_numb1. " Customer Number 1
  fp_contract_temp-partn_role2  = fp_contract-partn_role2. " Partner Function
  fp_contract_temp-partn_numb2  = fp_contract-partn_numb2. " Customer Number 1
  fp_contract_temp-con_st_dat  = fp_contract-con_st_dat. " Contract start date
  fp_contract_temp-con_en_dat  = fp_contract-con_en_dat. " Contract end date
  fp_contract_temp-inst_date   = fp_contract-inst_date . " Installation date
  fp_contract_temp-accept_dat  = fp_contract-accept_dat. " Agreement acceptance date
  fp_contract_temp-collect_no  = fp_contract-collect_no. " Collective Number "D2
  fp_contract_temp-purch_date  = fp_contract-purch_date. " Customer purchase order date
  fp_contract_temp-po_method  = fp_contract-po_method. " Customer purchase order type
  fp_contract_temp-name  = fp_contract-name. " Name of orderer
  fp_contract_temp-telephone  = fp_contract-telephone. " Telephone Number
  fp_contract_temp-purch_no_c  = fp_contract-purch_no_c. " Customer purchase order number
  fp_contract_temp-doc_date  = fp_contract-doc_date. " Document Date (Date Received/Sent)
  fp_contract_temp-pmnttrms  = fp_contract-pmnttrms. " Terms of Payment Key
  fp_contract_temp-itm_number  = fp_contract-itm_number. " Sales Document Item
  fp_contract_temp-material  = fp_contract-material. " Material
  fp_contract_temp-target_qty  = fp_contract-target_qty. " Target quantity in sales units
  fp_contract_temp-target_qu  = fp_contract-target_qu. " Target quantity in sales units
  fp_contract_temp-item_categ   = fp_contract-item_categ . " Sales document item category
  fp_contract_temp-sernr  = fp_contract-sernr. " Serial Number
  fp_contract_temp-equnr  = fp_contract-equnr. " Equipment Number
ENDFORM. " F_MOVE_CHNGCON_TSN
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_CONTRACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_CONTRACT>  text
*      <--P_LWA_CHGCON  text
*----------------------------------------------------------------------*
FORM f_move_contract  USING    fp_contract  TYPE ty_contract
                      CHANGING fp_contract_temp TYPE ty_chgcon.
  fp_contract_temp-vbeln  = fp_contract-vbeln. " Ref Doc
  fp_contract_temp-doc_type  = fp_contract-doc_type. " Sales Document Type
  fp_contract_temp-sales_org  = fp_contract-sales_org. " Sales Organization
  fp_contract_temp-distr_chan  = fp_contract-distr_chan. " Distribution Channel
  fp_contract_temp-division  = fp_contract-division. " Division
  fp_contract_temp-partn_role1  = fp_contract-partn_role1. " Partner Function
  fp_contract_temp-partn_numb1  = fp_contract-partn_numb1. " Customer Number 1
  fp_contract_temp-partn_role2  = fp_contract-partn_role2. " Partner Function
  fp_contract_temp-partn_numb2  = fp_contract-partn_numb2. " Customer Number 1
  fp_contract_temp-con_st_dat  = fp_contract-con_st_dat. " Contract start date
  fp_contract_temp-con_en_dat  = fp_contract-con_en_dat. " Contract end date
  fp_contract_temp-inst_date   = fp_contract-inst_date . " Installation date
  fp_contract_temp-accept_dat  = fp_contract-accept_dat. " Agreement acceptance date
  fp_contract_temp-collect_no  = fp_contract-collect_no. " Collective Number "D2
  fp_contract_temp-purch_date  = fp_contract-purch_date. " Customer purchase order date
  fp_contract_temp-po_method  = fp_contract-po_method. " Customer purchase order type
  fp_contract_temp-name  = fp_contract-name. " Name of orderer
  fp_contract_temp-telephone  = fp_contract-telephone. " Telephone Number
  fp_contract_temp-purch_no_c  = fp_contract-purch_no_c. " Customer purchase order number
  fp_contract_temp-doc_date  = fp_contract-doc_date. " Document Date (Date Received/Sent)
  fp_contract_temp-pmnttrms  = fp_contract-pmnttrms. " Terms of Payment Key
  fp_contract_temp-itm_number  = fp_contract-itm_number. " Sales Document Item
  fp_contract_temp-material  = fp_contract-material. " Material
  fp_contract_temp-target_qty  = fp_contract-target_qty. " Target quantity in sales units
  fp_contract_temp-target_qu  = fp_contract-target_qu. " Target quantity in sales units
  fp_contract_temp-item_categ   = fp_contract-item_categ . " Sales document item category
  fp_contract_temp-sernr  = fp_contract-sernr. " Serial Number
  fp_contract_temp-equnr  = fp_contract-equnr. " Equipment Number
ENDFORM. " F_MOVE_CONTRACT
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_CHGCON
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<LFS_FINAL>  text
*      <--P_LWA_CONTRACT  text
*----------------------------------------------------------------------*
FORM f_move_chgcon  USING    fp_contract  TYPE ty_chgcon
                    CHANGING fp_contract_temp TYPE ty_contract.
  fp_contract_temp-vbeln  = fp_contract-vbeln. " Ref Doc
  fp_contract_temp-doc_type  = fp_contract-doc_type. " Sales Document Type
  fp_contract_temp-sales_org  = fp_contract-sales_org. " Sales Organization
  fp_contract_temp-distr_chan  = fp_contract-distr_chan. " Distribution Channel
  fp_contract_temp-division  = fp_contract-division. " Division
  fp_contract_temp-partn_role1  = fp_contract-partn_role1. " Partner Function
  fp_contract_temp-partn_numb1  = fp_contract-partn_numb1. " Customer Number 1
  fp_contract_temp-partn_role2  = fp_contract-partn_role2. " Partner Function
  fp_contract_temp-partn_numb2  = fp_contract-partn_numb2. " Customer Number 1
  fp_contract_temp-con_st_dat  = fp_contract-con_st_dat. " Contract start date
  fp_contract_temp-con_en_dat  = fp_contract-con_en_dat. " Contract end date
  fp_contract_temp-inst_date   = fp_contract-inst_date . " Installation date
  fp_contract_temp-accept_dat  = fp_contract-accept_dat. " Agreement acceptance date
  fp_contract_temp-collect_no  = fp_contract-collect_no. " Collective Number "D2
  fp_contract_temp-purch_date  = fp_contract-purch_date. " Customer purchase order date
  fp_contract_temp-po_method  = fp_contract-po_method. " Customer purchase order type
  fp_contract_temp-name  = fp_contract-name. " Name of orderer
  fp_contract_temp-telephone  = fp_contract-telephone. " Telephone Number
  fp_contract_temp-purch_no_c  = fp_contract-purch_no_c. " Customer purchase order number
  fp_contract_temp-doc_date  = fp_contract-doc_date. " Document Date (Date Received/Sent)
  fp_contract_temp-pmnttrms  = fp_contract-pmnttrms. " Terms of Payment Key
*  fp_contract_temp-itm_number  = fp_contract-itm_number. " Sales Document Item
  fp_contract_temp-material  = fp_contract-material. " Material
  fp_contract_temp-target_qty  = fp_contract-target_qty. " Target quantity in sales units
  fp_contract_temp-target_qu  = fp_contract-target_qu. " Target quantity in sales units
  fp_contract_temp-item_categ   = fp_contract-item_categ . " Sales document item category
  fp_contract_temp-sernr  = fp_contract-sernr. " Serial Number
  fp_contract_temp-equnr  = fp_contract-equnr. " Equipment Number
ENDFORM. " F_MOVE_CHGCON
