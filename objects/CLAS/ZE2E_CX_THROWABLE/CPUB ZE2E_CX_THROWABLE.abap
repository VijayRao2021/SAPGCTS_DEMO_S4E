class ZE2E_CX_THROWABLE definition
  public
  inheriting from CX_AI_APPLICATION_FAULT
  create public .

*"* public components of class ZE2E_CX_THROWABLE
*"* do not include other source files here!!!
public section.

  data AUTOMATIC_RETRY type PRX_AUTOMATIC_RETRY read-only .
  data CONTROLLER type PRXCTRLTAB read-only .
  data FAULT type ZE2E_THROWABLE read-only .
  data NO_RETRY type PRX_NO_RETRY read-only .
  data WF_TRIGGERED type PRX_WORKFLOW_TRIGGERED read-only .

  methods CONSTRUCTOR
    importing
      !TEXTID like TEXTID optional
      !PREVIOUS like PREVIOUS optional
      !AUTOMATIC_RETRY type PRX_AUTOMATIC_RETRY optional
      !CONTROLLER type PRXCTRLTAB optional
      !FAULT type ZE2E_THROWABLE optional
      !NO_RETRY type PRX_NO_RETRY optional
      !WF_TRIGGERED type PRX_WORKFLOW_TRIGGERED optional .