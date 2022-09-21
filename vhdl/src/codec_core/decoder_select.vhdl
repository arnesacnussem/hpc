LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;

ENTITY decoder_select IS
    GENERIC (
        decoder_type : INTEGER := 0
    );
    PORT (
        code    : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC
    );
END ENTITY decoder_select;

ARCHITECTURE DecoderSelect OF decoder_select IS
BEGIN

    decoder_select_inst : CASE decoder_type GENERATE
        WHEN 0      =>
        WHEN OTHERS =>
    END GENERATE;

END ARCHITECTURE;