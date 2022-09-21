LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;
USE work.decoder_types.ALL;

ENTITY decoder IS
    GENERIC (
        DECODER_TYPE : DecoderType := UNDEFINED
    );
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC
    );
END ENTITY decoder;

ARCHITECTURE DecoderSelect OF decoder IS
BEGIN

    decoder_gen : CASE DECODER_TYPE GENERATE
        WHEN UNDEFINED =>
            -- Generate nothing.
            ASSERT DECODER_TYPE = UNDEFINED REPORT "Nothing generated" SEVERITY failure;
        WHEN PMS2 =>
            inst : ENTITY work.decoder_pms2
                PORT MAP(
                    codeIn  => codeIn,
                    msg     => msg,
                    ready   => ready,
                    rst     => rst,
                    clk     => clk,
                    has_err => has_err
                );
        WHEN BAO3 =>
            inst : ENTITY work.decoder_bao3
                PORT MAP(
                    codeIn  => codeIn,
                    msg     => msg,
                    ready   => ready,
                    rst     => rst,
                    clk     => clk,
                    has_err => has_err
                );
    END GENERATE;

END ARCHITECTURE;