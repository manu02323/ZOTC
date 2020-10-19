*&---------------------------------------------------------------------*
*&  Include           ZOTCN0156B_BATCH_DETER_TOP
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* PROGRAM    : ZOTCC0156_BATCH_DETER                                   *
* TITLE      :D3_OTC_CDD_0156_Convert Batch Determination Records      *
* DEVELOPER  : Jahan Mazumder
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID: D3_OTC_CDD_0156
*----------------------------------------------------------------------*
* DESCRIPTION: Convert Batch Determination Records                     *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER     TRANSPORT  DESCRIPTION                         *
* ===========  ======== ========== ====================================*
*06/01/2016   U029639   E1DK917995 Initial Development
*
*----------------------------------------------------------------------*
* Final Report Display Structure
TYPES : BEGIN OF ty_report,
       msgtyp TYPE char1,  "Message Type E / S
       msgtxt TYPE string, "Message Text
       key    TYPE string, "Key of message
      END OF ty_report,

      BEGIN OF ty_tab,
        input_line TYPE string,
      END OF ty_tab,

      BEGIN OF ty_final,
        kschl   TYPE kschg,    " Material listing/exclusion type
        kotabnr TYPE kotabnr,  " Condition table
        vkorg   TYPE vkorg,    " Sales Organization
        vtweg   TYPE vtweg,    " Distribution Channel
        lgnum   TYPE lgnum,    " Warehouse Number / Warehouse Complex
        matnr   TYPE matnr,    " Material Number
        mvgr2   TYPE mvgr2,    " Material Group 2
        bwart   TYPE bwart,    " Movement Type
        kunwe   TYPE kunwe,    " Ship-to party
        kunnr   TYPE kunnr,    " Sold-to party
        auart   TYPE auart,    " Sales Document Type
        werks   TYPE werks_d,  " Plant
        charg   TYPE charg_d,  " Batch Number
        datbi   TYPE char10,   " Validity end date of the condition record
        datab   TYPE char10,   " Validity start date of the condition record
        land1   TYPE lland,    " Country of Destination
        chasp   TYPE chasp,    " Batches: No. of batch splits allowed
        chspl   TYPE chspl,    " Batch split allowed
        chmdg   TYPE chmdg,    " Batches: Dialog batch determination
        kzame   TYPE kzame,    " ID for display of UoM in batch determination
        chmvs   TYPE chmvs,    " Batches: Exit to quantity proposal
        chvll   TYPE chvll,    " Overdelivery allowed in batch determination
        chvsk   TYPE chvsk,    " Selection type at start of batch determination
        srtsq   TYPE rcusrts,  " Sort sequence
        loevm   TYPE loevm_ko, " Deletion Indicator for Condition Item
        klass   TYPE klasse_d, " Class number
        atnam   TYPE atnam,    " Characteristic Name
        atwrt   TYPE atwrt,    " Characteristic Value
     END OF ty_final,

***Structure for error file
     BEGIN OF ty_error,
        kschl  TYPE kschg,   "Material listing/exclusion type
        vkorg  TYPE vkorg,   "Sales Organization
        vtweg  TYPE vtweg,   "Distribution Channel
        werks  TYPE werks_d, "Plant
        matnr  TYPE matnr,   "Material Number
        mvgr2  TYPE mvgr2,   "Distribution Channel
        bwart  TYPE bwart,   "Distribution Channel
        kunwe  TYPE kunwe,   "Ship-to party
        kunnr  TYPE kunag,   "Sold-to party
        auart  TYPE auart,   "Distribution Channel
        lgnum  TYPE lgnum,   "Distribution Channel
        land1  TYPE lland,   "Country of Destination
        charg  TYPE charg_d, "Batch Number
        datbi  TYPE char10,  "Validity end date of the condition record
        datab  TYPE char10,  "Validity start date of the condition record
        errmsg TYPE string,
     END OF ty_error.

**Table Type declaration
TYPES: ty_t_report    TYPE STANDARD TABLE OF ty_report INITIAL SIZE 0, " Report
       ty_t_final     TYPE STANDARD TABLE OF ty_final INITIAL SIZE 0,
       ty_t_error     TYPE STANDARD TABLE OF ty_error INITIAL SIZE 0,
       ty_t_bdcdata   TYPE STANDARD TABLE OF bdcdata   INITIAL SIZE 0. " For bdc data

* Constants
CONSTANTS :c_text      TYPE char3 VALUE 'TXT',                        "Extension .TXT
           c_file_type TYPE char10 VALUE 'ASC',                       "ASC
           c_lp_ind    TYPE char1 VALUE 'X',                          "X = Logical File Path
           c_tab       TYPE char1 VALUE                               " Tab of type CHAR1
                              cl_abap_char_utilities=>horizontal_tab, " Tab
           c_group     TYPE apqi-groupid VALUE 'OTC_0156',            " Session Name
           c_date      TYPE char10 VALUE '12/31/9999',                  " End date
           c_kzame     TYPE char1 VALUE 'B',                          "Display UoM dafult to B
           c_chmvs     TYPE char1 VALUE '1',                          " Quant proposal default to 1
           c_emsg      TYPE char1 VALUE 'E',                          " constant declaration for 'E' error message type
           c_fslash    TYPE char1 VALUE '/',                          " Forward slash
           c_error     TYPE char1 VALUE 'E',                          "Success Indicator
           c_tcode     TYPE tstc-tcode VALUE 'VCH1',                  " Tcode name
           c_tbp_fld   TYPE char5 VALUE 'TBP',                        " constant declaration for TBP folder
           c_done_fld  TYPE char5 VALUE 'DONE',                       " constant declaration for DONE folder.
           c_error_fld TYPE char5 VALUE 'ERROR',                      " constant declaration ERROR folder
           c_smsg      TYPE char1 VALUE 'S',                          " constant declaration for 'S' success message type
           c_rbselected TYPE char1 VALUE 'X',                         " constant declaration for radio button selected
           c_key_com1  TYPE char3    VALUE '916',
           c_key_com2  TYPE char3    VALUE '917',
           c_key_com3  TYPE char3    VALUE '920',
           c_key_com4  TYPE char3    VALUE '906',
           c_key_com5  TYPE char3    VALUE '907',
           c_key_com6  TYPE char3    VALUE '915',
           c_key_com7  TYPE char3    VALUE '905',
           c_key_com8  TYPE char3    VALUE '908',
           c_key_com9  TYPE char3    VALUE '921',
           c_key_com10 TYPE char3    VALUE '922'.


* Variable Declaration.
DATA: gv_save     TYPE char1,      "= X for Post; = Space for Verify Only
      gv_file     TYPE localfile,  "File name
      gv_mode     TYPE char10,     "Mode of transaction
      gv_scount   TYPE int2,       " Succes Count
      gv_ecount   TYPE int2,       " Error Count
      gv_codepage TYPE cpcodepage, " SAP Character Set ID   "
      gv_flg1     TYPE char1,      " Flg1 of type CHAR1
      gv_flg2     TYPE char1,      " Flg2 of type CHAR1
      gv_flg3     TYPE char1,      " Flg3 of type CHAR1
      gv_flg4     TYPE char1,      " Flg4 of type CHAR1
      gv_flg5     TYPE char1,      " Flg4 of type CHAR1
      gv_flg6     TYPE char1,      " Flg4 of type CHAR1
      gv_flg7     TYPE char1,      " Flg7 of type CHAR1
      gv_flg8     TYPE char1,      " Flg8 of type CHAR1
      gv_flg9     TYPE char1,      " Flg9 of type CHAR1
      gv_flg10    TYPE char1,      " Flg9 of type CHAR1   "
      gv_flg11    TYPE char1,      " Flg9 of type CHAR1   "
      gv_key_comb TYPE kotabnr.

*WorkArea
DATA: wa_report TYPE ty_report, " Report
      wa_final  TYPE ty_final,
      wa_error  TYPE ty_error.

**Internal Tables
DATA: i_final  TYPE STANDARD TABLE OF ty_final,
      i_error  TYPE STANDARD TABLE OF ty_error,
      i_valid  TYPE STANDARD TABLE OF ty_final,
      i_report TYPE ty_t_report, "Report table
      i_bdcdata TYPE ty_t_bdcdata,
      i_fs_tab TYPE STANDARD TABLE OF ty_tab.

FIELD-SYMBOLS:   <fs_tab> TYPE ANY TABLE.
