************************************************************************
* PROGRAM    :  ZOTCR0347O_STANDING_ORDERS                             *
* TITLE      :  D3_OTC_EDD_0347_Upload Standing Orders                 *
* DEVELOPER  :  Debasish Maiti /  Bijayeeta Banerjee                   *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0347                                         *
*----------------------------------------------------------------------*
* DESCRIPTION: Upload Standing Orders                                  *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 15.06.2016  BBANERJ   E1DK919242  Initial Development                *
*&---------------------------------------------------------------------*
* 27.07.2016  U034088   E1DK919242  Defect# 2741: Change output Layout *
*&---------------------------------------------------------------------*
* 30.08.2016  U029382/  E1DK919242  CR# 3502:  Add distribution channel*
*             U034088               from CSV sheet and Wrong sorting of*
*                                   of line items                      *
*&---------------------------------------------------------------------*
* 19.09.2016  U034088  E1DK919242  CR# 3502_PART2, The file separator  *
*                                  May be Comma or Colon. Need to      *
*                                  both.                               *
*&---------------------------------------------------------------------*
* 03.11.2016 APAUL    E1DK919242  CR#227, This change is dependendant  *
*                                 on the class zotc_cl_inb_so_edi_850  *
*                                 and corresponding EMI.  Implement the*
*                                 logic for split of LRD and Non-LRD as*
*                                 developed in D3_OTC_EDD-0362 to      *
*                                 populate Sales Organisation data.    *
*                                 Field Sales Organsiation  is not     *
*                                 needed  from  input file.            *
*&---------------------------------------------------------------------*
* 03.01.2017 U033867  E1DK926115  CR# 378:Add sales office in selection
*                                 screen
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0347O_STANDING_ORDERS_TOP
*&---------------------------------------------------------------------*


  TYPES:  BEGIN OF ty_leg_tab_c,
            auart       TYPE  auart,  " Sales Document Type
* <--- Begin of  Delete for CR#D3_227 by  APAUL
*            vkorg       TYPE  vkorg , " Sales Organization
* <--- End of  Delete for CR#D3_227 by  APAUL
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
            vtweg       TYPE vtweg, " Distribution Channel
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
            parvw_sp    TYPE  parvw ,    " Partner Function
            kunnr_sp    TYPE  kunnr ,    " Customer Number
            parvw_sh    TYPE  parvw ,    " Partner Function
            kunnr_sh    TYPE  kunnr ,    " Customer Number
            bstnk       TYPE bstnk,      " Customer purchase order number
            bstdk_c     TYPE char10,     " Customer purchase order date from File
            bsark       TYPE bsark,      " Customer purchase order type
            parvw_cp    TYPE  parvw ,    " Partner Function
            kunnr_cp    TYPE  kunnr ,    " Customer Number
            name1       TYPE name1,      " Name
            email       TYPE ad_smtpadr, " E-Mail Address
            tele1       TYPE ad_tlnmbr1, " First telephone no.: dialling code+number
            textid      TYPE tdid,       " Textid of type CHAR04
            text        TYPE tdline,     " Text of type CHAR60
            textid_2    TYPE tdid,       " Textid of type CHAR04  Second text ID
            text_2      TYPE tdline,     " Text of type CHAR60    Second text
            lifsk       TYPE lifsk,      " Delivery block (document header)
            matnr       TYPE matnr,      " Material Number
            kwmeng      TYPE char18,     " Quantity
            charg       TYPE charg_d,    " Batch Number
            etdat_c     TYPE char10,     " Schedule line date  form file
            bstdk       TYPE bstdk,      " Customer purchase order date
*            etdat       TYPE etdat,      " Schedule line date
            etdat       TYPE edatu,    " Schedule line date " Changed on 10/14/2016 for sorting by date
            lineno      TYPE index,    " Index of the record
            msgtyp      TYPE char1,    " Msgtyp of type CHAR1
            error       TYPE char1024, " Error of type CHAR1024
*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
            posnr       TYPE posnr_va, "Sales Document Item
*<--- End of Insert for Defect# 2741 by U034088 on 27.07.2016
* <--- Begin of Insert for CR#D3_227 by  APAUL
            vkorg       TYPE  vkorg , " Sales Organization
* <--- End of  Insert for CR#D3_227 by  APAUL
           END OF ty_leg_tab_c,
           ty_t_leg_tab_c TYPE STANDARD TABLE OF ty_leg_tab_c,

           BEGIN OF ty_land,
             kunnr TYPE kunnr,   " Customer Number
             land1 TYPE land1,   " Country Key
           END OF ty_land,

           BEGIN OF ty_report,
             msgtyp TYPE char1,  "Message Type E / S
             msgtxt TYPE string, "Message Text
             key    TYPE string, "Key of message
*---> Begin of Insert for Defect# 2741 by U034088 on 27.07.2016
** Fields are added for displaying the final table  as per
** business requirement
            posnr TYPE posnr_va,      " Sales Document Item
            auart       TYPE  auart,  " Sales Document Type
            vkorg       TYPE  vkorg , " Sales Organization
*---> Begin of Insert for CR# 3502 by U034088 on 30.08.2016
            vtweg       TYPE vtweg, " Distribution Channel
*<--- End of Insert for CR# 3502 by U034088 on 30.08.2016
            parvw_sp    TYPE  parvw , " Partner Function
            kunnr_sp    TYPE  kunnr , " Customer Number
            parvw_sh    TYPE  parvw , " Partner Function
            kunnr_sh    TYPE  kunnr , " Customer Number
            bstnk       TYPE  bstnk,  " Customer purchase order number
*<---- End of Insert for Defect# 2741 by U034088 on 27.07.2016
           END OF ty_report,

           BEGIN OF ty_kunnr_leg,
             vkorg TYPE  vkorg , " Sales Organization
             kunnr TYPE  kunnr , " Customer Number
           END OF ty_kunnr_leg,
           ty_t_report TYPE STANDARD TABLE OF ty_report.


  DATA: i_leg_tab_c  TYPE ty_t_leg_tab_c,                "#EC NEEDED
        i_leg_tab_msg  TYPE ty_t_leg_tab_c,              "#EC NEEDED
        i_report     TYPE ty_t_report,                   "#EC NEEDED
        i_kunnr_leg TYPE STANDARD TABLE OF ty_kunnr_leg, "#EC NEEDED
        gv_file     TYPE localfile,                      "Local file for upload/download
        gv_mode     TYPE char10,                         "#EC NEEDED  " Mode of type CHAR10
        gv_vtweg TYPE vtweg,                             " Distribution Channel
        gv_codepage TYPE cpcodepage,                     "#EC NEEDED " SAP Character Set ID
        gv_scount   TYPE int4,                           "#EC NEEDED  " Succes Count
        gv_ecount   TYPE int4,                           "#EC NEEDED  " Error Count
        gv_header     TYPE string,                       " Header String
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
        gv_sep TYPE char1. " Separator for deciding comma or Semicolon
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016

  CONSTANTS: c_extn       TYPE char3   VALUE 'CSV', " Constant declaration of type string with value 'TXT'
             c_sep TYPE char1 VALUE ',' ,           " Sep of type file
*---> Begin of Insert for CR# 3502 by U034088 on 19.09.2016
             c_colon TYPE char1 VALUE ';' , " Sep of type file
*<--- End of Insert for CR# 3502 by U034088 on 19.09.2016
             c_selected   TYPE char1   VALUE 'X'. " Constant declaration of type char1 with value 'X'
