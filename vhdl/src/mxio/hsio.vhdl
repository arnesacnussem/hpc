LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.numeric_bit.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
ENTITY hsio IS
    GENERIC (
        WIDTH : POSITIVE := 1;
        SIZE  : POSITIVE := 1;
        MODE  : IOMode   := INPUT
    );
    PORT (
        clkFast : IN STD_LOGIC;
        clkSlow : IN STD_LOGIC;
        dataMX  : INOUT MXIO;
        dataSE  : INOUT STD_LOGIC_VECTOR;
        alert   : OUT STD_LOGIC

    );
END ENTITY hsio;

ARCHITECTURE rtl OF hsio IS
    SIGNAL internal_ready : BOOLEAN := False;
    
BEGIN
    mode_select_inst : CASE MODE GENERATE
        WHEN INPUT =>
            PROCESS (clkFast)
            BEGIN
                IF rising_edge(clkFast) THEN

                END IF;
            END PROCESS;

        WHEN OUTPUT =>

    END GENERATE;
END ARCHITECTURE;