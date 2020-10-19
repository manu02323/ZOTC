***********************************************************************
*Program    : ZOTCN0136O_GLOBAL_VAR                                   *
*Title      : Custom Fields on Sales Document                         *
*Developer  : Shruti Gupta                                            *
*Object type: Enhancement                                             *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_EDD_0136                                           *
*---------------------------------------------------------------------*
*Description: Custom Fields on Sales Document Header & Item           *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*24-Feb-2015  SGUPTA4       E2DK900492     Initial Development for    *
*                                          CR D2_484,  Updating the   *
*                                          Item Category on the basis *
*                                          of doc type,billing method *
*                                          and billing frequency whose*
*                                          values are entered in a    *
*                                          popup by the user.         *
*                                                                     *
*22-Apr-2015  NSAXENA       E2DK900492    CR D2_626,for populating the*
*                                         BOM Last Component.         *
*---------------------------------------------------------------------*
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZOTCN0136O_GLOBAL_VAR
*&---------------------------------------------------------------------*


TYPES: BEGIN OF ty_vbap,
        vbeln TYPE vbeln_va,         " Sales Document
        posnr TYPE posnr_va,         " Sales Document Item
        zz_bilmet TYPE z_bmethod,    " Billing Method
        zz_bilfr  TYPE z_bfrequency, " Billing Frequency
       END OF ty_vbap.


TYPES:  BEGIN OF ty_vbrp,
         vbeln     TYPE vbeln_va,     " Sales Document
         posnr     TYPE posnr_va,     " Sales Document Item
         zz_bilmet TYPE z_bmethod,    " Billing Method
         zz_bilfr  TYPE z_bfrequency, " Billing Frequency
        END OF ty_vbrp.
* ---> Begin of Insert for D2_OTC_IDD_0136 CR D2_626 by NSAXENA
TYPES: BEGIN OF ty_bom_last_comp,
         uepos TYPE uepos, " Higher-level item in bill of material structures
         matnr TYPE matnr, " Material Number
       END OF ty_bom_last_comp.

DATA: i_bom_last_comp TYPE STANDARD TABLE OF ty_bom_last_comp. "Internal table to store last BOM component

* <--- End    of Insert for D2_OTC_IDD_0136 CR D2_626 by NSAXENA

DATA: i_vbap    TYPE TABLE OF ty_vbap, "Global Internal Table for ty_vbap
      wa_vbap   TYPE ty_vbap,          "Global work area for ty_vbap
      i_vbrp    TYPE TABLE OF ty_vbrp, "Global Internal table fot ty_vbrp
      wa_vbrp   TYPE ty_vbrp.          "Global work area for ty_vbrp
