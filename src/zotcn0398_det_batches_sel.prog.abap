*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_SEL
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTC_EDD0398_DET_BATCHES                               *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Dhanasekar Arumugam                                    *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials                 *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 24-Jan-2018 DARUMUG  E1DK934038 INITIAL DEVELOPMENT                  *
* 05-Mar-2018 DARUMUG  E1DK934038 CR# 212 Added Corresponding Batch    *
*                                 logic                                *
* 11-Mar-2018 DDWIVEDI E1DK934038 CR# 231 Manual batch inclusion       *
* 03-May-2018 DARUMUG  E1DK936439 Defect# 5957 Add Multiple SOrg's     *
* 27-Jun-2018 DARUMUG  E1DK937390 Defect# 6508 Unlock SO's once batch  *
*                                              is determined           *
* 02-Jul-2018 DARUMUG  E1DK937511 INC0423487 Defect# 6633 Consider     *
*                                 validity dates from Condition Records*
*                                 for Prioritization rules             *
* 08-Aug-2018 SMUKHER4 E1DK938198 CR# 307:Excel File upload for BDP tool*
* 04-Oct-2018 SMUKHER4 E1DK938946 Defect# 7289: Enabling background    *
*                                 functionality for BDP tool           *
* 29-Oct-2019 U033959  E2DK927169 Defect#10665- INC0433610-01          *
*                                 When split file check box is selected*
*                                 for background mode, then the records*
*                                 in the uploaded file will be split   *
*                                 into multiple files & mulitple       *
*                                 background jobs will be triggered.   *
*                                 Each file file contain no.of records *
*                                 as maintained in EMI                 *
*&---------------------------------------------------------------------*

*&-->Begin of delete for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

*selection-screen begin of block a1 with frame title text-001.
*
*select-options: s_matnr  for gv_matnr,
*                s_werks  for gv_plant no intervals no-extension,    "Defect# 5957
*                s_vkorg  for gv_vkorg obligatory,  "Sales Organization
*                s_vtweg  for gv_vtweg,             "Distribution Channel
*                s_rqdate for gv_rdate obligatory,  "Req Dlv Date
*                s_ordty  for gv_auart,             "Order Type
*                s_docno  for gv_docno,
*                s_soldto for gv_soldto,
*                s_charg  for gv_batch.
*
*parameters      p_unso as checkbox default space.
*
*selection-screen end of block a1.

*&<--End of delete for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018

*&-->Begin of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
*           'Online' Radio Button
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
PARAMETERS: rb_onln RADIOBUTTON GROUP rb1 DEFAULT 'X' USER-COMMAND comm1.
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
SELECTION-SCREEN BEGIN OF BLOCK a6 WITH FRAME. "TITLE text-044.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
SELECT-OPTIONS: s_matnr  FOR gv_matnr MODIF ID mi1,                           "Material Number
                s_werks  FOR gv_plant MODIF ID mi1 NO INTERVALS NO-EXTENSION, "Plant
                s_vkorg  FOR gv_vkorg MODIF ID mi1,                           "obligatory,                 "Sales Organization
                s_vtweg  FOR gv_vtweg MODIF ID mi1,                           "Distribution Channel
                s_rqdate FOR gv_rdate MODIF ID mi1,                           "obligatory,                   "Req Dlv Date
                s_ordty  FOR gv_auart MODIF ID mi1,                           "Order Type
                s_docno  FOR gv_docno MODIF ID mi1,                           "Sales Document Number
                s_soldto FOR gv_soldto MODIF ID mi1,                          "Sold-to Party
                s_charg  FOR gv_batch  MODIF ID mi1.                          "Batch number

PARAMETERS      p_unso AS CHECKBOX DEFAULT space MODIF ID mi1.
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
SELECTION-SCREEN END OF BLOCK a6.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
**           'Excel file' Radio Button
PARAMETERS: rb_file RADIOBUTTON GROUP rb1.
*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
SELECTION-SCREEN BEGIN OF BLOCK a8 WITH FRAME. "TITLE text-044.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
* For Processing Mode Selection - Verify or Post
SELECTION-SCREEN BEGIN OF BLOCK a3 WITH FRAME TITLE text-024.
* Verify and Post Radio Button
PARAMETERS: rb_vrfy RADIOBUTTON GROUP rb2 MODIF ID mi2 DEFAULT 'X',
            rb_post RADIOBUTTON GROUP rb2 MODIF ID mi2.
SELECTION-SCREEN END OF BLOCK a3.

* Selection Screen for Input File Location
SELECTION-SCREEN BEGIN OF BLOCK a4 WITH FRAME TITLE text-025.
* Input from Presentation Server Block
SELECTION-SCREEN BEGIN OF BLOCK a5 WITH FRAME TITLE text-026.

* Presentation Server File Inputs
PARAMETERS: p_ifile  TYPE char1024  MODIF ID mi2. " Local file for upload/download
PARAMETERS: p_lfile  TYPE char1024 MODIF ID mi2. " Local file for upload/download
SELECTION-SCREEN END OF BLOCK a5.
SELECTION-SCREEN END OF BLOCK a4.

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
SELECTION-SCREEN END OF BLOCK a8.
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018

*&-->Begin of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018
*&--Application Server file Inputs
PARAMETERS: rb_back RADIOBUTTON GROUP rb1.
SELECTION-SCREEN BEGIN OF BLOCK a7 WITH FRAME.
PARAMETERS: p_afile TYPE char1024 MODIF ID mi3. " Local file for upload/download
*--> Begin of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
PARAMETERS : ch_split AS CHECKBOX MODIF ID mi3.
*<-- End of Insert for INC0433610-01-Defect#10665 D3_OTC_EDD_0398 by U033959 dated 29-Oct-2019
SELECTION-SCREEN END OF BLOCK a7.
PARAMETERS: p_name TYPE sy-uname NO-DISPLAY. " User Name
PARAMETERS: p_tbp TYPE localfile NO-DISPLAY. " Local file for upload/download
*&<--End of changes for D3_OTC_EDD_0398 Defect# 7289 by APODDAR on 04-Oct-2018

SELECTION-SCREEN END OF BLOCK a1.

*&<--End of changes for D3_OTC_EDD_0398 R4 CR# 307 by SMUKHER4 on 08-Aug-2018
