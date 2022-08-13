LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;

ENTITY encoder_mxio IS
    GENERIC (
        MSG_RATIO  : POSITIVE := MSG_SERIAL'length;
        CODE_RATIO : POSITIVE := CODEWORD_SERIAL'length;
        IO_MODE    : BIT_VECTOR(0 TO 1)
    );
    PORT (
        msg  : IN MSG_SERIAL;
        code : IN CODEWORD_SERIAL;
        clk  : IN STD_LOGIC
    );
END ENTITY;