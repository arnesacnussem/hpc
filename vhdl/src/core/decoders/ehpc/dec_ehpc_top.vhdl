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
    TYPE stat_t IS (COPY, CHK_CR1, ERASE);
    SIGNAL stat         : stat_t                            := COPY;
    CONSTANT components : NATURAL                           := 2;
    SIGNAL clk_internal : STD_LOGIC_VECTOR(1 TO components) := (OTHERS => '0');
    SIGNAL rdy_internal : STD_LOGIC_VECTOR(1 TO components) := (OTHERS => '0');

    -- internal connections
    SIGNAL mem_code      : CODEWORD_MAT;
    SIGNAL link_erase      : CODEWORD_MAT;
    SIGNAL row_vector    : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_vector    : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL row_uncorrect : bit_vector(codeIn'RANGE)    := (OTHERS => '0');
    SIGNAL col_uncorrect : bit_vector(codeIn'RANGE(1)) := (OTHERS => '0');
    SIGNAL col_err_pos   : int_array(codeIn'RANGE(1))  := (OTHERS => 0);
BEGIN
    PROCESS (rdy_internal, rst, clk)
        VARIABLE col_count : INTEGER := 0;
        VARIABLE row_count : INTEGER := 0;
        VARIABLE col_sum   : INTEGER := 0;
        VARIABLE row_sum   : INTEGER := 0;

        FUNCTION sum_vec(vec1 : bit_vector; vec2 : bit_vector) RETURN INTEGER IS
            VARIABLE result : INTEGER := 0;
        BEGIN
            FOR i IN vec1'RANGE LOOP
                IF vec1(i) = '1' THEN
                    result := result + 1;
                END IF;
                IF vec2(i) = '1' THEN
                    result := result + 1;
                END IF;
            END LOOP;
            RETURN result; -- Return the sum of the corresponding elements
        END FUNCTION;

        PROCEDURE UpdateCountSum IS
        BEGIN
            col_count := 0;
            row_count := 0;
            FOR i IN col_vector'RANGE LOOP
                IF col_vector(i) = '1' THEN
                    col_count := col_count + 1;
                END IF;
            END LOOP;
            FOR i IN row_vector'RANGE LOOP
                IF row_vector(i) THEN
                    row_count := row_count + 1;
                END IF;
            END LOOP;
            col_sum := sum_vec(col_vector, col_uncorrect);
            row_sum := sum_vec(row_vector, row_uncorrect);
        END PROCEDURE;
    BEGIN
        IF rst = '1' THEN
            msg   <= (OTHERS => MXIO_ROW(ieee.numeric_bit.to_unsigned(0, msg(0)'length)));
            ready <= '0';
            stat  <= COPY;
        ELSE
            CASE stat IS
                WHEN COPY =>
                    mem_code <= codeIn;
                    stat     <= CHK_CR1;
                WHEN CHK_CR1 =>
                    clk_internal(1) <= clk;
                WHEN ERASE =>
                    clk_internal(2) <= clk;
                WHEN OTHERS =>
            END CASE;

        END IF;
    END PROCESS;

    ehpc_cr1_inst : ENTITY work.ehpc_cr1
        PORT MAP(
            enable           => clk_internal(1),
            reset         => rst,
            rec           => mem_code,
            rdy           => rdy_internal(1),
            row_vector    => row_vector,
            col_vector    => col_vector,
            row_uncorrect => row_uncorrect,
            col_uncorrect => col_uncorrect
        );

    ehpc_earse_inst : ENTITY work.ehpc_earse
        PORT MAP(
            enable     => clk_internal(2),
            reset      => rst,
            rec        => mem_code,
            recOut     => link_erase,
            row_vector => row_vector,
            col_vector => col_vector
        );
END ARCHITECTURE rtl;