-- generated from /workspaces/hpc/scripts/generate.js
library ieee;
USE work.types.ALL;
PACKAGE test_values IS
    CONSTANT MESSAGE_MATRIX : MSG_MAT := (
        0 => "0000",
    1 => "0000",
    2 => "0101",
    3 => "1101"
    );
    CONSTANT MESSAGE_SERIAL : MSG_SERIAL := "0000000001011101";
END PACKAGE test_values;
