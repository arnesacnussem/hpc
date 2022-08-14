LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;
USE work.test_values.ALL;

ENTITY encoder_tb IS
END;

ARCHITECTURE bench OF encoder_tb IS
    -- Clock period
    CONSTANT clk_period : TIME := 5 ns;
    -- Generics

    -- Ports
    SIGNAL msg   : MSG_MAT := MESSAGE_MATRIX;
    SIGNAL code  : CODEWORD_MAT;
    SIGNAL ready : STD_LOGIC;
    SIGNAL rst   : STD_LOGIC := '0';
    SIGNAL clk   : STD_LOGIC := '0';
    SIGNAL exit1 : BOOLEAN   := false;
BEGIN

    encoder_inst : ENTITY work.encoder
        PORT MAP(
            msg   => msg,
            code  => code,
            ready => ready,
            rst   => rst,
            clk   => clk
        );

    PROCESS

    BEGIN
        clk <= NOT clk;
        WAIT FOR 1 ps;
        IF exit1 THEN
            WAIT;
        END IF;
    END PROCESS;

    PROCESS
    BEGIN
        WAIT UNTIL ready = '1';
        WAIT UNTIL rising_edge(clk);
        rst <= '1';
        WAIT UNTIL rising_edge(clk);
        exit1 <= true;
        WAIT;
    END PROCESS;
END;