LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.core_util.ALL;

ENTITY ehpc_cr1 IS
    PORT (
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ready : OUT STD_LOGIC;

        rec           : IN CODEWORD_MAT;
        row_vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_vector    : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0');
        row_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE)    := (OTHERS => '0');
        col_uncorrect : OUT STD_LOGIC_VECTOR(CODEWORD_MAT'RANGE(1)) := (OTHERS => '0')
    );
END ENTITY;

ARCHITECTURE rtl OF ehpc_cr1 IS
    SIGNAL rdy   : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL rec_t : CODEWORD_MAT;
BEGIN

    inst_row : ENTITY work.ehpc_cr1_phase
        PORT MAP(
            clk       => clk,
            reset     => reset,
            ready     => rdy(0),
            rec       => rec,
            vector    => row_vector,
            uncorrect => row_uncorrect
        );

    transposer : ENTITY work.mxio_transposer
        GENERIC MAP(
            row_count => CODEWORD_LENGTH,
            col_count => CODEWORD_LENGTH
        )
        PORT MAP(
            input  => rec,
            output => rec_t
        );

    inst_col : ENTITY work.ehpc_cr1_phase
        PORT MAP(
            clk       => clk,
            reset     => reset,
            ready     => rdy(1),
            rec       => rec_t,
            vector    => col_vector,
            uncorrect => col_uncorrect
        );

    state_check : ready <= rdy(0) AND rdy(1);
END ARCHITECTURE rtl;