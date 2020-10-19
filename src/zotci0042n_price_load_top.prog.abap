*&---------------------------------------------------------------------*
*&  Include           ZOTCI0042B_PRICE_LOAD_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD                                  *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: Bio-Rad requires an interface to handle new entries and
* changes to the Transfer Price.This will not be a real time price
* update to the ECC system, but a periodic upload of the transfer price.
* This interface gives the ability to upload Transfer Price into the ECC
* system using a flat file. The format of the upload template will be a
* tab-delimited txt file. The upload program would read the flat file and
* create transfer price condition records in the SAP system. To load the
* data from the flat file, we will use a custom transaction, which will
* be scheduled to run every mid-night.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-June-2012 SPURI  E1DK901668 INITIAL DEVELOPMENT                   *
*&---------------------------------------------------------------------*

tables : zmdm_legcy_cross.

class cl_abap_char_utilities definition load.

types:  begin of ty_leg_tab,
               kschl type  kschl ,
               vkorg type  vkorg ,
               vtweg type  vtweg ,
               kunnr type  kunnr ,
               konwa type  konwa ,
               matnr type  matnr ,
               kbetr type  char20 ,
               kpein type  konp-kpein ,
               kmein type  kmein ,
               datab type  char10 ,
               datbi type  char10 ,
         end of ty_leg_tab,


          begin of ty_leg_tab_c,
               kschl type  kschl ,
               vkorg type  vkorg ,
               vtweg type  vtweg ,
               kunnr type  kunnr ,
               konwa type  konwa ,
               matnr type  matnr ,
               kbetr type  char20 ,
               kpein type  char10 ,
               kmein type  kmein ,
               datab type  char10 ,
               datbi type  char10 ,
         end of ty_leg_tab_c,


         begin of ty_a005,
               kappl type  kappl ,
               kschl type  kschl ,
               vkorg type  vkorg ,
               vtweg type  vtweg ,
               kunnr type  kunnr ,
               matnr type  matnr ,
               datbi type  datbi ,
               datab type  datab ,
               knumh type  knumh,
         end of ty_a005,

          begin of ty_t685,
                  kschl type  kschl ,
          end of ty_t685,

         begin of ty_tvko,
                  vkorg type  vkorg ,
          end of ty_tvko,

         begin of ty_tvtw,
                  vtweg type  vtweg ,
          end of ty_tvtw,

          begin of ty_tcurc,
                  waers type  waers ,
          end of ty_tcurc,

          begin of ty_t006,
                  msehi type  msehi ,
          end of ty_t006,

         begin of ty_report,
            msgtyp type char1,      "Message Type E / S
            msgtxt type string,     "Message Text
            key    type string,     "Key of message
         end of ty_report,

          begin of ty_knvv,
            kunnr type knvv-kunnr,
            vkorg type knvv-vkorg,
            vtweg type knvv-vtweg,
            waers type knvv-waers,
          end of ty_knvv,


          begin of ty_kna1,
            kunnr type kna1-kunnr,
            aufsd type kna1-aufsd,
          end of ty_kna1,


          begin of ty_mvke,
            MATNR type mvke-matnr,
            VKORG type mvke-vkorg,
            VTWEG type mvke-vtweg,
          end of ty_mvke,



         ty_t_report type standard table of ty_report. " Report display

constants:
*c_tab        type char1 value cl_abap_char_utilities=>horizontal_tab, " Horizontal Tab Stop Character
           c_semicolon  type char1 value ';',
           c_nline      type char1 value cl_abap_char_utilities=>cr_lf,          " Carriage Return and Line Feed  Character Pair
           c_comma      type char1 value ',',                                    " Comma
           c_selected   type char1 value 'X',                                    " Constant declaration of type char1 with value 'X'
           c_extn       type char3 value 'TXT',                                  " Constant declaration of type string with value 'TXT'
           c_msgtyp     type msgty value 'E',                                    " Constant declaration for message type
           c_tobeprscd  type char3 value 'TBP',     "TBP Folder
           c_done_fold  type char4 value 'DONE',    "Done Folder
           c_err_fold   type char5 value 'ERROR',   "Error folder
           c_error      type char1  value 'E',      "Error Indicator
           c_app_area   type char1  value 'V',      "Error Indicator
           c_table      type t681-kotabnr  value '005',
           c_mode_a(1)  type c      value 'A',
           c_mode_b(1)  type c      value 'B'.




data:      gv_mtext      type string,       " text used in concatenation
           gv_mkey       type string,       " key used in concaenation
           gv_file       type localfile,    " Local file for upload/download
           gv_name       type localfile,    " Local file for upload/download
           gv_mode       type char10,       " Character Field Length = 10
           gv_subrc      type sy-subrc,     " Return Value of ABAP Statements
           gv_header     type string,       " Header String
           gv_filename   type localfile,    " Directory name
           gv_no_success1    type int4,         " Success counter
           gv_error      type int4,         " Error Count
           gv_skip       type int4,          " Skip Count
           gv_tot        type int4,         " alv total count
           gv_kbetr      type  char20 ,
           gv_kpein      type  char10 ,
           gv_date_from  type  char10 ,
           gv_date_to    type  char10 .


data:  i_leg_tab           type standard table of ty_leg_tab initial size 0,
       i_leg_tab_temp      type standard table of ty_leg_tab initial size 0,
       i_leg_tab_c         type standard table of ty_leg_tab_c initial size 0,
       i_a005              type standard table of ty_a005    initial size 0,
       i_t685              type standard table of ty_t685    initial size 0,
       i_tvko              type standard table of ty_tvko    initial size 0,
       i_tvtw              type standard table of ty_tvtw    initial size 0,
       i_tcurc             type standard table of ty_tcurc   initial size 0,
       i_t006              type standard table of ty_t006    initial size 0,
       i_leg_tab_err       type standard table of ty_leg_tab initial size 0,
       i_report            type ty_t_report,
       i_bdcdata           type standard table of bdcdata    initial size 0,
       i_messtab           type standard table of bdcmsgcoll initial size 0,
       i_knvv              type standard table of ty_knvv    initial size 0,
       i_kna1              type standard table of ty_kna1    initial size 0,
       i_mvke              type standard table of ty_mvke    initial size 0.

data:  wa_leg_tab      type ty_leg_tab,
       wa_leg_tab_c    type ty_leg_tab_c,
       wa_a005         type ty_a005,
       wa_t685         type ty_t685,
       wa_tvko         type ty_tvko,
       wa_tvtw         type ty_tvtw,
       wa_tcurc        type ty_tcurc,
       wa_t006         type ty_t006,
       wa_report       type ty_report,
       wa_knvv         type ty_knvv,
       wa_kna1         type ty_kna1,
       wa_mvke         type ty_mvke,
       gv_total2       TYPE int4,       "Total Record
       gv_no_success2  TYPE int4,       "Succes
       gv_no_failed2   TYPE int4.       "Failed


field-symbols : <fs_leg_tab>   type ty_leg_tab,
                <fs_leg_tab_c> type ty_leg_tab_c.
