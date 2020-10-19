************************************************************************
* PROGRAM    :  LZOTC_GET_SHP_DTE_N_QUAN_GTOP ( Top Include )          *
* TITLE      :  Get Order Status                                       *
* DEVELOPER  :  Abhishek Gupta3                                        *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D2_OTC_IDD_0092_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION:Global data declaration for FM ZOTC_GET_SHP_DTE_N_QUAN_FM*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 02-June-2014  AGUPTA3  E2DK900484 Initial Development                *
* 24-Sep-2014   AGUPTA3  E2DK900484 CR_167 (Tracking number will be    *
*                                    populated from VEKP-SPE_IDENT_01  *
*                                    instead of VEKP-EXIDV. )          *
* 22-Jan-2015   NBAIS    E2DK900484 Defect 3084/3086 – CR 447 (As per  *
*                                    defect 3084: Fpr Tracking no      *
*                                    instead of SPE IDENT 01           *
*                                    now we will check SPE IDENT 01,   *
*                                    SPE IDENT 02,SPE IDENT 03,        *
*                                    SPE IDENT 04.                     *
*                                    defect:3086:For 3rd Party delivery*
*                                    "Tracking number" will be populate*
*                                    by LIKP-LIFEX instead of BOLNR.   *
* 28-Apr-2015   MBAGDA  E2DK900484  Defect 6248                        *
*                                    Change field LIKP-WADAT to field  *
*                                    LIKP-LFDAT for Delivery Cases     *
*&---------------------------------------------------------------------*


FUNCTION-POOL zotc_get_shp_dte_n_quan_g. "MESSAGE-ID ..

* INCLUDE LZOTC_GET_SHP_DTE_N_QUAN_GD...     " Local class definition

TYPES: BEGIN OF ty_vbap,
          vbeln TYPE vbeln_va,   " Sales Document
          posnr TYPE posnr_va,   " Sales Document Item
          fkrel TYPE fkrel,      " Relevant for Billing
         END OF ty_vbap,

          BEGIN OF ty_vbup,
           vbeln TYPE vbeln,     " Sales and Distribution Document Number
           posnr TYPE posnr,     " Item number of the SD document
           gbsta TYPE gbsta,     " Overall processing status of the SD document item
          END OF ty_vbup,

          BEGIN OF ty_vbep,
            vbeln TYPE vbeln_va, " Sales Document
            posnr TYPE posnr_va, " Sales Document Item
            etenr TYPE etenr,    " Delivery Schedule Line Number
            edatu TYPE edatu,    " Schedule line date
            wmeng TYPE wmeng,    " Order quantity in sales units
            bmeng TYPE bmeng,    " Confirmed Quantity
            vrkme TYPE vrkme,    " Sales unit
          END OF ty_vbep,

         ty_t_vbep TYPE STANDARD TABLE OF ty_vbep,

          BEGIN OF ty_vbep1,
            vbeln TYPE vbeln_va, " Sales Document
            posnr TYPE posnr_va, " Sales Document Item
            wbstk TYPE wbstk,    " Total goods movement status
            etenr TYPE etenr,    " Delivery Schedule Line Number
            edatu TYPE edatu,    " Schedule line date
            bmeng TYPE bmeng,    " Confirmed Quantity
            vrkme TYPE vrkme,    " Sales unit
* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
            ztrack TYPE zotc_track_num, " Alternative HU Identification
*            ztrack TYPE /SPE/DE_IDENT,               " Alternative Handling Unit Identification
* ---> End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
          END OF ty_vbep1,

         ty_t_vbep1 TYPE STANDARD TABLE OF ty_vbep1, "table type for scheduline

           BEGIN OF ty_vbuk,
            vbeln TYPE vbeln,                        " Sales and Distribution Document Number
            wbstk TYPE wbstk,                        " Total goods movement status
           END OF ty_vbuk,

            BEGIN OF ty_likp,
              vbeln TYPE vbeln_vl,                   " Delivery
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 6248 – by MBAGDA
*             wadat TYPE wadak,                      " Planned goods movement date
              lfdat TYPE lfdat,                      " Delivery Date
* <--- End of Change for D2_OTC_IDD_0092_Defect 6248 by MBAGDA
              wadat_ist TYPE wadat_ist,              " Actual Goods Movement Date
             END OF ty_likp,

             BEGIN OF ty_lips,
               vbeln TYPE vbeln_vl,                  " Delivery
               posnr TYPE posnr_vl,                  " Delivery Item
               lfimg TYPE lfimg,                     " Actual quantity delivered (in sales units)
               vrkme TYPE vrkme,                     " Sales unit
              END OF ty_lips,

              BEGIN OF ty_vepo,
                venum	TYPE venum,                    "HU number
                vepos	TYPE vepos,                    "Handling Unit Item
                vbeln	TYPE vbeln_vl,                 "delivery doc
                posnr	TYPE posnr_vl,                 "delivery item
                END OF ty_vepo,

                BEGIN OF ty_vekp,
                  venum	TYPE venum,                  "Hu number
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
          spe_idart_01 TYPE /spe/de_huidart, "Handling Unit Identification Type

* ---> Begin of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
*                  EXIDV type EXIDV,
          spe_ident_01  TYPE /spe/de_ident, "Alternative HU identification
* <--- End of Change for D2_OTC_IDD_0092_CR_167 by AGUPTA3
          spe_idart_02 TYPE /spe/de_huidart,
          spe_ident_02 TYPE /spe/de_ident, "Alternative HU identification
          spe_idart_03 TYPE /spe/de_huidart,
          spe_ident_03 TYPE /spe/de_ident, "Alternative HU identification
          spe_idart_04 TYPE /spe/de_huidart,
          spe_ident_04 TYPE /spe/de_ident, "Alternative HU identification
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447   by NBAIS
                 END OF ty_vekp,

                 BEGIN OF ty_ekes,
                   ebeln  TYPE ebeln, " Purchasing Document Number
*                   ebelp  TYPE ebelp,                " Item Number of Purchasing Document
                   ebelp  TYPE posnr,    " Item number of the SD document
                   eindt  TYPE  bbein,   " Delivery Date of Vendor Confirmation
                   vbeln  TYPE vbeln_vl, " Delivery
                   vbelp TYPE posnr_vl,  " Delivery Item
                 END OF ty_ekes,

                 BEGIN OF ty_likp1,
                   vbeln TYPE vbeln_vl,  " Delivery
* ---> Begin of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
*                   bolnr TYPE bolnr,     " Bill of lading
                   lifex TYPE lifex,      "External Identification of Delivery Note
* <--- End of Change for D2_OTC_IDD_0092_Defect 3084/3086 – CR 447  by NBAIS
                   END OF ty_likp1,

                 BEGIN OF ty_status,
                   sign   TYPE ddsign,   " Type of SIGN component in row type of a Ranges type
                   option TYPE ddoption, " Type of OPTION component in row type of a Ranges type
                   low    TYPE wbstk,    " Total goods movement status
                   high   TYPE wbstk,    " Total goods movement status
                 END OF ty_status.

DATA: i_item_tmp     TYPE STANDARD TABLE OF ty_vbap,                "Sales Item
      i_item         TYPE STANDARD TABLE OF ty_vbap,                "Sales Item
      i_item_stat    TYPE STANDARD TABLE OF ty_vbup,                "Item status
      i_docflow      TYPE STANDARD TABLE OF vbfa,                   " Sales Document Flow
      i_docflow_tmp  TYPE STANDARD TABLE OF vbfa,                   " Sales Document Flow
      i_sch_line     TYPE STANDARD TABLE OF ty_vbep,                "Schedule line data
      i_sch_line_a TYPE STANDARD TABLE OF ty_vbep,                  "Schedule line data
      i_sch_line_b TYPE STANDARD TABLE OF ty_vbep,                  "Schedule line data
      i_sch_line_1 TYPE STANDARD TABLE OF ty_vbep,                  "Schedule line data
      i_delv_doc_b TYPE STANDARD TABLE OF ty_vbep1,                 "delivery document
      i_delv_doc_c TYPE STANDARD TABLE OF ty_vbep1,                 "delivery document
     i_slsdoc_stat TYPE STANDARD TABLE OF ty_vbuk,                  "document status
      i_sddelivhead_data TYPE STANDARD TABLE OF ty_likp,            "item delivery date data
      i_sddelivitm_data  TYPE STANDARD TABLE OF ty_lips,            "Item quantity data
      i_track_num        TYPE STANDARD TABLE OF ty_vekp,            "Tracking number
      i_huitem           TYPE STANDARD TABLE OF ty_vepo,            "Handling unit number
      i_schline_out      TYPE STANDARD TABLE OF zotc_get_schline,   " Schedule line data
      i_output           TYPE STANDARD TABLE OF zotc_get_delv_data, " Get delivery date and Quantity
      i_ib_delv          TYPE STANDARD TABLE OF ty_ekes,            "Inbound delivery
      i_bol              TYPE STANDARD TABLE OF ty_likp1,           "Bill of lading
      i_constant   TYPE STANDARD TABLE OF zdev_enh_status,          " Enhancement Status
      i_del_stat   TYPE STANDARD TABLE OF ty_status,                "delivery status
      i_ord_stat   TYPE STANDARD TABLE OF ty_status,                "Order status
      wa_output    TYPE zotc_get_delv_data,                         " Get delivery date and Quantity
      wa_schline_out TYPE zotc_get_schline,                         " Schedule line data
      wa_salesorder  TYPE vbco6,                                    " Sales Document Access Methods: Key Fields
      gv_flag        TYPE char1.                                    " Flag of type CHAR1
