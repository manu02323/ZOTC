************************************************************************
* PROGRAM    :  ZOTCCL_PRICE_CONDITION_LOAD~PROCESS_DATA               *
* TITLE      :  Interface for receiving Price from  Quote System       *
* DEVELOPER  :  Anjan Paul,Pallavi Gupta                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:   D3_OTC_IDD_0203,D3_OTC_IDD_0042                         *
*----------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records                       *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
* 21-Jun-2016 APAUL     E1DK919349   INITIAL DEVELOPMENT               *
* 21-Jun-2016 U024571   E1DK919349   INITIAL DEVELOPMENT               *
*&---------------------------------------------------------------------*
* <--- Begin of Insert for D3_OTC_IDD_0203 by APAUL

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

TYPES : BEGIN OF lty_mvke,
    matnr TYPE matnr,               " Material Number
    vkorg TYPE vkorg,               " Sales Organization
    vtweg TYPE vtweg,               " Distribution Channel
  END OF  lty_mvke,

 BEGIN OF lty_knvv,
       kunnr TYPE knvv-kunnr,       " Customer Number
       vkorg TYPE knvv-vkorg,       " Sales Organization
       vtweg TYPE knvv-vtweg,       " Distribution Channel
      END OF lty_knvv,

      BEGIN OF lty_con_945,
       kappl TYPE kappl,            " Application
       kschl TYPE kschl ,           " Condition Type
       vkorg TYPE vkorg ,           " Sales Organization
       vtweg TYPE vtweg ,           " Distribution Channel
       kunag TYPE kunnr ,           " Customer Number
       kunwe TYPE kunwe ,           " Ship-to party
       datbi TYPE datbi,            " Valid To Date
       knumh TYPE knumh,            " Condition record number
    END OF lty_con_945 ,


      BEGIN OF lty_con_946,
       kappl TYPE kappl,            " Application
       kschl TYPE kschl ,           " Condition Type
       vkorg TYPE vkorg ,           " Sales Organization
       vtweg TYPE vtweg ,           " Distribution Channel
       kunag TYPE kunnr ,           " Customer Number
       datbi TYPE datbi,            " Valid To Date
       knumh TYPE knumh,            " Condition record number
    END OF lty_con_946 ,

  BEGIN OF lty_con_935,
       kappl TYPE kappl,            " Application
       kschl TYPE kschl ,           " Condition Type
       vkorg TYPE vkorg ,           " Sales Organization
       vtweg TYPE vtweg ,           " Distribution Channel
       kunag TYPE kunnr ,           " Customer Number
       kunwe TYPE kunwe ,           " Ship-to party
       matnr TYPE matnr  ,          " Material Number
       datbi TYPE datbi,            " Valid To Date
       knumh TYPE knumh,            " Condition record number
    END OF lty_con_935  ,



      BEGIN OF lty_con_005,
       kappl TYPE kappl,            " Application
       kschl TYPE kschl ,           " Condition Type
       vkorg TYPE vkorg ,           " Sales Organization
       vtweg TYPE vtweg ,           " Distribution Channel
       kunnr TYPE kunnr ,           " Ship-to party
       matnr TYPE matnr  ,          " Material Number
       datbi TYPE datbi,            " Valid To Date
       knumh TYPE knumh,            " Condition record number
    END OF lty_con_005 ,



   BEGIN OF lty_item,
      vkorg TYPE vkorg,             " Sales Organization
      vtweg TYPE vtweg,             " Distribution Channel
      kunnr TYPE kunnr,             " Customer Number
      kunwe TYPE kunwe ,            " Ship-to party
      matnr TYPE matnr ,            " Material Number
      kbetr TYPE kbetr ,            " Rate (condition amount or percentage)
      konwa TYPE konwa ,            " Rate unit (currency or percentage)
      kmein TYPE kmein,             " Condition unit
      kpein TYPE kpein,             " Condition pricing unit
      loevm_ko TYPE loevm_ko,       " Deletion Indicator for Condition Item
      datbi TYPE datbi,             " Valid To Date
      datab TYPE datab,             " Valid-From Date
      ztext TYPE char40,            " Ztext of type CHAR40
     END OF lty_item,

     BEGIN OF lty_tcurc,
       waers TYPE waers_curc,       " Currency Key
     END OF lty_tcurc,

     BEGIN OF lty_text_create,
       tdid        TYPE tdid,       " Text ID
       fname       TYPE tdobname,   " Name
       tdline      TYPE  tline   ,  " SAPscript: Text Lines
       cond_value  TYPE sxmsdvalue, "Conidition  no
       END OF lty_text_create ,
* <--- End of Insert for D3_OTC_IDD_0203 by APAUL
* <--- Begin of Insert for D3_OTC_IDD_0042 by U024571

     BEGIN OF lty_t685,
       kvewe TYPE kvewe,   " Usage of the condition table
       kappl TYPE kappl,   " Application
       kschl TYPE kschl,   " Condition Type
       END OF lty_t685,

     BEGIN OF lty_tvko,
       vkorg TYPE vkorg,   " Sales Organization
     END OF lty_tvko,

     BEGIN OF lty_tvtw,
       vtweg TYPE vtweg,   " Distribution Channel
     END OF lty_tvtw,

     BEGIN OF lty_kna1,
       kunnr TYPE kunnr,   " Customer Number
       aufsd TYPE aufsd_x, " Central order block for customer
     END OF lty_kna1,

     BEGIN OF lty_mara,
       matnr TYPE matnr,   " Material Number
     END OF lty_mara.
* <--- End of Insert for D3_OTC_IDD_0042 by U024571
