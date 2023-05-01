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
    TYPE stat_t IS (COPY, CHK_CR1);
    SIGNAL stat          : stat_t := COPY;
    SIGNAL mem_code      : CODEWORD_MAT;
    SIGNAL row_vector    : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector    : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL col_err_pos   : int_array(codeIn'RANGE(1))  := (OTHERS => 0);
    SIGNAL chkcr1rdy     : STD_LOGIC                   := '0';
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            IF rst = '1' THEN
                msg   <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
                ready <= '0';
                stat  <= COPY;
            ELSE
                CASE stat IS
                    WHEN COPY =>
                        mem_code <= codeIn;
                        stat     <= CHK_CR1;
                    WHEN OTHERS =>
                END CASE;

            END IF;
        END IF;
    END PROCESS;

    ehpc_cr1_inst : ENTITY work.ehpc_cr1
        PORT MAP(
            clk           => clk,
            reset         => rst,
            rec           => mem_code,
            rdy           => chkcr1rdy,
            row_vector    => row_vector,
            col_vector    => col_vector,
            row_uncorrect => row_uncorrect,
            col_uncorrect => col_uncorrect
        );

END ARCHITECTURE rtl;