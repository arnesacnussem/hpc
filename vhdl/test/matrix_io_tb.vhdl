LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.test_values.ALL;

ENTITY matrix_io_tb IS
END;

ARCHITECTURE bench OF matrix_io_tb IS

    COMPONENT matrix_io
        GENERIC (
            COL_CNT  : NATURAL;
            ROW_CNT  : NATURAL;
            IO_WIDTH : NATURAL;
            IO_MODE  : BIT_VECTOR(0 TO 1)
        );
        PORT (
            io_port : INOUT BIT_VECTOR(0 TO IO_WIDTH - 1);
            matrix  : OUT MATRIX_TYPE(0 TO COL_CNT - 1, 0 TO ROW_CNT - 1);
            clk     : IN STD_LOGIC;
            ready   : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Clock period
    CONSTANT clk_period : TIME := 5 ns;
    -- Generics
    CONSTANT COL_CNT  : NATURAL            := 11;
    CONSTANT ROW_CNT  : NATURAL            := 11;
    CONSTANT IO_WIDTH : NATURAL            := 1;
    CONSTANT IO_MODE  : BIT_VECTOR(0 TO 1) := "01";

    -- Ports
    SIGNAL io_port : BIT_VECTOR(0 TO IO_WIDTH - 1);
    SIGNAL matrix  : MATRIX_TYPE(0 TO COL_CNT - 1, 0 TO ROW_CNT - 1);
    SIGNAL clk     : STD_LOGIC;
    SIGNAL ready   : STD_LOGIC;

BEGIN

    matrix_io_inst : matrix_io
    GENERIC MAP(
        COL_CNT  => COL_CNT,
        ROW_CNT  => ROW_CNT,
        IO_WIDTH => IO_WIDTH,
        IO_MODE  => IO_MODE
    )
    PORT MAP(
        io_port => io_port,
        matrix  => matrix,
        clk     => clk,
        ready   => ready
    );

    clk_process : PROCESS
    BEGIN
        clk <= '1';
        WAIT FOR clk_period/2;
        clk <= '0';
        WAIT FOR clk_period/2;
        IF ready = '1' THEN
            WAIT;
        END IF;
    END PROCESS clk_process;

    input_test : PROCESS (clk)
        VARIABLE pos  : NATURAL := 0;
        VARIABLE pos2 : NATURAL := 0;
        VARIABLE tmp  : BIT_VECTOR(0 TO IO_WIDTH - 1);
    BEGIN
        IF pos < MESSAGE_SERIAL'length THEN
            IF rising_edge(clk) THEN
                FOR i IN io_port'RANGE LOOP
                    io_port(i) <= MESSAGE_SERIAL(pos + i);
                END LOOP;
                pos := pos + IO_WIDTH;
            END IF;
        END IF;
    END PROCESS;

END;