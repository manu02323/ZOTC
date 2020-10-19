***********************************************************************
*Program    : ZOTCN0093B_SEND_PRICE_LIST_TOP                          *
*Title      : Send Price List                                         *
*Developer  : Salman Zahir                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0093                                           *
*---------------------------------------------------------------------*
*Description: This interface program send  price list to application  *
*             server in a text file format                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*22-NOV-2016    U033959     E1DK918891      Initial development for   *
*                                           CR#249 and CR#255         *
*---------------------------------------------------------------------*

CONSTANTS : c_groupmi2     TYPE  char3          VALUE 'MI2',             " constant forscreen group2
            c_groupmi3     TYPE  char3          VALUE 'MI3',             " constant forscreen group3
            c_groupmi5     TYPE  char3          VALUE 'MI5',             " constant forscreen group5
            c_groupmi7     TYPE  char3          VALUE 'MI7',             " constant forscreen group7
            c_true         TYPE  boolean        VALUE 'X',               " check flag
            c_one          TYPE  char1          VALUE '1',               " constant forscreen active
            c_zero         TYPE  char1          VALUE '0',               " Constant forscreen inactive
            c_app          TYPE  kappl          VALUE 'V',               " Application
            c_cond_use     TYPE  kvewe          VALUE 'A',               " Usage of the condition table
            c_enh_idd_0093 TYPE  z_enhancement  VALUE 'D2_OTC_IDD_0093'. " Enhancement No.

TYPES : BEGIN OF ty_price_list,
          kunag     TYPE kunag,      " Sold-to party
          kunwe     TYPE kunwe,      " Ship-to party
          country   TYPE land1,      " Country Key
          matnr     TYPE matnr,      " Material Number
          datab     TYPE kodatab,    " Validity start date of the condition record
          datbi     TYPE kodatbi,    " Validity end date of the condition record
          kbetr     TYPE kbetr_kond, " Rate (condition amount or percentage) where no scale exists
          konwa     TYPE konwa,      " Rate unit (currency or percentage)
          inactive  TYPE char1,      " Inactive of type CHAR1
        END OF ty_price_list,
        BEGIN OF ty_final,
*         line TYPE char100, " Final record-DEL-DEEP
          line TYPE char120,                             " Final record-INS-DEEP
        END OF ty_final,
        ty_t_final      TYPE STANDARD TABLE OF ty_final. " Table type for final table

DATA : i_final      TYPE ty_t_final ##needed. " Internal table for Final

DATA : gv_vkorg TYPE vkorg,               " Sales Organization
       gv_vtweg TYPE vtweg,               " Distribution Channel
       gv_matnr TYPE matnr,               " Material Number
       gv_kunag TYPE kunag,               " Sold-to party
       gv_kunwe TYPE kunwe,               " Ship-to party
       gv_file  TYPE localfile ##needed,  " Local file for upload/download
       gv_lines TYPE int4      ##needed , " Natural Number
       gv_dcp_flag TYPE char1.            "(+) ddwivedi on 06-Dec-2016 CR#255-2
*SOC by ddwivedi on 06-Dec-2016 CR#255-2
DATA : git_status       TYPE STANDARD TABLE OF  zdev_enh_status, " Enhancement Status
       gv_key_date      type sy-datum.
CONSTANTS : gc_delcp  TYPE name_feld VALUE 'DELETECP',                   " Field name
            gc_enh_idd_0093 TYPE  z_enhancement  VALUE 'D2_OTC_IDD_0093'. " Enhancement No." Field name
*EOC by ddwivedi on 06-Dec-2016 CR#255-2
