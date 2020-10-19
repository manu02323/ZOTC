* PROGRAM    :  ZOTCN0214O_BOM_POSTINGBLOCK                                                          *
* TITLE      :  OTC SAP enhancement on Invoice to Block Accounting Release for Component Conditions  *
* DEVELOPER  :  Sudhanshu Ranjan                                                                     *
* OBJECT TYPE:  Enhancement                                                                          *
* SAP RELEASE:  SAP ECC 6.0                                                                          *
*----------------------------------------------------------------------------------------------------*
* WRICEF ID  : D3_OTC_EDD_0214
*----------------------------------------------------------------------------------------------------*
* DESCRIPTION: Enhancement for D3_OTC_EDD_0214
*----------------------------------------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                                              *
*====================================================================================================*
* DATE          USER      TRANSPORT      DESCRIPTION                                                 *
* ===========  ========   =========  ================================================================*
* 08-03-2017   U100018    E1DK926641 Defect# 2190: Apply Posting Block on Invoice for any of the BOM *
*                                    Component Conditions:                                           *
*                                    Case 1)If ZHPR is equal to zero                                 *
*                                    Case 2)If ZM00 is greater than zero                             *
*                                    Case 3)Sum of all components for condition ZBCR is not equal    *
*                                           to condition ZHPR                                        *
*                                    Case 4)ZPPM condition value for the BOM header is not equal     *
*                                           to ZPPM for BOM components.                              *
* 07-06-2018   U100018    E1DK936170 Defect# 5535_FUT Issue: Pricing Error while Invoice document of *
*                                                            Sales Order with multiple BOMs is saved *
*&---------------------------------------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZOTCN0214O_BOM_POSTINGBLOCK
*&---------------------------------------------------------------------*

*Declaration Of Field-Symbols
FIELD-SYMBOLS: <lfs_vbrp_data>   TYPE vbrpvb,          " Field-Symbol for XVBRP Structure
               <lfs_vbrp_data1>  TYPE vbrpvb,          " Field-Symbol for XVBRP Structure
               <lfs_komv2>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv3>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv4>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv5>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_komv6>       TYPE komv,            " Field-Symbol for Condition Record
               <lfs_lines>       TYPE tline,           " Field-Symbol for Text Line
               <lfs_enh_stat>    TYPE zdev_enh_status. " Enhancement Status

*Declaration Of Constants
CONSTANTS: lc_criteria_zppm  TYPE z_criteria    VALUE 'KSCHL_ZPPM',              " Condition type
           lc_criteria_zhpr  TYPE z_criteria    VALUE 'KSCHL_ZHPR',              " Condition type
           lc_criteria_zm00  TYPE z_criteria    VALUE 'KSCHL_ZM00',              " Condition type
           lc_criteria_zbcr  TYPE z_criteria    VALUE 'KSCHL_ZBCR',              " Condition type
           lc_criteria_rfbsk TYPE z_criteria    VALUE 'RFBSK',                   " posting block
           lc_criteria_ucomm TYPE z_criteria    VALUE 'UCOMM',                   " System command
           lc_criteria_trtyp TYPE z_criteria    VALUE 'TRTYP',                   " Transaction
           lc_null           TYPE z_criteria    VALUE 'NULL',                    " Enh. Criteria
           lc_sign_i         TYPE sign          VALUE 'I',                       " Sign
           lc_option_eq      TYPE option        VALUE 'EQ',                      " Option
           lc_id             TYPE tdid          VALUE 'ST',                      " Text ID
           lc_langu          TYPE sylangu       VALUE 'EN',                      " System Language
           lc_obj            TYPE tdobject      VALUE 'TEXT',                    " Texts: application object
           lc_text1          TYPE tdobname      VALUE 'ZOTC_POSTING_BLOCK_ZHPR', " Object Key for Text
           lc_text2          TYPE tdobname      VALUE 'ZOTC_POSTING_BLOCK_ZM00', " Object Key for Text
           lc_text3          TYPE tdobname      VALUE 'ZOTC_POSTING_BLOCK_ZPPM', " Object Key for Text
           lc_text4          TYPE tdobname      VALUE 'ZOTC_POSTING_BLOCK_ZBCR', " Object Key for Text
           lc_text5          TYPE tdobname      VALUE 'ZOTC_POSTING',            " Object Key for Text
           lc_edd_0214       TYPE z_enhancement VALUE 'D2_OTC_EDD_0214'.         " Enhancement

*Local Internal table
DATA: li_edd_0214_status TYPE STANDARD TABLE OF zdev_enh_status, " Enhancement Status
      li_lines           TYPE tlinet,                            " Lines read from text element
      li_vbrp_temp       TYPE STANDARD TABLE OF vbrpvb.          " Table of XVBRP Type

*Declaration Of Variables
DATA: lv_kschl_zhpr  TYPE kschl,                   " Condition Type ZHPR
      lv_kschl_zm00  TYPE kschl,                   " Condition Type ZM00
      lv_kschl_zbcr  TYPE kschl,                   " Condition Type ZBCR
      lv_kschl_zppm  TYPE kschl,                   " Condition Type ZPPM
      lv_text        TYPE string,                  " Text
      lv_text1       TYPE string,                  " Text
      lv_rfbsk       TYPE rfbsk,                   " Posting Block
      lv_zbcr_comp   TYPE kwert,                   " ZBCR value of Items
      lv_zppm_comp   TYPE kwert,                   " ZPPM value of Items
      lv_zhpr_comp   TYPE kwert,                   " ZHPR value of Header
      lv_zppm_hdr    TYPE kwert,                   " ZPPM value of Header
      lr_trtyp_range TYPE RANGE OF trtyp,          " Transaction type value
      lwa_r_trtyp    LIKE LINE OF  lr_trtyp_range, " Transaction type value
      lr_ucomm_range TYPE RANGE OF syucomm,        " system command value
      lwa_r_ucomm    LIKE LINE OF  lr_ucomm_range, " system command value
      lv_msg_zhpr    TYPE string,                  " Text Element details
      lv_msg_zhpr1   TYPE string,                  " Text Element details
      lv_msg_zm00    TYPE string,                  " Text Element details
      lv_msg_zm001   TYPE string,                  " Text Element details
      lv_msg_zppm    TYPE string,                  " Text Element details
      lv_msg_zppm1   TYPE string,                  " Text Element details
      lv_msg_zbcr    TYPE string,                  " Text Element details
      lv_msg_zbcr1   TYPE string,                  " Text Element details
      lv_msg_block   TYPE string.                  " Text Element details
*--> Begin of delete for D3_OTC_EDD_0214_Defect# 5535_FUT Issue by U100018 on 07-Jun-2018
*Clearing Variables
*CLEAR: lv_kschl_zhpr,
*       lv_kschl_zm00,
*       lv_kschl_zbcr,
*       lv_kschl_zppm,
*       lv_rfbsk,

*       lv_zbcr_comp,
*       lv_zppm_comp,
*       lv_zhpr_comp,

*       lv_zppm_hdr,
*       lwa_r_trtyp,
*       lwa_r_ucomm,
*       lv_msg_zhpr,
*       lv_msg_zm00,
*       lv_msg_zppm,
*       lv_msg_zbcr,
*       lv_msg_block.
*
*FREE: li_edd_0214_status,
*      lr_ucomm_range,
*      lr_trtyp_range,
*      li_vbrp_temp.
*<-- End of delete for D3_OTC_EDD_0214_Defect# 5535_FUT Issue by U100018 on 07-Jun-2018

CALL FUNCTION 'ZDEV_ENHANCEMENT_STATUS_CHECK'
  EXPORTING
    iv_enhancement_no = lc_edd_0214
  TABLES
    tt_enh_status     = li_edd_0214_status. "Enhancement status table

*Non active entries are removed.
DELETE li_edd_0214_status WHERE active EQ abap_false.

IF li_edd_0214_status IS NOT INITIAL.
  SORT li_edd_0214_status BY criteria.
* Check if enhancement is active on EMI
  READ TABLE  li_edd_0214_status
              WITH KEY criteria = lc_null
                       BINARY SEARCH
                       TRANSPORTING NO FIELDS.
  IF sy-subrc = 0.
    LOOP AT li_edd_0214_status ASSIGNING <lfs_enh_stat>.
      IF <lfs_enh_stat>-criteria = lc_criteria_ucomm.
*Range table for sy-ucomm
        lwa_r_ucomm-sign   = lc_sign_i.
        lwa_r_ucomm-option = lc_option_eq.
        lwa_r_ucomm-low    = <lfs_enh_stat>-sel_low.
        APPEND lwa_r_ucomm TO lr_ucomm_range.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_ucomm

      IF <lfs_enh_stat>-criteria = lc_criteria_trtyp.
*Range table for sy-ucomm
        lwa_r_trtyp-sign   = lc_sign_i.
        lwa_r_trtyp-option = lc_option_eq.
        lwa_r_trtyp-low    = <lfs_enh_stat>-sel_low.
        APPEND lwa_r_trtyp TO lr_trtyp_range.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_trtyp
      CLEAR: lwa_r_ucomm,
             lwa_r_trtyp.
*Populating the values maintained in the EMI in a variables
      IF <lfs_enh_stat>-criteria = lc_criteria_zppm.
        lv_kschl_zppm = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zppm
      IF <lfs_enh_stat>-criteria = lc_criteria_zhpr.
        lv_kschl_zhpr = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zhpr
      IF <lfs_enh_stat>-criteria = lc_criteria_zbcr.
        lv_kschl_zbcr = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zbcr
      IF <lfs_enh_stat>-criteria = lc_criteria_zm00.
        lv_kschl_zm00 = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_zm00
      IF <lfs_enh_stat>-criteria = lc_criteria_rfbsk.
        lv_rfbsk = <lfs_enh_stat>-sel_low.
      ENDIF. " IF <lfs_enh_stat>-criteria = lc_criteria_rfbsk
    ENDLOOP. " LOOP AT li_edd_0214_status ASSIGNING <lfs_enh_stat>

*Trigger the enhancement if the transaction type is change or add
    IF t180-trtyp IN lr_trtyp_range.

*  Will get triggred when we press on SAVe button for billing doc
*  and when user check the Release to accounting flag for a billing
*  doc whose accounting is blocked
      IF sy-ucomm IN lr_ucomm_range OR sy-batch = abap_true.
*  Trigger the code in case the posting block is initial
        IF vbrk-rfbsk <> lv_rfbsk AND vbrk-sfakn IS INITIAL.
          IF xkomv[] IS NOT INITIAL.

            CALL FUNCTION 'READ_TEXT'
              EXPORTING
                id                      = lc_id
                language                = lc_langu
                name                    = lc_text5
                object                  = lc_obj
              TABLES
                lines                   = li_lines
              EXCEPTIONS
                id                      = 1
                language                = 2
                name                    = 3
                not_found               = 4
                object                  = 5
                reference_check         = 6
                wrong_access_to_archive = 7
                OTHERS                  = 8.

            IF sy-subrc IS INITIAL.
              READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
              IF sy-subrc IS INITIAL.
                lv_msg_block = <lfs_lines>-tdline.
              ENDIF. " IF sy-subrc IS INITIAL
            ENDIF. " IF sy-subrc IS INITIAL

*Assigning XVBRP to local internal table and Deleting all entries with UEPOS not equal to ZERO
            li_vbrp_temp[] = xvbrp[].
            DELETE li_vbrp_temp WHERE uepos NE 0.
            LOOP AT li_vbrp_temp ASSIGNING <lfs_vbrp_data>.
*Case 4 : Check If ZPPM condition value for the BOM header is not equal to ZPPM for BOM components
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
              READ TABLE xkomv ASSIGNING <lfs_komv2>
              WITH KEY kposn = <lfs_vbrp_data>-posnr
                       kschl = lv_kschl_zppm.
              IF sy-subrc = 0.
                lv_zppm_hdr = <lfs_komv2>-kwert.
              ENDIF. " IF sy-subrc = 0
              READ TABLE xvbrp[] WITH KEY uepos = <lfs_vbrp_data>-posnr
              TRANSPORTING NO FIELDS.
              IF sy-subrc NE 0.
                CONTINUE.
              ENDIF. " IF sy-subrc NE 0
***************************************************************************************************
              LOOP AT xvbrp ASSIGNING <lfs_vbrp_data1> WHERE uepos = <lfs_vbrp_data>-posnr.
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
                READ TABLE xkomv ASSIGNING <lfs_komv3>
                WITH KEY kposn = <lfs_vbrp_data1>-posnr
                         kschl = lv_kschl_zhpr.
                IF sy-subrc = 0.
* Case 1: Check If ZHPR equals 0 for BOM components
                  IF <lfs_komv3>-kwert = 0 .
                    tvfk-rfbfk = abap_true.
                    vbrk-rfbsk  = lv_rfbsk.
                    xvbrk-rfbsk = lv_rfbsk.
                    gv_posting_flag = abap_true.

                    CALL FUNCTION 'READ_TEXT'
                      EXPORTING
                        id                      = lc_id
                        language                = lc_langu
                        name                    = lc_text1
                        object                  = lc_obj
                      TABLES
                        lines                   = li_lines
                      EXCEPTIONS
                        id                      = 1
                        language                = 2
                        name                    = 3
                        not_found               = 4
                        object                  = 5
                        reference_check         = 6
                        wrong_access_to_archive = 7
                        OTHERS                  = 8.

                    IF sy-subrc IS INITIAL.
                      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
                      IF sy-subrc IS INITIAL.
                        lv_msg_zhpr = <lfs_lines>-tdline.
                      ENDIF. " IF sy-subrc IS INITIAL
                      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 2.
                      IF sy-subrc IS INITIAL.
                        lv_msg_zhpr1 = <lfs_lines>-tdline.
                      ENDIF. " IF sy-subrc IS INITIAL
                    ENDIF. " IF sy-subrc IS INITIAL
                    CONCATENATE lv_msg_zhpr1 <lfs_vbrp_data1>-posnr INTO lv_msg_zhpr1
                    SEPARATED BY space.
                    IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true.
                      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                        EXPORTING
                          titel     = lv_msg_block
                          textline1 = lv_msg_zhpr
                          textline2 = lv_msg_zhpr1.
                    ENDIF. " IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true
                    EXIT.
                  ELSE. " ELSE -> IF <lfs_komv3>-kwert = 0
* Case 3: Check If Sum of all components for condition ZBCR is not equal to condition ZHPR
                    lv_zhpr_comp = <lfs_komv3>-kwert.
                  ENDIF. " IF <lfs_komv3>-kwert = 0
                ENDIF. " IF sy-subrc = 0
*****************************************************************************************************
* Case 2 : Check If ZM00 is greater than zero for BOM components
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
                READ TABLE xkomv ASSIGNING <lfs_komv4>
                WITH KEY kposn = <lfs_vbrp_data1>-posnr
                         kschl = lv_kschl_zm00.
                IF sy-subrc = 0.
                  IF <lfs_komv4>-kwert > 0.
                    tvfk-rfbfk = abap_true.
                    vbrk-rfbsk  = lv_rfbsk.
                    xvbrk-rfbsk = lv_rfbsk.
                    gv_posting_flag = abap_true.

                    CALL FUNCTION 'READ_TEXT'
                      EXPORTING
                        id                      = lc_id
                        language                = lc_langu
                        name                    = lc_text2
                        object                  = lc_obj
                      TABLES
                        lines                   = li_lines
                      EXCEPTIONS
                        id                      = 1
                        language                = 2
                        name                    = 3
                        not_found               = 4
                        object                  = 5
                        reference_check         = 6
                        wrong_access_to_archive = 7
                        OTHERS                  = 8.

                    IF sy-subrc IS INITIAL.
                      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
                      IF sy-subrc IS INITIAL.
                        lv_msg_zm00 = <lfs_lines>-tdline.
                      ENDIF. " IF sy-subrc IS INITIAL
                      READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 2.
                      IF sy-subrc IS INITIAL.
                        lv_msg_zm001 = <lfs_lines>-tdline.
                      ENDIF. " IF sy-subrc IS INITIAL
                    ENDIF. " IF sy-subrc IS INITIAL
                    CONCATENATE lv_msg_zm001 <lfs_vbrp_data1>-posnr INTO lv_msg_zm001
                    SEPARATED BY space.
                    IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true.
                      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                        EXPORTING
                          titel     = lv_msg_block
                          textline1 = lv_msg_zm00
                          textline2 = lv_msg_zm001.
                    ENDIF. " IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true
                    EXIT.
                  ENDIF. " IF <lfs_komv4>-kwert > 0
                ENDIF. " IF sy-subrc = 0
****************************************************************************************************
*Contn. of Case 3: Check If Sum of all components for condition ZBCR is not equal to condition ZHPR
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
                READ TABLE xkomv ASSIGNING <lfs_komv5>
                WITH KEY kposn = <lfs_vbrp_data1>-posnr
                          kschl = lv_kschl_zbcr.
                IF sy-subrc = 0.
                  lv_zbcr_comp = lv_zbcr_comp + <lfs_komv5>-kwert.
                ENDIF. " IF sy-subrc = 0
*****************************************************************************************************
*Contn. of Case 4 : Check  If ZPPM condition value for the BOM header is not equal to ZPPM for BOM components
*Since we are using Standard structure, so it will get hampered if Binary Search is used
*Reading XKOMV without Binary Search
                READ TABLE xkomv ASSIGNING <lfs_komv6>
                WITH KEY kposn = <lfs_vbrp_data1>-posnr
                         kschl = lv_kschl_zppm.
                IF sy-subrc = 0.
                  lv_zppm_comp = lv_zppm_comp + <lfs_komv6>-kwert.
                ENDIF. " IF sy-subrc = 0
              ENDLOOP. " LOOP AT xvbrp ASSIGNING <lfs_vbrp_data1> WHERE uepos = <lfs_vbrp_data>-posnr

              IF tvfk-rfbfk IS INITIAL OR vbrk-rfbsk IS INITIAL OR xvbrk-rfbsk IS INITIAL.
                IF lv_zppm_hdr NE lv_zppm_comp.
                  tvfk-rfbfk = abap_true.
                  vbrk-rfbsk  = lv_rfbsk.
                  xvbrk-rfbsk = lv_rfbsk.
                  gv_posting_flag = abap_true.

                  CALL FUNCTION 'READ_TEXT'
                    EXPORTING
                      id                      = lc_id
                      language                = lc_langu
                      name                    = lc_text3
                      object                  = lc_obj
                    TABLES
                      lines                   = li_lines
                    EXCEPTIONS
                      id                      = 1
                      language                = 2
                      name                    = 3
                      not_found               = 4
                      object                  = 5
                      reference_check         = 6
                      wrong_access_to_archive = 7
                      OTHERS                  = 8.

                  IF sy-subrc IS INITIAL.
                    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
                    IF sy-subrc IS INITIAL.
                      lv_msg_zppm = <lfs_lines>-tdline.
                    ENDIF. " IF sy-subrc IS INITIAL
                    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 2.
                    IF sy-subrc IS INITIAL.
                      lv_msg_zppm1 = <lfs_lines>-tdline.
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF sy-subrc IS INITIAL
                  IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true.
                    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                      EXPORTING
                        titel     = lv_msg_block
                        textline1 = lv_msg_zppm
                        textline2 = lv_msg_zppm1.
                  ENDIF. " IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true
                  EXIT.
                ENDIF. " IF lv_zppm_hdr NE lv_zppm_comp
*****************************************************************************************************
* Contn. of Case 3: Check If Sum of all components for condition ZBCR is not equal to condition ZHPR
                IF lv_zhpr_comp NE lv_zbcr_comp.
                  tvfk-rfbfk = abap_true.
                  vbrk-rfbsk  = lv_rfbsk.
                  xvbrk-rfbsk = lv_rfbsk.
                  gv_posting_flag = abap_true.
                  CALL FUNCTION 'READ_TEXT'
                    EXPORTING
                      id                      = lc_id
                      language                = lc_langu
                      name                    = lc_text4
                      object                  = lc_obj
                    TABLES
                      lines                   = li_lines
                    EXCEPTIONS
                      id                      = 1
                      language                = 2
                      name                    = 3
                      not_found               = 4
                      object                  = 5
                      reference_check         = 6
                      wrong_access_to_archive = 7
                      OTHERS                  = 8.
                  IF sy-subrc IS INITIAL.
                    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 1.
                    IF sy-subrc IS INITIAL.
                      lv_msg_zbcr = <lfs_lines>-tdline.
                    ENDIF. " IF sy-subrc IS INITIAL
                    READ TABLE li_lines ASSIGNING <lfs_lines> INDEX 2.
                    IF sy-subrc IS INITIAL.
                      lv_msg_zbcr1 = <lfs_lines>-tdline.
                    ENDIF. " IF sy-subrc IS INITIAL
                  ENDIF. " IF sy-subrc IS INITIAL
                  IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true.
                    CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
                      EXPORTING
                        titel     = lv_msg_block
                        textline1 = lv_msg_zbcr
                        textline2 = lv_msg_zbcr1.
                  ENDIF. " IF sy-tcode NE 'VF04' AND sy-tcode NE 'VF06' AND sy-batch NE abap_true
                  EXIT.
                ENDIF. " IF lv_zhpr_comp NE lv_zbcr_comp
              ENDIF. " IF tvfk-rfbfk IS INITIAL OR vbrk-rfbsk IS INITIAL OR xvbrk-rfbsk IS INITIAL
*--> Begin of insert for D3_OTC_EDD_0214_Defect# 5535_FUT Issue by U100018 on 07-Jun-2018
              CLEAR: lv_zbcr_comp,
                     lv_zhpr_comp,
                     lv_zppm_comp.
*<-- End of insert for D3_OTC_EDD_0214_Defect# 5535_FUT Issue by U100018 on 07-Jun-2018
            ENDLOOP. " LOOP AT li_vbrp_temp ASSIGNING <lfs_vbrp_data>

*Unassigning Of All Field-Symbols
            IF <lfs_vbrp_data> IS ASSIGNED.
              UNASSIGN <lfs_komv2>.
            ENDIF. " IF <lfs_vbrp_data> IS ASSIGNED

            IF <lfs_vbrp_data1> IS ASSIGNED.
              UNASSIGN <lfs_komv2>.
            ENDIF. " IF <lfs_vbrp_data1> IS ASSIGNED

            IF <lfs_komv2> IS ASSIGNED.
              UNASSIGN <lfs_komv2>.
            ENDIF. " IF <lfs_komv2> IS ASSIGNED

            IF <lfs_komv3> IS ASSIGNED.
              UNASSIGN <lfs_komv3>.
            ENDIF. " IF <lfs_komv3> IS ASSIGNED

            IF <lfs_komv4> IS ASSIGNED.
              UNASSIGN <lfs_komv4>.
            ENDIF. " IF <lfs_komv4> IS ASSIGNED

            IF <lfs_komv5> IS ASSIGNED.
              UNASSIGN <lfs_komv5>.
            ENDIF. " IF <lfs_komv5> IS ASSIGNED

            IF <lfs_komv6> IS ASSIGNED.
              UNASSIGN <lfs_komv6>.
            ENDIF. " IF <lfs_komv6> IS ASSIGNED

            IF <lfs_enh_stat> IS ASSIGNED.
              UNASSIGN <lfs_enh_stat>.
            ENDIF. " IF <lfs_enh_stat> IS ASSIGNED

          ENDIF. " IF xkomv[] IS NOT INITIAL
        ENDIF. " IF vbrk-rfbsk <> lv_rfbsk AND vbrk-sfakn IS INITIAL
      ENDIF. " IF sy-ucomm IN lr_ucomm_range OR sy-batch = abap_true
    ENDIF. " IF t180-trtyp IN lr_trtyp_range
  ENDIF. " IF sy-subrc = 0
ENDIF. " IF li_edd_0214_status IS NOT INITIAL
