LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.uniform;
USE ieee.math_real.round;
USE work.generated.ALL;

ENTITY channel IS
    GENERIC (
        CHANNEL_ERROR_RATE : INTEGER := 3
    );
    PORT (
        en      : IN STD_LOGIC;
        ready   : OUT STD_LOGIC := '0';
        dat_in  : IN CODEWORD_MAT;
        dat_out : OUT CODEWORD_MAT
    );
END channel;

ARCHITECTURE DataChannel OF channel IS
    TYPE CH_STATE_TYPE IS (DISABLED, ENABLED);
    SIGNAL STATE : CH_STATE_TYPE := DISABLED;

BEGIN
    unit_state : PROCESS (en)
    BEGIN
        IF en = '1' THEN
            STATE <= ENABLED;
            REPORT "CHANNEL ENABLED";
        ELSE
            STATE <= DISABLED;
            REPORT "CHANNEL DISABLED";
        END IF;
    END PROCESS;

    PROCESS (STATE)
        VARIABLE shouldError  : STD_LOGIC;
        VARIABLE seed1, seed2 : INTEGER := 999;
        VARIABLE err_bits     : real    := 0.0;
        VARIABLE err_rate     : real    := 0.0;

        IMPURE FUNCTION rand_real(min_val, max_val : real) RETURN real IS
            VARIABLE r                                 : real;
        BEGIN
            uniform(seed1, seed2, r);
            RETURN r * (max_val - min_val) + min_val;
        END FUNCTION;
    BEGIN
        CASE(STATE) IS
            WHEN ENABLED =>
            IF ready = '0' THEN
                REPORT "Start transport";
                FOR row IN 0 TO dat_in'length - 1 LOOP
                    FOR col IN 0 TO dat_in(0)'length - 1 LOOP
                        IF rand_real(0.0, 100.0) < real(CHANNEL_ERROR_RATE) THEN
                            shouldError := '1';
                            REPORT "Channel error at (" & INTEGER'image(row) & ", " & INTEGER'image(col) & ")";
                        ELSE
                            shouldError := '0';
                        END IF;
                        IF shouldError THEN
                            dat_out(row)(col) <= NOT dat_in(row)(col);
                            err_bits := err_bits + 1.0;
                        ELSE
                            dat_out(row)(col) <= dat_in(row)(col);
                        END IF;
                    END LOOP;
                END LOOP;
                REPORT "Overall channel error rate = " & real'image((err_bits / real(dat_in'length * dat_in(0)'length)) * 100.0) & "%";
                ready <= '1';
                REPORT "Finished transport";
            END IF;
            WHEN DISABLED =>
        END CASE;

    END PROCESS;

END ARCHITECTURE;