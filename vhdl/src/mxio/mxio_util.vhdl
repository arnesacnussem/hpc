LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;
USE work.constants.ALL;

PACKAGE mxio_util IS
    FUNCTION bitToChar(b                 : BIT) RETURN CHARACTER;
    FUNCTION MXIO_toString (input_mxio   : MXIO) RETURN STRING;
    FUNCTION MXIO_toHexString(input_mxio : MXIO) RETURN STRING;

    FUNCTION getColumn (
        mat   : MXIO;
        index : INTEGER
    ) RETURN MXIO_ROW;

    TYPE IOMode IS (INPUT, OUTPUT);
    PROCEDURE TransposeInPositionVAR(mat        : INOUT MXIO);
    PROCEDURE TransposeInPositionSIG(SIGNAL mat : INOUT MXIO);
    PROCEDURE CopyMXIO(a : IN MXIO; b : OUT MXIO);
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

    FUNCTION MXIO_toString(input_mxio : MXIO) RETURN STRING IS
        VARIABLE result                   : STRING(1 TO input_mxio'length * (input_mxio(1)'length + 1));
        VARIABLE index                    : NATURAL := 1;
    BEGIN
        FOR i IN input_mxio'RANGE LOOP
            FOR j IN input_mxio(i)'RANGE LOOP
                result(index) := bitToChar(input_mxio(i)(j));
                index         := index + 1;
            END LOOP;
            result(index) := CHARACTER'val(10); -- add line feed
            index         := index + 1;
        END LOOP;
        RETURN result(1 TO index - 1);
    END MXIO_toString;

    FUNCTION halfByteToChar(input_val : IN bit_vector(0 TO 3)) RETURN CHARACTER IS
    BEGIN
        CASE input_val IS
            WHEN "0000" => RETURN '0';
            WHEN "0001" => RETURN '1';
            WHEN "0010" => RETURN '2';
            WHEN "0011" => RETURN '3';
            WHEN "0100" => RETURN '4';
            WHEN "0101" => RETURN '5';
            WHEN "0110" => RETURN '6';
            WHEN "0111" => RETURN '7';
            WHEN "1000" => RETURN '8';
            WHEN "1001" => RETURN '9';
            WHEN "1010" => RETURN 'A';
            WHEN "1011" => RETURN 'B';
            WHEN "1100" => RETURN 'C';
            WHEN "1101" => RETURN 'D';
            WHEN "1110" => RETURN 'E';
            WHEN "1111" => RETURN 'F';
        END CASE;
    END halfByteToChar;

    FUNCTION mxio_row_to_hex(val : IN MXIO_ROW) RETURN STRING IS
        CONSTANT length              : INTEGER := ((val'length + 3) / 4) * 4;
        VARIABLE result              : STRING(1 TO length/4);
        VARIABLE padded              : BIT_VECTOR(0 TO length - 1) := (OTHERS => '0');
    BEGIN
        -- Copy the input value into the end of the padded
        padded(length - val'length TO length - 1) := val(val'RANGE);
        FOR i IN result'RANGE LOOP
            result(i) := halfByteToChar(padded((i - 1) * 4 TO i * 4 - 1));

        END LOOP;
        RETURN result;
    END;

    FUNCTION MXIO_toHexString(input_mxio : MXIO) RETURN STRING IS
        CONSTANT row_length                  : INTEGER := 1 + (input_mxio'length(1) + 3) / 4;
        CONSTANT str_length                  : INTEGER := row_length * input_mxio'length;
        VARIABLE result                      : STRING(1 TO str_length);
        VARIABLE row                         : STRING(1 TO row_length);
    BEGIN
        FOR i IN input_mxio'RANGE LOOP
            result(i * row_length + 1 TO (i + 1) * row_length) := mxio_row_to_hex(input_mxio(i)) & ' ';
        END LOOP;
        RETURN result;
    END MXIO_toHexString;

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
    PROCEDURE TransposeInPositionVAR(mat : INOUT MXIO) IS
        VARIABLE temp_bit                    : BIT;
    BEGIN
        FOR i IN 0 TO mat'length - 1 LOOP
            FOR j IN i + 1 TO mat'length(1) - 1 LOOP
                -- Swap elements (i, j) and (j, i)
                FOR k IN 0 TO 6 LOOP
                    temp_bit  := mat(i)(k);
                    mat(i)(k) := mat(j)(k);
                    mat(j)(k) := temp_bit;
                END LOOP;
                FOR k IN 0 TO 6 LOOP
                    temp_bit  := mat(k)(i);
                    mat(k)(i) := mat(k)(j);
                    mat(k)(j) := temp_bit;
                END LOOP;
            END LOOP;
        END LOOP;
    END TransposeInPositionVAR;
    PROCEDURE TransposeInPositionSIG(SIGNAL mat : INOUT MXIO) IS
        VARIABLE temp_bit                           : BIT;
    BEGIN
        FOR i IN 0 TO mat'length - 1 LOOP
            FOR j IN i + 1 TO mat'length(1) - 1 LOOP
                -- Swap elements (i, j) and (j, i)
                FOR k IN 0 TO 6 LOOP
                    temp_bit := mat(i)(k);
                    mat(i)(k) <= mat(j)(k);
                    mat(j)(k) <= temp_bit;
                END LOOP;
                FOR k IN 0 TO 6 LOOP
                    temp_bit := mat(k)(i);
                    mat(k)(i) <= mat(k)(j);
                    mat(k)(j) <= temp_bit;
                END LOOP;
            END LOOP;
        END LOOP;
    END TransposeInPositionSIG;

    PROCEDURE CopyMXIO(a : IN MXIO; b : OUT MXIO) IS
    BEGIN
        FOR i IN a'RANGE LOOP
            FOR j IN a(i)'RANGE LOOP
                b(i)(j) := a(i)(j);
            END LOOP;
        END LOOP;
    END CopyMXIO;
END PACKAGE BODY;