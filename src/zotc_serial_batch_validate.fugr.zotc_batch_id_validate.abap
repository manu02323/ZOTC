FUNCTION zotc_batch_id_validate.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_VKORG) TYPE  VKORG
*"     REFERENCE(IM_VTWEG) TYPE  VTWEG
*"     REFERENCE(IM_KUNNR) TYPE  KUNNR
*"     REFERENCE(IM_MATBATCH_QUAN) TYPE  ZOTC_T_MATBATCH_QUAN
*"  EXPORTING
*"     REFERENCE(EX_BATCH_MSG) TYPE  BAPIRETTAB
*"  EXCEPTIONS
*"      INVALID_BATCH
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_BATCH_ID_VALIDATE(Function Module)                 *
*Title      : Batch ID  Validation                                    *
*Developer  : Harshit Badlani                                         *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095( CR:D2_8)                                 *
*---------------------------------------------------------------------*
*Description: FM to return message by validating quantity of Valid    *
*Batch ID for a Material shipped  to supply centre.                   *
*CR D2_8    : This CR invloves One time customer Freight calculation, *
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
*01-OCT-2014  HBADLAN       E2DK900468      CR_D2_93                  *
*---------------------------------------------------------------------*
*19-NOV-2014  MCHATTE       E2DK900476      Defect# 1766- Changed     *
*                                        error message type to success*
*24-Nov-2014  SGUPTA4       E2DK900476    Defect# 1972- Added an error*
*                                         message if Batch Validation *
*                                         fails.                      *
*19-JAN_2014  SGUPTA4       E2DK900476   Defect#3128, All custom      *
*                                        messgages are set to warning *
*                                        and Batch number is displayed*
*                                        in the error message.        *
*---------------------------------------------------------------------*

*LOCAL DATA DECLARATIONS.

  TYPES : BEGIN OF lty_mvke,
          matnr TYPE matnr,     " Material Number
          vkorg TYPE vkorg,     " Sales Organization
          vtweg TYPE vtweg,     " Distribution Channel
          dwerk TYPE dwerk_ext, " Delivering Plant (Own or External)
          END OF lty_mvke,

          BEGIN OF lty_batch,
          matnr TYPE matnr,     " Material Number
          werks TYPE werks_d,   " Plant
          charg TYPE charg_d,   " Batch Number
          sobkz TYPE sobkz,     " Special Stock Indicator
          kunnr TYPE kunnr,     " Customer Number
          kulab TYPE labst,     " Valuated Unrestricted-Use Stock
          END OF lty_batch.

  DATA : li_mvke     TYPE STANDARD TABLE OF lty_mvke,
         li_batch    TYPE STANDARD TABLE OF lty_batch,
         li_temp     TYPE zotc_t_matbatch_quan,
         lwa_bapiret TYPE bapiret2. " Return Parameter

  DATA : lv_kunnr    TYPE kunnr, " Sold-to party
         lwa_kunnr   TYPE kunnr. " Customer Number
  FIELD-SYMBOLS : <lfs_matbatch_quan> TYPE zotc_matbatch_quan_s, " Structure for Material and Associated Batch
                  <lfs_batch>         TYPE lty_batch.            "Structure for Batch data

  CONSTANTS : lc_sobkz       TYPE sobkz      VALUE 'W',        " Special Stock Indicator
              lc_msg_error   TYPE bapi_mtype VALUE 'E',        " Message type: S Success, E Error, W Warning, I Info, A Abort
              lc_msg_success TYPE bapi_mtype VALUE 'S',        " Message type: S Success, E Error, W Warning, I Info, A Abort
              lc_msg_050     TYPE symsgno    VALUE '050',      " Message Number
              lc_msg_150     TYPE symsgno    VALUE '150',      " Message Number
              lc_msg_155     TYPE symsgno    VALUE '155',      " Message Number
              lc_msg_062     TYPE symsgno    VALUE '062',      " Message Number
              lc_msg_id      TYPE symsgid    VALUE 'ZOTC_MSG', " Object ID of Business Event Offered
* ---> Begin of Insert for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4
              lc_msg_warn    TYPE bapi_mtype VALUE 'W'. " Message type: S Success, E Error, W Warning, I Info, A Abort
* <--- End   of Insert for Defect#3128, D2_OTC_IDD_0095 by SGUPTA4

  REFRESH ex_batch_msg.
*Taking Material and batch data in to temp table &
*based on unique Material from it fetching data from MVKE.
  li_temp[] = im_matbatch_quan[].
  SORT li_temp BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_temp COMPARING matnr.

  IF li_temp  IS NOT INITIAL.
    SELECT matnr " Material Number
           vkorg " Sales Organization
           vtweg " Distribution Channel
           dwerk " Delivering Plant (Own or External)
    FROM   mvke  " Sales Data for Material
    INTO TABLE li_mvke
    FOR ALL ENTRIES IN li_temp
    WHERE matnr = li_temp-matnr AND
          vkorg = im_vkorg      AND
          vtweg = im_vtweg.
    IF sy-subrc EQ 0.
      SORT li_mvke BY matnr dwerk.
      DELETE ADJACENT DUPLICATES FROM li_mvke COMPARING matnr dwerk.
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_temp IS NOT INITIAL

*KUNNR VALIDATION by Jahan as part of OTC_IDD_90

*Applying conversion exit to customer
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = im_kunnr
    IMPORTING
      output = lv_kunnr.

  IF lv_kunnr IS NOT INITIAL.
    SELECT SINGLE kunnr " Customer Number
      FROM kna1         " General Data in Customer Master
      INTO lwa_kunnr
     WHERE kunnr = lv_kunnr.

    IF sy-subrc NE 0.
      CLEAR lwa_bapiret.
* ---> Begin of Change for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
*      lwa_bapiret-type       = lc_msg_error. "E
      lwa_bapiret-type       = lc_msg_warn. "
* <--- End   of Change for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
      lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
      lwa_bapiret-number     = lc_msg_050. "150
      lwa_bapiret-message_v1 = im_kunnr.
      MESSAGE e050(zotc_msg) WITH lwa_bapiret-message_v1 " Only & Qty of Batch & shipped to &.
                                  lwa_bapiret-message_v2
                                  lwa_bapiret-message_v3
                             INTO lwa_bapiret-message.
      APPEND lwa_bapiret TO ex_batch_msg.
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      RAISE invalid_batch.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
    ENDIF. " IF sy-subrc NE 0
  ENDIF. " IF lv_kunnr IS NOT INITIAL
*BATCH NUMBER CHECK.
*Once batch number itself has been validated it needs be ensured the
* material with the valid batch number has indeed been shipped to the customer consigned stock.

  IF li_mvke IS NOT INITIAL .
    SELECT matnr              " Material Number
           werks              " Plant
           charg              " Batch Number
           sobkz              " Special Stock Indicator
           kunnr              " Customer Number
           kulab              " Valuated Unrestricted-Use Stock
    FROM msku                 " Special Stocks with Customer
    INTO TABLE li_batch
    FOR ALL ENTRIES IN li_mvke
    WHERE  matnr EQ li_mvke-matnr
    AND    werks EQ li_mvke-dwerk
    AND    sobkz EQ lc_sobkz  "WW	Consignment (cust.)
    AND    kunnr EQ lv_kunnr. "Ship to party
    IF sy-subrc EQ 0.
      SORT li_batch BY matnr charg.

* ---> Begin of Insert for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
      LOOP AT   li_temp ASSIGNING <lfs_matbatch_quan>.
        READ TABLE li_batch ASSIGNING <lfs_batch> WITH KEY matnr = <lfs_matbatch_quan>-matnr
                                                           charg = <lfs_matbatch_quan>-charg
                                                           BINARY SEARCH.
        IF sy-subrc NE 0.
          CLEAR lwa_bapiret.
          lwa_bapiret-type       = lc_msg_warn. "W
          lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
          lwa_bapiret-number     = lc_msg_062. "062
          lwa_bapiret-message_v1 = <lfs_matbatch_quan>-charg.
          lwa_bapiret-message_v2 = lv_kunnr.
          lwa_bapiret-parameter = <lfs_matbatch_quan>-item_id.
          MESSAGE e062(zotc_msg) WITH lwa_bapiret-message_v1 " Batch not found for input batch and Partner &
                                      lwa_bapiret-message_v2
                                 INTO lwa_bapiret-message.
          APPEND lwa_bapiret TO ex_batch_msg.
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      RAISE invalid_batch.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
        ENDIF. " if sy-subrc ne 0
      ENDLOOP. " LOOP AT li_temp ASSIGNING <lfs_matbatch_quan>
    ELSE. " ELSE -> if sy-subrc ne 0
      LOOP AT   li_temp[] ASSIGNING <lfs_matbatch_quan>.
        CLEAR lwa_bapiret.
        lwa_bapiret-type       = lc_msg_warn. "W
        lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
        lwa_bapiret-number     = lc_msg_062. "062
        lwa_bapiret-message_v1 = <lfs_matbatch_quan>-charg.
        lwa_bapiret-message_v2 = lv_kunnr.
        lwa_bapiret-parameter = <lfs_matbatch_quan>-item_id.
        MESSAGE e062(zotc_msg) WITH lwa_bapiret-message_v1 " Batch not found for input batch and Partner &
                                    lwa_bapiret-message_v2
                               INTO lwa_bapiret-message.
        APPEND lwa_bapiret TO ex_batch_msg.
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      RAISE invalid_batch.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      ENDLOOP. " LOOP AT li_temp[] ASSIGNING <lfs_matbatch_quan>

* <--- End   of Insert for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4

* ---> Begin of Delete for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
*    ELSE. " ELSE -> IF sy-subrc EQ 0
*      CLEAR lwa_bapiret.
*      lwa_bapiret-type       = lc_msg_error. "E
*      lwa_bapiret-id         = lc_msg_id.    "ZOTC_MSG
*      lwa_bapiret-number     = lc_msg_062.   "062
*      lwa_bapiret-message_v1 = lv_kunnr.
*      MESSAGE e062(zotc_msg) WITH lwa_bapiret-message_v1 " Batch not found for input batch and Partner &
*                                  lwa_bapiret-message_v2
*                                  lwa_bapiret-message_v3
*                             INTO lwa_bapiret-message.
*      APPEND lwa_bapiret TO ex_batch_msg.
* <--- End   of Delete for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_mvke IS NOT INITIAL


*Validating data in from MSKU against input data.
  LOOP AT  im_matbatch_quan ASSIGNING <lfs_matbatch_quan>.
    READ TABLE  li_batch    ASSIGNING <lfs_batch> WITH KEY matnr = <lfs_matbatch_quan>-matnr
                                                           charg = <lfs_matbatch_quan>-charg
                                                  BINARY SEARCH.
    IF sy-subrc EQ 0.
*Message if line item quantity for the batch managed product greater than consigned inventory for that batch
      IF ( <lfs_batch>-kulab LT <lfs_matbatch_quan>-req_qty ).
        CLEAR lwa_bapiret.
* ---> Begin of Change for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
*      lwa_bapiret-type       = lc_msg_error. "E
        lwa_bapiret-type       = lc_msg_warn. "
* <--- End   of Change for Defect #3128, D2_OTC_IDD_0095 by SGUPTA4
        lwa_bapiret-id         = lc_msg_id. "ZOTC_MSG
        lwa_bapiret-number     = lc_msg_150. "150
        lwa_bapiret-message_v1 = <lfs_batch>-kulab.
        CONDENSE lwa_bapiret-message_v1.
        lwa_bapiret-message_v2 = <lfs_batch>-charg.
        lwa_bapiret-message_v3 = <lfs_batch>-kunnr.
* ---> Begin of Change for CR D2_93 by HBADLAN
        lwa_bapiret-parameter  = <lfs_matbatch_quan>-item_id.
* <--- End of Change for CR D2_93 by HBADLAN
        MESSAGE s150(zotc_msg) WITH lwa_bapiret-message_v1 " Only & Qty of Batch & shipped to &.
                                    lwa_bapiret-message_v2
                                    lwa_bapiret-message_v3
                               INTO lwa_bapiret-message.
        APPEND lwa_bapiret TO ex_batch_msg.
* ---> Begin of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
      RAISE invalid_batch.
* <--- End   of Insert for Defect#2892, D2_OTC_IDD_0095 by SGUPTA4
*A success message if batch no. is validated and input qty is lesser.
      ELSE. " ELSE -> IF ( <lfs_batch>-kulab LT <lfs_matbatch_quan>-req_qty )
        CLEAR lwa_bapiret.
*Begin of Defect# 1766
*        lwa_bapiret-type       = lc_msg_error. "S
        lwa_bapiret-type       = lc_msg_success.
*Begin of Defect# 1766
        lwa_bapiret-id         = lc_msg_id. " ZOTC(MSG)
        lwa_bapiret-number     = lc_msg_155. "155
        lwa_bapiret-message_v1 = <lfs_matbatch_quan>-charg.
        lwa_bapiret-message_v2 = <lfs_matbatch_quan>-req_qty.
        CONDENSE lwa_bapiret-message_v2.
        MESSAGE s155(zotc_msg) WITH lwa_bapiret-message_v1 " For Input Batch & ,Quanity & is avalibale.
                                    lwa_bapiret-message_v2
                               INTO lwa_bapiret-message.
        APPEND lwa_bapiret TO ex_batch_msg.
      ENDIF. " IF ( <lfs_batch>-kulab LT <lfs_matbatch_quan>-req_qty )
    ENDIF. " IF sy-subrc EQ 0
  ENDLOOP. " LOOP AT im_matbatch_quan ASSIGNING <lfs_matbatch_quan>

  FREE: li_mvke,
        li_batch,
        li_temp.

ENDFUNCTION.
