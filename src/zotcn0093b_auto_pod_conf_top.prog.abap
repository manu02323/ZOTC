*&---------------------------------------------------------------------*
*&  Include           ZOTCN0093B_AUTO_POD_CONF_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCR0093B_AUTO_POD_CONF_TOP                           *
* TITLE      :  OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
* DEVELOPER  :  Sneha Mukherjee                                        *
* OBJECT TYPE:  Report                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_EDD_0093_AUTOMATE POD CONFIRMATION                 *
*----------------------------------------------------------------------*
* DESCRIPTION: A program which will run in background through batch job*
*              to identify POD relevant deliveries with zero quality and
*              run VLPOD transaction for those deliveries.             *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 02-Dec-13  SMUKHER   E1DK912327  INITIAL DEVELOPMENT                 *
* 14-Jan-14  SMUKHER   E1DK912327  CR#1229 Updated functionality to    *
*                                          update all deliveries as a  *
*                                          radio button                *
* 07-Mar-14  SMUKHER   E1DK912327  HPQC Defect 1229 - addition of 'Ship*
*                                  -ping Point Description' to the     *
*                                  ALV Output.                         *
*&---------------------------------------------------------------------*


*******TYPE DECLARATION

TYPES: BEGIN OF ty_likp,
       vbeln TYPE vbeln_vl, " Delivery
       ernam TYPE ernam, " Created by
       erzet TYPE erzet, " Time
       erdat TYPE erdat, " Created on
       vstel TYPE vstel, " Shipping Point/Receiving Pt
       vkorg TYPE vkorg, " Sales Organization
       lfart TYPE lfart, " Delivery Type
       inco1 TYPE inco1, " Incoterms
       vsbed TYPE vsbed, " Shipping Conditions
       kunnr TYPE kunwe, " Ship-to party
       kunag TYPE kunag, " Sold-to party
       wadat_ist TYPE wadat_ist, " Actual Goods Movement Date "CR#1229
       vlstk TYPE vlstk, "Distributed
       podat TYPE podat, " Date(Proof Of Delivery)
       potim TYPE potim, " Confirmation Time
       END OF ty_likp,

       BEGIN OF ty_lips,
       vbeln TYPE vbeln_vl, " Delivery
       posnr TYPE posnr_vl, " Delivery Item
       lfimg TYPE lfimg,    " Delivery quantity
       kzpod TYPE kzpod,    " POD indicator
       END OF ty_lips,

       BEGIN OF ty_vbup,
       vbeln TYPE vbeln,    " Sales and Distribution Document Number
       posnr TYPE posnr,    " Item number of the SD document
       wbsta TYPE wbsta,    " Goods movement status
       gbsta TYPE gbsta,    " Overall processing status of SD doc item
       pdsta TYPE pdsta,    " POD status on item level
       END OF ty_vbup,

       BEGIN OF ty_vbuk,
       vbeln TYPE vbeln,    " Sales and Distribution Document Number
       wbstk TYPE wbstk,    " Total goods movement status
       END OF ty_vbuk,

**&& -- BOC for CR#1229
       BEGIN OF ty_tinct,
       spras TYPE spras, " Language Key
       inco1 TYPE inco1, " Incoterms
       bezei TYPE bezei30, " Incoterms Description
       END OF ty_tinct,

       BEGIN OF ty_tvsbt,
       spras TYPE spras, " Language Key
       vsbed TYPE vsbed_bez, " Shipping Conditions
       vtext TYPE vtext, " Shipping Condition Description
       END OF ty_tvsbt,
**&& -- EOC for CR#1229

**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       BEGIN OF ty_tvstt,
       spras TYPE	spras, " Language Key
       vstel TYPE	vstel, " Shipping Point/Receiving Point
       vtext TYPE	bezei30, " Description
       END OF ty_tvstt,
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14

       BEGIN OF ty_final,
       cb_sel TYPE char1, "Checkbox
       vbeln TYPE vbeln_vl, " Delivery Number
       ernam TYPE ernam, " Created by
       erzet TYPE erzet, " Time
       erdat TYPE erdat, " Created on
       vstel TYPE vstel, " Shipping Point/Receiving Pt
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       vtext1 TYPE bezei30, " Shipping Point Description
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       vkorg TYPE vkorg, " Sales Organization
       lfart TYPE lfart, " Delivery Type
       inco1 TYPE inco1, " Incoterms
       vsbed TYPE vsbed, " Shipping Conditions
       kunnr TYPE kunwe, " Ship-to party
       kunag TYPE kunag, " Sold-to party
**&& -- BOC for CR#1229
       vtext TYPE vtext, " Shipping Condition Description
       bezei TYPE bezei, " Incoterms Description
       wadat_ist TYPE wadat_ist, " Actual Movement Date
**&& -- EOC for CR#1229
       wbsta TYPE wbsta, " Goods movement status
       gbsta TYPE gbsta, " Overall processing status of the SD document item
       END OF ty_final.


*******TABLE TYPE DECLARATION.
TYPES: ty_t_likp TYPE STANDARD TABLE OF ty_likp,      "table type declaration for LIKP
       ty_t_lips TYPE STANDARD TABLE OF ty_lips,      "table type declaration for LIPS
       ty_t_vbup TYPE STANDARD TABLE OF ty_vbup,      "table type declaration for VBUP
       ty_t_vbuk TYPE STANDARD TABLE OF ty_vbuk,      "table type declaration for VBUK
**&& -- BOC for CR#1229
       ty_t_tinct TYPE STANDARD TABLE OF ty_tinct,    "table type declaration for TINCT
       ty_t_tvsbt TYPE STANDARD TABLE OF ty_tvsbt,    "table type declaration for TVSBT
**&& -- EOC for CR#1229
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       ty_t_tvstt TYPE STANDARD TABLE OF ty_tvstt,    "table type declaration for TVSTT
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       ty_t_final TYPE STANDARD TABLE OF ty_final,    "table type declaration for FINAL

       ty_bdcdata TYPE bdcdata,                         "BDC Data
       ty_bdcmsgcoll TYPE bdcmsgcoll,                       " BDC message
       ty_t_bdcdata TYPE STANDARD TABLE OF ty_bdcdata,  "BDC Data
       ty_t_bdcmsgcoll  TYPE STANDARD TABLE OF ty_bdcmsgcoll.   " BDC message

*******INTERNAL TABLE DECLARATION.
DATA : i_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0,            "internal table for LIKP
       i_lips TYPE STANDARD TABLE OF ty_lips INITIAL SIZE 0,            "internal table for LIPS
       i_vbup TYPE STANDARD TABLE OF ty_vbup INITIAL SIZE 0,            "internal table for VBUP
       i_vbuk TYPE STANDARD TABLE OF ty_vbuk INITIAL SIZE 0,            "internal table for VBUK
**&& -- BOC for CR#1229
       i_tinct TYPE STANDARD TABLE OF ty_tinct INITIAL SIZE 0,           "internal table for TINCT
       i_tvsbt TYPE STANDARD TABLE OF ty_tvsbt INITIAL SIZE 0,           "internal table for TVSBT
**&& -- EOC for CR#1229
**&& -- BOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       i_tvstt TYPE STANDARD TABLE OF ty_tvstt INITIAL SIZE 0,          "internal table for TVSTT
**&& -- EOC : HPQC Defect 1229 : SMUKHER : 07-MAR-14
       i_final TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0,          "internal table for FINAL

********Defining variables for select options

       gv_inco1 TYPE inco1,              "Incoterms(Part 1).
       gv_vsbed TYPE vsbed,              "Shipping Conditions
       gv_erdat TYPE erdat,              "Created On

*******ALV DATA DECLARATION

       i_fieldcat   TYPE  slis_t_fieldcat_alv. "Fieldcatalog Internal tab

********Constants Declaration
CONSTANTS: gc_save TYPE char1 VALUE 'A'.     " I_SAVE
