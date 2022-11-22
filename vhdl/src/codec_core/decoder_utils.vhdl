LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.generated.ALL;
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
    PROCEDURE syndrome (
        VARIABLE lin  : IN CODEWORD_LINE;
        VARIABLE synd : OUT INTEGER
    );
    PROCEDURE extract_column (
        mat   : IN MXIO;
        index : IN INTEGER;
        col   : OUT MXIO_ROW
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

    PROCEDURE syndrome (
        VARIABLE lin  : IN CODEWORD_LINE;
        VARIABLE synd : OUT INTEGER
    ) IS
        VARIABLE synd_vec : BIT_VECTOR(0 TO CHECK_LENGTH);
    BEGIN
        synd_vec := (OTHERS => '0');
        FOR col IN lin'RANGE LOOP
            FOR row IN synd_vec'RANGE LOOP
                synd_vec(row) := (lin(col) AND CHECK_MATRIX_T(col, row)) XOR synd_vec(row);
            END LOOP;
        END LOOP;

        synd := to_integer(unsigned(to_stdlogicvector(synd_vec))); -- binary to decimal
    END PROCEDURE;

    PROCEDURE line_decode (
        VARIABLE lin       : IN CODEWORD_LINE;
        VARIABLE err_exist : OUT BOOLEAN;
        VARIABLE err_pos   : OUT INTEGER -- err_pos大于等于0时表示该错误可纠正
    ) IS
        VARIABLE dsyn : INTEGER;
        VARIABLE pos  : INTEGER := (-1);
    BEGIN
        syndrome(lin => lin, synd => dsyn);
        err_exist := dsyn /= 0;
        IF err_exist THEN
            find(val => dsyn, pos => err_pos);
        END IF;
    END PROCEDURE;
    PROCEDURE extract_column (
        mat   : IN MXIO;
        index : IN INTEGER;
        col   : OUT MXIO_ROW
    ) IS
    BEGIN
        -- 列转行
        FOR row IN mat'RANGE LOOP
            col(row) := mat(row)(index);
        END LOOP;
    END PROCEDURE;
END PACKAGE BODY;