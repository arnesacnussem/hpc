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
    SIGNAL rdy         : STD_LOGIC_VECTOR(rec'RANGE) := (OTHERS => '0');
    SIGNAL mask        : CODEWORD_MAT;
    SIGNAL mark        : CODEWORD_LINE;
    SIGNAL mask_reduce : CODEWORD_LINE;

BEGIN

    record_to_error_mask_inst : ENTITY work.record_to_error_mask
        GENERIC MAP(
            rotate_input  => false,
            rotate_output => false
        )
        PORT MAP(
            rec         => rec,
            mask        => mask,
            mark        => mark,
            mask_reduce => mask_reduce
        );

    cr2_gen : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        proc_cr2_col : PROCESS (clk)
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    rdy(i)           <= '0';
                    col_vector(i)    <= '0';
                    col_uncorrect(i) <= '0';
                ELSE
                    IF mark(i) = '1' THEN
                        col_vector(i) <= '1';
                        IF mask_reduce(i) = '1' THEN
                            col_uncorrect(i) <= or_reduce(row_vector AND (NOT mask(i)));
                        ELSE
                            col_uncorrect(i) <= '1';
                        END IF;
                    END IF;
                    rdy(i) <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;
    col_err_site        <= mask;
    state_check : ready <= and_reduce(rdy);
END ARCHITECTURE rtl;