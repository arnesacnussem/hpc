-- generated from /workspaces/hpc/scripts/generate.js
LIBRARY ieee;
USE work.types.ALL;
PACKAGE consts IS
    CONSTANT GENERATE_MATRIX : GEN_MAT := (
        0 => "1101000",
        1 => "0110100",
        2 => "1110010",
        3 => "1010001"
    );
    CONSTANT CHECK_MATRIX : CHK_MAT := (
        0 => "1001011",
        1 => "0101110",
        2 => "0010111"
    );
END PACKAGE consts;