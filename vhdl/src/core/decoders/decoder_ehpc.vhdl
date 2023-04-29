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
    SIGNAL stat          : stat_t                      := COPY;
    SIGNAL row_vector    : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector    : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL col_err_pos   : int_array(codeIn'RANGE(1))  := (OTHERS => 0);
    SIGNAL transposeFlag : BOOLEAN                     := false;
    SIGNAL code          : CODEWORD_MAT;
    SIGNAL message       : MSG_MAT;
BEGIN

    PROCESS (clk)

        VARIABLE err_exist : BOOLEAN;
        VARIABLE err_pos   : INTEGER;
        -- FIXME: 这个提取行好像搞得太复杂了
        VARIABLE code_line : CODEWORD_LINE;

        VARIABLE index : NATURAL := 0;

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
                CASE stat IS
                    WHEN COPY =>
                        FOR i IN codeIn'RANGE LOOP
                            FOR j IN codeIn(i)'RANGE LOOP
                                code(i)(j) <= codeIn(i)(j);
                            END LOOP;
                        END LOOP;
                        stat <= CHK_R1;
                    WHEN CHK_R1 =>
                        code_line := code(index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            row_vector(index) <= '1';
                            IF err_pos =- 1 THEN
                                row_uncorrect(index) <= '1';
                            END IF;
                        END IF;
                        IF nextIndex(code'length) THEN
                            stat <= CHK_C1;
                        END IF;
                    WHEN CHK_C1 =>
                        code_line := getColumn(mat => code, index => index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            col_vector(index) <= '1';
                            IF err_pos =- 1 THEN
                                col_uncorrect(index) <= '1';
                            END IF;
                        END IF;
                        IF nextIndex(code'length(1)) THEN
                            stat <= CHK_SET_FLAG;
                        END IF;
                    WHEN CHK_SET_FLAG =>
                        UpdateCountSum;
                        IF col_count > row_count OR col_sum > row_sum THEN
                            transposeFlag <= true;
                            TransposeInPositionSIG(code);
                        END IF;
                        stat <= CHK_CRFLAG;
                    WHEN CHK_CRFLAG =>
                        IF row_count = col_count AND col_sum = row_sum THEN
                            IF col_count * col_count < col_sum * 2 THEN
                                stat <= CHK_CRLOOP;
                            END IF;
                        END IF;
                        stat <= RST_CRVEC;
                    WHEN CHK_CRLOOP =>
                        FOR i IN col_vector'RANGE LOOP
                            FOR j IN row_vector'RANGE LOOP
                                IF col_vector(i) = '1' AND row_vector(j) = '1' THEN
                                    code(i)(j) <= NOT code(i)(j);
                                END IF;
                            END LOOP;
                        END LOOP;
                        stat <= RST_CRVEC;
                    WHEN RST_CRVEC           =>
                        row_vector    <= (OTHERS => '0');
                        col_vector    <= (OTHERS => '0');
                        row_uncorrect <= (OTHERS => '0');
                        col_uncorrect <= (OTHERS => '0');
                        stat          <= CHK_R2;
                    WHEN CHK_R2 =>
                        code_line := code(index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            row_vector(index) <= '1';
                            IF err_pos =- 1 THEN
                                row_uncorrect(index) <= '1';
                            ELSE
                                code(index)(err_pos) <= NOT code(index)(err_pos);
                            END IF;
                        END IF;
                        IF nextIndex(code'length) THEN
                            stat <= CHK_C2;
                        END IF;
                    WHEN CHK_C2 =>
                        code_line := getColumn(mat => code, index => index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            col_vector(index) <= '1';
                            IF err_pos =- 1 THEN
                                col_uncorrect(index) <= '1';
                            ELSE
                                col_err_pos(index) <= err_pos;
                                IF row_vector(err_pos) = '0' THEN
                                    col_uncorrect(index) <= '1';
                                END IF;
                            END IF;
                        END IF;
                        IF nextIndex(code'length(1)) THEN
                            stat <= CHK_CR2_SUM;
                        END IF;
                    WHEN CHK_CR2_SUM =>
                        UpdateCountSum;
                        IF row_sum * 2 = 3 * col_sum THEN
                            stat <= CHK_CR2_LOOP_1;
                        ELSE
                            stat <= CHK_CR2_LOOP_2;
                        END IF;
                    WHEN CHK_CR2_LOOP_1 =>
                        FOR i IN col_vector'RANGE LOOP
                            FOR j IN row_vector'RANGE LOOP
                                IF col_vector(i) = '1' AND row_vector(j) = '1' THEN
                                    code(i)(j) <= NOT code(i)(j);
                                END IF;
                            END LOOP;
                        END LOOP;
                        stat <= CHK_R3;
                    WHEN CHK_CR2_LOOP_2 =>
                        IF col_err_pos(index) /= 0 THEN
                            code(col_err_pos(index))(index) <= NOT code(col_err_pos(index))(index);
                        END IF;
                        IF nextIndex(col_vector'length) THEN
                            stat <= CHK_CR2_LOOP_2S;
                        END IF;
                    WHEN CHK_CR2_LOOP_2S =>
                        code_line := code(index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            IF err_pos =- 1 THEN
                                FOR j IN code'RANGE(1) LOOP
                                    code(index)(j) <= NOT code(index)(j);
                                END LOOP;
                            ELSE
                                code(index)(err_pos) <= NOT code(index)(err_pos);
                            END IF;
                        END IF;
                        IF nextIndex(code'length) THEN
                            stat <= CHK_R3;
                        END IF;
                    WHEN CHK_R3 =>
                        code_line := code(index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            IF err_pos =- 1 THEN
                                has_err <= '1';
                            ELSE
                                code(index)(err_pos) <= NOT code(index)(err_pos);
                            END IF;
                        END IF;
                        IF nextIndex(code'length) THEN
                            stat <= CHK_REQ;
                        END IF;
                    WHEN CHK_REQ =>
                        IF has_err = '1' THEN
                            stat <= CHK_FLAG;
                        ELSE
                            stat <= CHK_C3;
                        END IF;
                    WHEN CHK_C3 =>
                        code_line := getColumn(mat => code, index => index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            has_err <= '1';
                            stat    <= CHK_FLAG;
                        END IF;
                        IF nextIndex(code'length(1)) THEN
                            stat <= CHK_FLAG;
                        END IF;
                    WHEN CHK_FLAG =>
                        IF transposeFlag THEN
                            TransposeInPositionSIG(code);
                        END IF;
                        stat <= EXTRACT;
                    WHEN EXTRACT =>
                        FOR col IN MSG_LINE'RANGE LOOP
                            message(MSG_MAT'length - index - 1)(MSG_LINE'length - col - 1) <= code(CODEWORD_LINE'length - col - 1)(CODEWORD_MAT'length - index - 1);
                        END LOOP;
                        IF nextIndex(message'length) THEN
                            stat <= RDY;
                        END IF;
                    WHEN RDY =>
                        ready <= '1';
                        msg   <= message;
                        REPORT LF & "[DEC/EHPC] codeIn=" & LF & MXIO_toHexString(codeIn);
                        REPORT LF & "[DEC/EHPC] corr=" & LF & MXIO_toHexString(code);
                        REPORT LF & "[DEC/EHPC] msg=" & LF & MXIO_toHexString(message);
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;