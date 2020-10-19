*&--------------------------------------------------------------------*
*&  Include           ZOTC0142_VFX3_ACCURAL_REP_SUB
*&--------------------------------------------------------------------*
*Program    : ZOTC0142_VFX3_ACCURAL_REP                               *
*Title      : D3_OTC_RDD_0142_VFX3_Accural Report                     *
*Developer  : ShivaNagh Samala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_RDD_0142                                          *
*---------------------------------------------------------------------*
*Description: Batch Master Date 1 Report                              *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ===========================*
*30-May-2019   U105235      E2DK924302     SCTASK0833109:Initial      *
*                                          development                *
*---------------------------------------------------------------------*
*16-July-2019  U105235     E2DK925308      Defect#10042 Item Category *
*                               description field value is truncating *
*&--------------------------------------------------------------------*
*23-Aug-2019   U033959     E2DK926218      Defect#10303               *
*                                     1. Net value -ve sign should be *
*                                        shown at begining during back*
*                                        -ground processing           *
*                                     2. Material Group 1 and Acc     *
*                                        Assign Grp to be fetched     *
*                                        from VBRP instead of VBAP    *
*---------------------------------------------------------------------*
*&      Form  F_INITIALIZATION
*&--------------------------------------------------------------------*
*       To Refresh all the internal tables
*---------------------------------------------------------------------*
FORM f_initialization.
*refresh all the internal tables
  REFRESH : i_vbrk_vbrp[],
            i_tvapt[],
            i_vbap[],
            i_likp[],
            i_dd07t[],
            i_tvfkt[],
*---> Begin of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*            i_tvkmt[],
*            i_tvm1t[],
*<--- End of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
            i_vbuk[],
            i_tvap[],
            i_vbreve[].

*make the radiobutton fields as input disabled until the mandatory fields are entered
  LOOP AT SCREEN.
    IF screen-group1 = c_xyz.   "modif id group XYZ
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

ENDFORM.

*&--------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&--------------------------------------------------------------------*
*       To modify screen
*---------------------------------------------------------------------*
FORM f_modify_screen.

  DATA :lc_app_file   TYPE rlgrap-filename .
*make the billing date selection-screen field range HIGH as mandatory
  LOOP AT SCREEN.
    IF screen-name = c_date. "S_FKDAT-HIGH.
      screen-required = 1.    "make the field as mandatory
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF rb_fore = abap_true.    "Foreground is selected
*the field for entering the mail id should be invisible
    LOOP AT SCREEN.
      IF screen-name CS c_text OR   "P_TEXT
         screen-name CS c_path.     "P_PATH
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF rb_back = abap_true. "Background is selected
*the field for entering the mail id should be visible
    LOOP AT SCREEN.
      IF screen-group1 = c_xyz.  "modif id XYZ
*screen-required = 1.
        MODIFY SCREEN.
      ELSEIF screen-group1 = c_abc.  "modif id ABC
        CONCATENATE '/appl/'(047) syst-sysid '/REP/OTC/OTC_RDD_0142' INTO lc_app_file.
        p_path = lc_app_file.
        screen-input = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.

*&--------------------------------------------------------------------*
*&      Form  F_SCREEN_VALIDATION
*&--------------------------------------------------------------------*
*       To validate the selection screen entries
*---------------------------------------------------------------------*
FORM f_screen_validation.
  DATA : lv_vbeln TYPE vbeln_vf,                            "#EC NEEDED
         lv_vkorg TYPE vkorg,                               "#EC NEEDED
         lv_vtweg TYPE vtweg.                               "#EC NEEDED
*validate the sales org. data entered in selection screen
  IF NOT s_vkorg[] IS INITIAL.
    CLEAR lv_vkorg.
    SELECT vkorg
           FROM tvko
           UP TO 1 ROWS
           INTO lv_vkorg
           WHERE vkorg IN s_vkorg.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE e984.      "Sales Organization is not valid
    ENDIF.
  ENDIF.

*validate the distribution channel data entered in selection screen
  IF NOT s_vtweg[] IS INITIAL .
    CLEAR lv_vtweg.
    SELECT vtweg
           FROM tvtw
           UP TO 1 ROWS
           INTO lv_vtweg
           WHERE vtweg IN s_vtweg.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE e985.    "Distribution Channel is not valid
    ENDIF.
  ENDIF.
*validate the billing document data entered in selection screen
  IF NOT s_vbeln IS INITIAL.
    CLEAR lv_vbeln.
    SELECT vbeln
           FROM vbuk
           UP TO 1 ROWS
           INTO lv_vbeln
           WHERE vbeln IN s_vbeln.
    ENDSELECT.
    IF sy-subrc NE 0.
      MESSAGE e097.     "Please Enter valid Billing Document
    ENDIF.
  ENDIF.

ENDFORM.
*&--------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&--------------------------------------------------------------------*
*       To retrieve all the data to display in the output
*---------------------------------------------------------------------*
FORM f_get_data.

  FIELD-SYMBOLS : <lfs_likp>      TYPE ty_likp,
                  <lfs_vbuk>      TYPE ty_vbuk,
                  <lfs_dd07t>     TYPE ty_dd07t,
                  <lfs_tvm1t>     TYPE ty_tvm1t,
                  <lfs_tvapt>     TYPE ty_tvapt,
                  <lfs_tvfkt>     TYPE ty_tvfkt,
                  <lfs_tvap>      TYPE ty_tvap,
                  <lfs_vbap>      TYPE ty_vbap,
                  <lfs_tvkmt>     TYPE ty_tvkmt,
                  <lfs_vbrk_vbrp> TYPE ty_vbrk_vbrp,
                  <lfs_vbreve>    TYPE ty_vbreve.

*retrieve the billing data from VBRK table based on the selection screen entries
  SELECT a~vbeln                "Billing Document
         a~fkart                "Billing Type
         a~waerk                "SD Document Currency
         a~vkorg                "Sales Organization
         a~vtweg                "Distribution Channel
         a~fkdat                "Billing Date for Billing Index and Printout
         a~rfbsk                "Status for transfer to accounting
         a~erdat                "Date on Which Record Was Created
         a~kunrg                "Payer
         a~kunag                "Sold-To Party
         b~posnr              "Billing item
         b~uepos              "Higher-level item in bill of material structures
         b~gewei              "Weight Unit
         b~netwr              "Net weight
         b~vgbel              "Document Number of the Reference Document
         b~vgpos              "Item Number of the Reference Item
         b~aubel              "Sales Document
         b~aupos              "Sales Document Item
         b~matnr              "Material Number
         b~arktx              "Short text for sales order item
         b~pstyv              "Sales Document Item Category
         b~werks              "Plant
*---> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
         b~ktgrm              "Account assignment group for this material
*<--- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
         b~prctr              "Profit Center
*---> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
         b~mvgr1              "Material group 1
*<--- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
         b~mwsbp              "Tax amount in document currency
         FROM vbrk AS a
         INNER JOIN vbrp AS b
         ON a~vbeln = b~vbeln
         INTO TABLE i_vbrk_vbrp
         WHERE a~vbeln IN s_vbeln
         AND   a~vkorg IN s_vkorg
         AND   a~vtweg IN s_vtweg
         AND   a~fkdat IN s_fkdat
         AND   a~erdat IN s_erdat.
  IF sy-subrc EQ 0.
*delete the entries for which the posting status is not equal to D/C/E
    DELETE i_vbrk_vbrp WHERE  rfbsk EQ c_d OR
                         rfbsk EQ c_c OR
                         rfbsk EQ c_e.
    IF NOT i_vbrk_vbrp[] IS INITIAL.
*---> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*  Fetch Material group 1 and account assignment group text
      DATA(li_vbrk_vbrp_t) = i_vbrk_vbrp[].
      SORT li_vbrk_vbrp_t BY mvgr1.
      DELETE ADJACENT DUPLICATES FROM li_vbrk_vbrp_t COMPARING mvgr1.
      IF li_vbrk_vbrp_t IS NOT INITIAL.
*retrieve the description for material group from TVM1T table
        SELECT spras,                 "Language Key
               mvgr1,                 "Material group 1
               bezei                 "Description
               FROM tvm1t
               INTO TABLE @DATA(li_tvm1t)
               FOR ALL ENTRIES IN @li_vbrk_vbrp_t
               WHERE spras EQ @sy-langu
                 AND mvgr1 EQ @li_vbrk_vbrp_t-mvgr1.
        IF sy-subrc EQ 0.
            SORT li_tvm1t BY mvgr1.
        ENDIF.
      ENDIF.

      CLEAR li_vbrk_vbrp_t.
      li_vbrk_vbrp_t = i_vbrk_vbrp[].
      SORT li_vbrk_vbrp_t BY ktgrm.
      DELETE ADJACENT DUPLICATES FROM li_vbrk_vbrp_t COMPARING ktgrm.
      IF li_vbrk_vbrp_t IS NOT INITIAL.
*retrieve the description for account assignment from TVKMT table
        SELECT spras,                 "Language Key
               ktgrm,                 "Account assignment group for this material
               vtext                 "Description
               FROM tvkmt
               INTO TABLE @DATA(li_tvkmt)
               FOR ALL ENTRIES IN @li_vbrk_vbrp_t
               WHERE spras EQ @sy-langu
                 AND ktgrm EQ @li_vbrk_vbrp_t-ktgrm.
        IF sy-subrc EQ 0.
            SORT li_tvkmt BY ktgrm.
        ENDIF.
      ENDIF.
      CLEAR li_vbrk_vbrp_t.
*<--- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*retrieve the billing type description from the table TVFKT
      SELECT spras               "Language Key
             fkart               "Billing Type
             vtext               "Description
             FROM tvfkt
             INTO TABLE i_tvfkt
             FOR ALL ENTRIES IN i_vbrk_vbrp
             WHERE fkart = i_vbrk_vbrp-fkart.
      IF sy-subrc EQ 0.
        DELETE i_tvfkt WHERE spras NE c_e.
      ENDIF.
*retrieve the billing item data from the table VBRP for the corresponding billing docs
      IF sy-subrc EQ 0.
*pass the item table data into an temporary internal table
        i_vbrk_vbrp_temp[] = i_vbrk_vbrp[].
        SORT i_vbrk_vbrp_temp BY aubel vgbel.
        DELETE ADJACENT DUPLICATES FROM i_vbrk_vbrp_temp COMPARING aubel vgbel.
*retreive the data from VBREVE table for the corresponding entries related to AUBEL, VGBEL
        IF NOT i_vbrk_vbrp_temp[] IS INITIAL.
          SELECT vbeln               "Sales Document
                 posnr               "Sales Document Item
                 sakrv               "G/L Account Number
                 bdjpoper            "Posting year and posting period (YYYYMMM format)
                 popupo              "Period sub-item
                 vbeln_n             "Subsequent sales and distribution document
                 posnr_n             "Subsequent item of an SD document
                 rrsta               "Revenue determination status
                 FROM vbreve
                 INTO TABLE i_vbreve
                 FOR ALL ENTRIES IN i_vbrk_vbrp_temp
                 WHERE vbeln   EQ i_vbrk_vbrp_temp-aubel
                 AND   vbeln_n EQ i_vbrk_vbrp_temp-vgbel.
          IF sy-subrc EQ 0.
            SORT i_vbreve BY vbeln vbeln_n.
          ENDIF.
*---> Begin of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*   Below code has been commented out for defect 10303.
*   Material group 1 and account assignment group will be
*   fethced from billing instead of sales order
**pass the item table data into an temporary internal table
*REFRESH i_vbrk_vbrp_temp[].
*i_vbrk_vbrp_temp[] = i_vbrk_vbrp[].
*SORT i_vbrk_vbrp_temp BY aubel.
*DELETE ADJACENT DUPLICATES FROM i_vbrk_vbrp_temp COMPARING aubel.
*IF NOT i_vbrk_vbrp_temp[] IS INITIAL.
**retrieve the sales document item data from VBAP for the corresponding sales document
*SELECT vbeln                 "Sales Document
*       posnr                 "Sales Document Item
*       ktgrm                 "Account assignment group for this material
*       mvgr1                 "Material group 1
*       FROM vbap
*       INTO TABLE i_vbap
*       FOR ALL ENTRIES IN i_vbrk_vbrp_temp
*       WHERE vbeln EQ i_vbrk_vbrp_temp-aubel.
*IF sy-subrc EQ 0.
**retrieve the description for account assignment from TVKMT table
*SELECT spras                 "Language Key
*       ktgrm                 "Account assignment group for this material
*       vtext                 "Description
*       FROM tvkmt
*       INTO TABLE i_tvkmt
*       FOR ALL ENTRIES IN i_vbap
*       WHERE ktgrm EQ i_vbap-ktgrm.
*IF sy-subrc EQ 0.
**delete the entries for which the language is not equal to 'E'
*DELETE i_tvkmt WHERE spras NE c_e.
*IF i_tvkmt[] IS NOT INITIAL.
*  SORT i_tvkmt BY spras ktgrm.
*  ENDIF.
*ENDIF.
**retrieve the description for material group from TVM1T table
*SELECT spras                 "Language Key
*       mvgr1                 "Material group 1
*       bezei                 "Description
*       FROM tvm1t
*       INTO TABLE i_tvm1t
*       FOR ALL ENTRIES IN i_vbap
*       WHERE mvgr1 EQ i_vbap-mvgr1.
*IF sy-subrc EQ 0.
**delete the entries for which the language is not equal to 'E'
*DELETE i_tvm1t WHERE spras NE c_e.
*IF i_tvm1t[] IS NOT INITIAL.
*  SORT i_tvm1t BY spras mvgr1.
*      ENDIF.
*    ENDIF.
*   ENDIF.
*  ENDIF.
*<--- End of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
        ENDIF.
*refresh the temporary internal table and load the VBRP data again
        REFRESH i_vbrk_vbrp_temp[].
        i_vbrk_vbrp_temp[] = i_vbrk_vbrp[].
        SORT i_vbrk_vbrp_temp BY vgbel.
        DELETE ADJACENT DUPLICATES FROM i_vbrk_vbrp_temp COMPARING vgbel.
*retrieve the delivery data from LIKP table for the corresponding delivery document
        IF NOT i_vbrk_vbrp_temp[] IS INITIAL.
          SELECT vbeln                 "Delivery
                 vkoiv                 "Sales organization for intercompany billing
                 vtwiv                 "Distribution channel for intercompany billing
                 kuniv                 "Customer number for intercompany billing
                 wadat_ist             "Actual Goods Movement Date
                 podat                 "Date (proof of delivery)
                 FROM likp
                 INTO TABLE i_likp
                 FOR ALL ENTRIES IN i_vbrk_vbrp_temp
                 WHERE vbeln EQ i_vbrk_vbrp_temp-vgbel.
          IF sy-subrc EQ 0.
            SORT i_likp BY vbeln.
          ENDIF.
*retrieve the data from VBUK table
          SELECT vbeln                 "Sales and Distribution Document Number
                 pdstk                 "POD status on header level
                 FROM vbuk
                 INTO TABLE i_vbuk
                 FOR ALL ENTRIES IN i_vbrk_vbrp_temp
                 WHERE vbeln EQ i_vbrk_vbrp_temp-vgbel.
          IF sy-subrc EQ 0.
            SORT i_vbuk BY vbeln.
          ENDIF.
        ENDIF.
        REFRESH i_vbrk_vbrp_temp[].
        i_vbrk_vbrp_temp[] = i_vbrk_vbrp[].
        SORT i_vbrk_vbrp_temp BY pstyv.
        DELETE ADJACENT DUPLICATES FROM i_vbrk_vbrp_temp COMPARING pstyv.
*retrieve the sales document item category statistical values from TVAP table
        SELECT pstyv                "Sales Document Item Category
               fkrel                "Relevant for Billing
               kowrr                "Statistical values
               rrrel                "Revenue recognition category
               FROM tvap
               INTO TABLE i_tvap
               FOR ALL ENTRIES IN i_vbrk_vbrp_temp
               WHERE pstyv EQ i_vbrk_vbrp_temp-pstyv.
        IF sy-subrc EQ 0.
          SORT i_tvap BY pstyv.
          LOOP AT i_vbrk_vbrp ASSIGNING <lfs_vbrk_vbrp>.
            READ TABLE i_tvap ASSIGNING <lfs_tvap> WITH KEY pstyv = <lfs_vbrk_vbrp>-pstyv
                                                            BINARY SEARCH.
            IF sy-subrc EQ 0 AND <lfs_tvap>-kowrr = c_y.
              <lfs_vbrk_vbrp>-vbeln = abap_false.
            ENDIF.
          ENDLOOP.
          DELETE i_vbrk_vbrp WHERE vbeln EQ abap_false.
*delete the entries for which the value of kowrr = Y
          DELETE i_tvap WHERE kowrr = c_y.  "No cumulation - Values can be used statistically
          IF NOT i_tvap[] IS INITIAL.
            SORT i_tvap BY pstyv.
*retrieve the sales document item category description from TVAPT table
            SELECT spras                  "Language Key
                   pstyv                  "Sales Document Item Category
                   vtext                  "Description
                   FROM tvapt
                   INTO TABLE i_tvapt
                   FOR ALL ENTRIES IN i_tvap
                   WHERE pstyv EQ i_tvap-pstyv.
            IF sy-subrc EQ 0.
*delete the entries for which the language is not equal to 'E'
              DELETE i_tvapt WHERE spras NE c_e.
              IF NOT i_tvapt[] IS INITIAL.
                SORT i_tvapt BY pstyv.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
*retrieve the f4 values maintained at the domain level for RFBSK
        SELECT domname
               ddlanguage
               ddtext
               domvalue_l
               FROM dd07t
               INTO TABLE i_dd07t
               WHERE ddlanguage EQ c_e
               AND   domname = c_rfbsk.  "rfbsk domain
        IF sy-subrc EQ 0.
          SORT i_dd07t BY domname domvalue_l.
        ENDIF.
*retrieve the f4 values maintained at the domain level for PDSTK & RRSTA
        SELECT domname
               ddlanguage
               ddtext
               domvalue_l
               FROM dd07t
               INTO TABLE i_statv
               WHERE ddlanguage EQ c_e
               AND   domname = c_statv.    "statv domain for PDSTK & RRSTA fields
        IF sy-subrc EQ 0.
          SORT i_statv BY domname domvalue_l.
        ENDIF.
*retrieve the f4 values maintained at the domain level for fkrel
        SELECT domname
               ddlanguage
               ddtext
               domvalue_l
               FROM dd07t
               INTO TABLE i_fkrel
               WHERE ddlanguage EQ c_e
               AND   domname = c_fkrel.    "statv domain for PDSTK & RRSTA fields
        IF sy-subrc EQ 0.
          SORT i_fkrel BY domname domvalue_l.
        ENDIF.

        SORT i_tvfkt BY fkart.
        SORT i_vbrk_vbrp_temp BY vbeln posnr.
        SORT i_vbap BY vbeln posnr.
        CLEAR wa_final.

        IF NOT i_vbrk_vbrp[] IS INITIAL.
*fill the final internal table with the field values
          LOOP AT i_vbrk_vbrp ASSIGNING <lfs_vbrk_vbrp>.
*populate the data from VBRK into final internal table field symbol
            wa_final-vkorg  = <lfs_vbrk_vbrp>-vkorg.
            wa_final-vtweg  = <lfs_vbrk_vbrp>-vtweg.
            wa_final-vbeln  = <lfs_vbrk_vbrp>-vbeln.
            wa_final-fkart  = <lfs_vbrk_vbrp>-fkart.
            wa_final-fkdat  = <lfs_vbrk_vbrp>-fkdat.
            wa_final-erdat  = <lfs_vbrk_vbrp>-erdat.
            wa_final-waerk  = <lfs_vbrk_vbrp>-waerk.
            wa_final-rfbsk  = <lfs_vbrk_vbrp>-rfbsk.
            wa_final-kunag  = <lfs_vbrk_vbrp>-kunag.
            wa_final-kunrg  = <lfs_vbrk_vbrp>-kunrg.
            SHIFT wa_final-kunrg LEFT DELETING LEADING '0'.
            SHIFT wa_final-kunag LEFT DELETING LEADING '0'.
*populate the data from VBRP into final internal table field symbol
            wa_final-posnr  = <lfs_vbrk_vbrp>-posnr.
            wa_final-uepos  = <lfs_vbrk_vbrp>-uepos.
            wa_final-netwr  = <lfs_vbrk_vbrp>-netwr.
            wa_final-vgbel  = <lfs_vbrk_vbrp>-vgbel.
            wa_final-vgpos  = <lfs_vbrk_vbrp>-vgpos.
            wa_final-aubel  = <lfs_vbrk_vbrp>-aubel.
            SHIFT wa_final-aubel LEFT DELETING LEADING '0'.
            wa_final-aupos  = <lfs_vbrk_vbrp>-aupos.
            wa_final-matnr  = <lfs_vbrk_vbrp>-matnr.
            wa_final-arktx  = <lfs_vbrk_vbrp>-arktx.
            wa_final-pstyv  = <lfs_vbrk_vbrp>-pstyv.
            wa_final-werks  = <lfs_vbrk_vbrp>-werks.
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = <lfs_vbrk_vbrp>-prctr
              IMPORTING
                output = <lfs_vbrk_vbrp>-prctr.
            wa_final-prctr  = <lfs_vbrk_vbrp>-prctr.
            wa_final-mwsbp  = <lfs_vbrk_vbrp>-mwsbp.
*---> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
* Populate account assignment group and material group 1
            wa_final-mvgr1  = <lfs_vbrk_vbrp>-mvgr1.
            wa_final-ktgrm  = <lfs_vbrk_vbrp>-ktgrm.
            READ TABLE li_tvm1t ASSIGNING <lfs_tvm1t> WITH KEY mvgr1 = <lfs_vbrk_vbrp>-mvgr1
                                                               BINARY SEARCH.
            IF sy-subrc EQ 0.
* Material group 1 text
              wa_final-bezei = <lfs_tvm1t>-bezei.
            ENDIF.
            READ TABLE li_tvkmt  ASSIGNING <lfs_tvkmt> WITH KEY ktgrm = <lfs_vbrk_vbrp>-ktgrm
                                                                BINARY SEARCH.
            IF sy-subrc EQ 0.
* Account assignment group text
              wa_final-vtext_acc = <lfs_tvkmt>-vtext.
            ENDIF.
*<--- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*populate the billing type description field value in the output
            READ TABLE i_tvfkt ASSIGNING <lfs_tvfkt> WITH KEY fkart = <lfs_vbrk_vbrp>-fkart
                                                              BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_final-vtext   = <lfs_tvfkt>-vtext.
            ENDIF.
*populate the description data from TVAPT into final internal table field
            READ TABLE i_tvap ASSIGNING <lfs_tvap> WITH KEY pstyv = <lfs_vbrk_vbrp>-pstyv
                                                             BINARY SEARCH.
            IF sy-subrc EQ 0.
              READ TABLE i_tvapt ASSIGNING <lfs_tvapt> WITH KEY pstyv = <lfs_tvap>-pstyv
                                                                 BINARY SEARCH.
              IF sy-subrc EQ 0.
                wa_final-vtext_it  =  <lfs_tvapt>-vtext.
              ENDIF.
            ENDIF.
*populate the text field value retrieved from the domain values
            READ TABLE i_dd07t ASSIGNING <lfs_dd07t> WITH KEY domname     = c_rfbsk
                                                               domvalue_l = <lfs_vbrk_vbrp>-rfbsk
                                                               BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_final-vtext_bil = <lfs_dd07t>-ddtext.
            ENDIF.
*populate the data from LIKP into final internal table field symbol
            READ TABLE i_likp ASSIGNING <lfs_likp> WITH KEY vbeln = <lfs_vbrk_vbrp>-vgbel
                                                                BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_final-podat      = <lfs_likp>-podat.
              wa_final-wadat_ist  = <lfs_likp>-wadat_ist.
              wa_final-vkoiv      = <lfs_likp>-vkoiv.
              wa_final-vtwiv      = <lfs_likp>-vtwiv.
              wa_final-kuniv      = <lfs_likp>-kuniv.
            ENDIF.
*populate the data from VBUK into final internal table field symbol
            READ TABLE i_vbuk ASSIGNING <lfs_vbuk> WITH KEY vbeln = <lfs_vbrk_vbrp>-vgbel
                                                                BINARY SEARCH.
            IF sy-subrc EQ 0.
              wa_final-pdstk  = <lfs_vbuk>-pdstk.
              IF <lfs_vbuk>-pdstk EQ abap_false.
                wa_final-text_pod  = c_no.
              ELSE.
                wa_final-text_pod  = c_yes.
              ENDIF.
            ENDIF.
*populate the data from VBREVE into final internal table field symbol
            IF <lfs_tvap> IS ASSIGNED.
              IF  <lfs_tvap>-rrrel EQ abap_false.
                wa_final-text_revc  = c_no.
              ELSE.
                wa_final-text_revc  = c_yes.
                IF <lfs_tvap>-fkrel EQ c_m.
                  READ TABLE i_vbreve ASSIGNING <lfs_vbreve> WITH KEY vbeln   = <lfs_vbrk_vbrp>-aubel
                                                                      vbeln_n = <lfs_vbrk_vbrp>-vgbel
                                                                       BINARY SEARCH.
                  IF sy-subrc EQ 0.
                    wa_final-rrsta  = <lfs_vbreve>-rrsta.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
*---> Begin of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*   Below code has been commented out for defect 10303.
*   Material group 1 and account assignment group will be
*   fethced from billing instead of sales order
**populate the data from VBAP into final internal table field symbol
*READ TABLE i_vbap ASSIGNING <lfs_vbap> WITH KEY  vbeln = <lfs_vbrk_vbrp>-aubel
**Begin of code change - Defect #10042 - ShivaNagh Samala - July 16-2019
*                                                 posnr = <lfs_vbrk_vbrp>-aupos
**End of code change - Defect #10042 - ShivaNagh Samala - July 16-2019
*                                                  BINARY SEARCH.
* IF sy-subrc EQ 0.
*   wa_final-mvgr1  = <lfs_vbap>-mvgr1.
*   wa_final-ktgrm  = <lfs_vbap>-ktgrm.
*READ TABLE i_tvm1t ASSIGNING <lfs_tvm1t> WITH KEY mvgr1 = <lfs_vbap>-mvgr1
*                                                   BINARY SEARCH.
*  IF sy-subrc EQ 0.
*wa_final-bezei = <lfs_tvm1t>-bezei.
*  ENDIF.
*READ TABLE i_tvkmt  ASSIGNING <lfs_tvkmt> WITH KEY ktgrm = <lfs_vbap>-ktgrm
*                                                    BINARY SEARCH.
*IF sy-subrc EQ 0.
*wa_final-vtext_acc = <lfs_tvkmt>-vtext.
*ENDIF.
* ENDIF.
*<--- End of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*append the record to the final internal table
            APPEND wa_final TO i_final.
            CLEAR wa_final.
          ENDLOOP.
        ELSE.
          MESSAGE  e095. "No Data Found For The Given Selection Criteria
        ENDIF.

      ENDIF.
    ELSE.
      MESSAGE  e095. "No Data Found For The Given Selection Criteria
    ENDIF.
  ELSE.
    MESSAGE e095. "No Data Found For The Given Selection Criteria
  ENDIF.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_FIELDCAT
*&---------------------------------------------------------------------*
*       To prepare the fieldcatalog
*----------------------------------------------------------------------*
*      <--fP_I_FIELDCAT[]  Intenal table for filed catalog
*----------------------------------------------------------------------*
FORM f_build_fieldcatalog CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv.

  PERFORM f_populate_fieldcat USING:
         'VKORG'     'I_FINAL' 'Sales Org'(001)                   CHANGING fp_i_fieldcat,
         'VTWEG'     'I_FINAL' 'Dist Chan'(002)                   CHANGING fp_i_fieldcat,
         'VBELN'     'I_FINAL' 'Billing Doc.'(003)                CHANGING fp_i_fieldcat,
         'POSNR'     'I_FINAL' 'Billing Item'(004)                CHANGING fp_i_fieldcat,
         'UEPOS'     'I_FINAL' 'Higher-lev Item'(005)             CHANGING fp_i_fieldcat,
         'FKART'     'I_FINAL' 'Billing Type'(006)                CHANGING fp_i_fieldcat,
         'VTEXT'     'I_FINAL' 'Billing Type Desc'(007)           CHANGING fp_i_fieldcat,
         'FKDAT'     'I_FINAL' 'Billing Date'(008)                CHANGING fp_i_fieldcat,
         'ERDAT'     'I_FINAL' 'Billing Created On'(009)          CHANGING fp_i_fieldcat,
         'NETWR'     'I_FINAL' 'Net Value'(010)                   CHANGING fp_i_fieldcat,
         'WAERK'     'I_FINAL' 'Doc Curr'(011)                    CHANGING fp_i_fieldcat,
         'VGBEL'     'I_FINAL' 'Ref.doc.'(013)                    CHANGING fp_i_fieldcat,
         'VGPOS'     'I_FINAL' 'Ref line item'(040)               CHANGING fp_i_fieldcat,
         'AUBEL'     'I_FINAL' 'Sales Doc'(014)                   CHANGING fp_i_fieldcat,
         'AUPOS'     'I_FINAL' 'Sales Doc Item'(015)              CHANGING fp_i_fieldcat,
         'MATNR'     'I_FINAL' 'Material'(016)                    CHANGING fp_i_fieldcat,
         'ARKTX'     'I_FINAL' 'Description'(017)                 CHANGING fp_i_fieldcat,
         'PSTYV'     'I_FINAL' 'Item Category'(018)               CHANGING fp_i_fieldcat,
         'VTEXT_IT'  'I_FINAL' 'Item Category Desc'(019)          CHANGING fp_i_fieldcat,
         'WERKS'     'I_FINAL' 'Plant'(020)                       CHANGING fp_i_fieldcat,
         'PRCTR'     'I_FINAL' 'Profit Center'(021)               CHANGING fp_i_fieldcat,
         'MWSBP'     'I_FINAL' 'Tax Amount'(022)                  CHANGING fp_i_fieldcat,
         'RFBSK'     'I_FINAL' 'Billing Posting Status'(023)      CHANGING fp_i_fieldcat,
         'VTEXT_BIL' 'I_FINAL' 'Billing Posting Status Desc'(024) CHANGING fp_i_fieldcat,
         'PODAT'     'I_FINAL' 'POD date'(025)                    CHANGING fp_i_fieldcat,
         'WADAT_IST' 'I_FINAL' 'Actual PGI date'(026)             CHANGING fp_i_fieldcat,
         'PDSTK'     'I_FINAL' 'POD status'(027)                  CHANGING fp_i_fieldcat,
         'RRSTA'     'I_FINAL' 'Rev Recog status'(028)            CHANGING fp_i_fieldcat,
         'KUNAG'     'I_FINAL' 'Sold To'(029)                     CHANGING fp_i_fieldcat,
         'KUNRG'     'I_FINAL' 'Payer'(030)                       CHANGING fp_i_fieldcat,
         'TEXT_POD'  'I_FINAL' 'Relevant for POD'(031)            CHANGING fp_i_fieldcat,
         'TEXT_REVC' 'I_FINAL' 'Relevant for Rev Rec'(032)        CHANGING fp_i_fieldcat,
         'MVGR1'     'I_FINAL' 'Material Group 1'(033)            CHANGING fp_i_fieldcat,
         'BEZEI'     'I_FINAL' 'Material Group 1 Desc'(034)       CHANGING fp_i_fieldcat,
         'KTGRM'     'I_FINAL' 'Acc Assign Grp'(035)              CHANGING fp_i_fieldcat,
         'VTEXT_ACC' 'I_FINAL' 'Acc Assign Grp Desc'(036)         CHANGING fp_i_fieldcat,
         'VKOIV'     'I_FINAL' 'EHQ/USPA Sales Org'(037)          CHANGING fp_i_fieldcat,
         'VTWIV'     'I_FINAL' 'EHQ/USPA Dist Chan'(038)          CHANGING fp_i_fieldcat,
         'KUNIV'     'I_FINAL' 'IC Customer'(039)                 CHANGING fp_i_fieldcat.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_POPULATE_FIELDCAT
*&---------------------------------------------------------------------*
*       To populate the field catalog
*----------------------------------------------------------------------*
*      -->fp_fnam           fieldname
*      -->fp_itab           table name
*      -->fp_descr          field description
*      <--FP_I_FIELDCAT  Internal Table for Field Catalog
*----------------------------------------------------------------------*
FORM f_populate_fieldcat  USING   fp_fnam    TYPE slis_fieldname      "fieldname
                                  fp_itab    TYPE slis_tabname        "table name
                                  fp_descr   TYPE text60              "field description
                          CHANGING fp_i_fieldcat TYPE slis_t_fieldcat_alv. "Internal Table for Field Catalog

  DATA : lwa_fcat TYPE slis_fieldcat_alv, "work area for fieldcatalog
         lv_descr TYPE dd03p-scrtext_l.
  STATICS lv_fpos TYPE sycucol. " Horizontal Cursor Position at PAI
  CLEAR : lwa_fcat,
          lv_descr.

  lv_descr = fp_descr.
  lwa_fcat-seltext_l     = lv_descr.
  lv_fpos = lv_fpos + 1.
  lwa_fcat-col_pos       = lv_fpos.
  lwa_fcat-fieldname     = fp_fnam.
  lwa_fcat-tabname       = fp_itab.
  APPEND lwa_fcat TO fp_i_fieldcat.
  CLEAR lwa_fcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ALV
*&---------------------------------------------------------------------*
*       To display ALV
*----------------------------------------------------------------------*
*      -->FP_I_FIELDCAT[] Internal Table for Field Catalog
*      -->FP_I_FINAL[]    Final Internal table
*----------------------------------------------------------------------*
FORM f_alv_display USING    fp_i_fieldcat TYPE slis_t_fieldcat_alv
                            fp_i_final    TYPE ty_t_final.
*fill the top header of the output display
  PERFORM f_top_header.
*fill the layout settings of the alv display
  wa_layo-colwidth_optimize  = abap_true.

*function module to display the output in ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = lc_top_page
      is_layout              = wa_layo
      it_fieldcat            = fp_i_fieldcat
      i_save                 = lc_a
    TABLES
      t_outtab               = fp_i_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc IS NOT INITIAL.
    MESSAGE  e132.    "Issue in ALV display
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_TOP_HEADER
*&---------------------------------------------------------------------*
*       To populate the header
*----------------------------------------------------------------------*
FORM f_top_header .

  wa_listheader-typ  = c_typ_h.
  wa_listheader-info = 'VFX3 Accrual Report'(041).
  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.

  wa_listheader-typ  = c_typ_s.
  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.

  wa_listheader-typ = c_typ_s.
  wa_listheader-key = 'Date and Time'(045).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO v_time
         SEPARATED BY c_colon. "':'.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO v_date
         SEPARATED BY c_slash. "'/'.

  CONCATENATE v_date
              v_time
         INTO wa_listheader-info
         SEPARATED BY space.
  APPEND wa_listheader TO i_listheader.
  CLEAR wa_listheader.


ENDFORM. "f_top_header

*&---------------------------------------------------------------------*
*&      Form  sub_top_of_page
*&---------------------------------------------------------------------*
*      Subroutine is used to call TOP OF PAGE event dynamically
*----------------------------------------------------------------------*
*      <-- i_top using internal table for the TOP_OF_PAGE
*----------------------------------------------------------------------*
FORM f_top_of_page.                                         "#EC CALLED
* Subroutine for top of page
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM. "f_top_of_page


FORM f_print_spool_pdf.
  DATA: i_pdf   TYPE STANDARD TABLE OF tline,
        lwa_pdf TYPE tline,
        l_buff  TYPE string.
  CLEAR gv_spono.
  gv_spono = sy-spono.

  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = gv_spono
      no_dialog                = space
    TABLES
      pdf                      = i_pdf
    EXCEPTIONS
      err_no_abap_spooljob     = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_destdevice       = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.
  IF sy-subrc EQ 0.

* Transfer the 132-long strings to 255-long strings
    LOOP AT i_pdf INTO lwa_pdf.
      TRANSLATE lwa_pdf USING ' ~'.
      CONCATENATE l_buff lwa_pdf INTO l_buff.
    ENDLOOP.

    TRANSLATE l_buff USING '~ '.

    DO.
      wa_msg_att = l_buff.
      APPEND wa_msg_att TO  i_msg_att.
      SHIFT l_buff LEFT BY c_255 PLACES.
      IF l_buff IS INITIAL.
        EXIT.
      ENDIF.
    ENDDO.

  ELSE.
    MESSAGE e314. "Spool to pdf conversion error

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  Z_DELETE_SPOOL
*&---------------------------------------------------------------------*
FORM z_delete_spool .
  DATA: l_spool_nr TYPE tsp01_sp0r-rqid_char.

  l_spool_nr = gv_spono.

  CALL FUNCTION 'RSPO_R_RDELETE_SPOOLREQ'
    EXPORTING
      spoolid = l_spool_nr.

ENDFORM.                    " Z_DELETE_SPOOL
*&---------------------------------------------------------------------*
*&      Form  F_SEND_PDF_EMAIL
*&---------------------------------------------------------------------*
FORM f_send_pdf_email .

  CLASS: cl_abap_char_utilities DEFINITION LOAD.
  FIELD-SYMBOLS : <lfs_final>  TYPE ty_final.
*-------Constants Declaration------------------------------------------*
  CONSTANTS: lc_tab   TYPE char1      VALUE cl_abap_char_utilities=>horizontal_tab, "Constant for Excel data
             lc_ret   TYPE char1      VALUE cl_abap_char_utilities=>cr_lf,
             lc_sign  TYPE char3      VALUE 'RAW',                                  "RAW
             lc_exe   TYPE char5      VALUE 'EXCEL',                                "Excel
             lc_fmat  TYPE char3      VALUE 'xls',                                  "Excel Format
             lc_e1p   TYPE char3      VALUE 'E1P',
             lc_xsx   TYPE char16     VALUE 'EXCEL ATTACHMENT',                     "Attachment
             lc_let   TYPE char3      VALUE '255',                                  "Constant for literal
*--> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
             lc_minus TYPE char1     VALUE '-'.                                    "-VE sign
*<-- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*-----Variable Declaration-------------*
  DATA : lv_lines_bin     TYPE i,          "no of lines for excel data
         lv_message_lines TYPE i,          "no of lines for body of mail
         lv_mailaddr      TYPE so_recname, "storing email id
         lv_string        TYPE string,     "String
         lv_flag          TYPE char1,      "flag
         lvx_string       TYPE xstring,    "String
         lv_filename(255) TYPE c,
         lv_desc          TYPE sodocchgi1-obj_descr,
         lv_netwr         TYPE char20,
***          lv_nt            TYPE p DECIMALS 1,
         lv_d             TYPE char10,
         lv_length        TYPE i,
         lv_leng(2)       TYPE c,
         lv_d1            TYPE char10,
         lv_erd           TYPE char10,
         lv_mat           TYPE char50,
         lv_fkd           TYPE char10,
         lv_mwsbp         TYPE char20,
*-------------Local Internal Table Declaration-----------------------------------*
         li_contents_hex  TYPE STANDARD TABLE OF solix  INITIAL SIZE 0,
         li_contents_hex1 TYPE STANDARD TABLE OF solix  INITIAL SIZE 0,
         li_objpack       TYPE STANDARD TABLE OF  sopcklsti1 INITIAL SIZE 0,
         li_message       TYPE STANDARD TABLE OF  solisti1   INITIAL SIZE 0,
         li_reclist       TYPE STANDARD TABLE OF  somlreci1  INITIAL SIZE 0,
         li_objbin        TYPE STANDARD TABLE OF  solisti1 INITIAL SIZE 0,
*---------workarea Declaration-----------------------------*
         lwa_content_hex  TYPE solix,       "work area for hex data
         lwa_objbin       TYPE  solisti1,   "work area for objbin
         lwa_imessage     TYPE  solisti1,   "work area imessage
         lwa_i_reclist    TYPE  somlreci1,
         lx_doc_chng      TYPE  sodocchgi1, "Structure for Excel data
         lwa_it_objpack   TYPE  sopcklsti1. "Structure for Excel data

  FIELD-SYMBOLS: <lfs_objbin> TYPE solisti1.        "Field Symbol

*populate the text for body of the mail
  CLEAR lwa_imessage.
  lwa_imessage-line = 'Please find above the excel attached for Accrual Report'(043).
  APPEND lwa_imessage TO li_message.

  DESCRIBE TABLE li_message LINES lv_message_lines. "no of lines for body of mail

  READ TABLE li_message INTO lwa_imessage INDEX lv_message_lines.
  IF sy-subrc = 0.
    lx_doc_chng-obj_name   = lc_exe. "Excel
*if the program is not running in production environment then concatenate the sysid to the subject line
*to the email send
    IF syst-sysid NE lc_e1p.
      CONCATENATE   'VFX3 Accrual Report'(041) '(' syst-sysid ')' INTO lv_desc.
      lx_doc_chng-obj_descr  = lv_desc.
    ELSE.
      lx_doc_chng-obj_descr  = 'VFX3 Accrual Report'(041).
    ENDIF.
    lx_doc_chng-doc_size   = ( lv_message_lines - 1 ) * lc_let + strlen( lwa_imessage-line ). " calculating total
  ENDIF.
*displaying Header in the excel
  CONCATENATE 'Sales Org'(001)
              'Dist Chan'(002)
              'Billing Doc.'(003)
              'Billing Item'(004)
              'Higher-lev Item'(005)
              'Billing Type'(006)
              'Billing Type Desc'(007)
              'Billing Date'(008)
              'Billing Created On'(009)
              'Net Value'(010)
              'Doc Curr'(011)
              'Ref.doc.'(013)
               INTO lwa_objbin SEPARATED BY lc_tab.
  CONCATENATE lwa_objbin lc_tab INTO lwa_objbin.
  APPEND lwa_objbin TO li_objbin.
  CLEAR : lwa_objbin.
  CONCATENATE 'Ref line item'(040)
              'Sales Doc'(014)
              'Sales Doc Item'(015)
              'Material'(016)
              'Description'(017)
              'Item Category'(018)
              'Item Category Desc'(019)
              'Plant'(020)
              'Profit Center'(021)
              'Tax Amount'(022)
              'Billing Posting Status'(023)
              'Billing Posting Status Desc'(024)
              INTO lwa_objbin SEPARATED BY lc_tab.
  CONCATENATE lwa_objbin lc_tab INTO lwa_objbin.
  APPEND lwa_objbin TO li_objbin.
  CLEAR : lwa_objbin.
  CONCATENATE   'POD date'(025)
                'Actual PGI date'(026)
                'POD status'(027)
                'Rev Recog status'(028)
                'Sold To'(029)
                'Payer'(030)
                'Relevant for POD'(031)
                'Relevant for Rev Rec'(032)
                'Material Group 1'(033)
                'Material Group 1 Desc'(034)
                'Acc Assign Grp'(035)
                'Acc Assign Grp Desc'(036)
                'EHQ/USPA Sales Org'(037)
                'EHQ/USPA Dist Chan'(038)
                'IC Customer'(039)
                 INTO lwa_objbin SEPARATED BY lc_tab.
  CONCATENATE lwa_objbin lc_ret   INTO lwa_objbin.
  APPEND lwa_objbin TO li_objbin.
  CLEAR : lwa_objbin.

*populate the final internal table data to the file
  LOOP AT i_final ASSIGNING <lfs_final>.
    CLEAR : lv_netwr,
            lv_mwsbp,
            lv_erd,
            lv_mat,
            lv_fkd.

    IF NOT <lfs_final>-fkdat IS INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = <lfs_final>-fkdat
        IMPORTING
          date_external            = lv_fkd
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc NE 0.
        CLEAR lv_fkd.
      ENDIF.
    ELSE.
      lv_fkd = abap_false.
    ENDIF.

    IF NOT <lfs_final>-erdat IS INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = <lfs_final>-erdat
        IMPORTING
          date_external            = lv_erd
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc NE 0.
        CLEAR lv_erd.
      ENDIF.
    ELSE.
      lv_erd = abap_false.
    ENDIF.

    WRITE <lfs_final>-netwr TO lv_netwr CURRENCY <lfs_final>-waerk.
    WRITE <lfs_final>-mwsbp TO lv_mwsbp CURRENCY <lfs_final>-waerk.
*--> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
* As per defect 10303, the -ve symbol for net value less than 0 should be shown
* at the beginning of the  number during background processing of the report.
    IF <lfs_final>-netwr < 0.
      SPLIT lv_netwr AT lc_minus INTO lv_netwr DATA(lv_text1).
      CONDENSE lv_netwr.
      CONCATENATE lc_minus lv_netwr INTO lv_netwr.
    ENDIF.
*<-- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
    CONCATENATE  <lfs_final>-vkorg
                 <lfs_final>-vtweg
                 <lfs_final>-vbeln
                 <lfs_final>-posnr
                 <lfs_final>-uepos
                 <lfs_final>-fkart
                 <lfs_final>-vtext
                 lv_fkd
                 lv_erd
                 lv_netwr
                 <lfs_final>-waerk
                 <lfs_final>-vgbel
                 INTO lwa_objbin SEPARATED BY lc_tab.
    CONCATENATE lwa_objbin lc_tab INTO lwa_objbin.
    APPEND lwa_objbin TO li_objbin.
    CLEAR : lwa_objbin.
    lv_length = strlen( <lfs_final>-matnr  ).
    lv_leng   = lv_length.
    CONCATENATE '=REPLACE("' <lfs_final>-matnr '",1,"' lv_leng '" ,"'
                             <lfs_final>-matnr '")' INTO lv_mat .
    CONCATENATE <lfs_final>-vgpos
                <lfs_final>-aubel
                <lfs_final>-aupos
                lv_mat
                <lfs_final>-arktx
                <lfs_final>-pstyv
                <lfs_final>-vtext_it
                <lfs_final>-werks
                <lfs_final>-prctr
                lv_mwsbp
                <lfs_final>-rfbsk
                <lfs_final>-vtext_bil
                INTO lwa_objbin SEPARATED BY lc_tab.
    CONCATENATE lwa_objbin lc_tab INTO lwa_objbin.
    APPEND lwa_objbin TO li_objbin.
    CLEAR : lwa_objbin.
    CLEAR : lv_d,
            lv_d1.
    IF NOT  <lfs_final>-wadat_ist IS INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = <lfs_final>-wadat_ist
        IMPORTING
          date_external            = lv_d
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc NE 0.
        CLEAR lv_d.
      ENDIF.
    ELSE.
      lv_d = abap_false.
    ENDIF.

    IF NOT <lfs_final>-podat IS INITIAL.
      CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
        EXPORTING
          date_internal            = <lfs_final>-podat
        IMPORTING
          date_external            = lv_d1
        EXCEPTIONS
          date_internal_is_invalid = 1
          OTHERS                   = 2.
      IF sy-subrc NE 0.
        CLEAR lv_d1.
      ENDIF.
    ELSE.
      lv_d1 = abap_false.
    ENDIF.
    CONCATENATE  lv_d1
                 lv_d
                <lfs_final>-pdstk
                <lfs_final>-rrsta
                <lfs_final>-kunag
                <lfs_final>-kunrg
                <lfs_final>-text_pod
                <lfs_final>-text_revc
                <lfs_final>-mvgr1
                <lfs_final>-bezei
                <lfs_final>-ktgrm
                <lfs_final>-vtext_acc
                <lfs_final>-vkoiv
                <lfs_final>-vtwiv
                <lfs_final>-kuniv
                INTO lwa_objbin SEPARATED BY lc_tab.
    CONCATENATE lwa_objbin lc_ret INTO lwa_objbin.
    APPEND lwa_objbin TO li_objbin.
    CLEAR lwa_objbin.
  ENDLOOP.
  CLEAR : lv_filename,
          wa_final.

*concatenate the file path system date and time into the file path
  CONCATENATE '/appl/'(047) syst-sysid '/REP/OTC/OTC_RDD_0142/VFX3 Accrual Report_'(048) syst-datum '&' syst-uzeit '_' sy-uname '.CSV' INTO lv_filename.

*Open the file path, to copy data .
  OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
*Transfer of data.
    LOOP AT li_objbin INTO lwa_objbin.
      TRANSFER lwa_objbin TO lv_filename.
    ENDLOOP.
    CLOSE DATASET lv_filename.
*populate the flag to be used later to print the final status message
    gv_flag = abap_true.
  ELSE.
    gv_flag = abap_false.
  ENDIF.

  LOOP AT li_objbin ASSIGNING <lfs_objbin>.
    lv_string = <lfs_objbin>-line.

    CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
      EXPORTING
        text   = lv_string
      IMPORTING
        buffer = lvx_string
      EXCEPTIONS
        failed = 1
        OTHERS = 2.

    IF sy-subrc = 0.
      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lvx_string
        TABLES
          binary_tab = li_contents_hex1.

      LOOP AT li_contents_hex1 INTO lwa_content_hex.
        APPEND lwa_content_hex TO li_contents_hex.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  DESCRIBE TABLE li_contents_hex LINES lv_lines_bin.
  CLEAR lwa_it_objpack-transf_bin. "Obj. to be transported not in binary form
  lwa_it_objpack-head_start = 1. "Start line of object header in transport packet
  lwa_it_objpack-head_num   = 0. "Number of lines of an object header in object packet
  lwa_it_objpack-body_start = 1. "Start line of object contents in an object packet
  lwa_it_objpack-body_num   = lv_message_lines. "Number of lines of the mail body
  lwa_it_objpack-doc_type   = lc_sign. "RAW
  APPEND lwa_it_objpack TO li_objpack.
  CLEAR lwa_it_objpack.

  lwa_it_objpack-transf_bin = c_x. " Should be X
  lwa_it_objpack-head_start = 1.
  lwa_it_objpack-head_num = 1.
  lwa_it_objpack-body_start = 1.
  lwa_it_objpack-body_num = lv_lines_bin. "no of lines of it_orders to give no of unprocessed orders
  lwa_it_objpack-doc_type = lc_fmat. "XLS ->  excel fomat
  lwa_it_objpack-obj_name = lc_xsx. "EXCEL ATTACHMENT

  CONCATENATE TEXT-041 '.xls'(046)  INTO lwa_it_objpack-obj_descr. " Obselete Material Quantity
  lwa_it_objpack-doc_size = lv_lines_bin * lc_let.
  APPEND lwa_it_objpack TO li_objpack.

  CLEAR lv_mailaddr.
*populate the email address entered in the selection screen
  lv_mailaddr = p_text.
*e-mail receivers.
  CLEAR lwa_i_reclist.
  lwa_i_reclist-receiver = lv_mailaddr.
  lwa_i_reclist-express =  c_x.                 " X
  lwa_i_reclist-rec_type = c_u.                 " U ->  Internet address
  APPEND lwa_i_reclist TO li_reclist.
  CLEAR  lwa_i_reclist.

  DELETE ADJACENT DUPLICATES FROM li_reclist COMPARING receiver.
*use the function module to send the output data to the email id entered in the selection screen
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = lx_doc_chng
      put_in_outbox              = c_x
      commit_work                = c_x
    TABLES
      packing_list               = li_objpack
      contents_txt               = li_message
      contents_hex               = li_contents_hex
      receivers                  = li_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  IF sy-subrc <> 0.
    lv_flag = abap_false.
  ELSE.
    PERFORM z_delete_spool.
    lv_flag = c_x.
  ENDIF.

  IF gv_flag = c_x AND
     lv_flag = c_x.
    MESSAGE s310.   "Data saved in application server and Data sent to email
  ELSEIF gv_flag = c_x AND
         lv_flag = abap_false.
    MESSAGE e311.   "Data saved in application server but Data NOT sent to email
  ELSEIF  gv_flag = abap_false AND
          lv_flag = c_x.
    MESSAGE e312.   "Data NOT saved in application server but Data  sent to email
  ELSEIF gv_flag = abap_false AND
         lv_flag = abap_false.
    MESSAGE e313.   "Data NOT saved in application server and Data NOT sent to email
  ENDIF.

ENDFORM.                    " Z_SEND_PDF_EMAIL

FORM f_call_alv.
  DATA: lwa_print TYPE slis_print_alv,
        lv_repid  TYPE sy-repid.
*fill the report name and print parameters to pass to the function module
  lv_repid = sy-repid.
  lwa_print-print = c_n.   "N

*build fieldcatalog to display the fields in the output
  PERFORM f_build_fieldcatalog CHANGING i_fieldcat[].

* call alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = lv_repid
      it_fieldcat        = i_fieldcat
      i_default          = c_x
      is_print           = lwa_print
    TABLES
      t_outtab           = i_final
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc NE 0.
    MESSAGE  e132.    "Issue in ALV display
  ENDIF.
  PERFORM f_print_spool_pdf.

ENDFORM.
