*&---------------------------------------------------------------------*
*&  Include           ZOTCN0495O_MATERIAL_TEXTS
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0406O_MATERIAL_TEXTS (Include)                    *
* TITLE      :  Copy_Char_Value_from_Matl_To_Sales_Order_text          *
* DEVELOPER  :  Srinivasa Gurijala                                     *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0406                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Populate Sales Order Line item texts in  from Material *
*               Classification for Italy  for Public Customer with     *
*               Industry Code Populated                                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*03-Mar-2017 U033814  E1DK934970  Initial                              *
*&---------------------------------------------------------------------*
*02-Jun-2018 U033876  E1DK937056  Defect 6300, Issue with Lv_num as    *
* declared as char2 and if value is more than "99" then short dump occurs*
*&---------------------------------------------------------------------*

DATA :
          lwa_header       TYPE thead,                   " Header workarea
          lwa_lines        TYPE tline,                   " Short Text
          li_lines         TYPE STANDARD TABLE OF tline, " Short text
          lv_num           TYPE char2 VALUE '20',        " Num of type CHAR2
          lv_bran1          TYPE bran1_d.                " Industry Code 1

FIELD-SYMBOLS: <lfs_xvbapt> TYPE vbapvb, " Document Structure for XVBAP/YVBAP
               <lfs_xvbpa> TYPE vbpavb.  " Reference structure for XVBPA/YVBPA

CONSTANTS :
          lc_edd_0406     TYPE z_enhancement    VALUE 'OTC_EDD_0406', " Enhancement No.
          lc_vbeln        TYPE char10           VALUE 'XXXXXXXXXX',   " Vbeln of type CHAR10
          lc_object       TYPE tdobject         VALUE 'VBBP',         " Texts: Application Object
          lc_id           TYPE char2            VALUE 'Z0',           " Id of type CHAR2
          lc_vkorg1       TYPE z_criteria       VALUE 'VKORG',        " Enh. Criteria
          lc_bran1        TYPE z_criteria       VALUE 'BRAN1'.        " Enh. Criteria


TYPES:
          BEGIN OF ty_cabn,
            atinn TYPE  atinn,  " Internal characteristic
            adzhl TYPE  adzhl,  " Internal counter for archiving objects via engin. chg. mgmt
            atnam TYPE  atnam,  " Characteristic Name
          END OF ty_cabn,
          BEGIN OF ty_ausp,
            objek TYPE  objnum, " Key of object to be classified
            atinn TYPE  atinn,  " Internal characteristic
            atzhl	TYPE wzaehl,
            mafid	TYPE klmaf,
            klart	TYPE klassenart,
            atwrt TYPE atwrt,   " Characteristic Value
           END OF ty_ausp,
           BEGIN OF ty_objek,
             objek TYPE objnum, " Key of object to be classified
           END OF ty_objek.

DATA :
       li_cabn    TYPE STANDARD TABLE OF ty_cabn INITIAL SIZE 0,
       li_ausp    TYPE STANDARD TABLE OF ty_ausp INITIAL SIZE 0,
       li_objek   TYPE STANDARD TABLE OF ty_objek INITIAL SIZE 0,
       lwa_ausp   TYPE ty_ausp,
       lv_tabix_1 TYPE sy-tabix, " Index of Internal Tables
       lwa_objek  TYPE ty_objek,
       lwa_cabn   TYPE ty_cabn.  " Characteristic

CONSTANTS : lc_klart TYPE klassenart VALUE '001',       " Class Type
            lc_atnam TYPE atnam VALUE 'ZM_TIPO',        " Characteristic Name
            lc_atnam1 TYPE atnam VALUE 'ZM_CODICE_CND', " Characteristic Name
            lc_atnam2 TYPE atnam VALUE 'ZM_NUMERO_RDM'. " Characteristic Name



IF t180-trtyp EQ 'H'.
* Call to EMI Function Module To Get List Of EMI Statuses
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_edd_0406
    TABLES
      tt_enh_status     = li_status. "Enhancement status table

  DELETE li_status WHERE active = space.

  READ TABLE li_status WITH KEY criteria = lc_null "NULL
                       TRANSPORTING NO FIELDS.
  IF sy-subrc EQ  0.
    READ TABLE xvbpa ASSIGNING <lfs_xvbpa> WITH KEY parvw = 'AG'.
    IF sy-subrc EQ 0 and <lfs_xvbpa>-kunnr IS ASSIGNED.
      SELECT SINGLE bran1 FROM kna1 INTO lv_bran1 WHERE kunnr EQ <lfs_xvbpa>-kunnr.
      IF lv_bran1 IS NOT INITIAL.
        READ TABLE li_status WITH KEY criteria = lc_vkorg1
                                      sel_low  = vbak-vkorg
                                      TRANSPORTING NO FIELDS. " No Binary Search required as table containes very few entries.
        IF sy-subrc = 0.

          READ TABLE li_status WITH KEY criteria = lc_bran1
                                        sel_low  = lv_bran1
                                        TRANSPORTING NO FIELDS.
          IF sy-subrc EQ 0.
            LOOP AT xvbap ASSIGNING <lfs_xvbap>.
              MOVE <lfs_xvbap>-matnr TO lwa_objek-objek.
              APPEND lwa_objek TO li_objek.
            ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_xvbap>

            SELECT atinn adzhl atnam FROM cabn " Characteristic
                        INTO TABLE li_cabn
                     WHERE atnam EQ lc_atnam
                       OR atnam EQ lc_atnam1
                       OR atnam EQ lc_atnam2
                       AND datuv LT sy-datum.

            IF sy-subrc IS INITIAL.
              SELECT objek atinn atzhl mafid klart atwrt FROM ausp " Characteristic Values
                             INTO TABLE li_ausp FOR ALL ENTRIES IN li_objek
                                              WHERE objek EQ li_objek-objek
*                                            AND atinn eq li_cabn-atinn
                                                AND klart EQ lc_klart.
              IF sy-subrc EQ 0.
                SORT li_cabn BY atinn.
                LOOP AT li_ausp INTO lwa_ausp.
                  lv_tabix_1 = sy-tabix.
                  READ TABLE li_cabn INTO lwa_cabn WITH KEY atinn = lwa_ausp-atinn.
                  IF sy-subrc NE 0.
                    DELETE li_ausp INDEX lv_tabix_1.
                  ENDIF. " IF sy-subrc NE 0
                ENDLOOP. " LOOP AT li_ausp INTO lwa_ausp
                SORT li_ausp BY objek atinn.
                SORT li_cabn BY atnam.
                LOOP AT xvbap ASSIGNING <lfs_xvbap>.
                  DO 3 TIMES.
                    lv_tabix_1 = sy-index.
                    MOVE lc_object TO lwa_header-tdobject.
                    CONCATENATE lc_vbeln <lfs_xvbap>-posnr INTO lwa_header-tdname.
                    CONCATENATE lc_id lv_num INTO lwa_header-tdid.
                    MOVE sy-langu TO lwa_header-tdspras.
                    lv_num = lv_num + 1.
                    CASE lv_tabix_1.
                      WHEN 1.
                        READ TABLE li_cabn INTO lwa_cabn WITH KEY atnam = lc_atnam.
                        IF sy-subrc EQ 0.
                          READ TABLE li_ausp INTO lwa_ausp WITH KEY objek =  <lfs_xvbap>-matnr
                                                                   atinn =  lwa_cabn-atinn BINARY SEARCH.
                          IF sy-subrc EQ 0.
                            MOVE lwa_ausp-atwrt TO lwa_lines-tdline.
                            APPEND lwa_lines TO li_lines.
                          ENDIF. " IF sy-subrc EQ 0
                        ENDIF. " IF sy-subrc EQ 0
                      WHEN 2.
                        READ TABLE li_cabn INTO lwa_cabn WITH KEY atnam = lc_atnam1.
                        IF sy-subrc EQ 0.
                          READ TABLE li_ausp INTO lwa_ausp WITH KEY objek =  <lfs_xvbap>-matnr
                                                                   atinn =  lwa_cabn-atinn BINARY SEARCH.
                          IF sy-subrc EQ 0.
                            MOVE lwa_ausp-atwrt TO lwa_lines-tdline.
                            APPEND lwa_lines TO li_lines.
                          ENDIF. " IF sy-subrc EQ 0
                        ENDIF. " IF sy-subrc EQ 0
                      WHEN 3.
                        READ TABLE li_cabn INTO lwa_cabn WITH KEY atnam = lc_atnam2.
                        IF sy-subrc EQ 0.
                          READ TABLE li_ausp INTO lwa_ausp WITH KEY objek =  <lfs_xvbap>-matnr
                                                                   atinn =  lwa_cabn-atinn BINARY SEARCH.
                          IF sy-subrc EQ 0.
                            MOVE lwa_ausp-atwrt TO lwa_lines-tdline.
                            APPEND lwa_lines TO li_lines.
                          ENDIF. " IF sy-subrc EQ 0
                        ENDIF. " IF sy-subrc EQ 0
                    ENDCASE.
*       Save the short text
                    CALL FUNCTION 'SAVE_TEXT'
                      EXPORTING
                        header          = lwa_header
*                       savemode_direct = abap_true
                      TABLES
                        lines           = li_lines
                      EXCEPTIONS
                        id              = 1
                        language        = 2
                        name            = 3
                        object          = 4
                        OTHERS          = 5.
                    CLEAR : lwa_header , li_lines.
                  ENDDO.
* Begin of change for Defect 6300 by U033876
* reset the lv_num to "20" after do loop so that for each item we have 3 times
                  lv_num = '20'.
* End of change for defect 6300 by U033876.
                ENDLOOP. " LOOP AT xvbap ASSIGNING <lfs_xvbap>
              ENDIF. " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc IS INITIAL
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lv_bran1 IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF sy-subrc EQ 0
ENDIF. " IF t180-trtyp EQ 'H'
