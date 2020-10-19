*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

***************************************************************************
* PROGRAM    :  ZOTCCL_CPQ_PRICE_COND_LOAD~PROCESS_DATA                   *
* TITLE      :  Interface for receiving Price from  Oracle System (CPQ)   *
* DEVELOPER  :  Ramakrishnan Subramaniam                                  *
* OBJECT TYPE:  Interface                                                 *
* SAP RELEASE:  SAP ECC 6.0                                               *
*----------------------------------------------------------------------****
* WRICEF ID:   D3_OTC_IDD_0230                                            *
*-------------------------------------------------------------------------*
* DESCRIPTION:  Update Pricing condition records from Oracle System (CPQ) *
*-------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                   *
*=========================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                          *
* =========== ========  ==========   =====================================*
* 06-JUN-2019 U105322   E2DK924406  INITIAL DEVELOPMENT/D3_OTC_IDD_0230   *
*                                   SC Task# SCTASK0836007                *
*&------------------------------------------------------------------------*
TYPES:
  "For Text creation
  BEGIN OF ty_text_create,
    tdid       TYPE tdid,       " Text ID
    fname      TYPE tdobname,   " Name
    tdline     TYPE tline,      " SAPscript: Text Lines
    cond_value TYPE sxmsdvalue, " Conidition  no
  END OF ty_text_create,
  ty_text_create_t TYPE STANDARD TABLE OF ty_text_create.
