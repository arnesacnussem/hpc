LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.test_values.ALL;
USE work.decoder_types.ALL;

ENTITY decoder_tb IS
END;

ARCHITECTURE bench OF decoder_tb IS

    -- Ports
    SIGNAL code    : CODEWORD_MAT;
    SIGNAL msg     : MSG_MAT := MESSAGE_MATRIX;
    SIGNAL msg_o   : MSG_MAT;
    SIGNAL ready   : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL rst     : STD_LOGIC_VECTOR(0 TO 1) := "00";
    SIGNAL clk_c   : STD_LOGIC_VECTOR(0 TO 1) := "00";
    SIGNAL clk_r   : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL clk     : STD_LOGIC := '0';
    SIGNAL exit1   : BOOLEAN   := false;
    SIGNAL has_err : STD_LOGIC;
BEGIN

    encoder_inst : ENTITY work.encoder
        PORT MAP(
            msg   => msg,
            code  => code,
            ready => ready(0),
            rst   => rst(0),
            clk   => clk_r(0)
        );

    decoder_inst : ENTITY work.decoder
        GENERIC MAP(
            decoder_type => PMS2
        )
        PORT MAP(
            codeIn  => code,
            msg     => msg_o,
            ready   => ready(1),
            rst     => rst(1),
            clk     => clk_r(1),
            has_err => has_err
        );
    PROCESS
        VARIABLE clk_real : STD_LOGIC := '0';
    BEGIN

        FOR i IN clk_c'RANGE LOOP
            IF clk_c(i) = '1' THEN
                clk_r(i) <= clk;
            ELSE
                clk_r(i) <= '0';
            END IF;
        END LOOP;

        clk <= NOT clk;
        WAIT FOR 1 ps;
        IF exit1 THEN
            WAIT;
        END IF;
    END PROCESS;

    PROCESS
    BEGIN
        clk_c <= "10";
        WAIT UNTIL ready = "10";

        WAIT UNTIL rising_edge(clk);
        clk_c <= "01";

        WAIT UNTIL ready = "11";
        clk_c <= "00";

        WAIT UNTIL rising_edge(clk);
        rst(1) <= '1';

        WAIT UNTIL rising_edge(clk);
        exit1 <= true;
        WAIT;
    END PROCESS;

END;