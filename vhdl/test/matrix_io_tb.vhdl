LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.test_values.ALL;
USE work.utils.ALL;

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
            matrix  : OUT MXIO_TYPE(0 TO COL_CNT - 1)(0 TO ROW_CNT - 1);
            clk     : IN STD_LOGIC;
            ready   : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Clock period
    CONSTANT clk_period : TIME := 5 ns;
    -- Generics
    CONSTANT COL_CNT  : NATURAL            := MESSAGE_MATRIX'length;
    CONSTANT ROW_CNT  : NATURAL            := MESSAGE_MATRIX(0)'length;
    CONSTANT IO_WIDTH : NATURAL            := 11;
    CONSTANT IO_MODE  : BIT_VECTOR(0 TO 1) := "01";

    -- Ports
    SIGNAL io_port     : BIT_VECTOR(0 TO IO_WIDTH - 1);
    SIGNAL matrix      : MXIO_TYPE(0 TO COL_CNT - 1)(0 TO ROW_CNT - 1);
    SIGNAL clk         : STD_LOGIC := '0';
    SIGNAL ready       : STD_LOGIC;
    SIGNAL input_ready : STD_LOGIC := '0';
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
        clk <= NOT clk;
        WAIT FOR clk_period/2;
        IF (IO_MODE = "00" AND input_ready = '1') OR (IO_MODE /= "00" AND ready = '1') THEN
            REPORT "END OF TEST";
            FOR i IN matrix'RANGE LOOP
                REPORT "matrix[" & INTEGER'image(i) & "]->" & bVecToString(bit_vector(matrix(i)));
            END LOOP;
            WAIT;
        END IF;
    END PROCESS clk_process;

    input_test : PROCESS (clk)
        VARIABLE pos : NATURAL := 0;
    BEGIN
        IF pos < MESSAGE_SERIAL'length THEN
            IF rising_edge(clk) THEN
                FOR i IN io_port'RANGE LOOP
                    io_port(i) <= MESSAGE_SERIAL(pos + i);
                END LOOP;
                REPORT "io_port[" & INTEGER'image(pos) & "]->" & bVecToString(io_port);
                pos := pos + IO_WIDTH;
            END IF;
        ELSE
            input_ready <= '1';
        END IF;
    END PROCESS;

END;