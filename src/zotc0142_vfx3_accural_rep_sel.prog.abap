*&--------------------------------------------------------------------*
*&  Include           ZOTC0142_VFX3_ACCURAL_REP_SEL
*&--------------------------------------------------------------------*
***********************************************************************
*Program    : ZOTC0142_VFX3_ACCURAL_REP                               *
*Title      : D3_OTC_RDD_0142_VFX3_Accural Report                     *
*Developer  : ShivaNagh Samala                                        *
*Object type: Report                                                  *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID:  D3_OTC_RDD_0142                                          *
*---------------------------------------------------------------------*
*Description: Batch Master Date 1 Report                              *
*                                                                     *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ===========================*
*30-May-2019   U105235      E2DK924302     SCTASK0833109:Initial      *
*                                          development                *
*---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS : s_vkorg FOR vbrk-vkorg OBLIGATORY,    "Sales Org
                 s_vtweg FOR vbrk-vtweg,               "Distribution channel
                 s_vbeln FOR vbrk-vbeln,               "Billing Document
                 s_fkdat FOR vbrk-fkdat,               "Billing Date for Billing Index and Printout
                 s_erdat FOR vbrk-erdat.               "Date on Which Record Was Created
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
PARAMETERS :
rb_fore RADIOBUTTON GROUP rg1 DEFAULT 'X' USER-COMMAND aa MODIF ID xyz,
rb_back RADIOBUTTON GROUP rg1 MODIF ID xyz.

PARAMETERS :
p_text TYPE string MODIF ID xyz,     "text field to enter the email address
p_path TYPE rlgrap-filename MODIF ID abc.
SELECTION-SCREEN END OF BLOCK b2.
