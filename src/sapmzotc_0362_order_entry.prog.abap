*&---------------------------------------------------------------------*
*& Module Pool       SAPMZOTC_0362_ORDER_ENTRY
*&
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  SAPMZOTC_0362_ORDER_ENTRY                              *
* TITLE      :  EHQ_USPA_Order Entry                                   *
* DEVELOPER  :  Neha Garg                                              *
* OBJECT TYPE:  Enhancement                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0362                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:   Create order using Split Idoc logic for EHQ/USPA      *
*                scenarios and Biorad/Diamed Scenarios.                *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE         USER      TRANSPORT  DESCRIPTION                        *
* ===========  ========  ========== ===================================*
* 04-10-2016   NGARG     E1DK922236 Initial Development
* ===========  ========  ========== ===================================*
* 27-10-2016   NGARG     E1DK922236 Defect#5694:                       *
*                                   a)No option to come out of the     *
*                                   Custom Order entry screen          *
*                                   b)Fix table control to take more   *
*                                   than one entry at once             *
*                                   c) Error message should come for   *
*                                   the material it is generated for,  *
*                                   not all
* ===========  ========  ========== ===================================*
PROGRAM sapmzotc_0362_order_entry  MESSAGE-ID zotc_msg.


* Class Methods declaration
INCLUDE mzotc_0362_order_entry_cl. " Include MZOTC_0362_CREATE_ENTRY_CL
*TOP include
INCLUDE mzotc_0362_order_entry_top . " INCLUDE for table control data (gen.)
* Class/methods implementation
INCLUDE mzotc_0362_order_entry_icl. " Include MZOTC_0362_CREATE_ENTRY_ICL
* Screen Ouput modules
INCLUDE mzotc_0362_order_entry_o01 . " INCLUDE for table control output module (gen.)
* Screen Input modules
INCLUDE mzotc_0362_order_entry_i01 . " INCLUDE for table control input module (gen.)
* Forms definitions
INCLUDE mzotc_0362_order_entry_f01 . " INCLUDE for TABLECONTROL subroutine (gen.)
