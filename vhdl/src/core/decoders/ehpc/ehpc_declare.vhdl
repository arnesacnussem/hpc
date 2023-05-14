LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

PACKAGE ehpc_declare IS

    TYPE PHASES IS (ROW, COLUMN);
    TYPE phase_map IS ARRAY(PHASES RANGE <>) OF STD_LOGIC;

END PACKAGE ehpc_declare;