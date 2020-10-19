*----------------------------------------------------------------------*
***INCLUDE LZOTC_SALE_EMPMAPI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  Z_TRACK_UID  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_track_uid INPUT.

  INCLUDE zcanxxxo_track_user.

ENDMODULE.                 " Z_TRACK_UID  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_VALIDATE_EMPROLE  INPUT
*&---------------------------------------------------------------------*
*       To validate Employee Role
*----------------------------------------------------------------------*
MODULE z_validate_emprole INPUT.

* Local structure declaration
  TYPES:BEGIN OF ty_sal_emp,
        emp_role TYPE z_emprole,
        END OF ty_sal_emp.

* Local constant declaration
  CONSTANTS:lc_para TYPE char10 VALUE 'EMP_ROLE',
          lc_blank TYPE char1 VALUE '',
          lc_sopt  TYPE char2 VALUE 'EQ',
          lc_act   TYPE char1 VALUE 'X'.

data: lv_mvalue1 type Z_MVALUE_LOW.

*fetch data from zotc_prc_control table
  SELECT single mvalue1
    FROM zotc_prc_control
      INTO lv_mvalue1
    WHERE mprogram NE lc_blank
    AND mparameter = lc_para
    AND mactive = lc_act
    AND soption = lc_sopt
    AND mvalue1 = zotc_sale_empmap-emp_role.

    IF sy-subrc <> 0.
      message e000 with 'Please enter valid Employee Role'.
    ENDIF.
  ENDMODULE.                 " Z_VALIDATE_EMPROLE  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_VALIDATE_EMPNUM  INPUT
*&---------------------------------------------------------------------*
*       Validate Employee Number
*----------------------------------------------------------------------*
module Z_VALIDATE_EMPNUM input.
  data: lv_kunnr type kunnr.
*  Local constant declaration
  CONSTANTS:lc_ktokd TYPE char10 VALUE 'ZREP'.



*Select data from Kna1
  SELECT single
    kunnr
    FROM kna1
    INTO lv_kunnr
    WHERE kunnr = zotc_sale_empmap-EMP_NUMBER
    and ktokd = lc_ktokd.
    IF sy-subrc <> 0.
      message e000 with 'Please enter valid Employee Number'.
    ENDIF.
endmodule.                 " Z_VALIDATE_EMPNUM  INPUT
