LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;

ENTITY bypassable_transposer IS
    GENERIC (
        row_count : NATURAL := 0;
        col_count : NATURAL := 0
    );
    PORT (
        input  : IN MXIO;
        output : OUT MXIO;
        bypass : IN STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF bypassable_transposer IS
    SIGNAL transposer : MXIO(input'RANGE)(input'RANGE(1));
BEGIN
    transposer_inst : ENTITY work.mxio_transposer
        GENERIC MAP(
            row_count => row_count,
            col_count => col_count
        )
        PORT MAP(
            input  => input,
            output => transposer
        );

    PROCESS (ALL)
    BEGIN
        IF bypass = '1' THEN
            output <= input;
        ELSE
            output <= transposer;
        END IF;
    END PROCESS;
END ARCHITECTURE rtl;