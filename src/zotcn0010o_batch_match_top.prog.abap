*&---------------------------------------------------------------------*
*&  Include           ZOTCN0010O_BATCH_MATCH_TOP
*&---------------------------------------------------------------------*
************************************************************************
*             Types Declaration                                        *
************************************************************************
types: begin of ty_final,
         atwrt     type atwrt,         " Prod Group
         atwrt_dec type atwrt,         " PG Description
         kunnr     type kunnr,         " Customer No
         name1     type name1,         " Cust. Description
         vbeln     type vbeln,         " Sales Order Number
         audat     type audat,         " Sales Order Creation Date
         vbelv     type vbeln_von,     " Delivery no
         wadat_ist type wadat_ist,     " Post Goods Issue Date realted to sales Order line item
         bstkd     type bstkd,         " Purchase Oder in sales order Document
         matnr     type matnr,         " Material Number
         posnr     type maktx,         " Material Description
         charg     type charg_d,       " Batch number in Sales Order
         hsdat     type hsdat,         " Manufacturing date of Batch number
         vfdat     type vfdat,         " Shelf life expiration date of batch number
         kwmeng    type i,             " Sales Order Quantity
         vrkme     type vrkme,         " Sales unit for material
         netwr     type i,             " Price in sales Order
         waers     type waers,         "SD Document Currency
         clabs     type i,             " Unrestricted stock Quantity
         werks     type werks_d,       " Unrest. Qty Plant
         atinn     type atinn ,        " Characteristics based on material
         atnam     type atnam,         " Characteristic description
         atwrt_m   type atwrt ,        " Characteristic Value
         ec_code   type char50,"char3,         " EC Code
         warning   type char10,        " Warning
         cuobj_bm  type cuobj_bm ,     " Internal object no.: Batch classification
         atnam1    type atnam,         " characteristic description from cabn
         kunnr0     type kunnr,         " customer no with preceeding zero
         matnr_p   type matnr,         " Parent Material
       end of ty_final,

       begin of ty_batch,
         matnr          type z_kit,               " Kit
         zlevel         type z_level,             " Level
         matnr2         type matnr,               " Material no
         compcode       type z_compcode,          " Compatibility Code
         ccode          type atinn,               "Internal char
       end of ty_batch,

       begin of ty_ausp,
         objek type matnr,                " Key of object to be classified
         atinn type atinn,                 " Internal characteristic
         atwrt type atwrt,                 " Characteristic Value
         atflv type atflv,                 " Internal floating point from
         cuobj type cuobj_bm,              " Internal characteristic
      end of ty_ausp,

      begin of ty_vbkd,
        vbeln type vbeln,                 " Sales and Distribution Document Number
        posnr type posnr,                 " Item number of the SD document
        bstkd type bstkd,                 " Customer purchase order number
      end of ty_vbkd,

      begin of ty_cabn,
       atinn type atinn,                  " Internal characteristic
       atnam type atnam,                  " Characteristic Name
       atfor type atfor,                  "Data type of characteristic
      end of ty_cabn,

      begin of ty_kna1,
        kunnr type kunnr,                 " Customer No
        name1 type name1,                 " Customer Name
      end of ty_kna1,

      begin of ty_likp,
        vbeln     type vbeln,                " Sales and Distribution Document Number
        wadat_ist type wadat_ist,           " Actual Goods Movement Date
      end of ty_likp,

      begin of ty_vbfa,
        vbelv   type vbeln_von,           " Preceding sales and distribution document
        posnv   type posnr_von,           " Preceding item of an SD document
        vbeln   type vbeln,               " Sales and Distribution Document Number
        vbtyp_n type vbtyp_n,             " Document category of subsequent document
     end of ty_vbfa,

     begin of ty_mchb,
        matnr type matnr,          " Material Number
        werks type werks_d,        " Plant
        charg type charg_d,        " Batch Number
        clabs type labst,          " Valuated Unrestricted-Use Stock
        cumlm type umlmd,          " Stock in transfer (from one storage location to another)
        cinsm type insme,          " Stock in Quality Inspection
        ceinm type einme,          " Total Stock of All Restricted Batches
        inv   type einme,   " var for Sum of four above fields
        del   type char2,          " Indicator for deletion
     end of ty_mchb,

     begin of ty_mch1,
        matnr    type matnr,         " Material Number
        charg    type charg_d,       " Batch Number
        vfdat    type vfdat,         " Shelf Life Expiration or Best-Before Date
        hsdat    type hsdat,         " Date of Manufacture
        cuobj_bm type cuobj_bm,      " Internal object no.: Batch classification
     end of ty_mch1,

     begin of ty_vbap,
      vbeln  type vbeln,           " Sales Order
      posnr  type posnr,           " Item No
      matnr  type matnr,           " MAterial No
      charg  type charg_d,         " Characteristics
      netwr  type netwr_ap,        " Net value of the order item in document currency
      waerk  type waerk,           "SD Document Currency
      kwmeng type kwmeng,          " Cumulative Order Quantity in Sales Units
      vrkme  type vrkme,           " Sales Unit
      werks  type werks_d,         " Plant
    end of ty_vbap,

    begin of ty_lips,
      vbeln type vbeln_vl,      "Delivery
      posnr type posnr_vl,      "Delivery Item
      charg type charg_d,       "charg
    end of ty_lips,

    begin of ty_vapma,
      matnr type matnr,           " Material No
      audat type audat,           " Document Date (Date Received/Sent)
      kunnr type kunnr,           " Customer no
      vbeln type vbeln,           " Sales Order No
      posnr type posnr,           " Item No
   end of ty_vapma,

   begin of ty_cawnt,
     atinn type atinn,            "Internal characteristic
     atzhl type atzhl,            "Internal Counter
     atwtb type atwtb,            "Characteristic value description
   end of ty_cawnt,

       begin of ty_batch_1,
         matnr          type z_kit,               " Kit
         zlevel         type z_level,             " Level
         matnr2         type objnum,               " Material no
         compcode       type z_compcode,          " Compatibility Code
         ccode          type atinn,               "Internal char
       end of ty_batch_1,

   begin of ty_inob,
     cuobj type cuobj,           "Configuration (internal object number)
     klart type klassenart,      "Class Type
     obtab type tabelle,         "Name of database table for object
     objek type cuobn,           "Key of Object to be Classified
   end of ty_inob,

   begin of ty_cabnt,
     atinn type atinn,  "Internal characteristic
*     spras TYPE spras,  "Language Key   "Commented for Defect#2164
     atbez type atbez,  "Characteristic description
  end of ty_cabnt,

  begin of ty_makt,
    matnr type matnr,    "Material Number
*    spras TYPE spras,    "Language Key  "Commented for Defect#2164
    maktx type maktx,    "Material Des
  end of ty_makt,

  begin of ty_atinn,
    atinn type atinn,  "Internal charactersitic
  end of ty_atinn.


**Table Type Declaration
types:  ty_t_batch     type standard table of ty_batch,           " Table type for ty_batch
        ty_t_batch_1   type standard table of ty_batch_1,         " Table type for ty_batch
        ty_t_makt      type standard table of ty_makt,            " Table type for ty_makt
        ty_t_final     type standard table of ty_final,           " Table type for ty_final
        ty_t_ausp      type standard table of ty_ausp,            " Table type for ty_ausp
        ty_t_atinn     type standard table of ty_atinn,           " Table type for ty_atinn
        ty_t_cawnt     type standard table of ty_cawnt,           "Table type for ty_cawnt
        ty_t_mch1      type standard table of ty_mch1,            " Table type for ty_mch1
        ty_t_mchb      type standard table of ty_mchb,            " Table type for ty_mchb_temp
        ty_t_vbap      type standard table of ty_vbap,            " Table type for ty_vbap
        ty_t_vbfa      type standard table of ty_vbfa,            " Table type for ty_vbfa
        ty_t_lips      type standard table of ty_lips,            " Table type for ty_lips
        ty_t_likp      type standard table of ty_likp,            " Table type for ty_likp
        ty_t_kna1      type standard table of ty_kna1,            " Table type for ty_kna1
        ty_t_vbkd      type standard table of ty_vbkd,            " Table type for ty_vbkd
        ty_t_cabn      type standard table of ty_cabn,            " Table type for ty_cabn
        ty_t_vapma     type standard table of ty_vapma,           " Table type for ty_vapma
        ty_t_inob      type standard table of ty_inob,            " Table type for ty_inob
        ty_t_cabnt     type standard table of ty_cabnt,           " Table type for cabnt
        ty_t_retrn1    type standard table of bapiret2.           " Table Type for Return Parameters

************************************************************************
*             Constants Declaration                                   *
************************************************************************
constants:    c_left   type char1   value 'L',               " Left justifaction in ALV display
              c_inv    type char1   value 'X',              " Constants for inv
              c_vbtyp  type vbtyp_n value 'J',              " Constants for delivery type as J
              c_zero   type char1  value '0',              " Constants for Zero Inv
              c_colon  type char1  value ':',              "Constant for colon
              c_slash  type char1  value '/',              "Constant for slash
              c_top    type slis_formname value 'F_TOP_OF_PAGE',"Constant for top of page
              c_save   type char1  value 'A',              "Used in alv for user save
              c_bm     type atnam  value 'BM_PRODGROUP',      "BM_PRODGROUP
              c_12     type numc3  value '012',              "Constant for 012.
              c_atinn  type atnam  value 'ZM_TECH_TYPE',     "Constant for 99
              c_ch     type char5  value 'CHECK',            "Constant for check
              c_fut    type char6  value 'FUTURE',           "Constant for future
              c_atfor  type char4  value 'CHAR',             "Constant for char data type
              c_sign   type char1  value 'I',                "Constant for sign
              c_option type char2  value 'BT',               "Constant for option
              c_posnr  type posnr  value '000000',           "Constant for posnr
              c_shead  type char1  value 'S',                "Constant for S
              c_head   type char1  value 'H',                "Constant for H
              c_class  type char3  value '001'.              "Constant for class type


************************************************************************
*                 Global Internal Table Declaration                    *
************************************************************************

data:    i_final      type ty_t_final,    "Final internal table
         i_final_tmp  type ty_t_final,    "Final temp internal table
         i_final_tmp1 type ty_t_final,    "Final temp internal table
         i_final_tmp2 type ty_t_final,
         i_batch      type ty_t_batch,    " Internal Table for Batch
         i_makt       type ty_t_makt,     " Internal table for makt
         i_batch_1    type ty_t_batch_1,  " Internal Table for Batch
         i_batch_tmp  type ty_t_batch,    " Internal Table for Batch
         i_ausp       type ty_t_ausp,     " Internal Table for Ausp
         i_ausp_1     type ty_t_ausp,     " Internal Table for Ausp
         i_cawnt      type ty_t_cawnt,    " Internal table for Cawnt
         i_cabn       type ty_t_cabn,     " Internal Table for Cabn
         i_cabnt      type ty_t_cabnt,    " Interna Table for char des
         i_mch1       type ty_t_mch1,     " Internal Table for Mch1
         i_mchb       type ty_t_mchb,     " Internal Table for Mchb
         i_vbap       type ty_t_vbap,     " Internal Table for Vbap
         i_vbap_tmp   type ty_t_vbap,     " Internal Table for Vbap
         i_vbfa       type ty_t_vbfa,     " Internal Table for Vbfa
         i_lips       type ty_t_lips,     " Internal table for lips
         i_vapma      type ty_t_vapma,    " Internal Table for Vapma
         i_kna1       type ty_t_kna1,     " Internal Table for Kna1
         i_vbkd       type ty_t_vbkd,     " Internal Table for Vbkd
         i_likp       type ty_t_likp,     " Internal Table for Likp
         i_inob       type ty_t_inob,     " Internal Table for Inob

************************************************************************
*                   ALV Data Declaration                               *
************************************************************************
      i_fieldcat         type slis_t_fieldcat_alv, "Fieldcatalog Internal tab
      i_listheader       type slis_t_listheader,   "List header internal tabab
      wa_fieldcat        type slis_fieldcat_alv,   "Fieldcatalog Workarea

************************************************************************
*             Variables Declaration                                   *
************************************************************************
      gv_date   type sy-datum,     "Current date
      gv_kunnr  type kunag,        " Customer No.
      gv_charg  type dfbatch-charg,"Batch No.
      gv_atinn  type atinn.       "Internal characteristic
