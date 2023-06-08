LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.core_util.ALL;

ENTITY line_encoder IS
    PORT (
        msg   : IN MSG_LINE;                          -- message matrix
        code  : OUT CODEWORD_LINE := (OTHERS => '0'); -- codeword matrix
        ready : OUT STD_LOGIC     := '0';             -- signal of work ready
        reset : IN STD_LOGIC;                         -- reset
        clk   : IN STD_LOGIC                          -- clock
    );
END ENTITY line_encoder;

ARCHITECTURE rtl OF line_encoder IS
BEGIN

    le : PROCESS (clk)
        VARIABLE lout : CODEWORD_LINE;
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                ready <= '0';
                code  <= (OTHERS => '0');
            ELSE
                lout := (OTHERS => '0');
                FOR col IN 0 TO CODEWORD_LENGTH LOOP
                    FOR row IN 0 TO MSG_LENGTH LOOP
                        lout(col) := (msg(row) AND GENERATE_MATRIX(row)(col)) XOR lout(col);
                    END LOOP;
                END LOOP;
                code  <= lout;
                ready <= '1';
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;