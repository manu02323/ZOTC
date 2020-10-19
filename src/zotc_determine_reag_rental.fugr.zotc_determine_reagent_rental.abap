FUNCTION zotc_determine_reagent_rental.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IM_VKORG) TYPE  VKORG
*"     REFERENCE(IM_VTWEG) TYPE  VTWEG
*"     REFERENCE(IM_SPART) TYPE  SPART
*"     REFERENCE(IM_SOLD_TO) TYPE  KUNAG
*"     REFERENCE(IM_SHIP_TO) TYPE  KUNWE
*"     REFERENCE(IM_MATNR_TAB) TYPE  TABLE_MATNR
*"  EXPORTING
*"     REFERENCE(EX_CONTRACT_DATA) TYPE  ZOTC_T_REAGENT_RENTAL
*"     REFERENCE(EX_CONTRACT_COUNT) TYPE  I
*"----------------------------------------------------------------------
***********************************************************************
*Program    : ZOTC_DETERMINE_REAGENT_RENTAL(Function Module)          *
*Title      : Re-agent rental contracts determination                 *
*Developer  : Harshit Badlani                                         *
*Object type: Function Module                                         *
*SAP Release: SAP ECC 6.0                                             *
*---------------------------------------------------------------------*
*WRICEF ID: D2_OTC_IDD_0095                                           *
*---------------------------------------------------------------------*
*Description: FM for Re-agent rental contracts determination. For each*
*material it will return the count of contract with contract number.  *
*---------------------------------------------------------------------*
*MODIFICATION HISTORY:
*=====================================================================*
*Date           User        Transport       Description
*=========== ============== ============== ===========================*
*21-MAY-2014  HBADLAN       E2DK900468      INITIAL DEVELOPMENT       *
*17-Jun-2014  JMAZUMD       E2DK900468     Include Item no in export  *
*                                          parameter and structure    *
*                                          required for OTC_IDD_0090  *
*---------------------------------------------------------------------*
* Local Data declarations

  CONSTANTS : lc_trvog TYPE trvog VALUE '4',    "Contract
              lc_zrrc  TYPE auart VALUE 'ZRRC'. " Sales Document Type

  TYPES :
*Structure  for  Material ,Contract combination
          BEGIN OF lty_vbeln,
          matnr TYPE matnr, "Material No
          vbeln TYPE vbeln, "Document no
          posnr TYPE posnr, "Item number of the SD document
          END OF lty_vbeln,

*Structure for Material numbers
          BEGIN OF lty_matnr,
          matnr TYPE matnr,                             " Material Number
          END OF lty_matnr,
          lty_t_vbeln TYPE STANDARD TABLE OF lty_vbeln, "Table type for material,contract struc
          lty_t_matnr TYPE STANDARD TABLE OF lty_matnr. "Table type for Material no.

  DATA :lwa_contract TYPE zotc_reagent_rental_s, "Output strcuture for Re-agent rental contracts determination
        li_vbeln     TYPE lty_t_vbeln,           "Contracts data table
        li_temp      TYPE lty_t_vbeln,           "Temp table
        li_matnr     TYPE lty_t_matnr,           "Table only for material numbers
        lv_index     TYPE sytabix,               " Index of Internal Tables
        lv_sold_to   TYPE kunag,                 " Sold-to party
        lv_ship_to   TYPE kunwe.                 " Ship-to party

  FIELD-SYMBOLS :
       <lfs_matnr>   TYPE lty_matnr, "Field  symbol for Material,
       <lfs_vbeln>   TYPE lty_vbeln. "Field symbol for Material,contract struc

  CONSTANTS  : lc_ship_to      TYPE parvw         VALUE 'WE'. "Partner type for Ship to customer

*Populating li_matnr with only unique material numbers.
  li_matnr[] = im_matnr_tab[].
  SORT li_matnr BY matnr.
  DELETE ADJACENT DUPLICATES FROM li_matnr COMPARING matnr.

  IF li_matnr[] IS NOT INITIAL.
*--- Convert Sold-to SAP Internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = im_sold_to
      IMPORTING
        output = lv_sold_to.

*--- Convert Ship-to SAP Internal format
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = im_ship_to
      IMPORTING
        output = lv_ship_to.

*Fetching  respective contract document
*We just need contract no's and we are not fetching non key fields.
*Hence full primary key select not required.
    SELECT
    a~matnr                              "Material
    a~vbeln                              "Doc no
    a~posnr                              "Item number of the SD document "INSERT by JAHAN
    INTO TABLE li_vbeln
    FROM vapma AS a INNER JOIN vbpa AS b
    ON b~vbeln = a~vbeln
    FOR ALL ENTRIES IN li_matnr
    WHERE a~matnr =  li_matnr-matnr  AND "Material Number
          a~vkorg =  im_vkorg        AND "Sales org
          a~trvog =  lc_trvog        AND "Transaction group
          a~vtweg =  im_vtweg        AND "Distribution channel
          a~spart =  im_spart        AND "Divison
          a~auart =  lc_zrrc         AND "Contract type-ZRRC
          a~kunnr =  lv_sold_to      AND "Sold to party
          a~datab <= sy-datum        AND "contract valid from
          a~datbi >= sy-datum        AND "contract valid to
          b~kunnr =  lv_ship_to      AND "Ship to party
          b~parvw = lc_ship_to.
    IF sy-subrc EQ 0.
      IF lines( li_vbeln[] ) > 0.
*If li_vbeln gets populated based on select query
        SORT li_vbeln BY vbeln matnr.
        DELETE ADJACENT DUPLICATES FROM li_vbeln COMPARING vbeln matnr.
      ENDIF. " IF lines( li_vbeln[] ) > 0
    ENDIF. " IF sy-subrc EQ 0
  ENDIF. " IF li_matnr[] IS NOT INITIAL

  SORT li_vbeln BY matnr.
*Appending  Material number ,Contract no and no. of contracts per material
*into table

  LOOP AT li_matnr ASSIGNING <lfs_matnr>.
* check if there is any contract for the material
    READ TABLE li_vbeln ASSIGNING <lfs_vbeln> WITH KEY  matnr = <lfs_matnr>-matnr
                                              BINARY SEARCH.
    IF sy-subrc = 0.
      CLEAR : lv_index,
              lwa_contract.

      lv_index = sy-tabix.
*Count of No. of contracts per material.
      li_temp[] = li_vbeln[].
      DELETE li_temp WHERE matnr NE <lfs_matnr>-matnr.
      ex_contract_count = lines( li_temp[] ). "Count of Reagent contract

      lwa_contract-matnr = <lfs_matnr>-matnr.

*Parallel cursor
      LOOP AT li_vbeln ASSIGNING <lfs_vbeln> FROM lv_index.
        IF <lfs_vbeln>-matnr <> <lfs_matnr>-matnr.
          EXIT.
        ENDIF. " IF <lfs_vbeln>-matnr <> <lfs_matnr>-matnr
        lwa_contract-contract_num  = <lfs_vbeln>-vbeln. "Contract number
        lwa_contract-contract_item = <lfs_vbeln>-posnr. "Contract Item
        APPEND lwa_contract TO ex_contract_data.
      ENDLOOP. " LOOP AT li_vbeln ASSIGNING <lfs_vbeln> FROM lv_index
    ELSE. " ELSE -> IF <lfs_vbeln>-matnr <> <lfs_matnr>-matnr
* no contract found so return blank count and contract number
      CLEAR: lwa_contract.
      lwa_contract-matnr = <lfs_matnr>-matnr.
      APPEND lwa_contract TO ex_contract_data.
    ENDIF. " IF sy-subrc = 0
  ENDLOOP. " LOOP AT li_matnr ASSIGNING <lfs_matnr>

ENDFUNCTION.
