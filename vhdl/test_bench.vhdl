LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.consts.ALL;

ENTITY test_bench IS
END test_bench;

ARCHITECTURE TestBench OF test_bench IS
    COMPONENT encoder
        PORT (
            msg : IN BIT_VECTOR(0 TO MSG_LENGTH);
            gen : IN generator_matrix;
            encoded : OUT BIT_VECTOR(0 TO CODEWORD_LENGTH);
            rst : IN STD_LOGIC;
            done : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL msg : BIT_VECTOR(0 TO MSG_LENGTH) := "1010";
    SIGNAL gen : generator_matrix := (
        0 => "1101000",
        1 => "0110100",
        2 => "1110010",
        3 => "1010001"
    );
    SIGNAL encoded : BIT_VECTOR(0 TO CODEWORD_LENGTH);
    SIGNAL rst, done : STD_LOGIC;
BEGIN

    encoder1u : encoder PORT MAP(
        msg => msg,
        gen => gen,
        encoded => encoded,
        rst => rst,
        done => done
    );
    PROCESS
    BEGIN
        IF rising_edge(done) THEN
            REPORT to_string(encoded);
            WAIT;
        ELSE
            WAIT FOR 1 ps;
        END IF;
    END PROCESS;
END ARCHITECTURE;