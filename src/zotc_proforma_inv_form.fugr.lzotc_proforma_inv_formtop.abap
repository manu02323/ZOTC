***********************************************************************
* Program     : LZOTC_PROFORMA_INV_FORMTOP                            *
* Title       : Proforma Invoice Form                                 *
* Developer   : Avanti Sharma                                         *
* Object type : Adobe Form                                            *
* SAP Release : SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID   : D3_OTC_FDD_0088                                       *
*---------------------------------------------------------------------*
* Description : Include program for data declaration                  *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* Date           User        Transport       Description              *
*=========== ============== ============== ===========================*
*23-SEP-2016 ASHARMA8       E1DK921463     Initial development        *
*&--------------------------------------------------------------------*
*09-OCT-2017 SMUKHER4      E1DK931130    D3_R2 Changes as follows:    *
* 1.Insurance: Omit printing of the label & field when pricing cond.  *
* ZINS is inactive.                                                   *
* 2. Document: Add the value for cond.ZDOC to the field Handling      *
* when pricing condition is active KINAK.                             *
* 3. Adding new field GLN in the layout.                              *
* 4. SWISS VAT Label-Logic implemented in OTC_FDD_0014.We are just    *
* the standard text.                                                  *
* 5.Environment Fee-new field is added in the layout.Pricing Cond.ZINV*
*Suppressing the field and printing when value is initial.            *
*&--------------------------------------------------------------------*
*17-Aug-2018 U101734      E1DK938306 defect 6832: Concate check digit *
*&--------------------------------------------------------------------*
*17-Aug-2018 U101734      E1DK938306 defect 6782: exclude UTXJ line   *
*                                    from Vat Summary table           *
*&--------------------------------------------------------------------*

FUNCTION-POOL zotc_proforma_inv_form. "MESSAGE-ID ..

* INCLUDE LZOTC_PROFORMA_INV_FORMD...        " Local class definition


TYPES: BEGIN OF ty_vbpa,
          vbeln TYPE  vbeln,       " Sales and Distribution Document Number
          posnr TYPE 	posnr,
          parvw	TYPE  parvw,
          kunnr	TYPE  kunnr,
          adrnr	TYPE  adrnr,
          land1 TYPE  land1,       " Country Key
       END OF ty_vbpa,

       BEGIN OF ty_ser02,
         obknr    TYPE  objknr,    " Object list number
         sdaufnr  TYPE vbeln_va,   " Sales Document
         posnr    TYPE posnr_va,   " Sales Document Item
       END OF ty_ser02,

       BEGIN OF ty_objk,
         obknr    TYPE objknr,     " Object list number
         obzae    TYPE objza,      " Object list counters
         sernr    TYPE gernr,      " Serial Number
       END OF ty_objk,

       BEGIN OF ty_knmt,
         vkorg    TYPE vkorg,      " Sales Organization
         vtweg    TYPE vtweg,      " Distribution Channel
         kunnr    TYPE kunnr_v,    " Customer number
         matnr    TYPE matnr,      " Material Number
         kdmat    TYPE matnr_ku,   " Material Number Used by Customer
       END OF ty_knmt,

       BEGIN OF ty_vbrp,
         vbeln    TYPE vbeln_vf,   " Billing Document
         posnr    TYPE posnr_vf,   " Billing item
         fbuda    TYPE fbuda,      " Date on which services rendered
         abrbg    TYPE abrbg,      " Start of accounting settlement period
       END OF ty_vbrp,

       BEGIN OF ty_eipo,
         exnum    TYPE exnum,      " Number of foreign trade data in MM and SD documents
         expos    TYPE expos,      " Internal item number for foreign trade data in MM and SD
         stawn    TYPE stawn,      " Commodity Code/Import Code Number for Foreign Trade
         herkl    TYPE herkl,      " Country of origin of the material
       END OF ty_eipo,

       BEGIN OF ty_vbfa,
         vbelv  TYPE vbeln_von,    " Preceding sales and distribution document
         posnv  TYPE posnr_von,    " Preceding item of an SD document
         vbeln  TYPE vbeln_nach,   " Subsequent sales and distribution document
         posnn  TYPE posnr_nach,   " Subsequent item of an SD document
         vbtyp_n  TYPE vbtyp_n,    " Document category of subsequent document
       END OF ty_vbfa,

       BEGIN OF ty_tax,
           kbetr_char TYPE char22, " Char of type CHAR22
           kawrt      TYPE kawrt,  " Condition base value
           kwert      TYPE kwert,  " Condition value
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
           koaid      TYPE koaid, " Condition class
           kntyp      TYPE kntyp, " Condition category (examples: tax, freight, price, cost)
           kstat      type kstat,
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782

       END OF ty_tax,

       BEGIN OF ty_konv,
           knumv      TYPE knumv, " Number of the document condition
           kposn      TYPE kposn, " Condition item number
           kschl      TYPE kscha, " Condition type
           kawrt      TYPE kawrt, " Condition base value
           kbetr      TYPE kbetr, " Rate (condition amount or percentage)
           mwsk1      TYPE mwskz, " Tax on sales/purchases code
           kwert      TYPE kwert, " Condition value
* Begin of Insert for Defect_5741 by ASHARMA8
           kinak      TYPE kinak, " Condition is inactive
* End of Insert for Defect_5741 by ASHARMA8
           koaid      TYPE koaid, " Condition class
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
           kntyp      TYPE kntyp, " Condition category (examples: tax, freight, price, cost)
           kstat      TYPE kstat, " Statistical data
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 14/08/2018 Defect #6782
       END OF ty_konv,

       BEGIN OF ty_stxh,
           tdobject   TYPE tdobject, " Texts: Application Object
           tdname  	  TYPE tdobname, " Name
           tdid       TYPE tdid,     " Text ID
           tdspras    TYPE spras,    " Language Key
       END OF ty_stxh,

       BEGIN OF ty_taxcode,
           mwskz  TYPE mwskz,        " Tax on sales/purchases code
       END OF ty_taxcode,

       BEGIN OF ty_lips,
           vbeln  TYPE vbeln_vl,     " Delivery
           posnr  TYPE posnr_vl,     " Delivery Item
           vfdat  TYPE vfdat,        " Shelf Life Expiration or Best-Before Date
       END OF ty_lips,

       BEGIN OF ty_bank,
           bukrs  TYPE bukrs,        " Company Code
           waerk  TYPE waerk,        " SD Document Currency
           hbkid  TYPE hbkid,        " Short Key for a House Bank
           htkid  TYPE hktid,        " ID for Account Details
       END OF ty_bank,

*&-->Begin of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017
       BEGIN OF ty_kna1,
       kunnr TYPE kunnr, " Customer Number
       bbbnr TYPE bbbnr, " International location number  (part 1)
       bbsnr TYPE bbsnr, " International location number (Part 2)
*&-->Begin of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
       bubkz TYPE bubkz, " Check digit
*&-->End of Insert for  D3_OTC_FDD_0088 by U101734 on 17/08/2018 Defect #6832
       END OF ty_kna1,
*&<--End of Insert for D3_R2 for D3_OTC_FDD_0088 by SMUKHER4 on 09-Oct-2017


        ty_t_lips  TYPE STANDARD TABLE OF ty_lips,
        ty_t_konv  TYPE STANDARD TABLE OF ty_konv,
        ty_t_vbfa  TYPE STANDARD TABLE OF ty_vbfa,
        ty_t_eipo  TYPE STANDARD TABLE OF ty_eipo,
        ty_t_vbrp  TYPE STANDARD TABLE OF ty_vbrp,
        ty_t_knmt  TYPE STANDARD TABLE OF ty_knmt,
        ty_t_ser02 TYPE STANDARD TABLE OF ty_ser02,
        ty_t_objk  TYPE STANDARD TABLE OF ty_objk.
