*&---------------------------------------------------------------------*
*&  Include         ZOTCN0028O_PRICING_REP_SS
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0028O_PRICING_REP_SS                              *
* TITLE      :  Pricing Report for Mass Price Upload                   *
* DEVELOPER  :  Vinita Choudhary                                       *
* OBJECT TYPE:  Include                                                 *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    OTC_RDD_0028_Pricing Report for Mass Price Upload      *
*----------------------------------------------------------------------*
* DESCRIPTION: This is an include program of Report                    *
*              ZOTCR0028O_PRICING_REPORT_NEW All selection parameters  *
*              of selection screen are declared in this include program.*
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== =======  ========== =====================================*
* 22-Jul-2015 VCHOUDH  E2DK914250 INITIAL DEVELOPMENT        -         *
*----------------------------------------------------------------------*
* 28-Aug-2015 DMOIRAN  E2DK914250 Defect 913
*&---------------------------------------------------------------------*
TABLES : zotc_territ_assn, " Comm Group: Territory Assignment
         a985.             " Sales org./Distr. Chl/SalesDocTy/National Ac/Matl grp 4



SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS : p_kappl TYPE t681a-kappl DEFAULT 'V'. " Application
PARAMETERS : p_kschl TYPE t685-kschl. " Condition Type
SELECTION-SCREEN END OF BLOCK b1.


SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS : p_tab TYPE kotabnr  . " Condition table
*PARAMETERS : p_tab1 type kotabnr as LISTBOX VISIBLE LENGTH 100 USER-COMMAND cmd1.
SELECTION-SCREEN END OF BLOCK b2.





* ---> Begin of Insert for D2_OTC_RDD_0028 Defect 913 by DMOIRAN
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-003.
  selection-SCREEN begin of line.
PARAMETERS : p_rdat RADIOBUTTON GROUP r3 DEFAULT 'X' USER-COMMAND cmd4.
SELECTION-SCREEN comment (20) text-099 for field p_rdat.
 PARAMETERS: p_rdatbi RADIOBUTTON GROUP r3.
SELECTION-SCREEN comment (20) text-098 for field p_rdatbi.
    SELECTION-SCREEN end of line .

PARAMETERS:  p_datab TYPE kodatab DEFAULT sy-datum MODIF ID m8. " Validity start date of the condition record
*---> Begin of Insert for D2_OTC_RDD_0028/Defect 1144 by VCHOUDH.
SELECT-OPTIONS : s_datbi FOR a985-datbi MODIF ID m9. " Validity end date of the condition record
*<--- End of Insert for D2_OTC_RDD_00028/Defect 1144 by VCHOUDH.

*             p_datbi TYPE kodatbi. " Validity end date of the condition record
SELECTION-SCREEN END OF BLOCK b4.
* <--- End    of Insert for D2_OTC_RDD_0028 Defect 913 by DMOIRAN

SELECT-OPTIONS:  s_srep  FOR zotc_territ_assn-territory_id . " Partner Territory ID
*---> Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH
SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-015.
PARAMETERS : p_xls  RADIOBUTTON GROUP r2 DEFAULT 'X',
             p_txt  RADIOBUTTON GROUP r2.
SELECTION-SCREEN END OF BLOCK b5.
*<--- End of Insert for D2_OTC_RDD_00028_Defect_913 by VCHOUDH.

*---> Begin of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.
SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE text-016.
PARAMETERS : p_chk1 AS CHECKBOX DEFAULT 'X'.
PARAMETERS : p_chk2 AS CHECKBOX USER-COMMAND cmd3.
SELECTION-SCREEN END OF BLOCK b6.

*<--- End of Insert for D2_OTC_RDD_0028_Defect_913 by VCHOUDH.


SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-010 .
PARAMETERS : p_pres RADIOBUTTON GROUP r1 USER-COMMAND cmd  DEFAULT 'X' , "   Presentation server option
             p_app RADIOBUTTON GROUP r1 ,                                "  Application server option
             p_email RADIOBUTTON GROUP r1 .                              "  email option

PARAMETERS : p_file  TYPE rlgrap-filename MODIF ID m1,       "  File path presentation server
             p_afpath TYPE  filepath-pathintern MODIF ID m2, "  Logical file path
             p_afile  TYPE  rlgrap-filename MODIF ID m2 ,    " File name
             p_affile TYPE rlgrap-filename MODIF ID m2,      "  actual file name
             p_mail TYPE  adr6-smtp_addr MODIF ID m3.        "   valid email Id
SELECTION-SCREEN END OF BLOCK b3.
