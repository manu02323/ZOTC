************************************************************************
* PROGRAM    :  ZOTCE0212B_SALES_BOM_CREATION                          *
* TITLE      :  Auto Creation of Sales BOM                             *
* DEVELOPER  :  NEHA KUMARI                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
*  WRICEF ID :  D2_OTC_EDD_0212                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Auto Creation of Material BOM and BOM Extension for    *
*               plant assignments                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT   DESCRIPTION                         *
* =========== ======== ==========  ====================================*
* 16-SEP-2014 NKUMARI  E2DK904869  INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
* 24-Feb-2015 NKUMARI  E2DK904869  Defect 4058: Logic is added for     *
*                                  Background Mode Execution           *
*&---------------------------------------------------------------------*

***-----------Structure Declaration------------*****
 TYPES:   BEGIN OF ty_werks,
           werks TYPE  werks_d,     " Plant
          END OF ty_werks,

          BEGIN OF ty_mail,         " Pur. Grp Email
           email  TYPE  ad_smtpadr, " E-Mail Address
          END   OF ty_mail,

* ---> Begin of change for Defect #4058 by NKUMARI

          BEGIN OF ty_matnr,
           matnr  TYPE matnr,    " Material Number
           status TYPE xtype,    " Instance object type
          END OF ty_matnr,

          BEGIN OF ty_marc,
            matnr TYPE  matnr,   " Material Number
            werks TYPE  werks_d, " Plant
          END OF ty_marc,

         BEGIN OF ty_bom_no,
            matnr TYPE  matnr,   " Material Number
            bomno TYPE  stnum,   " Bill of material
            msg1  TYPE  string,
            msg2  TYPE  string,
          END OF ty_bom_no.

* <--- End of change for Defect #4058 by NKUMARI

***----------Table type Declaration--------****
 TYPES:   ty_t_mail       TYPE STANDARD TABLE OF ty_mail         INITIAL SIZE 0, " Email Table Type
          ty_t_werks      TYPE STANDARD TABLE OF ty_werks        INITIAL SIZE 0, " Plant
          ty_r_werks      TYPE RANGE OF werks_d,                                 " Range declaration of plant
          ty_t_bom_create TYPE STANDARD TABLE OF zotc_bom_create INITIAL SIZE 0, " Characteristics information for sales BOM creation

* ---> Begin of change for Defect #4058 by NKUMARI
          ty_t_matnr      TYPE STANDARD TABLE OF ty_matnr        INITIAL SIZE 0,
          ty_r_matnr      TYPE RANGE OF matnr,                                   " Range declaration of Material Number
          ty_t_marc       TYPE STANDARD TABLE OF ty_marc         INITIAL SIZE 0. " Plant

***-----------Table and Global value Declaration For defect 4058------------*****
 DATA:    i_matnr        TYPE ty_t_matnr,                         " Internal table for Material
          i_marc         TYPE ty_t_marc,                          " Internal table for plant
          i_bomno        TYPE STANDARD TABLE OF ty_bom_no,        " Internal table for plant
          gv_matnr       TYPE  matnr,                             " Material Number
          i_matnr_range  TYPE STANDARD TABLE OF bapi_rangesmatnr, " BAPI Selection Structure: Material Number

* <--- End of change for Defect #4058 by NKUMARI
***-----------Table Declaration------------*****
        i_mail        TYPE ty_t_mail,       " Email data table
        i_werks       TYPE ty_t_werks,      " Internal table for plant
        i_bom_create  TYPE ty_t_bom_create, " Characteristics information for sales BOM creation

***-----------Global Variable Declaration------------*****
        gv_bom_no     TYPE  stnum,   " Bill of material
        gv_werks      TYPE  werks_d, " Plant
        gv_err_flg    TYPE  boolean, " Boolean Variable (X=True, -=False, Space=Unknown)
****-->> Begin of change by NKUMARI for defect# 1404
        gv_exist_flg  TYPE  boolean, " Boolean Variable (X=True, -=False, Space=Unknown)
****<<-- End of change by NKUMARI for defect# 1404
        gv_error      TYPE  bapi_msg, " Message Text
        gv_message    TYPE  bapi_msg, " Message Text
        gv_msg_create TYPE  bapi_msg, " Message text for mail
        gv_msg_extend TYPE  bapi_msg. " Message text for mail

****----------Field Symbol Declaration------------*****
 FIELD-SYMBOLS: <fs_bom_create> TYPE zotc_bom_create. " Characteristics information for sales BOM creation

***-----------Constant Declaration------------*****
 CONSTANTS:
        c_stlan    TYPE  stlan    VALUE '5', " BOM Usage
        c_added    TYPE  xfeld    VALUE 'I', " Checkbox
        c_complete TYPE  xfeld    VALUE 'C'. " Checkbox
