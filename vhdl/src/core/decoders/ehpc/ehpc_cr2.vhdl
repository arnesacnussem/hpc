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

ENTITY ehpc_cr2 IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec           : IN CODEWORD_MAT;
        recOut        : OUT CODEWORD_MAT;
        row_vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        row_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0')
    );
END ENTITY;

ARCHITECTURE rtl OF ehpc_cr2 IS
    TYPE state_t IS (DEC_ROW, DEC_COL, IDLE);

    SIGNAL state           : state_t                                := DEC_ROW;
    SIGNAL clock           : phase_map(PHASES'left TO PHASES'right) := (OTHERS => '0');
    SIGNAL rdy             : phase_map(PHASES'left TO PHASES'right) := (OTHERS => '0');
    SIGNAL row_vec_wire    : STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE);
    SIGNAL row_registers   : CODEWORD_MAT;
    SIGNAL row_registers_t : CODEWORD_MAT;
BEGIN
    fsm : PROCESS (state, clk)
        CONSTANT readySample : phase_map(PHASES'left TO PHASES'right) := (OTHERS => '1');
    BEGIN
        CASE state IS
            WHEN DEC_ROW =>
                clock(ROW)    <= clk;
                clock(COLUMN) <= '0';
            WHEN DEC_COL =>
                clock(ROW)    <= '0';
                clock(COLUMN) <= clk;
            WHEN IDLE        =>
                clock <= (OTHERS => '0');
        END CASE;

        IF rising_edge(clk) THEN
            IF reset = '1' THEN
                state <= DEC_ROW;
                ready <= '0';
            ELSE
                CASE state IS
                    WHEN DEC_ROW =>
                        ready <= '0';
                        IF rdy(ROW) = '1' THEN
                            state <= DEC_COL;
                        END IF;
                    WHEN DEC_COL =>
                        ready <= '0';
                        IF rdy(COLUMN) = '1' THEN
                            state <= IDLE;
                        END IF;
                    WHEN IDLE =>
                        ready <= '1';
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    recOut <= row_registers;

    inst_row : ENTITY work.ehpc_cr2_phase_row
        PORT MAP(
            clk           => clock(ROW),
            reset         => reset,
            ready         => rdy(ROW),
            rec           => rec,
            recOut        => row_registers,
            row_vector    => row_vec_wire,
            row_uncorrect => row_uncorrect
        );

    transposer_col : ENTITY work.mxio_transposer
        GENERIC MAP(
            row_count => CODEWORD_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => row_registers,
            output => row_registers_t
        );
    inst_col : ENTITY work.ehpc_cr2_phase_column
        PORT MAP(
            clk           => clock(COLUMN),
            reset         => reset,
            ready         => rdy(COLUMN),
            rec           => row_registers_t,
            row_vector    => row_vec_wire,
            col_vector    => col_vector,
            col_uncorrect => col_uncorrect
        );
    row_vector <= row_vec_wire;
END ARCHITECTURE rtl;