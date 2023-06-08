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
        col_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        col_err_site  : OUT CODEWORD_MAT
    );
END ENTITY;

ARCHITECTURE rtl OF ehpc_cr2 IS
    SIGNAL row_rdy         : STD_LOGIC;
    SIGNAL row_vec_wire    : STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE);
    SIGNAL row_registers   : CODEWORD_MAT;
    SIGNAL row_registers_t : CODEWORD_MAT;
BEGIN
    recOut <= row_registers;

    inst_row : ENTITY work.ehpc_cr2_phase_row
        PORT MAP(
            clk           => clk,
            reset         => reset,
            ready         => row_rdy,
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
            clk   => row_rdy,
            reset => reset,
            ready => ready,

            rec           => row_registers_t,
            row_vector    => row_vec_wire,
            col_vector    => col_vector,
            col_uncorrect => col_uncorrect,
            col_err_site  => col_err_site
        );
    row_vector <= row_vec_wire;
END ARCHITECTURE rtl;