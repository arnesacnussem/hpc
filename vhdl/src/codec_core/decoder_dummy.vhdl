LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.generated.ALL;
USE work.utils.ALL;
USE work.decoder_utils.ALL;

ENTITY decoder_dummy IS
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC
    );
END ENTITY decoder_dummy;

ARCHITECTURE decoder_dummy OF decoder_dummy IS
BEGIN
END ARCHITECTURE decoder_dummy;