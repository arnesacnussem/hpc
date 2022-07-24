LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.types.ALL;

ENTITY channel_tb IS
END;

ARCHITECTURE bench OF channel_tb IS

    COMPONENT channel
        PORT (
            clk     : IN STD_LOGIC;
            en      : IN STD_LOGIC;
            dat_in  : IN CODEWORD_MAT;
            dat_out : OUT CODEWORD_MAT
        );
    END COMPONENT;

    -- Clock period
    CONSTANT clk_period : TIME := 5 ns;
    -- Generics

    -- Ports
    SIGNAL clk     : STD_LOGIC;
    SIGNAL en      : STD_LOGIC;
    SIGNAL dat_in  : CODEWORD_MAT;
    SIGNAL dat_out : CODEWORD_MAT;

BEGIN

    channel_inst : channel
    PORT MAP(
        clk     => clk,
        en      => en,
        dat_in  => dat_in,
        dat_out => dat_out
    );
END;