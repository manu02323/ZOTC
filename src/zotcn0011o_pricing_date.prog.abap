*&---------------------------------------------------------------------*
*&  Include           ZOTCN0011O_PRICING_DATE
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0011O_PRICING_DATE                                *
* TITLE      :  Pricing Date                                           *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   OTC_EDD_0011_Pricing Routine Enhancement (CR#1318)      *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing date for the line item of an order should be the*
*              delivery date of that item. Currently, when an order is *
*              created with reference to a reagent rental contract, the*
*              pricing date is getting derived from the contract.      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 08-Jan-2015 SGHOSH   E2DK904378 Initial Dev -CR#2823:                *
*                                 CR#1318 and CR#1676 has been         *
*                                 retrofitted from D1.                 *
*&---------------------------------------------------------------------*
* 08-Jan-2015 SGHOSH   E2DK904378 CR#2823(D1 CR#1318):                 *
*                                 Reference document will also be      *
*                                 checked at item level if not found at*
*                                 header level and update its pricing  *
*                                 date correspondingly.
*&---------------------------------------------------------------------*
* 08-Jan-2015 SGHOSH  E2DK904378 CR#2823(D1 CR#1676): When the pricing *
*                                date of Sales order item created with *
*                                reference to a contractis updated to  *
*                                the delivery date of the item,the line*
*                                item should be repriced with the      *
*                                option C,so that the new pricing date *
*                                is in effect.                         *
*&---------------------------------------------------------------------*

  TYPES:
      BEGIN OF lty_ctrl,
        mparameter  TYPE enhee_parameter, " Parameter
        mvalue1     TYPE z_mvalue_low,    " Value Low
        mvalue2     TYPE z_mvalue_high,   " Value High
      END OF lty_ctrl,

*&--Table type for control table
      lty_t_ctrl TYPE STANDARD TABLE OF lty_ctrl,

*&--BOC: CR#1318 : RVERMA : 20-Aug-2014
      BEGIN OF lty_vbak1,
        vbeln TYPE vbeln_va, " Sales Document
        auart TYPE auart,    " Sales Document Type
      END OF lty_vbak1,
*&--Table type for doc type
      lty_t_vbak1 TYPE STANDARD TABLE OF lty_vbak1.
*&--EOC: CR#1318 : RVERMA : 20-Aug-2014

  DATA:    BEGIN OF li_xvbep OCCURS 150. " Local internal table for XVBEP
          INCLUDE STRUCTURE vbepvb. " Structure of Document for XVBEP/YVBEP
  DATA:    END OF li_xvbep.

  DATA: li_prc_ctrl TYPE lty_t_ctrl, " Internal table for ZOTC_PRC_CONTROL table
        lv_auart1   TYPE auart,     " Local variable for AUART
*&--BOC: CR#1676 : SNIGAM : 7-Oct-2014
        lv_retrigger_price TYPE char1, " Local variable for retrigger price
*&--EOC: CR#1676 : SNIGAM : 7-Oct-2014
        lwa_xvbep   LIKE LINE OF li_xvbep, " Local work area for XVBEP
        lwa_xvbkd   LIKE LINE OF xvbkd,    " Local work area for XVBKD
*&--BOC: CR#1318 : RVERMA : 20-Aug-2014
        li_vbap     TYPE va_vbapvb_t, " Internal table for VBAP
        lwa_vbap    TYPE vbapvb,      "Added by SBASU 24th Sep 2014
        li_vbak1    TYPE lty_t_vbak. " Internal table
*&--EOC: CR#1318 : RVERMA : 20-Aug-2014

  CONSTANTS:
       lc_mprog1       TYPE programm        VALUE 'ZOTCN0011O_PRICING_DATE', " Program Name
       lc_auart1       TYPE enhee_parameter VALUE 'AUART',                  " Parameter Name
       lc_auart_con    TYPE enhee_parameter VALUE 'AUART_CON',               " Parameter Name
       lc_posnr        TYPE posnr           VALUE '000000',                  " 000000
       lc_active1      TYPE char01          VALUE 'X',                       " Active
       lc_soptn_eq     TYPE char2           VALUE 'EQ',                      " Option:Equal
       lc_create_1318  TYPE trtyp           VALUE 'H'.                       " Creation mode


  FIELD-SYMBOLS: <lfs_ctrl>  TYPE lty_ctrl, " Field Symbol for ZOTC_PRC_CONTROL table
                 <lfs_xvbep> TYPE vbepvb,   " Field Symbol for XVBEP
                 <lfs_xvbkd> TYPE vbkdvb,   " Field Symbol for XVBKD
*&--BOC: CR#1318 : RVERMA : 20-Aug-2014
                 <lfs_vbap_1318> TYPE vbapvb, " Field Symbol for VBAP
                 <lfs_vbak_1318> TYPE lty_vbak1,
                 <lfs_vbkd1> TYPE vbkdvb.     " Reference structure for XVBKD/YVBKD
*&--EOC: CR#1318 : RVERMA : 20-Aug-2014

* This is needed for creation
  IF  ( t180-trtyp = lc_create_1318 ).

*&--Copy XVBEP data into local internal table.
    li_xvbep[] = xvbep[].
    SORT li_xvbep BY posnr.
    DELETE ADJACENT DUPLICATES FROM li_xvbep COMPARING posnr.

** BOC SBASU 24th Sep 2014
*&--Copy the data of XVBAP table
    li_vbap[] = xvbap[].
* EOC SBASU 24th Sep 2014
*&--Fetching control data
    SELECT mparameter       " Parameter
           mvalue1          " Select Options: Value Low
           mvalue2          " Select Options: Value High
      FROM zotc_prc_control " OTC Process Team Control Table
      INTO TABLE li_prc_ctrl
      WHERE vkorg      EQ vbak-vkorg
        AND vtweg      EQ vbak-vtweg
        AND mprogram   EQ lc_mprog1
        AND mparameter IN (lc_auart1, lc_auart_con)
        AND mactive    EQ lc_active1
        AND soption    EQ lc_soptn_eq.

    IF sy-subrc IS INITIAL.

*&--BOC: CR#1676 : SNIGAM : 7-Oct-2014
* Commented below piece of code under CR-1676. We need not to
* check the contract at the header level, hence below code is not
* required now.

***&--BOC: CR#1318 : RVERMA : 20-Aug-2014
***      IF vbak-vgbel IS NOT INITIAL.
****&--EOC: CR#1318 : RVERMA : 20-Aug-2014
***
****&--Fetching Reference contract document type
***        SELECT SINGLE auart
***          FROM vbak
***          INTO lv_auart
***          WHERE vbeln = vbak-vgbel.
***
***        IF sy-subrc IS INITIAL.
****&--If reference document type matches with the process control table entry (ZRRC) then proceed
***          READ TABLE li_prc_ctrl ASSIGNING <lfs_ctrl>
***                                 WITH KEY mparameter = lc_auart_con
***                                          mvalue1 = lv_auart.
***          IF sy-subrc IS INITIAL.
****&--If document type matches with the process control table entries (ZOR/ZSTD) then proceed
***            READ TABLE li_prc_ctrl ASSIGNING <lfs_ctrl>
***                                   WITH KEY mparameter = lc_auart1
***                                            mvalue1 = vbak-auart.
***            IF sy-subrc IS INITIAL.
****&--Read internal table XVBKD with POSNR = 000000 to fetch the header record
***              READ TABLE xvbkd INTO lwa_xvbkd WITH KEY posnr = lc_posnr.
***              IF sy-subrc IS INITIAL.
****&--Looping at local internal table of XVBEP to append schesule line items
****    with item delivery date as pricing date.
***                LOOP AT li_xvbep ASSIGNING <lfs_xvbep>.
****&--If some item already exists in XVBKD with the same item number then modify that record only.
***                  READ TABLE xvbkd ASSIGNING <lfs_vbkd> WITH KEY posnr = <lfs_xvbep>-posnr.
***                  IF sy-subrc = 0.
***                    <lfs_vbkd>-prsdt = <lfs_xvbep>-edatu.
***                    lv_retrigger_price = abap_true.
***                  ELSE.
***
********* BOC SBASU 24th Sep 2014
*****                    READ TABLE li_vbap INTO lwa_vbap WITH KEY posnr = <lfs_xvbep>-posnr
*****                                                              vgbel = vbak-vgbel.
*****                    IF sy-subrc eq 0.
********* EOC SBASU 24th Sep 2014
****&--If no record exists for that item number append new line in XVBKD.
***                      lwa_xvbkd-posnr = <lfs_xvbep>-posnr.
***                      lwa_xvbkd-prsdt = <lfs_xvbep>-edatu.
***                      lv_retrigger_price = abap_true.
***                      APPEND lwa_xvbkd TO xvbkd.
****                    ENDIF.
***
***                  ENDIF.
***                ENDLOOP.
***              ENDIF.
***            ENDIF.
***          ENDIF.
***        ENDIF.
****&--BOC: CR#1318 : RVERMA : 20-Aug-2014
***      ELSE.
*&--EOC: CR#1676 : SNIGAM : 7-Oct-2014


*&--If document type matches with the process control table entries (ZOR/ZSTD) then proceed
      READ TABLE li_prc_ctrl ASSIGNING <lfs_ctrl>
                             WITH KEY mparameter = lc_auart1
                                      mvalue1 = vbak-auart.
      IF sy-subrc IS INITIAL.

** BOC SBASU 24th Sep 2014
**&--Copy the data of XVBAP table
*          li_vbap[] = xvbap[].
** EOC SBASU 24th Sep 2014

*&--Sort and delete duplicates based on VGBEL
        SORT li_vbap BY vgbel.
        DELETE ADJACENT DUPLICATES FROM li_vbap
                              COMPARING vgbel.
*&--If LI_VBAP has records
        IF li_vbap[] IS NOT INITIAL.
*&--Fetch Doc type data from VBAK table
          SELECT vbeln " Sales Document
                 auart " Sales Document Type
            FROM vbak  " Sales Document: Header Data
            INTO TABLE li_vbak1
            FOR ALL ENTRIES IN li_vbap
            WHERE vbeln EQ li_vbap-vgbel.
*&--If records are fetched
          IF sy-subrc IS INITIAL.
            SORT li_vbak1 BY vbeln.

*&--Process on XVBAP data
            LOOP AT xvbap ASSIGNING <lfs_vbap_1318>.
*&--Check if XVBAP-VGBEL is not initial
              IF <lfs_vbap_1318>-vgbel IS NOT INITIAL.
*&--Read LI_VBAK1 table data to get Doc type of reference document
                READ TABLE li_vbak1 ASSIGNING <lfs_vbak_1318>
                                   WITH KEY vbeln = <lfs_vbap_1318>-vgbel
                                   BINARY SEARCH.
                IF sy-subrc IS INITIAL.
*&--If reference document type matches with the process control table entry (ZRRC) then proceed
                  READ TABLE li_prc_ctrl ASSIGNING <lfs_ctrl>
                                         WITH KEY mparameter = lc_auart_con
                                                  mvalue1 = <lfs_vbak_1318>-auart.
                  IF sy-subrc IS INITIAL.
*&--Read LI_XVBEP data to get schedule line date from first schedule line
                    READ TABLE li_xvbep ASSIGNING <lfs_xvbep>
                                        WITH KEY posnr = <lfs_vbap_1318>-posnr.
                    IF sy-subrc IS INITIAL.
*&--If some item already exists in XVBKD with the same item number then modify that record only.
                      READ TABLE xvbkd ASSIGNING <lfs_vbkd1>
                                       WITH KEY posnr = <lfs_xvbep>-posnr.
                      IF sy-subrc = 0.
                        <lfs_vbkd1>-prsdt = <lfs_xvbep>-edatu.
*&--BOC: CR#1676 : SNIGAM : 7-Oct-2014
                        lv_retrigger_price = abap_true.
*&--EOC: CR#1676 : SNIGAM : 7-Oct-2014
                      ELSE. " ELSE -> IF sy-subrc = 0
*&--If no record exists for that item number append new line in XVBKD.
*&--Read internal table XVBKD with POSNR = 000000 to fetch the header record
                        READ TABLE xvbkd INTO lwa_xvbkd
                                         WITH KEY posnr = lc_posnr.
                        IF sy-subrc IS INITIAL.
                          lwa_xvbkd-posnr = <lfs_xvbep>-posnr.
                          lwa_xvbkd-prsdt = <lfs_xvbep>-edatu.
*&--BOC: CR#1676 : SNIGAM : 7-Oct-2014
                          lv_retrigger_price = abap_true.
*&--EOC: CR#1676 : SNIGAM : 7-Oct-2014
                          APPEND lwa_xvbkd TO xvbkd.
                          CLEAR lwa_xvbkd.
                        ENDIF. " IF sy-subrc IS INITIAL
                      ENDIF. " IF sy-subrc = 0
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF sy-subrc IS INITIAL
                ENDIF. " IF sy-subrc IS INITIAL
              ENDIF. " IF <lfs_vbap_1318>-vgbel IS NOT INITIAL
            ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_vbap_1318>
          ENDIF. " IF sy-subrc IS INITIAL
        ENDIF. " IF li_vbap[] IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
***      ENDIF.  "VBAK-VGBEL is not initial check
*&--EOC: CR#1318 : RVERMA : 20-Aug-2014
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF ( t180-trtyp = lc_create_1318 )

*&--BOC: CR#1676 : SNIGAM : 7-Oct-2014
  IF lv_retrigger_price = abap_true.
    PERFORM preisfindung_gesamt USING 'C'.
    CLEAR lv_retrigger_price.
  ENDIF. " IF lv_retrigger_price = abap_true
*&--EOC: CR#1676 : SNIGAM : 7-Oct-2014
