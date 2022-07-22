-- generated from /workspaces/hpc/scripts/generate.js
library ieee;
USE work.types.ALL;
PACKAGE test_values IS
    CONSTANT MESSAGE_MATRIX : MSG_MAT := (
        0 => "0011",
    1 => "1010",
    2 => "0000",
    3 => "0010"
    );
    CONSTANT MESSAGE_SERIAL : MSG_SERIAL := "0011101000000010";
END PACKAGE test_values;
