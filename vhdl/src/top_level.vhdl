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
        SERIAL_CODE_RATIO : POSITIVE := CODEWORD_SERIAL'length;
        IN_BUFFER         : BIT      := '1';
        OUT_FILL          : BIT      := '0'
    );
    PORT (
        clk      : IN STD_LOGIC;
        msg_in   : IN BIT_VECTOR(0 TO MSG_SERIAL'length / SERIAL_MSG_RATIO - 1);
        code_out : OUT BIT_VECTOR(0 TO CODEWORD_SERIAL'length / SERIAL_CODE_RATIO - 1);
        code_in  : IN BIT_VECTOR(0 TO CODEWORD_SERIAL'length / SERIAL_CODE_RATIO - 1);
        msg_out  : OUT BIT_VECTOR(0 TO MSG_SERIAL'length / SERIAL_MSG_RATIO - 1);
        enc_rdy  : OUT STD_LOGIC;
        dec_rdy  : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF top_level IS
BEGIN
    enc_mxio_inst : ENTITY work.encoder_mxio
        GENERIC MAP(
            MSG_RATIO  => SERIAL_MSG_RATIO,
            CODE_RATIO => SERIAL_CODE_RATIO,
            IO_CONTROL => IN_BUFFER & OUT_FILL
        )
        PORT MAP(
            msg   => msg_in,
            code  => code_out,
            clk   => clk,
            ready => enc_rdy
        );

END ARCHITECTURE;