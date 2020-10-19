**&---------------------------------------------------------------------*
**&  Include           ZXVEDU04
**&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTC_IDD_00064                                         *
* TITLE      :  Billback CR/DR Upload Interface                        *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  User exit                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_IDD_0064                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:                                                         *
*Following fields to be populated using ORDERS05                       *
*Segment 	Qualifier	Field                                              *
*E1EDP02  001       Customer Purchase Order                            *
*E1EDP03  039       Ship-to party's PO date                            *
*E1EDP03  022       Purchase order date                                *
*E1EDP02            IHREZ                                              *
*This should happen only for billback documents document type will be  *
*updated in ZOTC_PRC_CONTROL  against  program name = EDI867           *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT    DESCRIPTION                        *
* =========== ======== ==========  ====================================*
* 03-AUG-2012 SPURI    E1DK904544  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 11-NOV-2012 DRAJPUT  E1DK908145  Def 1750/ Date is getting swapped   *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*======================================================================*
* DATE        USER     TRANSPORT    DESCRIPTION                        *
* =========== ======== ==========  ====================================*
* 03-AUG-2012 SPURI    E1DK904544  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 11-NOV-2012 DRAJPUT  E1DK908145  Def 1750/ Date is getting swapped   *
*&-----------------------------------------------------------------------*
* 22-May-2014 PMISHRA  E2DK900747  D2_OTC_IDD_0009 - D2 Changes to update*
*                                  EMail Id, custom fields in sales order*
*                                  header and item                       *
*------------------------------------------------------------------------*
* 04-Oct-2017 U033876  E1DK931303  D3.R2 OTC_CDD_0141_Convert Open Servic*
*                                  e Plans add additional tax classificat*
*                                  ion to the billing tab of Sales order *
*------------------------------------------------------------------------*

TYPES : BEGIN OF lty_val,
             item    TYPE vbap-posnr,                " Sales Document Item
             bstkd   TYPE vbkd-bstkd,                " Customer purchase order number
             bstdk   TYPE char10,                    " Bstdk of type CHAR10
             bstdk_e TYPE char10,                    " E of type CHAR10
             ihrez   TYPE vbkd-ihrez,                " Your Reference
        END OF lty_val,

        BEGIN OF lty_zotc_prc_control,
           mvalue1    TYPE zotc_prc_control-mvalue1, " Select Options: Value Low
        END OF lty_zotc_prc_control.
STATICS:  lv_count1    TYPE i , " Count1 of type Integers
          lv_curscr(4) TYPE c,  " Curscr(4) of type Character
          lv_prescr(4) TYPE c.  " Prescr(4) of type Character

DATA    : lwa_val                     TYPE lty_val,
          lwa_bdcdata                 TYPE bdcdata, " Batch input: New table field structure
          li_val                      TYPE STANDARD TABLE OF lty_val INITIAL SIZE 0,
          li_zotc_prc_control         TYPE STANDARD TABLE OF lty_zotc_prc_control INITIAL SIZE 0,
          lv_count       TYPE i ,                   " Count of type Integers
          lv_line        TYPE i,                    " Line of type Integers
          lv_org(4)      TYPE c,                    " Org(4) of type Character
          lv_dist(2)     TYPE c.                    " Dist(2) of type Character

DATA : lv_date TYPE datum. " Date

FIELD-SYMBOLS : <fs_zotc_prc_control> TYPE lty_zotc_prc_control.

*Get Sales/Org and Dist.
CLEAR : lv_org , lv_dist .
LOOP AT didoc_data WHERE segnam = 'E1EDK14'.
  CASE didoc_data-sdata+0(3).
    WHEN  '008'.
      lv_org = didoc_data-sdata+3(35).
    WHEN  '007'.
      lv_dist = didoc_data-sdata+3(35).
  ENDCASE.
ENDLOOP. " LOOP AT didoc_data WHERE segnam = 'E1EDK14'


*Get Order types
REFRESH li_zotc_prc_control[].
SELECT mvalue1          " Select Options: Value Low
FROM   zotc_prc_control " OTC Process Team Control Table
INTO TABLE li_zotc_prc_control
WHERE   vkorg       =  lv_org   AND
        vtweg       =  lv_dist  AND
        mprogram    =  'EDI867' AND
        mparameter  =  'AUART'  AND
        mactive     =  'X'      AND
        soption     =  'EQ'.

READ TABLE didoc_data WITH KEY segnam = 'E1EDK01'.
IF sy-subrc = 0.
  READ TABLE li_zotc_prc_control ASSIGNING <fs_zotc_prc_control> WITH KEY mvalue1 = didoc_data-sdata+79(4).
  IF sy-subrc = 0.
*store previous and current BDC screen numbers
    lv_prescr = lv_curscr.
    lv_curscr = dlast_dynpro.
*Populate li_val
    IF lv_curscr = '4003' AND lv_prescr = '4001'.
      REFRESH li_val[].
      CLEAR   lv_count.
*    if li_val[] is initial.
      LOOP AT didoc_data.
        CASE didoc_data-segnam.
          WHEN 'E1EDP02'.
*Get Customer Purchase Order/ Get IHREZ
            IF didoc_data-sdata+0(3) = '001'.
              lwa_val-bstkd = didoc_data-sdata+3(35).
              lwa_val-ihrez = didoc_data-sdata+93(30).
            ENDIF. " IF didoc_data-sdata+0(3) = '001'
          WHEN 'E1EDP03'.
*Get Ship-to party's PO date
            IF didoc_data-sdata+0(3) = '039'.
              lwa_val-bstdk = didoc_data-sdata+3(8).

*12/11/2012 Start of Change
*              concatenate lwa_val-bstdk+4(2) '/'
*                          lwa_val-bstdk+6(2) '/'
*                          lwa_val-bstdk+0(4)
*               into lwa_val-bstdk.
              CLEAR lv_date.
              lv_date = lwa_val-bstdk.
              WRITE lv_date TO lwa_val-bstdk.
*12/11/2012 End of Change

*Get Purchase order date
            ELSEIF didoc_data-sdata+0(3) = '022'.
              lwa_val-bstdk_e = didoc_data-sdata+3(8).

*12/11/2012 Start of Change
*              concatenate lwa_val-bstdk_e+4(2) '/'
*                          lwa_val-bstdk_e+6(2) '/'
*                          lwa_val-bstdk_e+0(4)
*               into lwa_val-bstdk_e.
              CLEAR lv_date.
              lv_date = lwa_val-bstdk_e.
              WRITE lv_date TO lwa_val-bstdk_e.
*12/11/2012 End of Change
            ENDIF. " IF didoc_data-sdata+0(3) = '039'
          WHEN 'E1EDP01'.
*Append record
            IF lwa_val IS NOT INITIAL.
              lwa_val-item = lv_count.
              APPEND lwa_val TO li_val.
              lv_count = lv_count + 1.
              CLEAR lwa_val.
            ENDIF. " IF lwa_val IS NOT INITIAL
        ENDCASE.
      ENDLOOP. " LOOP AT didoc_data
      IF lwa_val IS NOT INITIAL.
        lwa_val-item = lv_count.
        APPEND lwa_val TO li_val.
        CLEAR lwa_val.
      ENDIF. " IF lwa_val IS NOT INITIAL
*     endif.

* Increment counter to know which item is to be populated
* counter lv_count1 works as the item number
      lv_count1 = lv_count1 + 1.
      CLEAR lwa_val.
      READ TABLE li_val INTO lwa_val  INDEX lv_count1.
      IF sy-subrc = 0.
        CLEAR lwa_bdcdata.
        lwa_bdcdata-fnam = 'VBKD-BSTKD'. " purchase order
        lwa_bdcdata-fval =  lwa_val-bstkd.
        APPEND lwa_bdcdata TO dxbdcdata.

        CLEAR lwa_bdcdata.
        lwa_bdcdata-fnam = 'VBKD-BSTDK'. " purchase order date
*       lwa_bdcdata-fval =  lwa_val-bstdk. "DRAJPUT
        lwa_bdcdata-fval =  lwa_val-bstdk_e.
        APPEND lwa_bdcdata TO dxbdcdata.

        CLEAR lwa_bdcdata.
        lwa_bdcdata-fnam = 'VBKD-BSTDK_E'. "ship to party date
*       lwa_bdcdata-fval =  lwa_val-bstdk_e. "DRAJPUT
        lwa_bdcdata-fval =  lwa_val-bstdk.
        APPEND lwa_bdcdata TO dxbdcdata.

        CLEAR lwa_bdcdata.
        lwa_bdcdata-fnam = 'VBKD-IHREZ'. " your reference
        lwa_bdcdata-fval =  lwa_val-ihrez.
        APPEND lwa_bdcdata TO dxbdcdata.
      ENDIF. " IF sy-subrc = 0
    ENDIF. " IF lv_curscr = '4003' AND lv_prescr = '4001'

    DESCRIBE TABLE dxbdcdata LINES lv_line.
    READ TABLE dxbdcdata INDEX lv_line.
* On save clear item / counter number
    IF dxbdcdata-fval ='SICH'.
      CLEAR lv_count1.
    ENDIF. " IF dxbdcdata-fval ='SICH'
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF sy-subrc = 0

* ---> Begin of Change For D2_OTC_IDD_0009 by PMISHRA
PERFORM f_update_bdcdata USING didoc_data[]
                               dlast_dynpro
                      CHANGING dxbdcdata[].
* ---> End of Change For D2_OTC_IDD_0009 by PMISHRA

* ---> Begin of Change For OTC_CDD_0141 by U033876

  INCLUDE zotcn0141o_enh_for_dsma. " Enhancement to add add tax class to bdc data

* <--- End of Change For OTC_CDD_0141 by U033876
