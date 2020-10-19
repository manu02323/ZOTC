*&---------------------------------------------------------------------*
*&  Include           ZOTCN0217B_RIBA_CITI_BANK_TOP
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCN0217B_RIBA_CITI_BANK_TOP                          *
* TITLE      :  Interface for RIBA Payments Italy Outbound CITI Bank   *
* DEVELOPER  :  Raghav Sureddi                                         *
* OBJECT TYPE:  Include                                                *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    R3. D3_OTC_IDD_0217_RIBA_ITALY_Outbound-CITI Bank      *
*----------------------------------------------------------------------*
* DESCRIPTION:  This Interface generate the payment medium files from  *
*               SAP system with RIBA (payment method R) Payment method *
*               based on the due date of customer open invoices        *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER      TRANSPORT    DESCRIPTION                       *
* =========== ========  ==========   ==================================*
*18-Apr-2018  U033876   E1DK936113   Initial Development               *
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_reguh,
             laufd     TYPE laufd,      "Date of transfer
             laufi     TYPE laufi,      " Additional Identification
             zbukr     TYPE dzbukr,     " Paying company code
             lifnr     TYPE lifnr,      " Account Number of Vendor or Creditor
             kunnr     TYPE kunnr,      " Customer Number
             vblnr     TYPE vblnr,      " Document Number of the Payment Document
             waers     TYPE waers,      " Currency Key
             name1     TYPE name1_gp,   " Name 1
             name2     TYPE name2_gp,   " Name 2
             pstlz     TYPE pstlz,      " Postal Code
             ort01     TYPE ort01_gp,   " City
             stras     TYPE stras_gp,   " House number and street
             land1     TYPE land1,      " Country Key
             zaldt     TYPE dzaldt_zhl, " Posting date of the payment document
             ubknt     TYPE ubknt,      " Our account number at the bank
             ubnkl     TYPE ubnkl,      " Bank number of our bank
             valut     TYPE valut,      " Value Date
             rwbtr     TYPE rwbtr,      " Amount Paid in the Payment Currency
       END OF ty_reguh.

TYPES: BEGIN OF ty_regup,
             laufd     TYPE laufd,    "Date of transfer
             laufi     TYPE laufi,    " Additional Identification
             vblnr     TYPE vblnr,    " Document Number of the Payment Document
             bukrs     TYPE bukrs,    " Company Code
             belnr     TYPE belnr_d,  " Accounting Document Number
             rebzg     TYPE rebzg,    " Number of the Invoice the Transaction Belongs to
        END OF ty_regup,

        BEGIN OF ty_knb1,
          kunnr TYPE kunnr,           " Customer Number
          bukrs TYPE bukrs,           " Company Code
          kverm TYPE kverm,           " Memo
        END   OF ty_knb1,
        BEGIN OF ty_kna1,
          kunnr TYPE kunnr,           " Customer Number
          stcd1 TYPE stcd1,           " Tax Number 1
        END   OF ty_kna1,

        BEGIN OF ty_t001,
          bukrs TYPE bukrs,           " Company Code
          butxt TYPE butxt,           " Name of Company Code or Company
          adrnr TYPE adrnr,           " Address
        END   OF ty_t001,

        BEGIN OF ty_adrc,
          addrnumber TYPE ad_addrnum, " Address
          name1      TYPE ad_name1,   " Name 1
          street     TYPE ad_street,  " Street
          house_num1 TYPE ad_hsnm1,   " House Number
          post_code1 TYPE ad_pstcd1,  " City postal code
          city1      TYPE ad_city1,   " City
          region     TYPE regio,      " Region (State, Province, County)
          sort2      TYPE ad_sort2,   " Search Term 2
        END   OF ty_adrc,
*Header Record  - Will  be populated once in the file
       BEGIN OF ty_header,
         filler_s       TYPE char1,  " Filler of type CHAR1
         rec_type       TYPE char2,
         sp_sia_code    TYPE char5,  " Si_code of type CHAR5
         ob_abi_code    TYPE char5,  " Abi_code of type CHAR15
         erdat          TYPE char6,  " Date on Which Record Was Created
         file_name      TYPE char20, " Name of type CHAR20
         filler_m       TYPE char73, " M of type CHAR73
         rid_coll_typ   TYPE char1,  " Coll_typ of type CHAR1
         curr_code      TYPE char1,  " Code of type CHAR1
         filler_e       TYPE char6,  " E of type CHAR6
       END   OF ty_header,
*Record 14 - Disposition and Ordering Customer information  - will repeat for each payment document
       BEGIN OF ty_14_disp,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         filler_m1      TYPE char12, " M of type CHAR12
         matu_date      TYPE char6,  " Current Date of Application Server
         reason         TYPE char5,  " Reason of type CHAR5
         trans_amt      TYPE numc13, " char13 Amount Paid in the Payment Currency
         sign           TYPE char1,  " Sign of type CHAR1
         ob_abi_code    TYPE numc5,  " Bank number of our bank
         ob_cab_code    TYPE numc5,  " Bank number of our bank
         cr_accnt_no(12) TYPE n,     "char12, " Our account number at the bank
         db_abi_code    TYPE numc5,  " Bank number of our bank
         db_cab_code    TYPE numc5,  " Memo
         filler_m2      TYPE char12, " M of type CHAR12
         op_sia_code    TYPE char5,  " Sia_code of type CHAR5
         code_type      TYPE numc1,
         deb_id(16)     TYPE n,      " Id of type CHAR16
         filler_e       TYPE char6,  " E of type CHAR6
         curr_code      TYPE char1,  " Code of type CHAR1
       END   OF ty_14_disp,
*Record 20 - Orderer Description  -  will repeat for each payment document
       BEGIN OF ty_20_odesc,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         ord_cust_desc1 TYPE char24, " Cust_desc1 of type CHAR24
         ord_cust_desc2 TYPE char24, " Cust_desc2 of type CHAR24
         ord_cust_desc3 TYPE char24, " Cust_desc3 of type CHAR24
         ord_cust_desc4 TYPE char24, " Cust_desc4 of type CHAR24
         filler_e       TYPE char14, " E of type CHAR14
       END   OF ty_20_odesc,
*Record 30 - Debtor Information
       BEGIN OF ty_30_db_info,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         deb_name1      TYPE char30, " Name1 of type CHAR30
         deb_name2      TYPE char30, " Name2 of type CHAR30
         deb_fisc_code  TYPE char16, " Fisc_code of type CHAR16
         filler_e       TYPE char34, " E of type CHAR34
       END   OF ty_30_db_info,
*Record 40 - Debtor Address -  will repeat for each payment document
       BEGIN OF ty_40_db_add,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         deb_str_add    TYPE char30, " Str_add of type CHAR30
         deb_pos_code   TYPE numc5,  " 5 Character Numeric NUMC
         deb_city       TYPE char25, " City of type CHAR25
         deb_bank       TYPE char50, " Bank of type CHAR50
       END   OF ty_40_db_add,
*Record 50 - Notes for Debtor -  will repeat for each payment document
       BEGIN OF ty_50_db_notes,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         pay_det1       TYPE char40, " Det1 of type CHAR40
         pay_det2       TYPE char40, " Det2 of type CHAR40
         filler_m       TYPE char10, " M of type CHAR10
         cre_fisc_code  TYPE char16, " Fisc_code of type CHAR16
         filler_e       TYPE char4,  " E of type CHAR4
       END   OF ty_50_db_notes,

*       Record 51 - Province Internal Revenue Office Information -  will repeat for each payment document
       BEGIN OF ty_51_pir_info,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         trans_ref_no   TYPE numc10, " Numeric Character Field, Length 10
         ord_par_name   TYPE char20, " Par_name of type CHAR20
         pir_office     TYPE char15, " Office of type CHAR15
         auth_no        TYPE char10, " No of type CHAR10
         auth_date      TYPE char6,  " Current Date of Application Server
         filler_e(49)   TYPE c,      " E of type CHAR49
       END   OF ty_51_pir_info,

*       Record 70 - Control Key Detail  -  will repeat for each payment document
       BEGIN OF ty_70_ck_detail,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE numc2,
         disp_no        TYPE numc7,  " StADUEV: Seven-Digit Value
         res_of_cred    TYPE char3,  " Of_cred of type CHAR3
         cc_cred_bank   TYPE char3,  " Cred_bank of type CHAR3
         cred_bank_name TYPE char35, " Bank_name of type CHAR35
         cred_acc_no    TYPE char15, " Acc_no of type CHAR15
         cred_acc_name  TYPE char15, " Acc_name of type CHAR15
         f_riba_flag    TYPE char1,  " Riba_flag of type CHAR1
         filler_m       TYPE char18, " M of type CHAR18
         deb_docu_type  TYPE char1,
         pay_notif      TYPE char1,  " Notif of type CHAR1
         print_notif    TYPE char1,  " Notif of type CHAR1
         filler_e       TYPE char17, " E of type CHAR17
       END   OF ty_70_ck_detail,

*Trailer Record
       BEGIN OF ty_trailer,
         filler_s       TYPE char1,  " S of type CHAR1
         rec_type       TYPE char2,
         sp_sia_code    TYPE char5,  " Si_code of type CHAR5
         ob_abi_code    TYPE char5,  "numc5,   " 5 Character Numeric NUMC
         erdat          TYPE char6,  " Date on Which Record Was Created
         file_name      TYPE char20, " Name of type CHAR20
         filler_m1      TYPE char6,  " M1 of type CHAR6
         tot_no_disp    TYPE numc7,  " No_disp of type CHAR7
         tot_neg_amts   TYPE numc15, " Neg_amts of type CHAR15
         tot_pos_amts   TYPE numc15, " Pos_amts of type CHAR15
         no_of_recds    TYPE numc7,  " Of_recds of type CHAR7
         filler_m2      TYPE char23, " M2 of type CHAR23
         rid_coll_typ   TYPE char1,  " Coll_typ of type CHAR1
         curr_code      TYPE char1,  " Code of type CHAR1
         filler_e       TYPE char6,  " E of type CHAR6
       END   OF ty_trailer,
* Final table
       BEGIN OF ty_final,
*         str TYPE string,
         str TYPE char120,    " Str of type CHAR120
       END   OF ty_final,

       BEGIN OF ty_log,
         msgtyp TYPE char01,  " Message Type
         msgtxt TYPE char255, " Message Text
       END OF ty_log,

       BEGIN OF ty_data,
         data  TYPE char120,  "string,   " Data
       END OF ty_data.


TYPES: ty_t_reguh TYPE STANDARD TABLE OF ty_reguh,
       ty_t_regup TYPE STANDARD TABLE OF ty_regup,
       ty_t_kna1  TYPE STANDARD TABLE OF ty_kna1,
       ty_t_knb1  TYPE STANDARD TABLE OF ty_knb1,
       ty_t_t001  TYPE STANDARD TABLE OF ty_t001,
       ty_t_adrc  TYPE STANDARD TABLE OF ty_adrc,
       ty_t_final TYPE STANDARD TABLE OF ty_final,
       ty_t_data  TYPE STANDARD TABLE OF ty_data,
       ty_t_log   TYPE STANDARD TABLE OF ty_log.

DATA: i_reguh        TYPE ty_t_reguh,
      i_regup        TYPE ty_t_regup,
      i_kna1         TYPE ty_t_kna1,
      i_knb1         TYPE ty_t_knb1,
      i_t001         TYPE ty_t_t001,
      i_adrc         TYPE ty_t_adrc,
      wa_header      TYPE ty_header,
      wa_14_disp     TYPE ty_14_disp,
      wa_20_odesc    TYPE ty_20_odesc,
      wa_30_db_info  TYPE ty_30_db_info,
      wa_40_db_add   TYPE ty_40_db_add,
      wa_50_db_notes TYPE ty_50_db_notes,
      wa_51_pir_info TYPE ty_51_pir_info,
      wa_70_ck_detail TYPE ty_70_ck_detail,
      wa_trailer     TYPE ty_trailer,
      wa_final       TYPE ty_final,
      i_final        TYPE ty_t_final,
      i_data         TYPE ty_t_data,
      i_log          TYPE ty_t_log,
      gv_file        TYPE char50,    " Concatenated File name
      gv_pfile       TYPE localfile. " Local file for upload/download




CONSTANTS: c_mi2       TYPE char03 VALUE 'MI2',           " Mi3 of type CHAR03
           c_mi3       TYPE char03 VALUE 'MI3',           " Mi3 of type CHAR03
           c_mi4       TYPE char03 VALUE 'MI4',           " Mi3 of type CHAR03
           c_mi6       TYPE char03 VALUE 'MI6',           " Mi6 of type CHAR03
           c_mi9       TYPE char03 VALUE 'MI9',           " Mi9 of type CHAR03
           c_file_f    TYPE char07 VALUE 'P_AHDR',        " File_f of type CHAR07
           c_file_b    TYPE char07 VALUE 'P_AHDR1',       " File_b of type CHAR07
           c_extn      TYPE char3  VALUE 'TXT',           " Extn of type CHAR3
           c_asc       TYPE char10 VALUE 'ASC',           " Asc of type CHAR10
           c_msgtyp_s  TYPE char01 VALUE 'S',             " Success
           c_msgtyp_e  TYPE char01 VALUE 'E',             " Error
           c_msgtyp_i  TYPE char01 VALUE 'I',             " Information
           c_filename  TYPE char13 VALUE 'OTC_IDD_0217_', "File Name Start
           c_uscore    TYPE char01 VALUE '_',             " Uscore of type CHAR01
           c_fileext   TYPE char04 VALUE '.TXT'.          "File Extension
