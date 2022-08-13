LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;

ENTITY top_level IS
    GENERIC (
        -- 串行输入输出位宽比例
        -- 将被矩阵总长度整除
        -- 默认：位宽为1
        SERIAL_MSG_RATIO  : POSITIVE := MSG_SERIAL'length;
        SERIAL_CODE_RATIO : POSITIVE := CODEWORD_SERIAL'length
    );
    PORT (
        clk      : IN STD_LOGIC;
        msg_in   : IN BIT_VECTOR(0 TO MSG_SERIAL'length / SERIAL_MSG_RATIO);
        msg_out  : OUT BIT_VECTOR(0 TO MSG_SERIAL'length / SERIAL_MSG_RATIO);
        code_in  : IN BIT_VECTOR(0 TO CODEWORD_SERIAL'length / SERIAL_CODE_RATIO);
        code_out : OUT BIT_VECTOR(0 TO CODEWORD_SERIAL'length / SERIAL_CODE_RATIO)
    );
END ENTITY;

ARCHITECTURE rtl OF top_level IS
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
    COMPONENT encoder
        PORT (
            msg     : IN MSG_MAT;
            encoded : OUT CODEWORD_MAT;
            ready   : OUT STD_LOGIC;
            rst     : IN STD_LOGIC;
            clk     : IN STD_LOGIC
        );
    END COMPONENT;
    COMPONENT decoder
        PORT (
            code  : IN CODEWORD_MAT;
            msg   : OUT MSG_MAT;
            ready : OUT STD_LOGIC;
            rst   : IN STD_LOGIC;
            clk   : IN STD_LOGIC
        );
    END COMPONENT;

BEGIN

END ARCHITECTURE;