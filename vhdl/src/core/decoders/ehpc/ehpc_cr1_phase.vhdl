LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.decoder_utils.ALL;
USE work.core_util.ALL;

ENTITY ehpc_cr1_phase IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec       : IN CODEWORD_MAT;
        vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0');
        uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0')
    );
END ENTITY ehpc_cr1_phase;

ARCHITECTURE rtl OF ehpc_cr1_phase IS
    SIGNAL rdy  : STD_LOGIC_VECTOR(rec'RANGE) := (OTHERS => '0');
    SIGNAL mask : CODEWORD_MAT;
    SIGNAL mark : CODEWORD_LINE;
BEGIN
    state_check : ready <= and_reduce(rdy);

    decode_inst : ENTITY work.record_to_error_mask
        GENERIC MAP(
            rotate_input  => false,
            rotate_output => false
        )
        PORT MAP(
            rec  => rec,
            mask => mask,
            mark => mark
        );

    cr1_gen : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        proc_row : PROCESS (clk)
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    rdy(i)       <= '0';
                    vector(i)    <= '0';
                    uncorrect(i) <= '0';
                ELSE
                    IF mark(i) = '1' THEN
                        vector(i)    <= '1';
                        uncorrect(i) <= NOT or_reduce(mask(i));
                    ELSE
                        vector(i)    <= '0';
                        uncorrect(i) <= '0';
                    END IF;
                    rdy(i) <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;
END ARCHITECTURE rtl;