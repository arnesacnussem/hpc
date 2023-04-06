LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.generated.ALL;

PACKAGE mxio_util IS
    FUNCTION bitToChar(b            : BIT) RETURN CHARACTER;
    FUNCTION MXIOROW_toString (bVec : MXIO_ROW) RETURN STRING;
    FUNCTION MXIO_toString (mx      : MXIO) RETURN STRING;

    FUNCTION getColumn (
        mat   : MXIO;
        index : INTEGER
    ) RETURN MXIO_ROW;

    TYPE IOMode IS (INPUT, OUTPUT);
END PACKAGE;

PACKAGE BODY mxio_util IS

    FUNCTION bitToChar(b : BIT) RETURN CHARACTER IS
    BEGIN
        IF b = '1' THEN
            RETURN '1';
        ELSE
            RETURN '0';
        END IF;
    END FUNCTION;

    FUNCTION MXIOROW_toString (bVec : MXIO_ROW) RETURN STRING IS
        VARIABLE li                     : STRING(0 TO bVec'length * 2);
    BEGIN
        FOR i IN bVec'RANGE LOOP
            li(i * 2 TO i * 2 + 1) := bitToChar(bVec(i)) & ' ';
        END LOOP;
        RETURN li;
    END FUNCTION;

    FUNCTION MXIO_toString (mx : MXIO) RETURN STRING IS
        -- length: col*row + row*8 +2
        -- line length: col + 8 => 3 line num, 1 LF
        VARIABLE li : STRING(0 TO (mx'length * (mx(0)'length * 2 + 2))) := (OTHERS => NUL);

        -- LF is 2 char =_=
        CONSTANT len   : NATURAL := mx(0)'length * 2 + 2;
        VARIABLE index : NATURAL := 0;
    BEGIN
        FOR row IN mx'RANGE LOOP
            li(row * len TO (row + 1) * len - 1) := MXIOROW_toString(mx(row)) & LF;
            index                                := index + len + 1;
        END LOOP;
        RETURN li;
    END FUNCTION;

    FUNCTION getColumn (
        mat   : MXIO;
        index : INTEGER
    ) RETURN MXIO_ROW IS
        VARIABLE col : MXIO_ROW(mat(0)'RANGE);
    BEGIN
        -- 列转行
        FOR row IN mat'RANGE LOOP
            col(row) := mat(row)(index);
        END LOOP;
        RETURN col;
    END FUNCTION;
END PACKAGE BODY;