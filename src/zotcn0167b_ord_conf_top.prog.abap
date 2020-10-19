*&---------------------------------------------------------------------*
*&  Include           ZOTCN0167B_ORD_CONF_TOP
*&---------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTCN0167B_ORD_CONF_TOP                                 *
*Title      : Order acknowledgement                                   *
*Developer  : Nidhi Saxena (NSAXENA)                                  *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0167_SAP                                       *
*---------------------------------------------------------------------*
*Description: Send Order acknowledgement to PI and PI will send it    *
* as EMAIL in HTML format.                                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*01-Dec-2014  NSAXENA        E2DK906816     Initial DEvelopment.      *
*                                                                     *
*18-Mar-2015  NSAXENA       E2DK906816      Defect - 4825,Add texts id*
* at item level with text id Z014 and Z017  for more matrl description*
*Also, adding Street 3 logic for Mexico address                       *
*For Defect - 4872, no change ate ABAP Side only PI mapping required  *
*for Additional House id at Ship to address details                   *
*---------------------------------------------------------------------*
*13-Jul-2016  NGARG     E1DK919590      D3_OTC_IDD_0167
*---------------------------------------------------------------------*
*20-Dec-2016 MGARG      E1DK919590   Defect#6837_CR#289               *
*                                    Defect#6837:If customer’s langu  *
*                                    is neither EN, DE,ES orFR,default*
*                                    printing language should be EN   *
*                                    CR#289:Get Customer Address using*
*                                    FM for D3 only.                  *
*                                    Header and Item text determination*
*                                    logic based on default langu     *
*&--------------------------------------------------------------------*
*TYPES
*VBPA
TYPES:
    BEGIN OF ty_vbpa,
           vbeln TYPE vbeln,      "Sales and Distribution Document Number
           posnr TYPE posnr,      "Item number of the SD document
           parvw TYPE parvw,      "Partner Function
           kunnr TYPE kunnr,      "Customer Number
           parnr TYPE parnr,      "Contact Person number
           adrnr TYPE adrnr,      "Address
           adrnp TYPE ad_persnum, "Person number
    END OF ty_vbpa,
     tt_vbpa TYPE STANDARD TABLE OF ty_vbpa,

*ADDRESS
      BEGIN OF ty_address,
      addrnumber  TYPE ad_addrnum , "Address No.              "#EC NEEDED
      date_from  TYPE ad_date_fr,   " Valid-from date - in current Release only 00010101 possible
      nation   TYPE ad_nation,      " Version ID for International Addresses
      name1 TYPE ad_name1,          " Name 1
      name2  TYPE ad_name2,         " Name 2
      name3  TYPE ad_name3,         " Name 3
      name4  TYPE ad_name4,         " Name 4
      city1 TYPE ad_city1,          " City
      city2 TYPE ad_city2,          " District
      post_code1 TYPE ad_pstcd1,    " City postal code
      post_code2 TYPE ad_pstcd2,    " PO Box Postal Code
      po_box TYPE ad_pobx,          " PO B,,ox
      street TYPE ad_street,        " Street
      house_num1 TYPE ad_hsnm1,     " House No.
      house_num2 TYPE ad_hsnm1,     " House number supplement
      str_suppl1 TYPE ad_strspp1,   " Street 2
      str_suppl2 TYPE ad_strspp2,   " Street 3
      str_suppl3 TYPE ad_strspp3,   " Street 4
      building TYPE ad_bldng,       " Building (Number or Code)
      floor  TYPE ad_floor,         " Floor in building
      roomnumber TYPE ad_roomnum,   " Room or Appartment Number
      country  TYPE land1,          " Country Key
      region TYPE regio,            " Region (State, Province, County)
      tel_number TYPE ad_tlnmbr1,   " First telephone no.: dialling code+number
      smtp_addr TYPE  ad_smtpadr,   " E-Mail Address
      END OF ty_address.
* ---> Begin of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

*Types for stxh internal table
TYPES:  BEGIN OF ty_name,
          object TYPE tdobject, " Texts: Application Object
          name TYPE tdobname,   " Name
          id TYPE tdid,         " Text ID
          lang TYPE tdspras,    " Language key
        END OF ty_name,

*Begin of Change for D3_OTC_IDD_0167 by NGARG
        tty_status TYPE STANDARD TABLE OF zdev_enh_status. " Enhancement Status

DATA : gv_partner TYPE parvw,   " Partner Function
       gv_partner2 TYPE parvw . " Partner Function
*End of Change for D3_OTC_IDD_0167 by NGARG

*Internal table for Text details
DATA:   i_name TYPE STANDARD TABLE OF ty_name,
* ---> Begin of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
         gv_d3_flag   TYPE char1, " D3_flag of type CHAR1
* ---> End of Insert for D3_OTC_IDD_0167_Defect#6837_CR#289 by MGARG
*Begin of Change for D3_OTC_IDD_0167 by NGARG
         gv_zba1 TYPE flag,   " General Flag
         gv_spras TYPE spras. " Language Key
*End of Change for D3_OTC_IDD_0167 by NGARG

*&-->Begin of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019
 DATA gv_langu1 TYPE char2.
*&<--End of change for R6 D3_OTC_IDD_0167 Defect# 8305 by SMUKHER4 on 06-Mar-2019

*Field Symbols
FIELD-SYMBOLS <fs_name> TYPE ty_name.

*Global Constants:
CONSTANTS : c_english TYPE sylangu VALUE 'E'. " Language Key of Current Text Environment
* <--- End of Insert for D2_OTC_IDD_0167,Defect #4825 by NSAXENA

*
