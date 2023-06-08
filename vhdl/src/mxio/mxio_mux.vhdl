LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;

ENTITY mxio_mux IS
    PORT (
        sel     : IN STD_LOGIC;
        input_0 : IN MXIO;
        input_1 : IN MXIO;
        output  : OUT MXIO
    );
END ENTITY;
ARCHITECTURE rtl OF mxio_mux IS
BEGIN

    PROCESS (sel, input_0, input_1)
    BEGIN
        IF sel = '1' THEN
            output <= input_1;
        ELSE
            output <= input_0;
        END IF;
    END PROCESS;

END ARCHITECTURE rtl;