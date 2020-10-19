*&---------------------------------------------------------------------*
*&  Include           ZOTCI0042B_PRICE_LOAD_SCR
*&---------------------------------------------------------------------*
************************************************************************
* PROGRAM    :  ZOTCI0042B_PRICE_LOAD                                  *
* TITLE      :  OTC_IDD_42_Price Load                                  *
* DEVELOPER  :  Shammi Puri                                            *
* OBJECT TYPE:  Interface                                              *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:  OTC_IDD_42_Price Load
*----------------------------------------------------------------------*
* DESCRIPTION: Bio-Rad requires an interface to handle new entries and
* changes to the Transfer Price.This will not be a real time price
* update to the ECC system, but a periodic upload of the transfer price.
* This interface gives the ability to upload Transfer Price into the ECC
* system using a flat file. The format of the upload template will be a
* tab-delimited txt file. The upload program would read the flat file and
* create transfer price condition records in the SAP system. To load the
* data from the flat file, we will use a custom transaction, which will
* be scheduled to run every mid-night.
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER     TRANSPORT  DESCRIPTION                          *
* =========== ======== ========== =====================================*
* 05-June-2012 SPURI  E1DK901668 INITIAL DEVELOPMENT                   *
*&---------------------------------------------------------------------*

selection-screen begin of block blk1 with frame title text-001.
parameters: rb_pres  radiobutton group rb2 user-command comm2 modif id mi1 default 'X',
            p_phdr   type localfile modif id mi3,
            rb_app   radiobutton group rb2 modif id mi1 ,
            p_ahdr   type localfile modif id mi2.
selection-screen skip.
parameters: cb_map as checkbox default 'X'.
selection-screen end of block blk1.
