LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;

ENTITY decoder_mxio IS
    GENERIC (
        MSG_RATIO  : POSITIVE := MSG_SERIAL'length;
        CODE_RATIO : POSITIVE := CODEWORD_SERIAL'length;
        -- [0]: 输入缓存
        -- [1]: 输出填充
        IO_CONTROL : BIT_VECTOR(0 TO 1) := "10"
    );
    PORT (
        code  : IN BIT_VECTOR(0 TO CODEWORD_SERIAL'length / CODE_RATIO - 1);
        msg   : OUT BIT_VECTOR(0 TO MSG_SERIAL'length / MSG_RATIO - 1);
        clk   : IN STD_LOGIC;
        ready : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE encoder_mxio OF decoder_mxio IS
    SIGNAL msg_matrix  : MSG_MAT;
    SIGNAL code_matrix : CODEWORD_MAT;
    SIGNAL rst         : STD_LOGIC              := '0';
    SIGNAL in_port     : BIT_VECTOR(code'RANGE) := code;
    SIGNAL out_port    : BIT_VECTOR(msg'RANGE)  := msg;

    -- [0] mxio_in_ready
    -- [1] codec_ready
    -- [2] mxio_out_ready
    SIGNAL state : STD_ULOGIC_VECTOR(0 TO 2) := "000";

    -- clock control
    SIGNAL mxio_in_clk  : STD_LOGIC;
    SIGNAL codec_clk    : STD_LOGIC;
    SIGNAL mxio_out_clk : STD_LOGIC;
BEGIN
    dec_mxio_in : ENTITY work.matrix_io
        GENERIC MAP(
            COL_CNT  => CODEWORD_LINE'length,
            ROW_CNT  => CODEWORD_MAT'length,
            IO_WIDTH => code'length,
            IO_MODE  => '0' & IO_CONTROL(0)
        )
        PORT MAP(
            io_port => in_port,
            matrix  => code_matrix,
            clk     => mxio_in_clk,
            ready   => state(0)
        );

    decoder_inst : ENTITY work.decoder
        PORT MAP(
            code  => code_matrix,
            msg   => msg_matrix,
            ready => state(1),
            rst   => rst,
            clk   => codec_clk
        );
    dec_mxio_out : ENTITY work.matrix_io
        GENERIC MAP(
            COL_CNT  => MSG_LINE'length,
            ROW_CNT  => MSG_MAT'length,
            IO_WIDTH => msg'length,
            IO_MODE  => '1' & IO_CONTROL(1)
        )
        PORT MAP(
            io_port => out_port,
            matrix  => msg_matrix,
            clk     => mxio_out_clk,
            ready   => state(2)
        );

    PROCESS (ALL)
    BEGIN
        in_port <= code;
        msg     <= out_port;
        ready   <= state(2);
        CASE state IS
            WHEN "000" =>
                mxio_in_clk  <= clk;
                codec_clk    <= '0';
                mxio_out_clk <= '0';
            WHEN "100" =>
                mxio_in_clk  <= '0';
                codec_clk    <= clk;
                mxio_out_clk <= '0';
            WHEN "110" =>
                mxio_in_clk  <= '0';
                codec_clk    <= '0';
                mxio_out_clk <= clk;
            WHEN OTHERS =>
                mxio_in_clk  <= '0';
                codec_clk    <= '0';
                mxio_out_clk <= '0';
        END CASE;
    END PROCESS;
END ARCHITECTURE;