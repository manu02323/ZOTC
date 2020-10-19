*&---------------------------------------------------------------------*
*& REPORT  ZOTCC0050O_REBATE_CONVERSION
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    : ZOTCN0050O_MASTER_RECIPE_TOP                            *
* TITLE      :  OTC_CDD_0050_Convert_Rebate                            *
* DEVELOPER  :  SATEERTH DAS                                           *
* OBJECT TYPE:  Conversion                                             *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_CDD_0050_Convert_Recipe                              *
*----------------------------------------------------------------------*
* DESCRIPTION: Uploads a user-generated spreadsheet (tab delimited)
*              file for a Call Transaction of VBO1 (create rebate).
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 26-Jul-2012 SDAS     E1DK903273 INITIAL DEVELOPMENT                  *
* 31-Oct-2012 SPURI    E1DK905593 Defect 1247 : Incorrect
*                                 number of Agreements created for a
*                                 unique combination of Customer  and
*                                 GPO number.  Code Change : Removed
*                                 AT NEW statement  instead declared a
*                                 local variable to hold previous value
*                                 of GPO and customer.
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       Constants                                                      *
*----------------------------------------------------------------------*
  CONSTANTS: c_tab TYPE char1 VALUE
             cl_abap_char_utilities=>horizontal_tab,
             c_lp_ind   TYPE char1 VALUE 'X', "X = Logical File Path
             c_text     TYPE char3 VALUE 'TXT', "Extension .TXT
             c_mode_test TYPE c VALUE 'T',
             c_mode_post TYPE c VALUE 'P',
             c_error    TYPE char1 VALUE 'E', "Success Indicator
             c_success  TYPE char1 VALUE 'S', "Error Indicator
             c_tcode    TYPE sytcode VALUE 'VBO1', "T-code to upload
             c_tobeprscd  TYPE char3 VALUE 'TBP',     "TBP Folder
             c_done_fold  TYPE char4 VALUE 'DONE',    "Done Folder
             c_err_fold   TYPE char5 VALUE 'ERROR',   "Error folder
             c_x          type char1 VALUE 'X',       " Value X
             c_filetype     TYPE char10     VALUE 'ASC',    "File type
             c_session     TYPE char11  VALUE 'ZOTC_REBATE',
             c_zidn        TYPE BOART   VALUE 'ZIDN',
             c_zgpo        TYPE BOART   VALUE 'ZGPO'.
*----------------------------------------------------------------------*
*       DECLARATION OF TYPES                                           *
*----------------------------------------------------------------------*
 TYPES : Begin of ty_final ,
        VKORG TYPE  char4,
        VTWEG TYPE  char2,
        SPART TYPE  char2,
        VKBUR TYPE  char4,
        BOART TYPE  char4,
        ABTYP TYPE  char1,
        KAPPL TYPE  char2,
        BONEM TYPE  char10,
        WAERS TYPE  char5,
        ABREX TYPE  char20,
        EKORG TYPE  char4,
        BOLIF TYPE  char10,
        ABSPZ TYPE  char1,
        BOSTA TYPE  char1,
        DATAB TYPE  char8,
        DATBI TYPE  char8,
        KOBOG TYPE  char4,
        KDKGR TYPE  char3,
        BOTEXT  TYPE  char40,
        ZLSCH TYPE  char1,
        VALTG TYPE  char2,
        VALDT TYPE  char8,
        ZTERM TYPE  char4,
        BUKRS TYPE  char4,
        KSCHL TYPE  char4,
        KBETR TYPE  char11,
        BOMAT TYPE  char18,
        KBRUE TYPE  char11,
     End of ty_final .

*----------------------------------------------------------------------*
*       Internal Table and Work Area                                   *
*----------------------------------------------------------------------*

Data : i_final TYPE STANDARD TABLE OF ty_final,
       i_final1 TYPE STANDARD TABLE OF ty_final,
       i_final2 type standard table of ty_final ,
       i_final3 type standard table of ty_final ,
       wa_final TYPE ty_final,
       wa_final1 type ty_final,
       wa_final2 type ty_final,
       wa_final3 type ty_final,
       i_bdcdata  TYPE STANDARD TABLE OF bdcdata,
       wa_bdcdata TYPE bdcdata.

*----------------------------------------------------------------------*
*       Variables                                                      *
*----------------------------------------------------------------------*
  DATA:   gv_file     TYPE localfile,    "File name
          gv_mode     TYPE char10,       "Mode of transaction
          gv_success  TYPE int2,         "Success counter
          gv_error    TYPE int2,         "Error Count
          gv_line     TYPE int2,         "number of lines
          gv_err_flg  TYPE char1.        "Error Flag
