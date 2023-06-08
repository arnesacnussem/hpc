LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.decoder_utils.ALL;

ENTITY ehpc_vector_chk IS
    PORT (
        row_vector    : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_vector    : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        row_uncorrect : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_uncorrect : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');

        col_count : OUT NATURAL := 0;
        row_count : OUT NATURAL := 0;
        col_sum   : OUT NATURAL := 0;
        row_sum   : OUT NATURAL := 0;

        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC := '0'
    );
END ENTITY ehpc_vector_chk;

ARCHITECTURE rtl OF ehpc_vector_chk IS
    PROCEDURE VectorCS (
        SIGNAL vec1 : IN STD_LOGIC_VECTOR;
        SIGNAL vec2 : IN STD_LOGIC_VECTOR;
        SIGNAL sum  : OUT NATURAL;
        SIGNAL cnt  : OUT NATURAL
    ) IS
        VARIABLE count : NATURAL := 0;
    BEGIN
        FOR i IN vec1'RANGE LOOP
            IF vec1(i) = '1' THEN
                count := count + 1;
            END IF;
        END LOOP;
        sum <= count;
        FOR i IN vec2'RANGE LOOP
            IF vec2(i) = '1' THEN
                count := count + 1;
            END IF;
        END LOOP;
        cnt <= count;
    END PROCEDURE;
BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                ready     <= '0';
                row_sum   <= 0;
                col_sum   <= 0;
                row_count <= 0;
                col_count <= 0;
            ELSE
                VectorCS(vec1 => row_vector, vec2 => row_uncorrect, sum => row_sum, cnt => row_count);
                VectorCS(vec1 => col_vector, vec2 => col_uncorrect, sum => col_sum, cnt => col_count);
                ready <= '1';
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;