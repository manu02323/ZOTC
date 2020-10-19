*&---------------------------------------------------------------------*
*&  Include           ZOTCN0010O_BATCH_MATCHING_FORM                   *
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0010O_BATCH_MATCHING_FORM                         *
* TITLE      :  Batch Matching Report                                  *
* DEVELOPER  :  Pallavi Gupta                                          *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_RDD_0010_BATCH_MATCHING Report                       *
*----------------------------------------------------------------------*
* DESCRIPTION:  Include for Subroutine for report                      *
*               ZOTCR0010O_BATCH_MATCHING                              *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
*  DATE        USER     TRANSPORT   DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 16-Jul-2012 PGUPTA2  E1DK901335 INITIAL DEVELOPMENT                  *
* 17-Dec-2012 RVERMA   E1DK908486 Defect#2164: Performance Issues      *
* 06-AUG-2014 PROUT    E1DK913381 INC0140560 / CR1286:                 *
*                                 Updated selection screen with extra  *
*                                 checkbox 'Without Order History'. If *
*                                 the indicator got checked sales ord. *
*                                 details for the customer will not be *
*                                 displayed in the report output. Also *
*                                 Material Number and Batch Number will*
*                                 have multiple selections. If the     *
*                                 indicator is not checked then        *
*                                 Material No and Batch No will have   *
*                                 single entry and sales order history *
*                                 for the customer needs to be fetched *
*                                 for the customer in the report o/p.  *
*&---------------------------------------------------------------------*
* 16-SEP-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Added some additional requirements   *
*                                 as per business user demand.         *
*                                 1.New selection parameter of Ship-to *
*                                 2.New rept output column of Ship-to  *
*                                 3.Ship-to value fetching logic       *
*                                 4.Shift of column Unrest. Stock to   *
*                                   the end of the output              *
* 08-Oct-2014 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Field description changes recommended*
*                                 by business in the selection screen  *
*                                 and report output.                   *
*                                 Customer desc not getting populated. *
*&---------------------------------------------------------------------*
* 19-JAN-2015 SPAUL2   E1DK913381 INC0140560 / CR1286:                 *
*                                 Remove ‘Zero Inventory’ selection    *
*                                 button from the selection screen of  *
*                                 the report.                          *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F_DATA_SELECTION
*&---------------------------------------------------------------------*
*   Subroutine for data selection
*----------------------------------------------------------------------*
FORM f_data_selection.

* Local Declaration
  DATA : li_mchb_temp TYPE ty_t_mchb,  " Internal Table Temporary for Mchb
         li_batch     TYPE ty_t_batch, " Internal table of type batch
         lwa_batch    TYPE ty_batch_1, "Work area for ty_batch1
         li_atinn     TYPE ty_t_atinn, "Internal table for atinn
         lwa_atinn    TYPE ty_atinn,   "Work area for atinn
         li_cabn      TYPE ty_t_cabn,  "Local internal table for cabn
*&--BOC ADD Defect#2164 RVERMA 12/17/2012
         li_ausp      TYPE ty_t_ausp,  " Local Internal Table for Ausp
         li_mch1      TYPE ty_t_mch1,  " Local Internal Table for Mch1
         li_vapma     TYPE ty_t_vapma, " Local Internal Table for Vapma
         li_vbap      TYPE ty_t_vbap,  " Local Internal Table for Vbap
         li_vbfa      TYPE ty_t_vbfa,  " Local Internal Table for Vbfa
*&--EOC ADD Defect#2164 RVERMA 12/17/2012
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
         li_vbpa       TYPE ty_t_vbpa, " Internal table for VBPA
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
        li_kunnr       TYPE ty_t_kunnr, " Local Internal Table for kunnr values
        lwa_kunnr      TYPE ty_kunnr.   " Local Work area for KUNNR values
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014

* Feild Symbols Declaration
  FIELD-SYMBOLS : <lfs_batch>     TYPE ty_batch, " Field symbol for Batch
                  <lfs_ausp>      TYPE ty_ausp,  " Field Symbol for ausp
                  <lfs_mchb>      TYPE ty_mchb,  " Field Symbol for Mchb
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                   <lfs_mch1>      TYPE ty_mch1, " Field Symbol for Mch1
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
                  <lfs_mchb_temp> TYPE ty_mchb, " Field Symbol for Mchb
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
                  <lfs_vbpa>      TYPE ty_vbpa,  " Field Symbol for vbpa
                  <lfs_vapma>     TYPE ty_vapma. " Field Symbol for vapma
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
*Fetching data from table zotc_batchmatch
*If product group is entered on selection screen
  IF p_atwrt IS NOT INITIAL.

*Selcting the value of ATINN from the table CABN
    SELECT atinn               " Internal characteristic
           atnam               " Characteristic Name
       FROM cabn               " Characteristic
      INTO TABLE li_cabn
        WHERE atnam = c_atinn. "c_bm.

    IF sy-subrc = 0.

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
      SORT li_cabn BY atinn.
      DELETE ADJACENT DUPLICATES FROM li_cabn
                            COMPARING atinn.
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

      SELECT objek " Key of object to be classified
             atinn " Internal characteristic
             atzhl " Characteristic value counter
             mafid " Indicator: Object/Class
             klart " Class Type
             adzhl " Internal counter for archiving objects via engin. chg. mgmt
             atwrt " Characteristic Value
         FROM ausp " Characteristic Values
         INTO TABLE i_ausp
         FOR ALL ENTRIES IN li_cabn
         WHERE klart = c_class
           AND atinn = li_cabn-atinn
           AND atwrt = p_atwrt.
      IF sy-subrc <> 0.
        MESSAGE i116.
        LEAVE LIST-PROCESSING.
      ELSE. " ELSE -> IF sy-subrc <> 0
        SORT i_ausp BY objek atinn.
      ENDIF. " IF sy-subrc <> 0
    ENDIF. " IF sy-subrc = 0

    IF i_ausp IS NOT INITIAL.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*      SELECT matnr
*           zlevel
*           matnr2
*           compcode
*      FROM zotc_batchmatch
*      INTO TABLE i_batch
*      FOR ALL ENTRIES IN i_ausp
*        WHERE matnr2 = i_ausp-objek.
*
*      IF sy-subrc NE 0.
*        MESSAGE i115.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
      SORT li_ausp BY objek.
      DELETE ADJACENT DUPLICATES FROM li_ausp
                            COMPARING objek.

      IF li_ausp[] IS NOT INITIAL.
        SELECT matnr         " Kit
               zlevel        " Level
               matnr2        " Material Number
               compcode      " Compatibility Code
        FROM zotc_batchmatch " Material Characteristic
        INTO TABLE i_batch
        FOR ALL ENTRIES IN li_ausp
          WHERE matnr2 = li_ausp-objek.

        IF sy-subrc NE 0.
          MESSAGE i115.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF li_ausp[] IS NOT INITIAL
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

    ENDIF. " IF i_ausp IS NOT INITIAL

  ELSE. " ELSE -> IF sy-subrc NE 0
*If product group is not entered on selection screen
    SELECT matnr           " Kit
           zlevel          " Level
           matnr2          " Material Number
           compcode        " Compatibility Code
      FROM zotc_batchmatch " Material Characteristic
      INTO TABLE li_batch
*BOC : CR# 1286 : PROUT : 06-AUG-2014
*      WHERE matnr2 = p_matnr.
      WHERE matnr2 IN s_matnr.
*EOC : CR# 1286 : PROUT : 06-AUG-2014
    IF sy-subrc = 0.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*      SELECT matnr
*           zlevel
*           matnr2
*           compcode
*      FROM zotc_batchmatch
*      INTO TABLE i_batch
*        FOR ALL ENTRIES IN li_batch
*        WHERE matnr = li_batch-matnr.
*
*      IF sy-subrc NE 0.
*        MESSAGE i115.
*        LEAVE LIST-PROCESSING.
*      ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
      SORT li_batch BY matnr.
      DELETE ADJACENT DUPLICATES FROM li_batch
                            COMPARING matnr.

      IF li_batch[] IS NOT INITIAL.
        SELECT matnr           " Kit
               zlevel          " Level
               matnr2          " Material Number
               compcode        " Compatibility Code
          FROM zotc_batchmatch " Material Characteristic
          INTO TABLE i_batch
          FOR ALL ENTRIES IN li_batch
          WHERE matnr = li_batch-matnr.

        IF sy-subrc NE 0.
          MESSAGE i115.
          LEAVE LIST-PROCESSING.
        ENDIF. " IF sy-subrc NE 0
      ENDIF. " IF li_batch[] IS NOT INITIAL
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF p_atwrt IS NOT INITIAL

  IF cb_det IS INITIAL.
    LOOP AT i_batch ASSIGNING <lfs_batch>.
      IF <lfs_batch>-matnr NE <lfs_batch>-matnr2.
        CLEAR <lfs_batch>-matnr2.
      ENDIF. " IF <lfs_batch>-matnr NE <lfs_batch>-matnr2
    ENDLOOP. " LOOP AT i_batch ASSIGNING <lfs_batch>
    DELETE i_batch WHERE matnr2 IS INITIAL.
  ENDIF. " IF cb_det IS INITIAL

  IF i_batch IS NOT INITIAL.
    SORT i_batch BY matnr zlevel.
*Move the values of i_batch in temporary table
    i_batch_tmp[] = i_batch[].
    SORT i_batch_tmp BY matnr2.

*Converting the compatibilty code to numeric
    LOOP AT i_batch ASSIGNING <lfs_batch>.
      CALL FUNCTION 'CONVERSION_EXIT_ATINN_INPUT'
        EXPORTING
          input  = <lfs_batch>-compcode
        IMPORTING
          output = <lfs_batch>-ccode.
    ENDLOOP. " LOOP AT i_batch ASSIGNING <lfs_batch>

*Fetching the data from ausp table
    CLEAR li_batch. "Added for Defect#2164
    li_batch[] = i_batch[].

    SORT li_batch BY ccode.
    DELETE ADJACENT DUPLICATES FROM li_batch COMPARING ccode.
    REFRESH i_ausp.

    SELECT objek " Key of object to be classified
           atinn " Internal characteristic
           atzhl " Characteristic value counter
           mafid " Indicator: Object/Class
           klart " Class Type
           adzhl " Internal counter for archiving objects via engin. chg. mgmt
           atwrt " Characteristic Value
           atflv " Internal floating point from
      FROM ausp  " Characteristic Values
      INTO TABLE i_ausp
      FOR ALL ENTRIES IN li_batch
      WHERE atinn = li_batch-ccode.

    IF sy-subrc = 0.
      SORT i_ausp BY objek atinn.
    ENDIF. " IF sy-subrc = 0

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
*Fetching description
    SELECT atinn " Internal characteristic
           spras " Language Key
           adzhl " Internal counter for archiving objects via engin. chg. mgmt
           atbez " Characteristic description
      FROM cabnt " Characteristic Descriptions
      INTO TABLE i_cabnt
      FOR ALL ENTRIES IN li_batch
      WHERE atinn = li_batch-ccode
        AND spras = sy-langu.

    IF sy-subrc = 0.
      SORT i_cabnt BY atinn.
    ENDIF. " IF sy-subrc = 0

    CLEAR li_batch.
    li_batch[] = i_batch[].

    SORT li_batch BY matnr2.
    DELETE ADJACENT DUPLICATES FROM li_batch
                          COMPARING matnr2.

*Fetch Material Description
    SELECT  matnr " Material Number
            spras " Language Key
            maktx " Material Description (Short Text)
       FROM makt  " Material Descriptions
       INTO TABLE i_makt
       FOR ALL ENTRIES IN li_batch
       WHERE matnr = li_batch-matnr2
        AND  spras = sy-langu.
    IF sy-subrc = 0.
      SORT i_makt BY matnr.
    ENDIF. " IF sy-subrc = 0

* Fetching Batches data.
    SELECT matnr    " Material Number
           charg    " Batch Number
           vfdat    " Shelf Life Expiration or Best-Before Date
           hsdat    " Date of Manufacture
           cuobj_bm " Internal object no.: Batch classification
       FROM mch1    " Batches (if Batch Management Cross-Plant)
       INTO TABLE i_mch1
       FOR ALL ENTRIES IN li_batch
       WHERE matnr = li_batch-matnr2
        AND  charg IN s_charg.

    IF sy-subrc = 0.
      SORT i_mch1 BY matnr.
    ELSE. " ELSE -> IF sy-subrc = 0
      MESSAGE i115.
      LEAVE LIST-PROCESSING.
    ENDIF. " IF sy-subrc = 0

**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
    IF cb_hist IS INITIAL.
      DELETE i_mch1 WHERE vfdat < sy-datum.
    ENDIF. " IF cb_hist IS INITIAL
**&& -- EOC : CR# 1286 : PROUT : 06-AUG-2014
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
**Fetch Material Description
*    SELECT  matnr
*            spras
*            maktx
*       FROM makt
*       INTO TABLE i_makt
*       FOR ALL ENTRIES IN i_batch
*       WHERE matnr = i_batch-matnr2
*        AND  spras = sy-langu.
*    IF sy-subrc = 0.
*      SORT i_makt BY matnr spras.
*    ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

  ENDIF. " IF i_batch IS NOT INITIAL

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
  LOOP AT i_batch ASSIGNING <lfs_batch>.
    lwa_batch-matnr = <lfs_batch>-matnr.
    lwa_batch-zlevel = <lfs_batch>-zlevel.
    lwa_batch-matnr2 = <lfs_batch>-matnr2.
    lwa_batch-ccode = <lfs_batch>-ccode.
    APPEND lwa_batch TO i_batch_1.
    CLEAR lwa_batch.
  ENDLOOP. " LOOP AT i_batch ASSIGNING <lfs_batch>
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

*Fetching characteristic name
  CLEAR gv_atinn.
  SELECT atinn UP TO 1 ROWS
     INTO gv_atinn
     FROM cabn " Characteristic
    WHERE atnam = c_atinn.
  ENDSELECT.

  IF sy-subrc = 0.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*    SELECT objek
*         atinn
*         atwrt
*         atflv
*  FROM ausp
*    INTO TABLE i_ausp_1
*    FOR ALL ENTRIES IN i_batch_1
*    WHERE objek = i_batch_1-matnr2
*     AND  atinn = gv_atinn.
*
*    IF sy-subrc = 0.
*      SORT i_ausp_1 BY objek atinn.
*    ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
    IF i_batch_1[] IS NOT INITIAL.

      SORT i_batch_1 BY matnr2.
      DELETE ADJACENT DUPLICATES FROM i_batch_1
                            COMPARING matnr2.

      SELECT objek " Key of object to be classified
             atinn " Internal characteristic
             atzhl " Characteristic value counter
             mafid " Indicator: Object/Class
             klart " Class Type
             adzhl " Internal counter for archiving objects via engin. chg. mgmt
             atwrt " Characteristic Value
             atflv " Internal floating point from
        FROM ausp  " Characteristic Values
        INTO TABLE i_ausp_1
        FOR ALL ENTRIES IN i_batch_1
        WHERE objek = i_batch_1-matnr2
          AND atinn = gv_atinn.

      IF sy-subrc = 0.
        SORT i_ausp_1 BY objek atinn.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_batch_1[] IS NOT INITIAL
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

  ENDIF. " IF sy-subrc = 0

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*  LOOP AT i_batch ASSIGNING <lfs_batch>.
*    lwa_batch-matnr = <lfs_batch>-matnr.
*    lwa_batch-zlevel = <lfs_batch>-zlevel.
*    lwa_batch-matnr2 = <lfs_batch>-matnr2.
*    lwa_batch-ccode = <lfs_batch>-ccode.
*    APPEND lwa_batch TO i_batch_1.
*    CLEAR lwa_batch.
*  ENDLOOP.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

  LOOP AT i_ausp ASSIGNING <lfs_ausp>.
    lwa_atinn-atinn = <lfs_ausp>-atinn.
    APPEND lwa_atinn TO li_atinn.
    CLEAR lwa_atinn.
  ENDLOOP. " LOOP AT i_ausp ASSIGNING <lfs_ausp>

  LOOP AT i_ausp_1 ASSIGNING <lfs_ausp>.
    lwa_atinn-atinn = <lfs_ausp>-atinn.
    APPEND lwa_atinn TO li_atinn.
    CLEAR lwa_atinn.
  ENDLOOP. " LOOP AT i_ausp_1 ASSIGNING <lfs_ausp>

  IF li_atinn IS NOT INITIAL.

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
    SORT li_atinn BY atinn.
    DELETE ADJACENT DUPLICATES FROM li_atinn
                          COMPARING atinn.
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

*   Fetching Characteristc Details
    SELECT atinn " Internal characteristic
           adzhl " Internal counter for archiving objects via engin. chg. mgmt
           atnam " Characteristic Name
           atfor " Data type of characteristic
      FROM cabn  " Characteristic
      INTO TABLE i_cabn
      FOR ALL ENTRIES IN li_atinn
      WHERE atinn = li_atinn-atinn.

    IF sy-subrc = 0.
      SORT i_cabn BY atinn.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF li_atinn IS NOT INITIAL

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
**Fetching description
*  SELECT atinn
*         spras
*         atbez
*    FROM cabnt
*    INTO TABLE i_cabnt
*    FOR ALL ENTRIES IN i_batch
*    WHERE atinn = i_batch-ccode
*     AND  spras = sy-langu.
*
*  IF sy-subrc = 0.
*    SORT i_cabnt BY atinn spras.
*  ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*Fetching Product Group description from table CAWNT
  IF gv_atinn IS NOT INITIAL. "Added for Defect#2164
    SELECT atinn " Internal characteristic
           atzhl " Int counter
           spras " Language Key
           adzhl " Internal counter for archiving objects via engin. chg. mgmt
           atwtb " Characteristic value description
      FROM cawnt " Value Texts
      INTO TABLE i_cawnt
      WHERE atinn = gv_atinn
       AND  spras = sy-langu.
    IF sy-subrc = 0.
      SORT i_cawnt BY atinn atzhl.
    ENDIF. " IF sy-subrc = 0
  ENDIF.

  LOOP AT i_ausp ASSIGNING <lfs_ausp>.
    <lfs_ausp>-cuobj = <lfs_ausp>-objek.
  ENDLOOP. " LOOP AT i_ausp ASSIGNING <lfs_ausp>

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
** Fetching Batches data.
*  SELECT matnr
*         charg
*         vfdat
*         hsdat
*         cuobj_bm
*     FROM mch1
*     INTO TABLE i_mch1
*     FOR ALL ENTRIES IN i_batch
*     WHERE matnr = i_batch-matnr2
*      AND  charg IN s_charg.
*
*  IF sy-subrc = 0.
*    SORT i_mch1 BY matnr.
*  ELSE.
*    MESSAGE i115.
*    LEAVE LIST-PROCESSING.
*  ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

  IF i_mch1[] IS NOT INITIAL.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
**  Fetching Compatibilty Code
*    SELECT cuobj
*           klart
*           obtab
*           objek
*       FROM inob
*       INTO TABLE i_inob
*      FOR ALL ENTRIES IN i_mch1
*      WHERE cuobj = i_mch1-cuobj_bm.
*
*    IF sy-subrc = 0.
*      SORT i_inob BY cuobj.
*    ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
    li_mch1[] = i_mch1[].

    SORT li_mch1 BY cuobj_bm.
    DELETE ADJACENT DUPLICATES FROM li_mch1
                          COMPARING cuobj_bm.

    IF li_mch1[] IS NOT INITIAL.
*  Fetching Compatibilty Code
      SELECT cuobj " Configuration (internal object number)
             klart " Class Type
             obtab " Name of database table for object
             objek " Key of Object to be Classified
         FROM inob " Link between Internal Number and Object
         INTO TABLE i_inob
         FOR ALL ENTRIES IN li_mch1
         WHERE cuobj = li_mch1-cuobj_bm.

      IF sy-subrc = 0.
        SORT i_inob BY cuobj.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF li_mch1[] IS NOT INITIAL
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

*  Fetching Inventory Details
    SELECT matnr " Material Number
           werks " Plant
           lgort " Storage Location
           charg " Batch Number
           clabs " Valuated Unrestricted-Use Stock
           cumlm " Stock in transfer (from one storage location to another)
           cinsm " Stock in Quality Inspection
           ceinm " Total Stock of All Restricted Batches
       FROM mchb " Batch Stocks
       INTO TABLE i_mchb
       FOR ALL ENTRIES IN i_mch1
       WHERE matnr = i_mch1-matnr
       AND   charg = i_mch1-charg.

    IF sy-subrc = 0.

*     Sum up stock data based on material, plant and batch
      LOOP AT i_mchb ASSIGNING  <lfs_mchb>.
        COLLECT <lfs_mchb> INTO li_mchb_temp[].
      ENDLOOP. " LOOP AT i_mchb ASSIGNING <lfs_mchb>

      REFRESH: i_mchb[].
      i_mchb[] = li_mchb_temp[].

      SORT  li_mchb_temp BY matnr
                            werks
                            charg.


*       Calculation for Zero inventory
      LOOP AT i_mchb ASSIGNING <lfs_mchb>.

        READ TABLE li_mchb_temp ASSIGNING <lfs_mchb_temp> WITH KEY
                                                matnr = <lfs_mchb>-matnr
                                                werks = <lfs_mchb>-werks
                                                charg = <lfs_mchb>-charg
                                             BINARY SEARCH.

        IF sy-subrc = 0.
          <lfs_mchb_temp>-inv =   <lfs_mchb_temp>-inv
                                + <lfs_mchb_temp>-clabs
                                + <lfs_mchb_temp>-cumlm
                                + <lfs_mchb_temp>-cinsm
                                + <lfs_mchb_temp>-ceinm.
        ENDIF. " IF sy-subrc = 0
      ENDLOOP. " LOOP AT i_mchb ASSIGNING <lfs_mchb>

*       When Zero inv checkbox not selected
**&& --  BOC : CR# 1286 : SPAUL2 : 19-JAN-2015
*      IF cb_invt IS INITIAL.
*
*      LOOP AT li_mchb_temp ASSIGNING <lfs_mchb_temp>.
*        IF <lfs_mchb_temp>-inv = c_zero. "'0'.
*          <lfs_mchb_temp>-del = c_inv.  " 'X'.
*        ENDIF.
*      ENDLOOP.
*
*      ENDIF.
*
*      DELETE li_mchb_temp WHERE del = c_inv.
**&& --  EOC : CR# 1286 : SPAUL2 : 19-JAN-2015
      REFRESH i_mchb[].
      i_mchb[] = li_mchb_temp[].
      SORT i_mchb BY matnr
                      charg.
    ENDIF. " IF sy-subrc = 0

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
**     Fetching Sales Data
*    SELECT  matnr
*            audat
*            kunnr
*            vbeln
*            posnr
*       FROM vapma
*      INTO TABLE i_vapma
*      FOR ALL ENTRIES IN i_mch1
*        WHERE matnr = i_mch1-matnr
*         AND audat IN s_date
*         AND kunnr IN s_kunnr.
*
*    IF sy-subrc = 0.
*      SORT i_vapma BY vbeln.
*    ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
    CLEAR li_mch1.
    li_mch1[] = i_mch1[].

    SORT li_mch1 BY matnr.
    DELETE ADJACENT DUPLICATES FROM li_mch1
                          COMPARING matnr.

    IF li_mch1 IS NOT INITIAL.
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
      IF cb_hist = abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
*     Fetching Sales Data
        SELECT  matnr " Material Number
                vkorg " Sales Organization
                trvog " Transaction group
                audat " Document Date (Date Received/Sent)
                vtweg " Distribution Channel
                spart " Division
                auart " Sales Document Type
                kunnr " Sold-to party
                vkbur " Sales Office
                vkgrp " Sales Group
                bstnk " Customer purchase order number
                ernam " Name of Person who Created the Object
                vbeln " Sales and Distribution Document Number
                posnr " Item number of the SD document
          FROM vapma  " Sales Index: Order Items by Material
          INTO TABLE i_vapma
          FOR ALL ENTRIES IN li_mch1
          WHERE matnr = li_mch1-matnr
            AND audat IN s_date
            AND kunnr IN s_kunnr.

        IF sy-subrc = 0.
          SORT i_vapma BY vbeln.
**&& -- Begin of delete: CR #1286 : SPAUL2 : 16-SEP-2014
*        ENDIF.
**&& -- End of delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
          REFRESH li_vapma.
          li_vapma[] = i_vapma.
          SORT li_vapma BY vbeln.
          DELETE ADJACENT DUPLICATES FROM li_vapma COMPARING vbeln.

          SELECT vbeln                " Sales and Distribution Document Number
                 posnr                " Item number of the SD document
                 parvw                " Partner Function
                 kunnr                " Customer Number
                 FROM vbpa            " Sales Document: Partner
             INTO TABLE i_vbpa
             FOR ALL ENTRIES IN li_vapma
             WHERE vbeln = li_vapma-vbeln
               AND posnr = c_posnr
               AND parvw = c_parvw_we "SHip to
               AND kunnr IN s_shipto.
          IF sy-subrc =  0.
            SORT i_vbpa BY vbeln.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014

**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
      ENDIF. " IF cb_hist = abap_true
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

    ENDIF. " IF li_mch1 IS NOT INITIAL
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

  ENDIF. " IF i_mch1[] IS NOT INITIAL
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
  IF cb_hist = abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
    IF i_vbpa[] IS NOT INITIAL.
      li_vbpa[] =  i_vbpa[].

      SORT li_vbpa BY vbeln.
      DELETE ADJACENT DUPLICATES FROM li_vbpa
                            COMPARING vbeln.
      SELECT vbeln  " Sales Document
             posnr  " Sales Document Item
             matnr  " Material Number
             charg  " Batch Number
             netwr  " Net value of the order item in document currency
             waerk  " SD Document Currency
             kwmeng " Cumulative Order Quantity in Sales Units
             vrkme  " Sales unit
             werks  " Plant (Own or External)
        FROM vbap   " Sales Document: Item Data
        INTO TABLE i_vbap
        FOR ALL ENTRIES IN li_vbpa
        WHERE vbeln = li_vbpa-vbeln
          AND charg IN s_charg.

      IF sy-subrc = 0.
        SORT i_vbap BY vbeln posnr matnr charg.
        i_vbap_tmp[] = i_vbap[].
        SORT i_vbap_tmp BY matnr.
      ENDIF. " IF sy-subrc = 0
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 08-OCT-2014
*      REFRESH li_vbpa.
*      li_vbpa[] = i_vbpa[].
*
*      SORT li_vbpa BY kunnr.
*      DELETE ADJACENT DUPLICATES FROM li_vbpa
*                            COMPARING kunnr.
*
**     Fetching Customer no and name
*      SELECT kunnr
*             name1
*        FROM kna1
*        INTO TABLE i_kna1
*        FOR ALL ENTRIES IN li_vbpa
*        WHERE kunnr = li_vbpa-kunnr.
*
*      IF sy-subrc = 0.
*        SORT i_kna1 BY kunnr.
*      ENDIF.
**&& -- End of Delete: CR #1286 : SPAUL2 : 08-OCT-2014

    ELSE. " ELSE -> IF sy-subrc = 0
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014

*   Fetching Sales Item Data
      IF i_vapma[] IS NOT INITIAL.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*    SELECT vbeln
*           posnr
*           matnr
*           charg
*           netwr
*           waerk
*           kwmeng
*           vrkme
*           werks
*      FROM vbap
*      INTO TABLE i_vbap
*      FOR ALL ENTRIES IN i_vapma
*      WHERE vbeln = i_vapma-vbeln
*        AND posnr = i_vapma-posnr.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
        li_vapma[] = i_vapma[].

        SORT li_vapma BY vbeln posnr.
        DELETE ADJACENT DUPLICATES FROM li_vapma
                              COMPARING vbeln posnr.

        IF li_vapma[] IS NOT INITIAL.
          SELECT vbeln  " Sales Document
                 posnr  " Sales Document Item
                 matnr  " Material Number
                 charg  " Batch Number
                 netwr  " Net value of the order item in document currency
                 waerk  " SD Document Currency
                 kwmeng " Cumulative Order Quantity in Sales Units
                 vrkme  " Sales unit
                 werks  " Plant (Own or External)
            FROM vbap   " Sales Document: Item Data
            INTO TABLE i_vbap
            FOR ALL ENTRIES IN li_vapma
            WHERE vbeln = li_vapma-vbeln
              AND posnr = li_vapma-posnr
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
              AND charg IN s_charg.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

          IF sy-subrc = 0.
            SORT i_vbap BY vbeln posnr matnr charg.
            i_vbap_tmp[] = i_vbap[].
            SORT i_vbap_tmp BY matnr.
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF li_vapma[] IS NOT INITIAL

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
**     Fetching Customer no and name
*    SELECT kunnr
*           name1
*      FROM kna1
*      INTO TABLE i_kna1
*      FOR ALL ENTRIES IN i_vapma
*      WHERE kunnr = i_vapma-kunnr.
*
*    IF sy-subrc = 0.
*      SORT i_kna1 BY kunnr.
*    ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 08-OCT-2014
*        CLEAR li_vapma.
*        li_vapma[] = i_vapma[].
*
*        SORT li_vapma BY kunnr.
*        DELETE ADJACENT DUPLICATES FROM li_vapma
*                              COMPARING kunnr.
*
*        IF li_vapma[] IS NOT INITIAL.
*
**     Fetching Customer no and name
*          SELECT kunnr
*                 name1
*            FROM kna1
*            INTO TABLE i_kna1
*            FOR ALL ENTRIES IN li_vapma
*            WHERE kunnr = li_vapma-kunnr.
*
*          IF sy-subrc = 0.
*            SORT i_kna1 BY kunnr.
*          ENDIF.
*        ENDIF.
**&& -- End of Delete: CR #1286 : SPAUL2 : 08-OCT-2014

*&--EOC ADD Defect#2164 RVERMA 12/17/2012
      ENDIF. " IF i_vapma[] IS NOT INITIAL

**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
    ENDIF. " IF i_vbpa[] IS NOT INITIAL
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014

**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014

    REFRESH li_vbpa.
    li_vbpa[] = i_vbpa[].

    SORT li_vbpa BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_vbpa
                          COMPARING kunnr.

    LOOP AT li_vbpa ASSIGNING <lfs_vbpa>.
      lwa_kunnr-kunnr = <lfs_vbpa>-kunnr.
      APPEND lwa_kunnr TO li_kunnr.
    ENDLOOP. " LOOP AT li_vbpa ASSIGNING <lfs_vbpa>

    CLEAR li_vapma.
    li_vapma[] = i_vapma[].

    SORT li_vapma BY kunnr.
    DELETE ADJACENT DUPLICATES FROM li_vapma
                          COMPARING kunnr.
    LOOP AT li_vapma ASSIGNING <lfs_vapma>.
      lwa_kunnr-kunnr = <lfs_vapma>-kunnr.
      APPEND lwa_kunnr TO li_kunnr.
    ENDLOOP. " LOOP AT li_vapma ASSIGNING <lfs_vapma>

    IF li_kunnr[] IS NOT INITIAL.

      SELECT kunnr " Customer Number
             name1 " Name 1
        FROM kna1  " General Data in Customer Master
        INTO TABLE i_kna1
        FOR ALL ENTRIES IN li_kunnr
        WHERE kunnr = li_kunnr-kunnr.

      IF sy-subrc = 0.
        SORT i_kna1 BY kunnr.
      ENDIF. " IF sy-subrc = 0

    ENDIF. " IF li_kunnr[] IS NOT INITIAL
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014

*   Fetching Customer PO No.
    IF i_vbap[] IS NOT INITIAL.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*    SELECT vbeln
*           posnr
*           bstkd
*      FROM vbkd
*      INTO TABLE i_vbkd
*      FOR ALL ENTRIES IN i_vbap
*      WHERE vbeln = i_vbap-vbeln
*       AND  posnr = c_posnr.
*    IF sy-subrc = 0.
*      SORT i_vbkd BY vbeln.
*    ENDIF.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
      li_vbap[] = i_vbap[].

      SORT li_vbap BY vbeln.
      DELETE ADJACENT DUPLICATES FROM li_vbap
                            COMPARING vbeln.

      IF li_vbap[] IS NOT INITIAL.
        SELECT vbeln " Sales and Distribution Document Number
               posnr " Item number of the SD document
               bstkd " Customer purchase order number
          FROM vbkd  " Sales Document: Business Data
          INTO TABLE i_vbkd
          FOR ALL ENTRIES IN li_vbap
          WHERE vbeln = li_vbap-vbeln
           AND  posnr = c_posnr.
        IF sy-subrc = 0.
          SORT i_vbkd BY vbeln.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_vbap[] IS NOT INITIAL
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

*     Fetching Delivery no
      SELECT  vbelv               " Preceding sales and distribution document
              posnv               " Preceding item of an SD document
              vbeln               " Subsequent sales and distribution document
              posnn               " Subsequent item of an SD document
              vbtyp_n             " Document category of subsequent document
         FROM vbfa                " Sales Document Flow
         INTO TABLE i_vbfa
         FOR ALL ENTRIES IN i_vbap
         WHERE vbelv   = i_vbap-vbeln
           AND posnv   = i_vbap-posnr
           AND vbtyp_n = c_vbtyp. "'J'.

      IF sy-subrc = 0.
        SORT i_vbfa BY vbelv
                        posnv.

        SELECT vbeln " Delivery
               posnr " Delivery Item
               charg " Batch Number
          FROM lips  " SD document: Delivery: Item data
          INTO TABLE i_lips
          FOR ALL ENTRIES IN i_vbfa
          WHERE vbeln = i_vbfa-vbeln
            AND posnr = i_vbfa-posnv.
        IF sy-subrc = 0.
          SORT i_lips BY vbeln posnr.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF i_vbap[] IS NOT INITIAL

*   Fetching Actual Goods Movement Date
    IF i_vbfa[] IS NOT INITIAL.

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*    SELECT  vbeln
*            wadat_ist
*       FROM likp
*       INTO TABLE i_likp
*       FOR ALL ENTRIES IN i_vbfa
*       WHERE  vbeln = i_vbfa-vbeln.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
      li_vbfa[] = i_vbfa[].
      SORT li_vbfa BY vbeln.
      DELETE ADJACENT DUPLICATES FROM li_vbfa
                            COMPARING vbeln.

      IF li_vbfa[] IS NOT INITIAL.
        SELECT  vbeln     " Delivery
                wadat_ist " Actual Goods Movement Date
           FROM likp      " SD Document: Delivery Header Data
           INTO TABLE i_likp
           FOR ALL ENTRIES IN li_vbfa
           WHERE  vbeln = li_vbfa-vbeln.
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

        IF sy-subrc = 0.
          SORT i_likp BY vbeln.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF li_vbfa[] IS NOT INITIAL
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
    ENDIF. " IF i_vbfa[] IS NOT INITIAL
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
  ENDIF. " IF cb_hist = abap_true

ENDFORM. " F_DATA_SELECTION
*&---------------------------------------------------------------------*
*&      Form  F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*       Subroutine to display the output in ALV
*----------------------------------------------------------------------*
FORM f_output_display.

*Local Data
  DATA : lv_repid TYPE sy-repid. "Report name

*  Building header of the report display
  PERFORM f_fill_listheader.
*  Building Field Catalog
  PERFORM build_fieldcat.

  lv_repid = sy-repid.
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
  IF cb_hist IS INITIAL.
    SORT i_final BY vfdat DESCENDING.
  ELSE. " ELSE -> IF cb_hist IS INITIAL
    SORT i_final BY audat DESCENDING.
  ENDIF. " IF cb_hist IS INITIAL
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

*  FM Call to display output in ALV
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = lv_repid
      i_callback_top_of_page = c_top
      it_fieldcat            = i_fieldcat
      i_save                 = c_save
    TABLES
      t_outtab               = i_final
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.

    MESSAGE i000 WITH 'Output could not be displayed'(073).
    LEAVE LIST-PROCESSING.
  ENDIF. " IF sy-subrc <> 0

ENDFORM. " F_OUTPUT_DISPLAY
*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*      Subroutine for Creating field catalog
*----------------------------------------------------------------------*
FORM build_fieldcat .

  PERFORM f_fill_fieldcat USING 'ATWRT'(015)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Prod Group'(003)
                                 10
                                 0
                                c_left
                                ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'ATWRT_DEC'(069)
                             ''
                             ''
                            'I_FINAL'(013)
                            'PG Description'(070)
                             10
                             1
                            c_left
                            ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                            abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'MATNR'(014)
                               ''
                               ''
                               'I_FINAL'(013)
                               'Material'(004)
                                18
                                2
                                c_left
                                ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014


  PERFORM f_fill_fieldcat USING 'POSNR'(023)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Mat. Description'(010)
                                   6
                                   3
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'CHARG'(024)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Batch'(012)
                                 10
                                 4
                                 c_left
                                 ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'VFDAT'(017)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'SLED'(037)
                                   10
                                   5
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'ATINN'(042)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Char'(043)
                                 15
                                 6
                                 c_left
                                 ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'ATWRT_M'(071)
                              ''
                              ''
                              'I_FINAL'(013)
                              'Comp.Code'(072)
                               10
                               7
                               c_left
                               ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                               abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*  PERFORM f_fill_fieldcat USING 'CLABS'(050)
*                               ''
*                               'VRKME'(048)
*                               'I_FINAL'(013)
*                               'Unrest.Stock'(040)
*                                10
*                                8
*                                c_left
*                                'QUAN'(075)
***&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
*                                abap_false.
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
  IF cb_hist = abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
    PERFORM f_fill_fieldcat USING 'KUNNR'(057)
                                  ''
                                  ''
                                  'I_FINAL'(013)
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
                                  'Sold-to No.'(064)
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 08-OCT-2014
*                                  'Customer No.'(064)
**&& -- End of Delete: CR #1286 : SPAUL2 : 08-OCT-2014
                                   10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   9
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   8
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
    PERFORM f_fill_fieldcat USING 'NAME1'(018)
                                  ''
                                  ''
                                  'I_FINAL'(013)
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
                               'Sold-to Description'(005)
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 08-OCT-2014
*                                  'Cust. Description'(005)
**&& -- End of Insert: CR #1286 : SPAUL2 : 08-OCT-2014
                                   8
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   10
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   9
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
    PERFORM f_fill_fieldcat USING 'BSTKD'(022)
                                   ''
                                   ''
                                   'I_FINAL'(013)
                                   'PO No.'(009)
                                    10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                    11
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                    10
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                    c_left
                                    ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                    abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014


    PERFORM f_fill_fieldcat USING 'VBELN'(019)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Sales Order'(006)
                                   10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   12
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   11
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014


    PERFORM f_fill_fieldcat USING 'AUDAT'(020)
                                    ''
                                    ''
                                    'I_FINAL'(013)
                                    'SO Date'(007)
                                     10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                     13
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                     12
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                     c_left
                                     ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                     abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

    PERFORM f_fill_fieldcat USING 'KWMENG'(016)
                                ''
                                'VRKME'(048)
                                'I_FINAL'(013)
                                'Order Qty'(036)
                                 13
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                 14
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 13
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 c_left
                                 'QUAN'(075)
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014


    PERFORM f_fill_fieldcat USING 'WADAT_IST'(021)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Actual PGI Date'(008)
                                   10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   15
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   14
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_true.

  ELSE. " ELSE -> IF cb_hist = abap_false

    PERFORM f_fill_fieldcat USING 'KUNNR'(057)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Customer No.'(064)
                                   10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   9
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   8
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
                                   abap_false.


    PERFORM f_fill_fieldcat USING 'NAME1'(018)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Cust. Description'(005)
                                   8
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   10
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   9
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
                                   abap_false.

**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
    PERFORM f_fill_fieldcat USING 'SHIPTO'(025)
                                 ''
                                 ''
                                 'I_FINAL'(013)
                                 'Ship-to No.'(011)
                                  10
                                  10
                                  c_left
                                  ''
                                  abap_false.
    PERFORM f_fill_fieldcat USING 'DESCRIPTION'(002)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Ship-to Description'(047)
                                 8
                                 11
                                 c_left
                                 ''
                                 abap_false.
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014

    PERFORM f_fill_fieldcat USING 'BSTKD'(022)
                                   ''
                                   ''
                                   'I_FINAL'(013)
                                   'PO No.'(009)
                                    10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                    11
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                    12
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                    c_left
                                    ''
                                    abap_false.




    PERFORM f_fill_fieldcat USING 'VBELN'(019)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Sales Order'(006)
                                   10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   12
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   13
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
                                   abap_false.




    PERFORM f_fill_fieldcat USING 'AUDAT'(020)
                                    ''
                                    ''
                                    'I_FINAL'(013)
                                    'SO Date'(007)
                                     10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                     13
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                     14
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                     c_left
                                     ''
                                     abap_false.



    PERFORM f_fill_fieldcat USING 'KWMENG'(016)
                                ''
                                'VRKME'(048)
                                'I_FINAL'(013)
                                'Order Qty'(036)
                                 13
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                 14
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 15
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 c_left
                                 'QUAN'(075)
                                 abap_false.

    PERFORM f_fill_fieldcat USING 'WADAT_IST'(021)
                                    ''
                                    ''
                                    'I_FINAL'(013)
                                    'Actual PGI Date'(008)
                                     10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                     15
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                     16
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                     c_left
                                     ''
                                     abap_false.

  ENDIF. " IF cb_hist = abap_false
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'HSDAT'(045)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'Mfg Date'(035)
                                   10
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   16
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   17
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'VRKME'(048)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'UOM'(038)
                                   5
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   17
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   18
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'NETWR'(049)
                                'WAERS'(077)
                                ''
                                'I_FINAL'(013)
                                'USD/UoM'(039)
                                 12
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                 18
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 19
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 c_left
                                 'CURR'(076)
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014



  PERFORM f_fill_fieldcat USING 'WERKS'(051)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Plant'(041)
                                 5
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                 19
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 20
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 c_left
                                 ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'ATNAM'(046)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Description'(047)
                                 15
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                 20
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 21
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 c_left
                                 ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'EC_CODE'(056)
                                  ''
                                  ''
                                  'I_FINAL'(013)
                                  'EC Code'(058)
                                   15
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                   21
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   22
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                   c_left
                                   ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                   abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

  PERFORM f_fill_fieldcat USING 'WARNING'(059)
                                ''
                                ''
                                'I_FINAL'(013)
                                'Warning'(060)
                                 15
**&& -- Begin of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
*                                 22
**&& -- End of Delete: CR #1286 : SPAUL2 : 16-SEP-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 23
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
                                 c_left
                                 ''
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
                                 abap_false.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014
**&& -- Begin of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
  PERFORM f_fill_fieldcat USING 'CLABS'(050)
                               ''
                               'VRKME'(048)
                               'I_FINAL'(013)
                               'Unrest.Stock'(040)
                                10
                                24
                                c_left
                                'QUAN'(075)
                                abap_false.
**&& -- End of Insert: CR #1286 : SPAUL2 : 16-SEP-2014
ENDFORM. " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*      Subroutine for filling field catalog
*----------------------------------------------------------------------*
*  -->  FP_FIELDNAME    Field Name
*  -->  FP_TABNAME      Table Name
*  -->  FP_SELTEXT      Column Header
*  -->  fp_collength    column length
*  -->  fp_col_pos     column position
*  -->  fp_just         justification
*----------------------------------------------------------------------*
FORM f_fill_fieldcat USING fp_fieldname  TYPE slis_fieldname
                           fp_cfieldname TYPE slis_fieldname
                           fp_qfieldname TYPE slis_fieldname
                           fp_tabname    TYPE slis_tabname
                           fp_seltext    TYPE scrtext_l " Long Field Label
                           fp_collength  TYPE outputlen " Output Length
                           fp_col_pos    TYPE sycucol   " Horizontal Cursor Position at PAI
                           fp_just       TYPE just      " Justification: 'R'ight, 'L'eft, 'C'entered
                           fp_datatype   TYPE datatype_d
                           fp_no_out     TYPE char1.    " No_out of type CHAR1


  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname  = fp_fieldname.
  wa_fieldcat-cfieldname = fp_cfieldname.
  wa_fieldcat-qfieldname = fp_qfieldname.
  wa_fieldcat-tabname    = fp_tabname.
  wa_fieldcat-outputlen  = fp_collength.
  wa_fieldcat-seltext_l  = fp_seltext.
  wa_fieldcat-col_pos    = fp_col_pos.
  wa_fieldcat-just       = fp_just.
  wa_fieldcat-datatype   = fp_datatype.
  wa_fieldcat-no_out     = fp_no_out.


  APPEND wa_fieldcat TO i_fieldcat.
  CLEAR: wa_fieldcat.

ENDFORM. " F_FILL_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Subroutine for header display
*----------------------------------------------------------------------*
FORM f_top_of_page . "#EC CALLED

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = i_listheader.

ENDFORM. " F_TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  F_MAT_VALIDATION
*&---------------------------------------------------------------------*
*   Subroutine for validation of Material entered
*----------------------------------------------------------------------*
FORM f_mat_validation.
*Local data
  DATA lv_matnr TYPE matnr. " Material Number

* Validation for Material
  SELECT matnr UP TO 1 ROWS
    INTO lv_matnr
    FROM mara " General Material Data
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
*      WHERE matnr = p_matnr.
WHERE matnr IN s_matnr.
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
  ENDSELECT.
  IF sy-subrc NE 0 OR
     lv_matnr IS INITIAL.
    MESSAGE e113 WITH 'Material'(004).

  ENDIF. " IF sy-subrc NE 0 OR
ENDFORM. " F_MAT_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_CHARG_VALIDATION
*&---------------------------------------------------------------------*
*   Subroutine for validation of Batch entered                         *
*----------------------------------------------------------------------*
FORM f_charg_validation.

*Local Variable declaration
  DATA: lv_charg TYPE charg_d. "Batch

* Validation for Batch
  SELECT charg UP TO 1 ROWS
    INTO lv_charg
    FROM mch1 " Batches (if Batch Management Cross-Plant)
    WHERE charg IN s_charg.
  ENDSELECT.
  IF sy-subrc NE 0 OR
     lv_charg IS INITIAL.
    MESSAGE e113 WITH 'Batch'(012).

  ENDIF. " IF sy-subrc NE 0 OR
ENDFORM. " F_CHARG_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_SCREEN_DEFAULTS
*&---------------------------------------------------------------------*
*       Subroutine to get the previous month date
*----------------------------------------------------------------------*
FORM f_screen_defaults .

*Local Data
  DATA : lwa_date LIKE LINE OF s_date. "Local work area for s_date

  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
    EXPORTING
      currdate   = sy-datum
      backmonths = c_12
    IMPORTING
      newdate    = gv_date.

  lwa_date-low = gv_date.
  lwa_date-high = sy-datum.
  lwa_date-sign = c_sign.
  lwa_date-option = c_option.
  APPEND lwa_date TO s_date.
  CLEAR lwa_date.
ENDFORM. " F_SCREEN_DEFAULTS
*&---------------------------------------------------------------------*
*&      Form  F_KUNNR_VALIDATION
*&---------------------------------------------------------------------*
*   Subroutine for validation of customer Number entered
*----------------------------------------------------------------------*

FORM f_kunnr_validation .
*Local data
  DATA lv_kunnr TYPE kunnr. " Customer Number

* Validation for Customer no
  SELECT kunnr UP TO 1 ROWS
    INTO lv_kunnr
    FROM kna1 " General Data in Customer Master
    WHERE kunnr IN s_kunnr.
  ENDSELECT.
  IF sy-subrc NE 0 OR
     lv_kunnr IS INITIAL.
    MESSAGE e113 WITH 'Customer No.'(064).
  ENDIF. " IF sy-subrc NE 0 OR
ENDFORM. " F_KUNNR_VALIDATION
*&---------------------------------------------------------------------*
*&      Form  F_FILL_FINAL_TAB
*&---------------------------------------------------------------------*
*       Subroutine to fill final internal table
*----------------------------------------------------------------------*
FORM f_fill_final_tab .

  TYPES: BEGIN OF lty_mseg,
           mblnr TYPE mblnr,    " Number of Material Document
           mjahr TYPE mjahr,    " Material Document Year
           zeile TYPE mblpo,    " Item in Material Document
           matnr TYPE matnr,    " Material Number
           werks TYPE werks_d,  " Plant
           charg TYPE charg_d,  " Batch Number
         END OF   lty_mseg,

         BEGIN OF lty_ec_code,
           matnr TYPE matnr,    " Material Number
           werks TYPE werks_d,  " Plant
           charg TYPE charg_d,  " Batch Number
           atwrt TYPE atwrt,    " Characteristic Value
           ec_code TYPE char50, " Code of type CHAR50
         END OF   lty_ec_code.

*Local Data
  DATA : lwa_final   TYPE ty_final,                                  "Work area for Final table
         lwa_ec_code TYPE lty_ec_code,                               "Workarea for EC Code
         li_ec_code  TYPE STANDARD TABLE OF lty_ec_code,             " Table for EC Code
         lv_atzhl    TYPE atzhl,                                     "Local variable for atzhl
         lv_atwrt    TYPE string,                                    "Local variable for atwrt
         lv_string   TYPE string,                                    "Locl variable for string
         lv_kunnr    TYPE kunnr,                                     "Local variable for kunnr
         lv_tabix    TYPE sytabix,                                   "Index to start the loop
         li_class    TYPE STANDARD TABLE OF sclass INITIAL SIZE 0,   " Reference Structure: Class Data
                                                                     "Table for class type
         li_clobjdat TYPE STANDARD TABLE OF clobjdat INITIAL SIZE 0, " Reference structure: Classification data per object
                                                                     "Table for data object
         lwa_batch    TYPE ty_batch,                                 "Work area for Batch
         lwa_vbfa     TYPE ty_vbfa,                                  " Work area for Vbfa
*         lwa_vbap_batch TYPE ty_vbap,      "Defect#2164 "Not used anywhere in subroutine.
         lv_clabs     TYPE i, "Local variable for clabs
         lv_kwmeng    TYPE i, "Local variable for kwmeng
         lv_netwr     TYPE i, "Local variable for netwr
*         lv_ec_code   TYPE sytabix,      "Defect#2164 "Not used anywhere in subroutine.
         lv_atnam     TYPE atnam, " Characteristic Name
*         lv_flag_exist TYPE flag,        "Defect#2164 "Not used anywhere in subroutine.
         lv_string1    TYPE atwrt,   " Characteristic Value
         lv_string2    TYPE atwrt,   " Characteristic Value
         lv_ec_code_char TYPE string,
         lv_index      TYPE syindex, " Loop Index
         li_mseg      TYPE STANDARD TABLE OF lty_mseg.

  FIELD-SYMBOLS :   <lfs_ausp>      TYPE ty_ausp,  " Field Symbol for ausp
                    <lfs_cabn>      TYPE ty_cabn,  " Field Symbol for Cabn
                    <lfs_cabnt>     TYPE ty_cabnt, " Field Symbol for Cabnt
                    <lfs_mchb>      TYPE ty_mchb,  " Field Symbol for Mchb
                    <lfs_vbap>      TYPE ty_vbap,  " Field symbol for Vbap
                    <lfs_vapma>     TYPE ty_vapma, " Field Symbol for Vapma
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
                    <lfs_vbpa>      TYPE ty_vbpa, " Field Symbol for Vbpa
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014
                    <lfs_lips>      TYPE ty_lips,  " Field Symbol for Lips
                    <lfs_kna1>      TYPE ty_kna1,  " Field Symbol for Kna1
                    <lfs_vbkd>      TYPE ty_vbkd,  " Field Symbol for Vbkd
                    <lfs_likp>      TYPE ty_likp,  " Field Symbol for Likp
                    <lfs_mch1>      TYPE ty_mch1,  " Field Symbol for Mch1
                    <lfs_cawnt>     TYPE ty_cawnt, " Field Synbol for CAWNT
                    <lfs_inob>      TYPE ty_inob,  " Field Symbol for INOB
                    <lfs_object>    TYPE clobjdat, " Field Symbol for clobjdat
                    <lfs_makt>      TYPE ty_makt,  "Field Symbol for makt
                    <lfs_final>     TYPE ty_final, "Field Symbol for final
                    <lfs_ec_code>   TYPE lty_ec_code,
                    <lfs_ec_code_1> TYPE lty_ec_code.
*                    <lfs_final_tmp> TYPE ty_final.    "Defect#2164 "Not used anywhere in subroutine.

  CONSTANTS: lc_comma TYPE char1 VALUE ','. " Comma of type CHAR1


*Populating the string variable
  lv_string  = ( '0123456789').

  LOOP AT i_batch INTO lwa_batch.

*Populating characteristic
    lwa_final-atinn     = lwa_batch-ccode.
    lwa_final-matnr     = lwa_batch-matnr2.

    IF lwa_batch-matnr2 = lwa_batch-matnr.
      CLEAR: lwa_final-matnr_p.
    ELSE. " ELSE -> IF lwa_batch-matnr2 = lwa_batch-matnr
      lwa_final-matnr_p     = lwa_batch-matnr.
    ENDIF. " IF lwa_batch-matnr2 = lwa_batch-matnr

*Populating material description

    READ TABLE i_makt ASSIGNING <lfs_makt> WITH KEY matnr = lwa_final-matnr
*                                                    spras = sy-langu   "Commented for Defect#2164
                                                    BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-posnr = <lfs_makt>-maktx.
    ENDIF. " IF sy-subrc = 0
*Poplulating Characteristic Name from CABN
    READ TABLE i_cabn ASSIGNING <lfs_cabn> WITH KEY atinn = lwa_final-atinn
                                            BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-atnam1 = <lfs_cabn>-atnam.
    ENDIF. " IF sy-subrc = 0

*Populating characteristics description
    READ TABLE i_cabnt ASSIGNING <lfs_cabnt> WITH KEY atinn = lwa_final-atinn
*                                                      spras = sy-langu  "Commented for Defect#2164
                                              BINARY SEARCH.
    IF sy-subrc = 0.
      lwa_final-atnam = <lfs_cabnt>-atbez.
    ENDIF. " IF sy-subrc = 0
*Populating Product Group

    READ TABLE i_ausp_1 ASSIGNING <lfs_ausp> WITH KEY objek = lwa_batch-matnr2
                                                    atinn = gv_atinn
                                                    BINARY SEARCH.
    IF sy-subrc = 0.
      READ TABLE i_cabn ASSIGNING <lfs_cabn> WITH KEY atinn = <lfs_ausp>-atinn
                                          BINARY SEARCH.
      IF sy-subrc = 0.
*If atfor is character
        IF <lfs_cabn>-atfor = c_atfor.
          lwa_final-atwrt     = <lfs_ausp>-atwrt.

        ELSE. " ELSE -> IF <lfs_cabn>-atfor = c_atfor
*If atfor is other than character
          lwa_final-atwrt     = <lfs_ausp>-atflv.
        ENDIF. " IF <lfs_cabn>-atfor = c_atfor
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0
*Populating Product Group Description
    IF lwa_final-atwrt IS NOT INITIAL.
      lv_atwrt = lwa_final-atwrt.
      CONDENSE lv_atwrt.
      IF  lv_atwrt CO lv_string.
        lv_atzhl = lwa_final-atwrt - 9.

        READ TABLE i_cawnt ASSIGNING <lfs_cawnt> WITH KEY atinn = gv_atinn
                                                          atzhl = lv_atzhl
                                                          BINARY SEARCH.
        IF sy-subrc = 0.
          lwa_final-atwrt_dec = <lfs_cawnt>-atwtb.
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lv_atwrt CO lv_string
    ENDIF. " IF lwa_final-atwrt IS NOT INITIAL

    READ TABLE i_mch1 TRANSPORTING NO FIELDS
                                       WITH KEY matnr = lwa_final-matnr
                                       BINARY SEARCH.
    IF sy-subrc NE 0.
*     BOC ADD ADAS1 Defect 1165
      IF s_charg[] IS INITIAL.
        APPEND lwa_final TO i_final.
      ENDIF. " IF s_charg[] IS INITIAL
*     EOC ADD ADAS1 Defect 1165

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
    ELSE. " ELSE -> IF s_charg[] IS INITIAL
      lv_tabix = sy-tabix.
*&--EOC ADD Defect#2164 RVERMA 12/17/201
    ENDIF. " IF sy-subrc NE 0

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
*    LOOP AT i_mch1 ASSIGNING <lfs_mch1> WHERE matnr = lwa_final-matnr.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/201

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
    LOOP AT i_mch1 ASSIGNING <lfs_mch1> FROM lv_tabix.

      IF <lfs_mch1>-matnr NE lwa_final-matnr.
        EXIT.
      ENDIF. " IF <lfs_mch1>-matnr NE lwa_final-matnr
*&--EOC ADD Defect#2164 RVERMA 12/17/201

      lwa_final-charg = <lfs_mch1>-charg.
      lwa_final-cuobj_bm = <lfs_mch1>-cuobj_bm.
      lwa_final-hsdat    = <lfs_mch1>-hsdat. " Mfg Date
      lwa_final-vfdat    = <lfs_mch1>-vfdat.

      IF lwa_final-charg IS NOT INITIAL.
*Populating Compatibilty code
        READ TABLE i_inob ASSIGNING <lfs_inob> WITH KEY cuobj = lwa_final-cuobj_bm
                                               BINARY SEARCH.
        IF sy-subrc = 0.

          CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
            EXPORTING
              class              = ' '      "  class
              classtext          = 'X'
              classtype          = <lfs_inob>-klart
              clint              = 0
              features           = 'X'
              language           = sy-langu
              object             = <lfs_inob>-objek
              objecttable        = <lfs_inob>-obtab
              key_date           = sy-datum
              initial_charact    = 'X'
              change_service_clf = 'X'
              inherited_char     = ' '
              change_number      = ' '
            TABLES
              t_class            = li_class "  class
              t_objectdata       = li_clobjdat
            EXCEPTIONS
              no_classification  = 1
              no_classtypes      = 2
              invalid_class_type = 3
              OTHERS             = 4.

          IF sy-subrc = 0.
*Grt the value of compatibilty code using the objectdata table
*Sort is done inside the loop as the table li_clobjdat is populated inside the loop
**            SORT li_clobjdat BY atnam.

*            BOC DEL ADAS1 Defect 1403
*            READ TABLE li_clobjdat ASSIGNING <lfs_object> WITH KEY atnam = lwa_final-atnam1
*                                                                   BINARY SEARCH.
*            IF sy-subrc = 0.
*              lwa_final-atwrt_m = <lfs_object>-ausp1.
*            ENDIF.
*            EOC DEL ADAS1 Defect 1403

*            BOC ADD ADAS1 Defect 1403
            CLEAR: lv_index.
            LOOP AT li_clobjdat ASSIGNING <lfs_object>
                                WHERE atnam = lwa_final-atnam1.

              lv_index = lv_index + 1.
              IF lv_index = 1.
                MOVE <lfs_object>-ausp1 TO lwa_final-atwrt_m.
              ELSE. " ELSE -> IF lv_index = 1
                CONCATENATE lwa_final-atwrt_m lc_comma
                            <lfs_object>-ausp1
                            INTO lwa_final-atwrt_m.
              ENDIF. " IF lv_index = 1
            ENDLOOP. " LOOP AT li_clobjdat ASSIGNING <lfs_object>
*            EOC ADD ADAS1 Defect 1403
          ENDIF. " IF sy-subrc = 0
        ENDIF. " IF sy-subrc = 0
      ENDIF. " IF lwa_final-charg IS NOT INITIAL

      READ TABLE i_mchb ASSIGNING <lfs_mchb> WITH KEY matnr = <lfs_mch1>-matnr
                                                      charg = <lfs_mch1>-charg
                                                     BINARY SEARCH.
      IF sy-subrc = 0.
*Convert into integer
        lv_clabs  = <lfs_mchb>-clabs.
        lwa_final-clabs  =   lv_clabs.
        lwa_final-werks  = <lfs_mchb>-werks.
      ENDIF. " IF sy-subrc = 0
      READ TABLE i_vbap_tmp TRANSPORTING NO FIELDS
                 WITH KEY matnr = lwa_final-matnr
                 BINARY SEARCH.
      IF sy-subrc NE 0.
        APPEND lwa_final TO i_final.

*      BOC ADD ADAS1 Defect 1165
      ELSE. " ELSE -> IF sy-subrc NE 0

*        CLEAR: lwa_vbap_batch. "Defect#2164 "Not used anywhere in subroutine.
        READ TABLE i_vbap TRANSPORTING NO FIELDS
                   WITH KEY matnr = lwa_final-matnr.
        IF sy-subrc = 0.
          READ TABLE i_vbap TRANSPORTING NO FIELDS
               WITH KEY matnr = lwa_final-matnr
                        charg = <lfs_mch1>-charg.
          IF sy-subrc <> 0.
            APPEND lwa_final TO i_final.
          ENDIF. " IF sy-subrc <> 0
        ENDIF. " IF sy-subrc = 0
*      EOC ADD ADAS1 Defect 1165

      ENDIF. " IF sy-subrc NE 0
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
      IF  cb_hist = abap_true.
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

*   Populating Inventory Data from Mchb
        LOOP AT i_vbap ASSIGNING <lfs_vbap> WHERE matnr = lwa_final-matnr
*      BOC ADD ADAS1 Defect 1165
                                              AND charg = <lfs_mch1>-charg.
*      EOC ADD ADAS1 Defect 1165

          lwa_final-charg = <lfs_mch1>-charg.
          lwa_final-vbeln  = <lfs_vbap>-vbeln.
*Convert into integer
          lv_kwmeng = <lfs_vbap>-kwmeng.
          lwa_final-kwmeng = lv_kwmeng.
*Convert into integer
          lv_netwr = <lfs_vbap>-netwr.
          lwa_final-netwr  = lv_netwr.
          lwa_final-waers  = <lfs_vbap>-waerk.
          lwa_final-vrkme  = <lfs_vbap>-vrkme.

          READ TABLE i_vapma  ASSIGNING <lfs_vapma> WITH KEY vbeln  = <lfs_vbap>-vbeln
                                                     BINARY SEARCH.

          IF sy-subrc = 0.

            lwa_final-audat = <lfs_vapma>-audat.

            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
              EXPORTING
                input  = <lfs_vapma>-kunnr
              IMPORTING
                output = lv_kunnr.

            lwa_final-kunnr0 = <lfs_vapma>-kunnr.
            lwa_final-kunnr = lv_kunnr.
          ENDIF. " IF sy-subrc = 0
*Populating preceding sales and distribution document
          READ TABLE i_vbfa INTO lwa_vbfa WITH KEY vbelv = <lfs_vbap>-vbeln
                                                    posnv = <lfs_vbap>-posnr
                                                   BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_final-vbelv = lwa_vbfa-vbeln.
          ENDIF. " IF sy-subrc = 0

*Populating batch number
          IF lwa_final-charg IS INITIAL.
            READ TABLE i_lips ASSIGNING <lfs_lips> WITH KEY vbeln = lwa_vbfa-vbeln
                                                            posnr = lwa_vbfa-posnv
                                                        BINARY SEARCH.
            IF sy-subrc = 0.
              lwa_final-charg = <lfs_lips>-charg.
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF lwa_final-charg IS INITIAL


*Populating Customer PO No.
          READ TABLE i_vbkd ASSIGNING <lfs_vbkd> WITH KEY vbeln = <lfs_vbap>-vbeln
                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_final-bstkd = <lfs_vbkd>-bstkd.
          ENDIF. " IF sy-subrc = 0

*Populating Customer name
**&& -- Begin of insert: CR #1286 : SPAUL2 : 16-SEP-2014
          READ TABLE i_vbpa ASSIGNING <lfs_vbpa> WITH KEY vbeln = <lfs_vapma>-vbeln
                                                          BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_final-shipto = <lfs_vbpa>-kunnr. "Ship-to
            SHIFT lwa_final-shipto LEFT DELETING LEADING c_zero.
            READ TABLE i_kna1 ASSIGNING <lfs_kna1> WITH KEY kunnr = <lfs_vbpa>-kunnr
                                                    BINARY SEARCH.
            IF sy-subrc = 0.
              lwa_final-description = <lfs_kna1>-name1. "Ship-to description
            ENDIF. " IF sy-subrc = 0
          ENDIF. " IF sy-subrc = 0
**&& -- End of insert: CR #1286 : SPAUL2 : 16-SEP-2014
          READ TABLE i_kna1 ASSIGNING <lfs_kna1> WITH KEY kunnr = <lfs_vapma>-kunnr
                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_final-name1 = <lfs_kna1>-name1.
          ENDIF. " IF sy-subrc = 0

*Populating  Actual Goods Movement Date
          READ TABLE i_likp ASSIGNING <lfs_likp> WITH KEY vbeln = lwa_final-vbelv
                                                  BINARY SEARCH.
          IF sy-subrc = 0.
            lwa_final-wadat_ist = <lfs_likp>-wadat_ist.
          ENDIF. " IF sy-subrc = 0

*Appending into final internal table
          APPEND lwa_final TO i_final.
          CLEAR: lwa_final-vbeln,
                 lwa_final-kwmeng,
                 lwa_final-netwr,
                 lwa_final-waers,
                 lwa_final-vrkme,
                 lwa_final-audat,
                 lwa_final-kunnr0,
                 lwa_final-kunnr,
                 lwa_final-vbelv,
                 lwa_final-charg,
                 lwa_final-bstkd,
                 lwa_final-name1,
                 lwa_final-wadat_ist.
          CLEAR lwa_vbfa.
        ENDLOOP. " LOOP AT i_vbap ASSIGNING <lfs_vbap> WHERE matnr = lwa_final-matnr
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
      ENDIF. " IF cb_hist = abap_true
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014

      CLEAR: lwa_final-charg,
             lwa_final-cuobj_bm,
             lwa_final-hsdat,
             lwa_final-vfdat,
             lwa_final-atwrt_m,
             lwa_final-clabs,
             lwa_final-werks.
    ENDLOOP. " LOOP AT i_mch1 ASSIGNING <lfs_mch1> FROM lv_tabix
    CLEAR : lwa_final,
            lv_tabix,
            lwa_batch.
  ENDLOOP. " LOOP AT i_batch INTO lwa_batch

*Populating EC code

  i_final_tmp1[] = i_final[].
  SORT i_final_tmp1 BY matnr werks charg.
  DELETE ADJACENT DUPLICATES FROM i_final_tmp1 COMPARING matnr werks charg.
  IF NOT i_final_tmp1 IS INITIAL.
    SELECT mblnr     " Number of Material Document
           mjahr     " Material Document Year
           zeile     " Item in Material Document
           matnr     " Material Number
           werks     " Plant
           charg     " Batch Number
           FROM mseg " Document Segment: Material
           INTO TABLE li_mseg
           FOR ALL ENTRIES IN i_final_tmp1
           WHERE matnr = i_final_tmp1-matnr
             AND werks = i_final_tmp1-werks
             AND charg = i_final_tmp1-charg.
    IF sy-subrc = 0.
      SORT li_mseg BY matnr werks charg.
    ENDIF. " IF sy-subrc = 0
  ENDIF. " IF NOT i_final_tmp1 IS INITIAL
*  DELETE i_final_tmp1 WHERE atwrt_m = space.

* BOC ADD ADAS1 08/24/2012
*  i_final_tmp2[] = i_final[].
*  SORT i_final_tmp2 BY matnr_p.

  IF i_final IS NOT INITIAL.
*    SORT i_final.
*    DELETE ADJACENT DUPLICATES FROM i_final COMPARING ALL FIELDS.
*    SORT i_final BY matnr charg werks.

*     BOC ADD ADAS1 Defect 1107
**&& --  BOC : CR# 1286 : SPAUL2 : 19-JAN-2015
*    IF cb_invt = space.
*    DELETE i_final WHERE clabs IS INITIAL.
*    ENDIF.
**&& --  EOC : CR# 1286 : SPAUL2 : 19-JAN-2015

    IF NOT s_kunnr[] IS INITIAL.
      s_kunnr-sign = 'I'.
      s_kunnr-option = 'EQ'.
      s_kunnr-low = space.
      APPEND s_kunnr.
      DELETE i_final WHERE kunnr0 NOT IN s_kunnr[].
    ENDIF. " IF NOT s_kunnr[] IS INITIAL
*     EOC ADD ADAS1 Defect 1107
  ENDIF. " IF i_final IS NOT INITIAL

  SORT i_final BY atinn atwrt_m.

*** Ecc code = 1
**  lv_ec_code = lv_ec_code + 1.
**
**  UNASSIGN: <lfs_final>.
**  LOOP AT i_final ASSIGNING <lfs_final>.
**
***  Get Characteric name from number
**    CLEAR: lv_atnam.
**    CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
**      EXPORTING
**        input  = <lfs_final>-atinn
**      IMPORTING
**        output = lv_atnam.
**
***   For Characteristic name 'DC_CODE', find the match based on
***   batch and compatibility code
**    IF lv_atnam = 'DC_CODE' AND NOT <lfs_final>-charg IS INITIAL
**                            AND NOT <lfs_final>-atwrt_m IS INITIAL .
**
***     Nested loop for 'DC_CODE'
**      LOOP AT i_final ASSIGNING <lfs_final_tmp>
**                      WHERE atinn = <lfs_final>-atinn.
**
***     Multiple compatibility codes values can be maintained. so within Do loop
***     each compatibility codes are matched separately
**        CLEAR: lv_string1,
**               lv_string2,
**               lv_index.
**        MOVE <lfs_final_tmp>-atwrt_m TO lv_string2.
**        DO.
**
**          lv_index = lv_index + 1.
***       Get compatibility code values
**          SPLIT lv_string2 AT ',' INTO lv_string1 lv_string2.
**          CONDENSE lv_string1 NO-GAPS.
**          CONDENSE lv_string2 NO-GAPS.
**
***         if batch and compatibility code matches, assign ec_code
**          IF <lfs_final>-charg = lv_string1.
**
**            IF lv_index = 1.
**              IF ( NOT <lfs_final>-ec_code IS INITIAL AND
**                 NOT <lfs_final_tmp>-ec_code IS INITIAL ) AND
**               <lfs_final>-ec_code = <lfs_final_tmp>-ec_code.
**                EXIT.
**              ENDIF.
**            ENDIF.
**
***           Convert EC_code as a character field
**            CLEAR: lv_ec_code_char.
**            MOVE lv_ec_code TO lv_ec_code_char.
**            CONDENSE lv_ec_code_char NO-GAPS.
**
***           If the particular EC_Code is not assigned yet,
***           then only assign the same for the batches i.e. in the first loop
**            IF <lfs_final>-ec_code NA lv_ec_code_char.
***             For the first value, directly populate the value
**              IF <lfs_final>-ec_code IS INITIAL.
**                MOVE lv_ec_code_char TO <lfs_final>-ec_code.
**              ELSE.
***               From the 2nd onwards, concatenate with the first value
**                CONCATENATE <lfs_final>-ec_code lv_ec_code_char
**                            INTO <lfs_final>-ec_code
**                            SEPARATED BY lc_comma.
**              ENDIF. " IF <lfs_final>-ec_code IS INITIAL.
**            ENDIF. " IF <lfs_final>-ec_code NA lv_ec_code_char.
**
***           If the particular EC_Code is not assigned yet,
***           then only assign the same for the compatibility code
***           i.e. in the second loop
**            IF <lfs_final_tmp>-ec_code NA lv_ec_code_char.
***             For the first value, directly populate the value
**              IF <lfs_final_tmp>-ec_code IS INITIAL.
**                MOVE lv_ec_code_char TO <lfs_final_tmp>-ec_code.
**              ELSE.
***               From the 2nd onwards, concatenate with the first value
**                CONCATENATE <lfs_final_tmp>-ec_code lv_ec_code_char
**                            INTO <lfs_final_tmp>-ec_code
**                            SEPARATED BY lc_comma.
**              ENDIF. " IF <lfs_final_tmp>-ec_code IS INITIAL.
**            ENDIF. " IF <lfs_final_tmp>-ec_code NA lv_ec_code_char.
**            lv_flag_exist = 'X'.
**
**          ENDIF. " IF <lfs_final>-charg = lv_string1.
**
***         If no more compatibility code, exit from Do loop.
**          IF lv_string2 IS INITIAL.
**            EXIT.
**          ENDIF.
**
**        ENDDO.
**      ENDLOOP. " LOOP AT i_final ASSIGNING <lfs_final_tmp>
**
**    ENDIF. " IF lv_atnam = 'DC_CODE' AND NOT <lfs_final>-charg IS INITIAL
**    " AND NOT <lfs_final>-atwrt_m IS INITIAL .
**
***   Populate Warning
**    READ TABLE li_mseg TRANSPORTING NO FIELDS
**         WITH KEY matnr = <lfs_final>-matnr
**                  werks = <lfs_final>-werks
**                  charg = <lfs_final>-charg
**                  BINARY SEARCH.
**    IF sy-subrc <> 0.
**      <lfs_final>-warning = 'FUTURE'.
**    ENDIF.
**
***   If EC_CODE assigned, increse the EC_CODE by 1
**    IF lv_flag_exist = 'X'.
**      lv_ec_code = lv_ec_code + 1.
**      CLEAR: lv_flag_exist.
**    ENDIF.
**  ENDLOOP.


* BOC ADD ADAS1 CR 153
  UNASSIGN: <lfs_final>.
  LOOP AT i_final ASSIGNING <lfs_final>.

*  Get Characteric name from number
    CLEAR: lv_atnam.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
      EXPORTING
        input  = <lfs_final>-atinn
      IMPORTING
        output = lv_atnam.

*   For Characteristic name 'DC_CODE', find the match based on
*   batch and compatibility code
    IF lv_atnam = 'DC_CODE' AND NOT <lfs_final>-charg IS INITIAL
                            AND NOT <lfs_final>-atwrt_m IS INITIAL .

*     Multiple compatibility codes values can be maintained. so within Do loop
*     each compatibility codes are matched separately
      CLEAR: lv_string1,
             lv_string2,
             lv_index.
      MOVE <lfs_final>-atwrt_m TO lv_string2.
      DO.

*       Get compatibility code values
        SPLIT lv_string2 AT ',' INTO lv_string1 lv_string2.
        CONDENSE lv_string1 NO-GAPS.
        CONDENSE lv_string2 NO-GAPS.

*       Create another internal table to populate EC Code
        CLEAR: lwa_ec_code.
        lwa_ec_code-matnr = <lfs_final>-matnr.
        lwa_ec_code-werks = <lfs_final>-werks.
        lwa_ec_code-charg = <lfs_final>-charg.
        lwa_ec_code-atwrt = lv_string1.
        APPEND lwa_ec_code TO li_ec_code.

*         If no more compatibility code, exit from Do loop.
        IF lv_string2 IS INITIAL.
          EXIT.
        ENDIF. " IF lv_string2 IS INITIAL

      ENDDO.
    ENDIF. " IF lv_atnam = 'DC_CODE' AND NOT <lfs_final>-charg IS INITIAL

*   Populate Warning
    READ TABLE li_mseg TRANSPORTING NO FIELDS
         WITH KEY matnr = <lfs_final>-matnr
                  werks = <lfs_final>-werks
                  charg = <lfs_final>-charg
                  BINARY SEARCH.
    IF sy-subrc <> 0.
      <lfs_final>-warning = 'FUTURE'.
    ENDIF. " IF sy-subrc <> 0
  ENDLOOP. " LOOP AT i_final ASSIGNING <lfs_final>

* Get the Matching codes
  SORT li_ec_code BY charg.
  LOOP AT li_ec_code ASSIGNING  <lfs_ec_code>.

*   Match criss-cross i.e. compatibility code for 1st and batch of teh 2nd
*   and vice versa
    READ TABLE li_ec_code ASSIGNING <lfs_ec_code_1>
               WITH KEY charg = <lfs_ec_code>-atwrt
                        atwrt = <lfs_ec_code>-charg.
    IF sy-subrc = 0.

*     If EC Code is yet not assigned, assign the EC Code for both of the matching rows
      IF <lfs_ec_code_1>-ec_code IS INITIAL OR
         <lfs_ec_code>-ec_code   IS INITIAL.

        lv_index = lv_index + 1.
        IF <lfs_ec_code>-ec_code IS INITIAL.
          <lfs_ec_code>-ec_code = lv_index.
        ENDIF. " IF <lfs_ec_code>-ec_code IS INITIAL

        IF <lfs_ec_code_1>-ec_code IS INITIAL.
          <lfs_ec_code_1>-ec_code = lv_index.
        ENDIF. " IF <lfs_ec_code_1>-ec_code IS INITIAL
      ENDIF. " IF <lfs_ec_code_1>-ec_code IS INITIAL OR
           "    <lfs_ec_code>-ec_code   IS INITIAL.

    ENDIF. " IF sy-subrc = 0

  ENDLOOP. " LOOP AT li_ec_code ASSIGNING <lfs_ec_code>

* Deleteing the table where EC_Code is not found
  DELETE li_ec_code WHERE ec_code IS INITIAL.

*  Get Characteric name from number
  CLEAR: lv_index.
  LOOP AT i_final ASSIGNING <lfs_final>.
    CLEAR: lv_atnam.
    CALL FUNCTION 'CONVERSION_EXIT_ATINN_OUTPUT'
      EXPORTING
        input  = <lfs_final>-atinn
      IMPORTING
        output = lv_atnam.

*   For Characteristic name 'DC_CODE', find the match based on
*   batch and compatibility code
    IF lv_atnam = 'DC_CODE' AND NOT <lfs_final>-charg IS INITIAL
                            AND NOT <lfs_final>-atwrt_m IS INITIAL .

*     Match the entries for EC Code
      LOOP AT li_ec_code INTO lwa_ec_code
           WHERE matnr = <lfs_final>-matnr
             AND werks = <lfs_final>-werks
             AND charg = <lfs_final>-charg.

*       Increase the number of iterations
        lv_index = lv_index + 1.

*       Convert EC_code as a character field
        CLEAR: lv_ec_code_char.
        MOVE lwa_ec_code-ec_code  TO lv_ec_code_char.
        CONDENSE lv_ec_code_char NO-GAPS.

*       For the first iteration, directly pass the field to populate the final table
        IF lv_index = 1.
          MOVE lv_ec_code_char TO <lfs_final>-ec_code.
        ELSE. " ELSE -> IF lv_index = 1
*         From the 2nd onwards, concatenate with the first value
          CONCATENATE <lfs_final>-ec_code lv_ec_code_char
                      INTO <lfs_final>-ec_code
                      SEPARATED BY lc_comma.
        ENDIF. " IF lv_index = 1

      ENDLOOP. " LOOP AT li_ec_code INTO lwa_ec_code

    ENDIF. " IF lv_atnam = 'DC_CODE' AND NOT <lfs_final>-charg IS INITIAL
    CLEAR: lv_index.
  ENDLOOP. " LOOP AT i_final ASSIGNING <lfs_final>

** EOC ADD ADAS1 CR 153



  SORT i_final BY atwrt_m matnr_p atinn.
* EOC ADD ADAS1 08/24/2012
**&& --  BOC : CR# 1286 : PROUT : 06-AUG-2014
*sales order history needs to be fetched.
  IF cb_hist = abap_true.
    DELETE i_final WHERE kunnr IS INITIAL.
  ENDIF. " IF cb_hist = abap_true
**&& --  EOC : CR# 1286 : PROUT : 06-AUG-2014


ENDFORM. " F_FILL_FINAL_TAB
*&---------------------------------------------------------------------*
*&      Form  F_FILL_LISTHEADER
*&---------------------------------------------------------------------*
*      Subroutine to fill list header inetrnal table
*----------------------------------------------------------------------*
FORM f_fill_listheader .

* Local declaration
  DATA: lv_date    TYPE char10,              "date variable
        lv_time    TYPE char10,              "time variable
        lv_lines   TYPE i,                   "records count of final table
        lx_address TYPE bapiaddr3,           "User Address Data
        li_return  TYPE ty_t_retrn1,         "return table
        lwa_listheader TYPE slis_listheader. "List header Workarea

  lwa_listheader-typ  = c_head.
  lwa_listheader-key  = 'Report'(074).
  lwa_listheader-info = 'Batch Matching Report'(068).
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ  = c_shead.
  lwa_listheader-key  = 'User Name'(061).

* Get user details
  CALL FUNCTION 'BAPI_USER_GET_DETAIL'
    EXPORTING
      username = sy-uname
    IMPORTING
      address  = lx_address
    TABLES
      return   = li_return.

  IF lx_address-fullname IS NOT INITIAL.
    MOVE lx_address-fullname TO lwa_listheader-info.
  ELSE. " ELSE -> IF lx_address-fullname IS NOT INITIAL
    MOVE sy-uname TO lwa_listheader-info.
  ENDIF. " IF lx_address-fullname IS NOT INITIAL

  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  lwa_listheader-typ = c_shead.
  lwa_listheader-key = 'Date and Time'(062).

  CONCATENATE sy-uzeit+0(2)
              sy-uzeit+2(2)
              sy-uzeit+4(2)
         INTO lv_time
         SEPARATED BY c_colon.

  CONCATENATE sy-datum+4(2)
              sy-datum+6(2)
              sy-datum+0(4)
         INTO lv_date
         SEPARATED BY c_slash.

  CONCATENATE lv_date
              lv_time
         INTO lwa_listheader-info
         SEPARATED BY space.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.

  DESCRIBE TABLE i_final[] LINES lv_lines.

  lwa_listheader-typ  = c_shead.
  lwa_listheader-key  = 'Total Records'(063).
  MOVE lv_lines TO lwa_listheader-info.
  APPEND lwa_listheader TO i_listheader.
  CLEAR lwa_listheader.


ENDFORM. " F_FILL_LISTHEADER
*&---------------------------------------------------------------------*
*&      Form  F_F4_PROD_CATEGGORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_f4_prod_categgory .

* Local Data Declaration
  DATA: lv_atinn TYPE atinn,                                            " Internal characteristic
        li_exp_values  TYPE STANDARD TABLE OF api_value INITIAL SIZE 0, " API Interface for Characteristic Value
        lwa_exp_values TYPE api_value.                                  " API Interface for Characteristic Value

*&--BOC COMMENT Defect#2164 RVERMA 12/17/2012
** Get Characteristic number
*  SELECT SINGLE atinn
*     FROM cabn
*    INTO lv_atinn
*      WHERE atnam = c_atinn.
*&--EOC COMMENT Defect#2164 RVERMA 12/17/2012

*&--BOC ADD Defect#2164 RVERMA 12/17/2012
* Get Characteristic number
  SELECT atinn UP TO 1 ROWS
    FROM cabn " Characteristic
    INTO lv_atinn
    WHERE atnam = c_atinn.
  ENDSELECT.
*&--EOC ADD Defect#2164 RVERMA 12/17/2012

* Display F4 for product category
  IF sy-subrc = 0.

    CALL FUNCTION 'C107VAT_CTMS_CHAR_VALUE_F4'
      EXPORTING
        imp_characteristic = lv_atinn
        i_inst_tabix       = 0
      TABLES
        exp_values         = li_exp_values
      EXCEPTIONS
        cancelled_by_user  = 1
        OTHERS             = 2.
    IF sy-subrc = 0.
      READ TABLE li_exp_values INTO lwa_exp_values INDEX 1.
      IF sy-subrc = 0.
        p_atwrt = lwa_exp_values-atwrt.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF sy-subrc = 0

  ENDIF. " IF sy-subrc = 0

ENDFORM. " F_F4_PROD_CATEGGORY
*&---------------------------------------------------------------------*
*&      Form  F_HIST_VALIDATION
*&---------------------------------------------------------------------*
*      Subroutine for history validation
*----------------------------------------------------------------------*
FORM f_hist_validation .

  DATA: lv_lines_matnr  TYPE int4 , " for Material Number
        lv_lines_charg TYPE  int4.  " for Batches

  CONSTANTS: lc_e TYPE char1 VALUE 'E'. " Type = E

  DESCRIBE TABLE s_matnr LINES lv_lines_matnr.
  IF s_matnr-high IS NOT INITIAL OR lv_lines_matnr GT 1.
    MESSAGE i998 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF s_matnr-high IS NOT INITIAL OR lv_lines_matnr GT 1

  DESCRIBE TABLE s_charg LINES lv_lines_charg.
  IF s_charg-high IS NOT INITIAL OR lv_lines_charg GT 1.
    MESSAGE i117 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF. " IF s_charg-high IS NOT INITIAL OR lv_lines_charg GT 1
ENDFORM. "f_hist_validation
