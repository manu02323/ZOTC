***********************************************************************
*Program    : ZOTCN0344B_TRANSFER_BATCH_TOP                           *
*Title      : Include for global data declaration                     *
*Developer  : Ayushi Jain                                             *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0344                                           *
*---------------------------------------------------------------------*
*Description:Utility program to upload batch data in custom table     *
*            ZOTC_REST_BATCH and also update prject master table in   *
*            GTS table with batch data.                               *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*17-JUN-2016  U033830       E1DK918373     Initial Development        *
*25-JULY-2016 SBEHERA       E1DK918373      Defect#2932: 1.Changed By,*
*                           Changed On, and Changed Time  - To be auto*
*                           updated and to be Grey-out in display and *
*                           change mode on maintenance screen         *
*                                           2.Created By, Created On, *
*                           and Created Time  - To be auto updated and*
*                           to be Grey-out in display and change mode *
*                           on  maintenance screen.                   *
*                                           3. FUT Issue fixed        *
*---------------------------------------------------------------------*

TYPES:
*      Final Report Display Structure
       BEGIN OF ty_report,
        msgtyp  TYPE char1,     " Message Type
        msgtxt  TYPE string,    " Message Text
        key     TYPE string,    " Message Key
       END OF ty_report,

       BEGIN OF ty_matnr,
         matnr TYPE matnr,      " Material Number
         END OF ty_matnr,

       BEGIN OF ty_kunnr,
         kunnr TYPE kunnr,      " Customer Number
         END OF ty_kunnr,

       BEGIN OF ty_charg,
         matnr TYPE matnr,      " Material Number
         charg TYPE charg_d,    " Batch Number
         END OF ty_charg,

       BEGIN OF ty_land1,
         land1 TYPE aland,      " Departure country (country from which the goods are sent)
         END OF ty_land1,

       BEGIN OF ty_batch,
         matnr TYPE matnr,      " Material Number
         charg TYPE charg_d,    " Batch Number
         land1 TYPE land1,      " Country Key
         kunnr TYPE kunnr,      " Customer Number
       END OF ty_batch,
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
       BEGIN OF ty_batch1,
         matnr TYPE matnr,      " Material Number
         charg TYPE charg_d,    " Batch Number
         land1 TYPE land1,      " Country Key
         kunnr TYPE kunnr,      " Customer Number
         remarks TYPE z_remarks," Remarks
         row   TYPE string,     " Row Number
       END OF ty_batch1,
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
       BEGIN OF ty_gts_batch,
         mandt TYPE mandt,      " Client
         guid_lcpro TYPE raw16, " RAW16
         pronr TYPE char20,     " Pronr of type CHAR20
         ernam TYPE char12,     " Ernam of type CHAR12
         crtsp TYPE dec15,      " Packed field
         aenam TYPE char12,     " Aenam of type CHAR12
         chtsp TYPE dec15,      " Packed field
       END OF ty_gts_batch,

* Table Type Declaration
        ty_t_batch TYPE STANDARD TABLE OF zotc_rest_batch,  " Restricted Batch Table
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        ty_t_batch1 TYPE STANDARD TABLE OF ty_batch1,       " Batch Table
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        ty_t_report TYPE STANDARD TABLE OF ty_report,       " Report
        ty_t_final  TYPE STANDARD TABLE OF zotc_rest_batch. " For Final Data

* Constants
CONSTANTS:
        c_ext        TYPE string   VALUE  'XLS',                                 " File Extension
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        c_ext1       TYPE string   VALUE  'XLSX',                                " File Extension
        c_ext2       TYPE string   VALUE  'TXT',                                 " File Extension
        c_inform     TYPE char1    VALUE  'I',                                   " Information Indicator
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        c_error      TYPE char1    VALUE  'E',                                   " Error Indicator
        c_success    TYPE char1    VALUE  'S',                                   " Success Indicator
        c_slash      TYPE char1    VALUE  '/',                                   " For slash
        c_tab        TYPE char1    VALUE cl_abap_char_utilities=>horizontal_tab, " TAB value
        c_crlf       TYPE char1    VALUE cl_abap_char_utilities=>cr_lf.          " Carriage Return and Line Feed  Character Pair

* Internal Table Declaration.
DATA:   i_batch   TYPE ty_t_batch,  " For Input data
* ---> Begin of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        i_batch1  TYPE ty_t_batch1," For Input data
* <--- End of Insert for D3_OTC_EDD_0344_Defect#2932 by SBEHERA
        i_report  TYPE ty_t_report, " Report Internal Table
        i_final   TYPE ty_t_final,  " For Final Data

* Global Work area / structure declaration.
        wa_report TYPE ty_report, " Log Report

* Variable Declaration
        gv_mode        TYPE char10,     " Mode of transaction
        gv_file        TYPE localfile,  " Input Data
        gv_scount      TYPE int2,       " Succes Count
        gv_ecount      TYPE int2,       " Error Count
        gv_dest_system TYPE rfcdest,    " Logical Destination (Specified in Function Call)
        gv_codepage    TYPE cpcodepage. " SAP Character Set ID

* Class declaration
CLASS   cl_abap_char_utilities DEFINITION LOAD. " Class for Characters
