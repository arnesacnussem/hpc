LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.generated.ALL;
USE work.mxio_util.ALL;

PACKAGE decoder_utils IS
    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER -- err_pos大于等于0时表示该错误可纠正
    );

    FUNCTION find (val : INTEGER) RETURN INTEGER;

    FUNCTION syndrome (lin : CODEWORD_LINE) RETURN INTEGER;
END PACKAGE;

PACKAGE BODY decoder_utils IS
    FUNCTION find (val : INTEGER) RETURN INTEGER IS
        VARIABLE pos       : INTEGER := (-1);
    BEGIN
        FOR i IN REF_TABLE'RANGE LOOP
            IF (REF_TABLE(i) = val) THEN
                pos := i;
            END IF;
        END LOOP;
        RETURN pos;
    END FUNCTION;

    FUNCTION syndrome (lin : CODEWORD_LINE) RETURN INTEGER IS
        VARIABLE synd_vec      : BIT_VECTOR(0 TO CHECK_LENGTH);
    BEGIN
        synd_vec := (OTHERS => '0');
        FOR col IN lin'RANGE LOOP
            FOR row IN synd_vec'RANGE LOOP
                synd_vec(row) := (lin(col) AND CHECK_MATRIX_T(col)(row)) XOR synd_vec(row);
            END LOOP;
        END LOOP;

        RETURN to_integer(unsigned(to_stdlogicvector(synd_vec)));
    END FUNCTION;

    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER -- err_pos大于等于0时表示该错误可纠正
    ) IS
        VARIABLE dsyn : INTEGER;
        VARIABLE pos  : INTEGER := (-1);
    BEGIN
        dsyn      := syndrome(lin);
        err_exist := dsyn /= 0;
        IF err_exist THEN
            err_pos := find(dsyn);
        END IF;
    END PROCEDURE;


END PACKAGE BODY;