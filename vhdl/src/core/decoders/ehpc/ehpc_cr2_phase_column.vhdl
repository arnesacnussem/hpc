LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.core_util.ALL;
USE work.decoder_utils.ALL;
USE work.decoder_types.ALL;
USE work.ehpc_declare.ALL;

ENTITY ehpc_cr2_phase_column IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec           : IN CODEWORD_MAT;
        row_vector    : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)  := (OTHERS => '0');
        col_vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0');
        col_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0');
        col_err_site  : OUT CODEWORD_MAT
    );
END ENTITY;

ARCHITECTURE rtl OF ehpc_cr2_phase_column IS
    SIGNAL rdy      : STD_LOGIC_VECTOR(rec'RANGE) := (OTHERS => '0');
    SIGNAL err_mask : CODEWORD_MAT                := (OTHERS => (OTHERS => '0'));
BEGIN
    cr2_gen : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        proc_cr2_col : PROCESS (clk)
            VARIABLE code_line    : CODEWORD_LINE;
            VARIABLE err_exist    : BOOLEAN;
            VARIABLE err_mask_reg : CODEWORD_LINE;
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    rdy(i)           <= '0';
                    col_vector(i)    <= '0';
                    col_uncorrect(i) <= '0';
                    err_mask(i)      <= (OTHERS => '0');
                ELSE
                    code_line := rec(i);
                    line_decode_mask(code_line, err_exist, err_mask_reg);
                    IF err_exist THEN
                        col_vector(i) <= '1';
                        IF isAllSLVEqualTo(err_mask_reg, '0') THEN
                            col_uncorrect(i) <= '1';
                        ELSE
                            IF isAllSLVEqualTo(row_vector AND (NOT err_mask_reg), '0') THEN
                                col_uncorrect(i) <= '0';
                            ELSE
                                col_uncorrect(i) <= '1';
                            END IF;
                        END IF;
                    END IF;
                    err_mask(i) <= err_mask_reg;
                    rdy(i)      <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;
    col_err_site <= err_mask;
    state_check : PROCESS (rdy)
    BEGIN
        IF isAllSLVEqualTo(rdy, '1') THEN
            ready <= '1';
        ELSE
            ready <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;