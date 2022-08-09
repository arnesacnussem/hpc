LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;
USE work.test_values.ALL;

ENTITY encoder_tb IS
END;

ARCHITECTURE bench OF encoder_tb IS

    COMPONENT encoder
        PORT (
            msg     : IN MSG_MAT;
            gen     : IN GEN_MAT;
            encoded : OUT CODEWORD_MAT;
            ready    : OUT STD_LOGIC;
            rst     : IN STD_LOGIC;
            clk     : IN STD_LOGIC
        );
    END COMPONENT;

    -- Clock period
    CONSTANT clk_period : TIME := 5 ns;
    -- Generics

    -- Ports
    SIGNAL msg     : MSG_MAT := MESSAGE_MATRIX;
    SIGNAL gen     : GEN_MAT := GENERATE_MATRIX;
    SIGNAL encoded : CODEWORD_MAT;
    SIGNAL ready    : STD_LOGIC;
    SIGNAL rst     : STD_LOGIC := '0';
    SIGNAL clk     : STD_LOGIC := '0';

BEGIN

    encoder_inst : encoder
    PORT MAP(
        msg     => msg,
        gen     => gen,
        encoded => encoded,
        ready    => ready,
        rst     => rst,
        clk     => clk
    );
    PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR 1 ps;
        rst <= '0';
        WAIT FOR 1 ps;
        clk <= '1';
        WAIT FOR 1 ps;
        WAIT;
    END PROCESS;

    PROCESS
    BEGIN
        WAIT ON ready;
        WAIT UNTIL rising_edge(ready);
        REPORT "ready!!!!!";
        WAIT;
    END PROCESS;
END;