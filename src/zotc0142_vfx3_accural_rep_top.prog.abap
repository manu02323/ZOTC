*&--------------------------------------------------------------------*
*&  Include           ZOTC0142_VFX3_ACCURAL_REP_TOP
*&--------------------------------------------------------------------*
*Program    : ZOTC0142_VFX3_ACCURAL_REP                               *
*Title      : D3_OTC_RDD_0142_VFX3_Accural Report                     *
*Developer  : ShivaNagh Samala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_RDD_0142                                          *
*---------------------------------------------------------------------*
*Description: Batch Master Date 1 Report                              *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ===========================*
*30-May-2019   U105235      E2DK924302     SCTASK0833109:Initial      *
*                                          development                *
*---------------------------------------------------------------------*
*16-July-2019  U105235     E2DK925308      Defect#10042 Item Category *
*                               description field value is truncating *
*---------------------------------------------------------------------*
*23-Aug-2019   U033959     E2DK926218      Defect#10303               *
*                                     1. Net value -ve sign should be *
*                                        shown at begining during back*
*                                        -ground processing           *
*                                     2. Material Group 1 and Acc     *
*                                        Assign Grp to be fetched     *
*                                        from VBRP instead of VBAP    *
*---------------------------------------------------------------------*
*&--------------------------------------------------------------------*

TYPE-POOLS : slis.
TABLES : vbrk.

TYPES : BEGIN OF ty_vbrk_vbrp,
         vbeln      TYPE vbeln_vf,      "Billing Document
         fkart      TYPE fkart,         "Billing Type
         waerk      TYPE waerk,         "SD Document Currency
         vkorg      TYPE vkorg,         "Sales Organization
         vtweg      TYPE vtweg,         "Distribution Channel
         fkdat      TYPE fkdat,         "Billing Date for Billing Index and Printout
         rfbsk      TYPE rfbsk,         "Status for transfer to accounting
         erdat      TYPE erdat,         "Date on Which Record Was Created
         kunrg      TYPE kunrg,         "Payer
         kunag      TYPE kunag,         "Sold-To Party
        posnr       TYPE posnr_vf,       "Billing item
        uepos       TYPE uepos,          "Higher-level item in bill of material structures
        gewei       TYPE gewei,
        netwr       TYPE netwr_fp,
        vgbel       TYPE vgbel,          "Document Number of the Reference Document
        vgpos       TYPE vgpos,          "Item Number of the Reference Item
        aubel       TYPE vbeln_va,       "Sales Document
        aupos       TYPE posnr_va,       "Sales Document Item
        matnr       TYPE matnr,          "Material Number
        arktx       TYPE arktx,          "Short text for sales order item
        pstyv       TYPE pstyv,          "Sales Document Item Category
        werks       TYPE werks_d,        "Plant
*---> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
        ktgrm       TYPE ktgrm,          "Account assignment group for this material
*<--- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
        prctr       TYPE prctr,          "Profit Center
*---> Begin of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
        mvgr1       TYPE mvgr1,          "Material group 1
*<--- End of Insert for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
        mwsbp       TYPE mwsbp,          "Tax amount in document currency
        END OF ty_vbrk_vbrp,
        BEGIN OF ty_tvap,
        pstyv       TYPE pstyv,          "Sales Document Item Category
        fkrel       TYPE fkrel,          "Relevant for Billing
        kowrr       TYPE kowrr,          "Statistical values
        rrrel       TYPE rr_reltyp,      "
        END OF ty_tvap,
        BEGIN OF ty_tvapt,
         spras      TYPE spras,         "Language Key
         pstyv      TYPE pstyv,         "Sales Document Item Category
         vtext      TYPE bezei20,       "Description
        END OF ty_tvapt,
        BEGIN OF ty_tvfkt,
         spras      TYPE spras,         "Language Key
         fkart      TYPE fkart,         "Billing Type
         vtext      TYPE bezei20,       "Description
        END OF ty_tvfkt,
        BEGIN OF ty_dd07t,
         domname    TYPE domname,       "Domain name
         ddlanguage TYPE ddlanguage,    "Language Key
         ddtext     TYPE val_text,      "Short Text for Fixed Values
         domvalue_l TYPE domvalue_l,    "Values for Domains: Single Value / Upper Limit
        END OF  ty_dd07t,
         BEGIN OF ty_statv,
         domname    TYPE domname,       "Domain name
         ddlanguage TYPE ddlanguage,    "Language Key
         ddtext     TYPE val_text,      "Short Text for Fixed Values
         domvalue_l TYPE domvalue_l,    "Values for Domains: Single Value / Upper Limit
        END OF  ty_statv,
        BEGIN OF ty_fkrel,
         domname    TYPE domname,       "Domain name
         ddlanguage TYPE ddlanguage,    "Language Key
         ddtext     TYPE val_text,      "Short Text for Fixed Values
         domvalue_l TYPE domvalue_l,    "Values for Domains: Single Value / Upper Limit
        END OF  ty_fkrel,
        BEGIN OF ty_tvkmt,
         spras      TYPE spras,         "Language Key
         ktgrm      TYPE ktgrm,         "Account assignment group for this material
         vtext      TYPE bezei20,       "Description
        END OF ty_tvkmt,
        BEGIN OF ty_tvm1t,
         spras      TYPE spras,         "Language Key
         mvgr1      TYPE mvgr1,         "Material group 1
         bezei      TYPE bezei40,       "Description
        END OF ty_tvm1t,
        BEGIN OF ty_vbreve,
         vbeln      TYPE vbeln_va,      "Sales Document
         posnr      TYPE posnr_va,      "Sales Document Item
         sakrv      TYPE saknr,         "G/L Account Number
         bdjpoper   TYPE rr_bdjpoper,   "Posting year and posting period (YYYYMMM format)
         popupo     TYPE rr_popupo,     "Period sub-item
         vbeln_n    TYPE vbeln_nach,    "Subsequent sales and distribution document
         posnr_n    TYPE posnr_nach,    "Subsequent item of an SD document
         rrsta      TYPE rr_status,     "Revenue determination status
        END OF ty_vbreve,
        BEGIN OF ty_vbuk,
         vbeln      TYPE vbeln,         "Sales and Distribution Document Number
         pdstk      TYPE pdstk,         "POD status on header level
        END OF ty_vbuk,
        BEGIN OF ty_vbap,
          vbeln     TYPE vbeln_va,      "Sales Document
          posnr     TYPE posnr_va,      "Sales Document Item
          ktgrm     TYPE ktgrm,         "Account assignment group for this material
          mvgr1     TYPE mvgr1,         "Material group hierarchy 1
        END OF ty_vbap,
        BEGIN OF ty_likp,
          vbeln     TYPE vbeln_vl,      "Delivery
          vkoiv     TYPE vkoiv,         "Sales organization for intercompany billing
          vtwiv     TYPE vtwiv,         "Distribution channel for intercompany billing
          kuniv     TYPE kuniv,         "Customer number for intercompany billing
          wadat_ist TYPE wadat_ist,     "Actual Goods Movement Date
          podat     TYPE podat,         "Date (proof of delivery)
         END OF ty_likp,
         BEGIN OF ty_final,
         vkorg      TYPE vkorg,         "Sales Organization
         vtweg      TYPE vtweg,         "Distribution Channel
         vbeln      TYPE vbeln_vf,      "Billing Document
         posnr      TYPE posnr_vf,      "Billing item
         uepos      TYPE uepos,         "Higher-level item in bill of material structures
         fkart      TYPE fkart,         "Billing Type
         vtext      TYPE bezei20,       "Billing Type Description
         fkdat      TYPE fkdat,         "Billing Date for Billing Index and Printout
         erdat      TYPE erdat,         "Date on Which Record Was Created
         netwr      TYPE netwr_fp,      "Net weight
         waerk      TYPE waerk,         "SD Document Currency
         vgbel      TYPE vgbel,         "Document Number of the Reference Document
         vgpos      TYPE vgpos,         "Item Number of the Reference Item
         aubel      TYPE vbeln_va,      "Sales Document
         aupos      TYPE posnr_va,      "Sales Document Item
         matnr      TYPE matnr,         "Material Number
         arktx      TYPE arktx,         "Short text for sales order item
         pstyv      TYPE pstyv,         "Sales Document Item Category
         vtext_it   TYPE dd03p-scrtext_l,"Item Category Description
         werks      TYPE werks_d,       "Plant
         prctr      TYPE prctr,         "Profit Center
         mwsbp      TYPE mwsbp,         "Tax amount in document currency
         rfbsk      TYPE rfbsk,         "Status for transfer to accounting
*Begin of code changes - Defect 10042 - ShivaNagh Samala - July 16-2019
*         vtext_bil  TYPE dd03p-scrtext_l,"Posting status description
         vtext_bil  TYPE val_text,     "Posting status description
*End of code changes - Defect 10042 - ShivaNagh Samala - July 16-2019
         podat      TYPE podat,         "Date (proof of delivery)
         wadat_ist  TYPE wadat_ist,     "Actual Goods Movement Date
         pdstk      TYPE pdstk,         "POD status on header level
         rrsta      TYPE rr_status,     "Revenue determination status
         kunag      TYPE kunag,         "Sold-To Party
         kunrg      TYPE kunrg,         "Payer
         text_pod   TYPE dd03p-scrtext_l,"Relevant for POD
         text_revc  TYPE dd03p-scrtext_l,"Rev Recog Status
         mvgr1      TYPE mvgr1,         "Material group 1
         bezei      TYPE bezei40,       "Description
         ktgrm      TYPE ktgrm,         "Account assignment group for this material
         vtext_acc  TYPE dd03p-scrtext_l,"Description
         vkoiv      TYPE vkoiv,         "Sales organization for intercompany billing
         vtwiv      TYPE vtwiv,         "Distribution channel for intercompany billing
         kuniv      TYPE kuniv,         "Customer number for intercompany billing
         gewei      TYPE gewei,         "Weight Unit
         END OF ty_final,
         ty_t_final   TYPE STANDARD TABLE OF ty_final.
   DATA : i_tvap      TYPE STANDARD TABLE OF ty_tvap,
          i_tvfkt     TYPE STANDARD TABLE OF ty_tvfkt,
          i_vbuk      TYPE STANDARD TABLE OF ty_vbuk,
          i_dd07t     TYPE STANDARD TABLE OF ty_dd07t,
          i_statv     TYPE STANDARD TABLE OF ty_statv,
          i_fkrel     TYPE STANDARD TABLE OF ty_fkrel,
*---> Begin of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*          i_tvm1t     TYPE STANDARD TABLE OF ty_tvm1t,
*<--- End of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
          i_vbap      TYPE STANDARD TABLE OF ty_vbap,
          i_likp      TYPE STANDARD TABLE OF ty_likp,
          i_vbreve    TYPE STANDARD TABLE OF ty_vbreve,
          i_tvapt     TYPE STANDARD TABLE OF ty_tvapt,
*---> Begin of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
*          i_tvkmt     TYPE STANDARD TABLE OF ty_tvkmt,
*<--- End of Delete for D3_OTC_RDD_0142 defect#10303 by U033959 dated 23-AUG-2019
          i_final     TYPE STANDARD TABLE OF ty_final,
          i_vbrk_vbrp  TYPE STANDARD TABLE OF ty_vbrk_vbrp,
          i_vbrk_vbrp_temp TYPE STANDARD TABLE OF ty_vbrk_vbrp,
          gv_flag      TYPE  char1,
          gv_spono     TYPE tsp01-rqident,
          v_date       TYPE char10,          "date variable
          v_time       TYPE char10,          "time variable
          wa_final     TYPE ty_final,
          wa_layo      TYPE slis_layout_alv, "work area
          i_fieldcat   TYPE slis_t_fieldcat_alv,
          i_listheader TYPE slis_t_listheader,                " List header internal tab
          i_msg_att    TYPE STANDARD TABLE OF solisti1 ,
          wa_msg_att   TYPE solisti1,
          wa_listheader TYPE slis_listheader."list header


    CONSTANTS : c_rfbsk      TYPE char5   VALUE 'RFBSK',
                c_statv      TYPE char5   VALUE 'STATV',
                c_fkrel      TYPE char5   VALUE 'FKREL',
                c_y          TYPE char1   VALUE 'Y',
                c_e          TYPE char1   VALUE 'E',
                c_d          TYPE char1   VALUE 'D',
                c_c          TYPE char1   VALUE 'C',
                c_u          TYPE char1   VALUE 'U',
                c_n          TYPE char1   VALUE 'N',
                c_x          TYPE char1   VALUE 'X',
                c_m          TYPE char1   VALUE 'M',
                c_xyz        TYPE char3   VALUE 'XYZ',
                c_abc        TYPE char3   VALUE 'ABC',
                c_typ_h      TYPE char1   VALUE 'H',
                c_typ_s      TYPE char1   VALUE 'S',
                c_colon      TYPE char1   VALUE ':', "Colon
                c_slash      TYPE char1   VALUE '/', "Slash
                c_text       TYPE char6   VALUE 'P_TEXT',
                c_path       TYPE char6   VALUE 'P_PATH',
                c_date       TYPE char12  VALUE 'S_FKDAT-HIGH',
                lc_a         TYPE char1   VALUE 'A',
                c_no         TYPE char2   VALUE 'NO',
                c_yes        TYPE char3   VALUE 'YES',
                c_255        TYPE char3   VALUE '255',
                lc_top_page  TYPE slis_formname VALUE 'F_TOP_OF_PAGE'.
