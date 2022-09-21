LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.config.ALL;
USE work.utils.ALL;

PACKAGE decoder_utils IS
    PROCEDURE find (
        VARIABLE val : IN INTEGER;
        VARIABLE pos : OUT INTEGER
    );
    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER -- err_pos大于等于0时表示该错误可纠正
    );
END PACKAGE;
PACKAGE BODY decoder_utils IS
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
                syndrome(row) := (lin(col) AND CHECK_MATRIX(col, row)) XOR syndrome(row);
            END LOOP;
        END LOOP;

        dsyn      := to_integer(unsigned(to_stdlogicvector(syndrome))); -- binary to decimal
        err_exist := dsyn /= 0;
        IF err_exist THEN
            REPORT "syndrome: " & MXIOROW_toString(MXIO_ROW(syndrome)) & " line: " & MXIOROW_toString(lin);
            find(val => dsyn, pos => err_pos);
        END IF;
    END PROCEDURE;
END PACKAGE BODY;