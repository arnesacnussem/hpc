PACKAGE IO_PKG IS
    TYPE MATRIX_TYPE IS ARRAY(NATURAL RANGE <>, NATURAL RANGE <>) OF BIT;
END PACKAGE;
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.IO_PKG.ALL;
ENTITY matrix_io IS
    GENERIC (
        COL_CNT  : NATURAL;      -- 矩阵列数
        ROW_CNT  : NATURAL;      -- 矩阵行数
        IO_WIDTH : NATURAL := 1; -- 外部输入输出位宽

        -- IO模式(2bit)
        -- [0] 指定输入输出模式：0为输入（转为矩阵），1为输出（转自矩阵）
        -- [1] 为buffer开关
        -- [2] 输出是否时填充0
        IO_MODE : BIT_VECTOR(0 TO 2) := (OTHERS => '0')
    );
    PORT (
        io_port : IN BIT_VECTOR(0 TO IO_WIDTH - 1);
        matrix  : OUT MATRIX_TYPE(0 TO COL_CNT - 1, 0 TO ROW_CNT - 1);
        clk     : IN STD_LOGIC;
        -- 使用buffer时，完整处理一次矩阵后置高ready信号至下一个时钟信号
        -- 不适用Buffer时，ready始终为高电平
        ready : OUT STD_LOGIC
    );
END matrix_io;

ARCHITECTURE MATRIX_IO OF matrix_io IS
    PROCEDURE move_matrix_cursor (
        VARIABLE col, row   : IN NATURAL;
        VARIABLE colo, rowo : OUT NATURAL;
        VARIABLE rdy        : OUT BOOLEAN
    ) IS
        VARIABLE rdyx : BIT_VECTOR(0 TO 1);
    BEGIN
        IF row + 1 = ROW_CNT THEN
            rdyx(0) := '1';
            rowo    := 0;

            IF col + 1 = COL_CNT THEN
                rdyx(1) := '1';
                colo    := 0;
            ELSE
                colo := col + 1;
            END IF;

        ELSE
            rowo := row + 1;
        END IF;

        rdy := true WHEN rdyx = "11" ELSE false;
    END PROCEDURE;
BEGIN
    mode_select : CASE IO_MODE(0) GENERATE
        WHEN '0' =>
            input_buffer_mode : CASE IO_MODE(1) GENERATE
                WHEN '0' =>
                    -- input without a buffer
                    ready <= '1';
                    PROCESS (clk, io_port, matrix)
                        VARIABLE col : NATURAL := 0;
                        VARIABLE row : NATURAL := 0;
                        VARIABLE rdy : BOOLEAN;
                    BEGIN
                        IF rising_edge(clk) THEN
                            FOR i IN 0 TO IO_WIDTH - 1 LOOP
                                matrix(col, row) <= io_port(i);
                                move_matrix_cursor(col, row, col, row, rdy);
                                IF rdy THEN
                                    EXIT;
                                END IF;
                            END LOOP;
                        END IF;
                    END PROCESS;
                WHEN '1' =>
                    -- input with a buffer
                    ready <= '0';
                    PROCESS (clk, io_port, matrix)
                        VARIABLE col : NATURAL := 0;
                        VARIABLE row : NATURAL := 0;
                        VARIABLE rdy : BOOLEAN;
                        VARIABLE buf : MATRIX_TYPE(0 TO COL_CNT - 1, 0 TO ROW_CNT - 1);
                    BEGIN
                        IF rising_edge(clk) THEN
                            ready <= '0';
                            FOR i IN 0 TO IO_WIDTH - 1 LOOP
                                buf(col, row) := io_port(i);
                                move_matrix_cursor(col, row, col, row, rdy);

                                IF rdy THEN
                                    ready <= '1';
                                    EXIT;
                                END IF;
                            END LOOP;
                        END IF;
                    END PROCESS;
                WHEN OTHERS =>
            END GENERATE;
        WHEN '1' =>
            output_buffer_mode : CASE IO_MODE(1) GENERATE
                WHEN '0' =>
                    ready <= '1';
                WHEN '1'    =>
                WHEN OTHERS =>
            END GENERATE;
        WHEN OTHERS =>
    END GENERATE mode_select;
END ARCHITECTURE;