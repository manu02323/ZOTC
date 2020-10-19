class ZCL_IM_IM_ORDERS05_CRE_CLR definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_IM_ORDERS05_CRE_CLR
*"* do not include other source files here!!!

  interfaces IF_EX_IDOC_DATA_INSERT .
protected section.
*"* protected components of class ZCL_IM_IM_ORDERS05_CRE_CLR
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_IM_ORDERS05_CRE_CLR
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_IM_ORDERS05_CRE_CLR IMPLEMENTATION.


METHOD if_ex_idoc_data_insert~fill.
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
* For Inbound Message type ORDERS05. Get Sales organization ,
* Distribution Channel And division. If partner function is AG use the
* External LIFNR to get internal number and retrieve date. If partner
* is WE get AG first then retrieve data.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                   *
* ===========  ========   =========  ==================================*
* 06-June-2012 SPURI      E1DK903577     Initial Development           *
* 29-May-2013  BMAJI      E1DK910520     CR# 427: If the IDOC source   *
*                                        is Clarify then default the   *
*                                        Sales Area as 1000/10/00 by   *
*                                        TVARVC.                       *
* 03-Feb-2014  SNIGAM     E1DK912732     CR#1172: Populate Default
*                                        sales area value EDSDC 1000/10/00
*                                        when there are multiple sales
*                                        area for partner in KNVV
*&---------------------------------------------------------------------*

  TYPES :  BEGIN OF ty_knvv,
               vkorg TYPE knvv-vkorg,
               vtweg TYPE knvv-vtweg,
               spart TYPE knvv-spart,
           END OF ty_knvv.

  DATA: lv_counter(3)   TYPE c,
        lwa_data        TYPE edid4,
        lwa_data1       TYPE edid4,
        lwa_insert_rec  TYPE idoc_insert,
        lv_parvw        TYPE parvw,
        lv_expnr        TYPE edi_expnr,
        lv_kunnr        TYPE kunnr,
        lv_inpnr        TYPE edi_inpnr,
        i_knvv          TYPE STANDARD TABLE OF ty_knvv INITIAL SIZE 0,
        lwa_knvv        TYPE ty_knvv,
        lv_lines        TYPE i,
        lv_vkorg        TYPE knvv-vkorg,
        lv_vtweg        TYPE knvv-vtweg,
        lv_spart        TYPE knvv-spart,
        lv_sold_to_customer TYPE knvp-kunnr,
        lv_added            TYPE c,
        lv_add              TYPE c.



  CONSTANTS: c_inbound(1)                  TYPE c VALUE '2',         " IDoc Direction
             c_orders05(20)                TYPE c VALUE 'ORDERS05',  " IDOC TYPE
             c_e1edka1(20)                 TYPE c VALUE 'E1EDKA1',   " SEGMENT NAME
             c_ag(2)                       TYPE c VALUE 'AG',
             c_we(2)                       TYPE c VALUE 'WE',
             c_006(3)                      TYPE c VALUE '006',
             c_007(3)                      TYPE c VALUE '007',
             c_008(3)                      TYPE c VALUE '008',
             c_x(1)                        TYPE c VALUE 'X',
             c_e1edk14(20)                 TYPE c VALUE 'E1EDK14',   " SEGMENT NAME
             c_e1edk01(20)                 TYPE c VALUE 'E1EDK01',   " SEGMENT NAME
             c_zotc_msg(20)                TYPE c VALUE 'ZOTC_MSG',  " MESSAGE CLASS
             c_021(3)                      TYPE c VALUE '021',       " MESSAGE NUMBER
             c_clf                         TYPE edidc-stdmes VALUE 'CLF'.


  FIELD-SYMBOLS  :   <lfs_data> TYPE edid4.

  CASE control-idoctp.
    WHEN c_orders05.
      IF   control-direct  = c_inbound AND
           control-stdmes  = c_clf  .
        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edka1  sdata+0(2) = c_ag.
        IF sy-subrc = 0.
          CLEAR : lv_parvw,
                  lv_inpnr.
          lv_parvw              = <lfs_data>-sdata+0(3).
          lv_inpnr              = <lfs_data>-sdata+3(17).
          REFRESH i_knvv[].
          SELECT vkorg
                 vtweg
                 spart
          FROM knvv
          INTO TABLE i_knvv
          WHERE kunnr  =  lv_inpnr AND
                loevm  = space.
          IF sy-subrc = 0.
            CLEAR lv_lines.
            DESCRIBE TABLE i_knvv LINES lv_lines.
            IF lv_lines = 1.
              CLEAR lwa_knvv.
              READ TABLE i_knvv INTO lwa_knvv INDEX 1.
              IF sy-subrc = 0.
                lv_vkorg = lwa_knvv-vkorg.
                lv_vtweg = lwa_knvv-vtweg.
                lv_spart = lwa_knvv-spart.
              ENDIF.
* BOC : CR1172: SNIGAM : E1DK912732 : 03-Feb-2014
* Earlier CR 427 was implemented stating that when any inbound idoc is received from Clarify
* and system does not find one entry in KNVV for the sales area then it should be defaulted
* as 1000/10/00 in the idoc. Similar to CR-427, System should also take care of the master
* data issue, when any customer is extended to multiple sales area by mistake. As per the
* understanding as design one external customer cannot be extended to multiple sales areas.
            ELSE.
*&&-- Get data from EDSDC for KUNNR = space
              SELECT SINGLE vkorg  "Sales Organization
                            vtweg  "Distribution Channel
                            spart  "Division
                FROM edsdc  "Assignment of EDI Partner
                INTO (lv_vkorg, lv_vtweg, lv_spart)
                WHERE kunnr = space  "Customer Number as space
                  AND lifnr = space. "Vendor num as space
* EOC : CR1172: SNIGAM : E1DK912732 : 03-Feb-2014
            ENDIF.
*&&-- BOC of CR#427
*&&-- If there is no data in KNVV for partner AG
          ELSE.
*&&-- Get data from EDSDC for KUNNR = space
            SELECT SINGLE vkorg  "Sales Organization
                          vtweg  "Distribution Channel
                          spart  "Division
              FROM edsdc  "Assignment of EDI Partner
              INTO (lv_vkorg, lv_vtweg, lv_spart)
              WHERE kunnr = space  "Customer Number
                AND lifnr = space. "Vendor num sent with EDI
            IF sy-subrc IS NOT INITIAL.
              CLEAR: lv_vkorg, lv_vtweg, lv_spart.
            ENDIF.
*&&-- EOC of CR#427
          ENDIF.
        ENDIF.


        READ TABLE data ASSIGNING <lfs_data> WITH KEY segnam = c_e1edk14 sdata+0(3) = c_008.
        IF sy-subrc <> 0.
          IF lv_vkorg IS NOT INITIAL AND
             lv_vtweg IS NOT INITIAL AND
             lv_spart IS NOT INITIAL.
            CLEAR lv_added.
            LOOP AT data INTO lwa_data WHERE segnam =  c_e1edk01.
              lwa_insert_rec-counter   =    lv_counter.
              lwa_insert_rec-segnam    =    c_e1edk14.
              lwa_insert_rec-segnum    =    lwa_data-segnum.
              lwa_data1-sdata+0(3)     =    c_008.
              lwa_data1-sdata+3(35)    =    lv_vkorg.
              lwa_insert_rec-sdata     =    lwa_data1-sdata.
              APPEND  lwa_insert_rec TO new_entries.
              CLEAR : lwa_data1,lwa_insert_rec.

              lv_counter = lv_counter + 1.
              lwa_insert_rec-counter   =    lv_counter.
              lwa_insert_rec-segnam    =    c_e1edk14.
              lwa_insert_rec-segnum    =    lwa_data-segnum.
              lwa_data1-sdata+0(3)     =    c_007.
              lwa_data1-sdata+3(35)    =    lv_vtweg.
              lwa_insert_rec-sdata     =    lwa_data1-sdata.
              APPEND  lwa_insert_rec TO new_entries.
              CLEAR : lwa_data1,lwa_insert_rec.

              lv_counter = lv_counter + 1.
              lwa_insert_rec-counter   =    lv_counter.
              lwa_insert_rec-segnam    =    c_e1edk14.
              lwa_insert_rec-segnum    =    lwa_data-segnum.
              lwa_data1-sdata+0(3)     =    c_006.
              lwa_data1-sdata+3(35)    =    lv_spart.
              lwa_insert_rec-sdata     =    lwa_data1-sdata.
              APPEND  lwa_insert_rec TO new_entries.
              CLEAR : lwa_data1,lwa_insert_rec.
              lv_added = c_x.
            ENDLOOP.
          ENDIF.
        ENDIF.
        IF lv_added = c_x.
          have_to_change  = c_x.
          protocol-stamid = c_zotc_msg.            "Status message ID
          protocol-stamno = c_021.                 "Status message number
          protocol-stapa1 = text-001.              "Parameter 1
          protocol-stapa2 = text-002.              "Parameter 2
          protocol-stapa3 = text-003.              "Parameter 3
          IF lv_parvw = c_we.
            protocol-stapa4 = text-004.            "Parameter 4
          ENDIF.
          protocol-repid  = sy-cprog .             "Program Name
        ENDIF.
      ENDIF.
    WHEN  OTHERS.
  ENDCASE.
ENDMETHOD.
ENDCLASS.
