LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;

PACKAGE utils IS
    FUNCTION bVecToString (row  : bit_vector) RETURN STRING;
END PACKAGE;

PACKAGE BODY utils IS
    FUNCTION bVecToString (row : bit_vector) RETURN STRING IS
        VARIABLE li                : STRING(0 TO row'length);
    BEGIN
        FOR i IN row'RANGE LOOP
            IF row(i) = '1' THEN
                li(i) := '1';
            ELSE
                li(i) := '0';
            END IF;
        END LOOP;
        RETURN li;
    END FUNCTION;
END PACKAGE BODY;