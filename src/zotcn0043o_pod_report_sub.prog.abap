************************************************************************
* PROGRAM    :  ZOTCR0043O_POD_REPORT                                  *
* TITLE      :  OTC_RDD_0043_Comprehensive POD Report                  *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0043_Comprehensive POD Report                    *
*----------------------------------------------------------------------*
* DESCRIPTION: This report contains the POD relevant information which *
*              will improve the Business operations and will address to*
*              the issue of not automatically generated PODs.          *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 26-FEB-14  SMUKHER   E1DK912803  INITIAL DEVELOPMENT( CR#1149)       *
* 25-MAR-14  SMUKHER   E1DK912803  HPQC Defect 1149                    *
* 09-APR-14  SMUKHER   E1DK912803  ADDITIONAL CHANGES ON CR#1149       *
* 13-MAY-14  SMUKHER   E1DK913409  ADDITION OF NEW FIELD 'SALES OFFICE'*
* 17-JUL-14  SMUKHER   E1DK913409  ADDITION OF DATE LIMIT RANGE ON BACK*
*                                  -GROUND MODE.                       *
* 10-SEP-14  SMUKHER   E1DK913409  PERFORMANCE ENHANCEMENT FOR POD REPO*
*                                  -RT                                 *
* 06-OCT-14  SMUKHER   E1DK913409  ADDITIONAL CHANGES ON DELIVERY NUMBE*
*                                  -R AND ACTUAL PGI DATE              *
* 15-JAN-16  SMUKHER   E2DK916680  Defect# 1440 : The POD Report not wo*
*                                  -rking correctly when Delivery creat*
*                                  -ed through Purchase Order.         *
* 29-MAY-17  U034229   E1DK928313  Defect# 2933: 1)Actual PGI date and *
*                                  Sales organization as mandatory     *
*                                  field.                              *
*                                  2) Profit Center, Serial Number     *
*                                  Profile & POD Date are added in the *
*                                  output.                             *
*                                  3) Sales Org, Dist.Channel, Div,    *
*                                  Del.Type are made as range.         *
*                                  4) Performance Tuning.              *
* 13-Jul-17  U034229   E1DK929131  Defect# 3179 1) Cost column should  *
*                                  be replaced with MBEW-STPRS field.  *
*                                  2) Non-POD relevant shipments should*
*                                  check the PGI Status in POD Report. *
*                                  3) Item Category field is added in  *
*                                  the output.                         *
*                                  4) Multiple Handaling Units issue   *
*                                  need to be solved.                  *
*                                  5) Incorporating the standard ALV   *
*                                  output functionality in PF status.  *
* 29-Aug-17  ASK   E1DK930275  Defect# 3399 1) Cost column logic should*
*                                   be reset to old logic from KONV    *
*----------------------------------------------------------------------*
* 27-Nov-17 SMUKHER4 E1DK932720  Defect# 4308: Report not selecting the*
*                                POD relevant deliveries without HUs   *
* 10-Jul-18 U103565 E1DK937670  Defect #6638 1) Addition of new fields *
*                                       Higher Level HU,Tracking Number*
*                                       ESS carrier delivery date      *
*                                       Planned Carrier delivery date  *
*                                       Transit time from route        *
*                                       Installable delivery flag      *
*                                       Customer Acceptance date       *
*                                       Error Message                  *
*                                    2) "POD Relevant" is changed to   *
*                                     "Pending POD" on selection screen*
*21-Aug-2018 AMOHAPA E1DK937670 Defect#6638_FUT Issue:1) Incorrect     *
*                               Higher level HU is displaying          *
*                               2)Incorrect ESS carrier date is showing*
*12-Sep-2018 AMOHAPA E1DK937670 Defect#6638_FUT_Issue:1) Planned       *
*                               carrier date is not showing properly   *
*                               2)Filter is not working on Transit time*
*                               3)Actual PGI date is refreshed with    *
*                                 incorrect values clicking back       *
*04-Oct-2018 U103061  E1DK938976 Defect# 7261: We can’t run            *
*                                ZOTC_POD_REPORT_Tcode for comprenhesiv*
*                                POD report if user default decimal    *
*                                is space.                             *
*----------------------------------------------------------------------*
* 23/08/2019  U106341                 HANAtization changes
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*       For POD relevant radio button, the Actual PGI Date is editable
*----------------------------------------------------------------------*
FORM f_modify_screen .

* If any one of the additional parameters is provided to the selection screen
* then the selection screen changes to display mode

  CONSTANTS: lc_vbeln_low TYPE char40 VALUE  'S_VBELN-LOW',  " s_vbeln_low
             lc_vbeln_high TYPE char40 VALUE 'S_VBELN-HIGH', " s_vbeln_high
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
             lc_wadat_ist_low TYPE char40 VALUE 'S_PGI_AC-LOW',   " s_pgi_ac-low
             lc_wadat_ist_high TYPE char40 VALUE 'S_PGI_AC-HIGH', " s_pgi_ac-high
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
             lc_input TYPE char1 VALUE '0', " no value
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
             lc_req TYPE char1 VALUE '1'. " Req of type CHAR1
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017


  IF s_venum IS NOT INITIAL OR
     s_vbelnp IS NOT INITIAL OR
     s_vbelns IS NOT INITIAL.
    LOOP AT SCREEN .
      IF screen-name EQ lc_vbeln_low OR
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        screen-name EQ  lc_wadat_ist_low OR
        screen-name EQ  lc_wadat_ist_high OR "22-APR-14
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        screen-name EQ  lc_vbeln_high.
        screen-input = lc_input.
        MODIFY SCREEN.
      ENDIF. " IF screen-name EQ lc_vbeln_low OR
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF s_venum IS NOT INITIAL OR
**&& -- BOC : ADDITIONAL CHANGES ON DELIVERY NUMBER AND ACTUAL PGI DATE : SMUKHER : 06-OCT-14
  IF rb_conf = abap_true AND s_vbeln IS NOT INITIAL.
    LOOP AT SCREEN .
      IF screen-name  EQ lc_wadat_ist_low OR
          screen-name EQ  lc_wadat_ist_high.
        screen-input = lc_input.
        MODIFY SCREEN.
      ENDIF. " IF screen-name EQ lc_wadat_ist_low OR
    ENDLOOP. " LOOP AT SCREEN
  ENDIF. " IF rb_conf = abap_true AND s_vbeln IS NOT INITIAL
**&& -- EOC : ADDITIONAL CHANGES ON DELIVERY NUMBER AND ACTUAL PGI DATE : SMUKHER : 06-OCT-14
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*&--To make the selection options high field as mandatory.
  LOOP AT SCREEN.
    IF screen-name EQ lc_wadat_ist_high.
      screen-required = lc_req.
      MODIFY SCREEN.
    ENDIF. " IF screen-name EQ lc_wadat_ist_high
  ENDLOOP. " LOOP AT SCREEN
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
  IF s_venum IS INITIAL AND
      s_vbelnp IS INITIAL AND
      s_vbelns IS INITIAL AND
      gv_flag = abap_true.

    REFRESH: s_vbeln,
             s_pgi_ac.
    CLEAR gv_flag.
  ENDIF. " IF s_venum IS INITIAL AND
ENDFORM. " F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ADDITIONAL_DATA
*&---------------------------------------------------------------------*
*  Only one of the additional parameters can be provided to the selection
*  screen at a time.
*----------------------------------------------------------------------*
FORM f_check_additional_data .

  DATA: lv_counter TYPE int4 . "counter
* The user can check records coresponding to only one additional parameter
* at a time.
  IF s_venum IS NOT INITIAL.
    lv_counter = lv_counter + 1.
  ENDIF. " IF s_venum IS NOT INITIAL
  IF s_vbelnp IS NOT INITIAL.
    lv_counter = lv_counter + 1.
  ENDIF. " IF s_vbelnp IS NOT INITIAL
  IF s_vbelns IS NOT INITIAL.
    lv_counter = lv_counter + 1.
  ENDIF. " IF s_vbelns IS NOT INITIAL
  IF lv_counter > 1.
    MESSAGE i975.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF lv_counter > 1

ENDFORM. " F_CHECK_ADDITIONAL_DATA
*&---------------------------------------------------------------------*
*&      Form  F_GET_HU_DELIVERY
*&---------------------------------------------------------------------*
* Check for Handling Unit Delivery,then the selected deliveries and their
* corresponding actual PGI date gets automatically populated in the
* Delivery Number field and the Actual PGI date in selection screen itself.
*----------------------------------------------------------------------*
*      <--FP_I_HU_VBELN   internal table
*----------------------------------------------------------------------*
FORM f_get_hu_delivery. "  CHANGING fp_i_hu_vbeln TYPE psi_we_selopt_tt.

  TYPES: BEGIN OF lty_vekp,
          venum TYPE venum,          " Internal Handling Unit Number
         END OF lty_vekp,

         BEGIN OF lty_vepo,
           vbeln TYPE vbeln,         " Delivery Number
         END OF lty_vepo,

         BEGIN OF lty_likp,
           wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
         END OF lty_likp.

  DATA: li_venum TYPE STANDARD TABLE OF lty_vekp INITIAL SIZE 0,    " local internal table
        li_hu_vbeln TYPE STANDARD TABLE OF lty_vepo INITIAL SIZE 0, " local internal table
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        li_hu_date TYPE STANDARD TABLE OF lty_likp INITIAL SIZE 0,   " Local internal table
        lwa_hu_date TYPE LINE OF ty_r_wadat_ist,                     " local work area
        li_hu_vbeln1 TYPE STANDARD TABLE OF lty_vepo INITIAL SIZE 0, " local internal table
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        lwa_hu_vbeln TYPE selopt. "local work area

  CONSTANTS: lc_sign TYPE char1 VALUE 'I',    " Integer
             lc_option TYPE char4 VALUE 'EQ'. "Equal to

  FIELD-SYMBOLS: <lfs_hu_vbeln> TYPE lty_vepo, " field symbol
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
                 <lfs_hu_date> TYPE lty_likp. " field symbol
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
  IF s_venum IS NOT INITIAL.
    SELECT venum " Handling Unit Number
      FROM vekp  " Handling Unit - Header Table
      INTO TABLE li_venum
      WHERE exidv IN s_venum.
    IF sy-subrc IS INITIAL.

      SELECT vbeln " Delivery Number
        FROM vepo  " Packing: Handling Unit Item (Contents)
        INTO TABLE li_hu_vbeln
        FOR ALL ENTRIES IN li_venum
        WHERE venum = li_venum-venum.
      IF sy-subrc IS INITIAL.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Deleting duplicate entries.
        li_hu_vbeln1[] = li_hu_vbeln.
        SORT li_hu_vbeln1 BY vbeln.
        DELETE ADJACENT DUPLICATES FROM li_hu_vbeln1 COMPARING vbeln.

        IF li_hu_vbeln1 IS NOT INITIAL.
          SELECT wadat_ist " Actual Goods Movement Date
            FROM likp      " SD Document: Delivery Header Data
            INTO TABLE li_hu_date
            FOR ALL ENTRIES IN li_hu_vbeln1
            WHERE vbeln = li_hu_vbeln1-vbeln.
          IF sy-subrc IS INITIAL.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            gv_flag = abap_true. " setting the flag

            REFRESH i_hu_vbeln[].
            LOOP AT li_hu_vbeln ASSIGNING <lfs_hu_vbeln>.
              lwa_hu_vbeln-sign = lc_sign.
              lwa_hu_vbeln-option = lc_option.
              lwa_hu_vbeln-low = <lfs_hu_vbeln>-vbeln.
              APPEND lwa_hu_vbeln TO i_hu_vbeln.
              CLEAR lwa_hu_vbeln.
            ENDLOOP. " LOOP AT li_hu_vbeln ASSIGNING <lfs_hu_vbeln>
            UNASSIGN <lfs_hu_vbeln>.
            REFRESH s_vbeln.
            APPEND LINES OF i_hu_vbeln TO s_vbeln.

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            REFRESH i_hu_date[].
            LOOP AT li_hu_date ASSIGNING <lfs_hu_date>.
              lwa_hu_date-sign = lc_sign.
              lwa_hu_date-option = lc_option.
              lwa_hu_date-low = <lfs_hu_date>-wadat_ist.
              APPEND lwa_hu_date TO i_hu_date.
              CLEAR lwa_hu_date.
            ENDLOOP. " LOOP AT li_hu_date ASSIGNING <lfs_hu_date>
            UNASSIGN <lfs_hu_date>.
            REFRESH s_pgi_ac.
            APPEND LINES OF i_hu_date TO s_pgi_ac.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            MODIFY SCREEN.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_hu_vbeln1 IS NOT INITIAL
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF s_venum IS NOT INITIAL

ENDFORM. " F_GET_HU_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  F_GET_PO_DELIVERY
*&---------------------------------------------------------------------*
* Check for Purchase Order Delivery,then the selected deliveries and the
* actual PGI date gets automatically populated in the Delivery Number
* and Actual PGI Date field in selection screen itself.
*----------------------------------------------------------------------*
*      <--FP_I_PO_VBELN    internal table
*----------------------------------------------------------------------*
FORM f_get_po_delivery. "  CHANGING fp_i_po_vbeln TYPE psi_we_selopt_tt.

  TYPES: BEGIN OF lty_vbkd,
          vbeln TYPE vbeln,          "Sales and Distribution Document Number
         END OF lty_vbkd,

         BEGIN OF lty_lips,
           vbeln TYPE vbeln_vl,      "Delivery Number
         END OF lty_lips,

         BEGIN OF lty_likp,
           wadat_ist TYPE wadat_ist, " Actual PGI Date
         END OF lty_likp.

  CONSTANTS: lc_vbeln_sign TYPE char1 VALUE 'I',    " Integer
             lc_posnr TYPE posnr VALUE '000000',    " Item Number
             lc_vbeln_option TYPE char4 VALUE 'EQ'. " Equal To

  DATA: li_vbeln TYPE STANDARD TABLE OF lty_vbkd INITIAL SIZE 0,    " local internal table
        li_po_vbeln TYPE STANDARD TABLE OF lty_lips INITIAL SIZE 0, " local internal table
        lwa_po_vbeln TYPE selopt,                                   " local work area
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        li_po_vbeln1 TYPE STANDARD TABLE OF lty_lips INITIAL SIZE 0, "local internal table.
        li_po_date TYPE STANDARD TABLE OF lty_likp INITIAL SIZE 0,   " local internal table
        lwa_po_date TYPE LINE OF ty_r_wadat_ist.                     " local work area
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

  FIELD-SYMBOLS: <lfs_po_vbeln> TYPE lty_lips, " field symbol
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
                 <lfs_po_date> TYPE lty_likp. " field symbol
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

  IF s_vbelnp IS NOT INITIAL.
    SELECT vbeln " Sales and Distribution Document Number
      FROM vbkd  " Sales Document: Business Data
      INTO TABLE li_vbeln
      WHERE posnr = lc_posnr
      AND   bstkd IN s_vbelnp.
    IF sy-subrc IS INITIAL.

      SELECT vbeln " Delivery
        FROM lips  " SD document: Delivery: Item data
        INTO TABLE li_po_vbeln
        FOR ALL ENTRIES IN li_vbeln
        WHERE vgbel = li_vbeln-vbeln.
      IF sy-subrc IS INITIAL.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Deleting the duplicate entries.
        li_po_vbeln1[] = li_po_vbeln[].
        SORT li_po_vbeln BY vbeln.
*&-- Begin of Changes for HANAtization on OTC_RDD_0043 by U106341 on 22-Aug-2019 in E1SK901449
        SORT li_po_vbeln1 BY vbeln.
*&-- End of Changes for HANAtization on OTC_RDD_0043 by U106341 on 22-Aug-2019 in E1SK901449
        DELETE ADJACENT DUPLICATES FROM li_po_vbeln1 COMPARING vbeln.

        IF li_po_vbeln1 IS NOT INITIAL.
          SELECT wadat_ist "Actual PGI Date
            FROM likp      " SD Document: Delivery Header Data
            INTO TABLE li_po_date
            FOR ALL ENTRIES IN li_po_vbeln1
            WHERE vbeln = li_po_vbeln1-vbeln.
          IF sy-subrc IS INITIAL.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            gv_flag = abap_true. " setting the flag

            REFRESH i_po_vbeln[].
            LOOP AT li_po_vbeln ASSIGNING <lfs_po_vbeln>.
              lwa_po_vbeln-sign = lc_vbeln_sign.
              lwa_po_vbeln-option = lc_vbeln_option.
              lwa_po_vbeln-low = <lfs_po_vbeln>-vbeln.
              APPEND lwa_po_vbeln TO i_po_vbeln.
              CLEAR lwa_po_vbeln.
            ENDLOOP. " LOOP AT li_po_vbeln ASSIGNING <lfs_po_vbeln>
            UNASSIGN <lfs_po_vbeln>.
            REFRESH s_vbeln.
            APPEND LINES OF i_po_vbeln TO s_vbeln.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            REFRESH i_po_date[].
            LOOP AT li_po_date ASSIGNING <lfs_po_date>.
              lwa_po_date-sign = lc_vbeln_sign.
              lwa_po_date-option = lc_vbeln_option.
              lwa_po_date-low = <lfs_po_date>-wadat_ist.
              APPEND lwa_po_date TO i_po_date.
              CLEAR lwa_po_date.
            ENDLOOP. " LOOP AT li_po_date ASSIGNING <lfs_po_date>
            UNASSIGN <lfs_po_date>.
            REFRESH s_pgi_ac.
            APPEND LINES OF i_po_date TO s_pgi_ac.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            MODIFY SCREEN.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_po_vbeln1 IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF s_vbelnp IS NOT INITIAL
ENDFORM. " F_GET_PO_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  F_GET_SO_DELIVERY
*&---------------------------------------------------------------------*
* Check for Sales Order Delivery,then the selected deliveries and the
* actual PGI Date gets automatically populated in the Delivery Number
* and Actual PGI Date field in selection screen itself.
*----------------------------------------------------------------------*
*      <--FP_I_SO_VBELN  internal table
*----------------------------------------------------------------------*
FORM f_get_so_delivery. "  CHANGING fp_i_so_vbeln TYPE psi_we_selopt_tt.

  TYPES: BEGIN OF lty_lips,
          vbeln TYPE vbeln_vl, "Delivery Number(Item)
         END OF lty_lips,

         BEGIN OF lty_likp,
          vbeln TYPE vbeln_vl, "Delivery Number(Header)
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          wadat_ist TYPE wadat_ist, " Actual PGI Date
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
         END OF lty_likp.

  CONSTANTS: lc_vbeln_sign TYPE char1 VALUE 'I',  " Integer
           lc_vbeln_option TYPE char4 VALUE 'EQ'. " Equal To

  DATA: li_lips_vbeln TYPE STANDARD TABLE OF lty_lips INITIAL SIZE 0, " local internal table
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        li_lips_vbeln1 TYPE STANDARD TABLE OF lty_lips INITIAL SIZE 0, "local internal table.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
        li_likp_vbeln TYPE STANDARD TABLE OF lty_likp INITIAL SIZE 0, " local internal table
        lwa_likp_vbeln TYPE selopt,                                   " local work area
        lwa_likp_wadat_ist TYPE LINE OF ty_r_wadat_ist.               " local work area

  FIELD-SYMBOLS: <lfs_likp_vbeln> TYPE lty_likp. " field symbol

  IF s_vbelns IS NOT INITIAL.
    SELECT vbeln " Delivery Number
      FROM lips  " SD document: Delivery: Item data
      INTO TABLE li_lips_vbeln
      WHERE vgbel IN s_vbelns.
    IF sy-subrc IS INITIAL.

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Deleting duplicate entries.
      li_lips_vbeln1[] = li_lips_vbeln[].
      SORT li_lips_vbeln1 BY vbeln.
      DELETE ADJACENT DUPLICATES FROM li_lips_vbeln1 COMPARING vbeln.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

      IF li_lips_vbeln1 IS NOT INITIAL.
        SELECT vbeln "Delivery Number
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
               wadat_ist " Actual PGI Date
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          FROM likp
          INTO TABLE li_likp_vbeln
          FOR ALL ENTRIES IN li_lips_vbeln1
          WHERE vbeln = li_lips_vbeln1-vbeln.
        IF sy-subrc IS INITIAL.
          gv_flag = abap_true. " setting the flag

          REFRESH i_so_vbeln[].
          REFRESH i_so_date[].
          LOOP AT li_likp_vbeln ASSIGNING <lfs_likp_vbeln>.
            lwa_likp_vbeln-sign = lc_vbeln_sign.
            lwa_likp_vbeln-option = lc_vbeln_option.
            lwa_likp_vbeln-low = <lfs_likp_vbeln>-vbeln.
            APPEND lwa_likp_vbeln TO i_so_vbeln.
            CLEAR lwa_likp_vbeln.

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            lwa_likp_wadat_ist-sign = lc_vbeln_sign.
            lwa_likp_wadat_ist-option = lc_vbeln_option.
            lwa_likp_wadat_ist-low = <lfs_likp_vbeln>-wadat_ist.
            APPEND lwa_likp_wadat_ist TO i_so_date.
            CLEAR lwa_likp_wadat_ist.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

          ENDLOOP. " LOOP AT li_likp_vbeln ASSIGNING <lfs_likp_vbeln>
          UNASSIGN <lfs_likp_vbeln>.
          REFRESH s_vbeln.
          APPEND LINES OF i_so_vbeln TO s_vbeln.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          REFRESH s_pgi_ac.
          APPEND LINES OF i_so_date TO s_pgi_ac.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          MODIFY SCREEN.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF li_lips_vbeln1 IS NOT INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF s_vbelns IS NOT INITIAL
ENDFORM. " F_GET_SO_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_ZOTC_PRC_CONTROL
*&---------------------------------------------------------------------*
* Here we retrieve data from ZOTC_PRC_CONTROL table.
*----------------------------------------------------------------------*
FORM f_retrieve_zotc_prc_control .

  TYPES: BEGIN OF lty_zotc_prc_control,
         mprogram TYPE program,           "Program Name
         mparameter TYPE enhee_parameter, " Parameter Name
         mvalue1 TYPE z_mvalue_low,       " Value-Low
**&& --  BOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
         zz_comments TYPE z_comments, " Comments
**&& --  EOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
         END OF lty_zotc_prc_control.

  CONSTANTS: lc_vkorg TYPE vkorg VALUE '1000',                     " Sales Organization
             lc_vtweg TYPE vtweg VALUE '10',                       " Division
             lc_prog TYPE programm VALUE 'ZOTCR0043O_POD_REPORT',  " Program name
             lc_parameter1 TYPE enhee_parameter VALUE 'WADAT_IST', " Parameter
**&& --  BOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
             lc_1 TYPE char1 VALUE '1', " Value 1 for foreground
             lc_2 TYPE char2 VALUE '2', " Value 2 for background
**&& --  EOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
             lc_parameter2 TYPE enhee_parameter VALUE 'KSCHL', " Parameter
             lc_parameter3 TYPE enhee_parameter VALUE 'BSCHL'. " Parameter

  DATA: li_zotc_prc_control TYPE STANDARD TABLE OF lty_zotc_prc_control INITIAL SIZE 0. " internal table

  FIELD-SYMBOLS: <lfs_zotc_prc_control> TYPE lty_zotc_prc_control,  " field symbol
                 <lfs_zotc_prc_control1> TYPE lty_zotc_prc_control, " field symbol
                 <lfs_zotc_prc_control2> TYPE lty_zotc_prc_control. " field symbol

* Storing the value of the date range difference in a local variable.
  gv_days = s_pgi_ac-high - s_pgi_ac-low.

  SELECT mprogram       " ABAP Program Name
         mparameter     " Parameter
         mvalue1        " Select Options: Value Low
         zz_comments    " Comments
  FROM zotc_prc_control " OTC Process Team Control Table
  INTO TABLE li_zotc_prc_control
  WHERE vkorg = lc_vkorg
    AND vtweg = lc_vtweg
    AND mprogram = lc_prog
    AND mparameter IN (lc_parameter1 , lc_parameter2 , lc_parameter3)
    AND mactive = abap_true.

  IF sy-subrc IS INITIAL.
    SORT li_zotc_prc_control BY mparameter
                                zz_comments.
    READ TABLE li_zotc_prc_control ASSIGNING <lfs_zotc_prc_control> WITH KEY mparameter = lc_parameter1
**&& --  BOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
                                                                             zz_comments = lc_1
**&& --  EOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
                                                                                          BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE <lfs_zotc_prc_control>-mvalue1 TO gv_value_forgrnd.
    ENDIF. " IF sy-subrc IS INITIAL
    UNASSIGN <lfs_zotc_prc_control>.

**&& --  EOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER
    READ TABLE li_zotc_prc_control ASSIGNING <lfs_zotc_prc_control> WITH KEY mparameter = lc_parameter1
                                                                             zz_comments = lc_2
                                                                                          BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE <lfs_zotc_prc_control>-mvalue1 TO gv_value_backgr.
    ENDIF. " IF sy-subrc IS INITIAL
    UNASSIGN <lfs_zotc_prc_control>.
**&& --  EOC : ADDITION OF DATE LIMIT RANGE ON BACKGROUND MODE : 17-JUL-14 : SMUKHER

    READ TABLE li_zotc_prc_control ASSIGNING <lfs_zotc_prc_control1> WITH KEY mparameter = lc_parameter2
                                                                                           BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE <lfs_zotc_prc_control1>-mvalue1 TO gv_kschl.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE li_zotc_prc_control ASSIGNING <lfs_zotc_prc_control2> WITH KEY mparameter = lc_parameter3
                                                                                           BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      MOVE <lfs_zotc_prc_control2>-mvalue1 TO gv_bschl.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL
  UNASSIGN <lfs_zotc_prc_control1>.
  UNASSIGN <lfs_zotc_prc_control2>.
ENDFORM. " F_VALIDATE_S_PGI_AC
*&---------------------------------------------------------------------*
*&      Form  f_validate_p_vkorg
*&---------------------------------------------------------------------*
*       Validating the Sales Organization
*----------------------------------------------------------------------*
FORM f_validate_p_vkorg.

  DATA: lv_vkorg TYPE vkorg. "Sales Organization

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*  SELECT SINGLE vkorg " Sales Organization
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

* Perform Validation for Sales Organization.
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-20
  SELECT vkorg UP TO 1 ROWS " Sales Organization
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
    FROM tvko " Organizational Unit: Sales Organizations
    BYPASSING BUFFER
    INTO lv_vkorg
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*    WHERE vkorg = p_vkorg.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
    WHERE vkorg IN s_vkorg.
  ENDSELECT.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

  IF sy-subrc NE 0.
    CLEAR lv_vkorg.
* Sales Organization is not valid.
    MESSAGE e984. "Sales Organization is invalid
  ENDIF. " IF sy-subrc NE 0


ENDFORM. " F_VALIDATE_P_VKORG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_P_VTWEG
*&---------------------------------------------------------------------*
*  Validating the Distribution Channel
*----------------------------------------------------------------------*
FORM f_validate_p_vtweg.

  DATA: lv_vtweg TYPE vtweg. "Distribution Channel
*<--- Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*  SELECT SINGLE vtweg " Distribution Channel
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*<--- Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
  SELECT vtweg UP TO 1 ROWS " Distribution Channel
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
  FROM tvtw " Organizational Unit: Distribution Channels
  BYPASSING BUFFER
  INTO lv_vtweg
*---> Begin of delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*    WHERE vtweg = p_vtweg.
*<--- End of delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
   WHERE vtweg IN s_vtweg.
  ENDSELECT.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

  IF sy-subrc NE 0.
    CLEAR lv_vtweg.
* Distribution Channel is not valid.
    MESSAGE e985. "Distribution Channel is invalid
  ENDIF. " IF sy-subrc NE 0

ENDFORM. " F_VALIDATE_P_VTWEG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_P_SPART
*&---------------------------------------------------------------------*
*  Validating the Division
*----------------------------------------------------------------------*
FORM f_validate_p_spart.

  DATA: lv_spart TYPE spart. " Division

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*  SELECT SINGLE spart " Division
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
  SELECT spart UP TO 1 ROWS " Division
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
  FROM tspa " Organizational Unit: Sales Divisions
  BYPASSING BUFFER
  INTO lv_spart
*---> Begin of delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*    WHERE spart = p_spart.
*<--- End of delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
    WHERE spart IN s_spart.
  ENDSELECT.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

  IF sy-subrc NE 0.
    CLEAR lv_spart.
* Division is not valid.
    MESSAGE e986. "Division is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_P_SPART
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_WERKS
*&---------------------------------------------------------------------*
*  Validating the Plant
*----------------------------------------------------------------------*
FORM f_validate_s_werks.
  SELECT werks " Plant
    FROM t001w " Plants/Branches
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_werks
    WHERE werks IN s_werks.
  ENDSELECT.
  IF sy-subrc NE 0.
* Plant is not valid.
    MESSAGE e987. "Plant is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_WERKS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VBELN
*&---------------------------------------------------------------------*
*  Validating the Delivery Number
*----------------------------------------------------------------------*
FORM f_validate_s_vbeln.
  SELECT vbeln " Delivery
    FROM likp  " SD Document: Delivery Header Data
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_vbeln
    WHERE vbeln IN s_vbeln.
  ENDSELECT.
  IF sy-subrc NE 0.
* Delivery Number is not valid.
    MESSAGE e988. "Delivery Number is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_VBELN
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_P_LFART
*&---------------------------------------------------------------------*
*  Validating the Delivery Type
*----------------------------------------------------------------------*
FORM f_validate_p_lfart.

  DATA: lv_lfart TYPE lfart. "Delivery Type

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*  SELECT SINGLE lfart " Delivery Type
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
  SELECT lfart UP TO 1 ROWS " Delivery Type
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

  FROM tvlk " Delivery Types
  BYPASSING BUFFER
  INTO lv_lfart
*---> Begin of delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
*    WHERE lfart = p_lfart.
*<--- End of delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
  WHERE lfart IN s_lfart.
  ENDSELECT.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017

  IF sy-subrc NE 0.
    CLEAR lv_lfart.
* Delivery Type is not valid.
    MESSAGE e989. "Delivery Type is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_P_LFART
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_ROUTE
*&---------------------------------------------------------------------*
*  Validating the Route
*----------------------------------------------------------------------*
FORM f_validate_s_route.
  SELECT route " Actual delivery route
    FROM trolz " Routes: Determination in Deliveries
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_route
    WHERE route IN s_route.
  ENDSELECT.
  IF sy-subrc NE 0.
* Route is not valid.
    MESSAGE e990. "Route is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_ROUTE
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VSBED
*&---------------------------------------------------------------------*
*  Validating the Shipping Condition
*----------------------------------------------------------------------*
FORM f_validate_s_vsbed.
  SELECT vsbed " Shipping Conditions
    FROM tvsb  " Shipping Conditions
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_vsbed
    WHERE vsbed IN s_vsbed.
  ENDSELECT.
  IF sy-subrc NE 0.
* Shipping Condition is not valid.
    MESSAGE e991. "Shipping Condition is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_VSBED
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_KUNNR
*&---------------------------------------------------------------------*
*  Validating the Ship-to-Party
*----------------------------------------------------------------------*
FORM f_validate_s_kunnr.
  SELECT kunnr " Customer Number
    FROM kna1  " General Data in Customer Master
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_kunnr
    WHERE kunnr IN s_kunnr.
  ENDSELECT.
  IF sy-subrc NE 0.
* Ship-to-Party is not valid
    MESSAGE e992. "Ship-to-Party is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_KUNNR
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_KUNAG
*&---------------------------------------------------------------------*
*  Validating the Sold-to-Party
*----------------------------------------------------------------------*
FORM f_validate_s_kunag.
  SELECT kunnr " Customer Number
    FROM kna1  " General Data in Customer Master
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_kunnr
    WHERE kunnr IN s_kunag.
  ENDSELECT.
  IF sy-subrc NE 0.
* Sold-to-Party is not valid.
    MESSAGE e993. "Sold-to-Party is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_KUNAG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VENUM
*&---------------------------------------------------------------------*
*  Validating the Handling Unit Number
*----------------------------------------------------------------------*
FORM f_validate_s_venum.
  SELECT exidv " External Handling Unit Identification
    FROM vekp  " Handling Unit - Header Table
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_venum
    WHERE exidv IN s_venum.
  ENDSELECT.
  IF sy-subrc NE 0.
* Handling Unit Number is not valid.
    MESSAGE e982. "Handling Unit Number is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_VENUM
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VBELNP
*&---------------------------------------------------------------------*
*  Validating the Purchase Order Number
*----------------------------------------------------------------------*
FORM f_validate_s_vbelnp.
  SELECT bstkd " Customer purchase order number
    FROM vbkd  " Sales Document: Business Data
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_vbelnp
    WHERE bstkd IN s_vbelnp.
  ENDSELECT.
  IF sy-subrc NE 0.
* Purchase Order Number is not valid.
    MESSAGE e994. "Purchase Order Number is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_VBELNP
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VBELNS
*&---------------------------------------------------------------------*
*  Validating the Sales Order Number
*----------------------------------------------------------------------*
FORM f_validate_s_vbelns.
  SELECT vbeln " Sales Document
    FROM vbak  " Sales Document: Header Data
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_vbelns
    WHERE vbeln IN s_vbelns.
  ENDSELECT.
  IF sy-subrc NE 0.
* Sales Order Number is not valid.
    MESSAGE e980. "Sales Order Number is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_VBELNS
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_LIKP
*&---------------------------------------------------------------------*
*       Retrieve data from likp
*----------------------------------------------------------------------*
*      <--FP_I_LIKP changing  internal table i_likp                    *
*----------------------------------------------------------------------*
FORM f_retrieve_from_likp  CHANGING fp_i_likp TYPE ty_t_likp.

  SELECT vbeln " Delivery
         erdat " Created on
         vkorg " Sales Organization
         lfart " Delivery Type
         wadat " Planned goods movement date
         inco1 " Incoterms(Part 1)
         inco2 " Incoterms(Part 2)
         route " Route
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
         knfak "Factory calendar
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
         vsbed     " Shipping Conditions
         kunnr     " Ship-to party
         kunag     " Sold-to party
         waerk     " Currency
         wadat_ist " Actual Goods Movement Date
         podat     " Date(Proof Of Delivery)
    FROM likp      " SD Document: Delivery Header Data
    INTO TABLE fp_i_likp
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*&--The following WHERE clause fields are deleted for performance tuning
*    WHERE vbeln IN s_vbeln
*    AND   wadat IN s_pgi_pn
*    AND   route IN s_route
*    AND   vsbed IN s_vsbed
*    AND   kunnr IN s_kunnr
*    AND   kunag IN s_kunag
*    AND   wadat_ist IN s_pgi_ac.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Inser for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
     WHERE vkorg IN s_vkorg
     AND   wadat_ist IN s_pgi_ac
     AND   vbeln IN s_vbeln.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

  IF sy-subrc IS INITIAL.
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*    IF p_vkorg IS NOT INITIAL.
*      DELETE fp_i_likp WHERE vkorg <> p_vkorg.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
    IF s_pgi_pn IS NOT INITIAL.
      DELETE fp_i_likp WHERE wadat NOT IN s_pgi_pn.
    ENDIF. " IF s_pgi_pn IS NOT INITIAL
    IF s_route IS NOT INITIAL.
      DELETE fp_i_likp WHERE route NOT IN s_route.
    ENDIF. " IF s_route IS NOT INITIAL
    IF s_vsbed IS NOT INITIAL.
      DELETE fp_i_likp WHERE vsbed NOT IN s_vsbed.
    ENDIF. " IF s_vsbed IS NOT INITIAL
    IF s_kunnr IS NOT INITIAL.
      DELETE fp_i_likp WHERE kunnr NOT IN s_kunnr.
    ENDIF. " IF s_kunnr IS NOT INITIAL
    IF s_kunag IS NOT INITIAL.
      DELETE fp_i_likp WHERE kunag NOT IN s_kunag.
    ENDIF. " IF s_kunag IS NOT INITIAL
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*    ENDIF. " IF s_vkorg IS NOT INITIAL
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
*    IF p_lfart IS NOT INITIAL.
*      DELETE fp_i_likp WHERE lfart <> p_lfart.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
    IF s_lfart IS NOT INITIAL.
      DELETE fp_i_likp WHERE lfart NOT IN s_lfart.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 08-Jun-2017
    ENDIF. " IF s_lfart IS NOT INITIAL
**&& -- Check if i_likp[] is empty.
    IF fp_i_likp[] IS INITIAL.
 "Data not found.
      MESSAGE i981.
      LEAVE LIST-PROCESSING.
    ELSE. " ELSE -> IF fp_i_likp[] IS INITIAL
      SORT fp_i_likp BY vbeln.
    ENDIF. " IF fp_i_likp[] IS INITIAL
  ELSE. " ELSE -> IF sy-subrc IS INITIAL
 "Data not found.
    MESSAGE i981.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc IS INITIAL

ENDFORM. " F_RETRIEVE_FROM_LIKP
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_KNA1
*&---------------------------------------------------------------------*
*       retrieve data from KNA1 table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  internal table i_likp
*      <--FP_I_KNA1  internal table i_kna1
*----------------------------------------------------------------------*
FORM f_retrieve_from_kna1  USING    fp_i_likp TYPE ty_t_likp
                           CHANGING fp_i_kna1 TYPE ty_t_kna1.

  DATA: li_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0, "local internal table
        li_r_kunnr TYPE RANGE OF kunnr INITIAL SIZE 0,         "range table
        lwa_kunnr LIKE LINE OF li_r_kunnr.                     "work area

  CONSTANTS: lc_sign TYPE char1 VALUE 'I',      " Integer
               lc_option TYPE char2 VALUE 'EQ'. " Equal to

  FIELD-SYMBOLS: <lfs_likp> TYPE ty_likp. " Field-symbol

  li_likp[] = fp_i_likp[].
  SORT li_likp BY kunnr
                  kunag.
  DELETE ADJACENT DUPLICATES FROM li_likp COMPARING kunnr
                                                    kunag.

  LOOP AT li_likp ASSIGNING <lfs_likp>.
    lwa_kunnr-sign = lc_sign.
    lwa_kunnr-option = lc_option.
    lwa_kunnr-low = <lfs_likp>-kunnr.
    APPEND lwa_kunnr TO li_r_kunnr.
    CLEAR lwa_kunnr.
    lwa_kunnr-sign = lc_sign.
    lwa_kunnr-option = lc_option.
    lwa_kunnr-low = <lfs_likp>-kunag.
    APPEND lwa_kunnr TO li_r_kunnr.
    CLEAR lwa_kunnr.
  ENDLOOP. " LOOP AT li_likp ASSIGNING <lfs_likp>
  UNASSIGN <lfs_likp>.

  SORT li_r_kunnr BY low.
  DELETE ADJACENT DUPLICATES FROM li_r_kunnr COMPARING low.

*&&-- Get data from KNA1-NAME1
  SELECT kunnr " Customer Number
         name1 " Name 1
  FROM kna1    " General Data in Customer Master
  INTO TABLE fp_i_kna1
  WHERE kunnr IN li_r_kunnr.

  IF sy-subrc EQ 0.
    SORT fp_i_kna1 BY kunnr.
  ENDIF. " IF sy-subrc EQ 0

ENDFORM. " F_RETRIEVE_FROM_KNA1
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_TVSBT
*&---------------------------------------------------------------------*
*       retrieve data from TVSBT table.
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  internal table i_likp
*      <--FP_I_TVSBT  internal table i_tvsbt
*----------------------------------------------------------------------*
FORM f_retrieve_from_tvsbt  USING    fp_i_likp TYPE ty_t_likp
                            CHANGING fp_i_tvsbt TYPE ty_t_tvsbt.

  DATA: li_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0. " Local internal table

  li_likp[] = fp_i_likp[].
  SORT li_likp BY vsbed.
  DELETE ADJACENT DUPLICATES FROM li_likp COMPARING vsbed.

  IF NOT li_likp[] IS INITIAL.
    SELECT spras " Language Key
           vsbed " Shipping Conditions
           vtext " Description of the shipping condition
    FROM tvsbt   " Shipping Conditions: Texts
    INTO TABLE fp_i_tvsbt
    FOR ALL ENTRIES IN li_likp
    WHERE spras = sy-langu
    AND   vsbed = li_likp-vsbed.

    IF sy-subrc EQ 0.
      SORT fp_i_tvsbt BY vsbed.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_likp[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_TVSBT
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_TVROT
*&---------------------------------------------------------------------*
*       retrieve data from TVROT table.
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  internal table i_likp
*      <--FP_I_TVROT internal table i_tvrot
*----------------------------------------------------------------------*
FORM f_retrieve_from_tvrot  USING    fp_i_likp TYPE ty_t_likp
                            CHANGING fp_i_tvrot TYPE ty_t_tvrot.

  DATA: li_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0. " local internal table

  li_likp[] = fp_i_likp[].
  SORT li_likp BY route.
  DELETE ADJACENT DUPLICATES FROM li_likp COMPARING route.

  IF NOT li_likp[] IS INITIAL.
    SELECT spras             " Language Key
           route             "  Route
           bezei             "  Description of Route
    FROM tvrot               " Routes: Texts
    INTO TABLE fp_i_tvrot
    FOR ALL ENTRIES IN li_likp
      WHERE spras = sy-langu "lc_lang
      AND   route = li_likp-route.

    IF sy-subrc EQ 0.
      SORT fp_i_tvrot BY route.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_likp[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_TVROT
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_LIPS
*&---------------------------------------------------------------------*
*       retrieve data from LIPS table.
*----------------------------------------------------------------------*
*      <--FP_I_LIKP  internal table i_likp
*      <--FP_I_LIPS  internal table i_lips
*----------------------------------------------------------------------*
FORM f_retrieve_from_lips  CHANGING fp_i_lips TYPE ty_t_lips
                                    fp_i_likp TYPE ty_t_likp.

  FIELD-SYMBOLS : <lfs_likp> TYPE ty_likp, " field-symbol
                  <lfs_lips> TYPE ty_lips. " field-symbol

  IF fp_i_likp[] IS NOT INITIAL.

    SELECT vbeln " Delivery
           posnr " Delivery Item
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
           pstyv " Delivery item category
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
           matnr " Material Number
           werks " Plant
           charg " Batch
           lfimg " Actual quantity delivered (in sales units)
           vrkme " Sales unit
           vgbel " Document number of the reference document
           vgpos " Item number of the reference item
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
           vkbur " Sales Office
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
           vtweg " Distribution Channel
           spart " Division
           mvgr1 " Material group 1
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
           prctr " Profit Center
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
           kcmeng " Cumulative Quantity
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
           serail " Serial Number Profile
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
    FROM lips
    INTO TABLE fp_i_lips
    FOR ALL ENTRIES IN fp_i_likp
    WHERE vbeln = fp_i_likp-vbeln.

**&& Removed This part to Improve the Report Performance.
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      AND werks IN s_werks
***&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
*      AND vkbur IN s_vkbur
***&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
* "AND vtweg = p_vtweg          ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
* "   removing the Distribution Channel and Division
* "AND spart = p_spart                      because these fields are not mandatory on the selection screen.
*      AND vgbel IN s_vbelns.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

    IF sy-subrc EQ 0.

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      IF s_werks IS  NOT INITIAL.
        DELETE fp_i_lips WHERE werks NOT IN s_werks.
      ENDIF. " IF s_werks IS NOT INITIAL
      IF s_vkbur  IS NOT INITIAL.
        DELETE fp_i_lips WHERE vkbur NOT IN s_vkbur .
      ENDIF. " IF s_vkbur IS NOT INITIAL
      IF s_vbelns IS NOT INITIAL.
        DELETE fp_i_lips WHERE vgbel NOT IN s_vbelns.
      ENDIF. " IF s_vbelns IS NOT INITIAL
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- deleting entries based on the Distribution Channel and Division
**&&    from the selection condition.

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      IF p_vtweg IS NOT INITIAL.
*        DELETE fp_i_lips WHERE vtweg NE p_vtweg.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      IF s_vtweg IS NOT INITIAL.
        DELETE fp_i_lips WHERE vtweg NOT IN s_vtweg.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

      ENDIF. " IF s_vtweg IS NOT INITIAL
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      IF p_spart IS NOT INITIAL.
*        DELETE fp_i_lips WHERE spart NE p_spart.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      IF s_spart IS NOT INITIAL.
        DELETE fp_i_lips WHERE spart NOT IN s_spart.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

      ENDIF. " IF s_spart IS NOT INITIAL
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      SORT fp_i_lips BY vbeln.

      LOOP AT fp_i_likp ASSIGNING <lfs_likp>.
        READ TABLE fp_i_lips ASSIGNING <lfs_lips> WITH KEY vbeln = <lfs_likp>-vbeln
                                                                    BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.
          <lfs_likp>-vbeln = space.
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ENDLOOP. " LOOP AT fp_i_likp ASSIGNING <lfs_likp>
      UNASSIGN <lfs_lips>.
      UNASSIGN <lfs_likp>.
      DELETE fp_i_likp WHERE vbeln = space.
      IF fp_i_likp[] IS INITIAL.
        MESSAGE i981.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF fp_i_likp[] IS INITIAL
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE i981.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_likp[] IS NOT INITIAL

ENDFORM. " F_RETRIEVE_FROM_LIPS
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBAK
*&---------------------------------------------------------------------*
*       retrieve data from VBAK table.
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table i_likp
*      <--FP_I_VBAK  internal table i_vbak
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbak  USING    fp_i_lips TYPE ty_t_lips
                           CHANGING fp_i_vbak TYPE ty_t_vbak.

  DATA: li_lips TYPE STANDARD TABLE OF ty_lips INITIAL SIZE 0. " local internal table

  li_lips[] = fp_i_lips[].
  SORT li_lips BY vgbel.
  DELETE ADJACENT DUPLICATES FROM li_lips COMPARING vgbel.

  IF NOT li_lips[] IS INITIAL.
    SELECT vbeln " Sales Document
           ernam " Created By
           auart " Sales Document Type
           vkorg " Sales Organization
           vtweg " Distribution Channel
           spart " Division
           knumv " Number of the document condition
           bstnk " Customer purchase order number
    FROM vbak    " Sales Document: Header Data
    INTO TABLE fp_i_vbak
    FOR ALL ENTRIES IN li_lips
    WHERE vbeln = li_lips-vgbel.
 "AND   vkorg = p_vkorg        ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
 "AND   vtweg = p_vtweg                        "removing the Distribution Channel and Division
 "AND   spart = p_spart                        "because these fields are not mandatory on the selection screen.
    IF sy-subrc EQ 0.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- deleting entries based on the Distribution Channel and Division
**&&    from the selection condition.

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      IF p_vkorg IS NOT INITIAL.
*        DELETE fp_i_vbak WHERE vkorg NE p_vkorg.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      DELETE fp_i_vbak WHERE vkorg NOT IN s_vkorg.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      ENDIF. " IF s_vkorg IS NOT INITIAL
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      IF p_vtweg IS NOT INITIAL.
*        DELETE fp_i_vbak WHERE vtweg NE p_vtweg.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      IF s_vtweg IS NOT INITIAL.
        DELETE fp_i_vbak WHERE vtweg NOT IN s_vtweg.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

      ENDIF. " IF s_vtweg IS NOT INITIAL

*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      IF p_spart IS NOT INITIAL.
*        DELETE fp_i_vbak WHERE spart NE p_spart.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      IF s_spart IS NOT INITIAL.
        DELETE fp_i_vbak WHERE spart NOT IN s_spart.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

      ENDIF. " IF s_spart IS NOT INITIAL
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      SORT fp_i_vbak BY vbeln.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_lips[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_VBAK
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBKD
*&---------------------------------------------------------------------*
*       retrieve data from VBKD table.
*----------------------------------------------------------------------*
*      -->FP_I_VBAK  internal table i_likp
*      <--FP_I_VBKD  internal table i_vbak
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbkd  USING    fp_i_vbak TYPE ty_t_vbak
                           CHANGING fp_i_vbkd TYPE ty_t_vbkd.

  DATA: lc_posnr TYPE posnr VALUE '000000'. " Item Number

  IF NOT fp_i_vbak[] IS INITIAL.

    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           bstkd " Customer purchase order number
    FROM vbkd    " Sales Document: Business Data
    INTO TABLE fp_i_vbkd
    FOR ALL ENTRIES IN fp_i_vbak
    WHERE vbeln = fp_i_vbak-vbeln
    AND   posnr = lc_posnr.

    IF sy-subrc EQ 0.
      SORT fp_i_vbkd BY vbeln.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT fp_i_vbak[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_VBKD
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBUP
*&---------------------------------------------------------------------*
*       retrieve data from VBUP table.
*----------------------------------------------------------------------*
*      <--FP_I_LIPS  internal table i_lips
*      <--FP_I_VBUP  internal table i_vbup
*      <--FP_I_LIKP  internal table i_likp
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbup CHANGING  fp_i_lips TYPE ty_t_lips
                                    fp_i_vbup TYPE ty_t_vbup
                                    fp_i_likp TYPE ty_t_likp.

  CONSTANTS: lc_pdsta_a TYPE pdsta VALUE 'A', "A
             lc_pdsta_b TYPE pdsta VALUE 'B', "B
             lc_pdsta_c TYPE pdsta VALUE 'C'. "C

  FIELD-SYMBOLS: <lfs_likp> TYPE ty_likp, " Field symbol
                 <lfs_lips> TYPE ty_lips, " Field symbol
                 <lfs_vbup> TYPE ty_vbup. " Field Symbol

  IF fp_i_lips[] IS NOT INITIAL.

    SELECT vbeln " Sales and Distribution Document Number
           posnr " Item number of the SD document
           pdsta " POD status on item level
    FROM vbup    " Sales Document: Item Status
    INTO TABLE fp_i_vbup
    FOR ALL ENTRIES IN fp_i_lips
    WHERE vbeln = fp_i_lips-vbeln
    AND   posnr = fp_i_lips-posnr
    AND   pdsta IN (lc_pdsta_a, lc_pdsta_b, lc_pdsta_c).

    IF sy-subrc EQ 0.
* When POD confirmed radio button is selected then only those
* deliveries will be displayed in the output, which have VBUP-PDSTA = B or C
      IF rb_conf = abap_true.
        DELETE fp_i_vbup WHERE pdsta = lc_pdsta_a.
      ELSE. " ELSE -> IF rb_conf = abap_true
* When POD relevant radio button is selected then only those
* deliveries will be displayed in the output, which have VBUP-PDSTA = A.
        DELETE fp_i_vbup WHERE pdsta = lc_pdsta_b
                         OR    pdsta = lc_pdsta_c.
      ENDIF. " IF rb_conf = abap_true
      SORT fp_i_vbup BY vbeln
                        posnr.
* Deleting the non-relevant deliveries from LIKP table based on
* POD Confirmed or POD Relevant.
      LOOP AT fp_i_likp ASSIGNING <lfs_likp>.
        READ TABLE fp_i_vbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_likp>-vbeln
                                                                      BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.
          <lfs_likp>-vbeln = space.
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ENDLOOP. " LOOP AT fp_i_likp ASSIGNING <lfs_likp>
      UNASSIGN <lfs_vbup>.
      UNASSIGN <lfs_likp>.
      DELETE fp_i_likp WHERE vbeln = space.
      IF fp_i_likp[] IS INITIAL.
        MESSAGE i981.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF fp_i_likp[] IS INITIAL
**&& -- BOC : Performance Enhancement : SMUKHER : 10-SEP-14
**&& -- Deleting the non-relevant entries from LIPS based on
**       POD Confirmed or POD relevant.
      LOOP AT fp_i_lips ASSIGNING <lfs_lips>.
        READ TABLE fp_i_vbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_lips>-vbeln
                                                                       BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.
          <lfs_lips>-vbeln = space.
        ENDIF. " IF sy-subrc IS NOT INITIAL
      ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips>
      UNASSIGN <lfs_vbup>.
      UNASSIGN <lfs_lips>.
      DELETE fp_i_lips WHERE vbeln = space.
      IF fp_i_lips[] IS INITIAL.
        MESSAGE i981.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF fp_i_lips[] IS INITIAL
**&& -- EOC : Performance Enhancement : SMUKHER : 10-SEP-14
    ELSE. " ELSE -> IF sy-subrc EQ 0
      MESSAGE i981. " Data not found.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips[] IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_VBUP
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_TVM1T
*&---------------------------------------------------------------------*
*       retrieve data from TVM1T table.
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table i_lips
*      <--FP_I_TVM1T internal table i_tvm1t
*----------------------------------------------------------------------*
FORM f_retrieve_from_tvm1t  USING    fp_i_lips TYPE ty_t_lips
                            CHANGING fp_i_tvm1t TYPE ty_t_tvm1t.

  DATA: li_lips TYPE STANDARD TABLE OF ty_lips INITIAL SIZE 0. " local internal table

  li_lips[] = fp_i_lips[].
  SORT li_lips BY mvgr1.
  DELETE ADJACENT DUPLICATES FROM li_lips COMPARING mvgr1.

  IF NOT li_lips[] IS INITIAL.
    SELECT spras " Language Key
           mvgr1 " Material group 1
           bezei "  Description
    FROM tvm1t   " Material pricing group 1: Description
    INTO TABLE fp_i_tvm1t
    FOR ALL ENTRIES IN li_lips
    WHERE spras = sy-langu
    AND   mvgr1 = li_lips-mvgr1.

    IF sy-subrc EQ 0.
      SORT fp_i_tvm1t BY mvgr1.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_lips[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_TVM1T
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBAP
*&---------------------------------------------------------------------*
*       retrieve data from VBAP table.
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table LIPS table.
*      <--FP_I_VBAP  internal table VBAP table.
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbap  USING    fp_i_lips TYPE ty_t_lips
                           CHANGING fp_i_vbap TYPE ty_t_vbap.

  IF fp_i_lips[] IS NOT INITIAL.

    SELECT vbeln "  Sales Document
           posnr "  Sales Document Item
           charg " Batch
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
           uepos " Higher level line item
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
           netwr " Net value of the order item in document currency
**&& -- BOC : HPQC Defect 1149 : SMUKHER : 25-MAR-14
           kwmeng " Cumulative Order Quantity in Sales Units
**&& -- EOC : HPQC Defect 1149 : SMUKHER : 25-MAR-14
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
      mvgr1
*<--- end of Insert for D3_OTC_RDD_0043 CR#6638by U103565(AARYAN) on 10-Jul-2018
    FROM vbap
    INTO TABLE fp_i_vbap
    FOR ALL ENTRIES IN fp_i_lips
    WHERE vbeln = fp_i_lips-vgbel.

    IF sy-subrc EQ 0.
      SORT fp_i_vbap BY vbeln
                        posnr.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips[] IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_VBAP
*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
* Revert Back OLd logic
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_KONV
*&---------------------------------------------------------------------*
*       retrieve data from KONV table.
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table i_lips
*      -->FP_I_VBAK  internal table i_vbak
*      <--FP_I_LIPS  internal table i_lips
*----------------------------------------------------------------------*
FORM f_retrieve_from_konv  USING    fp_i_vbak TYPE ty_t_vbak
                           CHANGING fp_i_konv TYPE ty_t_konv.

  DATA: li_vbak TYPE STANDARD TABLE OF ty_vbak INITIAL SIZE 0. " loacal internal table

  li_vbak[] = fp_i_vbak[].
  SORT li_vbak BY knumv.
  DELETE ADJACENT DUPLICATES FROM li_vbak COMPARING knumv.

  IF NOT li_vbak[] IS INITIAL.
    SELECT knumv   " Number of the document condition
           kposn   " Condition item number
           stunr   " Step number
           zaehk   "  Condition counter
           kschl   " Condition type
           kwert_k " Condition value
    FROM konv      " Conditions (Transaction Data)
    INTO TABLE fp_i_konv
    FOR ALL ENTRIES IN li_vbak
    WHERE knumv = li_vbak-knumv
    AND   kschl = gv_kschl.

    IF sy-subrc EQ 0.
      SORT fp_i_konv BY knumv kposn.

    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF NOT li_vbak[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_KONV
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VEPO
*&---------------------------------------------------------------------*
*       retrieve data from VEPO table.
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table i_lips
*      <--FP_I_VEPO  internal table i_vepo
*----------------------------------------------------------------------*
FORM f_retrieve_from_vepo  USING    fp_i_lips TYPE ty_t_lips
                           CHANGING fp_i_vepo TYPE ty_t_vepo.

  IF fp_i_lips[] IS NOT INITIAL.

    SELECT venum " Internal Handling Unit Number
           vepos " Handling Unit Item
           vbeln " Delivery
           posnr " Delivery Item
    FROM vepo    " Packing: Handling Unit Item (Contents)
    INTO TABLE fp_i_vepo
    FOR ALL ENTRIES IN fp_i_lips
    WHERE vbeln = fp_i_lips-vbeln
    AND   posnr = fp_i_lips-posnr.

    IF sy-subrc EQ 0.
      SORT fp_i_vepo BY vbeln
                        posnr.

    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_lips[] IS NOT INITIAL

ENDFORM. " F_RETRIEVE_FROM_VEPO
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VEKP
*&---------------------------------------------------------------------*
*       retrieve data from VEKP table.
*----------------------------------------------------------------------*
*      -->FP_I_VEPO  internal table i_vepo
*      <--FP_I_VEKP  internal table i_vekp
*----------------------------------------------------------------------*
FORM f_retrieve_from_vekp  USING    fp_i_vepo TYPE ty_t_vepo
                           CHANGING fp_i_vekp TYPE ty_t_vekp.

*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
  DATA: li_vekp      TYPE STANDARD TABLE OF ty_vekp INITIAL SIZE 0,
        li_vekp_tmp  TYPE STANDARD TABLE OF ty_vekp INITIAL SIZE 0,
        lwa_vekp     TYPE ty_vekp,
        lwa_vekp_tmp TYPE ty_vekp.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018

  IF fp_i_vepo[] IS NOT INITIAL.

    SELECT venum " Internal Handling Unit Number
           exidv " Handling Unit No
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
           uevel
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
           spe_idart_01	 " Handling Unit Identification Type
           spe_ident_01  " Alternative HU Identification
           spe_idart_02	 " Handling Unit Identification Type
           spe_ident_02  " Alternative HU Identification
           spe_idart_03	 " Handling Unit Identification Type
           spe_ident_03  " Alternative HU Identification
           spe_idart_04  " Handling Unit Identification Type
           spe_ident_04  " Alternative HU Identification
    FROM vekp            " Handling Unit - Header Table
    INTO TABLE fp_i_vekp
    FOR ALL ENTRIES IN fp_i_vepo
    WHERE venum    = fp_i_vepo-venum.
    IF sy-subrc EQ 0.
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
      li_vekp_tmp[] = fp_i_vekp[].
      DELETE li_vekp_tmp WHERE uevel IS INITIAL.
      IF li_vekp_tmp IS NOT INITIAL.
        SELECT venum     " Internal Handling Unit Number
           exidv         " Handling Unit No
           uevel         " Higher-Level Handling Unit
           spe_idart_01	 " Handling Unit Identification Type
           spe_ident_01  " Alternative HU Identification
           spe_idart_02	 " Handling Unit Identification Type
           spe_ident_02  " Alternative HU Identification
           spe_idart_03	 " Handling Unit Identification Type
           spe_ident_03  " Alternative HU Identification
           spe_idart_04  " Handling Unit Identification Type
           spe_ident_04  " Alternative HU Identification
    FROM vekp            " Handling Unit - Header Table
    INTO TABLE li_vekp
    FOR ALL ENTRIES IN li_vekp_tmp
    WHERE venum    = li_vekp_tmp-uevel.
        IF sy-subrc IS INITIAL.
          LOOP AT li_vekp INTO lwa_vekp.
            lwa_vekp_tmp-venum = lwa_vekp-venum.
            lwa_vekp_tmp-exidv = lwa_vekp-exidv.
            lwa_vekp_tmp-uevel = lwa_vekp-uevel.
            lwa_vekp_tmp-spe_idart_01 = lwa_vekp-spe_idart_01.
            lwa_vekp_tmp-spe_ident_01 = lwa_vekp-spe_ident_01.
            lwa_vekp_tmp-spe_idart_02 = lwa_vekp-spe_idart_02.
            lwa_vekp_tmp-spe_ident_02 = lwa_vekp-spe_ident_02.
            lwa_vekp_tmp-spe_idart_03 = lwa_vekp-spe_idart_03.
            lwa_vekp_tmp-spe_ident_03 = lwa_vekp-spe_ident_03.
            lwa_vekp_tmp-spe_idart_04 = lwa_vekp-spe_idart_04.
            lwa_vekp_tmp-spe_ident_04 = lwa_vekp-spe_ident_04.
            APPEND lwa_vekp_tmp TO fp_i_vekp.
            CLEAR:lwa_vekp_tmp,
                  lwa_vekp.
          ENDLOOP. " LOOP AT li_vekp INTO lwa_vekp
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF li_vekp_tmp IS NOT INITIAL
      FREE: li_vekp[],
            li_vekp_tmp[].
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
      SORT fp_i_vekp BY venum.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF fp_i_vepo[] IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_VEKP
*&---------------------------------------------------------------------*
*&      Form  F_FINAL_TABLE_POPULATION
*&---------------------------------------------------------------------*
*       final table population
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  internla table i_likp
*      -->FP_I_KNA1  internal table i_kna1
*      -->FP_I_TVSBT internal table i_tvsbt
*      -->FP_I_TINCT internal table i_tinct
*      -->FP_I_TVROT internal table i_tvrot
*      -->FP_I_LIPS  internal table i_lips
*      -->FP_I_VBAK  internal table i_vbak
*      -->FP_I_VBUP  internal table i_vbup
*      -->FP_I_TVM1T internal table tvm1t
*      -->FP_I_VBAP  internal table i_vbap
*      -->FP_I_VEPO  internal table i_vepo
*      -->FP_I_VEKP  internal table i_vekp
*      <--FP_I_FINAL internal table i_final
*----------------------------------------------------------------------*
FORM f_final_table_population  USING    fp_i_likp  TYPE ty_t_likp
                                        fp_i_kna1  TYPE ty_t_kna1
                                        fp_i_tvsbt TYPE ty_t_tvsbt
                                        fp_i_tvrot TYPE ty_t_tvrot
                                        fp_i_bkpf  TYPE ty_t_bkpf
                                        fp_i_bseg  TYPE ty_t_bseg
                                        fp_i_lips  TYPE ty_t_lips
                                        fp_i_vbak  TYPE ty_t_vbak
                                        fp_i_vbkd  TYPE ty_t_vbkd
                                        fp_i_vbup  TYPE ty_t_vbup
                                        fp_i_tvm1t TYPE ty_t_tvm1t
                                        fp_i_vbap  TYPE ty_t_vbap
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                                        fp_i_konv  TYPE ty_t_konv " Defect 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                                        fp_i_vekp  TYPE ty_t_vekp
                                        fp_i_makt  TYPE ty_t_makt
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
                                        fp_i_marc  TYPE ty_t_marc
                                        fp_i_zlex_pod TYPE ty_t_zlex_pod
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
* *---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
                                        fp_i_hu_header    TYPE hum_hu_header_t
                                        fp_i_tvro         TYPE ty_t_tvro
                                        fp_i_zlex_pod_his TYPE ty_t_pod_his
                                        fp_i_error        TYPE ty_t_error
                                        fp_i_vbpa         TYPE ty_t_vbpa

*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*                                        fp_i_mbew  TYPE ty_t_mbew  " Defect 3399
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                               CHANGING fp_i_vepo  TYPE ty_t_vepo
                                        fp_i_final TYPE ty_t_final.

* Field symbol declaration
  FIELD-SYMBOLS : <lfs_likp>    TYPE ty_likp,  "Field symbol for LIKP
                  <lfs_kna1>    TYPE ty_kna1,  "Field symbol for KNA1
                  <lfs_tvsbt>   TYPE ty_tvsbt, "Field symbol for TVSBT
                  <lfs_tvrot>   TYPE ty_tvrot, "Field symbol for TVROT
                  <lfs_bkpf>    TYPE ty_bkpf,  " Field symbol for BKPF
                  <lfs_bseg>    TYPE ty_bseg,  " Field symbol for BSEG
                  <lfs_lips>    TYPE ty_lips,  "Field symbol for LIPS
                  <lfs_vbak>    TYPE ty_vbak,  "Field symbol for VBAK
                  <lfs_vbkd>    TYPE ty_vbkd,  "Field symbol for VBKD
                  <lfs_vbup>    TYPE ty_vbup,  "Field symbol for VBUP
                  <lfs_tvm1t>   TYPE ty_tvm1t, "Field symbol for TVM1T
                  <lfs_vbap>    TYPE ty_vbap,  "Field symbol for VBAP
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                  <lfs_konv>    TYPE ty_konv, "Field symbol for KONV  " Defect 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                  <lfs_vepo>    TYPE ty_vepo, "Field symbol for VEPO
                  <lfs_vekp>    TYPE ty_vekp, "Field symbol for VEKP
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
                  <lfs_makt>    TYPE ty_makt, "Field Symbol for MAKT
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*---> Begin of insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
                 <lfs_marc>     TYPE ty_marc,     "Field Symbol for MARC
                 <lfs_zlex_pod> TYPE ty_zlex_pod, "Field Symbol for ZLEX_POD
*<--- End of insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                 <lfs_mbew>    TYPE ty_mbew. "Field Symbol for MBEW
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017


  DATA: lwa_final TYPE ty_final, " work area for final
        lv_index  TYPE sy-index. " Parallel cursor

  CONSTANTS: lc_pdsta_a TYPE pdsta VALUE 'A', "A
             lc_pdsta_b TYPE pdsta VALUE 'B', "B
             lc_pdsta_c TYPE pdsta VALUE 'C', "C
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
             lc_land1_de TYPE land1 VALUE 'DE',          "Local constant DE
             lc_knfak_01 TYPE wfcid VALUE '01',          "Local constant 01
             lc_knfak_99 TYPE wfcid VALUE '99',          "Local constant 99
             lc_idart_t  TYPE /spe/de_huidart VALUE 'T'. "Local constant T

  DATA: lwa_hu_header TYPE vekpvb,       " Work Structure for Handling Unit Header
        lwa_tvro      TYPE ty_tvro,      "Local work area for TVRO
        lwa_error     TYPE ty_error,     "Local work area for Error
        lv_fcdate     TYPE scal-facdate, " Factory calendar: Factory date
        lv_facdate    TYPE scal-facdate, " Factory calendar: Factory date
        lwa_vbpa      TYPE ty_vbpa,      "Local work area for VBPA
        lv_knfak      TYPE knfak,        " Customer factory calendar
        lv_date       TYPE datum ,       " Local variable Date
        lwa_inst      TYPE ty_inst,      " Local work area for Instant delivery
        lwa_pod_his   TYPE
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
                           ty_pod_his,      "Local work area
        li_header     TYPE hum_hu_header_t, "Local Internal table for HU Header
        lwa_vekp      TYPE ty_vekp,
        lwa_header    TYPE vekpvb,          "Local work area
        lv_venum      TYPE venum,           " Internal Handling Unit Number
*---> Begin of Insert for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
        lv_sp_traztd  TYPE char10. " Sp_traztd of type CHAR10

  CONSTANTS: lc_dot   TYPE char1       VALUE '.', " local constant for dot
             lc_comma TYPE char1       VALUE ','. " local constant for comma
*<--- End of Insert for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
 "Taking the HU header in a local internal table
  li_header[] = fp_i_hu_header[].
 "Sort the table for Binary search
  SORT li_header BY venum.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
*        zlex_pod_his. " table symbol to store POD history from zlex_pod
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**& Sorting the VEPO table by Delivery Number & Item Number.
  SORT fp_i_vepo BY vbeln posnr.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

  LOOP AT fp_i_likp ASSIGNING <lfs_likp>.

    lwa_final-route =       <lfs_likp>-route. "Route
    lwa_final-vsbed =       <lfs_likp>-vsbed. "Shipping Conditions
    lwa_final-inco1 =       <lfs_likp>-inco1. "Incoterms
    lwa_final-inco2 =       <lfs_likp>-inco2. "Incoterms Description
    lwa_final-kunag =       <lfs_likp>-kunag. "Sold-to-Party
    lwa_final-kunnr =       <lfs_likp>-kunnr. "Ship-to-Party
    lwa_final-podat =       <lfs_likp>-podat. "Actual POD Date
    lwa_final-wadat_ist =   <lfs_likp>-wadat_ist. "Actual PGI Date
    lwa_final-wadat =       <lfs_likp>-wadat. "Planned PGI Date
    lwa_final-erdat =       <lfs_likp>-erdat. "Delivery Date
    lwa_final-lfart =       <lfs_likp>-lfart. "Delivery Type
    lwa_final-vbeln =       <lfs_likp>-vbeln. "Delivery Number
    lwa_final-vkorg =       <lfs_likp>-vkorg. "Distribution Channel
    lwa_final-waerk =       <lfs_likp>-waerk. "Currency

*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
 "Transit duration
    READ TABLE fp_i_tvro INTO lwa_tvro WITH KEY route = <lfs_likp>-route
                                                BINARY SEARCH.
    IF sy-subrc IS INITIAL.
*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
 "As filter was not working for the Transition time field in the output
 "so taking it intoi a character field
      CALL FUNCTION 'CONVERSION_EXIT_TSTRG_OUTPUT'
        EXPORTING
          input  = lwa_tvro-traztd
        IMPORTING
          output = lwa_final-traztd.
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
*      lwa_final-traztd = lwa_tvro-traztd.
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
    ENDIF. " IF sy-subrc IS INITIAL
 "Error status of the delivery
    READ TABLE fp_i_error INTO lwa_error WITH KEY vbeln = <lfs_likp>-vbeln
                                                BINARY SEARCH.
    IF  sy-subrc IS INITIAL .
      lwa_final-status = lwa_error-status.
    ENDIF. " IF sy-subrc IS INITIAL
 "Calculating total transition date from factory calender
    IF <lfs_likp>-knfak IS NOT INITIAL.

      lv_knfak =  <lfs_likp>-knfak.

    ELSE. " ELSE -> IF <lfs_likp>-knfak IS NOT INITIAL
      READ TABLE fp_i_vbpa INTO lwa_vbpa WITH KEY vbeln = <lfs_likp>-vbeln
                                                  BINARY SEARCH.
      IF sy-subrc IS INITIAL.

        IF lwa_vbpa-land1 IS NOT INITIAL.

          IF lwa_vbpa-land1 EQ lc_land1_de.

            lv_knfak = lc_knfak_01.
          ELSE. " ELSE -> IF lwa_vbpa-land1 EQ lc_land1_de
            lv_knfak = lwa_vbpa-land1.
          ENDIF. " IF lwa_vbpa-land1 EQ lc_land1_de
        ELSE. " ELSE -> IF lwa_vbpa-land1 IS NOT INITIAL
          lv_knfak = lc_knfak_99.
        ENDIF. " IF lwa_vbpa-land1 IS NOT INITIAL

      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF <lfs_likp>-knfak IS NOT INITIAL

    CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
      EXPORTING
        date                         = <lfs_likp>-wadat_ist
        factory_calendar_id          = lv_knfak
      IMPORTING
        factorydate                  = lv_fcdate
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        correct_option_invalid       = 2
        date_after_range             = 3
        date_before_range            = 4
        date_invalid                 = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 7.
    IF sy-subrc  = 0.

**---> Begin of delete for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
*        CALL FUNCTION 'CONVERSION_EXIT_TSTRG_OUTPUT'
*          EXPORTING
*            input  = lwa_tvro-traztd
*          IMPORTING
*            output = lwa_tvro-traztd.
**<--- End of delete for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
**---> Begin of Insert for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
 "As conversion exit is giving dump while executing the report with decimal notation ' ' for
 "European user.So we are making the logic robust to work in any decimal notation
      lv_sp_traztd = lwa_final-traztd.
      REPLACE ALL OCCURRENCES OF lc_comma IN lv_sp_traztd WITH lc_dot.
      lwa_tvro-traztd = lv_sp_traztd.
      CLEAR lv_sp_traztd.
**<--- End of Insert for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018

      lv_facdate =  lv_fcdate + lwa_tvro-traztd.

*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
          "If in some case factory calender not found in the FM
    ELSE. " ELSE -> IF sy-subrc = 0
      CLEAR lv_knfak.
      lv_knfak = lc_knfak_99.
      CALL FUNCTION 'DATE_CONVERT_TO_FACTORYDATE'
        EXPORTING
          date                         = <lfs_likp>-wadat_ist
          factory_calendar_id          = lv_knfak
        IMPORTING
          factorydate                  = lv_fcdate
        EXCEPTIONS
          calendar_buffer_not_loadable = 1
          correct_option_invalid       = 2
          date_after_range             = 3
          date_before_range            = 4
          date_invalid                 = 5
          factory_calendar_not_found   = 6
          OTHERS                       = 7.
      IF sy-subrc IS INITIAL.

**---> Begin of delete for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
*        CALL FUNCTION 'CONVERSION_EXIT_TSTRG_OUTPUT'
*          EXPORTING
*            input  = lwa_tvro-traztd
*          IMPORTING
*            output = lwa_tvro-traztd.
**<--- End of delete for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
**---> Begin of Insert for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018
 "As conversion exit is giving dump while executing the report with decimal notation ' ' for
 "European user.So we are making the logic robust to work in any decimal notation
        lv_sp_traztd = lwa_final-traztd.
        REPLACE ALL OCCURRENCES OF lc_comma IN lv_sp_traztd WITH lc_dot.
        lwa_tvro-traztd = lv_sp_traztd.
        CLEAR lv_sp_traztd.
**<--- End of Insert for D3_OTC_RDD_0043 Defect# 7261 by U103061 on 04-Oct-2018

        lv_facdate =  lv_fcdate + lwa_tvro-traztd.

      ENDIF. " IF sy-subrc IS INITIAL
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
    ENDIF. " IF sy-subrc = 0

    CALL FUNCTION 'FACTORYDATE_CONVERT_TO_DATE'
      EXPORTING
        factorydate                  = lv_facdate
        factory_calendar_id          = lv_knfak
      IMPORTING
        date                         = lv_date
      EXCEPTIONS
        calendar_buffer_not_loadable = 1
        factorydate_after_range      = 2
        factorydate_before_range     = 3
        factorydate_invalid          = 4
        factory_calendar_id_missing  = 5
        factory_calendar_not_found   = 6
        OTHERS                       = 7.
    IF sy-subrc = 0.
      lwa_final-pcdate = lv_date.
    ENDIF. " IF sy-subrc = 0
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
 "clear the local variable
    CLEAR: lv_knfak,
           lv_date,
           lv_facdate.
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018



    READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1> WITH KEY kunnr = <lfs_likp>-kunag " for Sold-to-Name
                                                                  BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-name1_kunag = <lfs_kna1>-name1.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_kna1 ASSIGNING <lfs_kna1> WITH KEY kunnr = <lfs_likp>-kunnr " for Ship-to-Name
                                                                  BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-name1_kunnr = <lfs_kna1>-name1.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_tvsbt ASSIGNING <lfs_tvsbt> WITH KEY vsbed = <lfs_likp>-vsbed
                                                                    BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-vtext =    <lfs_tvsbt>-vtext.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_tvrot ASSIGNING <lfs_tvrot> WITH KEY route = <lfs_likp>-route
                                                                    BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lwa_final-bezei_r =    <lfs_tvrot>-bezei. "route.
    ENDIF. " IF sy-subrc IS INITIAL

    READ TABLE fp_i_bkpf ASSIGNING <lfs_bkpf> WITH KEY xblnr = <lfs_likp>-vbeln
                                                                     BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      READ TABLE fp_i_bseg ASSIGNING <lfs_bseg> WITH KEY belnr = <lfs_bkpf>-belnr
                                                                       BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_final-hkont = <lfs_bseg>-hkont.
      ENDIF. " IF sy-subrc IS INITIAL
      UNASSIGN <lfs_bseg>.
    ENDIF. " IF sy-subrc IS INITIAL
    UNASSIGN <lfs_bkpf>.

    READ TABLE fp_i_lips TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_likp>-vbeln.
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*                                                BINARY SEARCH.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
    IF sy-subrc IS INITIAL.
      lv_index = sy-tabix.

      LOOP AT fp_i_lips ASSIGNING <lfs_lips> FROM lv_index.
        IF <lfs_lips>-vbeln <> <lfs_likp>-vbeln.
          EXIT.
        ENDIF. " IF <lfs_lips>-vbeln <> <lfs_likp>-vbeln
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- We consider only those deliveries where LIPS-KCMENG is initial-
*        For batch splited items we will display ONLY POSNR = 9xxxx
        IF <lfs_lips>-kcmeng IS INITIAL.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          lwa_final-vrkme =    <lfs_lips>-vrkme.
          lwa_final-lfimg =    <lfs_lips>-lfimg.
          lwa_final-werks =    <lfs_lips>-werks.
          lwa_final-matnr =    <lfs_lips>-matnr.
 "  lwa_final-charg =    <lfs_lips>-charg.  " commented out for ADDITIONAL CHANGES ON CR# 1149 : 09-APR-14
          lwa_final-vgpos =    <lfs_lips>-vgpos.
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
          lwa_final-vkbur =    <lfs_lips>-vkbur.
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
          lwa_final-posnr =    <lfs_lips>-posnr.
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**&& -- Addition of new field: 'Item Category'
          lwa_final-pstyv =    <lfs_lips>-pstyv.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
          lwa_final-prctr =    <lfs_lips>-prctr.

          READ TABLE fp_i_marc ASSIGNING <lfs_marc> WITH KEY matnr = <lfs_lips>-matnr
                                                             werks = <lfs_lips>-werks
                                                             BINARY SEARCH.

          IF sy-subrc IS INITIAL.
            lwa_final-sernp  = <lfs_marc>-sernp.
          ENDIF. " IF sy-subrc IS INITIAL
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
* Commenting out new code to revert to ld code for cost
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**&& -- Fetching the values for Cost
*          READ TABLE fp_i_mbew ASSIGNING <lfs_mbew> WITH KEY matnr = <lfs_lips>-matnr
*                                                             bwkey = <lfs_lips>-werks
*                                                                   BINARY SEARCH.
*          IF sy-subrc IS INITIAL.
*            lwa_final-stprs = <lfs_mbew>-stprs.
*          ENDIF. " IF sy-subrc IS INITIAL
*          UNASSIGN <lfs_mbew>.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Fretching the values for Material Description
          READ TABLE fp_i_makt ASSIGNING <lfs_makt> WITH KEY matnr = <lfs_lips>-matnr
                                                                     BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            lwa_final-maktx =  <lfs_makt>-maktx.
          ENDIF. " IF sy-subrc IS INITIAL
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          READ TABLE fp_i_vbup ASSIGNING <lfs_vbup> WITH KEY vbeln = <lfs_lips>-vbeln
                                                             posnr = <lfs_lips>-posnr
                                                                        BINARY SEARCH.
          IF sy-subrc IS INITIAL.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Populating the value for POD Status Description
            lwa_final-pdsta_value = <lfs_vbup>-pdsta.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

            IF <lfs_vbup>-pdsta = lc_pdsta_a.
              lwa_final-pdsta = icon_red_light.
            ELSEIF <lfs_vbup>-pdsta = lc_pdsta_b.
              lwa_final-pdsta = icon_yellow_light.
            ELSEIF <lfs_vbup>-pdsta = lc_pdsta_c.
              lwa_final-pdsta = icon_green_light.
            ENDIF. " IF <lfs_vbup>-pdsta = lc_pdsta_a
          ENDIF. " IF sy-subrc IS INITIAL

          READ TABLE fp_i_tvm1t ASSIGNING <lfs_tvm1t> WITH KEY mvgr1 = <lfs_lips>-mvgr1
                                                                          BINARY SEARCH.
          IF sy-subrc IS INITIAL.
            lwa_final-bezei =    <lfs_tvm1t>-bezei.
          ENDIF. " IF sy-subrc IS INITIAL

**&& -- BOC : HPQC Defect 1149 : SMUKHER : 25-MAR-14
**&& -- Fetching the Sales Document data from VBAP.
          READ TABLE fp_i_vbap ASSIGNING <lfs_vbap> WITH KEY vbeln = <lfs_lips>-vgbel
                                                             posnr = <lfs_lips>-vgpos
                                                                        BINARY SEARCH.
          IF sy-subrc IS INITIAL.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            lwa_final-charg = <lfs_vbap>-charg.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
            IF <lfs_vbap>-kwmeng IS NOT INITIAL.
**&& -- Populating the value of Net Value
              lwa_final-netwr = ( ( ( <lfs_vbap>-netwr ) * ( <lfs_lips>-lfimg ) ) / ( <lfs_vbap>-kwmeng ) ).
            ENDIF. " IF <lfs_vbap>-kwmeng IS NOT INITIAL
*&-- Begin of changes for Defect# 1440 by SMUKHER on 12-Jan-2016
* Code Bug Fix done for Short Dump 'GETWA_NOT_ASSIGNED'
*          ENDIF.
*&-- End of changes for Defect# 1440 by SMUKHER on 12-Jan-2016

*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
 "Populating the instalable delivery flag if at least one product have material group as 001,002 and 003

            IF <lfs_vbap>-mvgr1 IN i_mat_group.
              lwa_final-inst_delivery = abap_true.
              lwa_inst-vbeln  =  <lfs_lips>-vbeln.
              lwa_inst-inst_delivery = abap_true.
              APPEND lwa_inst TO i_inst.
              CLEAR lwa_inst.
            ENDIF. " IF <lfs_vbap>-mvgr1 IN i_mat_group
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

            READ TABLE fp_i_vbak ASSIGNING <lfs_vbak> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                                          BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lwa_final-auart =     <lfs_vbak>-auart.
              lwa_final-vtweg =     <lfs_vbak>-vtweg.
              lwa_final-spart =     <lfs_vbak>-spart.
              lwa_final-vgbel =     <lfs_vbak>-vbeln.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
              lwa_final-ernam =     <lfs_vbak>-ernam.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
              READ TABLE fp_i_vbkd ASSIGNING <lfs_vbkd> WITH KEY vbeln = <lfs_vbak>-vbeln
                                                                          BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lwa_final-bstnk =     <lfs_vbkd>-bstkd.
              ENDIF. " IF sy-subrc IS INITIAL
*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
* Revert back old code
* ---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

*& Cost is now being populated from MBEW.
              READ TABLE fp_i_konv ASSIGNING <lfs_konv> WITH KEY knumv = <lfs_vbak>-knumv
                                                                 kposn = <lfs_lips>-vgpos
                                                                            BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                IF <lfs_vbap>-kwmeng IS NOT INITIAL.
*&& -- Populating the value of Cost
                  lwa_final-kwert_k = ( ( <lfs_konv>-kwert_k ) * ( <lfs_lips>-lfimg ) ) / ( <lfs_vbap>-kwmeng ).
                ENDIF. " IF <lfs_vbap>-kwmeng IS NOT INITIAL
              ENDIF. " IF sy-subrc IS INITIAL
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399
            ENDIF. " IF sy-subrc IS INITIAL
*&-- Begin of changes for Defect# 1440 by SMUKHER on 12-Jan-2016
          ENDIF. " IF sy-subrc IS INITIAL
*&-- End of changes for Defect# 1440 by SMUKHER on 12-Jan-2016

**&& -- EOC : HPQC Defect 1149 : SMUKHER : 25-MAR-14
          READ TABLE fp_i_vepo ASSIGNING <lfs_vepo> WITH KEY vbeln = <lfs_lips>-vbeln
                                                             posnr = <lfs_lips>-posnr.
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*                                                                        BINARY SEARCH.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
          IF sy-subrc IS INITIAL.
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**&& -- Looping the VEPO table as Multiple HU's are there in the table
            CLEAR: lv_index.
            lv_index = sy-tabix.
            LOOP AT fp_i_vepo ASSIGNING <lfs_vepo> FROM lv_index.
              IF <lfs_vepo>-vbeln <> <lfs_lips>-vbeln
              OR <lfs_vepo>-posnr <> <lfs_lips>-posnr.
                EXIT.
              ENDIF. " IF <lfs_vepo>-vbeln <> <lfs_lips>-vbeln
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

              READ TABLE fp_i_vekp ASSIGNING <lfs_vekp> WITH KEY venum = <lfs_vepo>-venum
                                                                          BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lwa_final-exidv        =  <lfs_vekp>-exidv.
                lwa_final-spe_idart_01 =  <lfs_vekp>-spe_idart_01.
                lwa_final-spe_ident_01 =  <lfs_vekp>-spe_ident_01.
                lwa_final-spe_idart_02 =  <lfs_vekp>-spe_idart_02.
                lwa_final-spe_ident_02 =  <lfs_vekp>-spe_ident_02.
                lwa_final-spe_idart_03 =  <lfs_vekp>-spe_idart_03.
                lwa_final-spe_ident_03 =  <lfs_vekp>-spe_ident_03.
                lwa_final-spe_idart_04 =  <lfs_vekp>-spe_idart_04.
                lwa_final-spe_ident_04 =  <lfs_vekp>-spe_ident_04.
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
                "After getting the Higher level HU only we are supposed to get the Tracking Number
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*       for fetching tracking no. as per requirement
*                IF <lfs_vekp>-spe_idart_01 = lc_idart_t.
*                  IF <lfs_vekp>-spe_ident_01 IS NOT INITIAL.
*                    lwa_final-trac_no       =  <lfs_vekp>-spe_ident_01.
*                  ENDIF. " IF <lfs_vekp>-spe_ident_01 IS NOT INITIAL
*                ELSEIF
*                   <lfs_vekp>-spe_idart_02 = lc_idart_t.
*                  IF <lfs_vekp>-spe_ident_02 IS NOT INITIAL.
*                    lwa_final-trac_no       =  <lfs_vekp>-spe_ident_02.
*                  ENDIF. " IF <lfs_vekp>-spe_ident_02 IS NOT INITIAL
*                ELSEIF
*                   <lfs_vekp>-spe_idart_03 = lc_idart_t.
*                  IF <lfs_vekp>-spe_ident_03 IS NOT INITIAL.
*                    lwa_final-trac_no       =  <lfs_vekp>-spe_ident_03.
*                  ENDIF. " IF <lfs_vekp>-spe_ident_03 IS NOT INITIAL
*                ENDIF. " IF <lfs_vekp>-spe_idart_01 = lc_idart_t
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
                CLEAR lwa_final-pod_date.
*---> Begin  of Delete for D3_OTC_RDD_0043 CR#6638by U103565(AARYAN) on 10-Jul-2018
*                READ TABLE fp_i_zlex_pod  ASSIGNING <lfs_zlex_pod> WITH KEY hunum = <lfs_vekp>-exidv
*                                                                      BINARY SEARCH.
*                IF sy-subrc is initial.
*                   lwa_final-pod_date   = <lfs_zlex_pod>-pod_date.
*                ENDIF.

*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*<---  End  of Delete for D3_OTC_RDD_0043 CR#6638by U103565(AARYAN) on 10-Jul-2018

*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

 "To get the higher level HU if present otherwise we will populate the
                READ TABLE fp_i_hu_header INTO lwa_hu_header  WITH KEY venum = <lfs_vekp>-venum
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
                                                                        BINARY SEARCH.
                IF lwa_hu_header-uevel IS NOT INITIAL.
                  READ TABLE li_header INTO lwa_header WITH KEY venum = lwa_hu_header-uevel
                                                                BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    lwa_final-higher_hu = lwa_header-exidv.
                    lv_venum = lwa_header-venum.
                  ENDIF. " IF sy-subrc IS INITIAL
                ELSE. " ELSE -> IF lwa_hu_header-uevel IS NOT INITIAL
                  lwa_final-higher_hu = lwa_hu_header-exidv.
                  lv_venum = lwa_hu_header-venum.
                ENDIF. " IF lwa_hu_header-uevel IS NOT INITIAL
 "Raeding VEKP for Tracking Number for Higher level HU
                READ TABLE fp_i_vekp INTO lwa_vekp WITH KEY venum = lv_venum
                                                            BINARY SEARCH.
                IF sy-subrc IS INITIAL.
                  IF lwa_vekp-spe_idart_01 = lc_idart_t.
                    IF lwa_vekp-spe_ident_01 IS NOT INITIAL.
                      lwa_final-trac_no       =  lwa_vekp-spe_ident_01.
                    ENDIF. " IF lwa_vekp-spe_ident_01 IS NOT INITIAL
                  ELSEIF
                     lwa_vekp-spe_idart_02 = lc_idart_t.
                    IF lwa_vekp-spe_ident_02 IS NOT INITIAL.
                      lwa_final-trac_no       =  lwa_vekp-spe_ident_02.
                    ENDIF. " IF lwa_vekp-spe_ident_02 IS NOT INITIAL
                  ELSEIF
                     lwa_vekp-spe_idart_03 = lc_idart_t.
                    IF lwa_vekp-spe_ident_03 IS NOT INITIAL.
                      lwa_final-trac_no       = lwa_vekp-spe_ident_03.
                    ENDIF. " IF lwa_vekp-spe_ident_03 IS NOT INITIAL
                  ENDIF. " IF lwa_vekp-spe_idart_01 = lc_idart_t

                ENDIF. " IF sy-subrc IS INITIAL
                CLEAR lv_venum.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018

*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
*                IF sy-subrc IS INITIAL.
*                  lwa_final-higher_hu = lwa_hu_header-exidv.
*                ELSE. " ELSE -> IF sy-subrc IS INITIAL
*                  lwa_final-higher_hu = lwa_final-exidv.
*                ENDIF. " IF sy-subrc IS INITIAL
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
 "To get pod_dat based on outbound deliveries
                IF rb_conf = abap_false.
                  READ TABLE fp_i_zlex_pod  ASSIGNING <lfs_zlex_pod> WITH KEY hunum = lwa_final-higher_hu
                                                                    tracking_number = lwa_final-trac_no
                                                                    BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    lwa_final-pod_date   = <lfs_zlex_pod>-pod_date.
                  ENDIF. " IF sy-subrc IS INITIAL
                ELSE. " ELSE -> IF rb_conf = abap_false
 "Caught in IBM check but can be ignored as we have the requirement like this only
 "Any change in the structure may hamper
                  READ TABLE fp_i_zlex_pod_his  INTO lwa_pod_his WITH KEY hunum = lwa_final-higher_hu
                                                                          tracking_number = lwa_final-trac_no
                                                                          BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    lwa_final-pod_date   = lwa_pod_his-pod_date.
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF rb_conf = abap_false
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
                APPEND lwa_final TO fp_i_final.
                CLEAR:  lwa_final-exidv,
                        lwa_final-spe_idart_01,
                        lwa_final-spe_ident_01,
                        lwa_final-spe_idart_02,
                        lwa_final-spe_ident_02,
                        lwa_final-spe_idart_03,
                        lwa_final-spe_ident_03,
                        lwa_final-spe_idart_04,
                        lwa_final-spe_ident_04,
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638by U103565(AARYAN) on 10-Jul-2018
"Clearing the local work areas
                        lwa_final-trac_no,
                        lwa_final-higher_hu,
                        lwa_final-pod_date.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
              ENDIF. " IF sy-subrc IS INITIAL
            ENDLOOP. " LOOP AT fp_i_vepo ASSIGNING <lfs_vepo> FROM lv_index
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*            ENDIF. " IF sy-subrc IS INITIAL
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*---> Begin of Insert for D3_OTC_RDD_0043 Defect# 4308 by SMUKHER4 on 27-Nov-2017
          ELSE. " ELSE -> IF sy-subrc IS INITIAL
*If There is no HU then  also record should be appeneded
            APPEND lwa_final TO fp_i_final.
*<--- End of Insert for D3_OTC_RDD_0043 Defect# 4308 by SMUKHER4 on 27-Nov-2017
          ENDIF. " IF sy-subrc IS INITIAL
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*          APPEND lwa_final TO fp_i_final.
*          CLEAR: lwa_final-charg, lwa_final-vrkme, lwa_final-lfimg,
*                 lwa_final-werks, lwa_final-matnr, lwa_final-vgpos,
*                 lwa_final-vgbel, lwa_final-spart, lwa_final-posnr,
*                 lwa_final-auart, lwa_final-vtweg, lwa_final-bstnk,
*                 lwa_final-pdsta, lwa_final-bezei, lwa_final-netwr,
*                 lwa_final-kwert_k, lwa_final-exidv,
*                 lwa_final-spe_idart_01, lwa_final-spe_ident_01,
*                 lwa_final-spe_idart_02, lwa_final-spe_ident_02,
*                 lwa_final-spe_idart_03, lwa_final-spe_ident_03,
*                 lwa_final-spe_idart_04, lwa_final-spe_ident_04,
***&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*                 lwa_final-pdsta_value, lwa_final-ernam,
*                 lwa_final-maktx.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
          CLEAR: lwa_final-charg,
                 lwa_final-vrkme,
                 lwa_final-lfimg,
                 lwa_final-werks,
                 lwa_final-matnr,
                 lwa_final-vgpos,
                 lwa_final-vgbel,
                 lwa_final-spart,
                 lwa_final-posnr,
                 lwa_final-auart,
                 lwa_final-vtweg,
                 lwa_final-bstnk,
                 lwa_final-pdsta,
                 lwa_final-bezei,
                 lwa_final-netwr,
                 lwa_final-stprs,
                 lwa_final-pstyv,
                 lwa_final-pdsta_value,
                 lwa_final-ernam,
                 lwa_final-maktx,
*<--- Begin of Insert for D3_OTC_RDD_0043 CR#6638by U103565(AARYAN) on 10-Jul-2018
"clearing the local work areas
                 lwa_final-inst_delivery,
                 lwa_final-trac_no,
                 lwa_final-higher_hu,
                 lwa_final-pod_date.
*---> End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
        ENDIF. " IF <lfs_lips>-kcmeng IS INITIAL
      ENDLOOP. " LOOP AT fp_i_lips ASSIGNING <lfs_lips> FROM lv_index
      UNASSIGN <lfs_lips>.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      UNASSIGN <lfs_makt>.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
      UNASSIGN <lfs_vbak>.
      UNASSIGN <lfs_vbkd>.
      UNASSIGN <lfs_vbup>.
      UNASSIGN <lfs_tvm1t>.
      UNASSIGN <lfs_vbap>.
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*        UNASSIGN <lfs_konv>.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      UNASSIGN <lfs_vepo>.
      UNASSIGN <lfs_vekp>.
    ENDIF. " IF sy-subrc IS INITIAL
    CLEAR lwa_final.
  ENDLOOP. " LOOP AT fp_i_likp ASSIGNING <lfs_likp>
  UNASSIGN <lfs_likp>.
  UNASSIGN <lfs_tvrot>.
  UNASSIGN <lfs_tvsbt>.
  UNASSIGN <lfs_kna1>.
  UNASSIGN <lfs_bkpf>.
  UNASSIGN <lfs_bseg>.
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
  FREE li_header[].
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018

ENDFORM. " F_FINAL_TABLE_POPULATION
*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       prepare the fieldcatalog table
*----------------------------------------------------------------------*
*      <--P_I_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM f_prepare_fieldcat  CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.
  DATA: lv_pos TYPE i. "variable.
*Constants Declaration
  CONSTANTS: lc_left_adjst  TYPE char1 VALUE 'L',                    "(L)eft.
             lc_vkorg TYPE slis_fieldname VALUE 'VKORG',             "Sales Organization
             lc_vtweg TYPE slis_fieldname VALUE 'VTWEG',             "Distribution Channel
             lc_spart TYPE slis_fieldname VALUE 'SPART',             "Division
             lc_vbeln TYPE slis_fieldname VALUE 'VBELN',             "Delivery Number
             lc_lfart TYPE slis_fieldname VALUE 'LFART',             "Delivery Type
             lc_erdat TYPE slis_fieldname VALUE 'ERDAT',             "Delivery Date
             lc_wadat TYPE slis_fieldname VALUE 'WADAT',             "Planned PGI Date
             lc_wadat_ist TYPE slis_fieldname VALUE 'WADAT_IST',     "Actual PGI Date
             lc_podat TYPE slis_fieldname VALUE 'PODAT',             "Actual POD Date
             lc_kunag TYPE slis_fieldname VALUE 'KUNAG',             "Sold-to-party
             lc_name1_kunag TYPE slis_fieldname VALUE 'NAME1_KUNAG', "Sold-to-name
             lc_kunnr TYPE slis_fieldname VALUE 'KUNNR',             "Ship-to-party
             lc_name1_kunnr TYPE slis_fieldname VALUE 'NAME1_KUNNR', "Ship-to-name
             lc_inco1 TYPE slis_fieldname VALUE 'INCO1',             "Incoterm (Part 1)
             lc_inco2 TYPE slis_fieldname VALUE 'INCO2',             "Incoterm (Part 2)
             lc_vsbed TYPE slis_fieldname VALUE 'VSBED',             "Shipping Conditions
             lc_vtext TYPE slis_fieldname VALUE 'VTEXT',             "Description of the shipping conditions
             lc_route TYPE slis_fieldname VALUE 'ROUTE',             "Route
             lc_bezei_r TYPE slis_fieldname VALUE 'BEZEI_R',         "Description of Route
             lc_posnr TYPE slis_fieldname VALUE 'POSNR',             "Delivery Item
             lc_vgbel TYPE slis_fieldname VALUE 'VGBEL',             "Sales Order Number
*---> Begin of Insert for D3-OTC_RDD_0043_defect# 2933 by U034229 on 29-May-2017
             lc_prctr TYPE slis_fieldname VALUE 'PRCTR',    " Profit Center
             lc_sernp TYPE slis_fieldname VALUE 'SERNP',    " Serial Number Profile
             lc_pod   TYPE slis_fieldname VALUE 'POD_DATE', " Date
*<--- End of Insert for D3-OTC_RDD_0043_defect# 2933 by U034229 on 29-May-2017
             lc_auart TYPE slis_fieldname VALUE 'AUART', "Sales Document Type
             lc_bstnk TYPE slis_fieldname VALUE 'BSTNK', "Customer purchase order number
             lc_vgpos TYPE slis_fieldname VALUE 'VGPOS', "Item number of the reference item
             lc_pdsta TYPE slis_fieldname VALUE 'PDSTA', "POD status on item level
             lc_matnr TYPE slis_fieldname VALUE 'MATNR', "Material Number
             lc_werks TYPE slis_fieldname VALUE 'WERKS', "Plant
             lc_lfimg TYPE slis_fieldname VALUE 'LFIMG', "Actual quantity delivered (in sales units)
             lc_vrkme TYPE slis_fieldname VALUE 'VRKME', "Sales unit
             lc_charg TYPE slis_fieldname VALUE 'CHARG', "Batch Number
             lc_bezei TYPE slis_fieldname VALUE 'BEZEI', "Description
             lc_netwr TYPE slis_fieldname VALUE 'NETWR', "Net value of the order item in document currency
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*             lc_stprs TYPE slis_fieldname VALUE 'STPRS', " Cost  " Defect 3399
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
             lc_kwert_k TYPE slis_fieldname VALUE 'KWERT_K', "Condition value  " Defect 3399
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
             lc_waerk TYPE slis_fieldname VALUE 'WAERK',               "SD Document Currency
             lc_exidv TYPE slis_fieldname VALUE 'EXIDV',               "External Handling Unit Identification
             lc_spe_idart_01 TYPE slis_fieldname VALUE 'SPE_IDART_01', "Handling Unit Identification Type
             lc_spe_ident_01 TYPE slis_fieldname VALUE 'SPE_IDENT_01', "Alternative HU Identification
             lc_spe_idart_02 TYPE slis_fieldname VALUE 'SPE_IDART_02', "Handling Unit Identification Type
             lc_spe_ident_02 TYPE slis_fieldname VALUE 'SPE_IDENT_02', "Alternative HU Identification
             lc_spe_idart_03 TYPE slis_fieldname VALUE 'SPE_IDART_03', "Handling Unit Identification Type
             lc_spe_ident_03 TYPE slis_fieldname VALUE 'SPE_IDENT_03', "Alternative HU Identification
             lc_spe_idart_04 TYPE slis_fieldname VALUE 'SPE_IDART_04', "Handling Unit Identification Type
             lc_spe_ident_04 TYPE slis_fieldname VALUE 'SPE_IDENT_04', "Alternative HU Identification
             lc_hkont TYPE slis_fieldname VALUE 'HKONT',               " InTransit GL Account
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
             lc_maktx TYPE slis_fieldname VALUE 'MAKTX',             " Material Description
             lc_ernam TYPE slis_fieldname VALUE 'ERNAM',             " Created By
             lc_pdsta_value TYPE slis_fieldname VALUE 'PDSTA_VALUE', " POD Status on an item
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
             lc_vkbur TYPE slis_fieldname VALUE 'VKBUR', " Sales Office
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
             lc_pstyv TYPE slis_fieldname VALUE 'PSTYV', " Sales document item category
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
            lc_transit      TYPE slis_fieldname VALUE 'TRAZTD',        " Transit time from route
            lc_hu_header    TYPE slis_fieldname VALUE 'HIGHER_HU',     "Higher level HU
            lc_planned_date TYPE slis_fieldname VALUE 'PCDATE',        "Planned Carrier delivery date
            lc_inst         TYPE slis_fieldname VALUE 'INST_DELIVERY', "Installable Deliveries
            lc_trac_no      TYPE slis_fieldname VALUE 'TRAC_NO',       " tracking number.
            lc_error        TYPE slis_fieldname VALUE 'STATUS',        " Error Status
            lc_start_date   TYPE slis_fieldname VALUE 'START_DATE'.    "local constant for START DATE
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
*&& -- Changed the positions of the columns as per the latest requirement.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_pdsta 'POD Status'(029) lc_left_adjst "#EC TEXT_DUP
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vkorg 'Sales Organization'(006) lc_left_adjst
                                    CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vtweg 'Distribution Channel'(007) lc_left_adjst
                                    CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spart 'Division'(008) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_werks 'Plant'(031) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- BOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vkbur 'Sales Office'(060) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- EOC : ADDITION OF NEW FIELD 'SALES OFFICE' : 13-MAY-14
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vbeln 'Delivery Number'(009) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_lfart 'Delivery Type'(010) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_erdat 'Delivery Date'(011) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_wadat 'Planned PGI Date'(012) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_wadat_ist 'Actual PGI Date'(013) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_podat 'Actual POD Date'(014) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_kunag 'Sold-to-Number'(015) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_name1_kunag 'Sold-to-name'(016) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_kunnr 'Ship-to-Number'(017) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_name1_kunnr 'Ship-to-name'(018) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_inco1 'Incoterm'(019) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_inco2 'Incoterm Description'(020) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vsbed 'Shipping Conditions'(021) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vtext 'Shipping Conditions Description'(022) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_route 'Route'(023) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_bezei_r 'Route Description'(024) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_posnr 'Delivery Item'(025) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_lfimg 'Delivery Quantity'(032) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_matnr 'Material Number'(030) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Addition of 'Material Description' column
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_maktx 'Material Description'(064) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_charg 'Batch Number from Sales Order Number'(034)
  lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vgbel 'Sales Order Number'(056) lc_left_adjst
                                  CHANGING fp_i_fieldcat.

*---> Begin of Insert for D3-OTC_RDD_0043_defect# 2933 by U034229 on 29-May-2017
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_prctr 'Profit Center'(062) lc_left_adjst
                                  CHANGING fp_i_fieldcat.

  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_sernp 'Serial Number Profile'(063) lc_left_adjst
                                  CHANGING fp_i_fieldcat.

  lv_pos = lv_pos + 1.
*---> Begin of Delete for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*    PERFORM f_fieldcatalog_populate: USING lv_pos lc_pod   'POD Date'(066) lc_left_adjst
*                                  CHANGING fp_i_fieldcat.
*<--- End of Delete for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
 "have to rename the field as per the reqirement
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_pod   'ESS carrier delivery date'(072) lc_left_adjst
                              CHANGING fp_i_fieldcat.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
*<--- End of Insert for D3-OTC_RDD_0043_defect# 2933 by U034229 on 29-May-2017
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Addition of 'Sales Order Created By' column.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_ernam 'Sales Order Created By'(065) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_auart 'Sales Order Type'(026) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_bstnk 'Purchase Order Number'(027) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vgpos 'Sales Order Item'(028) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- Addition of 'POD Status' Column which will contain descriptions like 'A' 'B' or 'C'.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_pdsta_value 'POD Status'(029) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_vrkme 'UoM'(033) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_bezei 'Instrument Indicator'(035) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_netwr 'Net Value'(036) lc_left_adjst
                                  CHANGING fp_i_fieldcat.

*---> Begin of Change for D3_OTC_RDD_0043_Defect# 3399
*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_kwert_k 'Cost'(037) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*  PERFORM f_fieldcatalog_populate: USING lv_pos lc_stprs 'Cost'(037) lc_left_adjst
*                                     CHANGING fp_i_fieldcat.
**<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*<--- End of Change for D3_OTC_RDD_0043_Defect# 3399
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_waerk 'Currency'(038) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_exidv 'Handling Unit Number'(039) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_idart_01 'HU ID Type 1'(040) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_ident_01 'Alt Hnd Unit ID 1'(041) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_idart_02 'HU ID Type 2'(042) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_ident_02 'Alt Hnd Unit ID 2'(043) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_idart_03 'HU ID Type 3'(044) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_ident_03 'Alt Hnd Unit ID 3'(045) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_idart_04 'HU ID Type 4'(046) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_spe_ident_04 'Alt Hnd Unit ID 4'(047) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_hkont 'InTansit GL Account'(058) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_pstyv 'Item Cat'(067) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_hu_header 'Higher Level HU'(068) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_inst 'Installable delivery'(069) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_planned_date 'Planned Carrier Delivery Date'(071) lc_left_adjst
                                  CHANGING fp_i_fieldcat.

  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_trac_no 'Tracking Number'(073) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_error 'Error Message'(074) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_transit 'Transit time from route'(075) lc_left_adjst
                                  CHANGING fp_i_fieldcat.
  lv_pos = lv_pos + 1.
  PERFORM f_fieldcatalog_populate: USING lv_pos lc_start_date 'Customer Acceptance date'(076)
                                         lc_left_adjst CHANGING fp_i_fieldcat.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
ENDFORM. " F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*       Display ALV Output
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT internal table i_fieldcat
*      -->FP_I_FINAL    internal table i_final
*----------------------------------------------------------------------*
FORM f_output_display  USING    fp_i_fieldcat TYPE slis_t_fieldcat_alv
                                fp_i_final TYPE ty_t_final.

* local data declaration.
  DATA : lwa_layo TYPE slis_layout_alv. " Layout for alv

* Constants declaration
  CONSTANTS:lc_callback_subroutine TYPE slis_formname
                               VALUE 'F_USER_COMMAND',               "F_USER_COMMAND
            lc_top_page    TYPE slis_formname VALUE 'F_TOP_OF_PAGE', "top of page

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
           lc_pf_status   TYPE slis_formname VALUE 'ZOTC0043_PF_STATUS'. " PF Status
  DATA rt_extab TYPE slis_t_extab.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

  lwa_layo-zebra = abap_true.
  lwa_layo-colwidth_optimize = abap_true.

*&&-- Populate TOP-OF-PAGE
  PERFORM f_top_header.

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
**&& Setting the PF Status
  PERFORM zotc0043_pf_status USING rt_extab.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid    " report id
      i_callback_top_of_page  = lc_top_page " TOP-OF-PAGE
*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      i_callback_pf_status_set = lc_pf_status " PF status
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
      i_callback_user_command = lc_callback_subroutine " for User-Command
      is_layout               = lwa_layo               " for layout
      it_fieldcat             = fp_i_fieldcat          " field catalog
      i_save                  = gc_save                " save
    TABLES
      t_outtab                = fp_i_final             " internal table
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE e974.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0
ENDFORM. " F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  USER COMMAND
*&---------------------------------------------------------------------*
*      for user command interaction
*----------------------------------------------------------------------*
FORM f_user_command USING fp_ucomm LIKE sy-ucomm "#EC CALLED
                        fp_selfield TYPE slis_selfield.

*Constants Declaration
  CONSTANTS: lc_back TYPE sy-ucomm VALUE '&BACK&',            "back
             lc_end TYPE sy-ucomm VALUE '&EXIT&',             "exit
             lc_cancel TYPE sy-ucomm VALUE '&CANCEL&',        "cancel
             lc_hotspot TYPE sy-ucomm VALUE '&IC1',           "hotspot
             lc_fieldname1 TYPE slis_fieldname VALUE 'VBELN', "field value
             lc_fieldname2 TYPE slis_fieldname VALUE 'EXIDV', "field value
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
             lc_fieldname3 TYPE slis_fieldname VALUE 'VGBEL', "field value
             lc_field2 TYPE char10 VALUE 'AUN',               "parameter value
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
             lc_field1 TYPE char10 VALUE 'VL'. "parameter value

  DATA: li_bdcdata TYPE STANDARD TABLE OF bdcdata " Batch input: New table field structure
                   INITIAL SIZE 0.                "internal table for BDC data

*Field-symbols declaration
  FIELD-SYMBOLS: <lfs_final> TYPE ty_final.

  CASE fp_ucomm.

* To go back to previous screen
    WHEN lc_back.
      LEAVE TO SCREEN 0.
      fp_selfield-refresh = abap_true.

* to end the current process
    WHEN lc_end.
      LEAVE PROGRAM.

* to cancel the present process
    WHEN lc_cancel.
      LEAVE PROGRAM.

* to create hot spot for VBELN and EXIDV
    WHEN lc_hotspot.
* Check field clicked on within ALVgrid report
      IF fp_selfield-fieldname = lc_fieldname1.
* Read data table, using index of row user clicked on
        READ TABLE i_final ASSIGNING <lfs_final> INDEX fp_selfield-tabindex.
        IF sy-subrc EQ 0.
* Set parameter ID for transaction screen field
          SET PARAMETER ID lc_field1 FIELD <lfs_final>-vbeln.
* Execute transaction VLPOD, and skip initial data entry screen
          CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN. "#EC CI_CALLTA
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF fp_selfield-fieldname = lc_fieldname1

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- The User will navigate to VA03 transaction on 'double click' of Sales Order Number.

* Check field clicked on within ALVgrid report
      IF fp_selfield-fieldname = lc_fieldname3.
* Read data table, using index of row user clicked on
        READ TABLE i_final ASSIGNING <lfs_final> INDEX fp_selfield-tabindex.
        IF sy-subrc EQ 0.
* Set parameter ID for transaction screen field
          SET PARAMETER ID lc_field2 FIELD <lfs_final>-vgbel.
* Execute transaction VLPOD, and skip initial data entry screen
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN. "#EC CI_CALLTA
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF fp_selfield-fieldname = lc_fieldname3
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

* Check field clicked on within ALVgrid report
      IF fp_selfield-fieldname = lc_fieldname2.
* Read data table, using index of row user clicked on
        READ TABLE i_final ASSIGNING <lfs_final> INDEX fp_selfield-tabindex.
        IF sy-subrc EQ 0.
          PERFORM f_bdc_create USING <lfs_final>
                               CHANGING li_bdcdata.
          PERFORM f_call_transaction USING 'HUMO'
                                        li_bdcdata.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF fp_selfield-fieldname = lc_fieldname2
  ENDCASE.
ENDFORM. "f_user_command
*&---------------------------------------------------------------------*
*&      form F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       This is used for populating program name and screen number
*----------------------------------------------------------------------*
*      -->FP_V_PROGRAM        BDC Program Name
*      -->FP_V_DYNPRO         BDC Screen Dynpro No.
*      <--FP_I_BDCDATA        Filled up BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_dynpro  USING fp_v_program  TYPE bdc_prog " BDC module pool
                         fp_v_dynpro   TYPE bdc_dynr " BDC Screen number
                CHANGING fp_i_bdcdata  TYPE bdcdata_tab.

* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure
* Filling the BDC Data table for Program name, screen no and dyn begin
  CLEAR lwa_bdcdata.
  lwa_bdcdata-program  = fp_v_program.
  lwa_bdcdata-dynpro   = fp_v_dynpro.
  lwa_bdcdata-dynbegin = abap_true.
  APPEND lwa_bdcdata TO fp_i_bdcdata.
ENDFORM. " F_BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      form F_BDC_FIELD
*&---------------------------------------------------------------------*
*       This subroutine is used to populate field name and values
*----------------------------------------------------------------------*
*      -->FP_V_FNAM      Field Name
*      -->FP_V_FVAL      Field Value
*      <--FP_I_BDCDATA   Populated BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_field  USING fp_v_fnam    TYPE any
                        fp_v_fval    TYPE any
               CHANGING fp_i_bdcdata TYPE bdcdata_tab.

* Local data declaration
  DATA: lwa_bdcdata TYPE bdcdata. " Batch input: New table field structure

* Filling the BDC Data table for Field value and Field name
  IF NOT fp_v_fval IS INITIAL.
    CLEAR lwa_bdcdata.
    lwa_bdcdata-fnam = fp_v_fnam.
    lwa_bdcdata-fval = fp_v_fval.
    APPEND lwa_bdcdata TO fp_i_bdcdata.
  ENDIF. " IF NOT fp_v_fval IS INITIAL

ENDFORM. " F_BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_TOP_HEADER
*&---------------------------------------------------------------------*
FORM f_top_header .

  CONSTANTS: lc_typ_h       TYPE char1 VALUE 'H', "H
             lc_typ_s       TYPE char1 VALUE 'S'. "S

  TYPES: ty_t_bapiret TYPE STANDARD TABLE OF bapiret2. "Bapi Returb Tab Type

* Local data declaration
  DATA: lv_date    TYPE char10,              "date variable
        lv_time    TYPE char10,              "time variable
        lv_lines   TYPE int4,                "records count of final table
        lx_address TYPE bapiaddr3,           "User Address Data
        lwa_listheader TYPE slis_listheader, "list header
        li_return  TYPE ty_t_bapiret.        "return table

  CONSTANTS: lc_colon TYPE char1 VALUE ':', "Colon
             lc_slash TYPE char1 VALUE '/'. "Slash

  lwa_listheader-typ  = lc_typ_h.
  lwa_listheader-key  = 'Report'(048).
  lwa_listheader-info =
  'Comprehensive POD Report'(049).
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'User Name'(050).

* Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lx_address
    TABLES
      return   = li_return.

  IF lx_address-fullname IS NOT INITIAL.
    MOVE lx_address-fullname TO lwa_listheader-info.
  ELSE. " ELSE -> IF lx_address-fullname IS NOT INITIAL
    MOVE sy-uname TO lwa_listheader-info.
  ENDIF. " IF lx_address-fullname IS NOT INITIAL

  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ = lc_typ_s.
  lwa_listheader-key = 'Date and Time'(051).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY lc_colon. "':'.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY lc_slash. "'/'.

  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  DESCRIBE TABLE i_final[] LINES lv_lines.

  lwa_listheader-typ  = lc_typ_s.
  lwa_listheader-key  = 'Total Records'(052).
  MOVE lv_lines TO lwa_listheader-info.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

ENDFORM. " F_TOP_HEADER
*&---------------------------------------------------------------------*
*&      Form  sub_top_of_page
*&---------------------------------------------------------------------*
*      Subroutine is used to call TOP OF PAGE event dynamically
*----------------------------------------------------------------------*
*      <-- i_top using internal table for the TOP_OF_PAGE
*----------------------------------------------------------------------*
FORM f_top_of_page. "#EC CALLED
* Subroutine for top of page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM. "f_top_of_page
*&---------------------------------------------------------------------*
*&      Form  f_fieldcatalog_populate
*&---------------------------------------------------------------------*
*       populate the fieldcatalog table
*----------------------------------------------------------------------*
*      -->FP_LV_POS  position
*      -->FP_FIELDNAME  fieldname
*      -->FP_SELTEXT_L  label
*      -->FP_LEFT_ADJST  Left adjusted
*      <--FP_I_FIELDCAT  Fieldcatalog table
*----------------------------------------------------------------------*
FORM f_fieldcatalog_populate  USING     fp_lv_pos TYPE i            " Fieldcatalog_populate u of type Integers
                                        fp_fieldname TYPE slis_fieldname
                                        fp_seltext_l TYPE scrtext_l " Long Field Label
                                        fp_left_adjst TYPE char1    " Left_adjst of type CHAR1
                               CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

* Local data decleration.
  DATA :  lwa_fieldcat TYPE slis_fieldcat_alv, "Fieldcatalog Workarea
**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
          lv_pdsta TYPE slis_fieldname VALUE 'PDSTA'. " local variable
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14

  lwa_fieldcat-col_pos = fp_lv_pos.
  lwa_fieldcat-fieldname = fp_fieldname.
  lwa_fieldcat-seltext_l = fp_seltext_l.
  lwa_fieldcat-just = fp_left_adjst.

**&& -- BOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
**&& -- While download to excel sheet, the POD Status(Traffic Lights)
**&&    should not appear.
  IF fp_fieldname = lv_pdsta.
    lwa_fieldcat-icon = abap_true.
  ENDIF. " IF fp_fieldname = lv_pdsta
**&& -- EOC : ADDITIONAL CHANGES ON CR#1149 : 09-APR-14
  APPEND lwa_fieldcat TO fp_i_fieldcat.

ENDFORM. " f_fieldcatalog_populate
*&---------------------------------------------------------------------*
*&      Form  F_BDC_CREATE
*&---------------------------------------------------------------------*
*       subroutine for BDC data
*----------------------------------------------------------------------*
*      -->FP_LFS_FINAL    final internal table.
*      <--FP_LI_BDCDATA   BDC Data
*----------------------------------------------------------------------*
FORM f_bdc_create  USING    fp_lfs_final TYPE ty_final
                   CHANGING fp_li_bdcdata TYPE bdcdata_tab.

  PERFORM f_bdc_dynpro USING 'RHU_HELP' '1000'
                                  CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field USING 'BDC_CURSOR'  'SELEXIDV-LOW'
                        CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field USING 'SELEXIDV-LOW'  fp_lfs_final-exidv
                        CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field USING 'LSTAND'  'X'
                        CHANGING fp_li_bdcdata.
  PERFORM f_bdc_field USING 'NODIS'  '1,000'
                        CHANGING fp_li_bdcdata.


ENDFORM. " F_BDC_CREATE
*&---------------------------------------------------------------------*
*&      Form  F_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*       subroutine for BDC CALL TRANSACTION
*----------------------------------------------------------------------*
*      -->FP_TCODE       sytcode                                       *
*      -->FP_LI_BDCDATA  internal table for BDC data                   *
*----------------------------------------------------------------------*
FORM f_call_transaction  USING    fp_tcode TYPE sytcode " Current Transaction Code
                                  fp_li_bdcdata TYPE bdcdata_tab.

  CALL TRANSACTION fp_tcode USING fp_li_bdcdata.

ENDFORM. " F_CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_BKPF
*&---------------------------------------------------------------------*
*       retrieve data from BKPF table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  internal table i_likp
*      <--FP_I_BKPF  internal table i_bkpf
*----------------------------------------------------------------------*
FORM f_retrieve_from_bkpf  USING    fp_i_likp TYPE ty_t_likp
                           CHANGING fp_i_bkpf TYPE ty_t_bkpf.

  CONSTANTS: lc_tcode TYPE tcode VALUE 'VL02N'. " VL02N transaction
**&& -- BOC : Performance Enhancement : SMUKHER : 10-SEP-14
  DATA: lv_bukrs TYPE bukrs , " Company Code
**&& -- EOC : Performance Enhancement : SMUKHER : 10-SEP-14                                        " local variable
        li_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0. "local internal table.

  FIELD-SYMBOLS: <lfs_likp> TYPE ty_likp. "field symbol

* Type-cating XBLNR
  li_likp[] = fp_i_likp[].
  LOOP AT li_likp ASSIGNING <lfs_likp>.
    <lfs_likp>-vbeln_xblnr = <lfs_likp>-vbeln.
  ENDLOOP. " LOOP AT li_likp ASSIGNING <lfs_likp>

  SORT li_likp BY vbeln_xblnr .
  DELETE ADJACENT DUPLICATES FROM li_likp COMPARING vbeln_xblnr.
**&& -- BOC : Performance Enhancement : SMUKHER : 10-SEP-14
  IF NOT li_likp[] IS INITIAL.
**&& -- Fetching Company Code based on Sales Organization
    SELECT SINGLE bukrs " Company Code
      FROM tvko         " Organizational Unit: Sales Organizations
      INTO lv_bukrs

*---> Begin of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*      WHERE vkorg = p_vkorg.
*<--- End of Delete for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
      WHERE vkorg IN s_vkorg.
*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017


    IF sy-subrc IS INITIAL.
**&& -- EOC : Performance Enhancement : SMUKHER : 10-SEP-14

      SELECT bukrs " Company Code
             belnr " Accounting Document Number
             gjahr " Fiscal Year
             xblnr " Reference Document Number
             tcode " Transaction Code
      FROM bkpf    " Accounting Document Header
      INTO TABLE fp_i_bkpf
      FOR ALL ENTRIES IN li_likp
**&& -- BOC : Performance Enhancement : SMUKHER : 10-SEP-14
      WHERE bukrs = lv_bukrs
      AND   bstat = space
**&& -- EOC : Performance Enhancement : SMUKHER : 10-SEP-14
      AND   xblnr = li_likp-vbeln_xblnr.

      IF sy-subrc IS INITIAL.
        DELETE fp_i_bkpf WHERE tcode <> lc_tcode.
        SORT fp_i_bkpf BY xblnr.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF NOT li_likp[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_BKPF
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_BSEG
*&---------------------------------------------------------------------*
*       retrieve data from BSEG table
*----------------------------------------------------------------------*
*      -->FP_I_BKPF  internal table i_bkpf
*      <--FP_I_BSEG  internal type i_bseg
*----------------------------------------------------------------------*
FORM f_retrieve_from_bseg  USING    fp_i_bkpf TYPE ty_t_bkpf
                           CHANGING fp_i_bseg TYPE ty_t_bseg.

  CONSTANTS: lc_buzid TYPE buzid VALUE 'U'. " U

  DATA: li_bkpf TYPE STANDARD TABLE OF ty_bkpf INITIAL SIZE 0. "local internal table

  li_bkpf[] = fp_i_bkpf[].
  SORT li_bkpf BY belnr.
  DELETE ADJACENT DUPLICATES FROM li_bkpf COMPARING belnr.

  IF NOT li_bkpf[] IS INITIAL.

    SELECT bukrs " Company Code
           belnr " Accounting Document Number
           gjahr " fiscal year
           buzei " Number of line item within accounting document
           buzid " Identification of the Line Item
           bschl " Posting Key
           hkont " General Ledger Account
    FROM bseg    " Accounting Document Segment
    INTO TABLE fp_i_bseg
    FOR ALL ENTRIES IN li_bkpf
    WHERE belnr = li_bkpf-belnr
    AND   buzid = lc_buzid
    AND   bschl = gv_bschl.

    IF sy-subrc IS INITIAL.
      SORT fp_i_bseg BY belnr.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF NOT li_bkpf[] IS INITIAL
ENDFORM. " F_RETRIEVE_FROM_BSEG
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_PGI_AC
*&---------------------------------------------------------------------*
*       Validating the Actual PGI_Date
*----------------------------------------------------------------------*
FORM f_validate_s_pgi_ac .
  IF rb_conf = abap_true.
**&& -- Check if any Additional parameters are filled.
    IF s_vbeln IS NOT INITIAL OR
       s_venum IS NOT INITIAL OR
       s_vbelnp IS NOT INITIAL OR
       s_vbelns IS NOT INITIAL .
          " no mandatory date check or 15 days limit check is allowed.
    ELSE. " ELSE -> IF s_vbeln IS NOT INITIAL OR
      IF s_pgi_ac-low IS NOT INITIAL AND s_pgi_ac-high IS NOT INITIAL.
*      do nothing
      ELSE. " ELSE -> IF s_pgi_ac-low IS NOT INITIAL AND s_pgi_ac-high IS NOT INITIAL
        MESSAGE i976.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF s_pgi_ac-low IS NOT INITIAL AND s_pgi_ac-high IS NOT INITIAL
    ENDIF. " IF s_vbeln IS NOT INITIAL OR
  ENDIF. " IF rb_conf = abap_true
ENDFORM. " F_VALIDATE_S_PGI_AC
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_MAKT
*&---------------------------------------------------------------------*
*      Retrieving Data from Material Description Table
*----------------------------------------------------------------------*
*      -->FP_I_LIPS  internal table LIPS
*      <--FP_I_MAKT  internal table MAKT
*----------------------------------------------------------------------*
FORM f_retrieve_from_makt  USING    fp_i_lips TYPE ty_t_lips
                           CHANGING fp_i_makt TYPE ty_t_makt.
  DATA: li_lips TYPE STANDARD TABLE OF ty_lips INITIAL SIZE 0.
  li_lips[] = fp_i_lips[].
  SORT li_lips BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_lips COMPARING matnr.
  IF li_lips[] IS NOT INITIAL.
    SELECT matnr " Material Description
           spras " Language Key
           maktx " Material Description
    FROM makt    " Material Descriptions
    INTO TABLE fp_i_makt
    FOR ALL ENTRIES IN li_lips
    WHERE matnr = li_lips-matnr
    AND   spras = sy-langu.

    IF sy-subrc IS INITIAL.
      SORT fp_i_makt BY matnr.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDIF. " IF li_lips[] IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_MAKT
*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_S_VKBUR
*&---------------------------------------------------------------------*
*  Validating the Sales Office
*----------------------------------------------------------------------*
FORM f_validate_s_vkbur.
  SELECT vkbur " Sales Office
    FROM tvbur " Organizational Unit: Sales Offices
    UP TO 1 ROWS
    BYPASSING BUFFER
    INTO gv_vkbur
    WHERE vkbur IN s_vkbur.
  ENDSELECT.
  IF sy-subrc NE 0.
* Sales Office is invalid.
    MESSAGE e983. "Sales Office is invalid
  ENDIF. " IF sy-subrc NE 0
ENDFORM. " F_VALIDATE_S_VKBUR
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_PGI_AC_VBELN
*&---------------------------------------------------------------------*
*   Populating the Actual PGI Date in case Delivery Number is provided
*----------------------------------------------------------------------*
*FORM f_populate_pgi_ac_vbeln .
*
*  TYPES: BEGIN OF lty_pgi_ac,
*         vbeln TYPE vbeln_vl,      " Delivery
*         wadat_ist TYPE wadat_ist, " Actual Goods Movement Date
*         END OF lty_pgi_ac.
*
*  DATA: lwa_pgi_ac TYPE LINE OF ty_r_wadat_ist,      " local work area
*        li_pgi_ac TYPE STANDARD TABLE OF lty_pgi_ac. " local internal table
*
*  CONSTANTS: lc_sign TYPE char1 VALUE 'I',     " Sign of type CHAR1
*             lc_option TYPE char04 VALUE 'EQ'. " Option of type CHAR04
*
*  FIELD-SYMBOLS: <lfs_pgi_ac> TYPE lty_pgi_ac.
*
*  SELECT vbeln     " Delivery
*         wadat_ist " Actual Goods Movement Date
*  FROM likp        " SD Document: Delivery Header Data
*  INTO TABLE li_pgi_ac
*  WHERE vbeln IN s_vbeln.
*
*  IF sy-subrc IS INITIAL.
*    SORT li_pgi_ac BY wadat_ist.
*    DELETE li_pgi_ac WHERE wadat_ist IS INITIAL.
*    DELETE ADJACENT DUPLICATES FROM li_pgi_ac COMPARING wadat_ist.
*
*    LOOP AT li_pgi_ac ASSIGNING <lfs_pgi_ac>.
*      lwa_pgi_ac-sign = lc_sign.
*      lwa_pgi_ac-option = lc_option.
*      lwa_pgi_ac-low = <lfs_pgi_ac>-wadat_ist.
*      APPEND lwa_pgi_ac TO i_pgi_date.
*      CLEAR lwa_pgi_ac.
*    ENDLOOP. " LOOP AT li_pgi_ac ASSIGNING <lfs_pgi_ac>
*    REFRESH s_pgi_ac.
*    APPEND LINES OF i_pgi_date TO s_pgi_ac.
*    MODIFY SCREEN.
*  ENDIF. " IF sy-subrc IS INITIAL
*ENDFORM. " F_POPULATE_PGI_AC_VBELN
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_MARC
*&---------------------------------------------------------------------*
*       Retrieve data from MARC Table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  Internal table i_lips
*      <--FP_I_MARC  Internal table i_marc
*----------------------------------------------------------------------*
FORM f_retrieve_from_marc  USING    fp_i_lips TYPE ty_t_lips
                           CHANGING fp_i_marc TYPE ty_t_marc.
  DATA li_lips TYPE ty_t_lips.

  IF fp_i_lips IS NOT INITIAL.
* Copy fp_i_lips into local intern table
    li_lips[] = fp_i_lips[].
    SORT li_lips BY matnr werks.
    DELETE ADJACENT DUPLICATES FROM li_lips COMPARING matnr werks.

    IF li_lips IS NOT INITIAL.

      SELECT matnr " Material Number
             werks " Plant
             sernp " Serial Number Profile
         FROM marc " Plant Data for Material
         INTO TABLE fp_i_marc
         FOR ALL ENTRIES IN li_lips
         WHERE matnr = li_lips-matnr
           AND werks IN s_werks[].
      IF sy-subrc IS INITIAL.
        SORT fp_i_marc BY matnr werks.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_lips IS NOT INITIAL
  ENDIF. " IF fp_i_lips IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_MARC
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_ZLEX_POD
*&---------------------------------------------------------------------*
*       Retrieve From ZLEX_POD
*----------------------------------------------------------------------*
*      -->FP_I_LIKP      internal table I_LIKP
*      <--FP_I_ZLEX_POD  internal table I_ZLEX_POD
*----------------------------------------------------------------------*
FORM f_retrieve_from_zlex_pod  USING    fp_i_vekp     TYPE ty_t_vekp
                               CHANGING fp_i_zlex_pod TYPE ty_t_zlex_pod.

  DATA li_vekp TYPE ty_t_vekp.
  IF fp_i_vekp[] IS NOT INITIAL.
    li_vekp[] = fp_i_vekp[].
    SORT li_vekp BY exidv.
    DELETE ADJACENT DUPLICATES FROM li_vekp COMPARING exidv.

    SELECT hunum " Sales and Distribution Document Number
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
           tracking_number
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638 by U103565(AARYAN) on 10-Jul-2018
         pod_date  " Date
     FROM zlex_pod " LEX Proof Of Delivery
     INTO TABLE fp_i_zlex_pod
     FOR ALL ENTRIES IN li_vekp
     WHERE hunum = li_vekp-exidv.
    IF sy-subrc IS INITIAL.
      SORT fp_i_zlex_pod BY hunum
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
                            tracking_number.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_vekp[] IS NOT INITIAL

ENDFORM. " F_RETRIEVE_FROM_ZLEX_POD

*<--- End of Insert for D3_OTC_RDD_0043_Defect# 2933 by U034229 on 29-May-2017

*---> Begin of Insert for D3_OTC_RDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*&---------------------------------------------------------------------*
*&      Form  ZOTC0043_PF_STATUS
*&---------------------------------------------------------------------*
*       PF Status for POD Report
*----------------------------------------------------------------------*
FORM zotc0043_pf_status  USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'ZOTC0043_PF_STATUS' EXCLUDING rt_extab.

ENDFORM. " ZOTC0043_PF_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_MBEW
*&---------------------------------------------------------------------*
*       Retrieve Data from MBEW Table
*----------------------------------------------------------------------*
*  -->  FP_I_LIPS       Internal Table for I_LIPS
*  <--  FP_I_MBEW       Internal Table for I_MBEW
*----------------------------------------------------------------------*
FORM f_retrieve_from_mbew USING    fp_i_lips TYPE ty_t_lips
                          CHANGING fp_i_mbew TYPE ty_t_mbew.

  DATA: li_lips TYPE ty_t_lips. " local internal table MBEW

  IF fp_i_lips IS NOT INITIAL.
*Copy fp_i_lips into local internal table.
    li_lips[] = fp_i_lips[].
    SORT li_lips BY matnr werks.
    DELETE ADJACENT DUPLICATES FROM li_lips COMPARING matnr werks.

    IF li_lips IS NOT INITIAL.
      SELECT matnr " Material Number
             bwkey " Valuation Area
             bwtar " Valuation Type
             stprs " Standard price
        FROM mbew  " Material Valuation
        INTO TABLE fp_i_mbew
        FOR ALL ENTRIES IN li_lips
        WHERE matnr = li_lips-matnr
        AND   bwkey = li_lips-werks.
      IF sy-subrc IS INITIAL.
        SORT fp_i_mbew BY matnr bwkey.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF li_lips IS NOT INITIAL
  ENDIF. " IF fp_i_lips IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_MBEW

*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_VBUK
*&---------------------------------------------------------------------*
*       Retrieving Data from VBUK Table
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  Internal Table for LIKP
*      <--FP_I_VBUK  Internal Table for VBUK
*----------------------------------------------------------------------*
FORM f_retrieve_from_vbuk  CHANGING fp_i_likp TYPE ty_t_likp
                                    fp_i_vbuk TYPE ty_t_vbuk.

**&& Data Declarations
  FIELD-SYMBOLS: <lfs_likp>   TYPE ty_likp. "Local Field symbol for LIKP


  IF fp_i_likp IS NOT INITIAL. " Checking that FP_I_LIKP is Initial or not
    SELECT vbeln " Sales and Distribution Document Number
           wbstk " Total goods movement status
           pdstk " POD status on header level
      FROM vbuk  " Sales Document: Header Status and Administrative Data
      INTO TABLE fp_i_vbuk
      FOR ALL ENTRIES IN fp_i_likp
      WHERE vbeln = fp_i_likp-vbeln.
    IF sy-subrc IS INITIAL.
      DELETE fp_i_vbuk WHERE pdstk IS INITIAL. " Deleting the Entries where the POD Status is Blank
      DELETE fp_i_vbuk WHERE wbstk NE c_wbstk. " Deleting the Entries where Goods movement status is not Completed
    ENDIF. " IF sy-subrc IS INITIAL

    IF fp_i_vbuk IS NOT INITIAL.
*&-- Filtering out the unwanted records from I_LIKP , based on I_VBUK.
      SORT fp_i_vbuk BY vbeln.
      LOOP AT fp_i_likp ASSIGNING <lfs_likp>.
        READ TABLE fp_i_vbuk TRANSPORTING NO FIELDS WITH KEY vbeln = <lfs_likp>-vbeln
                                                    BINARY SEARCH.
        IF sy-subrc IS NOT INITIAL.
          <lfs_likp>-vbeln = space. " Adding space in Delivery column when the read statement got failed
        ENDIF. " IF sy-subrc IS NOT INITIAL

      ENDLOOP. " LOOP AT fp_i_likp ASSIGNING <lfs_likp>

      DELETE fp_i_likp WHERE vbeln = space. " Deleting the Entries from LIKP table based on the Entries prensent in VBUK table
      IF fp_i_likp IS INITIAL.
        MESSAGE i996.
        LEAVE LIST-PROCESSING.
      ENDIF. " IF fp_i_likp IS INITIAL
    ENDIF. " IF fp_i_vbuk IS NOT INITIAL

  ELSE. " ELSE -> IF fp_i_likp IS NOT INITIAL
    MESSAGE i996.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF fp_i_likp IS NOT INITIAL

ENDFORM. " F_RETRIEVE_FROM_VBUK
*<--- End of Insert For D3_OTC_EDD_0043_Defect# 3179 by U034229 on 13-Jul-2017
*---> Begin of Insert for D3_OTC_RDD_0043_CR#6638 by U103565(AARYAN) on 10-Jul-2018
*&---------------------------------------------------------------------*
*&      Form  F_FETCH_EMI_ENTRIES
*&---------------------------------------------------------------------*
*       Fetching EMI entries from ZDEV_ENH_STATUS
*       -->FP_I_MAT_GROUP Internal Table
*       -->FP_I_BOM_HD    Internal Table
*       -->FP_GV_DAY      Global Varibale
*----------------------------------------------------------------------*

FORM f_fetch_emi_entries CHANGING fp_i_mat_group TYPE ty_t_fkk
                                  fp_i_bom_hd    TYPE ty_t_fkk
                                  fp_gv_day      TYPE num2. " 2-Digit Numeric Value

  DATA: li_zdev_emi   TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Local internal Table
        lwa_emi       TYPE zdev_enh_status,                                  " Local work area for Enhanchment status
        lwa_mat_group TYPE fkk_ranges,                                       " Local work area for Materail group
        lwa_bom_hd    TYPE fkk_ranges.                                       " Local work area for BOM header

  CONSTANTS: lc_enhancement TYPE z_enhancement VALUE 'OTC_RDD_0043', " Default Status
             lc_days        TYPE z_criteria    VALUE 'DAYS',         " Criteria = DAYS
             lc_inst        TYPE z_criteria    VALUE 'INSTALLABLE',  " Criteria = INSTALLABLE
             lc_bom_hd      TYPE z_criteria    VALUE 'CATEGORY'.     " Enh. Criteria


  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_enhancement
    TABLES
      tt_enh_status     = li_zdev_emi.

  DELETE li_zdev_emi WHERE active <> abap_true.

  IF li_zdev_emi IS NOT INITIAL.
    CLEAR fp_gv_day.

    READ TABLE li_zdev_emi INTO lwa_emi
                           WITH KEY criteria = lc_days.

    IF sy-subrc IS INITIAL.
      fp_gv_day = lwa_emi-sel_low.
    ENDIF. " IF sy-subrc IS INITIAL
    CLEAR lwa_emi.

    LOOP AT li_zdev_emi INTO lwa_emi.
      IF lwa_emi-criteria = lc_inst.
        lwa_mat_group-sign = lwa_emi-sel_sign.
        lwa_mat_group-option = lwa_emi-sel_option.
        lwa_mat_group-low    = lwa_emi-sel_low.
        APPEND lwa_mat_group TO fp_i_mat_group.
        CLEAR  lwa_mat_group.
      ELSEIF lwa_emi-criteria = lc_bom_hd.
        lwa_bom_hd-sign = lwa_emi-sel_sign.
        lwa_bom_hd-option = lwa_emi-sel_option.
        lwa_bom_hd-low    = lwa_emi-sel_low.
        APPEND lwa_bom_hd TO fp_i_bom_hd.
        CLEAR  lwa_bom_hd.
      ENDIF. " IF lwa_emi-criteria = lc_inst
    ENDLOOP. " LOOP AT li_zdev_emi INTO lwa_emi
    CLEAR lwa_emi.
  ENDIF. " IF li_zdev_emi IS NOT INITIAL

ENDFORM. " F_FETCH_EMI_ENTRIES
*&---------------------------------------------------------------------*
*&      Form  F_GET_HIGHER_HU
*&---------------------------------------------------------------------*
*       Fetching Higher level HU
*----------------------------------------------------------------------*
*      -->FP_I_VEKP  Handling Unit - Header Table
*      <--FP_I_HU_HEADER
*----------------------------------------------------------------------*
FORM f_get_higher_hu  USING    fp_i_vekp TYPE ty_t_vekp
                      CHANGING fp_i_hu_header TYPE hum_hu_header_t.

  DATA: li_header    TYPE hum_hu_header_t, "Local internal table
        li_venum     TYPE hum_venum_t,     "Local internal table
        lwa_venum    TYPE hum_venum.       "Internal Handling Unit Number
  FIELD-SYMBOLS: <lfs_vekp> TYPE ty_vekp. "Local field symbol
***   &-- Fetch the header HU's in case it is a nested HU scenario
  LOOP AT fp_i_vekp ASSIGNING <lfs_vekp>.
    lwa_venum-venum = <lfs_vekp>-venum.
    APPEND lwa_venum TO li_venum.

    CALL FUNCTION 'HU_GET_HUS'
      EXPORTING
        if_more_hus = abap_true
        it_venum    = li_venum
      IMPORTING
        et_header   = li_header
      EXCEPTIONS
        hus_locked  = 1
        no_hu_found = 2
        fatal_error = 3
        OTHERS      = 4.
    IF sy-subrc IS INITIAL.

      APPEND LINES OF li_header TO fp_i_hu_header.
      REFRESH: li_header,
               li_venum.
      CLEAR:lwa_venum.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDLOOP. " LOOP AT fp_i_vekp ASSIGNING <lfs_vekp>
  IF <lfs_vekp> IS ASSIGNED.
    UNASSIGN <lfs_vekp>.
  ENDIF. " IF <lfs_vekp> IS ASSIGNED
  SORT fp_i_hu_header BY venum.

ENDFORM. " F_GET_HIGHER_HU

*&---------------------------------------------------------------------*
*&      Form  F_RETRIVE_FROM_TVRO
*&---------------------------------------------------------------------*
*       Retrieve Data from Routes
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  Internal Table for Delivery Header
*      <--FP_I_TVRO  Internal Table for Routes
*----------------------------------------------------------------------*
FORM f_retrive_from_tvro  USING    fp_i_likp TYPE ty_t_likp
                          CHANGING fp_i_tvro TYPE ty_t_tvro .

  DATA : li_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0. "local internal table
  IF fp_i_likp IS NOT INITIAL.
    li_likp[] = fp_i_likp[]. " Assigning fp_i_likp to local internal table
    SORT li_likp BY route.
    DELETE ADJACENT DUPLICATES FROM li_likp COMPARING route. " Deleting dulicates
    SELECT route     "Route
           traztd    "Transit time
           FROM tvro " Routes
           INTO TABLE fp_i_tvro
           FOR ALL ENTRIES IN li_likp
           WHERE route = li_likp-route.
    IF sy-subrc IS INITIAL.
      SORT fp_i_tvro BY route.
      FREE li_likp.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_likp IS NOT INITIAL

ENDFORM. " F_RETRIVE_FROM_TVRO

*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_ZLEX_POD_HIS
*&---------------------------------------------------------------------*
*       Retrieving Data from POD History table
*----------------------------------------------------------------------*
*      -->FP_I_VEKP  Handling Unit - Header Internaltable
*      <--FP_I_POD_HISTORY  Interanl table for POD history table
*----------------------------------------------------------------------*
FORM f_retrieve_from_zlex_pod_his  USING    fp_i_vekp TYPE ty_t_vekp
                                   CHANGING fp_i_pod_history TYPE ty_t_pod_his.

  DATA li_vekp TYPE ty_t_vekp. "Local internal table
  IF fp_i_vekp[] IS NOT INITIAL.
    li_vekp[] = fp_i_vekp[].
    SORT li_vekp BY exidv.
    DELETE ADJACENT DUPLICATES FROM li_vekp COMPARING exidv. "Deleting duplicates of exidv

    SELECT hunum           " Sales and Distribution Document Number
          tracking_number  " tracking Number
           pod_date        " Date
     FROM zlex_pod_history " LEX Proof Of Delivery History
     INTO TABLE fp_i_pod_history
     FOR ALL ENTRIES IN li_vekp
     WHERE hunum = li_vekp-exidv.
    IF sy-subrc IS INITIAL.
      SORT fp_i_pod_history BY hunum
*---> Begin of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
                               tracking_number
                               pod_date
                               DESCENDING.
      DELETE ADJACENT DUPLICATES FROM fp_i_pod_history COMPARING hunum tracking_number.
      SORT fp_i_pod_history BY hunum tracking_number.
*<--- End of Insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 21-Aug-2018
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_vekp[] IS NOT INITIAL
ENDFORM. " F_RETRIEVE_FROM_ZLEX_POD_HIS

*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_ERROR
*&---------------------------------------------------------------------*
*       Retrieve Data from zlex_pod_error
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  SD Document: Delivery Header Data
*      <--FP_I_ERROR  Interanl table to store from zlex_pod_error
*----------------------------------------------------------------------*
FORM f_retrieve_error  USING    fp_i_likp TYPE ty_t_likp
                       CHANGING fp_i_error TYPE ty_t_error.
  IF fp_i_likp IS NOT INITIAL.
    SELECT vbeln         " Sales and Distribution Document Number
           status        " message
     FROM zlex_pod_error " LEX error status
     INTO TABLE fp_i_error
     FOR ALL ENTRIES IN fp_i_likp
     WHERE vbeln = fp_i_likp-vbeln.
    IF sy-subrc IS INITIAL.
      SORT fp_i_error BY vbeln.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_likp IS NOT INITIAL
ENDFORM. " F_RETRIEVE_ERROR
*&---------------------------------------------------------------------*
*&      Form  F_RETRIVE_FROM_VBPA
*&---------------------------------------------------------------------*
*       Retireve data from Sales Document: Partner
*----------------------------------------------------------------------*
*      -->FP_I_LIKP  SD Document: Delivery Header Data internal table
*      --FP_I_VBPA  Sales Document: Partner internal table
*----------------------------------------------------------------------*
FORM f_retrive_from_vbpa  USING    fp_i_likp TYPE ty_t_likp
                          CHANGING fp_i_vbpa TYPE ty_t_vbpa.

  CONSTANTS: lc_we TYPE parvw VALUE 'WE'. " local constants for Partner Function

  IF fp_i_likp IS NOT INITIAL.

    SELECT vbeln "Delivery Number
          parvw  "Partner Function
          land1  "Counrty code
     FROM vbpa   " Sales Document: Partner
     INTO TABLE fp_i_vbpa
  FOR ALL ENTRIES IN fp_i_likp
  WHERE vbeln = fp_i_likp-vbeln
     AND parvw = lc_we.
    IF sy-subrc IS INITIAL.
      SORT fp_i_vbpa BY vbeln.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF fp_i_likp IS NOT INITIAL
ENDFORM. " F_RETRIVE_FROM_VBPA
*&---------------------------------------------------------------------*
*&      Form  F_RETRIEVE_FROM_SER01
*&---------------------------------------------------------------------*
*       Retrive data for serial number
*----------------------------------------------------------------------*
*      -->FP_I_LIPS     Internal table
*      <--FP_I_SER01    Internal table
*      <--FP_I_OBJK     Internal table
*      <--FP_I_EQUI     Internal table
*      <FP_I_SERIAL_NUM Internal table
*----------------------------------------------------------------------*
FORM f_retrieve_from_ser01  USING    fp_i_lips       TYPE ty_t_lips
                            CHANGING fp_i_ser01      TYPE ty_t_ser01
                                     fp_i_objk       TYPE ty_t_objk
                                     fp_i_equi       TYPE ty_t_equi
                                     fp_i_serial_num TYPE ty_t_serial_num.

  DATA : li_objk        TYPE STANDARD TABLE OF ty_objk INITIAL SIZE 0, "Local internal table
         lwa_serial_num TYPE ty_serial_num,                            "Local work area
         lwa_equi       TYPE ty_equi,                                  "Local work area
         lwa_objk       TYPE ty_objk,                                  "Local work area
         lwa_ser01      TYPE ty_ser01.                                 "Local work area
 "First Select Header information of Serial Numbers corresponding
 "to delivery Number
  IF fp_i_lips IS NOT INITIAL.
    SELECT obknr   "Object list number
           lief_nr "Delivery
           posnr   "Delivery Item
       FROM ser01  "Document Header for Serial Numbers for Delivery
       INTO TABLE fp_i_ser01
      FOR ALL ENTRIES IN fp_i_lips
"Using secondary index
       WHERE lief_nr = fp_i_lips-vbeln
       AND   posnr   = fp_i_lips-posnr.
    IF sy-subrc IS INITIAL.
      SORT fp_i_ser01 BY obknr.
      SELECT    obknr "Object list number
                obzae "Object list counters
                equnr "Equipment Number
                sernr "Serial Number
                matnr "Material Number
           FROM objk  "Plant Maintenance Object List
           INTO TABLE fp_i_objk
        FOR ALL ENTRIES IN fp_i_ser01
          WHERE obknr = fp_i_ser01-obknr.
      IF sy-subrc IS INITIAL.
        SORT fp_i_objk BY equnr.
        li_objk[] = fp_i_objk[].
        DELETE ADJACENT DUPLICATES FROM li_objk COMPARING equnr.
        IF li_objk IS NOT INITIAL.
          SELECT equnr "Equipment Number
                 inbdt "Start-up Date of the Technical Object
           FROM  equi  " Equipment master data
           INTO TABLE fp_i_equi
            FOR ALL ENTRIES IN li_objk
          WHERE equnr = li_objk-equnr.
          IF sy-subrc IS INITIAL.
            SORT fp_i_equi BY equnr.
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_objk IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF sy-subrc IS INITIAL

    LOOP AT fp_i_equi INTO lwa_equi.
      lwa_serial_num-equnr = lwa_equi-equnr.
      lwa_serial_num-inbdt = lwa_equi-inbdt.
      READ TABLE fp_i_objk INTO lwa_objk WITH KEY equnr = lwa_equi-equnr
                                                   BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lwa_serial_num-obknr = lwa_objk-obknr.
        lwa_serial_num-sernr = lwa_objk-sernr.
        READ TABLE fp_i_ser01 INTO lwa_ser01 WITH  KEY obknr = lwa_objk-obknr
                                                            BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          lwa_serial_num-vbeln = lwa_ser01-lief_nr.
          lwa_serial_num-posnr = lwa_ser01-posnr.
        ENDIF. " IF sy-subrc IS INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
      APPEND lwa_serial_num TO fp_i_serial_num.
      CLEAR : lwa_serial_num,
              lwa_objk,
              lwa_ser01.
    ENDLOOP. " LOOP AT fp_i_equi INTO lwa_equi

    SORT fp_i_serial_num BY vbeln posnr.

  ENDIF. " IF fp_i_lips IS NOT INITIAL
  FREE li_objk.
ENDFORM. " F_RETRIEVE_FROM_SER01
*&---------------------------------------------------------------------*
*&      Form  F_GET_START_DATE
*&---------------------------------------------------------------------*
*       Getting Start Date
*----------------------------------------------------------------------*
*      <--FP_I_FINAL  Internal table
*      <--FP_I_INST   Internal table
*----------------------------------------------------------------------*
FORM f_get_start_date  CHANGING  fp_i_final TYPE ty_t_final
                                 fp_i_inst  TYPE ty_t_inst.

  DATA : li_inst_del     TYPE STANDARD TABLE OF ty_final,      "Local internal table for Final
         li_bom_head     TYPE STANDARD TABLE OF ty_final,      "Local internal table for Final
         li_bom_comp     TYPE STANDARD TABLE OF ty_final,      "Local internal table for Final
         li_serial_num   TYPE STANDARD TABLE OF ty_serial_num, "Local internal table for serial number
         lwa_inst_del    TYPE ty_final,                        "Local work area
         lwa_bom_head    TYPE ty_final,                        "Local work area
         lwa_inst        TYPE ty_inst,                         "Local work area
         lwa_bom_comp    TYPE ty_final,                        "Local work area
         lwa_serial_num  TYPE ty_serial_num,                   "Local work area
         lwa_serial_num1 TYPE ty_serial_num,                   "Local work area
         lv_tabix1       TYPE sy-tabix,                        "Index of Internal Tables
         lv_tabix2       TYPE sy-tabix,                        "Index of Internal Tables
         lv_tabix3       TYPE sy-tabix,                        "Index of Internal Tables
         lv_rec_num      TYPE int4,                            "Natural Number
*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
         li_bom_comp_tmp TYPE STANDARD TABLE OF ty_final,
         lv_tabix4       TYPE sy-tabix, "Index of Internal Tables
         lv_tabix5       TYPE sy-tabix. "Index of Internal Table
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018

  FIELD-SYMBOLS: <lfs_final>     TYPE ty_final, "Local field symbol
                 <lfs_inst_del>  TYPE ty_final, "Local field symbol
                 <lfs_inst_del1> TYPE ty_final. "Local field symbol


  SORT fp_i_inst BY vbeln inst_delivery.
**---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
* "This loop is to Populate “Installable delivery” value for all the delivery line items
* "if delivery has at least one installable product.
*  LOOP AT fp_i_final ASSIGNING <lfs_final>.
*
*    READ TABLE fp_i_inst INTO lwa_inst WITH KEY vbeln = <lfs_final>-vbeln
*                                            inst_delivery = abap_true
*                                            BINARY SEARCH.
*    IF sy-subrc IS INITIAL.
*      <lfs_final>-inst_delivery = abap_true.
*    ENDIF. " IF sy-subrc IS INITIAL
*
*  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>
*
* "Unassigning the field symbol
*  IF <lfs_final> IS ASSIGNED.
*    UNASSIGN <lfs_final>.
*  ENDIF. " IF <lfs_final> IS ASSIGNED
**<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
 "Assigning data from final internal table to internal table
  li_inst_del = li_bom_comp = li_bom_head = fp_i_final.

  SORT li_inst_del BY vbeln.
*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
  DELETE li_inst_del WHERE inst_delivery IS INITIAL.
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
  DELETE ADJACENT DUPLICATES FROM li_inst_del COMPARING vbeln. " Getting only single delivery item
*---> Begin of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
*  DELETE li_inst_del WHERE inst_delivery IS INITIAL.
*<--- End of delete for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
 "If Installable delivery doesn't have sales BOM header ZBH1 and ZBH4
  DELETE li_bom_head WHERE pstyv NOT IN i_bom_hd.
  SORT li_bom_head BY vbeln.



  DELETE li_bom_comp WHERE pstyv IN i_bom_hd.
  SORT li_bom_comp BY vbeln posnr.
  DELETE ADJACENT DUPLICATES FROM li_bom_comp COMPARING vbeln posnr.
*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
  li_bom_comp_tmp[] = li_bom_comp[].
  SORT li_bom_comp_tmp BY vbeln inst_delivery.
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018

 "Loop into li_inst_del(Installable delivery internal table)

  LOOP AT li_inst_del  ASSIGNING <lfs_inst_del>.
 "Getting BOM header for delivery
    READ TABLE li_bom_head WITH KEY vbeln = <lfs_inst_del>-vbeln
                                   TRANSPORTING NO FIELDS
                                   BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lv_tabix1 = sy-tabix.

      LOOP AT li_bom_head INTO lwa_bom_head FROM lv_tabix1.

        IF <lfs_inst_del>-vbeln <> lwa_bom_head-vbeln. "if installabe delivery has BOM header
          EXIT.
        ELSE. " ELSE -> IF <lfs_inst_del>-vbeln <> lwa_bom_head-vbeln
          IF lwa_bom_head-inst_delivery = abap_true.

            READ TABLE li_bom_comp WITH KEY vbeln = lwa_bom_head-vbeln
                                            TRANSPORTING NO FIELDS
                                            BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lv_tabix2 = sy-tabix.

              LOOP AT li_bom_comp INTO lwa_bom_comp FROM lv_tabix2.
                IF lwa_bom_comp-vbeln <> lwa_bom_head-vbeln.
                  EXIT.
                ELSE. " ELSE -> IF lwa_bom_comp-vbeln <> lwa_bom_head-vbeln
                  READ TABLE i_serial_num WITH KEY vbeln = lwa_bom_comp-vbeln
                                                   posnr = lwa_bom_comp-posnr
                                                   TRANSPORTING NO FIELDS
                                                   BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    lv_tabix3 = sy-tabix.

 "Getting multiple serial nos.
                    LOOP AT i_serial_num INTO lwa_serial_num FROM lv_tabix3.
                      IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                         lwa_serial_num-posnr = lwa_bom_comp-posnr.
                        APPEND lwa_serial_num TO li_serial_num.

                      ELSE. " ELSE -> IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                        EXIT.
                      ENDIF. " IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                    ENDLOOP. " LOOP AT i_serial_num INTO lwa_serial_num FROM lv_tabix3
                    CLEAR lv_tabix3.
                  ENDIF. " IF sy-subrc IS INITIAL

                ENDIF. " IF lwa_bom_comp-vbeln <> lwa_bom_head-vbeln
              ENDLOOP. " LOOP AT li_bom_comp INTO lwa_bom_comp FROM lv_tabix2
              CLEAR lv_tabix2.
            ENDIF. " IF sy-subrc IS INITIAL

*---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
          ELSE. " ELSE -> IF lwa_bom_head-inst_delivery = abap_true
 "If Header is Non-Installable then we have to pick the
 "date from the Installable product in it
            READ TABLE li_bom_comp_tmp WITH KEY vbeln = lwa_bom_head-vbeln
                                                inst_delivery = abap_true
                                                TRANSPORTING NO FIELDS
                                                BINARY SEARCH.
            IF sy-subrc IS INITIAL.
              lv_tabix4 = sy-tabix.

              LOOP AT li_bom_comp_tmp INTO lwa_bom_comp FROM lv_tabix4.
                IF lwa_bom_comp-vbeln <> lwa_bom_head-vbeln.
                  EXIT.
                ELSE. " ELSE -> IF lwa_bom_comp-vbeln <> lwa_bom_head-vbeln
                  READ TABLE i_serial_num WITH KEY vbeln = lwa_bom_comp-vbeln
                                                   posnr = lwa_bom_comp-posnr
                                                   TRANSPORTING NO FIELDS
                                                   BINARY SEARCH.
                  IF sy-subrc IS INITIAL.
                    lv_tabix5 = sy-tabix.
 "Getting multiple serial nos.
                    LOOP AT i_serial_num INTO lwa_serial_num FROM lv_tabix5.
                      IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                         lwa_serial_num-posnr = lwa_bom_comp-posnr.
                        APPEND lwa_serial_num TO li_serial_num.

                      ELSE. " ELSE -> IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                        EXIT.
                      ENDIF. " IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                    ENDLOOP. " LOOP AT i_serial_num INTO lwa_serial_num FROM lv_tabix5
                    CLEAR lv_tabix5.
                  ENDIF. " IF sy-subrc IS INITIAL

                ENDIF. " IF lwa_bom_comp-vbeln <> lwa_bom_head-vbeln
              ENDLOOP. " LOOP AT li_bom_comp_tmp INTO lwa_bom_comp FROM lv_tabix4
              CLEAR lv_tabix4.
            ENDIF. " IF sy-subrc IS INITIAL
*<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018

          ENDIF. " IF lwa_bom_head-inst_delivery = abap_true
        ENDIF. " IF <lfs_inst_del>-vbeln <> lwa_bom_head-vbeln

      ENDLOOP. " LOOP AT li_bom_head INTO lwa_bom_head FROM lv_tabix1
      CLEAR lv_tabix1.

    ELSE. " ELSE -> IF sy-subrc IS INITIAL

      READ TABLE li_bom_comp WITH KEY vbeln = <lfs_inst_del>-vbeln
                                TRANSPORTING NO FIELDS
                                BINARY SEARCH.
      IF sy-subrc IS INITIAL. "If installable delkivery has BOM header
        lv_tabix1 = sy-tabix.

        LOOP AT li_bom_comp INTO lwa_bom_comp FROM lv_tabix1.
          IF lwa_bom_comp-vbeln <> <lfs_inst_del>-vbeln.
            EXIT. " EXIT loop if delivery no. has not BOM header or installable
          ELSE. " ELSE -> IF lwa_bom_comp-vbeln <> <lfs_inst_del>-vbeln
            IF lwa_bom_comp-inst_delivery IS NOT INITIAL.
              READ TABLE i_serial_num WITH KEY vbeln = lwa_bom_comp-vbeln
                                              posnr = lwa_bom_comp-posnr
                                              TRANSPORTING NO FIELDS
                                              BINARY SEARCH.
              IF sy-subrc IS INITIAL.
                lv_tabix2 = sy-tabix.
                LOOP AT i_serial_num INTO lwa_serial_num FROM lv_tabix2.
                  IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                     lwa_serial_num-posnr = lwa_bom_comp-posnr.
                    APPEND lwa_serial_num TO li_serial_num. "Getting Serialized deliveries
                  ELSE. " ELSE -> IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                    EXIT.
                  ENDIF. " IF lwa_serial_num-vbeln = lwa_bom_comp-vbeln AND
                ENDLOOP. " LOOP AT i_serial_num INTO lwa_serial_num FROM lv_tabix2

                CLEAR lv_tabix2.
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF lwa_bom_comp-inst_delivery IS NOT INITIAL
          ENDIF. " IF lwa_bom_comp-vbeln <> <lfs_inst_del>-vbeln
        ENDLOOP. " LOOP AT li_bom_comp INTO lwa_bom_comp FROM lv_tabix1
        CLEAR lv_tabix1.
      ENDIF. " IF sy-subrc IS INITIAL

    ENDIF. " IF sy-subrc IS INITIAL


    SORT li_serial_num BY inbdt. " Sorting to get blank start date on the top
    lv_rec_num = lines( li_serial_num ). " Counting no. of items in the table
    READ TABLE li_serial_num INTO lwa_serial_num1 INDEX 1.
 "If startup date is missing for the at least one equipment
 " then displays blank value as customer acceptance date for the whole delivery.
    IF lwa_serial_num1-inbdt IS INITIAL.
      <lfs_inst_del>-start_date = lwa_serial_num1-inbdt.
    ELSE. " ELSE -> IF lwa_serial_num1-inbdt IS INITIAL
      READ TABLE li_serial_num INTO lwa_serial_num1 INDEX lv_rec_num.
      IF sy-subrc IS INITIAL.
        <lfs_inst_del>-start_date = lwa_serial_num1-inbdt.
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF lwa_serial_num1-inbdt IS INITIAL


    FREE li_serial_num.

  ENDLOOP. " LOOP AT li_inst_del ASSIGNING <lfs_inst_del>

  SORT li_inst_del BY vbeln.

  LOOP AT fp_i_final ASSIGNING <lfs_inst_del1>.
    CLEAR lwa_inst_del.
    READ TABLE li_inst_del INTO lwa_inst_del WITH KEY vbeln = <lfs_inst_del1>-vbeln
                                                   BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_inst_del1>-start_date = lwa_inst_del-start_date. "getting start date for delivery
    ENDIF. " IF sy-subrc IS INITIAL

  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_inst_del1>

**---> Begin of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018
* "This loop is to Populate “Installable delivery” value for all the delivery line items
* "if delivery has at least one installable product.
  LOOP AT fp_i_final ASSIGNING <lfs_final>.

    READ TABLE fp_i_inst INTO lwa_inst WITH KEY vbeln = <lfs_final>-vbeln
                                            inst_delivery = abap_true
                                            BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      <lfs_final>-inst_delivery = abap_true.
    ENDIF. " IF sy-subrc IS INITIAL

  ENDLOOP. " LOOP AT fp_i_final ASSIGNING <lfs_final>

 "Unassigning the field symbol
  IF <lfs_final> IS ASSIGNED.
    UNASSIGN <lfs_final>.
  ENDIF. " IF <lfs_final> IS ASSIGNED

  FREE:    li_inst_del,     "Local internal table for Final
           li_bom_head,     "Local internal table for Final
           li_bom_comp,     "Local internal table for Final
           li_serial_num,   "Local internal table for serial number
           li_bom_comp_tmp. "Local internal table for Final
**<--- End of insert for D3_OTC_RDD_0043 CR#6638_FUT_Issues by AMOHAPA on 12-Sep-2018


ENDFORM. " F_GET_START_DATE
*<--- End of Insert for D3_OTC_RDD_0043_CR#6638 by U103565(AARYAN) on 10-Jul-2018
