LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;

ENTITY ehpc_earse IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec        : IN CODEWORD_MAT;
        recOut     : OUT CODEWORD_MAT;
        col_vector : IN bit_vector(CODEWORD_MAT'RANGE);
        row_vector : IN bit_vector(CODEWORD_MAT'RANGE)
    );
END ENTITY;
ARCHITECTURE rtl OF ehpc_earse IS
BEGIN

    PROCESS (clk)
        VARIABLE o : CODEWORD_MAT;
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                ready <= '0';
            ELSE
                FOR c IN col_vector'RANGE LOOP
                    FOR r IN row_vector'RANGE LOOP
                        IF col_vector(c) = '1' AND row_vector(r) = '1' THEN
                            o(r)(c) := NOT rec(r)(c);
                        ELSE
                            o(r)(c) := rec(r)(c);
                        END IF;
                    END LOOP;
                END LOOP;
                recOut <= o;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;