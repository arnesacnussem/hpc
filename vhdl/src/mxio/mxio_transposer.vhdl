LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.types.ALL;

ENTITY mxio_transposer IS
    GENERIC (
        row_count : NATURAL := 0;
        col_count : NATURAL := 0
    );
    PORT (
        input  : IN MXIO;
        output : OUT MXIO
    );
END ENTITY;

ARCHITECTURE rtl OF mxio_transposer IS
BEGIN
    r : FOR row IN 0 TO row_count GENERATE
        c : FOR col IN 0 TO col_count GENERATE
            wire : output(col)(row) <= input(row)(col);
        END GENERATE;
    END GENERATE;
END ARCHITECTURE rtl;