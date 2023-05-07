LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.decoder_utils.ALL;

ENTITY ehpc_vector_chk IS
    PORT (
        row_vector    : IN bit_vector(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_vector    : IN bit_vector(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        row_uncorrect : IN bit_vector(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_uncorrect : IN bit_vector(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');

        col_count : OUT NATURAL := 0;
        row_count : OUT NATURAL := 0;
        col_sum   : OUT NATURAL := 0;
        row_sum   : OUT NATURAL := 0;

        clk : IN STD_LOGIC
    );
END ENTITY ehpc_vector_chk;

ARCHITECTURE rtl OF ehpc_vector_chk IS

BEGIN

    PROCESS (clk)
        FUNCTION VectorSum(vec1 : bit_vector; vec2 : bit_vector) RETURN NATURAL IS
            VARIABLE result : INTEGER := 0;
        BEGIN
            FOR i IN vec1'RANGE LOOP
                IF vec1(i) = '1' THEN
                    result := result + 1;
                END IF;
                IF vec2(i) = '1' THEN
                    result := result + 1;
                END IF;
            END LOOP;
            RETURN result; -- Return the sum of the corresponding elements
        END FUNCTION;

        FUNCTION VectorCount(vec : bit_vector) RETURN NATURAL IS
            VARIABLE count           : NATURAL := 0;
        BEGIN
            FOR i IN vec'RANGE LOOP
                IF vec(i) = '1' THEN
                    count := count + 1;
                END IF;
            END LOOP;
            RETURN count;
        END VectorCount;
    BEGIN
        IF rising_edge(clk) THEN
            col_count <= VectorCount(col_vector);
            row_count <= VectorCount(row_vector);
            col_sum   <= VectorSum(col_vector, col_uncorrect);
            row_sum   <= VectorSum(row_vector, row_uncorrect);
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;