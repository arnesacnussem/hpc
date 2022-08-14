LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;

ENTITY decoder IS
    PORT (
        code  : IN CODEWORD_MAT;      -- codeword matrix
        msg   : OUT MSG_MAT;          -- message matrix
        ready : OUT STD_LOGIC := '0'; -- signal of work ready
        rst   : IN STD_LOGIC;         -- reset ready status and clock of work
        clk   : IN STD_LOGIC          -- clock
    );
END ENTITY decoder;

ARCHITECTURE decoder OF decoder IS
    TYPE state_t IS (R0, R1, R2, R3, RDY);
    SIGNAL stat : state_t := R1;
    PROCEDURE find (
        VARIABLE val : IN INTEGER;
        VARIABLE pos : OUT INTEGER
    ) IS
    BEGIN
        pos := (-1);
        FOR i IN REF_TABLE'RANGE LOOP
            IF (REF_TABLE(i) = val) THEN
                pos := i;
            END IF;
        END LOOP;
    END PROCEDURE;

    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER -- err_pos大于等于0时表示该错误可纠正
    ) IS
        VARIABLE syndrome : BIT_VECTOR(0 TO CHECK_LENGTH);
        VARIABLE dsyn     : INTEGER;
        VARIABLE pos      : INTEGER := (-1);
    BEGIN
        syndrome := (OTHERS => '0');
        FOR row IN syndrome'RANGE LOOP
            FOR col IN lin'RANGE LOOP
                syndrome(row) := (lin(col) AND CHECK_MATRIX(col, row)) XOR syndrome(row);
            END LOOP;
        END LOOP;

        dsyn      := to_integer(unsigned(to_stdlogicvector(syndrome)));
        err_exist := dsyn = 0;
        IF err_exist THEN
            find(val => dsyn, pos => err_pos);
        END IF;
    END PROCEDURE;

BEGIN

    PROCESS (clk)
        VARIABLE err_exist : BOOLEAN;
        VARIABLE err_pos   : INTEGER;

        VARIABLE col_vec : CODEWORD_LINE;
        VARIABLE row_vec : CODEWORD_LINE;

        VARIABLE code_tmp    : CODEWORD_MAT;
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
                            row_vec(index) := '1';
                            IF err_pos >= 0 THEN
                                code_tmp(index)(err_pos) := NOT code_tmp(index)(err_pos);
                            END IF;
                        ELSE
                            REPORT "[DEC(1/3)]: row=" & INTEGER'image(index) & " No error found";
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_MAT'length THEN
                            REPORT "[DEC] round 1/3";
                            index := 0;
                            stat <= R2;
                        END IF;

                    WHEN R2 =>
                        -- 列转行
                        FOR row IN CODEWORD_LINE'RANGE LOOP
                            column_temp(index) := code_tmp(row)(index);
                            line_decode(column_temp, err_exist, err_pos);
                        END LOOP;

                        IF err_exist THEN
                            REPORT "[DEC(1/3)]: col=" & INTEGER'image(index) & " err_pos=" & INTEGER'image(err_pos);
                            IF err_pos >= 0 THEN
                                code_tmp(err_pos)(index) := NOT code_tmp(err_pos)(index);
                                IF row_vec(err_pos) = '0' THEN
                                    col_vec(index) := '1';
                                END IF;
                            ELSE
                                col_vec(index) := '1';
                            END IF;
                        ELSE
                            REPORT "[DEC(1/3)]: col=" & INTEGER'image(index) & " No error found";
                        END IF;

                        index := index + 1;
                        IF index = CODEWORD_LINE'length THEN
                            REPORT "[DEC] round 2/3";
                            index := 0;
                            stat <= R3;
                        END IF;
                    WHEN R3 =>
                        line_decode(code_tmp(index), err_exist, err_pos);
                        IF err_exist THEN
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

                        IF index = CODEWORD_LINE'length THEN
                            REPORT "[DEC] round 3/3";
                            index := 0;
                            stat <= R3;
                        END IF;
                    WHEN RDY =>
                        ready <= '1';
                    WHEN OTHERS =>
                END CASE;
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE decoder;