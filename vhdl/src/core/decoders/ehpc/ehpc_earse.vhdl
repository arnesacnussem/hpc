LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;

ENTITY ehpc_earse IS
    PORT (
        enable : IN STD_LOGIC;
        reset  : IN STD_LOGIC;

        rec        : IN CODEWORD_MAT;
        recOut     : OUT CODEWORD_MAT;
        col_vector : IN bit_vector(CODEWORD_MAT'RANGE);
        row_vector : IN bit_vector(CODEWORD_MAT'RANGE)
    );
END ENTITY;
ARCHITECTURE rtl OF ehpc_earse IS
BEGIN
    PROCESS (enable)
        VARIABLE o : CODEWORD_MAT;
    BEGIN
        IF rising_edge(enable) THEN
            FOR i IN col_vector'RANGE LOOP
                FOR j IN row_vector'RANGE LOOP
                    IF col_vector(i) = '1' AND row_vector(j) = '1' THEN
                        o(i)(j) := NOT rec(i)(j);
                    ELSE
                        o(i)(j) := rec(i)(j);
                    END IF;
                END LOOP;
            END LOOP;
            recOut <= o;
        ELSE
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;