class Z01OTC_CX_FMT_EQUI definition
  public
  inheriting from CX_AI_APPLICATION_FAULT
  create public .

public section.

  data ADDITION type Z01OTC_EXCHANGE_LOG_DATA read-only .
  data AUTOMATIC_RETRY type PRX_AUTOMATIC_RETRY read-only .
  data CONTROLLER type PRXCTRLTAB read-only .
  data NO_RETRY type PRX_NO_RETRY read-only .
  data STANDARD type Z01OTC_EXCHANGE_FAULT_DATA read-only .
  data WF_TRIGGERED type PRX_WORKFLOW_TRIGGERED read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !ADDITION type Z01OTC_EXCHANGE_LOG_DATA optional
      !AUTOMATIC_RETRY type PRX_AUTOMATIC_RETRY optional
      !CONTROLLER type PRXCTRLTAB optional
      !NO_RETRY type PRX_NO_RETRY optional
      !STANDARD type Z01OTC_EXCHANGE_FAULT_DATA optional
      !WF_TRIGGERED type PRX_WORKFLOW_TRIGGERED optional .
protected section.
private section.
ENDCLASS.



CLASS Z01OTC_CX_FMT_EQUI IMPLEMENTATION.


method CONSTRUCTOR.
CALL METHOD SUPER->CONSTRUCTOR
EXPORTING
TEXTID = TEXTID
PREVIOUS = PREVIOUS
.
me->ADDITION = ADDITION .
me->AUTOMATIC_RETRY = AUTOMATIC_RETRY .
me->CONTROLLER = CONTROLLER .
me->NO_RETRY = NO_RETRY .
me->STANDARD = STANDARD .
me->WF_TRIGGERED = WF_TRIGGERED .
endmethod.
ENDCLASS.
