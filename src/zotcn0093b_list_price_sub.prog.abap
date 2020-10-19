*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093_LIST_PRICE_SUB
*&---------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*& PROGRAM   :  ZOTCO0093O_LIST_PRICE_TRANSFER                        *
* TITLE      :  Sub Program for initialization and sending idocs      *
* DEVELOPER  :  Moushumi Bhattacharya                                 *
* OBJECT TYPE:  INTERFACE                                             *
* SAP RELEASE:  SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:  Sub Program for initialization and sending idocs .    *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 21-May-2014 MBHATTA1 E2DK900420 INITIAL DEVELOPMENT                 *
*---------------------------------------------------------------------*
* Oct-27-2015  RDAS     E2DK915852 Incident INC0249304 PGL B changes *
* Changes done to replace select option date with parameter.
*---------------------------------------------------------------------*
* 17-11-2015  RDAS     E2DK915852 Defect#1285                         *
*Changes done to not generate Idoc with condition type not maintained
*in EMI.
* 28-Oct-2016 JAHANM  E1DK918891 Defect#5444 Performance Improvement  *
**---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_INTIALIZATION
*&---------------------------------------------------------------------*
*       Hide range tab from select options
*----------------------------------------------------------------------*
FORM f_initialization.

  DATA:   lwa_selopt   TYPE sscr_ass,
          lwa_opt_list TYPE sscr_opt_list,
          li_restrict TYPE sscr_restrict.

  CLEAR lwa_opt_list.
  lwa_opt_list-name          = 'EQ'.
  lwa_opt_list-options-eq    = 'X'.
  APPEND lwa_opt_list TO li_restrict-opt_list_tab.

  CLEAR lwa_selopt.
  lwa_selopt-kind            = 'S'.
  lwa_selopt-name            = 'S_DAT'.
  lwa_selopt-sg_main         = 'I'.
  lwa_selopt-sg_addy         = ' '.
  lwa_selopt-op_main         = 'EQ'.
  lwa_selopt-op_addy         = 'EQ'.
  APPEND lwa_selopt  TO li_restrict-ass_tab.

  CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
    EXPORTING
      restriction            = li_restrict
    EXCEPTIONS
      too_late               = 1
      repeated               = 2
      selopt_without_options = 5
      selopt_without_signs   = 6
      invalid_sign           = 7
      empty_option_list      = 9
      invalid_kind           = 10
      repeated_kind_a        = 11
      OTHERS                 = 12.
ENDFORM. "F_INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  F_SEND_IDOCS
*&---------------------------------------------------------------------*
*       Call FM MASTERIDOC_CREATE_COND_A to send outbound COND_A Idocs
*----------------------------------------------------------------------*
FORM f_send_idocs.

  DATA:    lv_line              TYPE i, " Line of type Integers
           lv_count             TYPE i, " Count of type Integers
           lv_max               TYPE i, " Max of type Integers
           lv_last              TYPE i, " Max of type Integers
           lv_loop_count        TYPE i. " Loop_count of type Integers
                                     " Max of type Integers
  TYPES : BEGIN OF lty_konp,
            knumh     TYPE knumh,    " Condition record number
            loevm_ko  TYPE loevm_ko, " Deletion Indicator for Condition Item
          END OF lty_konp.

  TYPES:
   BEGIN OF lty_knumh,
     knumh TYPE knumh, " Condition record number
   END OF lty_knumh.

* Begin of change for D2_OTC_IDD_0093 by MBHATTA1

* Local Data Declaration
  DATA : li_konp           TYPE STANDARD TABLE OF lty_konp,   " Condition Record Number Table
         lv_ref_tabletype  TYPE REF TO cl_abap_tabledescr,    " Runtime Type Services
         lv_ref_rowtype    TYPE REF TO cl_abap_structdescr,   " Runtime Type Services
         li_itab           TYPE REF TO data,                  " Class
         lwa_knumh_s       TYPE lty_knumh,
         li_knumh_t        TYPE TABLE OF lty_knumh,           " Table for Condition Number
         li_knumh2         TYPE STANDARD TABLE OF vkkacondit, " Gen. Condition Transfer: Condition Key
         lwa_knumh2        TYPE vkkacondit,                   " Gen. Condition Transfer: Condition Key
         lwa_t681          TYPE t681,                         " Conditions: Structures
         lwa_itab          TYPE REF TO data,                  " Class
         lwa_jobs         TYPE ty_jobs,
*begin of rdas
*&--Enhancement Status
         li_status            TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
         lr_kschl             TYPE RANGE OF kschl,                    " Condition Type
*&--Condition Type(s)
    lwa_kschl            LIKE LINE OF lr_kschl.
*end of rdas

* Local Constant Declaration
  CONSTANTS: lc_knumh  TYPE name_feld VALUE 'KNUMH', " Field name
             lc_kschl  TYPE name_feld VALUE 'KSCHL', " Field name
             lc_kappl  TYPE name_feld VALUE 'KAPPL', " Field name
             lc_datbi  TYPE name_feld VALUE 'DATBI', " Field name
             lc_datab  TYPE name_feld VALUE 'DATAB', " Field name
             lc_i      TYPE ddsign    VALUE 'I',     " Type of SIGN component in row type of a Ranges type
             lc_eq     TYPE ddoption  VALUE 'EQ',    " Type of OPTION component in row type of a Ranges type
             lc_004    TYPE kotabnr   VALUE '004',   " Condition table
             lc_009    TYPE msgfn     VALUE '009'.   " Function

* Local Field Symbol Declaration
  FIELD-SYMBOLS : <lfs_konp>  TYPE lty_konp,  " Condition Record
                  <lfs_itab>  TYPE ANY TABLE, " Dynamic Internal Table
                  <lfs_work>  TYPE any,       " Dynamic Workarea
                  <lfs_field> TYPE any,       " Dynamic Field Symbols
*&--Enhancement Status
                  <lfs_status> TYPE zdev_enh_status. " Enhancement Status

*--> Begin of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
*----------------------------------------------------------------------*
*  Read list of condition type(s) for OTC_IDD_0093 from EMI tool
*----------------------------------------------------------------------*
  CLEAR: li_status[].
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = c_enh_idd_0093
    TABLES
      tt_enh_status     = li_status.

*-- Check, if the Enh is active
* 1. If the value is: “X”, the overall Enhancement is active and can
*    proceed further for checks
  DELETE li_status WHERE active = abap_false.
  READ TABLE li_status WITH KEY criteria = lc_kschl "NULL
                       TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
*-- Collecting the condition types from EMI Tool
    LOOP AT li_status ASSIGNING <lfs_status>
                        WHERE criteria = lc_kschl.
      lwa_kschl-sign   = <lfs_status>-sel_sign.
      lwa_kschl-option = <lfs_status>-sel_option.
      lwa_kschl-low    = <lfs_status>-sel_low.
      APPEND lwa_kschl TO lr_kschl.
      CLEAR lwa_kschl.
    ENDLOOP. " LOOP AT li_status ASSIGNING <lfs_status>
  ENDIF. " IF sy-subrc = 0

*check whether the condition entered by user is maintained in EMI table
  IF p_cond IN lr_kschl.
*<--  End of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
    CONCATENATE c_cond_use p_tab INTO lwa_t681-kotab.

***>>> Begin of logic for Creation of Dynamic Internal table
    lv_ref_rowtype ?= cl_abap_typedescr=>describe_by_name( p_name = lwa_t681-kotab ).
    lv_ref_tabletype = cl_abap_tabledescr=>create( p_line_type = lv_ref_rowtype ).
    CREATE DATA li_itab TYPE HANDLE lv_ref_tabletype. " Internal ID of an object
    CREATE DATA lwa_itab TYPE HANDLE lv_ref_rowtype. " Internal ID of an object
    ASSIGN li_itab->* TO <lfs_itab>.
    ASSIGN lwa_itab->* TO <lfs_work>.
***<<< End of Logic for Creation fo Dynamic Internal Table

    IF s_matnr IS NOT INITIAL OR p_ersda IS NOT INITIAL.
* Select * is done instead of fields because otherwise the code wont get activated.
* However there is a possibility to make the selection fields also dynamic but because
* every time the following table will be a configuration table and the number of fields
* will be less then 10 so need to make the selection fields as dynamic.
      SELECT * FROM (lwa_t681-kotab)
               INTO TABLE <lfs_itab>
               WHERE kschl = p_cond
               AND   matnr IN s_matnr
*->> Start of Defect#5444 by Jahan.
               AND   vkorg IN s_vkorg
               AND   vtweg IN s_vtweg
*->> End of Defect#5444 by Jahan.

*  Begin of change for D2_OTC_IDD_0093 / Incident INC0249304 by RDAS
*             AND   datab <= s_ersda-low
*             AND   datbi >= s_ersda-high.
               AND   datab <= p_ersda
               AND   datbi >= p_ersda.
*  End of change for D2_OTC_IDD_0093 / Incident INC0249304 by RDAS
      IF sy-subrc = 0.

***>>> Begin of Logic collecting field KNUMH.
        IF <lfs_itab> IS NOT INITIAL.
          LOOP AT <lfs_itab> INTO <lfs_work>.
            ASSIGN COMPONENT lc_knumh OF STRUCTURE <lfs_work> TO <lfs_field>.
            IF sy-subrc = 0.
*  Begin of Defect # 1241 changes
              lwa_knumh_s = <lfs_field>.
              APPEND lwa_knumh_s TO li_knumh_t.
              CLEAR lwa_knumh_s.
            ENDIF. " IF sy-subrc = 0
*  End of Defect # 1241 changes
          ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>
        ENDIF. " IF <lfs_itab> IS NOT INITIAL
***<<< End of Logic of collecting field KNUMH
*--> Begin of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
      ELSE. " ELSE -> IF sy-subrc = 0
* No record found so give information message
        MESSAGE i981. " Data Not Found
*<-- End of change for D2_OTC_IDD_0093/Defect 1285 by RDAS

      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF s_matnr IS NOT INITIAL OR p_ersda IS NOT INITIAL

***>>> Begin of getting the condition items
    IF li_knumh_t IS NOT INITIAL.
      SELECT knumh                         " Condition record number
             loevm_ko                      " Deletion Indicator for Condition Item
             FROM  konp                    " Conditions (Item)
             INTO  TABLE li_konp
             FOR ALL ENTRIES IN li_knumh_t "Defect # 1241
             WHERE knumh EQ li_knumh_t-knumh.
* No Need to handle the -ve sy-subrc.
      IF sy-subrc = 0.
        SORT li_konp BY knumh loevm_ko.
*--> Begin of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
*        If all condition record are set for deletion it should not be considered for processing.
        READ TABLE li_konp ASSIGNING <lfs_konp> WITH KEY loevm_ko = space.
        IF sy-subrc IS NOT INITIAL.
          MESSAGE i196. "All condition record are marked for deletion
          LEAVE LIST-PROCESSING.
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ELSE. " ELSE -> IF sy-subrc = 0
        MESSAGE i981. "Data Not Found
*<-- End of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF li_knumh_t IS NOT INITIAL
***<<< End of getting the condition items

***>>> Begin of collecting all the required fields and populating into the condition record table
    LOOP AT <lfs_itab> INTO <lfs_work>.
      ASSIGN COMPONENT lc_knumh OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc = 0.
        READ TABLE li_konp ASSIGNING <lfs_konp>
                           WITH KEY knumh = <lfs_field>
                                    loevm_ko = space
                                    BINARY SEARCH.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF. " IF sy-subrc <> 0
        lwa_knumh2-knumh = <lfs_field>.
      ENDIF. " IF sy-subrc = 0
      ASSIGN COMPONENT lc_kschl OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc = 0.
        lwa_knumh2-kschl = <lfs_field>.
      ENDIF. " IF sy-subrc = 0
      ASSIGN COMPONENT lc_kappl OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc = 0.
        lwa_knumh2-kappl = <lfs_field>.
      ENDIF. " IF sy-subrc = 0
      ASSIGN COMPONENT lc_datbi OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc = 0.
        lwa_knumh2-datbi = <lfs_field>.
        lwa_knumh2-a_datbi = <lfs_field>.
      ENDIF. " IF sy-subrc = 0
      ASSIGN COMPONENT lc_datab OF STRUCTURE <lfs_work> TO <lfs_field>.
      IF sy-subrc = 0.
        lwa_knumh2-datab = <lfs_field>.
        lwa_knumh2-a_datab = <lfs_field>.
      ENDIF. " IF sy-subrc = 0
      lwa_knumh2-kotabnr = lc_004.
      lwa_knumh2-kvewe   = c_cond_use.
      lwa_knumh2-msgfn   = lc_009.
      APPEND lwa_knumh2 TO li_knumh2.
      CLEAR lwa_knumh2.
    ENDLOOP. " LOOP AT <lfs_itab> INTO <lfs_work>
    CLEAR li_konp.
    CLEAR li_knumh_t.
***<<< End of collecting all the required fields and populating into the condition record table

***>>> For Entire Load we are doing export in order to restrict the filteration which happens
***>>> from FM:EXIT_SAPLVKOE_002
*Begin of change by rdas
*  CALL FUNCTION 'ZOTC_SET_VALUE'
*    EXPORTING
*      im_flag = abap_true.
*End of change by rdas
* Calling the FM to create the IDOC

*->> Start of Defect#5444 by Jahan.
*--Split the itab based of threshold no 'p_max' into multiple batches
*--and submit them individually in background.
    lv_max = p_max. " No of records from Selection Screen

    DESCRIBE TABLE li_knumh2 LINES lv_line.
    IF lv_line > lv_max.

      lv_loop_count = lv_line DIV lv_max.

      LOOP AT li_knumh2 INTO lwa_knumh2.
        lv_last = sy-tabix .
        APPEND lwa_knumh2 TO i_knumh_dyn.
        lv_count = lv_count + 1.
        gv_count = lv_count.
        IF lv_count = lv_max.
          gv_subm_count = gv_subm_count + 1.
          PERFORM submit_background.

          CLEAR : i_knumh_dyn,
                  lwa_knumh2,
                  gv_count,
                  lv_count.
        ELSEIF gv_subm_count = lv_loop_count.
          IF lv_last = lv_line.
            gv_subm_count = gv_subm_count + 1.
            PERFORM submit_background.
            CLEAR : i_knumh_dyn,
                    lwa_knumh2,
                    gv_count,
                    lv_count.
          ENDIF. " IF lv_last = lv_line
        ENDIF. " IF lv_count = lv_max
      ENDLOOP. " LOOP AT li_knumh2 INTO lwa_knumh2

      WRITE text-008 . "Follwoing Background Jobs are created and submitted for processing
      ULINE.
      SKIP .
      LOOP AT i_jobs INTO lwa_jobs.
        WRITE:/ lwa_jobs-jobname,   '     ',  lwa_jobs-count, ' Records'.
      ENDLOOP. " LOOP at ijobs
    ELSE. " ELSE -> IF lv_line > lv_max

      CALL FUNCTION 'MASTERIDOC_CREATE_COND_A'
        EXPORTING
          pi_mestyp                 = c_msg_typ
          pi_direkt                 = abap_true
        TABLES
          pit_conditions            = li_knumh2
        EXCEPTIONS
          idoc_could_not_be_created = 1.
      IF sy-subrc = 0.
        COMMIT WORK.
      ELSE. " ELSE -> IF sy-subrc = 0
        ROLLBACK WORK.
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF lv_line > lv_max

***    CALL FUNCTION 'MASTERIDOC_CREATE_COND_A'
***      EXPORTING
***        pi_mestyp                 = c_msg_typ
***        pi_direkt                 = abap_true
***      TABLES
***        pit_conditions            = li_knumh2
***      EXCEPTIONS
***        idoc_could_not_be_created = 1.
***    IF sy-subrc = 0.
***      COMMIT WORK.
***    ELSE. " ELSE -> IF sy-subrc = 0
***      ROLLBACK WORK.
***    ENDIF. " IF sy-subrc = 0

*->> End of Defect#5444 by Jahan.

*--> Begin of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
  ELSE. " ELSE -> IF p_cond IN lr_kschl
*condtion entered by user not maintained in EMI

* Idoc not generated.Please enter different condition type
    MESSAGE i075.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF p_cond IN lr_kschl
*<-- End of change for D2_OTC_IDD_0093/Defect 1285 by RDAS
ENDFORM. " F_SEND_IDOCS

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_INPUT
*&---------------------------------------------------------------------*
* Subroutine to validate selection creen input details
*----------------------------------------------------------------------*
FORM f_validate_input.

* Local Data Declaration
  DATA: lwa_t685 TYPE t685. " Conditions: Types

  IF p_cond IS NOT INITIAL.
* Validating the Condition Record
    SELECT SINGLE *
           FROM t685 INTO lwa_t685
           WHERE kvewe = c_cond_use
           AND   kappl = c_app
           AND   kschl = p_cond.
    IF sy-subrc <> 0.
      MESSAGE e040(zotc_msg). " Invalid Condition Type
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF p_cond IS NOT INITIAL
ENDFORM. " VALIDATE_INPUT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_INPUT2
*&---------------------------------------------------------------------*
* Subroutine to validate selection creen input details
*----------------------------------------------------------------------*
FORM f_validate_input2.

* Local Data Declaration
  DATA: lwa_t681 TYPE t681. " Conditions: Access Sequences (Generated Form)

  IF  p_tab  IS NOT INITIAL.
* Validating the Condition Record Table
    SELECT SINGLE *
                 FROM t681 INTO lwa_t681
                 WHERE kvewe   = c_cond_use
                 AND   kotabnr = p_tab
                 AND   kappl   = c_app.
    IF sy-subrc <> 0.
      MESSAGE e041(zotc_msg). " Invalid Access Sequence
    ENDIF. " IF sy-subrc <> 0
  ENDIF. " IF p_tab IS NOT INITIAL
ENDFORM. " VALIDATE_INPUT2
* End of change for D2_OTC_IDD_0093 by MBHATTA1

*->> Start of Defect#5444 by Jahan.
*&---------------------------------------------------------------------*
*&      Form  SUBMIT_BACKGROUND
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM submit_background .

  DATA : lv_job_name      TYPE tbtcjob-jobname VALUE 'ZOTCIDD_93', " Background job name
         lv_job_number    TYPE tbtcjob-jobcount,                   " Job ID
         lv_loc_tim_stamp TYPE char15,                             " UTC Time Stamp in Short Form (YYYYMMDDhhmmss)
         lv_tim           TYPE systtimlo,                          " Local Time of Current User
         lv_dat           TYPE systdatlo,                          " Local Date for Current User
         lv_job_count     TYPE char3,                              " Local Date for Current User
         lv_mem_id        TYPE char22,
         lwa_jobs         TYPE ty_jobs.                             " Mem_id of type CHAR22

*    EXPORT li_knumh2 = li_knumh2 TO MEMORY ID 'ZOTC_IDD_0093'.
  lv_tim = sy-timlo.
  lv_dat = sy-datlo.

  lv_job_count = gv_subm_count.
  CONDENSE lv_job_count.
  CONCATENATE lv_dat lv_tim INTO lv_loc_tim_stamp SEPARATED BY '_'.
  CONCATENATE lv_job_name lv_loc_tim_stamp lv_job_count INTO lv_job_name SEPARATED BY '_'.

  CONCATENATE lv_loc_tim_stamp lv_job_count INTO lv_mem_id SEPARATED BY '_'.

*  EXPORT i_knumh_dyn TO SHARED BUFFER indx(st) ID lv_mem_id.
EXPORT i_knumh_dyn FROM i_knumh_dyn TO DATABASE indx(ar) CLIENT sy-mandt ID lv_mem_id.

  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_job_name
    IMPORTING
      jobcount         = lv_job_number
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.
  IF sy-subrc = 0.

    SUBMIT zotco0093b_listprice_submit_fm
      WITH p_edi = c_msg_typ
      WITH p_dir = abap_true
      WITH p_mem = lv_mem_id
      VIA JOB lv_job_name NUMBER lv_job_number
      AND RETURN.

    IF sy-subrc = 0.
      CALL FUNCTION 'JOB_CLOSE'
        EXPORTING
          jobcount             = lv_job_number
          jobname              = lv_job_name
          strtimmed            = 'X'
        EXCEPTIONS
          cant_start_immediate = 1
          invalid_startdate    = 2
          jobname_missing      = 3
          job_close_failed     = 4
          job_nosteps          = 5
          job_notex            = 6
          lock_failed          = 7
          OTHERS               = 8.
      IF sy-subrc = 0.
        lwa_jobs-jobname = lv_job_name.
        lwa_jobs-count = gv_count.
        APPEND lwa_jobs TO i_jobs.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

ENDFORM. " SUBMIT_BACKGROUND
*->> End of Defect#5444 by Jahan.
