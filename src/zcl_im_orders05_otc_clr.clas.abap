class ZCL_IM_ORDERS05_OTC_CLR definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_ORDERS05_OTC_CLR
*"* do not include other source files here!!!

  interfaces IF_EX_IDOC_DATA_MAPPER .
protected section.
*"* protected components of class ZCL_IM_ORDERS05_OTC_CLR
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_ORDERS05_OTC_CLR
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_ORDERS05_OTC_CLR IMPLEMENTATION.


METHOD if_ex_idoc_data_mapper~process.
************************************************************************
* PROGRAM    :  OTC_IDD_0009_SAP_Inbound sales order EDI 850           *
* TITLE      :  SAP_Inbound sales order EDI 850                        *
* DEVELOPER  :  SHAMMI PURI                                            *
* OBJECT TYPE:  BADI METHOD                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0009                                             *
*----------------------------------------------------------------------*
* DESCRIPTION:
* FOLLOWING FUNCTIONALITIES ARE ACHIEVED BY IMPLEMETING BELOW BADI IMP:
* For Inbound Message type ORDERS05. Get Internal Number for Partner and
* Update in E1EDKA1 segment
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 06-Jun-2012   SPURI     E1DK903577    Initial Development
* 31-Oct-2012   SPURI     E1DK907538    Defect: 1152 if no entry found in
*                                       table KNVP for partner function WE
*                                       or corresponding AG then go to table
*                                       VBAK with the document number from
*                                       segment E1EDK02 Qualifier 043 and
*                                       get the internal customer number. Update
*                                       segment E1EDKA1 with partner funnction
*                                       from table VBAK
*&---------------------------------------------------------------------*
* 17-mar-2015   Jrich                  *defect#4905 check for new logic for d2
*                                       check segment E1EDK02 qual = z02
*                                       document = 06 then E1EDK02 qual = z02
*                                       check qual = z01 document = sales order
*                                       get sold to party based on this else check
*                                       contract qual = '043'
*                                       else use knvp to get sold to
*
*&---------------------------------------------------------------------*
* 09-APR-2015   AKS   E2DK900747       *Defect#4905 Remove the logic for checking
*                                      segment E1EDK02 qual = z02 document = 06
*                                      Also removing check of VBTYP = C
*&---------------------------------------------------------------------*
  CONSTANTS      :  c_orders05(20)                TYPE c VALUE 'ORDERS05',       " IDOC TYPE
                    c_inbound(1)                  TYPE c VALUE '2',              " IDoc Direction
                    c_e1edka1(20)                 TYPE c VALUE 'E1EDKA1',        " SEGMENT NAME
                    c_e1edk02(20)                 TYPE c VALUE 'E1EDK02',        " SEGMENT NAME
                    c_yes(1)                      TYPE c VALUE 'X',              " SELECTED
                    c_zotc_msg(20)                TYPE c VALUE 'ZOTC_MSG',       " MESSAGE CLASS
                    c_022(3)                      TYPE c VALUE '022',            " 022(3) of type Character
                    c_043(3)                      TYPE c VALUE '043',            " 043(3) of type Character
                    c_partn                       TYPE char5 VALUE 'PARTN',      " Partn of type CHAR5
                    c_06                          TYPE char2 VALUE '06',         " 06 of type CHAR2
                    c_we                          TYPE char2 VALUE 'WE',         " We of type CHAR2
                    c_ag                          TYPE char2 VALUE 'AG',         " Ag of type CHAR2
                    c_z02                         TYPE char3 VALUE 'Z02',        " Z02 of type CHAR3
                    c_z01                          TYPE char3 VALUE 'Z01',       " Z01 of type CHAR3
                    c_clf                         TYPE edidc-stdmes VALUE 'CLF', " EDI message type
                    c_doc_cat(1)                  TYPE c VALUE 'G',              " Doc_cat(1) of type Character
                    c_doc_catc                     TYPE char1 VALUE 'C'.         " Doc_cat(1) of type Character


  FIELD-SYMBOLS  :  <lfs_data>                  TYPE edid4. " IDOC DATA
* Begin of Defect 4905
  TYPES : BEGIN OF lty_cust,
            kunnr TYPE kunnr, " Customer Number
          END   OF lty_cust.
  DATA : li_cust   TYPE STANDARD TABLE OF lty_cust,
         li_soldto TYPE STANDARD TABLE OF lty_cust,
         wa_soldto TYPE lty_cust.
* End of Defect 4905
  DATA:      lv_parvw             TYPE parvw,       " Partner Function
             lv_expnr             TYPE edi_expnr,   " External partner number (in customer system)
             lv_kunnr             TYPE kunnr,       " Customer Number
             lv_inpnr             TYPE edi_inpnr,   " Internal partner number (in SAP System)
             lwa_mapping_rec      TYPE idoc_chang,  " Transfer Structure for Values to be Changed
             lv_belnr_char        TYPE char35,      " Belnr_char of type CHAR35
             lv_vbeln             TYPE vbak-vbeln , " Sales Document
             lv_vbelv             TYPE vbfa-vbelv , " Preceding sales and distribution document
             lv_type              TYPE zotc_prc_control-mvalue1,
             lv_flag              TYPE char1,       " Flag of type CHAR1
             lv_sold_to_customer TYPE knvp-kunnr.   " Customer Number

  CASE control-idoctp.
    WHEN c_orders05.
      IF   control-direct = c_inbound AND
           control-stdmes = c_clf  .
*start  of defect 4905
*get sold to
        CLEAR lv_flag.
*check to see if contract exist
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam     = c_e1edk02
                                                      sdata+0(3) = c_043.
        IF sy-subrc = 0.

          lv_vbeln = <lfs_data>-sdata+3(35).
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = lv_vbeln
            IMPORTING
              output = lv_vbeln.

          CLEAR lv_sold_to_customer.
          SELECT SINGLE kunnr             " Sold-to party
                 FROM   vbak              " Sales Document: Header Data
                 INTO   lv_sold_to_customer
                 WHERE  vbeln = lv_vbeln. " AND
*                        vbtyp = c_doc_cat.   " Defect # 4905
          IF sy-subrc = 0.
            lv_flag = abap_true.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
*check if reference order exist
        IF lv_flag = abap_false.
*         Begin of change for Defect 4905 09-APR-2015
*          READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam     = c_e1edk02
*                                                       sdata+0(3) = c_z02.
*          IF sy-subrc = 0.
*            IF <lfs_data>-sdata+3(35) = c_06.
*         End of Change for Defect 4905 09-APR-2015
          READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam     = c_e1edk02
                                                       sdata+0(3) = c_z01.
          IF sy-subrc = 0.
            lv_vbeln = <lfs_data>-sdata+3(35).
            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
              EXPORTING
                input  = lv_vbeln
              IMPORTING
                output = lv_vbeln.

            CLEAR lv_sold_to_customer.
            SELECT SINGLE kunnr     " Sold-to party
             FROM   vbak            " Sales Document: Header Data
           INTO   lv_sold_to_customer
           WHERE  vbeln = lv_vbeln. " AND
*                vbtyp = c_doc_catc.     " Defect# 4905 09-APR-2015

            IF sy-subrc = 0.
              lv_flag = abap_true.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
*            ENDIF. " IF <lfs_data>-sdata+3(35) = c_06    " Defect 4905 09-APR-2015
*          ENDIF. " IF sy-subrc = 0                       " Defect 4905 09-APR-2015
          IF lv_flag = abap_false. " ELSE -> IF sy-subrc = 0
*GET SOLD TO CUSTOMER
            READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam     = c_e1edka1
                                                          sdata+0(2) = c_we .
            IF sy-subrc = 0.
              CLEAR : lv_parvw,
                      lv_inpnr,
                      lv_kunnr.

              lv_parvw              = <lfs_data>-sdata+0(3).
              lv_inpnr              = <lfs_data>-sdata+3(17).
              lv_kunnr              = lv_inpnr.

              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
                EXPORTING
                  input  = lv_kunnr
                IMPORTING
                  output = lv_kunnr.

              CLEAR lv_sold_to_customer.
              SELECT     kunnr       " Customer Number
                         FROM   knvp " Customer Master Partner Functions
*                         INTO   lv_sold_to_customer UP TO 1 ROWS   " Defect # 4905
                         INTO TABLE li_cust " Defect # 4905
                         WHERE  parvw = c_we AND
                                kunn2 = lv_kunnr .

              IF sy-subrc = 0.
                SELECT kunnr           " Customer Number
                           FROM   knvp " Customer Master Partner Functions
*                           INTO   lv_sold_to_customer UP TO 1 ROWS " Defect # 4905
                           INTO TABLE li_soldto
                           FOR ALL ENTRIES IN li_cust " Defect # 4905
*                           WHERE  kunn2 = lv_sold_to_customer AND " Defect # 4905
                            WHERE  kunn2 = li_cust-kunnr AND " Defect # 4905
                                  parvw = c_ag.

                IF sy-subrc = 0.
*                  Begin of Defect 4905
                  READ TABLE li_soldto INTO wa_soldto INDEX 1.
                  IF sy-subrc = 0.
                    lv_sold_to_customer = wa_soldto-kunnr.
                  ENDIF. " if sy-subrc = 0
*                  End  of Defect 4905
                ELSE. " ELSE -> if sy-subrc = 0
                  lv_sold_to_customer = lv_kunnr. " Defect # 4905
                ENDIF. " IF sy-subrc = 0
              ELSE. " ELSE -> IF sy-subrc = 0
                lv_sold_to_customer = lv_kunnr. " Defect # 4905
              ENDIF. " IF sy-subrc = 0
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lv_flag = abap_false
        ENDIF. " IF control-direct = c_inbound AND

*MODIFY AG ( SOLD TO CUSTOMER )
        LOOP AT data ASSIGNING <lfs_data> WHERE  segnam = c_e1edka1 AND
                                                 sdata+0(2) = c_ag.
          IF <lfs_data>-sdata+3(17) IS INITIAL.
            CLEAR : lwa_mapping_rec.
            lwa_mapping_rec-segnum      = <lfs_data>-segnum.
            lwa_mapping_rec-feldname    = c_partn.
            lwa_mapping_rec-save_type   = c_yes.
            lwa_mapping_rec-value       = lv_sold_to_customer.
            CONDENSE lwa_mapping_rec-value NO-GAPS.
            APPEND lwa_mapping_rec TO mapping_tab.
            have_to_change  = c_yes.
            protocol-stamid = c_zotc_msg.
            protocol-stamno = c_022.
            protocol-repid  = sy-cprog .
          ENDIF. " IF <lfs_data>-sdata+3(17) IS INITIAL
        ENDLOOP. " LOOP AT data ASSIGNING <lfs_data> WHERE segnam = c_e1edka1 AND
*end of defect#4905
      ENDIF. " IF control-direct = c_inbound AND
    WHEN OTHERS.
  ENDCASE.
ENDMETHOD.
ENDCLASS.
