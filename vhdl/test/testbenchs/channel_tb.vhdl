LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;
USE work.constants.ALL;
USE work.test_data.ALL;

ENTITY channel_tb IS
END;

ARCHITECTURE bench OF channel_tb IS

    COMPONENT channel
        PORT (
            en      : IN STD_LOGIC;
            dat_in  : IN CODEWORD_MAT;
            dat_out : OUT CODEWORD_MAT;
            ready   : OUT STD_LOGIC
        );
    END COMPONENT;
    COMPONENT encoder
        PORT (
            msg     : IN MSG_MAT;
            gen     : IN GEN_MAT;
            encoded : OUT CODEWORD_MAT;
            ready   : OUT STD_LOGIC;
            rst     : IN STD_LOGIC;
            clk     : IN STD_LOGIC
        );
    END COMPONENT;
    -- Clock period
    CONSTANT clk_period : TIME := 5 ns;
    -- Generics

    -- Ports
    SIGNAL en        : STD_LOGIC;
    SIGNAL enc_ready : STD_LOGIC;
    SIGNAL chn_ready : STD_LOGIC;
    SIGNAL dat_in    : CODEWORD_MAT;
    SIGNAL dat_out   : CODEWORD_MAT;
    SIGNAL msg       : MSG_MAT   := MESSAGE_MATRIX;
    SIGNAL gen       : GEN_MAT   := GENERATE_MATRIX;
    SIGNAL rst       : STD_LOGIC := '0';
    SIGNAL clk       : STD_LOGIC := '0';

BEGIN

    channel_inst : channel
    PORT MAP(
        en      => en,
        ready   => chn_ready,
        dat_in  => dat_in,
        dat_out => dat_out
    );
    encoder_inst : encoder
    PORT MAP(
        msg     => msg,
        gen     => gen,
        encoded => dat_in,
        ready   => enc_ready,
        rst     => rst,
        clk     => clk
    );

    PROCESS (enc_ready)
    BEGIN
        IF rising_edge(enc_ready) THEN
            en <= '1';
        ELSE
            en <= '0';
        END IF;
    END PROCESS;

    PROCESS
    BEGIN
        rst <= '1';
        WAIT FOR 1 ps;
        rst <= '0';
        WAIT FOR 1 ps;
        clk <= '1';
        WAIT FOR 1 ps;
        WAIT;
    END PROCESS;
END;