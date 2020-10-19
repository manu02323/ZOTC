*&---------------------------------------------------------------------*
*&  Include           ZOTCN0216B_SEND_TRAN_PRICE_TOP
***********************************************************************
*Program    : ZOTCI0216B_SEND_TRANSFER_PRICE                          *
*Title      : D3_OTC_IDD_0216_SEND TRANSFER PRICE TO EXTERNAL SYSTEM  *
*Developer  : Amlan mohapatra                                         *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_IDD_0216                                          *
*---------------------------------------------------------------------*
*Description: SEND TRANSEFER PRICE TO EXTERNAL  SYSTEM                *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport         Description
*=========== ============== ============== ===========================*
*02-NOV-2017   AMOHAPA      E1DK931691        Initial development      *
*22-DEC-2017   AMOHAPA      E1DK931691       FUT_ISSUE: MVKE needs to  *
*                                            be filtered from EMI entry*
*                                            Distribution-chain-specif-*
*                                            ic material status        *
*21-MAR-2018   AMOHAPA      E1DK931691       FUT_ISSUE:1) Instead of   *
*                                            Net Price, bussiness wants*
*                                            to see Net Value          *
*                                            2)Instead of Pricing unit *
*                                            bussiness wants to see    *
*                                            Bill Quantity             *
*                                            3)Instead of sales unit   *
*                                            Base unit of measurement  *
*                                            should be considered      *
*23-MAR-2018   AMOHAPA      E1DK931691       FUT_ISSUE: Material type  *
*                                            has been added in the     *
*                                            selection screen and      *
*                                            material are filltered    *
*                                            from entries of MARA      *
*18-Apr-2018   AMOHAPA      E1DK931691       Defect#5759: CDPOS-TABKEY *
*                                            entries are different for *
*                                            MBEW and MVKE             *
*                                            So to avoid the difference*
*                                            we have removed TAKEY from*
*                                            selection from CDPOS      *
*----------------------------------------------------------------------*


"Global Structure decalartion

TYPES: BEGIN OF ty_mvke,
       matnr  TYPE matnr, "Material Number
       vkorg  TYPE vkorg, "Sales Organization
       vtweg  TYPE vtweg, "Distribution Channel
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
       vmsta  TYPE vmsta, " Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
       dwerk  TYPE dwerk_ext, "Delivering Plant (Own or External)
       kondm  TYPE kondm,     "Material Pricing Group
       END OF ty_mvke,

"Internal table to populate MVKE with Plant in the first field
       BEGIN OF ty_mvke_pt,
       dwerk  TYPE dwerk_ext, "Delivering Plant (Own or External)
       matnr  TYPE matnr,     "Material Number
       vkorg  TYPE vkorg,     "Sales Organization
       vtweg  TYPE vtweg,     "Distribution Channel
       kondm  TYPE kondm,     "Material Pricing Group
       END OF ty_mvke_pt,

       BEGIN OF ty_final,
       icon TYPE  char4,      "Traffic light
       kschl TYPE kschl,      " Condition Type
       vkorg TYPE vkorg,      " Sales Organization
       vtweg TYPE vtweg,      " Distribution Channel
       kunnr TYPE kunag,      " Sold-to party
       waerk TYPE waers,      " Currency Key
       matnr TYPE matnr,      " Material Number
*--> Begin of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*       netpr TYPE netpr,      " Rate (condition amount or percentage)
*       kpein TYPE kpein,      " Condition pricing unit
*<-- End of delete for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
*--> Begin of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
       netwr TYPE netwr, " Net Value in Document Currency
       fkimg TYPE int4,  " Actual Invoiced Quantity
*<-- End of Insert for D3_OTC_IDD_0216_D3_R2_FUT Issue by AMOHAPA on 21-Mar-2018
       kmein TYPE kvmei,  " Quantity
       datab TYPE datum,  " Date
       datbi TYPE datum,  " Date
       error TYPE string, "Erropr message
       END OF ty_final,


       BEGIN OF ty_output.
        INCLUDE TYPE  vbrpvb. " Reference Structure for XVBRP/YVBRP
TYPES   waerk    TYPE waerk. " SD Document Currency
TYPES:  END OF ty_output,

        BEGIN OF ty_cdhdr,
        objectclas  TYPE cdobjectcl, "Object class
        objectid    TYPE cdobjectv,  "Object value
        changenr    TYPE cdchangenr, "Document change number
        udate	      TYPE cddatum,	   "Creation date of the change document
*--> Begin of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
*        tabkey      TYPE cdtabkey,   " Changed table record key
*<-- End of delete for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
        END OF ty_cdhdr,

        BEGIN OF ty_cdpos,
        objectclas  TYPE cdobjectcl, "Object class
        objectid    TYPE cdobjectv,  "Object value
*--> Begin of insert for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
        changenr    TYPE 	cdchangenr, "Document change number
        tabname	    TYPE tabname,  " Table Name
        tabkey      TYPE cdtabkey, " Changed table record key
*<-- End of insert for D3_OTC_IDD_0216_Defect#5759 by AMOHAPA on 18-Apr-2018
        fname       TYPE fieldname,  "Field Name
        chngind	    TYPE cdchngind,	 "Change Type (U, I, S, D)
        matnr       TYPE matnr,      "Material Number
        END OF ty_cdpos,

        BEGIN OF ty_mbew,
        matnr  TYPE matnr,           "Material Number
        bwkey  TYPE bwkey,           "Valuation Area
        END OF ty_mbew,

*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
        BEGIN OF ty_vmsta,
        sign TYPE char1,   " Sign of type CHAR1
        option TYPE char2, " Option of type CHAR2
        low    TYPE vmsta, " Distribution-chain-specific material status
        high   TYPE vmsta, " Distribution-chain-specific material status
        END OF ty_vmsta,

ty_t_vmsta  TYPE STANDARD TABLE OF ty_vmsta    INITIAL SIZE 0,
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

ty_t_mvke    TYPE STANDARD TABLE OF ty_mvke    INITIAL SIZE 0,
ty_t_mbew    TYPE STANDARD TABLE OF ty_mbew    INITIAL SIZE 0,
ty_t_mvke_pt TYPE STANDARD TABLE OF ty_mvke_pt INITIAL SIZE 0,
ty_t_final   TYPE STANDARD TABLE OF ty_final   INITIAL SIZE 0,
ty_t_cdhdr   TYPE STANDARD TABLE OF ty_cdhdr   INITIAL SIZE 0,
ty_t_cdpos   TYPE STANDARD TABLE OF ty_cdpos   INITIAL SIZE 0,
ty_t_status  TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
ty_t_submit  TYPE STANDARD TABLE OF rsparams        INITIAL SIZE 0. " ABAP: General Structure for PARAMETERS and SELECT-OPTIONS


"Global Data Declaration

DATA: gv_kondm TYPE kondm, " Material Pricing Group
      gv_matnr TYPE matnr, " Material Number
      gv_cdate TYPE laeda, " Date of Last Change
*-->Begin of Insert for D3_OTC_IDD_0216_R2 by AMOHAPA on 23-Mar-2018
      gv_mtart TYPE mtart, " Material Type
*<--End of Insert for D3_OTC_IDD_0216_R2 by AMOHAPA on 23-Mar-2018

"Global internal table declaration
      i_mvke        TYPE STANDARD TABLE OF ty_mvke    INITIAL SIZE 0,      "Internal table for MVKE
      i_mbew        TYPE STANDARD TABLE OF ty_mbew    INITIAL SIZE 0,      "Internal tabl;e for MBEW
      i_mvke_pt     TYPE STANDARD TABLE OF ty_mvke_pt INITIAL SIZE 0,      "Internal table for MBEW
      i_final       TYPE STANDARD TABLE OF ty_final   INITIAL SIZE 0,      "Internal table for Final
      i_error       TYPE STANDARD TABLE OF ty_final   INITIAL SIZE 0,      "Internal table to keep error entry
      i_cdhdr       TYPE STANDARD TABLE OF ty_cdhdr   INITIAL SIZE 0,      "Internal table for CDHDR
      i_cdpos       TYPE STANDARD TABLE OF ty_cdpos   INITIAL SIZE 0,      "Internal table for CDPOS
      i_fieldcat    TYPE slis_t_fieldcat_alv,                              " Fieldcatalog Internal tab
      i_listheader  TYPE slis_t_listheader,                                " List header internal tab
      i_status      TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, "Enhancement status table
*-->Begin of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017
      i_vmsta       TYPE STANDARD TABLE OF ty_vmsta   INITIAL SIZE 0. "Internal table for Distribution-chain-specific material status
*<--End of insert for D3_OTC_IDD_0216_R2_FUT_ISSUE by AMOHAPA on 22-Dec-2017

CONSTANTS: c_16 TYPE outputlen VALUE '16', "Global constant for output length
           c_10 TYPE outputlen VALUE '7',  "Global constant for output length
           c_30 TYPE outputlen VALUE '30'. "Global constant for output length
