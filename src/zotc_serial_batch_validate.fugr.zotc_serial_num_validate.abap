FUNCTION zotc_serial_num_validate.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_VKORG) TYPE  VKORG
*"     REFERENCE(IM_VTWEG) TYPE  VTWEG
*"     REFERENCE(IM_KUNNR) TYPE  KUNNR
*"     REFERENCE(IM_MATSER_TAB) TYPE  ZOTC_T_MATNR_SERNR
*"  EXPORTING
*"     REFERENCE(EX_SERIAL_MSG) TYPE  BAPIRETTAB
*"  EXCEPTIONS
*"      INVALID_SERIAL_NUMBER
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_SERIAL_NUM_VALIDATE(Function Module)               *
*Title      : Serial Number Validation                                *
*Developer  : Harshit Badlani                                         *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095( CR:D2_8)                                 *
*---------------------------------------------------------------------*
*Description: FM to determine whether SerialNumber is valid or Invalid*
*for a material,customer.Required Message is returned from FM         *
*CR D2_8 : This CR invloves One time customer Freight calculation,    *
*Serial and Batch validation.                                         *
*CR D2_93:In order to support EVO application to alert a web user     *
*for any error message returned by SAP at a line item level, the      *
*response XML is enhanced so that EVO can parse out messages per item *
*and alert user to take appropriate action                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*28-JUN-2014  HBADLAN       E2DK900468      INITIAL DEVELOPMENT       *
*26-SEP-2014  JMAZUMD       E2DK905232      D2_CR_137                 *
*01-OCT-2014  HBADLAN       E2DK900468      CR_D2_93                  *
*18-Nov-2014  JAHAN         E2DK904476      Defect # 1763 Serial no.  *
*                                           validation failing        *
*09-JAN-2014  SGUPTA4       E2DK900476      Defect#2892,Custom message*
*                                           are made warning mesaage  *
*                                           and display ZReferenceID  *
*                                           in messgae ZOTC_MSG_165.
*---------------------------------------------------------------------*

*Local data declarations.
  TYPES : BEGIN OF lty_mvke,
          matnr TYPE matnr,     " Material Number
          vkorg TYPE vkorg,     " Sales Organization
          vtweg TYPE vtweg,     " Distribution Channel
          dwerk TYPE dwerk_ext, " Delivering Plant (Own or External)
          END OF lty_mvke,

          BEGIN OF lty_join,
          equnr  TYPE equnr,    "Equipment Number
          matnr  TYPE matnr,    "Material Number
          sernr  TYPE gernr,    "Serial Number
          b_werk TYPE werks_d,  "Plant
          kunnr  TYPE kunnr,    "Customer no.
          END OF lty_join,

          BEGIN OF lty_sernr,
          sernr TYPE gernr,     "Serial Number
          matnr TYPE matnr,     "Material Number
          END OF lty_sernr.

  DATA : li_mvke        TYPE STANDARD TABLE OF lty_mvke,  "Table of local MVKE struc.
         li_matser_temp TYPE zotc_t_matnr_sernr,          "Material serail comb. temporary table
         li_join        TYPE STANDARD TABLE OF lty_join,  "EQUI and EQBS joinTable
         lv_sold_to     TYPE kunag,                       " Sold-to party
         lwa_bapiret    TYPE bapiret2,                    " Return Parameter
         li_sernr       TYPE STANDARD TABLE OF lty_sernr. "EQUI and EQBS joinTable

  FIELD-SYMBOLS : <lfs_matser> TYPE zotc_matnr_sernr_s, " Material Serial Number Combination structure
                  <lfs_join>   TYPE lty_join,
                  <lfs_sernr>  TYPE lty_sernr.

  CONSTANTS:lc_sobkz       TYPE sobkz      VALUE 'W',        " Special Stock Indicator
            lc_msg_error   TYPE bapi_mtype VALUE 'E',        " Message type: S Success, E Error, W Warning, I Info, A Abort
            lc_msg_success TYPE bapi_mtype VALUE 'S',        " Message type: S Success, E Error, W Warning, I Info, A Abort
            lc_msg_149     TYPE symsgno    VALUE '149',      " Message Number
            lc_msg_153     TYPE symsgno    VALUE '153',      " Message Number
            lc_msg_165     TYPE symsgno    VALUE '165',      " Message Number
            lc_msg_id      TYPE symsgid    VALUE 'ZOTC_MSG', " Object ID of Business Event Offered
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
            lc_msg_warn    TYPE bapi_mtype VALUE 'W'. " Message type: S Success, E Error, W Warning, I Info, A Abort
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4

  REFRESH ex_serial_msg.

*Start of changes for D2_CR_9 by Jahan
*Material and Serial number validation
  li_matser_temp[] = im_matser_tab[].
  SORT li_matser_temp BY matnr sernr.
  DELETE ADJACENT DUPLICATES FROM li_matser_temp COMPARING matnr sernr.

  IF li_matser_temp  IS NOT INITIAL.
    SELECT sernr                        " Sales Organization
           matnr                        " Material Number
    FROM   objk                         " Sales Data for Material
    INTO TABLE li_sernr
    FOR ALL ENTRIES IN li_matser_temp
    WHERE sernr = li_matser_temp-sernr AND
          matnr = li_matser_temp-matnr. "By Jahan Defect # 1763
    IF sy-subrc EQ 0.
      SORT li_sernr BY matnr sernr.
*Validating  serial numbers against those in input .
      LOOP AT  im_matser_tab ASSIGNING <lfs_matser>.
        READ TABLE  li_sernr ASSIGNING <lfs_sernr> WITH KEY matnr = <lfs_matser>-matnr
                                                            sernr = <lfs_matser>-sernr
                                                 BINARY SEARCH.
        IF sy-subrc <> 0.
*Return a custom warning message using message class ZOTC(149)
*No Material & and Serial Number & . And this should be returned in response in tag
          CLEAR lwa_bapiret.
* ---> Begin of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
*       lwa_bapiret-type       = lc_msg_error. "E
          lwa_bapiret-type       = lc_msg_warn. "W
* <--- End   of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
          lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
          lwa_bapiret-number     = lc_msg_165. "165
          lwa_bapiret-message_v1 = <lfs_matser>-sernr. "Message Variable
          lwa_bapiret-message_v2 = <lfs_matser>-matnr. "Message Variable
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
          lwa_bapiret-parameter  = <lfs_matser>-item_id. " Item ID
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4

          MESSAGE s165(zotc_msg)  WITH lwa_bapiret-message_v1 "Invalid Serial Number & for Material &.
                                       lwa_bapiret-message_v2
                                 INTO lwa_bapiret-message.
          APPEND lwa_bapiret TO ex_serial_msg.
          RAISE invalid_serial_number. "Def# 2892-MBAGDA
        ENDIF. " IF sy-subrc <> 0
      ENDLOOP. " LOOP AT im_matser_tab ASSIGNING <lfs_matser>
*&--Start of Defect # 1763 by Jahan
    ELSE. " ELSE -> IF sy-subrc <> 0
*Return a custom warning message using message class ZOTC(149)
*No Material & and Serial Number & . And this should be returned in response in tag
      LOOP AT  im_matser_tab ASSIGNING <lfs_matser>.

        CLEAR lwa_bapiret.
* ---> Begin of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
*        lwa_bapiret-type       = lc_msg_error. "E
        lwa_bapiret-type       = lc_msg_warn. "W
* <--- End   of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
        lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
        lwa_bapiret-number     = lc_msg_165. "165
        lwa_bapiret-message_v1 = <lfs_matser>-sernr. "Message Variable
        lwa_bapiret-message_v2 = <lfs_matser>-matnr. "Message Variable
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
        lwa_bapiret-parameter = <lfs_matser>-item_id.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4

        MESSAGE s165(zotc_msg)  WITH lwa_bapiret-message_v1 "Invalid Serial Number & for Material &.
                                     lwa_bapiret-message_v2
                               INTO lwa_bapiret-message.
        APPEND lwa_bapiret TO ex_serial_msg.
        RAISE invalid_serial_number. "Def# 2892-MBAGDA
      ENDLOOP. " LOOP AT im_matser_tab ASSIGNING <lfs_matser>
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_matser_temp IS NOT INITIAL
*&--End of Defect # 1763 by Jahan
*End of changes for D2_CR_9 by Jahan

*Applying conversion exit on sold to customer
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = im_kunnr
    IMPORTING
      output = lv_sold_to.

*Fetching data from MVKE via unique Material Numbers.
  li_matser_temp[] = im_matser_tab[].
  SORT li_matser_temp BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_matser_temp COMPARING matnr.

  IF li_matser_temp  IS NOT INITIAL.
    SELECT matnr " Material Number
           vkorg " Sales Organization
           vtweg " Distribution Channel
           dwerk " Delivering Plant (Own or External)
    FROM   mvke  " Sales Data for Material
    INTO TABLE li_mvke
    FOR ALL ENTRIES IN li_matser_temp
    WHERE matnr = li_matser_temp-matnr AND
          vkorg = im_vkorg             AND
          vtweg = im_vtweg.

*check sy-subrc after select
    IF sy-subrc EQ 0.
*Sorting and deleting duplicate material plant combination entries
      SORT li_mvke BY matnr dwerk.
      DELETE ADJACENT DUPLICATES FROM li_mvke COMPARING matnr dwerk.
*Initial check before FOR ALL ENTRIES
      IF li_mvke IS NOT INITIAL.
        SELECT a~equnr             "Equipment Number
               a~matnr             "Material Number
               a~sernr             "Serial Number
               b~b_werk            "Plant
               b~kunnr             "Sold to party
       INTO TABLE li_join
       FROM equi AS a
       INNER JOIN eqbs AS b
       ON a~equnr = b~equnr
       FOR ALL ENTRIES IN li_mvke
       WHERE a~matnr   EQ  li_mvke-matnr
       AND   b~b_werk  EQ li_mvke-dwerk
       AND   b~sobkz   EQ lc_sobkz " Stock Indicator = W
       AND   b~kunnr   EQ lv_sold_to.
        IF sy-subrc EQ 0.
          SORT li_join BY matnr sernr.
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF li_mvke IS NOT INITIAL
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_matser_temp IS NOT INITIAL

*Validating  serial numbers against those in input .
  LOOP AT  im_matser_tab ASSIGNING <lfs_matser>.
    READ TABLE  li_join ASSIGNING <lfs_join> WITH KEY matnr = <lfs_matser>-matnr
                                                      sernr =  <lfs_matser>-sernr
                                             BINARY SEARCH.
    IF sy-subrc EQ 0.
*Success message of validation
      CLEAR lwa_bapiret.
      lwa_bapiret-type       = lc_msg_success. "S
      lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
      lwa_bapiret-number     = lc_msg_153. "153
      lwa_bapiret-message_v1 = <lfs_matser>-sernr. "Message Variable
      lwa_bapiret-message_v2 = <lfs_matser>-matnr. "Message Variable
      lwa_bapiret-message_v3 = lv_sold_to.

      MESSAGE s153(zotc_msg) WITH lwa_bapiret-message_v1 " Valid Serial No & for Mat &, Cust &.
                                  lwa_bapiret-message_v2
                                  lwa_bapiret-message_v3
                                  INTO lwa_bapiret-message.
      APPEND lwa_bapiret TO ex_serial_msg.
    ELSE. " ELSE -> IF sy-subrc EQ 0
*Return a custom warning message using message class ZOTC(149)
*No Material & and Serial Number & Customer. And this should be returned in response in tag
      CLEAR lwa_bapiret.
* ---> Begin of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
*      lwa_bapiret-type       = lc_msg_error. "E
      lwa_bapiret-type       = lc_msg_warn. "W
* <--- End   of Change for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
      lwa_bapiret-number     = lc_msg_149. "149
      lwa_bapiret-message_v1 = <lfs_matser>-sernr. "Message Variable
      lwa_bapiret-message_v2 = <lfs_matser>-matnr. "Message Variable
      lwa_bapiret-message_v3 = lv_sold_to.
* ---> Begin of Change for CR D2_93 by HBADLAN
      lwa_bapiret-parameter = <lfs_matser>-item_id.
* <--- End of Change for CR D2_93 by HBADLAN

      MESSAGE s149(zotc_msg)  WITH lwa_bapiret-message_v1 " Invalid Serial No & for Mat &, Cust &.
                                   lwa_bapiret-message_v2
                                   lwa_bapiret-message_v3
                             INTO lwa_bapiret-message.
      APPEND lwa_bapiret TO ex_serial_msg.
      RAISE invalid_serial_number. "Def# 2892-MBAGDA
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT im_matser_tab ASSIGNING <lfs_matser>

  FREE : li_mvke,
         li_matser_temp,
         li_join.

ENDFUNCTION.
