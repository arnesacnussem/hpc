LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.core_util.ALL;
USE work.decoder_utils.ALL;

ENTITY ehpc_cr2_phase_row IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec           : IN CODEWORD_MAT;
        recOut        : OUT CODEWORD_MAT;
        row_vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0');
        row_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0')
    );
END ENTITY ehpc_cr2_phase_row;

ARCHITECTURE rtl OF ehpc_cr2_phase_row IS
    SIGNAL rdy       : STD_LOGIC_VECTOR(rec'RANGE) := (OTHERS => '0');
    SIGNAL registers : CODEWORD_MAT;
BEGIN
    cr2_gen : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        proc_cr2_row : PROCESS (clk)
            VARIABLE code_line   : CODEWORD_LINE;
            VARIABLE err_exist   : BOOLEAN;
            VARIABLE err_pattern : CODEWORD_LINE;
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    rdy(i)           <= '0';
                    row_vector(i)    <= '0';
                    row_uncorrect(i) <= '0';
                ELSE
                    code_line := rec(i);
                    line_decode_pattern(code_line, err_exist, err_pattern);
                    IF err_exist THEN
                        row_vector(i) <= '1';
                        IF isAllSLVEqualTo(err_pattern, '0') THEN -- un-correctable
                            row_uncorrect(i) <= '1';
                        ELSE
                            code_line := code_line XOR err_pattern;
                        END IF;
                    END IF;
                    registers(i) <= code_line;
                    rdy(i)       <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;
    recOut <= registers;
    state_check : PROCESS (rdy)
    BEGIN
        IF isAllSLVEqualTo(rdy, '1') THEN
            ready <= '1';
        ELSE
            ready <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;