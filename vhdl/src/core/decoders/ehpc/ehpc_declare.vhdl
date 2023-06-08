LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE ehpc_declare IS
    TYPE ehpc_state_t IS (CHK_CR1, ERASE, VEC_CHK, CHK_CR2, C2R3C, R3REQ);
    TYPE ehpc_state_map IS ARRAY(ehpc_state_t RANGE <>) OF STD_LOGIC;
END PACKAGE ehpc_declare;