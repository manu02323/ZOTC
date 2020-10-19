***************************************************************************
* Method     :FEH_EXECUTE                                                 *
* TITLE      :  Interface for receiving Price from  Gap   System          *
* DEVELOPER  :  Manoj Thatha                                              *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0203_DEFEC#9539                                 *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records form GAP                 *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 15-Feb-2017 MTHATHA  E1DK925792  INITIAL DEVELOPMENT/D3_OTC_IDD_0203_   *
*                                   DEFECT_9539                           *
* 04-Oct-2017 MTHATHA  E1DK931014  SCTASK0521172 changes                  *
* 08-Feb-2019 AMOHAPA  E1DK939406  Defect#6163_INC0394429-02:While delete *
*                                  operation we should consider Valid From*
*                                  as well and Valid from/ valid To date  *
*                                  should be greater than today's date    *
* 05-Jul-2019 AMOHAPA  E2DK924543  Defect#10027: To comment the part of   *
*                                  code done for Defect#6163 as it will   *
*                                  move later to production               *
*&------------------------------------------------------------------------*
TYPES : BEGIN OF lty_mvke,
          matnr TYPE matnr,         " Material Number
          vkorg TYPE vkorg,         " Sales Organization
          vtweg TYPE vtweg,         " Distribution Channel
        END OF  lty_mvke,

        BEGIN OF lty_knvv,
          kunnr TYPE knvv-kunnr, " Customer Number
          vkorg TYPE knvv-vkorg, " Sales Organization
          vtweg TYPE knvv-vtweg, " Distribution Channel
        END OF lty_knvv,

        BEGIN OF lty_con_945,
          kappl TYPE kappl,      " Application
          kschl TYPE kschl ,     " Condition Type
          vkorg TYPE vkorg ,     " Sales Organization
          vtweg TYPE vtweg ,     " Distribution Channel
          kunag TYPE kunnr ,     " Customer Number
          kunwe TYPE kunwe ,     " Ship-to party
          datbi TYPE datbi,      " Valid To Date
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*          datab TYPE kodatab, " Validity start date of the condition record
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
          knumh TYPE knumh,  " Condition record number
        END OF lty_con_945 ,


        BEGIN OF lty_con_946,
          kappl TYPE kappl,  " Application
          kschl TYPE kschl , " Condition Type
          vkorg TYPE vkorg , " Sales Organization
          vtweg TYPE vtweg , " Distribution Channel
          kunag TYPE kunnr , " Customer Number
          datbi TYPE datbi,  " Valid To Date
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
          datab TYPE kodatab, " Validity start date of the condition record
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
          knumh TYPE knumh, " Condition record number
        END OF lty_con_946 ,

*--Begin of Insert for SCTASK0521172 04-Oct-17 by MTHATHA
        BEGIN OF lty_con_914,
          kappl TYPE kappl,  " Application
          kschl TYPE kschl , " Condition Type
          vkorg TYPE vkorg , " Sales Organization
          vtweg TYPE vtweg , " Distribution Channel
          kunwe TYPE kunnr , " Customer Number
          datbi TYPE datbi,  " Valid To Date
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*          datab TYPE kodatab, " Validity start date of the condition record
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
          knumh TYPE knumh, " Condition record number
        END OF lty_con_914 ,
*--End of Insert for SCTASK0521172 04-Oct-17 by MTHATHA

        BEGIN OF lty_con_935,
          kappl TYPE kappl,   " Application
          kschl TYPE kschl ,  " Condition Type
          vkorg TYPE vkorg ,  " Sales Organization
          vtweg TYPE vtweg ,  " Distribution Channel
          kunag TYPE kunnr ,  " Customer Number
          kunwe TYPE kunwe ,  " Ship-to party
          matnr TYPE matnr  , " Material Number
          datbi TYPE datbi,   " Valid To Date
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
          datab TYPE kodatab, " Validity start date of the condition record
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
          knumh TYPE knumh,   " Condition record number
        END OF lty_con_935  ,



        BEGIN OF lty_con_005,
          kappl TYPE kappl,   " Application
          kschl TYPE kschl ,  " Condition Type
          vkorg TYPE vkorg ,  " Sales Organization
          vtweg TYPE vtweg ,  " Distribution Channel
          kunnr TYPE kunnr ,  " Ship-to party
          matnr TYPE matnr  , " Material Number
          datbi TYPE datbi,   " Valid To Date
*--> Begin of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
*-->Begin of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*          datab TYPE kodatab, " Validity start date of the condition record
*<--End of Insert for D3_OTC_IDD_0203_Defect#6163_INC0394429-02 by AMOHAPA on 08-Feb-2019
*<-- End of Delete for D3_OTC_IDD_0203_Defect#10027 by AMOHAPA on 05-Jul-2019
          knumh TYPE knumh,            " Condition record number
        END OF lty_con_005 ,



        BEGIN OF lty_item,
          vkorg    TYPE vkorg,             " Sales Organization
          vtweg    TYPE vtweg,             " Distribution Channel
          kunnr    TYPE kunnr,             " Customer Number
          kunwe    TYPE kunwe ,            " Ship-to party
          matnr    TYPE matnr ,            " Material Number
          kbetr    TYPE kbetr ,            " Rate (condition amount or percentage)
          konwa    TYPE konwa ,            " Rate unit (currency or percentage)
          kmein    TYPE kmein,             " Condition unit
          kpein    TYPE kpein,             " Condition pricing unit
          loevm_ko TYPE loevm_ko,       " Deletion Indicator for Condition Item
          datbi    TYPE datbi,             " Valid To Date
          datab    TYPE datab,             " Valid-From Date
          ztext    TYPE char40,            " Ztext of type CHAR40
        END OF lty_item,

        BEGIN OF lty_tcurc,
          waers TYPE waers_curc,       " Currency Key
        END OF lty_tcurc,

        BEGIN OF lty_text_create,
          tdid       TYPE tdid,       " Text ID
          fname      TYPE tdobname,   " Name
          tdline     TYPE  tline   ,  " SAPscript: Text Lines
          cond_value TYPE sxmsdvalue, "Conidition  no
        END OF lty_text_create.
