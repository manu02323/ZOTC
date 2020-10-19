*&---------------------------------------------------------------------*
*& Report  ZOTCE0274B_PRICE_UPLOAD_GIDOC
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0274B_PRICE_UPLOAD                                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Monika Garg                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition  (Part 2)  *
* Program will read all the files from specified folder of application *
* server and create the IDOC which will Insert/update/Delete the       *
* condition records.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
* 16-Sep-2015  MGARG    E2DK913959 Defect D2_959 PGL, Issues during the*
*                                  pricing upload.                     *
*&---------------------------------------------------------------------*
*  26-Oct-2015 DMOIRAN  E2DK913959 Defect 1209 PGL B development.      *
* Added logic to create segment Z1OTC_KONP_EXT to update pricing       *
* condition text.                                                      *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_FETCH_EMI
*&---------------------------------------------------------------------*
*       Subroutine to fetch the EMI values
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
FORM f_fetch_emi.

  CONSTANTS:
     lc_enh_no  TYPE z_enhancement  VALUE 'D2_OTC_EDD_0274', " Enhancement No.
     lc_part_type   TYPE z_criteria     VALUE 'PART_TYPE'.   " Enh. Criteria

  DATA:
    li_status   TYPE STANDARD TABLE OF zdev_enh_status. "Enhancement Status table" Kschl of type CHAR5

  FIELD-SYMBOLS:
    <lfs_status> TYPE zdev_enh_status. " Enhancement Status

  CLEAR: gv_rprt,
         gv_sprt.

* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enh_no
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

*  DELETE the ENTRIES which are NOT active AND pick ALL the active ENTRIES.

  DELETE li_status WHERE active = space.
  READ TABLE li_status ASSIGNING <lfs_status>
                       WITH KEY  criteria = lc_part_type.
  IF sy-subrc IS INITIAL.
    gv_rprt = <lfs_status>-sel_low.
    gv_sprt = <lfs_status>-sel_low.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_FETCH_EMI

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILES_FRM_DIR
*&---------------------------------------------------------------------*
*       Get Files from Directory and processed the files
*----------------------------------------------------------------------*

FORM f_get_files_frm_dir .

* Local Data Declaration
  DATA:
   lv_dirname     TYPE epsf-epsdirnam,             " Directory name
   lv_time        TYPE char10,                     " Time of type CHAR1
   lv_filename    TYPE localfile,                  " Local file for upload/download
   lv_set_index   TYPE sytabix,                    " Index of Internal Tables
   lv_noentry     TYPE string,
   lv_string      TYPE string,                     "Input Raw lines
   lv_subrc       TYPE sysubrc,                    " Return Value of ABAP Statements
   lv_field       TYPE string,
   lv_rem         TYPE string,
   lv_fname       TYPE string,
   lv_ftype       TYPE string,
   lv_cnt_field   TYPE sytabix,                    " Index of Internal Tables
   lv_cntr_val    TYPE sytabix,                    " Index of Internal Tables
   li_dirlist     TYPE STANDARD TABLE OF epsfili,  " Directory table
   lwa_fileinfo   TYPE ty_fileinfo,
   li_string      TYPE TABLE OF string,
   lref_type      TYPE REF TO cl_abap_typedescr,   " Runtime Type Services
   lref_line_type TYPE REF TO cl_abap_structdescr, " Runtime Type Services
   lref_tab       TYPE REF TO cl_abap_tabledescr,  " Runtime Type Services
   lref_dyn_tab   TYPE REF TO data,                "  class
   lref_dyn_wa    TYPE REF TO data,                "  class
   lv_name        TYPE epsfilnam.                  " File Name

  FIELD-SYMBOLS :
  <lfs_dirlist>   TYPE epsfili, " List of Files
  <lfs_fileinfo>  TYPE ty_fileinfo,
  <lfs_any_index> TYPE any.

  CONSTANTS:
  lc_zero   TYPE char1   VALUE '0', " Zero of type CHAR1
  lc_one    TYPE char1   VALUE '1', " One of type CHAR1
  lc_ctype  TYPE string  VALUE 'STRING'.


* Get the directory name
  lv_dirname = p_pfapth.

* Get all files from directory
  CALL FUNCTION 'EPS_GET_DIRECTORY_LISTING'
    EXPORTING
      dir_name               = lv_dirname
    TABLES
      dir_list               = li_dirlist
    EXCEPTIONS
      invalid_eps_subdir     = 1
      sapgparam_failed       = 2
      build_directory_failed = 3
      no_authorization       = 4
      read_directory_failed  = 5
      too_many_read_errors   = 6
      empty_directory_list   = 7
      OTHERS                 = 8.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE i973(zotc_msg) WITH lv_dirname DISPLAY LIKE c_e. " No File Exists in directory &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL

    LOOP AT li_dirlist ASSIGNING <lfs_dirlist>.
* To get attribute( time) of files

*--> Begin of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
      lv_name = <lfs_dirlist>-name.
      REPLACE ALL OCCURRENCES OF sy-uname IN lv_name WITH space.
      IF sy-subrc IS INITIAL.
      ELSE. " ELSE -> IF sy-subrc IS INITIAL
        CONTINUE.
      ENDIF. " IF sy-subrc IS INITIAL
*<-- End of insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.



      CALL FUNCTION 'EPS_GET_FILE_ATTRIBUTES'
        EXPORTING
          file_name              = <lfs_dirlist>-name
          dir_name               = lv_dirname
        IMPORTING
          file_mtime             = lv_time
        EXCEPTIONS
          read_directory_failed  = 1
          read_attributes_failed = 2
          OTHERS                 = 3.
      IF sy-subrc IS INITIAL.
        lwa_fileinfo-filename = <lfs_dirlist>-name.
        lwa_fileinfo-path     = lv_dirname.
        lwa_fileinfo-time     = lv_time.
        APPEND lwa_fileinfo TO i_fileinfo.
        CLEAR: lwa_fileinfo,
               lv_time.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDLOOP. " LOOP AT li_dirlist ASSIGNING <lfs_dirlist>

* Sort files with time to get the oldest one first.
    SORT i_fileinfo BY time.
  ENDIF. " IF sy-subrc IS NOT INITIAL


  LOOP AT i_fileinfo ASSIGNING <lfs_fileinfo>.
    CONCATENATE lv_dirname c_fslash <lfs_fileinfo>-filename INTO lv_filename.

    TRY.
* Opening the Dataset for File Read
        OPEN DATASET lv_filename FOR INPUT IN TEXT MODE ENCODING DEFAULT. "set as ready for input
      CATCH cx_sy_file_open.
* Populate error message
        MESSAGE i972(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " File & opened fail.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_codepage_converter_init.
* Populate error message
        MESSAGE i972(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " File & opened fail.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_conversion_codepage.
* Populate error message
        MESSAGE i972(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " File & opened fail.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_file_authority .
* Populate error message
        MESSAGE i972(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " File & opened fail.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_pipes_not_supported.
* Populate error message
        MESSAGE i972(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " File & opened fail.
        LEAVE LIST-PROCESSING.
      CATCH cx_sy_too_many_files.
* Populate error message
        MESSAGE i972(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " File & opened fail.
        LEAVE LIST-PROCESSING.
    ENDTRY.

    CLEAR: lv_string.
* To set the value of manual added column in internal table
    lv_set_index = lc_zero.
    WHILE ( lv_subrc EQ 0 ).
* Read single line
      READ DATASET lv_filename INTO lv_string.
*     Storing SY-SUBRC value, to be used as loop-breaking condition.
      lv_subrc = sy-subrc.

      IF sy-subrc IS INITIAL.
* Read the Header record
        IF sy-index = lc_one.
*      CHECK sy-index = 0.
          WHILE lv_string IS NOT INITIAL.
*       Aligning the values as per the structure
            SPLIT lv_string AT c_pipe INTO lv_field lv_rem.
            SPLIT lv_field AT c_fslash INTO lv_fname lv_ftype.

            IF lv_ftype CA c_crlf.
* Replacing the CR-LF from the last field if it contains CR-LF.
              REPLACE ALL OCCURRENCES OF c_crlf IN lv_ftype
              WITH space.
*         Removing the space.
              CONDENSE lv_ftype.
            ENDIF. " IF lv_ftype CA c_crlf
            IF lv_fname IS NOT INITIAL  AND lv_ftype IS NOT INITIAL.
* field name
              wa_field-name = lv_fname.
*To get Field Type
              CALL METHOD cl_abap_datadescr=>describe_by_name
                EXPORTING
                  p_name         = lv_ftype
                RECEIVING
                  p_descr_ref    = lref_type
                EXCEPTIONS
                  type_not_found = 1
                  OTHERS         = 2.
              IF sy-subrc IS INITIAL.
                wa_field-type ?= lref_type.
                CLEAR lref_type.
              ELSE. " ELSE -> IF sy-subrc IS INITIAL
                MESSAGE i960(zotc_msg) WITH lv_ftype DISPLAY LIKE c_e. " Field type & is incorrect in the file.
                LEAVE LIST-PROCESSING.
              ENDIF. " IF sy-subrc IS INITIAL

            ELSE. " ELSE -> IF lv_fname IS NOT INITIAL AND lv_ftype IS NOT INITIAL
              MESSAGE i971(zotc_msg) WITH lv_filename DISPLAY LIKE c_e. " Please enter Fieldname/Fieldtype correctly in file &.
              LEAVE LIST-PROCESSING.
            ENDIF. " IF lv_fname IS NOT INITIAL AND lv_ftype IS NOT INITIAL

            APPEND wa_field TO i_field.
            CLEAR wa_field.
            lv_string = lv_rem.
          ENDWHILE.

** Add a new column(ZIndex) in the structure
          wa_field-name = c_cname.
          wa_field-type ?= cl_abap_datadescr=>describe_by_name( lc_ctype ).
          INSERT wa_field INTO i_field INDEX 1.
          CLEAR  wa_field.
**********************************************************************
* Create Dynamic table from here
*  create work area for the dynamic internal table.
          CLEAR lref_line_type.
          TRY .
              lref_line_type = cl_abap_structdescr=>create( p_components = i_field ).
            CATCH cx_sy_struct_creation .
              MESSAGE i953(zotc_msg) DISPLAY LIKE c_e. " Dynamic Internal Structure can not be built.
              LEAVE LIST-PROCESSING.
          ENDTRY.

* Create dynamic table
          IF lref_line_type IS NOT INITIAL.
            CLEAR lref_tab.
            TRY.
                lref_tab = cl_abap_tabledescr=>create( p_line_type  = lref_line_type ).
              CATCH cx_sy_table_creation.
                MESSAGE i953(zotc_msg) DISPLAY LIKE c_e. " Dynamic Internal Structure can not be built.
                LEAVE LIST-PROCESSING.
            ENDTRY.
          ENDIF. " IF lref_line_type IS NOT INITIAL

          IF lref_tab IS NOT INITIAL.
            CREATE DATA lref_dyn_tab TYPE HANDLE lref_tab. " Internal ID of an object
          ENDIF. " IF lref_tab IS NOT INITIAL

          IF lref_line_type IS NOT INITIAL.
            CREATE DATA lref_dyn_wa TYPE HANDLE lref_line_type. " Internal ID of an object
          ENDIF. " IF lref_line_type IS NOT INITIAL

          ASSIGN lref_dyn_tab->* TO <fs_dyn_tab>.
          ASSIGN lref_dyn_wa->* TO <fs_dyn_wa>.
* Ending of creation of dynamic table
**********************************************************************
        ELSE. " ELSE -> IF lref_line_type IS NOT INITIAL
* Read Rows which are having data

          SPLIT lv_string AT c_pipe INTO TABLE li_string.
          lv_cnt_field = 2.
* Count No of lines in li_string table
          DESCRIBE TABLE li_string LINES lv_noentry.
          DO lv_noentry TIMES.
            LOOP AT li_string ASSIGNING <fs>.
              CLEAR lv_field.
              READ TABLE i_field ASSIGNING <fs_field> INDEX lv_cnt_field.
              IF sy-subrc IS INITIAL.
                lv_field = <fs_field>-name.
                TRANSLATE lv_field  TO UPPER CASE.
                ASSIGN COMPONENT lv_field OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
                IF <fs_any> IS ASSIGNED.
* Store value of field ZCOUNTER
                  IF lv_field = c_zcounter.
                    lv_cntr_val = <fs>.
                  ENDIF. " IF lv_field = c_zcounter

                  IF <fs> CA c_crlf.
* Replacing the CR-LF from the last field if it contains CR-LF.
                    REPLACE ALL OCCURRENCES OF c_crlf IN <fs>
                    WITH space.
*         Removing the space.
                    CONDENSE <fs>.
                  ENDIF. " IF <fs> CA c_crlf
                  <fs_any> = <fs>.
                ENDIF. " IF <fs_any> IS ASSIGNED
              ENDIF. " IF sy-subrc IS INITIAL
* Increment lv_cnt_field by 1
              lv_cnt_field = lv_cnt_field + 1.
* At the end of row check the value of ZCOUNTER field
* if value is 0, incremnet lv_set_index by 1
              AT LAST.
                IF lv_cntr_val = lc_zero.
                  lv_set_index = lv_set_index + 1 .
                ENDIF. " IF lv_cntr_val = lc_zero
* Add the value of field ZINDEX manually
                ASSIGN COMPONENT c_cname OF STRUCTURE <fs_dyn_wa> TO <lfs_any_index>.
                IF <lfs_any_index> IS ASSIGNED.
                  <lfs_any_index> = lv_set_index.
                ENDIF. " IF <lfs_any_index> IS ASSIGNED
                APPEND <fs_dyn_wa> TO <fs_dyn_tab>.
                CLEAR lv_cntr_val.
              ENDAT.
            ENDLOOP. " LOOP AT li_string ASSIGNING <fs>
            EXIT.
          ENDDO.

        ENDIF. " IF sy-index = lc_one
      ENDIF. " IF sy-subrc IS INITIAL
    ENDWHILE.

* Closing the Dataset after reading the file
    TRY .
        CLOSE DATASET lv_filename.
      CATCH cx_sy_file_close.
        MESSAGE i959(zotc_msg) WITH lv_filename. " Error while uploading file to &
        LEAVE LIST-PROCESSING.
    ENDTRY.

* Subroutine to Create IDOC
    PERFORM f_create_idoc USING lv_filename.

* Subroutine to move file from TBP to Done folder
    PERFORM f_move_file USING lv_filename.

* Clear Variables
    CLEAR:
      lv_set_index,lv_cnt_field,
      lv_subrc,lv_string,
      lv_field,lv_filename.
    UNASSIGN : <fs_dyn_wa>,
               <fs_field>.
    REFRESH :
    li_string, i_field,
    <fs_dyn_tab>.
  ENDLOOP. " LOOP AT i_fileinfo ASSIGNING <lfs_fileinfo>
  UNASSIGN: <lfs_fileinfo>.

ENDFORM. " F_GET_FILES_FRM_DIR

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_IDOC
*&---------------------------------------------------------------------*
*       Subroutine to create IDOC
*----------------------------------------------------------------------*

FORM f_create_idoc USING p_filename TYPE localfile. " Local file for upload/download

  TYPES:
  BEGIN OF lty_vkorg, " Sales Organizations
    vkorg TYPE vkorg, " Sales Organization
  END OF lty_vkorg,

  BEGIN OF lty_adrnr, " Sales Organization Address
    vkorg TYPE vkorg, " Sales Organization
    adrnr TYPE adrnr, " Address
  END OF lty_adrnr,

  BEGIN OF lty_land1, " Sales Organization Country
    adrnr TYPE adrnr, " Address
    land1 TYPE land1, " Country Key
  END OF lty_land1.

  CONSTANTS:
    lc_idoctyp      TYPE edi4idoctp VALUE 'COND_A01',          " Name of basic type
    lc_mestyp       TYPE edi_mestyp VALUE 'COND_A',            " Message Type
    lc_cimtyp       TYPE edi_cimtyp VALUE 'ZOTCE_COND_A01_01', " Extension
    lc_docrel       TYPE edi4docrel VALUE '731',               " SAP Release for IDoc
    lc_direct       TYPE edi4direct VALUE '2',                 " Direction
    lc_lwa          TYPE char4      VALUE 'LWA_',              " Lwa of type CHAR4
    lc_hash         TYPE char1      VALUE '-',                 " Hash of type CHAR1
    lc_null         TYPE char1      VALUE ' ',                 " Null of type CHAR1
    lc_kzbzg_b      TYPE kzbzg      VALUE 'B',                 " Scale basis indicator
    lc_kzbzg_c      TYPE kzbzg      VALUE 'C',                 " Scale basis indicator
    lc_krech_b      TYPE krech      VALUE 'B',                 " Calculation type for condition
    lc_krech_c      TYPE krech      VALUE 'C',                 " Calculation type for condition
    lc_stfkz        TYPE stfkz      VALUE 'A',                 " Scale Type
    lc_kunwe        TYPE char10     VALUE 'KUNWE',             " Kunwe of type CHAR10
    lc_kunag        TYPE char10     VALUE 'KUNAG',             " Kunag of type CHAR10
    lc_kunnr        TYPE char10     VALUE 'KUNNR'.             " Kunnr of type CHAR10

  DATA:
        lv_kunwe   TYPE kna1-kunnr ,                       " Customer Number
        lv_cust_flag TYPE char1,                           " Cust_flag of type CHAR1
    lv_wa           TYPE string,
    lv_no_of_fields TYPE string,
    lv_fieldname    TYPE string,
    lv_fieldnm      TYPE fieldname,                        " Field Name
    lv_field_cnt    TYPE sytabix,                          " Index of Internal Tables
    lv_indicator    TYPE char1,                            " Indicator of type CHAR1
    lv_idoc_cre     TYPE sytabix,                          " Index of Internal Tables
    lv_datab        TYPE sy-datum,                         " Current Date of Application Server
    lv_datbi        TYPE sy-datum,                         " Current Date of Application Server
    lv_knumh        TYPE knumh,                            " Condition record number
    lv_counter      TYPE i,                                " Counter of type Integers
    lv_lines        TYPE i VALUE 1,                        " Lines of type Integers
    lv_count        TYPE i,                                " Count of type Integers
    lv_len          TYPE int4,                             " Natural Number
    lv_kschl        TYPE kschl,                            " Condition Type
    lv_kbetr        TYPE kbetr,                            " Rate (condition amount or percentage)
    lv_kstbm        TYPE kstbm,                            " Condition scale quantity
    li_idoc_header  TYPE TABLE OF edi_dc40,                " IDoc Control Record for Interface to External System
    lwa_idoc_header TYPE          edi_dc40,                " IDoc Control Record for Interface to External System
    li_idoc_data    TYPE TABLE OF edi_dd40,                " IDoc Data Record for Interface to External System
    lwa_idoc_data   TYPE          edi_dd40,                " IDoc Data Record for Interface to External System
    lwa_e1komg      TYPE e1komg,                           " Filter segment with separated condition key
    lv_name         TYPE ddobjname,                        " Name of ABAP Dictionary Object
    li_fields       TYPE STANDARD TABLE OF dfies,          " Table for Internal Table fields
    li_vkorg        TYPE STANDARD TABLE OF lty_vkorg,      " Sales Organizations
    li_adrnr        TYPE STANDARD TABLE OF lty_adrnr,      " Address
    li_land1        TYPE STANDARD TABLE OF lty_land1,      " Country
    lwa_z1otc_cond_key_fields  TYPE z1otc_cond_key_fields, " Condition table custom key fields
    lwa_e1konh      TYPE e1konh,                           " Data from condition header
    lwa_e1konw      TYPE e1konw,                           " Conditions Value Scale
    lwa_e1konm      TYPE e1konm,                           " Conditions Quantity Scale
    lwa_e1konp      TYPE e1konp,                           " Conditions Items
* ---> Begin of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
    lwa_z1otc_konp_ext TYPE z1otc_konp_ext. " KONP Extension
* <--- End    of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
*

* Local Field Symbol declaration
  FIELD-SYMBOLS:
    <lfs_seg_fld_value> TYPE any,
    <lfs_dyn>           TYPE any,
    <lfs_idoc_data>     TYPE edi_dd40,  " IDoc Data Record for Interface to External System
    <lfs_fields>        TYPE dfies,     " DD Interface: Table Fields for DDIF_FIELDIN
    <lfs_vkorg>         TYPE lty_vkorg, " Sales Organizations
    <lfs_adrnr>         TYPE lty_adrnr, " Address
    <lfs_land1>         TYPE lty_land1, " Country
    <lfs_any>           TYPE any.

  lv_idoc_cre = 0.

* Fill IDOC with Control Information
  lwa_idoc_header-docrel  = lc_docrel.
  lwa_idoc_header-direct  = lc_direct.
  lwa_idoc_header-rcvprt  = gv_rprt.
  lwa_idoc_header-rcvprn  = gv_rcvprn.
  lwa_idoc_header-sndprt  = gv_sprt.
  lwa_idoc_header-sndprn  = gv_sndprn.
  lwa_idoc_header-idoctyp = lc_idoctyp.
  lwa_idoc_header-mestyp  = lc_mestyp.
  lwa_idoc_header-cimtyp  = lc_cimtyp.
  APPEND lwa_idoc_header TO li_idoc_header.
  CLEAR lwa_idoc_header.

* Create Segament with fields name
  PERFORM  f_create_segment CHANGING i_seg.

* Find  the no of lines for using in do enddo.
  DESCRIBE TABLE i_field LINES lv_no_of_fields.

*&--Get all Sales Organizations
  LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>.
    APPEND INITIAL LINE TO li_vkorg ASSIGNING <lfs_vkorg>.
    IF <lfs_vkorg> IS ASSIGNED.
      ASSIGN COMPONENT c_vkorg OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
      IF <fs_any> IS ASSIGNED.
        IF <fs_any> IS NOT INITIAL.
          <lfs_vkorg>-vkorg = <fs_any>.
          UNASSIGN: <fs_any>.
        ENDIF. " IF <fs_any> IS NOT INITIAL
      ENDIF. " IF <fs_any> IS ASSIGNED
    ENDIF. " IF <lfs_vkorg> IS ASSIGNED
  ENDLOOP. " LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>

  SORT li_vkorg BY vkorg.
  DELETE li_vkorg[] WHERE vkorg IS INITIAL.
  DELETE ADJACENT DUPLICATES FROM li_vkorg COMPARING vkorg.

  IF li_vkorg[] IS NOT INITIAL.
*&--Fetch Sales Org. Address Numbers
    SELECT vkorg " Sales Organization
           adrnr " Address
      FROM tvko  " Organizational Unit: Sales Organizations
      INTO TABLE li_adrnr
       FOR ALL ENTRIES IN li_vkorg
     WHERE vkorg EQ li_vkorg-vkorg.
    IF sy-subrc EQ 0 AND
       li_adrnr IS NOT INITIAL.

      SORT li_adrnr BY adrnr.
      DELETE ADJACENT DUPLICATES FROM li_adrnr COMPARING adrnr.
      SORT li_adrnr BY vkorg.

*&--Fetch Sales Org. Countries
      SELECT addrnumber " Address number
             country    " Country Key
        FROM adrc       " Addresses (Business Address Services)
        INTO TABLE li_land1
         FOR ALL ENTRIES IN li_adrnr
       WHERE addrnumber EQ li_adrnr-adrnr.
      IF sy-subrc EQ 0.

        SORT li_land1 BY adrnr.
      ENDIF. " IF sy-subrc EQ 0
    ENDIF. " IF sy-subrc EQ 0 AND
  ENDIF. " IF li_vkorg[] IS NOT INITIAL

  LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>.

    lv_lines = lv_lines + 1.

    ASSIGN COMPONENT c_kstbm OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
    IF <fs_any> IS ASSIGNED.
      IF <fs_any> IS NOT INITIAL.
        lwa_e1konp-kstbm  = <fs_any>.
        lv_kstbm  = <fs_any>.
        CONDENSE: lwa_e1konp-kstbm,
                  lwa_e1konm-kstbm.
        UNASSIGN: <fs_any>.
      ENDIF. " IF <fs_any> IS NOT INITIAL
    ENDIF. " IF <fs_any> IS ASSIGNED

    ASSIGN COMPONENT c_zcounter OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
    IF <fs_any> IS ASSIGNED.
      IF <fs_any> IS NOT INITIAL.
        lv_counter  = <fs_any>.
        UNASSIGN: <fs_any>.
      ENDIF. " IF <fs_any> IS NOT INITIAL
    ENDIF. " IF <fs_any> IS ASSIGNED

*--> Begin of Insert for D2_OTC_EDD_274 by VCHOUDH.
clear : lv_kbetr.
*<-- End of Insert for D2_OTC_EDD_0274 by VCHOUDH.
    ASSIGN COMPONENT c_kbetr1 OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
    IF <fs_any> IS ASSIGNED.
      IF <fs_any> IS NOT INITIAL.
        lv_kbetr  = <fs_any>.
        UNASSIGN: <fs_any>.
      ENDIF. " IF <fs_any> IS NOT INITIAL
    ENDIF. " IF <fs_any> IS ASSIGNED

    lv_field_cnt = 1.

    CLEAR: lv_fieldname,
           lv_indicator.

    DO lv_no_of_fields TIMES.
* Get fieldname
      READ TABLE i_field ASSIGNING <fs_field>  INDEX lv_field_cnt.
      IF sy-subrc IS INITIAL.
        lv_fieldname = <fs_field>-name.
      ENDIF. " IF sy-subrc IS INITIAL

      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
      IF <fs_any> IS ASSIGNED.
        IF <fs_any> IS NOT INITIAL.

* Store the value of indicator
          IF lv_fieldname = c_ztable.
            lv_indicator = <fs_any>.
          ELSE. " ELSE -> IF lv_fieldname = c_ztable
            lv_fieldnm = lv_fieldname.
*Read table i_seg so that mapping of segemnet and field can be done.
            READ TABLE i_seg INTO wa_seg WITH KEY fieldname = lv_fieldnm.
            IF sy-subrc IS INITIAL.
* Get Value of field
              CONCATENATE lc_lwa wa_seg-tabname lc_hash lv_fieldname INTO lv_wa.
              ASSIGN (lv_wa) TO <lfs_seg_fld_value>.
              <lfs_seg_fld_value> = <fs_any>.

            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF lv_fieldname = c_ztable
        ENDIF. " IF <fs_any> IS NOT INITIAL
      ENDIF. " IF <fs_any> IS ASSIGNED
* increase the counter
      lv_field_cnt = lv_field_cnt + 1.
    ENDDO.

****  Fill Segment E1KOMG
*---> Begin of addition for D2_OTC_EDD_0274/Defect 959 by vchoudh.
    IF lwa_e1komg-kunnr IS INITIAL.
      ASSIGN COMPONENT lc_kunag OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
      IF <fs_any> IS ASSIGNED.
        lwa_e1komg-kunnr = <fs_any>.
        UNASSIGN <fs_any>.

        ASSIGN COMPONENT lc_kunwe OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
        IF <fs_any> IS ASSIGNED.
          lv_kunwe = <fs_any>.
          lv_cust_flag = abap_true.
          UNASSIGN <fs_any>.
        ENDIF. " IF <fs_any> IS ASSIGNED
      ELSE. " ELSE -> IF <fs_any> IS ASSIGNED
        ASSIGN COMPONENT lc_kunwe OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
        IF <fs_any> IS ASSIGNED.
          lwa_e1komg-kunnr = <fs_any>.
          UNASSIGN <fs_any>.
        ENDIF. " IF <fs_any> IS ASSIGNED
      ENDIF. " IF <fs_any> IS ASSIGNED
    ELSE. " ELSE -> IF <fs_any> IS ASSIGNED
      ASSIGN COMPONENT lc_kunwe OF STRUCTURE <fs_dyn_wa> TO <fs_any>.
      IF <fs_any> IS ASSIGNED.
        lv_kunwe = <fs_any>.
*          lv_cust_flag = abap_true.
        UNASSIGN <fs_any>.
      ENDIF. " IF <fs_any> IS ASSIGNED

    ENDIF. " IF lwa_e1komg-kunnr IS INITIAL

*<--- End of addition for D2_OTC_EDD_0274/Defect 959 by vchoudh.

    IF ( lwa_e1komg IS NOT INITIAL ) AND
       ( lwa_e1komg <> lc_null )     AND
       ( lwa_e1komg-kotabnr <> lc_null ) .

      lwa_idoc_data-segnam = c_e1komg.
      lwa_idoc_data-hlevel = c_one.
      lwa_e1komg-kvewe     = c_kvewe.
      lwa_e1komg-kappl     = c_kappl_v.

      lv_kschl =  lwa_e1komg-kschl.

      CONCATENATE lwa_e1komg-kvewe
                  lwa_e1komg-kotabnr
             INTO lv_name.

* Getting the field names of the table
      CALL FUNCTION 'DDIF_FIELDINFO_GET'
        EXPORTING
          tabname        = lv_name
        TABLES
          dfies_tab      = li_fields
        EXCEPTIONS
          not_found      = 1
          internal_error = 2
          OTHERS         = 3.
* No need to handle the -ve case
      IF sy-subrc = 0.
        DELETE li_fields WHERE keyflag IS INITIAL.
        DELETE li_fields WHERE fieldname = c_mandt.
        DELETE li_fields WHERE fieldname = c_kschl.
        DELETE li_fields WHERE fieldname = c_kappl.
      ENDIF. " IF sy-subrc = 0

      LOOP AT li_fields ASSIGNING <lfs_fields>.
        AT FIRST.
          ASSIGN COMPONENT <lfs_fields>-fieldname OF STRUCTURE lwa_e1komg TO <lfs_any>.
          IF <lfs_any> IS ASSIGNED.
            lwa_e1komg-vakey = <lfs_any>.
            UNASSIGN <lfs_any>.

          ELSE. " ELSE -> IF <lfs_any> IS ASSIGNED
            ASSIGN COMPONENT <lfs_fields>-fieldname OF STRUCTURE lwa_z1otc_cond_key_fields TO <lfs_any>.
            IF <lfs_any> IS ASSIGNED.
              lwa_e1komg-vakey = <lfs_any>.
              UNASSIGN <lfs_any>.

            ENDIF. " IF <lfs_any> IS ASSIGNED
          ENDIF. " IF <lfs_any> IS ASSIGNED
          lv_len = lv_len + <lfs_fields>-leng.
          CONTINUE.
        ENDAT.

        ASSIGN COMPONENT <lfs_fields>-fieldname OF STRUCTURE lwa_e1komg TO <lfs_any>.
        IF <lfs_any> IS ASSIGNED.
          MOVE <lfs_any> TO lwa_e1komg-vakey+lv_len(<lfs_fields>-leng).
          UNASSIGN <lfs_any>.

        ELSE. " ELSE -> IF <lfs_any> IS ASSIGNED


*---> Begin of addition for D2_OTC_EDD_0274/Defect 959 by vchoudh.
          IF lv_cust_flag = abap_true. "    Table have both sold to/ Ship to.
            IF <lfs_fields>-fieldname = lc_kunag.
              ASSIGN COMPONENT lc_kunnr OF STRUCTURE lwa_e1komg TO <lfs_any>.
              IF <lfs_any> IS ASSIGNED .
                MOVE <lfs_any> TO lwa_e1komg-vakey+lv_len(<lfs_fields>-leng).
                UNASSIGN <lfs_any>.
              ENDIF. " IF <lfs_any> IS ASSIGNED
            ELSE. " ELSE -> IF <lfs_any> IS ASSIGNED
              IF <lfs_fields>-fieldname = lc_kunwe.
                MOVE lv_kunwe TO lwa_e1komg-vakey+lv_len(<lfs_fields>-leng).
              ENDIF. " IF <lfs_fields>-fieldname = lc_kunwe
            ENDIF. " IF <lfs_fields>-fieldname = lc_kunag
          ELSE. " ELSE -> IF <lfs_fields>-fieldname = lc_kunwe

            IF <lfs_fields>-fieldname = lc_kunag OR <lfs_fields>-fieldname = lc_kunwe.
              IF lv_kunwe IS NOT INITIAL.
                MOVE lv_kunwe TO lwa_e1komg-vakey+lv_len(<lfs_fields>-leng).
                UNASSIGN <lfs_any>.
*                 lv_len = lv_len + <lfs_fields>-leng.
              ELSE. " ELSE -> IF lv_kunwe is not INITIAL

                ASSIGN COMPONENT lc_kunnr OF STRUCTURE lwa_e1komg TO <lfs_any>.
                IF <lfs_any> IS ASSIGNED .
                  MOVE <lfs_any> TO lwa_e1komg-vakey+lv_len(<lfs_fields>-leng).
                  UNASSIGN <lfs_any>.
                ENDIF. " IF <lfs_any> IS ASSIGNED
              ENDIF. " IF lv_kunwe is not INITIAL
            ENDIF. " IF <lfs_fields>-fieldname = lc_kunag OR <lfs_fields>-fieldname = lc_kunwe
          ENDIF. " IF <lfs_any> IS ASSIGNED
*<--- End of addition for D2_OTC_EDD_0274/Defect 959 by vchoudh.


          ASSIGN COMPONENT <lfs_fields>-fieldname OF STRUCTURE lwa_z1otc_cond_key_fields TO <lfs_any>.
          IF <lfs_any> IS ASSIGNED.
            MOVE <lfs_any> TO lwa_e1komg-vakey+lv_len(<lfs_fields>-leng).
            UNASSIGN <lfs_any>.

          ENDIF. " IF <lfs_any> IS ASSIGNED

        ENDIF. " LOOP AT li_fields ASSIGNING <lfs_fields>

        lv_len = lv_len + <lfs_fields>-leng.

      ENDLOOP. " IF ( lwa_e1komg IS NOT INITIAL ) AND
      CLEAR: lv_len.
      REFRESH: li_fields.

*&--Read Address for Sales Org. Address
      READ TABLE li_adrnr ASSIGNING <lfs_adrnr>
                           WITH KEY vkorg = lwa_e1komg-vkorg
                      BINARY SEARCH.
      IF sy-subrc EQ 0.
*&--Read Sales Org. Country
        READ TABLE li_land1 ASSIGNING <lfs_land1>
                             WITH KEY adrnr = <lfs_adrnr>-adrnr
                        BINARY SEARCH.
        IF sy-subrc EQ 0.
          lwa_e1komg-lland = <lfs_land1>-land1.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0

      lwa_idoc_data-sdata  = lwa_e1komg.
      APPEND lwa_idoc_data TO li_idoc_data.
      CLEAR: lwa_idoc_data, lwa_e1komg.

      IF lwa_z1otc_cond_key_fields IS NOT INITIAL AND
         lwa_z1otc_cond_key_fields <> lc_null.
        lwa_idoc_data-segnam = c_ext_seg.
        lwa_idoc_data-hlevel = c_two.
        lwa_idoc_data-sdata = lwa_z1otc_cond_key_fields.
        APPEND lwa_idoc_data TO li_idoc_data.
        CLEAR: lwa_idoc_data.
      ENDIF. " IF lwa_z1otc_cond_key_fields IS NOT INITIAL AND
      CLEAR: lwa_e1komg.

**** Fill Segments E1KONH
      IF ( lwa_e1konh IS NOT INITIAL ) AND ( lwa_e1konh <> lc_null ).
        IF lwa_e1konh-datbi = 0.
          lwa_e1konh-datbi = lv_datbi.
        ENDIF. " IF lwa_e1konh-datbi = 0
        IF lwa_e1konh-datab = 0.
          lwa_e1konh-datab = lv_datab.
        ENDIF. " IF lwa_e1konh-datab = 0
        IF lwa_e1konh-knumh IS INITIAL.
          lwa_e1konh-knumh = lv_knumh.
        ENDIF. " IF lwa_e1konh-knumh IS INITIAL
        lwa_idoc_data-segnam = c_e1konh.
        lwa_idoc_data-hlevel = c_two.
        lwa_idoc_data-sdata  = lwa_e1konh.
        APPEND lwa_idoc_data TO li_idoc_data.

        lv_datab = lwa_e1konh-datab.
        lv_datbi = lwa_e1konh-datbi.
        lv_knumh = lwa_e1konh-knumh.
        CLEAR: lwa_idoc_data, lwa_e1konh.
      ENDIF. " IF ( lwa_e1konh IS NOT INITIAL ) AND ( lwa_e1konh <> lc_null )

**** Fill segments E1KONP
      IF ( lwa_e1konp IS NOT INITIAL ) AND ( lwa_e1konp <> lc_null ).
        lwa_idoc_data-segnam = c_e1konp.
        lwa_idoc_data-hlevel = c_three.
        lwa_e1konp-kschl     = lv_kschl.
        lwa_e1konp-stfkz     = lc_stfkz.

        CONDENSE lwa_e1konp-kbetr.
        CONDENSE lwa_e1konp-kpein.

*&--Get currency and UOM
        READ TABLE <fs_dyn_tab> ASSIGNING <lfs_dyn> INDEX lv_lines.
        IF sy-subrc EQ 0.
          ASSIGN COMPONENT c_zcounter OF STRUCTURE <lfs_dyn> TO <fs_any>.
          IF <fs_any> IS ASSIGNED.
            IF <fs_any> IS NOT INITIAL.
              lv_count = <fs_any>.
              UNASSIGN: <fs_any>.
            ENDIF. " IF <fs_any> IS NOT INITIAL
          ENDIF. " IF <fs_any> IS ASSIGNED

          IF lv_count = 1.

            ASSIGN COMPONENT c_konws OF STRUCTURE <lfs_dyn> TO <fs_any>.
            IF <fs_any> IS ASSIGNED.
              IF <fs_any> IS NOT INITIAL.
                lwa_e1konp-konwa = <fs_any>.
                lwa_e1konp-konws = <fs_any>.
                UNASSIGN: <fs_any>.
              ENDIF. " IF <fs_any> IS NOT INITIAL
            ENDIF. " IF <fs_any> IS ASSIGNED

            ASSIGN COMPONENT c_konms OF STRUCTURE <lfs_dyn> TO <fs_any>.
            IF <fs_any> IS ASSIGNED.
              IF <fs_any> IS NOT INITIAL.
                lwa_e1konp-kmein = <fs_any>.
                lwa_e1konp-konms = <fs_any>.
                UNASSIGN: <fs_any>.
              ENDIF. " IF <fs_any> IS NOT INITIAL
            ENDIF. " IF <fs_any> IS ASSIGNED
          ENDIF. " IF lv_count = 1
          UNASSIGN: <lfs_dyn>.
          CLEAR: lv_count.
        ENDIF. " IF sy-subrc EQ 0

        IF lv_indicator = c_iupd OR lv_indicator =  c_idel OR lv_indicator = c_iupd_l OR lv_indicator = c_idel_l.
          lwa_e1konp-loevm_ko = c_true.
        ENDIF. " IF lv_indicator = c_iupd OR lv_indicator = c_idel or lv_indicator = c_iupd_l or lv_indicator = c_idel_l

        IF lwa_e1konp-kbetr IS NOT INITIAL.
          lwa_e1konp-kzbzg     = lc_kzbzg_b.
* ---> Begin of Delete for D2_OTC_EDD_0274 Defect D2_959 PGL by MGARG
*          lwa_e1konp-krech     = lc_krech_b.
* ---> End of Delete for D2_OTC_EDD_0274 Defect D2_959 PGL by MGARG
        ENDIF. " IF lwa_e1konp-kbetr IS NOT INITIAL
        IF lwa_e1konp-kstbm IS NOT INITIAL.
          lwa_e1konp-kzbzg     = lc_kzbzg_c.
          lwa_e1konp-krech     = lc_krech_c.
        ENDIF. " IF lwa_e1konp-kstbm IS NOT INITIAL
        lwa_idoc_data-sdata  = lwa_e1konp.
        APPEND lwa_idoc_data TO li_idoc_data.
        CLEAR: lwa_idoc_data.

* ---> Begin of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN

        IF lwa_z1otc_konp_ext IS NOT INITIAL.
          lwa_idoc_data-segnam = c_z1otc_konp_ext.
          lwa_idoc_data-hlevel = c_four.
          lwa_idoc_data-sdata  = lwa_z1otc_konp_ext.
          APPEND lwa_idoc_data TO li_idoc_data.
          CLEAR: lwa_idoc_data.
          CLEAR lwa_idoc_data.
        ENDIF. " IF lwa_z1otc_konp_ext IS NOT INITIAL

* <--- End    of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN

      ENDIF. " IF ( lwa_e1konp IS NOT INITIAL ) AND ( lwa_e1konp <> lc_null )

    ENDIF. " LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>

    IF lv_counter NE 0.

* ---> Begin of Delete for Defect 959 by DMOIRAN
* As scale quantity is not used remove it.

**&--For Quantity Scale
*      IF lv_kstbm IS NOT INITIAL.
*        lwa_e1konm-kbetr = lv_kstbm.
*        lwa_e1konm-kstbm = lv_kstbm.
*
*        CONDENSE lwa_e1konm-kbetr.
*        CONDENSE lwa_e1konm-kstbm.
*
*        lwa_idoc_data-segnam = c_e1konm.
*        lwa_idoc_data-hlevel = c_four.
*        lwa_idoc_data-sdata  = lwa_e1konm.
*        APPEND lwa_idoc_data TO li_idoc_data.
*        CLEAR: lwa_idoc_data, lwa_e1konm.
*      ENDIF. " IF lv_kstbm IS NOT INITIAL
* <--- End   of Delete for Defect 959 by DMOIRAN
*&--For Amount Scale
*      IF lv_kbetr IS NOT INITIAL.
        lwa_e1konw-kbetr = lv_kbetr.
*---> Begin of delete for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
*        lwa_e1konw-kstbw = lv_kbetr.
*<--- End of Delete for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.

*---> Begin of Insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
        lwa_e1konw-kstbw = lv_kstbm.
*<--- End of Insert for D2_OTC_EDD_0274/Defect 959 by VCHOUDH.
        CONDENSE lwa_e1konw-kbetr.
        CONDENSE lwa_e1konw-kstbw.

        lwa_idoc_data-segnam = c_e1konw.
        lwa_idoc_data-hlevel = c_four.
        lwa_idoc_data-sdata  = lwa_e1konw.
        APPEND lwa_idoc_data TO li_idoc_data.
        CLEAR: lwa_idoc_data, lwa_e1konw.
*      ENDIF. " IF lv_kbetr IS NOT INITIAL
    ENDIF. " IF lv_counter NE 0

    AT END OF (c_cname).
* If Insert then, create a new record, * Go ahead for IDOC creation
      IF lv_indicator = c_iins OR lv_indicator = c_iins_l.
        CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
          TABLES
            idoc_control_rec_40 = li_idoc_header
            idoc_data_rec_40    = li_idoc_data.

        REFRESH li_idoc_data.
        lv_idoc_cre = lv_idoc_cre + 1.

* If Update, then first delete the exitsting record (By setting delete flag
*  and then create a new one
      ELSEIF lv_indicator = c_iupd OR lv_indicator = c_iupd_l.
* First Delete existing record
        CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
          TABLES
            idoc_control_rec_40 = li_idoc_header
            idoc_data_rec_40    = li_idoc_data.

        lv_idoc_cre = lv_idoc_cre + 1.

*&--Clear Deletion Indicator
        CLEAR lwa_e1konp-loevm_ko.

        READ TABLE li_idoc_data ASSIGNING <lfs_idoc_data>
                                 WITH KEY segnam = c_e1konp.
        IF sy-subrc EQ 0.
          <lfs_idoc_data>-sdata = lwa_e1konp.
        ENDIF. " IF sy-subrc EQ 0

*&--Create new record
        CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
          TABLES
            idoc_control_rec_40 = li_idoc_header
            idoc_data_rec_40    = li_idoc_data.

        REFRESH li_idoc_data.
        lv_idoc_cre = lv_idoc_cre + 1.

*&--If delete, then only set the deletion flag
      ELSEIF lv_indicator = c_idel OR lv_indicator = c_idel_l.

        CALL FUNCTION 'IDOC_INBOUND_ASYNCHRONOUS'
          TABLES
            idoc_control_rec_40 = li_idoc_header
            idoc_data_rec_40    = li_idoc_data.

        lv_idoc_cre = lv_idoc_cre + 1.


      ELSE. " ELSE -> IF sy-subrc EQ 0
        MESSAGE i969(zotc_msg) DISPLAY LIKE c_e. " Indicator only can have 'I' 'U' and 'D' value.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF lv_indicator = c_iins or lv_indicator = c_iins_l

      CLEAR: lv_datab,
             lv_datbi,
             lv_knumh,
             lv_counter,
             lwa_e1konp.

      REFRESH: li_idoc_data.

    ENDAT.

  ENDLOOP. " LOOP AT <fs_dyn_tab> ASSIGNING <fs_dyn_wa>
  REFRESH:
           <fs_dyn_tab>,
           li_idoc_header,
           i_seg,
           i_field.
  WRITE:/ text-001, p_filename, lv_idoc_cre.
  CLEAR: lv_idoc_cre.
ENDFORM. " F_CREATE_IDOC

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_SEGMENT
*&---------------------------------------------------------------------*
*       Subroutine to get all fieldsname of segments
*----------------------------------------------------------------------*
*      <--P_I_SEG  table having segment and fieldname
*----------------------------------------------------------------------*
FORM f_create_segment  CHANGING p_i_seg TYPE ty_t_seg.

  CONSTANTS:
  lc_sign   TYPE sign   VALUE 'I',  " Debit/Credit Sign (+/-)
  lc_option TYPE option VALUE 'EQ'. " Option for ranges tables

  TYPES:
    BEGIN OF lty_seg_r,
      sign    TYPE sign,    " Debit/Credit Sign (+/-)
      option  TYPE option,  " Option for ranges tables
      low     TYPE tabname, " Table Name
      high    TYPE tabname, " Table Name
     END OF lty_seg_r.

  DATA: li_seg_r  TYPE STANDARD TABLE OF lty_seg_r,
        lwa_seg_r TYPE lty_seg_r.

* Populate Range table
  lwa_seg_r-sign   = lc_sign.
  lwa_seg_r-option = lc_option.
* Append c_e1komg
  lwa_seg_r-low    = c_e1komg.
  APPEND lwa_seg_r TO li_seg_r.
  CLEAR:  lwa_seg_r-low.
* Append c_e1konh
  lwa_seg_r-low    = c_e1konh.
  APPEND lwa_seg_r TO li_seg_r.
  CLEAR:  lwa_seg_r-low.
* Append  c_e1konp
  lwa_seg_r-low    = c_e1konp.
  APPEND lwa_seg_r TO li_seg_r.
  CLEAR:  lwa_seg_r-low.
* Append c_ext_seg
  lwa_seg_r-low    = c_ext_seg.
  APPEND lwa_seg_r TO li_seg_r.
* ---> Begin of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
  CLEAR:  lwa_seg_r-low.
  lwa_seg_r-low = c_z1otc_konp_ext.
  APPEND lwa_seg_r TO li_seg_r.
  CLEAR:  lwa_seg_r.
* <--- End    of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN


* Get segmant and fieldname by table DD03l
  SELECT
    tabname    " Table Name
    fieldname  " Field Name
  FROM   dd03l " Table Fields
  INTO TABLE p_i_seg
  WHERE tabname IN li_seg_r.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE i970(zotc_msg) WITH c_e1komg c_e1konh c_e1konp c_ext_seg DISPLAY LIKE c_e. " No File Exists in directory &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_CREATE_SEGMENT
*&---------------------------------------------------------------------*
*&      Form  F_MOVE_FILE
*&---------------------------------------------------------------------*
*       Subroutine to move file from TBP to DONE folder
*----------------------------------------------------------------------*
*      -->P_LV_FILENAME  text
*----------------------------------------------------------------------*
FORM f_move_file  USING    p_filename TYPE localfile. " Local file for upload/download

  CONSTANTS : lc_tbp_fld    TYPE char5      VALUE 'TBP',  " TBP folder
              lc_done_fld   TYPE char5      VALUE 'DONE'. " DONE folder.

  DATA: lv_file TYPE localfile, " local variable declaration of type localfile
        lv_name TYPE localfile. " local variable declaration of type localfile.

  CALL FUNCTION '/SAPDMC/LSM_PATH_FILE_SPLIT'
    EXPORTING
      pathfile = p_filename
    IMPORTING
      pathname = lv_file
      filename = lv_name.

  REPLACE lc_tbp_fld  IN lv_file WITH lc_done_fld .
  CONCATENATE lv_file lv_name INTO lv_file.

* Calling the FM to move the file from Source location to Target
* Location.
  CALL FUNCTION 'ZDEV_FILE_MOVE'
    EXPORTING
      im_sourcepath = p_filename
      im_targetpath = lv_file
    EXCEPTIONS
      error_file    = 1
      OTHERS        = 2.
  IF sy-subrc NE 0.
    MESSAGE i958(zotc_msg) WITH p_filename DISPLAY LIKE  c_e. " File & cannot be archived
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_MOVE_FILE
*&---------------------------------------------------------------------*
*&      Form  F_GET_PHY_PATH
*&---------------------------------------------------------------------*
*       Subroutine to get physical path from logical path
*----------------------------------------------------------------------*
*      -->FP_P_LFPATH  Logical Path
*      <--FP_P_PFAPTH  Physical path
*----------------------------------------------------------------------*
FORM f_get_phy_path  USING    fp_p_lfpath TYPE filepath-pathintern " Logical path name
                     CHANGING fp_p_pfapth TYPE rlgrap-filename.    " Local file for upload/download

  DATA: lv_filename   TYPE rlgrap-filename VALUE 'DUMMY'. " Local file for upload/download

* Get the physical path from logical path
  CALL FUNCTION 'FILE_GET_NAME_USING_PATH'
    EXPORTING
      client                     = sy-mandt
      logical_path               = fp_p_lfpath
      operating_system           = sy-opsys
      file_name                  = lv_filename
    IMPORTING
      file_name_with_path        = fp_p_pfapth
    EXCEPTIONS
      path_not_found             = 1
      missing_parameter          = 2
      operating_system_not_found = 3
      file_system_not_found      = 4
      OTHERS                     = 5.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE i951(zotc_msg) WITH fp_p_lfpath  DISPLAY LIKE c_e. " No Input could be retrieved from Logical path &
    LEAVE LIST-PROCESSING.
  ELSE. " ELSE -> IF sy-subrc IS NOT INITIAL
    CONCATENATE c_fslash lv_filename INTO lv_filename.
    REPLACE lv_filename IN fp_p_pfapth WITH space.
    CONDENSE fp_p_pfapth.
  ENDIF. " IF sy-subrc IS NOT INITIAL

ENDFORM. " F_GET_PHY_PATH
*&---------------------------------------------------------------------*
*&      Form  F_GET_LOG_SYS
*&---------------------------------------------------------------------*
*       Get Logical system
*----------------------------------------------------------------------*
FORM f_get_log_sys .

  DATA:     lv_log_sys  TYPE tbdls-logsys. " Logical system

* Get Logical system
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_log_sys
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.
  IF sy-subrc IS INITIAL.
    gv_rcvprn = lv_log_sys.
    gv_sndprn = lv_log_sys.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_GET_LOG-SYS
