LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_bit.ALL;
USE work.generated.ALL;
USE work.core_util.ALL;

ENTITY p_decoder IS
    GENERIC (
        WORKER_COUNT : POSITIVE := 4
    );
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC

    );
END ENTITY p_decoder;

ARCHITECTURE rtl OF p_decoder IS

BEGIN

END ARCHITECTURE;