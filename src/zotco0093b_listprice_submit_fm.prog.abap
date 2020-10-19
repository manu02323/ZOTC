*&--------------------------------------------------------------------*
*& PROGRAM   :  zotco0093b_listprice_submit_fm.                       *
* TITLE      :  Report program to submit FM MAST_CREATE_COND_A        *
* DEVELOPER  :  Moushumi Bhattacharya                                 *
* OBJECT TYPE:  INTERFACE                                             *
* SAP RELEASE:  SAP ECC 6.0                                           *
*---------------------------------------------------------------------*
* WRICEF ID  :  D3_OTC_IDD_0093                                       *
*---------------------------------------------------------------------*
* DESCRIPTION:  Sub Program to submit FM MAST_CREATE_COND_A           *
*---------------------------------------------------------------------*
* MODIFICATION HISTORY:                                               *
*=====================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                         *
* =========== ======== ===============================================*
* 28-Oct-2016 JAHANM  E1DK918891 Defect#5444 Performance Improvement  *
**---------------------------------------------------------------------*

REPORT zotco0093b_listprice_submit_fm NO STANDARD PAGE HEADING
                                      LINE-SIZE 132
                                      MESSAGE-ID zotc_msg.

DATA :i_knumh         TYPE STANDARD TABLE OF vkkacondit, " Gen. Condition Transfer: Condition Key
      gv_mem_id        TYPE char22.

PARAMETERS: p_edi TYPE edi_mestyp OBLIGATORY. " Message Type
PARAMETERS: p_dir TYPE abap_bool DEFAULT 'X'.
PARAMETERS: p_mem TYPE char22.

gv_mem_id = p_mem.

*IMPORT i_knumh_dyn = i_knumh FROM SHARED BUFFER indx(st) ID gv_mem_id.
*DELETE FROM SHARED BUFFER indx(st) ID gv_mem_id.

IMPORT i_knumh_dyn TO i_knumh FROM DATABASE indx(ar) CLIENT sy-mandt ID gv_mem_id.

DELETE FROM DATABASE indx(st) ID gv_mem_id.

*----------------------------------------------------------------------*
*     START - OF - SELECTION
*----------------------------------------------------------------------*
START-OF-SELECTION.

CALL FUNCTION 'MASTERIDOC_CREATE_COND_A'
  EXPORTING
    pi_mestyp                 = p_edi
    pi_direkt                 = p_dir
  TABLES
    pit_conditions            = i_knumh
  EXCEPTIONS
    idoc_could_not_be_created = 1.
IF sy-subrc = 0.
  COMMIT WORK.
ELSE. " ELSE -> IF sy-subrc = 0
  ROLLBACK WORK.
ENDIF. " IF sy-subrc = 0
