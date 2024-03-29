LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.decoder_types.ALL;

ENTITY top_level IS
    GENERIC (
        -- 串行输入输出位宽比例
        -- 将被矩阵总长度整除
        -- 默认：位宽为1
        SERIAL_MSG_RATIO  : POSITIVE    := MSG_SERIAL'length;
        SERIAL_CODE_RATIO : POSITIVE    := CODEWORD_SERIAL'length;
        IN_BUFFER         : STD_LOGIC         := '1';
        OUT_FILL          : STD_LOGIC         := '0';
        DECODER_TYPE      : DecoderType := DUMMY
    );
    PORT (
        clk      : IN STD_LOGIC := '0';
        dec_en   : IN STD_LOGIC := '0';
        enc_en   : IN STD_LOGIC := '0';
        msg_in   : IN STD_LOGIC_VECTOR(0 TO MSG_SERIAL'length / SERIAL_MSG_RATIO - 1);
        code_in  : IN STD_LOGIC_VECTOR(0 TO CODEWORD_SERIAL'length / SERIAL_CODE_RATIO - 1);
        code_out : OUT STD_LOGIC_VECTOR(0 TO CODEWORD_SERIAL'length / SERIAL_CODE_RATIO - 1);
        msg_out  : OUT STD_LOGIC_VECTOR(0 TO MSG_SERIAL'length / SERIAL_MSG_RATIO - 1);
        enc_rdy  : OUT STD_LOGIC;
        dec_rdy  : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF top_level IS
BEGIN
    encoder_mxio_inst : ENTITY work.encoder_mxio
        GENERIC MAP(
            MSG_RATIO  => SERIAL_MSG_RATIO,
            CODE_RATIO => SERIAL_CODE_RATIO,
            IO_CONTROL => IN_BUFFER & OUT_FILL
        )
        PORT MAP(
            msg   => msg_in,
            code  => code_out,
            clk   => enc_en AND clk,
            ready => enc_rdy
        );
    decoder_mxio_inst : ENTITY work.decoder_mxio
        GENERIC MAP(
            MSG_RATIO    => SERIAL_MSG_RATIO,
            CODE_RATIO   => SERIAL_CODE_RATIO,
            IO_CONTROL   => IN_BUFFER & OUT_FILL,
            DECODER_TYPE => DECODER_TYPE
        )
        PORT MAP(
            code  => code_in,
            msg   => msg_out,
            clk   => dec_en AND clk,
            ready => dec_rdy
        );

END ARCHITECTURE;