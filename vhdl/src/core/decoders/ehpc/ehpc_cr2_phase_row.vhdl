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
    SIGNAL rdy         : STD_LOGIC_VECTOR(rec'RANGE) := (OTHERS => '0');
    SIGNAL registers   : CODEWORD_MAT;
    SIGNAL mask        : CODEWORD_MAT;
    SIGNAL mark        : CODEWORD_LINE;
    SIGNAL mask_reduce : CODEWORD_LINE;
BEGIN

    decode_inst : ENTITY work.record_to_error_mask
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
        proc_cr2_row : PROCESS (clk)
            VARIABLE code_line : CODEWORD_LINE;
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    rdy(i)           <= '0';
                    row_vector(i)    <= '0';
                    row_uncorrect(i) <= '0';
                ELSE
                    code_line := rec(i);
                    IF mark(i) = '1' THEN
                        row_vector(i) <= '1';
                        IF mask_reduce(i) = '1' THEN
                            code_line := rec(i) XOR mask(i);
                        ELSE
                            row_uncorrect(i) <= '1';
                        END IF;
                    END IF;
                    registers(i) <= code_line;
                    rdy(i)       <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;
    recOut              <= registers;
    state_check : ready <= and_reduce(rdy);
END ARCHITECTURE rtl;