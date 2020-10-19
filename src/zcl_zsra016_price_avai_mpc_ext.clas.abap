class ZCL_ZSRA016_PRICE_AVAI_MPC_EXT definition
  public
  inheriting from ZCL_ZSRA016_PRICE_AVAI_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZSRA016_PRICE_AVAI_MPC_EXT IMPLEMENTATION.


METHOD define.
  DATA lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ.
  DATA lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

*
*  DATA : lv_namespace  TYPE string,
*         lr_annotation TYPE REF TO cl_fis_shlp_annotation.


  super->define( ).

  lo_entity = model->get_entity_type( 'Product' ).
  lo_property = lo_entity->get_property( 'MimeType' ).
  lo_property->set_as_content_type( ).

  IF cl_sra016_lama=>is_lama_active( ) EQ abap_true.

    cl_sra016_lama=>update_metadata_matnr( io_model         = model
                                           iv_entity_name   = 'Product'
                                           iv_property_name = 'ProductID'
                                           iv_set_conv_exit = abap_true ).

    cl_sra016_lama=>update_metadata_matnr( io_model         = model
                                           iv_entity_name   = 'Product'
                                           iv_property_name = 'ProductReferenceNo'
                                           iv_set_conv_exit = abap_true ).

    cl_sra016_lama=>update_metadata_matnr( io_model         = model
                                           iv_entity_name   = 'ProductAttribute'
                                           iv_property_name = 'ProductID'
                                           iv_set_conv_exit = abap_true ).

    cl_sra016_lama=>update_metadata_matnr( io_model          = model
                                           iv_entity_name   = 'ProductAvailability'
                                           iv_property_name = 'ProductID'
                                           iv_set_conv_exit = abap_true ).
  ENDIF.

*  model->set_soft_state_enabled( iv_soft_state_enabled = abap_true ).
*  model->get_schema_namespace( IMPORTING ev_namespace = lv_namespace ).
*
*  "Customer Search Help Annotation
*  lr_annotation = cl_fis_shlp_annotation=>create(
*      io_odata_model               = model
*      io_vocan_model               = vocab_anno_model
*      iv_namespace                 = lv_namespace
*      iv_entitytype                = 'NotificationHeader'
*      iv_property                  = 'Kunnr'
*      iv_search_help               = 'ZOTC_AG_WE'
*      iv_search_help_field         = 'KUNNR'
*      iv_valuelist_entityset       = 'ZotcAgWeSet'
*      iv_valuelist_property        = 'Kunnr' ).
*
*  lr_annotation->add_display_parameter( iv_valuelist_property  = 'Name1' ) .
*  lr_annotation->add_display_parameter( iv_valuelist_property  = 'Mcod3' ) .
*  lr_annotation->add_display_parameter( iv_valuelist_property  = 'Land1' ) .
*  lr_annotation->add_display_parameter( iv_valuelist_property  = 'Pstlz' ) .
*  lr_annotation->add_display_parameter( iv_valuelist_property  = 'Kunn2' ) .

ENDMETHOD.
ENDCLASS.
