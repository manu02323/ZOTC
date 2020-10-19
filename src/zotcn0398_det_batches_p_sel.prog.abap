*&---------------------------------------------------------------------*
*&  Include           ZOTC_EDD0398_DET_BATCHES_SEL
*&---------------------------------------------------------------------*
selection-screen begin of block a1 with frame title text-001.
select-options: s_matnr  for gv_matnr,
                s_werks  for gv_plant no intervals no-extension,    "Defect# 5957
                s_vkorg  for gv_vkorg obligatory,  "Sales Organization
                s_vtweg  for gv_vtweg,             "Distribution Channel
                s_rqdate for gv_rdate obligatory,  "Req Dlv Date
                s_ordty  for gv_auart,             "Order Type
                s_docno  for gv_docno,
                s_soldto for gv_soldto,
                s_charg  for gv_batch.

parameters      p_unso as checkbox default space.
selection-screen end of block a1.
