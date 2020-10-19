*&---------------------------------------------------------------------*
*&  Include           ZOTCN0197O_REQUEST_CERT_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0197O_REQUEST_CERT_TOP                            *
* TITLE      :  Request Certificate of Origin                          *
* DEVELOPER  :  NEHA GARG                                              *
* OBJECT TYPE:  INTERFACE                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  D3_OTC_IDD_0197_SAP                                      *
*----------------------------------------------------------------------*
* DESCRIPTION: TOP INCLUDE                                             *
*                                                                      *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 04-JUL-2016 NGARG    E1DK919089 INITIAL DEVELOPMENT                  *
*&---------------------------------------------------------------------*
* 18-OCT-2016 MGARG   E1DK919089  D3_CR_0077&Defect_4188:              *
*                                 Build two BRFPLUS tables to store    *
*                                 commodity code desc& User logon      *
*                                 information. Added code to fetch EMI *
*                                 entries as country(sel_low)value     *
*&---------------------------------------------------------------------*
* 09-Dec-2016 NGARG  E1DK919089 Defect#7379 : Copy billing document to *
*                               OBSERVATION field , Convert currency to*
*                               USD and then to sold to  party         *
*                               country's curency , and add street to  *
*                               recipient address                      *
*&---------------------------------------------------------------------*
* 18-May-2017 U033876  E1DK928015 Defect#2798 : Incident INC0338515    *
*                                Populated Ship-To Address Instead of  *
*                               Sold-To in IDD_0197 Interface Program  *
*&---------------------------------------------------------------------*
* 21-June-2017 U033876 E1DK928015 Defect#3039 : Incident INC0338515    *
*                               Gross weight to be calulated based of  *
*                               billing document item gross weight and *
*                               Net weight of billing item to be groupe*
*                               based on country of origin of material *
*                               and commodity code
*----------------------------------------------------------------------*
DATA:  gv_oc     TYPE int4 ##needed , " Natural Number
       gv_bills  TYPE int4  ##needed, " Natural Number
       gv_docs   TYPE int4  ##needed. " Natural Number
*     Begin of Delete for Defect#7379 by NGARG*
*       gv_nb     TYPE i  ##needed.    " Nb of type Integers
*     End of Delete for Defect#7379 by NGARG

TYPES: BEGIN OF ty_vbrk,
         vbeln  TYPE vbeln_vf, "Billing Document
         fkart TYPE fkart,     " Billing Type
         waerk  TYPE waerk,    " SD Document Currency
         fkdat  TYPE fkdat,    " Billing date for billing index and printout
         kurrf  TYPE kurrf,    " Exchange rate for FI postings
         kunag  TYPE kunag,    " Sold-to party
         exnum  TYPE exnum,    " Number of foreign trade data in MM and SD documents
       END OF ty_vbrk,

       BEGIN OF ty_vbrp,
         vbeln  TYPE vbeln_vf, " Billing Document
         posnr  TYPE posnr_vf, " Billing item
         ntgew  TYPE ntgew_15, " Net weight
         brgew  TYPE brgew_15, " Gross weight
         gewei  TYPE gewei,    " Weight Unit
         netwr  TYPE netwr_fp, " Net value of the billing item in document currency
       END OF ty_vbrp,
*--> Begin of change for defect 2798- E1DK928015 by u033876.
       BEGIN OF ty_vbpa,
         vbeln  TYPE vbeln_vf,       " Billing Document
         posnr  TYPE posnr_vf,       " Billing item
         parvw  TYPE parvw,          " Partner Function
         kunnr  TYPE kunnr,          " Customer Number
         adrnr  TYPE adrnr,          " Address
       END OF ty_vbpa,

       BEGIN OF ty_adrc,
         addrnumber TYPE ad_addrnum, " Address
         country    TYPE land1,      " Country Key
         name1      TYPE ad_name1,   " Name 1
         name2      TYPE ad_name2,   " Name 2
         city1      TYPE ad_city1,   " City
         post_code1 TYPE ad_pstcd1,  " Postal Code
         street     TYPE ad_street,  " House number and street
         name3      TYPE ad_name3,   " Name 3
         name4      TYPE ad_name4,   " Name 4
         po_box     TYPE ad_pobx,    " PO Box
       END OF ty_adrc,
*<-- End of change for defect 2798-  E1DK928015 by u033876.

       BEGIN OF ty_vbfa,
         vbelv  TYPE vbeln_von,   " Preceding sales and distribution document
         posnv  TYPE posnr_von,   " Preceding item of an SD document
         vbeln  TYPE vbeln_nach,  " Billing Document
         posnn  TYPE posnr_nach,  " Billing item
         vbtyp_n TYPE vbtyp_n,    " Document category of subsequent document
         vbtyp_v TYPE vbtyp_v,    " Document category of preceding SD document
       END OF ty_vbfa,

       BEGIN OF ty_likp,
         vbeln TYPE vbeln_vl,     " Delivery
         kunnr TYPE kunwe,        " Ship-to party
         btgew TYPE gsgew,        " Total Weight
         gewei TYPE gewei,        " Weight Unit
       END OF ty_likp,

       BEGIN OF ty_kna1,
         kunnr TYPE kunnr,        " Customer Number
         land1 TYPE land1_gp,     " Country Key
         name1 TYPE name1_gp,     " Name 1
         name2 TYPE name2_gp,     " Name 2
         ort01 TYPE ort01_gp,     " City
         pstlz TYPE pstlz,        " Postal Code
         stras TYPE stras_gp,     " House number and street
         name3 TYPE name3_gp,     " Name 3
         name4 TYPE name4_gp,     " Name 4
         pfach TYPE pfach,        " PO Box
       END OF ty_kna1,

       BEGIN OF ty_eikp,
         exnum TYPE exnum,        " Number of foreign trade data in MM and SD documents
         expvz TYPE expvz,        " Mode of Transport for Foreign Trade
      END OF ty_eikp,

      BEGIN OF ty_eipo,
        exnum TYPE exnum,         " Number of foreign trade data in MM and SD documents
        expos TYPE expos,         " Internal item number for foreign trade data in MM and SD
        stawn TYPE stawn,         " Commodity Code/Import Code Number for Foreign Trade
        herkl TYPE herkl,         " Country of origin of the material
     END OF ty_eipo,

      BEGIN OF ty_data,
         vbeln TYPE vbeln,        " Sales and Distribution Document Number
         fkart TYPE fkart,        " Billing Type
         waerk TYPE waerk,        " SD Document Currency
         fkdat TYPE fkdat,        " Billing date for billing index and printout
         kurrf TYPE kurrf,        " Exchange rate for FI postings
         kunag TYPE kunag,        " Sold-to party
         exnum TYPE exnum,        " Number of foreign trade data in MM and SD documents
         kunnr TYPE kunwe,        " Ship-to party
         btgew TYPE gsgew,        " Total Weight
         gewei TYPE gewei,        " Weight Unit
         land1 TYPE land1_gp,     " Country Key
         name1 TYPE name1_gp,     " Name 1
         name2 TYPE name2_gp,     " Name 2
         ort01 TYPE ort01_gp,     " City
         pstlz TYPE pstlz,        " Postal Code
         stras TYPE stras_gp,     " House number and street
         name3 TYPE name3_gp,     " Name 3
         name4 TYPE name4_gp,     " Name 4
         pfach TYPE pfach,        " PO Box
         transport TYPE char3,    " Transport of type CHAR3
         del_no TYPE vbeln_vl,    " Delivery

       END OF ty_data,

        BEGIN OF ty_data_item,
         exnum TYPE exnum,        " Number of foreign trade data in MM and SD documents  Defect3039
         posnr  TYPE posnr_vf,    " Billing item
         ntgew TYPE ntgew_15,     " Net weight
         brgew  TYPE brgew_15,    " Gross weight
         gewei TYPE gewei,        " Weight Unit
         netwr  TYPE netwr_fp,    " Net value of the
         expvz TYPE expvz,        " Mode of Transport for Foreign Trade
         expos TYPE expos,        " Internal item number for foreign trade data in MM and SD
         stawn TYPE stawn,        " Commodity Code/Import Code Number for Foreign Trade
         herkl TYPE herkl,        " Country of origin of the material
       END OF ty_data_item,

       BEGIN OF ty_vekp,
         brgew TYPE brgew_vekp,   " Gross Weight
         gewei TYPE gewei,        " Weight Unit
         vpobj TYPE vpobj,        " Packing Object
         vpobjkey  TYPE vpobjkey, " Key for Object to Which the Handling Unit is Assigned
     END OF ty_vekp.


*-- Table type declarations
TYPES: ty_t_vbrp TYPE STANDARD TABLE OF ty_vbrp INITIAL SIZE 0,
       ty_t_vbrk TYPE STANDARD TABLE OF ty_vbrk INITIAL SIZE 0,
       ty_t_vbfa TYPE STANDARD TABLE OF ty_vbfa INITIAL SIZE 0,
*--->Begin of change for defect 2798- E1DK928015 by u033876
       ty_t_vbpa TYPE STANDARD TABLE OF ty_vbpa INITIAL SIZE 0,
       ty_t_adrc TYPE STANDARD TABLE OF ty_adrc INITIAL SIZE 0,
*<---End of change for defect 2798-  E1DK928015 by u033876
       ty_t_likp TYPE STANDARD TABLE OF ty_likp INITIAL SIZE 0,
       ty_t_kna1 TYPE STANDARD TABLE OF ty_kna1 INITIAL SIZE 0,
       ty_t_eikp TYPE STANDARD TABLE OF ty_eikp INITIAL SIZE 0,
       ty_t_eipo TYPE STANDARD TABLE OF ty_eipo INITIAL SIZE 0,
       ty_t_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0, " Enhancement Status
       ty_t_data TYPE STANDARD TABLE OF ty_data INITIAL SIZE 0,
       ty_t_vekp TYPE STANDARD TABLE OF ty_vekp INITIAL SIZE 0,
       ty_t_data_item TYPE STANDARD TABLE OF ty_data_item INITIAL SIZE 0. " User and Passwords for Certify

*-- Internal table declarations
DATA: i_vbrp TYPE  ty_t_vbrp  ##needed,
      i_vbrk TYPE  ty_t_vbrk  ##needed,
      i_vbfa TYPE  ty_t_vbfa  ##needed,
*--->Begin of change for defect 2798- E1DK928015 by u033876
      i_vbpa  TYPE ty_t_vbpa  ##needed,
      i_adrc  TYPE ty_t_adrc  ##needed,
*<---End of change for defect 2798-  E1DK928015 by u033876
      i_likp TYPE  ty_t_likp  ##needed,
      i_kna1 TYPE  ty_t_kna1  ##needed,
      i_eikp TYPE  ty_t_eikp  ##needed,
      i_eipo TYPE  ty_t_eipo ##needed,
      i_vekp TYPE ty_t_vekp ##needed,
      i_data TYPE ty_t_data ##needed,
      i_data_item TYPE ty_t_data_item ##needed,
      i_status TYPE STANDARD TABLE OF zdev_enh_status INITIAL SIZE 0 ##needed. " Enhancement Status

* ---> Begin of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
***** Constant declaration
CONSTANTS:
     c_underscore TYPE char1 VALUE '_'. " Underscore of type CHAR1
DATA:
     gv_usermail   TYPE string,
     gv_country    TYPE land1, " Country Key
* ---> End of Insert for D3_OTC_IDD_0197_D3_CR_0077&Defect_4188 by MGARG
*--->Begin of change for defect 2798- E1DK928015 by u033876
     gv_parvw      TYPE parvw.           " Partner Function
*<---End of change for defect 2798-  E1DK928015 by u033876
