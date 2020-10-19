class ZCL_IM_OTC_SAPSLL_IFEX_SDO definition
  public
  final
  create public .

public section.
*"* public components of class ZCL_IM_OTC_SAPSLL_IFEX_SDO
*"* do not include other source files here!!!

  interfaces /SAPSLL/IF_EX_IFEX_SD0C_R3 .
protected section.
*"* protected components of class ZCL_IM_OTC_SAPSLL_IFEX_SDO
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_OTC_SAPSLL_IFEX_SDO
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_OTC_SAPSLL_IFEX_SDO IMPLEMENTATION.


METHOD /sapsll/if_ex_ifex_sd0c_r3~if_extend_cus_cdoc.

* SAP Note : 1365020 HPQC # 1288

  DATA: ls_vbrp TYPE vbrpvb,
        ls_itm TYPE /sapsll/api6800_itm_r3_s,
        lv_mot TYPE thme_mot,
        lv_dgnu TYPE thme_dgnu,
        lv_tabix TYPE sy-tabix,
        lv_item_number TYPE text10.

  CLEAR: lv_mot.

  CASE is_eikp-expvz.

    WHEN '1'.
      lv_mot = '04'.

    WHEN '2'.
      lv_mot = '02'.

    WHEN '3'.
      lv_mot = '01'.

    WHEN '4'.
      lv_mot = '05'.

    WHEN '7'.
      lv_mot = '20'.

    WHEN '8'.
      lv_mot = '03'.

    WHEN OTHERS.
      lv_mot = '99'.

  ENDCASE.

*-Pro Position Gefahrgut lesen
  LOOP AT it_vbrp INTO ls_vbrp.

    CLEAR: lv_dgnu.

    SELECT SINGLE dgnu
    FROM dgtmd
    INTO lv_dgnu
    WHERE valfr <= sy-datum
    AND valto >= sy-datum
    AND delflg = ' '
    AND parkflg = ' '
    AND matnr = ls_vbrp-matnr
    AND mot = lv_mot
    AND tkui = 'UN'.

    IF NOT sy-subrc IS INITIAL.

      SELECT SINGLE dgnu
      FROM dgtmd
      INTO lv_dgnu
      WHERE valfr <= sy-datum
      AND valto >= sy-datum
      AND delflg = ' '
      AND parkflg = ' '
      AND matnr = ls_vbrp-matnr
      AND tkui = 'UN'.
    ENDIF.

    IF sy-subrc IS INITIAL AND NOT lv_dgnu IS INITIAL.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_vbrp-posnr
        IMPORTING
          output = lv_item_number.

      READ TABLE cs_itm_cdoc-gen INTO ls_itm WITH KEY item_number = lv_item_number.

      lv_tabix = sy-tabix.

      IF sy-subrc IS INITIAL.
        ls_itm-hazardous_goods_indicator = 'X'.
        ls_itm-hazardous_goods_number = lv_dgnu.
        MODIFY cs_itm_cdoc-gen FROM ls_itm INDEX lv_tabix TRANSPORTING hazardous_goods_indicator hazardous_goods_number.
      ENDIF.

    ENDIF.

  ENDLOOP.

ENDMETHOD.


  method /SAPSLL/IF_EX_IFEX_SD0C_R3~IF_EXTEND_PRE_PREFE.
  endmethod.


method /SAPSLL/IF_EX_IFEX_SD0C_R3~IF_EXTEND_PRE_VDWLO.
endmethod.
ENDCLASS.
