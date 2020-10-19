************************************************************************
* PROGRAM    :  ZOTCN0009I_ORDER_ASSIGN(Include)                       *
* TITLE      :  Order Assignment                                       *
* DEVELOPER  :  SHAMMI PURI                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0009                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: Population of VBAK AUFNR form Incoming BELNR
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 03-JUL-2012  SPURI   E1DK903577  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 06-APR-2015  ASK   E2DK900747  Defect #4905 Removed the hardcoding   *
*                                Sales Area during SELECT from Process *
*                                control table . Also if VBAK-VGBEL is *
*                                already ZRRC type Contract then put   *
*                                that in VBAP-AUFNR                    *
*&---------------------------------------------------------------------*

CONSTANTS : c_order_reason_s01 TYPE vbak-augru   VALUE 'S01',                     "Order Reason
            c_doc_type_g       TYPE vbfa-vbtyp_v VALUE 'G',                       "Document type
            c_sales_org        TYPE vkorg        VALUE '1000',                    "Sales organization
            c_dist_ch          TYPE vtweg        VALUE '10',                      "Distribution Channel
            c_prog_name        TYPE char50       VALUE 'ZOTCN0009I_ORDER_ASSIGN', "Program Name
            c_fld_name         TYPE char50       VALUE 'VBAK-AUART',              "Field Name
            c_option           TYPE char2        VALUE 'EQ',                      "Option
            c_active           TYPE c            VALUE 'X'.                       "Active


DATA :      lv_vbelv   TYPE vbfa-vbelv,               "Preceding sales and distribution document
            lv_vbeln   TYPE vbak-vbeln,               "Sales Document
            lv_type    TYPE zotc_prc_control-mvalue1, "Type
            lv_aufnr   TYPE vbap-aufnr.               "Order


*Check if Order Reason is 'S01'.
IF vbak-augru = c_order_reason_s01.
*Get type from custom table
  CLEAR lv_type.
  SELECT SINGLE  mvalue1          " Select Options: Value Low
           FROM  zotc_prc_control " OTC Process Team Control Table
           INTO  lv_type
*           WHERE vkorg      = c_sales_org  AND   " Defect 4905
*                 vtweg      = c_dist_ch    AND   " Defect 4905
           WHERE vkorg      = vbak-vkorg    AND " Defect 4905
                 vtweg      = vbak-vtweg    AND " Defect 4905
                 mprogram   = c_prog_name  AND
                 mparameter = c_fld_name   AND
                 mactive    = c_active     AND
                 soption    = c_option.

  IF sy-subrc = 0.
* Begin of Defect 4905
* First check if the reference Document No is already a ZRRC type Contract
* no or not. If so then populate VBAP_AUFNR with that
    SELECT SINGLE vbeln " Sales Document
          FROM   vbak   " Sales Document: Header Data
          INTO   lv_vbeln
          WHERE  vbeln = vbak-vgbel AND
                 vbtyp = c_doc_type_g AND
                 auart = lv_type.
    IF sy-subrc = 0.
      CLEAR lv_aufnr.
      lv_aufnr    =    lv_vbeln.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_aufnr
        IMPORTING
          output = lv_aufnr.
      vbap-aufnr = lv_aufnr.
    ELSE. " ELSE -> if sy-subrc = 0
* End of Defect 4905
* First Check
*Get Preceding Document Number from VBFA for Document type 'G'
      CLEAR lv_vbelv.
      SELECT SINGLE vbelv " Preceding sales and distribution document
      FROM   vbfa         " Sales Document Flow
      INTO   lv_vbelv
      WHERE  vbeln   = vbak-vgbel          AND
             vbtyp_v = c_doc_type_g        AND
             posnn   = space.
      IF sy-subrc = 0.
*Check if Preceding Document exists with required  type from Custom table
        CLEAR lv_vbeln.
        SELECT SINGLE vbeln " Sales Document
               FROM   vbak  " Sales Document: Header Data
               INTO   lv_vbeln
               WHERE  vbeln = lv_vbelv AND
                      auart = lv_type.
*If Preceding Document Exists with required type , set ORDER at item level
*With Preceding Document Number.
*Pleas Note that RTR needs to create preceding order first other wise order
*creation will fail. As there is no data in AUFK
        IF sy-subrc = 0.
          CLEAR lv_aufnr.
          lv_aufnr    =    lv_vbelv.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_aufnr
            IMPORTING
              output = lv_aufnr.
          vbap-aufnr = lv_aufnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " if sy-subrc = 0
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF vbak-augru = c_order_reason_S01
