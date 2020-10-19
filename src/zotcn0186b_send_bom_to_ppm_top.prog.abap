*&---------------------------------------------------------------------*
*&  Include           ZOTCN0186B_SEND_BOM_TO_PPM_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0186B_SEND_BOM_TO_PPM                             *
* TITLE      :  D2_OTC_IDD_0186_Send Sales BOM structure to PPM        *
* DEVELOPER  :  Sneha Ghosh                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 7.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_0186_Send Sales BOM structure to PPM             *
*----------------------------------------------------------------------*
* DESCRIPTION: The requirement is to send the BOM structure from SAP   *
* to PPM. From each Plant valid BOMs as on date will be extracted and  *
* stored in a flat file. This file subsequently will be uploaded to PPM*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 30-Sep-2015 MBAGDA   E2DK914957 Defect 1089: Replacing STKLN with    *
*                                 POSNR for BOM Item Number            *
* 15-Sep-2015 SGHOSH   E2DK914957 PGL- INITIAL DEVELOPMENT -           *
*                                 Task Number: E2DK915243,E2DK915041   *
*&---------------------------------------------------------------------*

*&--Type Declaration
TYPES: BEGIN OF ty_mast,
        matnr TYPE matnr,   " Material Number
        werks TYPE werks_d, " Plant
        stlan TYPE stlan,   " BOM Usage
       END OF ty_mast,

       BEGIN OF ty_final,
         matnr TYPE matnr,  " Material Number
         idnrk TYPE idnrk,  " BOM component
* ----> Begin of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
*        stlkn TYPE stlkn,    " BOM item node number-DELETE
         posnr TYPE sposn, " BOM item node number-INSERT
* <---- End of changes for Defect# 1089 by MBAGDA on 30-Sep-2015
         datuv TYPE dtvon,    " Valid-from/to date
         datub TYPE dtbis,    " Valid-to date
         menge TYPE kmpmg,    " Component quantity
         werks TYPE werks_d,  " Plant
       END OF ty_final,

       BEGIN OF ty_log,
         msgtyp TYPE char01,  " Message Type
         msgtxt TYPE char255, " Message Text
       END OF ty_log,

       BEGIN OF ty_data,
         data  TYPE string,   " Data
       END OF ty_data,

*&--Table Type Declaration
       ty_t_final TYPE STANDARD TABLE OF ty_final,
       ty_t_log   TYPE STANDARD TABLE OF ty_log,
       ty_t_data  TYPE STANDARD TABLE OF ty_data,
       ty_t_mast  TYPE STANDARD TABLE OF ty_mast.

*&--Data Declaration
DATA: gv_werks    TYPE werks_d,         " Plant
      gv_file     TYPE char50,          " Concatenated File name
      gv_pfile    TYPE localfile,       " Local file for upload/download
      gv_bomtyp   TYPE stlan VALUE '5', " BOM Usage
      i_mast      TYPE ty_t_mast,
      i_final     TYPE ty_t_final,
      i_log       TYPE ty_t_log,
      wa_log_err  TYPE ty_log,
      i_data      TYPE ty_t_data.

*&--Constant Declaration
CONSTANTS: c_bslash    TYPE char01 VALUE '\',    " Back Slash
           c_asc       TYPE char10 VALUE 'ASC',  " Asc of type CHAR10
           c_msgtyp_s  TYPE char01 VALUE 'S',    " Success
           c_msgtyp_e  TYPE char01 VALUE 'E',    " Error
           c_msgtyp_i  TYPE char01 VALUE 'I',    " Information
           c_pipe      TYPE char1 VALUE '|',     " Pipe of type CHAR1
           c_extn1     TYPE char05 VALUE '.txt', " Extn1 of type CHAR05
           c_extn      TYPE char05 VALUE 'TXT',     " Extn of type CHAR05
           c_mi2       TYPE char03 VALUE 'MI2',     " Mi3 of type CHAR03
           c_mi3       TYPE char03 VALUE 'MI3',     " Mi3 of type CHAR03
           c_mi4       TYPE char03 VALUE 'MI4',     " Mi3 of type CHAR03
           c_mi6       TYPE char03 VALUE 'MI6',     " Mi6 of type CHAR03
           c_mi9       TYPE char03 VALUE 'MI9',     " Mi9 of type CHAR03
           c_file_f    TYPE char07 VALUE 'P_AHDR',  " File_f of type CHAR07
           c_file_b    TYPE char07 VALUE 'P_AHDR1'. " File_b of type CHAR07
