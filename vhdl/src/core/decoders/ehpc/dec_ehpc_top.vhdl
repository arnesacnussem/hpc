LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.mxio_util.ALL;

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
    TYPE state_t IS (COPY, CHK_CR1, ERASE, VEC_CHK, CHK_CR2, VEC_RST);
    TYPE state_map IS ARRAY(state_t RANGE <>) OF STD_LOGIC;
    SIGNAL state : state_t := COPY;
    SIGNAL clock : state_map(state_t'left TO state_t'right);
    SIGNAL reset : state_map(state_t'left TO state_t'right);
    SIGNAL rdy   : state_map(state_t'left TO state_t'right);

    -- FSM control
    CONSTANT components : NATURAL := 10;

    -- internal connections
    SIGNAL link_erase   : CODEWORD_MAT;
    SIGNAL link_chk_cr2 : CODEWORD_MAT;
    SIGNAL bus_codeword : CODEWORD_MAT;

    SIGNAL row_vector    : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector    : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect : STD_LOGIC_VECTOR(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect : STD_LOGIC_VECTOR(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL col_err_pos   : int_array(codeIn'RANGE(1))  := (OTHERS => 0);
    SIGNAL col_count     : NATURAL                     := 0;
    SIGNAL row_count     : NATURAL                     := 0;
    SIGNAL col_sum       : NATURAL                     := 0;
    SIGNAL row_sum       : NATURAL                     := 0;

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

    -- this process also act as the memory controller
    ehpc_fsm : PROCESS (clk)
        IMPURE FUNCTION componentReady RETURN BOOLEAN IS
        BEGIN
            RETURN rdy(state) = '1';
        END FUNCTION;
    BEGIN
        IF rising_edge(clk) THEN
            CASE state IS
                WHEN COPY =>
                    bus_codeword <= codeIn;
                    state        <= CHK_CR1;
                WHEN CHK_CR1 =>
                    IF componentReady THEN

                    END IF;
                WHEN CHK_CR2 =>
                WHEN VEC_CHK =>
                WHEN ERASE   =>
                WHEN OTHERS  =>
            END CASE;
        END IF;
    END PROCESS;

    -- mux_codeword : PROCESS (state)
    -- BEGIN
    --     CASE state IS
    --         WHEN COPY    =>
    --         WHEN CHK_CR1 =>
    --             bus_codeword <= codeIn;
    --         WHEN OTHERS =>
    --     END CASE;
    -- END PROCESS;

    mux_clk : PROCESS (clk, state)
    BEGIN
        clock        <= (OTHERS => '0');
        clock(state) <= clk;
    END PROCESS;

    mux_vec : PROCESS (
        state,
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
        CASE state IS

            WHEN CHK_CR1 =>
                row_vector    <= row_vector_cr1;
                col_vector    <= col_vector_cr1;
                row_uncorrect <= row_uncorrect_cr1;
                col_uncorrect <= col_uncorrect_cr1;

            WHEN CHK_CR2 =>
                row_vector    <= row_vector_cr2;
                col_vector    <= col_vector_cr2;
                row_uncorrect <= row_uncorrect_cr2;
                col_uncorrect <= col_uncorrect_cr2;

            WHEN OTHERS              =>
                row_vector    <= (OTHERS => '0');
                col_vector    <= (OTHERS => '0');
                row_uncorrect <= (OTHERS => '0');
                col_uncorrect <= (OTHERS => '0');
        END CASE;
    END PROCESS;

    ehpc_cr1_inst : ENTITY work.ehpc_cr1
        PORT MAP(
            clk   => clock(CHK_CR1),
            reset => reset(CHK_CR1),
            ready => rdy(CHK_CR1),

            rec           => bus_codeword,
            row_vector    => row_vector_cr1,
            col_vector    => col_vector_cr1,
            row_uncorrect => row_uncorrect_cr1,
            col_uncorrect => col_uncorrect_cr1
        );

    ehpc_earse_inst : ENTITY work.ehpc_earse
        PORT MAP(
            clk   => clock(ERASE),
            reset => reset(ERASE),
            ready => rdy(ERASE),

            rec        => bus_codeword,
            recOut     => link_erase,
            row_vector => row_vector,
            col_vector => col_vector
        );

    ehpc_vector_chk_inst : ENTITY work.ehpc_vector_chk
        PORT MAP(
            row_vector    => row_vector,
            col_vector    => col_vector,
            row_uncorrect => row_uncorrect,
            col_uncorrect => col_uncorrect,
            col_count     => col_count,
            row_count     => row_count,
            col_sum       => col_sum,
            row_sum       => row_sum,

            clk   => clock(VEC_CHK),
            reset => reset(VEC_CHK),
            ready => rdy(VEC_CHK)
        );

    ehpc_cr2_inst : ENTITY work.ehpc_cr2
        PORT MAP(
            clk   => clock(CHK_CR2),
            reset => reset(CHK_CR2),
            ready => rdy(CHK_CR2),

            rec           => bus_codeword,
            recOut        => link_chk_cr2,
            row_vector    => row_vector_cr2,
            col_vector    => col_vector_cr2,
            row_uncorrect => row_uncorrect_cr2,
            col_uncorrect => col_uncorrect_cr2
        );
END ARCHITECTURE rtl;