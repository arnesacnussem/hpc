LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;
USE work.ehpc_declare.ALL;

ENTITY dec_ehpc_top IS
    PORT (
        codeIn  : IN CODEWORD_MAT;      -- codeword matrix
        msg     : OUT MSG_MAT;          -- message matrix
        ready   : OUT STD_LOGIC := '0'; -- signal of work ready
        rst     : IN STD_LOGIC;         -- reset ready status and clock of work
        clk     : IN STD_LOGIC;         -- clock
        has_err : OUT STD_LOGIC := '0'
    );
END ENTITY;
ARCHITECTURE rtl OF dec_ehpc_top IS
    TYPE int_array IS ARRAY (NATURAL RANGE <>) OF INTEGER;

    SIGNAL state : ehpc_state_t := CHK_CR1;
    SIGNAL clock : ehpc_state_map(ehpc_state_t'left TO ehpc_state_t'right);
    SIGNAL rdy   : ehpc_state_map(ehpc_state_t'left TO ehpc_state_t'right);

    -- codeword links
    SIGNAL input_cr2   : CODEWORD_MAT;
    SIGNAL input_erase : CODEWORD_MAT;
    SIGNAL input_r3req : CODEWORD_MAT;

    SIGNAL output_erase      : CODEWORD_MAT;
    SIGNAL output_cr2        : CODEWORD_MAT;
    SIGNAL output_2r3c       : CODEWORD_MAT;
    SIGNAL output_r3req      : CODEWORD_MAT;
    SIGNAL output_transposer : CODEWORD_MAT;

    SIGNAL final_codeword : CODEWORD_MAT;

    SIGNAL sel_erase      : STD_LOGIC := '0';
    SIGNAL sel_cr2        : STD_LOGIC := '0';
    SIGNAL sel_r3req      : STD_LOGIC := '0';
    SIGNAL flag_transpose : STD_LOGIC := '0';

    SIGNAL col_err_site : CODEWORD_MAT;
    SIGNAL col_count    : NATURAL := 0;
    SIGNAL row_count    : NATURAL := 0;
    SIGNAL col_sum      : NATURAL := 0;
    SIGNAL row_sum      : NATURAL := 0;

    SIGNAL row_vector    : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector    : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');

    -- CHK_CR1
    SIGNAL row_vector_cr1    : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector_cr1    : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect_cr1 : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect_cr1 : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');

    -- CHK_CR2
    SIGNAL row_vector_cr2    : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector_cr2    : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect_cr2 : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect_cr2 : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');
BEGIN
    mux_clk : PROCESS (clk, state)
    BEGIN
        clock        <= (OTHERS => '0');
        clock(state) <= clk;
    END PROCESS;

    mux_vec : PROCESS (
        rdy,
        row_vector_cr1,
        col_vector_cr1,
        row_uncorrect_cr1,
        col_uncorrect_cr1,
        row_vector_cr2,
        col_vector_cr2,
        row_uncorrect_cr2,
        col_uncorrect_cr2
        )
    BEGIN
        IF rdy(CHK_CR2) = '1' THEN
            row_vector    <= row_vector_cr2;
            col_vector    <= col_vector_cr2;
            row_uncorrect <= row_uncorrect_cr2;
            col_uncorrect <= col_uncorrect_cr2;
        ELSIF rdy(CHK_CR1) = '1' THEN
            row_vector    <= row_vector_cr1;
            col_vector    <= col_vector_cr1;
            row_uncorrect <= row_uncorrect_cr1;
            col_uncorrect <= col_uncorrect_cr1;
        ELSE
            row_vector    <= (OTHERS => '0');
            col_vector    <= (OTHERS => '0');
            row_uncorrect <= (OTHERS => '0');
            col_uncorrect <= (OTHERS => '0');
        END IF;
    END PROCESS;

    ehpc_fsm_inst : ENTITY work.ehpc_fsm
        PORT MAP(
            clk            => clk,
            reset          => rst,
            ready          => ready,
            state          => state,
            rdy            => rdy,
            col_count      => col_count,
            row_count      => row_count,
            col_sum        => col_sum,
            row_sum        => row_sum,
            flag_transpose => flag_transpose,
            sel_cr2        => sel_cr2,
            sel_erase      => sel_erase,
            sel_r3req      => sel_r3req
        );

    cmpt_cr1 : ENTITY work.ehpc_cr1
        PORT MAP(
            clk   => clock(CHK_CR1),
            reset => rst,
            ready => rdy(CHK_CR1),

            rec           => codeIn,
            row_vector    => row_vector_cr1,
            col_vector    => col_vector_cr1,
            row_uncorrect => row_uncorrect_cr1,
            col_uncorrect => col_uncorrect_cr1
        );

    t_flag_1 : ENTITY work.bypassable_transposer
        GENERIC MAP(
            row_count => CODEWORD_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => codeIn,
            output => output_transposer,
            bypass => NOT flag_transpose
        );

    mux_erase_input : ENTITY work.mxio_mux
        PORT MAP(
            sel     => sel_erase,
            input_0 => output_transposer,
            input_1 => output_cr2,
            output  => input_erase
        );
    mux_cr2_input : ENTITY work.mxio_mux
        PORT MAP(
            sel     => sel_cr2,
            input_0 => output_transposer,
            input_1 => output_erase,
            output  => input_cr2
        );

    cmpt_erase : ENTITY work.ehpc_earse
        PORT MAP(
            clk   => clock(ERASE),
            reset => rst,
            ready => rdy(ERASE),

            rec        => input_erase,
            recOut     => output_erase,
            row_vector => row_vector,
            col_vector => col_vector
        );

    cmpt_vec_chk : ENTITY work.ehpc_vector_chk
        PORT MAP(
            row_vector    => row_vector,
            col_vector    => col_vector,
            row_uncorrect => row_uncorrect,
            col_uncorrect => col_uncorrect,

            col_count => col_count,
            row_count => row_count,
            col_sum   => col_sum,
            row_sum   => row_sum,

            clk   => clock(VEC_CHK),
            reset => rst,
            ready => rdy(VEC_CHK)
        );

    cmpt_cr2 : ENTITY work.ehpc_cr2
        PORT MAP(
            clk   => clock(CHK_CR2),
            reset => rst,
            ready => rdy(CHK_CR2),

            rec           => input_cr2,
            recOut        => output_cr2,
            row_vector    => row_vector_cr2,
            col_vector    => col_vector_cr2,
            row_uncorrect => row_uncorrect_cr2,
            col_uncorrect => col_uncorrect_cr2,
            col_err_site  => col_err_site
        );

    cmpt_2r3c : ENTITY work.ehpc_2r3c
        PORT MAP(
            clk   => clock(C2R3C),
            reset => rst,
            ready => rdy(C2R3C),

            rec           => output_cr2,
            recOut        => output_2r3c,
            col_uncorrect => col_uncorrect_cr2,
            col_err_site  => col_err_site
        );

    mux_r3req : ENTITY work.mxio_mux
        PORT MAP(
            sel     => sel_r3req,
            input_0 => output_erase,
            input_1 => output_2r3c,
            output  => input_r3req
        );

    cmpt_r3req : ENTITY work.ehcp_r3req
        PORT MAP(
            clk   => clock(R3REQ),
            reset => rst,
            ready => rdy(R3REQ),

            rec     => input_r3req,
            recOut  => output_r3req,
            has_err => has_err
        );
    t_flag_2 : ENTITY work.bypassable_transposer
        GENERIC MAP(
            row_count => CODEWORD_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => output_r3req,
            output => final_codeword,
            bypass => NOT flag_transpose
        );

    message_extractor_inst : ENTITY work.message_extractor
        PORT MAP(
            trigger => rdy(R3REQ),
            rec     => final_codeword,
            msg     => msg
        );

END ARCHITECTURE rtl;