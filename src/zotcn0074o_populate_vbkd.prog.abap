************************************************************************
* PROGRAM    :  ZOTCN0074O_POPULATE_VBKD(Include)                      *
* TITLE      :  Sales Rep Cost Center Assignment                       *
* DEVELOPER  :  Suman K Pandit                                         *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   CR192(OTC_EDD_0074)                                     *
*----------------------------------------------------------------------*
* DESCRIPTION: Populate VSBED/INCO1/INCO2 from Ship-To customer record.*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 01-NOV-2012  SPANDIT E1DK907442  INITIAL DEVELOPMENT                 *
* 06-AUG-2014  BMAJI   E1DK914489  D# 1526 : For a Sales Order, when   *
*                                  the Shippping Conditions are changed*
*                                  by the User manually, then Route is *
*                                  not getting updated accordingly.    *
* 18-AUG-2015  APODDAR E2DK914771  Defect # 8945 Shipping Condition    *
*                                  Determination from Ship To          *
* 11-FEB-2016  SGHOSH  E2DK916946  Defect # 1497 Need to consider eVo  *
*                                  Orders with order type ZWEB & ZWB3. *
* 29-Aug-2019  U105235 E2DK926286  SCTASK0835733 if the ESKER file has *
*                                  data for SHIPPING CONDITIONS & INCO *
*                                  TERMS field then dont modify them in*
*                                  the include                         *
* 10-Oct-2019  U105235 E2DK927358  INC0520040 shipping condition is not*
*                                  populating correctly when the orders*
*                                  are placed from VA01 & VA02         *
*&---------------------------------------------------------------------*

* Local types
  TYPES: BEGIN OF lty_auart,
           mvalue1 TYPE z_mvalue_low,     "Select Options: Value Low
         END OF lty_auart,
         lty_t_auart TYPE STANDARD TABLE OF lty_auart,
         lty_r_auart TYPE RANGE OF auart, " Sales Document Type
         lty_auart_r TYPE LINE OF lty_r_auart.

* Local constants
  CONSTANTS:lc_prog_name        TYPE char50       VALUE 'EDD0074',    "Program Name
            lc_fld_name         TYPE char50       VALUE 'VBAK-AUART', "Field Name
            lc_sign_i           TYPE char1        VALUE 'I',          "Inclusive
            lc_option_eq        TYPE char2        VALUE 'EQ',         "Option
            lc_active           TYPE char1        VALUE 'X',          "Active
            lc_trtyp_v          TYPE trtyp        VALUE 'V',          "Creation mode
            lc_trtyp_h          TYPE trtyp        VALUE 'H',          "Change mode
* ---> Begin of Change for D2_OTC_EDD_0074 Defect # 1497 by SGHOSH
            lc_activity_lord    TYPE char4        VALUE 'LORD'. " Activity_lord of type CHAR4
* <--- End of Change for D2_OTC_EDD_0074 Defect # 1497 by SGHOSH

* Local data declaration
  DATA: lr_auart TYPE lty_r_auart,
        lwa_auart_r TYPE lty_auart_r,
        li_auart TYPE lty_t_auart,

* ---> Begin of Change for D2_OTC_EDD_0074 Defect # 8945 by APODDAR
        lv_thrd_prty TYPE flag. " General Flag
* <--- End    of Change for D2_OTC_EDD_0074 Defect # 8945 by APODDAR

DATA :  lv_esker  TYPE flag,  " Defect 9035
        lv_inco   TYPE flag,
        lv_ship   TYPE flag.

* Local field symbols
  FIELD-SYMBOLS: <lfs_auart> TYPE lty_auart.

* svbkd-tabix = 0 => creation
* svbkd-tabix > 0 => change mode / xvbak-weupda = 'X' => Ship-to-party modified
*{   INSERT         E1DK917642                                        1
IF sy-tcode <> 'ZOTC_ORDER'.
*}   INSERT
*Begin of code changes - SCTASK0835733 - U105235 - 29-Aug-2019
IMPORT  lv_esker     TO lv_esker     FROM MEMORY ID 'ESKER'.
IMPORT  lv_ship      TO lv_ship      FROM MEMORY ID 'SHIP'.
IMPORT  lv_inco      TO lv_inco      FROM MEMORY ID 'INCO'.
*End of code changes - SCTASK0835733 - U105235 - 29-Aug-2019
***IF sy-uname NE 'P2DCONE2D'.


* ---> Begin of Change for D2_OTC_EDD_0074 Defect # 8945 by APODDAR

* Flag is Set based on these custom fields which denotes the fact that
* this is not a manual run and is triggered by a Interface.


*Begin of code changes - SCTASK0863951 - U105235 - 29-Aug-2019
*commented the below code as the validation is not required
*for the data coming in Esker and the fields shipping condition,
*incoterm1, incoterm2 are to be populated by the SHIP-TO-Party data

**  IF xvbak-zzdocref IS NOT INITIAL
** AND xvbak-zzdoctyp IS NOT INITIAL.
**    lv_thrd_prty = lc_active.
**  ENDIF. " IF xvbak-zzdocref IS NOT INITIAL

*End of code changes - SCTASK0863951 - U105235 - 29-Aug-2019
* <--- End    of Change for D2_OTC_EDD_0074 Defect # 8945 by APODDAR

**&& -- BOC : D# 1526 : BMAJI : 06-AUG-2014
**  IF svbkd-tabix = 0 OR ( svbkd-tabix > 0 AND xvbak-weupda = lc_active ).
  IF ( svbkd-tabix = 0 AND xvbak-kunnr EQ space ) OR
        ( svbkd-tabix > 0 AND xvbak-weupda = lc_active )
**&& -- EOC : D# 1526 : BMAJI : 06-AUG-2014
* ---> Begin of Change for D2_OTC_EDD_0074 Defect # 1497 by SGHOSH
    OR ( svbkd-tabix > 0 AND call_activity = lc_activity_lord ).
*Begin of code changes - SCTASK0863951 - U105235 - 29-Aug-2019
*commented the line 97 as the third party validation is not required
* <--- End of Change for D2_OTC_EDD_0074 Defect # 1497 by SGHOSH
* ---> Begin of Change for D2_OTC_EDD_0074 Defect # 8945 by APODDAR
**   OR ( svbkd-tabix > 0 AND lv_thrd_prty = lc_active ) .
* <--- End    of Change for D2_OTC_EDD_0074 Defect # 8945 by APODDAR
*End of code changes - SCTASK0863951 - U105235 - 29-Aug-2019

* Creation / Display mode
    IF t180-trtyp = lc_trtyp_v OR
       t180-trtyp = lc_trtyp_h.

* Fetch Order Type from OTC Parameter table
      SELECT mvalue1           " Select Options: Value Low
        FROM  zotc_prc_control " OTC Process Team Control Table
        INTO  TABLE li_auart
        WHERE vkorg      = vbak-vkorg   AND
              vtweg      = vbak-vtweg   AND
              mprogram   = lc_prog_name  AND
              mparameter = lc_fld_name   AND
              mactive    = lc_active     AND
              soption    = lc_option_eq.
      IF sy-subrc IS INITIAL.

* Populate order types in range table
        LOOP AT li_auart ASSIGNING <lfs_auart>.
          lwa_auart_r-sign = lc_sign_i.
          lwa_auart_r-option = lc_option_eq.
          lwa_auart_r-low = <lfs_auart>-mvalue1.
          APPEND lwa_auart_r TO lr_auart.
        ENDLOOP. " LOOP AT li_auart ASSIGNING <lfs_auart>

* Override fields from Ship-to party
        IF vbak-auart IN lr_auart AND lr_auart IS NOT INITIAL.

*Begin of code changes - SCTASK0835733 - U105235 - 29-Aug-2019
*for the data coming from ESKER file, the field values should not be
*override by the ship-to party field values in the exit hence we are
*checking the condition that if the ESKER file sends the SHIPPING CONDITION
*and INCOTERMS data then do modify the field values here

*Begin of code changes - INC0520040 - U105235 - 10-Oct-2019
*the shipping condition is not populating correctly when the order is created
*from VA01 and VA02, hence the below code is written to populate the field values
          vbak-vsbed = kuwev-zzvsbed.
          vbkd-inco1 = kuwev-zzinco1.
*End of code changes - INC0520040 - U105235 - 10-Oct-2019

          IF lv_esker EQ abap_true AND
             lv_ship  NE abap_true.
            vbak-vsbed = kuwev-zzvsbed.
          ENDIF.
         IF lv_esker EQ abap_true AND
            lv_inco  NE abap_true.
          vbkd-inco1 = kuwev-zzinco1.
        ENDIF.

*End of code changes - SCTASK0835733 - U105235 - 29-Aug-2019

          vbkd-inco2 = kuwev-zzinco2.

        ENDIF. " IF vbak-auart IN lr_auart AND lr_auart IS NOT INITIAL
      ENDIF. " IF sy-subrc IS INITIAL
    ENDIF. " IF t180-trtyp = lc_trtyp_v OR
  ENDIF. " IF ( svbkd-tabix = 0 AND xvbak-kunnr EQ space ) OR
*{   INSERT         E1DK917642


*****ENDIF.    u105235

ENDIF.
*}   INSERT
