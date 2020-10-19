*&---------------------------------------------------------------------*
*&  Include           ZOTCN370B_DELIVERY_BLOCK
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN370B_DELIVERY_BLOCK (Enhancement)                 *
* TITLE      :  Delivery Block on duplicate Sales orders               *
* DEVELOPER  :  Anjan Paul                                             *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_EDD_0370                                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Check for duplicate Sales order. If                    *
*              duplicate sales order put Dleivery Block                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 16-JUN-2017 APAUL    E1DK928644 INITIAL DEVELOPMENT  - Defect 2557   *
*&---------------------------------------------------------------------*


* Types declaration
  TYPES: BEGIN OF  lty_vbak2,
            vbeln      TYPE vbeln,  " Sales and Distribution Document Number
            erdat      TYPE erdat,  " Date on Which Record Was Created
            kunnr      TYPE kunag , " Sold-to party
    END OF lty_vbak2.

  TYPES : BEGIN OF lty_vbkd ,
               vbeln TYPE  vbeln,     " Sales and Distribution Document Number
               posnr TYPE  posnr ,    " Item number of the SD document
               bstkd_m TYPE  bstkd_m, " Customer PO number as matchcode field
          END OF  lty_vbkd.



* Constant declaration
  CONSTANTS: lc_emi_proj         TYPE z_enhancement VALUE 'OTC_EDD_0370',   " Enhancement No.
             lc_null1            TYPE z_criteria    VALUE 'NULL',           " Enh. Criteria
             lc_dupl_days        TYPE z_criteria    VALUE 'DUPLICATE_DAYS', " Enh. Criteria
             lc_auart2           TYPE z_criteria    VALUE 'AUART' ,         " Enh. Criteria
             lc_lifsk            TYPE z_criteria    VALUE 'LIFSK'  ,        " Enh. Criteria
             lc_activity         TYPE char04        VALUE 'LORD',           " Proxy call
             lc_trtyp_v1          TYPE trtyp         VALUE 'V',             " Transaction type
             lc_trtyp_h1          TYPE trtyp         VALUE 'H',             " Transaction type
             lc_posnr1            TYPE posnr         VALUE '00000'.         " Item number of the SD document

*  Data declaraions
  DATA: li_enh_status          TYPE STANDARD TABLE OF zdev_enh_status , " Enhancement Status
        lv_dupl_days           TYPE numc_3,                             " Numeric value
        lv_erdat               TYPE erdat ,                             " Date on Which Record Was Created
        li_vbak2               TYPE TABLE OF lty_vbak2,
        li_vbkd                TYPE TABLE OF lty_vbkd.

* EMI  declarations
  FIELD-SYMBOLS  :      <lfs_enh_status>  TYPE    zdev_enh_status. " Enhancement Status

* This  developement will  trigger  for  IDOC , Proxy  and  background mode
  IF  call_activity = lc_activity  OR
      idoc_number  IS NOT INITIAL  OR
      sy-batch     IS NOT INITIAL.

* Check for Transaction type
    IF  t180-trtyp  = lc_trtyp_v1 OR
        t180-trtyp = lc_trtyp_h1 .

** Check if the object is active from EMI.
      CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
        EXPORTING
          iv_enhancement_no = lc_emi_proj
        TABLES
          tt_enh_status     = li_enh_status.

      IF li_enh_status IS NOT INITIAL.
        DELETE li_enh_status  WHERE active IS INITIAL.

        SORT li_enh_status BY criteria .

* Check  NULL activated or not
        READ TABLE li_enh_status WITH KEY
                           criteria = lc_null
                           BINARY SEARCH
                           TRANSPORTING NO FIELDS.
        IF sy-subrc  EQ 0.

          READ TABLE li_enh_status WITH KEY
                             criteria = lc_dupl_days
                            ASSIGNING  <lfs_enh_status>
                              BINARY SEARCH   .

          IF sy-subrc  EQ 0.
* Calculate the days  for duplicate sales order consideration
            lv_dupl_days  =  <lfs_enh_status>-sel_low .
            lv_erdat   =  sy-datum    - lv_dupl_days .


* Binary search not used as sorting is done on different key field and also
* no of records in the table is  very low i.e less than 10
            READ TABLE li_enh_status WITH KEY
                               criteria = lc_auart2
                               sel_low  = vbak-auart
                              ASSIGNING  <lfs_enh_status> .

* Don't consider the order type
            IF sy-subrc  NE 0 .


*  Check for sales order with Customer PO
              SELECT vbeln                    " Sales and Distribution Document Number
                     posnr                    " Item number of the SD document
                     bstkd_m                  " Customer PO number as matchcode field
                FROM vbkd                     " Sales Document: Business Data
                INTO TABLE li_vbkd
                WHERE bstkd_m = vbkd-bstkd_m. "Index VBKD~BST use

              IF sy-subrc  EQ 0.
                DELETE li_vbkd WHERE posnr NE lc_posnr1.

                IF li_vbkd IS NOT INITIAL  .

* Get all the Sales order for last consideration dates for the sold to party
* If selection failed then skip the remaining  checks
                  SELECT    vbeln " Sales Document
                            erdat " Date on Which Record Was Created
                            kunnr " Sold-to party
                  FROM  vbak      " Sales Document: Header Data
                  INTO TABLE li_vbak2
                  FOR ALL ENTRIES IN li_vbkd
                  WHERE vbeln = li_vbkd-vbeln.

                  IF sy-subrc  EQ 0.
* Consider only the specific PO
                    DELETE  li_vbak2  WHERE kunnr NE vbak-kunnr.
                    DELETE  li_vbak2  WHERE erdat LE lv_erdat.

* Check if there any entries presence for sold to party and PO
                    READ TABLE li_vbak2 INDEX 1 TRANSPORTING NO FIELDS.

                    IF  sy-subrc EQ 0.
                      READ TABLE li_enh_status WITH KEY
                                        criteria = lc_lifsk
                                       ASSIGNING  <lfs_enh_status>
                                         BINARY SEARCH   .
                      IF sy-subrc EQ 0.
* If Sales  order found then  with sold to party  and PO , then put delivery  block
                        vbak-lifsk = <lfs_enh_status>-sel_low.
                        xvbak-lifsk = <lfs_enh_status>-sel_low.

                      ENDIF. " IF sy-subrc EQ 0
                    ENDIF. " IF sy-subrc EQ 0
                  ENDIF . " IF sy-subrc EQ 0
                ENDIF. " IF li_vbkd IS NOT INITIAL
              ENDIF    . " IF sy-subrc EQ 0
            ENDIF. " IF sy-subrc NE 0
          ENDIF. " IF sy-subrc EQ 0
        ENDIF. " IF sy-subrc EQ 0
      ENDIF. " IF li_enh_status IS NOT INITIAL
    ENDIF . " IF t180-trtyp = lc_trtyp_v1 OR
  ENDIF  . " IF call_activity = lc_activity OR

  CLEAR:   li_enh_status    ,
           lv_dupl_days     ,
           lv_erdat         ,
           li_vbak2         ,
           li_vbkd.

  IF <lfs_enh_status> IS ASSIGNED .
    UNASSIGN <lfs_enh_status>  .
  ENDIF. " IF <lfs_enh_status> IS ASSIGNED
