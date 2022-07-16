LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE work.consts.ALL;

ENTITY test_bench IS
END test_bench;

ARCHITECTURE TestBench OF test_bench IS
    COMPONENT encoder
        PORT (
            msg : IN bit_vector(MSG_LENGTH TO 0);
            gen : IN generator_matrix;
            encoded : OUT bit_vector(CODEWORD_LENGTH TO 0)
        );
    END COMPONENT;

    SIGNAL msg : bit_vector(MSG_LENGTH TO 0);
    SIGNAL gen : generator_matrix;
    SIGNAL encoded : bit_vector(CODEWORD_LENGTH TO 0);
BEGIN

    encoder1u : encoder PORT MAP(
        msg => msg,
        gen => gen,
        encoded => encoded
    );
    PROCESS
        VARIABLE m : bit_vector(MSG_LENGTH TO 0);
    BEGIN
        msg <= m;
    END PROCESS;
END ARCHITECTURE;