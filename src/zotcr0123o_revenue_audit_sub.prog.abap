*&---------------------------------------------------------------------*
*&  Include           ZOTCR0123O_REVENUE_AUDIT_SUB
*&---------------------------------------------------------------------*
* PROGRAM    :  ZOTCR0121O_REVENUE_AUDITREPORT                         *
* TITLE      :  Revenue Report for Audit                               *
* DEVELOPER  :  Sumanpreet Kaur                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_RDD_0123                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Revenue Report for Audit                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER    TRANSPORT     DESCRIPTION                      *
* =========== ======== ========== =====================================*
* 07-MAY-2018 U034334  E1DK936497 Initial Development                  *
* 11-JUL-2018 U034334  E1DK936497 Defect_5741: Display invoice when we *
*                                 have both End customer & IC invoice  *
*&---------------------------------------------------------------------*
* 20-Sep-2018 U033814  E1DK936497 SCTASK0736901 Add some 9 new fields
*                                 remove some unwanted fiedls and change
*                                 the description for the mentioned fields
*&---------------------------------------------------------------------*
* 22-Oct-2018 U033814  E1DK938998 – Defect 7311 Add 3 new additional
* fields to capture Local amount & currency
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&---------------------------------------------------------------------*
*       Defaulting selection screen values
*----------------------------------------------------------------------*
FORM f_initialization .

  CONSTANTS: lc_sign   TYPE char1   VALUE 'E',    " Sign
             lc_option TYPE char2   VALUE 'EQ',   " Option
             lc_low    TYPE char24  VALUE 'VPRS'. " Low of type CHAR24
  DATA : lwa_range TYPE selopt. " Transfer Structure for Select Options

* Default the values for G/L Account
  lwa_range-sign   = lc_sign.
  lwa_range-option = lc_option.
  lwa_range-low    = lc_low.
  APPEND lwa_range TO s_sakrv.
  CLEAR lwa_range.

* Default the application server file path
  CONCATENATE '/appl/' sy-sysid '/REP/OTC/OTC_RDD_0123/DONE/' INTO p_afile.
ENDFORM. " F_INITIALIZATION
*&---------------------------------------------------------------------*
*&      Form  F_GET_EMI_ENTRIES
*&---------------------------------------------------------------------*
*       Get constant values from the EMI table
*----------------------------------------------------------------------*
*      <--FP_I_ENH_STATUS     EMI Table
*----------------------------------------------------------------------*

FORM f_get_emi_entries CHANGING fp_i_enh_status TYPE ty_t_emi.

  CONSTANTS lc_enhancement_no TYPE z_enhancement VALUE 'OTC_RDD_0123'. " Enhancement No.

  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement_no
    TABLES
      tt_enh_status     = fp_i_enh_status.

  DELETE fp_i_enh_status WHERE active = abap_false.

ENDFORM. " F_GET_EMI_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       Modify Screen according to the radiobutton selected
*----------------------------------------------------------------------*
FORM f_modify_screen .

  CONSTANTS : lc_mi1  TYPE char3  VALUE 'MI1'. " Mi1 of type CHAR3
  LOOP AT SCREEN .
    CASE screen-group1.
* Modif ID for Application Server file path
      WHEN lc_mi1.
* Application Server Option is NOT chosen
        IF rb_backg IS INITIAL.
          screen-active = 0.
          MODIFY SCREEN.
* Application Server Option is chosen
        ELSE. " ELSE -> IF rb_backg IS INITIAL
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF. " IF rb_backg IS INITIAL
      WHEN OTHERS.
    ENDCASE.
  ENDLOOP. " LOOP AT SCREEN
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_HELP_AS_PATH
*&---------------------------------------------------------------------*
*       F4 help for Application Server
*----------------------------------------------------------------------*
*      -->FP_FILENAME    Selected File Path from Application Server
*----------------------------------------------------------------------*
FORM f_help_as_path CHANGING fp_filename TYPE localfile. " Local file for upload/download

* Function  module for F4 help from Application  server
  CALL FUNCTION '/SAPDMC/LSM_F4_SERVER_FILE'
    IMPORTING
      serverfile       = fp_filename
    EXCEPTIONS
      canceled_by_user = 1
      OTHERS           = 2.
  IF sy-subrc <> 0.
    CLEAR fp_filename.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. "F_HELP_AS_PATH
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BUKRS
*&---------------------------------------------------------------------*
*       Validate the company code
*----------------------------------------------------------------------*
FORM f_validate_bukrs .

  DATA lv_bukrs TYPE bukrs. " Sales Organization

  SELECT bukrs " Company Code
    FROM t001  " Company Codes
   UP TO 1 ROWS
    INTO lv_bukrs
   WHERE bukrs IN s_bukrs.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i944 DISPLAY LIKE c_err. " Invalid Company Code
    LEAVE TO SCREEN 1000.
  ENDIF. " IF sy-subrc <> 0

  CLEAR lv_bukrs.
ENDFORM. " F_VALIDATE_BUKRS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_VBELN
*&---------------------------------------------------------------------*
*       Validate the Sales Document
*----------------------------------------------------------------------*
FORM f_validate_vbeln .

  DATA lv_vbeln TYPE vbeln_va. " Sales Document

  SELECT vbeln " Sales Document
    FROM vbak  " Revenue Recognition: Revenue Recognition Lines
   UP TO 1 ROWS
    INTO lv_vbeln
   WHERE vbeln IN s_vbeln.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i806 DISPLAY LIKE c_err. " Invalid Sales Document
  ENDIF. " IF sy-subrc <> 0

  CLEAR lv_vbeln.
ENDFORM. " F_VALIDATE_VBELN
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SAKRV
*&---------------------------------------------------------------------*
*       Validate G/L Account
*----------------------------------------------------------------------*
FORM f_validate_sakrv .

  DATA lv_sakrv TYPE saknr. " G/L Account Number

  SELECT saknr " G/L Account Number
    FROM ska1  " G/L Account Master (Chart of Accounts)
   UP TO 1 ROWS
    INTO lv_sakrv
     BYPASSING BUFFER
   WHERE saknr IN s_sakrv
     AND xloev = space.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i807 DISPLAY LIKE c_err . "Invalid G/L Account
  ENDIF. " IF sy-subrc <> 0

  CLEAR lv_sakrv.
ENDFORM. " F_VALIDATE_SAKRV
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_BLART
*&---------------------------------------------------------------------*
*       Validate Document Type
*----------------------------------------------------------------------*
FORM f_validate_blart .

  DATA lv_blart TYPE blart. " Document Type

  SELECT blart " Document Type
    FROM t003  " Document Types
   UP TO 1 ROWS
    INTO lv_blart
   WHERE blart IN s_blart.
  ENDSELECT.

  IF sy-subrc <> 0.
    MESSAGE i056 DISPLAY LIKE c_err. " Document Type is not valid
  ENDIF. " IF sy-subrc <> 0

  CLEAR lv_blart.
ENDFORM. " F_VALIDATE_BLART
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*       Checking the file extension
*----------------------------------------------------------------------*
FORM f_check_extension .

  DATA lv_extn TYPE char4. " File Extension
  CONSTANTS lc_text TYPE char3 VALUE 'TXT'. " Text

* Getting the Extension of the Filename
  CALL FUNCTION 'ZDEV_TRINT_FILE_GET_EXTENSION'
    EXPORTING
      im_filename  = p_afile
      im_uppercase = abap_true
    IMPORTING
      ex_extension = lv_extn.

* No need to check SY-SUBRC as no exception is raised by the FM and...
* ... it will always return SY-SUBRC = 0.
  IF lv_extn <> lc_text.
    MESSAGE i008 DISPLAY LIKE 'E'. " Please provide TXT file
    LEAVE LIST-PROCESSING.
  ENDIF. " IF lv_extn <> lc_text

ENDFORM. " F_CHECK_EXTENSION
*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*       Fetch and Process Data for ALV Display
*----------------------------------------------------------------------*
*  <--  fp_i_final           Final Table for ALV
*----------------------------------------------------------------------*
FORM f_get_data_for_display   CHANGING fp_i_final TYPE ty_t_final.

  DATA : li_vbreve    TYPE ty_t_vbreve,   " Revenue Recognition: Revenue Recognition Lines
         li_vbfa_dlv  TYPE ty_t_vbfa_dlv, " Deliveries from VBFA
         li_likp      TYPE ty_t_likp,     " Internal table for LIKP
         li_lips      TYPE ty_t_lips,     " Internal table for LIPS
         li_bkpf      TYPE ty_t_bkpf,     " Internal table for BKPF
         li_vbap      TYPE ty_t_vbap,     " Internal table for VBAP
         li_mkpf      TYPE ty_t_mkpf,     " Internal table for MKPF
         li_vbrp      TYPE ty_t_vbrp,     " Internal table fot VBRP
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
         li_vbrk      TYPE ty_t_vbrk. " Internal table for VBRK
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

* Get Revenue Data
  PERFORM f_get_rev_data CHANGING li_vbreve
                                  li_vbfa_dlv
                                  li_likp
                                  li_lips.

* Get Other Data
  PERFORM f_get_other_data  USING li_vbreve
                                  li_lips
                                  li_likp
                         CHANGING li_bkpf
                                  li_vbap
                                  li_mkpf
                                  li_vbrp
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
                                  li_vbrk.
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

* Populate final table
  PERFORM f_populate_final USING  li_vbreve
                                  li_vbfa_dlv
                                  li_likp
                                  li_lips
                                  li_bkpf
                                  li_vbap
                                  li_mkpf
                                  li_vbrp
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
                                  li_vbrk
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
                         CHANGING fp_i_final.

  FREE : li_vbreve,
         li_vbfa_dlv,
         li_likp,
         li_lips,
         li_bkpf,
         li_vbap,
         li_mkpf,
         li_vbrp,
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
         li_vbrk.
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
ENDFORM. " F_GET_DATA_FOR_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  F_GET_REV_DATA
*&---------------------------------------------------------------------*
*       Get Revenue Data
*----------------------------------------------------------------------*
*      <--FP_I_VBREVE       Revenue Recognition
*      <--FP_I_VBFA_DLV     Delivery data from VBFA
*      <--FP_I_LIKP         Delivery Header
*      <--FP_I_LIPS         Delivery Items
*----------------------------------------------------------------------*
FORM f_get_rev_data CHANGING fp_i_vbreve    TYPE ty_t_vbreve " Revenue Recognition: Revenue Recognition Lines
                             fp_i_vbfa_dlv  TYPE ty_t_vbfa_dlv
                             fp_i_likp      TYPE ty_t_likp
                             fp_i_lips      TYPE ty_t_lips.
* Local Variables
  DATA : li_vbreve      TYPE ty_t_vbreve,
         li_lips        TYPE ty_t_lips,
         lwa_vbfa_dlv   TYPE ty_vbfa_dlv,
         lwa_lips       TYPE ty_lips.
* Local Constants
  CONSTANTS : lc_c      TYPE char1      VALUE 'C', " Doc Type C
              lc_j      TYPE char1      VALUE 'J'. " Doc Type J

* Fetch Revenue Data from VBREVE
  SELECT *
    FROM vbreve " Revenue Recognition: Revenue Recognition Lines
    INTO TABLE fp_i_vbreve
   WHERE vbeln IN s_vbeln
     AND sakrv IN s_sakrv
     AND bukrs IN s_bukrs
     AND budat IN s_budat.

  IF sy-subrc = 0.
*&--- Get Delivery
* a) For VBREVE records where VBTYP_N = J
    li_vbreve[] = fp_i_vbreve[].
    DELETE li_vbreve WHERE vbtyp_n NE lc_j.
    IF li_vbreve IS NOT INITIAL.
      SORT li_vbreve BY vbeln_n posnr_n.
      DELETE ADJACENT DUPLICATES FROM li_vbreve COMPARING vbeln_n posnr_n.

      IF li_vbreve IS NOT INITIAL.
* Get the deliveries from LIPS
        SELECT vbeln " Delivery
               posnr " Delivery Item
               lfimg " Actual quantity delivered (in sales units)
               uecha " Higher-Level Item of Batch Split Item
          FROM lips  " SD document: Delivery: Item data
          INTO TABLE fp_i_lips
       FOR ALL ENTRIES IN li_vbreve
         WHERE vbeln = li_vbreve-vbeln_n.
*           AND posnr = li_vbreve-posnr_n.

        IF sy-subrc = 0.
* Do nothing
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_vbreve IS NOT INITIAL
    ENDIF. " IF li_vbreve IS NOT INITIAL

    FREE li_vbreve.

* b) For VBREVE records where VBTYP_N = C
    li_vbreve[] = fp_i_vbreve[].
    DELETE li_vbreve WHERE vbtyp_n NE lc_c.
    IF li_vbreve IS NOT INITIAL.
      SORT li_vbreve BY vbeln_n posnr_n.
      DELETE ADJACENT DUPLICATES FROM li_vbreve COMPARING vbeln_n posnr_n.

* Get deliveries from VBFA
      SELECT vbelv   " Preceding sales and distribution document
             posnv   " Preceding item of an SD document
             vbeln   " Subsequent sales and distribution document
             posnn   " Subsequent item of an SD document
             vbtyp_n " Document category of subsequent document
             rfmng   " Referenced quantity in base unit of measure
        FROM vbfa    " Sales Document Flow
        INTO TABLE fp_i_vbfa_dlv
     FOR ALL ENTRIES IN li_vbreve
       WHERE vbelv = li_vbreve-vbeln_n
         AND posnv = li_vbreve-posnr_n
         AND vbtyp_n = lc_j
         AND rfmng GT 0.

      IF sy-subrc = 0.
        SORT fp_i_vbfa_dlv BY vbelv posnv.
* Collect deliveries from VBFA into LIPS internal table
        LOOP AT fp_i_vbfa_dlv INTO lwa_vbfa_dlv.
          lwa_lips-vbeln = lwa_vbfa_dlv-vbeln.
          lwa_lips-posnr = lwa_vbfa_dlv-posnn.
          lwa_lips-lfimg = lwa_vbfa_dlv-rfmng.
          APPEND lwa_lips TO fp_i_lips.
          CLEAR : lwa_lips,
                  lwa_vbfa_dlv.
        ENDLOOP. " LOOP AT fp_i_vbfa_dlv INTO lwa_vbfa_dlv
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_vbreve IS NOT INITIAL

* Sort Delivery Item table
    IF fp_i_lips IS NOT INITIAL.
      SORT fp_i_lips BY vbeln posnr uecha.
      DELETE ADJACENT DUPLICATES FROM fp_i_lips COMPARING vbeln posnr uecha.
      SORT fp_i_lips BY vbeln posnr uecha.
    ENDIF. " IF fp_i_lips IS NOT INITIAL

* Get Delivery Header Details for all deliveries
    li_lips[] = fp_i_lips[].
    SORT li_lips BY vbeln.
    DELETE ADJACENT DUPLICATES FROM li_lips COMPARING vbeln.
    IF li_lips IS NOT INITIAL.
      SELECT vbeln     " Delivery
             lfart     " Delivery Type
             inco1     " Incoterms (Part 1)
             inco2     " Incoterms (Part 2)
             route     " Route
             kunnr     " Ship-to party
             kunag     " Sold-to party
             anzpk     " Total number of packages in delivery
             wadat_ist " Actual Goods Movement Date
             podat     " Date (proof of delivery)
        FROM likp      " SD Document: Delivery Header Data
      INTO TABLE fp_i_likp
     FOR ALL ENTRIES IN li_lips
       WHERE vbeln = li_lips-vbeln.

      IF sy-subrc = 0.
        SORT fp_i_likp BY vbeln.
* RFC call to EWM with all deliveries to fetch TUs
        PERFORM f_rfc_call CHANGING fp_i_likp.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_lips IS NOT INITIAL

  ELSE. " ELSE -> IF sy-subrc = 0
    MESSAGE i115 DISPLAY LIKE c_err. " No data found for the input given in selection screen
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc = 0

  FREE : li_lips,
         li_vbreve.
ENDFORM. " F_GET_REV_DATA
*&---------------------------------------------------------------------*
*&      Form  F_RFC_CALL
*&---------------------------------------------------------------------*
*       RFC call from ECC to EWM
*----------------------------------------------------------------------*
*      <--FP_I_LIKP        Delivery Header
*----------------------------------------------------------------------*
FORM f_rfc_call  CHANGING fp_i_likp TYPE ty_t_likp.

  CONSTANTS lc_rfcdes    TYPE z_criteria VALUE 'RFC_DEST'. " RFC Destination
  DATA :  lwa_enh_status TYPE zdev_enh_status, " Enhancement Status
          lv_rfcdest     TYPE rfcdest,         " RFC Logical Destination
          lv_rfc_dest    TYPE recvsystem,      " Receiving logical system
          lv_source      TYPE logsys.          " Calling System

* i) Get the logical name of calling system
  CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
    IMPORTING
      own_logical_system             = lv_source
    EXCEPTIONS
      own_logical_system_not_defined = 1
      OTHERS                         = 2.

  IF sy-subrc = 0.
* ii) Get the target system from EMI
    READ TABLE i_enh_status INTO lwa_enh_status
      WITH KEY criteria = lc_rfcdes " 'RFC_DEST'
               sel_low  = lv_source.
    IF sy-subrc = 0.
      lv_rfcdest = lwa_enh_status-sel_high.
      CLEAR lwa_enh_status.

* iii) Check the RFC connection
      SELECT SINGLE logsys     " Receiving logical system
               FROM tblsysdest " RFC Destination of Logical System
               INTO lv_rfc_dest
              WHERE logsys = lv_rfcdest.
      IF sy-subrc = 0.

* iv) Call RFC FM and retrieve TUs
        CALL FUNCTION 'ZOTC_TU_FROM_DELIVERY'
          DESTINATION lv_rfc_dest
          TABLES
            tbl_dlv_tu = fp_i_likp.
* Sy-Subrc not checked, because no error handling is required
      ELSE. " ELSE -> IF sy-subrc = 0
        MESSAGE i808. " RFC Connection to EWM Failed
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF sy-subrc = 0

  CLEAR : lv_source,
          lv_rfc_dest,
          lv_rfc_dest.
ENDFORM. " F_RFC_CALL
*&---------------------------------------------------------------------*
*&      Form  F_GET_OTHER_DATA
*&---------------------------------------------------------------------*
*       Get Other Data
*----------------------------------------------------------------------*
*      -->FP_I_VBREVE        Revenue Recognition
*      -->FP_I_LIPS          Delivery Item
*      <--FP_I_BKPF          Accounting Document Header
*      <--FP_I_VBAP          Sales Document Items
*      <--FP_I_MKPF          Material Document Header
*      <--FP_I_VBRP          Invoice Items
*----------------------------------------------------------------------*
FORM f_get_other_data  USING    fp_i_vbreve TYPE ty_t_vbreve
                                fp_i_lips   TYPE ty_t_lips
                                fp_i_likp   TYPE ty_t_likp
                       CHANGING fp_i_bkpf   TYPE ty_t_bkpf
                                fp_i_vbap   TYPE ty_t_vbap
                                fp_i_mkpf   TYPE ty_t_mkpf
                                fp_i_vbrp   TYPE ty_t_vbrp
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
                                fp_i_vbrk   TYPE ty_t_vbrk.
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

  TYPES : BEGIN OF lty_dlv,
            vbeln TYPE char16, " Delivery
          END OF lty_dlv,

          BEGIN OF lty_bkpf,
            bukrs TYPE bukrs,  " Company Code
            awkey TYPE awkey,  " Reference Key
          END OF lty_bkpf.

  CONSTANTS : lc_tcode      TYPE tcode      VALUE 'VLPOD', " Tcode
              lc_awtyp      TYPE z_criteria VALUE 'AWTYP', " Ref. Transaction
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
              lc_doctyp     TYPE vbtyp      VALUE 'M'. " SD Doc Category
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

  DATA :      li_dlv        TYPE STANDARD TABLE OF lty_dlv,  " Internal table for deliveries
              li_bkpf       TYPE STANDARD TABLE OF lty_bkpf, " Internal table for BKPF
              lr_awtyp      TYPE STANDARD TABLE OF selopt,   " Transfer Structure for Select Options
              li_vbreve     TYPE ty_t_vbreve,                " Internal Table for VBREVE
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
              li_vbrp       TYPE ty_t_vbrp, " Internal table for VBRP
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
              lwa_vbreve    TYPE vbreve,          " Revenue Recognition: Revenue Recognition Lines
              lwa_emi       TYPE zdev_enh_status, " Enhancement Status
              lwa_range     TYPE selopt,          " Transfer Structure for Select Options
              lwa_likp      TYPE ty_likp,         " WA for LIKP
              lwa_bkpf      TYPE lty_bkpf,        " WA for BKPF
              lwa_dlv       TYPE lty_dlv.         " WA for Deliveries

* Get AWTYP from EMI table into local range
  LOOP AT i_enh_status INTO lwa_emi WHERE criteria = lc_awtyp.
    lwa_range-sign = lwa_emi-sel_sign.
    lwa_range-option = lwa_emi-sel_option.
    lwa_range-low = lwa_emi-sel_low.
    APPEND lwa_range TO lr_awtyp.
    CLEAR : lwa_emi,
            lwa_range.
  ENDLOOP. " LOOP AT i_enh_status INTO lwa_emi WHERE criteria = lc_awtyp

* Get Sales Order Item data
  li_vbreve[] = fp_i_vbreve[].
  SORT li_vbreve BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM li_vbreve COMPARING vbeln posnr.
  IF li_vbreve IS NOT INITIAL.

    SELECT vbeln " Sales Document
           posnr " Sales Document Item
           pstyv " Sales document item category
* Begin of SCTASK0736901
           matnr " Material Number
           werks " Plant (Own or External)
           mvgr1 " Material group 1
* End of SCTASK0736901
           ktgrm " Account assignment group for this material
      FROM vbap  " Sales Document: Item Data
      INTO TABLE fp_i_vbap
   FOR ALL ENTRIES IN li_vbreve
     WHERE vbeln = li_vbreve-vbeln
       AND posnr = li_vbreve-posnr.
    IF sy-subrc = 0.
      SORT fp_i_vbap BY vbeln posnr.
    ENDIF. " IF sy-subrc = 0

* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
* Get Invoice Details
    SELECT vbeln " Billing Document
           posnr " Billing item
           vgbel " Document number of the reference document
           vgpos " Item number of the reference item
           aubel " Sales Document
           aupos " Sales Document Item
      FROM vbrp  " Billing Document: Item Data
      INTO TABLE fp_i_vbrp
   FOR ALL ENTRIES IN li_vbreve
     WHERE aubel = li_vbreve-vbeln
       AND aupos = li_vbreve-posnr.
    IF sy-subrc = 0.
      SORT fp_i_vbrp BY vbeln DESCENDING.

      li_vbrp[] = fp_i_vbrp[].
      SORT li_vbrp BY vbeln.
      DELETE ADJACENT DUPLICATES FROM li_vbrp COMPARING vbeln.
      IF li_vbrp IS NOT INITIAL.
        SELECT vbeln " Billing Document
               vbtyp " SD document category
               fksto " Billing document is cancelled
          FROM vbrk  " Billing Document: Header Data
          INTO TABLE fp_i_vbrk
       FOR ALL ENTRIES IN li_vbrp
         WHERE vbeln = li_vbrp-vbeln.
        IF sy-subrc = 0.
          DELETE fp_i_vbrk WHERE vbtyp NE lc_doctyp
                              OR fksto EQ abap_true.
          IF fp_i_vbrk IS NOT INITIAL.
            SORT fp_i_vbrk BY vbeln.
          ENDIF. " IF fp_i_vbrk IS NOT INITIAL
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_vbrp IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
  ENDIF. " IF li_vbreve IS NOT INITIAL

* Get Accounting Details
  LOOP AT fp_i_vbreve INTO lwa_vbreve.
    lwa_bkpf-bukrs = lwa_vbreve-bukrs.
    CONCATENATE lwa_vbreve-sammg lwa_vbreve-reffld
           INTO lwa_bkpf-awkey.
    APPEND lwa_bkpf TO li_bkpf.
    CLEAR : lwa_bkpf,
            lwa_vbreve.
  ENDLOOP. " LOOP AT fp_i_vbreve INTO lwa_vbreve

  SORT li_bkpf BY awkey.
  DELETE ADJACENT DUPLICATES FROM li_bkpf COMPARING awkey.
  IF li_bkpf IS NOT INITIAL.

    SELECT bukrs " Company Code
           belnr " Accounting Document Number
           gjahr " Fiscal Year
           blart " Document Type
           budat " Posting Date in the Document
* Begin of Defect 7311
           hwaer
           kursf
* End of Defect 7311
           awkey " Reference Key
      FROM bkpf  " Accounting Document Header
      INTO TABLE fp_i_bkpf
   FOR ALL ENTRIES IN li_bkpf
     WHERE awtyp IN lr_awtyp
       AND awkey = li_bkpf-awkey.
    IF sy-subrc = 0.
      SORT fp_i_bkpf BY awkey.
      DELETE fp_i_bkpf WHERE blart NOT IN s_blart.
      DELETE fp_i_bkpf WHERE bukrs NOT IN s_bukrs.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_bkpf IS NOT INITIAL

* Get User Name for POD
  IF fp_i_likp IS NOT INITIAL.
    LOOP AT fp_i_likp INTO lwa_likp.
      lwa_dlv-vbeln = lwa_likp-vbeln.
      APPEND lwa_dlv TO li_dlv.
      CLEAR : lwa_likp,
              lwa_dlv.
    ENDLOOP. " LOOP AT fp_i_likp INTO lwa_likp
  ENDIF. " IF fp_i_likp IS NOT INITIAL

  IF li_dlv IS NOT INITIAL.
    SELECT usnam  " User name
           xblnr  " Reference Document Number
           tcode2 " Transaction Code
      FROM mkpf   " Header: Material Document
      INTO TABLE fp_i_mkpf
   FOR ALL ENTRIES IN li_dlv
      WHERE xblnr  = li_dlv-vbeln.
    IF sy-subrc = 0.
      DELETE fp_i_mkpf WHERE tcode2 NE lc_tcode.
      IF fp_i_mkpf IS NOT INITIAL.
        SORT fp_i_mkpf BY xblnr.
      ENDIF. " IF fp_i_mkpf IS NOT INITIAL
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_dlv IS NOT INITIAL

* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
** Get Invoice Details
*  IF fp_i_lips IS NOT INITIAL.
** Delete adjacent duplicates not done bcoz of all unique records
*    SELECT vbeln " Billing Document
*           posnr " Billing item
*           vgbel " Document number of the reference document
*           vgpos " Item number of the reference item
*      FROM vbrp  " Billing Document: Item Data
*      INTO TABLE fp_i_vbrp
*   FOR ALL ENTRIES IN fp_i_lips
*     WHERE vgbel = fp_i_lips-vbeln
*       AND vgpos = fp_i_lips-posnr.
*    IF sy-subrc = 0.
*      SORT fp_i_vbrp BY vgbel vgpos.
*    ENDIF. " IF sy-subrc = 0
*  ENDIF. " IF fp_i_lips IS NOT INITIAL
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

  FREE : li_vbreve,
         li_dlv,
         li_bkpf,
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
         li_vbrp.
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

ENDFORM. " F_GET_OTHER_DATA
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FINAL
*&---------------------------------------------------------------------*
*       Populate Final Table for ALV display
*----------------------------------------------------------------------*
*      -->FP_I_VBREVE        Revenue Recognition
*      -->FP_I_VBFA_DLV      Delivery data from VBFA
*      -->FP_I_LIKP          Delivery Header
*      -->FP_I_LIPS          Delivery Items
*      -->FP_I_BKPF          Accounting Document Header
*      -->FP_I_VBAP          Sales Document Items
*      -->FP_I_MKPF          Material Document Header
*      -->FP_I_VBRP          Invoice Items
*      <--FP_I_FINAL         Final Table for ALV
*----------------------------------------------------------------------*
FORM f_populate_final  USING    fp_i_vbreve    TYPE ty_t_vbreve
                                fp_i_vbfa_dlv  TYPE ty_t_vbfa_dlv
                                fp_i_likp      TYPE ty_t_likp
                                fp_i_lips      TYPE ty_t_lips
                                fp_i_bkpf      TYPE ty_t_bkpf
                                fp_i_vbap      TYPE ty_t_vbap
                                fp_i_mkpf      TYPE ty_t_mkpf
                                fp_i_vbrp      TYPE ty_t_vbrp
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
                                fp_i_vbrk      TYPE ty_t_vbrk
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
                       CHANGING fp_i_final     TYPE ty_t_final.

  TYPES : BEGIN OF lty_parvw,
           sign   TYPE char1, " Sign of type CHAR1
           option TYPE char2, " Option of type CHAR2
           low    TYPE parvw, " Partner Function
           high   TYPE parvw, " Partner Function
          END OF lty_parvw.

  TYPES : BEGIN OF lty_makt,
          matnr TYPE matnr,   " Material Number
          maktx TYPE maktx,   " Material Description (Short Text)
         END OF lty_makt,

         BEGIN OF lty_kna1,
           kunnr TYPE kunnr,  " Customer Number
           name1 TYPE name1,  " Name
        END OF lty_kna1,

        BEGIN OF lty_tvrot,
          route TYPE route,   " Route
          bezei TYPE bezei,   " Name of the controlling area
        END OF lty_tvrot,

        BEGIN OF lty_t001w,
          werks TYPE werks_d, " Plant
          name1 TYPE name1,   " Name
        END OF lty_t001w,
* Begin of Defect 7311
        BEGIN OF lty_vbpa,
         vbeln TYPE vbeln, " Sales and Distribution Document Number
         posnr TYPE posnr, " Item number of the SD document
         parvw TYPE parvw, " Partner Function
         kunnr TYPE kunnr, " Customer Number
        END OF lty_vbpa.
* End of Defect 7311
  CONSTANTS: lc_doctyp TYPE z_criteria  VALUE 'DOCTYPE'. " DocType

  DATA : li_vbreve  TYPE ty_t_vbreve, " Internal Table for VBREVE
         lwa_vbreve TYPE vbreve,      " WA for VBREVE
         lwa_final  TYPE ty_final,    " WA for I_FINAL
         lwa_vbap   TYPE ty_vbap,     " WA for VBAP
         lwa_bkpf   TYPE ty_bkpf,     " WA for BKPF
         lwa_likp   TYPE ty_likp,     " WA for LIKP
         lwa_mkpf   TYPE ty_mkpf,     " WA for MKPF
         lv_posnr   TYPE posnr,       " Item number of the SD document
         lwa_lips   TYPE ty_lips,
         lwa_vbrp   TYPE ty_vbrp,     " WA for VBRP
         li_vbrp    TYPE ty_t_vbrp,
         li_lips_tmp TYPE ty_t_lips,
* Begin of SCTASK0736901
         li_kna1 TYPE STANDARD TABLE OF lty_kna1,
         li_makt TYPE STANDARD TABLE OF lty_makt,
         li_tvrot TYPE STANDARD TABLE OF lty_tvrot,
         li_t001w TYPE STANDARD TABLE OF lty_t001w,
         li_vbpa  TYPE STANDARD TABLE OF lty_vbpa,
         li_parvw TYPE STANDARD TABLE OF lty_parvw,
         lwa_parvw TYPE lty_parvw,
         lwa_kna1 TYPE lty_kna1,
         lwa_t001w TYPE lty_t001w,
         lwa_tvrot TYPE lty_tvrot,
         lwa_makt  TYPE lty_makt,
         lwa_vbpa  TYPE lty_vbpa,
* End of SCTASK0736901
* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
         lwa_vbrk   TYPE ty_vbrk, " WA for VBRK
* <--- End   of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
* ---> Begin of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
         lv_index   TYPE sy-tabix, " Index of Internal Tables
* <--- End   of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
         lv_awkey   TYPE awkey. " Reference Key

* Begin of SCTASK0736901
* Begin of Defect 7311
  IF fp_i_vbap IS NOT INITIAL.
    MOVE 'I' TO lwa_parvw-sign.
    MOVE 'EQ' TO lwa_parvw-option.
    MOVE 'WE' TO lwa_parvw-low.
    APPEND lwa_parvw TO li_parvw.
    CLEAR lwa_parvw-low.
    MOVE 'AG' TO lwa_parvw-low.
    APPEND lwa_parvw TO li_parvw.
    SELECT vbeln posnr parvw kunnr FROM vbpa INTO TABLE li_vbpa
      FOR ALL ENTRIES IN fp_i_vbap WHERE vbeln EQ fp_i_vbap-vbeln
                                     and parvw in li_parvw.
*                                     AND parvw EQ 'WE'
*                                      OR parvw EQ 'AG'.
    IF sy-subrc EQ 0.
      SORT li_vbpa BY vbeln posnr parvw.
      DELETE ADJACENT DUPLICATES FROM li_vbpa COMPARING vbeln posnr parvw.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbap IS NOT INITIAL

  IF li_vbpa IS NOT INITIAL.
    SELECT kunnr name1 FROM kna1 INTO TABLE li_kna1
                 FOR ALL ENTRIES IN li_vbpa  WHERE kunnr = li_vbpa-kunnr.

    IF sy-subrc EQ 0.
      SORT li_kna1 BY kunnr.
      DELETE ADJACENT DUPLICATES FROM li_kna1 COMPARING kunnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_vbpa IS NOT INITIAL
* End of Defect 7311
  IF fp_i_likp IS NOT INITIAL.
    SELECT route bezei FROM tvrot INTO TABLE li_tvrot
                 FOR ALL ENTRIES IN fp_i_likp WHERE route = fp_i_likp-route.

    IF sy-subrc EQ 0.
      SORT li_tvrot BY route.
      DELETE ADJACENT DUPLICATES FROM li_tvrot COMPARING route.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_likp IS NOT INITIAL

  IF fp_i_vbap IS NOT INITIAL.
    SELECT matnr maktx FROM makt INTO TABLE li_makt
                 FOR ALL ENTRIES IN fp_i_vbap WHERE matnr = fp_i_vbap-matnr
* Language Harcoded as rerquested by NALLURI
                                                AND spras EQ 'E'.

    IF sy-subrc EQ 0.
      SORT li_makt BY matnr.
      DELETE ADJACENT DUPLICATES FROM li_makt COMPARING matnr.
    ENDIF. " IF sy-subrc EQ 0

    SELECT werks name1 FROM t001w INTO TABLE li_t001w
                 FOR ALL ENTRIES IN fp_i_vbap WHERE werks = fp_i_vbap-werks.

    IF sy-subrc EQ 0.
      SORT li_t001w BY werks.
      DELETE ADJACENT DUPLICATES FROM li_t001w COMPARING werks.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vbap IS NOT INITIAL
* End of SCTASK0736901

  li_vbreve[] = fp_i_vbreve[].
  li_lips_tmp = fp_i_lips.
  DELETE li_lips_tmp WHERE lfimg IS INITIAL.
  SORT li_lips_tmp BY vbeln uecha.

  SORT li_vbreve BY vbeln_n posnr_n.
  DELETE ADJACENT DUPLICATES FROM li_vbreve COMPARING vbeln_n posnr_n.
  SORT li_vbreve BY vbeln posnr vbtyp_n.
  SORT fp_i_vbrp BY vgbel vgpos.

  SORT fp_i_vbreve BY vbeln posnr.
*--------------------- MAIN LOOP ------------------------
  LOOP AT fp_i_vbreve INTO lwa_vbreve.

    CLEAR lv_posnr.
* Revenue Details from VBREVE
    MOVE-CORRESPONDING lwa_vbreve TO lwa_final.

* Delivery Details
    PERFORM f_get_delivery USING  lwa_vbreve
                                  fp_i_lips
                                  li_vbreve
                                  fp_i_likp
                                  fp_i_vbfa_dlv
                         CHANGING lwa_final-delnum
                                  lwa_final-delpos.

    IF lwa_final-delnum IS NOT INITIAL.
* Delivery Header Details
      READ TABLE fp_i_likp INTO lwa_likp
        WITH KEY vbeln = lwa_final-delnum
                 BINARY SEARCH.

      IF sy-subrc = 0.
        lwa_final-inco1     = lwa_likp-inco1.
        lwa_final-inco2     = lwa_likp-inco2.
        lwa_final-route     = lwa_likp-route.
*        lwa_final-kunnr     = lwa_likp-kunnr.
*        lwa_final-kunag     = lwa_likp-kunag.
        lwa_final-anzpk     = lwa_likp-anzpk.
        lwa_final-podat     = lwa_likp-podat.
        lwa_final-wadat_ist = lwa_likp-wadat_ist.
        lwa_final-tu_num    = lwa_likp-tu_num.

* Export Indicator
        IF i_enh_status IS NOT INITIAL.
          READ TABLE i_enh_status TRANSPORTING NO FIELDS
            WITH KEY criteria = lc_doctyp
                     sel_low  = lwa_likp-lfart.
          IF sy-subrc = 0.
            lwa_final-export = abap_true.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF i_enh_status IS NOT INITIAL
        CLEAR lwa_likp.
      ENDIF. " IF sy-subrc = 0

* Username for POD
      READ TABLE fp_i_mkpf INTO lwa_mkpf
        WITH KEY xblnr = lwa_final-delnum
                 BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-usnam = lwa_mkpf-usnam.
        CLEAR lwa_mkpf.
      ENDIF. " IF sy-subrc = 0

* Invoice Details
* ---> Begin of Delete for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
* Commented and Invoice details retrieved via revised logic below
*      READ TABLE fp_i_vbrp INTO lwa_vbrp
*        WITH KEY vgbel = lwa_final-delnum
*                 vgpos = lwa_final-delpos
*                 BINARY SEARCH.
*      IF sy-subrc = 0.
*        lwa_final-invnum  = lwa_vbrp-vbeln.
*        lwa_final-invpos  = lwa_vbrp-posnr.
*        CLEAR lwa_vbrp.
*      ENDIF. " IF sy-subrc = 0
* <--- End   of Delete for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018

* ---> Begin of Insert for D3_OTC_RDD_0123_FUT_Issue by U034334 on 31-May-2018
* Invoice Details
      READ TABLE fp_i_vbrp INTO lwa_vbrp
        WITH KEY vgbel = lwa_final-delnum
                 vgpos = lwa_final-delpos
                 BINARY SEARCH.
      IF sy-subrc NE 0.
        READ TABLE li_lips_tmp INTO lwa_lips
                   WITH KEY vbeln =  lwa_final-delnum
                            uecha =  lwa_final-delpos
                            BINARY SEARCH.
        IF sy-subrc = 0.
          lv_posnr = lwa_lips-posnr.
          READ TABLE fp_i_vbrp INTO lwa_vbrp
                WITH KEY vgbel = lwa_final-delnum
                         vgpos = lwa_lips-posnr
                BINARY SEARCH.
        ENDIF. " IF sy-subrc = 0

      ENDIF. " IF sy-subrc NE 0
      IF sy-subrc = 0.
        IF lv_posnr IS INITIAL.
          lv_posnr = lwa_final-delpos.
        ENDIF. " IF lv_posnr IS INITIAL
* ---> Begin of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
        CLEAR lv_index.
        lv_index = sy-tabix.
* Loop at all invoices to get the latest non-cancelled Invoice (vbtyp M)
        LOOP AT fp_i_vbrp INTO lwa_vbrp FROM lv_index.
          IF lwa_vbrp-vgbel NE lwa_final-delnum OR
             lwa_vbrp-vgpos NE lv_posnr.
            EXIT.
          ENDIF. " IF lwa_vbrp-vgbel NE lwa_final-delnum OR
* <--- End   of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
          READ TABLE fp_i_vbrk INTO lwa_vbrk
            WITH KEY vbeln = lwa_vbrp-vbeln
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_final-invnum  = lwa_vbrk-vbeln.
            lwa_final-invpos  = lwa_vbrp-posnr.
            CLEAR lwa_vbrk.
* ---> Begin of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
            EXIT.
* <--- End   of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
          ENDIF. " IF sy-subrc = 0
          CLEAR lwa_vbrp.
* ---> Begin of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
        ENDLOOP. " LOOP AT fp_i_vbrp INTO lwa_vbrp FROM lv_index
* <--- End   of Insert for D3_OTC_RDD_0123_Defect_5741 by U034334 on 11-Jul-2018
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF lwa_final-delnum IS NOT INITIAL

* Sales Doc Item Category and AAG for material
    READ TABLE fp_i_vbap INTO lwa_vbap
      WITH KEY vbeln = lwa_vbreve-vbeln
               posnr = lwa_vbreve-posnr
               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-pstyv = lwa_vbap-pstyv.
      lwa_final-ktgrm = lwa_vbap-ktgrm.
* Begin of SCTASK0736901
      lwa_final-matnr = lwa_vbap-matnr.
      lwa_final-werks = lwa_vbap-werks.
      lwa_final-mvgr1 = lwa_vbap-mvgr1.
* End of SCTASK0736901

* Begin of Defect 7311
      READ TABLE li_vbpa INTO lwa_vbpa WITH KEY vbeln = lwa_vbreve-vbeln
                                                posnr = lwa_vbreve-posnr
                                                parvw = 'WE' BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE lwa_vbpa-kunnr TO lwa_final-kunnr.
      ELSE. " ELSE -> IF sy-subrc EQ 0
        READ TABLE li_vbpa INTO lwa_vbpa WITH KEY vbeln = lwa_vbreve-vbeln
                                                  posnr = '000000'
                                                  parvw = 'WE' BINARY SEARCH.
        IF sy-subrc EQ 0.
          MOVE lwa_vbpa-kunnr TO lwa_final-kunnr.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
      CLEAR lwa_vbpa.
      READ TABLE li_vbpa INTO lwa_vbpa WITH KEY vbeln = lwa_vbreve-vbeln
                                                posnr = lwa_vbreve-posnr
                                                parvw = 'AG' BINARY SEARCH.
      IF sy-subrc EQ 0.
        MOVE lwa_vbpa-kunnr TO lwa_final-kunag.
      ELSE. " ELSE -> IF sy-subrc EQ 0
        READ TABLE li_vbpa INTO lwa_vbpa WITH KEY vbeln = lwa_vbreve-vbeln
                                                  posnr = '000000'
                                                  parvw = 'AG' BINARY SEARCH.
        IF sy-subrc EQ 0.
          MOVE lwa_vbpa-kunnr TO lwa_final-kunag.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF sy-subrc EQ 0
      CLEAR lwa_vbpa.
* End of Defect 7311
      CLEAR lwa_vbap.
    ENDIF. " IF sy-subrc = 0

* Accounting Document Details
    CONCATENATE lwa_vbreve-sammg lwa_vbreve-reffld INTO lv_awkey.
    READ TABLE fp_i_bkpf INTO lwa_bkpf
      WITH KEY awkey = lv_awkey
               BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-belnr     = lwa_bkpf-belnr.
      lwa_final-blart     = lwa_bkpf-blart.
      lwa_final-rev_budat = lwa_bkpf-budat.
*      lwa_final-awkey     = lwa_bkpf-awkey.
* Begin of Defect 7311
      lwa_final-dmbtr     = lwa_bkpf-kursf * lwa_final-wrbtr.
      lwa_final-kursf     = lwa_bkpf-kursf.
      lwa_final-hwaer     = lwa_bkpf-hwaer.
* End of Defect 7311
      CLEAR lwa_bkpf.
    ENDIF. " IF sy-subrc = 0

* Begin of SCTASK0736901
    CONCATENATE lwa_final-vbeln lwa_final-posnr INTO lwa_final-soline.
    CLEAR lwa_kna1.
    READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_final-kunnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE lwa_kna1-name1 TO lwa_final-name1.
    ENDIF. " IF sy-subrc EQ 0

    CLEAR lwa_kna1.
    READ TABLE li_kna1 INTO lwa_kna1 WITH KEY kunnr = lwa_final-kunag BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE lwa_kna1-name1 TO lwa_final-name2.
    ENDIF. " IF sy-subrc EQ 0
    CLEAR lwa_t001w.
    READ TABLE li_t001w INTO lwa_t001w WITH KEY werks = lwa_final-werks BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE lwa_t001w-name1 TO lwa_final-name3.
    ENDIF. " IF sy-subrc EQ 0

    CLEAR lwa_makt.
    READ TABLE li_makt INTO lwa_makt WITH KEY matnr = lwa_final-matnr BINARY SEARCH.
    IF sy-subrc EQ 0.
      MOVE lwa_makt-maktx TO lwa_final-maktx.
    ENDIF. " IF sy-subrc EQ 0
    CLEAR lwa_tvrot.
    READ TABLE li_tvrot INTO lwa_tvrot WITH KEY route = lwa_final-route.
    IF sy-subrc EQ 0.
      MOVE lwa_tvrot-bezei TO lwa_final-bezei.
    ENDIF. " IF sy-subrc EQ 0
* End of SCTASK0736901

* Append Records to final table
    APPEND lwa_final TO fp_i_final.

    CLEAR : lwa_final,
            lwa_vbreve.
  ENDLOOP. " LOOP AT fp_i_vbreve INTO lwa_vbreve

  IF fp_i_final IS NOT INITIAL.
    SORT fp_i_final BY vbeln posnr.
  ELSE. " ELSE -> IF fp_i_final IS NOT INITIAL
    MESSAGE i115. " No data found for input given on selection screen
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_final IS NOT INITIAL

  FREE : li_vbreve.
ENDFORM. " F_POPULATE_FINAL
*&---------------------------------------------------------------------*
*&      Form  F_GET_DELIVERY
*&---------------------------------------------------------------------*
*       Get Delivery number and item number
*----------------------------------------------------------------------*
*      -->FP_X_VBREVE        WA for VBREVE
*      -->FP_I_LIPS          Delivery Items
*      -->FP_I_VBREVE        Revenue Recognition
*      -->FP_I_LIKP          Delivery Header
*      -->FP_I_VBFA_DLV      Delivery data from VBFA
*      <--FP_DELNUM          Delivery Number
*      <--FP_DELPOS          Delivery Item Number
*----------------------------------------------------------------------*
FORM f_get_delivery  USING    fp_x_vbreve   TYPE vbreve    " Revenue Recognition: Revenue Recognition Lines
                              fp_i_lips     TYPE ty_t_lips
                              fp_i_vbreve   TYPE ty_t_vbreve
                              fp_i_likp     TYPE ty_t_likp
                              fp_i_vbfa_dlv TYPE ty_t_vbfa_dlv
                     CHANGING fp_delnum     TYPE vbeln_va  " Sales Document
                              fp_delpos     TYPE posnr_va. " Sales Document Item

  TYPES : BEGIN OF lty_delv,
            vbeln TYPE vbeln_va, " Sales Document
            posnr TYPE posnr_va, " Sales Document Item
            podat TYPE podat,    " Date (proof of delivery)
          END OF lty_delv.

  CONSTANTS : lc_j    TYPE char1    VALUE 'J', " J of type CHAR1
              lc_c    TYPE char1    VALUE 'C'. " C of type CHAR1

  DATA : li_delv      TYPE STANDARD TABLE OF lty_delv, " Internal table for Deliveries
         li_lips      TYPE ty_t_lips,                  " Internal table for LIPS
         lwa_delv     TYPE lty_delv,                   " WA for Deliveries
         lwa_lips     TYPE ty_lips,                    " Delivery items
         lwa_likp     TYPE ty_likp,                    " Delivery Header
         lwa_vbreve   TYPE vbreve,                     " Revenue Recognition: Revenue Recognition Lines
         lwa_vbfa_dlv TYPE ty_vbfa_dlv,                " Deliveries from VBFA
         lv_index     TYPE sy-tabix,                   " Index
         lv_counter   TYPE int4.                       " Loop Counter

  li_lips[] = fp_i_lips[].
* Delete the records where qty is zero
  DELETE li_lips WHERE lfimg IS INITIAL.

  CASE fp_x_vbreve-vbtyp_n.
    WHEN lc_j.
* 1) VBREVE records with VBTYP_N = J (Delivery)
      READ TABLE fp_i_lips INTO lwa_lips
        WITH KEY vbeln = fp_x_vbreve-vbeln_n
                 posnr = fp_x_vbreve-posnr_n
                 BINARY SEARCH.
      IF sy-subrc <> 0.
* Check for Batch Split Scenario
        READ TABLE fp_i_lips INTO lwa_lips
          WITH KEY vbeln = fp_x_vbreve-vbeln_n
                   uecha = fp_x_vbreve-posnr_n..
        IF sy-subrc = 0.
          fp_delnum = lwa_lips-vbeln.
          fp_delpos = lwa_lips-posnr.
        ENDIF. " IF sy-subrc = 0
      ELSE. " ELSE -> IF sy-subrc <> 0
        fp_delnum = lwa_lips-vbeln.
        fp_delpos = lwa_lips-posnr.
      ENDIF. " IF sy-subrc <> 0
      CLEAR lwa_lips.

    WHEN lc_c.
* 2a) Check VBREVE records with vbtyp_n = J
      READ TABLE fp_i_vbreve INTO lwa_vbreve
        WITH KEY vbeln   = fp_x_vbreve-vbeln_n
                 posnr   = fp_x_vbreve-posnr_n
                 vbtyp_n = lc_j BINARY SEARCH.
* BINARY SEARCH not used because it might return incorrect value for sy-tabix
      IF sy-subrc = 0.
        CLEAR lv_index.
        lv_index = sy-tabix.

* Collect all deliveries for one line item into an internal table
        LOOP AT fp_i_vbreve INTO lwa_vbreve FROM lv_index.
          IF lwa_vbreve-vbeln NE fp_x_vbreve-vbeln_n
             OR lwa_vbreve-posnr NE fp_x_vbreve-posnr_n
             OR lwa_vbreve-vbtyp_n NE lc_j.
            EXIT.
          ENDIF. " IF lwa_vbreve-vbeln NE fp_x_vbreve-vbeln_n

          lwa_delv-vbeln = lwa_vbreve-vbeln_n.
          lwa_delv-posnr = lwa_vbreve-posnr_n.
* Append POD Date along with delivery number (used later)
          READ TABLE fp_i_likp INTO lwa_likp
            WITH KEY vbeln = lwa_vbreve-vbeln_n
                     BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_delv-podat = lwa_likp-podat.
          ENDIF. " IF sy-subrc = 0

          APPEND lwa_delv TO li_delv.
          CLEAR : lwa_delv,
                  lwa_likp,
                  lwa_vbreve.
        ENDLOOP. " LOOP AT fp_i_vbreve INTO lwa_vbreve FROM lv_index

* For one delivery against one record
        IF lines( li_delv ) = 1.
          READ TABLE li_delv INTO lwa_delv INDEX 1.
          IF sy-subrc = 0.
            fp_delnum = lwa_delv-vbeln.
            fp_delpos = lwa_delv-posnr.
            CLEAR lwa_delv.
          ENDIF. " IF sy-subrc = 0

* 2b) For more than one delivery (say 4, where 3rd and 4th has qty non zero)
        ELSEIF lines( li_delv ) > 1.
          LOOP AT li_delv INTO lwa_delv.
            READ TABLE li_lips INTO lwa_lips
              WITH KEY vbeln = lwa_delv-vbeln
                       posnr = lwa_delv-posnr
                       BINARY SEARCH.
            IF sy-subrc <> 0.
              CONTINUE.
            ENDIF. " IF sy-subrc <> 0
            fp_delnum = lwa_lips-vbeln.
            fp_delpos = lwa_lips-posnr.
            lv_counter = lv_counter + 1.
            CLEAR : lwa_delv,
                    lwa_lips.
          ENDLOOP. " LOOP AT li_delv INTO lwa_delv

* 2c) If more than one deliveries remain after this step, check using VBREVE-REFFLD
          IF lv_counter > 1.
            CLEAR : fp_delnum,
                    fp_delpos,
                    lv_counter.
            LOOP AT li_delv INTO lwa_delv.
              READ TABLE fp_i_vbreve INTO lwa_vbreve
                WITH KEY reffld = lwa_delv-vbeln.
              IF sy-subrc <> 0.
                CONTINUE.
              ENDIF. " IF sy-subrc <> 0
              fp_delnum = lwa_lips-vbeln.
              fp_delpos = lwa_lips-posnr.
              lv_counter = lv_counter + 1.
              CLEAR : lwa_delv,
                      lwa_vbreve.
            ENDLOOP. " LOOP AT li_delv INTO lwa_delv

* 2d) Still if multiple deliveries found, sort by PODAT and take latest one
            IF lv_counter > 1.
              CLEAR lv_counter.
* Table can only be created inside the loop, so sorted inside the loop
              SORT li_delv BY podat DESCENDING.
              READ TABLE li_delv INTO lwa_delv INDEX 1.
              IF sy-subrc = 0.
                fp_delnum = lwa_delv-vbeln.
                fp_delpos = lwa_delv-posnr.
                CLEAR lwa_delv.
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF lv_counter > 1
          ENDIF. " IF lv_counter > 1
        ENDIF. " IF lines( li_delv ) = 1

* 3) If no record found in VBREVE with VBTYP_N = J
      ELSE. " ELSE -> IF sy-subrc = 0
        READ TABLE fp_i_vbfa_dlv INTO lwa_vbfa_dlv
          WITH KEY vbelv = fp_x_vbreve-vbeln_n
                   posnv = fp_x_vbreve-posnr_n
                   BINARY SEARCH.
* BINARY SEARCH not used, it might change the value of sy-tabix
        IF sy-subrc = 0.
          CLEAR : lv_index.
          lv_index = sy-tabix.

* Collect all deliveries for one line item into an internal table
          LOOP AT fp_i_vbfa_dlv INTO lwa_vbfa_dlv FROM lv_index.
            IF lwa_vbfa_dlv-vbelv NE fp_x_vbreve-vbeln_n OR
               lwa_vbfa_dlv-posnv NE fp_x_vbreve-posnr_n.
              EXIT.
            ENDIF. " IF lwa_vbfa_dlv-vbelv NE fp_x_vbreve-vbeln_n OR

            lwa_delv-vbeln = lwa_vbfa_dlv-vbeln.
            lwa_delv-posnr = lwa_vbfa_dlv-posnn.
* Append POD Date along with delivery number (used later)
            READ TABLE fp_i_likp INTO lwa_likp
              WITH KEY vbeln = lwa_vbfa_dlv-vbeln
                       BINARY SEARCH.
            IF sy-subrc = 0.
              lwa_delv-podat = lwa_likp-podat.
            ENDIF. " IF sy-subrc = 0

            APPEND lwa_delv TO li_delv.
            CLEAR : lwa_delv,
                    lwa_likp,
                    lwa_vbfa_dlv.
          ENDLOOP. " LOOP AT fp_i_vbfa_dlv INTO lwa_vbfa_dlv FROM lv_index

* For one delivery against one record
          IF lines( li_delv ) = 1.
            READ TABLE li_delv INTO lwa_delv INDEX 1.
            IF sy-subrc = 0.
              fp_delnum = lwa_delv-vbeln.
              fp_delpos = lwa_delv-posnr.
              CLEAR lwa_delv.
            ENDIF. " IF sy-subrc = 0

* For more than one delivery (say 4 where 3rd and 4th has qty non zero)
          ELSEIF lines( li_delv ) > 1.
            SORT li_delv BY podat DESCENDING.
            READ TABLE li_delv INTO lwa_delv INDEX 1.
            IF sy-subrc = 0.
              fp_delnum = lwa_delv-vbeln.
              fp_delpos = lwa_delv-posnr.
              CLEAR lwa_delv.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lines( li_delv ) = 1
        ENDIF. " IF sy-subrc = 0
        CLEAR lwa_vbreve.
      ENDIF. " IF sy-subrc = 0

    WHEN OTHERS.
  ENDCASE.

  FREE : li_delv,
         li_lips.
ENDFORM. " F_GET_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       Prepare ALV Field Catalogue
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat .

  PERFORM f_update_fieldcat USING :
        'VBELN'            'I_FINAL'     'Sales Ord'(005),
        'POSNR'            'I_FINAL'     'Sales Doc Item'(006),
        'SAKRV'            'I_FINAL'     'G/L A/C'(007),
        'BDJPOPER'         'I_FINAL'     'Posting Period'(008),
        'POPUPO'           'I_FINAL'     'Period Sub-Item'(009),
        'VBELN_N'          'I_FINAL'     'Follow-On Doc'(010),
        'POSNR_N'          'I_FINAL'     'Follow-On Doc Item'(011),
        'WRBTR'            'I_FINAL'     'Amt in Doc Curr'(012),
        'RVAMT'            'I_FINAL'     'Revenue Amt'(013),
        'WAERK'            'I_FINAL'     'Crncy'(014),
        'ACCPD'            'I_FINAL'     'Accrual Period'(015),
        'VBTYP_N'          'I_FINAL'     'Doc Category of Subs. Doc'(016),
        'PAOBJNR'          'I_FINAL'     'Profitability Segment'(017),
        'PRCTR'            'I_FINAL'     'Profit Center'(018),
        'SAKDR'            'I_FINAL'     'A/C for Deferred Revenues'(019), " Select Deferred Tax
        'SAKUR'            'I_FINAL'     'A/C for Unbilled Recv'(020),
        'GSBER'            'I_FINAL'     'Business Area'(021),
        'BUKRS'            'I_FINAL'     'Company Code'(022),
        'BEMOT'            'I_FINAL'     'Accounting Indicator'(023),
        'SAMMG'            'I_FINAL'     'Group'(024),
        'REFFLD'           'I_FINAL'     'FI Doc Ref'(025),
        'RRSTA'            'I_FINAL'     'Revenue Determination Status'(026),
        'KUNAG'            'I_FINAL'     'Sold-to'(027),
        'PS_PSP_PNR'       'I_FINAL'     'WBS Element'(028),
        'VBELV'            'I_FINAL'     'Originating Document'(029),
        'POSNV'            'I_FINAL'     'Originating Item'(030),
        'AUFNR'            'I_FINAL'     'Order No'(031),
        'KOSTL'            'I_FINAL'     'Cost Center'(032),
        'KSTAT'            'I_FINAL'     'Condition used for statistics'(033),
        'ERDAT'            'I_FINAL'     'Record Created'(034),
        'ERZET'            'I_FINAL'     'Entry Time'(035),
        'BUDAT'            'I_FINAL'     'Posting Date'(036),
        'REVFIX'           'I_FINAL'     'Fixed Revenue Line Indicator'(037),
        'REVVBTYP_SOURCE'  'I_FINAL'     'Doc Category of Subs. Doc'(016),
        'REVEVTYP'         'I_FINAL'     'Revenue Event Type'(038),
        'REVEVDOCN'        'I_FINAL'     'Revenue Event Doc'(039),
        'REVEVDOCNI'       'I_FINAL'     'Revenue Event Item'(040),
        'REVEVDAT'         'I_FINAL'     'Revenue Event Date'(041),
        'REVPOBLCK'        'I_FINAL'     'Revenue Posting Block'(042),
        'DMBTR'            'I_FINAL'     'Amt in Locl Curr'(043),
        'RVAMT_LC'         'I_FINAL'     'Rev Amt in 1stLocl Cur'(044),
        'HWAER'            'I_FINAL'     'Local Currency'(045),
        'KRUEK'            'I_FINAL'     'Relevant for Accrual'(046),
        'COSTREC'          'I_FINAL'     'Relevant for Cost Recognition'(047), " CO Object: Price Totals
        'INVNUM'           'I_FINAL'     'Invoice'(048),
        'INVPOS'           'I_FINAL'     'Invoice Item'(049),
        'DELNUM'           'I_FINAL'     'Delivery'(050),
        'DELPOS'           'I_FINAL'     'Delivery Item'(051),
        'INCO1'            'I_FINAL'     'Inco1'(052),
        'INCO2'            'I_FINAL'     'Incoterms (Part 2)'(053),
        'ROUTE'            'I_FINAL'     'Route'(054),
        'KUNNR'            'I_FINAL'     'Ship-to'(055),
        'ANZPK'            'I_FINAL'     'Packages in Delivery'(056),
        'PODAT'            'I_FINAL'     'POD Date'(057),
        'WADAT_IST'        'I_FINAL'     'Actual Goods Mvmnt Date'(058),
        'USNAM'            'I_FINAL'     'POD by User'(059),
        'BELNR'            'I_FINAL'     'Acc Doc'(060),
        'BLART'            'I_FINAL'     'DocTyp'(061),
        'REV_BUDAT'        'I_FINAL'     'Revenue Posting Date'(062),
        'AWKEY'            'I_FINAL'     'Reference Key'(063),
        'PSTYV'            'I_FINAL'     'SO Item Category'(064),
        'KTGRM'            'I_FINAL'     'Mat AAG'(065),
        'EXPORT'           'I_FINAL'     'Export'(066),
        'SOLINE'           'I_FINAL'     'Sales Order & Line Item'(101),
        'NAME1'           'I_FINAL'     'Sold To Customer Name'(102),
        'NAME2'           'I_FINAL'     'Ship To Customer Name'(103),
        'MATNR'           'I_FINAL'     'Material Number'(104),
        'MAKTX'           'I_FINAL'     'Material Description'(105),
        'WERKS'           'I_FINAL'     'Plant'(106),
        'NAME3'           'I_FINAL'     'Plant Description'(107),
        'MVGR1'           'I_FINAL'     'Mat Grp1'(108),
        'BEZEI'           'I_FINAL'     'Route Description'(109),
        'TU_NUM'           'I_FINAL'     'TU'(067),
        'KURSF'            'i_FINAL'    'Exchange Rate'(135).
ENDFORM. " F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_FIELDCAT
*&---------------------------------------------------------------------*
*       Populate the Field Catalogue
*----------------------------------------------------------------------*
*      -->FP_FIELDNAME     Field name
*      -->FP_TABNAME       Table name
*      -->FP_SELTEXT       Field Label
*----------------------------------------------------------------------*
FORM f_update_fieldcat    USING fp_fieldname  TYPE slis_fieldname " Field Name
                                fp_tabname    TYPE slis_tabname   " Table Name
                                fp_seltext    TYPE scrtext_l.     " Long Field Label

  CONSTANTS : lc_wrbtr    TYPE slis_fieldname VALUE 'WRBTR',
              lc_rvamt    TYPE slis_fieldname VALUE 'RVAMT',
              lc_dmbtr    TYPE slis_fieldname VALUE 'DMBTR',
              lc_rvamt_lc TYPE slis_fieldname VALUE 'RVAMT_LC',
              lc_waerk    TYPE slis_fieldname VALUE 'WAERK',
              lc_hwaer    TYPE slis_fieldname VALUE 'HWAER',
              lc_prctr    TYPE slis_fieldname VALUE 'PRCTR',
              lc_sakdr    TYPE slis_fieldname VALUE 'SAKDR',
              lc_sakur    TYPE slis_fieldname VALUE 'SAKUR',
              lc_kunag    TYPE slis_fieldname VALUE 'KUNAG',
              lc_invnum   TYPE slis_fieldname VALUE 'INVNUM',
              lc_kunnr    TYPE slis_fieldname VALUE 'KUNNR'.

  DATA lwa_fieldcat TYPE slis_fieldcat_alv. " WA for Field Catalogue

* Column position
  gv_col_pos             = gv_col_pos + 1.
  lwa_fieldcat-col_pos   = gv_col_pos.
* Field Name
  lwa_fieldcat-fieldname = fp_fieldname.
* Table name
  lwa_fieldcat-tabname   = fp_tabname.
* Column Heading
  lwa_fieldcat-seltext_l = fp_seltext.

* For Currency fields, we need to pass the reference field as well.
  IF fp_fieldname = lc_wrbtr OR
     fp_fieldname = lc_rvamt.
    lwa_fieldcat-cfieldname = lc_waerk.
  ENDIF. " IF fp_fieldname = lc_wrbtr OR
  IF fp_fieldname = lc_dmbtr OR
      fp_fieldname = lc_rvamt_lc.
    lwa_fieldcat-cfieldname = lc_hwaer.
  ENDIF. " IF fp_fieldname = lc_dmbtr OR

* Suppress Leading Zeros
  IF fp_fieldname = lc_prctr OR
     fp_fieldname = lc_sakdr OR
     fp_fieldname = lc_sakur OR
     fp_fieldname = lc_kunag OR
     fp_fieldname = lc_invnum OR
     fp_fieldname = lc_kunnr.
    lwa_fieldcat-edit_mask = '==ALPHA'.
  ENDIF. " IF fp_fieldname = lc_prctr OR

  APPEND lwa_fieldcat TO i_fieldcat.
  CLEAR lwa_fieldcat.

ENDFORM. " F_UPDATE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*       ALV Output Display
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT     Field Catalogue table
*      -->FP_I_FINAL        Final table
*----------------------------------------------------------------------*
FORM f_display_output  USING fp_i_fieldcat TYPE slis_t_fieldcat_alv
                             fp_i_final    TYPE ty_t_final.

  IF rb_onlin = abap_true AND sy-batch IS INITIAL.
* ALV List for Presentation Server Foreground Run
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = fp_i_fieldcat
        i_save             = 'A'
      TABLES
        t_outtab           = fp_i_final
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE i132. " Issue in ALV display
    ENDIF. " IF sy-subrc <> 0

  ELSEIF rb_onlin = abap_true AND sy-batch IS NOT INITIAL.

* ALV List Display for Presentation Server Background Run
    CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
      EXPORTING
        i_callback_program = sy-repid
        it_fieldcat        = fp_i_fieldcat
      TABLES
        t_outtab           = fp_i_final
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
    IF sy-subrc <> 0.
      MESSAGE i132. " Issue in ALV display
    ENDIF. " IF sy-subrc <> 0

* ALV file for Application Server
  ELSEIF rb_backg = abap_true.
* Write the output to Application Server
    PERFORM f_write_file USING fp_i_final.
    IF sy-subrc = 0.
      MESSAGE s952. " Records are successfully posted to application server
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF rb_onlin = abap_true AND sy-batch IS INITIAL
ENDFORM. " F_DISPLAY_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_FILE
*&---------------------------------------------------------------------*
*       Write the Output List to Application Server file
*----------------------------------------------------------------------*
*      -->FP_I_FINAL       Final Internal Table
*----------------------------------------------------------------------*
FORM f_write_file  USING   fp_i_final TYPE ty_t_final.

* Local Data
  DATA: lv_data        TYPE string,     " Output data string
        lwa_final      TYPE ty_final,   " WA for final table
        lv_wrbtr       TYPE char16,     " Wrbtr of type CHAR16
        lv_rvamt       TYPE char22,     " Rvamt of type CHAR22
        lv_waerk       TYPE char5,      " Waerk of type CHAR5
        lv_accpd       TYPE char16,     " Accpd of type CHAR16
        lv_revevdat    TYPE char10,     " Revevdat of type CHAR10
        lv_dmbtr       TYPE char16,     " Dmbtr of type CHAR16
        lv_rvamt_lc    TYPE char22,     " Rvamt_lc of type CHAR22
        lv_hwaer       TYPE char5,      " Hwaer of type CHAR5
        lv_erdat       TYPE char10,     " Erdat of type CHAR10
        lv_erzet       TYPE char10,     " Erzet of type CHAR10
        lv_budat       TYPE char10,     " Budat of type CHAR10
        lv_podat       TYPE char10,     " Podat of type CHAR10
        lv_wadat_ist   TYPE char10,     " Wadat_ist of type CHAR10
        lv_rev_budat   TYPE char10,     " Rev_budat of type CHAR10
        lv_file        TYPE fileextern. " Physical file name
  CONSTANTS : lc_tab   TYPE char1    VALUE cl_abap_char_utilities=>horizontal_tab. " Tab Delimiter
  CONSTANTS: lc_act  TYPE char5 VALUE 'WRITE'. " Act of type Character

  lv_file = p_afile.
*  Authorization for writing to dataset
  CALL FUNCTION 'AUTHORITY_CHECK_DATASET'
    EXPORTING
      activity         = lc_act
      filename         = lv_file
    EXCEPTIONS
      no_authority     = 1
      activity_unknown = 2
      OTHERS           = 3.

  IF sy-subrc <> 0.
    MESSAGE i918 WITH p_afile. "  Error in opening the file &
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

* Open file for writing the records
  OPEN DATASET p_afile FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " Output type
  IF sy-subrc <> 0.
    MESSAGE i967 WITH p_afile. "  Error in opening the file &
  ELSE. " ELSE -> IF sy-subrc <> 0
* Begin of SCTASK0736901
* Create the Header Line
*    CONCATENATE 'Sales Order'(005)
*                'Sales Order Line Item'(068)
*                'G/L Account Number'(007)
*                'Posting Period'(069)
*                'Prd Sub-item'(070)
*                'Follow-On Doc'(010)
*                'Follow-on DocItm'(071)
*                'Amt in Doc Curr'(012)
*                'Revenue Amt'(013)
*                'Crncy'(014)
*                'Accrual Period'(015)
*                'Subs Doc Cat'(072)
*                'Profit Seg'(073)
*                'Profit Ctr'(074)
*                'Def Rev A/C'(075)
*                'Unbil Recv A/C'(076)
*                'BusAr'(077)
*                'Company Code'(078)
*                'AccInd'(079)
*                'Revenue Batch Group ID'(024)
*                'FI Doc Ref'(025)
*                'RevDet Stat'(080)
*                'Sold-to'(027)
*                'WBS Elmt'(081)
*                'Orig Doc'(082)
*                'Orig Itm'(083)
*                'Order No'(031)
*                'Cost Ctr'(084)
*                'Stat Cond'(085)
*                'Rev record creation date'(086)
*                'Revenue Recognition Entry Time'(035)
*                'Revenue Posting Date'(036)
*                'FixRev'(003)
*                'Subs Doc Cat'(072)
*                'RevEvTyp'(087)
*                'RevEv Doc'(088)
*                'RevEv Itm'(089)
*                'RevEv Date'(090)
*                'RevPost Blck'(091)
*                'Amt in Locl Curr'(043)
*                'Rev Amt in 1stLocl Cur'(044)
*                'LoclCurr'(092)
*                'Accr Relv'(093)
*                'CostRec Relv'(094)
*                'Invoice'(048)
*                'Invoice Line Item'(095)
*                'Delivery Number'(050)
*                'Delivery Line Item'(096)
*                'Incoterm'(052)
*                'Incoterm Description'(097)
*                'Route'(054)
*                'Ship-to'(055)
*                'Pkg in Dlv'(098)
*                'Actual POD Date'(057)
*                'Actual PGI Date'(099)
*                'POD by User'(059)
*                'Rev Recognition Document'(060)
*                'Document Type'(061)
*                'Revenue Posting Date'(100)
*                'Reference Key'(063)
*                'Item Category'(002)
*                'AAG'(065)
*                'Export'(066)
*                'Sales Order & Line Item'(101)
*                'Sold To Customer Name'(102)
*                'Ship To Customer Name'(103)
*                'Material Number'(104)
*                'Material Description'(105)
*                'Plant'(106)
*                'Plant Description'(107)
*                'Mat Grp1'(108)
*                'Route Description'(109)
*                'TU number'(067)
*
*           INTO lv_data
*   SEPARATED BY lc_tab.

    CONCATENATE 'CoCode'(078)
                'Sales Order & Line Item'(101)
                'Sales Order'(005)
                'Sales Order Line Item'(068)
                'Sold-to'(027)
                'Sold To Customer Name'(102)
                'Ship-to'(055)
                'Ship To Customer Name'(103)
                'Material Number'(104)
                'Material Description'(105)
                'Plant'(106)
                'Plant Description'(107)
                'Profit Ctr'(074)
                'Item Category'(002)
                'Mat Grp1'(108)
                'AAG'(065)
                'Amt in Doc Curr'(012)
                'Revenue Amt'(013)
                'Crncy'(014)
* Begin of Defect 7311
                'Amt in Locl Curr'(043)
                'Local Currency'(045)
                'Exchange Rate'(135)
* End of Defect 7311
                'Accrual Period'(015)
                'Invoice'(048)
                'Invoice Line Item'(095)
                'Delivery Number'(050)
                'Delivery Line Item'(096)
                'Incoterm'(052)
                'Incoterm Description'(097)
                'Route'(054)
                'Route Description'(109)
                'Actual POD Date'(057)
                'Actual PGI Date'(099)
                'POD by User'(059)
                'Pkg in Dlv'(098)
                'Rev Recognition Document'(060)
                'Document Type'(061)
                'Revenue Posting Date'(100)
                'RevDet Stat'(080)
                'Follow-On Doc'(010)
                'Follow-on DocItm'(071)
                'G/L Account Number'(007)
                'Posting Period'(069)
                'Def Rev A/C'(075)
                'Unbil Recv A/C'(076)
                'Revenue Batch Group ID'(024)
                'FI Doc Ref'(025)
                'Revenue Posting Date'(100)
                'Export'(066)
                'TU number'(067)
           INTO lv_data
   SEPARATED BY lc_tab.


* End of SCTASK0736901
    TRANSFER lv_data TO p_afile.
    CLEAR lv_data.

* Pass the ALV output data
    LOOP AT fp_i_final INTO lwa_final.

* Convert Amount/Currency Fields to CHAR
      WRITE :  lwa_final-wrbtr    TO lv_wrbtr    CURRENCY lwa_final-waerk,
               lwa_final-rvamt    TO lv_rvamt    CURRENCY lwa_final-waerk,
               lwa_final-waerk    TO lv_waerk,
               lwa_final-accpd    TO lv_accpd,
               lwa_final-dmbtr    TO lv_dmbtr    CURRENCY lwa_final-hwaer,
               lwa_final-hwaer    TO lv_hwaer.
* Begin of SCTASK0736901
*               lwa_final-rvamt_lc TO lv_rvamt_lc CURRENCY lwa_final-hwaer,

* End of SCTASK0736901
* Condense the amount fields
      CONDENSE: lv_wrbtr,
                lv_rvamt,
                lv_accpd,
                lv_dmbtr,
                lv_rvamt_lc.

* Write Date/Time fields in user format
      WRITE :
* Begin of SCTASK0736901
*              lwa_final-erdat     TO lv_erdat,
*              lwa_final-erzet     TO lv_erzet,
*              lwa_final-revevdat  TO lv_revevdat,
* End of SCTASK0736901
              lwa_final-budat     TO lv_budat,
              lwa_final-podat     TO lv_podat,
              lwa_final-wadat_ist TO lv_wadat_ist,
              lwa_final-rev_budat TO lv_rev_budat.
* Begin of SCTASK0736901
*      CONCATENATE lwa_final-vbeln
*                  lwa_final-posnr
*                  lwa_final-sakrv
*                  lwa_final-bdjpoper
*                  lwa_final-popupo
*                  lwa_final-vbeln_n
*                  lwa_final-posnr_n
*                  lv_wrbtr
*                  lv_rvamt
*                  lv_waerk
*                  lv_accpd
*                  lwa_final-vbtyp_n
*                  lwa_final-paobjnr
*                  lwa_final-prctr
*                  lwa_final-sakdr
*                  lwa_final-sakur
*                  lwa_final-gsber
*                  lwa_final-bukrs
*                  lwa_final-bemot
*                  lwa_final-sammg
*                  lwa_final-reffld
*                  lwa_final-rrsta
*                  lwa_final-kunag
*                  lwa_final-ps_psp_pnr
*                  lwa_final-vbelv
*                  lwa_final-posnv
*                  lwa_final-aufnr
*                  lwa_final-kostl
*                  lwa_final-kstat
*                  lv_erdat
*                  lv_erzet
*                  lv_budat
*                  lwa_final-revfix
*                  lwa_final-revvbtyp_source
*                  lwa_final-revevtyp
*                  lwa_final-revevdocn
*                  lwa_final-revevdocni
*                  lv_revevdat
*                  lwa_final-revpoblck
*                  lv_dmbtr
*                  lv_rvamt_lc
*                  lv_hwaer
*                  lwa_final-kruek
*                  lwa_final-costrec
*                  lwa_final-invnum
*                  lwa_final-invpos
*                  lwa_final-delnum
*                  lwa_final-delpos
*                  lwa_final-inco1
*                  lwa_final-inco2
*                  lwa_final-route
*                  lwa_final-kunnr
*                  lwa_final-anzpk
*                  lv_podat
*                  lv_wadat_ist
*                  lwa_final-usnam
*                  lwa_final-belnr
*                  lwa_final-blart
*                  lv_rev_budat
*                  lwa_final-awkey
*                  lwa_final-pstyv
*                  lwa_final-ktgrm
*                  lwa_final-export
*                  lwa_final-soline
*                  lwa_final-name1
*                  lwa_final-name2
*                  lwa_final-matnr
*                  lwa_final-maktx
*                  lwa_final-werks
*                  lwa_final-name3
*                  lwa_final-mvgr1
*                  lwa_final-bezei
*                  lwa_final-tu_num
*             INTO lv_data
*     SEPARATED BY lc_tab.

      CONCATENATE       lwa_final-bukrs
                        lwa_final-soline
                        lwa_final-vbeln
                        lwa_final-posnr
                        lwa_final-kunag
                        lwa_final-name2
                        lwa_final-kunnr
                        lwa_final-name1
                        lwa_final-matnr
                        lwa_final-maktx
                        lwa_final-werks
                        lwa_final-name3
                        lwa_final-prctr
                        lwa_final-pstyv
                        lwa_final-mvgr1
                        lwa_final-ktgrm
                        lv_wrbtr
                        lv_rvamt
                        lv_waerk
* Begin of Defect 7311
                        lv_dmbtr
                        lv_hwaer
                        lwa_final-kursf
* End of Defect 7311
                        lv_accpd
                        lwa_final-invnum
                        lwa_final-invpos
                        lwa_final-delnum
                        lwa_final-delpos
                        lwa_final-inco1
                        lwa_final-inco2
                        lwa_final-route
                        lwa_final-bezei
                        lv_podat
                        lv_wadat_ist
                        lwa_final-usnam
                        lwa_final-anzpk
                        lwa_final-belnr
                        lwa_final-blart
                        lv_rev_budat
                        lwa_final-rrsta
                        lwa_final-vbeln_n
                        lwa_final-posnr_n
                        lwa_final-sakrv
                        lwa_final-bdjpoper
                        lwa_final-sakdr
                        lwa_final-sakur
                        lwa_final-sammg
                        lwa_final-reffld
                        lv_rev_budat
                        lwa_final-export
                        lwa_final-tu_num
                   INTO lv_data
           SEPARATED BY lc_tab.
* End of SCTASK0736901
* Transfer the data into application server file
      TRANSFER lv_data TO p_afile.
      CLEAR : lv_data,
              lwa_final,
              lv_wrbtr,
              lv_rvamt,
              lv_waerk,
              lv_accpd,
              lv_dmbtr,
              lv_rvamt_lc,
              lv_hwaer,
              lv_podat,
              lv_wadat_ist,
              lv_rev_budat.
    ENDLOOP. " LOOP AT fp_i_final INTO lwa_final
  ENDIF. " IF sy-subrc <> 0
  CLOSE DATASET p_afile.

ENDFORM. "f_write_file
