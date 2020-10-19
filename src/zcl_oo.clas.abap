CLASS ZCL_OO DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
*Marker interface for Database Procedures
    INTERFACES: IF_AMDP_MARKER_HDB.
    CLASS-METHODS FUNCTION  FOR TABLE FUNCTION ZOTC_OPEN_SALES_ORDERS.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS ZCL_OO IMPLEMENTATION.

  METHOD FUNCTION BY DATABASE FUNCTION
      FOR HDB
      LANGUAGE SQLSCRIPT
      OPTIONS READ-ONLY
      USING VBAK VBAP VBEP LIKP LIPS.
    it_data_1 =
    SELECT vbep.mandt,
           vbep.vbeln,
           vbep.posnr,
           vbep.etenr,
           vbep.edatu,
           vbep.wmeng,
           vbap.kzwi1,
           vbap.kwmeng
     from vbep inner join vbap  on  vbep.mandt =  vbap.mandt
                                and vbep.vbeln = vbap.vbeln
                                and vbep.posnr = vbap.posnr
               INNER JOIN VBAK  on  vbep.mandt =  vbak.mandt
                                and vbep.vbeln = vbak.vbeln;

    it_data_2 =
    SELECT mandt,
           vbeln,
           posnr,
           etenr,
           edatu,
           wmeng,
           kzwi1,
           kwmeng,
           sum ( wmeng ) OVER ( PARTITION BY  mandt,vbeln,posnr order by edatu ) as wmeng_rt,
           sum ( wmeng ) OVER ( PARTITION BY  mandt,vbeln,posnr ) as wmeng_t
     from :it_data_1;


    it_data_3 =
    SELECT lips.mandt,
           lips.vgbel as vbeln,
           lips.vgpos as posnr,
           SUM( CASE WHEN LIKP.SPE_ACC_APP_STS = 'C'
                     THEN LIPS.LFIMG
                     else 0 END
           ) AS lfimg
     from lips inner join likp  on  lips.mandt =  likp.mandt
                                and lips.vbeln =  likp.vbeln
               INNER JOIN VBAK  on  lips.mandt =  vbak.mandt
                                and lips.vgbel =  vbak.vbeln
               INNER JOIN VBAP  on  lips.mandt =  vbap.mandt
                                and lips.vgbel =  vbap.vbeln
                                and lips.vgpos =  vbap.posnr
     group by lips.mandt,lips.vgbel,lips.vgpos;

    it_data_4 =
    SELECT :it_data_2.mandt,
           :it_data_2.vbeln,
           :it_data_2.posnr,
           :it_data_2.etenr,
           :it_data_2.edatu,
           case WHEN :it_data_2.wmeng_rt <= :it_data_3.lfimg
                THEN 0
                WHEN ( :it_data_2.wmeng_rt - :it_data_2.wmeng ) < :it_data_3.lfimg
                THEN :it_data_2.wmeng_rt - :it_data_3.lfimg
                ELSE :it_data_2.wmeng
                END AS WMENG_OO,
           :it_data_2.kzwi1,
           :it_data_2.kwmeng
     from :it_data_2 left outer join :it_data_3
                                 on  :it_data_2 .mandt =  :it_data_3.mandt
                                 and :it_data_2 .vbeln =  :it_data_3.vbeln
                                 and :it_data_2 .posnr =  :it_data_3.posnr;

    RETURN SELECT mandt,
                  vbeln as SalesDocument,
                  posnr as SalesDocumentItem,
                  etenr as ScheduleLine,
                  edatu as DeliveryDate,
                  wmeng as OpenQuantity,
                  ( kzwi1 /kwmeng ) * wmeng as OpenAmount
                  from :it_data_2
                  where wmeng > 0;

  ENDMETHOD.

ENDCLASS.
