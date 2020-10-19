************************************************************************
* PROGRAM    :  ZOTCN0069B_MODIFY_TOP                                  *
* TITLE      :  OTC_CDD_0069B BILLING OUTPUT                           *
* DEVELOPER  :  ANKIT PURI                                             *
* OBJECT TYPE:  INCLUDE                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  OTC_CDD_0069                                           *
*----------------------------------------------------------------------*
* DESCRIPTION:  INCLUDE FOR GLOBAL DECLARATIONS                        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 19-MAY-2012 APURI    E1DK901634 INITIAL DEVELOPMENT                  *
* 23-Dec-2014 SMEKALA  E2DK907954 D2: Add new billing condition types  *
* 23-MAY-2016 U033830  E1DK918109 D3:1.Add new condition types:        *
*                                      ZED1 and ZEIN.                  *
*                                 2. Remove upload for table B911 for  *
*                                    conditions ZRD1 and ZRD0.         *
* 09-Dec-2016 MTHATHA  E1DK918109 D3_Defect#6399:Add new condition     *
*                                 type ZEIN for  B905.                 *
* 16-Nov-2017 U033876  E1DK932575 D3.R2_Defect#4202:Add new conditions *
*                                 type ZEDK, ZEFI, ZENO, ZESE for  B905*
* 21-Feb-2018 U034334  E1DK932575 D3R3 Defect 4204: Add output types   *
*                                 for new E-invoices. Remove hard-coded*
*                                 constants and read them using EMI    *
* 07-MAR-2019 U104864  E2DK922522 SCTASK0801088 Update Key field and   *
*                                 addition of KeyCombination ZRD6905   *
************************************************************************
TYPES: BEGIN OF ty_modify,
        keycombi   TYPE char20,      " key combination
        kschl      TYPE na_kschl,    "condition type
        vkorg      TYPE vkorg,       "sales organization
        bsark      TYPE bsark,       " Customer purchase order type "Added in D2
        kunre      TYPE kunre,       "bill to party
        parvw      TYPE parvw,       "partner function
        parnr      TYPE na_parnr241, "partner number
        nacha      TYPE na_nacha,    "Message transmission medium
        vsztp      TYPE na_vsztp,    "dispatch time
        fkart      TYPE fkart,       "billing tpe
        tcode      TYPE cstrategy,   "Communication strategy
        ldest      TYPE rspopname,   "spool : output device
        tdarmod    TYPE syarmod,     "Print: Archiving mode
        tdschedule TYPE skschedule,  "send time request
        dimme      TYPE tdimmed,     "print immediately
       END OF ty_modify,

       BEGIN OF ty_modify_e,
        keycombi   TYPE char20,      " key combination
        kschl      TYPE na_kschl,    "condition type
        vkorg      TYPE vkorg,       "sales organization
        bsark      TYPE bsark,       " Customer purchase order type "Added in D2
        kunre      TYPE kunre,       "bill to party
        parvw      TYPE parvw,       "partner function
        parnr      TYPE na_parnr241, "partner number
        nacha      TYPE na_nacha,    "Message transmission medium
        vsztp      TYPE na_vsztp,    "dispatch time
        fkart      TYPE fkart,       "billing tpe
        tcode      TYPE cstrategy,   "Communication strategy
        ldest      TYPE rspopname,   "spool : output device
        tdarmod    TYPE syarmod,     "Print: Archiving mode
        tdschedule TYPE skschedule,  "send time request
        dimme      TYPE tdimmed,     "print immediately
        errormsg   TYPE char300,     "error message
       END OF ty_modify_e,


*Final Report Display Structure
       BEGIN OF ty_report,
        msgtyp  TYPE char1,  "Message Type
        msgtxt  TYPE string, "Message Text
        key     TYPE string, "Message Key
       END OF ty_report,

       BEGIN OF ty_vkorg,
         vkorg TYPE vkorg,   "sales organization from tvko table
         END OF ty_vkorg,

       BEGIN OF ty_kunnr,
         kunnr TYPE kunnr,   "customer number from kna1 table
         END OF ty_kunnr,

       BEGIN OF ty_parvw,
         parvw TYPE parvw,   "partner function from tpar table
         END OF ty_parvw,

       BEGIN OF ty_fkart,
         fkart TYPE fkart,   "billing type from tvfk table
         END OF ty_fkart ,

       BEGIN OF ty_kschl,
         kschl TYPE kschl,   "condition type
        END OF ty_kschl,
*-- Begin of D2
       BEGIN OF ty_bsark,
         bsark TYPE bsark, " Customer purchase order type
        END OF ty_bsark,
*-- End of D2
       BEGIN OF ty_b905,
         kappl TYPE kappl,    "Application
         kschl TYPE na_kschl, "output type
         vkorg TYPE vkorg,    "sales organisation
         fkart TYPE fkart,    "billing type
         kunre TYPE kunre,    "bill to party
       END OF ty_b905,

       BEGIN OF ty_b906,
        kappl TYPE kappl,     "Application
        kschl TYPE na_kschl,  "output type
        vkorg TYPE vkorg,     "sales organisation
        kunre TYPE kunre,     "bill to party
       END OF ty_b906,
*-- Begin of D2
       BEGIN OF ty_b911,
        kappl TYPE kappl,    "Application
        kschl TYPE na_kschl, "output type
        vkorg TYPE vkorg,    "sales organisation
        bsark TYPE bsark,    " Customer purchase order type
        kunre TYPE kunre,    "bill to party
      END OF ty_b911,
*-- End of D2

* Table Type Declaration
        ty_t_modify TYPE STANDARD TABLE OF ty_modify
                    INITIAL SIZE 0,                   "For Input data
        ty_t_error  TYPE STANDARD TABLE OF ty_modify_e
                    INITIAL SIZE 0,                   "For Error data
        ty_t_report TYPE STANDARD TABLE OF ty_report
                    INITIAL SIZE 0,                   "Report
        ty_t_final  TYPE STANDARD TABLE OF ty_modify
                    INITIAL SIZE 0,                   "For Final Data
        ty_t_vkorg  TYPE STANDARD TABLE OF ty_vkorg
                    INITIAL SIZE 0,                   "sales organization
        ty_t_kunnr  TYPE STANDARD TABLE OF ty_kunnr
                    INITIAL SIZE 0,                   "bill to party ,customer no
        ty_t_parvw  TYPE STANDARD TABLE OF ty_parvw
                    INITIAL SIZE 0,                   "partner function
        ty_t_fkart  TYPE STANDARD TABLE OF ty_fkart
                    INITIAL SIZE 0,                   "billing type
        ty_t_kschl  TYPE STANDARD TABLE OF ty_kschl
                    INITIAL SIZE 0,                   "condition type
        ty_t_bsark  TYPE STANDARD TABLE OF ty_bsark
                    INITIAL SIZE 0,                   "PO type   " Added for D2
        ty_t_b905   TYPE STANDARD TABLE OF ty_b905
                    INITIAL SIZE 0,                   "outtput condition record
        ty_t_b906   TYPE STANDARD TABLE OF ty_b906
                    INITIAL SIZE 0,                   "output condition record
        ty_t_b911     TYPE STANDARD TABLE OF ty_b911
                      INITIAL SIZE 0,                 "output condition record "Created for D2
        ty_t_bdcdata  TYPE STANDARD TABLE OF bdcdata, "bdc data
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
        ty_t_emi      TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status for CDD
        ty_t_einvoice TYPE STANDARD TABLE OF selopt.          " Transfer Structure for Select Options
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18

* Constants
CONSTANTS:
        c_comma      TYPE char1    VALUE  ',',         " constant declaration for comma
        c_rbselected TYPE char1    VALUE  'X',         " constant declaration of type char1 with value 'X'
        c_ind1       TYPE char1    VALUE  'X',         " constant declaration
        c_ext        TYPE string   VALUE  'CSV',       " constant for extension
        c_tbp_fld    TYPE char5    VALUE  'TBP',       " constant declaration for TBP folder
        c_error_fld  TYPE char5    VALUE  'ERROR',     " ERROR folder
        c_done_fld   TYPE char5    VALUE  'DONE',      " DONE folder
        c_error      TYPE char1    VALUE  'E',         " Error Indicator
        c_success    TYPE char1    VALUE  'S',         " Success Indicator
        c_slash      TYPE char1    VALUE  '/',         " For slash
        c_session    TYPE apq_grpn VALUE  'OTC69_BOC', " Session Name
        c_tcode      TYPE sytcode  VALUE  'VV31',      " T-code to upload
        c_ftyp       TYPE filetype VALUE  'ASC',       " filetype
        c_billing    TYPE char2    VALUE  'V3' ,       " billing
        c_zrd0905    TYPE char7    VALUE  'ZRD0905',   " recording name
        c_zrd0906    TYPE char7    VALUE  'ZRD0906',   " recording name
        c_zrd0f905   TYPE char8    VALUE  'ZRD0F905',  " recording name
        c_zrd0f906   TYPE char8    VALUE  'ZRD0F906',  " recording name
        c_zrd1905    TYPE char7    VALUE  'ZRD1905',   " recording name
        c_zrd1906    TYPE char7    VALUE  'ZRD1906',   " recording name
        c_z810905    TYPE char7    VALUE  'Z810905',   " recording name
        c_z810906    TYPE char7    VALUE  'Z810906',   " recording name
*-- Begin of D2
        c_z810911    TYPE char7    VALUE  'Z810911', " recording name
* ---> Begin of Delete for D3_OTC_CDD_0069 By U033830
*        c_zrd1911    TYPE char7    VALUE  'ZRD1911',  " recording name
*        c_zrd0f911   TYPE char8    VALUE  'ZRD0F911', " recording name
*        c_zrd0911    TYPE char7    VALUE  'ZRD0911',  " recording name
*-- End of D2
* ---> End of Delete for D3_OTC_CDD_0069 By U033830
* ---> Begin of Insert for D3_OTC_CDD_0069 By U033830
        c_zed1906    TYPE char7    VALUE  'ZED1906', " recording name
        c_zed1905    TYPE char7    VALUE  'ZED1905', " recording name
* ---> Begin of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
* Commenting the below hard-coded output types for E-Invoicing,
*  as they will be read from the EMI table
*        c_zein906    TYPE char7    VALUE  'ZEIN906', " recording name
* ---> End of Insert for D3_OTC_CDD_0069 By U033830
** ---> Begin of Insert for D3_Defect#6399 By mthatha
*       c_zein905    TYPE char7    VALUE  'ZEIN905', " recording name
** ---> End of Insert for D3_Defect#6399 By mthatha
** ---> Begin of Insert for D3.R2_Defect#4204 By U033876
*       c_zedk905    TYPE char7    VALUE  'ZEDK905', " recording name
*       c_zefi905    TYPE char7    VALUE  'ZEFI905', " recording name
*       c_zeno905    TYPE char7    VALUE  'ZENO905', " recording name
*       c_zese905    TYPE char7    VALUE  'ZESE905', " recording name
**<---- End of Insert for D3.R2_Defect#4204 By U033876
* <--- End   of Delete for D3R3_Defect_4204 by U034334 on 21-02-18
       c_tab        TYPE char1    VALUE cl_abap_char_utilities=>horizontal_tab, "TAB value
       c_crlf       TYPE char1    VALUE cl_abap_char_utilities=>cr_lf,          "Carriage Return and Line Feed  Character Pair
*---Begin of Insert SCTASK0801088 by U104864 on 07-March-2019.
       c_zrd6905    TYPE char7    VALUE  'ZRD6905',   " recording name
       c_zrd2906    TYPE char7    VALUE  'ZRD2906',   " recording name
       c_zrd6906    TYPE char7    VALUE  'ZRD6906'.   " recording name
*---End of Insert SCTASK0801088 by U104864 on 07-March-2019..
* Internal Table Declaration.
DATA:
        i_modify  TYPE ty_t_modify,  " For Input data
        i_error   TYPE ty_t_error,   " For Error data
        i_report  TYPE ty_t_report,  " Report Internal Table
        i_final   TYPE ty_t_final,   " For Final Data
        i_vkorg   TYPE ty_t_vkorg,   " sales organization
        i_kunnr   TYPE ty_t_kunnr,   " Customer number
        i_parvw   TYPE ty_t_parvw,   " Partner function
        i_fkart   TYPE ty_t_fkart,   " billing type
        i_kschl   TYPE ty_t_kschl,   " condition type
        i_bsark   TYPE ty_t_bsark,   " PO type  " Added for D2
        i_b905    TYPE ty_t_b905,    " condition record
        i_b906    TYPE ty_t_b906,    " condition record
        i_b911    TYPE ty_t_b911,    " condition record "Added for D2
        i_bdcdata TYPE ty_t_bdcdata, " For bdc data
* ---> Begin of Insert for D3R3_Defect_4204 by U034334 on 21-02-18
        i_cdd_emi      TYPE ty_t_emi, " Enhancement Status for CDD
        i_einvoice_905 TYPE ty_t_einvoice,
        i_einvoice_906 TYPE ty_t_einvoice,
* <--- End   of Insert for D3R3_Defect_4204 by U034334 on 21-02-18

* Global Work area / structure declaration.
        wa_report TYPE ty_report,   " work area for report
        wa_error  TYPE ty_modify_e, " error report
        wa_final  TYPE ty_modify,   " final internal table

* Variable Declaration.
        gv_mode     TYPE char10,    " Mode of transaction
        gv_modify   TYPE localfile, " Input Data
        gv_scount   TYPE int2,      " Succes Count
        gv_ecount   TYPE int2.      " Error Count
CLASS   cl_abap_char_utilities DEFINITION LOAD. "Class for Characters
