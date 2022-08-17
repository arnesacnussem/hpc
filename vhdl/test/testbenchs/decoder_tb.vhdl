LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.test_values.ALL;

ENTITY decoder_tb IS
END;

ARCHITECTURE bench OF decoder_tb IS

    -- Ports
    SIGNAL code  : CODEWORD_MAT;
    SIGNAL msg   : MSG_MAT := MESSAGE_MATRIX;
    SIGNAL msg_o : MSG_MAT;
    SIGNAL ready : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL rst   : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL clk1  : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL clk   : STD_LOGIC := '0';
    SIGNAL exit1 : BOOLEAN   := false;

BEGIN

    encoder_inst : ENTITY work.encoder
        PORT MAP(
            msg   => msg,
            code  => code,
            ready => ready(0),
            rst   => rst(0),
            clk   => clk1(0)
        );

    decoder_inst : ENTITY work.decoder
        PORT MAP(
            code  => code,
            msg   => msg_o,
            ready => ready(1),
            rst   => rst(1),
            clk   => clk1(1)
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
        clk1(0) <= clk;
        WAIT UNTIL ready = "10";

        WAIT UNTIL rising_edge(clk);
        clk1(0) <= '0';
        clk1(1) <= clk;

        WAIT UNTIL ready = "11";
        clk1(1) <= '0';

        WAIT UNTIL rising_edge(clk);
        rst(1) <= '1';
        WAIT;
    END PROCESS;

END;