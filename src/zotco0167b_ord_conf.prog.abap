***********************************************************************
*Program    : ZOTCO0167B_ORD_CONF                                      *
*Title      : Order acknowledgement                                   *
*Developer  : Nidhi Saxena (NSAXENA)                                  *
*Object type: Interface                                               *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0167_SAP                                       *
*---------------------------------------------------------------------*
*Description: Send Order acknowledgement to PI and PI will send it    *
* as EMAIL in HTML format.                                            *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*01-Dec-2014  NSAXENA       E2DK906816     Initial DEvelopment.       *
*22-jan-2014  NSAXENA       E2DK906816     Defect #3124- Change the   *
*                                          logic for ship to and sold *
*                                          to address details.        *
*27-Feb-2015  NSAXENA       E2DK906816      Defect # 3587-Using FM to *
*                                           Convert intrnal format txt*
*                                           to external format text   *
*18-Mar-2015  NSAXENA       E2DK906816      Defect - 4825,Add texts id*
* at item level with text id Z014 and Z017  for more matrl description*
*Also, adding Street 3 logic for Mexico address                       *
*For Defect - 4872, no change ate ABAP Side only PI mapping required  *
*for Additional House id at Ship to address details                   *
*                                                                     *
*20-Mar-2015  NSAXENA       E2DK906816      Defect-5109,Only Bio Rad  *
*Employees should get the email triggered in dev and quality system,  *
* while in Prdctn any email id can get the email generatd to its inbox*.
*                                                                     *
*30-Mar-2015 NSAXENA        E2DK906816     Defect-5418 Removing the   *
*text id Z017 detail at item level to keep FDD-12,FDD-14 and IDD-0167 *
* in sync. Adding the new Tax calculations logic at item level.       *
*                                                                     *
*31-Mar-2015 NSAXENA        E2DK906816      Defect-4414 email id blank*
*has been picked up for contact perosn details.                       *
*                                                                     *
*31-Mar-2015 NSAXENA        E2DK906816      Defect-5424 Est del date  *
* should not print when the confirmed qty is 0 for that line item.    *
*                                                                     *
*13-Apr-2015 NSAXENA     E2DK906816         Defect-5319 Processing log*
* has been updated with message id whenever the the sales order get   *
* successfully triggered.                                             *
*                                                                     *
*16-Apr-2015 NSAXENA     E2DK906816    Defect-6018,Unit Price and     *
*extended price logic chnage                                          *
*                                                                     *
*24-Apr-2015 NSAXENA     E2DK906816 Defect-6219,Discard Rejected Lines*
*---------------------------------------------------------------------*
*29-Jun-2016 NGARG       E1DK919590 Description:D3_OTC_IDD_0167:Change*
*                                   language,use SOLD-TO-PARTY's      *
*                                   language for ZBA1 and ZBA0 output *
*                                   where VKORG is not 1000/1020/1103.*
*                                   For ZCON , set default system     *
*                                   language                          *
*                                   Email Address: For cases where    *
*                                   both CP and ZA are maintained ,   *
*                                   fill email address for both       *
*---------------------------------------------------------------------*
*24-Aug-2016  NGARG     E1DK919590 Defect #3102: The Label             *
*                                 'Attention To' is being sent from    *
*                                 ABAP, hence needed translation here. *
*                                 Also, 'Order Comment' value text was *
*                                 being read in english, hence every   *
*                                 where a text is being read using     *
*                                'READ_TEXT', we have passed gv_spras  *
*                                 language based on Partner). So now   *
*                                 whole email is sent only in partner's*
*                                language.                             *
*----------------------------------------------------------------------*
* 31-Aug-2016  NGARG  E1DK919590 Defect#3682: In order comments field, *
*                                convert the single string into 3 different
*                                strings.                              *
*                                Each for sales order text, reference  *
*                                text and case reference text          *

*----------------------------------------------------------------------*
* 09-Sep-2016 NGARG  E1DK919590 Defect#3931: Remove Carrier( Shipping  *
*                                            conditions) field         *
*----------------------------------------------------------------------*
* 15-Sep-2016 NGARG E1DK919590 Defect#4090: Change text and position   *
*                              of refernce doc type and change subject *
*                              line text
*&---------------------------------------------------------------------*
*09-May-2016 PDEBARU    E2DK917647   CR# 1612 : Change text TBD to    *
*                                    Header date if conf qty is 0     *
*---------------------------------------------------------------------*
*20-Dec-2016 MGARG      E1DK919590   Defect#6837_CR#289               *
*                                    Defect#6837:If customer’s langu  *
*                                    is neither EN, DE,ES orFR,default*
*                                    printing language should be EN   *
*                                    CR#289:Get Customer Address using*
*                                    FM for D3 only.                  *
*                                    Header and Item text determination*
*                                    logic based on default langu     *
*&--------------------------------------------------------------------*
*11-Jan-2016 U034334/MGARG E1DK919590 CR#301: For D3 Sales Org        *
* - Print Name1, Name 2 fields of sales org in header                 *
* - Print Inco1 and Inco2 under incoterms                             *
*&--------------------------------------------------------------------*
*18-Jan-2016  MGARG     E1DK919590   Defect#8553: For D3 Sales Org    *
*                                    Customer Address format Change   *
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*09-Oct-2017  U029267   E1DK931267   D3 R2 Changes:                   *
*                                    1)Translate existing layout to   *
*                                      the languages Danish, Swedish, *
*                                      Norwegian and Finnish.         *
*                                    2)New labels are added for the   *
*                                      new field “Insurance”, “GLN”.  *
*                                    3) For Document Charges add the  *
*                                      value for the header pricing   *
*                                      condition ZDOC to the field    *
*                                     “Handling” when the pricing     *
*                                      condition is existing in the   *
*                                      sales order header.            *
*                                    4)Fix the Batch print alignment. *
*                                    5)Add Footer text for French only*
*                                    6)Include the bill-to partner    *
*                                      from the SO into the form      *
*                                    7)Envirmt. charge to be added in *
*                                      between "Tax" and "Handling".  *
*                                      Suppress the field from        *
*                                      printing when the value of the *
*                                      field is initial/zero.         *
*                                    8)If email ID of either Contact  *
*                                      Person (AP) or ORDER-Contact   *
*                                      Person (ZA) is present, output *
*                                      ZBA1 triggers 2 messges to PI, *
*                                      but if one of the partnr funct *
*                                      does not contain email ID,     *
*                                      that message fails in PI.      *
*&--------------------------------------------------------------------*
*08-Nov-2017  U029267   E1DK931267     Defect #4033: Change the       *
*                                      message description            *
*&--------------------------------------------------------------------*
*11-Jan-2019   MTHATHA  E1DK937583   SCTASK0764894:Esker Changes      *
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*19-May-2019   MTHATHA  E2DK924017   Commnted the above version change*
*&--------------------------------------------------------------------*
*&--------------------------------------------------------------------*
*21-May-2019   ASK  E2DK924099    INC0485087-01 Put the ESKER related change for    *
*                                 skipping EMAIL validations          *
*&--------------------------------------------------------------------*
*13-Jun-2019   U103062  E2DK924610   SCTASK0836003: Maintained EMI    *
*                                    entry instead of passing hard    *
*                                    coded value for ZESK condition   *
*                                    type                             *
*&--------------------------------------------------------------------*

REPORT  zotco0167b_ord_conf MESSAGE-ID zotc_msg.
INCLUDE zotcn0167b_ord_conf_top. " INCLUDE for General Table Descriptions for Print Programs
INCLUDE zotcn0167b_ord_conf_f01. " Include ZOTCN0167B_ORD_CONF_F01

*&---------------------------------------------------------------------*
*&      Form  call_proxy
*&---------------------------------------------------------------------*
*      -->FP_return_code        Return Code                               *
*      -->FP_US_SCREEN   Screen type                                      *
*----------------------------------------------------------------------*

FORM f_call_proxy USING fp_return_code TYPE sy-subrc  ##called " Return Value of ABAP Statements
                         fp_us_screen TYPE c.                  " Us_screen of type Character
*Types
  TYPES:
*For Email Id
    BEGIN OF lty_smtp_addr,
      addrnumber TYPE ad_addrnum, "Address number
      persnumber TYPE ad_persnum, "Person number
      date_from  TYPE ad_date_fr,  "Valid-from date
      consnumber TYPE ad_consnum, "Sequence Number
      smtp_addr  TYPE ad_smtpadr,  "E-Mail Address
    END OF lty_smtp_addr.

*Internal tables
  DATA: li_vbpa      TYPE STANDARD TABLE OF ty_vbpa,
        li_vbpa_tmp  TYPE STANDARD TABLE OF ty_vbpa,
        li_smtp_addr TYPE STANDARD TABLE OF lty_smtp_addr,
* ---> Begin of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
        li_status    TYPE STANDARD TABLE OF  zdev_enh_status. " Internal table for Enhancement Status
* <--- End of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXEN

*data declaration
  DATA: lref_po_proxy_out      TYPE REF TO co_sls_purchaseorderco,        "Ref for Proxy Object
        lref_protocol          TYPE REF TO if_wsprotocol_async_messaging, "Routing Protocoll for EOIO
        lv_context             TYPE prx_scnt,                             "Context
        lx_structure_out       TYPE sls_purchase_order_confirmati2,       "Output structure for Proxy
        lref_system_fault      TYPE REF TO cx_ai_system_fault,            " Application Integration: Technical Error
* ---> Begin of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
        lref_wsprotocol        TYPE REF TO if_wsprotocol,            " ABAP Proxies: Available Protocols
        lref_wsprotocol_msg_id TYPE REF TO if_wsprotocol_message_id, " XI and WS: Read Message ID
        lx_cx_root             TYPE REF TO cx_root,                  " Abstract Superclass for All Global Exceptions
        lv_xml_message_id      TYPE sxmsmguid,                       " XI: Message ID
        lv_msg_v1              TYPE oia_char50.                      "NAST Message
* <--- End of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN


*Constants
  CONSTANTS: lc_posnr         TYPE posnr_va VALUE '000000',  "Header Item count
             lc_otc_msg       TYPE arbgb VALUE 'ZOTC_MSG', "Message Class
             lc_msg_000       TYPE symsgno VALUE '000',    "Message Number
             lc_status_code   TYPE char2 VALUE 'AP',   "Status_code of type CHAR2
             lc_sold_to       TYPE parvw    VALUE 'AG',    "Bill-to party " added by nsaxena
             lc_ship_to       TYPE parvw    VALUE 'WE',    "Ship-to party  " added by nsaxena
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
             lc_bill_to       TYPE parvw    VALUE 'RE', "Bill-to party
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
             lc_ponof         TYPE char6  VALUE 'POCONF',    "Ponof of type CHAR6
             lc_nast          TYPE tabname VALUE 'NAST',      "Messages
             lc_tnapr         TYPE tabname VALUE 'TNAPR',    "Processing programs for output
             lc_contact       TYPE parvw    VALUE 'AP',    "Contact person " added by nsaxena
             lc_contact_other TYPE parvw VALUE 'ZA', "Contact person "added by nsaxena
* ---> Begin of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
             lc_sign          TYPE char1 VALUE '@',                                   "sepertor sign
             lc_system_id     TYPE z_criteria VALUE 'D2_OTC_IDD_0167_SYSTEM_ID', " Enh. Criteria
             lc_extension     TYPE z_criteria  VALUE 'D2_OTC_IDD_0167_EXT',      " Enh. Criteria
             lc_idd_0167      TYPE z_enhancement VALUE 'D2_OTC_IDD_0167',         "Enhancement number

* <--- End of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA

* ---> Begin of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
             lc_msg_907       TYPE symsgno     VALUE '907', " Message Number
* <--- End of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN

* ---> Begin of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019
             lc_zesk          TYPE z_criteria VALUE 'ZCOND_ZESK'.
* <--- End of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019

*Field Symbols
  FIELD-SYMBOLS:
    <lfs_x_nast>    TYPE nast,    "NAST Structure
    <lfs_vbpa>      TYPE ty_vbpa, "VBPA local structure
    <lfs_x_tnapr>   TYPE tnapr,  "TNAPR Structure
* ---> Begin of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
    <lfs_status>    TYPE zdev_enh_status,   "For Reading enhancement table
    <lfs_smtp_addr> TYPE lty_smtp_addr. "Production system
* <--- End of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
*Local Variables
  DATA: lv_retcode    TYPE sy-subrc, "Returncode
        lv_vbeln      TYPE vbeln_va,   "Sales Document
        lv_partner    TYPE symsgv,   "Message Variable
        lv_parnr_1    TYPE parnr,    "Number of contact person
        lv_parnr_2    TYPE parnr,    "Number of contact person
        lv_text       TYPE oia_char50,  "NAST Message
        lv_num        TYPE i,            " Num of type Integers
* ---> Begin of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
        lv_first_name TYPE char200, " First_name of type CHAR200
        lv_extension  TYPE char200,  " Extension of type CHAR200
        lv_lines      TYPE num2,         " 2-Digit Numeric Value
        lv_prod       TYPE sysysid,      "Production system
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
        lv_msg        TYPE symsgv,
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

* <--- End of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA

* ---> Begin of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019
        lv_zesk       TYPE kschl.        " Condition Type
* <--- End of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019

*BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
  DATA :   lx_struc_out2           TYPE sls_purchase_order_confirmati2. "Output structure for Proxy


*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

  REFRESH li_status[].

*BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

* GET EMI DATA
  CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
    EXPORTING
      iv_enhancement_no = lc_idd_0167 "Object id
    TABLES
      tt_enh_status     = li_status.  "Status internal table
*Non active entries are removed.
  IF li_status[] IS NOT INITIAL.
    DELETE li_status WHERE active EQ abap_false.
  ENDIF. " IF li_status[] IS NOT INITIAL
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG


*&--Assign NAST Structure
  ASSIGN (lc_tnapr) TO <lfs_x_tnapr>.
  IF <lfs_x_tnapr> IS ASSIGNED.
*&--Assign TNAPR Structure
    ASSIGN (lc_nast) TO <lfs_x_nast>.
    IF <lfs_x_tnapr> IS ASSIGNED.
* Begin of Change for INC0485087-01
*--Begin of changes manoj

* ---> Begin of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019
      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_zesk
                                                           sel_low  = <lfs_x_tnapr>-kschl.
**For condtion type ZESK
*      IF sy-subrc IS INITIAL.
*        lv_zesk = <lfs_status>-sel_low.
*      ENDIF. " IF sy-subrc EQ 0

* <--- End of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019

* ---> Begin of delete for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019
*      IF <lfs_x_tnapr>-kschl = 'ZESK'.
* <--- End of delete for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019

* ---> Begin of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019
*      IF <lfs_x_tnapr>-kschl = lv_zesk.
       IF SY-SUBRC EQ 0.
* <--- End of insert for D3_OTC_IDD_0167_SCTASK0836003 by U103062 on 13-Jun-2019
*When partner function and their email id is maintained.
        PERFORM f_processing USING fp_us_screen
                       <lfs_x_nast>
                       <lfs_x_tnapr>
                       li_vbpa
                        li_status
              CHANGING  lx_structure_out
                       lx_struc_out2
                       lv_retcode.
        fp_return_code = '0'.
        MOVE lc_status_code TO lx_structure_out-purchase_order_confirmation-purchase_order-acceptance_status_code.
        PERFORM f_create_proxy USING  lx_structure_out
                                      lv_vbeln.
      ELSE. " ELSE -> IF <lfs_x_tnapr>-kschl = 'ZESK'
*--End of changes manoj
* End  of Change for INC0485087-01
* Set return-code
        fp_return_code = '0'.
* Get Sales Order Number from NaSt
        lv_vbeln = <lfs_x_nast>-objky.

*Fecthing the data from VBPA Table
*We will check for partner function AP and ZA if this
*chcek is valid then check if the email id is maintianed,
*in case email id is not maintained processing log will created
*If the email is maintained then do the further processing.
        SELECT vbeln    " Sales and Distribution Document Number
               posnr    " Item number of the SD document
               parvw    "Partner Function
               kunnr    "Customer Number
               parnr    "Contact person number
               adrnr    "Address Number
               adrnp    "personnel number in case of ZA partner function
              FROM vbpa " Sales Document: Partner
              INTO TABLE li_vbpa
             WHERE vbeln = lv_vbeln
               AND posnr = lc_posnr
               AND parvw IN (lc_contact,lc_contact_other,lc_sold_to,lc_ship_to,
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                  lc_bill_to).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

        IF sy-subrc EQ 0.
          li_vbpa_tmp[] = li_vbpa[].

          DELETE li_vbpa_tmp WHERE parvw EQ lc_sold_to
          OR parvw EQ lc_ship_to
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
          OR parvw EQ lc_bill_to.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*To Check if the vba table has contact person partners maintained or not.
          DESCRIBE TABLE li_vbpa_tmp LINES lv_num.
*If there is no partner maintained for AP and ZA then update the NAST , processing log.
          IF lv_num EQ 0.
*When Partner function is not maintained.
*&--Information:
            fp_return_code = 4.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            CLEAR lv_msg.
            lv_msg = 'Partner for contact person details is not present'(012).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb              = lc_otc_msg                                               "Message class
                msg_nr                 = lc_msg_000                                               "Message number
                msg_ty                 = if_cwd_constants=>c_message_info
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*               msg_v1                 = 'Partner for contact person details is not present'(012) " Partner number
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                msg_v1                 = lv_msg " Partner number
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              EXCEPTIONS
                message_type_not_valid = 0
                no_sy_message          = 0
                OTHERS                 = 0.
            RETURN.
          ENDIF. " IF lv_num EQ 0
*Check for contact person with partner function AP
          READ TABLE li_vbpa_tmp ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact.
          IF sy-subrc EQ 0.
            lv_parnr_1 = <lfs_vbpa>-parnr.
          ENDIF. " IF sy-subrc EQ 0
*Check for contact person with partner function ZA
          READ TABLE li_vbpa_tmp ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact_other.
          IF sy-subrc EQ 0.
            lv_parnr_2 = <lfs_vbpa>-parnr.
          ENDIF. " IF sy-subrc EQ 0
*Collect partner function for error messages
          IF lv_parnr_1 IS NOT INITIAL AND lv_parnr_2 IS NOT INITIAL.
            CONCATENATE lv_parnr_1 'and' lv_parnr_2 INTO lv_partner SEPARATED BY space.
          ELSEIF lv_parnr_1 IS INITIAL.
            lv_partner = lv_parnr_2.
          ELSE. " ELSE -> IF lv_parnr_1 IS NOT INITIAL AND lv_parnr_2 IS NOT INITIAL
            lv_partner = lv_parnr_1.
          ENDIF. " IF lv_parnr_1 IS NOT INITIAL AND lv_parnr_2 IS NOT INITIAL
*Chcek if the Email address are not maintained
          SELECT  addrnumber                     "Address number
                  persnumber                     "Person number
                  date_from                      "Valid-from date - in current Release only 00010101 possible
                  consnumber                     "Sequence Number
                  smtp_addr                      "E-Mail Address
            FROM adr6                            "E-Mail Addresses (Business Address Services)
             INTO TABLE li_smtp_addr
          FOR ALL ENTRIES IN li_vbpa_tmp
           WHERE addrnumber = li_vbpa_tmp-adrnr. "Address number
          IF sy-subrc EQ 0.
*Delete address lines where the valid date is greater then current date
            DELETE li_smtp_addr WHERE date_from GT sy-datum.
            IF li_smtp_addr[] IS INITIAL.
*When Email id is not maintained.
*&--Information:
              fp_return_code = 4.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              CLEAR lv_msg.
              lv_msg = 'No Email Id has maintained for partner number'(009).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

              CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                EXPORTING
                  msg_arbgb              = lc_otc_msg                                           "Message class
                  msg_nr                 = lc_msg_000                                           "Message number
                  msg_ty                 = if_cwd_constants=>c_message_info
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*                 msg_v1                 = 'No Email Id has maintained for partner number'(009) " Partner number
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                  msg_v1                 = lv_msg " Partner number
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                  msg_v2                 = lv_partner                                           "Partner number
                EXCEPTIONS
                  message_type_not_valid = 0
                  no_sy_message          = 0
                  OTHERS                 = 0.
              RETURN.
            ELSE. " ELSE -> IF li_smtp_addr[] IS INITIAL
* ---> Begin of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
*When Email id is maintained, need to check its extension for non-production system
*Calling FM to get the emi table values.
*           BEGIN OF DELETE FOR D3_OTC_IDD_0167  BY NGARG
*            CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
*              EXPORTING
*                iv_enhancement_no = lc_idd_0167 "Object id
*              TABLES
*                tt_enh_status     = li_status.  "Status internal table
**Non active entries are removed.
*            DELETE li_status WHERE active EQ abap_false.
*           END OF DELETE FOR D3_OTC_IDD_0167  BY NGARG
*Read table to get the system id maintained in EMI.
              READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_system_id.
              IF sy-subrc EQ 0.
*Check for system id with emi entry.
                IF sy-sysid NE <lfs_status>-sel_low.
                  DESCRIBE TABLE li_smtp_addr LINES lv_lines.
*When Bith AP and ZA has email id maintained
                  IF lv_lines > 1.
*Choose contact person with AP type as it has priority over ZA type.
                    READ TABLE li_vbpa_tmp ASSIGNING <lfs_vbpa> WITH KEY parvw = lc_contact.
                    IF sy-subrc EQ 0.
*Read email id table based on address number passed from VBPA internal table
                      READ TABLE li_smtp_addr ASSIGNING <lfs_smtp_addr> WITH KEY addrnumber = <lfs_vbpa>-adrnr.
                      IF sy-subrc EQ 0.
*Converting the emil id to upper case
                        TRANSLATE <lfs_smtp_addr>-smtp_addr TO UPPER CASE.
                        SPLIT  <lfs_smtp_addr>-smtp_addr AT lc_sign INTO lv_first_name lv_extension.
*Read EMI table for Extension check
                        READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_extension.
                        IF sy-subrc EQ 0.
                          IF lv_extension NE <lfs_status>-sel_low.
                            fp_return_code = 4.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                            CLEAR lv_msg.
                            lv_msg = 'Email for NON BOI-RAD Id is not allowed'(013).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*when extension is not BIO-RAD.COM, update the Message in NAST.
                            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                              EXPORTING
                                msg_arbgb              = lc_otc_msg "Message class
                                msg_nr                 = lc_msg_000 "Message number
                                msg_ty                 = if_cwd_constants=>c_message_info
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*                               msg_v1                 = 'Email for NON BOI-RAD Id is not allowed'(013)
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                                msg_v1                 = lv_msg
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                              EXCEPTIONS
                                message_type_not_valid = 0
                                no_sy_message          = 0
                                OTHERS                 = 0.
                            RETURN.
                          ENDIF. " IF lv_extension NE <lfs_status>-sel_low
                        ENDIF. " IF sy-subrc EQ 0
                      ENDIF. " IF sy-subrc EQ 0
                    ENDIF. " IF sy-subrc EQ 0
*When only one email id is mainatained either or AP or ZA partner type
                  ELSE. " ELSE -> IF lv_lines > 1
                    READ TABLE li_smtp_addr ASSIGNING <lfs_smtp_addr> INDEX 1.
                    IF sy-subrc EQ 0.
                      TRANSLATE <lfs_smtp_addr>-smtp_addr TO UPPER CASE.
*Seperate the email id into two parts with name and extension and check for BIO-RAD.COM extension
                      SPLIT  <lfs_smtp_addr>-smtp_addr AT lc_sign INTO lv_first_name lv_extension.
                      READ TABLE li_status ASSIGNING <lfs_status> WITH KEY criteria = lc_extension.
                      IF sy-subrc EQ 0.
                        IF lv_extension NE <lfs_status>-sel_low.
                          fp_return_code = 4.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                          CLEAR lv_msg.
                          lv_msg = 'Email for NON BOI-RAD Id is not allowed'(013).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*when extension is not BIO-RAD.COM update the message log in NAST.
                          CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                            EXPORTING
                              msg_arbgb              = lc_otc_msg "Message class
                              msg_nr                 = lc_msg_000 "Message number
                              msg_ty                 = if_cwd_constants=>c_message_info
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*                             msg_v1                 = 'Email for NON BOI-RAD Id is not allowed'(013)
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                              msg_v1                 = lv_msg
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                            EXCEPTIONS
                              message_type_not_valid = 0
                              no_sy_message          = 0
                              OTHERS                 = 0.
                          RETURN.
                        ENDIF. " IF lv_extension NE <lfs_status>-sel_low
                      ENDIF. " IF sy-subrc EQ 0
                    ENDIF. " IF sy-subrc EQ 0
                  ENDIF. " IF lv_lines > 1
                ENDIF. " IF sy-sysid NE <lfs_status>-sel_low
              ENDIF. " IF sy-subrc EQ 0
* <--- End of Insert for D2_OTC_IDD_0167, Defect 5109 by NSAXENA
*When partner function and their email id is maintained.
              PERFORM f_processing USING fp_us_screen
                             <lfs_x_nast>
                             <lfs_x_tnapr>
                             li_vbpa
*  BEGIN OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG
                              li_status
*  END OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG

                    CHANGING  lx_structure_out
*  BEGIN OF INSERT FOR FOR D3_OTC_IDD_0167 BY NGARG
                             lx_struc_out2

*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

                             lv_retcode.
              fp_return_code = '0'.
* Set Acceptance Satus Code to AP = Accepted
              MOVE lc_status_code TO lx_structure_out-purchase_order_confirmation-purchase_order-acceptance_status_code.

*  BEGIN OF INSERT FOR D3_OTC_IDD_0167 BY NGARG
*           Create 2 XML , one for CP partner and another for ZA partner
*           NAST will get updated with Message id of both XML
              IF gv_partner EQ lc_contact.
                PERFORM f_create_proxy USING  lx_structure_out
                                              lv_vbeln.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              ELSE. " ELSE -> IF gv_partner EQ lc_contact
*When Email id is not maintained.
*&--Info:
                fp_return_code = 0.
                CLEAR lv_msg.
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
*              lv_msg = 'Partner for contact person AP is not present'(007).
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
                lv_msg = 'No e-mail will be sent to partner AP'(007).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
                CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                  EXPORTING
                    msg_arbgb              = lc_otc_msg "Message class
                    msg_nr                 = lc_msg_000 "Message number
                    msg_ty                 = if_cwd_constants=>c_message_warning
                    msg_v1                 = lv_msg
                  EXCEPTIONS
                    message_type_not_valid = 0
                    no_sy_message          = 0
                    OTHERS                 = 0.

* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17

              ENDIF. " IF gv_partner EQ lc_contact
              IF gv_partner2 EQ lc_contact_other.
                PERFORM f_create_proxy USING  lx_struc_out2
                                              lv_vbeln.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              ELSE. " ELSE -> IF gv_partner2 EQ lc_contact_other
*When Email id is not maintained.
*&--Info:
                fp_return_code = 0.
                CLEAR lv_msg.
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
*              lv_msg = 'Partner for contact person ZA is not present'(015).
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
                lv_msg = 'No e-mail will be sent to partner ZA'(015).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 Defect #4033 by U029267 on 08-Nov-17
                CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
                  EXPORTING
                    msg_arbgb              = lc_otc_msg                                               "Message class
                    msg_nr                 = lc_msg_000                                               "Message number
                    msg_ty                 = if_cwd_constants=>c_message_warning
                    msg_v1                 = lv_msg
                  EXCEPTIONS
                    message_type_not_valid = 0
                    no_sy_message          = 0
                    OTHERS                 = 0.
                RETURN.
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              ENDIF. " IF gv_partner2 EQ lc_contact_other
*  END OF INSERT FOR D3_OTC_IDD_0167 BY NGARG

*BEGIN OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

* Deleteing old code for creation of XML and updation of  NAST
* Create Proxy
*            TRY.
*                CREATE OBJECT lref_po_proxy_out.
*              CATCH cx_ai_system_fault INTO lref_system_fault. "#EC *
*                lv_text = lref_system_fault->get_text( ).
*
*                IF NOT lv_text IS INITIAL.
** Update the Log in NAST
*                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*                    EXPORTING
*                      msg_arbgb              = lc_otc_msg "Message class
*                      msg_nr                 = lc_msg_000 "Message number
*                      msg_ty                 = if_cwd_constants=>c_message_error
*                      msg_v1                 = lv_text
*                    EXCEPTIONS
*                      message_type_not_valid = 0
*                      no_sy_message          = 0
*                      OTHERS                 = 0.
*                  RETURN.
*                ENDIF. " IF NOT lv_text IS INITIAL
*            ENDTRY.
** Send XML via Proxy
*            TRY.
**         Note: Currently we only support this message mediated with Excatly-Once-In-Order
*                lref_protocol ?= lref_po_proxy_out->get_protocol( if_wsprotocol=>async_messaging ).
*                CONCATENATE lc_ponof lv_vbeln INTO lv_context.
*                lref_protocol->set_serialization_context( lv_context ).
**calling method
*                CALL METHOD lref_po_proxy_out->execute_asynchronous
*                  EXPORTING
*                    output = lx_structure_out.
** ---> Begin of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
**get_WSprotocol
*                CALL METHOD lref_po_proxy_out->get_protocol
*                  EXPORTING
*                    protocol_name = 'IF_WSPROTOCOL_MESSAGE_ID' " todo use constant
*                  RECEIVING
*                    protocol      = lref_wsprotocol.           "Protocol
**Try a narrowing cast - try and catch
*                TRY.
*                    lref_wsprotocol_msg_id ?= lref_wsprotocol.
*                  CATCH cx_root INTO lx_cx_root. "#EC *
*                ENDTRY.
*                IF lx_cx_root IS NOT BOUND.
**       XML-message ID determination
*                  lv_xml_message_id = lref_wsprotocol_msg_id->get_message_id( ).
*                  IF lv_xml_message_id IS NOT INITIAL.
*                    lv_msg_v1 = lv_xml_message_id.
**Once we get the message id that has been generated
**when the sales order processing is done successfully we will update the processing log.
**This will help in keeping the track for particular sales order with message id it get generated.
*                    CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*                      EXPORTING
*                        msg_arbgb              = lc_otc_msg "Message class
*                        msg_nr                 = lc_msg_907 "message number Message id is &
*                        msg_ty                 = if_cwd_constants=>c_message_success
*                        msg_v1                 = lv_msg_v1
*                      EXCEPTIONS
*                        message_type_not_valid = 0
*                        no_sy_message          = 0
*                        OTHERS                 = 0.
*                  ENDIF. " IF lv_xml_message_id IS NOT INITIAL
*                ENDIF. " IF lx_cx_root IS NOT BOUND
** <--- End of Change for D2_OTC_IDD_0167,Defect #5319 by DMOIRAN
**To catch exceptions
*              CATCH cx_ai_system_fault INTO lref_system_fault. "#EC *
*                lv_text = lref_system_fault->get_text( ).
*
*                IF NOT lv_text IS INITIAL.
** Update the Log in NAST
*                  CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
*                    EXPORTING
*                      msg_arbgb              = lc_otc_msg "Message class
*                      msg_nr                 = lc_msg_000 "message number
*                      msg_ty                 = if_cwd_constants=>c_message_error
*                      msg_v1                 = lv_text
*                    EXCEPTIONS
*                      message_type_not_valid = 0
*                      no_sy_message          = 0
*                      OTHERS                 = 0.
*                  RETURN.
*
*
*                ENDIF. " IF NOT lv_text IS INITIAL
*
*            ENDTRY.
* END OF DELETE FOR D3_OTC_IDD_0167 BY NGARG

            ENDIF. " IF li_smtp_addr[] IS INITIAL
          ELSE. " ELSE -> IF sy-subrc EQ 0
*When Email id is not maintained.
*&--Information:
            fp_return_code = 4.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            CLEAR lv_msg.
            lv_msg = 'No Email Id has maintained for partner number'(009).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
              EXPORTING
                msg_arbgb              = lc_otc_msg                                           "Message class
                msg_nr                 = lc_msg_000                                           "Message number
                msg_ty                 = if_cwd_constants=>c_message_info
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*               msg_v1                 = 'No Email Id has maintained for partner number'(009) " Partner number
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                msg_v1                 = lv_msg
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
                msg_v2                 = lv_partner                                           "Partner number
              EXCEPTIONS
                message_type_not_valid = 0
                no_sy_message          = 0
                OTHERS                 = 0.
            RETURN.
          ENDIF. " IF sy-subrc EQ 0
        ELSE. " ELSE -> IF sy-subrc EQ 0

*When Partner function is not maintained.
*&--Information:
          fp_return_code = 4.
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
          CLEAR lv_msg.
          lv_msg = 'Partner for contact person details is not present'(012).
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
          CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
            EXPORTING
              msg_arbgb              = lc_otc_msg                                               "Message class
              msg_nr                 = lc_msg_000                                               "Message number
              msg_ty                 = if_cwd_constants=>c_message_info
* ---> Begin of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
*             msg_v1                 = 'Partner for contact person details is not present'(012) " Partner number
* <--- End of Delete for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
* ---> Begin of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
              msg_v1                 = lv_msg
* <--- End of Insert for D3 R2 changes for D3_OTC_IDD_0167 by U029267 on 09-Oct-17
            EXCEPTIONS
              message_type_not_valid = 0
              no_sy_message          = 0
              OTHERS                 = 0.
          RETURN.
        ENDIF. " IF sy-subrc EQ 0
*--Begin of changes manoj
      ENDIF. " IF <lfs_x_tnapr>-kschl = 'ZESK'  " *  Change for INC0485087-01
*--End of changes manoj
    ELSE. " ELSE -> IF <lfs_x_tnapr> IS ASSIGNED
      RETURN.
    ENDIF. " IF <lfs_x_tnapr> IS ASSIGNED
  ELSE. " ELSE -> IF <lfs_x_tnapr> IS ASSIGNED
    RETURN.
  ENDIF. " IF <lfs_x_tnapr> IS ASSIGNED
ENDFORM. "call_pr
