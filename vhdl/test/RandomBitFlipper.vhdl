LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE work.types.ALL;
USE work.constants.ALL;

ENTITY RandomBitFlipper IS
    GENERIC (
        FLIP_COUNT : NATURAL := 7 -- default to flipping 7 bits if not specified
    );
    PORT (
        enable : IN STD_LOGIC := '0';
        matIn  : IN MXIO;
        matOut : OUT MXIO
    );
END ENTITY RandomBitFlipper;

ARCHITECTURE rtl OF RandomBitFlipper IS
BEGIN
    PROCESS (enable)
        VARIABLE temp      : MXIO(matIn'RANGE)(matIn'RANGE(1));
        VARIABLE row_index : INTEGER;
        VARIABLE col_index : INTEGER;

        VARIABLE seed1                     : INTEGER := 150006;
        VARIABLE seed2                     : INTEGER := 85613;
        IMPURE FUNCTION rand_int(min_val, max_val : INTEGER) RETURN INTEGER IS
            VARIABLE r                                : real;
        BEGIN
            uniform(seed1, seed2, r);
            RETURN INTEGER(
            round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
        END FUNCTION;
    BEGIN
        IF enable THEN
            -- Copy input signal to temp variable
            temp := matIn;

            -- Flip FLIP_COUNT random bits in temp variable
            FOR i IN 1 TO FLIP_COUNT LOOP
                -- Generate a random index for the row and column
                -- to modify
                row_index := rand_int(0, matIn'length - 1);
                col_index := rand_int(0, matIn'length(1) - 1);
                REPORT LF & "[RBF] flip(:" & INTEGER'image(i) & "): (" & INTEGER'image(row_index) & ", " & INTEGER'image(col_index) & ")";

                -- Toggle the bit at the specified row and column index
                temp(row_index)(col_index) := NOT temp(row_index)(col_index);
            END LOOP;

            -- Output the modified signal on matOut
            matOut <= temp;
        END IF;

    END PROCESS;
END ARCHITECTURE rtl;