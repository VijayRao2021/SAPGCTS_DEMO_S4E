PROCESS BEFORE OUTPUT.

MODULE %_INIT_PBO.

MODULE %_PBO_REPORT.

MODULE %_PF_STATUS.

MODULE %_END_OF_PBO.

PROCESS AFTER INPUT.

  MODULE %_BACK AT EXIT-COMMAND.

  MODULE %_INIT_PAI.

FIELD !P_RETTIM MODULE %_P_RETTIM .


CHAIN.
  FIELD P_RETTIM .
    MODULE %_BLOCK_1000000.
ENDCHAIN.

CHAIN.
  FIELD P_RETTIM .
  MODULE %_END_OF_SCREEN.
  MODULE %_OK_CODE_1000.
ENDCHAIN.