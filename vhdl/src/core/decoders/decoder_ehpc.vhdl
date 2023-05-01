LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.decoder_utils.ALL;

ENTITY decoder_ehpc IS
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC := '0'
    );
END ENTITY decoder_ehpc;

ARCHITECTURE rtl OF decoder_ehpc IS
    TYPE int_array IS ARRAY (NATURAL RANGE <>) OF INTEGER;
    TYPE stat_t IS (COPY, CHK_R1, CHK_C1, CHK_SET_FLAG, CHK_CRFLAG, CHK_CRLOOP, RST_CRVEC, CHK_R2, CHK_C2, CHK_CR2_SUM, CHK_CR2_LOOP_1, CHK_CR2_LOOP_2, CHK_CR2_LOOP_2S, CHK_R3, CHK_C3, CHK_REQ, CHK_FLAG, EXTRACT, RDY);
    SIGNAL stat : stat_t := COPY;
    SIGNAL row_vector    : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector    : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');

BEGIN


    ehpc_proc : PROCESS (clk)
        VARIABLE err_exist     : BOOLEAN;
        VARIABLE err_pos       : INTEGER;
        VARIABLE code_line     : CODEWORD_LINE;
        VARIABLE col_err_pos   : int_array(codeIn'RANGE(1))  := (OTHERS => 0);
        VARIABLE transposeFlag : BOOLEAN                     := false;
        VARIABLE code          : CODEWORD_MAT;
        VARIABLE message       : MSG_MAT;
        VARIABLE index         : NATURAL := 0;

        IMPURE FUNCTION nextIndex(lim : INTEGER) RETURN BOOLEAN IS
        BEGIN
            index := index + 1;
            IF index = lim THEN
                index := 0;
                RETURN true;
            END IF;
            RETURN false;
        END;

        FUNCTION sum_vec(vec1 : bit_vector; vec2 : bit_vector) RETURN INTEGER IS
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

        VARIABLE col_count : INTEGER := 0;
        VARIABLE row_count : INTEGER := 0;
        VARIABLE col_sum   : INTEGER := 0;
        VARIABLE row_sum   : INTEGER := 0;

        PROCEDURE UpdateCountSum IS
        BEGIN
            col_count := 0;
            row_count := 0;
            FOR i IN col_vector'RANGE LOOP
                IF col_vector(i) = '1' THEN
                    col_count := col_count + 1;
                END IF;
            END LOOP;
            FOR i IN row_vector'RANGE LOOP
                IF row_vector(i) THEN
                    row_count := row_count + 1;
                END IF;
            END LOOP;
            col_sum := sum_vec(col_vector, col_uncorrect);
            row_sum := sum_vec(row_vector, row_uncorrect);
        END PROCEDURE;
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                msg   <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
                ready <= '0';
                stat  <= COPY;
            ELSE
                
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;