*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_COMPARE_PRICE
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0011O_COMPARE_PRICE                               *
* TITLE      :  List Price Pop Up                                      *
* DEVELOPER  :  Rohit Verma                                            *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_EDD_0011_Pricing Routine Enhancement (CR#1354)      *
*----------------------------------------------------------------------*
* DESCRIPTION: Check if price of list comparison condition (ZCMP) is   *
*              gretaer than or equal to zero than issue a pop up       *
*              message.                                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 12-May-2014 RVERMA   E1DK913520 Initial Dev - CR#1354                *
* 05-Nov-2014 SPAUL2   E1DK915045 CR 1536/ INC0176486 : The list price *
*                                 pop up should be restricted to sales *
*                                 related transactions like VA01, VA02,*
*                                 VA03, VA41, VA42, VA43. It should    *
*                                 not appear in any other transactions.*
*&---------------------------------------------------------------------*

  TYPES:
    BEGIN OF lty_control,
      mparameter  TYPE enhee_parameter, "Parameter
      mvalue1     TYPE z_mvalue_low,    "Value Low
      mvalue2     TYPE z_mvalue_high,   "Value High
    END OF lty_control,
*&--Table type for control table
    lty_t_control TYPE STANDARD TABLE OF lty_control.

*&--Local Constant Declaration
  CONSTANTS:
    lc_mprog      TYPE programm        VALUE 'ZOTCN0011O_COMPARE_PRICE',  "Program Name
    lc_mpar_kschl TYPE enhee_parameter VALUE 'KSCHL', "Parameter Name
    lc_mpar_auart TYPE enhee_parameter VALUE 'AUART', "Parameter Name
    lc_active     TYPE char01          VALUE 'X',     "Active
    lc_rsign_i    TYPE char1           VALUE 'I',     "Sign:Include
    lc_roptn_eq   TYPE char2           VALUE 'EQ',    "Option:Equal
    lc_ustyp_a    TYPE xuustyp         VALUE 'A',     "Dialog User
    lc_create     TYPE trtyp           VALUE 'H',     "Creation Mode
    lc_change     TYPE trtyp           VALUE 'V',     "Change Mode
    lc_bt_cont    TYPE syucomm         VALUE 'CONT',  "Continue Button
    lc_bt_ent1    TYPE syucomm         VALUE 'ENT1',  "Enter Button
* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
    lc_mpar_agdiv TYPE enhee_parameter VALUE 'T180-AGDIV',
    lc_mpar_trvog TYPE enhee_parameter VALUE 'T180-TRVOG'.
* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486

*&--Local Data Declaration
  DATA:
    lv_cond     TYPE kscha,   "ZCMP Condition Type
    lv_fcode    TYPE syucomm, "SY-UCOMM value
    lv_ustyp    TYPE xuustyp, "User Type

    li_note1    TYPE STANDARD TABLE OF txw_note, "Note with plain text
    li_control  TYPE lty_t_control,               "Control Data
    li_auart_r  TYPE RANGE OF auart,             "Order Type Table

    lwa_auart_r LIKE LINE OF li_auart_r,         "Order Type Workarea
    lwa_note1   TYPE txw_note,                   "Note with plain text
* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
    li_control_auart  TYPE lty_t_control,          " Control Data
    li_control_trvog  TYPE lty_t_control,          " Control Data
    li_trvog_r        TYPE RANGE OF trvog,         " Range table Transportation group
    lwa_trvog_r       LIKE LINE OF li_trvog_r,     " Wrk area for Transportation group
    lv_prog           TYPE z_mvalue_low.
* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486

*&--Local Field Symbol Declaration
  FIELD-SYMBOLS:
    <lfs_xvbap1>  TYPE vbapvb,         "Item str
    <lfs_control> TYPE lty_control,     "Control Data
    <lfs_xkomv>   TYPE komv.           "Condition record str

*&--this enhancement should not trigger when order is created through idoc
  IF sy-batch IS INITIAL AND
     idoc_number IS INITIAL.

*&--Restrict the enhancement for Dialogue users (USR02-USTYP = 'A')
    SELECT SINGLE ustyp
      FROM usr02
      INTO lv_ustyp
      WHERE bname EQ sy-uname.

    IF sy-subrc EQ 0 AND
       lv_ustyp EQ lc_ustyp_a AND      "Dialog User Check

       ( t180-trtyp EQ lc_create OR   "Order Creation VA01
         t180-trtyp EQ lc_change ).   "Order Change VA02

*&--Fetch control data
      SELECT mparameter
             mvalue1
             mvalue2
        FROM zotc_prc_control
        INTO TABLE li_control
        WHERE vkorg      EQ vbak-vkorg
          AND vtweg      EQ vbak-vtweg
          AND mprogram   EQ lc_mprog
          AND mparameter IN (lc_mpar_kschl,lc_mpar_auart,
* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
        lc_mpar_agdiv,lc_mpar_trvog)
* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
          AND mactive    EQ lc_active
          AND soption    EQ lc_roptn_eq.

      IF sy-subrc EQ 0.

* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
*&--Restrict the enhancement for sales related transactions like VA01, VA02, VA03,
*   VA41, VA42, VA43. It should not appear in any other transactions.
*&--No Binary search is used as there are few entries (<=6) in LI_CONTROL

        READ TABLE li_control ASSIGNING <lfs_control>
                              WITH KEY mparameter = lc_mpar_agdiv.
        IF sy-subrc = 0.
          MOVE <lfs_control>-mvalue1 TO lv_prog.
        ENDIF.

*&--Build range table for transaction group
        li_control_trvog[] = li_control[].
        DELETE li_control_trvog WHERE mparameter NE lc_mpar_trvog.

        LOOP AT li_control_trvog ASSIGNING <lfs_control>.
          lwa_trvog_r-sign   = lc_rsign_i.
          lwa_trvog_r-option = lc_roptn_eq.
          MOVE <lfs_control>-mvalue1 TO lwa_trvog_r-low.

          APPEND lwa_trvog_r TO li_trvog_r.
          CLEAR lwa_trvog_r.
        ENDLOOP.

* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486

*&--Read condition type value of list comparison price (ZR00)
*&--No Binary search is used as there are few entries (<=6) in LI_CONTROL
        READ TABLE li_control ASSIGNING <lfs_control>
                              WITH KEY mparameter = lc_mpar_kschl.
*
        IF sy-subrc EQ 0.
          MOVE <lfs_control>-mvalue1 TO lv_cond.
        ENDIF.

* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
*        DELETE li_control WHERE mparameter = lc_mpar_kschl.
        li_control_auart[] = li_control[].
        DELETE li_control WHERE mparameter ne lc_mpar_auart.
* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486

*&--Build range table for Order Type
        LOOP AT li_control ASSIGNING <lfs_control>.
          lwa_auart_r-sign = lc_rsign_i.
          lwa_auart_r-option = lc_roptn_eq.
          MOVE <lfs_control>-mvalue1 TO lwa_auart_r-low.

          APPEND lwa_auart_r TO li_auart_r.
          CLEAR lwa_auart_r.
        ENDLOOP.
      ENDIF.

* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
*&--Restrict the enhancement for sales related transactions like VA01, VA02, VA03,
*   VA41, VA42, VA43. It should not appear in any other transactions.
      IF  t180-tcode EQ sy-tcode
          AND t180-agidv EQ lv_prog
          AND t180-trvog IN li_trvog_r.
* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486

        IF lv_cond IS NOT INITIAL AND    "Condition type value found in control table
           vbak-auart IN li_auart_r.    "Order Type in control table/Range table

*&--Process on each item of order
          LOOP AT xvbap ASSIGNING <lfs_xvbap1>.

*&--Read price for condition type ZCMP of an item
            READ TABLE xkomv ASSIGNING <lfs_xkomv>
                             WITH KEY kposn = <lfs_xvbap1>-posnr
                                      kschl = lv_cond.

            IF sy-subrc EQ 0.
*&--if list comparison price is greater than or equal to zero
*&--i.e. final price is greater than or equal to list price of an item
              IF <lfs_xkomv>-kwert GE 0.

                MESSAGE e142(zotc_msg) INTO lwa_note1-line
                                       WITH <lfs_xvbap1>-posnr.
                APPEND lwa_note1 TO li_note1.
                CLEAR lwa_note1.

              ENDIF.    "IF <lfs_xkomv>-kwert GE 0.

            ENDIF.    "SY_SUBRC check of Read statement on XKOMV

          ENDLOOP.    "LOOP AT xvbap ASSIGNING <lfs_xvbap1>.

*&--Check if LI_NOTE table has records than display the message
          IF li_note1[] IS NOT INITIAL.

*&--Insert Heading 'Warnings !!' text message
            MESSAGE e143(zotc_msg) INTO lwa_note1-line.   "Warning Message
            INSERT lwa_note1 INTO li_note1 INDEX 1.
            CLEAR lwa_note1.
            INSERT lwa_note1 INTO li_note1 INDEX 2.       "Add a blank line for better look

            lv_fcode = sy-ucomm.

*&--Display the text editor with the errors
            CALL FUNCTION 'ZOTC_TXW_TEXTNOTE_EDIT'
              EXPORTING
                edit_mode = space
              TABLES
                t_txwnote = li_note1.

*&--If CONT (Continue) button not pressed than Order will not saved and
*&--it remains on same screen
            IF sy-ucomm NE lc_bt_cont.
*&--Set the FCODE and sy-ucomm with the ENTER code to keep the control
*&--in the same screen instead of saving
              fcode    = lc_bt_ent1.
              sy-ucomm = lc_bt_ent1.

              SET SCREEN sy-dynnr.
              LEAVE SCREEN.
            ELSE.
              sy-ucomm = lv_fcode.
            ENDIF.    "SY-UCOMM Check

          ENDIF.    "IF li_note1[] IS NOT INITIAL.

        ENDIF.    "LV_COND not intial check
* Begin-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
      ENDIF.
* End-of-change by SPAUL2 on 05-Nov-2014 for CR 1536/ INC0176486
    ENDIF.    "Dialog User Check

  ENDIF.    "IF sy-batch IS INITIAL.
