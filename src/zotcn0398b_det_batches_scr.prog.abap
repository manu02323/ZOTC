*&---------------------------------------------------------------------*
*&  Include           ZOTCN0398B_DET_BATCHES_SCR
*&---------------------------------------------------------------------*
*&**********************************************************************
* PROGRAM    :  ZOTCN0398B_DET_BATCHES_SCR                             *
* TITLE      :  Batch Determination at Sales Order                     *
* DEVELOPER  :  Avik Poddar                                            *
* OBJECT TYPE:  Enhancement Program                                    *
* SAP RELEASE:  SAP ECC 6.0                                            *
*----------------------------------------------------------------------*
* WRICEF ID:    D3_OTC_EDD_0398                                        *
*----------------------------------------------------------------------*
* DESCRIPTION:  Batch determination program will be used as a tool for *
*               automatic batch assignment to sales order lines,       *
*               specifically red-blood cells materials in background   *
*----------------------------------------------------------------------*
* MODIFICATION HISTORY:                                                *
*======================================================================*
* DATE        USER        TRANSPORT         DESCRIPTION                *
* 11-OCT-2018  APODDAR   E1DK938946      Initial Development           *
* =========== ======== ========== =====================================*

PARAMETERS : p_apsfil  TYPE localfile  OBLIGATORY, "Local file for upload/download
             p_jobnam  TYPE btcjob     OBLIGATORY, "Job Name
             p_jobnum  TYPE btcjobcnt  OBLIGATORY, "Job Num
             p_mailid  TYPE ad_smtpadr OBLIGATORY. "Mail Id
