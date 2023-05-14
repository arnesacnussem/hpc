LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.decoder_utils.ALL;

ENTITY ehpc_flipper IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec           : IN CODEWORD_MAT;
        recOut        : OUT CODEWORD_MAT;
        row_vector    : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_vector    : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        row_uncorrect : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_uncorrect : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0')
    );
END ENTITY;

ARCHITECTURE rtl OF ehpc_flipper IS
    
BEGIN

    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                ready <= '0';
            ELSE
                
            END IF;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;