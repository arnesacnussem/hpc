LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.core_util.ALL;

PACKAGE decoder_utils IS
    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER -- err_pos大于等于0时表示该错误可纠正
    );
    FUNCTION find (synd_vec                     : STD_LOGIC_VECTOR) RETURN INTEGER;
    FUNCTION syndrome (lin                      : CODEWORD_LINE) RETURN STD_LOGIC_VECTOR;
    FUNCTION syndrome_to_flip_pattern (synd_vec : STD_LOGIC_VECTOR(0 TO CHECK_LENGTH)) RETURN CODEWORD_LINE;
    PROCEDURE line_decode_mask (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_mask  : OUT CODEWORD_LINE
    );
    CONSTANT synd_no_err : STD_LOGIC_VECTOR(0 TO CHECK_LENGTH) := (OTHERS => '0');
END PACKAGE;

PACKAGE BODY decoder_utils IS
    FUNCTION find (synd_vec : STD_LOGIC_VECTOR) RETURN INTEGER IS
        VARIABLE pos            : INTEGER := (-1);
    BEGIN
        FOR i IN CHECK_MATRIX_T'RANGE LOOP
            IF (CHECK_MATRIX_T(i) = synd_vec) THEN
                pos := i;
            END IF;
        END LOOP;
        RETURN pos;
    END FUNCTION;

    FUNCTION syndrome (lin : CODEWORD_LINE) RETURN STD_LOGIC_VECTOR IS
        VARIABLE synd_vec      : STD_LOGIC_VECTOR(0 TO CHECK_LENGTH);
    BEGIN
        synd_vec := (OTHERS => '0');
        FOR col IN lin'RANGE LOOP
            FOR row IN synd_vec'RANGE LOOP
                synd_vec(row) := (lin(col) AND CHECK_MATRIX_T(col)(row)) XOR synd_vec(row);
            END LOOP;
        END LOOP;

        RETURN synd_vec;
    END FUNCTION;

    FUNCTION syndrome_to_flip_pattern (synd_vec : STD_LOGIC_VECTOR(0 TO CHECK_LENGTH)) RETURN CODEWORD_LINE IS
        VARIABLE pattern                            : CODEWORD_LINE;

    BEGIN
        FOR i IN pattern'RANGE LOOP
            pattern(i) := and_reduce(synd_vec XOR (NOT CHECK_MATRIX_T(i)));
        END LOOP;
        RETURN pattern;
    END FUNCTION;

    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER
    ) IS
        VARIABLE synd_vec : STD_LOGIC_VECTOR(0 TO CHECK_LENGTH);
        VARIABLE pos      : INTEGER := (-1);
    BEGIN
        synd_vec  := syndrome(lin);
        err_exist := synd_vec /= synd_no_err;
        IF err_exist THEN
            err_pos := find(synd_vec);
        END IF;
    END PROCEDURE;
    PROCEDURE line_decode_mask (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_mask  : OUT CODEWORD_LINE
    ) IS
        VARIABLE synd_vec : STD_LOGIC_VECTOR(0 TO CHECK_LENGTH);
    BEGIN
        synd_vec  := syndrome(lin);
        err_exist := synd_vec /= synd_no_err;
        err_mask  := syndrome_to_flip_pattern(synd_vec);
    END PROCEDURE;
END PACKAGE BODY;