LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;

ENTITY decoder_mxio IS
    GENERIC (
        MSG_RATIO  : POSITIVE := MSG_SERIAL'length;
        CODE_RATIO : POSITIVE := CODEWORD_SERIAL'length;
        -- [0]: 输入缓存
        -- [1]: 输出填充
        IO_CONTROL : BIT_VECTOR(0 TO 1) := "10"
    );
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;

    );
END ENTITY;