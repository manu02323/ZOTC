*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_CHECK_REAGENT_REV
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0011O_CHECK_REAGENT_REV(Include)                  *
* TITLE      :  Check Reagent Revenue                                  *
* DEVELOPER  :  Gautam Nag                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   Def#475(OTC_EDD_0011)                                   *
*----------------------------------------------------------------------*
* DESCRIPTION: Check the sum total condition values of ZSER, ZRER and  *
*              ZEQR is equal to the 100% value of ZB00 or YC00 ( a     *
*              tolerance of 0.001% allowed); else error message and stop
*              the user from saving the document.                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 02-AUG-2013 GNAG     E1DK911186 Initial dev - Def#475: Check Reagent *
*                                 Revenue total matches 100%           *
* 21-MAR-2014 BMAJI    E1DK912937 Def#1296: Cleared all local variables*
*                                 outside the IF condition check within*
*                                 the LOOP                             *
* 15-May-2014 SNIGAM   E1DK913520 Removed the Hardcoding of condition  *
*                                 types used in this include CR-1354   *
* 05-May-2016 U033870  E1DK917543 Changes against D3_OTC_CDD_0005_0007_*
*                                 0140     when this method is trigger *
*                                 from BDC / IDOC ref, then supress the*
*                                 error pop-up and give IDOC error     *
*&---------------------------------------------------------------------*

* Local constants
CONSTANTS:
  lc_true       TYPE char1   VALUE 'X',      " Value 'X'
  lc_program    TYPE char50  VALUE 'ZOTCN0011O_CHECK_REAGENT_REV', " Program Name
  lc_prognam    TYPE programm  VALUE 'EDD0011_RV63A916', " Program Name  "Added by SNIGAM on 15-May-2014 CR-1354
  lc_parameter  TYPE char5     VALUE 'KSCHL', "Condition Type   "Added by SNIGAM on 15-May-2014 CR-1354
  lc_fld_name   TYPE char50  VALUE 'VBAK-AUART', " Field Name for Order Type
  lc_fld_name_pstyv TYPE char50 VALUE 'VBAP-PSTYV',  " Field name for Item Cat
  lc_sign_i     TYPE char1   VALUE 'I',      " Sign I
  lc_option_eq  TYPE char2   VALUE 'EQ',     " Option EQ
  lc_trtyp_h    TYPE trtyp   VALUE 'H',      " Creation mode
  lc_trtyp_v    TYPE trtyp   VALUE 'V',      " Change mode
  lc_updkz_i    TYPE updkz_d VALUE 'I',      " Update indicator: Creation
*  lc_kschl_yc00 TYPE kschl   VALUE 'YC00',   " Condition type YC00  "Commented by SNIGAM on 15-May-2014: CR-1354
*  lc_kschl_zb00 TYPE kschl   VALUE 'ZB00',   " Condition type ZB00  "Commented by SNIGAM on 15-May-2014: CR-1354
  lc_kschl_zser TYPE kschl   VALUE 'ZSER',   " Condition type ZSER
  lc_kschl_zrer TYPE kschl   VALUE 'ZRER',   " Condition type ZRER
  lc_kschl_zeqr TYPE kschl   VALUE 'ZEQR',   " Condition type ZEQR
* BOC : SNIGAM : CR1296 : 24-Mar-2014
* Change the tolerance level from '0.0010' to '0.010'
  lc_tolerance   TYPE decfloat34 VALUE '0.010',  " Tolerance level
* EOC : SNIGAM : CR1296 : 24-Mar-2014
  lc_ucomm_enter TYPE syucomm    VALUE 'ENT1'.    " User commande: ENTER

* Local type for OTC control table data
TYPES:
  BEGIN OF lty_auart,
    mvalue1 TYPE z_mvalue_low, " AUART Value
  END OF lty_auart,

  BEGIN OF lty_pstyv,
    mvalue1 TYPE z_mvalue_low, " PSTYV Value
  END OF lty_pstyv,

* BOC : SNIGAM : CR-1354 : 15-May-2014
* Type declaration for ZOTC_CONTROL
  BEGIN OF lty_otc_control,
    mvalue1     TYPE z_mvalue_low,    "Select Options: Value Low
    zz_comments TYPE z_comments,      "Comments
  END OF lty_otc_control,

* Table type declaration
 lty_t_otc_control TYPE STANDARD TABLE OF lty_otc_control INITIAL SIZE 0,
* EOC : SNIGAM : CR-1354 : 15-May-2014

  lty_t_auart TYPE STANDARD TABLE OF lty_auart,   " Table type for AUART Value
  lty_t_pstyv TYPE STANDARD TABLE OF lty_pstyv.   " Table type for PSTYV Value

* Local data declaration
DATA: lv_order_type_match TYPE char1,  " Flag for AUART check
      lv_kwert_tot  TYPE decfloat16,   " Condition value of sum total
      lv_kwert_base TYPE decfloat16,   " Condition value of base
      lv_kwert_zser TYPE decfloat16,   " Condition value of ZSER
      lv_kwert_zrer TYPE decfloat16,   " Condition value of ZRER
      lv_kwert_zeqr TYPE decfloat16,   " Condition value of ZEQR
      lv_delta      TYPE decfloat16.   " Variation %

*&--Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
Data lv_index type sy-tabix.
*&--End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

* Local internal tables/wa
DATA: li_auart TYPE lty_t_auart,        "Int Table for OTC control table for Order Type
      li_pstyv TYPE lty_t_pstyv,        "Int Table for OTC control table for Item Cat
      lr_pstyv TYPE RANGE OF pstyv,     " Range table for Item Cat.
      li_zotc_prc_control TYPE lty_t_otc_control,  "Internal table for zotc_prc_control "Added by SNIGAM on 15-May-2014 CR-1354
      li_note  TYPE STANDARD TABLE OF txw_note, " Note with plain text
      lwa_note TYPE txw_note,                   " Note with plain text
      lwa_pstyv LIKE LINE OF lr_pstyv.          " WA for range table

* Local field sumbols
FIELD-SYMBOLS: <lfs_auart> TYPE lty_auart,      " OTC control table for Order Type
               <lfs_pstyv> TYPE lty_pstyv,      " OTC control table for Item Cat
               <lfs_vbap> TYPE vbapvb,          " Item str
               <lfs_komv> TYPE komv,            " Condition record str
               <lfs_otc_control>  TYPE lty_otc_control. "Field symbol for otc_control  "Added by SNIGAM on 15-May-2014 CR-1354


* This is needed only for VA41; hence check the creation mode
IF t180-trtyp = lc_trtyp_h OR
   t180-trtyp = lc_trtyp_v.     " Added by SBASU - Seems like they will need this in change also

* Check the Order Type maintained in OTC Control table. If the order
* type matched, only then this validation should be applied. This is
* supposed to be applied on only Reagent Revenue Contracts with type ZRRC
  SELECT mvalue1
    FROM zotc_prc_control
    INTO TABLE  li_auart
    WHERE vkorg      = vbak-vkorg
      AND vtweg      = vbak-vtweg
      AND mprogram   = lc_program
      AND mparameter = lc_fld_name
      AND mactive    = lc_true
      AND soption    = lc_option_eq.

  lv_order_type_match = space.
* If the contract order type is found in the OTC table, set a flag
  LOOP AT li_auart ASSIGNING <lfs_auart>.
    IF <lfs_auart>-mvalue1 EQ vbak-auart.
      lv_order_type_match = lc_true.
      EXIT.
    ENDIF.
  ENDLOOP.
* Check the AUART flag and if true, then only apply the RRC validation
  IF lv_order_type_match = lc_true.

*   BoC GNAG - 20-Sep-2013 - Check on Item Category
*   Check the Item Cat maintained in OTC Control table.
    SELECT mvalue1
      FROM zotc_prc_control
      INTO TABLE  li_pstyv
      WHERE vkorg      = vbak-vkorg
        AND vtweg      = vbak-vtweg
        AND mprogram   = lc_program
        AND mparameter = lc_fld_name_pstyv
        AND mactive    = lc_true
        AND soption    = lc_option_eq.
    IF sy-subrc IS INITIAL.
*     Prepare a range table with the Item Cat values
      lwa_pstyv-sign   = lc_sign_i.
      lwa_pstyv-option = lc_option_eq.
      LOOP AT li_pstyv ASSIGNING <lfs_pstyv>.
        lwa_pstyv-low = <lfs_pstyv>-mvalue1.
        APPEND lwa_pstyv TO lr_pstyv.
        CLEAR lwa_pstyv-low.
      ENDLOOP.
    ENDIF.
*   If no Item Cat is maintained in the OTC table, then no need to proceed
    IF lr_pstyv IS NOT INITIAL.
*   EoC GNAG - 20-Sep-2013


* BOC : SNIGAM : CR-1354 : 15-May-2014
* Fetching Condition types from table ZOTC_PRC_CONTROL
* Same condition types have been used in RV63A916
      SELECT mvalue1        "Select Options: Value Low
             zz_comments    "Comments
      FROM   zotc_prc_control
      INTO TABLE li_zotc_prc_control
      WHERE vkorg      = vbak-vkorg
      AND   vtweg      = vbak-vtweg
      AND   mprogram   = lc_prognam
      AND   mparameter = lc_parameter
      AND   mactive    = lc_true
      AND   soption    = lc_option_eq
      AND   zz_comments NE space.

*     If Condtion Values found
      IF sy-subrc EQ 0.
*     Sort the table LI_ZOTC_PRC_CONTROL table by ZZ_COMMENTS fiels. This field will contain the
*     the sequence in which we have to use the condition type stored in ZOTC_PRC_CONTROL-MVALUE1
        SORT li_zotc_prc_control BY zz_comments ASCENDING.
* EOC : SNIGAM : CR-1354 : 15-May-2014

        REFRESH li_note.
*   Check for each item of the contract
        LOOP AT xvbap ASSIGNING <lfs_vbap>.
*BOC SBASU - Seems like they need the functionality in update mode also
*     If the VBAP item is for creation, then only proceed
*      IF <lfs_vbap>-updkz NE lc_updkz_i.
*        CONTINUE.
*      ENDIF.
*EOC SBASU
*       BoC GNAG - 20-Sep-2013 - Check on Item Category
*       If the Item Cat of the current item is not maintained in the OTC table,
*       the validation is not applied on this item
          IF NOT <lfs_vbap>-pstyv IN lr_pstyv.
            CONTINUE.
          ENDIF.
*       EoC GNAG - 20-Sep-2013

* BOC : SNIGAM : CR-1354 : 15-May-2014
* Commented below READ statments where the condition types were hardcoded.
* Instead of that, using the LOOP statement on LI_ZOTC_PRC_CONTROL table

**     Get the value of YC00
*        READ TABLE xkomv ASSIGNING <lfs_komv> WITH KEY kposn = <lfs_vbap>-posnr
*                                                       kschl = lc_kschl_yc00.
*        IF sy-subrc IS INITIAL.
*          lv_kwert_base = <lfs_komv>-kwert.
*        ELSE.
**       If YC00 not found, get the same for ZB00
*          READ TABLE xkomv ASSIGNING <lfs_komv> WITH KEY kposn = <lfs_vbap>-posnr
*                                                         kschl = lc_kschl_zb00.
*          IF sy-subrc IS INITIAL.
*            lv_kwert_base = <lfs_komv>-kwert.
*          ENDIF.
*        ENDIF.


*         Read condition types one by one using LOOP
          LOOP AT li_zotc_prc_control ASSIGNING <lfs_otc_control>.

*         Read the Condition value for the condition type.
*         Note1: As soon as the Condition value for one condition type is found, update the
*                field LV_KWERT_BASE with the condition value found for that condition type
*         Note 2: We are not using the Binary Search here as this table contain 2 records as of now
*                 At max it will contain 5 (if it will be so in future)

            READ TABLE xkomv ASSIGNING <lfs_komv> WITH KEY kposn = <lfs_vbap>-posnr
                                                           kschl = <lfs_otc_control>-mvalue1.
            IF sy-subrc EQ 0.

*             Populate Condition Value
              lv_kwert_base = <lfs_komv>-kwert.
*             If condition value for condition type found, then no need to read condition
*             value of rest of condition types. Simply come out of loop
              EXIT.

            ENDIF.

          ENDLOOP.
* EOC : SNIGAM : CR-1354 : 15-May-2014

*         If either of YC00 or ZB00 or ZL00 is found, get the values of ZSER, ZRER and ZEQR
          IF sy-subrc IS INITIAL AND lv_kwert_base IS NOT INITIAL.

            READ TABLE xkomv ASSIGNING <lfs_komv> WITH KEY kposn = <lfs_vbap>-posnr
                                                           kschl = lc_kschl_zser.
            IF sy-subrc IS INITIAL.
              lv_kwert_zser = ( <lfs_komv>-kwert / lv_kwert_base ) * 100.
            ENDIF.
            READ TABLE xkomv ASSIGNING <lfs_komv> WITH KEY kposn = <lfs_vbap>-posnr
                                                           kschl = lc_kschl_zrer.
            IF sy-subrc IS INITIAL.
              lv_kwert_zrer = ( <lfs_komv>-kwert / lv_kwert_base ) * 100.
            ENDIF.
            READ TABLE xkomv ASSIGNING <lfs_komv> WITH KEY kposn = <lfs_vbap>-posnr
                                                           kschl = lc_kschl_zeqr.
            IF sy-subrc IS INITIAL.
              lv_kwert_zeqr = ( <lfs_komv>-kwert / lv_kwert_base ) * 100.
            ENDIF.

*           Sum up the 3 condition types
            lv_kwert_tot = lv_kwert_zser + lv_kwert_zrer + lv_kwert_zeqr.

*           Calculate the variation % from the base value
            lv_delta = ( 100 - lv_kwert_tot ).
            lv_delta = abs( lv_delta ).
            lv_delta  = round( val = lv_delta dec = 3 ).  " Added by SBASU to round it up

* BOC : SNIGAM : CR-1354 : 15-May-2014
*           Round up the values upto 3 digits
            lv_kwert_zser = round( val = lv_kwert_zser dec = 3 ).
            lv_kwert_zrer = round( val = lv_kwert_zrer dec = 3 ).
            lv_kwert_zeqr = round( val = lv_kwert_zeqr dec = 3 ).
* EOC : SNIGAM : CR-1354 : 15-May-2014

*           If the variation is more than the tolerance level, error message
            IF lv_delta GT lc_tolerance.
*             Populate an internal table with the error messages from all the items
*             then all the messages would be displayed at the end
              MESSAGE e129(zotc_msg) INTO lwa_note-line   " Item: & Total Reagent Revenue does not match 100%
                                     WITH <lfs_vbap>-posnr
                                          lv_kwert_zser
                                          lv_kwert_zrer
                                          lv_kwert_zeqr.
              APPEND lwa_note TO li_note.
*            CLEAR : lwa_note,lv_kwert_zser,lv_kwert_zrer,lv_kwert_zeqr."Def#1296--
            ENDIF.    " lv_delta GT lc_tolerance
          ENDIF.    " either of YC00 and ZB00 is found

*&&-- BOC of Def#1296: Added on 21-Mar-2014: the variables were not getting
*        cleared and the message was getting triggered
          CLEAR : lwa_note,lv_kwert_zser,
                  lv_kwert_zrer,lv_kwert_zeqr,
                  lv_kwert_tot.                             "Def#1296++
*&&-- EOC of Def#1296
        ENDLOOP.

*   If any error found for any items, then display the messages in a pop-up
        IF li_note IS NOT INITIAL.

*&--Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
*&--this enhancement should not trigger when order is created through idoc
          IF sy-batch IS INITIAL AND
             idoc_number IS INITIAL.
*&--End of Change for D3_OTC_CDD_0005_0007_0140 by U033870

*         Add a covering line for the error corretion
          MESSAGE e130(zotc_msg) INTO lwa_note-line.   " Please correct the following errors and then save
          INSERT lwa_note INTO li_note INDEX 1.
          CLEAR lwa_note.
          INSERT lwa_note INTO li_note INDEX 2.     " Add a blank line for better look

*         Display the text editor with the errors

* BOC : SNIGAM : 15-May-2014 : CR-1354
* Replaced the unapproved FM 'TXW_TEXTNOTE_EDIT' with the custom 'ZOTC_TXW_TEXTNOTE_EDIT'
*          CALL FUNCTION 'TXW_TEXTNOTE_EDIT'      "Commented by SNIGAM on 15-May-2014 CR-1354
            CALL FUNCTION 'ZOTC_TXW_TEXTNOTE_EDIT'  "Added by SNIGAM on 15-May-2014 CR-1354
              EXPORTING
                edit_mode = space
              TABLES
                t_txwnote = li_note.
* EOC : SNIGAM : 15-May-2014 : CR-1354

*         Set the FCODE and sy-ucomm with the ENTER code to keep the control
*         in the same screen instead of saving
            fcode    = lc_ucomm_enter.
            sy-ucomm = lc_ucomm_enter.

            SET SCREEN sy-dynnr.
            LEAVE SCREEN.
*&--Begin of Change for D3_OTC_CDD_0005_0007_0140 by U033870
          ELSE.
            DESCRIBE TABLE li_note LINES lv_index.
            Read TABLE li_note into lwa_note INDEX lv_index.
            MESSAGE e899 WITH lwa_note+0(50) lwa_note+50(22)
            RAISING do_not_process_idoc.
          ENDIF.
*&--End of Change for D3_OTC_CDD_0005_0007_0140 by U033870
        ENDIF.
      ENDIF.  "Added by SNIGAM on 15-May-2014 : CR-1254
    ENDIF.
  ENDIF.    " lv_order_type_match = true
ENDIF.    " t180-trtyp = 'H', creation mode
