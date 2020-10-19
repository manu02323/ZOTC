***********************************************************************
*Program    : ZOTCN0093B_SEND_PRICE_LIST_SCR                          *
*Title      : Send Price List                                         *
*Developer  : Salman Zahir                                            *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D3_OTC_EDD_0093                                           *
*---------------------------------------------------------------------*
*Description: This interface program send  price list to application  *
*             server in a text file format                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:                                                *
*=====================================================================*
*Date           User        Transport       Description               *
*=========== ============== ============== ===========================*
*22-NOV-2016    U033959     E1DK918891      Initial development for   *
*                                           CR#249 and CR#255         *
*---------------------------------------------------------------------*


SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
* Presentation sever radiobutton
PARAMETERS: rb_pres  RADIOBUTTON GROUP rb2 USER-COMMAND comm2 MODIF ID mi1 DEFAULT 'X'.

* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
* File path presentation
PARAMETERS: p_phdr   TYPE localfile MODIF ID mi3. " Local file for upload/download
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN SKIP 1.
* Application sever radiobutton
PARAMETERS: rb_app   RADIOBUTTON GROUP rb2 MODIF ID mi1 .
* Input for application server block
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-008.
* Application sever radiobutton
PARAMETERS: rb_aphy  RADIOBUTTON GROUP rb4 MODIF ID mi5 DEFAULT 'X' USER-COMMAND comm4,
* File path application server
            p_ahdr   TYPE localfile MODIF ID mi2. " Local file for upload/download

* Logical file radiobutton
PARAMETERS: rb_alog RADIOBUTTON GROUP rb4    MODIF ID mi5,
* Logical file path application server
            p_alog  TYPE filepath-pathintern MODIF ID mi7. " Logical path name
SELECTION-SCREEN END OF BLOCK b3.
SELECTION-SCREEN END OF BLOCK blk1.
* Block for Active/Inactive radio buttons
SELECTION-SCREEN : BEGIN OF BLOCK bl7 WITH FRAME TITLE text-011.
PARAMETERS : rb_act   RADIOBUTTON GROUP rb5,
             rb_inact RADIOBUTTON GROUP rb5.
SELECTION-SCREEN : END OF BLOCK bl7.
* Block for date
SELECTION-SCREEN: BEGIN OF BLOCK bl1 WITH FRAME.
SELECTION-SCREEN: BEGIN OF BLOCK bl2 WITH FRAME TITLE text-003.
PARAMETERS : p_ersda type ersda. " Created On
SELECTION-SCREEN: END OF BLOCK bl2.
* Block for condtion type and table
SELECTION-SCREEN: BEGIN OF BLOCK bl3 WITH FRAME TITLE text-004.
PARAMETERS : p_cond TYPE kschl  OBLIGATORY. "Selection Condition Type
PARAMETERS : p_tab  TYPE kotabnr  OBLIGATORY. " Condition table
SELECTION-SCREEN: END OF BLOCK bl3.
SELECTION-SCREEN: BEGIN OF BLOCK bl6 WITH FRAME TITLE text-007.
SELECT-OPTIONS  : s_vkorg FOR gv_vkorg OBLIGATORY NO INTERVALS NO-EXTENSION.
SELECT-OPTIONS  : s_vtweg FOR gv_vtweg OBLIGATORY NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN: END OF BLOCK bl6.
* Block for material and customer
SELECTION-SCREEN: BEGIN OF BLOCK bl4 WITH FRAME.
SELECT-OPTIONS  : s_matnr FOR gv_matnr, " Material Number
                  s_kunag FOR gv_kunag, " Sold to party
                  s_kunwe FOR gv_kunwe. " Ship to party
SELECTION-SCREEN: END OF BLOCK bl4.

SELECTION-SCREEN: END OF BLOCK bl1.
