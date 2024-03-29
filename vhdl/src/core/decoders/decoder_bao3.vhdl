LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.decoder_utils.ALL;

ENTITY decoder_bao3 IS
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC := '0'
    );
END ENTITY decoder_bao3;

ARCHITECTURE decoder_bao3 OF decoder_bao3 IS
    TYPE state_t IS (COPY, R1, R2, R3, EXTRACT, RDY);
    SIGNAL stat    : state_t := COPY;
    SIGNAL code    : CODEWORD_MAT;
    SIGNAL col_vec : CODEWORD_LINE;
    SIGNAL row_vec : CODEWORD_LINE;
BEGIN

    PROCESS (clk)
        VARIABLE err_pos   : INTEGER;
        VARIABLE err_exist : BOOLEAN;

        VARIABLE message : MSG_MAT;

        VARIABLE code_line : CODEWORD_LINE;
        VARIABLE index     : NATURAL := 0;
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                msg     <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
                ready   <= '0';
                has_err <= '0';
                stat    <= COPY;
            ELSE
                CASE stat IS
                    WHEN COPY =>
                        code <= codeIn;
                        stat <= R1;
                    WHEN R1 =>
                        code_line := code(index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            REPORT "[DEC/BAO3] found error: row=" & INTEGER'image(index) & " err_pos=" & INTEGER'image(err_pos);
                            has_err        <= '1';
                            row_vec(index) <= '1';
                            IF err_pos >= 0 THEN
                                code(index)(err_pos) <= NOT code(index)(err_pos);
                            END IF;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC/BAO3] round 1/3";
                            index := 0;
                            stat <= R2;
                        END IF;

                    WHEN R2 =>
                        code_line := getColumn(mat => code, index => index);
                        line_decode(code_line, err_exist, err_pos);

                        IF err_exist THEN
                            REPORT "[DEC/BAO3]: col=" & INTEGER'image(index) & " err_pos=" & INTEGER'image(err_pos);
                            has_err <= '1';
                            IF err_pos >= 0 THEN
                                code(err_pos)(index) <= NOT code(err_pos)(index);
                                IF row_vec(err_pos) = '0' THEN
                                    col_vec(index) <= '1';
                                END IF;
                            ELSE
                                col_vec(index) <= '1';
                            END IF;
                        END IF;

                        index := index + 1;
                        -- 这玩意是正方形的，所以col和row长度一样...
                        IF index = CODEWORD_LINE'length THEN
                            REPORT "[DEC/BAO3] round 2/3";
                            index := 0;
                            stat <= R3;
                        END IF;
                    WHEN R3 =>
                        code_line := code(index);
                        line_decode(code_line, err_exist, err_pos);
                        IF err_exist THEN
                            has_err <= '1';
                            IF err_pos >= 0 THEN
                                code(index)(err_pos) <= NOT code(index)(err_pos);
                            ELSE
                                FOR col IN CODEWORD_LINE'RANGE LOOP
                                    IF col_vec(col) = '1' THEN
                                        code(index)(col) <= NOT code(index)(col);
                                    END IF;
                                END LOOP;
                            END IF;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_LINE'length THEN
                            REPORT "[DEC/BAO3] round 3/3";
                            index := 0;
                            stat <= EXTRACT;
                        END IF;
                    WHEN EXTRACT =>
                        FOR col IN MSG_LINE'RANGE LOOP
                            message(MSG_MAT'length - index - 1)(MSG_LINE'length - col - 1) := code(CODEWORD_LINE'length - col - 1)(CODEWORD_MAT'length - index - 1);
                        END LOOP;

                        index := index + 1;
                        IF index = msg'length THEN
                            REPORT "[DEC/BAO3] message extracted";
                            index := 0;
                            stat <= RDY;
                        END IF;
                    WHEN RDY =>
                        ready <= '1';
                        msg   <= message;
                        REPORT LF & "[DEC/BAO3] codeIn=" & LF & MXIO_toHexString(codeIn);
                        REPORT LF & "[DEC/BAO3] corr=" & LF & MXIO_toHexString(code);
                        REPORT LF & "[DEC/BAO3] msg=" & LF & MXIO_toHexString(message);
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE decoder_bao3;