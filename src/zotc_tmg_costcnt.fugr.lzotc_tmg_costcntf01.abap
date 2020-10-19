************************************************************************
* PROGRAM    :  LZOTC_TMG_COSTCNTF01                                   *
* TITLE      :  OTC_EDD_0074_Sales Rep Cost Center Assignment          *
* DEVELOPER  :  Debraj Haldar                                          *
* OBJECT TYPE:  ENHANCEMENT                                            *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_EDD_0074                                             *
*----------------------------------------------------------------------*
* DESCRIPTION: This program will be used to maintain the table         *
*              ZOTC_COSTCENTER                                         *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
*  30-JUN-2012 DHALDAR  E1DK903043 INITIAL DEVELOPMENT                 *
*&---------------------------------------------------------------------*



*&---------------------------------------------------------------------*
*&      Form  CREATE_NEW
*&---------------------------------------------------------------------*
*       Subroutine to update descriptions while creating new entries   *
*----------------------------------------------------------------------*


FORM create_new.

*Local data declaration
  DATA: lv_vtext TYPE vtxtk,
        lv_bezei TYPE z_bezei,
        lv_name1 TYPE z_kna1_name1,
        lv_ktext TYPE z_ktext.

*Check whether the Sales organization is initial or not
* If it is having value then populate the Sales Org description
  IF zotc_costcenter-vkorg IS NOT INITIAL.
* Get the Sales organization description from TVKOT
    SELECT  SINGLE
            vtext  "Name
     FROM   tvkot
     INTO  lv_vtext
     WHERE spras = sy-langu
     AND   vkorg = zotc_costcenter-vkorg.
    IF sy-subrc = 0.
      zotc_costcenter-vtext = lv_vtext.
    ENDIF.
  ENDIF.

*Check whether Sales Document Type is initial or not
* If it is having value then populate the Sales doc description
  IF zotc_costcenter-auart IS NOT INITIAL.
* Get the Sales Document type description from TVKOT
    SELECT  SINGLE
            bezei  "Description
     FROM   tvakt
     INTO  lv_bezei
     WHERE spras = sy-langu
     AND   auart = zotc_costcenter-auart.
    IF sy-subrc = 0.
      zotc_costcenter-bezei = lv_bezei.
    ENDIF.
  ENDIF.

*Check whether Customer Number is initial or not
* If it is having value then populate the Customer Description
  IF zotc_costcenter-kunnr IS NOT INITIAL.
* Get the Customer Name from KNA1
    SELECT  SINGLE
            name1  "Name 1
     FROM   kna1
     INTO  lv_name1
     WHERE kunnr = zotc_costcenter-kunnr
     AND spras = sy-langu.
    IF sy-subrc = 0.
      zotc_costcenter-name1 = lv_name1.
    ENDIF.
  ENDIF.


*Check whether Cost Center is initial or not
* If it is having value then populate the Cost Center description
  IF zotc_costcenter-kostl IS NOT INITIAL.

* Get the Cost Center description from CSKT
    SELECT  ktext  "General Name
     UP TO 1 ROWS
     FROM   cskt
     INTO  lv_ktext
     WHERE kostl = zotc_costcenter-kostl
     AND spras = sy-langu.
    ENDSELECT.

    IF sy-subrc = 0.
      zotc_costcenter-ktext = lv_ktext.
    ENDIF.
  ENDIF.


ENDFORM.                    "CREATE_NEW


*&---------------------------------------------------------------------*
*&      Form  FILL_HIDDEN
*&---------------------------------------------------------------------*
*   Subroutine to update descriptions while editing new entries        *
*----------------------------------------------------------------------*
FORM fill_hidden.

*Local data declaration
  DATA: lv_ktext TYPE z_ktext.
*Check whether Cost Center is initial or not
* If it is having value then populate the Cost Center description
  IF zotc_costcenter-kostl IS NOT INITIAL.

* Get the Cost Center description from CSKT
    SELECT  ktext  "General Name
     UP TO 1 ROWS
     FROM   cskt
     INTO  lv_ktext
     WHERE kostl = zotc_costcenter-kostl
     AND spras = sy-langu.
    ENDSELECT.

    IF sy-subrc = 0.
      zotc_costcenter-ktext = lv_ktext.
    ENDIF.
  ENDIF.

ENDFORM.                    "FILL_HIDDEN
