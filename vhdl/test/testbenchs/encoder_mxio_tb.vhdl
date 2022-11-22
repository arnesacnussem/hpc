LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.generated.ALL;
USE work.test_data.ALL;

ENTITY encoder_mxio_tb IS
END;

ARCHITECTURE bench OF encoder_mxio_tb IS
    -- Clock period
    CONSTANT clk_period : TIME := 2 ps;
    -- Generics
    CONSTANT MSG_RATIO  : POSITIVE           := 4;
    CONSTANT CODE_RATIO : POSITIVE           := 7;
    CONSTANT IO_CONTROL : BIT_VECTOR(0 TO 1) := "10";

    -- Ports
    SIGNAL msg        : BIT_VECTOR(0 TO MSG_SERIAL'length / MSG_RATIO - 1);
    SIGNAL code       : BIT_VECTOR(0 TO CODEWORD_SERIAL'length / CODE_RATIO - 1);
    SIGNAL clk        : STD_LOGIC := '0';
    SIGNAL device_clk : STD_LOGIC := '0';
    SIGNAL ready      : STD_LOGIC;

    SIGNAL exit1 : BOOLEAN := false;
BEGIN

    encoder_mxio_inst : ENTITY work.encoder_mxio
        GENERIC MAP(
            MSG_RATIO  => MSG_RATIO,
            CODE_RATIO => CODE_RATIO,
            IO_CONTROL => IO_CONTROL
        )
        PORT MAP(
            msg   => msg,
            code  => code,
            clk   => clk,
            ready => ready
        );

    clk_process : PROCESS
    BEGIN
        clk <= NOT clk;
        WAIT FOR clk_period/2;
        IF exit1 THEN
            WAIT;
        END IF;
    END PROCESS clk_process;

    PROCESS
        VARIABLE pos : NATURAL := 0;
    BEGIN
        IF pos < MESSAGE_SERIAL'length THEN
            FOR i IN msg'RANGE LOOP
                msg(i) <= MESSAGE_SERIAL(pos + i);
            END LOOP;
            device_clk <= NOT device_clk;
            REPORT "[TB] line wrote";
            pos := pos + msg'length;
        ELSE
            device_clk <= clk;
            WAIT UNTIL ready = '1';
            exit1 <= true;
            WAIT;
        END IF;
        WAIT UNTIL rising_edge(clk);
    END PROCESS;
END;