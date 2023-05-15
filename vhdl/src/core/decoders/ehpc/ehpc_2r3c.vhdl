LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.core_util.ALL;

ENTITY ehpc_2r3c IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec           : IN CODEWORD_MAT;
        recOut        : OUT CODEWORD_MAT;
        col_uncorrect : IN STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1));
        col_err_site  : IN CODEWORD_MAT

    );
END ENTITY ehpc_2r3c;
ARCHITECTURE rtl OF ehpc_2r3c IS
    SIGNAL rdy           : STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE) := (OTHERS => '0');
    SIGNAL post_es       : CODEWORD_MAT;
    SIGNAL err_mask      : CODEWORD_MAT;
    SIGNAL err_mark      : CODEWORD_LINE;
    SIGNAL post_row_corr : CODEWORD_MAT;

BEGIN
    error_site_handler : ENTITY work.ehpc_2r3c_es_handler
        PORT MAP(
            rec          => rec,
            recOut       => post_es,
            col_err_site => col_err_site
        );

    decode_inst : ENTITY work.record_to_error_mask
        GENERIC MAP(
            rotate_input  => false,
            rotate_output => false
        )
        PORT MAP(
            rec  => post_es,
            mask => err_mask,
            mark => err_mark
        );

    proc_2r3c_main : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        PROCESS (clk)
            VARIABLE correctable : BOOLEAN;
            VARIABLE temp_reg    : CODEWORD_LINE;
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    rdy(i)    <= '0';
                    recOut(i) <= (OTHERS => '0');
                ELSE
                    IF err_mark(i) = '1' THEN
                        IF NOT isAllSLVEqualToSIG(err_mask(i), '0') THEN
                            recOut(i) <= post_es(i) XOR err_mask(i);
                        ELSE
                            recOut(i) <= post_es(i) XOR col_uncorrect;
                        END IF;
                    ELSE
                        recOut(i) <= post_es(i);
                    END IF;
                    rdy(i) <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;

    state_check : PROCESS (rdy)
    BEGIN
        IF isAllSLVEqualTo(rdy, '1') THEN
            ready <= '1';
        ELSE
            ready <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;