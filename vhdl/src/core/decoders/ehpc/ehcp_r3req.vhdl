LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.core_util.ALL;

ENTITY ehcp_r3req IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec     : IN CODEWORD_MAT;
        recOut  : OUT CODEWORD_MAT;
        has_err : OUT STD_LOGIC := '0'
    );
END ENTITY;

ARCHITECTURE rtl OF ehcp_r3req IS
    TYPE state_t IS (phase1, phase2, phase_end);
    SIGNAL state         : state_t := phase1;
    SIGNAL rec_internal  : CODEWORD_MAT;
    SIGNAL req           : CODEWORD_LINE := (OTHERS => '0');
    SIGNAL err_mask      : CODEWORD_MAT;
    SIGNAL err_mark      : CODEWORD_LINE;
    SIGNAL mask_reduce   : CODEWORD_LINE;
    SIGNAL post_row_chk  : CODEWORD_MAT;
    SIGNAL row_chk_ready : CODEWORD_LINE := (OTHERS => '0');
BEGIN
    mux : PROCESS (row_chk_ready, post_row_chk, rec)
    BEGIN
        IF and_reduce(row_chk_ready) = '1' THEN
            rec_internal <= post_row_chk;
        ELSE
            rec_internal <= rec;
        END IF;
    END PROCESS;

    decode_inst : ENTITY work.record_to_error_mask
        GENERIC MAP(
            rotate_input  => false,
            rotate_output => false
        )
        PORT MAP(
            rec         => rec_internal,
            mask        => err_mask,
            mark        => err_mark,
            mask_reduce => mask_reduce
        );

    row_chk : FOR i IN 0 TO CODEWORD_LENGTH GENERATE
        proc_row_chk : PROCESS (clk)
        BEGIN
            IF rising_edge(clk) THEN
                IF reset = '1' THEN
                    post_row_chk(i)  <= (OTHERS => '0');
                    row_chk_ready(i) <= '0';
                    req(i)           <= '0';
                ELSE
                    IF err_mark(i) = '1' AND mask_reduce(i) = '0' THEN
                        req(i) <= '1';
                    END IF;
                    post_row_chk(i)  <= rec(i) XOR err_mask(i);
                    row_chk_ready(i) <= '1';
                END IF;
            END IF;
        END PROCESS;
    END GENERATE;

    if_no_req   : has_err <= and_reduce(req) OR or_reduce(err_mark);
    state_check : ready   <= and_reduce(row_chk_ready);
    recOut                <= post_row_chk;
END ARCHITECTURE rtl;