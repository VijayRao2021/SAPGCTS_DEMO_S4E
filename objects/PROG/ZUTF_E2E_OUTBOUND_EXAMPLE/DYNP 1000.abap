PROCESS BEFORE OUTPUT.

MODULE %_INIT_PBO.

MODULE %_PBO_REPORT.

MODULE %_PF_STATUS.

MODULE %_END_OF_PBO.

PROCESS AFTER INPUT.

  MODULE %_BACK AT EXIT-COMMAND.

  MODULE %_INIT_PAI.

FIELD !P_DATEFR MODULE %_P_DATEFR .

FIELD !P_DATETO MODULE %_P_DATETO .


CHAIN.
  FIELD P_DATEFR .
  FIELD P_DATETO .
    MODULE %_BLOCK_1000000.
ENDCHAIN.

FIELD !P_DISWS MODULE %_P_DISWS .

FIELD !P_LOGLVL MODULE %_P_LOGLVL .


CHAIN.
  FIELD P_DISWS .
  FIELD P_LOGLVL .
    MODULE %_BLOCK_1000004.
ENDCHAIN.

CHAIN.
  FIELD P_DATEFR .
  FIELD P_DATETO .
  FIELD P_DISWS .
  FIELD P_LOGLVL .
  MODULE %_END_OF_SCREEN.
  MODULE %_OK_CODE_1000.
ENDCHAIN.