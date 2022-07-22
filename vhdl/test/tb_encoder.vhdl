LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.consts.ALL;
USE work.test_values.ALL;

ENTITY tb_encoder IS
END tb_encoder;

ARCHITECTURE TB_Encoder OF tb_encoder IS
    COMPONENT encoder IS
        PORT (
            msg      : IN MSG_MAT;       -- message matrix
            gen      : IN GEN_MAT;       -- generator matrix
            encoded  : OUT CODEWORD_MAT; -- codeword matrix
            done     : OUT STD_LOGIC;    -- signal of work done
            rst, clk : IN STD_LOGIC      -- reset done status and clock of work
        );
    END COMPONENT;
    SIGNAL msg      : MSG_MAT := MESSAGE_MATRIX;  -- message matrix
    SIGNAL gen      : GEN_MAT := GENERATE_MATRIX; -- generator matrix
    SIGNAL encoded  : CODEWORD_MAT;               -- codeword matrix
    SIGNAL done     : STD_LOGIC;                  -- signal of work done
    SIGNAL rst, clk : STD_LOGIC;                  -- reset done status and clock of work
BEGIN
    encoder1 : encoder
    PORT MAP(
        clk  => clk,
        rst  => rst,
        msg  => msg,
        done => done,
        gen  => gen
    );
    PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR 1 ps;
        rst <= '0';
        WAIT FOR 1 ps;
        WAIT FOR 1 ps;

        WAIT;
    END PROCESS;

END ARCHITECTURE;