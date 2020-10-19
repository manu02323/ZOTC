*&---------------------------------------------------------------------*
*&  Include           ZOTCN0216B_SEND_TRAN_PRICE_SEL
***********************************************************************
*Program    : ZOTCI0216B_SEND_TRANSFER_PRICE                          *
*Title      : D3_OTC_IDD_0216_SEND TRANSFER PRICE TO EXTERNAL SYSTEM  *
*Developer  : Amlan mohapatra                                         *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_IDD_0216                                          *
*---------------------------------------------------------------------*
*Description: SEND TRANSEFER PRICE TO EXTERNAL  SYSTEM                *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport         Description
*=========== ============== ============== ===========================*
*02-NOV-2017   AMOHAPA      E1DK931691        Initial development      *
*23-MAR-2018   AMOHAPA      E1DK931691       FUT_ISSUE: Material type  *
*                                            has been added in the     *
*                                            selection screen and      *
*                                            material are filltered    *
*                                            from entries of MARA      *
*---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETERS: p_vkorg TYPE vkorg OBLIGATORY,                       " Sales Organization
            p_vtweg TYPE vtweg OBLIGATORY,                       " Distribution Channel
            p_spart TYPE spart OBLIGATORY,                       " Division
            p_kunnr TYPE kunag MATCHCODE OBJECT debi OBLIGATORY. " Sold-to party

SELECT-OPTIONS:
*-->Begin of Insert for D3_OTC_IDD_0216_R2 by AMOHAPA on 23-Mar-2018
                s_mtart FOR gv_mtart MATCHCODE OBJECT h_t134, "Material Type
*<--End of Insert for D3_OTC_IDD_0216_R2 by AMOHAPA on 23-Mar-2018
                s_kondm FOR gv_kondm MATCHCODE OBJECT h_t178,
                s_matnr FOR gv_matnr.

PARAMETERS: p_prsdt TYPE prsdt OBLIGATORY DEFAULT sy-datum. " Date for pricing and exchange rate

SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

PARAMETERS: rb_fl RADIOBUTTON GROUP rab1 DEFAULT 'X' USER-COMMAND ucomm.
PARAMETERS: rb_dl RADIOBUTTON GROUP rab1.

SELECT-OPTIONS: s_cdate FOR gv_cdate DEFAULT sy-datum MODIF ID m1.

SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.

PARAMETERS: rb_alv  RADIOBUTTON GROUP rab2 DEFAULT 'X' USER-COMMAND ucomm,
            rb_file RADIOBUTTON GROUP rab2,
            p_path    TYPE rlgrap-filename MODIF ID m2. " Local file for upload/download

SELECTION-SCREEN END OF BLOCK b3.
