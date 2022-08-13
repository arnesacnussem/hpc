LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;

ENTITY decoder IS
    PORT (
        code  : IN CODEWORD_MAT; -- codeword matrix
        msg   : OUT MSG_MAT;     -- message matrix
        ready : OUT STD_LOGIC;   -- signal of work ready
        rst   : IN STD_LOGIC;    -- reset ready status and clock of work
        clk   : IN STD_LOGIC     -- clock
    );
END ENTITY decoder;

ARCHITECTURE decoder OF decoder IS

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
        FOR col IN lin'RANGE LOOP
            FOR row IN syndrome'RANGE LOOP
                syndrome(col) := (lin(row) AND CHECK_MATRIX(row, col)) XOR syndrome(col);
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

        VARIABLE code_tmp    : CODEWORD_MAT := code;
        VARIABLE column_temp : CODEWORD_LINE;
    BEGIN

        REPORT "[DEC] round 1/3";
        dec_r1 : FOR row IN CODEWORD_MAT'RANGE LOOP
            line_decode(code_tmp(row), err_exist, err_pos);
            IF err_exist THEN
                REPORT "[DEC(1/3)]: row=" & INTEGER'image(row) & " err_pos=" & INTEGER'image(err_pos);
                row_vec(row) := '1';
                IF err_pos >= 0 THEN
                    code_tmp(row)(err_pos) := NOT code_tmp(row)(err_pos);
                END IF;
            ELSE
                REPORT "[DEC(1/3)]: row=" & INTEGER'image(row) & " No error found";
            END IF;
        END LOOP;

        REPORT "[DEC] round 2/3";
        dec_r2 : FOR col IN CODEWORD_LINE'RANGE LOOP
            -- 列转行
            FOR row IN CODEWORD_LINE'RANGE LOOP
                column_temp(row) := code_tmp(row)(col);
                line_decode(column_temp, err_exist, err_pos);
            END LOOP;

            IF err_exist THEN
                REPORT "[DEC(1/3)]: col=" & INTEGER'image(col) & " err_pos=" & INTEGER'image(err_pos);
                IF err_pos >= 0 THEN
                    code_tmp(err_pos)(col) := NOT code_tmp(err_pos)(col);
                    IF row_vec(err_pos) = '0' THEN
                        col_vec(col) := '1';
                    END IF;
                ELSE
                    col_vec(col) := '1';
                END IF;
            ELSE
                REPORT "[DEC(1/3)]: col=" & INTEGER'image(col) & " No error found";
            END IF;
        END LOOP;

        REPORT "[DEC] round 3/3";
        FOR row IN CODEWORD_LINE'RANGE LOOP
            line_decode(code_tmp(row), err_exist, err_pos);
            IF err_exist THEN
                IF err_pos >= 0 THEN
                    code_tmp(row)(err_pos) := NOT code_tmp(row)(err_pos);
                ELSE
                    FOR col IN CODEWORD_LINE'RANGE LOOP
                        IF col_vec(col) = '1' THEN
                            code_tmp(row)(col) := NOT code_tmp(row)(col);
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END LOOP;

        REPORT "[DEC] finish";
    END PROCESS;

END ARCHITECTURE decoder;