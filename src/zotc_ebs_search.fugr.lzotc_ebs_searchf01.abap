***----------------------------------------------------------------------*
*****INCLUDE LZOTC_EBS_SEARCHF01.
***----------------------------------------------------------------------*
***MODIFICATION HISTORY:
***=====================================================================*
***Date           User        Transport                     Description
***=========== ============== ============== ===========================*
***09-Aug-2019   U105235      E2DK924281    SCTASK0791864 - PCR 703     *
***                                         additional validations      *
***---------------------------------------------------------------------*
FORM f_track_change.

** Log Entries
  FIELD-SYMBOLS:
    <lfs_tab_name> TYPE any, "Table name
    <lfs_field>    TYPE any. "Field name
  DATA : lv_hbkid TYPE hbkid,
         lv_hktid TYPE hktid,
         lv_bukrs TYPE bukrs,
         lv_text  TYPE ztext,
         lv_flag  TYPE char1,
         lv_flag1 TYPE char1,
         lv_flag2 TYPE char1,
         lv_text1 TYPE ztext,
         lv_bankn TYPE bankn.
*Begin of changes - SCTASK0791864 - U105235 - 08/09/2019
  CONSTANTS : lc_text TYPE char4 VALUE 'TEXT',
              lc_save TYPE char4 VALUE 'SAVE',
              lc_yes  TYPE char3 VALUE 'YES',
              lc_kopf TYPE char4 VALUE 'KOPF',
              lc_i    TYPE char1 VALUE 'I',
              lc_d    TYPE char1 VALUE 'D',
              lc_1    TYPE char1 VALUE '1'.
  DATA : length     TYPE i,
         lv_zprio   TYPE zprio,
         lv_kunnr   TYPE kunnr,
         lv_bukrs1  TYPE bukrs,
         lv_hbkid1  TYPE hbkid,
         lv_hktid1  TYPE hktid,
         lv_zprio1  TYPE zprio,
         lv_kunnr1  TYPE kunnr,
         lwa_search TYPE zotc_ebs_search.
  FIELD-SYMBOLS : <vim>  TYPE any.
*End of changes - SCTASK0791864 - U105235 - 08/09/2019

* Get table name
  ASSIGN (master_name) TO <lfs_tab_name>.

  IF sy-subrc IS INITIAL.
* Record User ID
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL
  ENDIF. " IF sy-subrc IS INITIAL

*Begin of changes - SCTASK0791864 - U105235 - 08/09/2019
*validations as part of PCR 703
  ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
  IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
    lv_flag1 = abap_true.
  ENDIF.
*validations are written as part of PCR 703
  IF  ( sy-ucomm EQ lc_save OR
     sy-ucomm EQ lc_yes  OR
     sy-ucomm EQ lc_kopf OR
     sy-ucomm EQ  ' '    ) AND
     lv_flag1 EQ  abap_true.

*if the House bank and Account ID are entered, then retrieve the value of BANK ACCOUNT from T012K table
*and autopopulate the value of the BANK Account number
    CLEAR : lv_hbkid,
            lv_hktid,
            lv_bankn.
    ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
      lv_hbkid = <lfs_field>.
      ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        lv_hktid = <lfs_field>.
        SELECT  bankn
                FROM t012k
                INTO lv_bankn
                UP TO 1 ROWS
                WHERE hbkid = lv_hbkid
                AND   hktid = lv_hktid.
        ENDSELECT.
        ASSIGN COMPONENT 'BANKN' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
          <lfs_field> = lv_bankn.
        ENDIF.
      ENDIF.
    ENDIF.

*priority field value should be defaulted to '1',if the value is blank
    ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
      <lfs_field>  = lc_1.
    ENDIF.

*check if the customer field value is initial or not
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
      lv_kunnr = <lfs_field>.
*if the customer field value is not initial, check whether the Rule field value is TEXT
      ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> NE lc_text.
        MESSAGE e315(zotc_msg).   "With customer number populated,the Rule needs to be Text only
      ENDIF.
*if the ztext field is initial, throw an error message
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE  e316(zotc_msg).    "With customer number populated,Custom Text cannot be blank
      ENDIF.

*if the customer is not populated, ZRULE field value cannot be 'TEXT'
    ELSEIF sy-subrc IS INITIAL AND   <lfs_field> IS INITIAL.
      ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
        MESSAGE e317(zotc_msg).  "If customer number is blank then rule cannot be TEXT
      ENDIF.
*if the customer is blank, custom text field should also be blank else throw an error message
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        MESSAGE  e318(zotc_msg).    "If customer number is blank then Custom Text must be blank
      ENDIF.
    ENDIF.

*if the Rule field value is IBAN or ACCOUNT NUMBER, then custom text must be blank else throw an
*error message
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> NE lc_text.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        MESSAGE  e319(zotc_msg).    "If Rule is IBAN or Account Number then Custom Text must be blank
      ENDIF.
    ENDIF.

*if the Rule field value is equal to TEXT, then custom text cant be blank and if it is blank throw an
*error message
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e320(zotc_msg).  "If Rule is Text then Custom Text can not be blank.
      ENDIF.
    ENDIF.

*check the below mandatory field values before saving the record
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
      ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e322(zotc_msg) DISPLAY LIKE lc_i.  "If Rule is Text then Customer field cant be blank
      ENDIF.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e331(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field ZTEXT value is missing
      ENDIF.
    ENDIF.

*update the changed by, date and Time for the newly created record
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL

*Rule
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
      MESSAGE e323(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field RULE value is missing
    ELSE.
*company code
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e324(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field BURKS value is missing
      ELSE.
        lv_bukrs = <lfs_field>.
*Short key for a house bank
        ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
          MESSAGE e325(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field HOUSE BANK value is missing
        ELSE.
          lv_hbkid = <lfs_field>.
*ID for account details
          ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
            MESSAGE e326(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field Account Details value is missing
          ELSE.
            lv_hktid = <lfs_field>.
*Priority
            ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
            IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
              MESSAGE e327(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field PRIORITY value is missing
            ELSE.
              lv_zprio = <lfs_field>.
*Bank account number
              ASSIGN COMPONENT 'BANKN' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                MESSAGE e328(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field BANK Account Number value is missing
              ELSE.
*Tag
                ASSIGN COMPONENT 'ZTAG' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                  MESSAGE e329(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field TAG value is missing
                ELSE.
                  ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                  IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
                    MESSAGE e330(zotc_msg) DISPLAY LIKE lc_i.  "Mandatory field LAST CHANGED BY value is missing
                  ELSE.
* Record Current Date
                    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                      MESSAGE e332(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field CURRENT DATE value is missing
                    ELSE.
* Record Current Time
                      ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                      IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
                        MESSAGE e333(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field CURRENT TIME value is missing
                      ELSE.

                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

ENDIF.

*End of changes - SCTASK0791864 - U105235 - 08/09/2019
ENDFORM. "f_track_change

FORM f_track_change_01.

*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ===========================*
*09-Aug-2019   U105235      E2DK924281    SCTASK0791864 - PCR 703     *
*                                         additional validations      *
*---------------------------------------------------------------------*
  FIELD-SYMBOLS:
      <lfs_tab_name> TYPE any, "Table name
      <lfs_field>    TYPE any, "Field name
      <vim>          TYPE any.
  CONSTANTS : lc_text TYPE char4 VALUE 'TEXT',
              lc_save TYPE char4 VALUE 'SAVE',
              lc_yes  TYPE char3 VALUE 'YES',
              lc_kopf TYPE char4 VALUE 'KOPF',
              lc_i    TYPE char1 VALUE 'I',
              lc_d    TYPE char1 VALUE 'D',
              lc_1    TYPE char1 VALUE '1'.
  DATA : length     TYPE i,
         lv_zprio   TYPE zprio,
         lv_kunnr   TYPE kunnr,
         lv_bukrs1  TYPE bukrs,
         lv_hbkid1  TYPE hbkid,
         lv_hktid1  TYPE hktid,
         lv_hbkid   TYPE hbkid,
         lv_bankn   TYPE bankn,
         lv_hktid   TYPE hktid,
         lv_bukrs   TYPE bukrs,
         lv_text    TYPE ztext,
         lv_flag    TYPE char1,
         lv_flag1   TYPE char1,
         lv_flag2   TYPE char1,
         lv_text1   TYPE ztext,
         lv_zprio1  TYPE zprio,
         lv_zrule   TYPE zrule,
         lv_kunnr1  TYPE kunnr,
         lwa_search TYPE zotc_ebs_search.

* Get table name
  ASSIGN (master_name) TO <lfs_tab_name>.


*validations are written as part of PCR 703
  IF  ( sy-ucomm EQ lc_save OR
     sy-ucomm EQ lc_yes  OR
     sy-ucomm EQ lc_kopf OR
     sy-ucomm EQ abap_false )  AND
    ( <action> NE lc_d  AND
     <action>  EQ abap_false ).

*if the House bank and Account ID are entered, then retrieve the value of BANK ACCOUNT from T012K table
*and autopopulate the value of the BANK Account number
    CLEAR : lv_hbkid,
            lv_hktid,
            lv_bankn.
    ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
      lv_hbkid = <lfs_field>.
      ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        lv_hktid = <lfs_field>.
        SELECT  bankn
                FROM t012k
                INTO lv_bankn
                UP TO 1 ROWS
                WHERE hbkid = lv_hbkid
                AND   hktid = lv_hktid.
        ENDSELECT.
        ASSIGN COMPONENT 'BANKN' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
          <lfs_field> = lv_bankn.
        ENDIF.
      ENDIF.
    ENDIF.

*priority field value should be defaulted to '1',if the value is blank
    ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
      <lfs_field>  = lc_1.
    ENDIF.

*check if the customer field value is initial or not
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
      lv_kunnr = <lfs_field>.
*if the customer field value is not initial, check whether the Rule field value is TEXT
      ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> NE lc_text.
        MESSAGE e315(zotc_msg).   "With customer number populated,the Rule needs to be Text only
       ENDIF.
*if the ztext field is initial, throw an error message
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE  e316(zotc_msg).    "With customer number populated,Custom Text cannot be blank
      ENDIF.

*if the customer is not populated, ZRULE field value cannot be 'TEXT'
    ELSEIF sy-subrc IS INITIAL AND   <lfs_field> IS INITIAL.
      ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
        MESSAGE e317(zotc_msg).  "If customer number is blank then rule cannot be TEXT
      ENDIF.
*if the customer is blank, custom text field should also be blank else throw an error message
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        MESSAGE  e318(zotc_msg).    "If customer number is blank then Custom Text must be blank
      ENDIF.
    ENDIF.

*if the Rule field value is IBAN or ACCOUNT NUMBER, then custom text must be blank else throw an
*error message
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> NE lc_text.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        MESSAGE  e319(zotc_msg).    "If Rule is IBAN or Account Number then Custom Text must be blank
      ENDIF.
    ENDIF.

*if the Rule field value is equal to TEXT, then custom text cant be blank and if it is blank throw an
*error message
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e320(zotc_msg).  "If Rule is Text then Custom Text can not be blank.
      ENDIF.
    ENDIF.

*check the below mandatory field values before saving the record
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
      ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e322(zotc_msg) DISPLAY LIKE lc_i.  "If Rule is Text then Customer field cant be blank

      ENDIF.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e331(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field ZTEXT value is missing
      ENDIF.
    ENDIF.

*update the changed by, date and Time for the newly created record
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF.

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF.

*Rule
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
      MESSAGE e323(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field RULE value is missing
    ELSE.
*company code
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e324(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field BURKS value is missing
      ELSE.
        lv_bukrs = <lfs_field>.
*Short key for a house bank
        ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
          MESSAGE e325(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field HOUSE BANK value is missing
        ELSE.
          lv_hbkid = <lfs_field>.
*ID for account details
          ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
            MESSAGE e326(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field Account Details value is missing
          ELSE.
            lv_hktid = <lfs_field>.
*Priority
            ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
            IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
              MESSAGE e327(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field PRIORITY value is missing
            ELSE.
              lv_zprio = <lfs_field>.
*Bank account number
              ASSIGN COMPONENT 'BANKN' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                MESSAGE e328(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field BANK Account Number value is missing
              ELSE.
*Tag
                ASSIGN COMPONENT 'ZTAG' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                  MESSAGE e329(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field TAG value is missing
                ELSE.
                  ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                  IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
                    MESSAGE e330(zotc_msg) DISPLAY LIKE lc_i.  "Mandatory field LAST CHANGED BY value is missing
                  ELSE.
* Record Current Date
                    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                      MESSAGE e332(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field CURRENT DATE value is missing
                    ELSE.
* Record Current Time
                      ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                      IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
                        MESSAGE e333(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field CURRENT TIME value is missing
                      ELSE.

                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
ENDIF.

         ASSIGN total   TO <vim> CASTING TYPE (x_header-maintview).
         ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <vim> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
              lv_bukrs1 = <lfs_field>.
              ENDIF.
          ASSIGN COMPONENT 'HBKID' OF STRUCTURE <vim> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
              lv_hbkid1 = <lfs_field>.
              ENDIF.
            ASSIGN COMPONENT 'HKTID' OF STRUCTURE <vim> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
              lv_hktid1 =  <lfs_field>.
              ENDIF.
             ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <vim> TO <lfs_field>.
                 IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
                  lv_kunnr1 =  <lfs_field>.
                  ENDIF.
             ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <vim> TO <lfs_field>.
                  IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
                   lv_zprio1 =  <lfs_field>.
                  ENDIF.
              ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <vim> TO <lfs_field>.
                  IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
                   lv_zrule =  <lfs_field>.
                  ENDIF.

*if we want to delete the record,retreive the data from the table
* and delete the record
    IF <action> EQ lc_d  AND lv_zrule EQ lc_text.
      CLEAR lwa_search.
      SELECT SINGLE * FROM zotc_ebs_search
               INTO lwa_search
               WHERE  bukrs EQ lv_bukrs1
                   AND   hbkid EQ lv_hbkid1
                   AND   hktid EQ lv_hktid1
                   AND   zprio EQ lv_zprio1
                   AND   kunnr EQ lv_kunnr1.
      IF sy-subrc EQ 0.
        DELETE zotc_ebs_search FROM lwa_search.
      ENDIF.

    ELSEIF  <action> EQ lc_d  AND lv_zrule NE lc_text.
       CLEAR lwa_search.
      SELECT SINGLE * FROM zotc_ebs_search
               INTO lwa_search
               WHERE  bukrs EQ lv_bukrs1
                   AND   hbkid EQ lv_hbkid1
                   AND   hktid EQ lv_hktid1
                   AND   zprio EQ lv_zprio1.
      IF sy-subrc EQ 0.
        DELETE zotc_ebs_search FROM lwa_search.
      ENDIF.

    ENDIF.
ENDFORM.
FORM f_track_change_05.
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport                     Description
*=========== ============== ============== ===========================*
*09-Aug-2019   U105235      E2DK924281    SCTASK0791864 - PCR 703     *
*                                         additional validations      *
*---------------------------------------------------------------------*
     DATA : length    TYPE i,
           lv_zprio   TYPE zprio,
           lv_kunnr   TYPE kunnr,
           lv_bukrs1  TYPE bukrs,
           lv_hbkid1  TYPE hbkid,
           lv_hktid1  TYPE hktid,
           lv_zprio1  TYPE zprio,
           lv_kunnr1  TYPE kunnr,
           lwa_search TYPE zotc_ebs_search,
             lv_hbkid TYPE hbkid,
             lv_hktid TYPE hktid,
             lv_bukrs TYPE bukrs,
             lv_text  TYPE ztext,
             lv_flag  TYPE char1,
             lv_flag1 TYPE char1,
             lv_flag2 TYPE char1,
             lv_text1 TYPE ztext,
             lv_bankn TYPE bankn.
  CONSTANTS : lc_text TYPE char4 VALUE 'TEXT',
              lc_save TYPE char4 VALUE 'SAVE',
              lc_yes  TYPE char3 VALUE 'YES',
              lc_kopf TYPE char4 VALUE 'KOPF',
              lc_i    TYPE char1 VALUE 'I',
              lc_d    TYPE char1 VALUE 'D',
              lc_1    TYPE char1 VALUE '1'.
  FIELD-SYMBOLS:
    <lfs_tab_name> TYPE any, "Table name
      <lfs_field>    TYPE any, "Field name
    <vim> TYPE any.
* Get table name
  ASSIGN (master_name) TO <lfs_tab_name>.
  ASSIGN :   total   TO <vim> CASTING TYPE (x_header-maintview).

  ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS NOT  INITIAL.
           lv_hktid = <lfs_field>.
         ENDIF.
  ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS NOT  INITIAL.
           lv_hbkid = <lfs_field>.
          ENDIF.

  ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS NOT  INITIAL.
           lv_bukrs = <lfs_field>.
          ENDIF.
  ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS NOT  INITIAL.
           lv_zprio = <lfs_field>.
           ENDIF.
  ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS NOT  INITIAL.
           lv_kunnr = <lfs_field>.
           ENDIF.
*check whether the entry exists in the table already or not
    SELECT SINGLE * FROM zotc_ebs_search
             INTO lwa_search
             WHERE  bukrs EQ lv_bukrs
                 AND   hbkid EQ lv_hbkid
                 AND   hktid EQ lv_hktid
                 AND   zprio EQ lv_zprio.
    IF sy-subrc NE 0.
      lv_flag2 = abap_true.
    ENDIF.

     ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
          lv_text = <lfs_field>.

        ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <vim> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
          lv_bukrs1 = <lfs_field>.
          ASSIGN COMPONENT 'HBKID' OF STRUCTURE <vim> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
            lv_hbkid1 = <lfs_field>.
            ASSIGN COMPONENT 'HKTID' OF STRUCTURE <vim> TO <lfs_field>.
            IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
              lv_hktid1 =  <lfs_field>.
              ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <vim> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
                lv_bukrs1 =  <lfs_field>.
                ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <vim> TO <lfs_field>.
                IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
                  lv_kunnr1 =  <lfs_field>.
                  ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <vim> TO <lfs_field>.
                  IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
                    lv_zprio1 =  <lfs_field>.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

   IF lv_flag2  NE abap_true.
*duplicate check for ZTEXT field value for the CC,House Bank and Account ID combination
        SELECT ztext
               FROM zotc_ebs_search
               INTO lv_text1
               WHERE bukrs EQ lv_bukrs1
               AND   hbkid EQ lv_hbkid1
               AND   hktid EQ lv_hktid1
               AND   ztext EQ lv_text.
        ENDSELECT.
        IF  sy-subrc EQ 0.
          IF lv_text1 EQ lv_text.
            MESSAGE e334(zotc_msg) DISPLAY LIKE lc_i.   "ZTEXT value for the CC,House Bank,Account ID already exists
          ENDIF.
        ENDIF.
 ENDIF.

 IF  ( sy-ucomm EQ lc_save OR
       sy-ucomm EQ lc_yes  OR
       sy-ucomm EQ lc_kopf OR
       sy-ucomm EQ abap_false )  AND
     ( <action> NE lc_d  AND
       <action>  EQ ' ' ).

*if the House bank and Account ID are entered, then retrieve the value of BANK ACCOUNT from T012K table
*and autopopulate the value of the BANK Account number
    CLEAR : lv_hbkid,
            lv_hktid,
            lv_bankn.
    ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
      lv_hbkid = <lfs_field>.
      ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        lv_hktid = <lfs_field>.
        SELECT  bankn
                FROM t012k
                INTO lv_bankn
                UP TO 1 ROWS
                WHERE hbkid = lv_hbkid
                AND   hktid = lv_hktid.
        ENDSELECT.
        ASSIGN COMPONENT 'BANKN' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
          <lfs_field> = lv_bankn.
        ENDIF.
      ENDIF.
    ENDIF.

*priority field value should be defaulted to '1',if the value is blank
    ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
      <lfs_field>  = lc_1.
    ENDIF.

*check if the customer field value is initial or not
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
      lv_kunnr = <lfs_field>.
*if the customer field value is not initial, check whether the Rule field value is TEXT
      ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> NE lc_text.
        MESSAGE e315(zotc_msg).   "With customer number populated,the Rule needs to be Text only
      ENDIF.
*if the ztext field is initial, throw an error message
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE  e316(zotc_msg).    "With customer number populated,Custom Text cannot be blank
      ENDIF.

*if the customer is not populated, ZRULE field value cannot be 'TEXT'
    ELSEIF sy-subrc IS INITIAL AND   <lfs_field> IS INITIAL.
      ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
        MESSAGE e317(zotc_msg).  "If customer number is blank then rule cannot be TEXT
      ENDIF.
*if the customer is blank, custom text field should also be blank else throw an error message
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        MESSAGE  e318(zotc_msg).    "If customer number is blank then Custom Text must be blank
      ENDIF.
    ENDIF.

*if the Rule field value is IBAN or ACCOUNT NUMBER, then custom text must be blank else throw an
*error message
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> NE lc_text.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS NOT INITIAL.
        MESSAGE  e319(zotc_msg).    "If Rule is IBAN or Account Number then Custom Text must be blank
      ENDIF.
    ENDIF.

*if the Rule field value is equal to TEXT, then custom text cant be blank and if it is blank throw an
*error message
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e320(zotc_msg).  "If Rule is Text then Custom Text can not be blank.
      ENDIF.
    ENDIF.

*check the below mandatory field values before saving the record
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> EQ lc_text.
      ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e322(zotc_msg) DISPLAY LIKE lc_i.  "If Rule is Text then Customer field cant be blank

      ENDIF.
      ASSIGN COMPONENT 'ZTEXT' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e331(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field ZTEXT value is missing
      ENDIF.
    ENDIF.

*update the changed by, date and Time for the newly created record
    ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uname.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Date
    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-datum.
    ENDIF. " IF sy-subrc IS INITIAL

* Record Current Time
    ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL.
      <lfs_field> = sy-uzeit.
    ENDIF. " IF sy-subrc IS INITIAL

*Rule
    ASSIGN COMPONENT 'ZRULE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
      MESSAGE e323(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field RULE value is missing
    ELSE.
*company code
      ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
      IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
        MESSAGE e324(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field BURKS value is missing
      ELSE.
        lv_bukrs = <lfs_field>.
*Short key for a house bank
        ASSIGN COMPONENT 'HBKID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
        IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
          MESSAGE e325(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field HOUSE BANK value is missing
        ELSE.
          lv_hbkid = <lfs_field>.
*ID for account details
          ASSIGN COMPONENT 'HKTID' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
          IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
            MESSAGE e326(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field Account Details value is missing
          ELSE.
            lv_hktid = <lfs_field>.
*Priority
            ASSIGN COMPONENT 'ZPRIO' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
            IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
              MESSAGE e327(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field PRIORITY value is missing
            ELSE.
              lv_zprio = <lfs_field>.
*Bank account number
              ASSIGN COMPONENT 'BANKN' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
              IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                MESSAGE e328(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field BANK Account Number value is missing
              ELSE.
*Tag
                ASSIGN COMPONENT 'ZTAG' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                  MESSAGE e329(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field TAG value is missing
                ELSE.
                  ASSIGN COMPONENT 'ZZ_LASTCHANGED' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                  IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
                    MESSAGE e330(zotc_msg) DISPLAY LIKE lc_i.  "Mandatory field LAST CHANGED BY value is missing
                  ELSE.
* Record Current Date
                    ASSIGN COMPONENT 'ZZ_CHANGE_DATE' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                    IF sy-subrc IS INITIAL AND <lfs_field> IS INITIAL.
                      MESSAGE e332(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field CURRENT DATE value is missing
                    ELSE.
* Record Current Time
                      ASSIGN COMPONENT 'ZZ_CHANGE_TIME' OF STRUCTURE <lfs_tab_name> TO <lfs_field>.
                      IF sy-subrc IS INITIAL AND <lfs_field> IS  INITIAL.
                        MESSAGE e333(zotc_msg) DISPLAY LIKE lc_i.   "Mandatory field CURRENT TIME value is missing
                      ELSE.

                      ENDIF.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
ENDIF.
ENDFORM.
