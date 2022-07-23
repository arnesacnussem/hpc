-- generated from /workspaces/hpc/scripts/generate.js
LIBRARY ieee;
USE work.types.ALL;
PACKAGE config IS
    CONSTANT CHANNEL_ERROR_RATE : INTEGER := 3;
    -- MSG_LENGTH(k) = 11
    CONSTANT MSG_LENGTH : INTEGER := 10;

    -- CODEWORD_LENGTH(n) = 11
    CONSTANT CODEWORD_LENGTH : INTEGER := 14;

    -- CHECK_BITS = 4
    CONSTANT CHEKC_BITS      : INTEGER := 3;
    CONSTANT GENERATE_MATRIX : GEN_MAT := (
        0  => "110010000000000",
        1  => "011001000000000",
        2  => "001100100000000",
        3  => "110100010000000",
        4  => "101000001000000",
        5  => "010100000100000",
        6  => "111000000010000",
        7  => "011100000001000",
        8  => "111100000000100",
        9  => "101100000000010",
        10 => "100100000000001"
    );
    CONSTANT CHECK_MATRIX : CHK_MAT := (
        0 => "100010011010111",
        1 => "010011010111100",
        2 => "001001101011110",
        3 => "000100110101111"
    );
END PACKAGE config;