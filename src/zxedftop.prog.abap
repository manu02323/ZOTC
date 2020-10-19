*&---------------------------------------------------------------------*
*&  Include           ZXEDFTOP
*&---------------------------------------------------------------------*
DATA: gv_kposn TYPE komvd-kposn. " Condition item number

************************************************************************
* INCLUDE    :  ZXEDFTOP                                               *
* TITLE      :  D2_OTC_IDD_0111                                        *
* DEVELOPER  :  Vivek Gaur                                             *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0111                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Outbound Customer Invoices EDI 810                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 31-JAN-2015  VGAUR     E2DK908545  INITIAL DEVELOPMENT               *
************************************************************************

TYPES:
   BEGIN OF ty_serial,                              " Delv. Serial Nos.
    obknr         TYPE objectnr,                    " Object list number
    lief_nr	      TYPE vbeln_vl,                    " Delivery
    posnr         TYPE posnr_vl,                    " Delivery Item
    anzsn         TYPE anzsn,                       " Number of serial numbers
   END OF ty_serial,

   BEGIN OF ty_object,                              " Plant Maintenance Object List
    obknr	        TYPE objectnr,                    " Object list number
    obzae	        TYPE objza,                       " Object list counters
    sernr	        TYPE gernr,                       " Serial Number
    matnr	        TYPE matnr,                       " Material Number
   END OF ty_object,

   BEGIN OF ty_pedi_i,                              " Inb.Pedimento Data
    werks         TYPE werks_d,                     " Plant
    vbeln         TYPE vbeln_vl,                    " Delivery
    posnr         TYPE posnr_vl,                    " Delivery Item
    matnr         TYPE matnr,                       " Material Number
    pedimento_nbr TYPE z_pedimento,                 " Pedimento Number
    custplace     TYPE z_custplace,                 " Customs Place
    custdate      TYPE z_custdate,                  " Customs Date
   END OF ty_pedi_i,

   BEGIN OF ty_pedi_o,                              " Out.Pedimento Data
    werks         TYPE werks_d,                     " Plant
    vbeln         TYPE vbeln_vl,                    " Delivery
    posnr         TYPE posnr_vl,                    " Delivery Item
    pedimento_seq TYPE z_ped_sequence,              " Pedimento Seq
    matnr         TYPE matnr,                       " Material Number
    pedimento_nbr TYPE z_pedimento,                 " Pedimento Number
    pedimento_qty TYPE z_pedimento_qty,             " Pedimento Qty
    pedimento_uom TYPE meins,                       " Unit of Measure
    custplace     TYPE z_custplace,                 " Customs Place
    custdate      TYPE z_custdate,                  " Customs Date
   END OF ty_pedi_o,

   ty_t_pedi_i   TYPE HASHED TABLE OF ty_pedi_i     " Inb. Pedimento Data
                  WITH UNIQUE KEY werks
                                  vbeln
                                  posnr,

   ty_t_pedi_o   TYPE HASHED TABLE OF ty_pedi_o     " Out. Pedimento Data
                  WITH UNIQUE KEY werks
                                  vbeln
                                  posnr
                                  pedimento_seq,

   ty_t_serial    TYPE STANDARD TABLE OF ty_serial, " Delv. Serial Nos.

   ty_t_object    TYPE STANDARD TABLE OF ty_object. " Plant Object List

DATA:
   x_pedi_i       TYPE ty_pedi_i,   " Inb. Pedimento Data
   i_pedi_o       TYPE ty_t_pedi_o. " Out. Pedimento Data

DATA:
##needed
   gv_count       TYPE int4,    " Count
##needed
   gv_uepos       TYPE uepos,   " Higher-level item in bill of material structures
##needed
   gv_posnr       TYPE posnr,   " Item number of the SD document
##needed
   gv_gjahr       TYPE gjahr,   " Fiscal Year
##needed
   gv_matnr       TYPE matnr,   " Material Number
##needed
   gv_batch       TYPE charg_d, " Batch Number
##needed
   gv_plant       TYPE werks_d, " Plant
##needed
   gv_belnr       TYPE char35.  " Document: Qualf 001

DATA:
  i_serial        TYPE ty_t_serial, " Delv. Serial Nos.
  i_object        TYPE ty_t_object. " Plant Object List

* ---> Begin of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
************************************************************************
* INCLUDE    :  ZXEDFTOP                                               *
* TITLE      :  D2_OTC_IDD_0011                                        *
* DEVELOPER  :  Dhananjoy Moirangthem                                  *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID  :  D2_OTC_IDD_0011                                       *
*----------------------------------------------------------------------*
* DESCRIPTION: Outbound Customer Invoices EDI 810                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT   DESCRIPTION                       *
* ===========  ========  ==========  ==================================*
* 18-JUL-2015  DMOIRAN   E2DK914082  INITIAL DEVELOPMENT               *
************************************************************************

  data:  gv_invoice          TYPE vbeln_vf. " Billing Document
* <--- End    of Insert for D2_OTC_IDD_0011 / INC0238201 by DMOIRAN
