************************************************************************
* PROGRAM    :  ZOTCN0081O_SALES_REP_FORM                              *
* TITLE      :  OTC_IDD_0081 UPLOAD SALES REP TERRITORY                *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_IDD_0081                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  COMMON INCLUDE FOR ALL SUBROUTINES                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT    DESCRIPTION                      *
* ===========  ========  ==========   =================================*
* 27-JUNE-2012 APURI     E1DK903418   INITIAL DEVELOPMENT              *
* 19-DEC-2012  SPURI     E1DK908580   Defect 2233 : Make Zip code as   *
*                                     optional.                        *
* 15-APR-2013  SGHOSH    E1DK909923   Defect 3571:                     *
*                                     1. Short dump at production server.
*                                     Program was performing nested loop
*                                     on I_DATE table resulting in huge
*                                     data volumn in internal table.
*                                     2. Existing Record was not splitting
*                                     in case of validity overlap.
*                                     3. Addition of Start date end date
*                                     validation on input file
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION                                        *
*&---------------------------------------------------------------------*
*       Checking extension of file                                     *
*----------------------------------------------------------------------*
*      -->fp_p_file  Localfile from app and pres server                *
*----------------------------------------------------------------------*
FORM f_check_extension  USING fp_p_file TYPE localfile.
  IF fp_p_file IS NOT INITIAL.
    CLEAR gv_extn.
*   Getting the file extension
    PERFORM f_file_extn_check USING fp_p_file
                              CHANGING gv_extn.
*Checking the extension whether its of .XLS
    IF gv_extn <> c_ext .
      MESSAGE e000 WITH 'Please provide .XLS file'(030).
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHECK_EXTENSION

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_PRESNT_FILES                                    *
*&---------------------------------------------------------------------*
*       Uploading the file from presentation server                    *
*----------------------------------------------------------------------*
*      -->fp_p_pfile   Localfile                                       *
*      <--fp_i_input   Input file                                      *
*----------------------------------------------------------------------*
FORM f_upload_presnt_files  USING    fp_p_pfile  TYPE localfile
                            CHANGING fp_i_input  TYPE ty_t_input.
* Local Declaration
  DATA: li_tab      TYPE STANDARD TABLE OF alsmex_tabline
                    INITIAL SIZE 0,
        lwa_tab     TYPE alsmex_tabline,
        li_input    TYPE ty_t_input,
        lv_year     TYPE char4,
        lv_month    TYPE char2,
        lv_day      TYPE char2,
        lwa_input   TYPE ty_input.

*  FIELD-SYMBOLS: <lfs_tab> TYPE alsmex_tabline.

* Uploading the XLS file from Presentation Server
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = fp_p_pfile
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 11
      i_end_row               = 65536
    TABLES
      intern                  = li_tab[]
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.


  IF sy-subrc IS NOT INITIAL.
    MESSAGE i000
    WITH 'File could not be read from presentation server'(007).
    LEAVE LIST-PROCESSING.
  ENDIF.


  LOOP AT li_tab INTO lwa_tab.
    CASE lwa_tab-col.
      WHEN c_fstcol.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lwa_tab-value
          IMPORTING
            output = lwa_input-kunnr.
      WHEN c_scdcol.
        lwa_input-pstlz = lwa_tab-value.
      WHEN c_trdcol.

        SPLIT lwa_tab-value AT c_slash
        INTO lv_month
             lv_day
             lv_year.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_day
          IMPORTING
            output = lv_day.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_month
          IMPORTING
            output = lv_month.
        CONCATENATE lv_year
                    lv_month
                    lv_day
                    INTO gv_stdate.
        lwa_input-stdate = gv_stdate.
        CLEAR: lv_month,
               lv_day,
               lv_year.
      WHEN c_fourtcol.

        SPLIT lwa_tab-value AT c_slash
        INTO lv_month
             lv_day
             lv_year.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_day
          IMPORTING
            output = lv_day.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_month
          IMPORTING
            output = lv_month.
        CONCATENATE lv_year
                    lv_month
                    lv_day
        INTO gv_eddate.
        lwa_input-eddate = gv_eddate.
        CLEAR: lv_month,
               lv_day,
               lv_year.
      WHEN c_fifthcol.
        lwa_input-mtart = lwa_tab-value.
      WHEN c_sixcol.
        lwa_input-matkl = lwa_tab-value.
      WHEN c_svncol.
        lwa_input-prdha = lwa_tab-value.
      WHEN c_eghtcol.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lwa_tab-value
          IMPORTING
            output = lwa_input-prctr.
      WHEN c_ninecol.
        lwa_input-ktokd = lwa_tab-value.
      WHEN c_tencol.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lwa_tab-value
          IMPORTING
            output = lwa_input-empno.
      WHEN c_elevencol.
        lwa_input-comments = lwa_tab-value.
    ENDCASE.

    AT END OF row.
      APPEND lwa_input TO li_input.
      CLEAR lwa_input.
    ENDAT.
  ENDLOOP.
  fp_i_input[] = li_input.

ENDFORM.                    " F_UPLOAD_PRESNT_FILES

*&---------------------------------------------------------------------*
*&      Form  F_GET_DB_VALUES                                          *
*&---------------------------------------------------------------------*
*       Retrieving existing data for validation purpose                *
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
FORM f_get_db_values .

* local internal table declaration
  DATA:
  li_kunnr TYPE ty_t_kunnr,
  li_mtart TYPE ty_t_mtart,
  li_matkl TYPE ty_t_matkl,
  li_prdha TYPE ty_t_prdha,
  li_prctr TYPE ty_t_prctr,
  li_ktokd TYPE ty_t_ktokd,
  li_zotc_sale_empmap
           TYPE ty_t_zotc_sale_empmap,
  li_kna1_empno
           TYPE ty_t_kna1_empno,

* local work area declaration
  lwa_kunnr TYPE ty_kunnr,
  lwa_pstlz TYPE ty_pstlz,
  lwa_shptocst TYPE ty_shptocst,
  lwa_mtart TYPE ty_mtart,
  lwa_matkl TYPE ty_matkl,
  lwa_prdha TYPE ty_prdha,
  lwa_prctr TYPE ty_prctr,
  lwa_ktokd TYPE ty_ktokd,
  lwa_zotc_sale_empmap
            TYPE ty_zotc_sale_empmap,
  lwa_kna1_empno
            TYPE ty_kna1_empno.

* range table and work area declaration
  DATA:

  lr_shptocst   TYPE RANGE OF zotc_sale_empmap-ship_to_customer
                INITIAL SIZE 0,
  lr_pstlz      TYPE RANGE OF zotc_sale_empmap-zip_code
                INITIAL SIZE 0,
  lr_ktokd      TYPE RANGE OF zotc_sale_empmap-emp_role
                INITIAL SIZE 0,
  lwa_shptocst1 LIKE LINE  OF lr_shptocst,
  lwa_emp_role  LIKE LINE  OF lr_ktokd,
  lwa_pstlz1    LIKE LINE  OF lr_pstlz.


  FIELD-SYMBOLS <lfs_input> TYPE ty_input.

  LOOP AT i_input ASSIGNING <lfs_input>.

*   appendind customer number from input file to local internal table
    CLEAR lwa_kunnr.
    lwa_kunnr-kunnr = <lfs_input>-kunnr.
    APPEND lwa_kunnr TO li_kunnr.

*   appending postal code from input file to local internal table
    CLEAR lwa_pstlz.
    lwa_pstlz-pstlz  = <lfs_input>-pstlz.
    APPEND lwa_pstlz TO i_pstlz.


*   appending material type from input file to local internal table
    CLEAR lwa_mtart.
    lwa_mtart-mtart = <lfs_input>-mtart.
    APPEND lwa_mtart TO li_mtart.

*   appending material group from input file to local internal table
    CLEAR lwa_matkl.
    lwa_matkl-matkl = <lfs_input>-matkl.
    APPEND lwa_matkl TO li_matkl.

*   appending pdoduct hierarchy from input file to local internal table
    CLEAR lwa_prdha.
    lwa_prdha-prdha = <lfs_input>-prdha.
    APPEND lwa_prdha TO li_prdha.

*   appending profit centre from input file to local internal table.
    CLEAR lwa_prctr.
    lwa_prctr-prctr = <lfs_input>-prctr.
    APPEND lwa_prctr TO li_prctr.

*   appending ship to customer from input file to build range table
    CLEAR lwa_shptocst.
    lwa_shptocst-kunnr = <lfs_input>-kunnr.
    APPEND lwa_shptocst TO i_shptocst.

*   appending employee role from input file to local internal table.
    CLEAR lwa_ktokd.
    lwa_ktokd-ktokd = <lfs_input>-ktokd.
    APPEND lwa_ktokd TO li_ktokd.

*   appending record with key fields from input file to internal table
    CLEAR lwa_zotc_sale_empmap.
    lwa_zotc_sale_empmap-kunnr   = <lfs_input>-kunnr.
    lwa_zotc_sale_empmap-pstlz   = <lfs_input>-pstlz.
    lwa_zotc_sale_empmap-emprole = <lfs_input>-ktokd.
    lwa_zotc_sale_empmap-stdate  = <lfs_input>-stdate.
    lwa_zotc_sale_empmap-eddate  = <lfs_input>-eddate.

    APPEND lwa_zotc_sale_empmap TO li_zotc_sale_empmap.

*   appending employee number from input file to internal table
    CLEAR lwa_kna1_empno.
    lwa_kna1_empno-empno = <lfs_input>-empno.
    APPEND lwa_kna1_empno TO li_kna1_empno.

  ENDLOOP.

* selectig kunnr from database table KNA1
  IF li_kunnr IS NOT INITIAL.
    SORT li_kunnr BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_kunnr
    COMPARING kunnr.
    SELECT kunnr name1
    FROM kna1
    INTO TABLE i_kunnr
    FOR ALL ENTRIES IN li_kunnr
    WHERE kunnr EQ li_kunnr-kunnr.
    IF sy-subrc EQ 0 .
      SORT i_kunnr BY kunnr.
    ENDIF.
  ENDIF.

* deleting duplicate entries from internal table for postal code
  IF i_pstlz IS NOT INITIAL.
    SORT i_pstlz BY pstlz.
    DELETE ADJACENT DUPLICATES FROM i_pstlz
    COMPARING pstlz.
  ENDIF.

* selecting material type (mtart) from database table T134
  IF li_mtart IS NOT INITIAL.
    SORT li_mtart BY mtart.
    DELETE ADJACENT DUPLICATES
    FROM li_mtart
    COMPARING mtart.
    SELECT mtart
    FROM t134
    INTO TABLE i_mtart
    FOR ALL ENTRIES IN li_mtart
    WHERE mtart EQ li_mtart-mtart.
    IF sy-subrc EQ 0.
      SORT i_mtart BY mtart.
    ENDIF.
  ENDIF.

* selecting material group (matkl) from database table t023
  IF li_matkl IS NOT INITIAL.
    SORT li_matkl BY matkl.
    DELETE ADJACENT DUPLICATES
    FROM li_matkl
    COMPARING matkl.
    SELECT matkl
    FROM t023
    INTO TABLE i_matkl
    FOR ALL ENTRIES IN li_matkl
    WHERE matkl EQ li_matkl-matkl.
    IF sy-subrc EQ 0.
      SORT i_matkl BY matkl.
    ENDIF.
  ENDIF.

* selecting product hierarchy (prdha) from databse table t179
  IF li_prdha IS NOT INITIAL.
    SORT li_prdha BY prdha.
    DELETE ADJACENT DUPLICATES
    FROM li_prdha
    COMPARING prdha.
    SELECT prodh
    FROM t179
    INTO TABLE i_prdha
    FOR ALL ENTRIES IN li_prdha
    WHERE prodh = li_prdha-prdha.
    IF sy-subrc EQ 0.
      SORT i_prdha BY prdha.
    ENDIF.
  ENDIF.

* deleting adjacent duplicates from internal table for ship
* to customer
  IF i_shptocst IS NOT INITIAL.
    SORT i_shptocst BY kunnr.
    DELETE ADJACENT DUPLICATES
    FROM i_shptocst
    COMPARING kunnr.
  ENDIF.

* selecting profit centre (prctr) from database table CEPC
  IF li_prctr IS NOT INITIAL.
    SORT li_prctr BY prctr.
    DELETE ADJACENT DUPLICATES
    FROM li_prctr
    COMPARING prctr.
    SELECT prctr
    FROM cepc
    INTO TABLE i_prctr
    FOR ALL ENTRIES IN li_prctr
    WHERE prctr EQ li_prctr-prctr.
    IF sy-subrc EQ 0.
      SORT i_prctr BY prctr.
    ENDIF.
  ENDIF.

*selecting employee role (ktokd) from database table zotc_prc_control
  IF li_ktokd IS NOT INITIAL.
    SORT li_ktokd BY ktokd.
    DELETE ADJACENT DUPLICATES
    FROM li_ktokd
    COMPARING ktokd.
    SELECT mvalue1
    FROM zotc_prc_control
    INTO TABLE i_ktokd
    FOR ALL ENTRIES IN li_ktokd
    WHERE mvalue1    EQ li_ktokd-ktokd AND
          mprogram   EQ c_mprogram     AND
          mparameter EQ c_mparameter   AND
          mactive    EQ c_mactive .
    IF sy-subrc NE 0.
      SORT i_ktokd BY ktokd.
    ENDIF.
  ENDIF.

* selecting employee number from database table kna1
  IF li_kna1_empno IS NOT INITIAL.
    SORT li_kna1_empno BY empno.
    DELETE ADJACENT DUPLICATES
    FROM li_kna1_empno COMPARING empno.
    SELECT kunnr name1
    FROM kna1
    INTO TABLE i_kna1_empno
    FOR ALL ENTRIES IN li_kna1_empno
    WHERE kunnr = li_kna1_empno-empno
          AND ktokd = c_ktokd.
    IF sy-subrc EQ 0.
      SORT i_kna1_empno BY empno.
    ENDIF.
  ENDIF.

* validating duplicate records
  IF li_zotc_sale_empmap IS NOT INITIAL.
    SORT li_zotc_sale_empmap BY
                             kunnr
                             pstlz
                             emprole
                             stdate
                             eddate.
    DELETE ADJACENT DUPLICATES
    FROM li_zotc_sale_empmap
    COMPARING kunnr
              pstlz
              emprole
              stdate
              eddate.
    SELECT ship_to_customer
           zip_code
           emp_role
           validity_start
           validity_end
    FROM zotc_sale_empmap
    INTO TABLE i_zotc_sale_empmap
    FOR ALL ENTRIES IN li_zotc_sale_empmap
    WHERE ship_to_customer = li_zotc_sale_empmap-kunnr   AND
          zip_code         = li_zotc_sale_empmap-pstlz   AND
          emp_role         = li_zotc_sale_empmap-emprole AND
          validity_start   = li_zotc_sale_empmap-stdate  AND
          validity_end     = li_zotc_sale_empmap-eddate.
    IF  sy-subrc EQ 0.
      SORT i_zotc_sale_empmap BY
                                kunnr
                                pstlz
                                emprole
                                stdate
                                eddate.
    ENDIF.
  ENDIF.
* Populating range table from internal table
  LOOP AT i_shptocst INTO wa_shptocst.
    lwa_shptocst1-sign   = c_inclusive.
    lwa_shptocst1-option = c_equal.
    lwa_shptocst1-low    = wa_shptocst-kunnr.
    APPEND lwa_shptocst1 TO lr_shptocst.
    CLEAR lwa_shptocst1.
  ENDLOOP.

* populating range table from internal table
  LOOP AT i_pstlz INTO wa_pstlz.
    lwa_pstlz1-sign   = c_inclusive.
    lwa_pstlz1-option = c_equal.
    lwa_pstlz1-low    = wa_pstlz-pstlz.
    APPEND lwa_pstlz1 TO lr_pstlz.
    CLEAR lwa_pstlz1.
  ENDLOOP.

  LOOP AT li_ktokd INTO lwa_ktokd.
    lwa_emp_role-sign   = c_inclusive.
    lwa_emp_role-option = c_equal.
    lwa_emp_role-low    = lwa_ktokd-ktokd.
    APPEND lwa_emp_role TO lr_ktokd.
    CLEAR lwa_emp_role.
  ENDLOOP.

* selecting all records from custom table
  SELECT *
  FROM zotc_sale_empmap
  INTO TABLE i_date
  WHERE ship_to_customer  IN lr_shptocst AND
        zip_code          IN lr_pstlz    AND
        emp_role          IN lr_ktokd.

  IF sy-subrc EQ 0.
    SORT i_date
    BY ship_to_customer
       zip_code
       emp_role.
  ENDIF.

ENDFORM.                    " F_GET_DB_VALUES

*----------------------------------------------------------------------*
*       Form  F_VALIDATE_INPUT                                         *
*----------------------------------------------------------------------*
*       validating the records                                         *
*----------------------------------------------------------------------*
*                                                                      *
*----------------------------------------------------------------------*
FORM f_validate_input .


* local declaration
  DATA:

*  local internal table declaration
   li_input_temp TYPE STANDARD TABLE OF ty_input
                 INITIAL SIZE 0,

*  local work area declaration
   lwa_input_temp TYPE ty_input,        "temp table work area
   lwa_type_input TYPE ty_input,        "make key for final record.

* local variable declaration
  lv_error   TYPE char1,       "error flag
  lv_key     TYPE string,      "key
  lv_stdate  TYPE sy-datum,    "start date
  lv_eddate  TYPE sy-datum,    "end date
  lv_ktokd   TYPE z_mvalue_low,"emp role
  lv_msg     TYPE string.      "messgae

* field symbols declaration
  FIELD-SYMBOLS: <lfs_input> TYPE ty_input,  "fiel symbol of input
                 <lfs_date>  TYPE zotc_sale_empmap. " date

  LOOP AT i_input ASSIGNING <lfs_input>.

    IF li_input_temp IS NOT INITIAL.
      IF lv_error IS NOT INITIAL.
        gv_ecount = gv_ecount + 1. " error count
      ELSE.
        gv_scount = gv_scount + 1. " Success Count
        APPEND LINES OF li_input_temp TO i_final.
        READ TABLE li_input_temp INTO lwa_type_input
        INDEX 1.
        IF sy-subrc EQ 0.
          CONCATENATE lwa_type_input-kunnr
          lwa_type_input-pstlz
          lwa_type_input-stdate
          lwa_type_input-eddate
          INTO wa_report-key
          SEPARATED BY c_slash.
        ENDIF.
        wa_report-msgtyp = c_success.
        wa_report-msgtxt = 'Record verified'(008).
        APPEND wa_report TO i_report.
        CLEAR wa_report.
      ENDIF.
    ENDIF.
    CLEAR lv_error.
    REFRESH li_input_temp.


*   validating customer number
    IF <lfs_input>-kunnr IS NOT INITIAL.
      READ TABLE i_kunnr
      TRANSPORTING NO FIELDS
      WITH KEY kunnr = <lfs_input>-kunnr
      BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Ship to customer number does not exist'(009)
        <lfs_input>-kunnr
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.


*START DEFECT 2233
**   validating postal code
**   it is mandatory field and it cannot be empty
*    IF <lfs_input>-pstlz IS INITIAL.
*      lv_error = c_true.
*      wa_report-msgtyp = c_error.
*      CONCATENATE 'ZIP code cannot be empty'(010)
*      <lfs_input>-pstlz
*      INTO lv_msg
*      SEPARATED BY c_slash.
*      wa_report-msgtxt = lv_msg.
*      CONCATENATE <lfs_input>-kunnr
*                  <lfs_input>-pstlz
*                  <lfs_input>-stdate
*                  <lfs_input>-eddate
*      INTO lv_key
*      SEPARATED BY c_slash.
*      wa_report-key = lv_key.
*      APPEND wa_report TO i_report.
*      CLEAR wa_report.
*      lwa_input_temp = <lfs_input>.
*      APPEND lwa_input_temp TO li_input_temp.
*      CLEAR lwa_input_temp.
*    ENDIF.
*END DEFECT 2233



*   validating start date.
    IF <lfs_input>-stdate IS INITIAL.
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Start date cannot be empty'(011)
      <lfs_input>-stdate
      INTO lv_msg
      SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      CONCATENATE <lfs_input>-kunnr
                  <lfs_input>-pstlz
                  <lfs_input>-stdate
                  <lfs_input>-eddate
      INTO lv_key
      SEPARATED BY c_slash.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      lwa_input_temp = <lfs_input>.
      APPEND lwa_input_temp TO li_input_temp.
      CLEAR lwa_input_temp.
*   checking whether date is valid or not.
    ELSE.
      lv_stdate = <lfs_input>-stdate.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_stdate
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Start date is not valid date. Please check date'(012)
        <lfs_input>-stdate
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   validating end date
    IF <lfs_input>-eddate IS INITIAL.
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'End date cannot be empty'(013)
      <lfs_input>-eddate
      INTO lv_msg
      SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      CONCATENATE <lfs_input>-kunnr
                  <lfs_input>-pstlz
                  <lfs_input>-stdate
                  <lfs_input>-eddate
      INTO lv_key
      SEPARATED BY c_slash.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      lwa_input_temp = <lfs_input>.
      APPEND lwa_input_temp TO li_input_temp.
      CLEAR lwa_input_temp.
*   checking whether date is valid or not.
    ELSE.
      lv_eddate = <lfs_input>-eddate.
      CALL FUNCTION 'DATE_CHECK_PLAUSIBILITY'
        EXPORTING
          date                      = lv_eddate
        EXCEPTIONS
          plausibility_check_failed = 1
          OTHERS                    = 2.
      IF sy-subrc <> 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'End date is not valid date. Please check date'(014)
        <lfs_input>-eddate
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

* Begin of Defect 3571
* Validity Start date must be lesser or equal to validity end date.
    IF <lfs_input>-stdate GT <lfs_input>-eddate.
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Valid From date must be less than Valid To date'(005)
      <lfs_input>-stdate
      <lfs_input>-eddate
      INTO lv_msg
      SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      CONCATENATE <lfs_input>-kunnr
                  <lfs_input>-pstlz
                  <lfs_input>-stdate
                  <lfs_input>-eddate
      INTO lv_key
      SEPARATED BY c_slash.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      lwa_input_temp = <lfs_input>.
      APPEND lwa_input_temp TO li_input_temp.
      CLEAR lwa_input_temp.
    ENDIF.
* End of Defect 3571

*   validating material type
    IF <lfs_input>-mtart IS NOT INITIAL.
      READ TABLE i_mtart
      TRANSPORTING NO FIELDS
      WITH KEY mtart = <lfs_input>-mtart
      BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Material type does not exist'(015)
        <lfs_input>-mtart
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   validating material group
    IF  <lfs_input>-matkl IS NOT INITIAL.
      READ TABLE i_matkl
      TRANSPORTING NO FIELDS
      WITH KEY matkl = <lfs_input>-matkl
      BINARY SEARCH.
      IF  sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Material group does not exist'(016)
        <lfs_input>-matkl
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   validating product hierarchy
    IF  <lfs_input>-prdha IS NOT INITIAL.
      READ TABLE i_prdha
      TRANSPORTING NO FIELDS
      WITH KEY prdha = <lfs_input>-prdha
      BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Product hierarchy does not exist'(017)
        <lfs_input>-prdha
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   Validating profit centre
    IF <lfs_input>-prctr IS NOT INITIAL.
      READ TABLE i_prctr
      TRANSPORTING NO FIELDS
      WITH KEY prctr = <lfs_input>-prctr
      BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Profit centre does not exist'(018)
        <lfs_input>-prctr
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   validating employee number
    IF <lfs_input>-empno IS NOT INITIAL.
      READ TABLE i_kna1_empno
      TRANSPORTING NO FIELDS
      WITH KEY empno = <lfs_input>-empno
      BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Bio-Rad employee number does not exist'(019)
        <lfs_input>-empno
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR  wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   validating employee role
    IF <lfs_input>-ktokd IS INITIAL.
      lv_error = c_true.
      wa_report-msgtyp = c_error.
      CONCATENATE 'Employee role cannot be empty'(020)
      <lfs_input>-ktokd
      INTO lv_msg
      SEPARATED BY c_slash.
      wa_report-msgtxt = lv_msg.
      CONCATENATE <lfs_input>-kunnr
                  <lfs_input>-pstlz
                  <lfs_input>-stdate
                  <lfs_input>-eddate
      INTO lv_key
      SEPARATED BY c_slash.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR wa_report.
      lwa_input_temp = <lfs_input>.
      APPEND lwa_input_temp TO li_input_temp.
      CLEAR lwa_input_temp.
*   checking whether employee role exists or not.
    ELSE.
      lv_ktokd = <lfs_input>-ktokd.
      READ TABLE i_ktokd
      TRANSPORTING NO FIELDS
      WITH KEY ktokd = lv_ktokd
      BINARY SEARCH.
      IF sy-subrc NE 0.
        lv_error = c_true.
        wa_report-msgtyp = c_error.
        CONCATENATE 'Bio-Rad employee role does not exist'(021)
        <lfs_input>-ktokd
        INTO lv_msg
        SEPARATED BY c_slash.
        wa_report-msgtxt = lv_msg.
        CONCATENATE <lfs_input>-kunnr
                    <lfs_input>-pstlz
                    <lfs_input>-stdate
                    <lfs_input>-eddate
        INTO lv_key
        SEPARATED BY c_slash.
        wa_report-key = lv_key.
        APPEND wa_report TO i_report.
        CLEAR  wa_report.
        lwa_input_temp = <lfs_input>.
        APPEND lwa_input_temp TO li_input_temp.
        CLEAR lwa_input_temp.
      ENDIF.
    ENDIF.

*   validating duplicate records
    READ TABLE i_zotc_sale_empmap
    TRANSPORTING NO FIELDS
    WITH KEY kunnr   =  <lfs_input>-kunnr
             pstlz   =  <lfs_input>-pstlz
             emprole =  <lfs_input>-ktokd
             stdate  =  <lfs_input>-stdate
             eddate  =  <lfs_input>-eddate
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      lv_error = c_true.
      wa_report-msgtyp = c_error.

      wa_report-msgtxt = 'Duplicate record already exists.'(022).
      CONCATENATE <lfs_input>-kunnr
                  <lfs_input>-pstlz
                  <lfs_input>-ktokd
                  <lfs_input>-stdate
                  <lfs_input>-eddate
      INTO lv_key
      SEPARATED BY c_slash.
      wa_report-key = lv_key.
      APPEND wa_report TO i_report.
      CLEAR  wa_report.
      lwa_input_temp = <lfs_input>.
      APPEND lwa_input_temp TO li_input_temp.
      CLEAR lwa_input_temp.
    ENDIF.
    IF lv_error IS INITIAL.
      APPEND <lfs_input> TO li_input_temp.
    ENDIF.

*   some exceptional test cases
************************************************************************
    IF i_date IS NOT INITIAL AND lv_error IS INITIAL.
      LOOP AT i_date
      ASSIGNING <lfs_date>
      WHERE ship_to_customer = <lfs_input>-kunnr
      AND   zip_code         = <lfs_input>-pstlz
      AND   emp_role         = <lfs_input>-ktokd
      AND   prod_hier        = <lfs_input>-prdha.   "Defect 3571 ++

*       start date of new record lies within start date
*       and end date of existing record
*          -----------------
*                  ---------------- ( pictorial representation )
        IF ( <lfs_input>-stdate GT <lfs_date>-validity_start AND
             <lfs_input>-stdate LT <lfs_date>-validity_end ) AND
           ( <lfs_input>-eddate GT <lfs_date>-validity_end   AND
             <lfs_input>-eddate GT <lfs_date>-validity_start ) .
*         add new record
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

*         change old record and append it to insert table
          wa_change_date              = <lfs_date>.
          wa_change_date-validity_end = <lfs_input>-stdate - 1.
          APPEND wa_change_date TO i_table_insert.
          CLEAR wa_change_date.

*         delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

*       If start date and end date of new record exists within the
*       Start date and end date of existing record.
*                      ------------------------- (existing)
*                            ------------        ( file record)
        IF ( <lfs_input>-stdate GT <lfs_date>-validity_start AND
             <lfs_input>-stdate LT <lfs_date>-validity_end ) AND
           ( <lfs_input>-eddate GT <lfs_date>-validity_start AND
             <lfs_input>-eddate LT <lfs_date>-validity_end ).

*         add new record
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

*         change old record and append it to insert table
          wa_change_date = <lfs_date>.
          wa_change_date-validity_end = <lfs_input>-stdate - 1.
          APPEND wa_change_date TO i_table_insert.
          CLEAR wa_change_date.

*         delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

*       if end date of new record lies within
*       start date and end date of existing record
*                          ----------------- existing
*                    --------------          new
        IF ( <lfs_input>-eddate GT <lfs_date>-validity_start AND
             <lfs_input>-eddate LT <lfs_date>-validity_end ) AND
           ( <lfs_input>-stdate LT <lfs_date>-validity_start ) .

*         add new record
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

*         change old record and append it to insert table
          wa_change_date = <lfs_date>.
          wa_change_date-validity_start = <lfs_input>-eddate + 1.
          APPEND wa_change_date TO i_table_insert.
          CLEAR wa_change_date.

*         delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

*       if start date and end date of new record does
*       not lies within start date and end date of old record.
*       New record is after old record.
*
*                       ---------- existing
*                                      ------------- new

        IF ( <lfs_input>-stdate GT <lfs_date>-validity_start  AND
             <lfs_input>-stdate GT <lfs_date>-validity_end )  AND
           ( <lfs_input>-eddate GT <lfs_date>-validity_start  AND
             <lfs_input>-eddate GT <lfs_date>-validity_end ).

*         add new record and do not change existing record
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.
        ENDIF.

*       if start date and end date of new record does not lies
*       within start date and end date of old record.
*       New record is before old record

*                       ---------- existing
*        -----------new

        IF ( <lfs_input>-stdate LT <lfs_date>-validity_start AND
             <lfs_input>-stdate LT <lfs_date>-validity_end ) AND
           ( <lfs_input>-eddate LT <lfs_date>-validity_start AND
             <lfs_input>-eddate LT <lfs_date>-validity_end ).

*         add new record and do not change existing record
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.
        ENDIF.

*       if start date and end date of new record ( validity range is extended )
*       is greater than start date and end of existing record.
*       Existing record lies within the range of new record

*                     -----------        existing
*                ----------------------  new
        IF ( <lfs_input>-stdate LT <lfs_date>-validity_start AND
             <lfs_input>-stdate LT <lfs_date>-validity_end ) AND
           ( <lfs_input>-eddate GT <lfs_date>-validity_start AND
             <lfs_input>-eddate GT <lfs_date>-validity_end ).

*         Insert new record as it is
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

*         Delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

*       if start date of new record overlaps (exactly equal to)
*       with start date of existing record
*       ----------
*       ---------------- ( pictorial representation )
        IF ( <lfs_input>-stdate EQ <lfs_date>-validity_start AND
             <lfs_input>-stdate LT <lfs_date>-validity_end ) AND
           ( <lfs_input>-eddate GT <lfs_date>-validity_end   AND
             <lfs_input>-eddate GT <lfs_date>-validity_start ) .

*         Insert new record as it is
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

*         Delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

*     if end date of new record overlaps (exactly equal to)
*     end date of existing record.
*             -----------
*     ------------------- ( pictorial representation )
        IF ( <lfs_input>-eddate  EQ <lfs_date>-validity_end     AND
             <lfs_input>-eddate  GT <lfs_date>-validity_start ) AND
           (  <lfs_input>-stdate LT <lfs_date>-validity_start   AND
             <lfs_input>-stdate  LT <lfs_date>-validity_end   ) .

*         Insert new record as it is
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

*         Delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

* If start date of new record is same as existing record satrt date
* but the endadate is less than the existing record's enddate
* then old record start date should be changed.
*     -------------------   Existing record
*     ----------            Input Record ( pictorial representation )

        IF ( <lfs_input>-stdate EQ <lfs_date>-validity_start AND
              <lfs_input>-stdate LT <lfs_date>-validity_end ) AND
            ( <lfs_input>-eddate LT <lfs_date>-validity_end   AND
              <lfs_input>-eddate GT <lfs_date>-validity_start ) .

*         Insert new record as it is
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

          wa_change_date = <lfs_date>.
          wa_change_date-validity_start = <lfs_input>-eddate + 1.
          APPEND wa_change_date TO i_table_insert.
          CLEAR wa_change_date.

*         Delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.

* Begin of Change - Defect 3571
* If end date of new record is same as existing record end date
* but the start date is greater than the existing record's start date
* then old record end date should be changed.
*     -------------------   Existing record
*              ----------   Input Record ( pictorial representation )
        IF ( <lfs_input>-eddate  EQ <lfs_date>-validity_end     AND
             <lfs_input>-eddate  GT <lfs_date>-validity_start ) AND
           (  <lfs_input>-stdate GT <lfs_date>-validity_start   AND
             <lfs_input>-stdate  LT <lfs_date>-validity_end   ) .

*         Insert new record as it is
          lwa_input_temp = <lfs_input>.
          APPEND lwa_input_temp TO i_final.
          CLEAR lwa_input_temp.

          wa_change_date = <lfs_date>.
          wa_change_date-validity_end = <lfs_input>-stdate - 1.
          APPEND wa_change_date TO i_table_insert.
          CLEAR wa_change_date.

*         Delete old record
          APPEND <lfs_date> TO i_delete.
        ENDIF.
* End of Change - Defect 3571
      ENDLOOP. " loop at i_date
    ENDIF.     " if i_date is not initial
  ENDLOOP.     " loop at i_input


* for the last record.
  IF li_input_temp IS NOT INITIAL.
    IF lv_error IS NOT INITIAL.
      gv_ecount = gv_ecount + 1. " error count
    ELSE.
      gv_scount = gv_scount + 1. " Success Count
      APPEND LINES OF li_input_temp TO i_final.
      READ TABLE li_input_temp INTO lwa_type_input
        INDEX 1.
      IF sy-subrc EQ 0.
        CONCATENATE lwa_type_input-kunnr
        lwa_type_input-pstlz
        lwa_type_input-stdate
        lwa_type_input-eddate
        INTO wa_report-key
        SEPARATED BY c_slash.
      ENDIF.
      wa_report-msgtyp = c_success.
      wa_report-msgtxt = 'Record verified'(008).
      APPEND wa_report TO i_report.
      CLEAR wa_report.
    ENDIF.
  ENDIF.

ENDFORM.                    " F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_INSERT_INTO_TABLE
*&---------------------------------------------------------------------*
*       Inserting into and deleting from databse table
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_insert_into_table .

  DATA:
  lwa_kunnr TYPE ty_kunnr,
  lwa_kna1_empno TYPE ty_kna1_empno.
  FIELD-SYMBOLS: <lfs_final> TYPE ty_input.

  DELETE ADJACENT DUPLICATES
  FROM      i_final
  COMPARING kunnr
            pstlz
            ktokd
            stdate
            eddate.

  LOOP AT i_final ASSIGNING <lfs_final>.
    READ TABLE i_kunnr INTO lwa_kunnr
    WITH KEY kunnr = <lfs_final>-kunnr
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_table_insert-cust_name        = lwa_kunnr-name1.
    ENDIF.
    READ TABLE i_kna1_empno INTO lwa_kna1_empno
    WITH KEY empno =  <lfs_final>-empno
    BINARY SEARCH.
    IF sy-subrc EQ 0.
      wa_table_insert-emp_name         = lwa_kna1_empno-empname.
    ENDIF.
    wa_table_insert-mandt            = sy-mandt.
    wa_table_insert-ship_to_customer = <lfs_final>-kunnr.
    wa_table_insert-zip_code         = <lfs_final>-pstlz.
    wa_table_insert-validity_start   = <lfs_final>-stdate.
    wa_table_insert-validity_end     = <lfs_final>-eddate.
    wa_table_insert-mat_type         = <lfs_final>-mtart.
    wa_table_insert-mat_group        = <lfs_final>-matkl.
    wa_table_insert-prod_hier        = <lfs_final>-prdha.
    wa_table_insert-profit_center    = <lfs_final>-prctr.
    wa_table_insert-emp_role         = <lfs_final>-ktokd.
    wa_table_insert-emp_number       = <lfs_final>-empno.
    wa_table_insert-zz_lastchanged   = sy-uname.
    wa_table_insert-zz_change_date   = sy-datum.
    wa_table_insert-zz_change_time   = sy-uzeit.
    wa_table_insert-zz_comments      = <lfs_final>-comments.
    APPEND wa_table_insert TO i_table_insert.
    CLEAR:
    wa_table_insert,
    lwa_kunnr,
    lwa_kna1_empno.
  ENDLOOP.
  SORT i_table_insert BY ship_to_customer zip_code
                         emp_role validity_start validity_end.
  DELETE ADJACENT DUPLICATES FROM i_table_insert
                             COMPARING ship_to_customer zip_code
                             emp_role validity_start validity_end.

  CALL FUNCTION 'ENQUEUE_EZOTC_SALE_EMP'
    EXPORTING
      mode_zotc_sale_empmap = c_mode
      mandt                 = sy-mandt
    EXCEPTIONS
      foreign_lock          = 1
      system_failure        = 2
      OTHERS                = 3.
  IF sy-subrc EQ 0.
    IF i_delete IS NOT INITIAL.
      DELETE zotc_sale_empmap
      FROM TABLE i_delete.
      IF sy-subrc EQ 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.              " i_delete is not initial
    IF i_table_insert IS NOT INITIAL.
      INSERT zotc_sale_empmap
      FROM TABLE i_table_insert
      ACCEPTING DUPLICATE KEYS.
      IF sy-subrc EQ 0. " if insert is successful
        COMMIT WORK.
        wa_report-msgtyp = c_success.
        wa_report-msgtxt =
        'Sales Employee Table updated successfully'(038).
        APPEND wa_report TO i_report.
        CLEAR wa_report.
      ENDIF.            " if sy-subrc eq 0 for insert
    ENDIF.              " i_table_insert is not initial
    CALL FUNCTION 'DEQUEUE_EZOTC_SALE_EMP'
      EXPORTING
        mode_zotc_sale_empmap = c_mode
        mandt                 = sy-mandt.
  ELSE.   "if lock fails
    wa_report-msgtyp = c_info.
    wa_report-msgtxt =
    'Sales Employee Table cannot be locked'(024).
    APPEND wa_report TO i_report.
    CLEAR wa_report.
  ENDIF.                " if lock
ENDFORM.                " F_INSERT_INTO_TABLE
