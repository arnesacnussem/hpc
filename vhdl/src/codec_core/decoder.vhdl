LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;
USE work.utils.ALL;
USE work.decoder_utils.ALL;

ENTITY decoder IS
    PORT (
        code    : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC
    );
END ENTITY decoder;

ARCHITECTURE decoder OF decoder IS
    TYPE state_t IS (R0, R1, R2, R3, R4, RDY);
    SIGNAL stat : state_t := R0;
BEGIN

    PROCESS (clk)
        VARIABLE err_exist : BOOLEAN;
        VARIABLE err_pos   : INTEGER;

        VARIABLE col_vec : CODEWORD_LINE;
        VARIABLE row_vec : CODEWORD_LINE;

        VARIABLE code_tmp : CODEWORD_MAT;
        VARIABLE message  : MSG_MAT;
        -- FIXME: 这个提取行好像搞得太复杂了
        VARIABLE column_temp : CODEWORD_LINE;

        VARIABLE index : NATURAL := 0;
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                msg   <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
                ready <= '0';
                stat  <= R0;
            ELSE
                CASE stat IS
                    WHEN R0 =>
                        code_tmp := code;
                        stat <= R1;
                    WHEN R1 =>
                        line_decode(code_tmp(index), err_exist, err_pos);
                        IF err_exist THEN
                            REPORT "[DEC(1/3)]: row=" & INTEGER'image(index) & " err_pos=" & INTEGER'image(err_pos);
                            has_err <= '1';
                            row_vec(index) := '1';
                            IF err_pos >= 0 THEN
                                code_tmp(index)(err_pos) := NOT code_tmp(index)(err_pos);
                            END IF;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC/R1] round 1/3";
                            index := 0;
                            stat <= R2;
                        END IF;

                    WHEN R2 =>
                        -- 列转行
                        FOR row IN CODEWORD_LINE'RANGE LOOP
                            column_temp(row) := code_tmp(row)(index);
                        END LOOP;
                        line_decode(column_temp, err_exist, err_pos);

                        IF err_exist THEN
                            REPORT "[DEC(2/3)]: col=" & INTEGER'image(index) & " err_pos=" & INTEGER'image(err_pos);
                            has_err <= '1';
                            IF err_pos >= 0 THEN
                                code_tmp(err_pos)(index) := NOT code_tmp(err_pos)(index);
                                IF row_vec(err_pos) = '0' THEN
                                    col_vec(index) := '1';
                                END IF;
                            ELSE
                                col_vec(index) := '1';
                            END IF;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_LINE'length THEN
                            REPORT "[DEC/R2] round 2/3";
                            index := 0;
                            stat <= R3;
                        END IF;
                    WHEN R3 =>
                        line_decode(code_tmp(index), err_exist, err_pos);
                        IF err_exist THEN
                            has_err <= '1';
                            IF err_pos >= 0 THEN
                                code_tmp(index)(err_pos) := NOT code_tmp(index)(err_pos);
                            ELSE
                                FOR col IN CODEWORD_LINE'RANGE LOOP
                                    IF col_vec(col) = '1' THEN
                                        code_tmp(index)(col) := NOT code_tmp(index)(col);
                                    END IF;
                                END LOOP;
                            END IF;
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_LINE'length THEN
                            REPORT "[DEC/R3] round 3/3";
                            index := 0;
                            stat <= R4;
                        END IF;
                    WHEN R4 =>
                        FOR col IN MSG_LINE'RANGE LOOP
                            message(MSG_MAT'length - index - 1)(MSG_LINE'length - col - 1) := code_tmp(CODEWORD_LINE'length - col - 1)(CODEWORD_MAT'length - index - 1);
                        END LOOP;

                        index := index + 1;
                        IF index = msg'length THEN
                            REPORT "[DEC/R4] message extracted";
                            index := 0;
                            stat <= RDY;
                        END IF;
                    WHEN RDY =>
                        ready <= '1';
                        msg   <= message;
                        REPORT LF & "[DEC] code=" & LF & MXIO_toString(code);
                        REPORT LF & "[DEC] corr=" & LF & MXIO_toString(code_tmp);
                        REPORT LF & "[DEC] msg=" & LF & MXIO_toString(message);
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE decoder;