*&---------------------------------------------------------------------*
*& Report  ZOTCE0274B_PRICE_UPLOAD_GIDOC
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCE0274B_PRICE_UPLOAD                                *
* TITLE      :  D2_OTC_EDD_0274_Pricing upload program for pricing cond*
* DEVELOPER  :  Monika Garg                                            *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D2_OTC_EDD_0274                                        *
*----------------------------------------------------------------------*
* DESCRIPTION: Pricing Upload program for pricing condition  (Part 2)  *
* Program will read all the files from specified folder of application *
* server and create the IDOC which will Insert/update/Delete the       *
* condition records.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE          USER     TRANSPORT  DESCRIPTION                        *
* =========== ======== ========== =====================================*
* 18-Aug-2015  MGARG    E2DK913959 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*
*  26-Oct-2015 DMOIRAN  E2DK913959 Defect 1209 PGL B development.      *
* Added logic to create segment Z1OTC_KONP_EXT to update pricing       *
* condition text.                                                      *
*&---------------------------------------------------------------------*

* Declare Constant
  CONSTANTS:
   c_e          TYPE char1      VALUE 'E',                            " E of type CHAR1
   c_idel       TYPE char1      VALUE 'D',                            " Idel of type CHAR1
   c_iupd       TYPE char1      VALUE 'U',                            " Iupd of type CHAR1
   c_iins       TYPE char1      VALUE 'I',                            " Iins of type CHAR1
   c_idel_l     TYPE char1      VALUE 'd',                            " Idel of type CHAR1
   c_iupd_l     TYPE char1      VALUE 'u',                            " Iupd of type CHAR1
   c_iins_l     TYPE char1      VALUE 'i',                            " Iins of type CHAR1
   c_true       TYPE char1      VALUE 'X',                            " True of type CHAR1
   c_kvewe      TYPE kvewe      VALUE 'A',                            " Usage of the condition table
   c_kappl_v    TYPE kappl      VALUE 'V',                            " Application
   c_cname      TYPE string     VALUE 'ZINDEX',
   c_zcounter   TYPE string     VALUE 'ZCOUNTER',
   c_kstbm      TYPE string     VALUE 'KSTBM',
   c_kbetr1     TYPE string     VALUE 'KBETR1',
   c_vkorg      TYPE string     VALUE 'VKORG',
   c_ztable     TYPE string     VALUE 'ZTABLE',
   c_mandt      TYPE string     VALUE 'MANDT',
   c_kschl      TYPE string     VALUE 'KSCHL',
   c_kappl      TYPE string     VALUE 'KAPPL',
   c_konws      TYPE string     VALUE 'KONWS',
   c_konms      TYPE string     VALUE 'KONMS',
   c_fslash     TYPE char1      VALUE '/',                            " Forward slash
   c_crlf       TYPE char1      VALUE  cl_abap_char_utilities=>cr_lf, " New Line feed
   c_pipe       TYPE char02     VALUE '||',                           " Comma of type CHAR1
   c_e1komg     TYPE edilsegtyp VALUE 'E1KOMG',                       " Segment type
   c_e1konh     TYPE edilsegtyp VALUE 'E1KONH',                       " Segment type
   c_e1konp     TYPE edilsegtyp VALUE 'E1KONP',                       " Segment type
   c_e1konm     TYPE edilsegtyp VALUE 'E1KONM',                       " Segment type
   c_e1konw     TYPE edilsegtyp VALUE 'E1KONW',                       " Segment type
   c_ext_seg    TYPE edilsegtyp VALUE 'Z1OTC_COND_KEY_FIELDS',        " Segment type
   c_one        TYPE char1      VALUE '1',                            " One of type CHAR1
   c_two        TYPE char1      VALUE '2',                            " Two of type CHAR1
   c_three      TYPE char1      VALUE '3',                            " Three of type CHAR1
   c_four       TYPE char1      VALUE '4',                            " Four of type CHAR1
* ---> Begin of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN
   c_z1otc_konp_ext TYPE edilsegtyp VALUE  'Z1OTC_KONP_EXT'. " Segment type
* <--- End    of Insert for D2_OTC_EDD_0274 Defect 1209 by DMOIRAN

*  Types Declaration
  TYPES:
    BEGIN OF ty_fileinfo,
      filename TYPE localfile,      " Local file for upload/download
      path     TYPE epsf-epsdirnam, " Directory name
      time     TYPE p,              " Time of type Packed Number
    END OF ty_fileinfo,

    BEGIN OF ty_seg,
      tabname   TYPE tabname,       " Table Name
      fieldname TYPE fieldname,     " Field Name
    END OF ty_seg,

     ty_t_seg     TYPE STANDARD TABLE OF ty_seg.

* Declare variables
  DATA:
        gv_sprt   TYPE edi4sndprt, " Partner type of sender
        gv_rprt   TYPE edi4rcvprt, " Partner Type of Receiver
*    gv_rcvpor    TYPE edi4rcvpor , " Receiver port
    gv_rcvprn    TYPE edi4rcvprn , " Partner Number of Receiver
*    gv_sndpor    TYPE edi4sndpor,  " Sender port (SAP System, external subsystem)
    gv_sndprn    TYPE edi4sndprn , " Partner Number of Sender
    i_fileinfo   TYPE STANDARD TABLE OF ty_fileinfo,
    i_seg        TYPE STANDARD TABLE OF ty_seg,
    wa_seg       TYPE ty_seg,
    i_field      TYPE cl_abap_structdescr=>component_table,
    wa_field     TYPE cl_abap_structdescr=>component.

* Field Symbols
  FIELD-SYMBOLS:
   <fs>          TYPE any,
   <fs_any>      TYPE any,
   <fs_field>    TYPE cl_abap_structdescr=>component,
   <fs_dyn_tab>  TYPE STANDARD TABLE,
   <fs_dyn_wa>   TYPE any.
